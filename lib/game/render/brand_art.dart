import 'dart:ui';

import 'design_svg.dart';
import 'oyen.dart';
import 'oyen_painter.dart';
import 'svg_template.dart';

/// Ukuran gambar merek (ikon launcher, splash, gambar toko): kepala Oyen
/// depan bermata ngantuk dari sprite desain, tanpa badan dan bayangan.
abstract final class BrandArt {
  /// Kotak kepala (telinga sampai pipi) di viewBox Oyen 100×100.
  static const headBox = Rect.fromLTRB(16, 8, 84, 68);

  /// Ambang terang (luminans 0–1) ikon monokrom: lebih terang = siluet,
  /// lebih gelap (mata, hidung, mulut, belang) = lubang.
  static const monoThreshold = 0.6;
}

final _head = SvgTemplate(oyenSvg).render({
  ...oyenVals(const OyenLook()),
  'isNormal': false,
  'showTailSide': false,
});

/// Menggambar kepala Oyen selebar [width] dengan pojok kiri atas
/// [BrandArt.headBox] di titik asal kanvas.
void paintOyenHead(Canvas canvas, {required double width}) {
  const box = BrandArt.headBox;
  canvas
    ..save()
    ..scale(width / box.width)
    ..translate(-box.left, -box.top)
    ..clipRect(box);
  _head.paint(canvas);
  canvas.restore();
}

/// Kepala Oyen sebagai siluet satu warna [color] untuk ikon tema Android
/// 13+: bagian gelap jadi lubang, tepi tetap halus.
void paintOyenHeadMono(
  Canvas canvas, {
  required double width,
  required Color color,
}) {
  const box = BrandArt.headBox;
  final bounds = Rect.fromLTWH(0, 0, width, width * box.height / box.width);
  const k = 40.0;
  const t = BrandArt.monoThreshold;
  final threshold = ColorFilter.matrix([
    0, 0, 0, 0, color.r * 255, //
    0, 0, 0, 0, color.g * 255,
    0, 0, 0, 0, color.b * 255,
    k * 0.2126, k * 0.7152, k * 0.0722, 0, -k * t * 255,
  ]);
  canvas
    ..saveLayer(bounds, Paint())
    ..saveLayer(bounds, Paint()..colorFilter = threshold);
  paintOyenHead(canvas, width: width);
  // Alfa asli menjaga tepi kepala tetap halus.
  canvas
    ..restore()
    ..saveLayer(bounds, Paint()..blendMode = BlendMode.dstIn);
  paintOyenHead(canvas, width: width);
  canvas
    ..restore()
    ..restore();
}
