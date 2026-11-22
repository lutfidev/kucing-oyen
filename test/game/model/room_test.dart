import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/room.dart';

void main() {
  final bowlSpot = roomItemOf(RoomItemId.mangkuk).defaultSpot;
  final kardus = roomItemOf(RoomItemId.kardus);

  test('awal: hanya mangkuk, di posisi bawaannya', () {
    expect(Room.initial.owned, {RoomItemId.mangkuk});
    expect(Room.initial.placed, {RoomItemId.mangkuk: bowlSpot});
    expect(Room.initial.stored, isEmpty);
  });

  test('mangkuk selalu dimiliki dan ditaruh', () {
    final room = Room(placed: {RoomItemId.kardus: Spot(0, 0)});
    expect(room.owned, {RoomItemId.mangkuk});
    expect(room.placed, {RoomItemId.mangkuk: bowlSpot});
  });

  test('canBuy: belum dimiliki, koin cukup, bukan mangkuk', () {
    expect(Room.initial.canBuy(RoomItemId.kardus, 50), isTrue);
    expect(Room.initial.canBuy(RoomItemId.kardus, 49), isFalse);
    expect(Room.initial.canBuy(RoomItemId.mangkuk, 999), isFalse);
    final owned = Room.initial.buy(RoomItemId.kardus);
    expect(owned.canBuy(RoomItemId.kardus, 999), isFalse);
  });

  test('beli: dimiliki dan langsung ditaruh di posisi bawaan', () {
    final room = Room.initial.buy(RoomItemId.kardus);
    expect(room.owns(RoomItemId.kardus), isTrue);
    expect(room.spotOf(RoomItemId.kardus), kardus.defaultSpot);
    expect(room.buy(RoomItemId.kardus), room);
    expect(Room.initial.buy(RoomItemId.mangkuk), Room.initial);
  });

  test('ke Gudang lalu ditaruh lagi', () {
    final bought = Room.initial.buy(RoomItemId.kardus);
    final stored = bought.store(RoomItemId.kardus);
    expect(stored.owns(RoomItemId.kardus), isTrue);
    expect(stored.isPlaced(RoomItemId.kardus), isFalse);
    expect(stored.spotOf(RoomItemId.kardus), isNull);
    expect(stored.stored, [RoomItemId.kardus]);

    // Spot di kiri depan lantai: tidak menutup jalur pintu teras maupun
    // pintu depan, jadi tidak digeser.
    final back = stored.place(RoomItemId.kardus, Spot(0.2, 0.95));
    expect(back.spotOf(RoomItemId.kardus), Spot(0.2, 0.95));
    expect(back.stored, isEmpty);
  });

  test('mangkuk tidak bisa ke Gudang, tapi bisa digeser', () {
    expect(Room.initial.store(RoomItemId.mangkuk), Room.initial);
    final moved = Room.initial.place(RoomItemId.mangkuk, Spot(0.5, 0.9));
    expect(moved.spotOf(RoomItemId.mangkuk), Spot(0.5, 0.9));
  });

  test('barang yang tidak dimiliki tidak bisa ditaruh atau disimpan', () {
    expect(Room.initial.place(RoomItemId.bola, Spot(0, 0)), Room.initial);
    expect(Room.initial.store(RoomItemId.bola), Room.initial);
  });

  test('Gudang urut katalog', () {
    final room = Room(owned: {RoomItemId.bola, RoomItemId.tikus});
    expect(room.stored, [RoomItemId.tikus, RoomItemId.bola]);
  });

  test('JSON pulang-pergi', () {
    final room = Room.initial
        .buy(RoomItemId.kardus)
        .buy(RoomItemId.lukisan)
        .store(RoomItemId.lukisan)
        .place(RoomItemId.kardus, Spot(0.2, 0.9));
    expect(Room.fromJson(room.toJson()), room);
    expect(Room.fromJson(Room.initial.toJson()), Room.initial);
  });

  test('JSON rusak dibuang per entri tanpa melempar', () {
    final room = Room.fromJson({
      'owned': ['kardus', 'kursiAsing', 7, null, 'bola'],
      'placed': {
        'kardus': [0.2, 0.95],
        'bola': 'a',
        'tikus': [0.1, 0.1],
        'kursiAsing': [0, 0],
        'mangkuk': [double.nan, 0],
      },
    });
    expect(room.owned, {
      RoomItemId.mangkuk,
      RoomItemId.kardus,
      RoomItemId.bola,
    });
    expect(room.placed, {
      RoomItemId.mangkuk: bowlSpot,
      RoomItemId.kardus: Spot(0.2, 0.95),
    });
    expect(room.stored, [RoomItemId.bola]);

    expect(Room.fromJson({'owned': 'x', 'placed': 3}), Room.initial);
    expect(Room.fromJson({}), Room.initial);
  });

  test('owned hasil beli tidak bisa diubah', () {
    final room = Room().buy(RoomItemId.bola);
    expect(() => room.owned.add(RoomItemId.jam), throwsUnsupportedError);
  });

  group('dua ruangan', () {
    const floor = HouseFloor();
    final owned = [RoomItemId.kasur, RoomItemId.lukisan, RoomItemId.hammock];

    test('simpanan tanpa terrace: semua barang di ruang tengah', () {
      final room = Room.fromJson({
        'owned': ['kasur'],
        'placed': {
          'kasur': [0.1, 0.2],
        },
      });
      expect(room.roomOf(RoomItemId.kasur), HouseRoom.living);
      expect(room.placedIn(HouseRoom.terrace), isEmpty);
      expect(room.placedIn(HouseRoom.living).keys, {
        RoomItemId.mangkuk,
        RoomItemId.kasur,
      });
    });

    test('barang teras tersimpan lewat JSON', () {
      final room = Room(owned: owned)
          .place(RoomItemId.kasur, Spot(0.5, 0.9), room: HouseRoom.terrace);
      expect(room.roomOf(RoomItemId.kasur), HouseRoom.terrace);
      final back = Room.fromJson(room.toJson());
      expect(back, room);
      expect(back.roomOf(RoomItemId.kasur), HouseRoom.terrace);
      expect(back.placedIn(HouseRoom.terrace).keys, {RoomItemId.kasur});
    });

    test('barang dinding biasa tidak bisa ke teras, gantungan bisa', () {
      final room = Room(owned: owned);
      expect(
        room.place(RoomItemId.lukisan, Spot(0, 0), room: HouseRoom.terrace),
        room,
      );
      final hung = room.place(
        RoomItemId.hammock,
        Spot(0, 0),
        room: HouseRoom.terrace,
      );
      expect(hung.roomOf(RoomItemId.hammock), HouseRoom.terrace);
      // Nama yang tidak boleh di teras dibaca sebagai ruang tengah.
      final json = hung.toJson()..['terrace'] = ['hammock', 'lukisan', 7];
      json['placed'] = <String, dynamic>{
        ...(json['placed'] as Map<String, dynamic>),
        'lukisan': [0.2, 0.2],
      };
      final read = Room.fromJson(json);
      expect(read.roomOf(RoomItemId.lukisan), HouseRoom.living);
      expect(read.roomOf(RoomItemId.hammock), HouseRoom.terrace);
    });

    test('barang lama di jalur pintu digeser ke tempat yang boleh', () {
      final kasur = roomItemOf(RoomItemId.kasur);
      final blocked = floor.spotAtFeet(300, 500);
      expect(floor.blocksDoor(kasur, HouseRoom.living, blocked), isTrue);
      final room = Room.fromJson({
        'owned': ['kasur'],
        'placed': {'kasur': blocked.toJson()},
      });
      final spot = room.spotOf(RoomItemId.kasur)!;
      expect(floor.blocksDoor(kasur, HouseRoom.living, spot), isFalse);
      final placed = room.place(RoomItemId.kasur, blocked);
      expect(
        floor.blocksDoor(
          kasur,
          HouseRoom.living,
          placed.spotOf(RoomItemId.kasur)!,
        ),
        isFalse,
      );
    });

    test('ke Gudang menghapus ruangannya; beli di ruang tengah', () {
      final room = Room(owned: owned)
          .place(RoomItemId.kasur, Spot(0.5, 0.9), room: HouseRoom.terrace)
          .store(RoomItemId.kasur);
      expect(room.roomOf(RoomItemId.kasur), HouseRoom.living);
      expect(room.placedIn(HouseRoom.terrace), isEmpty);
      expect(
        Room.initial.buy(RoomItemId.bola).roomOf(RoomItemId.bola),
        HouseRoom.living,
      );
    });
  });

  group('simpanan lama dan pintu depan', () {
    const floor = HouseFloor();
    final tiang = roomItemOf(RoomItemId.tiang);
    final kasur = roomItemOf(RoomItemId.kasur);
    // Posisi bawaan tiang garukan v1 (pojok kiri) jatuh di jalur pintu
    // depan.
    final oldTiang = spotAt(tiang, 20, 330);

    test('posisi bawaan baru tiang garukan di luar jalur pintu depan', () {
      expect(floor.blocksDoor(tiang, HouseRoom.living, oldTiang), isTrue);
      // AdeganTengah: kiri 266 (lebar 50 × skala 0,78), tengah kaki 285,6.
      final feet = floor.feetAt(tiang.defaultSpot);
      expect(feet.x, closeTo(285.6, 0.5));
      expect(feet.y, closeTo(414, 0.5));
      expect(
        floor.blocksDoor(tiang, HouseRoom.living, tiang.defaultSpot),
        isFalse,
      );
    });

    test('hanya barang yang menutup jalur dipindah, ke tempat bebas', () {
      final kasurAt = floor.spotAtFeet(195, 630);
      // Barang di luar jalur tetap, juga kalau bertumpuk (aturan v1).
      final kardusAt = floor.spotAtFeet(200, 635);
      final room = Room.fromJson({
        'owned': ['tiang', 'kasur', 'kardus'],
        'placed': {
          'tiang': oldTiang.toJson(),
          'kasur': kasurAt.toJson(),
          'kardus': kardusAt.toJson(),
        },
      });
      expect(room.spotOf(RoomItemId.kasur), kasurAt);
      expect(room.spotOf(RoomItemId.kardus), kardusAt);
      final moved = room.spotOf(RoomItemId.tiang)!;
      expect(moved, isNot(oldTiang));
      expect(floor.blocksDoor(tiang, HouseRoom.living, moved), isFalse);
      for (final (other, at) in [
        (kasur, kasurAt),
        (roomItemOf(RoomItemId.kardus), kardusAt),
      ]) {
        expect(
          floor.footprint(tiang, moved).overlaps(floor.footprint(other, at)),
          isFalse,
        );
      }
    });

    test('tanpa tempat bebas: masuk Gudang, tetap dimiliki', () {
      final room = Room.fromJson({
        'owned': ['tiang'],
        'placed': {'tiang': oldTiang.toJson()},
      }, floor: const _FullFloor());
      expect(room.owns(RoomItemId.tiang), isTrue);
      expect(room.isPlaced(RoomItemId.tiang), isFalse);
      expect(room.stored, [RoomItemId.tiang]);
    });

    test('mangkuk tidak pernah ke Gudang', () {
      final blocked = floor.spotAtFeet(60, 480);
      final room = Room.fromJson({
        'owned': <String>[],
        'placed': {'mangkuk': blocked.toJson()},
      }, floor: const _FullFloor());
      final spot = room.spotOf(RoomItemId.mangkuk)!;
      expect(
        floor.blocksDoor(
          roomItemOf(RoomItemId.mangkuk),
          HouseRoom.living,
          spot,
        ),
        isFalse,
      );
    });
  });
}

/// Lantai tanpa tempat bebas sama sekali (ruangan penuh).
class _FullFloor extends HouseFloor {
  const _FullFloor();

  @override
  Spot? freeSpot(
    RoomItem item,
    HouseRoom room,
    Spot spot,
    Iterable<({RoomItem item, Spot spot})> others,
  ) => null;
}
