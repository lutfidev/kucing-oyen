import 'dart:ui';

import '../../model/home_items.dart';
import '../../model/kitties.dart';
import 'art_pack.dart';
import 'cat_rig.dart';

enum ArtArea { santai, makan, main, rawat }

/// Art-only compositions for inspection. Positions are not game/model state.
void paintAreaArt(Canvas canvas, ArtPack pack, ArtArea area, {double? time}) {
  canvas.save();
  canvas.clipRect(const Rect.fromLTWH(0, 0, 390, 390));
  for (final layer in ['wall', 'floor', 'decor']) {
    pack.paint(canvas, 'rooms/${area.name}-$layer');
  }
  void item(RoomItemId id, double x, double y, double scale, {String? layer}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    for (final l in layer == null ? ['back', 'front'] : [layer]) {
      pack.paint(canvas, 'items/${id.name}-$l');
    }
    canvas.restore();
  }

  void cat(
    KittyId id,
    double x,
    double y,
    CatMotion motion, {
    CatDirection direction = CatDirection.front,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(0.85);
    CatRig(
      cat: id,
      motion: motion,
      direction: direction,
      time: time,
    ).paint(canvas, pack, props: motion != CatMotion.eat);
    canvas.restore();
  }

  switch (area) {
    case ArtArea.santai:
      item(RoomItemId.karpet, 76, 164, 1.85);
      item(RoomItemId.kasur, 7, 229, 0.95, layer: 'back');
      cat(KittyId.salju, 14, 226, CatMotion.sleep);
      item(RoomItemId.kasur, 7, 229, 0.95, layer: 'front');
      cat(KittyId.oyen, 133, 224, CatMotion.happy);
      cat(
        KittyId.mendung,
        265,
        218,
        CatMotion.walk,
        direction: CatDirection.left,
      );
      item(RoomItemId.bola, 274, 297, 0.55);
    case ArtArea.makan:
      item(RoomItemId.karpet, 100, 164, 1.7);
      cat(KittyId.telon, 126, 229, CatMotion.eat);
      item(RoomItemId.mangkuk, 140, 250, 0.75);
      cat(KittyId.kopiSusu, 260, 232, CatMotion.sit);
    case ArtArea.main:
      item(RoomItemId.tiang, 4, 164, 1.1);
      item(RoomItemId.terowongan, 238, 259, 1.1);
      cat(KittyId.arang, 89, 230, CatMotion.play);
      cat(
        KittyId.kembang,
        215,
        202,
        CatMotion.chase,
        direction: CatDirection.left,
      );
    case ArtArea.rawat:
      item(RoomItemId.karpet, 70, 164, 1.85);
      cat(KittyId.mochi, 96, 229, CatMotion.brush);
      cat(KittyId.bos, 242, 229, CatMotion.pet);
  }
  canvas.restore();
}
