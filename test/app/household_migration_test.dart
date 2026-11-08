import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';

import '../test_helpers.dart';
import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final now = DateTime(2026, 11, 8, 12);
  Future<ProgressController> load(ProgressStore store) =>
      ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );

  test('complete legacy fixture preserves purchases, progress, quotas and settings', () async {
    final originalHome = Home(
      kitties: KittyId.values,
      fresh: [KittyId.kembang],
      room: Room(
        owned: RoomItemId.values,
        placed: {
          for (final id in RoomItemId.values.where(
            (id) => id != RoomItemId.sofaMini,
          ))
            id: roomItemOf(id).defaultSpot,
        },
      ),
      closet: AccessoryCloset(
        owned: AccessoryId.values,
        wearing: {
          KittyId.oyen: AccessoryId.pita,
          KittyId.bos: AccessoryId.mahkotaRaja,
        },
      ),
      pantry: Pantry({SnackId.tuna: 7, SnackId.susu: 99}),
    );
    final originalNeeds = HomeNeeds(
      cats: {
        for (final k in KittyId.values)
          k: CatNeeds(
            hunger: 55,
            joy: 60,
            at: now,
            playedAt: now,
            petWindowStart: now,
            petWindowJoy: 20,
          ),
      },
      bowl: Bowl(filledAt: now, eaten: [KittyId.oyen]),
      rewardDays: {KittyId.bos: dayNumber(now)},
      decoratedAt: now,
    );
    final store = AtomicTestStore()
      ..saved = Progress({1: 3, 2: 2})
      ..tutorials = {1, 3, 6}
      ..coins = 145
      ..hints = {2: 3}
      ..home = originalHome
      ..needs = originalNeeds
      ..rewards = DailyRewards(
        bonusDay: dayNumber(now),
        adDay: dayNumber(now),
        adsWatched: 4,
      )
      ..language = AppLanguage.ru;
    final c = await load(store);
    expect(c.home, originalHome);
    expect(c.needs, originalNeeds);
    expect(c.household.areas.placed.containsKey(RoomItemId.sofaMini), isFalse);
    expect(c.household.routine.locations.length, 9);
    final again = await load(store);
    expect(again.home, originalHome);
    expect(again.needs, originalNeeds);
    expect(again.coins, 145);
    expect(again.progress.best, {1: 3, 2: 2});
    expect(again.tutorialsDone, {1, 3, 6});
    expect(again.hintTier(2), 3);
    expect(again.language, AppLanguage.ru);
    expect(again.adsLeft, 6);
    expect(again.canClaimBonus, isFalse);
  });

  test('pause reasons compose, decorating rejects invitations, reduced motion persists', () async {
    final store = AtomicTestStore();
    final c = await load(store);
    await c.setHomeArea(HomeArea.rawat);
    await c.setReducedMotion(true);
    c.pauseHousehold(HouseholdPause.background);
    c.pauseHousehold(HouseholdPause.decorating);
    expect(await c.inviteKitty(KittyId.oyen, HomeActivity.pet), isFalse);
    c.resumeHousehold(HouseholdPause.decorating);
    expect(c.householdPaused, isTrue);
    final before = c.household.routine.toJson();
    expect(await c.advanceHousehold(100), isFalse);
    expect(c.household.routine.toJson(), before);
    c.resumeHousehold(HouseholdPause.background);
    expect(c.householdPaused, isFalse);
    final restored = await load(store);
    expect(restored.household.lastArea, HomeArea.rawat);
    expect(restored.household.reducedMotion, isTrue);
    expect(restored.household.initialSelection, isNull);
  });

  test(
    'clock rollback never rewinds needs or a committed reward day',
    () async {
      var clock = now;
      final store = AtomicTestStore();
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => clock,
      );
      await c.claimAllKittyRewards();
      clock = now.subtract(const Duration(days: 2));
      expect(await c.claimAllKittyRewards(), isFalse);
      expect(c.catNeeds(KittyId.oyen).hunger, 100);
      await c.setHomeArea(HomeArea.main);
      final again = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => clock,
      );
      expect(again.household.effectiveAt, now);
      expect(await again.claimAllKittyRewards(), isFalse);
    },
  );

  test(
    'retry revalidates a reward after needs declined during storage failure',
    () async {
      var clock = now;
      final store = AtomicTestStore();
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => clock,
      );
      store.fail = true;
      await c.claimAllKittyRewards();
      store.fail = false;
      clock = now.add(const Duration(hours: 8));
      await c.retrySaves();
      expect(c.coins, 0);
      expect(c.needs.rewardDays, isEmpty);
      expect(c.hasUnsavedChanges, isFalse);
    },
  );

  test('atomic purchases fail without charging; adoption/reset keep locations valid', () async {
    final store = AtomicTestStore()..coins = 1000;
    final c = await load(store);
    store.fail = true;
    expect(await c.buyKitty(KittyId.salju), isFalse);
    expect(c.home.ownsKitty(KittyId.salju), isFalse);
    expect(c.coins, 1000);
    store.fail = false;
    await c.retrySaves();
    expect(c.home.ownsKitty(KittyId.salju), isTrue);
    expect(c.household.routine.locations[KittyId.salju], HomeArea.santai);
    expect(c.coins, 700);
    expect(await c.buyKitty(KittyId.salju), isFalse);
    await c.claimAllKittyRewards();
    await c.resetProgress();
    expect(c.household.routine.locations.keys, [KittyId.oyen]);
    expect(c.coins, 0);
    expect(await c.claimAllKittyRewards(), isFalse);
    final again = await load(store);
    expect(again.household.routine.locations.keys, [KittyId.oyen]);
    expect(again.coins, 0);
  });

  test(
    'partial corrupt snapshot repairs house without dropping valid purchases',
    () async {
      final store = AtomicTestStore()
        ..home = Home(kitties: KittyId.values)
        ..coins = 120;
      await load(store);
      store.snapshot!['household'] = {
        'lastArea': 'unknown',
        'routine': {
          'locations': {for (final k in KittyId.values) k.name: 'santai'},
          'activities': {
            'oyen': {
              'id': 4,
              'kind': 'eat',
              'left': double.nan,
              'player': true,
            },
          },
          'journeys': [
            {
              'id': 6,
              'kitty': 'alien',
              'from': 'santai',
              'to': 'makan',
              'elapsed': .2,
            },
          ],
        },
      };
      final c = await load(store);
      expect(c.coins, 120);
      expect(c.home.kitties, containsAll(KittyId.values));
      for (final area in HomeArea.values) {
        expect(c.household.routine.present(area).length, area.capacity);
      }
      expect(c.household.routine.journeys, isEmpty);
      expect(c.household.routine.activities, isEmpty);
    },
  );

  test(
    'layout draft saves atomically, unchanged draft gives no bonus',
    () async {
      final store = AtomicTestStore()
        ..home = Home(
          room: Room(
            owned: [RoomItemId.kasur],
            placed: {
              RoomItemId.kasur: roomItemOf(RoomItemId.kasur).defaultSpot,
            },
          ),
        )
        ..needs = HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 80, joy: 50, at: now)},
        );
      final c = await load(store);
      expect(await c.saveAreaLayout(c.household.areas), isFalse);
      expect(c.needs.decoratedAt, isNull);
      final draft = c.household.areas.place(
        c.home,
        RoomItemId.kasur,
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 0),
      );
      store.fail = true;
      expect(await c.saveAreaLayout(draft), isFalse);
      expect(c.household.areas.placed[RoomItemId.kasur]?.area, HomeArea.santai);
      expect(c.catNeeds(KittyId.oyen).joy, 50);
      store.fail = false;
      await c.retrySaves();
      expect(c.household.areas.placed[RoomItemId.kasur]?.area, HomeArea.rawat);
      expect(c.catNeeds(KittyId.oyen).joy, 55);
      expect(await c.saveAreaLayout(draft), isFalse);
    },
  );
}
