import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
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

    test('tutorial selesai: simpan lalu muat, id rusak dibuang', () async {
      expect(await PrefsProgressStore().loadTutorials(), isEmpty);
      await PrefsProgressStore().saveTutorials({6, 1});
      expect(await PrefsProgressStore().loadTutorials(), {1, 6});
      expect(
        await SharedPreferencesAsync().getStringList(
          PrefsProgressStore.tutorialsKey,
        ),
        ['1', '6'],
      );
      await SharedPreferencesAsync().setStringList(
        PrefsProgressStore.tutorialsKey,
        ['3', 'tiga'],
      );
      expect(await PrefsProgressStore().loadTutorials(), {3});
    });

    test('koin: simpan lalu muat, belum pernah atau rusak = null', () async {
      expect(await PrefsProgressStore().loadCoins(), isNull);
      await PrefsProgressStore().saveCoins(120);
      expect(await PrefsProgressStore().loadCoins(), 120);
      await SharedPreferencesAsync().setInt(PrefsProgressStore.coinsKey, -5);
      expect(await PrefsProgressStore().loadCoins(), isNull);
      await SharedPreferencesAsync().setString(
        PrefsProgressStore.coinsKey,
        'x',
      );
      expect(await PrefsProgressStore().loadCoins(), isNull);
    });

    test('petunjuk: simpan lalu muat, entri rusak dibuang', () async {
      expect(await PrefsProgressStore().loadHints(), isEmpty);
      await PrefsProgressStore().saveHints({13: 2, 3: 1});
      expect(await PrefsProgressStore().loadHints(), {13: 2, 3: 1});
      expect(
        await SharedPreferencesAsync().getString(PrefsProgressStore.hintsKey),
        '{"3":1,"13":2}',
      );
      await SharedPreferencesAsync().setString(
        PrefsProgressStore.hintsKey,
        '{"13": 2, "x": 1, "4": 0, "5": 7, "6": "dua"}',
      );
      expect(await PrefsProgressStore().loadHints(), {13: 2});
      for (final raw in ['bukan json', '[1]']) {
        await SharedPreferencesAsync().setString(
          PrefsProgressStore.hintsKey,
          raw,
        );
        expect(await PrefsProgressStore().loadHints(), isEmpty);
      }
    });
  });

  group('ProgressController', () {
    test('memuat dari simpanan', () async {
      final store = MemoryProgressStore(Progress({1: 2}), {1});
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
      expect(controller.isTutorialDone(1), isTrue);
      expect(controller.isTutorialDone(3), isFalse);
    });

    test(
      'tutorial selesai: disimpan sekali dan pendengar diberi tahu',
      () async {
        final store = MemoryProgressStore();
        final controller = ProgressController(levels: testLevels, store: store);
        var notified = 0;
        controller.addListener(() => notified++);

        await controller.finishTutorial(3);
        expect(controller.isTutorialDone(3), isTrue);
        expect(store.tutorials, {3});
        expect(notified, 1);

        await controller.finishTutorial(3);
        expect(notified, 1);
        await controller.finishTutorial(1);
        expect(store.tutorials, {1, 3});
        expect(controller.tutorialsDone, {1, 3});
      },
    );

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

  group('koin dan petunjuk', () {
    test('record memberi koin hanya untuk bintang baru', () async {
      final c = testProgressWith();
      var notified = 0;
      c.addListener(() => notified++);
      expect(c.coinsFor(13, 2), 20);
      await c.record(13, 2);
      expect(c.coins, 20);
      expect(c.coinsFor(13, 3), 10);
      await c.record(13, 3);
      expect(c.coins, 30);
      expect(c.coinsFor(13, 3), 0);
      await c.record(13, 3);
      await c.record(14, 0);
      expect(c.coins, 30);
      expect(notified, 2);
      expect((c.store as MemoryProgressStore).coins, 30);
    });

    test('pemain lama: saldo awal dari total bintang', () async {
      final store = MemoryProgressStore(Progress(wonUpTo(4)));
      final c = await ProgressController.load(levels: testLevels, store: store);
      expect(c.coins, 120);
    });

    test('memuat koin dan petunjuk tersimpan', () async {
      final store = MemoryProgressStore(Progress(wonUpTo(4)), const {})
        ..coins = 7
        ..hints = {13: 2};
      final c = await ProgressController.load(levels: testLevels, store: store);
      expect(c.coins, 7);
      expect(c.hintTier(13), 2);
      expect(c.hintTier(3), 0);
    });

    test('tingkat dibuka berurutan dengan koin', () async {
      final c = testProgressWith(coins: 100);
      expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.notReady);
      expect(await c.unlockHint(13, 1, HintPay.coins), HintUnlock.opened);
      expect(await c.unlockHint(13, 1, HintPay.coins), HintUnlock.notReady);
      expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.opened);
      expect(c.coins, 40);
      expect(
        await c.unlockHint(13, 3, HintPay.coins),
        HintUnlock.notEnoughCoins,
      );
      expect(c.coins, 40);
      expect(c.hintTier(13), 2);
      final store = c.store as MemoryProgressStore;
      expect(store.hints, {13: 2});
      expect(store.coins, 40);
    });

    test('iklan membuka tanpa koin; iklan gagal tidak membuka', () async {
      final ads = FakeRewardedAds();
      final ok = testProgressWith(ads: ads);
      expect(await ok.unlockHint(3, 1, HintPay.ad), HintUnlock.opened);
      expect(ads.shown, 1);
      expect(ok.coins, 0);
      expect(ok.hintTier(3), 1);

      final fail = testProgressWith(ads: FakeRewardedAds(succeed: false));
      expect(await fail.unlockHint(3, 1, HintPay.ad), HintUnlock.adFailed);
      expect(fail.hintTier(3), 0);
    });

    test('dua ketukan bersamaan hanya membuka sekali', () async {
      final c = testProgressWith(coins: 100);
      final coins = await Future.wait([
        c.unlockHint(13, 1, HintPay.coins),
        c.unlockHint(13, 1, HintPay.coins),
      ]);
      expect(coins.where((r) => r == HintUnlock.opened), hasLength(1));
      expect(c.coins, 80);

      final ads = FakeRewardedAds();
      final d = testProgressWith(ads: ads);
      final viaAds = await Future.wait([
        d.unlockHint(13, 1, HintPay.ad),
        d.unlockHint(13, 1, HintPay.coins),
      ]);
      expect(viaAds, [HintUnlock.opened, HintUnlock.notReady]);
      expect(d.coins, 0);
      expect(ads.shown, 1);
    });

    test('tingkat di luar 1–3 ditolak', () async {
      final c = testProgressWith(coins: 500, hints: {13: 3});
      expect(await c.unlockHint(13, 4, HintPay.coins), HintUnlock.notReady);
      expect(await c.unlockHint(3, 0, HintPay.coins), HintUnlock.notReady);
      expect(c.coins, 500);
    });

    test('iklan yang melempar error dianggap gagal', () async {
      final c = testProgressWith(ads: _ThrowingAds());
      expect(await c.unlockHint(3, 1, HintPay.ad), HintUnlock.adFailed);
      expect(c.hintTier(3), 0);
      // Tidak macet: tingkat yang sama bisa dicoba lagi.
      expect(await c.unlockHint(3, 1, HintPay.ad), HintUnlock.adFailed);
    });
  });
}

/// Iklan yang gagal dimuat dengan error, seperti SDK asli.
class _ThrowingAds implements RewardedAds {
  @override
  Future<bool> show() async => throw StateError('iklan gagal dimuat');
}
