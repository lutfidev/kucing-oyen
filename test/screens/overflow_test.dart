import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';

import '../test_helpers.dart';

/// Semua rute harus bebas overflow dari layar kecil sampai besar, juga
/// dengan teks sistem 130%. Overflow RenderFlex dilaporkan sebagai exception
/// sehingga test gagal. Rute baru di langkah roadmap berikutnya ditambahkan
/// ke daftar ini.
final routes = <String>[
  AppRoutes.home,
  AppRoutes.gallery,
  AppRoutes.galleryBoard,
  AppRoutes.galleryOyen,
  // Tanpa benda, dua jenis benda, dan tiga jenis benda (baki terlebar).
  AppRoutes.level(1),
  AppRoutes.level(13),
  AppRoutes.level(19),
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

  // Fase jalan sampai hasil sementara, tanpa benda: level 1 (tanpa chip
  // status), level 12 (gelas jatuh), level 13 (vas pecah, mondar-mandir).
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final id in const [1, 12, 13]) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: fase jalan level $id @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await pumpApp(tester, location: AppRoutes.level(id));
            await tester.tap(find.text('Bangunkan Oyen'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Lihat hasil'));
            await tester.pumpAndSettle();
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
