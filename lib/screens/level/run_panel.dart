import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Penghitung langkah di bar atas fase jalan: "Langkah 1" (desain 04).
class StepCounter extends StatelessWidget {
  const StepCounter({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: context.l10n.stepNumber(step),
      excludeSemantics: true,
      child: KoChip.dark(label: context.l10n.step, text: '$step', large: true),
    );
  }
}

/// Status di bawah bar atas fase jalan: vas aman/pecah dan jumlah benda
/// dipakai.
class RunStatus extends StatelessWidget {
  const RunStatus({
    super.key,
    required this.vaseBroken,
    required this.itemsUsed,
  });

  /// Null = tidak ada vas di peta.
  final bool? vaseBroken;
  final int itemsUsed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final broken = vaseBroken;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (broken != null) ...[
            _StatusChip(
              dot: broken ? c.brick : c.success,
              text: broken ? context.l10n.vaseBroken : context.l10n.vaseSafe,
            ),
            SizedBox(width: context.koSpace.s8),
          ],
          _StatusChip(text: context.l10n.itemsUsed(itemsUsed)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, this.dot});

  final String text;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final dot = this.dot;
    return Container(
      height: s.chipSmall,
      padding: EdgeInsets.symmetric(horizontal: space.s12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
        border: Border.all(color: c.line, width: s.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: s.dot,
              height: s.dot,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            SizedBox(width: space.s6),
          ],
          Text(text, maxLines: 1, style: context.koType.labelSmall),
        ],
      ),
    );
  }
}

/// Gaya yang benar-benar dipakai `Text`: [style] di atas [DefaultTextStyle]
/// (mis. tinggi baris tema), supaya ukuran hasil hitung sama dengan layar.
TextStyle _effective(BuildContext context, TextStyle style) =>
    DefaultTextStyle.of(context).style.merge(style);

/// Kotak caption langkah: nomor langkah di lingkaran oranye dan teksnya.
///
/// Tingginya tetap untuk [lines] baris teks, jadi papan tidak berubah ukuran
/// saat caption berganti.
class RunCaption extends StatelessWidget {
  const RunCaption({
    super.key,
    required this.step,
    required this.text,
    this.lines = minLines,
  });

  final int step;
  final String text;

  /// Baris teks yang disiapkan.
  final int lines;

  /// Caption desain 04 paling panjang dua baris.
  static const minLines = 2;

  /// Tinggi kotak untuk [lines] baris teks.
  static double heightFor(BuildContext context, int lines) {
    final space = context.koSpace;
    final s = context.koSize;
    final style = context.koType.paragraph;
    final line =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    return math.max(s.captionBox, lines * line + 2 * (space.s8 + s.border));
  }

  /// Baris terbanyak yang dibutuhkan [captions] di kotak selebar [width]
  /// (paling sedikit [minLines]).
  static int linesFor(
    BuildContext context,
    double width,
    Iterable<String> captions,
  ) {
    final space = context.koSpace;
    final s = context.koSize;
    final t = context.koType;
    final textWidth =
        width - 2 * (s.border + space.s14) - s.stepBadge - space.s10;
    var lines = minLines;
    for (final caption in captions.toSet()) {
      final painter = TextPainter(
        text: TextSpan(text: caption, style: _effective(context, t.paragraph)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: math.max(0, textWidth));
      lines = math.max(lines, painter.computeLineMetrics().length);
      painter.dispose();
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    return Container(
      height: heightFor(context, lines),
      padding: EdgeInsets.symmetric(horizontal: space.s14, vertical: space.s8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(context.koRadius.control),
        border: Border.all(color: c.line, width: s.border),
      ),
      child: Row(
        children: [
          Container(
            width: s.stepBadge,
            height: s.stepBadge,
            decoration: BoxDecoration(color: c.orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$step', maxLines: 1, style: t.numberBadge),
              ),
            ),
          ),
          SizedBox(width: space.s10),
          Expanded(
            child: Text(
              text,
              maxLines: lines,
              overflow: TextOverflow.ellipsis,
              style: t.paragraph,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol putar fase jalan: maju satu langkah, Jeda/Lanjutkan, dan ×2,
/// dengan keterangan tombol tengah di bawahnya.
class RunControls extends StatelessWidget {
  const RunControls({
    super.key,
    required this.playing,
    required this.fast,
    required this.onStepOnce,
    required this.onTogglePlay,
    required this.onToggleFast,
  });

  final bool playing;
  final bool fast;
  final VoidCallback onStepOnce;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFast;

  /// Tinggi tombol dan keterangannya.
  static double heightOf(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: context.l10n.resume,
        style: _effective(context, context.koType.controlLabel),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final label = painter.height;
    painter.dispose();
    return context.koSize.play + context.koSpace.s14 + label;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final label = playing ? l.pause : l.resume;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              semanticLabel: l.stepForward,
              onPressed: onStepOnce,
              child: KoIcon(
                KoIcons.stepForward,
                size: s.iconMedium,
                color: c.ink,
              ),
            ),
            SizedBox(width: space.s16),
            KoPressable(
              onPressed: onTogglePlay,
              semanticLabel: label,
              color: c.orange,
              edgeColor: c.orangeDeep,
              depth: context.koShadow.press,
              circle: true,
              glow: context.koShadow.glowPlay,
              width: s.play,
              height: s.play,
              child: Center(
                child: KoIcon(
                  playing ? KoIcons.pause : KoIcons.resume,
                  size: s.iconPlay,
                  color: c.ink,
                ),
              ),
            ),
            SizedBox(width: space.s16),
            _ControlButton(
              semanticLabel: l.doubleSpeed,
              toggled: fast,
              onPressed: onToggleFast,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'x2',
                  maxLines: 1,
                  style: t.numberSmall.copyWith(color: fast ? c.cream : c.ink),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: space.s14),
        ExcludeSemantics(
          child: Text(
            label,
            maxLines: 1,
            style: t.controlLabel.copyWith(color: c.inkSoft),
          ),
        ),
      ],
    );
  }
}

/// Tombol kotak 56 px. Dengan [toggled] true, tombol jadi gelap (×2 menyala).
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
    this.toggled,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final Widget child;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final dark = toggled ?? false;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      toggled: toggled,
      color: dark ? c.ink : c.surface,
      edgeColor: dark ? c.inkDeep : c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: dark ? c.ink : c.line,
      borderWidth: s.border,
      radius: context.koRadius.control,
      width: s.control,
      height: s.control,
      padding: EdgeInsets.all(context.koSpace.s8),
      child: Center(child: child),
    );
  }
}

/// Tombol "Lihat hasil" setelah langkah terakhir, muncul dengan animasi
/// `koPop` desain 04 (skala 0,85 → 1,06 → 1 dalam 0,4 detik).
class RunDoneButton extends StatelessWidget {
  const RunDoneButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _pop = Duration(milliseconds: 400);

  /// Skala `koPop` di waktu [t] (0..1): tiap potongan keyframe memakai
  /// `ease-out`, seperti `animation-timing-function` CSS.
  static double _scale(double t) {
    const mid = 0.6;
    if (t < mid) {
      return lerpDouble(0.85, 1.06, Curves.easeOut.transform(t / mid))!;
    }
    return lerpDouble(
      1.06,
      1,
      Curves.easeOut.transform((t - mid) / (1 - mid)),
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final button = KoButton(
      label: context.l10n.seeResult,
      kind: KoButtonKind.success,
      onPressed: onPressed,
    );
    if (MediaQuery.disableAnimationsOf(context)) return button;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _pop,
      builder: (context, t, child) =>
          Transform.scale(scale: _scale(t), child: child),
      child: button,
    );
  }
}
