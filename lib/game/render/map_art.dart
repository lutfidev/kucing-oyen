import 'dart:math' as math;
import 'dart:ui';

import 'design_svg.dart';
import 'svg_template.dart';

/// Letak dan gerak gambar Beranda (`01-beranda.html`) dan peta babak
/// (`02-peta-babak-2-ruang-tamu.html`), di koordinat layar desain 390×844.
abstract final class MapArt {
  /// Layar desain.
  static const screen = Size(390, 844);

  // ── Beranda ───────────────────────────────────────────────────────────

  /// Kotak-kotak latar: satu pola 2×2 (`background-size: 64px`).
  static const double checkerPattern = 64;

  // ── Peta babak ────────────────────────────────────────────────────────

  /// Tengah node level 1–9 dan kotak bos (titik terakhir), sama untuk
  /// semua babak.
  static const points = [
    Offset(80, 240),
    Offset(186, 222),
    Offset(298, 258),
    Offset(304, 352),
    Offset(198, 376),
    Offset(88, 406),
    Offset(88, 506),
    Offset(192, 530),
    Offset(300, 562),
    Offset(200, 690),
  ];

  /// Peta yang bisa digulir mulai di y 140, tempat pudar latar judul
  /// mulai (`linear-gradient(#FFF4E2 76%, ...)` setinggi 184).
  static const double mapTop = 140;
  static const double headerFade = 184 - mapTop;

  /// Dua jejak kaki di antara dua node: letak di garis (0–1) dan geser ke
  /// samping garis. Jejak sesudah node yang sudah selesai lebih jelas.
  static const pawSteps = [0.36, 0.64];
  static const double pawSide = 5;
  static const double pawSize = 18;
  static const double pawOpacity = 0.95;
  static const double pawDimOpacity = 0.4;

  /// Lebar kotak tempat node, label bos, dan bintangnya di tengah: label
  /// boleh lebih lebar dari node (teks besar), tapi tetap di dalam layar.
  static const double nodeSlot = 300;

  /// Label "Main" di atas node level saat ini.
  static const double labelAbove = 30;

  /// Cincin node level saat ini membesar 1 → 1,45 sambil memudar 0,9 → 0
  /// tiap 1,4 detik (`koPulse`, `ease-out`).
  static const double pulseScale = 1.45;
  static const double pulseOpacity = 0.9;
  static const pulseTime = Duration(milliseconds: 1400);

  /// Tebal garis bintang di bawah node dan di kartu babak (viewBox 24).
  static const double starStroke = 1.6;

  /// viewBox ikon babak di kartu babak dan gambar bos.
  static const double chapterIconViewBox = 36;
  static const double bossArtViewBox = 64;

  /// Kotak bos terkunci memudar; badge gembok keluar 10 px dari sudut kanan
  /// atas; label nama bos 10 px di bawah kotak.
  static const double bossLockedOpacity = 0.8;
  static const double bossBadgeOut = 10;
  static const double bossLabelGap = 10;

  /// Arah jejak kaki dari node [from] ke [to] (derajat searah jarum jam,
  /// 0 = ke atas), seperti `rotate()` di desain.
  static double pawAngle(Offset from, Offset to) {
    final d = to - from;
    return math.atan2(d.dy, d.dx) * 180 / math.pi + 90;
  }

  /// Tengah dua jejak kaki di antara [from] dan [to].
  static List<Offset> pawsBetween(Offset from, Offset to) {
    final d = to - from;
    final normal = Offset(-d.dy, d.dx) / (d.distance == 0 ? 1 : d.distance);
    return [
      for (final (k, t) in pawSteps.indexed)
        from + d * t + normal * (k == 0 ? pawSide : -pawSide),
    ];
  }
}

final _pawsBottom = SvgTemplate(homePawsBottomSvg).render(const {});
final _pawsTop = SvgTemplate(homePawsTopSvg).render(const {});
final _kitchen = SvgTemplate(chapterKitchenSvg).render(const {});
final _livingRoom = SvgTemplate(chapterLivingRoomSvg).render(const {});
final _bossArea = SvgTemplate(bossAreaSvg).render(const {});
final _ketupat = SvgTemplate(bossKetupatSvg).render(const {});
final _fish = SvgTemplate(bossFishSvg).render(const {});

/// Jejak kaki latar Beranda di layar [size]: dua jejak bawah menempel ke
/// sudut kiri bawah, dua jejak atas ke sudut kanan atas, seperti di layar
/// desain.
void paintHomePaws(Canvas canvas, Size size) {
  canvas
    ..save()
    ..translate(0, size.height - MapArt.screen.height);
  _pawsBottom.paint(canvas);
  canvas
    ..restore()
    ..save()
    ..translate(size.width - MapArt.screen.width, 0);
  _pawsTop.paint(canvas);
  canvas.restore();
}

/// Ikon babak [chapter] di kotak 36×36: dapur untuk Babak 1, ruang tamu
/// untuk babak lain.
void paintChapterIcon(Canvas canvas, int chapter) =>
    (chapter == 1 ? _kitchen : _livingRoom).paint(canvas);

/// Gambar bos babak [chapter] di kotak 64×64: ikan asin untuk Babak 1,
/// ketupat untuk babak lain.
void paintBossArt(Canvas canvas, int chapter) =>
    (chapter == 1 ? _fish : _ketupat).paint(canvas);

/// Area bos di koordinat layar desain.
void paintBossArea(Canvas canvas) => _bossArea.paint(canvas);
