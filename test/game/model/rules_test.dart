import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rules.dart';

import '../../test_helpers.dart';

void main() {
  test('lima kartu urut desain 05, nomor 1–5', () {
    expect(OyenRule.values, [
      OyenRule.knock,
      OyenRule.fish,
      OyenRule.water,
      OyenRule.wall,
      OyenRule.box,
    ]);
    expect(OyenRule.values.map((r) => r.number), [1, 2, 3, 4, 5]);
  });

  test('level pengenalan sesuai kolom "Hal baru" GDD', () {
    expect(
      {for (final r in OyenRule.values) r: r.level},
      {
        OyenRule.knock: 12,
        OyenRule.fish: 3,
        OyenRule.water: 6,
        OyenRule.wall: 2,
        OyenRule.box: 14,
      },
    );
  });

  group('kartu terbuka per level (progres sampai level sebelumnya)', () {
    final expected = <int, Set<OyenRule>>{
      1: {},
      2: {OyenRule.wall},
      3: {OyenRule.wall, OyenRule.fish},
      5: {OyenRule.wall, OyenRule.fish},
      6: {OyenRule.wall, OyenRule.fish, OyenRule.water},
      11: {OyenRule.wall, OyenRule.fish, OyenRule.water},
      12: {OyenRule.wall, OyenRule.fish, OyenRule.water, OyenRule.knock},
      // Layar contoh desain: kardus masih "???" di level 13.
      13: {OyenRule.wall, OyenRule.fish, OyenRule.water, OyenRule.knock},
      14: OyenRule.values.toSet(),
      20: OyenRule.values.toSet(),
    };
    for (final MapEntry(key: id, value: rules) in expected.entries) {
      test('level $id', () {
        final progress = Progress(wonUpTo(id - 1));
        expect(learnedRules(progress, id), rules);
      });
    }
  });

  test('level yang sudah terbuka membuka kartunya di level sebelumnya', () {
    // Level 14 terbuka setelah level 13 menang: main ulang level 1 pun
    // kartu kardus sudah terbuka.
    expect(learnedRules(Progress(wonUpTo(13)), 1), OyenRule.values.toSet());
    expect(
      learnedRules(Progress(wonUpTo(12)), 1),
      isNot(contains(OyenRule.box)),
    );
  });

  test('level dibuka lewat rute tanpa progres: kartu sampai level itu', () {
    expect(learnedRules(Progress.empty, 6), {
      OyenRule.wall,
      OyenRule.fish,
      OyenRule.water,
    });
  });
}
