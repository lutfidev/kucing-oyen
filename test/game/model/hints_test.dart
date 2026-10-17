import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/hints.dart';
import 'package:kucing_oren/game/sim/sim.dart';

import '../../test_helpers.dart';

Level byId(int id) => testLevels.firstWhere((l) => l.id == id);

void main() {
  test('koin hanya dari bintang baru', () {
    expect(coinsForStars(0, 2), 20);
    expect(coinsForStars(2, 3), 10);
    expect(coinsForStars(3, 3), 0);
    expect(coinsForStars(2, 1), 0);
    expect(coinsForStars(0, 0), 0);
  });

  test('harga tingkat persis desain 10', () {
    expect([for (var t = 1; t <= maxHintTier; t++) hintCost(t)], [20, 40, 80]);
    expect(() => hintCost(0), throwsArgumentError);
    expect(() => hintCost(4), throwsArgumentError);
  });

  test('tanda per tingkat level 13', () {
    final level = byId(13);
    expect(hintMarks(level, 0), isEmpty);
    expect(hintMarks(level, 1), {const Pos(3, 3): null});
    expect(hintMarks(level, 2), {const Pos(3, 3): Item.water});
    expect(hintMarks(level, 3), {
      const Pos(3, 3): Item.water,
      const Pos(2, 4): Item.fish,
    });
  });

  test('level tanpa benda tidak punya tanda', () {
    for (var tier = 0; tier <= maxHintTier; tier++) {
      expect(hintMarks(byId(1), tier), isEmpty);
    }
  });

  test('teks level 13 sama dengan desain 10 untuk tingkat 1 dan 2', () {
    final level = byId(13);
    expect(
      hintText(level, 1),
      'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.',
    );
    expect(
      hintText(level, 2),
      'Taruh ember air di petak yang menyala. '
      'Oyen bakal kaget dan balik badan.',
    );
    expect(
      hintText(level, 3),
      'Ember air dan ikan asin di petak yang menyala. Vas aman, 3 bintang.',
    );
  });

  test('teks tingkat 3 menghitung benda sejenis', () {
    expect(hintText(byId(3), 3), 'Ikan asin di petak yang menyala. 3 bintang!');
    expect(
      hintText(byId(5), 3),
      'Dua ikan asin di petak yang menyala. 3 bintang!',
    );
    expect(
      hintText(byId(10), 3),
      'Ember air dan dua ikan asin di petak yang menyala. 3 bintang!',
    );
    expect(
      hintText(byId(19), 3),
      'Ember air, ikan asin, dan kardus di petak yang menyala. '
      'Vas aman, 3 bintang.',
    );
  });

  test('teks tingkat 2 menyebut benda pertama di semua level berbenda', () {
    const names = {
      Item.fish: 'ikan asin',
      Item.water: 'ember air',
      Item.box: 'kardus',
    };
    for (final level in testLevels.where((l) => l.solution.isNotEmpty)) {
      final name = names[level.solution.first.item]!;
      expect(
        hintText(level, 2),
        startsWith('Taruh $name di petak yang menyala. Oyen bakal '),
        reason: 'level ${level.id}',
      );
    }
    expect(
      hintText(byId(3), 2),
      'Taruh ikan asin di petak yang menyala. '
      'Oyen bakal ngejar dan makan ikannya.',
    );
    expect(
      hintText(byId(14), 2),
      'Taruh ikan asin di petak yang menyala. '
      'Oyen bakal ngejar dan makan ikannya.',
    );
  });

  test('teks kardus', () {
    // Level 14: kardus di urutan kedua; tingkat 3 menyebutnya.
    expect(
      hintText(byId(14), 3),
      'Ikan asin dan kardus di petak yang menyala. 3 bintang!',
    );
    expect(hintEffect(Item.box), 'Oyen bakal masuk dan duduk di situ.');
  });

  test('pesan level tanpa benda', () {
    expect(
      noItemsHintText,
      'Level ini nggak butuh benda. Langsung bangunkan Oyen!',
    );
  });
}
