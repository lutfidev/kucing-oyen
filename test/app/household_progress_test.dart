import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_snapshot.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../test_helpers.dart';

class AtomicTestStore extends MemoryProgressStore implements SnapshotStore {
  Map<String, dynamic>? snapshot;
  bool fail = false;
  Completer<void>? hold;
  int writes = 0;
  @override
  Future<Map<String, dynamic>?> readSnapshot() async => snapshot;
  @override
  Future<void> writeSnapshot(Map<String, Object?> value) async {
    await hold?.future;
    if (fail) throw StateError('disk unavailable');
    snapshot = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
    writes++;
  }
}

void main() {
  final now = DateTime(2026, 11, 8, 12);
  Future<ProgressController> load(ProgressStore store) =>
      ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );

  test(
    'failed bulk claim publishes nothing; retry and reload award once',
    () async {
      final store = AtomicTestStore()
        ..home = Home(kitties: KittyId.values)
        ..coins = 5;
      final c = await load(store);
      store.fail = true;
      expect(await c.claimAllKittyRewards(), isFalse);
      expect(c.coins, 5);
      expect(c.needs.rewardDays, isEmpty);
      expect(c.hasUnsavedChanges, isTrue);
      expect(await c.claimAllKittyRewards(), isFalse);
      store.fail = false;
      await c.retrySaves();
      expect(c.coins, 95);
      final again = await load(store);
      expect(again.coins, 95);
      expect(await again.claimAllKittyRewards(), isFalse);
    },
  );

  test(
    'routine start, completion failure, restart and same-ID retry',
    () async {
      final store = AtomicTestStore()
        ..needs = HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 50, at: now)},
        );
      final c = await load(store);
      expect(await c.inviteKitty(KittyId.oyen, HomeActivity.eat), isTrue);
      await c.advanceHousehold(0);
      await c.advanceHousehold(1);
      final id = c.household.routine.activities[KittyId.oyen]!.id;
      store.fail = true;
      expect(await c.advanceHousehold(4), isFalse);
      expect(c.needs.bowl.eaten, isEmpty);
      expect(c.household.routine.activities[KittyId.oyen]!.id, id);
      store.fail = false;
      final restarted = await load(store);
      await restarted.advanceHousehold(4);
      expect(restarted.needs.bowl.eaten, contains(KittyId.oyen));
      expect(restarted.catNeeds(KittyId.oyen).hunger, 80);
      final again = await load(store);
      await again.advanceHousehold(4);
      expect(again.catNeeds(KittyId.oyen).hunger, 80);
    },
  );

  test('concurrent claim and puzzle result preserve both balances', () async {
    final store = AtomicTestStore()..coins = 0;
    final c = await load(store);
    store.hold = Completer<void>();
    final claim = c.claimAllKittyRewards();
    await Future<void>.delayed(Duration.zero);
    final result = c.record(1, 3);
    expect(c.coins, 30);
    store.hold!.complete();
    await Future.wait([claim, result]);
    expect(c.coins, 40);
    final again = await load(store);
    expect(again.coins, 40);
    expect(again.progress.starsOf(1), 3);
  });

  test(
    'raw legacy backup precedes migration; audio and keys survive',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final prefs = SharedPreferencesAsync();
      await prefs.setString(
        PrefsProgressStore.homeKey,
        jsonEncode(Home(kitties: KittyId.values).toJson()),
      );
      await prefs.setInt(PrefsProgressStore.coinsKey, 123);
      await prefs.setBool(PrefsProgressStore.musicKey, false);
      final c = await load(PrefsProgressStore(prefs));
      expect(c.coins, 123);
      expect(c.household.migrationNotice, isTrue);
      expect(c.household.routine.present(HomeArea.santai), hasLength(3));
      expect(
        await prefs.getString(PrefsProgressStore.legacyBackupKey),
        contains('123'),
      );
      expect(await prefs.getString(PrefsProgressStore.snapshotKey), isNotNull);
      expect(await prefs.getInt(PrefsProgressStore.coinsKey), 123);
      expect((await PrefsProgressStore(prefs).loadSound()).music, isFalse);
    },
  );
}
