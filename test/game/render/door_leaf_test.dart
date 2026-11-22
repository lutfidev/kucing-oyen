import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/door_leaf.dart';

Matcher _at(double x, double y) => predicate<({double x, double y})>(
  (p) => (p.x - x).abs() <= 0.6 && (p.y - y).abs() <= 0.6,
  'mendekati ($x, $y)',
);

/// Warna piksel di koordinat desain 390×652 sesudah [paint].
Future<Color> _pixel(void Function(Canvas) paint, double x, double y) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(390, 652);
  final bytes = (await image.toByteData())!;
  final i = (y.floor() * 390 + x.floor()) * 4;
  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

void main() {
  test('pintu depan tertutup = bukaan dinding kiri (kPintuDepan)', () {
    const f = DoorLeafSide.front;
    expect(doorLeafPoint(f, 0, 0, 0), _at(70, 212));
    expect(doorLeafPoint(f, 0, 1, 0), _at(8, 203));
    expect(doorLeafPoint(f, 0, 1, 1), _at(8, 489));
    expect(doorLeafPoint(f, 0, 0, 1), _at(70, 403));
  });

  test('pintu pulang tertutup = bukaan dinding kanan, terbuka 8° di x 363', () {
    const h = DoorLeafSide.home;
    expect(doorLeafPoint(h, 0, 0, 0), _at(320, 212));
    expect(doorLeafPoint(h, 0, 1, 0), _at(382, 203));
    expect(doorLeafPoint(h, 0, 1, 1), _at(382, 489));
    expect(doorLeafPoint(h, 0, 0, 1), _at(320, 403));
    expect(doorLeafPoint(h, 8, 1, 0).x, closeTo(363, 0.6));
  });

  test('pintu kucing tertutup (kPintuDepan)', () {
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 0, 0), _at(61, 344));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 1, 0), _at(25, 375));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 1, 1), _at(25, 455));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 0, 1), _at(61, 407));
  });

  test('sisi yang terlihat berganti di sekitar 27°', () {
    expect(doorShowsOutside(DoorLeafSide.front, 0), isFalse);
    expect(doorShowsOutside(DoorLeafSide.front, 20), isFalse);
    expect(doorShowsOutside(DoorLeafSide.front, 40), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 0), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 20), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 40), isFalse);
  });

  test('daun pintu depan tertutup bercat kayu di tengah daun', () async {
    final color = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0, flapDeg: 0),
      45,
      323,
    );
    expect(color, const Color(0xFFC99466));
  });

  test('tanpa pintu kucing (flapDeg null) lubangnya tembus', () async {
    // Tengah lubang pintu kucing: u 0,5, v 0,8.
    final p = doorLeafPoint(DoorLeafSide.front, 0, 0.5, 0.8);
    final open = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0),
      p.x,
      p.y,
    );
    expect(open.a, 0);
    final closed = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0, flapDeg: 0),
      p.x,
      p.y,
    );
    expect(closed.a, greaterThan(0.9));
  });
}
