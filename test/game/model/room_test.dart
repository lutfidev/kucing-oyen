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
      // Barang di luar jalur tetap, juga kalau bertumpuk (simpanan yang
      // sudah dirapikan sekali, `tidy: 1`).
      final kardusAt = floor.spotAtFeet(200, 635);
      final room = Room.fromJson({
        'tidy': 1,
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
          floor.stacks((item: tiang, spot: moved), (item: other, spot: at)),
          isFalse,
        );
      }
    });

    test(
      'dua barang lama di jalur pintu: keduanya pindah, tidak bertumpuk',
      () {
        final rumah = roomItemOf(RoomItemId.rumah);
        final rumahAt = floor.spotAtFeet(60, 480);
        expect(floor.blocksDoor(rumah, HouseRoom.living, rumahAt), isTrue);
        final room = Room.fromJson({
          'owned': ['tiang', 'rumah'],
          'placed': {'tiang': oldTiang.toJson(), 'rumah': rumahAt.toJson()},
        });
        final movedRumah = room.spotOf(RoomItemId.rumah)!;
        final movedTiang = room.spotOf(RoomItemId.tiang)!;
        expect(floor.blocksDoor(rumah, HouseRoom.living, movedRumah), isFalse);
        expect(floor.blocksDoor(tiang, HouseRoom.living, movedTiang), isFalse);
        expect(
          floor.stacks(
            (item: rumah, spot: movedRumah),
            (item: tiang, spot: movedTiang),
          ),
          isFalse,
        );
        // Dibaca ulang: tempat barunya tetap (tidak bergeser tiap dibuka).
        expect(
          Room.fromJson(room.toJson()).spotOf(RoomItemId.rumah),
          movedRumah,
        );
        expect(
          Room.fromJson(room.toJson()).spotOf(RoomItemId.tiang),
          movedTiang,
        );
      },
    );

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

  group('rapi (langkah 40)', () {
    const floor = HouseFloor();
    final kasur = roomItemOf(RoomItemId.kasur);
    final spotA = floor.spotAtFeet(150, 610);
    final farAway = floor.spotAtFeet(190, 440);

    void expectTidy(Room room, HouseRoom which) {
      final items = [
        for (final MapEntry(:key, :value) in room.placedIn(which).entries)
          if (!(which == HouseRoom.terrace && terraceHangers.contains(key)))
            (item: roomItemOf(key), spot: value),
      ];
      for (var i = 0; i < items.length; i++) {
        expect(
          floor.blocksDoor(items[i].item, which, items[i].spot),
          isFalse,
          reason: '${items[i].item.id}',
        );
        for (var j = i + 1; j < items.length; j++) {
          expect(
            floor.stacks(items[i], items[j]),
            isFalse,
            reason: '${items[i].item.id} x ${items[j].item.id}',
          );
        }
      }
    }

    test('tidy memindah barang yang menumpuk, sisanya tetap', () {
      final room = Room(
        owned: [RoomItemId.kasur, RoomItemId.sofaMini, RoomItemId.lukisan],
        placed: {
          RoomItemId.kasur: spotA,
          RoomItemId.sofaMini: spotA,
          RoomItemId.lukisan: Spot(0, 0),
        },
      );
      final tidy = room.tidy(HouseRoom.living);
      // Kasur lebih dulu di katalog: tetap; sofa pindah.
      expect(tidy.spotOf(RoomItemId.kasur), spotA);
      expect(tidy.spotOf(RoomItemId.sofaMini), isNot(spotA));
      expect(tidy.spotOf(RoomItemId.lukisan), Spot(0, 0));
      expect(tidy.spotOf(RoomItemId.mangkuk), room.spotOf(RoomItemId.mangkuk));
      expectTidy(tidy, HouseRoom.living);
      expect(tidy.movedFrom(room), {RoomItemId.sofaMini});
    });

    test('ruangan yang sudah rapi tidak berubah', () {
      final room = Room(
        owned: [RoomItemId.kasur, RoomItemId.sofaMini],
        placed: {RoomItemId.kasur: spotA, RoomItemId.sofaMini: farAway},
      );
      expect(room.tidy(HouseRoom.living), room);
      expect(room.tidy(HouseRoom.living).movedFrom(room), isEmpty);
    });

    test('rumah penuh: tidak ada yang menumpuk, tidak ke ruangan lain', () {
      final all = [for (final item in shopItems) item.id];
      final room = Room(
        owned: all,
        placed: {for (final id in all) id: Spot(0.5, 0.5)},
      );
      final tidy = room.tidy(HouseRoom.living);
      expectTidy(tidy, HouseRoom.living);
      expect(tidy.placedIn(HouseRoom.terrace), isEmpty);
      expect(tidy.owned, room.owned);
      expect(tidy.isPlaced(RoomItemId.mangkuk), isTrue);
      // Sekali sama dengan dua kali.
      expect(tidy.tidy(HouseRoom.living), tidy);
      for (final id in tidy.movedFrom(room)) {
        expect(tidy.roomOf(id), HouseRoom.living);
      }
    });

    test('tanpa tempat: masuk Gudang; mangkuk tetap ditaruh', () {
      final room = Room(
        owned: [RoomItemId.kasur, RoomItemId.sofaMini],
        placed: {
          RoomItemId.kasur: spotA,
          RoomItemId.sofaMini: spotA,
          RoomItemId.mangkuk: spotA,
        },
      );
      final tidy = room.tidy(HouseRoom.living, floor: const _FullFloor());
      expect(tidy.isPlaced(RoomItemId.mangkuk), isTrue);
      // Mangkuk diproses pertama: kasur dan sofa yang menimpanya ke Gudang.
      expect(tidy.stored, [RoomItemId.kasur, RoomItemId.sofaMini]);
    });

    test('tidy tidak menyentuh ruangan lain', () {
      final room = Room(
        owned: [RoomItemId.kasur, RoomItemId.sofaMini],
        placed: {RoomItemId.kasur: spotA, RoomItemId.sofaMini: spotA},
        rooms: {
          RoomItemId.kasur: HouseRoom.terrace,
          RoomItemId.sofaMini: HouseRoom.terrace,
        },
      );
      expect(room.tidy(HouseRoom.living), room);
      expectTidy(room.tidy(HouseRoom.terrace), HouseRoom.terrace);
    });

    test('beli: spot bawaan terisi -> tempat kosong terdekat', () {
      final room = Room(
        owned: [RoomItemId.sofaMini],
        placed: {RoomItemId.sofaMini: kasur.defaultSpot},
      );
      final bought = room.buyPlaced(RoomItemId.kasur);
      expect(bought.at, HouseRoom.living);
      expect(bought.room.spotOf(RoomItemId.kasur), isNot(kasur.defaultSpot));
      expectTidy(bought.room, HouseRoom.living);
      expect(room.buy(RoomItemId.kasur), bought.room);
    });

    test('beli saat ruang tengah penuh -> teras; barang dinding -> Gudang', () {
      final full = _LivingFullFloor();
      final room = Room.initial;
      final kasurBought = room.buyPlaced(RoomItemId.kasur, floor: full);
      expect(kasurBought.at, HouseRoom.terrace);
      expect(kasurBought.room.roomOf(RoomItemId.kasur), HouseRoom.terrace);
      final wall = room.buyPlaced(RoomItemId.lukisan, floor: full);
      expect(wall.at, isNull);
      expect(wall.room.stored, [RoomItemId.lukisan]);
    });

    test('simpanan lama tanpa tidy dirapikan sekali; dengan tidy tidak', () {
      final json = {
        'owned': ['kasur', 'sofaMini'],
        'placed': {'kasur': spotA.toJson(), 'sofaMini': spotA.toJson()},
      };
      final once = Room.fromJson(json);
      expectTidy(once, HouseRoom.living);
      expect(once.toJson()['tidy'], 1);
      final kept = Room.fromJson({...json, 'tidy': 1});
      expect(kept.spotOf(RoomItemId.kasur), spotA);
      expect(kept.spotOf(RoomItemId.sofaMini), spotA);
      // Dibaca ulang: tidak dirapikan lagi.
      expect(Room.fromJson(once.toJson()), once);
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

/// Ruang tengah selalu penuh; teras seperti biasa.
class _LivingFullFloor extends HouseFloor {
  @override
  Spot? freeSpot(
    RoomItem item,
    HouseRoom room,
    Spot spot,
    Iterable<({RoomItem item, Spot spot})> others,
  ) => room == HouseRoom.living
      ? null
      : super.freeSpot(item, room, spot, others);
}
