import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/theme/theme.dart';

/// Ukuran layar logis (dpr 1), dipulihkan setelah test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Skala teks sistem (mis. 1.3 = 130%), dipulihkan setelah test.
void setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Pompa aplikasi lengkap di [location].
Future<void> pumpApp(WidgetTester tester, {String location = '/'}) async {
  await tester.pumpWidget(KucingOrenApp(initialLocation: location));
  await tester.pumpAndSettle();
}

/// Dekorasi [Container] pertama di dalam [of] (permukaan tombol, chip, slot).
BoxDecoration decorationOf(WidgetTester tester, Finder of) {
  final box = tester.widget<Container>(
    find.descendant(of: of, matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

/// Pompa satu widget dengan tema Kucing Oren.
Future<void> pumpThemed(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: KoTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
