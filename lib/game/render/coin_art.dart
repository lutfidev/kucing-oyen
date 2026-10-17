import 'dart:ui';

import 'design_svg.dart';
import 'svg_template.dart';

/// Ukuran gambar koin desain 01 dan 10.
abstract final class CoinArt {
  /// Gambar koin memakai viewBox 28×28.
  static const double viewBox = 28;
}

final _coin = SvgTemplate(coinSvg).render(const {});
final _plain = SvgTemplate(coinPlainSvg).render(const {});

/// Menggambar koin di kotak 0..28 kanvas. [plain] = tanpa huruf S, seperti
/// di tombol bayar sheet Petunjuk.
void paintCoin(Canvas canvas, {bool plain = false}) =>
    (plain ? _plain : _coin).paint(canvas);
