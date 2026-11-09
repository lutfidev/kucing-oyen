import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/dining.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';

import '../test_helpers.dart';
import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final epoch = DateTime(2026, 11, 9, 12);
  late DateTime now;
  late AtomicTestStore store;
  Future<ProgressController> load() => ProgressController.load(
    levels: testLevels,
    store: store,
    clock: () => now,
  );
  setUp(() {
    now = epoch;
    store = AtomicTestStore()
      ..home = Home(kitties: [KittyId.oyen, KittyId.salju])
      ..needs = HomeNeeds(
        cats: {
          for (final k in [KittyId.oyen, KittyId.salju])
            k: CatNeeds(hunger: 40, joy: 80, at: now),
        },
      );
  });
  test(
    'automatic dining from lounge finishes once then accepts rest',
    () async {
      final c = await load();
      await c.advanceHousehold(4);
      expect(c.household.routine.journeys, isNotEmpty);
      await c.advanceHousehold(1);
      expect(c.dining.eating, KittyId.oyen);
      await c.advanceHousehold(4);
      expect(c.catNeeds(KittyId.oyen).hunger, 80);
      expect(c.needs.bowl.eaten, contains(KittyId.oyen));
      expect(c.coins, 0);
      await c.inviteKitty(KittyId.oyen, HomeActivity.rest);
      await c.advanceHousehold(0);
      await c.advanceHousehold(1);
      expect(c.household.routine.locations[KittyId.oyen], HomeArea.santai);
      expect(c.catNeeds(KittyId.oyen).hunger, 80);
    },
  );
  test(
    'double invitation, occupied bowl, cancel and reward use one quota',
    () async {
      final c = await load();
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      final order = c.household.routine.invitations[KittyId.oyen]!.order;
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      expect(c.household.routine.invitations[KittyId.oyen]!.order, order);
      await c.inviteKitty(KittyId.salju, HomeActivity.eat);
      await c.advanceHousehold(0);
      await c.advanceHousehold(1);
      expect(c.dining.eating, KittyId.oyen);
      expect(c.dining.queue, [KittyId.salju]);
      await c.cancelInvitation(KittyId.salju);
      await c.advanceHousehold(4);
      expect(c.catNeeds(KittyId.salju).hunger, 40);
      expect(c.catNeeds(KittyId.oyen).hunger, 80);
      expect(c.dining.portionsLeft, 1);
      expect(await c.claimAllKittyRewards(), isTrue);
      expect(c.coins, 10);
      expect(await c.claimAllKittyRewards(), isFalse);
    },
  );
  test(
    'failed completion retries once across pause reload and clock rollback',
    () async {
      final c = await load();
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      await c.advanceHousehold(0);
      await c.advanceHousehold(1);
      await c.advanceHousehold(2);
      final id = c.household.routine.activities[KittyId.oyen]!.id;
      c.pauseHousehold(HouseholdPause.hidden);
      now = now.add(const Duration(hours: 1));
      expect(await c.advanceHousehold(1000), isFalse);
      expect(c.household.routine.activities[KittyId.oyen]!.left, 2);
      c.resumeHousehold(HouseholdPause.hidden);
      store.fail = true;
      expect(await c.advanceHousehold(2), isFalse);
      expect(c.needs.bowl.eaten, isEmpty);
      expect(c.household.routine.activities[KittyId.oyen]!.id, id);
      store.fail = false;
      await c.retrySaves();
      expect(c.needs.bowl.eaten, contains(KittyId.oyen));
      final food = c.catNeeds(KittyId.oyen).hunger;
      now = epoch.subtract(const Duration(days: 1));
      final again = await load();
      await again.advanceHousehold(2);
      expect(again.catNeeds(KittyId.oyen).hunger, food);
      expect(
        again.dining.availability(KittyId.oyen),
        DiningAvailability.alreadyAte,
      );
      expect(again.dining.refillIn, const Duration(hours: 4));
    },
  );
  test(
    'full and consumed portions clear requests then refresh automatically',
    () async {
      store.needs = HomeNeeds(
        cats: {
          KittyId.oyen: CatNeeds.full(now),
          KittyId.salju: CatNeeds(hunger: 20, joy: 80, at: now),
        },
        bowl: Bowl(filledAt: now, eaten: [KittyId.salju]),
      );
      final c = await load();
      expect(c.dining.portionsLeft, 1);
      expect(c.dining.availability(KittyId.oyen), DiningAvailability.full);
      for (final k in [KittyId.oyen, KittyId.salju]) {
        await c.inviteKitty(k, HomeActivity.eat);
      }
      await c.advanceHousehold(0);
      expect(c.dining.queue, isEmpty);
      expect(c.dining.eating, isNull);
      expect(
        c.household.routine.notices.values,
        everyElement(RoutineNotice.ineligible),
      );
      now = now.add(const Duration(hours: 4));
      expect(c.dining.portionsLeft, 2);
      await c.advanceHousehold(4);
      await c.advanceHousehold(1);
      await c.advanceHousehold(4);
      expect(c.needs.bowl.eaten, contains(KittyId.oyen));
    },
  );
  test('visible queue shares scheduler player priority and fairness', () {
    final routine = HomeRoutine.fromJson(
      {
        'invitations': {
          'oyen': {'kind': 'eat', 'order': 1, 'player': false},
          'salju': {'kind': 'eat', 'order': 2, 'player': true},
        },
      },
      [KittyId.oyen, KittyId.salju],
    );
    expect(routine.queueFor(HomeArea.makan), [KittyId.salju, KittyId.oyen]);
    final fair = HomeRoutine.fromJson(
      {
        ...routine.toJson(),
        'streaks': {'makan': 2},
      },
      [KittyId.oyen, KittyId.salju],
    );
    expect(fair.queueFor(HomeArea.makan), [KittyId.oyen, KittyId.salju]);
  });
}
