import 'home_areas.dart';
import 'home_routine.dart';
import 'kitties.dart';
import 'needs.dart';

enum DiningAvailability { ready, full, alreadyAte }

/// Read-only projection of the existing shared bowl; it owns no stock/clock.
class DiningState {
  DiningState({
    required this.needs,
    required this.routine,
    required Iterable<KittyId> owned,
    required this.now,
  }) : owned = Set.unmodifiable(owned);

  final HomeNeeds needs;
  final HomeRoutine routine;
  final Set<KittyId> owned;
  final DateTime now;

  DiningAvailability availability(KittyId kitty) =>
      needs.bowl.hasEaten(kitty, now)
      ? DiningAvailability.alreadyAte
      : !needs.of(kitty, now).canEatFromBowl
      ? DiningAvailability.full
      : DiningAvailability.ready;

  int get portionsLeft =>
      owned.where((k) => !needs.bowl.hasEaten(k, now)).length;
  Duration? get refillIn => needs.bowl.refillIn(now);
  KittyId? get eating => routine.activities.entries
      .where((e) => e.value.kind == HomeActivity.eat)
      .map((e) => e.key)
      .firstOrNull;
  List<KittyId> get queue => routine.queueFor(HomeArea.makan);
}
