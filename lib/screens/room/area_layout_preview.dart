import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../game/model/home_areas.dart';
import '../../game/model/home_items.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/painted_scenery.dart';

/// Read-only draft preview in the same 390-unit room coordinates as HomeScene.
class AreaLayoutPreview extends StatelessWidget {
  const AreaLayoutPreview({
    super.key,
    required this.pack,
    required this.draft,
    required this.area,
  });
  final ArtPack pack;
  final HomeAreas draft;
  final HomeArea area;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: switch (area) {
              HomeArea.santai => PaintedScenery.lounge,
              HomeArea.makan => PaintedScenery.dining,
              HomeArea.main => PaintedScenery.play,
              HomeArea.rawat => PaintedScenery.care,
            },
            fit: BoxFit.cover,
          ),
          CustomPaint(painter: _DraftPainter(pack, draft, area)),
        ],
      ),
    ),
  );
}

class _DraftPainter extends CustomPainter {
  const _DraftPainter(this.pack, this.draft, this.area);
  final ArtPack pack;
  final HomeAreas draft;
  final HomeArea area;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 390);
    for (final e in draft.placed.entries.where((e) => e.value.area == area)) {
      final slot = e.value;
      final part = pack['items/${e.key.name}-back'];
      final dimension = slot.zone == RoomZone.wall ? 62.0 : 90.0;
      final scale = math.min(
        dimension / part.size.width,
        dimension / part.size.height,
      );
      final x = slot.anchor.x * 390;
      final y = slot.zone == RoomZone.wall
          ? [35.0, 20.0, 30.0][slot.index]
          : slot.index < 2
          ? 281.0
          : 370.0;
      canvas.save();
      // The dining bowl and active toy have dedicated center anchors in play.
      final central = e.key == RoomItemId.mangkuk || e.key == draft.playToy;
      canvas.translate(
        (central ? 195 : x) - part.size.width * scale / 2,
        (central ? 300 : y) -
            part.size.height * scale * (slot.zone == RoomZone.floor ? .9 : .4),
      );
      canvas.scale(scale);
      pack.paint(canvas, 'items/${e.key.name}-back');
      pack.paint(canvas, 'items/${e.key.name}-front');
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DraftPainter old) =>
      old.pack != pack || old.draft != draft || old.area != area;
}
