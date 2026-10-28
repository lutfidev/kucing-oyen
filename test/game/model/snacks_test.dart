import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/snacks.dart';

void main() {
  test('5 camilan: harga Toko, Lapar dan Senang dari Kamar', () {
    expect(
      [for (final s in snacks) (s.id, s.price, s.hunger, s.joy)],
      [
        (SnackId.ikanAsin, 20, 25, 5),
        (SnackId.susu, 15, 15, 5),
        (SnackId.tuna, 40, 40, 5),
        (SnackId.biskuit, 10, 10, 2),
        (SnackId.puding, 90, 60, 15),
      ],
    );
    expect(snackOf(SnackId.tuna).hunger, 40);
  });

  group('Pantry', () {
    test('tambah dan ambil', () {
      final pantry = Pantry.empty.add(SnackId.susu).add(SnackId.susu);
      expect(pantry.countOf(SnackId.susu), 2);
      expect(pantry.countOf(SnackId.tuna), 0);
      expect(pantry.take(SnackId.susu)!.countOf(SnackId.susu), 1);
      expect(Pantry.empty.take(SnackId.susu), isNull);
    });

    test('paling banyak 99 per jenis', () {
      var pantry = Pantry.empty;
      for (var i = 0; i < maxSnackStock; i++) {
        expect(pantry.canAdd(SnackId.biskuit), isTrue);
        pantry = pantry.add(SnackId.biskuit);
      }
      expect(pantry.countOf(SnackId.biskuit), 99);
      expect(pantry.canAdd(SnackId.biskuit), isFalse);
      expect(pantry.add(SnackId.biskuit), pantry);
      expect(pantry.canAdd(SnackId.susu), isTrue);
    });

    test('JSON pulang-pergi', () {
      final pantry = Pantry({SnackId.susu: 3, SnackId.puding: 1});
      expect(Pantry.fromJson(pantry.toJson()), pantry);
      expect(Pantry.fromJson(Pantry.empty.toJson()), Pantry.empty);
    });

    test('JSON rusak dibuang; lebih dari 99 jadi 99', () {
      final read = Pantry.fromJson({
        'susu': 2,
        'tuna': -1,
        'biskuit': 'x',
        'kue': 4,
        'puding': 500,
        'ikanAsin': 1.5,
      });
      expect(read, Pantry({SnackId.susu: 2, SnackId.puding: 99}));
    });
  });
}
