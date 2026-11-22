import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';

void main() {
  const floor = HouseFloor();
  final kasur = roomItemOf(RoomItemId.kasur);

  test('skala kedalaman: 0,75 di belakang sampai 1,15 di depan', () {
    expect(depthScale(392), 0.75);
    expect(depthScale(456), closeTo(0.8485, 1e-4));
    expect(depthScale(600), closeTo(1.07, 1e-3));
    expect(depthScale(652), closeTo(1.15, 1e-9));
    expect(depthScale(300), 0.75);
    expect(depthScale(800), 1.15);
  });

  test('spot lantai ke titik kaki di zona Hias dan sebaliknya', () {
    expect(floor.feetAt(Spot(0, 0)), (x: 84.0, y: 398.0));
    expect(floor.feetAt(Spot(1, 0)), (x: 306.0, y: 398.0));
    expect(floor.feetAt(Spot(0, 1)), (x: 4.0, y: 646.0));
    expect(floor.feetAt(Spot(1, 1)), (x: 386.0, y: 646.0));
    for (final spot in [Spot(0.3, 0.2), Spot(0.8, 0.5), Spot(0.1, 0.9)]) {
      final f = floor.feetAt(spot);
      final back = floor.spotAtFeet(f.x, f.y);
      expect(back.x, closeTo(spot.x, 1e-9));
      expect(back.y, closeTo(spot.y, 1e-9));
    }
  });

  test('ukuran barang = ukuran desain × skala kedalaman', () {
    final spot = floor.spotAtFeet(146, 432);
    final feet = floor.itemFeet(kasur, spot);
    expect(feet.y, closeTo(432, 1e-9));
    expect(feet.scale, closeTo(depthScale(432), 1e-9));
    expect(
      floor.itemSize(kasur, feet.scale).width,
      closeTo(150 * feet.scale, 1e-9),
    );
    // Di tepi kiri, tengah barang dijepit supaya gambarnya tetap di layar.
    final edge = floor.itemFeet(kasur, Spot(0, 1));
    expect(edge.x - 150 * edge.scale / 2, greaterThanOrEqualTo(0));
  });

  test('barang dinding: hanya di ruang tengah, kecuali gantungan teras', () {
    expect(canPlaceIn(RoomItemId.lukisan, HouseRoom.living), isTrue);
    expect(canPlaceIn(RoomItemId.lukisan, HouseRoom.terrace), isFalse);
    expect(canPlaceIn(RoomItemId.hammock, HouseRoom.terrace), isTrue);
    expect(canPlaceIn(RoomItemId.lampuBulan, HouseRoom.terrace), isTrue);
    expect(canPlaceIn(RoomItemId.kasur, HouseRoom.terrace), isTrue);
    expect(canPlaceIn(RoomItemId.mangkuk, HouseRoom.terrace), isFalse);
    expect(canPlaceIn(RoomItemId.mangkuk, HouseRoom.living), isTrue);
    expect(HouseRoom.living.other, HouseRoom.terrace);
    expect(HouseRoom.terrace.other, HouseRoom.living);
  });

  test('ambang pintu kedua ruangan', () {
    expect(
      floor.feetAt(floor.threshold(HouseRoom.living)).x,
      closeTo(345, 1e-9),
    );
    expect(
      floor.feetAt(floor.threshold(HouseRoom.living)).y,
      closeTo(456, 1e-9),
    );
    expect(
      floor.feetAt(floor.threshold(HouseRoom.terrace)).x,
      closeTo(46, 1e-9),
    );
    expect(
      floor.feetAt(floor.threshold(HouseRoom.terrace)).y,
      closeTo(456, 1e-9),
    );
  });

  test('jalur pintu: barang lantai yang menghalangi, karpet tidak', () {
    final blocked = floor.spotAtFeet(300, 500);
    expect(floor.blocksDoor(kasur, HouseRoom.living, blocked), isTrue);
    expect(
      // Kasur bawah jendela seperti AdeganTengah Gang Depan (kaki y 434,
      // tengah x 179), di antara jalur pintu depan dan pintu teras.
      floor.blocksDoor(kasur, HouseRoom.living, floor.spotAtFeet(179, 434)),
      isFalse,
    );
    expect(
      floor.blocksDoor(
        roomItemOf(RoomItemId.karpet),
        HouseRoom.living,
        blocked,
      ),
      isFalse,
    );
    expect(
      floor.blocksDoor(
        roomItemOf(RoomItemId.lukisan),
        HouseRoom.living,
        blocked,
      ),
      isFalse,
    );
    // Teras: jalur dari pintu kiri.
    expect(
      floor.blocksDoor(kasur, HouseRoom.terrace, floor.spotAtFeet(90, 500)),
      isTrue,
    );
    expect(floor.blocksDoor(kasur, HouseRoom.terrace, blocked), isFalse);
  });

  test('allowedSpot: spot terdekat yang tidak menghalangi', () {
    final blocked = floor.spotAtFeet(300, 500);
    final moved = floor.allowedSpot(kasur, HouseRoom.living, blocked);
    expect(floor.blocksDoor(kasur, HouseRoom.living, moved), isFalse);
    final d = floor.distance(blocked, moved);
    for (var i = 0; i <= 40; i++) {
      for (var j = 0; j <= 40; j++) {
        final s = Spot(i / 40, j / 40);
        if (!floor.blocksDoor(kasur, HouseRoom.living, s)) {
          expect(floor.distance(blocked, s), greaterThanOrEqualTo(d - 1e-9));
        }
      }
    }
    final free = floor.spotAtFeet(179, 434);
    expect(floor.allowedSpot(kasur, HouseRoom.living, free), free);
  });

  group('ikon perhatian di pintu', () {
    (KittyId, DoorNeed)? attention(
      Set<KittyId> kitties, {
      Set<KittyId> hungry = const {},
      Set<KittyId> sad = const {},
      Set<KittyId> reward = const {},
    }) => doorAttention(
      kitties,
      hungry: hungry.contains,
      sad: sad.contains,
      reward: reward.contains,
    );

    test('lapar menang atas hadiah koin', () {
      expect(
        attention(
          {KittyId.mochi, KittyId.salju},
          hungry: {KittyId.salju},
          reward: {KittyId.mochi},
        ),
        (KittyId.salju, DoorNeed.hungry),
      );
    });

    test('sedih menang atas hadiah koin', () {
      expect(
        attention(
          {KittyId.mochi, KittyId.salju},
          sad: {KittyId.salju},
          reward: {KittyId.mochi},
        ),
        (KittyId.salju, DoorNeed.sad),
      );
    });

    test('kebutuhan sama: urutan KittyId', () {
      expect(
        attention(
          {KittyId.telon, KittyId.mochi},
          reward: {KittyId.telon, KittyId.mochi},
        ),
        (
          KittyId.values.firstWhere(
            (k) => k == KittyId.telon || k == KittyId.mochi,
          ),
          DoorNeed.reward,
        ),
      );
    });

    test('tidak ada kebutuhan: null', () {
      expect(attention({KittyId.mochi}), isNull);
      expect(attention(const {}, hungry: {KittyId.mochi}), isNull);
    });
  });

  group('pintu depan (Gang Depan)', () {
    const floor = HouseFloor();
    final kardus = roomItemOf(RoomItemId.kardus);
    final kasur = roomItemOf(RoomItemId.kasur);

    test('jalur pintu depan di ruang tengah, bukan di teras', () {
      expect(floor.doorPaths(HouseRoom.living), hasLength(2));
      expect(floor.doorPaths(HouseRoom.terrace), hasLength(1));
      expect(
        floor.onDoorPath(HouseRoom.living, floor.spotAtFeet(60, 480)),
        isTrue,
      );
      expect(
        floor.onDoorPath(HouseRoom.terrace, floor.spotAtFeet(60, 480)),
        isTrue,
        reason: 'jalur pintu teras di sudut yang sama',
      );
      expect(
        floor.onDoorPath(HouseRoom.living, floor.spotAtFeet(150, 600)),
        isFalse,
      );
      expect(
        floor.blocksDoor(kardus, HouseRoom.living, floor.spotAtFeet(60, 480)),
        isTrue,
      );
      final moved = floor.allowedSpot(
        kardus,
        HouseRoom.living,
        floor.spotAtFeet(60, 480),
      );
      expect(floor.blocksDoor(kardus, HouseRoom.living, moved), isFalse);
    });

    test('ambang pintu depan dan garis potong pintu kucing', () {
      final feet = floor.feetAt(floor.frontThreshold);
      expect(feet.x, closeTo(70, 0.01));
      expect(feet.y, closeTo(436, 0.01));
      expect(flapClipX, 45.2);
      expect(laneFlapClipX, 344.8);
    });

    test('freeSpot: terdekat, bebas jalur pintu dan barang lain', () {
      final kasurAt = floor.spotAtFeet(200, 560);
      // Kardus ingin di tempat kasur: digeser ke spot bebas terdekat.
      final free = floor.freeSpot(kardus, HouseRoom.living, kasurAt, [
        (item: kasur, spot: kasurAt),
      ])!;
      expect(free, isNot(kasurAt));
      expect(floor.blocksDoor(kardus, HouseRoom.living, free), isFalse);
      expect(
        floor.footprint(kardus, free).overlaps(floor.footprint(kasur, kasurAt)),
        isFalse,
      );
      expect(floor.distance(free, kasurAt), lessThan(60));
      // Tempat yang sudah bebas dipakai apa adanya.
      final open = floor.spotAtFeet(200, 620);
      expect(floor.freeSpot(kardus, HouseRoom.living, open, const []), open);
    });

    test('freeSpot: null kalau semua tempat terisi', () {
      final everywhere = [
        for (var i = 0; i <= 40; i++)
          for (var j = 0; j <= 40; j++)
            (item: kasur, spot: Spot(i / 40, j / 40)),
      ];
      expect(
        floor.freeSpot(kardus, HouseRoom.living, Spot(0.5, 0.5), everywhere),
        isNull,
      );
    });
  });
}
