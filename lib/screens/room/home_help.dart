import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/ko_sheet.dart';
import '../../widgets/v2/ui_panel.dart';
import '../../widgets/v2/ui_button.dart';

/// Optional, repeatable introduction; it never opens in front of a puzzle.
Future<void> showHomeHelp(BuildContext context) => showKoSheet(
  context,
  barrierLabel: context.l10n.close,
  builder: (context, onClose) => KoSheet(
    label: context.l10n.guidanceHomeTitle,
    onClose: onClose,
    header: UiSheetHeader(
      title: context.l10n.guidanceHomeTitle,
      onClose: onClose,
    ),
    children: [
      UiPanel(child: Text(context.l10n.guidanceHomeBody, style: KoUi.body)),
      const SizedBox(height: KoUi.s16),
      UiButton(
        label: context.l10n.close,
        kind: UiButtonKind.secondary,
        onPressed: onClose,
      ),
    ],
  ),
);
