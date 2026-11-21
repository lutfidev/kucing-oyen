import 'dart:math' as math;
import 'dart:ui';

import '../../game/model/home_items.dart';
import '../../game/model/house.dart';
import '../../game/model/kitties.dart';
import '../../game/model/room_life.dart';
import '../../game/render/room_item_art.dart';

/// Area rumah desain (layar 390×844, panel bawah mulai y 652).
const designRoomWidth = 390.0;
const designRoomHeight = 652.0;

/// Ukuran sprite kucing di garis kedalaman skala 1 (Oyen lebih besar).
const oyenRoomSize = 116.0;
const kittyRoomSize = 96.0;

/// Kaki kucing di 92% tinggi kotak sprite: dipakai untuk urutan gambar.
const catFeetFactor = 0.92;

/// Garis kaki paling belakang di lantai (zona Hias, `HouseFloor`).
const designFloorBack = 398.0;

/// Lompatan kucing ke barang dinding, dalam px desain (dikali `artScale`):
/// paling tinggi [catHopUp] untuk lompatan ke barang dinding (naik ke
/// pijakan tidak dibatasi: kucing memanjat perabot), dan pijakan paling jauh
/// [catHopDepth] dari garis lantai belakang (ke depan) dan [catHopSide] ke
/// samping dari kucing di barangnya.
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

/// Peta [Spot] ke kotak layar untuk ruangan [which] seukuran [room]
/// (desain rumah dua ruangan). Posisi mengikuti [sx]/[sy] (viewBox
/// 390×652 diskalakan seperti lapisan latar, catatan `n360`); ukuran
/// sprite mengikuti [artScale] (rata-rata keduanya) × skala kedalaman.
class RoomGeometry {
  RoomGeometry(this.room, [this.which = HouseRoom.living]);

  final Size room;
  final HouseRoom which;

  static const _floor = HouseFloor();

  double get sx => room.width / designRoomWidth;
  double get sy => room.height / designRoomHeight;

  double get artScale => ((sx + sy) / 2).clamp(0.6, 1.2);

  Offset toScreen(double x, double y) => Offset(x * sx, y * sy);

  /// Dinding belakang ruang tengah untuk barang dinding.
  Rect get wallZone => Rect.fromLTRB(
    houseWallLeft * sx,
    houseWallTop * sy,
    houseWallRight * sx,
    houseWallBottom * sy,
  );

  Size _wallSize(RoomItem item) =>
      Size(item.baseWidth, item.baseHeight) * houseWallScale;

  Size _floorSize(RoomItem item, double scale) =>
      Size(item.baseWidth, item.baseHeight) * (scale * artScale);

  Rect boxOf(RoomItem item, Spot spot) {
    if (item.zone == RoomZone.wall) {
      final size = _wallSize(item);
      final left =
          houseWallLeft +
          spot.x * (houseWallRight - houseWallLeft - size.width);
      final top =
          houseWallTop +
          spot.y * (houseWallBottom - houseWallTop - size.height);
      return toScreen(left, top) & size * artScale;
    }
    final feet = _floor.itemFeet(item, spot);
    final size = _floorSize(item, feet.scale);
    final at = toScreen(feet.x, feet.y);
    // Dijepit lagi di layar: di layar lebar artScale bisa lebih dari sx.
    final half = size.width / 2;
    final x = at.dx.clamp(half, math.max(half, room.width - half)).toDouble();
    return Rect.fromLTWH(
      x - half,
      at.dy - size.height,
      size.width,
      size.height,
    );
  }

  /// [Spot] untuk [item] dengan pojok kiri-atas di [topLeft] (dijepit).
  Spot spotFor(RoomItem item, Offset topLeft) {
    if (item.zone == RoomZone.wall) {
      final size = _wallSize(item);
      double unit(double v, double from, double span) =>
          span <= 0 ? 0 : (v - from) / span;
      return Spot(
        unit(
          topLeft.dx / sx,
          houseWallLeft,
          houseWallRight - houseWallLeft - size.width,
        ),
        unit(
          topLeft.dy / sy,
          houseWallTop,
          houseWallBottom - houseWallTop - size.height,
        ),
      );
    }
    // Tinggi gambar bergantung pada kedalaman kakinya: cari titik tetapnya.
    var feetY = topLeft.dy / sy;
    for (var i = 0; i < 6; i++) {
      final size = _floorSize(item, depthScale(feetY));
      feetY = (topLeft.dy + size.height) / sy;
    }
    final size = _floorSize(item, depthScale(feetY));
    return _floor.spotAtFeet((topLeft.dx + size.width / 2) / sx, feetY);
  }

  double _catBase(KittyId kitty) =>
      kitty == KittyId.oyen ? oyenRoomSize : kittyRoomSize;

  /// Sisi kotak kucing [kitty] dengan kaki di [feetY] (px layar).
  double catSizeAt(KittyId kitty, double feetY) =>
      _catBase(kitty) * depthScale(feetY / sy) * artScale;

  /// Kotak kucing [kitty] di [spot]; tengahnya dijepit supaya badannya
  /// tetap di layar (zona kaki sampai x 4–386, kucing lebih lebar dari itu).
  Rect catBoxOf(KittyId kitty, Spot spot) {
    final feet = _floor.feetAt(spot);
    final at = toScreen(feet.x, feet.y);
    final half = catSizeAt(kitty, at.dy) / 2;
    final x = at.dx.clamp(half, math.max(half, room.width - half)).toDouble();
    return catBoxAtFeet(kitty, x, at.dy);
  }

  double feetOf(Rect catBox) => catBox.top + catBox.height * catFeetFactor;

  /// [Spot] kucing [kitty] untuk kotak sprite [box] (kebalikan [catBoxOf],
  /// dijepit ke lantai).
  Spot catSpotAt(KittyId kitty, Rect box) =>
      _floor.spotAtFeet(box.center.dx / sx, feetOf(box) / sy);

  /// Kotak kucing [kitty] dengan tengah di [centerX] dan kaki di [feet]
  /// (px layar), seukuran kedalamannya.
  Rect catBoxAtFeet(KittyId kitty, double centerX, double feet) {
    final size = catSizeAt(kitty, feet);
    return Rect.fromLTWH(
      centerX - size / 2,
      feet - size * catFeetFactor,
      size,
      size,
    );
  }

  /// Barang dipakai digambar terbalik kalau kotak biasanya keluar tepi
  /// kiri atau kanan ruangan (mis. tiang garukan di pojok kiri).
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

  /// Rute kucing [kitty] untuk memakai barang [id] di ruangan berisi
  /// [placed], atau null kalau tidak bisa dipakai (hiasan saja, atau
  /// barang dinding yang terlalu tinggi tanpa pijakan di dekatnya).
  ///
  /// Barang lantai: berdiri dengan kaki dan tengah di kucing barangnya.
  /// Barang dinding: lompat langsung dari garis lantai paling belakang
  /// kalau cukup rendah, selain itu lewat pijakan terdekat (berdiri di
  /// depannya, naik ke permukaannya, lalu ke barangnya).
  ItemPath? pathTo(KittyId kitty, RoomItemId id, Map<RoomItemId, Spot> placed) {
    final spot = placed[id];
    if (spot == null || lifeDecorOnly.contains(id)) return null;
    final item = roomItemOf(id);
    final user = userBoxOf(id, boxOf(item, spot));
    final userFeet = feetOf(user);
    Rect onFloor(double centerX, double feet) =>
        catBoxOf(kitty, catSpotAt(kitty, catBoxAtFeet(kitty, centerX, feet)));

    ItemPath path(List<Rect> boxes, int hops) =>
        ItemPath(catSpotAt(kitty, boxes.first), boxes, hops: hops);

    if (item.zone == RoomZone.floor) {
      return path([onFloor(user.center.dx, userFeet), user], 0);
    }
    final base = designFloorBack * sy;
    final up = catHopUp * artScale;
    if (base - userFeet <= up) {
      return path([onFloor(user.center.dx, base), user], 1);
    }
    (double, Rect, Rect)? best;
    for (final MapEntry(key: perchId, value: perchSpot) in placed.entries) {
      final top = perchTops[perchId];
      if (top == null) continue;
      final box = boxOf(roomItemOf(perchId), perchSpot);
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
        // Kucing di pijakan dekat tepi tetap di dalam ruangan.
        final size = catSizeAt(kitty, surface);
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

  /// Kotak tetap desain (bidang kosong, gelembung, panduan) ke layar:
  /// posisi ikut [sx]/[sy]; ukuran ikut [artScale], atau dengan [stretch]
  /// lebar ikut [sx] dan tinggi ikut [sy].
  Rect fromDesign(Rect design, {bool stretch = false}) {
    final size = stretch
        ? Size(design.width * sx, design.height * sy)
        : design.size * artScale;
    return toScreen(design.left, design.top) & size;
  }
}

/// Satu benda yang digambar di ruangan, urut [roomSprites].
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

/// Urutan gambar ruangan: barang rata (karpet), barang dinding, lalu
/// barang lantai dan kucing menurut garis kakinya (yang lebih bawah di
/// depan).
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
