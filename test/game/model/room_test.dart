import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
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

    final back = stored.place(RoomItemId.kardus, Spot(0.5, 0.5));
    expect(back.spotOf(RoomItemId.kardus), Spot(0.5, 0.5));
    expect(back.stored, isEmpty);
  });

  test('mangkuk tidak bisa ke Gudang, tapi bisa digeser', () {
    expect(Room.initial.store(RoomItemId.mangkuk), Room.initial);
    final moved = Room.initial.place(RoomItemId.mangkuk, Spot(0.1, 0.2));
    expect(moved.spotOf(RoomItemId.mangkuk), Spot(0.1, 0.2));
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
        'kardus': [0.5, 0.5],
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
      RoomItemId.kardus: Spot(0.5, 0.5),
    });
    expect(room.stored, [RoomItemId.bola]);

    expect(Room.fromJson({'owned': 'x', 'placed': 3}), Room.initial);
    expect(Room.fromJson({}), Room.initial);
  });
}
