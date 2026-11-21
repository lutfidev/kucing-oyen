import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';

void main() {
  const floor = HouseFloor();
  final design = RoomGeometry(const Size(390, 652));

  test('ukuran desain: skala 1, koordinat desain = layar', () {
    expect(design.sx, 1);
    expect(design.sy, 1);
    expect(design.artScale, 1);
    expect(design.toScreen(345, 456), const Offset(345, 456));
    final small = RoomGeometry(const Size(360, 488));
    expect(small.sx, closeTo(360 / 390, 1e-9));
    expect(small.sy, closeTo(488 / 652, 1e-9));
  });

  test('lewat pintu: dari ambang ke balik kusen, dan sebaliknya', () {
    for (final (room, inside, behind) in [
      (HouseRoom.living, const Offset(345, 456), const Offset(400, 470)),
      (HouseRoom.terrace, const Offset(46, 456), const Offset(-10, 470)),
    ]) {
      Offset feetAt(double p, {required bool leaving}) {
        final box = design.passingBox(KittyId.mochi, room, p, leaving: leaving);
        return Offset(box.center.dx, design.feetOf(box));
      }

      bool near(Offset a, Offset b) => (a - b).distance < 1e-6;
      expect(near(feetAt(0, leaving: true), inside), isTrue, reason: '$room');
      expect(near(feetAt(1, leaving: true), behind), isTrue, reason: '$room');
      expect(near(feetAt(0, leaving: false), behind), isTrue, reason: '$room');
      expect(near(feetAt(1, leaving: false), inside), isTrue, reason: '$room');
      // Ukuran ikut kedalaman: lebih depan sedikit = sedikit lebih besar.
      final start = design.passingBox(KittyId.mochi, room, 0, leaving: true);
      final end = design.passingBox(KittyId.mochi, room, 1, leaving: true);
      expect(start.width, closeTo(kittyRoomSize * depthScale(456), 1e-9));
      expect(end.width, greaterThan(start.width));
    }
  });

  test('kucing: ukuran mengikuti kedalaman, kaki di 92% kotak', () {
    final threshold = floor.threshold(HouseRoom.living);
    // Desain: Arang duduk di ambang pintu (tengah 345, kaki 456).
    final arang = design.catBoxOf(KittyId.arang, threshold);
    expect(design.feetOf(arang), closeTo(456, 1e-9));
    expect(arang.center.dx, closeTo(345, 1e-9));
    // Oyen lebih besar: digeser supaya tidak keluar tepi kanan layar.
    final oyen = design.catBoxOf(KittyId.oyen, threshold);
    expect(oyen.width, closeTo(116 * depthScale(456), 1e-9));
    expect(oyen.right, closeTo(390, 1e-9));
    final salju = design.catBoxOf(KittyId.salju, threshold);
    expect(salju.width, closeTo(96 * depthScale(456), 1e-9));
    final back = design.catBoxOf(KittyId.salju, floor.spotAtFeet(200, 432));
    final front = design.catBoxOf(KittyId.salju, floor.spotAtFeet(200, 600));
    expect(front.width, greaterThan(back.width));
    expect(design.feetOf(back), back.top + back.height * catFeetFactor);
  });

  test('catSpotAt adalah kebalikan catBoxOf', () {
    final spot = floor.spotAtFeet(150, 560);
    final box = design.catBoxOf(KittyId.mochi, spot);
    final back = design.catSpotAt(KittyId.mochi, box);
    expect(back.x, closeTo(spot.x, 1e-6));
    expect(back.y, closeTo(spot.y, 1e-6));
  });

  test('barang lantai: kaki di spot, ukuran desain × kedalaman', () {
    final kasur = roomItemOf(RoomItemId.kasur);
    final spot = floor.spotAtFeet(146, 432);
    final box = design.boxOf(kasur, spot);
    final s = depthScale(432);
    expect(box.bottom, closeTo(432, 1e-9));
    expect(box.center.dx, closeTo(146, 1e-9));
    expect(box.width, closeTo(150 * s, 1e-9));
    expect(box.height, closeTo(76 * s, 1e-9));
  });

  test('barang dinding ruang tengah di dinding belakang, skala 0,75', () {
    final lukisan = roomItemOf(RoomItemId.lukisan);
    final wall = design.wallZone;
    expect(wall, const Rect.fromLTRB(88, 150, 302, 332));
    for (final spot in [Spot(0, 0), Spot(1, 1), Spot(0.4, 0.6)]) {
      final box = design.boxOf(lukisan, spot);
      expect(box.left, greaterThanOrEqualTo(wall.left - 1e-9));
      expect(box.right, lessThanOrEqualTo(wall.right + 1e-9));
      expect(box.top, greaterThanOrEqualTo(wall.top - 1e-9));
      expect(box.bottom, lessThanOrEqualTo(wall.bottom + 1e-9));
      expect(box.width, closeTo(lukisan.baseWidth * 0.75, 1e-9));
    }
  });

  test('spotFor adalah kebalikan boxOf dan menjepit di luar zona', () {
    final geo = RoomGeometry(const Size(412, 700));
    for (final id in [RoomItemId.bola, RoomItemId.kasur, RoomItemId.rak]) {
      final item = roomItemOf(id);
      final spot = Spot(0.3, 0.8);
      final back = geo.spotFor(item, geo.boxOf(item, spot).topLeft);
      expect(back.x, closeTo(0.3, 0.002), reason: '$id');
      expect(back.y, closeTo(0.8, 0.002), reason: '$id');
      expect(geo.spotFor(item, const Offset(-500, -500)).y, 0, reason: '$id');
      expect(geo.spotFor(item, const Offset(5000, 5000)), Spot(1, 1));
    }
  });

  test('semua barang di spot 0 dan 1 tetap di dalam layar', () {
    for (final size in const [Size(360, 488), Size(412, 720)]) {
      final geo = RoomGeometry(size);
      for (final item in roomItems) {
        for (final spot in [Spot(0, 0), Spot(1, 1), Spot(0, 1), Spot(1, 0)]) {
          final box = geo.boxOf(item, spot);
          final why = '${item.id} $spot $size';
          expect(box.left, greaterThanOrEqualTo(-1e-9), reason: why);
          expect(box.right, lessThanOrEqualTo(size.width + 1e-9), reason: why);
          expect(box.top, greaterThanOrEqualTo(0), reason: why);
          expect(box.bottom, lessThanOrEqualTo(size.height), reason: why);
        }
      }
    }
  });

  test('fromDesign: posisi ikut sx/sy, ukuran ikut artScale', () {
    const window = Rect.fromLTWH(212, 176, 88, 70);
    expect(design.fromDesign(window), window);
    final small = RoomGeometry(const Size(360, 488));
    final out = small.fromDesign(window);
    expect(out.left, closeTo(212 * 360 / 390, 1e-9));
    expect(out.top, closeTo(176 * 488 / 652, 1e-9));
    expect(out.width, closeTo(88 * small.artScale, 1e-9));
    final stretched = small.fromDesign(window, stretch: true);
    expect(stretched.height, closeTo(70 * 488 / 652, 1e-9));
  });

  test(
    'urutan gambar: karpet, barang dinding, lalu lantai dan kucing urut kaki',
    () {
      final sprites = roomSprites(
        items: {
          RoomItemId.bola: Spot(0.5, 1),
          RoomItemId.lukisan: Spot(0.5, 0.5),
          RoomItemId.kasur: Spot(0.1, 0),
          RoomItemId.karpet: Spot(0.3, 0.8),
        },
        cats: {KittyId.oyen: Spot(0.2, 0.5)},
        geo: design,
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
      final feet = [
        for (final s in sprites.skip(2))
          s is ItemSprite ? s.box.bottom : design.feetOf(s.box),
      ];
      expect(feet, orderedEquals([...feet]..sort()));
      // Kucing di depan kasur karena kakinya lebih bawah.
      final kinds = [for (final s in sprites.skip(2)) s.runtimeType];
      expect(kinds, [ItemSprite, KittySprite, ItemSprite]);
    },
  );

  group('rute ke barang', () {
    test('barang lantai: kaki dan tengah kucing tepat di kucing barangnya', () {
      for (final kitty in [KittyId.oyen, KittyId.salju]) {
        for (final id in [RoomItemId.kasur, RoomItemId.kardus]) {
          final placed = {id: floor.spotAtFeet(150, 520)};
          final path = design.pathTo(kitty, id, placed)!;
          expect(path.hops, 0);
          final stand = design.catBoxOf(kitty, path.stand);
          final user = design.userBoxOf(
            id,
            design.boxOf(roomItemOf(id), placed[id]!),
          );
          expect(stand.center.dx, closeTo(user.center.dx, 0.01));
          expect(design.feetOf(stand), closeTo(design.feetOf(user), 0.01));
          expect(path.boxes, [stand, user]);
        }
      }
    });

    test('lukisan dan jam hanya hiasan: tidak punya rute', () {
      final placed = {
        RoomItemId.lukisan: Spot(0.2, 0.5),
        RoomItemId.jam: Spot(0.8, 0.5),
      };
      expect(design.pathTo(KittyId.oyen, RoomItemId.lukisan, placed), isNull);
      expect(design.pathTo(KittyId.oyen, RoomItemId.jam, placed), isNull);
    });

    test('lampu bulan rendah di dinding: satu lompatan dari lantai', () {
      final placed = {RoomItemId.lampuBulan: Spot(0.5, 1)};
      final path = design.pathTo(KittyId.salju, RoomItemId.lampuBulan, placed)!;
      expect(path.hops, 1);
      final [stand, user] = path.boxes;
      expect(design.catBoxOf(KittyId.salju, path.stand), stand);
      // Berdiri di lantai paling belakang, di bawah lampunya.
      expect(path.stand.y, 0);
      expect(stand.center.dx, closeTo(user.center.dx, 0.01));
    });

    test('rak tinggi tanpa pijakan: tidak bisa dinaiki', () {
      final placed = {RoomItemId.rak: Spot(0.5, 0)};
      expect(design.pathTo(KittyId.oyen, RoomItemId.rak, placed), isNull);
    });

    test(
      'rak tinggi dengan tiang di belakang dekatnya: lewat puncak tiang',
      () {
        final rak = {RoomItemId.rak: Spot(0.5, 0.5)};
        expect(design.pathTo(KittyId.oyen, RoomItemId.rak, rak), isNull);
        final placed = {...rak, RoomItemId.tiang: floor.spotAtFeet(200, 420)};
        final path = design.pathTo(KittyId.oyen, RoomItemId.rak, placed)!;
        expect(path.hops, 2);
        final [stand, perch, _] = path.boxes;
        final post = design.boxOf(
          roomItemOf(RoomItemId.tiang),
          placed[RoomItemId.tiang]!,
        );
        expect(design.feetOf(stand), closeTo(post.bottom, 0.01));
        expect(design.feetOf(perch), lessThan(post.top + post.height * 0.1));
      },
    );

    test('pijakan di depan lantai tidak dipakai', () {
      final placed = {
        RoomItemId.rak: Spot(0.5, 0.5),
        RoomItemId.tiang: floor.spotAtFeet(200, 620),
      };
      expect(design.pathTo(KittyId.oyen, RoomItemId.rak, placed), isNull);
    });

    test('kotak lompat: mulai, tengah melengkung ke atas, dan akhir', () {
      const a = Rect.fromLTWH(0, 100, 50, 50);
      const b = Rect.fromLTWH(100, 0, 30, 30);
      expect(hopBox([a, b], 0, arc: 20), rectMoreOrLessEquals(a));
      expect(hopBox([a, b], 1, arc: 20), rectMoreOrLessEquals(b));
      final mid = hopBox([a, b], 0.5, arc: 20);
      expect(mid.width, closeTo(40, 0.01));
      expect(mid.top, lessThan((a.top + b.top) / 2));
      const c = Rect.fromLTWH(200, -50, 30, 30);
      expect(hopBox([a, b, c], 0.5, arc: 20), rectMoreOrLessEquals(b));
    });

    test('barang dipakai dicerminkan kalau kotaknya keluar tepi', () {
      final tiang = roomItemOf(RoomItemId.tiang);
      final box = design.boxOf(tiang, Spot(0, 1));
      expect(design.mirrorsInUse(RoomItemId.tiang, box), isTrue);
      final kasur = roomItemOf(RoomItemId.kasur);
      expect(
        design.mirrorsInUse(
          RoomItemId.kasur,
          design.boxOf(kasur, floor.spotAtFeet(146, 432)),
        ),
        isFalse,
      );
      expect(
        design.userBoxOf(RoomItemId.tiang, box),
        RoomItemArt.catBox(
          RoomItemId.tiang,
          RoomItemArt.inUseBox(RoomItemId.tiang, box, mirror: true),
          mirror: true,
        ),
      );
    });
  });
}
