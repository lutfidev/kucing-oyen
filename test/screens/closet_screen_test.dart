import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/closet/closet_parts.dart';
import 'package:kucing_oren/screens/closet/closet_screen.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

Finder _card(OyenCostume id) => find.byKey(ValueKey('costume-${id.name}'));

/// Teks [text] di dalam kartu kostum [id].
Finder _inCard(OyenCostume id, String text) =>
    find.descendant(of: _card(id), matching: find.text(text));

/// Tombol aksi di bawah layar (`KoButton` satu-satunya).
KoButton _action(WidgetTester tester) =>
    tester.widget<KoButton>(find.byType(KoButton));

/// Oyen pratinjau di lemari (ukuran 168).
OyenView _preview(WidgetTester tester) => tester
    .widgetList<OyenView>(find.byType(OyenView))
    .firstWhere((v) => v.size == 168);

Future<ProgressController> _openCloset(
  WidgetTester tester, {
  int coins = 0,
  Wardrobe? wardrobe,
}) {
  setScreenSize(tester, const Size(390, 844));
  return pumpApp(
    tester,
    location: AppRoutes.closet,
    progress: testProgressWith(coins: coins, wardrobe: wardrobe),
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await settle(tester);
}

void main() {
  testWidgets('awal: lima kartu, Polos dipakai dan terpilih', (tester) async {
    await _openCloset(tester);
    expect(find.text('Lemari Kostum'), findsOneWidget);
    final tops = [for (final c in costumes) tester.getTopLeft(_card(c.id))];
    // Grid 2 kolom: Polos-Peci, Sarung-Topi Koki, Kacamata.
    expect(tops[0].dy, tops[1].dy);
    expect(tops[2].dy, greaterThan(tops[0].dy));
    expect(tops[4].dx, tops[0].dx);
    expect(_inCard(OyenCostume.none, 'Polos'), findsOneWidget);
    expect(_inCard(OyenCostume.none, 'Dipakai'), findsOneWidget);
    expect(_inCard(OyenCostume.peci, '60'), findsOneWidget);
    expect(_inCard(OyenCostume.sarung, '90'), findsOneWidget);
    expect(_inCard(OyenCostume.koki, '150'), findsOneWidget);
    expect(_inCard(OyenCostume.kacamata, '45'), findsOneWidget);
    expect(_action(tester).label, 'Sedang dipakai');
    expect(_action(tester).onPressed, isNull);
    expect(_preview(tester).look.costume, OyenCostume.none);
    expect(_preview(tester).look.pose, OyenPose.happy);
    expect(find.bySemanticsLabel('0 koin, tambah koin'), findsOneWidget);
  });

  testWidgets('pilih kartu hanya pratinjau, beli memotong koin dan memakai', (
    tester,
  ) async {
    final progress = await _openCloset(tester, coins: 120);
    await _tap(tester, _card(OyenCostume.peci));
    expect(_preview(tester).look.costume, OyenCostume.peci);
    expect(find.text('Peci'), findsNWidgets(2)); // nama pratinjau + kartu
    expect(_action(tester).label, 'Beli · 60 koin');
    expect(progress.wardrobe.wearing, OyenCostume.none);

    await _tap(tester, find.byType(KoButton));
    expect(progress.coins, 60);
    expect(progress.wardrobe.wearing, OyenCostume.peci);
    expect(find.bySemanticsLabel('60 koin, tambah koin'), findsOneWidget);
    expect(_inCard(OyenCostume.peci, 'Dipakai'), findsOneWidget);
    expect(_inCard(OyenCostume.none, 'Punyamu'), findsOneWidget);
    expect(_action(tester).label, 'Sedang dipakai');
    final store = progress.store as MemoryProgressStore;
    expect(store.wardrobe.wearing, OyenCostume.peci);
    expect(store.coins, 60);
  });

  testWidgets('koin pas dengan harga: bisa beli, saldo jadi 0', (tester) async {
    await _openCloset(tester, coins: 45);
    await _tap(tester, _card(OyenCostume.kacamata));
    expect(_action(tester).label, 'Beli · 45 koin');
    await _tap(tester, find.byType(KoButton));
    expect(find.bySemanticsLabel('0 koin, tambah koin'), findsOneWidget);
    expect(_inCard(OyenCostume.kacamata, 'Dipakai'), findsOneWidget);
  });

  testWidgets('koin kurang: tombol mati, tidak ada yang berubah', (
    tester,
  ) async {
    final progress = await _openCloset(tester, coins: 30);
    await _tap(tester, _card(OyenCostume.koki));
    expect(_action(tester).label, 'Koin kurang · 150');
    expect(_action(tester).onPressed, isNull);
    await _tap(tester, find.byType(KoButton));
    expect(progress.coins, 30);
    expect(progress.wardrobe, Wardrobe.initial);
  });

  testWidgets('kostum dimiliki: "Punyamu", lalu Pakai', (tester) async {
    final progress = await _openCloset(
      tester,
      wardrobe: Wardrobe(owned: {OyenCostume.peci}),
    );
    expect(_inCard(OyenCostume.peci, 'Punyamu'), findsOneWidget);
    await _tap(tester, _card(OyenCostume.peci));
    expect(_action(tester).label, 'Pakai');
    await _tap(tester, find.byType(KoButton));
    expect(progress.wardrobe.wearing, OyenCostume.peci);
    expect(_inCard(OyenCostume.peci, 'Dipakai'), findsOneWidget);
  });

  testWidgets('dibuka lagi: terpilih kostum yang dipakai', (tester) async {
    await _openCloset(
      tester,
      coins: 500,
      wardrobe: Wardrobe(
        owned: {OyenCostume.kacamata},
        wearing: OyenCostume.kacamata,
      ),
    );
    expect(_preview(tester).look.costume, OyenCostume.kacamata);
    await _tap(tester, _card(OyenCostume.sarung));
    await _tap(tester, find.bySemanticsLabel('Kembali ke Beranda'));
    expect(find.byType(HomeScreen), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Lemari Kostum'));
    expect(find.byType(ClosetScreen), findsOneWidget);
    expect(_preview(tester).look.costume, OyenCostume.kacamata);
    expect(_action(tester).label, 'Sedang dipakai');
  });

  testWidgets('kartu terpilih ditandai untuk pembaca layar', (tester) async {
    await _openCloset(tester);
    await _tap(tester, _card(OyenCostume.sarung));
    expect(
      tester.getSemantics(_card(OyenCostume.sarung)),
      isSemantics(isToggled: true, hasToggledState: true),
    );
    expect(
      tester.getSemantics(_card(OyenCostume.none)),
      isSemantics(isToggled: false, hasToggledState: true),
    );
  });

  testWidgets('pratinjau mengisi sisa tempat tanpa gulir atau celah', (
    tester,
  ) async {
    for (final (size, scale) in [
      (const Size(360, 640), 1.0),
      (const Size(360, 740), 1.0),
      (const Size(390, 720), 1.0),
      (const Size(390, 780), 1.3),
      (const Size(412, 915), 1.0),
    ]) {
      setScreenSize(tester, size);
      setTextScale(tester, scale);
      await pumpApp(tester, location: AppRoutes.closet);
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(ClosetScreen),
          matching: find.byType(Scrollable),
        ),
      );
      final art = ClosetArt.viewBox.height;
      final preview = tester.getSize(find.byType(ClosetPreview)).height;
      final position = scroll.position;
      if (preview > art * 0.999) continue;
      if (position.maxScrollExtent > 0) {
        // Layar pendek: pratinjau berhenti di skala terkecil.
        expect(preview, closeTo(art * 0.5, 2), reason: '$size $scale');
      } else {
        // Isi pas setinggi tempatnya: tidak ada celah di bawah grid.
        final content = tester
            .renderObject<RenderBox>(
              find
                  .descendant(
                    of: find.byType(SingleChildScrollView),
                    matching: find.byType(Column),
                  )
                  .first,
            )
            .size
            .height;
        expect(
          content,
          closeTo(position.viewportDimension, 0.5),
          reason: '$size $scale',
        );
      }
    }
  });
}
