import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/picture_map_art.dart';

import '../../test_helpers.dart';

/// Warna piksel di (x, y) gambar [paint] seukuran [size].
Future<Color> _pixel(void Function(Canvas) paint, Size size, Offset at) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(
    size.width.ceil(),
    size.height.ceil(),
  );
  final data = (await image.toByteData())!;
  final i = (at.dy.toInt() * image.width + at.dx.toInt()) * 4;
  return Color.fromARGB(
    data.getUint8(i + 3),
    data.getUint8(i),
    data.getUint8(i + 1),
    data.getUint8(i + 2),
  );
}

void main() {
  const points = PictureMapArt.points;

  test('titik node desain 23', () {
    expect(points, const [
      Offset(86, 262),
      Offset(200, 236),
      Offset(306, 282),
      Offset(300, 378),
      Offset(190, 404),
      Offset(84, 446),
      Offset(96, 546),
      Offset(206, 574),
      Offset(306, 612),
      Offset(196, 724),
    ]);
  });

  test('roadD: kurva halus seperti desain (toFixed(1))', () {
    final d = PictureMapArt.roadD(points);
    expect(d, startsWith('M86 262 C105.0 257.7 163.3 232.7 200 236 C'));
    expect(d.split(' C'), hasLength(10));
    expect(d, endsWith(' 196 724'));
  });

  test('onRoad: ujung segmen di titik node, tengahnya melengkung', () {
    expect(PictureMapArt.onRoad(points, 1, 0), points[1]);
    expect(PictureMapArt.onRoad(points, 1, 1), points[2]);
    final mid = PictureMapArt.onRoad(points, 1, 0.5);
    final straight = (points[1] + points[2]) / 2;
    expect((mid - straight).distance, greaterThan(0.5));
  });

  test('benda per level urut desain', () {
    final levels = testLevels;
    expect(PictureMapArt.objectOf(levels[0]), 'kulkas');
    expect(PictureMapArt.objectOf(levels[9]), 'pestaIkanAsin');
    expect(PictureMapArt.objectOf(levels[12]), 'rakTV');
    expect(PictureMapArt.objectOf(levels[19]), 'ketupat');
    expect({
      for (final level in levels) PictureMapArt.objectOf(level),
    }, hasLength(20));
  });

  test('layar kecil: jarak vertikal dirapatkan 12% dari titik pertama', () {
    final compact = PictureMapArt.pointsFor(compact: true);
    expect(compact.first, points.first);
    expect(compact[9].dx, points[9].dx);
    expect(compact[9].dy, closeTo(262 + (724 - 262) * 0.88, 1e-9));
    expect(PictureMapArt.pointsFor(compact: false), points);
  });

  test(
    'ikon benda: semua 20 bisa digambar, tengah kulkas tidak kosong',
    () async {
      for (final level in testLevels) {
        final object = PictureMapArt.objectOf(level);
        final color = await _pixel(
          (c) => paintNodeIcon(c, object, size: 46),
          const Size(46, 46),
          const Offset(23, 23),
        );
        expect(color.a, greaterThan(0), reason: object);
      }
    },
  );

  test('peta: latar babak dan jalur tergambar', () async {
    for (final chapter in [1, 2]) {
      final color = await _pixel(
        (c) => paintPictureMap(c, chapter: chapter, points: points),
        const Size(390, 844),
        // Di jalur antara node 1 dan 2 (garis 34 px #FFF4E2).
        PictureMapArt.onRoad(points, 0, 0.5),
      );
      expect(color.a, greaterThan(0), reason: 'babak $chapter');
    }
  });
}
