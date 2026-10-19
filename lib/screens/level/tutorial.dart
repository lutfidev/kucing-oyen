import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/game_audio.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Tutorial level pengenalan: Oyen di atas kartu dan bagian layar yang
/// disorot. Teks kartunya per bahasa (`tutorialTitle`, `tutorialBody`).
class Tutorial {
  const Tutorial({required this.levelId, required this.look, this.item});

  /// Level yang memakai tutorial ini; menentukan teks kartunya.
  final int levelId;
  final OyenLook look;

  /// Slot baki yang disorot; null = tombol "Bangunkan Oyen". Tutorial
  /// selesai saat yang disorot dipakai (benda mulai diseret atau Oyen
  /// dibangunkan), atau dilewati.
  final Item? item;
}

/// Tutorial level [levelId]: level 1 (desain 11), level 3 (ikan), dan
/// level 6 (ember). Level lain tidak punya tutorial.
Tutorial? tutorialFor(int levelId) => switch (levelId) {
  1 => const Tutorial(
    levelId: 1,
    look: OyenLook(pose: OyenPose.sleep, bubble: OyenBubble.zzz),
  ),
  3 => const Tutorial(
    levelId: 3,
    look: OyenLook(pose: OyenPose.sleep, bubble: OyenBubble.ikan),
    item: Item.fish,
  ),
  6 => const Tutorial(
    levelId: 6,
    look: OyenLook(pose: OyenPose.shock, bubble: OyenBubble.kaget),
    item: Item.water,
  ),
  _ => null,
};

/// Teks besar kartu tutorial.
String tutorialTitle(AppLocalizations l, Tutorial tutorial) =>
    switch (tutorial.levelId) {
      1 => l.tutorial1Title,
      3 => l.tutorial3Title,
      _ => l.tutorial6Title,
    };

/// Teks kecil kartu tutorial.
String tutorialBody(AppLocalizations l, Tutorial tutorial) =>
    switch (tutorial.levelId) {
      1 => l.tutorial1Body,
      3 => l.tutorial3Body,
      _ => l.tutorial6Body,
    };

/// Overlay tutorial (desain 11): layar digelapkan kecuali [target] yang
/// disorot dengan cincin berdenyut, tangan penunjuk di atasnya, kartu
/// [tutorial] di atas tangan, dan tombol "Lewati" di kanan atas.
///
/// Sentuhan di sorotan diteruskan ke [target]; di luar itu ditahan.
/// Letak [target] diukur sesudah tata letak, jadi kartu dan tangan baru
/// tampil di bingkai berikutnya.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    super.key,
    required this.tutorial,
    required this.target,
    required this.targetRadius,
    required this.onSkip,
    this.costume = OyenCostume.none,
  });

  /// Kostum Oyen dari Lemari Kostum.
  final OyenCostume costume;

  final Tutorial tutorial;
  final GlobalKey target;

  /// Radius sudut [target]; sorotan [KoSpace.s8] lebih besar di tiap sisi
  /// dan radiusnya [KoSpace.s6] lebih besar (desain: tombol 24, sorotan
  /// 30).
  final double targetRadius;
  final VoidCallback onSkip;

  /// Ujung jari tangan penunjuk di tombol lebar, dari kiri tombol (desain:
  /// x 284 di tombol 16–374). Slot baki ditunjuk di tengah.
  static const double buttonHandAt = 0.75;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: RuleArt.ringTime,
  );
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: RuleArt.handBobTime,
  );

  /// Kotak [TutorialOverlay.target] di koordinat overlay.
  Rect? _target;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _ring.reset();
      _tap.reset();
    } else {
      if (!_ring.isAnimating) _ring.repeat();
      if (!_tap.isAnimating) _tap.repeat();
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    _tap.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final target =
        widget.target.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || target == null || !box.hasSize || !target.hasSize) {
      return;
    }
    final rect = MatrixUtils.transformRect(
      target.getTransformTo(box),
      Offset.zero & target.size,
    );
    if (rect != _target) setState(() => _target = rect);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final padding = MediaQuery.paddingOf(context);
    // Diukur ulang sesudah tiap tata letak (juga saat ukuran layar berubah).
    MediaQuery.sizeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    final target = _target;
    final hole = target == null
        ? null
        : RRect.fromRectAndRadius(
            target.inflate(space.s8),
            Radius.circular(widget.targetRadius + space.s6),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final children = <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _SpotlightPainter(
                hole: hole,
                ring: _ring,
                dim: c.scrimDeep,
                ringColor: c.spotlightRing,
              ),
            ),
          ),
        ];
        if (target != null) {
          final at = widget.tutorial.item == null
              ? TutorialOverlay.buttonHandAt
              : 0.5;
          final tip = Offset(
            target.left + target.width * at,
            target.top - RuleArt.handBob,
          );
          final handTop = tip.dy - RuleArt.handTip.dy;
          final side = space.gutter + space.s8;
          final cardTop = padding.top + space.s8;
          children.addAll([
            Positioned(
              left: tip.dx - RuleArt.handTip.dx,
              top: handTop,
              child: IgnorePointer(
                child: CustomPaint(
                  size: RuleArt.hand,
                  painter: _HandPainter(_tap),
                ),
              ),
            ),
            Positioned(
              left: side,
              right: side,
              top: cardTop,
              // Tidak pernah setinggi negatif, juga di layar yang sangat
              // pendek.
              bottom: math.max(
                0,
                constraints.maxHeight - math.max(handTop, cardTop),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: math.max(0, constraints.maxWidth - 2 * side),
                    child: _TutorialCard(
                      widget.tutorial,
                      costume: widget.costume,
                    ),
                  ),
                ),
              ),
            ),
          ]);
        }
        children.add(
          Positioned(
            top: padding.top + space.s8 + (s.iconButton - s.chip) / 2,
            right: space.gutter,
            child: _SkipButton(onPressed: widget.onSkip),
          ),
        );
        return Stack(children: children);
      },
    );
  }
}

/// Oyen di atas kartu teks tutorial.
class _TutorialCard extends StatelessWidget {
  const _TutorialCard(this.tutorial, {required this.costume});

  final Tutorial tutorial;
  final OyenCostume costume;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    return Semantics(
      container: true,
      label: context.l10n.tutorialLabel,
      explicitChildNodes: true,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: s.oyenTutorial - s.oyenTutorialOverlap,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                space.s24,
                space.s32,
                space.s24,
                space.s24,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(context.koRadius.dialog),
                boxShadow: context.koShadow.dialog,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tutorialTitle(context.l10n, tutorial),
                    textAlign: TextAlign.center,
                    style: t.dialogTitle.copyWith(color: c.ink),
                  ),
                  SizedBox(height: space.s6),
                  Text(
                    tutorialBody(context.l10n, tutorial),
                    textAlign: TextAlign.center,
                    style: t.bodySmall.copyWith(color: c.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          ExcludeSemantics(
            child: OyenView(
              tutorial.look.copyWith(costume: costume),
              size: s.oyenTutorial,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol "Lewati" bergaris terang di atas overlay.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Semantics(
      button: true,
      label: context.l10n.skipTutorial,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tapSound(context, onPressed),
        child: Container(
          height: s.chip,
          padding: EdgeInsets.symmetric(horizontal: space.s16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.koRadius.pill),
            border: Border.all(color: c.onScrimLine, width: s.border),
          ),
          child: Text(
            context.l10n.skip,
            maxLines: 1,
            style: context.koType.chipLabel.copyWith(color: c.cream),
          ),
        ),
      ),
    );
  }
}

/// Layar gelap dengan lubang [hole] dan cincin yang melebar dari tepinya.
/// Sentuhan di dalam lubang tidak ditahan.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.ring,
    required this.dim,
    required this.ringColor,
  }) : super(repaint: ring);

  final RRect? hole;
  final Animation<double> ring;
  final Color dim;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final hole = this.hole;
    if (hole == null) {
      canvas.drawPath(screen, Paint()..color = dim);
      return;
    }
    final cut = Path()..addRRect(hole);
    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, cut),
      Paint()..color = dim,
    );
    final t = Curves.easeOut.transform(ring.value);
    if (t == 0) return;
    final outer = Path()..addRRect(hole.inflate(RuleArt.ringSpread * t));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, cut),
      Paint()..color = ringColor.withValues(alpha: ringColor.a * (1 - t)),
    );
  }

  @override
  bool hitTest(Offset position) => !(hole?.contains(position) ?? false);

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.dim != dim || old.ringColor != ringColor;
}

class _HandPainter extends CustomPainter {
  _HandPainter(this.tap) : super(repaint: tap);

  final Animation<double> tap;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, RuleArt.handOffset(tap.value));
    paintTutorialHand(canvas);
  }

  @override
  bool shouldRepaint(_HandPainter old) => old.tap != tap;
}
