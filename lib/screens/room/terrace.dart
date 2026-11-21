// PROTOTIPE (spike/teras, 21 Nov 2026): teras di kanan ruang tengah untuk
// dicoba di HP. Sekali pakai: warna ditulis di sini, bukan token, dan tidak
// ada test. Kalau idenya dipakai, dibangun ulang lewat desain dan rencana.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/kitties.dart';
import '../../game/model/room_life.dart';
import 'room_geometry.dart';

/// Nyalakan dengan `--dart-define=TERAS=true`.
const terraceSpike = bool.fromEnvironment('TERAS');

/// Lebar desain seluruh rumah: ruang tengah 390 + teras.
const houseDesignWidth = 740.0;

// Pintu (px desain): kusen kiri 372–384, bukaan 384–458, kusen kanan
// 458–470, ambang atas sampai y 150.
const _doorLeft = 372.0;
const _openLeft = 384.0;
const _openRight = 458.0;
const _doorRight = 470.0;
const _lintel = 150.0;

/// Tempat nyaman tanpa barang: titik kaki (px desain rumah), pose, arah
/// hadap, lama, dan bobot.
const _places = <(Offset, LifePose, LifeHeading, double, int)>[
  (Offset(421, 470), LifePose.idle, LifeHeading.right, 7, 3), // ambang pintu
  (Offset(600, 568), LifePose.lounge, LifeHeading.down, 10, 4), // berjemur
  (Offset(560, 600), LifePose.sleep, LifeHeading.down, 10, 2), // matahari
  (Offset(670, 458), LifePose.lick, LifeHeading.left, 5, 2), // dekat pagar
  (Offset(520, 628), LifePose.idle, LifeHeading.left, 5, 2), // dekat pot
  (Offset(110, 486), LifePose.sleep, LifeHeading.down, 8, 2), // bawah jendela
  (Offset(220, 616), LifePose.lounge, LifeHeading.down, 8, 2), // tengah
];

/// Tempat nyaman untuk [RoomLife] di rumah [house] (geometri seluruh
/// rumah, `designWidth` = [houseDesignWidth]).
Map<int, LifePlace> terracePlaces(RoomGeometry house) {
  final unit = house.room.width / houseDesignWidth;
  final floorUnit = house.floor.height / (designRoomHeight - designFloorTop);
  return {
    for (final (i, (feet, pose, heading, seconds, weight)) in _places.indexed)
      i: LifePlace(
        house.catSpotAt(
          KittyId.values[1],
          house.catBoxAtFeet(
            KittyId.values[1],
            feet.dx * unit,
            house.floor.top + (feet.dy - designFloorTop) * floorUnit,
          ),
        ),
        pose: pose,
        heading: heading,
        seconds: seconds,
        weight: weight,
      ),
  };
}

/// Lebar ruang tengah yang terlihat penuh sebelum digeser (px layar).
double terraceStart(RoomGeometry house) =>
    _openLeft * house.room.width / houseDesignWidth;

/// Latar teras, pintu, dan cahaya yang masuk ke ruang tengah. Digambar di
/// atas [RoomBackground] ruang tengah, di bawah barang dan kucing.
class TerraceBackground extends StatelessWidget {
  const TerraceBackground({super.key, required this.house, this.time});

  final RoomGeometry house;
  final double? time;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(painter: _TerracePainter(house, time ?? 0)),
  );
}

const _sky = Color(0xFFA9DBF2);
const _skyLow = Color(0xFFE6F4DE);
const _sun = Color(0xFFFFD45C);
const _cloud = Color(0xFFFFFFFF);
const _hedge = Color(0xFF8CC47A);
const _hedgeDark = Color(0xFF6FAE62);
const _rail = Color(0xFFC08A58);
const _railDark = Color(0xFF9C6A3E);
const _deck = Color(0xFFDDAE74);
const _deckLine = Color(0x55A06B3C);
const _wallTop = Color(0xFFFCE6C8);
const _jamb = Color(0xFFB07A4F);
const _jambLight = Color(0xFFC99466);
const _threshold = Color(0xFFC99466);
const _light = Color(0xFFFFE9A8);
const _pot = Color(0xFFD9774B);
const _potDark = Color(0xFFB85E36);
const _leaf = Color(0xFF79B866);
const _leafDark = Color(0xFF5E9E50);

class _TerracePainter extends CustomPainter {
  _TerracePainter(this.house, this.time);

  final RoomGeometry house;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final u = house.room.width / houseDesignWidth;
    final wallU = house.wall.height / designWallHeight;
    final floorU = house.floor.height / (designRoomHeight - designFloorTop);
    double x(double v) => v * u;
    double wy(double v) => v * wallU;
    double fy(double v) => house.floor.top + (v - designFloorTop) * floorU;
    final right = house.room.width;
    final wallBottom = house.trim.bottom;

    // Cahaya dari pintu di lantai ruang tengah.
    final glow = Path()
      ..moveTo(x(_openLeft), fy(440))
      ..lineTo(x(_openLeft), fy(652))
      ..lineTo(x(250), fy(652))
      ..lineTo(x(330), fy(440))
      ..close();
    canvas.drawPath(
      glow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_light.withValues(alpha: 0.75), _light.withValues(alpha: 0)],
        ).createShader(Rect.fromLTRB(x(250), 0, x(_openLeft), 1)),
    );

    // Langit teras.
    final sky = Rect.fromLTRB(x(_openLeft), 0, right, wallBottom);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sky, _skyLow],
        ).createShader(sky),
    );
    final sunAt = Offset(x(650), wy(240));
    canvas.drawCircle(
      sunAt,
      x(58),
      Paint()..color = _sun.withValues(alpha: 0.22),
    );
    canvas.drawCircle(sunAt, x(30), Paint()..color = _sun);
    final drift = math.sin(time * 0.15) * x(10);
    _cloudAt(canvas, Offset(x(560) + drift, wy(170)), x(1));
    _cloudAt(canvas, Offset(x(430) - drift, wy(210)), x(0.7));

    // Pagar tanaman di kejauhan.
    final hedge = Paint()..color = _hedge;
    for (var cx = _openLeft - 10; cx < houseDesignWidth + 40; cx += 44) {
      canvas.drawCircle(Offset(x(cx), wy(318)), x(30), hedge);
    }
    canvas.drawRect(
      Rect.fromLTRB(x(_openLeft), wy(318), right, wy(350)),
      Paint()..color = _hedgeDark,
    );

    // Pagar kayu teras.
    final rail = Paint()..color = _rail;
    final railDark = Paint()..color = _railDark;
    for (var px = _doorRight + 14; px < houseDesignWidth; px += 34) {
      canvas.drawRect(
        Rect.fromLTWH(x(px), wy(300), x(10), wallBottom - wy(300)),
        rail,
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(x(_doorRight), wy(292), right, wy(306)),
      railDark,
    );
    canvas.drawRect(
      Rect.fromLTRB(x(_doorRight), wy(356), right, wy(366)),
      railDark,
    );
    // Lis bawah teras.
    canvas.drawRect(
      Rect.fromLTRB(x(_openLeft), house.trim.top, right, wallBottom),
      Paint()..color = _railDark,
    );

    // Lantai papan teras.
    final deck = Rect.fromLTRB(
      x(_openLeft),
      house.floor.top,
      right,
      house.room.height,
    );
    canvas.drawRect(deck, Paint()..color = _deck);
    final line = Paint()..color = _deckLine;
    for (var px = _openLeft + 30; px < houseDesignWidth; px += 30) {
      canvas.drawRect(Rect.fromLTWH(x(px), deck.top, x(2), deck.height), line);
    }
    // Petak matahari.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x(590), fy(575)),
        width: x(190),
        height: fy(575) - fy(505),
      ),
      Paint()..color = _light.withValues(alpha: 0.7),
    );

    // Pot tanaman.
    _potAt(canvas, Offset(x(712), wallBottom + x(4)), x(1.1));
    _potAt(canvas, Offset(x(488), fy(648)), x(0.9));

    // Dinding di atas pintu dan kusen.
    canvas.drawRect(
      Rect.fromLTRB(x(_doorLeft), 0, x(_doorRight), wy(_lintel)),
      Paint()..color = _wallTop,
    );
    final jamb = Paint()..color = _jamb;
    final jambLight = Paint()..color = _jambLight;
    canvas.drawRect(
      Rect.fromLTRB(
        x(_doorLeft) - x(4),
        wy(_lintel) - x(14),
        x(_doorRight) + x(4),
        wy(_lintel),
      ),
      jamb,
    );
    for (final (l, r) in [(_doorLeft, _openLeft), (_openRight, _doorRight)]) {
      canvas.drawRect(Rect.fromLTRB(x(l), wy(_lintel), x(r), wallBottom), jamb);
      canvas.drawRect(
        Rect.fromLTRB(x(l), wy(_lintel), x(l) + x(3), wallBottom),
        jambLight,
      );
    }
    // Ambang pintu.
    canvas.drawRect(
      Rect.fromLTRB(x(_doorLeft), house.floor.top, x(_doorRight), fy(446)),
      Paint()..color = _threshold,
    );
  }

  void _cloudAt(Canvas canvas, Offset at, double k) {
    final p = Paint()..color = _cloud.withValues(alpha: 0.9);
    canvas.drawCircle(at, 18 * k, p);
    canvas.drawCircle(at + Offset(20 * k, 4 * k), 14 * k, p);
    canvas.drawCircle(at + Offset(-20 * k, 5 * k), 12 * k, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          at.dx - 30 * k,
          at.dy + 2 * k,
          at.dx + 32 * k,
          at.dy + 18 * k,
        ),
        Radius.circular(8 * k),
      ),
      p,
    );
  }

  /// Pot dengan alas di [base] (tengah bawah).
  void _potAt(Canvas canvas, Offset base, double k) {
    final leaf = Paint()..color = _leaf;
    final leafDark = Paint()..color = _leafDark;
    for (final (dx, dy, r, dark) in [
      (-16.0, -52.0, 16.0, true),
      (14.0, -56.0, 17.0, true),
      (0.0, -70.0, 18.0, false),
      (-10.0, -46.0, 13.0, false),
      (12.0, -44.0, 12.0, false),
    ]) {
      canvas.drawCircle(
        base + Offset(dx * k, dy * k),
        r * k,
        dark ? leafDark : leaf,
      );
    }
    final pot = Path()
      ..moveTo(base.dx - 20 * k, base.dy - 36 * k)
      ..lineTo(base.dx + 20 * k, base.dy - 36 * k)
      ..lineTo(base.dx + 15 * k, base.dy)
      ..lineTo(base.dx - 15 * k, base.dy)
      ..close();
    canvas.drawPath(pot, Paint()..color = _pot);
    canvas.drawRect(
      Rect.fromLTRB(
        base.dx - 22 * k,
        base.dy - 40 * k,
        base.dx + 22 * k,
        base.dy - 32 * k,
      ),
      Paint()..color = _potDark,
    );
  }

  @override
  bool shouldRepaint(_TerracePainter old) =>
      old.house.room != house.room || (old.time - time).abs() > 0.2;
}
