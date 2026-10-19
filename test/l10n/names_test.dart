import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';

import '../test_helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final chapters = chaptersOf(testLevels);

  test('nama level Indonesia sama dengan data level, ke-20 level', () {
    for (final level in testLevels) {
      expect(levelName(l10nId, level), level.name, reason: '${level.id}');
    }
  });

  test('nama level bahasa lain, bos dengan awalan', () {
    expect(levelName(en, testLevels[12]), "Mom's Vase");
    expect(levelName(en, testLevels[9]), 'BOSS: Salted Fish Feast');
    expect(levelName(ru, testLevels[19]), 'БОСС: Ураза-байрам');
    for (final level in testLevels) {
      expect(levelName(en, level), isNot(level.name), reason: '${level.id}');
    }
  });

  test('level tanpa terjemahan memakai nama di data', () {
    final extra = Level(
      id: 21,
      name: 'Lorong Panjang',
      chapter: 3,
      map: testLevels.first.map,
      inventory: const {},
      starItems: 0,
      solution: const [],
      solutionSteps: 0,
    );
    expect(levelName(en, extra), 'Lorong Panjang');
  });

  test('babak dan bos', () {
    final [kitchen, livingRoom] = chapters;
    expect(chapterName(l10nId, kitchen), 'Dapur');
    expect(chapterTitle(l10nId, kitchen), 'Babak 1 – Dapur');
    expect(chapterTitle(en, livingRoom), 'Chapter 2 – Living Room');
    expect(bossName(l10nId, kitchen), 'Pesta Ikan Asin');
    expect(bossName(l10nId, livingRoom), 'Hari Lebaran');
    expect(bossName(en, livingRoom), 'Eid Day');
  });

  test('kostum, benda, dan Oyen', () {
    expect(
      [for (final c in OyenCostume.values) costumeName(l10nId, c)],
      ['Polos', 'Peci', 'Sarung', 'Topi Koki', 'Kacamata'],
    );
    expect(costumeName(en, OyenCostume.koki), 'Chef Hat');
    expect(itemName(l10nId, Item.water), 'Ember air');
    expect(itemName(en, Item.fish), 'Salted fish');
    const look = OyenLook(pose: OyenPose.sleep, dir: Direction.left);
    expect(oyenLabel(l10nId, look), 'Oyen tidur, menghadap kiri');
    expect(oyenLabel(en, look), 'Oyen asleep, facing left');
    expect(
      oyenLabel(ru, const OyenLook(pose: OyenPose.walk, dir: Direction.up)),
      'Ойен идёт, смотрит вверх',
    );
  });

  test('tutorial level 1, 3, 6', () {
    expect(
      tutorialTitle(l10nId, tutorialFor(1)!),
      'Oyen nggak bisa disuruh. Bangunkan saja dia!',
    );
    expect(
      tutorialBody(l10nId, tutorialFor(6)!),
      'Taruh ember di jalannya. Ketemu air, dia kaget lalu putar balik.',
    );
    expect(
      tutorialTitle(en, tutorialFor(3)!),
      "Oyen can't resist salted fish!",
    );
  });
}
