import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/theme/theme.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

/// Semua rute harus bebas overflow dari layar kecil sampai besar, juga
/// dengan teks sistem 130%. Overflow RenderFlex dilaporkan sebagai exception
/// sehingga test gagal. Rute baru di langkah roadmap berikutnya ditambahkan
/// ke daftar ini.
final routes = <String>[
  AppRoutes.home,
  AppRoutes.chapter(1),
  AppRoutes.chapter(2),
  AppRoutes.gallery,
  AppRoutes.galleryBoard,
  AppRoutes.galleryOyen,
  // Tanpa benda, dua jenis benda, dan tiga jenis benda (baki terlebar).
  AppRoutes.level(1, chapter: 1),
  AppRoutes.level(13, chapter: 2),
  AppRoutes.level(19, chapter: 2),
];

const sizes = <Size>[
  Size(360, 640),
  Size(360, 740),
  Size(390, 844),
  Size(412, 915),
];

const textScales = <double>[1.0, 1.3];

void main() {
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final route in routes) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets('tanpa overflow: $route @ $label, teks ${scale * 100}%', (
          tester,
        ) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(tester, location: route);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // Fase jalan sampai layar hasil, tanpa benda: level 1 (tanpa chip
  // status, Berhasil), level 12 (gelas jatuh), level 13 (vas pecah,
  // mondar-mandir).
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final id in const [1, 12, 13]) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: fase jalan level $id @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await pumpApp(
              tester,
              location: AppRoutes.level(id, chapter: levels[id - 1].chapter),
            );
            await tester.tap(find.text('Bangunkan Oyen'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Lihat hasil'));
            // Sinar layar Berhasil berputar terus: tanpa pumpAndSettle.
            await pumpFor(tester, const Duration(milliseconds: 1500));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Layar hasil langsung dari sesi: Berhasil 3 dan 2 bintang, vas pecah,
  // mondar-mandir, dan kelamaan.
  final results = <String, LevelSession Function()>{
    'Berhasil level 13': () => resultOf(levels[12], levels[12].solution),
    'Berhasil 2 bintang level 15': () => resultOf(levels[14], twoStars),
    'vas pecah level 13': () => resultOf(levels[12], fishOnly),
    'Oyen bosan level 20': () => resultOf(levels[19]),
    'kelamaan': () => resultOf(longWalk),
  };
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: session) in results.entries) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: hasil $name @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await tester.pumpWidget(
              MaterialApp(
                theme: KoTheme.light(),
                home: Scaffold(
                  body: ResultView(
                    session: session(),
                    onArrange: () {},
                    onRestart: () {},
                    onNext: () {},
                  ),
                ),
              ),
            );
            await pumpFor(tester, const Duration(milliseconds: 1500));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Putar ulang langsung dari sesi: 6 langkah, Oyen bosan (40 langkah,
  // judul level terpanjang), dan kelamaan (80 langkah), di langkah 0 dan
  // terakhir.
  final replays = <String, LevelSession Function()>{
    'level 13': () => resultOf(levels[12], levels[12].solution),
    'Oyen bosan level 20': () => resultOf(levels[19]),
    'kelamaan': () => resultOf(longWalk),
  };
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: session) in replays.entries) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: putar ulang $name @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await tester.pumpWidget(
              MaterialApp(
                theme: KoTheme.light(),
                home: Scaffold(
                  body: ReplayView(
                    session: session(),
                    onBack: () {},
                    onMap: () {},
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            // Langkah terakhir: ketuk ujung kanan slider.
            final track = tester.getRect(
              find.descendant(
                of: find.byType(ReplaySlider),
                matching: find.byType(CustomPaint),
              ),
            );
            await tester.tapAt(track.centerRight - const Offset(1, 0));
            await tester.pumpAndSettle();
            expect(find.byType(ReplayCaption), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('galeri bisa digulir sampai bawah di 360×640, teks 130%', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 640));
    setTextScale(tester, 1.3);
    await pumpApp(tester, location: AppRoutes.gallery);
    await tester.scrollUntilVisible(
      find.text('Kartu dengan bayangan lembut.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final (route, last) in [
    (AppRoutes.galleryBoard, find.text('Vas pecah')),
    (AppRoutes.galleryOyen, find.text('Kacamata')),
  ]) {
    testWidgets('$route bisa digulir sampai bawah di 360×640, teks 130%', (
      tester,
    ) async {
      setScreenSize(tester, const Size(360, 640));
      setTextScale(tester, 1.3);
      await pumpApp(tester, location: route);
      await tester.scrollUntilVisible(
        last,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
