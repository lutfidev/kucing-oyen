import '../../app/progress_scope.dart';
import '../../game/model/care.dart';
import '../../game/model/dining.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
import '../../game/model/play.dart';
import '../../l10n/l10n.dart';

String homeAreaLabel(AppLocalizations l, HomeArea area) => switch (area) {
  HomeArea.santai => l.uiAreaLounge,
  HomeArea.makan => l.uiAreaDining,
  HomeArea.main => l.uiAreaPlay,
  HomeArea.rawat => l.uiAreaCare,
};

String homeKittyStatus(
  AppLocalizations l,
  ProgressController c,
  KittyId kitty,
) {
  final r = c.household.routine;
  final invite = r.invitations[kitty];
  final action = r.activities[kitty];
  final target = invite?.kind.area;
  if (r.moving(kitty)) {
    return l.homeTravel(homeAreaLabel(l, r.findArea(kitty)!));
  }
  if (invite != null && action != null) {
    return l.homeAfterActivity(homeAreaLabel(l, target!));
  }
  if (action != null) return l.homeDoing(l.homeActivity(action.kind.name));
  if (invite != null) {
    final queue = r.queueFor(target!);
    return l.homeWaiting(homeAreaLabel(l, target), queue.indexOf(kitty) + 1);
  }
  return switch (r.notices[kitty]) {
    RoutineNotice.ineligible => l.homeIneligible,
    RoutineNotice.cancelled => l.homeCancelled,
    RoutineNotice.facilityRemoved => l.homeFacilityRemoved,
    null => r.sleeping.contains(kitty) ? l.homeSleeping : l.homeResting,
  };
}

String diningAvailabilityLabel(AppLocalizations l, DiningAvailability status) =>
    switch (status) {
      DiningAvailability.ready => l.diningReady,
      DiningAvailability.full => l.diningFull,
      DiningAvailability.alreadyAte => l.diningAlreadyAte,
    };

String playAvailabilityLabel(
  AppLocalizations l,
  PlayState state,
  KittyId kitty,
) => switch (state.availability(kitty)) {
  PlayAvailability.ready => l.playReady,
  PlayAvailability.full => l.playFull,
  PlayAvailability.cooldown => l.playCooldown(
    (state.cooldown(kitty).inMicroseconds / Duration.microsecondsPerMinute)
        .ceil(),
  ),
};

String careAvailabilityLabel(
  AppLocalizations l,
  CareState state,
  KittyId kitty,
) => switch (state.availability(kitty)) {
  CareAvailability.ready => l.careReady,
  CareAvailability.full => l.careFull,
  CareAvailability.limit => l.careCooldown(
    (state.cooldown(kitty).inMicroseconds / Duration.microsecondsPerMinute)
        .ceil(),
  ),
};
