import 'package:flutter/material.dart';

import '../../theme/ko_ui.dart';
import 'ui_button.dart';

class UiChip extends StatelessWidget {
  const UiChip({
    super.key,
    required this.label,
    this.icon = Icons.check_circle_outline,
  });
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: KoUi.s12,
      vertical: KoUi.s8,
    ),
    decoration: KoUi.card(
      radius: KoUi.chipRadius,
      color: KoUi.cream,
    ).copyWith(boxShadow: []),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: KoUi.ink, size: 18),
        const SizedBox(width: KoUi.s8),
        Flexible(child: Text(label, style: KoUi.small)),
      ],
    ),
  );
}

/// Values are supplied by the model; no decay or reward rules in the view.
class UiNeed extends StatelessWidget {
  const UiNeed({
    super.key,
    required this.label,
    required this.value,
    required this.lowLabel,
    required this.icon,
  });
  final String label, lowLabel;
  final double value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final percent = value.isFinite ? value.round().clamp(0, 100) : 0;
    final low = percent < 20;
    return Semantics(
      label: label,
      value: '$percent%${low ? ', $lowLabel' : ''}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: KoUi.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                low ? Icons.warning_amber_rounded : icon,
                size: 18,
                color: low ? KoUi.danger : KoUi.ink,
              ),
              Text(
                '$label $percent%${low ? ' · $lowLabel' : ''}',
                style: KoUi.small,
              ),
            ],
          ),
          const SizedBox(height: KoUi.s4),
          ClipRRect(
            borderRadius: BorderRadius.circular(KoUi.chipRadius),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: KoUi.s8,
              color: low ? KoUi.danger : KoUi.success,
              backgroundColor: KoUi.peach,
            ),
          ),
        ],
      ),
    );
  }
}

class UiAreaTabs extends StatefulWidget {
  const UiAreaTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  }) : assert(labels.length == 4),
       assert(selected >= 0 && selected < 4);
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  State<UiAreaTabs> createState() => _UiAreaTabsState();
}

class _UiAreaTabsState extends State<UiAreaTabs> {
  final keys = List.generate(4, (_) => GlobalKey());
  @override
  void didUpdateWidget(UiAreaTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _reveal();
  }

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) {
      return;
    }
    final target = keys[widget.selected].currentContext;
    if (target != null) {
      Scrollable.of(target, axis: Axis.horizontal).position.ensureVisible(
        target.findRenderObject()!,
        alignment: .5,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : KoUi.tabTime,
      );
    }
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ExcludeSemantics(
        child: Icon(Icons.chevron_left, size: KoUi.s16, color: KoUi.mutedInk),
      ),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              4,
              (i) => Padding(
                key: keys[i],
                padding: const EdgeInsets.only(right: KoUi.s8, bottom: KoUi.s4),
                child: UiButton(
                  label: widget.labels[i],
                  kind: UiButtonKind.secondary,
                  selected: i == widget.selected,
                  icon: i == widget.selected ? Icons.check : null,
                  onPressed: () => widget.onChanged(i),
                ),
              ),
            ),
          ),
        ),
      ),
      const ExcludeSemantics(
        child: Icon(Icons.chevron_right, size: KoUi.s16, color: KoUi.mutedInk),
      ),
    ],
  );
}

class UiCatCard extends StatelessWidget {
  const UiCatCard({
    super.key,
    required this.name,
    required this.status,
    required this.portrait,
    required this.needs,
    required this.action,
    required this.onPressed,
  });
  final String name, status, action;
  final Widget portrait;
  final List<UiNeed> needs;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Container(
    decoration: KoUi.card(),
    padding: const EdgeInsets.all(KoUi.s16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: SizedBox(width: 72, height: 72, child: portrait),
            ),
            const SizedBox(width: KoUi.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: KoUi.heading),
                  Text(status, style: KoUi.small),
                ],
              ),
            ),
          ],
        ),
        for (final need in needs)
          Padding(
            padding: const EdgeInsets.only(bottom: KoUi.s8),
            child: need,
          ),
        UiButton(
          label: action,
          kind: UiButtonKind.secondary,
          onPressed: onPressed,
        ),
      ],
    ),
  );
}

class UiHeader extends StatelessWidget {
  const UiHeader({
    super.key,
    required this.title,
    required this.balanceLabel,
    required this.onBalance,
    required this.settingsLabel,
    required this.onSettings,
  });
  final String title, balanceLabel, settingsLabel;
  final VoidCallback onBalance, onSettings;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: KoUi.title),
      const SizedBox(height: KoUi.s8),
      Row(
        children: [
          Expanded(
            child: UiButton(
              label: balanceLabel,
              icon: Icons.paid_outlined,
              kind: UiButtonKind.secondary,
              onPressed: onBalance,
            ),
          ),
          const SizedBox(width: KoUi.s8),
          Tooltip(
            message: settingsLabel,
            child: UiButton(
              label: settingsLabel,
              kind: UiButtonKind.secondary,
              onPressed: onSettings,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Pinned puzzle CTA is separate from the four room activities.
class UiNavigation extends StatelessWidget {
  const UiNavigation({
    super.key,
    required this.puzzleLabel,
    required this.labels,
    required this.selected,
    required this.onPuzzle,
    required this.onChanged,
  }) : assert(labels.length == 3);
  final String puzzleLabel;
  final List<String> labels;
  final int selected;
  final VoidCallback onPuzzle;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: double.infinity,
        child: UiButton(
          label: puzzleLabel,
          icon: Icons.extension_outlined,
          onPressed: onPuzzle,
        ),
      ),
      const SizedBox(height: KoUi.s8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          3,
          (i) => Expanded(
            flex: labels[i].runes.length > 10 ? 3 : 2,
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : KoUi.s4),
              child: UiButton(
                label: labels[i],
                compact: true,
                kind: UiButtonKind.secondary,
                selected: i == selected,
                onPressed: () => onChanged(i),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
