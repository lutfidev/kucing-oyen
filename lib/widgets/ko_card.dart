import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'ko_dashed_border.dart';

/// Kartu: permukaan krem, garis 2 px, sudut 20.
///
/// [locked] = kartu yang belum terbuka (latar pudar, garis putus-putus),
/// [elevated] = dengan bayangan lembut "card".
class KoCard extends StatelessWidget {
  const KoCard({
    super.key,
    required this.child,
    this.padding,
    this.locked = false,
    this.elevated = false,
    this.borderColor,
  });

  final Widget child;

  /// Default [KoSpace.s12] di semua sisi.
  final EdgeInsetsGeometry? padding;
  final bool locked;
  final bool elevated;

  /// Warna garis kartu terbuka; default [KoColors.line].
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final radius = context.koRadius.card;
    final inner = Padding(
      padding: padding ?? EdgeInsets.all(context.koSpace.s12),
      child: child,
    );
    final shadows = elevated ? context.koShadow.card : null;

    if (locked) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: c.locked,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: KoDashedBorder(color: c.muted, radius: radius, child: inner),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? c.line,
          width: context.koSize.border,
        ),
        boxShadow: shadows,
      ),
      child: Padding(
        // Ruang garis, supaya isi tidak menimpa border.
        padding: EdgeInsets.all(context.koSize.border),
        child: inner,
      ),
    );
  }
}
