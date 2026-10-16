import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Sinar berputar di belakang layar Berhasil, berpusat di (0, 0) kotaknya
/// sendiri: taruh lewat `Positioned` dengan ukuran 0. Sinar digambar sekali
/// di lapisannya sendiri lalu hanya diputar. Diam di sudut awal kalau
/// animasi dimatikan.
class ResultRays extends StatefulWidget {
  const ResultRays({super.key});

  @override
  State<ResultRays> createState() => _ResultRaysState();
}

class _ResultRaysState extends State<ResultRays>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: ResultArt.raysTurn,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _turn.value = 0;
    } else if (!_turn.isAnimating) {
      _turn.repeat();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RotationTransition(
        turns: _turn,
        child: const RepaintBoundary(
          child: CustomPaint(painter: _RaysPainter()),
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  @override
  void paint(Canvas canvas, Size size) => paintRays(canvas);

  @override
  bool shouldRepaint(_RaysPainter old) => false;
}

/// Kartu ilustrasi layar hasil seukuran [size]: lantai kotak-kotak (pola
/// 2×2 selebar [pattern]), garis dalam, sudut 28, lalu [children] di atasnya
/// dengan koordinat desain.
class ResultArtCard extends StatelessWidget {
  const ResultArtCard({
    super.key,
    required this.size,
    required this.pattern,
    required this.children,
  });

  final Size size;
  final double pattern;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.koRadius.art),
      child: CustomPaint(
        painter: _FloorPainter(
          floor: c.floor,
          floorAlt: c.floorAlt,
          pattern: pattern,
          line: c.line,
          lineWidth: context.koSize.artBorder,
          radius: context.koRadius.art,
        ),
        child: SizedBox.fromSize(
          size: size,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }
}

/// `conic-gradient(floorAlt 25%, transparent 0 50%, floorAlt 0 75%,
/// transparent 0)` di atas [floor], lalu `box-shadow: inset 0 0 0 3px`.
class _FloorPainter extends CustomPainter {
  _FloorPainter({
    required this.floor,
    required this.floorAlt,
    required this.pattern,
    required this.line,
    required this.lineWidth,
    required this.radius,
  });

  final Color floor;
  final Color floorAlt;
  final double pattern;
  final Color line;
  final double lineWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = floor);
    // Kerucut mulai dari atas searah jarum jam: kuadran kanan atas dan kiri
    // bawah tiap pola berwarna.
    final half = pattern / 2;
    final alt = Paint()..color = floorAlt;
    for (var y = 0.0; y < size.height; y += pattern) {
      for (var x = 0.0; x < size.width; x += pattern) {
        canvas
          ..drawRect(Rect.fromLTWH(x + half, y, half, half), alt)
          ..drawRect(Rect.fromLTWH(x, y + half, half, half), alt);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(lineWidth / 2),
        Radius.circular(radius - lineWidth / 2),
      ),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );
  }

  @override
  bool shouldRepaint(_FloorPainter old) =>
      old.floor != floor ||
      old.floorAlt != floorAlt ||
      old.pattern != pattern ||
      old.line != line ||
      old.lineWidth != lineWidth ||
      old.radius != radius;
}

/// Mangkuk berisi pakan, viewBox [ResultArt.bowlViewBox] diperkecil ke
/// kotaknya (`preserveAspectRatio` bawaan: `xMidYMid meet`). Hiasan saja.
class _Bowl extends StatelessWidget {
  const _Bowl({required this.vase});

  final bool vase;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FittedBox(
        child: CustomPaint(
          size: ResultArt.bowlViewBox,
          painter: _BowlPainter(vase: vase),
        ),
      ),
    );
  }
}

class _BowlPainter extends CustomPainter {
  _BowlPainter({required this.vase});

  final bool vase;

  @override
  void paint(Canvas canvas, Size size) =>
      vase ? paintVaseBowl(canvas) : paintSuccessBowl(canvas);

  @override
  bool shouldRepaint(_BowlPainter old) => old.vase != vase;
}

/// Ilustrasi layar Berhasil: Oyen makan dengan bahagia di mangkuknya.
class SuccessArt extends StatelessWidget {
  const SuccessArt({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultArtCard(
      size: ResultArt.successCard,
      pattern: ResultArt.successPattern,
      children: [
        Positioned.fromRect(
          rect: ResultArt.successOyen,
          child: OyenView(
            const OyenLook(pose: OyenPose.eat, dir: Direction.down),
            size: ResultArt.successOyen.width,
          ),
        ),
        Positioned.fromRect(
          rect: ResultArt.successBowl,
          child: const _Bowl(vase: false),
        ),
      ],
    );
  }
}

/// Ilustrasi layar vas pecah: vas pecah di belakang Oyen, Ibu muncul dari
/// pintu (`koPeek`), dan "PRANG!" bergoyang (`koShake`). Diam di keadaan
/// akhir kalau animasi dimatikan.
class VaseArt extends StatefulWidget {
  const VaseArt({super.key});

  /// Label pembaca layar, sama dengan `aria-label` di desain.
  static const label =
      'Vas pecah di belakang Oyen, Ibu muncul dari pintu dengan wajah kesal';

  /// Sudut "PRANG!" di waktu [t] (0..1) satu goyangan: -4° → 4° → -4°,
  /// tiap potongan `ease-in-out`.
  static double swingAt(double t) {
    const swing = ResultArt.prangSwing;
    if (t < 0.5) {
      return lerpDouble(-swing, swing, Curves.easeInOut.transform(t / 0.5))!;
    }
    return lerpDouble(
      swing,
      -swing,
      Curves.easeInOut.transform((t - 0.5) / 0.5),
    )!;
  }

  @override
  State<VaseArt> createState() => _VaseArtState();
}

class _VaseArtState extends State<VaseArt> with TickerProviderStateMixin {
  late final AnimationController _peek = AnimationController(
    vsync: this,
    duration: ResultArt.momPeekTime,
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: ResultArt.prangSwingTime,
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _peek.value = 1;
      _shake.stop();
    } else {
      if (_peek.value == 0) _peek.forward();
      if (!_shake.isAnimating) _shake.repeat();
    }
  }

  @override
  void dispose() {
    _peek.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: VaseArt.label,
      excludeSemantics: true,
      child: ResultArtCard(
        size: ResultArt.vaseCard,
        pattern: ResultArt.vasePattern,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _VaseScenePainter(
                peek: _peek,
                shake: _shake,
                still: _still,
              ),
            ),
          ),
          Positioned.fromRect(
            rect: ResultArt.vaseOyen,
            child: OyenView(
              const OyenLook(pose: OyenPose.eat, dir: Direction.down),
              size: ResultArt.vaseOyen.width,
            ),
          ),
          Positioned.fromRect(
            rect: ResultArt.vaseBowl,
            child: const _Bowl(vase: true),
          ),
        ],
      ),
    );
  }
}

class _VaseScenePainter extends CustomPainter {
  _VaseScenePainter({
    required this.peek,
    required this.shake,
    required this.still,
  }) : super(repaint: Listenable.merge([peek, shake]));

  final Animation<double> peek;
  final Animation<double> shake;

  /// Tanpa animasi: "PRANG!" tegak.
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    paintVaseScene(
      canvas,
      momShift: ResultArt.momPeek * (1 - Curves.easeOut.transform(peek.value)),
      prangAngle: still ? 0 : VaseArt.swingAt(shake.value),
    );
  }

  @override
  bool shouldRepaint(_VaseScenePainter old) =>
      old.peek != peek || old.shake != shake || old.still != still;
}

/// Papan layar gagal (desain 08): papan [scene] yang sedikit pudar
/// (`saturate(0.7)`), mengisi kotak rasio 350×450 terbesar yang muat, dengan
/// [badge] di pojok kanan atasnya.
class RestBoard extends StatelessWidget {
  const RestBoard({super.key, required this.scene, required this.badge});

  final BoardScene scene;
  final Widget badge;

  /// Matriks `saturate()` CSS (Filter Effects, `feColorMatrix`).
  static List<double> saturation(double s) => [
    0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0, //
    0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0, //
    0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final ring = context.koShadow.board.first.spreadRadius;
    final space = context.koSpace;
    return LayoutBuilder(
      builder: (context, box) {
        // BoardView hanya mengecil, tidak membesar melewati 350×450.
        final scale = math.max(
          0.0,
          math.min(
            1.0,
            math.min(
              (box.maxWidth - 2 * ring) / BoardScene.width,
              (box.maxHeight - 2 * ring) / BoardScene.height,
            ),
          ),
        );
        return Center(
          child: SizedBox(
            width: BoardScene.width * scale,
            height: BoardScene.height * scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      saturation(context.koSize.dimSaturation),
                    ),
                    child: BoardView(scene),
                  ),
                ),
                // Chip mengecil kalau papannya lebih sempit dari chip.
                Positioned(
                  top: space.s14,
                  right: space.s16,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(
                        0,
                        BoardScene.width * scale - 2 * space.s16,
                      ),
                    ),
                    child: FittedBox(fit: BoxFit.scaleDown, child: badge),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Chip gelap di atas papan layar gagal: "Muter terus".
class RestBadge extends StatelessWidget {
  const RestBadge({super.key, required this.icon, required this.text});

  final KoIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return Container(
      height: s.chipCompact,
      padding: EdgeInsets.symmetric(horizontal: context.koSpace.s12),
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(icon, size: s.iconChip, color: c.cream),
          SizedBox(width: context.koSpace.s6),
          Text(
            text,
            maxLines: 1,
            style: context.koType.labelSmall.copyWith(color: c.cream),
          ),
        ],
      ),
    );
  }
}
