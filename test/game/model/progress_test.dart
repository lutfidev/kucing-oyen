import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/sim/sim.dart';

final _levels = parseLevels(File(chapter1to2Asset).readAsStringSync());
final _ids = [for (final level in _levels) level.id];

void main() {
  group('Progress', () {
    test('kosong: hanya level 1 terbuka, level saat ini level 1', () {
      const progress = Progress.empty;
      expect(progress.totalStars, 0);
      expect(progress.starsOf(1), 0);
      expect(progress.isWon(1), isFalse);
      expect(progress.isUnlocked(1), isTrue);
      expect(progress.isUnlocked(2), isFalse);
      expect(progress.current(_ids), 1);
    });

    test('level n+1 terbuka setelah level n menang', () {
      final progress = Progress.empty.record(1, 1);
      expect(progress.isUnlocked(2), isTrue);
      expect(progress.isUnlocked(3), isFalse);
      expect(progress.current(_ids), 2);
    });

    test('gagal (0 bintang) tidak dicatat dan tidak membuka level', () {
      final progress = Progress.empty.record(1, 0);
      expect(progress, same(Progress.empty));
      expect(progress.isUnlocked(2), isFalse);
    });

    test('yang disimpan bintang terbaik', () {
      final progress = Progress.empty.record(13, 1).record(13, 3);
      expect(progress.starsOf(13), 3);
      final worse = progress.record(13, 2);
      expect(worse, same(progress));
      expect(worse.starsOf(13), 3);
    });

    test('bintang di luar 0–3 ditolak', () {
      expect(() => Progress.empty.record(1, 4), throwsArgumentError);
      expect(() => Progress.empty.record(1, -1), throwsArgumentError);
    });

    test('total bintang semua level dan sebagian level', () {
      final progress = Progress({1: 3, 2: 2, 11: 1});
      expect(progress.totalStars, 6);
      expect(progress.starsIn([1, 2, 3]), 5);
      expect(progress.starsIn([11, 12]), 1);
    });

    test('semua level menang: tidak ada level saat ini', () {
      final progress = Progress({for (final id in _ids) id: 3});
      expect(progress.current(_ids), isNull);
      expect(progress.totalStars, 60);
    });

    test('level saat ini = level pertama yang belum menang', () {
      final progress = Progress({for (var id = 1; id <= 12; id++) id: 2});
      expect(progress.current(_ids), 13);
      expect(progress.isUnlocked(13), isTrue);
      expect(progress.isUnlocked(14), isFalse);
    });

    test('JSON bolak-balik', () {
      final progress = Progress({1: 3, 2: 1, 20: 2});
      expect(Progress.fromJson(progress.toJson()), progress);
      expect(progress.toJson(), {'1': 3, '2': 1, '20': 2});
    });

    test('JSON rusak: entri yang tidak sah dibuang', () {
      final progress = Progress.fromJson({
        '1': 3,
        'abc': 2,
        '2': 'tiga',
        '3': 0,
        '4': 5,
        '5': 2,
      });
      expect(progress, Progress({1: 3, 5: 2}));
    });

    test('tidak bisa diubah dari luar', () {
      final best = {1: 3};
      final progress = Progress(best);
      best[2] = 3;
      expect(progress.starsOf(2), 0);
      expect(() => progress.best[3] = 1, throwsUnsupportedError);
    });
  });

  group('Chapter', () {
    final chapters = chaptersOf(_levels);

    test('dua babak, sepuluh level, bos di akhir', () {
      expect(chapters, hasLength(2));
      final [kitchen, livingRoom] = chapters;
      expect(kitchen.number, 1);
      expect(kitchen.levels.map((l) => l.id), [
        for (var i = 1; i <= 10; i++) i,
      ]);
      expect(kitchen.boss.id, 10);
      expect(kitchen.maxStars, 30);

      expect(livingRoom.number, 2);
      expect(livingRoom.levels.first.id, 11);
      expect(livingRoom.boss.id, 20);
    });

    test('level dari 1 sampai 20 berurutan (aturan buka kunci memakai id)', () {
      expect(_ids, [for (var i = 1; i <= 20; i++) i]);
    });

    test('babak terbuka, selesai, dan bintangnya', () {
      final [kitchen, livingRoom] = chapters;
      const fresh = Progress.empty;
      expect(kitchen.isUnlocked(fresh), isTrue);
      expect(livingRoom.isUnlocked(fresh), isFalse);
      expect(kitchen.isDone(fresh), isFalse);

      final done = Progress({for (var id = 1; id <= 10; id++) id: 3})
          .record(5, 3)
          .record(11, 2);
      expect(kitchen.isDone(done), isTrue);
      expect(kitchen.stars(done), 30);
      expect(livingRoom.isUnlocked(done), isTrue);
      expect(livingRoom.isDone(done), isFalse);
      expect(livingRoom.stars(done), 2);
    });

    test('babak level saat ini; semua menang = babak terakhir', () {
      expect(chapterToPlay(chapters, Progress.empty).number, 1);
      final kitchenDone = Progress({for (var id = 1; id <= 10; id++) id: 1});
      expect(chapterToPlay(chapters, kitchenDone).number, 2);
      final all = Progress({for (final id in _ids) id: 1});
      expect(chapterToPlay(chapters, all).number, 2);
    });

    test('babak dari nomor dan dari level', () {
      expect(chapterNumbered(chapters, 2)?.number, 2);
      expect(chapterNumbered(chapters, 3), isNull);
      expect(chapterOfLevel(chapters, 10)?.number, 1);
      expect(chapterOfLevel(chapters, 11)?.number, 2);
      expect(chapterOfLevel(chapters, 99), isNull);
    });
  });
}
