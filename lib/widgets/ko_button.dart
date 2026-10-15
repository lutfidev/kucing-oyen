import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'ko_icon.dart';
import 'ko_pressable.dart';

enum KoButtonKind {
  /// Oranye, bayangan oranye dalam ("Bangunkan Oyen", "Lanjut").
  primary,

  /// Toska ("Lihat hasil").
  success,

  /// Permukaan krem bergaris ("Ulangi", "Lanjut Saja").
  secondary,
}

enum KoButtonSize {
  /// 76 px: "Main" di Beranda.
  hero,

  /// 72 px: "Bangunkan Oyen".
  large,

  /// 64 px: tombol di layar hasil.
  medium,
}

/// Tombol teks dengan bayangan padat yang hilang saat ditekan.
///
/// Selebar isinya, atau selebar induk kalau induk memaksa lebarnya (mis.
/// di dalam `Column` yang `stretch`). Label mengecil kalau tidak muat.
class KoButton extends StatelessWidget {
  const KoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = KoButtonKind.primary,
    this.size = KoButtonSize.medium,
    this.icon,
  });

  final String label;

  /// Null = nonaktif.
  final VoidCallback? onPressed;
  final KoButtonKind kind;
  final KoButtonSize size;
  final KoIconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final radius = context.koRadius;
    final shadow = context.koShadow;
    final s = context.koSize;
    final enabled = onPressed != null;
    final big = size != KoButtonSize.medium;

    final (Color bg, Color fg, Color edge, Color? border) = !enabled
        ? (c.disabled, c.onDisabled, c.muted, null)
        : switch (kind) {
            KoButtonKind.primary => (c.orange, c.ink, c.orangeDeep, null),
            KoButtonKind.success => (
              c.success,
              c.onSuccess,
              c.successDeep,
              null,
            ),
            KoButtonKind.secondary => (c.surface, c.ink, c.lineDeep, c.line),
          };
    final depth = kind == KoButtonKind.secondary
        ? shadow.pressSecondary
        : (big ? shadow.pressHero : shadow.press);
    final glow = !enabled || kind != KoButtonKind.primary
        ? const <BoxShadow>[]
        : switch (size) {
            KoButtonSize.hero => shadow.glowStrong,
            KoButtonSize.large => shadow.glow,
            KoButtonSize.medium => const <BoxShadow>[],
          };
    final style = kind == KoButtonKind.secondary
        ? t.heading
        : switch (size) {
            KoButtonSize.hero => t.buttonHero,
            KoButtonSize.large => t.title,
            KoButtonSize.medium => t.button,
          };
    final (double height, double iconSize) = switch (size) {
      KoButtonSize.hero => (s.buttonHero, s.iconHero),
      KoButtonSize.large => (s.buttonLarge, s.iconLarge),
      KoButtonSize.medium => (s.button, s.icon),
    };
    final gap = big ? space.s12 : space.s8;

    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: bg,
      edgeColor: edge,
      depth: depth,
      borderColor: border,
      borderWidth: s.border,
      radius: big ? radius.primary : radius.button,
      glow: glow,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: space.s24),
      child: Center(
        widthFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              KoIcon(icon!, size: iconSize, color: fg),
              SizedBox(width: gap),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: style.copyWith(color: fg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
