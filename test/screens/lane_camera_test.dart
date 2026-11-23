import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/screens/lane/lane_scene.dart';
import 'package:kucing_oren/screens/room/lane_camera.dart';
import 'package:kucing_oren/screens/room/room_parts.dart';
import 'package:kucing_oren/screens/room/room_scene.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

Matcher _near(double x, double y) => predicate<({double x, double y})>(
  (p) => (p.x - x).abs() < 1e-6 && (p.y - y).abs() < 1e-6,
  '($x, $y)',
);

Future<void> _pumpRoom(WidgetTester tester) async {
  setScreenSize(tester, const Size(390, 844));
  await pumpApp(tester, progress: testProgressWith(best: const {1: 3}));
}

Finder get _frontDoor => find.byKey(const ValueKey('front-door'));
Finder get _camera => find.byType(LaneCamera);

/// Pompa kamera sampai selesai (bingkai 16 ms), lalu satu bingkai lagi
/// untuk `onDone`.
Future<void> _finishCamera(WidgetTester tester) async {
  for (var ms = 0; ms <= laneCameraMs + 50; ms += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump();
}

void main() {
  group('linimasa kamera (kKamera)', () {
    test('awal: zoom 1, pintu tertutup, pusat pintu di tempatnya', () {
      final f = laneCameraAt(0, home: false);
      expect(f.zoom, 1);
      expect(f.doorDeg, 0);
      expect(f.focus, _near(39, 346));
      expect(f.laneInOpening, isFalse);
    });

    test('480 ms: zoom 1,6, pintu di (195, 330)', () {
      final f = laneCameraAt(480, home: false);
      expect(f.zoom, closeTo(1.6, 1e-9));
      expect(f.focus, _near(195, 330));
      expect(f.doorDeg, 0);
    });

    test('600 ms: gang mulai di bukaan pada 0,5×', () {
      final f = laneCameraAt(600, home: false);
      expect(f.laneInOpening, isTrue);
      expect(f.laneScale, 0.5);
    });

    test('860 ms: pintu 70°, zoom 2,1 (artboard 6c)', () {
      final f = laneCameraAt(860, home: false);
      expect(f.doorDeg, closeTo(70, 1e-9));
      expect(f.zoom, closeTo(2.1, 1e-9));
    });

    test('1400 ms: zoom 5,4, pintu 88°, gang 0,92', () {
      final f = laneCameraAt(1400, home: false);
      expect(f.zoom, closeTo(5.4, 1e-9));
      expect(f.doorDeg, closeTo(88, 1e-9));
      expect(f.laneScale, closeTo(0.92, 1e-9));
    });

    test('1700 ms: gang penuh, skala 1, chip tampil', () {
      final f = laneCameraAt(1700, home: false);
      expect(f.laneFull, isTrue);
      expect(f.laneScale, 1);
      expect(f.chipOpacity, 1);
    });

    test('pulang: dicerminkan ke pintu pulang, pintu mulai dari 8°', () {
      final f = laneCameraAt(0, home: true);
      expect(f.focus, _near(351, 346));
      expect(f.doorDeg, LaneDoorAngles.homeRest);
    });

    test('bukaan memenuhi layar sebelum gang menggantikan kamera', () {
      final f = laneCameraAt(laneCameraMs - 1, home: false);
      for (final (x, y) in const [(70.0, 212.0), (8.0, 203.0)]) {
        expect(f.apply(x, y).y, lessThan(0));
      }
      expect(f.apply(8, 300).x, lessThan(0));
      expect(f.apply(70, 300).x, greaterThan(390));
    });

    test('tidak ada bingkai tanpa ruang tengah dan tanpa gang', () {
      for (var ms = 0.0; ms <= laneCameraMs; ms += 10) {
        final f = laneCameraAt(ms, home: false);
        // Ruang tengah selalu digambar sampai gang penuh; gang di bukaan
        // sejak 600 ms dan tidak pernah langsung penuh sebelum akhir.
        if (ms >= laneOpeningMs && ms < laneCameraMs) {
          expect(f.laneInOpening, isTrue, reason: '$ms');
        }
        if (ms < laneCameraMs) expect(f.laneFull, isFalse, reason: '$ms');
      }
    });
  });

  testWidgets('ketuk pintu depan: sesudah 1700 ms gang tampil', (tester) async {
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump();
    expect(_camera, findsOneWidget);
    await _finishCamera(tester);
    expect(_camera, findsNothing);
    expect(find.byType(LaneScene), findsOneWidget);
    expect(find.byType(RoomScene), findsNothing);
  });

  testWidgets('ketuk dua kali: satu transisi, ketukan kedua ke akhir', (
    tester,
  ) async {
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_camera, findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lane-camera')));
    await tester.pump();
    await tester.pump();
    expect(_camera, findsNothing);
    expect(find.byType(LaneScene), findsOneWidget);
  });

  testWidgets('header diam selama kamera', (tester) async {
    await _pumpRoom(tester);
    final before = tester.getRect(find.byType(RoomHeader));
    await tester.tap(_frontDoor);
    await tester.pump();
    for (var ms = 0; ms < 900; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(_camera, findsOneWidget);
    expect(tester.getRect(find.byType(RoomHeader)), before);
  });

  testWidgets('tombol kembali di gang: pulang ke ruang tengah', (tester) async {
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    expect(find.byType(LaneScene), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    final camera = tester.widget<LaneCamera>(_camera);
    expect(camera.home, isTrue);
    await _finishCamera(tester);
    expect(find.byType(LaneScene), findsNothing);
    expect(find.byType(RoomScene), findsOneWidget);
  });

  testWidgets('chip "Ruang tengah" di gang membawa pulang', (tester) async {
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    await tester.tap(find.text(l10nId.roomName('living')));
    await tester.pump();
    await _finishCamera(tester);
    expect(find.byType(RoomScene), findsOneWidget);
  });

  testWidgets('geser di gang tidak pindah ke teras', (tester) async {
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    await tester.dragFrom(
      tester.getCenter(find.byType(LaneScene)),
      const Offset(-300, 0),
    );
    await settle(tester);
    expect(find.byType(LaneScene), findsOneWidget);
    expect(find.byKey(const ValueKey('house-terrace')), findsNothing);
  });

  testWidgets('kurangi gerak: crossfade 240 ms tanpa zoom', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pumpRoom(tester);
    await tester.tap(_frontDoor);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('lane-camera-fade')), findsOneWidget);
    expect(find.byKey(const ValueKey('lane-camera-from')), findsNothing);
    await tester.pump(Duration(milliseconds: laneFadeMs.toInt()));
    await tester.pump();
    expect(_camera, findsNothing);
    expect(find.byType(LaneScene), findsOneWidget);
  });

  testWidgets('pembaca layar: pintu di gang "Pulang ke ruang tengah"', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpRoom(tester);
    expect(find.bySemanticsLabel(l10nId.frontDoorTo), findsOneWidget);
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    expect(find.bySemanticsLabel(l10nId.laneHomeDoor), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('pembaca layar: tiba di gang dan pulang diumumkan', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpRoom(tester);
    tester.takeAnnouncements();
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    expect(
      tester.takeAnnouncements().map((a) => a.message),
      contains(l10nId.laneName),
    );
    await tester.tap(find.byKey(const ValueKey('lane-home-door-button')));
    await tester.pump();
    await _finishCamera(tester);
    expect(
      tester.takeAnnouncements().map((a) => a.message),
      contains(l10nId.roomName('living')),
    );
    semantics.dispose();
  });

  testWidgets('daun pintu menutup kasur di belakangnya, bukan Oyen di depan', (
    tester,
  ) async {
    // Kasur di posisi desain `AdeganTengah` (kiri 118, kaki 434), Oyen di
    // tempat awalnya (kaki y 556) = di depan kasur.
    const floor = HouseFloor();
    final kasur = roomItemOf(RoomItemId.kasur);
    final s = floor.itemSize(kasur, depthScale(434));
    final room = Room(owned: const [RoomItemId.kasur])
        .place(RoomItemId.kasur, floor.spotAtFeet(118 + s.width / 2, 434));
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      progress: testProgressWith(
        best: const {1: 3},
        home: Home(room: room),
      ),
    );
    await tester.tap(_frontDoor);
    // Pintu 70–88°: daun menutup sebagian kasur.
    for (var ms = 0; ms <= laneOpeningMs + 300; ms += 16) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final covers = find.byType(DoorLeafCoverView);
    expect(covers, findsWidgets);
    // Urutan gambar (urutan pohon di satu Stack): tutupan kasur sesudah
    // kasur dan sebelum Oyen, jadi Oyen tetap di atas daun pintu.
    final order = find
        .descendant(
          of: find.byType(RoomScene),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DoorLeafCoverView ||
                w.key == const ValueKey(KittyId.oyen) ||
                (w is RoomItemView && w.id == RoomItemId.kasur),
          ),
        )
        .evaluate()
        .map((e) => e.widget)
        .toList();
    final bed = order.indexWhere((w) => w is RoomItemView);
    final cover = order.indexWhere((w) => w is DoorLeafCoverView);
    final oyen = order.indexWhere((w) => w.key == const ValueKey(KittyId.oyen));
    expect(bed, isNonNegative);
    expect(oyen, greaterThan(bed));
    expect(cover, greaterThan(bed));
    expect(cover, lessThan(oyen));
    await _finishCamera(tester);
  });

  testWidgets('bunyi pintu terbuka dan tertutup', (tester) async {
    final audio = testAudio();
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      progress: testProgressWith(best: const {1: 3}),
      audio: audio,
    );
    await tester.tap(_frontDoor);
    await tester.pump();
    await _finishCamera(tester);
    final played = playedBy(audio);
    expect(
      played,
      containsAllInOrder([GameSound.doorOpen, GameSound.doorClose]),
    );
  });
}
