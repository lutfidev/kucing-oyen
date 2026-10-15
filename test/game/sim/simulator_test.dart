import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );

  group('Level 13 · Vas Ibu', () {
    final board = levels.firstWhere((l) => l.id == 13).board;

    test('tanpa benda gagal mondar-mandir', () {
      final result = simulate(board);
      expect(result.win, isFalse);
      expect(result.failReason, FailReason.loop);
      // Sama dengan acuan Python: steps=25, vas ikut pecah.
      expect(result.steps, 25);
      expect(result.vaseBroken, isTrue);
    });

    test('ikan saja di (2,4) menang, tapi vas pecah di langkah 2', () {
      final result = simulate(board, const [Placement(Item.fish, Pos(2, 4))]);
      expect(result.win, isTrue);
      expect(result.vaseBroken, isTrue);
      expect(result.vaseBrokenAtStep, 2);
      expect(result.trace[1].kind, StepKind.knockVase);
      expect(result.trace[1].changed, const Pos(2, 3));
      // Log acuan Python, langkah 1–10.
      expect(result.trace.map((s) => s.toString()), [
        'walk(3,3)<',
        'knockVase(3,3)<',
        'turn(3,3)^',
        'turn(3,3)>',
        'walk(4,3)>',
        'walk(5,3)>',
        'turn(5,3)v',
        'walk(5,4)v',
        'walk(4,4)<',
        'walk(3,4)<',
      ]);
      expect(result.steps, 10);
    });
  });

  group('batas $maxSteps langkah', () {
    // Lorong lurus: Oyen menghadap kanan, mangkuk tepat [distance] petak di
    // depannya, jadi tidak ada keadaan yang berulang.
    Board corridor(int distance) {
      final wall = '#' * (distance + 3);
      return Board.parse([wall, '#>${'.' * (distance - 1)}T#', wall]);
    }

    test('mangkuk di langkah $maxSteps masih menang', () {
      final result = simulate(corridor(maxSteps));
      expect(result.win, isTrue);
      expect(result.steps, maxSteps);
    });

    test('mangkuk di langkah ${maxSteps + 1} gagal kelamaan', () {
      final result = simulate(corridor(maxSteps + 1));
      expect(result.win, isFalse);
      expect(result.failReason, FailReason.tooManySteps);
      expect(result.steps, maxSteps);
      expect(result.trace, hasLength(maxSteps + 1));
    });
  });

  group('menaruh benda', () {
    final board = levels.firstWhere((l) => l.id == 13).board;

    test('ditolak di tembok, meja, mangkuk, dan petak Oyen', () {
      for (final pos in const [Pos(0, 0), Pos(2, 3), Pos(3, 4), Pos(4, 3)]) {
        expect(
          () => simulate(board, [Placement(Item.fish, pos)]),
          throwsArgumentError,
          reason: '$pos',
        );
      }
    });

    test('ditolak kalau dua benda di petak yang sama', () {
      expect(
        () => simulate(board, const [
          Placement(Item.fish, Pos(2, 4)),
          Placement(Item.water, Pos(2, 4)),
        ]),
        throwsArgumentError,
      );
    });

    test('petak kosong tidak termasuk petak Oyen', () {
      expect(board.emptyCells, isNot(contains(board.start)));
      expect(board.emptyCells.every(board.canPlace), isTrue);
    });
  });
}
