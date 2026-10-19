import 'dart:math' as math;

import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/widgets.dart';

import '../../game/kucing_game.dart';
import '../../game/render/render.dart';
import '../../theme/theme.dart';
import '../../l10n/l10n.dart';

/// Papan level: [KucingGame] dalam `GameWidget` dengan bingkai dan bayangan
/// papan di belakangnya.
///
/// Papan mengisi kotak rasio 350×450 terbesar yang muat (bingkai 4 px di
/// luarnya ikut dihitung), di tengah tempatnya. Papan tidak bisa difokus:
/// hanya sentuhan.
class LevelBoard extends StatelessWidget {
  const LevelBoard({super.key, required this.game});

  final KucingGame game;

  @override
  Widget build(BuildContext context) {
    final ring = context.koShadow.board.first.spreadRadius;
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
          child: SizedBox(
            width: BoardScene.width * scale,
            height: BoardScene.height * scale,
            child: CustomPaint(
              painter: _FramePainter(scale),
              child: Semantics(
                image: true,
                label: context.l10n.boardLabel,
                child: ExcludeFocus(
                  child: GameWidget(game: game, autofocus: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.scale);

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    paintBoardFrame(canvas);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.scale != scale;
}
