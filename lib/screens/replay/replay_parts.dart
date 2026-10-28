import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Gaya yang benar-benar dipakai `Text`: [style] di atas [DefaultTextStyle],
/// supaya ukuran hasil hitung sama dengan layar.
TextStyle _effective(BuildContext context, TextStyle style) =>
    DefaultTextStyle.of(context).style.merge(style);

/// Ukuran [text] dengan [style] di skala teks layar.
Size _textSize(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: _effective(context, style)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final size = painter.size;
  painter.dispose();
  return size;
}

/// Nomor langkah di caption dan pembaca layar: "Awal" untuk langkah 0.
String replayStepLabel(AppLocalizations l, int step) =>
    step == 0 ? l.replayStart : '$step';

/// Bar atas putar ulang: kembali ke hasil, "LEVEL 13 · VAS IBU" di atas
/// judul "Putar Ulang", dan chip "Rekaman".
class ReplayBar extends StatelessWidget {
  const ReplayBar({super.key, required this.kicker, required this.onBack});

  /// "Level 13 · Vas Ibu" (ditulis kapital).
  final String kicker;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    return SizedBox(
      height: context.koSize.iconButton,
      child: Row(
        children: [
          KoIconButton(
            icon: KoIcons.back,
            semanticLabel: context.l10n.backToResult,
            onPressed: onBack,
          ),
          SizedBox(width: space.s10),
          Expanded(
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kicker.toUpperCase(),
                      maxLines: 1,
                      style: t.overline.copyWith(color: c.inkSoft),
                    ),
                    Text(
                      context.l10n.replay,
                      maxLines: 1,
                      style: t.headingLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: space.s10),
          const RecordChip(),
        ],
      ),
    );
  }
}

/// Chip gelap "Rekaman" dengan titik oranye.
class RecordChip extends StatelessWidget {
  const RecordChip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Container(
      height: s.chipMedium,
      padding: EdgeInsets.symmetric(horizontal: space.s12),
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: s.dotSmall,
            height: s.dotSmall,
            decoration: BoxDecoration(color: c.orange, shape: BoxShape.circle),
          ),
          SizedBox(width: space.s6),
          Text(
            context.l10n.recording,
            maxLines: 1,
            style: context.koType.labelSmall.copyWith(color: c.cream),
          ),
        ],
      ),
    );
  }
}

/// Papan putar ulang: mengisi kotak rasio 350×450 terbesar yang muat
/// (bingkai ikut dihitung), seperti papan level. Saat langkah berganti,
/// Oyen digeser ke petak barunya selama [moveTime] dengan kurva `ease`
/// (transisi `left`/`top` di `Board.dc.html`).
class ReplayBoard extends StatelessWidget {
  const ReplayBoard({super.key, required this.scene});

  final BoardScene scene;

  /// Transisi posisi Oyen di desain: 0,35 detik.
  static const moveTime = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final ring = context.koShadow.board.first.spreadRadius;
    final oyen = scene.oyen;
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.max(
          0.0,
          math.min(
            (constraints.maxWidth - 2 * ring) / BoardScene.width,
            (constraints.maxHeight - 2 * ring) / BoardScene.height,
          ),
        );
        return Center(
          child: Semantics(
            image: true,
            label: context.l10n.boardLabel,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(
                end: oyen == null ? Offset.zero : Offset(oyen.col, oyen.row),
              ),
              duration: still ? Duration.zero : moveTime,
              curve: Curves.ease,
              builder: (context, at, _) => CustomPaint(
                size: Size(BoardScene.width, BoardScene.height) * scale,
                painter: _BoardPainter(scene, at, scale),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.scene, this.oyenAt, this.scale);

  final BoardScene scene;
  final Offset oyenAt;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    paintBoardFrame(canvas);
    paintBoard(canvas, scene, oyenAt: oyenAt);
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.scene != scene || old.oyenAt != oyenAt || old.scale != scale;
}

/// Kotak caption putar ulang: nomor langkah ("Awal" di langkah 0) di pill
/// gelap dan teksnya. Tingginya tetap untuk [lines] baris supaya papan
/// tidak berubah ukuran saat caption berganti.
class ReplayCaption extends StatelessWidget {
  const ReplayCaption({
    super.key,
    required this.step,
    required this.text,
    required this.lines,
    this.announce = true,
  });

  final int step;
  final String text;
  final int lines;

  /// Dibacakan pembaca layar tiap berganti. False selama putar otomatis
  /// supaya caption tidak saling memotong.
  final bool announce;

  /// Caption desain 09 paling panjang satu baris; disiapkan dua seperti
  /// fase jalan.
  static const minLines = 2;

  /// Tinggi kotak untuk [lines] baris teks.
  static double heightFor(BuildContext context, int lines) {
    final space = context.koSpace;
    final s = context.koSize;
    final style = context.koType.paragraphSmall;
    final line =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    return math.max(
      s.captionBoxSmall,
      lines * line + 2 * (space.s6 + s.border),
    );
  }

  /// Baris terbanyak yang dibutuhkan [captions] di kotak selebar [width],
  /// dengan pill nomor selebar nomor terpanjang ("Awal" atau langkah
  /// terakhir).
  static int linesFor(
    BuildContext context,
    double width,
    List<String> captions,
  ) {
    final space = context.koSpace;
    final s = context.koSize;
    final t = context.koType;
    final badge = math.max(
      s.stepBadge,
      2 * space.s8 +
          [
                replayStepLabel(context.l10n, 0),
                replayStepLabel(context.l10n, captions.length - 1),
              ]
              .map((label) => _textSize(context, label, t.numberBadge).width)
              .reduce(math.max),
    );
    final textWidth = width - 2 * (s.border + space.s14) - badge - space.s10;
    var lines = minLines;
    for (final caption in captions.toSet()) {
      final painter = TextPainter(
        text: TextSpan(
          text: caption,
          style: _effective(context, t.paragraphSmall),
        ),
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
    final l = context.l10n;
    final label = replayStepLabel(l, step);
    return Semantics(
      container: true,
      liveRegion: announce,
      label: step == 0 ? text : l.replayStepCaption(step, text),
      excludeSemantics: true,
      child: Container(
        height: heightFor(context, lines),
        padding: EdgeInsets.symmetric(
          horizontal: space.s14,
          vertical: space.s6,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.slot),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          children: [
            Container(
              constraints: BoxConstraints(minWidth: s.stepBadge),
              height: s.stepBadge,
              padding: EdgeInsets.symmetric(horizontal: space.s8),
              decoration: BoxDecoration(
                color: c.ink,
                borderRadius: BorderRadius.circular(context.koRadius.pill),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                style: t.numberBadge.copyWith(color: c.cream),
              ),
            ),
            SizedBox(width: space.s10),
            Expanded(
              child: Text(
                text,
                maxLines: lines,
                overflow: TextOverflow.ellipsis,
                style: t.paragraphSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slider "Waktu" dari langkah 0 sampai [max] dengan angka langkah di
/// bawahnya (`input type=range` desain 09). Digeser atau diketuk.
class ReplaySlider extends StatelessWidget {
  const ReplaySlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  /// Angka di bawah slider. Desain menulis setiap langkah (0–6); kalau
  /// tidak muat, kelipatan 2, 5, 10, ... dan langkah terakhir. Jarak antar
  /// angka paling sedikit [spacing] di jalur selebar [trackWidth].
  static List<int> ticks(int max, double trackWidth, double spacing) {
    if (max <= 0) return const [0];
    final unit = trackWidth / max;
    const steps = [1, 2, 5, 10, 20, 50];
    final every = steps.firstWhere(
      (k) => k * unit >= spacing,
      orElse: () => steps.last,
    );
    final ticks = [for (var i = 0; i <= max; i += every) i];
    if (ticks.last != max) {
      if (ticks.length > 1 && (max - ticks.last) * unit < spacing) {
        ticks.removeLast();
      }
      ticks.add(max);
    }
    return ticks;
  }

  String _valueOf(AppLocalizations l, int step) =>
      step == 0 ? replayStepLabel(l, 0) : l.stepNumber(step);

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final radius = s.sliderThumb / 2;
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final track = math.max(0.0, width - 2 * radius);
        double xOf(int step) => radius + (max == 0 ? 0 : step / max * track);
        void seek(Offset local) {
          if (max == 0 || track == 0) return;
          final step = ((local.dx - radius) / track * max).round().clamp(
            0,
            max,
          );
          if (step != value) onChanged(step);
        }

        final tick = t.numberTick.copyWith(color: c.inkSoft);
        final tickSize = _textSize(context, '$max', tick);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Text(
                l.timeline.toUpperCase(),
                maxLines: 1,
                style: t.overline.copyWith(color: c.inkSoft),
              ),
            ),
            SizedBox(height: space.s4),
            Semantics(
              slider: true,
              label: l.timeline,
              value: _valueOf(l, value),
              increasedValue: value < max ? _valueOf(l, value + 1) : null,
              decreasedValue: value > 0 ? _valueOf(l, value - 1) : null,
              onIncrease: value < max ? () => onChanged(value + 1) : null,
              onDecrease: value > 0 ? () => onChanged(value - 1) : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => seek(details.localPosition),
                onHorizontalDragStart: (details) => seek(details.localPosition),
                onHorizontalDragUpdate: (details) =>
                    seek(details.localPosition),
                child: CustomPaint(
                  size: Size(width, s.slider),
                  painter: _SliderPainter(
                    x: xOf(value),
                    radius: radius,
                    trackHeight: s.sliderTrack,
                    active: c.orangeLine,
                    inactive: c.line,
                  ),
                ),
              ),
            ),
            SizedBox(height: space.s4),
            ExcludeSemantics(
              child: SizedBox(
                height: tickSize.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tiap angka di tengah posisi pegangan untuk langkah itu.
                    for (final step in ticks(
                      max,
                      track,
                      tickSize.width + space.s16,
                    ))
                      Positioned(
                        left: xOf(step),
                        top: 0,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: Text('$step', maxLines: 1, style: tick),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.x,
    required this.radius,
    required this.trackHeight,
    required this.active,
    required this.inactive,
  });

  /// Tengah pegangan.
  final double x;
  final double radius;
  final double trackHeight;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    Paint line(Color color) => Paint()
      ..color = color
      ..strokeWidth = trackHeight
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(radius, y),
        Offset(size.width - radius, y),
        line(inactive),
      )
      ..drawLine(Offset(radius, y), Offset(x, y), line(active))
      ..drawCircle(Offset(x, y), radius, Paint()..color = active);
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.x != x ||
      old.radius != radius ||
      old.trackHeight != trackHeight ||
      old.active != active ||
      old.inactive != inactive;
}

/// Tombol bawah putar ulang: mundur satu langkah, "Kembali ke peta", dan
/// maju satu langkah. Mundur/maju nonaktif di ujung.
class ReplayControls extends StatelessWidget {
  const ReplayControls({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onMap,
  });

  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Row(
      children: [
        _StepButton(
          icon: KoIcons.stepBack,
          semanticLabel: context.l10n.stepBack,
          onPressed: onPrev,
        ),
        SizedBox(width: space.s12),
        Expanded(
          child: KoButton(label: context.l10n.backToMap, onPressed: onMap),
        ),
        SizedBox(width: space.s12),
        _StepButton(
          icon: KoIcons.stepForward,
          semanticLabel: context.l10n.stepForward,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Tombol bulat oranye putar otomatis/jeda di kiri slider, gaya tombol main
/// fase jalan (desain 04) seukuran tombol kontrol.
class ReplayPlayButton extends StatelessWidget {
  const ReplayPlayButton({
    super.key,
    required this.playing,
    required this.onPressed,
  });

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final l = context.l10n;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: playing ? l.pause : l.replayPlay,
      color: c.orange,
      edgeColor: c.orangeDeep,
      depth: context.koShadow.press,
      circle: true,
      width: s.control,
      height: s.control,
      child: Center(
        child: KoIcon(
          playing ? KoIcons.pause : KoIcons.resume,
          size: s.iconMedium,
          color: c.ink,
        ),
      ),
    );
  }
}

/// Tombol kotak 64 px bergaris dengan ikon 24 px.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final KoIconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.button,
      width: s.button,
      height: s.button,
      child: Center(
        child: KoIcon(icon, size: s.iconMedium, color: c.ink),
      ),
    );
  }
}
