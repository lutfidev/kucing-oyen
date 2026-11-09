import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/progress_scope.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_items.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/cat_rig.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import 'home_labels.dart';

/// Model-owned locations are the only source of visible cats. Gallery
/// compositions deliberately aren't used: they contain illustrative cats.
class HomeScene extends StatefulWidget {
  const HomeScene({
    super.key,
    required this.pack,
    required this.progress,
    required this.area,
    required this.selected,
    required this.onSelect,
    required this.animate,
  });
  final ArtPack pack;
  final ProgressController progress;
  final HomeArea area;
  final KittyId? selected;
  final ValueChanged<KittyId> onSelect;
  final bool animate;

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene>
    with SingleTickerProviderStateMixin {
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker((elapsed) {
    if (!widget.progress.householdPaused) {
      _time.value = elapsed.inMicroseconds / 1e6;
    }
  });

  @override
  void initState() {
    super.initState();
    widget.progress.householdPauseChanges.addListener(_sync);
  }

  void _sync() {
    final run =
        widget.animate &&
        !widget.progress.householdPaused &&
        !widget.progress.householdSaveFailed &&
        TickerMode.valuesOf(context).enabled;
    if (run && !_ticker.isActive) _ticker.start();
    if (!run && _ticker.isActive) _ticker.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(HomeScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    widget.progress.householdPauseChanges.removeListener(_sync);
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.progress;
    final cats = c.household.routine.present(widget.area);
    return ClipRRect(
      borderRadius: BorderRadius.circular(KoUi.cardRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 390;
          return Stack(
            key: const ValueKey('home-scene'),
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _RoomLayers(widget.pack, c, widget.area),
                  ),
                ),
              ),
              for (var i = 0; i < cats.length; i++)
                _cat(
                  context,
                  cats[i],
                  i,
                  cats.length,
                  scale,
                  constraints.maxHeight,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _cat(
    BuildContext context,
    KittyId kitty,
    int index,
    int count,
    double scale,
    double height,
  ) {
    final c = widget.progress;
    final r = c.household.routine;
    final moving = r.moving(kitty);
    final catSize = count == 1
        ? 144.0
        : count == 2
        ? 132.0
        : 124.0;
    // Three safe, separate foreground slots, with room left for the doorway.
    final x = count == 1
        ? 123.0
        : count == 2
        ? 43.0 + index * 165
        : 2.0 + index * 130;
    var y = index.isOdd ? 248.0 : 264.0;
    var dx = x;
    for (final trip in r.journeys.where((j) => j.cats.contains(kitty))) {
      if (!widget.animate) continue;
      // The same cat is only painted by its current slot owner, including
      // paired swaps. At the threshold it appears at the destination door.
      final t = trip.committed ? (trip.elapsed - .5) * 2 : trip.elapsed * 2;
      final door = 390 - catSize - KoUi.s8;
      dx = trip.committed ? door + (x - door) * t : x + (door - x) * t;
      y = trip.committed ? 216 + (y - 216) * t : y + (216 - y) * t;
    }
    final motion = moving
        ? CatMotion.walk
        : switch (r.activities[kitty]?.kind) {
            HomeActivity.eat => CatMotion.eat,
            HomeActivity.play => CatMotion.play,
            HomeActivity.brush => CatMotion.brush,
            HomeActivity.pet => CatMotion.pet,
            _ =>
              r.sleeping.contains(kitty)
                  ? CatMotion.sleep
                  : c.catNeeds(kitty).isSad
                  ? CatMotion.tired
                  : CatMotion.idle,
          };
    final name = kittyName(context.l10n, kitty);
    final status = homeKittyStatus(context.l10n, c, kitty);
    return Positioned(
      left: dx * scale,
      top: math.min(
        y * height / 390,
        height - (catSize + 16) * scale - KoUi.s8,
      ),
      width: catSize * scale,
      height: (catSize + 16) * scale,
      child: Semantics(
        button: true,
        selected: widget.selected == kitty,
        label: '$name, $status',
        child: Tooltip(
          message: name,
          child: GestureDetector(
            key: ValueKey('home-cat-${kitty.name}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onSelect(kitty),
            child: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: HomeCatPainter(
                        widget.pack,
                        CatRig(
                          cat: kitty,
                          motion: motion,
                          direction: moving
                              ? CatDirection.right
                              : CatDirection.front,
                          accessory: c.home.closet.wearingOf(kitty),
                        ),
                        time: widget.animate ? _time : null,
                        selected: widget.selected == kitty,
                      ),
                    ),
                  ),
                ),
                ExcludeSemantics(child: Text(name, style: KoUi.caption)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeCatPainter extends CustomPainter {
  HomeCatPainter(this.pack, this.rig, {this.time, this.selected = false})
    : super(repaint: time);
  final ArtPack pack;
  final CatRig rig;
  final ValueNotifier<double>? time;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 128;
    canvas.save();
    canvas.translate(
      (size.width - 128 * scale) / 2,
      (size.height - 128 * scale) / 2,
    );
    canvas.scale(scale);
    if (selected) {
      canvas.drawOval(
        const Rect.fromLTWH(15, 106, 98, 18),
        Paint()..color = KoUi.peach,
      );
      canvas.drawOval(
        const Rect.fromLTWH(15, 106, 98, 18),
        Paint()
          ..color = KoUi.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    CatRig(
      cat: rig.cat,
      motion: rig.motion,
      direction: rig.direction,
      accessory: rig.accessory,
      time: time?.value,
    ).paint(canvas, pack);
    canvas.restore();
  }

  @override
  bool shouldRepaint(HomeCatPainter old) => true;
}

class _RoomLayers extends CustomPainter {
  _RoomLayers(this.pack, ProgressController c, this.area)
    : placed = c.household.areas.placed;
  final ArtPack pack;
  final HomeArea area;
  final Map<RoomItemId, AreaSlot> placed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 390);
    for (final layer in ['wall', 'floor', 'decor']) {
      pack.paint(canvas, 'rooms/${area.name}-$layer');
    }
    // The lounge rug is structural, not an unowned catalogue purchase.
    if (area == HomeArea.santai || area == HomeArea.rawat) {
      canvas.drawOval(
        const Rect.fromLTWH(34, 246, 322, 120),
        Paint()..color = KoUi.paper,
      );
      canvas.drawOval(
        const Rect.fromLTWH(34, 246, 322, 120),
        Paint()
          ..color = KoUi.honey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (final entry in placed.entries.where((e) => e.value.area == area)) {
      final id = entry.key;
      final slot = entry.value;
      final part = pack['items/${id.name}-back'];
      final scale = math.min(90 / part.size.width, 90 / part.size.height);
      final anchor = slot.anchor;
      canvas.save();
      canvas.translate(
        anchor.x * 390 - part.size.width * scale / 2,
        anchor.y * 390 - part.size.height * scale / 2,
      );
      canvas.scale(scale);
      pack.paint(canvas, 'items/${id.name}-back');
      pack.paint(canvas, 'items/${id.name}-front');
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoomLayers old) =>
      old.pack != pack || old.area != area || !identical(old.placed, placed);
}
