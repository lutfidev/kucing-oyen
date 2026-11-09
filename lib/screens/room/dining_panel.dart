import 'package:flutter/material.dart';

import '../../app/progress_scope.dart';
import '../../game/model/dining.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import 'home_labels.dart';

String diningAvailabilityLabel(AppLocalizations l, DiningAvailability status) =>
    switch (status) {
      DiningAvailability.ready => l.diningReady,
      DiningAvailability.full => l.diningFull,
      DiningAvailability.alreadyAte => l.diningAlreadyAte,
    };

/// The bowl and the selected cat have different quotas. Show both explicitly.
class DiningPanel extends StatelessWidget {
  const DiningPanel({
    super.key,
    required this.progress,
    required this.onChoose,
  });
  final ProgressController progress;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = progress;
    final state = c.dining;
    final remaining = state.refillIn;
    final minutes = remaining == null ? 0 : (remaining.inSeconds / 60).ceil();
    final time =
        '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
    final selected = c.selectedHomeKitty;
    final busy = c.householdBusy || c.householdSaveFailed;
    return Container(
      key: const ValueKey('dining-panel'),
      decoration: KoUi.homeCard(),
      padding: const EdgeInsets.all(KoUi.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.diningTitle, style: KoUi.heading),
          Text(
            l.diningStock(state.portionsLeft, state.owned.length),
            key: const ValueKey('dining-stock'),
            style: KoUi.body,
          ),
          Text(
            remaining == null ? l.diningFresh : l.diningRefill(time),
            style: KoUi.caption,
          ),
          const SizedBox(height: KoUi.s8),
          Text(
            state.eating == null
                ? state.portionsLeft == 0
                      ? l.diningEmpty
                      : l.diningFree
                : l.diningUsing(kittyName(l, state.eating!)),
            style: KoUi.small,
          ),
          if (selected != null) ...[
            const SizedBox(height: KoUi.s4),
            Text(
              '${kittyName(l, selected)} · ${diningAvailabilityLabel(l, state.availability(selected))}',
              key: const ValueKey('dining-availability'),
              style: KoUi.small,
            ),
          ],
          if (state.queue.isNotEmpty) ...[
            const SizedBox(height: KoUi.s8),
            Text(l.diningQueue(state.queue.length), style: KoUi.small),
            for (final kitty in state.queue)
              Padding(
                padding: const EdgeInsets.only(top: KoUi.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${kittyName(l, kitty)} · ${homeKittyStatus(l, c, kitty)}',
                        key: ValueKey('dining-queue-${kitty.name}'),
                        style: KoUi.caption,
                      ),
                    ),
                    const SizedBox(width: KoUi.s8),
                    UiButton(
                      homeStyle: true,
                      compact: true,
                      key: ValueKey('dining-cancel-${kitty.name}'),
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
            key: const ValueKey('dining-choose'),
            label: l.diningChoose,
            icon: Icons.restaurant_rounded,
            kind: UiButtonKind.secondary,
            onPressed: onChoose,
          ),
        ],
      ),
    );
  }
}
