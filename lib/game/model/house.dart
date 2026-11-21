import 'dart:math' as math;

import 'home_items.dart';

/// Rumah Oyen dua ruangan (langkah 33, desain `rumah-dua-ruangan`):
/// ruang tengah dan teras, dihubungkan satu pintu. Semua angka di sini
/// koordinat desain area rumah 390×652 (catatan `kRuangTengah`, `kTeras`,
/// `kSkala` di `canvas.json`).
enum HouseRoom {
  living,
  terrace;

  HouseRoom get other => this == living ? terrace : living;
}

/// Garis lantai paling belakang dan paling depan (titik kaki).
const houseDepthBack = 392.0;
const houseDepthFront = 652.0;

/// Ukuran sprite menurut kedalaman: 0,75 di garis belakang, 1,15 di depan.
double depthScale(double feetY) {
  final t = ((feetY - houseDepthBack) / (houseDepthFront - houseDepthBack))
      .clamp(0.0, 1.0);
  return 0.75 + 0.4 * t;
}

/// Barang dinding yang juga boleh digantung di balok atap teras.
const terraceHangers = {RoomItemId.hammock, RoomItemId.lampuBulan};

/// Barang dinding di dinding belakang ruang tengah: skala tetap.
const houseWallScale = 0.75;

/// Rentang dinding belakang ruang tengah untuk barang dinding.
const houseWallLeft = 88.0;
const houseWallRight = 302.0;
const houseWallTop = 150.0;
const houseWallBottom = 332.0;

/// Barang lantai boleh di ruangan mana pun (mangkuk hanya ruang tengah);
/// barang dinding hanya di ruang tengah, kecuali [terraceHangers].
bool canPlaceIn(RoomItemId id, HouseRoom room) {
  if (room == HouseRoom.living) return true;
  final item = roomItemOf(id);
  if (item.builtIn) return false;
  return item.zone == RoomZone.floor || terraceHangers.contains(id);
}

typedef HousePoint = ({double x, double y});

/// Lantai berperspektif yang sama di kedua ruangan. [Spot] lantai =
/// titik kaki (tengah bawah) di zona Hias: `y` 0 = belakang (y 398), 1 =
/// depan (y 646); `x` 0–1 dari tepi kiri ke tepi kanan zona di kedalaman
/// itu. Spot simpanan v1 dibaca langsung sebagai pecahan di zona ini.
class HouseFloor {
  const HouseFloor();

  static const _top = 398.0;
  static const _bottom = 646.0;
  static const _bend = 508.0;
  static const _backLeft = 84.0;
  static const _backRight = 306.0;
  static const _frontLeft = 4.0;
  static const _frontRight = 386.0;
  static const _width = 390.0;

  double _left(double y) => y >= _bend
      ? _frontLeft
      : _backLeft + (_frontLeft - _backLeft) * (y - _top) / (_bend - _top);

  double _right(double y) => y >= _bend
      ? _frontRight
      : _backRight + (_frontRight - _backRight) * (y - _top) / (_bend - _top);

  HousePoint feetAt(Spot spot) {
    final y = _top + spot.y * (_bottom - _top);
    final left = _left(y);
    return (x: left + spot.x * (_right(y) - left), y: y);
  }

  /// Kebalikan [feetAt], dijepit ke zona.
  Spot spotAtFeet(double x, double y) {
    final yc = y.clamp(_top, _bottom);
    final left = _left(yc);
    return Spot(
      (x - left) / (_right(yc) - left),
      (yc - _top) / (_bottom - _top),
    );
  }

  /// Jarak dua titik kaki, px desain.
  double distance(Spot a, Spot b) {
    final p = feetAt(a);
    final q = feetAt(b);
    final dx = p.x - q.x;
    final dy = p.y - q.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Ukuran gambar barang lantai pada [scale] kedalaman (ukuran
  /// `Barang.dc.html` × skala, seperti `AdeganTengah`).
  ({double width, double height}) itemSize(RoomItem item, double scale) =>
      (width: item.baseWidth * scale, height: item.baseHeight * scale);

  /// Titik kaki dan skala barang lantai di [spot]; tengahnya dijepit
  /// supaya gambarnya tetap di dalam lebar rumah.
  ({double x, double y, double scale}) itemFeet(RoomItem item, Spot spot) {
    final feet = feetAt(spot);
    final scale = depthScale(feet.y);
    final half = itemSize(item, scale).width / 2;
    return (
      x: feet.x.clamp(half, math.max(half, _width - half)),
      y: feet.y,
      scale: scale,
    );
  }

  /// Tempat kucing berdiri di ambang pintu ruangan [room].
  Spot threshold(HouseRoom room) =>
      room == HouseRoom.living ? spotAtFeet(345, 456) : spotAtFeet(46, 456);

  /// Area yang tidak boleh ditempati barang, dari ambang ke tengah lantai.
  List<HousePoint> doorPath(HouseRoom room) => room == HouseRoom.living
      ? const [
          (x: 318, y: 402),
          (x: 384, y: 491),
          (x: 266, y: 570),
          (x: 212, y: 508),
        ]
      : const [
          (x: 72, y: 401),
          (x: 176, y: 516),
          (x: 124, y: 578),
          (x: 4, y: 492),
        ];

  /// Barang lantai [item] di [spot] menutup jalur pintu: jejaknya (selebar
  /// gambar, 12 × skala px di belakang kaki) bersinggungan dengan
  /// [doorPath]. Barang rata (karpet) dan barang dinding boleh di sana.
  bool blocksDoor(RoomItem item, HouseRoom room, Spot spot) {
    if (item.zone != RoomZone.floor || item.flat) return false;
    final feet = itemFeet(item, spot);
    final half = itemSize(item, feet.scale).width / 2;
    return _rectTouches(
      doorPath(room),
      feet.x - half,
      feet.y - 12 * feet.scale,
      feet.x + half,
      feet.y,
    );
  }

  /// [spot] kalau tidak menutup jalur pintu; selain itu spot terdekat
  /// (jarak kaki) di kisi 41×41 yang tidak menutupnya.
  Spot allowedSpot(RoomItem item, HouseRoom room, Spot spot) {
    if (!blocksDoor(item, room, spot)) return spot;
    Spot? best;
    var bestDistance = double.infinity;
    for (var i = 0; i <= 40; i++) {
      for (var j = 0; j <= 40; j++) {
        final candidate = Spot(i / 40, j / 40);
        if (blocksDoor(item, room, candidate)) continue;
        final d = distance(spot, candidate);
        if (d < bestDistance) {
          bestDistance = d;
          best = candidate;
        }
      }
    }
    return best ?? spot;
  }
}

/// Persegi (l, t, r, b) bersinggungan dengan poligon cembung atau tidak.
bool _rectTouches(
  List<HousePoint> polygon,
  double l,
  double t,
  double r,
  double b,
) {
  bool inRect(HousePoint p) => p.x >= l && p.x <= r && p.y >= t && p.y <= b;
  if (polygon.any(inRect)) return true;
  final corners = <HousePoint>[
    (x: l, y: t),
    (x: r, y: t),
    (x: r, y: b),
    (x: l, y: b),
  ];
  if (corners.any((c) => _inPolygon(polygon, c))) return true;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final c = polygon[(i + 1) % polygon.length];
    for (var k = 0; k < 4; k++) {
      if (_cross(a, c, corners[k], corners[(k + 1) % 4])) return true;
    }
  }
  return false;
}

bool _inPolygon(List<HousePoint> polygon, HousePoint p) {
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final a = polygon[i];
    final b = polygon[j];
    if ((a.y > p.y) != (b.y > p.y) &&
        p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

double _side(HousePoint a, HousePoint b, HousePoint p) =>
    (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);

bool _cross(HousePoint a, HousePoint b, HousePoint c, HousePoint d) =>
    _side(a, b, c) * _side(a, b, d) < 0 && _side(c, d, a) * _side(c, d, b) < 0;
