import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';

/// Skala gambar uji supaya tepi bentuk tidak ikut tersampel.
const _scale = 4.0;

/// Menggambar [paint] di kotak [width]×[height] lalu mengembalikan warna di
/// titik koordinat gambar.
Future<Color Function(double x, double y)> _render(
  void Function(Canvas canvas) paint, {
  required double width,
  required double height,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(_scale);
  paint(canvas);
  final w = (width * _scale).toInt();
  final h = (height * _scale).toInt();
  final image = await recorder.endRecording().toImage(w, h);
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i = ((y * _scale).floor() * w + (x * _scale).floor()) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

Matcher _near(int argb) => predicate<Color>((c) {
  final want = Color(argb);
  double d(double a, double b) => (a - b).abs();
  return d(c.a, want.a) < 0.04 &&
      d(c.r, want.r) < 0.04 &&
      d(c.g, want.g) < 0.04 &&
      d(c.b, want.b) < 0.04;
}, 'mendekati ${argb.toRadixString(16)}');

final _transparent = predicate<Color>((c) => c.a < 0.02, 'transparan');

void main() {
  // Sumber kepala rumah v2, dengan margin aman di sekitar outline SVG.
  final box = BrandArt.headBox;

  test('kotak kepala', () {
    expect(box, const Rect.fromLTRB(20, 25, 108, 97));
  });

  test('kepala Oyen v2: bulu, moncong, mata, tanpa badan', () async {
    final at = await _render(
      (canvas) => paintOyenHead(canvas, width: box.width),
      width: box.width,
      height: box.height,
    );
    expect(at(44, 30), _near(0xFFFFB24D));
    expect(at(44, 47), _near(0xFFFFF0CC));
    expect(at(28, 42), _near(0xFF573018));
    // Belang dahi.
    expect(at(44, 20), _near(0xFFCE6D24));
    // Di bawah pipi kiri: kosong (badan dan bayangan tidak digambar).
    expect(at(2, 70), _transparent);
  });

  test('kepala diskalakan ke lebar yang diminta', () async {
    final at = await _render(
      (canvas) => paintOyenHead(canvas, width: box.width * 2),
      width: box.width * 2,
      height: box.height * 2,
    );
    expect(at(88, 60), _near(0xFFFFB24D));
    expect(at(56, 84), _near(0xFF573018));
  });

  test('ikon monokrom: siluet dengan mata dan belang berlubang', () async {
    final at = await _render(
      (canvas) => paintOyenHeadMono(
        canvas,
        width: box.width,
        color: const Color(0xFFFFFFFF),
      ),
      width: box.width,
      height: box.height,
    );
    expect(at(44, 30), _near(0xFFFFFFFF));
    expect(at(44, 47), _near(0xFFFFFFFF));
    expect(at(28, 42), _transparent);
    expect(at(44, 20), _transparent);
    expect(at(2, 70), _transparent);
  });
}
