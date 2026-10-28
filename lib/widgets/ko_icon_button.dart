import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'ko_icon.dart';
import 'ko_pressable.dart';

enum KoIconButtonTone {
  /// Permukaan krem bergaris dengan bayangan padat (kembali, Aturan).
  surface,

  /// Seperti [surface] tanpa bayangan (tutup sheet).
  flat,

  /// Warna lantai tanpa bayangan (kosongkan papan di baki).
  floor,

  /// Kuning (petunjuk); bulat kalau tanpa label.
  hint,
}

/// Tombol ikon 44 px. Dengan [label], tombol melebar berisi ikon + teks
/// (tombol "Aturan" di bar atas).
class KoIconButton extends StatelessWidget {
  const KoIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.tone = KoIconButtonTone.surface,
    this.label,
    this.iconSize,
    this.silent = false,
  });

  final KoIconData icon;
  final String semanticLabel;

  /// Null = nonaktif.
  final VoidCallback? onPressed;
  final KoIconButtonTone tone;
  final String? label;

  /// Default [KoSize.icon], atau [KoSize.iconSmall] kalau ada [label].
  final double? iconSize;

  /// Lihat [KoPressable.silent].
  final bool silent;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final (Color bg, Color line, Color? edge) = switch (tone) {
      KoIconButtonTone.surface => (c.surface, c.line, c.lineDeep),
      KoIconButtonTone.flat => (c.surface, c.line, null),
      KoIconButtonTone.floor => (c.floor, c.lineDeep, null),
      KoIconButtonTone.hint => (c.hint, c.hintLine, c.hintDeep),
    };
    final text = label;
    final glyph = KoIcon(
      icon,
      size: iconSize ?? (text == null ? s.icon : s.iconSmall),
      color: c.ink,
    );

    return KoPressable(
      onPressed: onPressed,
      silent: silent,
      semanticLabel: semanticLabel,
      color: bg,
      edgeColor: edge,
      depth: context.koShadow.pressIcon,
      borderColor: line,
      borderWidth: s.border,
      radius: context.koRadius.icon,
      circle: tone == KoIconButtonTone.hint && text == null,
      width: text == null ? s.iconButton : null,
      height: s.iconButton,
      padding: text == null
          ? null
          : EdgeInsetsDirectional.only(start: space.s10, end: space.s14),
      child: text == null
          ? Center(child: glyph)
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  glyph,
                  SizedBox(width: space.s6),
                  Text(
                    text,
                    maxLines: 1,
                    style: context.koType.label.copyWith(color: c.ink),
                  ),
                ],
              ),
            ),
    );
  }
}
