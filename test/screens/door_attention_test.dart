import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/screens/room/door_parts.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import 'room_fixtures.dart';

final _attention = find.byType(DoorAttention);

/// Kotak desain [design] (area rumah 390×652) di layar.
Rect _onScreen(WidgetTester tester, Rect design) {
  final (room, geo) = roomOf(tester);
  return geo.fromDesign(design).shift(room.topLeft);
}

void main() {
  testWidgets('Mochi lapar di teras: tanda lapar di pintu ruang tengah', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (90, 90),
        KittyId.mochi: (10, 90),
      }, home: Home(kitties: {KittyId.mochi})),
    );
    expect(_attention, findsOneWidget);
    final mark = find.descendant(
      of: _attention,
      matching: find.byType(SadMarkView),
    );
    expect(tester.widget<SadMarkView>(mark).hungry, isTrue);
    expect(
      tester.getRect(mark).topLeft,
      offsetMoreOrLessEquals(
        _onScreen(tester, const Rect.fromLTWH(327, 238, 48, 52)).topLeft,
      ),
    );
    expect(
      find.bySemanticsLabel('Ke teras. Mochi di teras lapar'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('hadiah koin Oyen di ruang tengah: gelembung di pintu teras', (
    tester,
  ) async {
    // Kurangi gerak: kamar hidup tanpa kucing berjalan.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final semantics = tester.ensureSemantics();
    await pumpRoom(
      tester,
      life: true,
      random: () => Random(1),
      progress: withNeeds({KittyId.oyen: (90, 90)}),
    );
    expect(_attention, findsNothing);
    await goThroughDoor(tester);
    expect(_attention, findsOneWidget);
    final bubble = find.descendant(
      of: _attention,
      matching: find.byType(CoinBubbleView),
    );
    expect(
      tester.getRect(bubble).topLeft,
      offsetMoreOrLessEquals(
        _onScreen(tester, const Rect.fromLTWH(7, 226, 64, 76)).topLeft,
      ),
    );
    expect(
      find.bySemanticsLabel('Ke ruang tengah. Ada hadiah koin dari Oyen'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('kucing lapar di ruangan yang dibuka: tanpa ikon pintu', (
    tester,
  ) async {
    await pumpRoom(tester, progress: withNeeds({KittyId.oyen: (10, 90)}));
    expect(find.byType(SadMarkView), findsOneWidget);
    expect(_attention, findsNothing);
  });

  testWidgets('saat menghias: tanpa ikon pintu', (tester) async {
    await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (90, 90),
        KittyId.mochi: (10, 90),
      }, home: Home(room: fullRoom(), kitties: {KittyId.mochi})),
    );
    expect(_attention, findsOneWidget);
    await tester.tap(find.text('Hias'));
    await tester.pumpAndSettle();
    expect(_attention, findsNothing);
  });
}
