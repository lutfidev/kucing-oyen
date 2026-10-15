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

  // Galeri utuh dalam satu gambar panjang.
  testWidgets('$folder/galeri-penuh', (tester) async {
    setScreenSize(tester, Size(_size.width, 4800));
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(const KucingOrenApp(initialLocation: AppRoutes.gallery)),
      );
      await tester.pumpAndSettle();
      await capture(tester, '$folder/galeri-penuh');
    });
  }, skip: !screenshotsEnabled);
}
