import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/progress_scope.dart';
import '../../app/game_audio.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_items.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
import '../../game/model/sounds.dart';
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
    this.onBowl,
    this.onToy,
    this.onCare,
  });
  final ArtPack pack;
  final ProgressController progress;
  final HomeArea area;
  final KittyId? selected;
  final ValueChanged<KittyId> onSelect;
  final bool animate;
  final ImageProvider sceneryProvider;
  final VoidCallback? onBowl;
  final VoidCallback? onToy;
  final VoidCallback? onCare;

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene>
    with SingleTickerProviderStateMixin {
  final _time = ValueNotifier<double>(0);
  Duration? _lastTick;
  Map<KittyId, int> _heard = {};
  late final Ticker _ticker = createTicker((elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (!widget.progress.householdPaused) {
      if (last != null) {
        _time.value += (elapsed - last).inMicroseconds / 1e6;
      }
    }
  });

  @override
  void initState() {
    super.initState();
    widget.progress.householdPauseChanges.addListener(_sync);
    _rememberActivities();
  }

  void _rememberActivities() => _heard = {
    for (final e in widget.progress.household.routine.activities.entries)
      e.key: e.value.id,
  };

  void _hearActivity(HomeScene old) {
    final c = widget.progress;
    if (old.area == widget.area &&
        !c.householdPaused &&
        !c.householdSaveFailed &&
        TickerMode.valuesOf(context).enabled) {
      for (final entry in c.household.routine.activities.entries) {
        final action = entry.value;
        if (_heard[entry.key] == action.id || action.kind.area != widget.area) {
          continue;
        }
        final sound = switch (action.kind) {
          HomeActivity.eat => GameSound.munch,
          HomeActivity.pet || HomeActivity.brush => GameSound.purr,
          HomeActivity.play => GameSound.meow,
          HomeActivity.rest => null,
        };
        if (sound != null) AudioScope.maybeRead(context)?.play(sound);
        break; // At most one foreground activity cue per published snapshot.
      }
    }
    _rememberActivities();
  }

  void _sync() {
    final run =
        widget.animate &&
        !widget.progress.householdPaused &&
        !widget.progress.householdSaveFailed &&
        TickerMode.valuesOf(context).enabled;
    if (run && !_ticker.isActive) {
      _lastTick = null;
      _ticker.start();
    }
    if (!run && _ticker.isActive) {
      _ticker.stop();
      _lastTick = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(HomeScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hearActivity(oldWidget);
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
          if (!constraints.hasBoundedWidth ||
              !constraints.hasBoundedHeight ||
              constraints.maxWidth <= 0 ||
              constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }
          final scale = constraints.maxWidth / 390;
          return Stack(
            key: const ValueKey('home-scene'),
            children: [
              if (widget.area == HomeArea.santai ||
                  widget.area == HomeArea.makan ||
                  widget.area == HomeArea.main ||
                  widget.area == HomeArea.rawat)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Image(
                      key: ValueKey(
                        widget.area == HomeArea.rawat
                            ? 'care-painted-backdrop'
                            : widget.area == HomeArea.santai
                            ? 'home-painted-backdrop'
                            : widget.area == HomeArea.main
                            ? 'play-painted-backdrop'
                            : 'dining-painted-backdrop',
                      ),
                      image: widget.area == HomeArea.rawat
                          ? PaintedScenery.care
                          : widget.area == HomeArea.main
                          ? PaintedScenery.play
                          : widget.area == HomeArea.makan
                          ? PaintedScenery.dining
                          : widget.sceneryProvider,
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
                      background:
                          widget.area != HomeArea.santai &&
                          widget.area != HomeArea.makan &&
                          widget.area != HomeArea.main &&
                          widget.area != HomeArea.rawat,
                    ),
                  ),
                ),
              ),
              if (widget.area == HomeArea.main)
                Positioned(
                  left: 195 * scale,
                  top: constraints.maxHeight * .88 - 56 * scale,
                  width: math.max(48, 56 * scale),
                  height: math.max(48, 56 * scale),
                  child: Semantics(
                    button: true,
                    label: roomItemName(context.l10n, c.playing.toy),
                    child: Tooltip(
                      message: context.l10n.playChoose,
                      child: GestureDetector(
                        key: const ValueKey('play-toy'),
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onToy,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: PlayToyPainter(
                              widget.pack,
                              c.playing.toy,
                              time: widget.animate && c.playing.playing != null
                                  ? _time
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.area == HomeArea.rawat) ...[
                Positioned(
                  left: 26 * scale,
                  top: constraints.maxHeight * .88 - 24 * scale,
                  width: 184 * scale,
                  height: 38 * scale,
                  child: const IgnorePointer(
                    child: CustomPaint(painter: CareMatPainter()),
                  ),
                ),
                Positioned(
                  left: 195 * scale,
                  top: constraints.maxHeight * .88 - 56 * scale,
                  width: 48,
                  height: 48,
                  child: Tooltip(
                    message: context.l10n.careChoose,
                    child: Semantics(
                      label: context.l10n.careChoose,
                      button: true,
                      child: InkWell(
                        key: const ValueKey('care-brush'),
                        onTap: widget.onCare,
                        borderRadius: BorderRadius.circular(KoUi.buttonRadius),
                        child: const Icon(
                          Icons.brush_rounded,
                          color: KoUi.ink,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              for (var i = 0; i < cats.length; i++)
                _cat(
                  context,
                  cats[i],
                  i,
                  cats.length,
                  scale,
                  constraints.maxHeight,
                ),
              if (widget.area == HomeArea.makan)
                Positioned(
                  left: 67 * scale,
                  top: constraints.maxHeight * .88 - 70 * scale,
                  width: 112 * scale,
                  height: 112 * scale,
                  child: Semantics(
                    button: true,
                    label: context.l10n.roomItemMangkuk,
                    child: Tooltip(
                      message: context.l10n.diningChoose,
                      child: GestureDetector(
                        key: const ValueKey('dining-bowl'),
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onBowl,
                        child: CustomPaint(
                          painter: DiningBowlPainter(
                            widget.pack,
                            empty: c.dining.portionsLeft == 0,
                          ),
                        ),
                      ),
                    ),
                  ),
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
    final facilityArea =
        widget.area == HomeArea.makan ||
        widget.area == HomeArea.main ||
        widget.area == HomeArea.rawat;
    final eater = widget.area == HomeArea.rawat
        ? c.caring.using
        : widget.area == HomeArea.main
        ? c.playing.playing
        : c.dining.eating;
    final first = eater ?? _facilityLead(r, widget.area);
    final atFacility = facilityArea && kitty == first;
    final catSize = facilityArea
        ? (atFacility ? 168.0 : 140.0)
        : count == 1
        ? 205.0
        : count == 2
        ? 168.0
        : index == 0
        ? 176.0
        : index == 1
        ? 130.0
        : 124.0;
    // Three safe, separate foreground slots, with room left for the doorway.
    final x = facilityArea
        ? (atFacility ? (widget.area == HomeArea.makan ? 39.0 : 35.0) : 228.0)
        : count == 1
        ? 94.0
        : count == 2
        ? 22.0 + index * 172
        : index == 0
        ? 108.0
        : index == 1
        ? -3.0
        : 263.0;
    var y = facilityArea
        ? ((height * (atFacility ? .88 : .82) - (catSize + 16) * scale) /
              height *
              390)
        : count == 3 && index == 2
        ? 228.0
        : 271.0;
    var dx = x;
    var direction = CatDirection.front;
    for (final trip in r.journeys.where((j) => j.cats.contains(kitty))) {
      if (!widget.animate) continue;
      if (facilityArea && trip.from == trip.to) {
        // Already in this area: approach the facility from the waiting spot, rather
        // than walking out to the doorway and back.
        dx = 228 + (x - 228) * trip.elapsed;
        direction = CatDirection.left;
        continue;
      }
      // The same cat is only painted by its current slot owner, including
      // paired swaps. At the threshold it appears at the destination door.
      final t = trip.committed ? (trip.elapsed - .5) * 2 : trip.elapsed * 2;
      final door = 390 - catSize - KoUi.s8;
      dx = trip.committed ? door + (x - door) * t : x + (door - x) * t;
      direction = trip.committed ? CatDirection.left : CatDirection.right;
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
    return _CatPosition(
      key: ValueKey('home-position-${kitty.name}'),
      roomHeight: height,
      scale: scale,
      atFacility: atFacility,
      duration: facilityArea && widget.animate && !moving
          ? const Duration(milliseconds: 350)
          : Duration.zero,
      left: dx * scale,
      top: math.min(
        y * height / 390,
        height - (catSize + 16) * scale - KoUi.s8,
      ),
      width: catSize * scale,
      height: (catSize + 16) * scale,
      child: LayoutBuilder(
        builder: (context, box) => Semantics(
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
                            direction: direction,
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
                  left: box.maxWidth * .18,
                  right: box.maxWidth * .06,
                  top: box.maxWidth * .2,
                  bottom: box.maxWidth * .03,
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
      ),
    );
  }
}

/// Both cats use different depth lanes during a facility handoff. At the
/// crossing, the incoming cat walks behind the outgoing one; smaller walking
/// silhouettes preserve separate touch targets even in the 240dp room.
class _CatPosition extends ImplicitlyAnimatedWidget {
  const _CatPosition({
    super.key,
    required super.duration,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.roomHeight,
    required this.scale,
    required this.atFacility,
    required this.child,
  }) : super(curve: Curves.easeInOut);
  final double left, top, width, height, roomHeight, scale;
  final bool atFacility;
  final Widget child;
  @override
  AnimatedWidgetBaseState<_CatPosition> createState() => _CatPositionState();
}

class _CatPositionState extends AnimatedWidgetBaseState<_CatPosition> {
  RectTween? _rect;
  bool _crossing = false;
  @override
  void didUpdateWidget(_CatPosition oldWidget) {
    if (oldWidget.left != widget.left) {
      _crossing =
          (oldWidget.left - widget.left).abs() > 100 * widget.scale &&
          widget.duration != Duration.zero;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final target = Rect.fromLTWH(
      widget.left,
      widget.top,
      widget.width,
      widget.height,
    );
    _rect = visitor(
      _rect,
      target,
      (value) => RectTween(begin: value as Rect),
    ) as RectTween?;
  }

  @override
  Widget build(BuildContext context) {
    var rect = widget.duration == Duration.zero
        ? Rect.fromLTWH(widget.left, widget.top, widget.width, widget.height)
        : _rect!.evaluate(animation)!;
    if (_crossing && widget.duration != Duration.zero) {
      final arc = math.min(1.0, math.sin(animation.value * math.pi) * 1.25);
      final shrink = math.min(
        rect.width - 76 * widget.scale,
        arc * (widget.atFacility ? 78 : 70) * widget.scale,
      );
      final laneFeet = widget.atFacility
          ? widget.roomHeight * .65
          : widget.roomHeight - KoUi.s8;
      final feet = rect.bottom + (laneFeet - rect.bottom) * arc;
      rect = Rect.fromLTWH(
        rect.left,
        feet - rect.height + shrink,
        rect.width - shrink,
        rect.height - shrink,
      );
    }
    return Positioned.fromRect(rect: rect, child: widget.child);
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
    ).paint(
      canvas,
      pack,
      props:
          rig.motion != CatMotion.happy &&
          rig.motion != CatMotion.eat &&
          rig.motion != CatMotion.play,
    );
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
  }) : placed = c.household.areas.placed,
       playToy = c.playing.toy;
  final bool background, items;
  final ArtPack pack;
  final HomeArea area;
  final Map<RoomItemId, AreaSlot> placed;
  final RoomItemId playToy;

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
        if (area == HomeArea.makan && id == RoomItemId.mangkuk) continue;
        if (area == HomeArea.main && id == playToy) continue;
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
      old.playToy != playToy ||
      !identical(old.placed, placed);
}

KittyId? _facilityLead(HomeRoutine routine, HomeArea area) {
  final present = routine.present(area);
  return routine.queueFor(area).where(present.contains).firstOrNull ??
      present.firstOrNull;
}

/// One model-owned bowl, drawn in front of the eating cat. No rig prop copy.
class DiningBowlPainter extends CustomPainter {
  DiningBowlPainter(this.pack, {required this.empty});
  final ArtPack pack;
  final bool empty;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 128, size.height / 128);
    canvas.drawOval(
      const Rect.fromLTWH(20, 104, 90, 16),
      Paint()..color = KoUi.homeShade,
    );
    if (empty) {
      canvas.drawOval(
        const Rect.fromLTWH(21, 68, 86, 30),
        Paint()..color = const Color(0xFFEEB871),
      );
      canvas.drawOval(
        const Rect.fromLTWH(32, 72, 64, 18),
        Paint()..color = const Color(0xFF90603B),
      );
    } else {
      pack.paint(canvas, 'items/mangkuk-back');
    }
    pack.paint(canvas, 'items/mangkuk-front');
    canvas.restore();
  }

  @override
  bool shouldRepaint(DiningBowlPainter old) =>
      old.pack != pack || old.empty != empty;
}

/// One shared model-selected toy; the cat rig supplies movement, no extra ball.
class PlayToyPainter extends CustomPainter {
  PlayToyPainter(this.pack, this.toy, {this.time}) : super(repaint: time);
  final ArtPack pack;
  final RoomItemId toy;
  final ValueNotifier<double>? time;

  @override
  void paint(Canvas canvas, Size size) {
    final part = pack['items/${toy.name}-back'];
    final phase = time?.value ?? 0;
    final loose =
        toy == RoomItemId.bola ||
        toy == RoomItemId.tikus ||
        toy == RoomItemId.catnip;
    final wave = time == null ? 0.0 : math.sin(phase * math.pi * 2 / .8);
    final dimension = size.shortestSide * (loose ? 1.25 : .94);
    final scale = math.min(
      dimension / part.size.width,
      dimension / part.size.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - part.size.width * scale) / 2 + (loose ? wave * 4 : 0),
      size.height - part.size.height * scale - 5,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        0,
        part.size.height * scale - 3,
        part.size.width * scale,
        6,
      ),
      Paint()..color = KoUi.homeShade,
    );
    canvas.scale(scale);
    pack.paint(canvas, 'items/${toy.name}-back');
    pack.paint(canvas, 'items/${toy.name}-front');
    canvas.restore();
  }

  @override
  bool shouldRepaint(PlayToyPainter old) =>
      old.pack != pack || old.toy != toy || old.time != time;
}

/// Structural free grooming mat; it never grants a second activity slot.
class CareMatPainter extends CustomPainter {
  const CareMatPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(
      rect.shift(const Offset(0, 3)),
      Paint()..color = KoUi.homeShade,
    );
    canvas.drawOval(rect, Paint()..color = KoUi.homePeach);
    canvas.drawOval(rect.deflate(4), Paint()..color = KoUi.homeCream);
    canvas.drawOval(rect.deflate(7), Paint()..color = KoUi.homePaper);
  }

  @override
  bool shouldRepaint(CareMatPainter old) => false;
}
