import 'dart:math' as math;
import 'dart:ui';

import 'design_svg_lane.dart';

/// Daun pintu yang diproyeksikan: [front] = pintu depan di dinding kiri
/// ruang tengah (desain `sisi: kiri`), [home] = pintu pulang di dinding
/// kanan gang (`kanan`, X dicerminkan).
enum DoorLeafSide { front, home }

/// Titik di layar desain 390×652.
typedef DoorPoint = ({double x, double y});

// Kamera dan daun pintu (`kProyeksi`, `PintuDepan.dc.html`): x = 195 +
// 270·X/Z, y = 230 + 270·Y/Z; engsel di Z 2,16, lebar daun 0,716…, tepi
// atas Y −0,144, tinggi 1,528….
const _focal = 270.0;
const _vanishX = 195.0;
const _vanishY = 230.0;
const _hingeZ = 2.16;
const _leafWidth = 0.716149732620321;
const _leafTop = -0.14400000000000002;
const _leafHeight = 1.5286153846153847;

/// Lubang pintu kucing di daun (u kiri, v atas, u kanan, v bawah).
const _flapBox = (0.2, 0.65, 0.8, 0.96);

/// Tebal daun pintu (pita di tepi bebas).
const _thickness = 0.045;

/// Pita tepi bebas daun (`tepi` desain).
const _edgeFill = Color(0xFFB07A4F);
const _edgeStroke = Color(0xFF8E5A30);
const _edgeStrokeWidth = 0.8;

/// Titik daun pintu [side] terbuka [angleDeg] derajat: [u] dari engsel
/// (0) ke tepi bebas (1), [v] dari atas (0) ke bawah (1), [n] tegak lurus
/// daun ke arah ruangan (`P3` desain).
DoorPoint doorLeafPoint(
  DoorLeafSide side,
  double angleDeg,
  double u,
  double v, {
  double n = 0,
}) {
  final theta = angleDeg * math.pi / 180;
  return _project(side, u, v, n, math.sin(theta), math.cos(theta));
}

DoorPoint _project(
  DoorLeafSide side,
  double u,
  double v,
  double n,
  double sin,
  double cos,
) {
  var x = -1 + u * _leafWidth * sin + n * cos;
  final z = _hingeZ - u * _leafWidth * cos + n * sin;
  final y = _leafTop + v * _leafHeight;
  if (side == DoorLeafSide.home) x = -x;
  return (x: _vanishX + _focal * x / z, y: _vanishY + _focal * y / z);
}

/// Titik daun pintu kucing di pintu [side] terbuka [angleDeg]: [a] 0–1 dari
/// kiri ke kanan lubang, [b] 0–1 dari engsel atas flap ke bawah; flap
/// berayun [flapDeg] derajat ke arah ruangan (`fnF` desain).
DoorPoint doorFlapPoint(
  DoorLeafSide side,
  double angleDeg,
  double flapDeg,
  double a,
  double b,
) {
  final (left, top, right, bottom) = _flapBox;
  final phi = flapDeg * math.pi / 180;
  final down = (bottom - top) * b;
  return doorLeafPoint(
    side,
    angleDeg,
    left + (right - left) * a,
    top + down * math.cos(phi),
    n: down * _leafHeight * math.sin(phi),
  );
}

double _area(List<DoorPoint> points) {
  var sum = 0.0;
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final q = points[(i + 1) % points.length];
    sum += p.x * q.y - q.x * p.y;
  }
  return sum;
}

List<DoorPoint> _corners(DoorLeafSide side, double sin, double cos) => [
  for (final (u, v) in const [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)])
    _project(side, u, v, 0, sin, cos),
];

/// Daun pintu [side] terbuka [angleDeg] memperlihatkan sisi luarnya:
/// pintu depan mulai sekitar 27°, pintu pulang sebelum itu (`flip`
/// desain: tanda luas daun berbalik dibanding pintu tertutup).
bool doorShowsOutside(DoorLeafSide side, double angleDeg) {
  final theta = angleDeg * math.pi / 180;
  final flip =
      _area(_corners(side, math.sin(theta), math.cos(theta))) *
          _area(_corners(side, 0, 1)) <
      0;
  final near = side == DoorLeafSide.home;
  return flip ? !near : near;
}

Color _color(Object? hex) {
  final s = hex! as String;
  return Color(0xFF000000 | int.parse(s.substring(1), radix: 16));
}

Path _polygon(List<DoorPoint> points) =>
    Path()..addPolygon([for (final p in points) Offset(p.x, p.y)], true);

/// Menggambar daun pintu [side] terbuka [angleDeg] di koordinat desain
/// 390×652, dari data `DATA` desain: pita tepi, poligon daun sisi yang
/// terlihat (lubang pintu kucing dengan `evenodd`), lalu daun pintu kucing
/// berayun [flapDeg]. [flapDeg] null = tanpa daun pintu kucing (kucing
/// sedang lewat); [leaf] false = tidak menggambar apa pun.
void paintDoorLeaf(
  Canvas canvas,
  DoorLeafSide side, {
  required double angleDeg,
  double? flapDeg,
  bool leaf = true,
}) {
  if (!leaf) return;
  final theta = angleDeg * math.pi / 180;
  final sin = math.sin(theta);
  final cos = math.cos(theta);
  DoorPoint at(List<Object?> p, {double n = 0}) => _project(
    side,
    (p[0]! as num).toDouble(),
    (p[1]! as num).toDouble(),
    n,
    sin,
    cos,
  );

  void draw(Path path, Color fill, Color? stroke, double width) {
    canvas.drawPath(path, Paint()..color = fill);
    if (stroke != null && width > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width
          ..color = stroke,
      );
    }
  }

  draw(
    _polygon([
      at(const [1, 0]),
      at(const [1, 1]),
      at(const [1, 1], n: -_thickness),
      at(const [1, 0], n: -_thickness),
    ]),
    _edgeFill,
    _edgeStroke,
    _edgeStrokeWidth,
  );

  final face = doorShowsOutside(side, angleDeg) ? 'l' : 'd';
  for (final e in doorLeafData['E']!) {
    if (e['f'] != face) continue;
    final path = _polygon([for (final p in e['p']! as List) at(p as List)]);
    final hole = e['h'] as List?;
    if (hole != null) {
      path
        ..addPath(_polygon([for (final p in hole) at(p as List)]), Offset.zero)
        ..fillType = PathFillType.evenOdd;
    }
    final stroke = e['st'];
    draw(
      path,
      _color(e['fill']),
      stroke == 'none' ? null : _color(stroke),
      (e['sw']! as num).toDouble(),
    );
  }

  final flap = flapDeg;
  if (flap == null) return;
  for (final e in doorLeafData['FL']!) {
    final path = _polygon([
      for (final p in e['p']! as List)
        doorFlapPoint(
          side,
          angleDeg,
          flap,
          ((p as List)[0] as num).toDouble(),
          (p[1] as num).toDouble(),
        ),
    ]);
    final stroke = e['st'];
    draw(
      path,
      _color(e['fill']),
      stroke == 'none' ? null : _color(stroke),
      (e['sw']! as num).toDouble(),
    );
  }
}
