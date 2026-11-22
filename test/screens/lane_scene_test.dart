import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/render/door_leaf.dart';
import 'package:kucing_oren/screens/lane/lane_scene.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Urutan anak [Stack] terluar [LaneScene] menurut kuncinya.
List<String> _order(WidgetTester tester) {
  final stack = tester.widget<Stack>(
    find
        .descendant(of: find.byType(LaneScene), matching: find.byType(Stack))
        .first,
  );
  return [
    for (final child in stack.children)
      if (child.key case ValueKey<String>(:final value)) value,
  ];
}

void main() {
  testWidgets('lapisan gang urut desain (kGang)', (tester) async {
    await tester.pumpWidget(
      testApp(
        home: SizedBox(
          width: 390,
          height: 652,
          child: LaneScene(
            geo: RoomGeometry(const Size(390, 652), HouseRoom.living),
            passing: const [SizedBox(key: ValueKey('lane-passing'))],
            onBench: const [SizedBox(key: ValueKey('lane-on-bench'))],
            sprites: const [SizedBox(key: ValueKey('lane-sprite'))],
          ),
        ),
      ),
    );
    expect(_order(tester), [
      'lane-back',
      'lane-home-door',
      'lane-floor-light',
      'lane-shadows',
      'lane-passing',
      'lane-frame',
      'lane-bench-back',
      'lane-on-bench',
      'lane-bench-front',
      'lane-sprite',
      'lane-air',
    ]);
    // Pintu pulang sedikit terbuka (8°) dengan pintu kucing tertutup.
    final door = tester.widget<DoorLeafView>(find.byType(DoorLeafView));
    expect(door.side, DoorLeafSide.home);
    expect(door.angleDeg, 8);
    expect(door.flapDeg, 0);
  });
}
