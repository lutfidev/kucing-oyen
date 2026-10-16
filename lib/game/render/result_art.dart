import 'dart:math' as math;
import 'dart:ui';

import 'design_svg.dart';
import 'svg_template.dart';

/// Ukuran dan gerak ilustrasi layar hasil (`06-hasil-berhasil.html`,
/// `07-hasil-vas-pecah.html`, `08-gagal-oyen-bosan.html`), di koordinat
/// desain.
abstract final class ResultArt {
  // ── Berhasil ──────────────────────────────────────────────────────────

  /// Kartu ilustrasi dengan lantai kotak-kotak (satu pola 2×2 = 58 px).
  static const successCard = Size(290, 196);
  static const double successPattern = 58;

  /// Oyen makan dan mangkuknya di dalam kartu.
  static const successOyen = Rect.fromLTWH(70, 6, 150, 150);
  static const successBowl = Rect.fromLTWH(75, 134, 140, 54);

  /// Sinar di belakang layar: jari-jari 310, opasitas 0,55, satu putaran
  /// 40 detik (`koSpin`). Pusatnya 50 px di bawah deret bintang (desain:
  /// pusat sinar di y 290, deret bintang berakhir di y 240).
  static const double raysRadius = 310;
  static const double raysOpacity = 0.55;
  static const raysTurn = Duration(seconds: 40);
  static const double raysBelowStars = 50;

  // ── Vas pecah ─────────────────────────────────────────────────────────

  /// Kartu ilustrasi (lantai kotak-kotak 60 px); gambarnya 358×300 dan
  /// terpotong di bawah.
  static const vaseCard = Size(358, 280);
  static const double vasePattern = 60;

  /// Oyen makan dan mangkuknya (viewBox mangkuk diperkecil ke kotak ini).
  static const vaseOyen = Rect.fromLTWH(130, 126, 120, 120);
  static const vaseBowl = Rect.fromLTWH(132, 232, 116, 46);

  /// Ibu masuk dari kanan 30 px dalam 0,6 detik (`koPeek`, `ease-out`).
  static const double momPeek = 30;
  static const momPeekTime = Duration(milliseconds: 600);

  /// "PRANG!" di `translate(60 76)`, bergoyang -4° → 4° → -4° tiap 0,5
  /// detik (`koShake`, `ease-in-out`) di tengah kotak gambarnya.
  static const prangAt = Offset(60, 76);
  static const double prangSwing = 4;
  static const prangSwingTime = Duration(milliseconds: 500);

  // ── Gagal ─────────────────────────────────────────────────────────────

  /// Oyen tidur di kotak kartu pesan.
  static const double restOyen = 50;

  /// viewBox mangkuk di layar Berhasil dan vas pecah.
  static const bowlViewBox = Size(140, 54);
}

final _rays = SvgTemplate(raysSvg).render(const {});
final _successBowl = SvgTemplate(successBowlSvg).render(const {});
final _vaseBowl = SvgTemplate(vaseBowlSvg).render(const {});
final _vaseRoom = SvgTemplate(vaseRoomSvg).render(const {});
final _vaseMom = SvgTemplate(vaseMomSvg).render(const {});
final _vaseTable = SvgTemplate(vaseTableSvg).render(const {});
final _vasePrang = SvgTemplate(vasePrangSvg).render(const {});

/// Sinar layar Berhasil berpusat di (0, 0), diputar [turns] putaran.
void paintRays(Canvas canvas, {double turns = 0}) {
  const r = ResultArt.raysRadius;
  canvas
    ..save()
    ..rotate(turns * 2 * math.pi)
    ..saveLayer(
      Rect.fromCircle(center: Offset.zero, radius: r),
      Paint()..color = Color.fromRGBO(0, 0, 0, ResultArt.raysOpacity),
    );
  _rays.paint(canvas);
  canvas
    ..restore()
    ..restore();
}

/// Mangkuk layar Berhasil di kotak [ResultArt.bowlViewBox].
void paintSuccessBowl(Canvas canvas) => _successBowl.paint(canvas);

/// Mangkuk layar vas pecah di kotak [ResultArt.bowlViewBox].
void paintVaseBowl(Canvas canvas) => _vaseBowl.paint(canvas);

/// Ilustrasi vas pecah di kotak 358×300 (tanpa Oyen dan mangkuk): Ibu
/// digeser [momShift] ke kanan dan "PRANG!" diputar [prangAngle] derajat.
void paintVaseScene(
  Canvas canvas, {
  double momShift = 0,
  double prangAngle = 0,
}) {
  _vaseRoom.paint(canvas);
  canvas
    ..save()
    ..translate(momShift, 0);
  _vaseMom.paint(canvas);
  canvas.restore();
  _vaseTable.paint(canvas);
  final pivot = _vasePrang.bounds.center;
  canvas
    ..save()
    ..translate(
      ResultArt.prangAt.dx + pivot.dx,
      ResultArt.prangAt.dy + pivot.dy,
    )
    ..rotate(prangAngle * math.pi / 180)
    ..translate(-pivot.dx, -pivot.dy);
  _vasePrang.paint(canvas);
  canvas.restore();
}
