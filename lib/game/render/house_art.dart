import 'dart:ui';

import '../model/house.dart';
import 'css_animation.dart';
import 'design_svg_house.dart';
import 'svg_template.dart';

/// Lapisan gambar satu ruangan, urut dari belakang (desain `kSkala`):
/// latar, cahaya di lantai, (bayangan dan kucing yang lewat pintu), kusen
/// pintu depan, (barang dan kucing), cahaya di udara.
enum HouseLayer { back, floorLight, frame, airLight }

/// Ukuran viewBox lapisan rumah (area rumah desain).
const houseViewBox = Size(390, 652);

final _keyframes = CssKeyframes.parse(houseKeyframesCss);

String _source(HouseRoom room, HouseLayer layer) => switch ((room, layer)) {
  (HouseRoom.living, HouseLayer.back) => houseLivingBackSvg,
  (HouseRoom.living, HouseLayer.floorLight) => houseLivingFloorLightSvg,
  (HouseRoom.living, HouseLayer.frame) => houseLivingFrameSvg,
  (HouseRoom.living, HouseLayer.airLight) => houseLivingAirLightSvg,
  (HouseRoom.terrace, HouseLayer.back) => houseTerraceBackSvg,
  (HouseRoom.terrace, HouseLayer.floorLight) => houseTerraceFloorLightSvg,
  (HouseRoom.terrace, HouseLayer.frame) => houseTerraceFrameSvg,
  (HouseRoom.terrace, HouseLayer.airLight) => houseTerraceAirLightSvg,
};

final _templates = <(HouseRoom, HouseLayer), SvgTemplate>{};
final _still = <(HouseRoom, HouseLayer), SvgDrawing>{};
final _moving = <(HouseRoom, HouseLayer), SvgAnimation>{};

SvgTemplate _template(HouseRoom room, HouseLayer layer) =>
    _templates.putIfAbsent(
      (room, layer),
      () => SvgTemplate(
        _source(room, layer),
        keyframes: _keyframes,
        classes: houseClassStyles,
      ),
    );

/// Lapisan [layer] ruangan [room] seukuran [size] (viewBox 390×652
/// diskalakan tidak seragam, catatan `n360`). [time] = detik animasi
/// (awan, daun, cahaya berdenyut); null = diam (kurangi gerak).
void paintHouseLayer(
  Canvas canvas,
  HouseRoom room,
  HouseLayer layer, {
  required Size size,
  double? time,
}) {
  final key = (room, layer);
  final template = _template(room, layer);
  final drawing = time == null || !template.animated
      ? _still.putIfAbsent(key, () => template.render(const {}))
      : _moving
            .putIfAbsent(key, () => template.bind(const {}))
            .render(time: time);
  canvas
    ..save()
    ..scale(size.width / houseViewBox.width, size.height / houseViewBox.height);
  drawing.paint(canvas);
  canvas.restore();
}
