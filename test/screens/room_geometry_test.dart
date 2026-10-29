import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';

void main() {
  test('kamar desain: dinding, trim, dan lantai seperti Kamar.dc.html', () {
    final geo = RoomGeometry(const Size(390, 652));
    expect(geo.scale, 1);
    expect(geo.artScale, 1);
    expect(geo.wall, const Rect.fromLTRB(0, 0, 390, 412));
    expect(geo.trim, const Rect.fromLTRB(0, 412, 390, 426));
    expect(geo.floor, const Rect.fromLTRB(0, 426, 390, 652));
  });

  test('rentang barang dinding dan lantai sama dengan batas seret desain', () {
    final geo = RoomGeometry(const Size(390, 652));
    final lukisan = roomItemOf(RoomItemId.lukisan);
    final wall = geo.rangeOf(RoomZone.wall, geo.sizeOf(lukisan));
    expect(wall.left, wallLeft);
    expect(wall.right, closeTo(wallRight - lukisan.width, 1e-9));
    expect(wall.top, wallTop);
    expect(wall.bottom, closeTo(wallBottom - lukisan.height, 1e-9));
    final kasur = roomItemOf(RoomItemId.kasur);
    final floor = geo.rangeOf(RoomZone.floor, geo.sizeOf(kasur));
    expect(floor.left, floorLeft);
    expect(floor.right, closeTo(floorRight - kasur.width, 1e-9));
    expect(floor.top, closeTo(floorTop - kasur.height, 1e-9));
    expect(floor.bottom, closeTo(floorBottom - kasur.height, 1e-9));
  });

  test('posisi bawaan digambar di koordinat desain', () {
    final geo = RoomGeometry(const Size(390, 652));
    for (final (id, left, top) in [
      (RoomItemId.kasur, 246.0, 448.0),
      (RoomItemId.lukisan, 206.0, 150.0),
      (RoomItemId.mangkuk, 298.0, 596.0),
    ]) {
      final item = roomItemOf(id);
      final box = geo.boxOf(item, item.defaultSpot);
      expect(box.left, closeTo(left, 0.01), reason: '$id');
      expect(box.top, closeTo(top, 0.01), reason: '$id');
      expect(box.width, closeTo(item.width, 1e-9), reason: '$id');
      expect(box.height, closeTo(item.height, 1e-9), reason: '$id');
    }
  });

  test('spotFor adalah kebalikan boxOf dan menjepit di luar zona', () {
    final geo = RoomGeometry(const Size(412, 700));
    final item = roomItemOf(RoomItemId.bola);
    final spot = Spot(0.3, 0.8);
    final back = geo.spotFor(item, geo.boxOf(item, spot).topLeft);
    expect(back.x, closeTo(0.3, 0.001));
    expect(back.y, closeTo(0.8, 0.001));
    expect(geo.spotFor(item, const Offset(-500, -500)), Spot(0, 0));
    expect(geo.spotFor(item, const Offset(5000, 5000)), Spot(1, 1));
  });

  test('spot 0 dan 1 tetap di dalam zona untuk semua barang', () {
    for (final size in const [Size(360, 480), Size(412, 720)]) {
      final geo = RoomGeometry(size);
      for (final item in roomItems) {
        for (final spot in [Spot(0, 0), Spot(1, 1)]) {
          final box = geo.boxOf(item, spot);
          final why = '${item.id} $spot $size';
          expect(box.left, greaterThanOrEqualTo(0), reason: why);
          expect(box.right, lessThanOrEqualTo(size.width), reason: why);
          expect(box.top, greaterThanOrEqualTo(0), reason: why);
          if (item.zone == RoomZone.wall) {
            expect(box.bottom, lessThanOrEqualTo(geo.wall.bottom), reason: why);
          } else {
            expect(box.bottom, greaterThan(geo.floor.top), reason: why);
            expect(
              box.bottom,
              lessThanOrEqualTo(geo.floor.bottom),
              reason: why,
            );
          }
        }
      }
    }
  });

  test(
    'fromDesign: jendela di koordinat desain, ikut mengecil di layar kecil',
    () {
      final design = RoomGeometry(const Size(390, 652));
      const window = Rect.fromLTWH(26, 124, 140, 134);
      expect(design.fromDesign(window), window);
      final small = RoomGeometry(const Size(360, 480)).fromDesign(window);
      expect(small.width, closeTo(140 * 0.83, 2));
      expect(small.top, closeTo(124 * 303 / 412, 2));
    },
  );

  test('fromDesign stretch: bidang lantai mengikuti tinggi lantai', () {
    final geo = RoomGeometry(const Size(390, 852));
    const rect = Rect.fromLTWH(10, 436, 370, 210);
    final out = geo.fromDesign(rect, stretch: true);
    expect(out.width, closeTo(370, 1e-9));
    expect(out.top, greaterThan(geo.floor.top));
    expect(out.bottom, lessThanOrEqualTo(geo.floor.bottom));
    expect(out.height, greaterThan(210));
  });

  test('layar 360×640 mengecil seperti catatan n360', () {
    final geo = RoomGeometry(const Size(360, 480));
    expect(geo.artScale, closeTo(0.83, 0.02));
    expect(geo.wall.height / geo.room.height, closeTo(0.63, 0.01));
    expect(geo.catSize(KittyId.oyen), closeTo(96, 3));
  });

  test('kucing: Oyen lebih besar, kaki di 92% kotak', () {
    final geo = RoomGeometry(const Size(390, 652));
    expect(geo.catSize(KittyId.oyen), oyenRoomSize);
    expect(geo.catSize(KittyId.salju), kittyRoomSize);
    final box = geo.catBoxOf(KittyId.oyen, Spot(0.5, 0.5));
    expect(box.width, oyenRoomSize);
    expect(geo.feetOf(box), box.top + box.height * catFeetFactor);
  });

  test(
    'urutan gambar: karpet, barang dinding, lalu lantai dan kucing urut bawah',
    () {
      final geo = RoomGeometry(const Size(390, 652));
      final sprites = roomSprites(
        items: {
          RoomItemId.bola: Spot(0.5, 1),
          RoomItemId.lukisan: roomItemOf(RoomItemId.lukisan).defaultSpot,
          RoomItemId.kasur: Spot(0.5, 0),
          RoomItemId.karpet: roomItemOf(RoomItemId.karpet).defaultSpot,
        },
        cats: {KittyId.oyen: Spot(0.5, 0.5)},
        geo: geo,
      );
      expect(sprites, hasLength(5));
      expect(
        sprites[0],
        isA<ItemSprite>()
            .having((s) => s.id, 'id', RoomItemId.karpet)
            .having((s) => s.flat, 'flat', isTrue),
      );
      expect(
        sprites[1],
        isA<ItemSprite>().having((s) => s.id, 'id', RoomItemId.lukisan),
      );
      final bottoms = [
        for (final s in sprites.skip(2))
          s is ItemSprite ? s.box.bottom : geo.feetOf(s.box),
      ];
      expect(bottoms, orderedEquals([...bottoms]..sort()));
      expect(sprites.skip(2).whereType<KittySprite>(), hasLength(1));
    },
  );
}
