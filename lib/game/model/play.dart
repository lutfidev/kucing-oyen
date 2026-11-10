import 'home_areas.dart';
import 'home_items.dart';
import 'home_routine.dart';
import 'kitties.dart';
import 'needs.dart';

enum PlayAvailability { ready, full, cooldown }

/// A read-only projection; quotas and time remain owned by the household.
class PlayState {
  const PlayState({
    required this.needs,
    required this.routine,
    required this.areas,
    required this.now,
  });
  final HomeNeeds needs;
  final HomeRoutine routine;
  final HomeAreas areas;
  final DateTime now;

  Duration cooldown(KittyId kitty) {
    final last = needs.of(kitty, now).playedAt;
    if (last == null) return Duration.zero;
    final left = last.add(const Duration(minutes: playMinutes)).difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  PlayAvailability availability(KittyId kitty) => needs.of(kitty, now).isJoyFull
      ? PlayAvailability.full
      : cooldown(kitty) > Duration.zero
      ? PlayAvailability.cooldown
      : PlayAvailability.ready;

  KittyId? get playing => routine.activities.entries
      .where((e) => e.value.kind == HomeActivity.play)
      .map((e) => e.key)
      .firstOrNull;
  RoomItemId get toy => playing == null
      ? areas.playToy ?? RoomItemId.bola
      : routine.activities[playing]!.facility ?? RoomItemId.bola;
  List<KittyId> get queue => routine.queueFor(HomeArea.main);
}
