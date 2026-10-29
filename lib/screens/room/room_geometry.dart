import 'dart:ui';

import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';

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
