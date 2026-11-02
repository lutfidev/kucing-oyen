import 'dart:math' as math;
import 'dart:ui';

import 'design_svg.dart';
import 'picture_map_art.dart';
import 'svg_template.dart';

/// Letak dan gerak bagian peta babak yang tidak berubah sejak desain 02
/// (judul, label "Main", denyut, bintang, ikon kartu babak). Gambar peta
/// bergambar desain 23 ada di [PictureMapArt].
abstract final class MapArt {
  // ── Peta babak ────────────────────────────────────────────────────────

  /// Pudar latar judul (`linear-gradient(#FFF4E2 76%, ...)` setinggi
  /// 184) mulai di y 140 layar desain, tempat peta yang digulir mulai.
  static const double headerFade = 184 - 140;

  /// Lebar kotak tempat node, label bos, dan bintangnya di tengah: label
  /// boleh lebih lebar dari node (teks besar), tapi tetap di dalam layar.
  static const double nodeSlot = 300;

  /// Label "Main" di atas node level saat ini.
  static const double labelAbove = 30;

  /// Cincin node level saat ini memudar 0,9 → 0 tiap 1,4 detik
  /// (`tlvPulse`, `ease-out`); besarnya di [PictureMapArt.pulseScale].
  static const double pulseOpacity = 0.9;
  static const pulseTime = Duration(milliseconds: 1400);

  /// Tebal garis bintang di bawah node dan di kartu babak (viewBox 24).
  static const double starStroke = 1.6;

  /// Arah jejak kaki dari node [from] ke [to] (derajat searah jarum jam,
  /// 0 = ke atas), seperti `rotate()` di desain.
  static double pawAngle(Offset from, Offset to) {
    final d = to - from;
    return math.atan2(d.dy, d.dx) * 180 / math.pi + 90;
  }

  /// viewBox ikon babak di kartu babak.
  static const double chapterIconViewBox = 36;
}

final _kitchen = SvgTemplate(chapterKitchenSvg).render(const {});
final _livingRoom = SvgTemplate(chapterLivingRoomSvg).render(const {});

/// Ikon babak [chapter] di kotak 36×36: dapur untuk Babak 1, ruang tamu
/// untuk babak lain.
void paintChapterIcon(Canvas canvas, int chapter) =>
    (chapter == 1 ? _kitchen : _livingRoom).paint(canvas);
