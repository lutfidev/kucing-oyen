import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';

void main() {
  test('20 barang Toko, urutan dan harga persis desain', () {
    expect(
      [for (final i in shopItems) i.id.name],
      [
        'tikus',
        'akuarium',
        'rumah',
        'kasur',
        'catnip',
        'jam',
        'kardus',
        'bola',
        'karpet',
        'tiang',
        'lukisan',
        'rak',
        'pancingan',
        'lampuBulan',
        'bantalIkan',
        'monstera',
        'terowongan',
        'hammock',
        'sofaMini',
        'jendelaBurung',
      ],
    );
    expect(
      [for (final i in shopItems) i.price],
      [
        120, 600, 900, 200, 180, 240, 50, 80, 150, 220, //
        140, 160, 60, 120, 160, 200, 260, 380, 450, 700,
      ],
    );
    expect(shopItems.fold(0, (sum, i) => sum + i.price), 5370);
  });

  test('mangkuk barang bawaan gratis, tidak dijual', () {
    final bowl = roomItemOf(RoomItemId.mangkuk);
    expect(bowl.builtIn, isTrue);
    expect(bowl.price, 0);
    expect(bowl.zone, RoomZone.floor);
    expect(bowl.use, ItemUse.eat);
    expect(shopItems, isNot(contains(bowl)));
    expect(roomItems, hasLength(21));
    expect(shopItems.where((i) => i.builtIn), isEmpty);
  });

  test('14 barang lantai dan 6 barang dinding (desain 22)', () {
    final wall = {
      for (final i in shopItems)
        if (i.zone == RoomZone.wall) i.id,
    };
    expect(wall, {
      RoomItemId.lukisan,
      RoomItemId.jam,
      RoomItemId.rak,
      RoomItemId.jendelaBurung,
      RoomItemId.lampuBulan,
      RoomItemId.hammock,
    });
    expect(shopItems.where((i) => i.zone == RoomZone.floor), hasLength(14));
  });

  test('mainan sesuai spesifikasi', () {
    expect(
      {
        for (final i in roomItems)
          if (i.toy) i.id,
      },
      {
        RoomItemId.bola,
        RoomItemId.tikus,
        RoomItemId.tiang,
        RoomItemId.catnip,
        RoomItemId.akuarium,
        RoomItemId.pancingan,
        RoomItemId.terowongan,
        RoomItemId.jendelaBurung,
      },
    );
  });

  test('cara dipakai dari pose desain 22', () {
    expect(roomItemOf(RoomItemId.kasur).use, ItemUse.sleep);
    expect(roomItemOf(RoomItemId.karpet).use, ItemUse.sleep);
    expect(roomItemOf(RoomItemId.sofaMini).use, ItemUse.lounge);
    expect(roomItemOf(RoomItemId.kardus).use, ItemUse.hide);
    expect(roomItemOf(RoomItemId.tiang).use, ItemUse.scratch);
    expect(roomItemOf(RoomItemId.rak).use, ItemUse.sit);
    expect(roomItemOf(RoomItemId.akuarium).use, ItemUse.watch);
    expect(roomItemOf(RoomItemId.bola).use, ItemUse.play);
  });

  test('ukuran kamar = ukuran desain × skala Kamar', () {
    final kasur = roomItemOf(RoomItemId.kasur);
    expect(kasur.width, closeTo(127.5, 1e-9));
    expect(kasur.height, closeTo(64.6, 1e-9));
    expect(roomItemOf(RoomItemId.tikus).width, 46);
  });

  test('karpet digambar rata di lantai, barang lain tidak', () {
    expect(roomItemOf(RoomItemId.karpet).flat, isTrue);
    expect(roomItems.where((i) => i.flat).map((i) => i.id), [
      RoomItemId.karpet,
    ]);
  });

  group('Spot', () {
    test('dijepit ke 0–1, NaN jadi 0', () {
      expect(Spot(-1, 2), Spot(0, 1));
      expect(Spot(double.nan, 0.5), Spot(0, 0.5));
      expect(Spot(0.25, 0.75).x, 0.25);
    });

    test('JSON pulang-pergi; rusak = null', () {
      final spot = Spot(0.25, 0.5);
      expect(Spot.fromJson(spot.toJson()), spot);
      for (final bad in <Object?>[
        null,
        'a',
        [1],
        [0.1, 'x'],
        [double.nan, 0],
        [0, double.infinity],
        [0.1, 0.2, 0.3],
      ]) {
        expect(Spot.fromJson(bad), isNull, reason: '$bad');
      }
      expect(Spot.fromJson([1, 0]), Spot(1, 0));
      expect(Spot.fromJson([5, -1]), Spot(1, 0));
    });

    test('pojok area: spot 0 dan 1 = batas seret desain', () {
      final lukisan = roomItemOf(RoomItemId.lukisan);
      final (wx0, wy0) = positionOf(lukisan, Spot(0, 0));
      expect((wx0, wy0), (wallLeft, wallTop));
      final (wx1, wy1) = positionOf(lukisan, Spot(1, 1));
      expect(wx1 + lukisan.width, closeTo(wallRight, 1e-9));
      expect(wy1 + lukisan.height, closeTo(wallBottom, 1e-9));

      final bola = roomItemOf(RoomItemId.bola);
      final (fx0, fy0) = positionOf(bola, Spot(0, 0));
      expect((fx0, fy0 + bola.height), (floorLeft, floorTop));
      final (fx1, fy1) = positionOf(bola, Spot(1, 1));
      expect(fx1 + bola.width, closeTo(floorRight, 1e-9));
      expect(fy1 + bola.height, closeTo(floorBottom, 1e-9));
    });

    test('posisi bawaan kembali ke koordinat desain', () {
      for (final item in roomItems) {
        final (x, y) = positionOf(item, item.defaultSpot);
        expect(x, closeTo(item.defaultX, 0.01), reason: item.id.name);
        // Kardus di Kamar.dc.html melewati batas lantai 2 px; dijepit.
        final expectedY = item.id == RoomItemId.kardus
            ? floorBottom - item.height
            : item.defaultY;
        expect(y, closeTo(expectedY, 0.01), reason: item.id.name);
      }
    });

    test('spotAt kebalikan positionOf', () {
      final rak = roomItemOf(RoomItemId.rak);
      expect(spotAt(rak, 250, 336), rak.defaultSpot);
      final (x, y) = positionOf(rak, Spot(0.3, 0.6));
      final back = spotAt(rak, x, y);
      expect(back.x, closeTo(0.3, 1e-9));
      expect(back.y, closeTo(0.6, 1e-9));
    });
  });
}
