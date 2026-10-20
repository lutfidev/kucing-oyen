import 'dart:ui';

import 'design_svg.dart';
import 'svg_template.dart';

/// Ukuran gambar koin desain 01 dan 10.
abstract final class CoinArt {
  /// Gambar koin memakai viewBox 28×28.
  static const double viewBox = 28;
}

/// Gambar koin per tempat di desain.
enum CoinKind {
  /// Dengan huruf S (chip saldo, desain 01 dan 10).
  full,

  /// Tanpa huruf, garis 2 (tombol bayar sheet Petunjuk, desain 10).
  plain,

  /// Tanpa huruf, garis 2,4 (label harga kartu kostum, desain 12).
  price,
}

final _drawings = {
  CoinKind.full: SvgTemplate(coinSvg).render(const {}),
  CoinKind.plain: SvgTemplate(coinPlainSvg).render(const {}),
  CoinKind.price: SvgTemplate(coinPriceSvg).render(const {}),
};

/// Menggambar koin [kind] di kotak 0..28 kanvas.
void paintCoin(Canvas canvas, {CoinKind kind = CoinKind.full}) =>
    _drawings[kind]!.paint(canvas);
