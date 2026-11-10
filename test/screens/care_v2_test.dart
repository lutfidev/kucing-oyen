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
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/screens/room/home_scene.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';
import 'package:kucing_oren/l10n/l10n.dart';

import '../test_helpers.dart';
import 'home_v2_test.dart' as home;

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CARE_REVIEW')) return;
  await tester.runAsync(() async {
    final boundary =
        home.captureKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('docs/design-v2/care/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<ProgressController> setupCare(
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
  await c.setHomeArea(HomeArea.rawat);
  if (!full) {
    await c.inviteKitty(KittyId.oyen, HomeActivity.brush);
    await c.inviteKitty(KittyId.salju, HomeActivity.brush);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
  }
  await home.pumpHome(tester, c, life: life);
  await tester.runAsync(
    () => precacheImage(
      PaintedScenery.care,
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
    'puzzle pauses an active care turn and returning resumes it once',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupCare(tester, life: true);
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
      expect(c.household.lastArea, HomeArea.rawat);
      await home.tick(tester, 90);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      expect(c.catNeeds(KittyId.oyen).petWindowJoy, 10);
      await home.tick(tester, 90);
      expect(c.catNeeds(KittyId.oyen).joy, 75);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'brush target opens care sheet, duplicate tap and cancel are safe',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupCare(tester);
      expect(c.caring.using, KittyId.oyen);
      expect(c.caring.queue, [KittyId.salju]);
      final brush = find.byKey(const ValueKey('care-brush'));
      expect(tester.getSize(brush).shortestSide, greaterThanOrEqualTo(48));
      for (final kitty in [KittyId.oyen, KittyId.salju]) {
        expect(
          tester.getRect(brush).overlaps(tester.getRect(home.cat(kitty))),
          isFalse,
        );
      }
      await capture(tester, 'rawat-antrean-id');
      await home.tap(tester, find.byKey(const ValueKey('care-cancel-salju')));
      expect(c.caring.queue, isEmpty);
      await home.tap(tester, brush);
      await home.tap(
        tester,
        find.byKey(const ValueKey('care-invite-pet-salju')),
      );
      expect(
        c.household.routine.invitations[KittyId.salju]!.kind,
        HomeActivity.pet,
      );
      await capture(tester, 'rawat-sheet-id');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('handoff keeps targets apart and reduced motion is static', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 640));
    final c = await setupCare(tester);
    await c.advanceHousehold(6);
    await tester.pump();
    expect(c.caring.using, KittyId.salju);
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
    for (final kitty in [KittyId.oyen, KittyId.salju]) {
      final paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byKey(ValueKey('home-position-${kitty.name}')),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect((paint.painter! as HomeCatPainter).time, isNull);
    }
    final a = tester.getRect(home.cat(KittyId.oyen));
    final b = tester.getRect(home.cat(KittyId.salju));
    expect(a.overlaps(b), isFalse);
    expect(a.shortestSide, greaterThanOrEqualTo(48));
    expect(b.shortestSide, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });
  testWidgets('full joy and shared hourly limit explain disabled actions', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    await setupCare(tester, full: true);
    await capture(tester, 'rawat-kosong-id');
    await home.tap(tester, find.byKey(const ValueKey('care-choose')));
    for (final kind in ['brush', 'pet']) {
      expect(
        tester
            .widget<UiButton>(find.byKey(ValueKey('care-invite-$kind-oyen')))
            .onPressed,
        isNull,
      );
    }
    await capture(tester, 'rawat-penuh-id');
    final c = await home.load(
      needs: HomeNeeds(
        cats: {
          KittyId.oyen: CatNeeds(
            hunger: 90,
            joy: 65,
            at: home.now,
            petWindowStart: home.now,
            petWindowJoy: 30,
          ),
        },
      ),
    );
    await c.setHomeArea(HomeArea.rawat);
    await home.pumpHome(tester, c);
    await home.tap(tester, find.byKey(const ValueKey('care-choose')));
    final l = tester.element(find.byType(HomeView)).l10n;
    expect(find.text(l.careCooldown(60)), findsOneWidget);
    for (final kind in ['brush', 'pet']) {
      expect(
        tester
            .widget<UiButton>(find.byKey(ValueKey('care-invite-$kind-oyen')))
            .onPressed,
        isNull,
      );
    }
    await capture(tester, 'rawat-batas-id');
    expect(tester.takeException(), isNull);
  });
  testWidgets('screen reader names grooming target and both actions', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    final semantics = tester.ensureSemantics();
    await setupCare(tester);
    final l = tester.element(find.byType(HomeView)).l10n;
    expect(find.bySemanticsLabel(l.careChoose), findsWidgets);
    await home.tap(tester, find.byKey(const ValueKey('care-brush')));
    expect(
      find.bySemanticsLabel(l.homeInviteFor('Oyen', l.homeActivity('pet'))),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel(l.homeInviteFor('Oyen', l.homeActivity('brush'))),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
  for (final language in AppLanguage.values) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('care ${language.name} small text $scale fits and scrolls', (
        tester,
      ) async {
        setScreenSize(tester, const Size(360, 640));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await setupCare(tester, language: language);
        await capture(
          tester,
          'rawat-${language.name}-360-${(scale * 100).round()}',
        );
        await home.tap(tester, find.byKey(const ValueKey('care-choose')));
        await tester.ensureVisible(
          find.byKey(const ValueKey('care-invite-brush-salju')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
