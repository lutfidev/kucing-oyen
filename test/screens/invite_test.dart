import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/screens/room/kitty_card.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

/// Oyen dan Mochi (Mochi mulai di teras), kamar diam kecuali [life].
Future<void> _pump(
  WidgetTester tester, {
  bool life = false,
  Size size = const Size(390, 844),
}) => pumpRoom(
  tester,
  size: size,
  life: life,
  random: () => Random(1),
  progress: withNeeds({
    KittyId.oyen: (90, 90),
    KittyId.mochi: (90, 90),
  }, home: Home(kitties: {KittyId.mochi})),
);

final _invite = find.byKey(const ValueKey('kitty-invite'));
final _passingOyen = find.byKey(const ValueKey('passing-oyen'));

/// Tengah bukaan pintu ruang tengah di layar.
Offset _doorCenter(WidgetTester tester) {
  final (room, geo) = roomOf(tester);
  return geo.door.getBounds().center + room.topLeft;
}

/// Tahan Oyen [hold] lalu geser ke [to] dan lepas; status angkat diperiksa
/// [whileLifted] sebelum dilepas.
Future<void> _liftOyen(
  WidgetTester tester,
  Offset to, {
  Duration hold = const Duration(milliseconds: 600),
  void Function()? whileLifted,
}) async {
  final start = tester.getCenter(kittyView(KittyId.oyen));
  final gesture = await tester.startGesture(start);
  await tester.pump(hold);
  for (var i = 1; i <= 10; i++) {
    await gesture.moveTo(Offset.lerp(start, to, i / 10)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  whileLifted?.call();
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('kartu: "Sedang di ruang tengah." dan "Ajak ke teras"', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sedang di ruang tengah.'), findsOneWidget);
    expect(
      find.descendant(of: _invite, matching: find.text('Ajak ke teras')),
      findsOneWidget,
    );
  });

  testWidgets('kartu di teras: "Ajak ke ruang tengah"', (tester) async {
    await _pump(tester);
    await goThroughDoor(tester);
    await tester.tap(kittyView(KittyId.mochi));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sedang di teras.'), findsOneWidget);
    expect(
      find.descendant(of: _invite, matching: find.text('Ajak ke ruang tengah')),
      findsOneWidget,
    );
  });

  testWidgets('Ajak ke teras: kartu tertutup, Oyen berjalan lewat pintu', (
    tester,
  ) async {
    await _pump(tester, life: true);
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(
      find.semantics.byLabel(RegExp(r'^Oyen.*Ketuk untuk lihat kartunya$')),
    );
    await tester.pump();
    semantics.dispose();
    await tester.ensureVisible(_invite);
    await tester.pump();
    await tester.tap(_invite);
    await tester.pump();
    expect(find.byType(KittyCard), findsNothing);
    var passed = false;
    for (var i = 0; i < 200 && !passed; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      passed = _passingOyen.evaluate().isNotEmpty;
    }
    expect(passed, isTrue);
  });

  testWidgets('kurangi gerak: diajak = langsung di ruangan tujuan', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pump(tester, life: true);
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pump();
    await tester.ensureVisible(_invite);
    await tester.pump();
    await tester.tap(_invite);
    await tester.pump();
    expect(kittyView(KittyId.oyen), findsNothing);
    await goThroughDoor(tester);
    expect(kittyView(KittyId.oyen), findsOneWidget);
  });

  testWidgets('tahan lalu seret ke pintu: diajak; status dan geser mati', (
    tester,
  ) async {
    await _pump(tester);
    await _liftOyen(
      tester,
      _doorCenter(tester),
      whileLifted: () {
        expect(find.text('Bawa ke pintu untuk ajak ke teras'), findsOneWidget);
        expect(find.byKey(const ValueKey('door-glow')), findsOneWidget);
      },
    );
    await settle(tester, max: const Duration(seconds: 1));
    expect(find.text('Bawa ke pintu untuk ajak ke teras'), findsNothing);
    expect(find.byKey(const ValueKey('door-glow')), findsNothing);
    // Geseran saat diangkat tidak memindahkan ruangan.
    expect(find.byKey(const ValueKey('house-living')), findsOneWidget);
    expect(kittyView(KittyId.oyen), findsNothing);
    await goThroughDoor(tester);
    expect(kittyView(KittyId.oyen), findsOneWidget);
  });

  testWidgets('tahan lalu seret ke lantai kosong: Oyen pindah di situ', (
    tester,
  ) async {
    await _pump(tester);
    final before = tester.getRect(kittyView(KittyId.oyen));
    final to = before.center + const Offset(-90, 40);
    await _liftOyen(tester, to);
    await settle(tester, max: const Duration(seconds: 1));
    final after = tester.getRect(kittyView(KittyId.oyen));
    expect((after.center.dx - to.dx).abs(), lessThan(2));
    expect(after, isNot(before));
    expect(find.byType(KittyCard), findsNothing);
  });

  testWidgets('angkat dibatalkan sistem: kucing turun, status hilang', (
    tester,
  ) async {
    await _pump(tester);
    final start = tester.getCenter(kittyView(KittyId.oyen));
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(start + const Offset(-40, 20));
    await tester.pump();
    expect(find.byKey(const ValueKey('door-glow')), findsOneWidget);
    await gesture.cancel();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const ValueKey('door-glow')), findsNothing);
    expect(find.text('Bawa ke pintu untuk ajak ke teras'), findsNothing);
    expect(kittyView(KittyId.oyen), findsOneWidget);
    // Rutinitas dan geser ruangan jalan lagi.
    await tester.flingFrom(const Offset(200, 300), const Offset(-300, 0), 1500);
    await settle(tester, max: const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('house-terrace')), findsOneWidget);
  });

  testWidgets('geser dari lantai kosong tetap pindah ruangan', (tester) async {
    await _pump(tester);
    await tester.flingFrom(const Offset(200, 300), const Offset(-300, 0), 1500);
    await settle(tester, max: const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('house-terrace')), findsOneWidget);
  });

  testWidgets('ketuk biasa tetap membuka kartu', (tester) async {
    await _pump(tester);
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pumpAndSettle();
    expect(find.byType(KittyCard), findsOneWidget);
  });

  testWidgets('pembaca layar: aksi "Ajak ke teras" pada kucing', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);
    final oyen = find.semantics.byLabel(
      RegExp(r'^Oyen.*Ketuk untuk lihat kartunya$'),
    );
    tester.semantics.customAction(
      oyen,
      CustomSemanticsAction(label: 'Ajak ke teras'),
    );
    await settle(tester, max: const Duration(seconds: 1));
    expect(kittyView(KittyId.oyen), findsNothing);
    await goThroughDoor(tester);
    expect(kittyView(KittyId.oyen), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('kartu 360×640 teks 130%: tanpa overflow', (tester) async {
    setTextScale(tester, 1.3);
    await _pump(tester, size: const Size(360, 640));
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pumpAndSettle();
    await tester.ensureVisible(_invite);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
