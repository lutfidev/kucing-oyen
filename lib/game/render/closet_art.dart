import 'dart:ui';

import 'design_svg.dart';
import 'svg_template.dart';

/// Ukuran gambar Lemari Kostum (desain 12).
abstract final class ClosetArt {
  /// viewBox lemari kayu.
  static const viewBox = Size(300, 236);
}

final _closet = SvgTemplate(closetSvg).render(const {});

/// Lemari kayu di kotak [ClosetArt.viewBox].
void paintCloset(Canvas canvas) => _closet.paint(canvas);
