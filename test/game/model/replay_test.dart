import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/replay.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/sim/sim.dart';

import '../../screens/result_fixtures.dart' show longWalk;

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  ({SimResult result, List<RunFrame> frames}) run(
    Level level, [
    List<Placement>? placed,
  ]) {
    final result = simulate(level.board, placed ?? level.solution);
    return (result: result, frames: runFrames(level.board, result));
  }

  List<String> captions(Level level, [List<Placement>? placed]) {
    final r = run(level, placed);
    return replayCaptions(level.board, r.result, r.frames);
  }

  /// "(kolom,baris) nomor" tiap jejak.
  List<String> trail(Level level, [List<Placement>? placed]) => [
    for (final mark in replayTrail(run(level, placed).frames))
      '${mark.pos} ${mark.label}',
  ];

  group('nomor jejak', () {
    test('solusi level 13: seperti desain 09', () {
      expect(trail(level(13)), [
        '(4,3) 1',
        '(5,3) 2·3',
        '(5,4) 4',
        '(4,4) 5',
        '(3,4) 6',
      ]);
    });

    test('langkah tiap petak dan urutan kunjungan pertama', () {
      final marks = replayTrail(run(level(15)).frames);
      expect(marks.map((m) => m.steps), [
        [1],
        [2],
        [3],
        [4],
        [5, 6],
        [7, 8, 9],
        [10],
        [11],
        [12],
      ]);
      expect(marks[5].label, '7–9');
    });

    test('petak yang dikunjungi lagi: langkah pertama tiap kunjungan', () {
      String label(List<int> steps) => TrailMark(const Pos(1, 1), steps).label;
      expect(label([4]), '4');
      expect(label([2, 3]), '2·3');
      expect(label([5, 6, 7]), '5–7');
      expect(label([7, 12]), '7·12');
      expect(label([13, 14, 26, 27]), '13·26');
      expect(label([11, 12, 18, 30]), '11·18·…');
    });

    test('langkah 0 tidak bernomor', () {
      // Level 1: langkah pertama sudah pindah petak.
      final l = level(1);
      final marks = replayTrail(run(l).frames);
      expect(marks.map((m) => m.pos), isNot(contains(l.board.start)));
      expect(marks.first.steps, [1]);
    });

    test('setiap langkah 1..akhir ada di tepat satu nomor jejak', () {
      for (final l in levels) {
        for (final placed in [l.solution, const <Placement>[]]) {
          final frames = run(l, placed).frames;
          final steps = [for (final mark in replayTrail(frames)) ...mark.steps]
            ..sort();
          expect(steps, [for (var i = 1; i < frames.length; i++) i]);
        }
      }
    });
  });

  group('caption', () {
    test('solusi level 13: persis desain 09', () {
      expect(captions(level(13)), [
        'Awal: Oyen tidur menghadap kiri.',
        'Ketemu ember air, kaget, putar balik.',
        'Jalan lurus ke kanan.',
        'Mentok tembok, berputar menghadap bawah.',
        'Ikan asin kelihatan lurus di kiri.',
        'Kejar ikan. Vas tetap aman.',
        'Masuk mangkuk. Selesai dalam 6 langkah.',
      ]);
    });

    test('jalan, kejar ikan tanpa vas, makan, meja, dan kardus', () {
      final c = captions(level(15));
      expect(c.sublist(0, 4), [
        'Awal: Oyen tidur menghadap kiri.',
        'Ikan asin kelihatan lurus di atas.',
        'Kejar ikan ke atas.',
        'Hap! Ikan asin dimakan.',
      ]);
      expect(c[6], 'Mentok meja, berputar menghadap bawah.');
      expect(c.sublist(7, 11), [
        'Masuk kardus, duduk dulu.',
        'Masih duduk di kardus.',
        'Kardusnya penyok dan hilang.',
        'Jalan lurus ke bawah.',
      ]);
      expect(c.last, 'Masuk mangkuk. Selesai dalam 12 langkah.');
    });

    test('genangan air bawaan peta', () {
      expect(captions(level(7))[4], 'Ketemu genangan air, kaget, putar balik.');
    });

    test('barang jatuh: gelas aman, vas pecah', () {
      expect(captions(level(12))[6], 'Gelas didorong jatuh. Aman, plastik.');
      final vase = captions(level(13), [const Placement(Item.fish, Pos(2, 4))]);
      expect(vase[2], 'Vas Ibu didorong jatuh. Pecah!');
      // Sesudah vas pecah, kejar ikan tidak lagi menyebut vas aman.
      expect(vase.where((c) => c.contains('Vas tetap aman')), isEmpty);
    });

    test('mondar-mandir: langkah terakhir menyebut keadaan yang terulang', () {
      final c = captions(level(13), const []);
      expect(c, hasLength(26));
      expect(
        c.last,
        'Balik lagi seperti langkah 7. Oyen muter terus, jadi bosan.',
      );
      expect(
        captions(level(3), const []).last,
        'Balik lagi seperti awal. Oyen muter terus, jadi bosan.',
      );
    });

    test('keadaan yang terulang sama dengan deteksi simulator', () {
      // Semua penempatan satu benda dari baki di 20 level: keadaan langkah
      // terakhir yang mondar-mandir muncul tepat sekali sebelumnya.
      var loops = 0;
      for (final l in levels) {
        for (final item in l.inventory.keys) {
          for (final pos in l.board.emptyCells) {
            final r = run(l, [Placement(item, pos)]);
            if (r.result.failReason != FailReason.loop) continue;
            loops++;
            final c = replayCaptions(l.board, r.result, r.frames).last;
            final match = RegExp(r'seperti (awal|langkah (\d+))').firstMatch(c);
            expect(match, isNotNull, reason: '$l $item $pos');
            final step = int.parse(match!.group(2) ?? '0');
            final last = r.frames.last;
            final earlier = r.frames[step];
            expect(step, lessThan(r.result.steps));
            expect((earlier.pos, earlier.dir), (last.pos, last.dir));
          }
        }
      }
      expect(loops, greaterThan(100));
    });

    test('kelamaan: langkah ke-80', () {
      final c = captions(longWalk, const []);
      expect(c, hasLength(maxSteps + 1));
      expect(c.last, 'Langkah ke-80, mangkuknya belum ketemu. Oyen bosan.');
    });

    test('caption untuk setiap jenis langkah', () {
      // Semua langkah 20 solusi dan percobaan tanpa benda.
      final kinds = <StepKind>{};
      for (final l in levels) {
        for (final placed in [l.solution, const <Placement>[]]) {
          final r = run(l, placed);
          final c = replayCaptions(l.board, r.result, r.frames);
          expect(c, hasLength(r.frames.length));
          for (var i = 0; i < c.length; i++) {
            expect(c[i], isNotEmpty);
            final action = r.frames[i].action;
            if (action != null) kinds.add(action.kind);
          }
        }
      }
      expect(kinds, StepKind.values.toSet());
    });
  });
}
