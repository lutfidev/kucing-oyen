import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/kitties.dart';

void main() {
  test('16 aksesoris: urutan, harga, kelangkaan, jangkar persis desain', () {
    const common = Rarity.common, rare = Rarity.rare, special = Rarity.special;
    const top = AccessoryAnchor.headTop, neck = AccessoryAnchor.neck;
    expect(
      [for (final a in accessories) (a.id.name, a.price, a.rarity, a.anchor)],
      [
        ('pita', 50, common, AccessoryAnchor.headSideRight),
        ('jepitBunga', 60, common, AccessoryAnchor.headSideLeft),
        ('bandana', 80, common, neck),
        ('dasiKupu', 90, common, neck),
        ('kalung', 120, common, neck),
        ('syal', 140, common, neck),
        ('beanie', 180, rare, top),
        ('topiKoki', 200, rare, top),
        ('baret', 220, rare, top),
        ('kacamata', 250, rare, AccessoryAnchor.face),
        ('headphone', 280, rare, top),
        ('tandukRusa', 320, rare, top),
        ('topiPesta', 350, rare, top),
        ('topiPenyihir', 520, special, top),
        ('mahkota', 600, special, top),
        ('mahkotaRaja', 800, special, top),
      ],
    );
    expect(accessories.fold(0, (sum, a) => sum + a.price), 4260);
    expect(accessoryOf(AccessoryId.kacamata).price, 250);
  });

  group('AccessoryCloset', () {
    final closet = AccessoryCloset.initial
        .buy(AccessoryId.pita)
        .buy(AccessoryId.kalung);

    test('awal kosong; beli tidak langsung dipakai', () {
      expect(AccessoryCloset.initial.owned, isEmpty);
      expect(closet.owned, {AccessoryId.pita, AccessoryId.kalung});
      expect(closet.wearingOf(KittyId.oyen), isNull);
      expect(closet.buy(AccessoryId.pita), closet);
    });

    test('canBuy: belum dimiliki dan koin cukup', () {
      expect(closet.canBuy(AccessoryId.bandana, 80), isTrue);
      expect(closet.canBuy(AccessoryId.bandana, 79), isFalse);
      expect(closet.canBuy(AccessoryId.pita, 999), isFalse);
    });

    test('satu aksesoris dipakai beberapa kucing sekaligus', () {
      final worn = closet
          .wear(KittyId.oyen, AccessoryId.pita)
          .wear(KittyId.arang, AccessoryId.pita);
      expect(worn.wearingOf(KittyId.oyen), AccessoryId.pita);
      expect(worn.wearingOf(KittyId.arang), AccessoryId.pita);
    });

    test('ganti dan lepas; satu kucing satu aksesoris', () {
      final worn = closet.wear(KittyId.oyen, AccessoryId.pita);
      final swapped = worn.wear(KittyId.oyen, AccessoryId.kalung);
      expect(swapped.wearingOf(KittyId.oyen), AccessoryId.kalung);
      final off = swapped.wear(KittyId.oyen, null);
      expect(off.wearingOf(KittyId.oyen), isNull);
      expect(off.owned, closet.owned);
    });

    test('aksesoris yang tidak dimiliki tidak bisa dipakai', () {
      expect(closet.wear(KittyId.oyen, AccessoryId.mahkotaRaja), closet);
      final ghost = AccessoryCloset(
        owned: {AccessoryId.pita},
        wearing: {KittyId.oyen: AccessoryId.beanie},
      );
      expect(ghost.wearingOf(KittyId.oyen), isNull);
    });

    test('JSON pulang-pergi', () {
      final worn = closet
          .wear(KittyId.oyen, AccessoryId.pita)
          .wear(KittyId.salju, AccessoryId.kalung);
      expect(AccessoryCloset.fromJson(worn.toJson()), worn);
      expect(
        AccessoryCloset.fromJson(AccessoryCloset.initial.toJson()),
        AccessoryCloset.initial,
      );
    });

    test('JSON rusak dibuang, termasuk aksesoris yang tidak dimiliki', () {
      final read = AccessoryCloset.fromJson({
        'owned': ['pita', 'peci', 3, null],
        'wearing': {
          'oyen': 'pita',
          'arang': 'beanie',
          'harimau': 'pita',
          'salju': 7,
        },
      });
      expect(read.owned, {AccessoryId.pita});
      expect(read.wearing, {KittyId.oyen: AccessoryId.pita});
      expect(
        AccessoryCloset.fromJson({'owned': 'x', 'wearing': []}),
        AccessoryCloset.initial,
      );
    });
  });
}
