import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../test_helpers.dart';

void main() {
  group('PrefsProgressStore', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('belum pernah disimpan: kosong', () async {
      expect(await PrefsProgressStore().load(), Progress.empty);
    });

    test('simpan lalu muat dengan objek baru', () async {
      final progress = Progress({1: 3, 2: 1, 13: 2});
      await PrefsProgressStore().save(progress);
      expect(await PrefsProgressStore().load(), progress);
      expect(
        await SharedPreferencesAsync().getString(PrefsProgressStore.key),
        '{"1":3,"2":1,"13":2}',
      );
    });

    for (final raw in ['bukan json', '[1, 2]', '{"1": "tiga"}']) {
      test('data rusak ($raw): kosong', () async {
        await SharedPreferencesAsync().setString(PrefsProgressStore.key, raw);
        expect(await PrefsProgressStore().load(), Progress.empty);
      });
    }
  });

  group('ProgressController', () {
    test('memuat dari simpanan', () async {
      final store = MemoryProgressStore(Progress({1: 2}));
      final controller = await ProgressController.load(
        levels: testLevels,
        store: store,
      );
      expect(controller.progress.starsOf(1), 2);
      expect(controller.chapters, hasLength(2));
      expect(controller.maxStars, 60);
      expect(controller.levelById(13)?.name, 'Vas Ibu');
      expect(controller.levelById(99), isNull);
      expect(controller.chapter(2)?.name, 'Ruang Tamu');
      expect(controller.currentChapter.number, 1);
    });

    test('menang: dicatat, disimpan, dan pendengar diberi tahu', () async {
      final store = MemoryProgressStore();
      final controller = ProgressController(levels: testLevels, store: store);
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.record(1, 2);
      expect(controller.progress.starsOf(1), 2);
      expect(controller.progress.isUnlocked(2), isTrue);
      expect(store.saved, controller.progress);
      expect(notified, 1);

      // Tidak lebih baik dan gagal: tidak disimpan ulang.
      await controller.record(1, 1);
      await controller.record(2, 0);
      expect(store.saves, 1);
      expect(notified, 1);

      await controller.record(1, 3);
      expect(store.saved.starsOf(1), 3);
      expect(notified, 2);
    });
  });
}
