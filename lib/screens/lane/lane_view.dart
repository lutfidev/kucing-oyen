import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/accessories.dart';
import '../../game/model/house.dart';
import '../../game/model/kitties.dart';
import '../../game/model/lane.dart';
import '../../game/model/lane_life.dart';
import '../../game/model/neighbor.dart';
import '../../game/model/room_life.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../widgets/widgets.dart';
import '../room/door_parts.dart';
import '../room/lane_camera.dart';
import '../room/room_geometry.dart';
import '../room/room_scene.dart';
import 'lane_scene.dart';

/// Langkah kaki kucing yang lewat pintu kucing pintu pulang (px desain):
/// dari titik kaki [laneFlapFeet] ke balik dinding kanan.
const laneFlapWalk = 60.0;

/// Kotak sprite [actor] di gang [geo] (px layar): titik kakinya, skala
/// kedalaman gang ([laneScale] dari [LaneActor.scaleY]), lompatan bangku
/// melengkung [catHopArc], dan langkah lewat pintu kucing.
Rect laneCatBox(RoomGeometry geo, LaneActor actor) {
  final base = actor.cat == LaneCat.oyen ? oyenRoomSize : kittyRoomSize;
  var x = actor.x;
  var y = actor.y;
  var scaleY = actor.scaleY;
  var lift = 0.0;
  final from = actor.hopFrom;
  final to = actor.hopTo;
  if (actor.isHopping && from != null && to != null) {
    final t = actor.hopProgress;
    final up = actor.activity == CatActivity.climbing;
    x = from.x + (to.x - from.x) * t;
    y = from.y + (to.y - from.y) * t;
    final fromScale = up ? from.y : laneBenchScaleY;
    final toScale = up ? laneBenchScaleY : to.y;
    scaleY = fromScale + (toScale - fromScale) * t;
    lift = catHopArc * math.sin(math.pi * t);
  } else if (actor.isPassing && actor.viaFlap) {
    final t = actor.doorProgress;
    final out = actor.activity == CatActivity.leaving ? t : 1 - t;
    x = laneFlapFeet.x + laneFlapWalk * out;
    y = laneFlapFeet.y;
    scaleY = y;
  }
  final size = base * laneScale(scaleY) * geo.artScale;
  final feet = geo.toScreen(x, y) - Offset(0, lift * geo.artScale);
  return Rect.fromLTWH(
    feet.dx - size / 2,
    feet.dy - size * catFeetFactor,
    size,
    size,
  );
}

/// Pose sprite [actor] (pose gang menggantikan pose biasa).
KittyPose laneKittyPose(LaneActor actor) => switch (actor.lanePose) {
  LanePose.sniff => KittyPose.endus,
  LanePose.shift => KittyLook.shiftPose(actor.elapsed),
  LanePose.play => KittyPose.play,
  null => switch (actor.pose) {
    LifePose.idle => KittyPose.idle,
    LifePose.lick => KittyPose.lick,
    LifePose.walk => KittyLook.walkPose(actor.elapsed),
    LifePose.sad => KittyPose.lesu,
    LifePose.happy => KittyPose.happy,
    LifePose.petted => KittyPose.petted,
    LifePose.eat => KittyPose.eat,
    LifePose.sleep => KittyPose.sleep,
    LifePose.lounge => KittyPose.rebah,
  },
};

KittyFacing _facing(LifeHeading heading) => switch (heading) {
  LifeHeading.down => KittyFacing.down,
  LifeHeading.left => KittyFacing.left,
  LifeHeading.right => KittyFacing.right,
};

/// Gang Depan (desain 7–13): latar dan pintu pulang ([LaneScene]), Oyen dan
/// Kumis dari [life] (di bangku di antara dua lapisan bangku, lewat pintu
/// kucing di belakang kusen), tombol pintu pulang, dan ketuk kucing.
/// [time] = detik animasi, null = diam.
class LaneView extends StatelessWidget {
  const LaneView({
    super.key,
    required this.geo,
    required this.life,
    required this.time,
    required this.onOyen,
    required this.onKumis,
    required this.onHome,
    this.oyenAccessory,
    this.oyenLabel,
    this.homeDeg = LaneDoorAngles.homeRest,
    this.boxes,
  });

  final RoomGeometry geo;
  final LaneLife life;
  final double? time;
  final VoidCallback onOyen;
  final VoidCallback onKumis;
  final VoidCallback onHome;
  final AccessoryId? oyenAccessory;

  /// Label pembaca layar Oyen (ketuk untuk kartu); null = nama dan pose.
  final String? oyenLabel;

  /// Sudut pintu pulang (8° diam, lebih lebar selama kamera pulang).
  final double homeDeg;

  /// Diisi kotak tiap kucing yang tampil (untuk letak reaksi).
  final Map<LaneCat, Rect>? boxes;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final unit = geo.artScale;
    final ground = <(double, Widget)>[];
    final bench = <Widget>[];
    final passing = <Widget>[];
    final shadows = <SceneShadow>[];
    final targets = <DoorCoverTarget>[];
    double? flapDeg = 0;
    for (final actor in life.actors) {
      final box = laneCatBox(geo, actor);
      boxes?[actor.cat] = box;
      final oyen = actor.cat == LaneCat.oyen;
      final look = KittyLook(
        kitty: oyen ? KittyId.oyen : null,
        neighbor: oyen ? null : Neighbor.kumis,
        pose: laneKittyPose(actor),
        facing: _facing(actor.heading),
        accessory: oyen ? oyenAccessory : null,
        bowl: false,
        time: time,
      );
      final label = oyen
          ? oyenLabel ?? kittyLabel(l, look)
          : l.neighborTapHint(neighborName(l, Neighbor.kumis));
      Widget sprite = Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: oyen ? onOyen : onKumis,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: oyen ? onOyen : onKumis,
          child: KittyView(look: look, size: box.width),
        ),
      );
      if (actor.alpha < 1) {
        sprite = Opacity(opacity: actor.alpha.clamp(0.0, 1.0), child: sprite);
      }
      final key = ValueKey(oyen ? 'lane-oyen' : 'lane-kumis');
      if (actor.isPassing && actor.viaFlap) {
        flapDeg = null;
        passing.add(
          Positioned.fromRect(
            key: key,
            rect: box,
            child: ClipRect(
              clipper: _KeepLeft(laneFlapClipX * geo.sx - box.left),
              child: ExcludeSemantics(child: IgnorePointer(child: sprite)),
            ),
          ),
        );
        continue;
      }
      final positioned = Positioned.fromRect(
        key: key,
        rect: box,
        child: sprite,
      );
      if (actor.onBench && !actor.isHopping) {
        bench.add(positioned);
      } else {
        final feet = geo.feetOf(box);
        ground.add((feet, positioned));
        if (!actor.isHopping) {
          shadows.add(SceneShadow.ofCat(box, feet, unit: unit));
        }
        targets.add(
          DoorCoverTarget(
            Rect.fromLTRB(
              box.left / geo.sx,
              box.top / geo.sy,
              box.right / geo.sx,
              box.bottom / geo.sy,
            ),
            feet: feet / geo.sy,
            depth: DoorCoverTarget.upright,
          ),
        );
      }
    }
    ground.sort((a, b) => a.$1.compareTo(b.$1));
    return Stack(
      key: const ValueKey('lane'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: LaneScene(
            geo: geo,
            time: time,
            homeDoorDeg: homeDeg,
            flapDeg: flapDeg,
            butterflies: life.butterflies || life.actors.isEmpty,
            shadows: shadows,
            // Pintu di bawah kucing: kucing di ambang tetap bisa diketuk.
            passing: [
              DoorButton(
                key: const ValueKey('lane-home-door-button'),
                geo: geo,
                label: l.laneHomeDoor,
                onTap: onHome,
              ),
              ...passing,
            ],
            onBench: bench,
            sprites: [for (final (_, sprite) in ground) sprite],
            // Pintu pulang yang terbuka (kamera pulang) menutup kucing di
            // belakang bidang daunnya.
            cover: [
              if (homeDeg > LaneDoorAngles.homeRest)
                Positioned.fill(
                  child: DoorLeafCoverView(
                    side: DoorLeafSide.home,
                    angleDeg: homeDeg,
                    targets: targets,
                  ),
                ),
            ],
          ),
        ),
        // Kepulan endus di atas cahaya udara (desain z 890).
        if (life.puff)
          const Positioned.fill(child: IgnorePointer(child: LanePuffView())),
      ],
    );
  }
}

/// Menyisakan bagian kucing di kiri garis pintu kucing [right] (lokal):
/// bagian kanannya sudah di dalam rumah.
class _KeepLeft extends CustomClipper<Rect> {
  const _KeepLeft(this.right);

  final double right;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-size.width, -size.height, right, size.height * 2);

  @override
  bool shouldReclip(_KeepLeft old) => old.right != right;
}
