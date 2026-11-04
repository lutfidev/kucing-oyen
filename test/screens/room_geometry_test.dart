import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/render.dart';
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

  group('rute ke barang', () {
    final geo = RoomGeometry(const Size(390, 652));

    Map<RoomItemId, Spot> placedAt(Map<RoomItemId, (double, double)> at) => {
      for (final MapEntry(key: id, value: (x, y)) in at.entries)
        id: spotAt(roomItemOf(id), x, y),
    };

    Map<RoomItemId, Spot> defaults(Iterable<RoomItemId> ids) => {
      for (final id in ids) id: roomItemOf(id).defaultSpot,
    };

    test('barang lantai: kaki dan tengah kucing tepat di kucing barangnya', () {
      for (final kitty in [KittyId.oyen, KittyId.salju]) {
        for (final id in [RoomItemId.kasur, RoomItemId.kardus]) {
          final placed = defaults([id]);
          final path = geo.pathTo(kitty, id, placed)!;
          expect(path.hops, 0);
          final stand = geo.catBoxOf(kitty, path.stand);
          final user = geo.userBoxOf(
            id,
            geo.boxOf(roomItemOf(id), placed[id]!),
          );
          expect(stand.width, geo.catSize(kitty), reason: '$kitty $id');
          expect(stand.center.dx, closeTo(user.center.dx, 0.01));
          expect(geo.feetOf(stand), closeTo(geo.feetOf(user), 0.01));
          expect(path.boxes, [stand, user]);
        }
      }
    });

    test('lukisan dan jam hanya hiasan: tidak punya rute', () {
      final placed = defaults([
        RoomItemId.lukisan,
        RoomItemId.jam,
        RoomItemId.tiang,
      ]);
      expect(geo.pathTo(KittyId.oyen, RoomItemId.lukisan, placed), isNull);
      expect(geo.pathTo(KittyId.oyen, RoomItemId.jam, placed), isNull);
    });

    test('rak rendah: satu lompatan langsung dari lantai', () {
      final placed = placedAt({RoomItemId.rak: (150, 340)});
      final path = geo.pathTo(KittyId.salju, RoomItemId.rak, placed)!;
      expect(path.hops, 1);
      expect(path.boxes, hasLength(2));
      final stand = path.boxes.first;
      expect(geo.catBoxOf(KittyId.salju, path.stand), stand);
      // Berdiri di lantai paling belakang, di bawah raknya.
      expect(path.stand.y, 0);
      final user = path.boxes.last;
      expect(stand.center.dx, closeTo(user.center.dx, 0.01));
    });

    test('jendela tinggi tanpa pijakan: tidak bisa dinaiki', () {
      final placed = placedAt({RoomItemId.jendelaBurung: (30, 160)});
      expect(
        geo.pathTo(KittyId.oyen, RoomItemId.jendelaBurung, placed),
        isNull,
      );
    });

    test('jendela tinggi dengan tiang di dekatnya: lewat puncak tiang', () {
      final placed = defaults([RoomItemId.jendelaBurung, RoomItemId.tiang]);
      final path = geo.pathTo(KittyId.oyen, RoomItemId.jendelaBurung, placed)!;
      expect(path.hops, 2);
      final [stand, perch, user] = path.boxes;
      final post = geo.boxOf(
        roomItemOf(RoomItemId.tiang),
        placed[RoomItemId.tiang]!,
      );
      // Berdiri di depan tiang, lalu naik ke puncaknya.
      // Di depan tiang (dijepit ke lantai kalau tiangnya di pojok).
      expect(
        (stand.center.dx - post.center.dx).abs(),
        lessThanOrEqualTo(stand.width / 2),
      );
      expect(geo.feetOf(stand), closeTo(post.bottom, 0.01));
      // Di puncak tiang, dijepit supaya tetap di dalam kamar (tiang di
      // pojok kiri).
      expect(perch.left, greaterThanOrEqualTo(0));
      expect(
        (perch.center.dx - post.center.dx).abs(),
        lessThanOrEqualTo(perch.width / 2),
      );
      expect(geo.feetOf(perch), lessThan(post.top + post.height * 0.1));
      expect(perch.width, geo.catSize(KittyId.oyen));
      expect(
        user,
        geo.userBoxOf(
          RoomItemId.jendelaBurung,
          geo.boxOf(
            roomItemOf(RoomItemId.jendelaBurung),
            placed[RoomItemId.jendelaBurung]!,
          ),
        ),
      );
    });

    test('pijakan yang jauh dari barang dinding tidak dipakai', () {
      final placed = {
        ...placedAt({RoomItemId.jendelaBurung: (30, 160)}),
        ...placedAt({RoomItemId.tiang: (330, 480)}),
      };
      expect(
        geo.pathTo(KittyId.oyen, RoomItemId.jendelaBurung, placed),
        isNull,
      );
    });

    test('pijakan terdekat yang dipilih', () {
      final placed = {
        ...placedAt({RoomItemId.hammock: (230, 240)}),
        ...placedAt({RoomItemId.akuarium: (180, 446)}),
        ...placedAt({RoomItemId.tiang: (300, 330)}),
      };
      final path = geo.pathTo(KittyId.salju, RoomItemId.hammock, placed)!;
      final post = geo.boxOf(
        roomItemOf(RoomItemId.tiang),
        placed[RoomItemId.tiang]!,
      );
      final tank = geo.boxOf(
        roomItemOf(RoomItemId.akuarium),
        placed[RoomItemId.akuarium]!,
      );
      final user = path.boxes.last;
      final nearest =
          (post.center.dx - user.center.dx).abs() <
              (tank.center.dx - user.center.dx).abs()
          ? post
          : tank;
      expect(path.boxes[1].center.dx, closeTo(nearest.center.dx, 0.01));
    });

    test(
      'posisi bawaan kamar penuh: barang dinding yang bisa dipakai punya rute',
      () {
        final placed = defaults(roomItems.map((i) => i.id));
        for (final id in [
          RoomItemId.rak,
          RoomItemId.hammock,
          RoomItemId.jendelaBurung,
          RoomItemId.lampuBulan,
        ]) {
          for (final kitty in [KittyId.oyen, KittyId.mochi]) {
            expect(
              geo.pathTo(kitty, id, placed),
              isNotNull,
              reason: '$id $kitty',
            );
          }
        }
      },
    );

    test('kotak lompat: mulai, tengah melengkung ke atas, dan akhir', () {
      const a = Rect.fromLTWH(0, 100, 50, 50);
      const b = Rect.fromLTWH(100, 0, 30, 30);
      expect(hopBox([a, b], 0, arc: 20), rectMoreOrLessEquals(a));
      expect(hopBox([a, b], 1, arc: 20), rectMoreOrLessEquals(b));
      final mid = hopBox([a, b], 0.5, arc: 20);
      expect(mid.width, closeTo(40, 0.01));
      expect(mid.top, lessThan((a.top + b.top) / 2));
      // Dua lompatan: separuh jalan = pijakan.
      const c = Rect.fromLTWH(200, -50, 30, 30);
      expect(hopBox([a, b, c], 0.5, arc: 20), rectMoreOrLessEquals(b));
    });

    test('barang dipakai dicerminkan kalau kotaknya keluar tepi', () {
      final tiang = roomItemOf(RoomItemId.tiang);
      final box = geo.boxOf(tiang, tiang.defaultSpot);
      expect(geo.mirrorsInUse(RoomItemId.tiang, box), isTrue);
      final kasur = roomItemOf(RoomItemId.kasur);
      expect(
        geo.mirrorsInUse(RoomItemId.kasur, geo.boxOf(kasur, kasur.defaultSpot)),
        isFalse,
      );
      final user = geo.userBoxOf(RoomItemId.tiang, box);
      expect(
        user,
        RoomItemArt.catBox(
          RoomItemId.tiang,
          RoomItemArt.inUseBox(RoomItemId.tiang, box, mirror: true),
          mirror: true,
        ),
      );
    });
  });
}
