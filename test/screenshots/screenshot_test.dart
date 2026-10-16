// Potret layar ke PNG untuk dibandingkan dengan desain:
//
//   flutter test test/screenshots --dart-define=SCREENSHOTS=true
//
// Hasil di build/screenshots/<lebar>x<tinggi>/. Font asli dimuat oleh
// test/flutter_test_config.dart. Tanpa define di atas, test ini dilewati
// (tidak ikut `flutter test` biasa).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/routes.dart';

import '../test_helpers.dart';
import 'capture.dart';

const _screens = <String, String>{
  '00-beranda-sementara': AppRoutes.home,
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
      setScreenSize(tester, _size);
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
}
