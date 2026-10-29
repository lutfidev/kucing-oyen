import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/screens/room/kitty_card.dart';
import 'package:kucing_oren/screens/room/room_view.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

Future<void> openCard(WidgetTester tester, [KittyId k = KittyId.oyen]) async {
  await tester.tap(kittyView(k).first);
  await tester.pumpAndSettle();
}

Finder card() => find.byType(KittyCard);

Finder inCard(Finder f) => find.descendant(of: card(), matching: f);

/// Mengetuk teks [text] di kartu (digulir dulu ke layar), satu bingkai.
Future<void> tapInCard(WidgetTester tester, String text) async {
  final target = inCard(find.text(text));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}

void main() {
  testWidgets('ketuk kucing membuka kartu dengan nama, keterangan, dan bar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpRoom(tester, progress: withNeeds({KittyId.oyen: (55, 72)}));
    expect(card(), findsNothing);
    await openCard(tester);
    expect(card(), findsOneWidget);
    expect(inCard(find.text('Oyen')), findsOneWidget);
    expect(inCard(find.text(l10nId.kittyOyenDesc)), findsOneWidget);
    expect(inCard(find.text('Lapar')), findsOneWidget);
    expect(inCard(find.text('Senang')), findsOneWidget);
    expect(inCard(find.text('55')), findsOneWidget);
    expect(inCard(find.text('72')), findsOneWidget);
    expect(find.bySemanticsLabel('Lapar 55 dari 100'), findsOneWidget);
    expect(find.bySemanticsLabel('Kartu Oyen'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('bar hampir habis memberi tahu', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRoom(tester, progress: withNeeds({KittyId.oyen: (12, 80)}));
    await openCard(tester);
    expect(
      inCard(find.text('Hampir habis! Perutnya keroncongan.')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Lapar 12 dari 100, hampir habis'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Elus menambah Senang dan memunculkan reaksi', (tester) async {
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({KittyId.oyen: (80, 50)}),
    );
    await openCard(tester);
    await tapInCard(tester, 'Elus');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+10 senang'), findsOneWidget);
    expect(progress.catNeeds(KittyId.oyen).joy, 60);
    await tester.pumpAndSettle();
    expect(find.text('+10 senang'), findsNothing);
    expect(card(), findsOneWidget);
  });

  testWidgets('batas elus: elusan keempat hanya memunculkan hati', (
    tester,
  ) async {
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({KittyId.oyen: (80, 20)}),
    );
    await openCard(tester);
    for (var i = 0; i < 3; i++) {
      await tapInCard(tester, 'Elus');
      await tester.pumpAndSettle();
    }
    expect(progress.catNeeds(KittyId.oyen).joy, 50);
    await tapInCard(tester, 'Elus');
    await tester.pump(const Duration(milliseconds: 300));
    expect(progress.catNeeds(KittyId.oyen).joy, 50);
    expect(find.text('+10 senang'), findsNothing);
    expect(find.byKey(const ValueKey('reaction-hearts')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Camilan: Ikan Asin mengurangi stok dan menambah Lapar', (
    tester,
  ) async {
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (40, 50),
      }, home: Home(pantry: Pantry({SnackId.ikanAsin: 2}))),
    );
    await openCard(tester);
    await tapInCard(tester, 'Camilan');
    await tester.pumpAndSettle();
    expect(inCard(find.text('PILIH DARI STOK')), findsOneWidget);
    expect(inCard(find.text('×2')), findsOneWidget);
    await tapInCard(tester, 'Ikan Asin');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+25 kenyang'), findsOneWidget);
    expect(progress.catNeeds(KittyId.oyen).hunger, 65);
    expect(progress.home.pantry.countOf(SnackId.ikanAsin), 1);
    await tester.pumpAndSettle();
    expect(inCard(find.text('×1')), findsOneWidget);
  });

  testWidgets('Puding Ikan menambah Lapar dan Senang', (tester) async {
    await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (10, 10),
      }, home: Home(pantry: Pantry({SnackId.puding: 1}))),
    );
    await openCard(tester);
    await tapInCard(tester, 'Camilan');
    await tester.pumpAndSettle();
    await tapInCard(tester, 'Puding Ikan');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+60 kenyang, +15 senang'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('camilan habis: tombolnya mati', (tester) async {
    final semantics = tester.ensureSemantics();
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({KittyId.oyen: (40, 50)}),
    );
    await openCard(tester);
    await tapInCard(tester, 'Camilan');
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Beri Tuna Kaleng, stok 0, habis'),
      findsOneWidget,
    );
    await tapInCard(tester, 'Tuna Kaleng');
    await tester.pumpAndSettle();
    expect(progress.catNeeds(KittyId.oyen).hunger, 40);
    semantics.dispose();
  });

  testWidgets('ketukan ganda camilan hanya memotong satu stok', (tester) async {
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (40, 50),
      }, home: Home(pantry: Pantry({SnackId.biskuit: 5}))),
    );
    await openCard(tester);
    await tapInCard(tester, 'Camilan');
    await tester.pumpAndSettle();
    final biskuit = inCard(find.text('Biskuit Kucing'));
    await tester.ensureVisible(biskuit);
    await tester.pumpAndSettle();
    await tester.tap(biskuit);
    await tester.tap(biskuit);
    await tester.pumpAndSettle();
    expect(progress.home.pantry.countOf(SnackId.biskuit), 4);
  });

  testWidgets('Aksesoris: memasang dan melepas dari kartu', (tester) async {
    final progress = await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (80, 80),
      }, home: Home(closet: AccessoryCloset(owned: const [AccessoryId.pita]))),
    );
    await openCard(tester);
    await tapInCard(tester, 'Aksesoris');
    await tester.pumpAndSettle();
    expect(inCard(find.text('PUNYAMU · GANTI GRATIS')), findsOneWidget);
    await tapInCard(tester, 'Pita');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Cakep!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(progress.home.closet.wearingOf(KittyId.oyen), AccessoryId.pita);
    expect(inCard(find.text('Dipakai')), findsOneWidget);
    expect(
      tester
          .widgetList<KittyView>(kittyView(KittyId.oyen))
          .every((v) => v.look.accessory == AccessoryId.pita),
      isTrue,
    );
    await tapInCard(tester, 'Lepas');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lega!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(progress.home.closet.wearingOf(KittyId.oyen), isNull);
  });

  testWidgets('Toko aksesoris → membuka Toko tab Aksesoris', (tester) async {
    await pumpRoom(tester);
    await openCard(tester);
    await tapInCard(tester, 'Aksesoris');
    await tester.pumpAndSettle();
    await tapInCard(tester, 'Toko aksesoris');
    await settle(tester);
    expect(
      tester.widget<ShopScreen>(find.byType(ShopScreen)).initialTab,
      ShopTab.accessories,
    );
  });

  testWidgets('kartu ditutup lewat tombol X, latar, dan tombol kembali', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpRoom(tester);
    await openCard(tester);
    await tester.tap(find.bySemanticsLabel('Tutup kartu'));
    await tester.pumpAndSettle();
    expect(card(), findsNothing);

    await openCard(tester);
    await tester.tapAt(const Offset(195, 830));
    await tester.pumpAndSettle();
    expect(card(), findsNothing);

    await openCard(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(card(), findsNothing);
    expect(find.byType(RoomView), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('tanda lesu di atas kucing yang lesu', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRoom(
      tester,
      progress: withNeeds({
        KittyId.oyen: (15, 80),
        KittyId.salju: (80, 15),
        KittyId.telon: (60, 60),
      }, home: Home(kitties: const [KittyId.salju, KittyId.telon])),
    );
    expect(find.bySemanticsLabel('Lesu: lapar'), findsOneWidget);
    expect(find.bySemanticsLabel('Lesu: kurang perhatian'), findsOneWidget);
    expect(find.byType(SadMarkView), findsNWidgets(2));
    expect(
      find.bySemanticsLabel('Oyen, lapar. Ketuk untuk lihat kartunya'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('kartu kucing di 360×640 teks 130% bisa digulir', (tester) async {
    setTextScale(tester, 1.3);
    await pumpRoom(
      tester,
      size: const Size(360, 640),
      progress: withNeeds({
        KittyId.oyen: (12, 12),
      }, home: Home(pantry: Pantry({for (final s in SnackId.values) s: 99}))),
    );
    await openCard(tester);
    await tapInCard(tester, 'Camilan');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final last = inCard(find.text('Puding Ikan'));
    await tester.ensureVisible(last);
    await tester.pumpAndSettle();
    expect(tester.getRect(last).bottom, lessThanOrEqualTo(640));
    expect(tester.getRect(card()).bottom, lessThanOrEqualTo(640));
  });

  testWidgets('kurangi gerak: reaksi tetap muncul lalu hilang', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpRoom(tester, progress: withNeeds({KittyId.oyen: (80, 50)}));
    await openCard(tester);
    await tapInCard(tester, 'Elus');
    await tester.pump();
    expect(find.text('+10 senang'), findsOneWidget);
    // Tetap tampil (diam) selama waktu reaksi biasa, baru hilang.
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('+10 senang'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('+10 senang'), findsNothing);
  });
}
