import 'dart:math' as math;
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import '../../theme/ko_colors.dart';
import '../../theme/ko_shadow.dart';
import '../sim/direction.dart';
import '../sim/pos.dart';
import 'board_scene.dart';
import 'design_svg.dart';
import 'oyen_painter.dart';
import 'svg_template.dart';
import 'tile.dart';
import 'tile_painter.dart';

/// Ukuran gambar papan dari `Board.dc.html`, di koordinat desain.
abstract final class BoardArt {
  /// Sudut papan.
  static const double radius = 16;

  /// Oyen digambar 62 px, digeser (-6, -12) dari pojok petaknya supaya
  /// kepalanya menyembul ke petak atas.
  static const double oyenSize = 62;
  static const Offset oyenOffset = Offset(-6, -12);

  /// Garis jalur Oyen: tebal 4, putus-putus 2 9, ujung bulat.
  static const double pathWidth = 4;
  static const List<double> pathDash = [2, 9];

  /// Panah arah hadap: ikon 12 px di lingkaran 18 px (padding 3) dengan
  /// cincin 2 px.
  static const double facingIcon = 12;
  static const double facingPadding = 3;
  static const double facingRing = 2;

  static const rect = Rect.fromLTWH(0, 0, BoardScene.width, BoardScene.height);
  static final rrect = RRect.fromRectAndRadius(
    rect,
    const Radius.circular(radius),
  );
}

final _facing = SvgTemplate(facingSvg).render(const {});

/// Bingkai papan: bayangan lembut dan cincin 4 px di luar kotak 350×450
/// (token `KoShadow.board`). Digambar sebelum [paintBoard].
void paintBoardFrame(Canvas canvas) {
  // Di CSS, bayangan pertama di daftar berada paling atas.
  for (final shadow in KoShadow.standard.board.reversed) {
    canvas.drawRRect(
      BoardArt.rrect.shift(shadow.offset).inflate(shadow.spreadRadius),
      shadow.toPaint(),
    );
  }
}

/// Menggambar isi papan di kotak 0..350 × 0..450: 63 petak, jalur Oyen,
/// Oyen, dan panah arah hadap, dipotong sudut 16 px seperti
/// `overflow: hidden` di desain.
///
/// [glowOpacity] untuk kedip petak menyala, lihat [tileGlowOpacity].
void paintBoard(Canvas canvas, BoardScene scene, {double glowOpacity = 1}) {
  canvas
    ..save()
    ..clipRRect(BoardArt.rrect);
  paintBoardTiles(canvas, scene, glowOpacity: glowOpacity);
  paintBoardPath(canvas, scene);
  paintBoardOyen(canvas, scene);
  canvas.restore();
}

/// Jalur Oyen ([BoardScene.path]) sebagai garis putus-putus oranye lewat
/// tengah petak (`polyline` di `Board.dc.html`), di atas petak dan di bawah
/// Oyen.
void paintBoardPath(Canvas canvas, BoardScene scene) {
  final path = scene.path;
  if (path.length < 2) return;
  Offset center(Pos p) => Offset(p.x + 0.5, p.y + 0.5) * Tile.size;
  final line = Path()..moveTo(center(path.first).dx, center(path.first).dy);
  for (final p in path.skip(1)) {
    line.lineTo(center(p).dx, center(p).dy);
  }
  canvas.drawPath(
    dashPath(line, dashArray: CircularIntervalList(BoardArt.pathDash)),
    Paint()
      ..color = KoColors.standard.orangeLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = BoardArt.pathWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

/// Bagian petak dari [paintBoard] (63 petak dan bendanya), tanpa potongan
/// sudut.
void paintBoardTiles(
  Canvas canvas,
  BoardScene scene, {
  double glowOpacity = 1,
}) {
  for (var i = 0; i < scene.tiles.length; i++) {
    canvas
      ..save()
      ..translate(
        (i % BoardScene.columns) * Tile.size,
        (i ~/ BoardScene.columns) * Tile.size,
      );
    paintTile(canvas, scene.tiles[i], glowOpacity: glowOpacity);
    canvas.restore();
  }
}

/// Bagian Oyen dari [paintBoard] (Oyen dan panah arah hadap), tanpa potongan
/// sudut. [at] (kolom, baris) menimpa posisi Oyen di [scene], untuk animasi
/// pindah petak.
void paintBoardOyen(Canvas canvas, BoardScene scene, {Offset? at}) {
  final oyen = scene.oyen;
  if (oyen == null) return;
  final tile = (at ?? Offset(oyen.col, oyen.row)) * Tile.size;
  canvas
    ..save()
    ..translate(
      tile.dx + BoardArt.oyenOffset.dx,
      tile.dy + BoardArt.oyenOffset.dy,
    );
  paintOyen(canvas, oyen.look, size: BoardArt.oyenSize);
  canvas.restore();
  if (scene.showFacing) _paintFacing(canvas, tile, oyen.look.dir);
}

/// Panah di tepi petak Oyen (pojok kiri atasnya di [tile]), ke arah hadapnya
/// (`facingStyle` di desain).
void _paintFacing(Canvas canvas, Offset tile, Direction dir) {
  // Pojok kiri atas ikon 12 px, relatif ke pojok petak.
  final (fx, fy) = switch (dir) {
    Direction.right => (44.0, 19.0),
    Direction.left => (-6.0, 19.0),
    Direction.up => (19.0, -6.0),
    Direction.down => (19.0, 44.0),
  };
  final degrees = switch (dir) {
    Direction.right => 0,
    Direction.down => 90,
    Direction.left => 180,
    Direction.up => -90,
  };
  const half = BoardArt.facingIcon / 2;
  const radius = half + BoardArt.facingPadding;
  const c = KoColors.standard;
  canvas
    ..save()
    ..translate(tile.dx + fx + half, tile.dy + fy + half)
    ..drawCircle(
      Offset.zero,
      radius + BoardArt.facingRing,
      Paint()..color = c.surface,
    )
    ..drawCircle(Offset.zero, radius, Paint()..color = c.orange)
    ..rotate(degrees * math.pi / 180)
    ..translate(-half, -half);
  _facing.paint(canvas);
  canvas.restore();
}
