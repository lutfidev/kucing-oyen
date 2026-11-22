import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/room/door_parts.dart';
import 'package:kucing_oren/screens/room/house_pager.dart';
import 'package:kucing_oren/screens/room/room_scene.dart';
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

  testWidgets('tombol Hias ada di kedua ruangan', (tester) async {
    await pumpRoom(
      tester,
      progress: testProgressWith(
        home: Home(room: Room().buy(RoomItemId.kardus)),
      ),
    );
    expect(find.text('Hias'), findsOneWidget);
    await tester.tap(_toTerrace());
    await tester.pumpAndSettle();
    expect(find.text('Hias'), findsOneWidget);
    await tester.tap(_chip());
    await tester.pumpAndSettle();
    expect(find.text('Hias'), findsOneWidget);
  });

  testWidgets('kucing di depan pintu tetap bisa diketuk', (tester) async {
    // Tempat awal kucing tidak di depan pintu, jadi diperiksa susunan
    // lapisannya: pintu di lapisan lantai, di bawah semua kucing.
    await pumpRoom(
      tester,
      progress: testProgressWith(home: Home(kitties: allKitties)),
    );
    final scene = tester.widget<RoomScene>(find.byType(RoomScene));
    expect(scene.floor.whereType<DoorButton>(), hasLength(1));
    expect(scene.sprites.where((w) => w.key is ValueKey<KittyId>), isNotEmpty);
    final (room, geo) = roomOf(tester);
    final door = geo.doorTap.shift(room.topLeft);
    final oyen = tester.getRect(kittyView(KittyId.oyen));
    expect(oyen.overlaps(door), isFalse);
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pumpAndSettle();
    expect(find.text('Elus'), findsOneWidget);
    expect(_chip(), findsNothing);
  });

  group('HousePager langsung', () {
    Future<ValueNotifier<(HouseRoom, bool)>> pumpPager(
      WidgetTester tester,
      List<HouseRoom> moved,
    ) async {
      final state = ValueNotifier((HouseRoom.living, true));
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder(
            valueListenable: state,
            builder: (context, value, _) => HousePager(
              room: value.$1,
              enabled: value.$2,
              onRoom: (room) {
                moved.add(room);
                state.value = (room, state.value.$2);
              },
              builder: (context, room) => ColoredBox(
                color: const Color(0xFF000000),
                child: Text(room.name),
              ),
            ),
          ),
        ),
      );
      return state;
    }

    testWidgets('geser jauh lalu lempar balik: tetap di ruangan', (
      tester,
    ) async {
      final moved = <HouseRoom>[];
      await pumpPager(tester, moved);
      final gesture = await tester.startGesture(const Offset(780, 300));
      // 40% lebar layar test (800 px): lewat sepertiga.
      // Cap waktu eksplisit: tanpa itu kecepatan lepas selalu 0 di test.
      var ms = 0;
      for (var i = 0; i < 18; i++) {
        ms += 16;
        await gesture.moveBy(
          const Offset(-20, 0),
          timeStamp: Duration(milliseconds: ms),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      // Berhenti sebentar, lalu lempar cepat ke arah sebaliknya; posisinya
      // masih lewat sepertiga (360 − 48 px dari 800).
      ms += 50;
      for (var i = 0; i < 6; i++) {
        ms += 4;
        await gesture.moveBy(
          const Offset(8, 0),
          timeStamp: Duration(milliseconds: ms),
        );
        await tester.pump(const Duration(milliseconds: 4));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moved, isEmpty);
      expect(tester.getRect(_house('living')).left, 0);
    });

    testWidgets('dimatikan di tengah geser: kembali, tidak macet', (
      tester,
    ) async {
      final moved = <HouseRoom>[];
      final state = await pumpPager(tester, moved);
      final gesture = await tester.startGesture(const Offset(300, 300));
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      expect(tester.getRect(_house('living')).left, lessThan(0));
      state.value = (HouseRoom.living, false);
      await tester.pumpAndSettle();
      expect(tester.getRect(_house('living')).left, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      // Sesudah dinyalakan lagi, ganti ruangan dari luar tetap bergeser.
      state.value = (HouseRoom.terrace, true);
      await tester.pumpAndSettle();
      expect(_house('living'), findsNothing);
      expect(moved, isEmpty);
    });
  });
}
