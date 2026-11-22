import 'dart:ui';

import 'css_animation.dart';
import 'design_svg_lane.dart';
import 'svg_template.dart';

/// Lapisan gambar Gang Depan, urut dari belakang (catatan kanvas `kGang`):
/// latar, cahaya di tanah, (bayangan, kucing yang lewat pintu), kusen pintu
/// pulang, bangku belakang, (kucing di bangku), bangku depan, (kucing
/// lain), cahaya di udara dan kupu-kupu.
enum LaneLayer { back, floorLight, frame, benchBack, benchFront, airLight }

/// Ukuran viewBox lapisan gang (sama dengan area rumah desain).
const laneViewBox = Size(390, 652);

final _keyframes = CssKeyframes.parse(laneKeyframesCss);

String _source(LaneLayer layer) => switch (layer) {
  LaneLayer.back => laneBackSvg,
  LaneLayer.floorLight => laneFloorLightSvg,
  LaneLayer.frame => laneFrameSvg,
  LaneLayer.benchBack => benchBackSvg,
  LaneLayer.benchFront => benchFrontSvg,
  LaneLayer.airLight => laneAirLightSvg,
};

final _templates = <LaneLayer, SvgTemplate>{};
final _still = <(LaneLayer, bool), SvgDrawing>{};
final _moving = <(LaneLayer, bool), SvgAnimation>{};

SvgTemplate _template(LaneLayer layer) => _templates.putIfAbsent(
  layer,
  () => SvgTemplate(
    _source(layer),
    keyframes: _keyframes,
    classes: laneClassStyles,
  ),
);

/// Lapisan [layer] punya animasi (awan, daun, sachet, tenda, cahaya,
/// kupu-kupu); kalau tidak, waktunya tidak perlu digambar ulang.
bool laneLayerAnimated(LaneLayer layer) => _template(layer).animated;

/// Lapisan [layer] gang seukuran [size] (viewBox 390×652 diskalakan tidak
/// seragam seperti rumah). [time] = detik animasi; null = diam (kurangi
/// gerak). [butterflies] = kupu-kupu di cahaya udara (`kupu` desain;
/// dimatikan saat momen "melihat kupu-kupu" menggambar kupu-kupunya
/// sendiri).
void paintLaneLayer(
  Canvas canvas,
  LaneLayer layer, {
  required Size size,
  double? time,
  bool butterflies = true,
}) {
  final key = (layer, butterflies);
  final template = _template(layer);
  final vals = {'kupu': butterflies};
  final drawing = time == null || !template.animated
      ? _still.putIfAbsent(key, () => template.render(vals))
      : _moving.putIfAbsent(key, () => template.bind(vals)).render(time: time);
  canvas
    ..save()
    ..scale(size.width / laneViewBox.width, size.height / laneViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}

/// Ukuran viewBox penanda "Oyen di gang" (`PenandaGang.dc.html`).
const laneMarkerViewBox = Size(48, 52);

final _marker = SvgTemplate(
  laneMarkerSvg,
  keyframes: _keyframes,
  classes: laneClassStyles,
);
SvgDrawing? _markerStill;
SvgAnimation? _markerMoving;

/// Penanda "Oyen di gang" seukuran [size] di pojok kiri atas kanvas;
/// [time] = detik ayunan `pgBob`, null = diam.
void paintLaneMarker(Canvas canvas, {required Size size, double? time}) {
  final drawing = time == null
      ? _markerStill ??= _marker.render(const {})
      : (_markerMoving ??= _marker.bind(const {})).render(time: time);
  canvas
    ..save()
    ..scale(
      size.width / laneMarkerViewBox.width,
      size.height / laneMarkerViewBox.height,
    );
  drawing.paint(canvas);
  canvas.restore();
}
