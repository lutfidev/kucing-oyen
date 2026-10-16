import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  List<RunFrame> frames(Level level, [List<Placement>? placed]) =>
      runFrames(level.board, simulate(level.board, placed ?? level.solution));

  List<String> path(List<RunFrame> frames) => [
    for (final f in frames) '${f.pos}${f.dir.symbol}',
  ];

  test('level 13: langkah 0 = awal, lalu posisi tiap langkah', () {
    final f = frames(level(13));
    expect(f, hasLength(7));
    expect(f.first.step, 0);
    expect(f.first.action, isNull);
    expect(path(f), [
      '(4,3)<',
      '(4,3)>',
      '(5,3)>',
      '(5,3)v',
      '(5,4)v',
      '(4,4)<',
      '(3,4)<',
    ]);
    expect(
      [for (final x in f.skip(1)) x.action!.kind],
      [
        StepKind.scared,
        StepKind.walk,
        StepKind.turn,
        StepKind.walk,
        StepKind.walk,
        StepKind.walk,
      ],
    );
    expect([for (final x in f) x.atBowl], [...List.filled(6, false), true]);
    expect(f.last.cleared, isEmpty);
    expect(f.last.knocked, isEmpty);
    expect(f.last.vaseBroken, isFalse);
  });

  test('level 13 ikan saja: vas pecah mulai langkah 2', () {
    final f = frames(level(13), [const Placement(Item.fish, Pos(2, 4))]);
    expect(f, hasLength(11));
    expect(f[1].vaseBroken, isFalse);
    expect(f[2].action!.kind, StepKind.knockVase);
    expect(f[2].knocked, {const Pos(2, 3)});
    expect(f[2].vaseBroken, isTrue);
    expect(f.last.knocked, {const Pos(2, 3)});
    expect(f.last.vaseBroken, isTrue);
    expect(f.last.atBowl, isTrue);
  });

  test('level 15: ikan dimakan, kardus diduduki 2 langkah lalu hilang', () {
    final f = frames(level(15));
    expect(f, hasLength(13));
    expect(f[3].action!.kind, StepKind.eat);
    expect(f[3].cleared, {const Pos(1, 4)});
    expect(f[5].cleared, {const Pos(1, 4), const Pos(2, 3)});
    expect(
      [for (final x in f.sublist(7, 10)) x.action!.kind],
      [StepKind.enterBox, StepKind.sit, StepKind.sit],
    );
    expect(
      [for (final x in f) x.inBox],
      [...List.filled(7, false), true, true, false, false, false, false],
    );
    expect(f[8].cleared, isNot(contains(const Pos(2, 4))));
    expect(f[9].cleared, contains(const Pos(2, 4)));
    expect(f.last.cleared, {const Pos(1, 4), const Pos(2, 3), const Pos(2, 4)});
    expect(f.last.atBowl, isTrue);
  });

  test('level 12: gelas yang jatuh tercatat, vas aman', () {
    final f = frames(level(12));
    expect(f.last.knocked, {const Pos(1, 1), const Pos(4, 2)});
    expect(f.last.vaseBroken, isFalse);
  });

  test('gagal mondar-mandir: semua langkah diputar', () {
    final result = simulate(level(13).board);
    final f = runFrames(level(13).board, result);
    expect(result.failReason, FailReason.loop);
    expect(f, hasLength(result.steps + 1));
    expect(f.last.atBowl, isFalse);
  });

  test('kelamaan: diputar sampai langkah $maxSteps, aksi berikutnya tidak', () {
    // Lorong lurus, mangkuk satu petak lewat batas langkah.
    const distance = maxSteps + 1;
    final wall = '#' * (distance + 3);
    final board = Board.parse([wall, '#>${'.' * (distance - 1)}T#', wall]);
    final result = simulate(board);
    expect(result.failReason, FailReason.tooManySteps);
    final f = runFrames(board, result);
    expect(f, hasLength(maxSteps + 1));
    expect(f.last.pos, const Pos(maxSteps + 1, 1));
  });
}
