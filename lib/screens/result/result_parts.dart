import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../app/game_audio.dart';
import '../../game/model/sounds.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Kerangka layar hasil: latar penuh, isi dari atas, dan tombol di bawah,
/// dengan jarak tepi seperti layar level.
class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.background,
    required this.children,
  });

  final Color background;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return ColoredBox(
      color: background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            space.gutter,
            space.s8,
            space.gutter,
            space.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// "LEVEL 13 · VAS IBU" lalu judul hasil, di tengah.
class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
    required this.kicker,
    required this.title,
    required this.gap,
  });

  /// Ditulis kapital di layar.
  final String kicker;
  final Widget title;

  /// Jarak kicker ke judul.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            kicker.toUpperCase(),
            maxLines: 1,
            style: context.koType.overlineLarge.copyWith(
              color: context.koColors.inkSoft,
            ),
          ),
        ),
        SizedBox(height: gap),
        Semantics(header: true, child: title),
      ],
    );
  }
}

/// Tiga bintang hasil: tengah lebih besar dan lebih tinggi [raise] px.
/// Dengan [pop], bintang yang didapat muncul satu per satu (`koStar` desain
/// 06); bintang yang tidak didapat langsung tampil pudar.
class ResultStars extends StatefulWidget {
  const ResultStars({
    super.key,
    required this.earned,
    required this.size,
    required this.midSize,
    required this.raise,
    required this.strokeWidth,
    this.midStrokeWidth,
    this.shine = false,
    this.pop = false,
    this.afterSound,
  });

  final int earned;
  final double size;
  final double midSize;
  final double raise;

  /// Tebal garis di viewBox 24 (bintang tengah boleh lain).
  final double strokeWidth;
  final double? midStrokeWidth;
  final bool shine;

  /// Bintang muncul satu per satu (`koStar`), masing-masing berbunyi
  /// [GameSound.star]. Tanpa animasi (atau kurangi gerak) bintang langsung
  /// tampil tanpa suara.
  final bool pop;

  /// Suara sesudah bintang terakhir muncul (mis. koin), atau langsung kalau
  /// bintang tidak dianimasikan.
  final GameSound? afterSound;

  static const total = 3;

  /// `koStar`: 0,5 detik per bintang, mulai 0,1 / 0,35 / 0,6 detik.
  static const popTime = Duration(milliseconds: 500);
  static const popDelays = [
    Duration(milliseconds: 100),
    Duration(milliseconds: 350),
    Duration(milliseconds: 600),
  ];

  /// Titik putar `transform-origin: 50% 60%`.
  static const popOrigin = Alignment(0, 0.2);

  /// Skala, putaran (derajat), dan opasitas `koStar` di waktu [t] (0..1):
  /// 0 / -30° / 0 → 1,2 / 6° / 1 di 70% → 1 / 0° / 1, tiap potongan
  /// `ease-out` seperti `animation-timing-function` CSS.
  static (double, double, double) popAt(double t) {
    const mid = 0.7;
    if (t <= 0) return (0, -30, 0);
    if (t >= 1) return (1, 0, 1);
    if (t < mid) {
      final e = Curves.easeOut.transform(t / mid);
      return (lerpDouble(0, 1.2, e)!, lerpDouble(-30, 6, e)!, e);
    }
    final e = Curves.easeOut.transform((t - mid) / (1 - mid));
    return (lerpDouble(1.2, 1, e)!, lerpDouble(6, 0, e)!, 1);
  }

  @override
  State<ResultStars> createState() => _ResultStarsState();
}

class _ResultStarsState extends State<ResultStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration:
        ResultStars.popDelays[math.max(0, widget.earned - 1)] +
        ResultStars.popTime,
  );

  /// Bintang yang suaranya sudah diputar.
  int _starsHeard = 0;
  bool _afterHeard = false;

  @override
  void initState() {
    super.initState();
    _clock
      ..addListener(_playStars)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _playAfter();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = widget.pop && !MediaQuery.disableAnimationsOf(context);
    if (!animate) {
      _starsHeard = widget.earned;
      _clock.value = 1;
      _playAfter();
    } else if (!_clock.isAnimating && _clock.value == 0) {
      _clock.forward();
    }
  }

  void _play(GameSound sound) => AudioScope.maybeRead(context)?.play(sound);

  void _playStars() {
    while (_starsHeard < widget.earned && _progress(_starsHeard) > 0) {
      _starsHeard++;
      _play(GameSound.star);
    }
  }

  void _playAfter() {
    if (_afterHeard) return;
    _afterHeard = true;
    if (widget.afterSound case final sound?) _play(sound);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// Waktu `koStar` bintang ke-[i] (0..1) di posisi jam sekarang.
  double _progress(int i) {
    final total = _clock.duration!.inMicroseconds * _clock.value;
    final start = ResultStars.popDelays[i].inMicroseconds;
    return ((total - start) / ResultStars.popTime.inMicroseconds).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final gap = context.koSpace.s6;
    return Semantics(
      container: true,
      image: true,
      label: context.l10n.starsOf(w.earned, ResultStars.total),
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < ResultStars.total; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Padding(
                padding: EdgeInsets.only(bottom: i == 1 ? w.raise : 0),
                child: _star(i),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _star(int i) {
    final w = widget;
    final mid = i == 1;
    final filled = i < w.earned;
    final star = KoStar(
      filled: filled,
      size: mid ? w.midSize : w.size,
      strokeWidth: mid ? w.midStrokeWidth ?? w.strokeWidth : w.strokeWidth,
      shine: w.shine,
    );
    if (!filled || !w.pop) return star;
    final (scale, degrees, opacity) = ResultStars.popAt(_progress(i));
    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: ResultStars.popOrigin,
        transform: Matrix4.identity()
          ..scaleByDouble(scale, scale, 1, 1)
          ..rotateZ(degrees * math.pi / 180),
        child: star,
      ),
    );
  }
}

/// Kotak angka hasil: "6 langkah", "2 benda dipakai", "+30 koin".
/// [compact] = kotak kecil di layar vas pecah.
class ResultStat extends StatelessWidget {
  const ResultStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.leading,
    this.prefix = '',
    this.compact = false,
  });

  final int value;
  final String label;
  final KoIconData? icon;

  /// Gambar di kiri angka, menggantikan [icon] (koin).
  final Widget? leading;

  /// Di depan angka ("+").
  final String prefix;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final r = context.koRadius;
    final gap = compact ? space.s8 : space.s10;
    final icon = this.icon;
    final leading =
        this.leading ??
        (icon == null
            ? null
            : KoIcon(icon, size: s.iconMedium, color: c.statIcon));
    return Semantics(
      container: true,
      label: '$prefix$value $label',
      excludeSemantics: true,
      child: Container(
        height: compact ? s.statBoxCompact : s.statBox,
        padding: EdgeInsets.symmetric(horizontal: space.s8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(compact ? r.statCompact : r.stat),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading, SizedBox(width: gap)],
                Text(
                  '$prefix$value',
                  maxLines: 1,
                  style: compact ? t.numberCompact : t.number,
                ),
                SizedBox(width: gap),
                Text(
                  label,
                  maxLines: 1,
                  style: t.chipLabel.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kotak angka berdampingan dengan jarak 12.
class ResultStats extends StatelessWidget {
  const ResultStats({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: context.koSpace.s12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// Satu syarat bintang di [ResultRules].
class ResultRule {
  const ResultRule({
    required this.text,
    required this.status,
    this.stars,
    this.statusColor,
  });

  final String text;

  /// Teks di kanan ("Dapat", "Pecah di langkah 2", "Belum"); null =
  /// centang tercapai.
  final String? status;
  final Color? statusColor;

  /// Bintang di kiri teks (layar Berhasil); null = tanpa bintang.
  final int? stars;
}

/// Daftar syarat bintang dengan garis putus-putus antarbaris.
class ResultRules extends StatelessWidget {
  const ResultRules({super.key, required this.rules, required this.padding});

  final List<ResultRule> rules;

  /// Jarak atas-bawah daftar (desain 06: 6, desain 07: 4).
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: space.s16, vertical: padding),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(context.koRadius.card),
        border: Border.all(color: c.line, width: s.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) const _DashedLine(),
            _RuleRow(rules[i]),
          ],
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow(this.rule);

  final ResultRule rule;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final stars = rule.stars;
    final status = rule.status;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: s.ruleRow),
        child: Row(
          children: [
            if (stars != null) ...[
              SizedBox(
                width: ResultStars.total * s.starSmall,
                child: Row(
                  children: [
                    for (var i = 0; i < stars; i++)
                      KoStar(
                        size: s.starSmall,
                        strokeWidth: ResultArt.ruleStarStroke,
                      ),
                  ],
                ),
              ),
              SizedBox(width: space.s10),
            ],
            Expanded(child: Text(rule.text, style: t.body)),
            SizedBox(width: space.s10),
            if (status == null)
              Semantics(
                label: context.l10n.goalAchieved,
                child: Container(
                  width: s.checkBadge,
                  height: s.checkBadge,
                  decoration: BoxDecoration(
                    color: c.success,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: KoIcon(
                    KoIcons.check,
                    size: s.iconTiny,
                    color: c.onSuccess,
                  ),
                ),
              )
            else
              Text(
                status,
                style: t.labelSmall.copyWith(
                  color: rule.statusColor ?? c.inkSoft,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Garis putus-putus selebar baris (CSS `border-bottom: 1.5px dashed`).
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    return CustomPaint(
      size: Size.fromHeight(s.divider),
      painter: _DashedLinePainter(
        color: context.koColors.line,
        width: s.divider,
        dash: s.dash,
        gap: s.dashGap,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.width,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double width;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final line = Path()
      ..moveTo(0, y)
      ..lineTo(size.width, y);
    canvas.drawPath(
      dashPath(line, dashArray: CircularIntervalList([dash, gap])),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) =>
      old.color != color ||
      old.width != width ||
      old.dash != dash ||
      old.gap != gap;
}

/// Dua tombol berdampingan dengan jarak 12, lebarnya [flex] banding.
class ResultButtons extends StatelessWidget {
  const ResultButtons({
    super.key,
    required this.first,
    required this.second,
    this.flex = (1, 1),
  });

  final Widget first;
  final Widget second;
  final (int, int) flex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: flex.$1, child: first),
        SizedBox(width: context.koSpace.s12),
        Expanded(flex: flex.$2, child: second),
      ],
    );
  }
}

/// Tempat kartu ilustrasi: kartu seukuran [size] mengecil kalau tempatnya
/// kurang, dan disembunyikan kalau skalanya di bawah [KoSize.artMinScale].
class ResultArtSlot extends StatelessWidget {
  const ResultArtSlot({super.key, required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final minScale = context.koSize.artMinScale;
    return LayoutBuilder(
      builder: (context, box) {
        final scale = math.min(
          box.maxWidth / size.width,
          box.maxHeight / size.height,
        );
        if (scale < minScale) return const SizedBox.shrink();
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox.fromSize(size: size, child: child),
          ),
        );
      },
    );
  }
}
