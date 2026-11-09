import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/screens/room/home_scene.dart';
import 'package:kucing_oren/widgets/v2/ui_sheet.dart';

import '../app/household_progress_test.dart' show AtomicTestStore;
import '../test_helpers.dart';
import 'room_fixtures.dart' show fullRoom;

final now = DateTime(2026, 11, 9, 12);
late ArtPack pack;
final captureKey = GlobalKey();

Future<ProgressController> load({
  AtomicTestStore? store,
  Home? home,
  HomeNeeds? needs,
  AppLanguage language = AppLanguage.id,
}) async {
  final data = store ?? AtomicTestStore();
  data.language = language;
  if (home != null) data.home = home;
  if (needs != null) data.needs = needs;
  final c = await ProgressController.load(
    levels: testLevels,
    store: data,
    clock: () => now,
  );
  await c.acknowledgeHomeMigration();
  return c;
}

Future<void> pumpHome(
  WidgetTester tester,
  ProgressController c, {
  bool life = false,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: KucingOrenApp(
        key: ValueKey(c),
        progress: c,
        roomLife: life,
        homeBuilder: (_) =>
            HomeView(progress: c, life: life, loadArt: () async => pack),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> tick(WidgetTester tester, int tenths) async {
  for (var i = 0; i < tenths; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> export(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('HOME_REVIEW')) return;
  await tester.runAsync(() async {
    final boundary =
        captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/design-v2/home/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Finder cat(KittyId id) => find.byKey(ValueKey('home-cat-${id.name}'));
Finder button(String key) => find.byKey(ValueKey(key));

class WaitingAds implements RewardedAds {
  final done = Completer<bool>();
  @override
  Future<bool> show() => done.future;
}

void main() {
  setUpAll(() async {
    pack = await ArtPack.load();
  });

  testWidgets(
    'migration notice is acknowledged once and failed area change retains previous area',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final store = AtomicTestStore()
        ..language = AppLanguage.id
        ..home = Home(room: fullRoom());
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      await pumpHome(tester, c);
      expect(find.text(l10nId.homeMigration), findsOneWidget);
      await tap(tester, find.text(l10nId.close));
      expect(c.household.migrationNotice, isFalse);
      store.fail = true;
      await tap(tester, find.text('Makan · 0/2'));
      expect(c.household.lastArea, HomeArea.santai);
      expect(c.householdSaveFailed, isTrue);
      store.fail = false;
      await tap(tester, find.text(l10nId.homeRetry));
      expect(c.household.lastArea, HomeArea.makan);
      final again = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      expect(again.household.migrationNotice, isFalse);
      expect(again.household.lastArea, HomeArea.makan);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'asset failure offers a working retry without changing house state',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load();
      var attempts = 0;
      await tester.pumpWidget(
        KucingOrenApp(
          progress: c,
          roomLife: false,
          homeBuilder: (_) => HomeView(
            progress: c,
            life: false,
            loadArt: () async {
              if (++attempts == 1) throw StateError('asset unavailable');
              return pack;
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(l10nId.homeLoadFailed), findsOneWidget);
      await tap(tester, find.text(l10nId.homeRetry));
      expect(cat(KittyId.oyen), findsOneWidget);
      expect(attempts, 2);
      expect(c.household.routine.locations[KittyId.oyen], HomeArea.santai);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'ad pause composes with background pause and failed saves stop the active clock',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final ads = WaitingAds();
      final store = AtomicTestStore()
        ..language = AppLanguage.id
        ..needs = HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 40, at: now)},
        );
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
        coinAds: ads,
      );
      await c.acknowledgeHomeMigration();
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      await pumpHome(tester, c, life: true);
      await tick(tester, 18);
      final watching = c.watchAdForCoins();
      final paused = c.household.routine.toJson();
      c.pauseHousehold(HouseholdPause.background);
      await tick(tester, 60);
      expect(c.household.routine.toJson(), paused);
      ads.done.complete(true);
      await watching;
      await tick(tester, 10);
      expect(c.householdPaused, isTrue);
      expect(c.household.routine.toJson(), paused);
      c.resumeHousehold(HouseholdPause.background);
      store.fail = true;
      await tick(tester, 10);
      expect(c.householdSaveFailed, isTrue);
      final failed = c.household.routine.toJson();
      await tick(tester, 50);
      expect(c.household.routine.toJson(), failed);
      store.fail = false;
      await c.retrySaves();
      await tick(tester, 50);
      expect(c.needs.bowl.eaten, contains(KittyId.oyen));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'system reduced motion keeps the scheduler running with static art',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final c = await load(
        needs: HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 80, at: now)},
        ),
      );
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      await pumpHome(tester, c, life: true);
      expect(tester.widget<HomeScene>(find.byType(HomeScene)).animate, isFalse);
      await tick(tester, 70);
      expect(c.needs.bowl.eaten, contains(KittyId.oyen));
      expect(c.catNeeds(KittyId.oyen).hunger, 80);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'starter uses only owned cats; puzzle navigation retains area and selection',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load();
      await pumpHome(tester, c);
      expect(cat(KittyId.oyen), findsOneWidget);
      expect(cat(KittyId.salju), findsNothing);
      expect(find.text('Santai · 1/3'), findsOneWidget);
      await export(tester, 'santai-baru-id');
      await tap(tester, find.text('Main Puzzle'));
      await settle(tester);
      expect(c.householdPaused, isTrue);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(c.selectedHomeKitty, KittyId.oyen);
      expect(c.household.lastArea, HomeArea.santai);
      expect(c.householdPaused, isFalse);
      expect(cat(KittyId.oyen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'full house: tabs do not move cats; collection finds every cat without duplication',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load(
        home: Home(kitties: KittyId.values, room: fullRoom()),
      );
      await pumpHome(tester, c);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('home-cat-'),
        ),
        findsNWidgets(3),
      );
      for (final label in [
        'Santai · 3/3',
        'Makan · 2/2',
        'Main · 2/2',
        'Rawat · 2/2',
      ]) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      final scene = tester.getRect(button('home-scene'));
      final targets = [
        for (final kitty in c.household.routine.present(HomeArea.santai))
          tester.getRect(cat(kitty)),
      ];
      for (var i = 0; i < targets.length; i++) {
        expect(scene.contains(targets[i].topLeft), isTrue);
        expect(scene.contains(targets[i].bottomRight), isTrue);
        expect(targets[i].width, greaterThanOrEqualTo(48));
        for (var j = i + 1; j < targets.length; j++) {
          expect(targets[i].overlaps(targets[j]), isFalse);
        }
      }
      await export(tester, 'santai-penuh-id');
      final before = c.household.routine.toJson();
      await tap(tester, find.text('Makan · 2/2'));
      expect(c.household.lastArea, HomeArea.makan);
      expect(c.household.routine.toJson(), before);
      expect(cat(KittyId.oyen), findsNothing);
      await tap(tester, find.text('Kucing'));
      await tap(tester, button('home-find-kembang'));
      expect(c.selectedHomeKitty, KittyId.kembang);
      expect(
        c.household.lastArea,
        c.household.routine.findArea(KittyId.kembang),
      );
      expect(cat(KittyId.kembang), findsOneWidget);
      final restored = await load(store: c.store as AtomicTestStore);
      expect(restored.household.lastArea, c.household.lastArea);
      expect(restored.selectedHomeKitty, restored.household.initialSelection);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'invitation and journey remain live in sheets; cancel releases reservation',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load(
        needs: HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 40, at: now)},
        ),
      );
      await pumpHome(tester, c);
      await tap(tester, find.text('Oyen').last);
      await tap(tester, button('home-invite-eat'));
      expect(
        c.household.routine.invitations[KittyId.oyen]?.kind,
        HomeActivity.eat,
      );
      await c.advanceHousehold(0);
      await tester.pump();
      expect(find.text('Menuju Makan…'), findsWidgets);
      await tap(tester, find.text('Batalkan ajakan'));
      expect(c.household.routine.journeys, isEmpty);
      expect(c.household.routine.locations[KittyId.oyen], HomeArea.santai);
      expect(c.household.routine.reserved(HomeArea.makan), 0);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      await c.advanceHousehold(0);
      await c.advanceHousehold(.6);
      await tester.pump();
      expect(cat(KittyId.oyen), findsNothing);
      await tap(tester, find.text('Lihat area'));
      expect(cat(KittyId.oyen), findsOneWidget);
      await export(tester, 'perjalanan-makan-id');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('empty area is usable and does not teleport the selection', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    final c = await load();
    await c.setHomeArea(HomeArea.main);
    await pumpHome(tester, c);
    expect(
      find.text('Area ini lagi sepi. Temukan kucing lewat koleksi, yuk.'),
      findsOneWidget,
    );
    expect(cat(KittyId.oyen), findsNothing);
    expect(c.household.routine.locations[KittyId.oyen], HomeArea.santai);
    await export(tester, 'area-kosong-id');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'failed reward transaction shows retry; repeated claim awards once',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final store = AtomicTestStore()..coins = 5;
      final c = await load(
        store: store,
        home: Home(kitties: KittyId.values),
      );
      await pumpHome(tester, c);
      await tap(tester, button('home-rewards'));
      store.fail = true;
      await tap(tester, button('home-claim-all'));
      expect(c.coins, 5);
      expect(find.text(l10nId.homeSaveFailed).hitTestable(), findsOneWidget);
      store.fail = false;
      await tap(tester, find.text('Coba lagi').last);
      expect(c.coins, 95);
      await tap(tester, button('home-claim-all'));
      expect(c.coins, 95);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      final again = await load(store: store);
      expect(again.coins, 95);
      expect(again.claimableKitties, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'clock runs with reduced motion and sheets, pauses for routes/background and resumes without offline jump',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load(
        needs: HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 80, at: now)},
        ),
      );
      await c.setReducedMotion(true);
      await c.inviteKitty(KittyId.oyen, HomeActivity.eat);
      await pumpHome(tester, c, life: true);
      await tick(tester, 18);
      final action = c.household.routine.activities[KittyId.oyen]!;
      expect(action.left, greaterThan(0));
      await tap(tester, find.text('Kucing'));
      await tick(tester, 5);
      expect(
        c.household.routine.activities[KittyId.oyen]!.left,
        lessThan(action.left),
      );
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      final paused = c.household.routine.toJson();
      await tick(tester, 100);
      expect(c.household.routine.toJson(), paused);
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tick(tester, 1);
      expect(c.household.routine.toJson(), paused);
      await tick(tester, 50);
      expect(c.catNeeds(KittyId.oyen).hunger, 80);
      final ctx = tester.element(find.byType(HomeView));
      GoRouter.of(ctx).go('/pengaturan');
      await tester.pump(const Duration(milliseconds: 300));
      final hidden = c.household.routine.toJson();
      await tick(tester, 60);
      expect(c.household.routine.toJson(), hidden);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'snack and accessory inventory remains accessible from the cat sheet',
    (tester) async {
      setScreenSize(tester, const Size(390, 844));
      final c = await load(
        home: Home(
          pantry: Pantry({SnackId.ikanAsin: 2}),
          closet: AccessoryCloset(owned: [AccessoryId.pita]),
        ),
        needs: HomeNeeds(
          cats: {KittyId.oyen: CatNeeds(hunger: 40, joy: 40, at: now)},
        ),
      );
      await pumpHome(tester, c);
      await tap(tester, find.text('Oyen').last);
      await tap(tester, find.text(l10nId.snackPanel));
      await tick(tester, 4);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<UiSheet>(),
        isNotNull,
      );
      await tap(tester, find.text(l10nId.snackGive('Ikan Asin', 2)));
      expect(c.home.pantry.countOf(SnackId.ikanAsin), 1);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      await tap(tester, find.text('Oyen').last);
      await tap(tester, find.text(l10nId.accessories));
      await tap(tester, find.text('Pita'));
      expect(c.home.closet.wearingOf(KittyId.oyen), AccessoryId.pita);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final language in [
    AppLanguage.id,
    AppLanguage.en,
    AppLanguage.pt,
    AppLanguage.ru,
  ]) {
    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(412, 915),
    ]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'home and full collection fit $language $size text $scale',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            final c = await load(
              language: language,
              store: AtomicTestStore()..coins = 99999,
              home: Home(kitties: KittyId.values),
            );
            await pumpHome(tester, c);
            final l = lookupAppLocalizations(Locale(language.name));
            final puzzle = tester.getRect(find.text(l.uiPlayPuzzle));
            // Each navigation label is a single word in these locales. Keep
            // the Portuguese settings word intact at the largest text scale.
            expect(
              tester.getSize(find.text(l.settings)).height,
              lessThanOrEqualTo(30),
            );
            expect(puzzle.bottom, lessThanOrEqualTo(size.height));
            expect(tester.takeException(), isNull);
            if (size == const Size(360, 640) && scale == 1.3) {
              await export(tester, 'santai-${language.name}-360-130');
            }
            await tap(tester, find.text(l.homeCats));
            await tap(tester, button('home-find-kembang'));
            await tester.pump(const Duration(milliseconds: 250));
            expect(cat(KittyId.kembang), findsOneWidget);
            expect(
              find.text(l.homeAreaCount(l.homeInviteCare, 2, 2)).hitTestable(),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
