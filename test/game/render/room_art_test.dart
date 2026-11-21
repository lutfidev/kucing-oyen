import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';

/// Warna piksel di koordinat kanvas.
Future<Color Function(double x, double y)> _sampler(
  void Function(Canvas canvas) paint,
  Size size,
) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(
    size.width.ceil(),
    size.height.ceil(),
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

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

Matcher _near(Color expected, {int tolerance = 2}) => predicate<Color>((c) {
  int ch(double v) => (v * 255).round();
  return (ch(c.r) - ch(expected.r)).abs() <= tolerance &&
      (ch(c.g) - ch(expected.g)).abs() <= tolerance &&
      (ch(c.b) - ch(expected.b)).abs() <= tolerance;
}, 'mendekati $expected');

void main() {
  test('tanda lesu lapar dan sedih berbeda', () async {
    final hungry = await _sampler(
      (c) => paintSadMark(c, hungry: true),
      RoomArt.sadMarkViewBox,
    );
    final sad = await _sampler(
      (c) => paintSadMark(c, hungry: false),
      RoomArt.sadMarkViewBox,
    );
    expect(sad(24, 16), _near(_hex('#B9C7DA')));
    expect(hungry(24, 16), _near(_hex('#EEF2F7')));
  });

  test('tanda lesu ikut lebar', () async {
    final at = await _sampler(
      (c) => paintSadMark(c, hungry: false, width: 96),
      const Size(96, 104),
    );
    expect(at(48, 32), _near(_hex('#B9C7DA')));
  });
}
