import 'package:flutter/material.dart';

import '../../game/model/accessories.dart';
import '../../game/model/kitties.dart';
import '../../game/render/render.dart';
import '../../widgets/widgets.dart';

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
              child: KittyView(
                look: KittyLook(
                  kitty: KittyId.oyen,
                  pose: pose,
                  facing: facing,
                  accessory: accessory,
                  time: time,
                ),
                size: PictureMapArt.tokenSprite,
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
  void paint(Canvas canvas, Size size) => paintTokenBase(canvas);

  @override
  bool shouldRepaint(_Base old) => false;
}
