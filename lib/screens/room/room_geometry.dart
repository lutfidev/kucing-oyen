import 'dart:math' as math;
import 'dart:ui';

import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/room_life.dart';
import '../../game/render/room_item_art.dart';

// Ukuran kamar di `Kamar.dc.html` (layar 390×844, panel bawah mulai 652):
// dinding 0–412, trim 412–426, lantai 426–652.
const designRoomWidth = 390.0;
const designRoomHeight = 652.0;
const designWallHeight = 412.0;
const designTrimHeight = 14.0;
const designFloorTop = 426.0;

/// Ukuran sprite kucing di kamar desain (Oyen lebih besar).
const oyenRoomSize = 116.0;
const kittyRoomSize = 96.0;

/// Kaki kucing di 92% tinggi kotak sprite: dipakai untuk urutan gambar.
const catFeetFactor = 0.92;

/// Lompatan kucing ke barang dinding, dalam px desain (dikali `artScale`):
/// paling tinggi [catHopUp] untuk lompatan ke barang dinding (naik ke
/// pijakan tidak dibatasi: kucing memanjat perabot), dan pijakan paling jauh
/// [catHopDepth] dari kaki dinding (ke depan) dan [catHopSide] ke samping
/// dari kucing di barangnya.
const catHopUp = 100.0;
const catHopDepth = 120.0;
const catHopSide = 120.0;

/// Lengkung lompatan (px desain, dikali `artScale`).
const catHopArc = 18.0;

/// Barang lantai yang bisa jadi pijakan, dan tinggi permukaannya dari tepi
/// atas gambar (px gambar desain): puncak tiang, sandaran sofa, bibir
/// kardus, tutup akuarium. Atap rumah kucing runcing, jadi bukan pijakan.
const perchTops = <RoomItemId, double>{
  RoomItemId.tiang: 4,
  RoomItemId.sofaMini: 8,
  RoomItemId.kardus: 24,
  RoomItemId.akuarium: 4,
};

/// Rute seekor kucing ke barang: [stand] = tempat berdiri di lantai,
/// [boxes] = kotak kucing dari tempat berdiri, pijakan (kalau ada), sampai
/// kucing di dalam barang. [hops] = jumlah lompatan (0 = barang lantai).
class ItemPath {
  const ItemPath(this.stand, this.boxes, {required this.hops});

  final Spot stand;
  final List<Rect> boxes;
  final int hops;
}

/// Kotak kucing yang sedang melompat sepanjang [boxes] pada kemajuan
/// [progress] 0–1 (lompatan sama panjang), melengkung setinggi [arc].
Rect hopBox(List<Rect> boxes, double progress, {required double arc}) {
  final hops = boxes.length - 1;
  final p = progress.clamp(0.0, 1.0) * hops;
  final i = math.min(p.floor(), hops - 1);
  final raw = p - i;
  final t = raw * raw * (3 - 2 * raw);
  final box = Rect.lerp(boxes[i], boxes[i + 1], t)!;
  return box.translate(0, -math.sin(math.pi * raw) * arc);
}

/// Peta [Spot] ke kotak layar untuk kamar seukuran [room]. Lebar
/// mengikuti `scale`, gambar mengikuti `artScale` (rata-rata skala lebar
/// dan tinggi, catatan `n360`), dinding dan lantai membagi tinggi kamar
/// sebanding desain.
class RoomGeometry {
  RoomGeometry(this.room);

  final Size room;

  double get scale => room.width / designRoomWidth;

  double get artScale =>
      ((scale + room.height / designRoomHeight) / 2).clamp(0.6, 1.2);

  Rect get wall => Rect.fromLTWH(
    0,
    0,
    room.width,
    room.height * designWallHeight / designRoomHeight,
  );

  Rect get trim =>
      Rect.fromLTWH(0, wall.bottom, room.width, designTrimHeight * scale);

  Rect get floor => Rect.fromLTRB(0, trim.bottom, room.width, room.height);

  double get _wallUnit => wall.height / designWallHeight;

  double get _floorUnit => floor.height / (designRoomHeight - designFloorTop);

  Size sizeOf(RoomItem item) => Size(item.width, item.height) * artScale;

  /// Rentang pojok kiri-atas kotak seukuran [box] di [zone].
  Rect rangeOf(RoomZone zone, Size box) => switch (zone) {
    RoomZone.wall => Rect.fromLTRB(
      wallLeft * scale,
      wallTop * _wallUnit,
      room.width - (designRoomWidth - wallRight) * scale - box.width,
      wallBottom * _wallUnit - box.height,
    ),
    RoomZone.floor => Rect.fromLTRB(
      floorLeft * scale,
      _floorY(floorTop) - box.height,
      room.width - (designRoomWidth - floorRight) * scale - box.width,
      _floorY(floorBottom) - box.height,
    ),
  };

  double _floorY(double designY) =>
      floor.top + (designY - designFloorTop) * _floorUnit;

  Rect boxOf(RoomItem item, Spot spot) {
    final size = sizeOf(item);
    return _place(rangeOf(item.zone, size), spot) & size;
  }

  /// [Spot] untuk [item] dengan pojok kiri-atas di [topLeft] (dijepit).
  Spot spotFor(RoomItem item, Offset topLeft) {
    final range = rangeOf(item.zone, sizeOf(item));
    double unit(double v, double from, double span) =>
        span == 0 ? 0 : (v - from) / span;
    return Spot(
      unit(topLeft.dx, range.left, range.width),
      unit(topLeft.dy, range.top, range.height),
    );
  }

  double catSize(KittyId kitty) =>
      (kitty == KittyId.oyen ? oyenRoomSize : kittyRoomSize) * artScale;

  Rect catBoxOf(KittyId kitty, Spot spot) {
    final size = Size.square(catSize(kitty));
    return _place(rangeOf(RoomZone.floor, size), spot) & size;
  }

  double feetOf(Rect catBox) => catBox.top + catBox.height * catFeetFactor;

  /// [Spot] kucing [kitty] untuk kotak sprite [box] (kebalikan [catBoxOf],
  /// dijepit ke lantai).
  Spot catSpotAt(KittyId kitty, Rect box) {
    final range = rangeOf(RoomZone.floor, Size.square(catSize(kitty)));
    double unit(double v, double from, double span) =>
        span == 0 ? 0 : (v - from) / span;
    return Spot(
      unit(box.left, range.left, range.width),
      unit(box.top, range.top, range.height),
    );
  }

  /// Kotak kucing [kitty] dengan tengah di [centerX] dan kaki di [feet].
  Rect catBoxAtFeet(KittyId kitty, double centerX, double feet) {
    final size = catSize(kitty);
    return Rect.fromLTWH(
      centerX - size / 2,
      feet - size * catFeetFactor,
      size,
      size,
    );
  }

  /// Barang dipakai digambar terbalik kalau kotak biasanya keluar tepi
  /// kiri atau kanan kamar (mis. tiang garukan di pojok kiri).
  bool mirrorsInUse(RoomItemId id, Rect box) {
    final plain = RoomItemArt.inUseBox(id, box);
    if (plain.left >= 0 && plain.right <= room.width) return false;
    final flipped = RoomItemArt.inUseBox(id, box, mirror: true);
    double outside(Rect r) =>
        math.max(0.0, -r.left) + math.max(0.0, r.right - room.width);
    return outside(flipped) < outside(plain);
  }

  /// Kotak kucing di barang [id] (kotak diam [box]) yang sedang dipakai.
  Rect userBoxOf(RoomItemId id, Rect box) {
    final mirror = mirrorsInUse(id, box);
    return RoomItemArt.catBox(
      id,
      RoomItemArt.inUseBox(id, box, mirror: mirror),
      mirror: mirror,
    );
  }

  /// Rute kucing [kitty] untuk memakai barang [id] di kamar berisi
  /// [placed], atau null kalau tidak bisa dipakai (hiasan saja, atau
  /// barang dinding yang terlalu tinggi tanpa pijakan di dekatnya).
  ///
  /// Barang lantai: berdiri dengan kaki dan tengah di kucing barangnya.
  /// Barang dinding: lompat langsung dari lantai paling belakang kalau
  /// cukup rendah, selain itu lewat pijakan terdekat (berdiri di depannya,
  /// naik ke permukaannya, lalu ke barangnya).
  ItemPath? pathTo(KittyId kitty, RoomItemId id, Map<RoomItemId, Spot> placed) {
    final spot = placed[id];
    if (spot == null || lifeDecorOnly.contains(id)) return null;
    final item = roomItemOf(id);
    final user = userBoxOf(id, boxOf(item, spot));
    final userFeet = feetOf(user);
    final range = rangeOf(RoomZone.floor, Size.square(catSize(kitty)));
    Rect onFloor(double centerX, double feet) {
      final box = catBoxAtFeet(kitty, centerX, feet);
      final left = box.left.clamp(range.left, range.right);
      final top = box.top.clamp(range.top, range.bottom);
      return Offset(left, top) & box.size;
    }

    ItemPath path(List<Rect> boxes, int hops) =>
        ItemPath(catSpotAt(kitty, boxes.first), boxes, hops: hops);

    if (item.zone == RoomZone.floor) {
      return path([onFloor(user.center.dx, userFeet), user], 0);
    }
    final base = floor.top;
    final up = catHopUp * artScale;
    if (base - userFeet <= up) {
      return path([onFloor(user.center.dx, userFeet), user], 1);
    }
    (double, Rect, Rect)? best;
    for (final MapEntry(key: perchId, value: perchSpot) in placed.entries) {
      final top = perchTops[perchId];
      if (top == null) continue;
      final perch = roomItemOf(perchId);
      final box = boxOf(perch, perchSpot);
      final surface =
          box.top + top * box.height / RoomItemArt.sizeOf(perchId).height;
      final side = (box.center.dx - user.center.dx).abs();
      // Tinggi dihitung dari lantai, bukan dari layar: pijakan yang lebih
      // depan tampak lebih rendah di layar, padahal setinggi barangnya.
      if (box.bottom - base > catHopDepth * artScale ||
          side > catHopSide * artScale ||
          (base - userFeet) - (box.bottom - surface) > up) {
        continue;
      }
      if (best == null || side < best.$1) {
        // Kucing di pijakan dekat tepi tetap di dalam kamar.
        final size = catSize(kitty);
        final x = box.center.dx.clamp(size / 2, room.width - size / 2);
        best = (side, box, catBoxAtFeet(kitty, x, surface));
      }
    }
    if (best == null) return null;
    final (_, perchBox, onPerch) = best;
    return path([
      onFloor(perchBox.center.dx, perchBox.bottom),
      onPerch,
      user,
    ], 2);
  }

  /// Kotak tetap desain (jendela, bidang kosong, panduan zona) ke layar.
  /// Tepi atas di dinding atau lantai mengikuti zonanya; ukuran ikut
  /// `artScale`, atau dengan [stretch] lebar ikut `scale` dan tinggi ikut
  /// zonanya.
  Rect fromDesign(Rect design, {bool stretch = false}) {
    final onWall = design.top < designFloorTop;
    final top = onWall ? design.top * _wallUnit : _floorY(design.top);
    final size = stretch
        ? Size(
            design.width * scale,
            design.height * (onWall ? _wallUnit : _floorUnit),
          )
        : design.size * artScale;
    return Offset(design.left * scale, top) & size;
  }

  static Offset _place(Rect range, Spot spot) =>
      range.topLeft + Offset(spot.x * range.width, spot.y * range.height);
}

/// Satu benda yang digambar di kamar, urut [roomSprites].
sealed class RoomSprite {
  const RoomSprite(this.box);

  final Rect box;
}

class ItemSprite extends RoomSprite {
  const ItemSprite(this.id, super.box, {this.flat = false});

  final RoomItemId id;
  final bool flat;
}

class KittySprite extends RoomSprite {
  const KittySprite(this.kitty, super.box);

  final KittyId kitty;
}

/// Urutan gambar kamar: barang rata (karpet), barang dinding, lalu barang
/// lantai dan kucing menurut tepi bawahnya (yang lebih bawah di depan).
List<RoomSprite> roomSprites({
  required Map<RoomItemId, Spot> items,
  required Map<KittyId, Spot> cats,
  required RoomGeometry geo,
}) {
  final placed = [
    for (final item in roomItems)
      if (items[item.id] case final spot?) (item, geo.boxOf(item, spot)),
  ];
  final standing = <(double, RoomSprite)>[
    for (final (item, box) in placed)
      if (item.zone == RoomZone.floor && !item.flat)
        (box.bottom, ItemSprite(item.id, box)),
    for (final MapEntry(key: kitty, value: spot) in cats.entries)
      if (geo.catBoxOf(kitty, spot) case final box)
        (geo.feetOf(box), KittySprite(kitty, box)),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  return [
    for (final (item, box) in placed)
      if (item.flat) ItemSprite(item.id, box, flat: true),
    for (final (item, box) in placed)
      if (item.zone == RoomZone.wall) ItemSprite(item.id, box),
    for (final (_, sprite) in standing) sprite,
  ];
}
