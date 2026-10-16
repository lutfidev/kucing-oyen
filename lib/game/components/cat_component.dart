import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart' show Curves;

import '../kucing_game.dart';
import '../render/render.dart';

/// Oyen dan panah arah hadapnya (`paintBoardOyen`), dipotong sudut papan.
/// Digambar di atas [BoardComponent] supaya kepala Oyen menutupi petak atas.
///
/// Saat petak Oyen di `scene` berganti, Oyen digeser dari posisi yang
/// sedang tampil ke petak baru selama [KucingGame.moveTime] (kurva `ease`,
/// seperti transisi `left`/`top` di `Board.dc.html`). Pose langsung
/// berganti.
class CatComponent extends Component with HasGameReference<KucingGame> {
  /// Posisi (kolom, baris) awal dan tujuan geseran, dan kemajuannya 0..1.
  Offset? _from;
  Offset? _to;
  double _progress = 1;

  /// Oyen sedang berpindah petak.
  bool get moving => _progress < 1;

  /// Posisi Oyen yang sedang tampil, atau null sebelum [update] pertama.
  Offset? get shown {
    final to = _to;
    if (to == null || _progress >= 1) return to;
    return Offset.lerp(_from, to, Curves.ease.transform(_progress));
  }

  @override
  void update(double dt) {
    final oyen = game.scene.oyen;
    final to = oyen == null ? null : Offset(oyen.col, oyen.row);
    if (to != _to) {
      final from = shown;
      final slide =
          game.animate && game.moveTime > 0 && from != null && to != null;
      _from = slide ? from : to;
      _to = to;
      _progress = slide ? 0 : 1;
    } else if (moving) {
      _progress = game.moveTime > 0
          ? math.min(1, _progress + dt / game.moveTime)
          : 1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas
      ..save()
      ..clipRRect(BoardArt.rrect);
    paintBoardOyen(canvas, game.scene, at: shown);
    canvas.restore();
  }
}
