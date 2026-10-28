import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/kitties.dart';

void main() {
  test('Oyen gratis, lalu 8 kucing Toko dengan harga desain', () {
    expect(kitties.first.id, KittyId.oyen);
    expect(kitties.first.price, 0);
    expect([for (final k in kitties) k.id], KittyId.values);
    expect(
      {for (final k in kitties) k.id: k.price},
      {
        KittyId.oyen: 0,
        KittyId.salju: 300,
        KittyId.telon: 550,
        KittyId.arang: 400,
        KittyId.mendung: 350,
        KittyId.kopiSusu: 300,
        KittyId.mochi: 450,
        KittyId.bos: 600,
        KittyId.kembang: 700,
      },
    );
    expect(kitties.fold(0, (sum, k) => sum + k.price), 3650);
    expect(kittyOf(KittyId.bos).price, 600);
  });
}
