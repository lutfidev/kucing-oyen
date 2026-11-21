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
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';
import 'package:kucing_oren/screens/room/room_reaction.dart';
import 'package:kucing_oren/screens/room/room_view.dart';
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

  testWidgets('gelembung hadiah juga di atas kucing di dalam barang', (
    tester,
  ) async {
    final progress = testProgressWith(
      home: _furnished(),
      clock: () => roomNow,
      coins: 5,
      needs: HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 90, at: roomNow)},
      ),
    );
    await _pump(tester, progress: progress);
    expect(
      await _until(tester, () => _inUseBy(KittyId.oyen).evaluate().isNotEmpty),
      isTrue,
    );
    final view = tester.widget<RoomItemView>(_inUseBy(KittyId.oyen));
    final cat = RoomItemArt.catBox(
      view.id,
      tester.getRect(_inUseBy(KittyId.oyen)),
      mirror: view.mirror,
    );
    final bubble = find.byKey(const ValueKey('reward-oyen'));
    expect(bubble, findsOneWidget);
    final rect = tester.getRect(bubble);
    // Letak sebanding desain, dijepit di dalam kamar.
    expect(rect.top, moreOrLessEquals(cat.top - cat.width * 68 / 116));
    final (room, _) = roomOf(tester);
    expect(rect.left, greaterThanOrEqualTo(room.left));
    expect(rect.right, lessThanOrEqualTo(room.right));
    expect(
      rect.left,
      moreOrLessEquals(
        (cat.left + cat.width * 26 / 116).clamp(
          room.left + 8,
          room.right - 8 - rect.width,
        ),
      ),
    );
    await tester.tap(bubble);
    await tester.pump();
    expect(progress.coins, 5 + kittyRewardCoins);
    await settle(tester);
    expect(bubble, findsNothing);
  });

  testWidgets('kucing baru: tag "Baru!" dulu, gelembung sesudah kartu dibuka', (
    tester,
  ) async {
    final progress = withNeeds({
      KittyId.oyen: (90, 90),
      KittyId.salju: (90, 90),
    }, home: Home(kitties: {KittyId.salju}).adopt(KittyId.salju));
    final semantics = tester.ensureSemantics();
    await _pump(tester, progress: progress);
    expect(find.text('Baru!'), findsOneWidget);
    expect(find.byKey(const ValueKey('reward-salju')), findsNothing);
    expect(find.byKey(const ValueKey('reward-oyen')), findsOneWidget);
    // Kucing bergerak terus: diketuk lewat pembaca layar.
    tester.semantics.tap(
      find.semantics.byLabel('Salju, baru. Ketuk untuk lihat kartunya'),
    );
    await settle(tester, max: const Duration(seconds: 1));
    tester.semantics.tap(find.semantics.byLabel('Tutup kartu'));
    await settle(tester, max: const Duration(seconds: 1));
    expect(find.text('Baru!'), findsNothing);
    expect(find.byKey(const ValueKey('reward-salju')), findsOneWidget);
    semantics.dispose();
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

  // Mangkuk terisi 4 jam sesudah isi dimulai: sisa < 60 menit = sebentar
  // lagi, tepat 60 menit = 1 jam, 61 menit = 2 jam.
  for (final (elapsed, text) in [
    (210, 'Terisi sebentar lagi'),
    (239, 'Terisi sebentar lagi'),
    (180, 'Terisi lagi 1 jam'),
    (179, 'Terisi lagi 2 jam'),
  ]) {
    testWidgets('mangkuk kosong, $elapsed menit: "$text"', (tester) async {
      final progress = testProgressWith(
        clock: () => roomNow,
        needs: HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 90, at: roomNow)},
          bowl: Bowl(
            filledAt: roomNow.subtract(Duration(minutes: elapsed)),
            eaten: const [KittyId.oyen],
          ),
        ),
      );
      await _pump(tester, progress: progress);
      expect(find.text(text), findsOneWidget);
    });
  }

  testWidgets('jam HP mundur saat kamar terbuka: kamar tetap jalan', (
    tester,
  ) async {
    var now = roomNow;
    final progress = testProgressWith(
      home: _furnished(),
      clock: () => now,
      needs: HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 60, joy: 60, at: roomNow)},
        bowl: Bowl(
          filledAt: roomNow.subtract(const Duration(minutes: 70)),
          eaten: const [KittyId.oyen],
        ),
      ),
    );
    await _pump(tester, progress: progress);
    expect(find.text('Terisi lagi 3 jam'), findsOneWidget);

    now = roomNow.subtract(const Duration(hours: 3));
    progress.refreshDay();
    await tester.pump(roomRefreshInterval);
    await settle(tester, max: const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    final needs = progress.catNeeds(KittyId.oyen);
    expect(needs.hunger, inInclusiveRange(0, 100));
    expect(needs.joy, inInclusiveRange(0, 100));
    expect(find.textContaining('-'), findsNothing);
    // Isi mangkuk tidak bertambah lama karena jam mundur.
    expect(find.text('Terisi lagi 4 jam'), findsOneWidget);

    await tester.tap(kittyView(KittyId.oyen));
    await settle(tester, max: const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.text('60'), findsNWidgets(2));
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

  group('barang dipakai', () {
    Finder inUse(RoomItemId id) => find.byWidgetPredicate(
      (w) => w is RoomItemView && w.id == id && w.user != null,
    );

    /// Kotak kucing yang digambar barang [id] yang sedang dipakai.
    Rect userBox(WidgetTester tester, RoomItemId id) {
      final view = tester.widget<RoomItemView>(inUse(id));
      return RoomItemArt.catBox(
        id,
        tester.getRect(inUse(id)),
        mirror: view.mirror,
      );
    }

    double feet(Rect r) => r.top + r.height * catFeetFactor;

    for (final kitty in [KittyId.oyen, KittyId.mochi]) {
      testWidgets('${kitty.name} tidak bergeser saat mulai memakai kasur', (
        tester,
      ) async {
        final home = Home(
          room: Room().buy(RoomItemId.kasur),
          kitties: {KittyId.oyen, kitty},
        );
        await _pump(tester, progress: testProgressWith(home: home, coins: 0));
        Rect? last;
        bool used() =>
            inUse(RoomItemId.kasur).evaluate().isNotEmpty &&
            tester.widget<RoomItemView>(inUse(RoomItemId.kasur)).user!.kitty ==
                kitty;
        for (var i = 0; i < 12000 && !used(); i++) {
          if (kittyView(kitty).evaluate().isNotEmpty) {
            last = tester.getRect(kittyView(kitty).first);
          }
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(used(), isTrue);
        final cat = userBox(tester, RoomItemId.kasur);
        expect(last, isNotNull);
        // Satu bingkai jalan (70 px/detik) = ±1 px.
        expect((last!.center.dx - cat.center.dx).abs(), lessThan(3));
        expect((feet(last) - feet(cat)).abs(), lessThan(3));
      });
    }

    testWidgets('jendela burung dinaiki lewat puncak tiang, tanpa teleport', (
      tester,
    ) async {
      final home = Home(
        room: Room().buy(RoomItemId.jendelaBurung).buy(RoomItemId.tiang),
      );
      await _pump(tester, progress: testProgressWith(home: home, coins: 0));
      final post = tester.getRect(itemView(RoomItemId.tiang));
      var aboveFloor = false;
      var previous = Rect.zero;
      var biggestJump = 0.0;
      for (
        var i = 0;
        i < 2400 && inUse(RoomItemId.jendelaBurung).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 16));
        if (kittyView(KittyId.oyen).evaluate().isEmpty) continue;
        final rect = tester.getRect(kittyView(KittyId.oyen).first);
        if (feet(rect) < post.center.dy) aboveFloor = true;
        if (previous != Rect.zero) {
          biggestJump = max(
            biggestJump,
            (rect.center - previous.center).distance,
          );
        }
        previous = rect;
      }
      expect(inUse(RoomItemId.jendelaBurung), findsOneWidget);
      // Oyen sempat berada di atas tiang sebelum masuk ke jendela.
      expect(aboveFloor, isTrue);
      // Bingkai terakhir sebelum masuk sudah di kucing jendelanya.
      final cat = userBox(tester, RoomItemId.jendelaBurung);
      expect((previous.center - cat.center).distance, lessThan(12));
      // Tidak ada perpindahan mendadak antar bingkai.
      expect(biggestJump, lessThan(20));
    });

    testWidgets(
      'dielus di jendela burung: tetap di jendela, reaksi di atasnya',
      (tester) async {
        final home = Home(
          room: Room().buy(RoomItemId.jendelaBurung).buy(RoomItemId.tiang),
        );
        await _pump(
          tester,
          progress: withNeeds({KittyId.oyen: (80, 50)}, home: home),
        );
        for (
          var i = 0;
          i < 3000 && inUse(RoomItemId.jendelaBurung).evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final window = tester.getRect(inUse(RoomItemId.jendelaBurung));
        final cat = userBox(tester, RoomItemId.jendelaBurung);
        await tester.tap(inUse(RoomItemId.jendelaBurung));
        await tester.pump();
        final pet = find.text('Elus');
        await tester.ensureVisible(pet);
        await tester.pump();
        await tester.tap(pet);
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        // Oyen tidak turun ke lantai: jendelanya masih menggambar Oyen.
        expect(inUse(RoomItemId.jendelaBurung), findsOneWidget);
        expect(tester.getRect(inUse(RoomItemId.jendelaBurung)), window);
        expect(kittyView(KittyId.oyen), findsNothing);
        // Reaksi melayang di atas Oyen di jendela, bukan di lantai.
        final reaction = tester.getRect(find.byType(ReactionOverlay));
        expect((reaction.center.dx - cat.center.dx).abs(), lessThan(4));
        expect(reaction.bottom, lessThan(cat.center.dy));
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.byType(ReactionOverlay), findsNothing);
        expect(kittyView(KittyId.oyen), findsNothing);
      },
    );

    testWidgets('lukisan dan jam dinding tidak pernah dipakai', (tester) async {
      final home = Home(
        room: Room()
            .buy(RoomItemId.lukisan)
            .buy(RoomItemId.jam)
            .buy(RoomItemId.tiang),
      );
      await _pump(tester, progress: testProgressWith(home: home, coins: 0));
      for (var i = 0; i < 600; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(inUse(RoomItemId.lukisan), findsNothing);
        expect(inUse(RoomItemId.jam), findsNothing);
      }
    });
  });
}
