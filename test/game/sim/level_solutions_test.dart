import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );

  test('ada 20 level berurutan', () {
    expect(levels.map((l) => l.id), List.generate(20, (i) => i + 1));
  });

  group('solusi bintang 3', () {
    for (final level in levels) {
      test('$level: menang, vas aman, ${level.solutionSteps} langkah', () {
        final result = simulate(level.board, level.solution);
        expect(result.win, isTrue, reason: 'gagal: ${result.failReason}');
        expect(
          result.vaseBroken,
          isFalse,
          reason: 'vas pecah di langkah ${result.vaseBrokenAtStep}',
        );
        expect(result.steps, level.solutionSteps);
      });
    }
  });
}
