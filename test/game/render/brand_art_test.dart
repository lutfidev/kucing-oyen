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
  // Kotak kepala 68×60 di viewBox Oyen; lebar 68 = skala 1, jadi titik
  // gambar = titik desain dikurangi (16, 8).
  final box = BrandArt.headBox;

  test('kotak kepala', () {
    expect(box, const Rect.fromLTRB(16, 8, 84, 68));
  });

  test('kepala Oyen: bulu, moncong, mata ngantuk, tanpa badan', () async {
    final at = await _render(
      (canvas) => paintOyenHead(canvas, width: box.width),
      width: box.width,
      height: box.height,
    );
    expect(at(34, 34), _near(0xFFF5A447));
    expect(at(34, 48), _near(0xFFFDE6C4));
    expect(at(20, 37), _near(0xFF3A2618));
    // Belang dahi.
    expect(at(34, 12), _near(0xFFC4651A));
    // Di bawah pipi kiri: kosong (badan dan bayangan tidak digambar).
    expect(at(2, 58), _transparent);
  });

  test('kepala diskalakan ke lebar yang diminta', () async {
    final at = await _render(
      (canvas) => paintOyenHead(canvas, width: box.width * 2),
      width: box.width * 2,
      height: box.height * 2,
    );
    expect(at(68, 68), _near(0xFFF5A447));
    expect(at(40, 74), _near(0xFF3A2618));
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
    expect(at(34, 34), _near(0xFFFFFFFF));
    expect(at(34, 48), _near(0xFFFFFFFF));
    expect(at(20, 37), _transparent);
    expect(at(34, 12), _transparent);
    expect(at(2, 58), _transparent);
  });
}
