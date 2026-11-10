import 'home_areas.dart';
import 'home_routine.dart';
import 'kitties.dart';
import 'needs.dart';

enum CareAvailability { ready, full, limit }

/// Shared pet/brush quota, projected using the household's effective time.
class CareState {
  const CareState({
    required this.needs,
    required this.routine,
    required this.now,
  });
  final HomeNeeds needs;
  final HomeRoutine routine;
  final DateTime now;

  Duration cooldown(KittyId kitty) {
    final cat = needs.of(kitty, now);
    if (cat.petWindowStart == null || cat.petWindowJoy < petJoyPerHour) {
      return Duration.zero;
    }
    final left = cat.petWindowStart!
        .add(const Duration(hours: 1))
        .difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  CareAvailability availability(KittyId kitty) => needs.of(kitty, now).isJoyFull
      ? CareAvailability.full
      : cooldown(kitty) > Duration.zero
      ? CareAvailability.limit
      : CareAvailability.ready;

  KittyId? get using => routine.activities.entries
      .where((e) => isCare(e.value.kind))
      .map((e) => e.key)
      .firstOrNull;
  List<KittyId> get queue => routine.queueFor(HomeArea.rawat);
  static bool isCare(HomeActivity? kind) =>
      kind == HomeActivity.brush || kind == HomeActivity.pet;
}
