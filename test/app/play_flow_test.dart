import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/play.dart';
import 'package:kucing_oren/game/model/room.dart';

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
  Future<void> start(ProgressController c) async {
    await c.inviteKitty(KittyId.oyen, HomeActivity.play);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
    expect(c.playing.playing, KittyId.oyen);
  }

  setUp(() {
    now = epoch;
    store = AtomicTestStore()
      ..home = Home(kitties: [KittyId.oyen, KittyId.salju])
      ..needs = HomeNeeds(
        decoratedAt: now,
        cats: {
          for (final k in [KittyId.oyen, KittyId.salju])
            k: CatNeeds(hunger: 90, joy: 65, at: now),
        },
      );
  });
  test(
    'automatic play uses free ball and awards joy only at completion',
    () async {
      final c = await load();
      await c.advanceHousehold(4);
      await c.advanceHousehold(1);
      expect(c.playing.playing, KittyId.oyen);
      expect(c.playing.toy, RoomItemId.bola);
      await c.advanceHousehold(7);
      expect(c.catNeeds(KittyId.oyen).joy, 65);
      await c.advanceHousehold(1);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      expect(c.playing.cooldown(KittyId.oyen), const Duration(minutes: 30));
      expect(c.coins, 0);
      expect(await c.claimAllKittyRewards(), isTrue);
      expect(c.coins, 10);
      expect(await c.claimAllKittyRewards(), isFalse);
    },
  );
  test('one player at a time, duplicate invitation and cancel preserve active play', () async {
    final c = await load();
    await start(c);
    await c.inviteKitty(KittyId.salju, HomeActivity.play);
    final order = c.household.routine.invitations[KittyId.salju]!.order;
    await c.inviteKitty(KittyId.salju, HomeActivity.play);
    expect(c.household.routine.invitations[KittyId.salju]!.order, order);
    expect(c.playing.queue, [KittyId.salju]);
    await c.cancelInvitation(KittyId.salju);
    expect(c.playing.queue, isEmpty);
    expect(c.playing.playing, KittyId.oyen);
    await c.inviteKitty(KittyId.oyen, HomeActivity.rest);
    await c.advanceHousehold(7);
    expect(c.playing.playing, KittyId.oyen);
    expect(c.catNeeds(KittyId.oyen).joy, 65);
    await c.advanceHousehold(1);
    expect(c.catNeeds(KittyId.oyen).joy, 75);
    expect(c.household.routine.journeys, isNotEmpty);
  });
  test('cooldown shared across toys, full joy and exact expiry', () async {
    store.home = Home(
      room: Room(
        owned: [RoomItemId.tikus],
        placed: {RoomItemId.tikus: roomItemOf(RoomItemId.tikus).defaultSpot},
      ),
    );
    final c = await load();
    expect(c.playing.toy, RoomItemId.tikus);
    await start(c);
    expect(
      c.household.routine.activities[KittyId.oyen]!.facility,
      RoomItemId.tikus,
    );
    await c.advanceHousehold(8);
    await c.saveAreaLayout(c.household.areas.store(RoomItemId.tikus));
    expect(c.playing.toy, RoomItemId.bola);
    expect(c.canInvitePlay(KittyId.oyen), isFalse);
    now = epoch.add(const Duration(minutes: 29, seconds: 59));
    expect(c.playing.cooldown(KittyId.oyen), const Duration(seconds: 1));
    now = epoch.add(const Duration(minutes: 30));
    expect(c.canInvitePlay(KittyId.oyen), isTrue);
    final full = PlayState(
      needs: HomeNeeds(cats: {KittyId.oyen: CatNeeds.full(now)}),
      routine: c.household.routine,
      areas: c.household.areas,
      now: now,
    );
    expect(full.availability(KittyId.oyen), PlayAvailability.full);
  });
  test(
    'removing occupied toy interrupts without joy then falls back to ball',
    () async {
      store.home = Home(
        room: Room(
          owned: [RoomItemId.tikus],
          placed: {RoomItemId.tikus: roomItemOf(RoomItemId.tikus).defaultSpot},
        ),
      );
      final c = await load();
      await start(c);
      await c.advanceHousehold(4);
      await c.saveAreaLayout(c.household.areas.store(RoomItemId.tikus));
      expect(c.playing.playing, isNull);
      expect(c.catNeeds(KittyId.oyen).joy, 65);
      expect(c.catNeeds(KittyId.oyen).playedAt, isNull);
      expect(c.playing.toy, RoomItemId.bola);
      await start(c);
      await c.advanceHousehold(8);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
    },
  );
  test(
    'pause, reload, failed completion and rollback preserve one reward',
    () async {
      var c = await load();
      await start(c);
      await c.advanceHousehold(4);
      c.pauseHousehold(HouseholdPause.hidden);
      expect(await c.advanceHousehold(999), isFalse);
      expect(c.household.routine.activities[KittyId.oyen]!.left, 4);
      c = await load();
      expect(c.household.routine.activities[KittyId.oyen]!.left, 4);
      store.fail = true;
      expect(await c.advanceHousehold(4), isFalse);
      expect(c.catNeeds(KittyId.oyen).joy, 65);
      store.fail = false;
      await c.retrySaves();
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      now = epoch.subtract(const Duration(days: 1));
      c = await load();
      expect(c.playing.cooldown(KittyId.oyen), const Duration(minutes: 30));
      await c.advanceHousehold(8);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      await c.claimAllKittyRewards();
      await c.claimAllKittyRewards();
      expect(c.coins, 20); // Salju also finishes its automatic turn.
    },
  );
  test('visible queue respects player priority and automatic fairness', () {
    final r = HomeRoutine.fromJson(
      {
        'invitations': {
          'oyen': {'kind': 'play', 'order': 1, 'player': false},
          'salju': {'kind': 'play', 'order': 2, 'player': true},
        },
      },
      [KittyId.oyen, KittyId.salju],
    );
    expect(r.queueFor(HomeArea.main), [KittyId.salju, KittyId.oyen]);
    final fair = HomeRoutine.fromJson(
      {
        ...r.toJson(),
        'streaks': {'main': 2},
      },
      [KittyId.oyen, KittyId.salju],
    );
    expect(fair.queueFor(HomeArea.main), [KittyId.oyen, KittyId.salju]);
  });
  test(
    'player may invite above automatic threshold without exceeding full joy',
    () async {
      store.home = Home();
      store.needs = HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 95, at: now)},
      );
      final c = await load();
      await c.advanceHousehold(4);
      expect(c.playing.playing, isNull);
      expect(c.playing.queue, isEmpty);
      await start(c);
      await c.advanceHousehold(8);
      expect(c.catNeeds(KittyId.oyen).joy, 100);
      expect(c.playing.availability(KittyId.oyen), PlayAvailability.full);
    },
  );
}
