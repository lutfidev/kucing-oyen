import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';

void main() {
  final now = DateTime(2026, 11, 8, 12);
  HomeNeeds hungry() => HomeNeeds(
    cats: {
      for (final k in KittyId.values) k: CatNeeds(hunger: 40, joy: 40, at: now),
    },
  );
  test(
    'FIFO waits for the older arrival and fairness serves automatic third',
    () {
      var state = HomeRoutine.initial(KittyId.values)
          .invite(KittyId.oyen, HomeActivity.eat)
          .invite(KittyId.arang, HomeActivity.eat);
      state = state.advance(0, hungry(), now).routine;
      expect(
        state.activities,
        isEmpty,
        reason: 'resident cannot overtake older invitation in transit',
      );
      state = state.advance(1, hungry(), now).routine;
      expect(state.activities.keys, [KittyId.oyen]);

      final raw = HomeRoutine.initial(KittyId.values).toJson();
      raw['streaks'] = {'makan': 2};
      state = HomeRoutine.fromJson(raw, KittyId.values)
          .invite(KittyId.oyen, HomeActivity.eat, player: false)
          .invite(KittyId.arang, HomeActivity.eat);
      state = state.advance(0, hungry(), now).routine;
      expect(state.activities, isEmpty);
      state = state.advance(1, hungry(), now).routine;
      expect(state.activities.keys, [KittyId.oyen]);
      expect(state.activities.values.single.player, isFalse);
    },
  );

  test('same-area invitation includes a short approach before starting', () {
    var state = HomeRoutine.initial(KittyId.values)
        .invite(KittyId.arang, HomeActivity.eat);
    state = state.advance(0, hungry(), now).routine;
    expect(state.activities, isEmpty);
    expect(state.journeys.single.from, state.journeys.single.to);
    expect(state.reserved(HomeArea.makan), 0);
    state = HomeRoutine.fromJson(
      state.toJson(),
      KittyId.values,
    ).advance(1, hungry(), now).routine;
    expect(state.activities.keys, [KittyId.arang]);
  });
  void check(HomeRoutine state) {
    expect(state.locations.length, 9);
    for (final a in HomeArea.values) {
      expect(
        state.present(a).length + state.reserved(a),
        lessThanOrEqualTo(a.capacity),
      );
    }
    final moving = state.journeys
        .expand((j) => [j.kitty, if (j.other != null) j.other!])
        .toList();
    expect(moving.toSet().length, moving.length);
    expect(moving.any(state.activities.containsKey), isFalse);
    expect(
      state.activities.values.map((a) => a.kind.area).toSet().length,
      state.activities.length,
    );
  }

  test(
    'seeded mixed invitations survive cancellation and repeated reloads',
    () {
      List<Object?> run(int seed) {
        final random = Random(seed);
        var state = HomeRoutine.initial(KittyId.values);
        var needs = hungry();
        for (var i = 0; i < 1200; i++) {
          if (i % 9 == 0) {
            final cat = KittyId.values[random.nextInt(9)];
            state = state.invite(cat, HomeActivity.values[random.nextInt(5)]);
          }
          if (i % 23 == 0) {
            state = state.cancel(KittyId.values[random.nextInt(9)]);
          }
          final next = state.advance(.25, needs, now, random: random);
          state = next.routine;
          needs = next.needs;
          if (i % 11 == 0) {
            state = HomeRoutine.fromJson(state.toJson(), KittyId.values);
          }
          check(state);
        }
        return [state.toJson(), needs.toJson()];
      }

      expect(run(123), run(123));
      run(987);
    },
  );

  test('new invitation waits for active task and cancellation preserves its one effect', () {
    var state = HomeRoutine.initial(KittyId.values)
        .invite(KittyId.arang, HomeActivity.eat);
    var needs = hungry();
    state = state.advance(0, needs, now).routine;
    state = state.advance(1, needs, now).routine;
    final id = state.activities[KittyId.arang]!.id;
    state = state.invite(KittyId.arang, HomeActivity.play);
    expect(state.activities[KittyId.arang]!.id, id);
    state = state.cancel(KittyId.arang);
    final next = state.advance(4, needs, now);
    state = next.routine;
    needs = next.needs;
    expect(needs.of(KittyId.arang, now).hunger, 80);
    expect(state.invitations[KittyId.arang], isNull);
    expect(state.advance(0, needs, now).needs, needs);
  });

  test(
    'full house swaps atomically, cancellation before and after threshold',
    () {
      final initial = HomeRoutine.initial(KittyId.values);
      var state = initial.invite(KittyId.oyen, HomeActivity.eat);
      state = state.advance(0, hungry(), now, random: Random(1)).routine;
      expect(state.journeys.single.other, isNotNull);
      expect(state.locations[KittyId.oyen], HomeArea.santai);
      check(state);
      expect(state.cancel(KittyId.oyen).journeys, isEmpty);
      state = state.advance(.5, hungry(), now).routine;
      expect(state.locations[KittyId.oyen], HomeArea.makan);
      check(state);
      state = state.cancel(KittyId.oyen);
      expect(state.journeys, hasLength(1));
      state = state.advance(.5, hungry(), now).routine;
      expect(state.journeys, isEmpty);
      expect(state.activities, isEmpty);
    },
  );
  test('nine invitations complete without duplicate cats or deadlock', () {
    var state = HomeRoutine.initial(KittyId.values);
    var needs = hungry();
    for (final k in KittyId.values) {
      state = state.invite(k, HomeActivity.eat);
    }
    final rng = Random(17);
    for (var i = 0; i < 800; i++) {
      final next = state.advance(.25, needs, now, random: rng);
      state = next.routine;
      needs = next.needs;
      check(state);
      if (needs.bowl.eaten.length == 9) break;
    }
    expect(needs.bowl.eaten, containsAll(KittyId.values));
  });
  test('start precedes completion; save/reload, pause and eligibility', () {
    var state = HomeRoutine.initial([KittyId.oyen]);
    var needs = hungry();
    state = state.invite(KittyId.oyen, HomeActivity.eat);
    state = state.advance(100, needs, now).routine;
    expect(needs.bowl.eaten, isEmpty);
    state = state.advance(1, needs, now).routine;
    expect(state.activities, isNotEmpty);
    final restored = HomeRoutine.fromJson(state.toJson(), [KittyId.oyen]);
    final finished = restored.advance(4, needs, now);
    needs = finished.needs;
    expect(needs.bowl.eaten, contains(KittyId.oyen));
    expect(finished.routine.advance(4, needs, now).needs, needs);
    expect(
      restored.advance(20, hungry(), now, paused: true).routine.toJson(),
      restored.toJson(),
    );
    final full = HomeNeeds.empty.withKitties([KittyId.oyen], now);
    final rejected = HomeRoutine.initial([KittyId.oyen])
        .invite(KittyId.oyen, HomeActivity.eat)
        .advance(0, full, now);
    expect(rejected.routine.invitations, isEmpty);
    expect(rejected.routine.notices[KittyId.oyen], RoutineNotice.ineligible);
  });
}
