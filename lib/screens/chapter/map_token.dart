import 'package:flutter/material.dart';

import '../../game/model/accessories.dart';
import '../../game/render/render.dart';
import '../../game/render/v2/cat_rig.dart';
import '../../game/render/v2/journey_art.dart';

/// Token Oyen di peta (desain 23, `TokenOyenPeta.dc.html`): alas elips dan
/// sprite Oyen 56 px di kotak 64×76. Hiasan saja; node saat ini sudah
/// dibacakan "main sekarang".
class MapToken extends StatelessWidget {
  const MapToken({
    super.key,
    required this.pose,
    required this.facing,
    this.accessory,
    this.time,
  });

  final KittyPose pose;
  final KittyFacing facing;

  /// Aksesoris yang sedang dipakai Oyen di rumah.
  final AccessoryId? accessory;

  /// Detik animasi sprite (kedip, ekor); null = diam.
  final double? time;

  @override
  Widget build(BuildContext context) {
    const at = PictureMapArt.tokenSpriteAt;
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: PictureMapArt.tokenSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: CustomPaint(painter: _Base())),
            Positioned(
              left: at.dx,
              top: at.dy,
              child: CustomPaint(
                size: const Size.square(PictureMapArt.tokenSprite),
                painter: _Cat(pose, facing, accessory, time),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Base extends CustomPainter {
  const _Base();

  @override
  void paint(Canvas canvas, Size size) => canvas.drawOval(
    const Rect.fromLTWH(5, 57, 54, 12),
    Paint()..color = const Color(0x33573018),
  );

  @override
  bool shouldRepaint(_Base old) => false;
}

class _Cat extends CustomPainter {
  const _Cat(this.pose, this.facing, this.accessory, this.time);
  final KittyPose pose;
  final KittyFacing facing;
  final AccessoryId? accessory;
  final double? time;
  @override
  void paint(Canvas canvas, Size size) => JourneyArt.cat(
    canvas,
    Offset.zero & size,
    motion: switch (pose) {
      KittyPose.walk1 || KittyPose.walk2 => CatMotion.walk,
      KittyPose.happy => CatMotion.happy,
      _ => CatMotion.idle,
    },
    direction: switch (facing) {
      KittyFacing.left => CatDirection.left,
      KittyFacing.right => CatDirection.right,
      _ => CatDirection.front,
    },
    accessory: accessory,
    time: time,
  );
  @override
  bool shouldRepaint(_Cat old) =>
      old.pose != pose ||
      old.facing != facing ||
      old.accessory != accessory ||
      old.time != time;
}
