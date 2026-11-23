import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'room_geometry.dart';

/// Lama gerakan kamera ke gang atau pulang (`kKamera`), dan crossfade
/// pengganti saat gerak dikurangi.
const laneCameraMs = 1700.0;
const laneFadeMs = 240.0;

/// Batas tahap kamera (ms): mendekat, pintu terayun, melewati ambang,
/// menetap; gang mulai terlihat di bukaan pada [laneOpeningMs].
const _approachMs = 480.0;
const laneOpeningMs = 600.0;
const _swingMs = 860.0;
const _throughMs = 1400.0;

/// Chip "‹ Ruang tengah" memudar masuk 120 ms terakhir.
const _chipFadeMs = 120.0;

/// Titik desain (area rumah 390×652) yang dibawa kamera ke tengah layar:
/// pusat pintu depan dan pintu pulang, dan titik tengah tempat gang (atau
/// ruang tengah) di dalam bukaan diskalakan.
const frontDoorCenter = (x: 39.0, y: 346.0);
const homeDoorCenter = (x: 351.0, y: 346.0);
const laneCameraFocus = (x: 195.0, y: 330.0);

/// Bukaan pintu depan (dinding kiri ruang tengah) dan pintu pulang (dinding
/// kanan gang), titik desain urut `kPintuDepan`/`kGang`.
const frontDoorOpening = [
  (70.0, 212.0),
  (8.0, 203.0),
  (8.0, 489.0),
  (70.0, 403.0),
];
const homeDoorOpening = [
  (320.0, 212.0),
  (382.0, 203.0),
  (382.0, 489.0),
  (320.0, 403.0),
];

/// Zoom di tiap batas tahap: 1 → 1,6 (mendekat), → 2,1 saat pintu sampai
/// 70° (artboard 6c), → 5,4 (melewati ambang), → 6,5 saat bukaan sudah
/// melewati semua tepi layar (gang penuh tanpa potongan).
const _zooms = (1.0, 1.6, 2.1, 5.4, 6.5);

/// Sudut daun pintu: tertutup (depan) atau sedikit terbuka (pulang, 8°),
/// lalu 70° dan 88°.
const _doorOpen = 70.0;
const _doorWide = 88.0;

/// Skala tempat tujuan di dalam bukaan: 0,5 saat mulai terlihat, 0,92 saat
/// bukaan memenuhi layar, 1 di akhir.
const _sceneScales = (0.5, 0.92, 1.0);

/// Satu bingkai kamera.
class LaneCameraFrame {
  const LaneCameraFrame({
    required this.zoom,
    required this.focus,
    required this.door,
    required this.doorDeg,
    required this.laneScale,
    required this.laneInOpening,
    required this.laneFull,
    required this.chipOpacity,
  });

  /// Skala tempat asal di sekitar pusat pintu [door].
  final double zoom;

  /// Titik layar (desain) tempat pusat pintu digambar.
  final ({double x, double y}) focus;

  /// Pusat pintu (desain) yang dibawa ke [focus].
  final ({double x, double y}) door;

  /// Sudut daun pintu yang sedang dibuka.
  final double doorDeg;

  /// Skala tempat tujuan di sekitar [laneCameraFocus].
  final double laneScale;

  /// Tempat tujuan terlihat lewat bukaan (dipotong bentuk bukaan).
  final bool laneInOpening;

  /// Tempat tujuan sudah tampil penuh tanpa tempat asal (akhir).
  final bool laneFull;

  /// Opasitas chip "‹ Ruang tengah" (0–1).
  final double chipOpacity;

  /// Titik desain [x], [y] tempat asal sesudah gerakan kamera.
  ({double x, double y}) apply(double x, double y) =>
      (x: focus.x + zoom * (x - door.x), y: focus.y + zoom * (y - door.y));
}

double _part(double ms, double from, double to) =>
    ((ms - from) / (to - from)).clamp(0.0, 1.0);

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Bingkai kamera pada [ms] (0–[laneCameraMs]). [home] = pulang dari gang
/// lewat pintu pulang (dicerminkan, pintu mulai dari 8°).
LaneCameraFrame laneCameraAt(double ms, {required bool home}) {
  final door = home ? homeDoorCenter : frontDoorCenter;
  final approach = Curves.easeInOut.transform(_part(ms, 0, _approachMs));
  final double zoom;
  if (ms <= _approachMs) {
    zoom = _lerp(_zooms.$1, _zooms.$2, approach);
  } else if (ms <= _swingMs) {
    zoom = _lerp(_zooms.$2, _zooms.$3, _part(ms, _approachMs, _swingMs));
  } else if (ms <= _throughMs) {
    final t = Curves.easeIn.transform(_part(ms, _swingMs, _throughMs));
    zoom = _lerp(_zooms.$3, _zooms.$4, t);
  } else {
    final t = Curves.easeOut.transform(_part(ms, _throughMs, laneCameraMs));
    zoom = _lerp(_zooms.$4, _zooms.$5, t);
  }
  final focus = (
    x: _lerp(door.x, laneCameraFocus.x, approach),
    y: _lerp(door.y, laneCameraFocus.y, approach),
  );
  final closed = home ? LaneDoorAngles.homeRest : 0.0;
  final double doorDeg;
  if (ms <= _approachMs) {
    doorDeg = closed;
  } else if (ms <= _swingMs) {
    final t = Curves.easeOut.transform(_part(ms, _approachMs, _swingMs));
    doorDeg = _lerp(closed, _doorOpen, t);
  } else {
    final t = Curves.easeIn.transform(_part(ms, _swingMs, _throughMs));
    doorDeg = _lerp(_doorOpen, _doorWide, t);
  }
  final double laneScale;
  if (ms <= _swingMs) {
    laneScale = _sceneScales.$1;
  } else if (ms <= _throughMs) {
    laneScale = _lerp(
      _sceneScales.$1,
      _sceneScales.$2,
      Curves.easeIn.transform(_part(ms, _swingMs, _throughMs)),
    );
  } else {
    laneScale = _lerp(
      _sceneScales.$2,
      _sceneScales.$3,
      Curves.easeOut.transform(_part(ms, _throughMs, laneCameraMs)),
    );
  }
  return LaneCameraFrame(
    zoom: zoom,
    focus: focus,
    door: door,
    doorDeg: doorDeg,
    laneScale: laneScale,
    laneInOpening: ms >= laneOpeningMs && ms < laneCameraMs,
    laneFull: ms >= laneCameraMs,
    chipOpacity: _part(ms, laneCameraMs - _chipFadeMs, laneCameraMs),
  );
}

/// Sudut daun pintu yang diam.
abstract final class LaneDoorAngles {
  /// Pintu pulang di gang terbuka sedikit (`kGang`: 8°).
  static const homeRest = 8.0;
}

/// Gerakan kamera menembus pintu (desain 6 dan 12): tempat asal [from]
/// (dibangun dengan sudut daun pintu yang sedang dibuka) didekati dan
/// diperbesar di sekitar pintunya, lalu tempat tujuan [to] terlihat lewat
/// bukaan yang ikut bergerak dan membesar sampai memenuhi layar. Ketuk
/// selama berjalan = langsung ke akhir. Gerak dikurangi = crossfade
/// [laneFadeMs] tanpa zoom. [onOpen] saat pintu mulai terayun, [onDone]
/// sekali di akhir.
class LaneCamera extends StatefulWidget {
  const LaneCamera({
    super.key,
    required this.home,
    required this.from,
    required this.to,
    required this.geo,
    required this.onDone,
    this.onOpen,
    this.onFrame,
  });

  /// Pulang dari gang (pintu pulang), bukan ke gang (pintu depan).
  final bool home;

  /// Tempat asal dengan daun pintu pada sudut yang diberikan.
  final Widget Function(double doorDeg) from;

  /// Tempat tujuan seukuran area rumah.
  final Widget to;

  /// Geometri area rumah (ukuran layar dan skala desain).
  final RoomGeometry geo;

  final VoidCallback onDone;
  final VoidCallback? onOpen;

  /// Tiap bingkai (mis. untuk opasitas chip).
  final ValueChanged<LaneCameraFrame>? onFrame;

  @override
  State<LaneCamera> createState() => LaneCameraState();
}

class LaneCameraState extends State<LaneCamera>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  double _ms = 0;
  bool _opened = false;
  bool _done = false;
  bool _still = false;

  /// Bingkai yang sedang tampil.
  LaneCameraFrame get frame => laneCameraAt(_ms, home: widget.home);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (!_ticker.isActive && !_done) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final total = _still ? laneFadeMs : laneCameraMs;
    final ms = math.min(elapsed.inMicroseconds / 1000.0, total);
    _advance(_still ? ms / laneFadeMs * laneCameraMs : ms);
  }

  void _advance(double ms) {
    if (_done) return;
    setState(() => _ms = ms);
    widget.onFrame?.call(frame);
    if (!_opened && ms >= _approachMs) {
      _opened = true;
      if (!_still) widget.onOpen?.call();
    }
    if (ms >= laneCameraMs) {
      _done = true;
      _ticker.stop();
      // Sesudah bingkai ini: tempat tujuan menggantikan kamera.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDone();
      });
    }
  }

  /// Ketuk selama berjalan: langsung ke akhir.
  void skip() => _advance(laneCameraMs);

  Matrix4 _camera(LaneCameraFrame f) {
    final g = widget.geo;
    final focus = g.toScreen(f.focus.x, f.focus.y);
    final door = g.toScreen(f.door.x, f.door.y);
    return Matrix4.identity()
      ..translateByDouble(focus.dx, focus.dy, 0, 1)
      ..scaleByDouble(f.zoom, f.zoom, 1, 1)
      ..translateByDouble(-door.dx, -door.dy, 0, 1);
  }

  Matrix4 _scene(double scale) {
    final c = widget.geo.toScreen(laneCameraFocus.x, laneCameraFocus.y);
    return Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
  }

  /// Bukaan pintu di layar sesudah gerakan kamera.
  Path _opening(LaneCameraFrame f) {
    final g = widget.geo;
    final points = widget.home ? homeDoorOpening : frontDoorOpening;
    return Path()..addPolygon([
      for (final (x, y) in points)
        switch (f.apply(x, y)) {
          final p => g.toScreen(p.x, p.y),
        },
    ], true);
  }

  @override
  Widget build(BuildContext context) {
    final f = frame;
    final Widget body;
    if (_still) {
      final t = (_ms / laneCameraMs).clamp(0.0, 1.0);
      body = Stack(
        fit: StackFit.expand,
        children: [
          widget.from(widget.home ? LaneDoorAngles.homeRest : 0),
          FadeTransition(
            key: const ValueKey('lane-camera-fade'),
            opacity: AlwaysStoppedAnimation(t),
            child: widget.to,
          ),
        ],
      );
    } else if (f.laneFull) {
      body = widget.to;
    } else {
      body = Stack(
        fit: StackFit.expand,
        children: [
          Transform(
            key: const ValueKey('lane-camera-from'),
            transform: _camera(f),
            child: widget.from(f.doorDeg),
          ),
          if (f.laneInOpening)
            ClipPath(
              key: const ValueKey('lane-camera-opening'),
              clipper: _PathClipper(_opening(f)),
              child: Transform(
                transform: _scene(f.laneScale),
                child: widget.to,
              ),
            ),
        ],
      );
    }
    return GestureDetector(
      key: const ValueKey('lane-camera'),
      behavior: HitTestBehavior.opaque,
      onTap: skip,
      child: IgnorePointer(child: ClipRect(child: body)),
    );
  }
}

class _PathClipper extends CustomClipper<Path> {
  const _PathClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(_PathClipper old) => true;
}
