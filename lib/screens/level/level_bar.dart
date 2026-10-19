import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../l10n/l10n.dart';

/// Bar atas layar level: kembali, judul level, dan [trailing] (tombol
/// Aturan di fase atur, penghitung langkah di fase jalan).
class LevelTopBar extends StatelessWidget {
  const LevelTopBar({
    super.key,
    required this.title,
    required this.backLabel,
    required this.onBack,
    required this.trailing,
  });

  /// "Level 13 · Vas Ibu".
  final String title;

  /// Label pembaca layar tombol kembali.
  final String backLabel;
  final VoidCallback onBack;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return SizedBox(
      height: context.koSize.iconButton,
      child: Row(
        children: [
          KoIconButton(
            icon: KoIcons.back,
            semanticLabel: backLabel,
            onPressed: onBack,
          ),
          SizedBox(width: space.s10),
          Expanded(
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, maxLines: 1, style: context.koType.heading),
              ),
            ),
          ),
          SizedBox(width: space.s10),
          trailing,
        ],
      ),
    );
  }
}

/// Tombol Aturan di bar atas fase atur.
class RulesButton extends StatelessWidget {
  const RulesButton({super.key, required this.onPressed});

  /// Null = belum berfungsi (kartu aturan di langkah 11).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return KoIconButton(
      icon: KoIcons.rules,
      semanticLabel: context.l10n.rules,
      label: context.l10n.rules,
      onPressed: onPressed,
    );
  }
}

/// Target bintang 3 di bawah bar atas: "★★★ pakai 2 benda".
class TargetChip extends StatelessWidget {
  const TargetChip({super.key, required this.items});

  /// Jumlah benda paling banyak untuk bintang 3.
  final int items;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final text = context.l10n.targetItems(items);
    return Semantics(
      container: true,
      label: context.l10n.targetLabel(text),
      excludeSemantics: true,
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(start: space.s10, end: space.s14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) KoStar(size: s.starSmall),
            SizedBox(width: space.s8),
            Text(text, maxLines: 1, style: context.koType.chipLabel),
          ],
        ),
      ),
    );
  }
}

/// Tombol bohlam kuning di kanan chip target (desain 03): membuka sheet
/// Petunjuk.
class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return KoIconButton(
      icon: KoIcons.hint,
      semanticLabel: context.l10n.hint,
      tone: KoIconButtonTone.hint,
      onPressed: onPressed,
    );
  }
}
