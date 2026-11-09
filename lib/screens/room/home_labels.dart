import '../../app/progress_scope.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
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
    final queue =
        r.invitations.entries.where((e) => e.value.kind.area == target).toList()
          ..sort((a, b) => a.value.order.compareTo(b.value.order));
    return l.homeWaiting(
      homeAreaLabel(l, target!),
      queue.indexWhere((e) => e.key == kitty) + 1,
    );
  }
  return switch (r.notices[kitty]) {
    RoutineNotice.ineligible => l.homeIneligible,
    RoutineNotice.cancelled => l.homeCancelled,
    RoutineNotice.facilityRemoved => l.homeFacilityRemoved,
    null => r.sleeping.contains(kitty) ? l.homeSleeping : l.homeResting,
  };
}
