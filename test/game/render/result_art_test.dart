import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/design_svg.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/svg_template.dart';

/// Gambar [draw] di kanvas [size] berlatar putih, lalu kembalikan pembaca
/// warna piksel.
Future<Color Function(double x, double y)> _paint(
  Size size,
  void Function(Canvas canvas) draw,
) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));
  draw(canvas);
  final image = await recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i = (y.floor() * image.width + x.floor()) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

Matcher _near(Color expected, {int tolerance = 2}) => predicate<Color>((c) {
  int ch(double v) => (v * 255).round();
  return (ch(c.r) - ch(expected.r)).abs() <= tolerance &&
      (ch(c.g) - ch(expected.g)).abs() <= tolerance &&
      (ch(c.b) - ch(expected.b)).abs() <= tolerance;
}, 'mendekati $expected');

const _white = Color(0xFFFFFFFF);

void main() {
  group('sinar layar Berhasil', () {
    // #FCE3BC dengan opasitas 0,55 di atas putih.
    const ray = Color(0xFFFDF0DA);
    const size = Size(700, 700);

    test('dua belas sinar dari tengah, opasitas 0,55', () async {
      final at = await _paint(size, (canvas) {
        canvas.translate(350, 350);
        paintRays(canvas);
      });
      // Sinar pertama lurus ke atas, berikutnya tiap 30°.
      expect(at(350, 150), _near(ray));
      expect(at(350, 550), _near(ray));
      expect(at(550, 350), _near(ray));
      // Di antara dua sinar (15°).
      expect(at(350 + 54, 150), _near(_white));
    });
  });

  group('ilustrasi vas pecah', () {
    const size = Size(358, 300);

    test('dinding, pintu, dan Ibu di tempatnya', () async {
      final at = await _paint(size, paintVaseScene);
      expect(at(10, 10), _near(const Color(0xFFE9C9A0)));
      expect(at(10, 62), _near(const Color(0xFFB07A4F)));
      // Badan Ibu (x 274..332) di depan pintu gelap.
      expect(at(290, 150), _near(const Color(0xFF4F8A8B)));
      expect(at(262, 30), _near(const Color(0xFF4A2F1C)));
    });

    test('Ibu digeser masuk dari kanan', () async {
      final at = await _paint(
        size,
        (canvas) => paintVaseScene(canvas, momShift: ResultArt.momPeek),
      );
      expect(at(290, 150), _near(const Color(0xFF4A2F1C)));
      expect(at(320, 150), _near(const Color(0xFF4F8A8B)));
    });

    test('PRANG! berputar di tengah kotak gambarnya', () {
      final prang = SvgTemplate(vasePrangSvg).render(const {});
      expect(prang.bounds, const Rect.fromLTRB(-28, -26, 30, 28));
    });
  });

  test('mangkuk kedua layar tergambar di viewBox 140×54', () async {
    for (final paint in [paintSuccessBowl, paintVaseBowl]) {
      final at = await _paint(ResultArt.bowlViewBox, paint);
      // Badan mangkuk dan isi pakan biru muda.
      expect(at(70, 44), _near(const Color(0xFF3E9BCB)));
      expect(at(40, 13), _near(const Color(0xFFBFE7F7)));
    }
  });
}
