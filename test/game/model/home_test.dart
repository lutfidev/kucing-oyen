import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/snacks.dart';

void main() {
  test('awal: Oyen, kamar dengan mangkuk, tanpa aksesoris dan stok', () {
    expect(Home.initial.kitties, {KittyId.oyen});
    expect(Home.initial.room, Room.initial);
    expect(Home.initial.closet, AccessoryCloset.initial);
    expect(Home.initial.pantry, Pantry.empty);
  });

  test('Oyen selalu dimiliki', () {
    final home = Home(kitties: {KittyId.salju});
    expect(home.kitties, {KittyId.oyen, KittyId.salju});
    expect(home.ownsKitty(KittyId.oyen), isTrue);
  });

  test('canBuyKitty: belum dimiliki dan koin cukup', () {
    expect(Home.initial.canBuyKitty(KittyId.salju, 300), isTrue);
    expect(Home.initial.canBuyKitty(KittyId.salju, 299), isFalse);
    expect(Home.initial.canBuyKitty(KittyId.oyen, 999), isFalse);
  });

  test('copyWith mengganti satu bagian', () {
    final room = Room.initial.buy(RoomItemId.bola);
    final home = Home.initial.copyWith(room: room);
    expect(home.room, room);
    expect(home.kitties, Home.initial.kitties);
    expect(home.copyWith(kitties: {KittyId.arang}).room, room);
  });

  test('JSON pulang-pergi', () {
    final home = Home(
      room: Room.initial.buy(RoomItemId.kardus),
      kitties: {KittyId.arang},
      closet: AccessoryCloset.initial
          .buy(AccessoryId.pita)
          .wear(KittyId.arang, AccessoryId.pita),
      pantry: Pantry({SnackId.susu: 2}),
    );
    expect(Home.fromJson(home.toJson()), home);
    expect(Home.fromJson(Home.initial.toJson()), Home.initial);
  });

  test('bagian JSON rusak kembali ke awal, bagian lain tetap', () {
    final home = Home.fromJson({
      'room': 'x',
      'kitties': ['salju', 'harimau', 3],
      'closet': [],
      'pantry': {'susu': 1},
    });
    expect(home.room, Room.initial);
    expect(home.kitties, {KittyId.oyen, KittyId.salju});
    expect(home.closet, AccessoryCloset.initial);
    expect(home.pantry, Pantry({SnackId.susu: 1}));
    expect(Home.fromJson({}), Home.initial);
  });

  test('aksesoris dipakai kucing yang tidak dimiliki dibuang', () {
    final home = Home.fromJson({
      'kitties': ['arang'],
      'closet': {
        'owned': ['pita'],
        'wearing': {'oyen': 'pita', 'arang': 'pita', 'bos': 'pita'},
      },
    });
    expect(home.closet.wearing, {
      KittyId.oyen: AccessoryId.pita,
      KittyId.arang: AccessoryId.pita,
    });
  });
}
