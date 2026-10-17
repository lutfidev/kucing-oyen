import 'dart:ui';

import 'package:flutter/animation.dart' show Curves;

import 'design_svg.dart';
import 'item_art.dart';
import 'svg_template.dart';
import 'tile.dart';

final _template = SvgTemplate(tileSvg);
final _cache = <Tile, SvgDrawing>{};

/// Hanya kotak menyala; digambar terpisah supaya bisa berkedip.
final _glow = _template.render({'glow': true});

/// Port `renderVals()` di `Tile.dc.html`.
Map<String, Object> tileVals(Tile tile) {
  final kind = tile.kind;
  final item = tile.item;
  return {
    'hasFloor': !kind.isWallish,
    'floorFill': tile.alt ? '#F1DDBA' : '#F7E8CE',
    'isWallish': kind.isWallish,
    'isWall': kind == TileKind.wall,
    'isCupboard': kind == TileKind.cupboard,
    'isShelf': kind == TileKind.shelf,
    'isFridge': kind == TileKind.fridge,
    'isBowl': kind == TileKind.bowl,
    'isTable': kind.isTable,
    'isGlass': kind == TileKind.tableGlass,
    'isVase': kind == TileKind.tableVase,
    'isBroken': kind == TileKind.tableBroken,
    'itemFish': item == TileItem.fish || item == TileItem.fishP,
    'itemWater': item == TileItem.water,
    'itemBucket': item == TileItem.bucketP,
    'itemBox': item == TileItem.box || item == TileItem.boxP,
    'player': item == TileItem.fishP || item == TileItem.boxP,
    'glow': tile.glow,
  };
}

/// Menggambar [tile] di kotak 0..50 kanvas. Skala dan posisi diatur
/// pemanggil (`canvas.translate`/`canvas.scale`).
///
/// [glowOpacity] untuk kedip petak menyala, lihat [tileGlowOpacity]. Benda
/// petunjuk ([Tile.ghost]) digambar samar di atas kotak menyala supaya
/// warnanya tetap terbaca.
void paintTile(Canvas canvas, Tile tile, {double glowOpacity = 1}) {
  final base = Tile(kind: tile.kind, item: tile.item, alt: tile.alt);
  _cache
      .putIfAbsent(base, () => _template.render(tileVals(base)))
      .paint(canvas);
  if (tile.glow && glowOpacity > 0) {
    if (glowOpacity >= 1) {
      _glow.paint(canvas);
    } else {
      canvas.saveLayer(
        null,
        Paint()..color = Color.fromRGBO(0, 0, 0, glowOpacity),
      );
      _glow.paint(canvas);
      canvas.restore();
    }
  }
  final ghost = tile.ghost;
  if (ghost != null && tile.item == TileItem.none) {
    canvas.saveLayer(
      null,
      Paint()..color = const Color.fromRGBO(0, 0, 0, ItemArt.hintOpacity),
    );
    paintItemArt(canvas, ghost, ghost: true);
    canvas.restore();
  }
}

/// Opasitas kotak menyala pada detik ke-[seconds] animasi `koGlow` di
/// desain: 1 → 0,45 → 1 tiap 1 detik, `ease-in-out` per separuh.
double tileGlowOpacity(double seconds) {
  const low = 0.45;
  final t = seconds % 1;
  final half = Curves.easeInOut.transform(t < 0.5 ? t * 2 : t * 2 - 1);
  return t < 0.5 ? 1 - (1 - low) * half : low + (1 - low) * half;
}
