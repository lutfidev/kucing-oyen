import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../theme/ko_ui.dart';
import '../../model/rules.dart';
import '../../sim/sim.dart';
import '../oyen.dart';
import 'puzzle_art.dart';

/// The same rig and object drawings as the playable board.
class GuidanceCat extends StatelessWidget {
  const GuidanceCat({super.key, required this.look, required this.size});
  final OyenLook look;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _Cat(look)),
  );
}

class _Cat extends CustomPainter {
  const _Cat(this.look);
  final OyenLook look;
  @override
  void paint(Canvas canvas, Size size) =>
      paintPuzzleOyen(canvas, look, size: size.width);
  @override
  bool shouldRepaint(_Cat old) => old.look != look;
}

class GuidanceRuleArt extends StatelessWidget {
  const GuidanceRuleArt({
    super.key,
    required this.rule,
    required this.learned,
    this.turn,
  });
  final OyenRule rule;
  final bool learned;
  final Animation<double>? turn;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: const Size.square(76),
      painter: _Rule(rule, learned, turn),
    ),
  );
}

class _Rule extends CustomPainter {
  _Rule(this.rule, this.learned, this.turn) : super(repaint: turn);
  final OyenRule rule;
  final bool learned;
  final Animation<double>? turn;
  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.scale(size.width / 100);
    PuzzleArt.box(c, const Rect.fromLTWH(2, 2, 96, 96), KoUi.cream, radius: 18);
    if (!learned) {
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(31, 43, 38, 30),
        KoUi.homeLine,
        radius: 6,
      );
      c.drawArc(
        const Rect.fromLTWH(37, 25, 26, 34),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = KoUi.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    } else {
      c.save();
      c.translate(1, 25);
      c.scale(.58);
      paintPuzzleOyen(
        c,
        OyenLook(
          pose: rule == OyenRule.box ? OyenPose.box : OyenPose.idle,
          dir: rule == OyenRule.wall && (turn?.value ?? 0) >= .5
              ? Direction.down
              : Direction.right,
        ),
        size: 100,
      );
      c.restore();
      c.save();
      c.translate(56, 21);
      c.scale(.8);
      switch (rule) {
        case OyenRule.fish:
          paintPuzzleItem(c, Item.fish, player: false);
        case OyenRule.water:
          paintPuzzleItem(c, Item.water, player: false);
        case OyenRule.box:
          paintPuzzleItem(c, Item.box, player: false);
        case OyenRule.knock:
          PuzzleArt.box(c, const Rect.fromLTWH(0, 30, 47, 9), PuzzleArt.wood);
          PuzzleArt.box(
            c,
            const Rect.fromLTWH(10, 8, 19, 23),
            KoUi.water,
            radius: 3,
          );
          PuzzleArt.line(c, const Offset(9, 39), const Offset(9, 67), width: 4);
        case OyenRule.wall:
          PuzzleArt.box(c, const Rect.fromLTWH(25, 0, 20, 61), PuzzleArt.wood);
          c.drawArc(
            const Rect.fromLTWH(-11, 16, 26, 26),
            -math.pi / 2,
            math.pi * .8,
            false,
            Paint()
              ..color = KoUi.ink
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          PuzzleArt.line(
            c,
            const Offset(9, 40),
            const Offset(15, 34),
            width: 3,
          );
          PuzzleArt.line(c, const Offset(9, 40), const Offset(4, 33), width: 3);
      }
      c.restore();
    }
    c.restore();
  }

  @override
  bool shouldRepaint(_Rule old) =>
      old.rule != rule || old.learned != learned || old.turn != turn;
}
