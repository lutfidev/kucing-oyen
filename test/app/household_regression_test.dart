import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';

import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/room.dart';

import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final now = DateTime(2026, 11, 8, 12);
  test('failed purchase retry rechecks funds after hint payment', () async {
    final store = AtomicTestStore()..coins = 300;
    final c = await ProgressController.load(
      levels: [],
      store: store,
      clock: () => now,
    );
    store.fail = true;
    expect(await c.buyKitty(KittyId.salju), isFalse);
    store.fail = false;
    await c.unlockHint(1, 1, HintPay.coins);
    await c.retrySaves();
    expect(c.coins, 280);
    expect(c.home.ownsKitty(KittyId.salju), isFalse);
    expect(c.hasUnsavedChanges, isFalse);
  });
  test('adoption with sole empty slot reserved', () {
    var r = HomeRoutine.initial(KittyId.values.take(8));
    final n = HomeNeeds(
      cats: {
        for (final k in KittyId.values)
          k: CatNeeds(hunger: 40, joy: 40, at: now),
      },
    );
    r = r.invite(KittyId.oyen, HomeActivity.pet).advance(0, n, now).routine;
    expect(r.reserved(HomeArea.rawat), 1);
    expect(() => r.sync(KittyId.values), returnsNormally);
  });
  test('purchase and hint cannot spend same coins', () async {
    final s = AtomicTestStore()..coins = 300;
    final c = await ProgressController.load(
      levels: [],
      store: s,
      clock: () => now,
    );
    s.hold = Completer<void>();
    final buy = c.buyKitty(KittyId.salju);
    await Future<void>.delayed(Duration.zero);
    final hint = c.unlockHint(1, 1, HintPay.coins);
    s.hold!.complete();
    await Future.wait([buy, hint]);
    expect(c.coins, greaterThanOrEqualTo(0));
  });
  test('legacy snapshot writes advance clock high water mark', () async {
    var clock = now;
    final s = AtomicTestStore();
    final c = await ProgressController.load(
      levels: [],
      store: s,
      clock: () => clock,
    );
    clock = now.add(const Duration(hours: 8));
    await c.setLanguage(AppLanguage.ru);
    final low = c.catNeeds(KittyId.oyen).hunger;
    expect(
      (s.snapshot!['household'] as Map)['at'],
      clock.millisecondsSinceEpoch,
    );
    clock = now;
    expect(c.catNeeds(KittyId.oyen).hunger, low);
  });
  test('v2 placement from old storage survives home sync', () async {
    final s = AtomicTestStore()
      ..home = Home(
        room: Room(owned: [RoomItemId.kasur], placed: {}),
      );
    final c = await ProgressController.load(
      levels: [],
      store: s,
      clock: () => now,
    );
    final layout = c.household.areas.place(
      c.home,
      RoomItemId.kasur,
      const AreaSlot(HomeArea.santai, RoomZone.floor, 0),
    );
    expect(await c.saveAreaLayout(layout), isTrue);
    expect(c.household.areas.placed.containsKey(RoomItemId.kasur), isTrue);
    await c.claimKittyReward(KittyId.oyen);
    expect(c.household.areas.placed.containsKey(RoomItemId.kasur), isTrue);
  });
  test('invalid room subsection retains legacy owned items', () async {
    final s = AtomicTestStore()
      ..home = Home(
        room: Room(owned: [RoomItemId.kasur], placed: {}),
      );
    await ProgressController.load(levels: [], store: s, clock: () => now);
    (s.snapshot!['home'] as Map)['room'] = 'corrupt';
    final c = await ProgressController.load(
      levels: [],
      store: s,
      clock: () => now,
    );
    expect(c.home.room.owns(RoomItemId.kasur), isTrue);
  });
}
