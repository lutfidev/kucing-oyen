import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/gallery/gallery_board_screen.dart';
import 'package:kucing_oren/gallery/gallery_oyen_screen.dart';
import 'package:kucing_oren/gallery/gallery_screen.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Beranda → galeri → kembali ke Beranda', (tester) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Kucing Oren'), findsOneWidget);

    await tester.tap(find.text('Galeri komponen'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Token & komponen'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is KoIconButton && w.semanticLabel == 'Kembali ke Beranda',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Beranda → Level 13 → kembali ke Beranda', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Level 13'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelView), findsOneWidget);
    expect(find.text('Level 13 · Vas Ibu'), findsOneWidget);

    await tester.tap(_back('Kembali ke Beranda'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Beranda sementara punya jalan ke level 1–20', (tester) async {
    setScreenSize(tester, const Size(390, 2000));
    await pumpApp(tester);
    for (var id = 1; id <= 20; id++) {
      expect(find.bySemanticsLabel('Level $id'), findsOneWidget);
    }
  });

  for (final location in ['/level/99', '/level/abc']) {
    testWidgets('$location: level tidak ada, bisa kembali', (tester) async {
      await pumpApp(tester, location: location);
      expect(find.text('Level ini nggak ada.'), findsOneWidget);
      await tester.tap(_back('Kembali ke Beranda'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }

  testWidgets('galeri menampilkan semua komponen dasar', (tester) async {
    // Layar tinggi supaya semua bagian galeri dibangun ListView.
    setScreenSize(tester, const Size(390, 5000));
    await pumpApp(tester, location: '/galeri');
    for (final type in [
      KoButton,
      KoIconButton,
      KoChip,
      TraySlot,
      KoStars,
      KoCard,
    ]) {
      expect(find.byType(type), findsWidgets);
    }
  });

  testWidgets('galeri → Elemen papan / Oyen → kembali ke galeri', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.gallery);
    await tester.tap(find.text('Elemen papan'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryBoardScreen), findsOneWidget);

    await tester.tap(_back('Kembali ke galeri'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryScreen), findsOneWidget);

    await tester.tap(find.text('Oyen'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryOyenScreen), findsOneWidget);

    await tester.tap(_back('Kembali ke galeri'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryScreen), findsOneWidget);
  });

  testWidgets('galeri papan menggambar 18 petak dan 3 papan', (tester) async {
    setScreenSize(tester, const Size(390, 5000));
    await pumpApp(tester, location: AppRoutes.galleryBoard);
    expect(find.byType(TileView), findsNWidgets(18));
    expect(find.byType(BoardView), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('galeri Oyen menggambar arah, pose, dan kostum', (tester) async {
    setScreenSize(tester, const Size(390, 5000));
    await pumpApp(tester, location: AppRoutes.galleryOyen);
    expect(find.byType(OyenView), findsNWidgets(4 + 7 + 4));
    for (final label in [
      'Oyen jalan, menghadap kanan',
      'Oyen kaget, menghadap bawah',
      'Oyen duduk dalam kardus, menghadap bawah',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    expect(tester.takeException(), isNull);
  });
}

Finder _back(String label) => find.byWidgetPredicate(
  (w) => w is KoIconButton && w.semanticLabel == label,
);
