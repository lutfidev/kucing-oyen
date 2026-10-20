import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/render/oyen.dart';
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
    test('kostum: simpan lalu muat', () async {
      final wardrobe = Wardrobe(
        owned: {OyenCostume.peci, OyenCostume.koki},
        wearing: OyenCostume.koki,
      );
      await PrefsProgressStore().saveWardrobe(wardrobe);
      expect(await PrefsProgressStore().loadWardrobe(), wardrobe);
      expect(
        await SharedPreferencesAsync().getString(PrefsProgressStore.wearingKey),
        'koki',
      );
    });

    test('kostum bertipe salah: Polos, aplikasi tetap terbuka', () async {
      final prefs = SharedPreferencesAsync();
      await prefs.setInt(PrefsProgressStore.ownedKey, 3);
      await prefs.setBool(PrefsProgressStore.wearingKey, true);
      expect(await PrefsProgressStore().loadWardrobe(), Wardrobe.initial);
    });

    test('kostum: belum pernah disimpan = Polos', () async {
      expect(await PrefsProgressStore().loadWardrobe(), Wardrobe.initial);
    });

    test(
      'kostum rusak: id tak dikenal dibuang, dipakai kembali ke Polos',
      () async {
        final prefs = SharedPreferencesAsync();
        await prefs.setStringList(PrefsProgressStore.ownedKey, [
          'peci',
          'topi',
        ]);
        await prefs.setString(PrefsProgressStore.wearingKey, 'sarung');
        final wardrobe = await PrefsProgressStore().loadWardrobe();
        expect(wardrobe.owned, {OyenCostume.none, OyenCostume.peci});
        expect(wardrobe.wearing, OyenCostume.none);
      },
    );
    test('hadiah harian: simpan lalu muat', () async {
      const rewards = DailyRewards(bonusDay: 3, adDay: 4, adsWatched: 2);
      await PrefsProgressStore().saveRewards(rewards);
      expect(await PrefsProgressStore().loadRewards(), rewards);
    });

    test('hadiah harian: belum pernah disimpan = awal', () async {
      expect(await PrefsProgressStore().loadRewards(), DailyRewards.initial);
    });

    test('hadiah harian rusak atau bertipe salah: awal', () async {
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PrefsProgressStore.rewardsKey, 'bukan json');
      expect(await PrefsProgressStore().loadRewards(), DailyRewards.initial);
      await prefs.setString(PrefsProgressStore.rewardsKey, '[1]');
      expect(await PrefsProgressStore().loadRewards(), DailyRewards.initial);
      await prefs.setInt(PrefsProgressStore.rewardsKey, 3);
      expect(await PrefsProgressStore().loadRewards(), DailyRewards.initial);
    });

    test(
      'bahasa: simpan lalu muat, belum pernah atau rusak = ikuti HP',
      () async {
        expect(await PrefsProgressStore().loadLanguage(), AppLanguage.system);
        await PrefsProgressStore().saveLanguage(AppLanguage.ru);
        expect(await PrefsProgressStore().loadLanguage(), AppLanguage.ru);
        expect(
          await SharedPreferencesAsync().getString(
            PrefsProgressStore.languageKey,
          ),
          'ru',
        );
        final prefs = SharedPreferencesAsync();
        await prefs.setString(PrefsProgressStore.languageKey, 'klingon');
        expect(await PrefsProgressStore().loadLanguage(), AppLanguage.system);
        await prefs.setInt(PrefsProgressStore.languageKey, 3);
        expect(await PrefsProgressStore().loadLanguage(), AppLanguage.system);
      },
    );

    test(
      'suara: simpan lalu muat, belum pernah atau rusak = menyala',
      () async {
        expect(await PrefsProgressStore().loadSound(), SoundSettings.on);
        await PrefsProgressStore().saveSound(
          const SoundSettings(music: false, effects: true),
        );
        expect(
          await PrefsProgressStore().loadSound(),
          const SoundSettings(music: false, effects: true),
        );
        final prefs = SharedPreferencesAsync();
        expect(await prefs.getBool(PrefsProgressStore.musicKey), isFalse);
        expect(await prefs.getBool(PrefsProgressStore.effectsKey), isTrue);
        await prefs.setString(PrefsProgressStore.musicKey, 'mati');
        await prefs.setBool(PrefsProgressStore.effectsKey, false);
        expect(
          await PrefsProgressStore().loadSound(),
          const SoundSettings(music: true, effects: false),
        );
      },
    );
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
      expect(controller.chapter(2)?.levels.first.id, 11);
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

  group('kostum', () {
    test(
      'beli dengan koin cukup: dipotong, dimiliki, dipakai, disimpan',
      () async {
        final c = testProgressWith(coins: 100);
        var notified = 0;
        c.addListener(() => notified++);
        expect(await c.buyCostume(OyenCostume.peci), isTrue);
        expect(c.coins, 40);
        expect(c.wardrobe.wearing, OyenCostume.peci);
        expect(notified, 1);
        final store = c.store as MemoryProgressStore;
        expect(store.coins, 40);
        expect(store.wardrobe.owns(OyenCostume.peci), isTrue);
        expect(store.wardrobe.wearing, OyenCostume.peci);
      },
    );

    test('koin kurang: tidak ada yang berubah', () async {
      final c = testProgressWith(coins: 59);
      expect(await c.buyCostume(OyenCostume.peci), isFalse);
      expect(c.coins, 59);
      expect(c.wardrobe, Wardrobe.initial);
      final store = c.store as MemoryProgressStore;
      expect(store.coins, 59);
      expect(store.wardrobe, Wardrobe.initial);
    });

    test('kostum disimpan dulu, baru koin', () async {
      final store = _SlowWardrobeStore()..coins = 100;
      final c = ProgressController(
        levels: testLevels,
        store: store,
        coins: 100,
      );
      final bought = c.buyCostume(OyenCostume.peci);
      await pumpEventQueue();
      // Lemari belum selesai disimpan: koin lama masih di simpanan, jadi
      // kalau aplikasi mati di sini pemain tidak rugi.
      expect(store.coins, 100);
      store.wardrobeSaved.complete();
      expect(await bought, isTrue);
      expect(store.coins, 40);
      expect(store.wardrobe.owns(OyenCostume.peci), isTrue);
    });

    test('dua ketukan bersamaan hanya memotong sekali', () async {
      final c = testProgressWith(coins: 100);
      final first = c.buyCostume(OyenCostume.peci);
      final second = c.buyCostume(OyenCostume.peci);
      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(c.coins, 40);
    });

    test('pakai hanya kostum yang dimiliki', () async {
      final c = testProgressWith(coins: 100);
      expect(await c.wearCostume(OyenCostume.sarung), isFalse);
      await c.buyCostume(OyenCostume.peci);
      expect(await c.wearCostume(OyenCostume.none), isTrue);
      expect(c.wardrobe.wearing, OyenCostume.none);
      expect(c.wardrobe.owns(OyenCostume.peci), isTrue);
      final store = c.store as MemoryProgressStore;
      expect(store.wardrobe.wearing, OyenCostume.none);
    });

    test('memuat kostum tersimpan', () async {
      final wardrobe = Wardrobe(
        owned: {OyenCostume.kacamata},
        wearing: OyenCostume.kacamata,
      );
      final store = MemoryProgressStore()..wardrobe = wardrobe;
      final c = await ProgressController.load(levels: testLevels, store: store);
      expect(c.wardrobe, wardrobe);
    });
  });
  group('koin tambahan', () {
    var now = DateTime(2026, 10, 19, 9);
    DateTime clock() => now;
    setUp(() => now = DateTime(2026, 10, 19, 9));

    test('bonus harian: +20 sekali, tersimpan, besok bisa lagi', () async {
      final c = testProgressWith(coins: 5, clock: clock);
      var notified = 0;
      c.addListener(() => notified++);
      expect(c.canClaimBonus, isTrue);
      expect(await c.claimDailyBonus(), isTrue);
      expect(c.coins, 25);
      expect(c.canClaimBonus, isFalse);
      expect(notified, 1);
      final store = c.store as MemoryProgressStore;
      expect(store.coins, 25);
      expect(store.rewards.canClaimBonus(dayNumber(now)), isFalse);

      now = DateTime(2026, 10, 19, 23, 59);
      expect(await c.claimDailyBonus(), isFalse);
      expect(c.coins, 25);

      now = DateTime(2026, 10, 20, 0, 1);
      expect(c.canClaimBonus, isTrue);
      expect(await c.claimDailyBonus(), isTrue);
      expect(c.coins, 45);
    });

    test('bonus: dua ketukan bersamaan hanya +20 sekali', () async {
      final c = testProgressWith(clock: clock);
      final first = c.claimDailyBonus();
      final second = c.claimDailyBonus();
      expect([await first, await second], [true, false]);
      expect(c.coins, 20);
    });

    test('iklan selesai: +20, sisa berkurang, tersimpan', () async {
      final ads = FakeRewardedAds();
      final c = testProgressWith(coins: 5, ads: ads, clock: clock);
      expect(c.adsLeft, 5);
      expect(await c.watchAdForCoins(), AdReward.rewarded);
      expect(c.coins, 25);
      expect(c.adsLeft, 4);
      expect(ads.shown, 1);
      final store = c.store as MemoryProgressStore;
      expect(store.coins, 25);
      expect(store.rewards.adsLeft(dayNumber(now)), 4);
    });

    test('iklan gagal: tidak menambah, tidak dihitung', () async {
      final c = testProgressWith(
        coins: 5,
        ads: FakeRewardedAds(succeed: false),
        clock: clock,
      );
      expect(await c.watchAdForCoins(), AdReward.failed);
      expect(c.coins, 5);
      expect(c.adsLeft, 5);
      final store = c.store as MemoryProgressStore;
      expect(store.coins, 5);
      expect(store.rewards, DailyRewards.initial);
    });

    test('iklan yang error dianggap gagal', () async {
      final c = testProgressWith(ads: _ThrowingAds(), clock: clock);
      expect(await c.watchAdForCoins(), AdReward.failed);
      expect(c.coins, 0);
    });

    test('lima iklan per hari, besok penuh lagi', () async {
      final ads = FakeRewardedAds();
      final c = testProgressWith(ads: ads, clock: clock);
      for (var i = 0; i < 5; i++) {
        expect(await c.watchAdForCoins(), AdReward.rewarded);
      }
      expect(c.coins, 100);
      expect(await c.watchAdForCoins(), AdReward.limitReached);
      expect(ads.shown, 5);
      expect(c.coins, 100);
      now = DateTime(2026, 10, 20, 8);
      expect(c.adsLeft, 5);
    });

    test('iklan: ketukan kedua selama iklan diputar ditolak', () async {
      final ads = FakeRewardedAds();
      final c = testProgressWith(ads: ads, clock: clock);
      final first = c.watchAdForCoins();
      final second = c.watchAdForCoins();
      expect(await second, AdReward.busy);
      expect(await first, AdReward.rewarded);
      expect(ads.shown, 1);
      expect(c.coins, 20);
    });

    test('refreshDay memberi tahu hanya kalau hari berganti', () {
      final c = testProgressWith(clock: clock);
      var notified = 0;
      c.addListener(() => notified++);
      now = DateTime(2026, 10, 19, 23, 59);
      c.refreshDay();
      expect(notified, 0);
      now = DateTime(2026, 10, 20, 7);
      c.refreshDay();
      expect(notified, 1);
      c.refreshDay();
      expect(notified, 1);
    });

    test(
      'refreshDay pertama kali sesudah hari berganti tetap memberi tahu',
      () {
        final c = testProgressWith(clock: clock);
        var notified = 0;
        c.addListener(() => notified++);
        now = DateTime(2026, 10, 20, 7);
        c.refreshDay();
        expect(notified, 1);
      },
    );

    test('memuat hadiah harian tersimpan', () async {
      final today = dayNumber(now);
      final store = MemoryProgressStore()
        ..rewards = DailyRewards(bonusDay: today, adDay: today, adsWatched: 3);
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: clock,
      );
      expect(c.canClaimBonus, isFalse);
      expect(c.adsLeft, 2);
    });
  });

  group('bahasa dan pengaturan', () {
    test('setLanguage: disimpan dan pendengar diberi tahu sekali', () async {
      final store = MemoryProgressStore();
      final c = ProgressController(levels: testLevels, store: store);
      var notified = 0;
      c.addListener(() => notified++);
      expect(c.language, AppLanguage.system);

      await c.setLanguage(AppLanguage.pt);
      expect(c.language, AppLanguage.pt);
      expect(store.language, AppLanguage.pt);
      expect(notified, 1);

      await c.setLanguage(AppLanguage.pt);
      expect(notified, 1);
    });

    test('memuat bahasa tersimpan', () async {
      final store = MemoryProgressStore()..language = AppLanguage.id;
      final c = await ProgressController.load(levels: testLevels, store: store);
      expect(c.language, AppLanguage.id);
    });

    test('replayTutorials: tutorial muncul lagi dan tersimpan', () async {
      final store = MemoryProgressStore(Progress.empty, {1, 3, 6});
      final c = ProgressController(
        levels: testLevels,
        store: store,
        tutorialsDone: {1, 3, 6},
      );
      var notified = 0;
      c.addListener(() => notified++);
      await c.replayTutorials();
      expect(c.tutorialsDone, isEmpty);
      expect(store.tutorials, isEmpty);
      expect(notified, 1);
    });

    test('resetProgress menghapus bintang, koin, petunjuk, kostum, dan '
        'tutorial; hadiah harian, bahasa, dan suara tetap', () async {
      final now = DateTime(2026, 10, 19, 9);
      final today = dayNumber(now);
      final rewards = DailyRewards(
        bonusDay: today,
        adDay: today,
        adsWatched: 4,
      );
      final wardrobe = Wardrobe(
        owned: {OyenCostume.peci},
        wearing: OyenCostume.peci,
      );
      final store = MemoryProgressStore(Progress({1: 3, 2: 2}), {1, 3})
        ..coins = 250
        ..hints = {13: 2}
        ..wardrobe = wardrobe
        ..rewards = rewards
        ..language = AppLanguage.ru
        ..sound = const SoundSettings(music: false, effects: false);
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      var notified = 0;
      c.addListener(() => notified++);

      await c.resetProgress();

      expect(notified, 1);
      expect(c.progress, Progress.empty);
      expect(c.coins, 0);
      expect(c.hintTier(13), 0);
      expect(c.wardrobe.owned, {OyenCostume.none});
      expect(c.wardrobe.wearing, OyenCostume.none);
      expect(c.tutorialsDone, isEmpty);
      expect(c.canClaimBonus, isFalse);
      expect(c.adsLeft, maxAdsPerDay - 4);
      expect(c.language, AppLanguage.ru);

      expect(store.saved, Progress.empty);
      expect(store.coins, 0);
      expect(store.hints, isEmpty);
      expect(store.wardrobe.owned, {OyenCostume.none});
      expect(store.tutorials, isEmpty);
      expect(store.rewards, rewards);
      expect(store.language, AppLanguage.ru);
      expect(store.sound, const SoundSettings(music: false, effects: false));

      // Dibuka ulang: tetap kosong, koin tidak dihitung ulang dari bintang.
      final again = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      expect(again.coins, 0);
      expect(again.progress.totalStars, 0);
    });
  });
}

/// Iklan yang gagal dimuat dengan error, seperti SDK asli.
class _ThrowingAds implements RewardedAds {
  @override
  Future<bool> show() async => throw StateError('iklan gagal dimuat');
}

/// Penyimpanan lemari yang menunggu [wardrobeSaved].
class _SlowWardrobeStore extends MemoryProgressStore {
  final wardrobeSaved = Completer<void>();

  @override
  Future<void> saveWardrobe(Wardrobe wardrobe) async {
    await wardrobeSaved.future;
    await super.saveWardrobe(wardrobe);
  }
}
