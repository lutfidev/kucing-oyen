import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/room/home_scene.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';

import '../test_helpers.dart';
import 'home_v2_test.dart' as home;

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('DINING_REVIEW')) return;
  await tester.runAsync(() async {
    final boundary =
        home.captureKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('docs/design-v2/dining/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<ProgressController> setupDining(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.id,
  bool consumed = false,
  bool life = false,
}) async {
  final c = await home.load(
    language: language,
    home: Home(kitties: [KittyId.oyen, KittyId.salju]),
    needs: HomeNeeds(
      cats: {
        for (final k in [KittyId.oyen, KittyId.salju])
          k: CatNeeds(hunger: 40, joy: 80, at: home.now),
      },
      bowl: consumed
          ? Bowl(filledAt: home.now, eaten: [KittyId.oyen, KittyId.salju])
          : null,
    ),
  );
  await c.setHomeArea(HomeArea.makan);
  if (!consumed) {
    await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
    await c.inviteKitty(KittyId.salju, HomeActivity.eat);
    await c.advanceHousehold(0);
    await c.advanceHousehold(1);
  }
  await home.pumpHome(tester, c, life: life);
  await tester.runAsync(
    () => precacheImage(
      PaintedScenery.dining,
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
  testWidgets('one live bowl and separate eating and waiting hit targets', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    final c = await setupDining(tester);
    expect(find.byKey(const ValueKey('dining-bowl')), findsOneWidget);
    expect(c.dining.eating, KittyId.oyen);
    expect(c.dining.queue, [KittyId.salju]);
    expect(
      tester
          .getRect(home.cat(KittyId.oyen))
          .overlaps(tester.getRect(home.cat(KittyId.salju))),
      isFalse,
    );
    final bowl = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const ValueKey('dining-bowl')),
        matching: find.byType(CustomPaint),
      ),
    );
    expect((bowl.painter! as DiningBowlPainter).empty, isFalse);
    await capture(tester, 'makan-antrean-id');
    await home.tap(tester, find.byKey(const ValueKey('dining-cancel-salju')));
    expect(c.dining.queue, isEmpty);
    await home.tap(tester, find.byKey(const ValueKey('dining-bowl')));
    expect(find.byKey(const ValueKey('dining-invite-salju')), findsOneWidget);
    await home.tap(tester, find.byKey(const ValueKey('dining-invite-salju')));
    expect(c.dining.queue, [KittyId.salju]);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'empty shared bowl shows next cycle and disables already-fed invitation',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupDining(tester, consumed: true);
      expect(c.dining.portionsLeft, 0);
      final l = tester.element(find.byType(HomeView)).l10n;
      expect(find.text(l.diningRefill('4:00')), findsOneWidget);
      expect(find.text(l.diningEmpty), findsOneWidget);
      expect(find.text(l.diningFree), findsNothing);
      await capture(tester, 'makan-jatah-habis-id');
      await home.tap(tester, find.byKey(const ValueKey('dining-choose')));
      final invite = tester.widget<UiButton>(
        find.byKey(const ValueKey('dining-invite-oyen')),
      );
      expect(invite.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'handoff moves to bowl gradually and reduced motion stays static',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await setupDining(tester, life: true);
      final slot = find.byKey(const ValueKey('home-cat-position-salju'));
      final start = tester.getTopLeft(slot).dx;
      await c.advanceHousehold(4);
      await tester.pump();
      expect(c.dining.eating, KittyId.salju);
      expect(tester.getTopLeft(slot).dx, start);
      await tester.pump(const Duration(milliseconds: 175));
      final middle = tester.getTopLeft(slot).dx;
      expect(middle, lessThan(start));
      expect(
        tester
            .getRect(home.cat(KittyId.salju))
            .overlaps(tester.getRect(home.cat(KittyId.oyen))),
        isFalse,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getTopLeft(slot).dx, lessThan(middle));
      await c.setReducedMotion(true);
      await tester.pump();
      final position = tester.widget<ImplicitlyAnimatedWidget>(slot);
      expect(position.duration, Duration.zero);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'small room handoff keeps separate 48dp targets throughout crossing',
    (tester) async {
      setScreenSize(tester, const Size(360, 640));
      final c = await setupDining(tester, life: true);
      await c.advanceHousehold(4);
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 35));
        final incoming = tester.getRect(home.cat(KittyId.salju));
        final outgoing = tester.getRect(home.cat(KittyId.oyen));
        expect(incoming.overlaps(outgoing), isFalse, reason: 'frame $i');
        expect(incoming.width, greaterThanOrEqualTo(48));
        expect(outgoing.width, greaterThanOrEqualTo(48));
        if (i == 4) await capture(tester, 'makan-pergantian-giliran-id');
      }
      expect(tester.takeException(), isNull);
    },
  );
  for (final language in AppLanguage.values) {
    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'dining ${language.name} small text $scale fits and scrolls',
        (tester) async {
          setScreenSize(tester, const Size(360, 640));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await setupDining(tester, language: language);
          expect(tester.takeException(), isNull);
          await capture(
            tester,
            'makan-${language.name}-360-${(scale * 100).round()}',
          );
          await home.tap(tester, find.byKey(const ValueKey('dining-choose')));
          await tester.ensureVisible(
            find.byKey(const ValueKey('dining-invite-salju')),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
