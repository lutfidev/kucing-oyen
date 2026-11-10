import 'package:flutter/material.dart';

import '../../app/progress_scope.dart';
import '../../game/model/kitties.dart';
import '../../game/model/care.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import 'home_labels.dart';

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

class CarePanel extends StatelessWidget {
  const CarePanel({super.key, required this.progress, required this.onChoose});
  final ProgressController progress;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = progress;
    final state = c.caring;
    final selected = c.selectedHomeKitty;
    final busy = c.householdBusy || c.householdSaveFailed;
    return Container(
      key: const ValueKey('care-panel'),
      decoration: KoUi.homeCard(),
      padding: const EdgeInsets.all(KoUi.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.careTitle, style: KoUi.heading),
          Text(l.careRules, style: KoUi.caption),
          const SizedBox(height: KoUi.s8),
          Semantics(
            liveRegion: true,
            child: Text(
              state.using == null
                  ? l.careFree
                  : l.careUsing(kittyName(l, state.using!)),
              style: KoUi.small,
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: KoUi.s4),
            Text(
              '${kittyName(l, selected)} · ${state.using == selected ? l.careActive : careAvailabilityLabel(l, state, selected)}',
              key: const ValueKey('care-availability'),
              style: KoUi.small,
            ),
          ],
          if (state.queue.isNotEmpty) ...[
            const SizedBox(height: KoUi.s8),
            Text(l.careQueue(state.queue.length), style: KoUi.small),
            for (final kitty in state.queue)
              Padding(
                padding: const EdgeInsets.only(top: KoUi.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${kittyName(l, kitty)} · ${homeKittyStatus(l, c, kitty)}',
                        key: ValueKey('care-queue-${kitty.name}'),
                        style: KoUi.caption,
                      ),
                    ),
                    const SizedBox(width: KoUi.s8),
                    UiButton(
                      homeStyle: true,
                      compact: true,
                      key: ValueKey('care-cancel-${kitty.name}'),
                      label: l.homeCancelInvitation,
                      kind: UiButtonKind.secondary,
                      onPressed: busy ? null : () => c.cancelInvitation(kitty),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: KoUi.s8),
          UiButton(
            homeStyle: true,
            key: const ValueKey('care-choose'),
            label: l.careChoose,
            icon: Icons.brush_rounded,
            kind: UiButtonKind.secondary,
            onPressed: onChoose,
          ),
        ],
      ),
    );
  }
}
