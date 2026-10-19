import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/hints.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/hint_texts.dart';
import 'package:kucing_oren/l10n/l10n.dart';

import '../../test_helpers.dart';

Level byId(int id) => testLevels.firstWhere((l) => l.id == id);

/// Kalimat petunjuk tingkat [tier] (default bahasa Indonesia).
String text(Level level, int tier, [AppLocalizations? l]) =>
    hintTextFor(l ?? l10nId, hintText(level, tier));

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
      text(level, 1),
      'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.',
    );
    expect(
      text(level, 2),
      'Taruh ember air di petak yang menyala. '
      'Oyen bakal kaget dan balik badan.',
    );
    expect(
      text(level, 3),
      'Ember air dan ikan asin di petak yang menyala. Vas aman, 3 bintang.',
    );
  });

  test('teks tingkat 3 menghitung benda sejenis', () {
    expect(text(byId(3), 3), 'Ikan asin di petak yang menyala. 3 bintang!');
    expect(text(byId(5), 3), 'Dua ikan asin di petak yang menyala. 3 bintang!');
    expect(
      text(byId(10), 3),
      'Ember air dan dua ikan asin di petak yang menyala. 3 bintang!',
    );
    expect(
      text(byId(19), 3),
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
        text(level, 2),
        startsWith('Taruh $name di petak yang menyala. Oyen bakal '),
        reason: 'level ${level.id}',
      );
    }
    expect(
      text(byId(3), 2),
      'Taruh ikan asin di petak yang menyala. '
      'Oyen bakal ngejar dan makan ikannya.',
    );
    expect(
      text(byId(14), 2),
      'Taruh ikan asin di petak yang menyala. '
      'Oyen bakal ngejar dan makan ikannya.',
    );
  });

  test('teks kardus', () {
    // Level 14: kardus di urutan kedua; tingkat 3 menyebutnya.
    expect(
      text(byId(14), 3),
      'Ikan asin dan kardus di petak yang menyala. 3 bintang!',
    );
    expect(
      l10nId.hintPlaceBox,
      'Taruh kardus di petak yang menyala. Oyen bakal masuk dan duduk di situ.',
    );
  });

  test('isi petunjuk sebagai data: benda sejenis urut kemunculan', () {
    expect(
      hintText(byId(10), 3),
      const HintText(3, items: [(Item.water, 1), (Item.fish, 2)]),
    );
    expect(hintText(byId(13), 2), const HintText(2, item: Item.water));
    expect(hintText(byId(13), 1), const HintText(1));
    expect(hintText(byId(19), 3).hasVase, isTrue);
    expect(() => hintText(byId(13), 4), throwsArgumentError);
  });

  test('tingkat 3 di bahasa lain: daftar dan jumlah per bahasa', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final pt = lookupAppLocalizations(const Locale('pt'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(
      text(byId(19), 3, en),
      'A water bucket, a salted fish, and a box on the glowing tiles. '
      'Vase safe, 3 stars.',
    );
    expect(
      text(byId(19), 3, pt),
      'Um balde de água, um peixe salgado e uma caixa nos quadrados acesos. '
      'Vaso inteiro, 3 estrelas.',
    );
    expect(
      text(byId(10), 3, ru),
      'Поставь ведро воды и две солёные рыбки на светящиеся клетки. '
      '3 звезды!',
    );
    expect(
      text(byId(5), 3, en),
      'Two salted fish on the glowing tiles. 3 stars!',
    );
  });

  test('pesan level tanpa benda', () {
    expect(
      l10nId.noItemsHint,
      'Level ini nggak butuh benda. Langsung bangunkan Oyen!',
    );
  });
}
