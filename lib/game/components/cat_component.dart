import 'dart:ui';

import 'package:flame/components.dart';

import '../kucing_game.dart';
import '../render/render.dart';

/// Oyen dan panah arah hadapnya (`paintBoardOyen`), dipotong sudut papan.
/// Digambar di atas [BoardComponent] supaya kepala Oyen menutupi petak atas.
class CatComponent extends Component with HasGameReference<KucingGame> {
  @override
  void render(Canvas canvas) {
    canvas
      ..save()
      ..clipRRect(BoardArt.rrect);
    paintBoardOyen(canvas, game.scene);
    canvas.restore();
  }
}
