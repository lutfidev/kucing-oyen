import 'package:flutter/material.dart';

import '../../app/progress_scope.dart';
import '../../game/model/kitties.dart';
import '../../game/model/play.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import 'home_labels.dart';

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

class PlayPanel extends StatelessWidget {
  const PlayPanel({super.key, required this.progress, required this.onChoose});
  final ProgressController progress;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = progress;
    final state = c.playing;
    final selected = c.selectedHomeKitty;
    final busy = c.householdBusy || c.householdSaveFailed;
    return Container(
      key: const ValueKey('play-panel'),
      decoration: KoUi.homeCard(),
      padding: const EdgeInsets.all(KoUi.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.playTitle, style: KoUi.heading),
          Text(l.playRules, style: KoUi.caption),
          const SizedBox(height: KoUi.s8),
          Text(l.playToy(roomItemName(l, state.toy)), style: KoUi.small),
          Text(
            state.playing == null
                ? l.playFree
                : l.playUsing(kittyName(l, state.playing!)),
            style: KoUi.small,
          ),
          if (selected != null) ...[
            const SizedBox(height: KoUi.s4),
            Text(
              '${kittyName(l, selected)} · ${state.playing == selected ? l.playActive : playAvailabilityLabel(l, state, selected)}',
              key: const ValueKey('play-availability'),
              style: KoUi.small,
            ),
          ],
          if (state.queue.isNotEmpty) ...[
            const SizedBox(height: KoUi.s8),
            Text(l.playQueue(state.queue.length), style: KoUi.small),
            for (final kitty in state.queue)
              Padding(
                padding: const EdgeInsets.only(top: KoUi.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${kittyName(l, kitty)} · ${homeKittyStatus(l, c, kitty)}',
                        key: ValueKey('play-queue-${kitty.name}'),
                        style: KoUi.caption,
                      ),
                    ),
                    const SizedBox(width: KoUi.s8),
                    UiButton(
                      homeStyle: true,
                      compact: true,
                      key: ValueKey('play-cancel-${kitty.name}'),
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
            key: const ValueKey('play-choose'),
            label: l.playChoose,
            icon: Icons.sports_baseball_rounded,
            kind: UiButtonKind.secondary,
            onPressed: onChoose,
          ),
        ],
      ),
    );
  }
}
