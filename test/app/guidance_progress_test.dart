import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';

import '../test_helpers.dart';
import 'household_progress_test.dart' show AtomicTestStore;

class _DeferredAd implements RewardedAds {
  final result = Completer<bool>();
  int calls = 0;
  @override
  Future<bool> show() {
    calls++;
    return result.future;
  }
}

class _SoundStore extends AtomicTestStore {
  @override
  Future<void> saveSound(SoundSettings value) async {
    if (this.fail) throw StateError('disk unavailable');
    await super.saveSound(value);
  }
}

void main() {
  final now = DateTime(2026, 11, 10, 12);
  Future<ProgressController> load(AtomicTestStore store, {RewardedAds? ads}) =>
      ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
        hintAds: ads,
        coinAds: ads,
      );

  test(
    'daily bonus is invisible until commit; duplicate and reload give it once',
    () async {
      final store = AtomicTestStore()..coins = 7;
      final c = await load(store);
      store.hold = Completer<void>();
      final claim = c.claimDailyBonus();
      await Future<void>.delayed(Duration.zero);
      expect(c.coins, 7);
      expect(await c.claimDailyBonus(), isFalse);
      store.hold!.complete();
      expect(await claim, isTrue);
      final again = await load(store);
      expect(again.coins, 27);
      expect(await again.claimDailyBonus(), isFalse);
    },
  );

  test('failed bonus leaves balance and quota; retry commits once', () async {
    final store = AtomicTestStore()..coins = 7;
    final c = await load(store);
    store.fail = true;
    expect(await c.claimDailyBonus(), isFalse);
    expect(c.coins, 7);
    expect(c.canClaimBonus, isTrue);
    expect(c.saveFailed, isTrue);
    expect(c.householdSaveFailed, isTrue);
    store.fail = false;
    await c.retrySaves();
    await c.retrySaves();
    expect(c.coins, 27);
    expect(c.canClaimBonus, isFalse);
    expect(c.householdSaveFailed, isFalse);
    expect((await load(store)).coins, 27);
  });

  test('failed paid hint retries its payment once; subsequent tier remains ordered', () async {
    final store = AtomicTestStore()..coins = 60;
    final c = await load(store);
    store.fail = true;
    expect(await c.unlockHint(13, 1, HintPay.coins), HintUnlock.saveFailed);
    expect(c.coins, 60);
    expect(c.hintTier(13), 0);
    expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.notReady);
    store.fail = false;
    await c.retrySaves();
    await c.retrySaves();
    expect(c.coins, 40);
    expect(c.hintTier(13), 1);
    expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.opened);
    expect((await load(store)).coins, 0);
  });

  test('earned ad hint retries storage without another ad', () async {
    final store = AtomicTestStore()..coins = 2;
    final ads = FakeRewardedAds();
    final c = await load(store, ads: ads);
    store.fail = true;
    expect(await c.unlockHint(13, 1, HintPay.ad), HintUnlock.saveFailed);
    expect(c.hintTier(13), 0);
    store.fail = false;
    await c.retrySaves();
    expect(c.hintTier(13), 1);
    expect(c.coins, 2);
    expect(ads.shown, 1);
  });

  test(
    'earned ad coins retry storage without spending another daily slot',
    () async {
      final store = AtomicTestStore()..coins = 2;
      final ads = FakeRewardedAds();
      final c = await load(store, ads: ads);
      store.fail = true;
      expect(await c.watchAdForCoins(), AdReward.saveFailed);
      expect(c.coins, 2);
      expect(c.adsLeft, maxAdsPerDay);
      store.fail = false;
      await c.retrySaves();
      await c.retrySaves();
      expect(c.coins, 22);
      expect(c.adsLeft, maxAdsPerDay - 1);
      expect(ads.shown, 1);
      expect((await load(store)).adsLeft, maxAdsPerDay - 1);
    },
  );

  test(
    'puzzle earnings during a guidance write survive both commits',
    () async {
      final store = AtomicTestStore()..coins = 50;
      final c = await load(store);
      store.hold = Completer<void>();
      final hint = c.unlockHint(13, 1, HintPay.coins);
      await Future<void>.delayed(Duration.zero);
      final record = c.record(1, 3);
      store.hold!.complete();
      await Future.wait([hint, record]);
      expect(c.coins, 60);
      final again = await load(store);
      expect(again.coins, 60);
      expect(again.hintTier(13), 1);
      expect(again.progress.starsOf(1), 3);
    },
  );

  test('failed reset preserves full home; success resets areas, queues and selection', () async {
    final store = AtomicTestStore()
      ..home = Home(kitties: KittyId.values)
      ..coins = 71
      ..language = AppLanguage.ru
      ..rewards = DailyRewards(bonusDay: dayNumber(now))
      ..needs = HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 40, at: now)},
      );
    final c = await load(store);
    await c.setReducedMotion(true);
    await c.setHomeArea(HomeArea.main);
    await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
    c.selectHomeKitty(KittyId.salju);
    final before = jsonEncode(store.snapshot);
    store.fail = true;
    expect(await c.resetProgress(), isFalse);
    expect(c.coins, 71);
    expect(c.home.kitties, hasLength(9));
    expect(c.household.routine.invitations, isNotEmpty);
    expect(jsonEncode(store.snapshot), before);
    store.fail = false;
    expect(await c.resetProgress(), isTrue);
    expect(c.home, Home.initial);
    expect(c.coins, 0);
    expect(c.household.lastArea, HomeArea.santai);
    expect(c.household.routine.invitations, isEmpty);
    expect(c.household.routine.activities, isEmpty);
    expect(c.household.reducedMotion, isTrue);
    expect(c.selectedHomeKitty, KittyId.oyen);
    final again = await load(store);
    expect(again.home, Home.initial);
    expect(again.language, AppLanguage.ru);
    expect(again.canClaimBonus, isFalse);
    expect(again.household.reducedMotion, isTrue);
  });

  for (final hint in [false, true]) {
    test('reset ignores old ${hint ? "hint" : "coin"} ad callback', () async {
      final store = AtomicTestStore()..coins = 50;
      final ads = _DeferredAd();
      final c = await load(store, ads: ads);
      final pending = hint
          ? c.unlockHint(13, 1, HintPay.ad)
          : c.watchAdForCoins();
      expect(ads.calls, 1);
      expect(await c.resetProgress(), isTrue);
      ads.result.complete(true);
      await pending;
      expect(c.coins, 0);
      expect(c.hintTier(13), 0);
      final again = await load(store);
      expect(again.coins, 0);
      expect(again.hintTier(13), 0);
    });
  }

  test('sound failure is visible and retry saves the latest toggles', () async {
    final store = _SoundStore()..fail = true;
    final audio = GameAudio(player: FakeSoundPlayer(), store: store);
    await audio.setMusicOn(false);
    await audio.setEffectsOn(false);
    expect(audio.saveFailed, isTrue);
    store.fail = false;
    await audio.retrySettings();
    expect(audio.saveFailed, isFalse);
    expect(store.sound, const SoundSettings(music: false, effects: false));
  });

  test(
    'lifecycle retry during failed reset preserves pending home reward',
    () async {
      final store = AtomicTestStore()..coins = 5;
      final c = await load(store);
      store.fail = true;
      expect(await c.claimAllKittyRewards(), isFalse);
      expect(c.householdSaveFailed, isTrue);
      store.hold = Completer<void>();
      final reset = c.resetProgress();
      await Future<void>.delayed(Duration.zero);
      final retry = c.retrySaves();
      expect(c.householdSaveFailed, isTrue);
      store.hold!.complete();
      expect(await reset, isFalse);
      await retry;
      expect(c.householdSaveFailed, isTrue);
      store.fail = false;
      await c.retrySaves();
      expect(c.coins, 15);
      expect(c.householdSaveFailed, isFalse);
      expect((await load(store)).coins, 15);
    },
  );

  for (final hint in [false, true]) {
    test(
      'earned ${hint ? "hint" : "coin"} ad survives failed concurrent reset',
      () async {
        final store = AtomicTestStore()..coins = 5;
        final ads = _DeferredAd();
        final c = await load(store, ads: ads);
        final reward = hint
            ? c.unlockHint(13, 1, HintPay.ad)
            : c.watchAdForCoins();
        store.hold = Completer<void>();
        store.fail = true;
        final reset = c.resetProgress();
        await Future<void>.delayed(Duration.zero);
        ads.result.complete(true);
        await Future<void>.delayed(Duration.zero);
        expect(c.coins, 5);
        store.hold!.complete();
        expect(await reset, isFalse);
        await reward;
        expect(c.saveFailed, isTrue);
        store.fail = false;
        await c.retrySaves();
        expect(c.coins, hint ? 5 : 25);
        expect(c.hintTier(13), hint ? 1 : 0);
        expect(ads.calls, 1);
      },
    );
  }

  test('ad reserves guidance until reward is persisted, preventing competing bonus', () async {
    final store = AtomicTestStore()..coins = 5;
    final ads = _DeferredAd();
    final c = await load(store, ads: ads);
    final reward = c.watchAdForCoins();
    expect(await c.claimDailyBonus(), isFalse);
    expect(await c.unlockHint(13, 1, HintPay.ad), HintUnlock.notReady);
    store.fail = true;
    ads.result.complete(true);
    expect(await reward, AdReward.saveFailed);
    store.fail = false;
    await c.retrySaves();
    expect(c.coins, 25);
    expect(await c.claimDailyBonus(), isTrue);
    expect(c.coins, 45);
    expect(ads.calls, 1);
  });

  for (final hint in [false, true]) {
    test(
      'queued earned ${hint ? "hint" : "coin"} survives a later failed reset',
      () async {
        final store = AtomicTestStore()..coins = 5;
        final ads = _DeferredAd();
        final c = await load(store, ads: ads);
        final reward = hint
            ? c.unlockHint(13, 1, HintPay.ad)
            : c.watchAdForCoins();
        store.hold = Completer<void>();
        final record = c.record(1, 3);
        await Future<void>.delayed(Duration.zero);
        ads.result.complete(true);
        await Future<void>.delayed(Duration.zero);
        final reset = c.resetProgress();
        store.fail = true;
        store.hold!.complete();
        await record;
        await reward;
        expect(await reset, isFalse);
        expect(c.saveFailed, isTrue);
        store.fail = false;
        await c.retrySaves();
        expect(c.coins, hint ? 35 : 55);
        expect(c.hintTier(13), hint ? 1 : 0);
        expect(ads.calls, 1);
      },
    );
  }

  test(
    'successful reset clears a previous ordinary snapshot failure',
    () async {
      final store = AtomicTestStore()..coins = 50;
      final c = await load(store);
      store.fail = true;
      await c.setLanguage(AppLanguage.ru);
      expect(c.saveFailed, isTrue);
      store.fail = false;
      expect(await c.resetProgress(), isTrue);
      expect(c.saveFailed, isFalse);
      expect(c.hasUnsavedChanges, isFalse);
      expect((await load(store)).language, AppLanguage.ru);
    },
  );
}
