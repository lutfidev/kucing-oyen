import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/screens/room/area_decorate.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';
import 'package:kucing_oren/widgets/v2/catalog_art.dart';

import '../app/household_progress_test.dart' show AtomicTestStore;
import '../test_helpers.dart';

late ArtPack pack;
final captureKey = GlobalKey();
final now = DateTime(2026, 11, 10, 12);
Finder key(String value) => find.byKey(ValueKey(value));
Future<void> tap(WidgetTester t, String value) async {
  await t.ensureVisible(key(value));
  await t.pump();
  await t.tap(key(value));
  await settle(t);
}

Future<ProgressController> load({
  AtomicTestStore? store,
  AppLanguage lang = AppLanguage.id,
  int coins = 1000,
}) async {
  final data = store ?? AtomicTestStore();
  data.language = lang;
  data.coins = coins;
  data.home = Home(
    room: Room(owned: [RoomItemId.kardus, RoomItemId.jam, RoomItemId.bola]),
    kitties: [KittyId.salju],
    closet: AccessoryCloset(owned: [AccessoryId.pita]),
  );
  final c = await ProgressController.load(
    levels: testLevels,
    store: data,
    clock: () => now,
  );
  await c.acknowledgeHomeMigration();
  return c;
}

Future<void> pump(
  WidgetTester t,
  ProgressController c, {
  ShopTab? tab,
  Future<ArtPack> Function()? loader,
}) async {
  if (t.view.physicalSize / t.view.devicePixelRatio == const Size(800, 600)) {
    setScreenSize(t, const Size(390, 844));
  }
  await t.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: KucingOrenApp(
        key: UniqueKey(),
        progress: c,
        roomLife: false,
        loadShopArt: loader ?? () async => pack,
        initialLocation: tab == null ? '/' : '/toko?tab=${tab.name}',
        homeBuilder: (_) =>
            HomeView(progress: c, life: false, loadArt: () async => pack),
      ),
    ),
  );
  await settle(t);
  await t.runAsync(() async {
    final context = t.element(find.byType(Scaffold).first);
    for (final provider in [
      PaintedScenery.lounge,
      PaintedScenery.dining,
      PaintedScenery.play,
      PaintedScenery.care,
    ]) {
      await precacheImage(provider, context);
    }
  });
  await t.pump();
}

Future<void> capture(WidgetTester t, String name) async {
  if (!const bool.fromEnvironment('SHOP_REVIEW')) return;
  await t.runAsync(() async {
    final boundary =
        captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/design-v2/shop/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  testWidgets('catalog asset failure retries without changing the wallet', (
    t,
  ) async {
    var tries = 0;
    final c = await load();
    await pump(
      t,
      c,
      tab: ShopTab.items,
      loader: () async {
        if (++tries == 1) throw StateError('temporary asset failure');
        return pack;
      },
    );
    expect(find.text(l10nId.homeLoadFailed), findsOneWidget);
    await t.tap(find.text(l10nId.homeRetry));
    await settle(t);
    expect(key('shop-item-tikus'), findsOneWidget);
    expect(c.coins, 1000);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'store keeps ownership and Gudang can place the item again in another area',
    (t) async {
      final c = await load();
      await c.saveAreaLayout(
        c.household.areas.place(
          c.home,
          RoomItemId.kardus,
          const AreaSlot(HomeArea.santai, RoomZone.floor, 0),
        ),
      );
      await pump(t, c);
      await tap(t, 'home-decorate');
      await tap(t, 'decorate-item-kardus');
      await tap(t, 'decorate-store');
      await tap(t, 'decorate-storage');
      expect(key('decorate-item-kardus'), findsOneWidget);
      expect(key('decorate-item-mangkuk'), findsNothing);
      await capture(t, 'gudang-id');
      await tap(t, 'decorate-save');
      expect(c.household.areas.placed[RoomItemId.kardus], isNull);
      expect(c.home.room.owns(RoomItemId.kardus), isTrue);
      await tap(t, 'home-decorate');
      await tap(t, 'decorate-item-kardus');
      await tap(t, 'decorate-area-rawat');
      await tap(t, 'decorate-slot-floor-2');
      await tap(t, 'decorate-save');
      expect(
        c.household.areas.placed[RoomItemId.kardus],
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 2),
      );
    },
  );
  testWidgets('close purchase during write then retry from shop charges once', (
    t,
  ) async {
    final store = AtomicTestStore();
    final c = await load(store: store, coins: 200);
    await pump(t, c, tab: ShopTab.items);
    await tap(t, 'shop-item-tikus');
    store.hold = Completer<void>();
    await tap(t, 'buy-confirm');
    expect(c.householdBusy, isTrue);
    await tap(t, 'buy-close');
    expect(key('buy-confirm'), findsNothing);
    store.fail = true;
    store.hold!.complete();
    await settle(t);
    expect(c.coins, 200);
    expect(c.householdSaveFailed, isTrue);
    store.fail = false;
    final retry = find.text(l10nId.homeRetry);
    await t.ensureVisible(retry);
    await t.tap(retry);
    await settle(t);
    expect(c.coins, 80);
    expect(c.home.room.owns(RoomItemId.tikus), isTrue);
    await c.retrySaves();
    expect(c.coins, 80);
  });
  testWidgets(
    'rapid editor open stays single and pause lasts through reverse transition',
    (t) async {
      final c = await load();
      await pump(t, c);
      final context = t.element(find.byType(HomeView));
      final first = showAreaDecorate(context, c, pack);
      await showAreaDecorate(context, c, pack);
      await settle(t);
      expect(find.byType(AreaDecorate), findsOneWidget);
      expect(c.householdDecorating, isTrue);
      await t.tap(key('decorate-cancel'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(c.householdDecorating, isTrue);
      await settle(t);
      await first;
      expect(c.householdDecorating, isFalse);
      expect(c.householdPaused, isFalse);
    },
  );
  setUpAll(() async {
    pack = await ArtPack.load();
  });
  testWidgets(
    'draft moves area, invalid zone stays put, bowl fixed, save and reload',
    (t) async {
      setScreenSize(t, const Size(390, 844));
      final store = AtomicTestStore();
      final c = await load(store: store);
      await pump(t, c);
      await tap(t, 'home-decorate');
      expect(c.householdPaused, isTrue);
      final before = c.household.areas;
      await tap(t, 'decorate-item-kardus');
      await tap(t, 'decorate-slot-wall-0');
      expect(c.household.areas, before);
      expect(find.text(l10nId.decorateInvalid), findsOneWidget);
      await tap(t, 'decorate-area-rawat');
      await tap(t, 'decorate-slot-floor-1');
      expect(c.household.areas, before);
      await capture(t, 'hias-draf-id');
      await tap(t, 'decorate-save');
      expect(find.byType(AreaDecorate), findsNothing);
      expect(c.householdPaused, isFalse);
      expect(
        c.household.areas.placed[RoomItemId.kardus],
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 1),
      );
      final restored = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      expect(restored.household.areas, c.household.areas);
      await tap(t, 'home-decorate');
      await tap(t, 'decorate-item-mangkuk');
      expect(find.text(l10nId.decorateBowlFixed), findsOneWidget);
      expect(c.household.areas.store(RoomItemId.mangkuk), c.household.areas);
      await tap(t, 'decorate-cancel');
      expect(find.byType(AreaDecorate), findsNothing);
    },
  );
  testWidgets('back prompts; continue and discard preserve committed layout', (
    t,
  ) async {
    final c = await load();
    await pump(t, c);
    await tap(t, 'home-decorate');
    final before = c.household.areas;
    await tap(t, 'decorate-item-kardus');
    await tap(t, 'decorate-slot-floor-0');
    await t.binding.handlePopRoute();
    await settle(t);
    expect(find.text(l10nId.decorateUnsaved), findsOneWidget);
    await t.tap(find.text(l10nId.decorateContinue));
    await settle(t);
    expect(find.byType(AreaDecorate), findsOneWidget);
    await tap(t, 'decorate-cancel');
    await tap(t, 'decorate-discard');
    expect(c.household.areas, before);
    expect(c.householdPaused, isFalse);
  });
  testWidgets(
    'failed save can retry once or discard without a later hidden commit',
    (t) async {
      final store = AtomicTestStore();
      final c = await load(store: store);
      await pump(t, c);
      await tap(t, 'home-decorate');
      final before = c.household.areas;
      await tap(t, 'decorate-item-kardus');
      await tap(t, 'decorate-slot-floor-0');
      store.fail = true;
      await tap(t, 'decorate-save');
      expect(c.household.areas, before);
      expect(c.householdSaveFailed, isTrue);
      await capture(t, 'hias-gagal-id');
      await tap(t, 'decorate-cancel');
      await tap(t, 'decorate-discard');
      store.fail = false;
      await c.retrySaves();
      expect(c.household.areas, before);
      expect(c.needs.decoratedAt, isNull);
      await tap(t, 'home-decorate');
      await tap(t, 'decorate-item-kardus');
      await tap(t, 'decorate-slot-floor-0');
      store.fail = true;
      await tap(t, 'decorate-save');
      store.fail = false;
      await tap(t, 'decorate-retry');
      expect(c.householdSaveFailed, isFalse);
      expect(c.needs.decoratedAt, isNotNull);
      expect(find.byType(AreaDecorate), findsNothing);
    },
  );
  testWidgets(
    'drag into slot accepts; release outside and overlap preserve layout',
    (t) async {
      setScreenSize(t, const Size(360, 640));
      final c = await load();
      await pump(t, c);
      await tap(t, 'home-decorate');
      await tap(t, 'decorate-item-kardus');
      final source = key('decorate-drag-floor');
      await t.ensureVisible(source);
      await settle(t);
      await t.drag(
        source,
        t.getCenter(key('decorate-slot-floor-0')) - t.getCenter(source),
      );
      await settle(t);
      final target = find.ancestor(
        of: key('decorate-slot-floor-0'),
        matching: find.byType(DragTarget<RoomItemId>),
      );
      expect(
        t
            .widget<CatalogArt>(
              find.descendant(of: target, matching: find.byType(CatalogArt)),
            )
            .item,
        RoomItemId.kardus,
      );
      await t.drag(source, const Offset(-500, 0));
      await settle(t);
      expect(find.text(l10nId.decorateInvalid), findsOneWidget);
      await tap(t, 'decorate-item-bola');
      await tap(t, 'decorate-slot-floor-0');
      expect(find.text(l10nId.decorateInvalid), findsOneWidget);
      expect(await c.advanceHousehold(10), isFalse);
      await tap(t, 'decorate-cancel');
      await tap(t, 'decorate-discard');
      expect(c.household.areas.placed[RoomItemId.kardus], isNull);
    },
  );
  testWidgets(
    'failed purchase stays in sheet; retry, balance and ownership agree',
    (t) async {
      final store = AtomicTestStore();
      final c = await load(store: store, coins: 200);
      // Owned kardus above is a storage fixture; choose another affordable item.
      await pump(t, c, tab: ShopTab.items);
      await tap(t, 'shop-item-tikus');
      final price = roomItemOf(RoomItemId.tikus).price;
      expect(find.text(l10nId.shopBalanceAfter(200 - price)), findsOneWidget);
      store.fail = true;
      await tap(t, 'buy-confirm');
      expect(c.coins, 200);
      expect(c.home.room.owns(RoomItemId.tikus), isFalse);
      store.fail = false;
      await tap(t, 'buy-retry');
      expect(c.coins, 200 - price);
      expect(c.home.room.owns(RoomItemId.tikus), isTrue);
      expect(find.text(l10nId.buySuccessOverline), findsOneWidget);
      await capture(t, 'beli-sukses-id');
    },
  );
  for (final lang in AppLanguage.supported) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('shop and decoration ${lang.name} 360x640 text $scale', (
        t,
      ) async {
        setScreenSize(t, const Size(360, 640));
        setTextScale(t, scale);
        final c = await load(lang: lang);
        await c.setReducedMotion(true);
        await pump(t, c, tab: ShopTab.items);
        await capture(t, 'toko-${lang.name}-360-${(scale * 100).round()}');
        for (final tab in ShopTab.values) {
          await tap(t, 'shop-tab-${tab.name}');
          if (lang == AppLanguage.id && scale == 1.0) {
            await capture(t, 'toko-${tab.name}-id');
          }
          expect(t.takeException(), isNull);
        }
        GoRouter.of(t.element(find.byType(ShopScreen))).go('/');
        await settle(t);
        await tap(t, 'home-decorate');
        await capture(t, 'hias-${lang.name}-360-${(scale * 100).round()}');
        await tap(t, 'decorate-item-kardus');
        await tap(t, 'decorate-slot-floor-0');
        expect(t.widget<UiButton>(key('decorate-save')).onPressed, isNotNull);
        expect(
          t.getSize(key('decorate-save')).height,
          greaterThanOrEqualTo(48),
        );
        expect(t.takeException(), isNull);
        await tap(t, 'decorate-save');
        expect(c.householdPaused, isFalse);
      });
    }
  }
}
