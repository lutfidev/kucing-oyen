import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/model/sounds.dart';
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

    test('rumah dan kebutuhan: simpan lalu muat', () async {
      final home = Home(
        room: Room.initial.buy(RoomItemId.kardus),
        kitties: {KittyId.arang},
        pantry: Pantry({SnackId.susu: 2}),
      );
      final needs = HomeNeeds.empty
          .withKitties([KittyId.oyen], DateTime(2026, 10, 28, 8))
          .claim(KittyId.oyen, DateTime(2026, 10, 28, 8))!;
      await PrefsProgressStore().saveHome(home);
      await PrefsProgressStore().saveNeeds(needs);
      expect(await PrefsProgressStore().loadHome(), home);
      expect(await PrefsProgressStore().loadNeeds(), needs);
      expect(PrefsProgressStore.homeKey, 'home.state');
      expect(PrefsProgressStore.needsKey, 'home.needs');
      final prefs = SharedPreferencesAsync();
      expect(await prefs.getString(PrefsProgressStore.homeKey), isNotNull);
      expect(await prefs.getString(PrefsProgressStore.needsKey), isNotNull);
    });

    test('kunci kostum lama dihapus saat rumah dimuat', () async {
      final prefs = SharedPreferencesAsync();
      await prefs.setStringList('costume.owned', ['peci']);
      await prefs.setString('costume.wearing', 'peci');
      expect(await PrefsProgressStore().loadHome(), Home.initial);
      expect(await prefs.containsKey('costume.owned'), isFalse);
      expect(await prefs.containsKey('costume.wearing'), isFalse);
    });

    test('rumah dan kebutuhan: belum pernah disimpan = awal', () async {
      expect(await PrefsProgressStore().loadHome(), Home.initial);
      expect(await PrefsProgressStore().loadNeeds(), HomeNeeds.empty);
    });

    test(
      'kebutuhan dengan waktu di luar jangkauan: awal, tidak melempar',
      () async {
        await SharedPreferencesAsync().setString(
          PrefsProgressStore.needsKey,
          '{"cats":{"oyen":{"hunger":50,"joy":50,"at":9000000000000000}},'
          '"bowl":{"at":9000000000000000},"decoratedAt":9000000000000000}',
        );
        expect(await PrefsProgressStore().loadNeeds(), HomeNeeds.empty);
      },
    );

    test('rumah dan kebutuhan rusak atau bertipe salah: awal', () async {
      final prefs = SharedPreferencesAsync();
      for (final key in [
        PrefsProgressStore.homeKey,
        PrefsProgressStore.needsKey,
      ]) {
        await prefs.setString(key, 'bukan json');
      }
      expect(await PrefsProgressStore().loadHome(), Home.initial);
      expect(await PrefsProgressStore().loadNeeds(), HomeNeeds.empty);
      for (final key in [
        PrefsProgressStore.homeKey,
        PrefsProgressStore.needsKey,
      ]) {
        await prefs.setString(key, '[1]');
      }
      expect(await PrefsProgressStore().loadHome(), Home.initial);
      expect(await PrefsProgressStore().loadNeeds(), HomeNeeds.empty);
      for (final key in [
        PrefsProgressStore.homeKey,
        PrefsProgressStore.needsKey,
      ]) {
        await prefs.setInt(key, 3);
      }
      expect(await PrefsProgressStore().loadHome(), Home.initial);
      expect(await PrefsProgressStore().loadNeeds(), HomeNeeds.empty);
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

    test('petunjuk dan koin memakai unit iklan masing-masing', () async {
      final hintAds = FakeRewardedAds();
      final coinAds = FakeRewardedAds();
      final c = ProgressController(
        levels: testLevels,
        store: MemoryProgressStore(),
        hintAds: hintAds,
        coinAds: coinAds,
      );
      expect(await c.unlockHint(3, 1, HintPay.ad), HintUnlock.opened);
      expect((hintAds.shown, coinAds.shown), (1, 0));
      expect(await c.watchAdForCoins(), AdReward.rewarded);
      expect((hintAds.shown, coinAds.shown), (1, 1));
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

  group('rumah', () {
    var now = DateTime(2026, 10, 28, 8);
    DateTime clock() => now;
    setUp(() => now = DateTime(2026, 10, 28, 8));
    const hour = Duration(hours: 1);

    ProgressController controller({
      int coins = 0,
      Home? home,
      HomeNeeds? needs,
    }) =>
        testProgressWith(coins: coins, home: home, needs: needs, clock: clock);
    MemoryProgressStore storeOf(ProgressController c) =>
        c.store as MemoryProgressStore;
    Home owning(Iterable<RoomItemId> items, {Pantry? pantry}) => Home(
      room: items.fold<Room>(Room.initial, (room, id) => room.buy(id)),
      pantry: pantry,
    );

    test('awal: Oyen dengan bar penuh, kamar dengan mangkuk', () {
      final c = controller();
      expect(c.home, Home.initial);
      expect(c.catNeeds(KittyId.oyen), CatNeeds.full(now));
    });

    test(
      'beli barang: dipotong, ditaruh, tersimpan, pendengar sekali',
      () async {
        final c = controller(coins: 100);
        var notified = 0;
        c.addListener(() => notified++);
        expect(await c.buyItem(RoomItemId.kardus), isTrue);
        expect(c.coins, 50);
        expect(c.home.room.isPlaced(RoomItemId.kardus), isTrue);
        expect(notified, 1);
        expect(storeOf(c).home, c.home);
        expect(storeOf(c).coins, 50);
      },
    );

    test('koin kurang atau sudah dimiliki: gagal tanpa efek', () async {
      final c = controller(coins: 49);
      var notified = 0;
      c.addListener(() => notified++);
      expect(await c.buyItem(RoomItemId.kardus), isFalse);
      expect(await c.buyItem(RoomItemId.mangkuk), isFalse);
      expect(await c.buyKitty(KittyId.salju), isFalse);
      expect(await c.buyKitty(KittyId.oyen), isFalse);
      expect(await c.buyAccessory(AccessoryId.pita), isFalse);
      expect(await c.buySnack(SnackId.puding), isFalse);
      expect(c.coins, 49);
      expect(c.home, Home.initial);
      expect(notified, 0);
      expect(storeOf(c).home, Home.initial);
      expect(storeOf(c).coins, 49);
    });

    test('dua ketukan bersamaan hanya membayar sekali', () async {
      final c = controller(coins: 1000);
      final buys = [
        c.buyItem(RoomItemId.kardus),
        c.buyItem(RoomItemId.kardus),
        c.buyKitty(KittyId.salju),
        c.buyKitty(KittyId.salju),
        c.buyAccessory(AccessoryId.pita),
        c.buyAccessory(AccessoryId.pita),
      ];
      expect(await Future.wait(buys), [true, false, true, false, true, false]);
      expect(c.coins, 1000 - 50 - 300 - 50);
      expect(storeOf(c).coins, c.coins);
      expect(storeOf(c).home, c.home);
    });

    test(
      'camilan dibeli berulang: tiap ketukan satu, paling banyak 99',
      () async {
        final c = controller(
          coins: 100,
          home: Home(pantry: Pantry({SnackId.susu: 97})),
        );
        final taps = [c.buySnack(SnackId.susu), c.buySnack(SnackId.susu)];
        expect(await Future.wait(taps), [true, true]);
        expect(await c.buySnack(SnackId.susu), isFalse);
        expect(c.home.pantry.countOf(SnackId.susu), 99);
        expect(c.coins, 70);
        expect(storeOf(c).home.pantry.countOf(SnackId.susu), 99);
      },
    );

    test('kucing baru: bar penuh saat dibeli, lalu turun', () async {
      final c = controller(coins: 300);
      now = now.add(hour * 5);
      expect(await c.buyKitty(KittyId.salju), isTrue);
      expect(c.home.ownsKitty(KittyId.salju), isTrue);
      expect(c.catNeeds(KittyId.salju), CatNeeds.full(now));
      expect(storeOf(c).needs.cats[KittyId.salju], CatNeeds.full(now));
      now = now.add(hour * 6);
      expect(c.catNeeds(KittyId.salju).hunger, closeTo(50, 1e-9));
    });

    test('aksesoris: dipakai beberapa kucing, diganti, dilepas', () async {
      final c = controller(coins: 1000, home: Home(kitties: {KittyId.arang}));
      expect(await c.wearAccessory(KittyId.oyen, AccessoryId.pita), isFalse);
      expect(await c.buyAccessory(AccessoryId.pita), isTrue);
      expect(c.home.closet.wearingOf(KittyId.oyen), isNull);
      expect(await c.wearAccessory(KittyId.oyen, AccessoryId.pita), isTrue);
      expect(await c.wearAccessory(KittyId.arang, AccessoryId.pita), isTrue);
      expect(await c.wearAccessory(KittyId.salju, AccessoryId.pita), isFalse);
      expect(c.home.closet.wearingOf(KittyId.arang), AccessoryId.pita);
      expect(await c.buyAccessory(AccessoryId.kalung), isTrue);
      expect(await c.wearAccessory(KittyId.oyen, AccessoryId.kalung), isTrue);
      expect(c.home.closet.wearingOf(KittyId.oyen), AccessoryId.kalung);
      expect(await c.wearAccessory(KittyId.oyen, null), isTrue);
      expect(c.home.closet.wearingOf(KittyId.oyen), isNull);
      expect(storeOf(c).home.closet, c.home.closet);
      expect(c.coins, 1000 - 50 - 120);
    });

    test('tata letak: taruh, ke Gudang, taruh lagi', () async {
      final c = controller(home: owning([RoomItemId.kardus]));
      expect(await c.placeItem(RoomItemId.kardus, Spot(0.5, 0.5)), isTrue);
      expect(c.home.room.spotOf(RoomItemId.kardus), Spot(0.5, 0.5));
      expect(await c.storeItem(RoomItemId.kardus), isTrue);
      expect(c.home.room.stored, [RoomItemId.kardus]);
      expect(await c.storeItem(RoomItemId.kardus), isFalse);
      expect(await c.storeItem(RoomItemId.mangkuk), isFalse);
      expect(await c.placeItem(RoomItemId.bola, Spot(0, 0)), isFalse);
      expect(await c.placeItem(RoomItemId.kardus, Spot(0, 1)), isTrue);
      expect(storeOf(c).home.room.spotOf(RoomItemId.kardus), Spot(0, 1));
    });

    test('beri camilan: stok berkurang, bar naik; stok habis gagal', () async {
      final c = controller(home: Home(pantry: Pantry({SnackId.ikanAsin: 1})));
      now = now.add(hour * 6);
      expect(await c.feed(KittyId.oyen, SnackId.ikanAsin), isTrue);
      expect(c.catNeeds(KittyId.oyen).hunger, closeTo(75, 1e-9));
      expect(c.home.pantry.countOf(SnackId.ikanAsin), 0);
      expect(await c.feed(KittyId.oyen, SnackId.ikanAsin), isFalse);
      expect(await c.feed(KittyId.salju, SnackId.susu), isFalse);
      expect(storeOf(c).home.pantry, Pantry.empty);
      expect(storeOf(c).needs.of(KittyId.oyen, now).hunger, closeTo(75, 1e-9));
    });

    test('elus: +10, paling banyak tiga kali per jam', () async {
      final c = controller();
      now = now.add(hour * 8);
      for (var i = 0; i < 3; i++) {
        expect(await c.pet(KittyId.oyen), isTrue);
      }
      expect(await c.pet(KittyId.oyen), isFalse);
      expect(await c.pet(KittyId.salju), isFalse);
      expect(c.catNeeds(KittyId.oyen).joy, closeTo(80, 1e-9));
      expect(storeOf(c).needs.of(KittyId.oyen, now).joy, closeTo(80, 1e-9));
    });

    test('main: hanya mainan yang ditaruh, sekali per 30 menit', () async {
      final c = controller(home: owning([RoomItemId.bola, RoomItemId.kardus]));
      now = now.add(hour * 8);
      expect(await c.play(KittyId.oyen, RoomItemId.kardus), isFalse);
      expect(await c.play(KittyId.oyen, RoomItemId.tikus), isFalse);
      expect(await c.play(KittyId.arang, RoomItemId.bola), isFalse);
      expect(await c.play(KittyId.oyen, RoomItemId.bola), isTrue);
      expect(await c.play(KittyId.oyen, RoomItemId.bola), isFalse);
      now = now.add(const Duration(minutes: 30));
      expect(await c.storeItem(RoomItemId.bola), isTrue);
      expect(await c.play(KittyId.oyen, RoomItemId.bola), isFalse);
    });

    test('selesai menghias: +5 semua kucing, sekali per jam', () async {
      final c = controller(home: Home(kitties: {KittyId.arang}));
      now = now.add(hour * 8);
      expect(await c.finishDecorating(), isTrue);
      expect(c.catNeeds(KittyId.oyen).joy, closeTo(55, 1e-9));
      expect(c.catNeeds(KittyId.arang).joy, closeTo(55, 1e-9));
      expect(await c.finishDecorating(), isFalse);
      now = now.add(hour);
      expect(await c.finishDecorating(), isTrue);
      expect(storeOf(c).needs.decoratedAt, now);
    });

    test('mangkuk: sekali per isi, hanya kalau lapar', () async {
      final c = controller();
      expect(c.canEatFromBowl(KittyId.oyen), isFalse);
      expect(await c.eatFromBowl(KittyId.oyen), isFalse);
      now = now.add(hour * 6);
      expect(c.canEatFromBowl(KittyId.oyen), isTrue);
      expect(c.canEatFromBowl(KittyId.salju), isFalse);
      expect(await c.eatFromBowl(KittyId.oyen), isTrue);
      expect(c.catNeeds(KittyId.oyen).hunger, closeTo(90, 1e-9));
      now = now.add(hour * 3);
      expect(await c.eatFromBowl(KittyId.oyen), isFalse);
      expect(storeOf(c).needs.bowl, c.needs.bowl);
    });

    test('hadiah kucing: +10 koin sekali sehari', () async {
      final c = controller(coins: 5);
      expect(c.canClaimKittyReward(KittyId.oyen), isTrue);
      expect(c.canClaimKittyReward(KittyId.salju), isFalse);
      expect(await c.claimKittyReward(KittyId.oyen), isTrue);
      expect(c.coins, 15);
      expect(c.canClaimKittyReward(KittyId.oyen), isFalse);
      expect(await c.claimKittyReward(KittyId.oyen), isFalse);
      expect(await c.claimKittyReward(KittyId.salju), isFalse);
      expect(c.coins, 15);
      expect(storeOf(c).coins, 15);
      expect(storeOf(c).needs.rewardDays, {KittyId.oyen: dayNumber(now)});
    });

    test(
      'memuat tanpa simpanan rumah: Oyen penuh di jam muat, tersimpan',
      () async {
        final store = MemoryProgressStore();
        final c = await ProgressController.load(
          levels: testLevels,
          store: store,
          clock: clock,
        );
        expect(c.home, Home.initial);
        expect(c.catNeeds(KittyId.oyen), CatNeeds.full(now));
        expect(store.needs.cats, {KittyId.oyen: CatNeeds.full(now)});

        // Dibuka lagi 12 jam kemudian tanpa aksi apa pun: bar sudah turun.
        now = now.add(hour * 12);
        final again = await ProgressController.load(
          levels: testLevels,
          store: store,
          clock: clock,
        );
        expect(again.catNeeds(KittyId.oyen).hunger, closeTo(0, 1e-9));
      },
    );

    test('memuat rumah dan kebutuhan tersimpan', () async {
      final home = Home(
        room: Room.initial.buy(RoomItemId.bola),
        kitties: {KittyId.mochi},
      );
      final needs = HomeNeeds.empty.withKitties(home.kitties, now);
      final store = MemoryProgressStore()
        ..home = home
        ..needs = needs;
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: clock,
      );
      expect(c.home, home);
      expect(c.needs, needs);
    });
  });

  group('simpanan gagal', () {
    ProgressController controller(
      FailingProgressStore store, {
      int coins = 0,
      DateTime Function()? clock,
    }) => ProgressController(
      levels: testLevels,
      store: store,
      coins: coins,
      hintAds: FakeRewardedAds(),
      coinAds: FakeRewardedAds(),
      clock: clock,
    );

    test('urutan tulis memihak pemain', () async {
      final store = FailingProgressStore();
      final c = controller(store, coins: 500);

      await c.record(1, 3);
      expect(store.writes, ['coins', 'progress']);

      store.writes.clear();
      await c.unlockHint(13, 1, HintPay.coins);
      expect(store.writes, ['hints', 'coins']);

      store.writes.clear();
      await c.claimDailyBonus();
      expect(store.writes, ['coins', 'rewards']);

      store.writes.clear();
      expect(await c.watchAdForCoins(), AdReward.rewarded);
      expect(store.writes, ['coins', 'rewards']);

      // Barang sebelum koin; koin hadiah kucing sebelum hari hadiahnya.
      store.writes.clear();
      expect(await c.buySnack(SnackId.susu), isTrue);
      expect(store.writes, ['home', 'coins']);

      store.writes.clear();
      expect(await c.buyKitty(KittyId.salju), isTrue);
      expect(store.writes, ['home', 'coins', 'needs']);

      store.writes.clear();
      expect(await c.feed(KittyId.oyen, SnackId.susu), isTrue);
      expect(store.writes, ['home', 'needs']);

      store.writes.clear();
      expect(await c.claimKittyReward(KittyId.salju), isTrue);
      expect(store.writes, ['coins', 'needs']);
    });

    test('simpan gagal tidak melempar; keadaan di memori tetap', () async {
      final store = FailingProgressStore(failing: {'coins'});
      final c = controller(store);

      await c.record(1, 3);
      expect(c.progress.starsOf(1), 3);
      expect(c.coins, 30);
      expect(c.hasUnsavedChanges, isTrue);
      // Koin gagal: progres tidak ditulis supaya bintang yang tersimpan
      // tidak lebih dulu dari koinnya.
      expect(store.writes, isEmpty);
      expect(store.saved, Progress.empty);
    });

    test('menulis ulang yang tertunda di simpan berikutnya', () async {
      final store = FailingProgressStore(failing: {'coins'});
      final c = controller(store);
      await c.record(1, 3);
      await c.record(2, 2);

      store.failing = {};
      await c.setLanguage(AppLanguage.ru);
      expect(store.language, AppLanguage.ru);
      expect(store.coins, 50);
      expect(store.saved.starsOf(1), 3);
      expect(store.saved.starsOf(2), 2);
      expect(c.hasUnsavedChanges, isFalse);
    });

    test('perubahan selama menulis tetap mengikuti urutan', () async {
      final store = FailingProgressStore();
      final slow = Completer<void>();
      store.holds['home'] = slow.future;
      final c = controller(store, coins: 200);

      final first = c.buyItem(RoomItemId.kardus);
      await Future<void>.delayed(Duration.zero);
      expect(store.writes, ['home']);
      // Barang kedua dibeli selagi barang pertama masih ditulis.
      final second = c.buyItem(RoomItemId.bola);
      slow.complete();
      await Future.wait([first, second]);

      // Barang kedua tersimpan sebelum koin yang sudah dipotong untuknya.
      expect(store.writes, ['home', 'home', 'coins']);
      expect(store.home.room.owns(RoomItemId.bola), isTrue);
      expect(store.coins, 70);
    });

    test('retrySaves menulis yang tertunda', () async {
      final store = FailingProgressStore(failing: {'home'});
      final c = controller(store, coins: 100);
      expect(await c.buyItem(RoomItemId.bola), isTrue);
      expect(c.hasUnsavedChanges, isTrue);
      expect(store.coins, isNull, reason: 'rumah gagal, koin belum ditulis');

      await c.retrySaves();
      expect(c.hasUnsavedChanges, isTrue, reason: 'masih gagal');

      store.failing = {};
      await c.retrySaves();
      expect(c.hasUnsavedChanges, isFalse);
      expect(store.home.room.owns(RoomItemId.bola), isTrue);
      expect(store.coins, 20);
    });

    testWidgets('ke latar belakang menulis ulang yang tertunda', (
      tester,
    ) async {
      final store = FailingProgressStore(failing: {'coins'});
      final c = controller(store);
      await pumpApp(tester, progress: c);
      await c.record(1, 3);
      expect(c.hasUnsavedChanges, isTrue);

      store.failing = {};
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(c.hasUnsavedChanges, isFalse);
      expect(store.coins, 30);
      expect(store.saved.starsOf(1), 3);
    });

    test('semua aksi selesai tanpa error walau simpanan rusak', () async {
      final store = FailingProgressStore(
        failing: {
          'progress',
          'tutorials',
          'coins',
          'hints',
          'rewards',
          'language',
          'home',
          'needs',
        },
      );
      final c = controller(store, coins: 500);
      await c.record(1, 3);
      await c.unlockHint(13, 1, HintPay.coins);
      await c.claimDailyBonus();
      await c.watchAdForCoins();
      await c.setLanguage(AppLanguage.en);
      await c.finishTutorial(1);
      await c.replayTutorials();
      expect(await c.buyItem(RoomItemId.bola), isTrue);
      expect(await c.buyKitty(KittyId.salju), isTrue);
      expect(await c.buyAccessory(AccessoryId.pita), isTrue);
      expect(await c.buySnack(SnackId.susu), isTrue);
      expect(await c.wearAccessory(KittyId.oyen, AccessoryId.pita), isTrue);
      expect(await c.placeItem(RoomItemId.bola, Spot(0, 0)), isTrue);
      expect(await c.play(KittyId.oyen, RoomItemId.bola), isTrue);
      expect(await c.storeItem(RoomItemId.bola), isTrue);
      expect(await c.feed(KittyId.oyen, SnackId.susu), isTrue);
      expect(await c.pet(KittyId.oyen), isTrue);
      expect(await c.finishDecorating(), isTrue);
      await c.eatFromBowl(KittyId.oyen);
      expect(await c.claimKittyReward(KittyId.salju), isTrue);
      await c.resetProgress();
      expect(c.hasUnsavedChanges, isTrue);
      expect(store.writes, isEmpty);
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

    test('resetProgress menghapus bintang, koin, petunjuk, rumah, '
        'dan tutorial; hadiah harian, bahasa, dan suara tetap', () async {
      final now = DateTime(2026, 10, 19, 9);
      final today = dayNumber(now);
      final rewards = DailyRewards(
        bonusDay: today,
        adDay: today,
        adsWatched: 4,
      );
      final store = MemoryProgressStore(Progress({1: 3, 2: 2}), {1, 3})
        ..coins = 250
        ..hints = {13: 2}
        ..rewards = rewards
        ..language = AppLanguage.ru
        ..sound = const SoundSettings(music: false, effects: false)
        ..home = Home(
          room: Room.initial.buy(RoomItemId.kardus),
          kitties: {KittyId.arang},
          closet: AccessoryCloset.initial
              .buy(AccessoryId.pita)
              .wear(KittyId.arang, AccessoryId.pita),
          pantry: Pantry({SnackId.susu: 3}),
        )
        ..needs = HomeNeeds.empty
            .withKitties([KittyId.oyen, KittyId.arang], now)
            .pet(KittyId.oyen, now)!
            .claim(KittyId.oyen, now)!;
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
      expect(c.tutorialsDone, isEmpty);
      expect(c.canClaimBonus, isFalse);
      expect(c.adsLeft, maxAdsPerDay - 4);
      expect(c.language, AppLanguage.ru);
      expect(c.home, Home.initial);
      expect(c.catNeeds(KittyId.oyen), CatNeeds.full(now));
      expect(c.canClaimKittyReward(KittyId.oyen), isFalse);

      expect(store.saved, Progress.empty);
      expect(store.home, Home.initial);
      expect(store.needs.cats, {KittyId.oyen: CatNeeds.full(now)});
      expect(store.needs.rewardDays, {KittyId.oyen: today});
      expect(store.coins, 0);
      expect(store.hints, isEmpty);
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
