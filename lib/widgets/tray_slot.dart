import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'ko_dashed_border.dart';

/// Slot baki 64 px berisi gambar satu jenis benda dan badge angka sisa.
///
/// Kalau [count] 0 (benda habis atau sedang diseret), slot jadi garis
/// putus-putus oranye dan [child] tampil pudar sebagai bayangan.
class TraySlot extends StatelessWidget {
  const TraySlot({
    super.key,
    required this.count,
    required this.semanticLabel,
    this.child,
  });

  final int count;

  /// Mis. "Ikan asin, sisa 1".
  final String semanticLabel;

  /// Gambar benda; diberi ruang [KoSize.slotItem] persegi.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final radius = context.koRadius.slot;
    final empty = count == 0;
    final art = child;

    final Widget slot = empty
        ? KoDashedBorder(
            color: c.orangeLine,
            radius: radius,
            child: SizedBox.square(
              dimension: s.slot - 2 * s.border,
              child: art == null
                  ? null
                  : Center(
                      child: Opacity(
                        opacity: s.ghostOpacity,
                        child: SizedBox.square(
                          dimension: s.slotGhost,
                          child: art,
                        ),
                      ),
                    ),
            ),
          )
        : Container(
            width: s.slot,
            height: s.slot,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.floor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: c.lineDeep, width: s.border),
              boxShadow: KoShadow.solid(c.lineDeep, context.koShadow.pressIcon),
            ),
            child: art == null
                ? null
                : SizedBox.square(dimension: s.slotItem, child: art),
          );

    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          slot,
          PositionedDirectional(
            end: -s.badgeInset,
            top: -s.badgeInset,
            child: _Badge(count: count),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final empty = count == 0;
    return Container(
      constraints: BoxConstraints(minWidth: s.badge),
      height: s.badge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? c.muted : c.ink,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
        boxShadow: context.koShadow.badgeRing,
      ),
      child: Text(
        '$count',
        maxLines: 1,
        style: context.koType.badge.copyWith(color: empty ? c.ink : c.cream),
      ),
    );
  }
}
