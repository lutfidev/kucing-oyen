import 'package:flutter/material.dart';

import '../../game/render/render.dart';
import '../../widgets/widgets.dart';
import '../room/room_geometry.dart';
import '../room/room_scene.dart';

/// Gang Depan dari bawah ke atas (catatan kanvas `kGang`): latar, daun
/// pintu pulang, cahaya tanah, bayangan, kucing yang lewat pintu
/// ([passing], di belakang kusen), kusen pintu pulang, bangku belakang,
/// kucing di bangku ([onBench]), bangku depan, kucing lain urut kaki
/// ([sprites]), lalu cahaya udara dan kupu-kupu.
///
/// [geo] = `RoomGeometry(size, HouseRoom.living)`: bukaan pintu pulang sama
/// dengan pintu teras ruang tengah, jadi `door`/`doorTap`-nya dipakai apa
/// adanya.
class LaneScene extends StatelessWidget {
  const LaneScene({
    super.key,
    required this.geo,
    this.time,
    this.homeDoorDeg = homeDoorRest,
    this.flapDeg = 0,
    this.butterflies = true,
    this.shadows = const [],
    this.passing = const [],
    this.onBench = const [],
    this.sprites = const [],
  });

  /// Pintu pulang diam: sedikit terbuka (`kGang`: 8°, tepi bebas x 363).
  static const homeDoorRest = 8.0;

  final RoomGeometry geo;

  /// Detik animasi lapisan; null = diam.
  final double? time;
  final double homeDoorDeg;

  /// Sudut pintu kucing pintu pulang; null = tanpa daun (kucing lewat).
  final double? flapDeg;

  /// Kupu-kupu di cahaya udara (`kupu` desain).
  final bool butterflies;
  final List<SceneShadow> shadows;
  final List<Widget> passing;
  final List<Widget> onBench;
  final List<Widget> sprites;

  @override
  Widget build(BuildContext context) {
    Widget layer(String key, LaneLayer layer) => Positioned.fill(
      key: ValueKey(key),
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(painter: _LanePainter(layer, time, butterflies)),
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        layer('lane-back', LaneLayer.back),
        Positioned.fill(
          key: const ValueKey('lane-home-door'),
          child: DoorLeafView(
            side: DoorLeafSide.home,
            angleDeg: homeDoorDeg,
            flapDeg: flapDeg,
          ),
        ),
        layer('lane-floor-light', LaneLayer.floorLight),
        Positioned.fill(
          key: const ValueKey('lane-shadows'),
          child: SceneShadowLayer(shadows: shadows, geo: geo),
        ),
        ...passing,
        layer('lane-frame', LaneLayer.frame),
        layer('lane-bench-back', LaneLayer.benchBack),
        ...onBench,
        layer('lane-bench-front', LaneLayer.benchFront),
        ...sprites,
        layer('lane-air', LaneLayer.airLight),
      ],
    );
  }
}

class _LanePainter extends CustomPainter {
  _LanePainter(this.layer, this.time, this.butterflies);

  final LaneLayer layer;
  final double? time;
  final bool butterflies;

  /// Lapisan diam (kusen, bangku) tidak ikut waktu.
  late final double? _time = laneLayerAnimated(layer) ? time : null;

  @override
  void paint(Canvas canvas, Size size) => paintLaneLayer(
    canvas,
    layer,
    size: size,
    time: _time,
    butterflies: butterflies,
  );

  @override
  bool shouldRepaint(_LanePainter old) =>
      old._time != _time ||
      old.layer != layer ||
      old.butterflies != butterflies;
}
