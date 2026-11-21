import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/v2/journey_art.dart';
import 'package:kucing_oren/screens/result/result_parts.dart';
import 'package:kucing_oren/theme/ko_ui.dart';

import '../test_helpers.dart';

Future<ByteData> pixels(
  WidgetTester t,
  void Function(Canvas) paint,
  int w,
  int h,
) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final picture = recorder.endRecording();
  return (await t.runAsync(() async {
    final image = await picture.toImage(w, h);
    final data = await image.toByteData();
    image.dispose();
    return data!;
  }))!;
}

Color at(ByteData d, int w, int x, int y) {
  final i = (y * w + x) * 4;
  return Color.fromARGB(
    d.getUint8(i + 3),
    d.getUint8(i),
    d.getUint8(i + 1),
    d.getUint8(i + 2),
  );
}

void main() {
  testWidgets('sinar memudar ke tepi, tanpa ujung lurus', (t) async {
    const size = 1400;
    final d = await pixels(t, (c) {
      c.translate(size / 2, size / 2);
      JourneyArt.rays(c);
    }, size, size);
    // Sinar pertama mengarah ke atas (0, -r).
    double alpha(double r) => at(d, size, size ~/ 2, (size / 2 - r).round()).a;
    expect(alpha(100), greaterThan(.05));
    // Dulu ujung segitiga berhenti mendadak di 310.
    expect(alpha(330), greaterThan(0));
    expect(alpha(330), lessThan(alpha(100)));
    expect(alpha(JourneyArt.raysRadius - 4), lessThan(.01));
  });

  testWidgets('mangkuk di samping Oyen, tidak menimpa kaki', (t) async {
    const w = 320, h = 220;
    final d = await pixels(
      t,
      (c) => JourneyArt.result(c, const Size(320, 220)),
      w,
      h,
    );
    bool honey(Color c) =>
        ((c.r - KoUi.honey.r).abs() + (c.g - KoUi.honey.g).abs()) < .04;
    expect(honey(at(d, w, w ~/ 2, h - 29)), isFalse);
    expect(honey(at(d, w, w ~/ 2 + JourneyArt.bowlShift.round() + 6, h - 29)),
        isTrue);
  });

  testWidgets('area gulir hasil selebar layar (sinar tidak terpotong)', (
    t,
  ) async {
    setScreenSize(t, const Size(390, 844));
    await t.pumpWidget(
      testApp(
        home: const ResultPage(
          background: KoUi.cream,
          children: [SizedBox(height: 10)],
        ),
      ),
    );
    final scroll = t.getRect(find.byType(SingleChildScrollView));
    expect(scroll.left, 0);
    expect(scroll.width, 390);
  });
}
