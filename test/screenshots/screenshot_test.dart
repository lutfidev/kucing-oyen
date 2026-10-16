// Potret layar ke PNG untuk dibandingkan dengan desain:
//
//   flutter test test/screenshots --dart-define=SCREENSHOTS=true
//
// Hasil di build/screenshots/<lebar>x<tinggi>/. Font asli dimuat oleh
// test/flutter_test_config.dart. Tanpa define di atas, test ini dilewati
// (tidak ikut `flutter test` biasa).
import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'capture.dart';

const _screens = <String, String>{
  '00-beranda-sementara': AppRoutes.home,
  '03-fase-atur-level-13': '/level/13',
  '03-fase-atur-level-1': '/level/1',
  '03-fase-atur-level-19': '/level/19',
  '03-fase-atur-level-19-360x640': '/level/19',
  'galeri': AppRoutes.gallery,
  'galeri-papan': AppRoutes.galleryBoard,
  'galeri-oyen': AppRoutes.galleryOyen,
};

/// Halaman galeri utuh dalam satu gambar panjang: rute dan tinggi layarnya.
const _fullPages = <String, (String, double)>{
  'galeri-penuh': (AppRoutes.gallery, 4800),
  'galeri-papan-penuh': (AppRoutes.galleryBoard, 3150),
  'galeri-oyen-penuh': (AppRoutes.galleryOyen, 1900),
};

const _size = Size(390, 844);

void main() {
  final folder = '${_size.width.toInt()}x${_size.height.toInt()}';

  for (final MapEntry(key: name, value: location) in _screens.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(
        tester,
        name.endsWith('-360x640') ? const Size(360, 640) : _size,
      );
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(KucingOrenApp(initialLocation: location)),
        );
        await tester.pumpAndSettle();
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  for (final MapEntry(key: name, value: (location, height))
      in _fullPages.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, Size(_size.width, height));
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(KucingOrenApp(initialLocation: location)),
        );
        await tester.pumpAndSettle();
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  testWidgets('$folder/03-fase-atur-seret-ember', (tester) async {
    setScreenSize(tester, _size);
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(KucingOrenApp(initialLocation: AppRoutes.level(13))),
      );
      await tester.pumpAndSettle();
      // Ember diseret ke petak (3, 3) seperti layar desain 03.
      final board = tester.getRect(find.byType(GameWidget<KucingGame>));
      final scale = board.width / 350;
      final target = board.topLeft + const Offset(175, 175) * scale;
      final slot = find.byWidgetPredicate(
        (w) => w is TraySlot && w.semanticLabel.startsWith('Ember air'),
      );
      final gesture = await tester.startGesture(tester.getCenter(slot));
      await tester.pump();
      await gesture.moveTo(target);
      // Kedip petak menyala kembali ke opasitas penuh tiap 1 detik.
      await tester.pump(const Duration(seconds: 1));
      await capture(tester, '$folder/03-fase-atur-seret-ember');
      await gesture.up();
      await tester.pumpAndSettle();
    });
  }, skip: !screenshotsEnabled);

  /// Fase jalan: level, benda (awalan nama slot baki, kolom, baris), lalu
  /// berapa kali "Maju satu langkah" ditekan (null = putar sampai selesai),
  /// dan apakah ×2 dinyalakan.
  const runs = <String, (int, List<(String, int, int)>, int?, bool)>{
    '04-fase-jalan-langkah-1': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      0,
      false,
    ),
    '04-fase-jalan-langkah-5-jeda-x2': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      4,
      true,
    ),
    '04-fase-jalan-selesai': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      null,
      false,
    ),
    '04-fase-jalan-vas-pecah': (13, [('Ikan asin', 2, 4)], 1, false),
    '04-fase-jalan-kardus-level-15': (15, [('Ikan asin', 2, 3)], 6, false),
  };
  for (final MapEntry(key: name, value: (id, items, steps, fast))
      in runs.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, _size);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(KucingOrenApp(initialLocation: AppRoutes.level(id))),
        );
        await tester.pumpAndSettle();
        final board = tester.getRect(find.byType(GameWidget<KucingGame>));
        final scale = board.width / 350;
        for (final (slotName, col, row) in items) {
          final slot = find.byWidgetPredicate(
            (w) => w is TraySlot && w.semanticLabel.startsWith(slotName),
          );
          final target =
              board.topLeft + Offset(col * 50 + 25, row * 50 + 25) * scale;
          final gesture = await tester.startGesture(tester.getCenter(slot));
          await tester.pump();
          await gesture.moveTo(target);
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Bangunkan Oyen'));
        await tester.pump();
        if (steps == null) {
          await tester.pumpAndSettle();
        } else {
          for (var i = 0; i < steps; i++) {
            await tester.tap(find.bySemanticsLabel('Maju satu langkah'));
            await tester.pump();
          }
          if (steps == 0) {
            await tester.tap(find.bySemanticsLabel('Jeda'));
            await tester.pump();
          }
          if (fast) {
            await tester.tap(find.bySemanticsLabel('Percepat dua kali'));
            await tester.pump();
          }
          await tester.pump(const Duration(seconds: 1));
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }
}
