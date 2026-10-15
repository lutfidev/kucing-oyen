import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aktif hanya dengan `--dart-define=SCREENSHOTS=true`.
const bool screenshotsEnabled = bool.fromEnvironment('SCREENSHOTS');

/// Folder output (default `build/screenshots`).
const String screenshotDir = String.fromEnvironment(
  'SCREENSHOT_DIR',
  defaultValue: 'build/screenshots',
);

final _boundaryKey = GlobalKey();

/// Membungkus [child] supaya bisa dipotret.
Widget capturable(Widget child) =>
    RepaintBoundary(key: _boundaryKey, child: child);

/// Menyimpan tampilan [capturable] sebagai `<screenshotDir>/<name>.png`
/// dengan skala piksel 2.
Future<void> capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$screenshotDir/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

/// Menjalankan [body] dengan bayangan blur menyala. `flutter_test` mematikan
/// blur bayangan supaya stabil, dan nilainya harus kembali sebelum test
/// selesai.
Future<void> withShadows(Future<void> Function() body) async {
  final before = debugDisableShadows;
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = before;
  }
}
