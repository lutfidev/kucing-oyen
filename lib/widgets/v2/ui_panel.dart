import 'package:flutter/material.dart';

import '../../theme/ko_ui.dart';
import '../../l10n/l10n.dart';
import 'ui_button.dart';

/// Shared paper panel for guidance, rewards and preferences.
class UiPanel extends StatelessWidget {
  const UiPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.locked = false,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final bool locked;
  @override
  Widget build(BuildContext context) => Container(
    decoration: KoUi.card(color: locked ? KoUi.cream : KoUi.paper).copyWith(
      border: Border.all(
        color: borderColor ?? KoUi.homeLine,
        width: KoUi.outline,
      ),
    ),
    padding: padding ?? const EdgeInsets.all(KoUi.s16),
    child: child,
  );
}

/// Title can wrap without competing with a large balance or a close target.
class UiSheetHeader extends StatelessWidget {
  const UiSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: KoUi.title),
            ),
          ),
          const SizedBox(width: KoUi.s8),
          Semantics(
            container: true,
            button: true,
            enabled: onClose != null,
            label: context.l10n.close,
            onTap: onClose,
            excludeSemantics: true,
            child: IconButton(
              onPressed: onClose,
              constraints: const BoxConstraints.tightFor(
                width: KoUi.target,
                height: KoUi.target,
              ),
              icon: const Icon(Icons.close, color: KoUi.ink),
            ),
          ),
        ],
      ),
      if (trailing != null)
        Align(alignment: AlignmentDirectional.centerStart, child: trailing!),
      if (subtitle != null) ...[
        const SizedBox(height: KoUi.s8),
        Text(subtitle!, style: KoUi.small.copyWith(color: KoUi.mutedInk)),
      ],
    ],
  );
}

class UiSaveNotice extends StatelessWidget {
  const UiSaveNotice({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: KoUi.s12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            context.l10n.guidanceSaveFailed,
            style: KoUi.small.copyWith(color: KoUi.danger),
          ),
        ),
        const SizedBox(height: KoUi.s8),
        UiButton(
          label: context.l10n.homeRetry,
          onPressed: onRetry,
          kind: UiButtonKind.secondary,
        ),
      ],
    ),
  );
}
