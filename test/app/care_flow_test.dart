import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/care.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';

import '../test_helpers.dart';
import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final epoch = DateTime(2026, 11, 10, 12);
  late DateTime now;
  late AtomicTestStore store;
  Future<ProgressController> load() => ProgressController.load(
    levels: testLevels,
    store: store,
    clock: () => now,
  );
  Future<void> start(ProgressController c, HomeActivity kind) async {
    await c.inviteKitty(KittyId.oyen, kind);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
    expect(c.caring.using, KittyId.oyen);
    expect(c.household.routine.activities[KittyId.oyen]!.kind, kind);
  }

  setUp(() {
    now = epoch;
    store = AtomicTestStore()
      ..home = Home()
      ..needs = HomeNeeds(
        cats: {
          KittyId.oyen: CatNeeds(hunger: 90, joy: 55, at: now, playedAt: now),
        },
      );
  });
  test('pet and brush share quota, duration, expiry and rollback', () async {
    var c = await load();
    for (final kind in [
      HomeActivity.pet,
      HomeActivity.brush,
      HomeActivity.pet,
    ]) {
      final before = c.catNeeds(KittyId.oyen).joy;
      await start(c, kind);
      await c.advanceHousehold(kind.seconds - 1);
      expect(c.catNeeds(KittyId.oyen).joy, before);
      await c.advanceHousehold(1);
      expect(c.catNeeds(KittyId.oyen).joy, before + 10);
    }
    expect(c.caring.availability(KittyId.oyen), CareAvailability.limit);
    expect(c.canInviteCare(KittyId.oyen, HomeActivity.brush), isFalse);
    expect(c.coins, 0);
    now = epoch.subtract(const Duration(days: 1));
    c = await load();
    expect(c.caring.cooldown(KittyId.oyen), const Duration(hours: 1));
    now = epoch.add(const Duration(minutes: 59, seconds: 59));
    expect(c.caring.cooldown(KittyId.oyen), const Duration(seconds: 1));
    now = epoch.add(const Duration(hours: 1));
    expect(c.canInviteCare(KittyId.oyen, HomeActivity.pet), isTrue);
    await start(c, HomeActivity.pet);
    await c.advanceHousehold(2);
    expect(c.catNeeds(KittyId.oyen).petWindowJoy, 10);
  });
  test('full joy prevents both, partial gain caps at 100', () async {
    store.needs = HomeNeeds(
      cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 95, at: now)},
    );
    final c = await load();
    await start(c, HomeActivity.pet);
    await c.advanceHousehold(2);
    expect(c.catNeeds(KittyId.oyen).joy, 100);
    expect(c.caring.availability(KittyId.oyen), CareAvailability.full);
    for (final kind in [HomeActivity.pet, HomeActivity.brush]) {
      expect(c.canInviteCare(KittyId.oyen, kind), isFalse);
    }
  });
  test(
    'duplicate, queue replacement and cancellation preserve active effect',
    () async {
      store.home = Home(kitties: [KittyId.oyen, KittyId.salju]);
      store.needs = HomeNeeds(
        cats: {
          for (final k in [KittyId.oyen, KittyId.salju])
            k: CatNeeds(hunger: 90, joy: 65, at: now, playedAt: now),
        },
      );
      final c = await load();
      await start(c, HomeActivity.brush);
      await c.inviteKitty(KittyId.salju, HomeActivity.pet);
      final order = c.household.routine.invitations[KittyId.salju]!.order;
      await c.inviteKitty(KittyId.salju, HomeActivity.pet);
      expect(c.household.routine.invitations[KittyId.salju]!.order, order);
      expect(c.caring.queue, [KittyId.salju]);
      await c.inviteKitty(KittyId.salju, HomeActivity.brush);
      expect(c.caring.queue, [KittyId.salju]);
      await c.cancelInvitation(KittyId.salju);
      await c.cancelInvitation(KittyId.oyen);
      expect(c.caring.queue, isEmpty);
      await c.advanceHousehold(6);
      expect(c.catNeeds(KittyId.oyen).petWindowJoy, 10);
      expect(c.catNeeds(KittyId.salju).petWindowJoy, 0);
    },
  );
  test(
    'pause reload and failed completion retain activity until one commit',
    () async {
      var c = await load();
      await start(c, HomeActivity.brush);
      await c.advanceHousehold(3);
      final id = c.household.routine.activities[KittyId.oyen]!.id;
      for (final reason in HouseholdPause.values) {
        c.pauseHousehold(reason);
        expect(await c.advanceHousehold(100), isFalse);
        c.resumeHousehold(reason);
      }
      c = await load();
      expect(c.household.routine.activities[KittyId.oyen]!.id, id);
      expect(c.household.routine.activities[KittyId.oyen]!.left, 3);
      store.fail = true;
      expect(await c.advanceHousehold(3), isFalse);
      expect(c.catNeeds(KittyId.oyen).petWindowJoy, 0);
      store.fail = false;
      await c.retrySaves();
      expect(c.catNeeds(KittyId.oyen).petWindowJoy, 10);
      await c.retrySaves();
      expect(c.catNeeds(KittyId.oyen).petWindowJoy, 10);
    },
  );
  test('automatic brushing is occasional, never automatic petting, and obeys cooldown', () {
    final rng = Random(7);
    var r = HomeRoutine.initial([KittyId.oyen]);
    var needs = store.needs;
    var completed = 0;
    for (var i = 0; i < 150; i++) {
      final next = r.advance(1, needs, now, random: rng);
      r = next.routine;
      needs = next.needs;
      expect(
        r.activities.values.any((a) => a.kind == HomeActivity.pet),
        isFalse,
      );
      if (needs.of(KittyId.oyen, now).petWindowJoy > 0) completed++;
    }
    expect(completed, greaterThan(0));
    expect(needs.of(KittyId.oyen, now).petWindowJoy, 10);
    expect(r.brushedAt[KittyId.oyen], now);
    expect(r.queueFor(HomeArea.rawat), isEmpty);
  });
}
