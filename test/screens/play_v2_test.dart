import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/room/home_scene.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';

import '../test_helpers.dart';
import 'home_v2_test.dart' as home;

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('PLAY_REVIEW')) return;
  await tester.runAsync(() async {
    final boundary =
        home.captureKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('docs/design-v2/play/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<ProgressController> setupPlay(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.id,
  bool life = false,
  bool full = false,
}) async {
  final c = await home.load(
    language: language,
    home: Home(kitties: [KittyId.oyen, KittyId.salju]),
    needs: HomeNeeds(
      cats: {
        for (final k in [KittyId.oyen, KittyId.salju])
          k: CatNeeds(hunger: 90, joy: full ? 100 : 65, at: home.now),
      },
    ),
  );
  await c.setHomeArea(HomeArea.main);
  if (!full) {
    await c.inviteKitty(KittyId.oyen, HomeActivity.play);
    await c.inviteKitty(KittyId.salju, HomeActivity.play);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
  }
  await home.pumpHome(tester, c, life: life);
  await tester.runAsync(
    () => precacheImage(
      PaintedScenery.play,
      tester.element(find.byType(HomeView)),
    ),
  );
  await tester.pump();
  return c;
}

void main() {
  setUpAll(() async {
    home.pack = await ArtPack.load();
  });
  testWidgets(
    'puzzle pauses an active play turn and returning resumes it once',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupPlay(tester, life: true);
      final router = GoRouter.of(tester.element(find.byType(HomeView)));
      router.go('/babak/1/level/1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final left = c.household.routine.activities[KittyId.oyen]!.left;
      await home.tick(tester, 100);
      expect(c.household.routine.activities[KittyId.oyen]!.left, left);
      expect(c.catNeeds(KittyId.oyen).joy, 65);
      router.go('/');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.household.lastArea, HomeArea.main);
      await home.tick(tester, 90);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      expect(c.catNeeds(KittyId.oyen).playedAt, home.now);
      await home.tick(tester, 90);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shared toy opens live invitation sheet and cancels queued turn',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupPlay(tester);
      expect(c.playing.playing, KittyId.oyen);
      expect(c.playing.queue, [KittyId.salju]);
      final toyTarget = tester.getRect(find.byKey(const ValueKey('play-toy')));
      for (final kitty in [KittyId.oyen, KittyId.salju]) {
        expect(toyTarget.overlaps(tester.getRect(home.cat(kitty))), isFalse);
      }
      final toy = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(const ValueKey('play-toy')),
          matching: find.byType(CustomPaint),
        ),
      );
      expect((toy.painter! as PlayToyPainter).toy, RoomItemId.bola);
      expect(
        tester
            .getRect(home.cat(KittyId.oyen))
            .overlaps(tester.getRect(home.cat(KittyId.salju))),
        isFalse,
      );
      await capture(tester, 'main-antrean-id');
      await home.tap(tester, find.byKey(const ValueKey('play-cancel-salju')));
      expect(c.playing.queue, isEmpty);
      await home.tap(tester, find.byKey(const ValueKey('play-toy')));
      expect(
        tester
            .widget<UiButton>(find.byKey(const ValueKey('play-invite-oyen')))
            .onPressed,
        isNull,
      );
      await home.tap(tester, find.byKey(const ValueKey('play-invite-salju')));
      expect(c.playing.queue, [KittyId.salju]);
      expect(tester.takeException(), isNull);
      await capture(tester, 'main-sheet-id');
    },
  );
  testWidgets(
    'handoff preserves 48dp targets and reduced motion freezes rendering',
    (tester) async {
      setScreenSize(tester, const Size(360, 640));
      final c = await setupPlay(tester, life: true);
      final toyTarget = tester.getRect(find.byKey(const ValueKey('play-toy')));
      expect(toyTarget.width, greaterThanOrEqualTo(48));
      expect(toyTarget.height, greaterThanOrEqualTo(48));
      for (final kitty in [KittyId.oyen, KittyId.salju]) {
        expect(toyTarget.overlaps(tester.getRect(home.cat(kitty))), isFalse);
      }
      await c.advanceHousehold(8);
      await tester.pump();
      expect(c.playing.playing, KittyId.salju);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 35));
        final a = tester.getRect(home.cat(KittyId.oyen));
        final b = tester.getRect(home.cat(KittyId.salju));
        expect(a.overlaps(b), isFalse, reason: 'frame $i');
        expect(a.width, greaterThanOrEqualTo(48));
        expect(b.width, greaterThanOrEqualTo(48));
      }
      await c.setReducedMotion(true);
      await tester.pump();
      expect(
        tester
            .widget<ImplicitlyAnimatedWidget>(
              find.byKey(const ValueKey('home-position-salju')),
            )
            .duration,
        Duration.zero,
      );
      final toy = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(const ValueKey('play-toy')),
          matching: find.byType(CustomPaint),
        ),
      );
      expect((toy.painter! as PlayToyPainter).time, isNull);
      final l = tester.element(find.byType(HomeView)).l10n;
      expect(find.text('Oyen · ${l.playCooldown(30)}'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('play-availability')),
      );
      await tester.pump();
      await capture(tester, 'main-cooldown-id');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('full joy disables invitations', (tester) async {
    setScreenSize(tester, const Size(390, 844));
    await setupPlay(tester, full: true);
    final l = tester.element(find.byType(HomeView)).l10n;
    expect(find.text(l.homeEmpty), findsOneWidget);
    await capture(tester, 'main-kosong-id');
    await home.tap(tester, find.byKey(const ValueKey('play-choose')));
    expect(
      tester
          .widget<UiButton>(find.byKey(const ValueKey('play-invite-oyen')))
          .onPressed,
      isNull,
    );
    await capture(tester, 'main-penuh-id');
  });
  testWidgets('occupied catalogue toy replaces structural ball in scene', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    final c = await home.load(
      home: Home(
        room: Room(
          owned: [RoomItemId.tiang],
          placed: {RoomItemId.tiang: roomItemOf(RoomItemId.tiang).defaultSpot},
        ),
      ),
      needs: HomeNeeds(
        cats: {KittyId.oyen: CatNeeds(hunger: 90, joy: 65, at: home.now)},
      ),
    );
    await c.setHomeArea(HomeArea.main);
    await c.inviteKitty(KittyId.oyen, HomeActivity.play);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
    await home.pumpHome(tester, c);
    await tester.runAsync(
      () => precacheImage(
        PaintedScenery.play,
        tester.element(find.byType(HomeView)),
      ),
    );
    await tester.pump();
    final toy = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const ValueKey('play-toy')),
        matching: find.byType(CustomPaint),
      ),
    );
    expect((toy.painter! as PlayToyPainter).toy, RoomItemId.tiang);
    expect(
      c.household.routine.activities[KittyId.oyen]!.facility,
      RoomItemId.tiang,
    );
    await capture(tester, 'main-tiang-id');
    expect(tester.takeException(), isNull);
  });
  for (final language in AppLanguage.values) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('play ${language.name} small text $scale fits and scrolls', (
        tester,
      ) async {
        setScreenSize(tester, const Size(360, 640));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await setupPlay(tester, language: language);
        await capture(
          tester,
          'main-${language.name}-360-${(scale * 100).round()}',
        );
        await home.tap(tester, find.byKey(const ValueKey('play-choose')));
        await tester.ensureVisible(
          find.byKey(const ValueKey('play-invite-salju')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
