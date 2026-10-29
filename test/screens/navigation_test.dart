import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/gallery/gallery_board_screen.dart';
import 'package:kucing_oren/gallery/gallery_oyen_screen.dart';
import 'package:kucing_oren/gallery/gallery_screen.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/room/room_screen.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart' show pumpFor;

void main() {
  testWidgets('Beranda → Main → peta → level 1 → kembali ke peta → Beranda', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(RoomScreen), findsOneWidget);

    await tester.tap(find.text('Main'));
    await settle(tester);
    expect(find.byType(ChapterView), findsOneWidget);
    expect(find.text('Dapur'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Level 1, main sekarang'));
    await settle(tester);
    expect(find.byType(LevelView), findsOneWidget);
    expect(find.text('Level 1 · Bangunkan Oyen'), findsOneWidget);

    await tester.tap(_back('Kembali ke peta'));
    await settle(tester);
    expect(find.byType(ChapterView), findsOneWidget);
    expect(find.byType(LevelView), findsNothing);

    await tester.tap(_back('Kembali ke Beranda'));
    await settle(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(find.byType(ChapterView), findsNothing);
  });

  testWidgets('Beranda → Toko → kembali ke Beranda', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Toko'));
    await settle(tester);
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.byType(RoomScreen), findsNothing);

    await tester.tap(_back('Kembali ke Beranda'));
    await settle(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(find.byType(ShopScreen), findsNothing);
  });

  testWidgets('rute Toko bisa dibuka langsung di tab Aksesoris', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, location: AppRoutes.shop(tab: ShopTab.accessories));
    await settle(tester);
    expect(find.byType(ShopScreen), findsOneWidget);
    // Tab terpilih memakai keadaan toggled KoPressable, seperti kartu
    // kostum.
    expect(
      tester.getSemantics(find.text('Aksesoris')),
      isSemantics(isToggled: true, hasToggledState: true),
    );
    expect(
      tester.getSemantics(find.text('Barang')),
      isSemantics(isToggled: false, hasToggledState: true),
    );
    semantics.dispose();
  });

  testWidgets('tombol kembali sistem di Toko kembali ke Beranda', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.shop());
    expect(find.byType(ShopScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
  });

  testWidgets('tombol kembali sistem: level → peta → Beranda', (tester) async {
    await pumpApp(tester, location: AppRoutes.level(13, chapter: 2));
    expect(find.byType(LevelView), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(ChapterView), findsOneWidget);
    expect(find.text('Ruang Tamu'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
  });

  group('tombol kembali sistem di level', () {
    Future<void> openLevel(WidgetTester tester) async {
      await pumpApp(tester, location: AppRoutes.level(1, chapter: 1));
      await tester.tap(find.text('Bangunkan Oyen'));
      await tester.pump();
    }

    testWidgets('fase jalan → fase atur, lalu ke peta', (tester) async {
      await openLevel(tester);
      expect(find.text('Bangunkan Oyen'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LevelView), findsOneWidget);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.byType(LevelView), findsNothing);
      expect(find.byType(ChapterView), findsOneWidget);
    });

    testWidgets('layar hasil → fase atur', (tester) async {
      await openLevel(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await pumpFor(tester, const Duration(milliseconds: 1500));
      expect(find.byType(SuccessResult), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SuccessResult), findsNothing);
      expect(find.byType(LevelView), findsOneWidget);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
    });
  });

  testWidgets('Main membuka babak level yang dimainkan berikutnya', (
    tester,
  ) async {
    await pumpApp(tester, progress: testProgress(wonUpTo(10)));
    await tester.tap(find.text('Main'));
    await settle(tester);
    expect(find.text('Ruang Tamu'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 11, main sekarang'), findsOneWidget);
  });

  testWidgets('kartu babak membuka babak lain kalau terbuka', (tester) async {
    await pumpApp(
      tester,
      location: AppRoutes.chapter(2),
      progress: testProgress(wonUpTo(10)),
    );
    await tester.tap(find.text('Babak 1 – Dapur'));
    await settle(tester);
    expect(find.text('Dapur'), findsOneWidget);

    await tester.tap(find.text('Babak 2 – Ruang Tamu'));
    await settle(tester);
    expect(find.text('Ruang Tamu'), findsOneWidget);
  });

  testWidgets('babak terkunci dan level terkunci tidak bisa dibuka', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.chapter(1));
    await tester.tap(find.text('Babak 2 – Ruang Tamu'));
    await settle(tester);
    expect(find.text('Dapur'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Level 2, terkunci'));
    await tester.tap(
      find.bySemanticsLabel('Level 10, bos Pesta Ikan Asin, terkunci'),
    );
    await settle(tester);
    expect(find.byType(LevelView), findsNothing);
  });

  testWidgets('level yang sudah selesai bisa dimainkan lagi', (tester) async {
    await pumpApp(
      tester,
      location: AppRoutes.chapter(1),
      progress: testProgress({1: 2}),
    );
    await tester.tap(find.bySemanticsLabel('Level 1, 2 bintang'));
    await settle(tester);
    expect(find.text('Level 1 · Bangunkan Oyen'), findsOneWidget);
  });

  group('rute yang tidak ada', () {
    for (final (location, back, target) in [
      ('/babak/2/level/99', 'Kembali ke peta', ChapterView),
      ('/babak/abc/level/abc', 'Kembali ke Beranda', RoomScreen),
    ]) {
      testWidgets('$location: level tidak ada, bisa kembali', (tester) async {
        await pumpApp(tester, location: location);
        expect(find.text('Level ini nggak ada.'), findsOneWidget);
        await tester.tap(_back(back));
        await settle(tester);
        expect(find.byType(target), findsOneWidget);
      });
    }

    testWidgets('/babak/9: babak tidak ada, bisa kembali', (tester) async {
      await pumpApp(tester, location: '/babak/9');
      expect(find.text('Babak ini nggak ada.'), findsOneWidget);
      await tester.tap(_back('Kembali ke Beranda'));
      await settle(tester);
      expect(find.byType(RoomScreen), findsOneWidget);
    });

    testWidgets('level di path babak lain kembali ke babaknya sendiri', (
      tester,
    ) async {
      await pumpApp(tester, location: '/babak/1/level/13');
      expect(find.text('Level 13 · Vas Ibu'), findsOneWidget);
      await tester.tap(_back('Kembali ke peta'));
      await settle(tester);
      expect(find.text('Ruang Tamu'), findsOneWidget);
    });
  });

  testWidgets('galeri (tanpa tombol di Beranda) → kembali ke Beranda', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.gallery);
    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Token & komponen'), findsOneWidget);

    await tester.tap(_back('Kembali ke Beranda'));
    await settle(tester);
    expect(find.byType(RoomScreen), findsOneWidget);
  });

  testWidgets('galeri menampilkan semua komponen dasar', (tester) async {
    // Layar tinggi supaya semua bagian galeri dibangun ListView.
    setScreenSize(tester, const Size(390, 5000));
    await pumpApp(tester, location: AppRoutes.gallery);
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
