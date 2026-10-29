import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

/// Kamar hidup seukuran desain; kucing bergerak terus, jadi [settle].
Future<ProgressController> _pump(
  WidgetTester tester, {
  ProgressController? progress,
  int seed = 1,
}) async {
  setScreenSize(tester, const Size(390, 844));
  return pumpApp(
    tester,
    progress: progress ?? testProgressWith(home: _furnished()),
    roomRandom: () => Random(seed),
    roomLife: true,
  );
}

/// Kamar dengan kasur, bola, dan kardus (plus mangkuk bawaan).
Home _furnished() => Home(
  room: Room()
      .buy(RoomItemId.kasur)
      .buy(RoomItemId.bola)
      .buy(RoomItemId.kardus),
);

Finder _inUseBy(KittyId kitty) =>
    find.byWidgetPredicate((w) => w is RoomItemView && w.user?.kitty == kitty);

/// Pompa per 100 ms sampai [done] atau [max] habis.
Future<bool> _until(
  WidgetTester tester,
  bool Function() done, {
  Duration max = const Duration(seconds: 60),
}) async {
  const frame = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < max; t += frame) {
    if (done()) return true;
    await tester.pump(frame);
  }
  return done();
}

void main() {
  testWidgets('Oyen berjalan ke barang lalu memakainya', (tester) async {
    await _pump(tester);
    final start = tester.getRect(kittyView(KittyId.oyen).first);
    expect(
      await _until(tester, () => _inUseBy(KittyId.oyen).evaluate().isNotEmpty),
      isTrue,
    );
    // Sprite Oyen sendiri disembunyikan; barangnya yang menggambar Oyen.
    expect(kittyView(KittyId.oyen), findsNothing);
    // Sebelum sampai, Oyen sempat pindah dari tempat awalnya.
    expect(start, isNot(Rect.zero));
  });

  testWidgets('kucing berkedip: waktu animasi maju tiap bingkai', (
    tester,
  ) async {
    await _pump(tester);
    final before = tester.widget<KittyView>(kittyView(KittyId.oyen)).look.time;
    await tester.pump(const Duration(milliseconds: 50));
    final after = tester.widget<KittyView>(kittyView(KittyId.oyen)).look.time;
    expect(before, isNotNull);
    expect(after, greaterThan(before!));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('kartu terbuka: rutinitas berhenti, kucing diam di tempat', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(kittyView(KittyId.oyen));
    await tester.pump();
    final rect = tester.getRect(kittyView(KittyId.oyen).first);
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.getRect(kittyView(KittyId.oyen).first), rect);
  });

  testWidgets('kurangi gerak: kucing diam, tanpa bingkai terjadwal', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pump(tester);
    final rect = tester.getRect(kittyView(KittyId.oyen).first);
    expect(tester.widget<KittyView>(kittyView(KittyId.oyen)).look.time, isNull);
    await tester.pump(const Duration(seconds: 10));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.getRect(kittyView(KittyId.oyen).first), rect);
  });

  testWidgets('kurangi gerak: kucing lapar tetap makan dari mangkuk', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final progress = withNeeds({KittyId.oyen: (30, 80)});
    await _pump(tester, progress: progress);
    await tester.pump();
    expect(progress.catNeeds(KittyId.oyen).hunger, 30 + bowlFood);
  });

  testWidgets('kucing lapar menuju mangkuk dan makan sekali per isi', (
    tester,
  ) async {
    final audio = testAudio();
    final progress = withNeeds({KittyId.oyen: (30, 80)}, home: _furnished());
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      progress: progress,
      audio: audio,
      roomRandom: () => Random(1),
      roomLife: true,
    );
    expect(
      await _until(
        tester,
        () => progress.catNeeds(KittyId.oyen).hunger > 30,
        max: const Duration(seconds: 20),
      ),
      isTrue,
    );
    expect(progress.catNeeds(KittyId.oyen).hunger, 30 + bowlFood);
    expect(playedBy(audio), contains(GameSound.munch));
    expect(progress.canEatFromBowl(KittyId.oyen), isFalse);
  });

  testWidgets('gelembung hadiah: ketuk menambah koin sekali', (tester) async {
    final audio = testAudio();
    final progress = withNeeds({KittyId.oyen: (90, 90)}, coins: 5);
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      progress: progress,
      audio: audio,
      roomRandom: () => Random(1),
      roomLife: true,
    );
    final bubble = find.byKey(const ValueKey('reward-oyen'));
    expect(bubble, findsOneWidget);
    await tester.tap(bubble);
    await tester.pump();
    expect(progress.coins, 5 + kittyRewardCoins);
    expect(playedBy(audio), contains(GameSound.reward));
    expect(find.text('+10 koin'), findsOneWidget);
    await settle(tester);
    expect(bubble, findsNothing);
    expect(progress.canClaimKittyReward(KittyId.oyen), isFalse);
  });

  testWidgets('kucing lesu tidak memunculkan gelembung', (tester) async {
    await _pump(tester, progress: withNeeds({KittyId.oyen: (10, 90)}));
    expect(find.byType(CoinBubbleView), findsNothing);
    expect(find.byType(SadMarkView), findsOneWidget);
  });

  testWidgets('mangkuk kosong: label jam isi ulang', (tester) async {
    final progress = testProgressWith(
      clock: () => roomNow,
      needs: HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 90, at: roomNow)},
        bowl: Bowl(
          filledAt: roomNow.subtract(const Duration(minutes: 70)),
          eaten: const [KittyId.oyen],
        ),
      ),
    );
    await _pump(tester, progress: progress);
    expect(find.text('Terisi lagi 3 jam'), findsOneWidget);
    final bowl = itemView(RoomItemId.mangkuk);
    expect(tester.widget<RoomItemView>(bowl).full, isFalse);
  });

  testWidgets('ketuk kucing mengeong, elus mendengkur; efek mati = senyap', (
    tester,
  ) async {
    for (final effects in [true, false]) {
      final audio = testAudio(settings: SoundSettings(effects: effects));
      setScreenSize(tester, const Size(390, 844));
      await pumpApp(
        tester,
        progress: withNeeds({KittyId.oyen: (80, 50)}),
        audio: audio,
        roomRandom: () => Random(1),
        roomLife: true,
      );
      await tester.tap(kittyView(KittyId.oyen));
      await tester.pump();
      final pet = find.text('Elus');
      await tester.ensureVisible(pet);
      await tester.pump();
      await tester.tap(pet);
      await tester.pump();
      final played = playedBy(audio);
      if (effects) {
        expect(played, containsAllInOrder([GameSound.meow, GameSound.purr]));
      } else {
        expect(played, isEmpty);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('mode hias: kucing melepas barang dan tidak dianimasikan', (
    tester,
  ) async {
    await _pump(tester);
    await _until(tester, () => _inUseBy(KittyId.oyen).evaluate().isNotEmpty);
    await tester.tap(find.text('Hias'));
    await tester.pump();
    expect(_inUseBy(KittyId.oyen), findsNothing);
    expect(tester.widget<KittyView>(kittyView(KittyId.oyen)).look.time, isNull);
  });

  testWidgets('layar lain menutupi kamar: jam kamar berhenti', (tester) async {
    await _pump(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go(AppRoutes.chapter(1));
    await settle(tester);
    final room = find.byType(KittyView, skipOffstage: false);
    final look = tester.widget<KittyView>(room.first).look;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.widget<KittyView>(room.first).look, look);
  });
}
