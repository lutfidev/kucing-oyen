import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Chip setinggi 40 px.
///
/// - [KoChip.new]: pill krem bergaris, angka Fredoka, ikon opsional di depan
///   ("★ 14/60").
/// - [KoChip.dark]: kotak tinta gelap, label kecil + angka ("Langkah 1").
class KoChip extends StatelessWidget {
  const KoChip({super.key, required this.text, this.leading})
    : label = null,
      dark = false;

  const KoChip.dark({super.key, required String this.label, required this.text})
    : leading = null,
      dark = true;

  /// Angka atau teks utama.
  final String text;

  /// Ikon di depan (chip krem).
  final Widget? leading;

  /// Label di depan angka (chip gelap).
  final String? label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final fg = dark ? c.cream : c.ink;
    final prefix = label;

    return MergeSemantics(
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(
          start: leading == null ? space.s14 : space.s8,
          end: space.s14,
        ),
        decoration: BoxDecoration(
          color: dark ? c.ink : c.cream,
          borderRadius: BorderRadius.circular(
            dark ? context.koRadius.icon : context.koRadius.pill,
          ),
          border: dark ? null : Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: space.s6)],
            if (prefix != null) ...[
              Text(prefix, style: t.labelSmall.copyWith(color: fg)),
              SizedBox(width: space.s6),
            ],
            Text(
              text,
              style: (dark ? t.numberSmall : t.chip).copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
