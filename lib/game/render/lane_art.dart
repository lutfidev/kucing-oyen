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
      : _moving
            .putIfAbsent(key, () => template.bind(vals, record: true))
            .render(time: time);
  canvas
    ..save()
    ..scale(size.width / laneViewBox.width, size.height / laneViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}

/// Ukuran viewBox penanda "Oyen di gang" (`PenandaGang.dc.html`).
const laneMarkerViewBox = Size(48, 52);

final _marker = SvgTemplate(laneMarkerSvg, classes: laneClassStyles);
SvgDrawing? _markerDrawing;

/// Penanda "Oyen di gang" seukuran [size] di pojok kiri atas kanvas. Isinya
/// diam; ayunan `pgBob` (kelas di tag `<svg>`) digerakkan `LaneMarker`.
void paintLaneMarker(Canvas canvas, {required Size size}) {
  final drawing = _markerDrawing ??= _marker.render(const {});
  canvas
    ..save()
    ..scale(
      size.width / laneMarkerViewBox.width,
      size.height / laneMarkerViewBox.height,
    );
  drawing.paint(canvas);
  canvas.restore();
}

final _tail = SvgTemplate(
  kumisTailSvg,
  keyframes: _keyframes,
  classes: laneClassStyles,
);
SvgDrawing? _tailStill;
SvgAnimation? _tailMoving;

/// Ekor Kumis di pintu kucing ruang tengah (`AdeganTengah`, viewBox
/// 390×652 = area rumah [size]); [time] = detik goyang `ekGoyang`, null =
/// diam.
void paintKumisTail(Canvas canvas, {required Size size, double? time}) {
  final drawing = time == null
      ? _tailStill ??= _tail.render(const {})
      : (_tailMoving ??= _tail.bind(const {})).render(time: time);
  canvas
    ..save()
    ..scale(size.width / laneViewBox.width, size.height / laneViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}

/// Ukuran viewBox tanda "!" (`AdeganTengah`, `seru`).
const seruViewBox = Size(24, 30);

final _seru = SvgTemplate(seruSvg);
SvgDrawing? _seruDrawing;

/// Tanda "!" seukuran [size] di pojok kiri atas kanvas (pantulannya
/// digerakkan widget, karena kelas `at-seru` ada di tag `<svg>`).
void paintSeru(Canvas canvas, {required Size size}) {
  final drawing = _seruDrawing ??= _seru.render(const {});
  canvas
    ..save()
    ..scale(size.width / seruViewBox.width, size.height / seruViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}

final _puff = SvgTemplate(lanePuffSvg);
SvgDrawing? _puffDrawing;

/// Kepulan kecil di antara hidung Oyen dan Kumis saat mengendus
/// (`AdeganGang`, `temuD`; viewBox 390×652 = area rumah [size]).
void paintLanePuff(Canvas canvas, {required Size size}) {
  final drawing = _puffDrawing ??= _puff.render(const {});
  canvas
    ..save()
    ..scale(size.width / laneViewBox.width, size.height / laneViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}
