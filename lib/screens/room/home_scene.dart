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
import '../../game/render/v2/lounge_lighting.dart';
import '../../game/render/v2/painted_scenery.dart';
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
    this.sceneryProvider = PaintedScenery.lounge,
  });
  final ArtPack pack;
  final ProgressController progress;
  final HomeArea area;
  final KittyId? selected;
  final ValueChanged<KittyId> onSelect;
  final bool animate;
  final ImageProvider sceneryProvider;

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
              if (widget.area == HomeArea.santai)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Image(
                      key: const ValueKey('home-painted-backdrop'),
                      image: widget.sceneryProvider,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      excludeFromSemantics: true,
                      frameBuilder: (
                        context,
                        child,
                        frame,
                        synchronouslyLoaded,
                      ) => frame == null ? _vectorBackdrop(c) : child,
                      errorBuilder: (context, error, stack) =>
                          _vectorBackdrop(c),
                    ),
                  ),
                ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _RoomLayers(
                      widget.pack,
                      c,
                      widget.area,
                      background: widget.area != HomeArea.santai,
                    ),
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

  Widget _vectorBackdrop(ProgressController c) => CustomPaint(
    key: const ValueKey('home-vector-backdrop'),
    painter: _RoomLayers(widget.pack, c, widget.area, items: false),
  );

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
        ? 205.0
        : count == 2
        ? 168.0
        : index == 0
        ? 176.0
        : index == 1
        ? 130.0
        : 124.0;
    // Three safe, separate foreground slots, with room left for the doorway.
    final x = count == 1
        ? 94.0
        : count == 2
        ? 22.0 + index * 172
        : index == 0
        ? 108.0
        : index == 1
        ? -3.0
        : 263.0;
    var y = count == 3 && index == 2 ? 228.0 : 271.0;
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
                  : widget.selected == kitty
                  ? CatMotion.happy
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
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
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
              ),
              Positioned(
                left: catSize * scale * .18,
                right: catSize * scale * .06,
                top: catSize * scale * .2,
                bottom: catSize * scale * .03,
                child: GestureDetector(
                  key: ValueKey('home-cat-${kitty.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onSelect(kitty),
                ),
              ),
            ],
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
        Paint()
          ..color = KoUi.homeShade
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    CatRig(
      cat: rig.cat,
      motion: rig.motion,
      direction: rig.direction,
      accessory: rig.accessory,
      time: time?.value,
    ).paint(canvas, pack, props: rig.motion != CatMotion.happy);
    canvas.restore();
  }

  @override
  bool shouldRepaint(HomeCatPainter old) => true;
}

class _RoomLayers extends CustomPainter {
  _RoomLayers(
    this.pack,
    ProgressController c,
    this.area, {
    this.background = true,
    this.items = true,
  }) : placed = c.household.areas.placed;
  final bool background, items;
  final ArtPack pack;
  final HomeArea area;
  final Map<RoomItemId, AreaSlot> placed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 390);
    if (background) {
      for (final layer in ['wall', 'floor']) {
        pack.paint(canvas, 'rooms/${area.name}-$layer');
      }
      if (area == HomeArea.santai) {
        paintLoungeLighting(canvas);
      }
      pack.paint(canvas, 'rooms/${area.name}-decor');
      // The lounge rug is structural, not an unowned catalogue purchase.
      if (area == HomeArea.santai || area == HomeArea.rawat) {
        const rug = Rect.fromLTWH(28, 265, 336, 112);
        canvas.drawOval(
          rug.shift(const Offset(0, 5)),
          Paint()
            ..color = KoUi.homeShade
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        final edge = Path();
        for (var i = 0; i <= 144; i++) {
          final t = i / 144 * math.pi * 2;
          final ripple = math.sin(t * 36) * 1.8;
          final x = 196 + (168 + ripple) * math.cos(t);
          final y = 321 + (56 + ripple) * math.sin(t);
          if (i == 0) {
            edge.moveTo(x, y);
          } else {
            edge.lineTo(x, y);
          }
        }
        edge.close();
        canvas.drawPath(edge, Paint()..color = KoUi.homeFloor);
        canvas.drawOval(
          rug.deflate(5),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [KoUi.homePaper, KoUi.homeCream],
            ).createShader(rug),
        );
        canvas.drawOval(
          rug.deflate(9),
          Paint()
            ..color = KoUi.homePeach
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        final wool = Paint()
          ..color = KoUi.homePeach
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 38; i++) {
          final t = i * 2.399;
          final d = math.sqrt((i + 1) / 40);
          final x = 196 + 145 * d * math.cos(t);
          final y = 321 + 44 * d * math.sin(t);
          canvas.drawPath(
            Path()
              ..moveTo(x - 3, y)
              ..quadraticBezierTo(x, y - 4, x + 3, y),
            wool,
          );
        }
      }
    }
    if (items) {
      for (final entry in placed.entries.where((e) => e.value.area == area)) {
        final id = entry.key;
        final slot = entry.value;
        final part = pack['items/${id.name}-back'];
        final dimension = slot.zone == RoomZone.wall ? 62.0 : 90.0;
        final scale = math.min(
          dimension / part.size.width,
          dimension / part.size.height,
        );
        final anchor = slot.anchor;
        final centerX = anchor.x * 390;
        final centerY = slot.zone == RoomZone.wall
            ? [35.0, 20.0, 30.0][slot.index]
            : slot.index < 2
            ? 281.0
            : 370.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: dimension * .75,
            height: slot.zone == RoomZone.floor ? 9 : 4,
          ),
          Paint()
            ..color = KoUi.homeShade
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        canvas.save();
        canvas.translate(
          centerX - part.size.width * scale / 2,
          centerY -
              part.size.height *
                  scale *
                  (slot.zone == RoomZone.floor ? .9 : .4),
        );
        canvas.scale(scale);
        pack.paint(canvas, 'items/${id.name}-back');
        pack.paint(canvas, 'items/${id.name}-front');
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoomLayers old) =>
      old.pack != pack ||
      old.area != area ||
      old.background != background ||
      old.items != items ||
      !identical(old.placed, placed);
}
