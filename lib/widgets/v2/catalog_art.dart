import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../game/model/accessories.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/cat_rig.dart';

/// Static catalog previews share the same finite art pack as the home cats.
class CatalogArt extends StatelessWidget {
  const CatalogArt({
    super.key,
    required this.pack,
    this.item,
    this.kitty,
    this.accessory,
    this.size = 112,
  });
  final ArtPack pack;
  final RoomItemId? item;
  final KittyId? kitty;
  final AccessoryId? accessory;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CatalogPainter(pack, item, kitty, accessory),
      ),
    ),
  );
}

class _CatalogPainter extends CustomPainter {
  const _CatalogPainter(this.pack, this.item, this.kitty, this.accessory);
  final ArtPack pack;
  final RoomItemId? item;
  final KittyId? kitty;
  final AccessoryId? accessory;
  @override
  void paint(Canvas canvas, Size size) {
    final natural = item == null
        ? const Size(128, 128)
        : pack['items/${item!.name}-back'].size;
    final scale =
        math.min(size.width / natural.width, size.height / natural.height) * .9;
    canvas.save();
    canvas.translate(
      (size.width - natural.width * scale) / 2,
      (size.height - natural.height * scale) / 2,
    );
    canvas.scale(scale);
    if (item case final id?) {
      pack.paint(canvas, 'items/${id.name}-back');
      pack.paint(canvas, 'items/${id.name}-front');
    } else {
      CatRig(
        cat: kitty ?? KittyId.oyen,
        motion: CatMotion.happy,
        accessory: accessory,
      ).paint(canvas, pack, props: false);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CatalogPainter old) =>
      old.pack != pack ||
      old.item != item ||
      old.kitty != kitty ||
      old.accessory != accessory;
}
