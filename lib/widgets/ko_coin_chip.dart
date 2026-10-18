import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'game_art.dart';
import 'ko_icon.dart';
import 'ko_pressable.dart';

/// Gaya [KoCoinChip] per layar.
enum KoCoinChipStyle {
  /// Beranda (desain 01): koin 28 px, bayangan `coinChip`.
  raised,

  /// Lemari Kostum (desain 12): koin 24 px, bergaris tanpa bayangan.
  outlined,

  /// Kepala sheet (desain 10): lebih pendek, koin 22 px, bergaris.
  compact,
}

/// Saldo koin. Dengan [onPressed] chip menjadi tombol "tambah koin" dengan
/// "+" kecil di kanan angka; [badge] menambah titik di pojok kanan atas
/// (bonus harian siap).
class KoCoinChip extends StatelessWidget {
  const KoCoinChip({
    super.key,
    required this.coins,
    this.style = KoCoinChipStyle.raised,
    this.onPressed,
    this.badge = false,
  });

  final int coins;
  final KoCoinChipStyle style;

  /// Null = hanya menampilkan saldo.
  final VoidCallback? onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final radius = context.koRadius.pill;
    final raised = style == KoCoinChipStyle.raised;
    final compact = style == KoCoinChipStyle.compact;
    final pressable = onPressed != null;

    final (double coin, double gap, TextStyle number) = switch (style) {
      KoCoinChipStyle.raised => (s.iconLarge, space.s8, t.chip),
      KoCoinChipStyle.outlined => (
        s.iconMedium,
        space.s6,
        t.numberCoinLarge.copyWith(color: c.ink),
      ),
      KoCoinChipStyle.compact => (s.icon, space.s6, t.numberCoin),
    };
    final height = compact ? s.chipMedium : s.chip;
    final padding = EdgeInsetsDirectional.only(
      start: space.s6,
      end: pressable ? space.s8 : (compact ? space.s12 : space.s14),
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CoinView(size: coin),
        SizedBox(width: gap),
        Text('$coins', maxLines: 1, style: number),
        if (pressable) ...[
          SizedBox(width: space.s8),
          Container(
            key: const ValueKey('coin-plus'),
            width: s.iconSmall,
            height: s.iconSmall,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.orange, shape: BoxShape.circle),
            child: KoIcon(KoIcons.plus, size: s.iconTiny, color: c.surface),
          ),
        ],
      ],
    );

    final border = raised ? null : c.line;
    final shadow = context.koShadow.coinChip;
    final label = [
      '$coins koin',
      if (pressable) 'tambah koin',
      if (pressable && badge) 'bonus harian siap',
    ].join(', ');
    final Widget chip;
    if (pressable) {
      chip = KoPressable(
        onPressed: onPressed,
        semanticLabel: label,
        color: c.surface,
        // Bayangan `coinChip` = garis padat (turun saat ditekan) + lembut.
        edgeColor: raised ? shadow.first.color : null,
        depth: shadow.first.offset.dy,
        glow: raised ? shadow.skip(1).toList() : const [],
        borderColor: border,
        borderWidth: s.border,
        radius: radius,
        height: height,
        padding: padding,
        child: content,
      );
    } else {
      chip = Semantics(
        container: true,
        liveRegion: true,
        label: label,
        excludeSemantics: true,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(radius),
            border: border == null
                ? null
                : Border.all(color: border, width: s.border),
            boxShadow: raised ? shadow : null,
          ),
          child: content,
        ),
      );
    }
    if (!badge) return chip;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        chip,
        PositionedDirectional(
          top: -space.s2,
          end: -space.s2,
          child: Container(
            key: const ValueKey('coin-badge'),
            width: s.dot + s.border * 2,
            height: s.dot + s.border * 2,
            decoration: BoxDecoration(
              color: c.brick,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: s.border),
            ),
          ),
        ),
      ],
    );
  }
}
