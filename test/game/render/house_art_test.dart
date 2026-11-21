import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/render/render.dart';

const _size = Size(390, 652);

/// Warna piksel lapisan [layers] yang digambar berurutan seukuran desain.
Future<Color Function(double x, double y)> _sample(
  HouseRoom room,
  List<HouseLayer> layers, {
  Size size = _size,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  for (final layer in layers) {
    paintHouseLayer(canvas, room, layer, size: size);
  }
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

int _ch(double v) => (v * 255).round();

Matcher _near(int r, int g, int b, {int tolerance = 4}) =>
    predicate<Color>((c) {
      return (_ch(c.r) - r).abs() <= tolerance &&
          (_ch(c.g) - g).abs() <= tolerance &&
          (_ch(c.b) - b).abs() <= tolerance;
    }, 'mendekati ($r, $g, $b)');

void main() {
  test(
    'ruang tengah: dinding belakang, lantai bergradien, langit di pintu',
    () async {
      final px = await _sample(HouseRoom.living, [HouseLayer.back]);
      expect(px(203, 300), _near(0xFC, 0xE6, 0xC8));
      // Gradien lantai #E3BC86 → #EBC896 dari y 392 sampai 652.
      expect(px(230, 600), _near(233, 198, 147));
      final sky = px(360, 250);
      expect(_ch(sky.b), greaterThan(_ch(sky.r)));
    },
  );

  test('kusen depan: hanya tiang pintu, sisanya transparan', () async {
    final px = await _sample(HouseRoom.living, [HouseLayer.frame]);
    expect(px(388, 300), _near(0xC9, 0x94, 0x66));
    expect(px(200, 300).a, 0);
    final terrace = await _sample(HouseRoom.terrace, [HouseLayer.frame]);
    expect(terrace(2, 300), _near(0xC9, 0x94, 0x66));
    expect(terrace(200, 300).a, 0);
  });

  test('teras: lewat pintu kiri terlihat ruang tengah yang hangat', () async {
    final px = await _sample(HouseRoom.terrace, [HouseLayer.back]);
    final inside = px(40, 300);
    expect(_ch(inside.r), greaterThan(_ch(inside.b) + 20));
  });

  test('cahaya pintu (#FFE39A) mencerahkan lantai ruang tengah', () async {
    final plain = await _sample(HouseRoom.living, [HouseLayer.back]);
    final lit = await _sample(HouseRoom.living, [
      HouseLayer.back,
      HouseLayer.floorLight,
    ]);
    expect(_ch(lit(300, 480).g), greaterThan(_ch(plain(300, 480).g) + 5));
    expect(_ch(lit(120, 600).g), _ch(plain(120, 600).g));
  });

  test('diskalakan ke ukuran ruangan (n360: pintu ikut mengecil)', () async {
    const small = Size(360, 488);
    final px = await _sample(HouseRoom.living, [HouseLayer.frame], size: small);
    // Kusen desain x 381–392, y 191–503 → x 352–362, y 143–377.
    expect(px(356, 260), _near(0xC9, 0x94, 0x66));
    expect(px(356, 420).a, 0);
  });

  test('semua lapisan bisa digambar diam dan bergerak', () {
    for (final room in HouseRoom.values) {
      for (final layer in HouseLayer.values) {
        for (final time in [null, 0.0, 3.0, 17.5]) {
          final recorder = PictureRecorder();
          paintHouseLayer(
            Canvas(recorder),
            room,
            layer,
            size: _size,
            time: time,
          );
          recorder.endRecording();
        }
      }
    }
  });
}
