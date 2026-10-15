import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );

  // Jumlah solusi minimum dari `solve()` di oyen_simulator.py; level lain 1.
  const solutionCounts = {3: 3, 5: 3, 19: 3, 20: 3, 9: 2, 10: 2, 17: 2, 18: 2};

  // Solver cukup dijalankan sekali per level.
  final solved = <int, SolveResult?>{};
  SolveResult? solveLevel(Level level) =>
      solved.putIfAbsent(level.id, () => solve(level.board, level.inventory));

  for (final level in levels) {
    group('$level', () {
      final count = solutionCounts[level.id] ?? 1;

      test('${level.starItems} benda, $count solusi, termasuk solusi JSON', () {
        final result = solveLevel(level);
        expect(result, isNotNull);
        expect(result!.minItems, level.starItems);
        expect(result.solutions, hasLength(count));
        expect(result.solutions, contains(unorderedEquals(level.solution)));
      });

      test('setiap solusi muat di baki, menang, dan vas aman', () {
        final result = solveLevel(level)!;
        for (final solution in result.solutions) {
          expect(solution, hasLength(result.minItems));
          for (final item in Item.values) {
            expect(
              solution.where((p) => p.item == item).length,
              lessThanOrEqualTo(level.inventory[item] ?? 0),
              reason: '$solution',
            );
          }
          final sim = simulate(level.board, solution);
          expect(sim.win, isTrue, reason: '$solution');
          expect(sim.vaseBroken, isFalse, reason: '$solution');
        }
      });
    });
  }

  test('benda sejenis yang bertukar tempat dihitung satu solusi', () {
    final level5 = levels.firstWhere((l) => l.id == 5);
    expect(level5.inventory, {Item.fish: 2});
    final solutions = solveLevel(level5)!.solutions;
    final asSets = solutions.map((s) => s.toSet()).toList();
    for (var i = 0; i < asSets.length; i++) {
      for (var j = i + 1; j < asSets.length; j++) {
        expect(asSets[i], isNot(equals(asSets[j])));
      }
    }
  });

  test('tanpa syarat vas aman, level 13 cukup satu ikan', () {
    final level13 = levels.firstWhere((l) => l.id == 13);
    final result = solve(level13.board, level13.inventory, needSafe: false)!;
    // Sama dengan acuan Python `solve(..., need_safe=False)`.
    expect(result.minItems, 1);
    expect(result.solutions, [
      [const Placement(Item.fish, Pos(2, 4))],
      [const Placement(Item.fish, Pos(3, 5))],
      [const Placement(Item.fish, Pos(3, 6))],
    ]);
  });

  test('null kalau tidak ada susunan yang menang', () {
    // Oyen terkurung tembok, mangkuk di balik tembok, baki kosong.
    final board = Board.parse(['#####', '#>#T#', '#####']);
    expect(solve(board, const {}), isNull);
  });
}
