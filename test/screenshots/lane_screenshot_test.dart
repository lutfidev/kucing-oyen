// Potret Gang Depan (langkah 36): gang belum bisa dibuka dari kamar
// (langkah 38), jadi LaneScene digambar langsung di area rumah 390×652.
//   flutter test test/screenshots/lane_screenshot_test.dart --dart-define=SCREENSHOTS=true
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/neighbor.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/lane/lane_scene.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'capture.dart';

const _area = Size(390, 652);

/// Kucing duduk di bangku seperti `AdeganGang` (`seat`): kaki y 396,5,
/// skala dari lantai y [laneBenchScaleY].
Widget _seated(KittyLook look, double x, double size) {
  final px = size * laneScale(laneBenchScaleY);
  return Positioned(
    left: x - px / 2,
    top: laneBenchLeft.y - catFeetFactor * px,
    width: px,
    height: px,
    child: KittyView(look: look, size: px),
  );
}

Future<void> _pumpLane(
  WidgetTester tester, {
  List<Widget> onBench = const [],
}) async {
  setScreenSize(tester, _area);
  await tester.pumpWidget(
    capturable(
      testApp(
        home: SizedBox.fromSize(
          size: _area,
          child: LaneScene(
            geo: RoomGeometry(_area, HouseRoom.living),
            onBench: onBench,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('390x844/36-gang-utama', (tester) async {
    await withShadows(() async {
      await _pumpLane(
        tester,
        onBench: [
          _seated(
            const KittyLook(kitty: KittyId.oyen),
            laneBenchLeft.x,
            oyenRoomSize,
          ),
          _seated(
            const KittyLook(neighbor: Neighbor.kumis, facing: KittyFacing.left),
            laneBenchRight.x,
            kittyRoomSize,
          ),
        ],
      );
      await capture(tester, '390x844/36-gang-utama');
    });
  }, skip: !screenshotsEnabled);

  testWidgets('390x844/36-gang-kosong', (tester) async {
    await withShadows(() async {
      await _pumpLane(tester);
      await capture(tester, '390x844/36-gang-kosong');
    });
  }, skip: !screenshotsEnabled);

  testWidgets('390x844/36-kumis-pose', (tester) async {
    setScreenSize(tester, const Size(390, 120));
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(
          testApp(
            home: Row(
              children: [
                for (final pose in [
                  KittyPose.idle,
                  KittyPose.endus,
                  KittyPose.geser1,
                  KittyPose.geser2,
                  KittyPose.sleep,
                ])
                  KittyView(
                    look: KittyLook(neighbor: Neighbor.kumis, pose: pose),
                    size: 78,
                  ),
              ],
            ),
          ),
        ),
      );
      await capture(tester, '390x844/36-kumis-pose');
    });
  }, skip: !screenshotsEnabled);
}
