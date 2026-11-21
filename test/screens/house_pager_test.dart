import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

Finder _toTerrace() => find.bySemanticsLabel('Pergi ke teras');
Finder _toLiving() => find.bySemanticsLabel('Pergi ke ruang tengah');
Finder _chip() => find.text('Ruang tengah');
Finder _house(String room) => find.byKey(ValueKey('house-$room'));

/// Titik dinding belakang yang kosong (di bawah jendela), koordinat layar.
const _emptyWall = Offset(150, 330);

void main() {
  testWidgets('ketuk pintu: geser ke teras dalam 420 ms', (tester) async {
    await pumpRoom(tester);
    expect(_chip(), findsNothing);
    await tester.tap(_toTerrace());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pumpAndSettle();
    expect(_chip(), findsOneWidget);
    expect(_toLiving(), findsOneWidget);
    expect(_toTerrace(), findsNothing);
    expect(_house('living'), findsNothing);
  });

  testWidgets('di tengah transisi: ruang tengah keluar ke kiri, header diam', (
    tester,
  ) async {
    await pumpRoom(tester);
    final logo = tester.getRect(find.byType(GameLogo));
    final play = tester.getRect(find.text('Main'));
    await tester.tap(_toTerrace());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    expect(tester.getRect(_house('living')).left, closeTo(-195, 2));
    expect(tester.getRect(_house('terrace')).left, closeTo(195, 2));
    expect(tester.getRect(find.byType(GameLogo)), logo);
    expect(tester.getRect(find.text('Main')), play);
    // Chip "Ruang tengah" baru muncul di akhir transisi.
    expect(_chip(), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('geser pendek kembali, geser jauh pindah ke teras', (
    tester,
  ) async {
    await pumpRoom(tester);
    await tester.dragFrom(_emptyWall, const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(_chip(), findsNothing);
    expect(tester.getRect(_house('living')).left, 0);
    await tester.dragFrom(_emptyWall, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(_chip(), findsOneWidget);
    // Di teras, geser ke kiri tidak ke mana-mana.
    await tester.dragFrom(_emptyWall, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(_chip(), findsOneWidget);
    // Geser ke kanan kembali ke ruang tengah.
    await tester.dragFrom(_emptyWall, const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(_chip(), findsNothing);
    expect(_toTerrace(), findsOneWidget);
  });

  testWidgets('chip Ruang tengah membawa kembali', (tester) async {
    await pumpRoom(tester);
    await tester.tap(_toTerrace());
    await tester.pumpAndSettle();
    await tester.tap(_chip());
    await tester.pumpAndSettle();
    expect(_chip(), findsNothing);
    expect(tester.getRect(_house('living')).left, 0);
  });

  testWidgets('kurangi gerak: langsung pindah tanpa geser', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpRoom(tester);
    await tester.tap(_toTerrace());
    await tester.pump();
    expect(_chip(), findsOneWidget);
    expect(_house('living'), findsNothing);
  });

  testWidgets('mode Hias: pintu dan geser ruangan mati', (tester) async {
    await pumpRoom(
      tester,
      progress: testProgressWith(
        home: Home(room: Room().buy(RoomItemId.kardus)),
      ),
    );
    await tester.tap(find.text('Hias'));
    await tester.pumpAndSettle();
    expect(_toTerrace(), findsNothing);
    await tester.dragFrom(_emptyWall, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(_chip(), findsNothing);
    expect(tester.getRect(_house('living')).left, 0);
  });

  testWidgets('tombol kembali sistem di teras tidak pindah ruangan', (
    tester,
  ) async {
    await pumpRoom(tester);
    await tester.tap(_toTerrace());
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_chip(), findsOneWidget);
  });
}
