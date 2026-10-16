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
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/theme/theme.dart';
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

/// Menaruh benda (awalan nama slot baki, kolom, baris) lewat seretan.
Future<void> _place(WidgetTester tester, List<(String, int, int)> items) async {
  final board = tester.getRect(find.byType(GameWidget<KucingGame>));
  final scale = board.width / 350;
  for (final (slotName, col, row) in items) {
    final slot = find.byWidgetPredicate(
      (w) => w is TraySlot && w.semanticLabel.startsWith(slotName),
    );
    final target = board.topLeft + Offset(col * 50 + 25, row * 50 + 25) * scale;
    final gesture = await tester.startGesture(tester.getCenter(slot));
    await tester.pump();
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }
}

/// Membangunkan Oyen, memutar sampai selesai, lalu membuka layar hasil dan
/// menunggu bintang dan Ibu selesai muncul. Sinar dan "PRANG!" bergerak
/// terus, jadi tanpa `pumpAndSettle`.
Future<void> _showResult(WidgetTester tester) async {
  await tester.tap(find.text('Bangunkan Oyen'));
  await tester.pump();
  await tester.pumpAndSettle();
  await tester.tap(find.text('Lihat hasil'));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

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

  /// Layar hasil: level, benda, dan ukuran layar.
  const results = <String, (int, List<(String, int, int)>, Size)>{
    '06-berhasil-level-13': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      _size,
    ),
    '06-berhasil-2-bintang-level-15': (
      15,
      [('Ikan asin', 2, 3), ('Ember air', 1, 1)],
      _size,
    ),
    '06-berhasil-level-1-360x640': (1, [], Size(360, 640)),
    '07-vas-pecah-level-13': (13, [('Ikan asin', 2, 4)], _size),
    '07-vas-pecah-level-13-360x640': (
      13,
      [('Ikan asin', 2, 4)],
      Size(360, 640),
    ),
    '08-oyen-bosan-level-13': (13, [], _size),
    '08-oyen-bosan-level-13-360x640': (13, [], Size(360, 640)),
  };
  for (final MapEntry(key: name, value: (id, items, size)) in results.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(KucingOrenApp(initialLocation: AppRoutes.level(id))),
        );
        await tester.pumpAndSettle();
        await _place(tester, items);
        await _showResult(tester);
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  testWidgets('$folder/08-oyen-kelamaan', (tester) async {
    setScreenSize(tester, _size);
    // Tidak ada level yang bisa lewat 80 langkah; peta ini dibuat untuk
    // contoh layar kelamaan.
    final level = Level(
      id: 21,
      name: 'Lorong Panjang',
      chapter: 3,
      map: const [
        '#######',
        '#^..#.#',
        '#.....#',
        '#T...##',
        '#.#..##',
        '###.FA#',
        '##.F..#',
        '#.A#.F#',
        '#######',
      ],
      inventory: const {},
      starItems: 0,
      solution: const [],
      solutionSteps: 0,
    );
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: KoTheme.light(),
            home: LevelView(
              level: level,
              backLabel: 'Kembali',
              onBack: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _showResult(tester);
      await capture(tester, '$folder/08-oyen-kelamaan');
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
