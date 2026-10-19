import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/render/oyen.dart';

void main() {
  test('urutan, nama, dan harga persis desain 12', () {
    expect(
      [for (final c in costumes) c.id],
      [
        OyenCostume.none,
        OyenCostume.peci,
        OyenCostume.sarung,
        OyenCostume.koki,
        OyenCostume.kacamata,
      ],
    );
    expect([for (final c in costumes) c.price], [0, 60, 90, 150, 45]);
    expect(costumeOf(OyenCostume.koki).price, 150);
  });

  group('Wardrobe', () {
    test('awal: hanya Polos, dipakai', () {
      expect(Wardrobe.initial.owned, {OyenCostume.none});
      expect(Wardrobe.initial.wearing, OyenCostume.none);
    });

    test('Polos selalu dimiliki, kostum dipakai harus dimiliki', () {
      final w = Wardrobe(owned: {OyenCostume.peci}, wearing: OyenCostume.koki);
      expect(w.owned, {OyenCostume.none, OyenCostume.peci});
      expect(w.wearing, OyenCostume.none);
    });

    test('bisa beli kalau belum dimiliki dan koin cukup', () {
      final w = Wardrobe.initial;
      expect(w.canBuy(OyenCostume.kacamata, 45), isTrue);
      expect(w.canBuy(OyenCostume.kacamata, 44), isFalse);
      expect(w.canBuy(OyenCostume.none, 0), isFalse);
    });

    test('beli = dimiliki dan langsung dipakai', () {
      final w = Wardrobe.initial.buy(OyenCostume.peci);
      expect(w.owns(OyenCostume.peci), isTrue);
      expect(w.wearing, OyenCostume.peci);
      expect(identical(w.buy(OyenCostume.peci), w), isTrue);
    });

    test('pakai hanya kostum yang dimiliki', () {
      final w = Wardrobe.initial.buy(OyenCostume.peci);
      expect(identical(w.wear(OyenCostume.sarung), w), isTrue);
      final plain = w.wear(OyenCostume.none);
      expect(plain.wearing, OyenCostume.none);
      expect(plain.owns(OyenCostume.peci), isTrue);
    });

    test('aksi tombol per keadaan', () {
      final w = Wardrobe(
        owned: {OyenCostume.peci, OyenCostume.koki},
        wearing: OyenCostume.koki,
      );
      expect(w.actionFor(OyenCostume.koki, 0), CostumeAction.wearing);
      expect(w.actionFor(OyenCostume.peci, 0), CostumeAction.wear);
      expect(w.actionFor(OyenCostume.sarung, 90), CostumeAction.buy);
      expect(w.actionFor(OyenCostume.sarung, 89), CostumeAction.notEnoughCoins);
    });

    test('sama kalau isinya sama', () {
      expect(
        Wardrobe(owned: {OyenCostume.peci}, wearing: OyenCostume.peci),
        Wardrobe.initial.buy(OyenCostume.peci),
      );
    });
  });
}
