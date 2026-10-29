import 'dart:ui';

import 'design_svg_home.dart';
import 'svg_template.dart';

final _window = SvgTemplate(roomWindowSvg).render(const {});
final _floorDecor = SvgTemplate(roomFloorDecorSvg).render(const {});
final _sadMark = SvgTemplate(sadMarkSvg);
final _sadCache = <bool, SvgDrawing>{};

/// Latar kamar (`Kamar.dc.html`) dan tanda lesu (`TandaLesu.dc.html`).
abstract final class RoomArt {
  static const windowViewBox = Rect.fromLTRB(-8, 0, 132, 134);

  /// Letak jendela di desain 390×844.
  static const windowBox = Rect.fromLTWH(26, 124, 140, 134);

  /// Bagian `roomFloorDecorSvg` yang berisi gambar: lantai desain.
  static const floorDecorViewBox = Rect.fromLTRB(0, 426, 390, 652);

  static const sadMarkViewBox = Size(48, 52);
}

void _paintIn(Canvas canvas, SvgDrawing drawing, Rect viewBox, Rect box) {
  canvas.save();
  canvas.translate(box.left, box.top);
  canvas.scale(box.width / viewBox.width, box.height / viewBox.height);
  canvas.translate(-viewBox.left, -viewBox.top);
  drawing.paint(canvas);
  canvas.restore();
}

/// Jendela dinding di [box] (ukuran desain 140×134).
void paintRoomWindow(Canvas canvas, {required Rect box}) =>
    _paintIn(canvas, _window, RoomArt.windowViewBox, box);

/// Bidang cahaya dan goresan lantai, direntangkan ke [floor].
void paintRoomFloorDecor(Canvas canvas, {required Rect floor}) =>
    _paintIn(canvas, _floorDecor, RoomArt.floorDecorViewBox, floor);

/// Tanda lesu selebar [width] di pojok kiri atas kanvas: perut keroncongan
/// kalau [hungry], selain itu awan mendung.
void paintSadMark(Canvas canvas, {required bool hungry, double width = 48}) {
  final drawing = _sadCache.putIfAbsent(
    hungry,
    () => _sadMark.render({'isLapar': hungry, 'isSedih': !hungry}),
  );
  final size = RoomArt.sadMarkViewBox;
  _paintIn(
    canvas,
    drawing,
    Offset.zero & size,
    Offset.zero & size * (width / size.width),
  );
}
