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
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/run_clock.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'capture.dart';

/// Progres seperti contoh desain: Babak 1 selesai dengan 26 bintang, level
/// 11 dan 12 menang (5 bintang), level 13 sedang dimainkan (total 31/60).
final _designProgress = {...wonUpTo(8), 9: 1, 10: 1, 11: 3, 12: 2};

/// Rute dan progresnya.
final _screens = <String, (String, Map<int, int>)>{
  '01-beranda': (AppRoutes.home, _designProgress),
  '01-beranda-baru-360x640': (AppRoutes.home, const {}),
  '02-peta-babak-2': (AppRoutes.chapter(2), _designProgress),
  '02-peta-babak-2-360x640': (AppRoutes.chapter(2), _designProgress),
  '02-peta-babak-2-bos': (AppRoutes.chapter(2), wonUpTo(19, stars: 2)),
  '02-peta-babak-2-selesai': (AppRoutes.chapter(2), wonUpTo(20)),
  '02-peta-babak-1-baru': (AppRoutes.chapter(1), const {}),
  '02-peta-babak-1-level-4': (AppRoutes.chapter(1), {1: 3, 2: 2, 3: 1}),
  '02-peta-babak-1-bos-360x640': (AppRoutes.chapter(1), wonUpTo(9)),
  '03-fase-atur-level-13': (AppRoutes.level(13, chapter: 2), const {}),
  '03-fase-atur-level-1': (AppRoutes.level(1, chapter: 1), const {}),
  '03-fase-atur-level-19': (AppRoutes.level(19, chapter: 2), const {}),
  '03-fase-atur-level-19-360x640': (AppRoutes.level(19, chapter: 2), const {}),
  'galeri': (AppRoutes.gallery, const {}),
  'galeri-papan': (AppRoutes.galleryBoard, const {}),
  'galeri-oyen': (AppRoutes.galleryOyen, const {}),
};

/// Aplikasi lengkap di [location] dengan progres [best], siap dipotret.
/// Semua tutorial sudah selesai kecuali [tutorialsDone] diberikan. Saldo
/// 120 koin seperti contoh desain, kecuali progres kosong.
Widget _app(
  String location, [
  Map<int, int> best = const {},
  Set<int>? tutorialsDone,
]) => capturable(
  KucingOrenApp(
    progress: testProgressWith(
      best: best,
      tutorialsDone: tutorialsDone,
      coins: best.isEmpty ? 0 : 120,
    ),
    initialLocation: location,
  ),
);

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

  for (final MapEntry(key: name, value: (location, best)) in _screens.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(
        tester,
        name.endsWith('-360x640') ? const Size(360, 640) : _size,
      );
      await withShadows(() async {
        await tester.pumpWidget(_app(location, best));
        // Node level saat ini di peta berdenyut terus.
        await settle(tester);
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  for (final MapEntry(key: name, value: (location, height))
      in _fullPages.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, Size(_size.width, height));
      await withShadows(() async {
        await tester.pumpWidget(_app(location));
        await tester.pumpAndSettle();
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  testWidgets('$folder/03-fase-atur-seret-ember', (tester) async {
    setScreenSize(tester, _size);
    await withShadows(() async {
      await tester.pumpWidget(_app(AppRoutes.level(13, chapter: 2)));
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
          _app(AppRoutes.level(id, chapter: testLevels[id - 1].chapter)),
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
          _app(AppRoutes.level(id, chapter: testLevels[id - 1].chapter)),
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

  /// Putar ulang: level, benda, berapa kali "Maju satu langkah" ditekan, dan
  /// ukuran layar. Dibuka dari "Tonton putar ulang" (Berhasil) atau "Putar
  /// Ulang" (Oyen bosan).
  const replays = <String, (int, List<(String, int, int)>, int, Size)>{
    '09-putar-ulang-langkah-4': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      4,
      _size,
    ),
    '09-putar-ulang-awal-360x640': (
      13,
      [('Ember air', 3, 3), ('Ikan asin', 2, 4)],
      0,
      Size(360, 640),
    ),
    '09-putar-ulang-kardus-level-15': (15, [('Ikan asin', 2, 3)], 8, _size),
    '09-putar-ulang-bosan-level-20': (20, [], 40, _size),
  };
  for (final MapEntry(key: name, value: (id, items, steps, size))
      in replays.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          _app(AppRoutes.level(id, chapter: testLevels[id - 1].chapter)),
        );
        await tester.pumpAndSettle();
        await _place(tester, items);
        await _showResult(tester);
        final open = find.text('Tonton putar ulang');
        await tester.tap(
          open.evaluate().isEmpty ? find.text('Putar Ulang') : open,
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < steps; i++) {
          await tester.tap(find.bySemanticsLabel('Maju satu langkah'));
          await tester.pumpAndSettle();
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Sheet Aturan (desain 05): level 13 dengan kardus terkunci seperti
  // desain, dan semua kartu terbuka di layar kecil.
  const rules = <String, (int, Size)>{
    '05-kartu-aturan': (13, _size),
    '05-kartu-aturan-semua-360x640': (20, Size(360, 640)),
  };
  for (final MapEntry(key: name, value: (id, size)) in rules.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          _app(AppRoutes.level(id, chapter: 2), wonUpTo(id - 1)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Aturan'));
        // Kucing kartu 4 berputar terus; potret saat masih diam.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Tutorial level 1 (desain 11), 3, dan 6.
  const tutorials = <String, (int, Size)>{
    '11-tutorial-level-1': (1, _size),
    '11-tutorial-level-1-360x640': (1, Size(360, 640)),
    '11-tutorial-level-3': (3, _size),
    '11-tutorial-level-6': (6, _size),
  };
  for (final MapEntry(key: name, value: (id, size)) in tutorials.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          _app(AppRoutes.level(id, chapter: 1), wonUpTo(id - 1), {}),
        );
        // Cincin dan tangan bergerak terus.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Sheet Petunjuk (desain 10): 120 koin, tingkat 1 terbuka seperti desain,
  // semua tertutup, koin kurang, level tanpa benda, dan papan dengan
  // tingkat 3 sesudah sheet ditutup.
  const hints = <String, (int, int, Map<int, int>, bool, Size)>{
    '10-petunjuk': (13, 120, {13: 1}, true, _size),
    '10-petunjuk-awal': (13, 120, {}, true, _size),
    '10-petunjuk-koin-kurang-360x640': (13, 10, {13: 1}, true, Size(360, 640)),
    '10-petunjuk-level-1': (1, 120, {}, true, _size),
    '10-petunjuk-papan': (13, 0, {13: 3}, false, _size),
  };
  for (final MapEntry(key: name, value: (id, coins, opened, sheet, size))
      in hints.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(
            KucingOrenApp(
              progress: testProgressWith(
                best: wonUpTo(id - 1),
                coins: coins,
                hints: opened,
              ),
              initialLocation: AppRoutes.level(id, chapter: id <= 10 ? 1 : 2),
            ),
          ),
        );
        // Petak petunjuk berkedip terus: tanpa pumpAndSettle.
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        if (sheet) {
          await tester.tap(find.bySemanticsLabel('Petunjuk'));
          for (var i = 0; i < 10; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Lemari Kostum seperti contoh desain 12: 120 koin, Kacamata dimiliki dan
  // dipakai, Peci dipilih.
  for (final small in [false, true]) {
    final name = '12-lemari-kostum${small ? '-360x640' : ''}';
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, small ? const Size(360, 640) : _size);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(
            KucingOrenApp(
              progress: testProgressWith(
                coins: 120,
                wardrobe: Wardrobe(
                  owned: {OyenCostume.kacamata},
                  wearing: OyenCostume.kacamata,
                ),
              ),
              initialLocation: AppRoutes.closet,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('costume-peci')));
        await tester.pumpAndSettle();
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Sheet Tambah Koin dari Beranda bersaldo 120: siap semua, bonus diambil
  // dan jatah iklan habis, dan iklan gagal di layar kecil.
  final now = DateTime(2026, 10, 19, 9);
  final today = dayNumber(now);
  final coinSheets = <String, (DailyRewards, bool, Size)>{
    '14-tambah-koin': (DailyRewards.initial, false, _size),
    '14-tambah-koin-habis': (
      DailyRewards(bonusDay: today, adDay: today, adsWatched: maxAdsPerDay),
      false,
      _size,
    ),
    '14-tambah-koin-gagal-360x640': (
      DailyRewards(bonusDay: today, adDay: today, adsWatched: 2),
      true,
      Size(360, 640),
    ),
  };
  for (final MapEntry(key: name, value: (rewards, fail, size))
      in coinSheets.entries) {
    testWidgets('$folder/$name', (tester) async {
      setScreenSize(tester, size);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(
            KucingOrenApp(
              progress: testProgressWith(
                coins: 120,
                rewards: rewards,
                clock: () => now,
                ads: FakeRewardedAds(succeed: !fail),
              ),
              initialLocation: AppRoutes.home,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(KoCoinChip));
        await tester.pumpAndSettle();
        if (fail) {
          await tester.tap(find.text('+20 koin'));
          await tester.pumpAndSettle();
        }
        await capture(tester, '$folder/$name');
      });
    }, skip: !screenshotsEnabled);
  }

  // Oyen berpeci di fase jalan level 13, langkah ke-2.
  testWidgets('$folder/04-fase-jalan-kostum-peci', (tester) async {
    setScreenSize(tester, _size);
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(
          KucingOrenApp(
            progress: testProgressWith(
              wardrobe: Wardrobe(
                owned: {OyenCostume.peci},
                wearing: OyenCostume.peci,
              ),
            ),
            initialLocation: AppRoutes.level(13, chapter: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bangunkan Oyen'));
      await tester.pump();
      for (var i = 0; i < 2; i++) {
        await tester.pump(RunClock.stepTime);
      }
      await tester.tap(find.bySemanticsLabel(RegExp('Jeda')));
      await tester.pumpAndSettle();
      await capture(tester, '$folder/04-fase-jalan-kostum-peci');
    });
  }, skip: !screenshotsEnabled);
}
