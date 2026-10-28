import 'dart:ui';

import '../model/accessories.dart';
import 'design_svg_home.dart';
import 'svg_template.dart';

final _template = SvgTemplate(accessoryIconSvg);
final _cache = <AccessoryId?, SvgDrawing>{};

/// Ikon aksesoris di kartu dan panel pratinjau (`IkonAksesoris.dc.html`).
abstract final class AccessoryIconArt {
  static const viewBox = 48.0;
}

/// Menggambar ikon aksesoris [id] seukuran [size] px di pojok kiri atas
/// kanvas; null = ikon "tanpa aksesoris" desain.
void paintAccessoryIcon(
  Canvas canvas,
  AccessoryId? id, {
  double size = AccessoryIconArt.viewBox,
}) {
  final drawing = _cache.putIfAbsent(
    id,
    () => _template.render({
      'a': {
        'none': id == null,
        for (final value in AccessoryId.values) value.name: value == id,
      },
    }),
  );
  canvas.save();
  canvas.scale(size / AccessoryIconArt.viewBox);
  drawing.paint(canvas);
  canvas.restore();
}
