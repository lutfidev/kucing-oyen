import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/household.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/rewards.dart';

import 'household_progress_test.dart' show AtomicTestStore;

void main() {
  final now = DateTime(2026, 11, 8, 12);
  test('unknown restored facility cannot silently become free base toy', () {
    final raw = Household.migrate(Home.initial, now).toJson();
    final routine = HomeRoutine.initial(Home.initial.kitties).toJson();
    routine['locations'] = {'oyen': 'main'};
    routine['activities'] = {
      'oyen': {
        'id': 1,
        'kind': 'play',
        'left': 1,
        'player': true,
        'facility': 'unknown',
      },
    };
    raw['routine'] = routine;
    final house = Household.fromJson(raw, Home.initial, now);
    final needs = HomeNeeds(
      cats: {KittyId.oyen: CatNeeds(hunger: 80, joy: 50, at: now)},
    );
    expect(house.advance(1, needs, now).needs.of(KittyId.oyen, now).joy, 50);
  });
  test('corrupt restored action cannot use removed toy', () {
    final home = Home.initial;
    final raw = Household.migrate(home, now).toJson();
    final routine = HomeRoutine.initial(home.kitties).toJson();
    routine['locations'] = {'oyen': 'main'};
    routine['activities'] = {
      'oyen': {
        'id': 1,
        'kind': 'play',
        'left': 1,
        'player': true,
        'facility': 'bola',
      },
    };
    raw['routine'] = routine;
    final h = Household.fromJson(raw, home, now);
    final needs = HomeNeeds(
      cats: {KittyId.oyen: CatNeeds(hunger: 80, joy: 50, at: now)},
    );
    final next = h.advance(1, needs, now);
    expect(next.needs.of(KittyId.oyen, now).joy, 50);
  });
  test('migration effective clock honors future legacy reward days', () async {
    final future = now.add(const Duration(days: 1));
    final s = AtomicTestStore()
      ..needs = HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 80, joy: 80, at: now)},
        rewardDays: {KittyId.oyen: dayNumber(future)},
      );
    final c = await ProgressController.load(
      levels: [],
      store: s,
      clock: () => now,
    );
    expect(
      c.household.effectiveAt.isBefore(
        DateTime(future.year, future.month, future.day),
      ),
      isFalse,
    );
  });
}
