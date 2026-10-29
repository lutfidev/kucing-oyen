import 'dart:ui';

import 'css_animation.dart';
import 'design_svg_home.dart';
import 'svg_template.dart';

final _window = SvgTemplate(roomWindowSvg).render(const {});
final _floorDecor = SvgTemplate(roomFloorDecorSvg).render(const {});
final _sadMark = SvgTemplate(sadMarkSvg);
final _sadCache = <bool, SvgDrawing>{};
final _coinBubble = SvgTemplate(coinBubbleSvg).render(const {});
final _badgeKeyframes = CssKeyframes.parse(roomBadgeKeyframes);

/// Latar kamar (`Kamar.dc.html`) dan tanda lesu (`TandaLesu.dc.html`).
abstract final class RoomArt {
  static const windowViewBox = Rect.fromLTRB(-8, 0, 132, 134);

  /// Letak jendela di desain 390×844.
  static const windowBox = Rect.fromLTWH(26, 124, 140, 134);

  /// Bagian `roomFloorDecorSvg` yang berisi gambar: lantai desain.
  static const floorDecorViewBox = Rect.fromLTRB(0, 426, 390, 652);

  static const sadMarkViewBox = Size(48, 52);

  static const coinBubbleViewBox = Size(64, 76);

  /// Letak label "+N" di gelembung koin (desain: `top: 40px`, tinggi 18).
  static const coinBubbleLabelTop = 40.0;

  /// Naik-turun gelembung koin (`gkBob` 1,6 detik) dan tanda lesu (`tlBob`
  /// 2,4 detik) pada detik [time], dalam px desain; 0 kalau diam.
  static double coinBubbleBob(double? time) =>
      _bob('animation: gkBob 1.6s ease-in-out infinite', time);

  static double sadMarkBob(double? time) =>
      _bob('animation: tlBob 2.4s ease-in-out infinite', time);
}

double _bob(String style, double? time) {
  if (time == null) return 0;
  final frame = CssStyle.parse(style).frameAt(time, _badgeKeyframes);
  return frame?.matrix(0, 0).$6 ?? 0;
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

/// Gelembung koin hadiah selebar [width] di pojok kiri atas kanvas (tanpa
/// label "+N", yang ditulis widget).
void paintCoinBubble(Canvas canvas, {double width = 64}) {
  final size = RoomArt.coinBubbleViewBox;
  _paintIn(
    canvas,
    _coinBubble,
    Offset.zero & size,
    Offset.zero & size * (width / size.width),
  );
}
