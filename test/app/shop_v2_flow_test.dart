import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';

import '../test_helpers.dart';
import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final now = DateTime(2026, 11, 10, 12);
  Future<ProgressController> load(AtomicTestStore store) =>
      ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );

  test(
    'discard failed layout cannot later commit through global retry',
    () async {
      final store = AtomicTestStore()
        ..home = Home(room: Room(owned: [RoomItemId.kardus]));
      final c = await load(store);
      final before = c.household.areas;
      final draft = before.place(
        c.home,
        RoomItemId.kardus,
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 1),
      );
      store.fail = true;
      expect(await c.saveAreaLayout(draft), isFalse);
      expect(c.discardAreaLayoutSave(before), isFalse);
      expect(c.discardAreaLayoutSave(draft), isTrue);
      store.fail = false;
      await c.retrySaves();
      expect(c.household.areas, before);
      expect(c.needs.decoratedAt, isNull);
      expect((await load(store)).household.areas, before);
    },
  );

  test('purchase preview and actual slot agree, full area goes to storage', () async {
    final store = AtomicTestStore()
      ..coins = 10000
      ..home = Home(room: Room(owned: shopItems.map((e) => e.id)));
    final c = await load(store);
    // Start a fresh household without kardus, with the other floor slots full.
    final fresh = AtomicTestStore()
      ..coins = 50
      ..home = Home(
        room: Room(
          owned: const [
            RoomItemId.kasur,
            RoomItemId.karpet,
            RoomItemId.rumah,
            RoomItemId.monstera,
          ],
          placed: {
            for (final id in [
              RoomItemId.kasur,
              RoomItemId.karpet,
              RoomItemId.rumah,
              RoomItemId.monstera,
            ])
              id: Spot(.5, .5),
          },
        ),
      );
    final buyer = await load(fresh);
    expect(buyer.itemPurchaseSlot(RoomItemId.kardus), isNull);
    expect(await buyer.buyItem(RoomItemId.kardus), isTrue);
    expect(buyer.home.room.owns(RoomItemId.kardus), isTrue);
    expect(buyer.household.areas.placed[RoomItemId.kardus], isNull);
    expect(buyer.coins, 0);
    expect(await buyer.buyItem(RoomItemId.kardus), isFalse);
    final restored = await load(fresh);
    expect(restored.household.areas, buyer.household.areas);
    expect(c.home.room.owned.length, 21);
  });

  test(
    'adoption preview uses scheduler capacity and persists its destination',
    () async {
      final store = AtomicTestStore()
        ..coins = 10000
        ..home = Home(kitties: [KittyId.salju, KittyId.mendung]);
      final c = await load(store);
      final expected = c.kittyAdoptionArea(KittyId.telon);
      expect(expected, HomeArea.makan);
      expect(await c.buyKitty(KittyId.telon), isTrue);
      expect(c.household.routine.findArea(KittyId.telon), expected);
      expect((await load(store)).home.isFresh(KittyId.telon), isTrue);
    },
  );

  test('failed purchase and double tap retry charge exactly once', () async {
    final store = AtomicTestStore()..coins = 50;
    final c = await load(store);
    store.hold = Completer<void>();
    final first = c.buyItem(RoomItemId.kardus);
    expect(await c.buyItem(RoomItemId.kardus), isFalse);
    store.fail = true;
    store.hold!.complete();
    expect(await first, isFalse);
    expect(c.coins, 50);
    expect(c.home.room.owns(RoomItemId.kardus), isFalse);
    store.fail = false;
    await c.retrySaves();
    await c.retrySaves();
    expect(c.coins, 0);
    final restored = await load(store);
    expect(restored.coins, 0);
    expect(restored.home.room.owns(RoomItemId.kardus), isTrue);
  });

  test(
    'area draft commits atomically, preserves bowl and rewards once',
    () async {
      final store = AtomicTestStore()
        ..home = Home(room: Room(owned: [RoomItemId.kardus]));
      final c = await load(store);
      final before = c.household.areas;
      final draft = before.place(
        c.home,
        RoomItemId.kardus,
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 1),
      );
      expect(c.household.areas, before);
      store.fail = true;
      expect(await c.saveAreaLayout(draft), isFalse);
      expect(c.household.areas, before);
      store.fail = false;
      await c.retrySaves();
      expect(c.household.areas, draft);
      final decorated = c.needs.decoratedAt;
      expect(decorated, isNotNull);
      expect(await c.saveAreaLayout(draft), isFalse);
      expect(c.needs.decoratedAt, decorated);
      final restored = await load(store);
      expect(restored.household.areas, draft);
      expect(restored.household.areas.store(RoomItemId.mangkuk), draft);
      expect(
        restored.household.areas.placed[RoomItemId.mangkuk],
        const AreaSlot(HomeArea.makan, RoomZone.floor, 0),
      );
    },
  );
}
