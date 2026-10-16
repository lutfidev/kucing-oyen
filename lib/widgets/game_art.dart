import 'package:flutter/widgets.dart';

import '../game/render/render.dart';

/// Satu petak seukuran [size] px (desain 50 px). Hiasan saja.
class TileView extends StatelessWidget {
  const TileView(this.tile, {super.key, this.size = Tile.size});

  final Tile tile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _TilePainter(tile)),
    );
  }
}

class _TilePainter extends CustomPainter {
  _TilePainter(this.tile);

  final Tile tile;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / Tile.size);
    paintTile(canvas, tile);
  }

  @override
  bool shouldRepaint(_TilePainter old) => old.tile != tile;
}

/// Oyen seukuran [size] px. Gelembung dan topi boleh keluar dari kotaknya,
/// jadi beri ruang di atas dan kanan.
class OyenView extends StatelessWidget {
  const OyenView(this.look, {super.key, required this.size});

  final OyenLook look;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: look.label,
      child: CustomPaint(size: Size.square(size), painter: _OyenPainter(look)),
    );
  }
}

class _OyenPainter extends CustomPainter {
  _OyenPainter(this.look);

  final OyenLook look;

  @override
  void paint(Canvas canvas, Size size) =>
      paintOyen(canvas, look, size: size.width);

  @override
  bool shouldRepaint(_OyenPainter old) => old.look != look;
}

/// Papan 350×450 lengkap dengan bingkai dan bayangan. Mengecil kalau
/// tempatnya kurang lebar; bingkai menempati 4 px di luar kotaknya.
class BoardView extends StatelessWidget {
  const BoardView(this.scene, {super.key});

  final BoardScene scene;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: BoardScene.label,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: CustomPaint(
          size: const Size(BoardScene.width, BoardScene.height),
          painter: _BoardPainter(scene),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.scene);

  final BoardScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    paintBoardFrame(canvas);
    paintBoard(canvas, scene);
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.scene != scene;
}
