import 'dart:math' as math;
import 'dart:ui';

import '../sim/item.dart';
import 'design_svg.dart';
import 'svg_template.dart';
import 'tile.dart';

/// Ukuran gambar benda pemain di baki dan di tangan, dari
/// `03-gameplay-fase-atur.html`, di koordinat desain.
abstract final class ItemArt {
  /// Gambar benda memakai viewBox 50×50, sama dengan petak.
  static const double viewBox = 50;

  /// Benda yang sedang diseret: kotak 64 px, diputar -8° dan diperbesar
  /// 1,12 kali di tengahnya.
  static const double liftSize = 64;
  static const double liftTilt = -8 * math.pi / 180;
  static const double liftScale = 1.12;

  /// Pusat benda yang diseret relatif ke titik jari: sedikit di atas jari
  /// supaya tidak tertutup (pusat gambar ember dibanding pusat riak sentuh di
  /// desain).
  static const liftFromFinger = Offset(-3, -19);

  /// `drop-shadow(0 12px 10px …)`: geser 12 px, blur 10 px.
  static const liftShadowOffset = Offset(0, 12);
  static const double liftShadowBlur = 10;

  /// Opasitas benda petunjuk di petak papan (gambar bayangan slot baki).
  /// Desain tidak punya; lebih tebal dari bayangan slot (0,28) supaya
  /// jenisnya terbaca di papan.
  static const double hintOpacity = 0.55;

  /// Benda pemain di petak papan: digambar dengan cincin oranye.
  static TileItem tileItem(Item item) => switch (item) {
    Item.fish => TileItem.fishP,
    Item.water => TileItem.bucketP,
    Item.box => TileItem.boxP,
  };
}

final _box = SvgTemplate(trayBoxSvg);
final _drawings = <(Item, bool), SvgDrawing>{};

SvgDrawing _drawing(Item item, bool ghost) =>
    _drawings.putIfAbsent((item, ghost), () {
      final svg = switch ((item, ghost)) {
        (Item.fish, false) => trayFishSvg,
        (Item.fish, true) => trayFishGhostSvg,
        (Item.water, false) => trayBucketSvg,
        (Item.water, true) => trayBucketGhostSvg,
        (Item.box, _) => null,
      };
      return svg == null
          ? _box.render({'player': !ghost})
          : SvgTemplate(svg).render(const {});
    });

/// Menggambar [item] di kotak 0..50 kanvas, seperti di slot baki. [ghost]
/// = bayangan benda di slot yang sisanya 0 (tanpa cincin oranye); opasitas
/// pudarnya diatur pemanggil.
void paintItemArt(Canvas canvas, Item item, {bool ghost = false}) =>
    _drawing(item, ghost).paint(canvas);

/// Menggambar [item] yang sedang diseret di kotak 0..[ItemArt.liftSize]:
/// miring, diperbesar, dengan bayangan jatuh berwarna [shadow]. Bayangan
/// ikut miring karena di CSS `filter` digambar sebelum `transform`.
void paintLiftedItem(Canvas canvas, Item item, {required Color shadow}) {
  const half = ItemArt.liftSize / 2;
  const scale = ItemArt.liftSize / ItemArt.viewBox;
  final art = _drawing(item, false);
  canvas
    ..save()
    ..translate(half, half)
    ..rotate(ItemArt.liftTilt)
    ..scale(ItemArt.liftScale)
    ..translate(-half, -half);

  // Blur CSS sebesar r px = simpangan baku r/2.
  const sigma = ItemArt.liftShadowBlur / 2;
  canvas
    ..saveLayer(
      null,
      Paint()
        ..imageFilter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma)
        ..colorFilter = ColorFilter.mode(shadow, BlendMode.srcIn),
    )
    ..translate(ItemArt.liftShadowOffset.dx, ItemArt.liftShadowOffset.dy)
    ..scale(scale);
  art.paint(canvas);
  canvas
    ..restore()
    ..save()
    ..scale(scale);
  art.paint(canvas);
  canvas
    ..restore()
    ..restore();
}
