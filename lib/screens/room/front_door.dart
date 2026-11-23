import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/render/render.dart';
import '../../widgets/widgets.dart';
import 'room_geometry.dart';

/// Momen ekor (desain 4, `AdeganTengah` `ekorA`–`ekorC`), detik sejak ekor
/// Kumis muncul di pintu kucing: ekor bergoyang [tailShowSeconds], Oyen
/// menoleh dengan "!" [tailNoticeSeconds], lalu ekor hilang dan pintu
/// kucing mereda [tailSettleSeconds] sebelum Oyen berjalan ke pintu.
const tailShowSeconds = 1.2;
const tailNoticeSeconds = 0.8;
const tailSettleSeconds = 0.8;
const tailMomentSeconds =
    tailShowSeconds + tailNoticeSeconds + tailSettleSeconds;

/// Pintu kucing terdorong ekor (20°) dan sudut sesudahnya mereda (9° di
/// tengah peredaman, 0° di akhir).
const tailFlapDeg = 20.0;

/// Ayunan pintu kucing sesudah Oyen lewat: keluar −14°, masuk 12°
/// (`selinapC`, `pulangB`), mereda dalam [flapSwingSeconds].
const flapOutDeg = -14.0;
const flapInDeg = 12.0;
const flapSwingSeconds = 0.8;

/// Tahap momen ekor pada detik [t], null sesudah selesai.
enum TailPhase { tail, notice, settle }

TailPhase? tailPhaseAt(double t) {
  if (t < 0) return null;
  if (t < tailShowSeconds) return TailPhase.tail;
  if (t < tailShowSeconds + tailNoticeSeconds) return TailPhase.notice;
  if (t < tailMomentSeconds) return TailPhase.settle;
  return null;
}

/// Ekor masih terlihat (tahap [TailPhase.tail] dan [TailPhase.notice]).
bool tailVisibleAt(double t) {
  final phase = tailPhaseAt(t);
  return phase == TailPhase.tail || phase == TailPhase.notice;
}

/// Sudut pintu kucing selama momen ekor: 20° selama ekor ada, lalu mereda
/// 20° → 9° → 0° (desain: "peredaman 0,8 s").
double tailFlapAt(double t) {
  if (tailVisibleAt(t)) return tailFlapDeg;
  final u = ((t - tailShowSeconds - tailNoticeSeconds) / tailSettleSeconds)
      .clamp(0.0, 1.0);
  return tailFlapDeg * math.pow(1 - u, 1.15);
}

/// Pintu kucing berayun dari [from] dan mereda ke 0 dalam
/// [flapSwingSeconds] (sekali balik arah, seperti daun yang terayun).
double flapSwingAt(double t, double from) {
  if (t >= flapSwingSeconds) return 0;
  final u = (t / flapSwingSeconds).clamp(0.0, 1.0);
  return from * math.pow(1 - u, 1.4) * math.cos(u * math.pi * 1.5);
}

/// Pintu depan ruang tengah (desain 1b, 4): daun pintu tertutup, pintu
/// kucing pada [flapDeg] (null = sedang dilewati, tidak digambar), dan ekor
/// Kumis yang bergoyang kalau [tail]. Seukuran area rumah, di lapisan
/// `door` [RoomScene]. [time] = detik goyang ekor, null = diam.
class FrontDoor extends StatelessWidget {
  const FrontDoor({
    super.key,
    required this.flapDeg,
    this.angleDeg = 0,
    this.tail = false,
    this.time,
  });

  /// Sudut daun pintu depan (0 = tertutup; terbuka selama kamera ke gang).
  final double angleDeg;
  final double? flapDeg;
  final bool tail;
  final double? time;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        DoorLeafView(
          side: DoorLeafSide.front,
          angleDeg: angleDeg,
          flapDeg: flapDeg,
        ),
        if (tail) KumisTailView(key: const ValueKey('kumis-tail'), time: time),
      ],
    ),
  );
}

/// Penanda "Oyen di gang" (`PenandaGang.dc.html`) di dekat pintu depan,
/// kotak desain (15, 238) 48×52, naik-turun 3 px (`pgBob` 2,4 detik).
/// Tanpa semantik: label pintu depan yang menyebutnya.
class LaneMarker extends StatelessWidget {
  const LaneMarker({super.key, required this.geo, this.time});

  final RoomGeometry geo;
  final double? time;

  /// Kotak desain penanda.
  static const box = Rect.fromLTWH(15, 238, 48, 52);

  /// Naik-turun `pgBob`: 0 → −3 → 0 px desain dalam 2,4 detik.
  static const bobPx = 3.0;
  static const bobSeconds = 2.4;

  @override
  Widget build(BuildContext context) {
    final rect = geo.fromDesign(box);
    final t = time;
    final lift = t == null
        ? 0.0
        : bobPx * (0.5 - 0.5 * math.cos(2 * math.pi * t / bobSeconds));
    return Positioned.fromRect(
      rect: rect.shift(Offset(0, -lift * geo.artScale)),
      child: IgnorePointer(child: LaneMarkerView(size: rect.size, time: null)),
    );
  }
}

/// Tanda "!" di atas kepala Oyen saat menyadari ekor (`AdeganTengah`
/// `seru`): kiri = tengah kucing − 12, atas = atas kotak kucing − 22 (px
/// desain), memantul `atSeru` (naik 3 px dan membesar 1,06 dalam 0,9 detik).
class SeruMark extends StatelessWidget {
  const SeruMark({super.key, required this.cat, required this.unit, this.time});

  /// Kotak sprite Oyen di layar.
  final Rect cat;
  final double unit;
  final double? time;

  static const size = Size(24, 30);
  static const seconds = 0.9;

  @override
  Widget build(BuildContext context) {
    final t = time;
    final k = t == null
        ? 0.0
        : 0.5 - 0.5 * math.cos(2 * math.pi * (t % seconds) / seconds);
    return Positioned(
      left: cat.center.dx - 12 * unit,
      top: cat.top - 22 * unit,
      width: size.width * unit,
      height: size.height * unit,
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(0, -3 * unit * k),
          child: Transform.scale(
            scale: 1 + 0.06 * k,
            alignment: Alignment.bottomCenter,
            child: SeruView(size: size * unit),
          ),
        ),
      ),
    );
  }
}

/// Memotong kucing yang lewat pintu kucing di garis dinding [clipX] (px
/// layar, koordinat induk): bagian di kiri garis sudah di luar rumah.
class FlapClipper extends CustomClipper<Rect> {
  const FlapClipper(this.left);

  /// Garis potong di koordinat lokal kotak kucing.
  final double left;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    math.max(0, left),
    -size.height,
    size.width * 2,
    size.height * 2,
  );

  @override
  bool shouldReclip(FlapClipper old) => old.left != left;
}

/// Pintu depan ke Gang Depan: kotak ketuk tak terlihat
/// ([RoomGeometry.frontDoorTap]), tombol untuk pembaca layar.
class FrontDoorButton extends StatelessWidget {
  const FrontDoorButton({
    super.key,
    required this.geo,
    required this.label,
    required this.onTap,
  });

  final RoomGeometry geo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
    rect: geo.frontDoorTap,
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
    ),
  );
}
