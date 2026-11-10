// Shared host/device fixture. Never accesses player preferences.
import 'dart:convert';

import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_snapshot.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/household.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/sim/sim.dart';

class ProfileStore extends MemoryProgressStore implements SnapshotStore {
  Map<String, dynamic>? snapshot;
  @override
  Future<Map<String, dynamic>?> readSnapshot() async => snapshot;
  @override
  Future<void> writeSnapshot(Map<String, Object?> value) async {
    snapshot = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }
}

Future<ProgressController> profileProgress(List<Level> levels) async {
  final now = DateTime.now();
  var room = Room();
  for (final item in shopItems) {
    room = room.buy(item.id);
  }
  final home = Home(
    room: room,
    kitties: KittyId.values,
    closet: AccessoryCloset(
      owned: AccessoryId.values,
      wearing: {
        for (final kitty in KittyId.values)
          kitty: AccessoryId.values[kitty.index % AccessoryId.values.length],
      },
    ),
  );
  var areas = HomeAreas.migrate(home);
  for (final item in roomItems) {
    if (areas.placed.containsKey(item.id)) continue;
    var placed = false;
    for (final area in allowedItemAreas(item.id)) {
      for (var i = 0; i < (item.zone == RoomZone.floor ? 4 : 3); i++) {
        final slot = AreaSlot(area, item.zone, i);
        if (areas.placed.containsValue(slot)) continue;
        areas = areas.place(home, item.id, slot);
        placed = areas.placed.containsKey(item.id);
        if (placed) break;
      }
      if (placed) break;
    }
  }
  final data = ProgressSnapshot(
    progress: Progress({for (final level in levels) level.id: 3}),
    tutorials: {for (final level in levels) level.id},
    coins: 99999,
    hints: const {},
    home: home,
    needs: HomeNeeds(
      cats: {
        for (final cat in KittyId.values)
          cat: CatNeeds(hunger: 40, joy: 40, at: now),
      },
    ),
    rewards: DailyRewards(),
    language: AppLanguage.id,
    household: Household.migrate(home, now).copyWith(areas: areas),
  );
  final store = ProfileStore();
  await store.writeSnapshot(data.toJson());
  return ProgressController.load(levels: levels, store: store);
}
