import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

/// Cara menggambar satu bentuk ikon.
enum KoIconPaint { stroke, fill, fillAndStroke }

/// Satu bentuk di ikon: path SVG, lingkaran, elips, atau persegi bersudut
/// bulat. Semuanya memakai warna ikon (`currentColor` di desain).
@immutable
class KoIconShape {
  const KoIconShape.path(String this.d, {this.paint = KoIconPaint.stroke})
    : center = null,
      rect = null,
      radius = 0,
      radiusY = null;

  const KoIconShape.circle(
    Offset this.center,
    this.radius, {
    this.paint = KoIconPaint.stroke,
  }) : d = null,
       rect = null,
       radiusY = null;

  const KoIconShape.rrect(
    Rect this.rect,
    this.radius, {
    this.paint = KoIconPaint.stroke,
  }) : d = null,
       center = null,
       radiusY = null;

  /// Elips (`<ellipse>` di SVG): [radius] mendatar, [radiusY] tegak.
  const KoIconShape.ellipse(
    Offset this.center,
    this.radius,
    double this.radiusY, {
    this.paint = KoIconPaint.stroke,
  }) : d = null,
       rect = null;

  final String? d;
  final Offset? center;
  final Rect? rect;

  /// Jari-jari lingkaran, jari-jari mendatar elips, atau sudut persegi.
  final double radius;
  final KoIconPaint paint;

  /// Jari-jari tegak elips; null untuk bentuk lain.
  final double? radiusY;

  static final _cache = <String, Path>{};

  Path toPath() {
    if (d != null) return _cache.putIfAbsent(d!, () => parseSvgPathData(d!));
    if (center != null) {
      return Path()..addOval(
        Rect.fromCenter(
          center: center!,
          width: 2 * radius,
          height: 2 * (radiusY ?? radius),
        ),
      );
    }
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect!, Radius.circular(radius)));
  }
}

/// Definisi ikon: bentuk-bentuk, tebal garisnya, dan viewBox (umumnya
/// 0 0 24 24).
@immutable
class KoIconData {
  const KoIconData(
    this.shapes, {
    required this.strokeWidth,
    this.viewBox = standardViewBox,
  });

  final List<KoIconShape> shapes;
  final double strokeWidth;

  /// Kotak koordinat yang digambar memenuhi ukuran ikon (persegi).
  final Rect viewBox;

  static const standardViewBox = Rect.fromLTWH(0, 0, 24, 24);
}

/// Ikon garis dari layar desain, path disalin apa adanya dari SVG.
abstract final class KoIcons {
  /// Kembali (bar atas).
  static const back = KoIconData([
    KoIconShape.path('M15 5 8 12l7 7'),
  ], strokeWidth: 2.6);

  /// Petunjuk (lampu).
  static const hint = KoIconData([
    KoIconShape.path('M9 18h6M10 21h4'),
    KoIconShape.path(
      'M12 3a6 6 0 0 0-3.6 10.8c.7.5 1.1 1.3 1.1 2.2h5c0-.9.4-1.7 1.1-2.2A6 6 0 0 0 12 3z',
    ),
  ], strokeWidth: 2.2);

  /// Tonton iklan (layar dengan tombol main), desain 10.
  static const ad = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(3, 5, 18, 14), 3),
    KoIconShape.path('M10 9v6l5-3z', paint: KoIconPaint.fillAndStroke),
  ], strokeWidth: 2.4);

  /// Aturan (buku).
  static const rules = KoIconData([
    KoIconShape.path(
      'M4 5.5A2.5 2.5 0 0 1 6.5 3H20v15H6.5A2.5 2.5 0 0 0 4 20.5z',
    ),
    KoIconShape.path('M4 20.5A2.5 2.5 0 0 0 6.5 23H20v-5'),
    KoIconShape.path('M9 8h7M9 12h5'),
  ], strokeWidth: 2.2);

  /// Bangunkan Oyen (matahari).
  static const wake = KoIconData([
    KoIconShape.circle(Offset(12, 12), 4),
    KoIconShape.path(
      'M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
    ),
  ], strokeWidth: 2.4);

  /// Kosongkan papan.
  static const reset = KoIconData([
    KoIconShape.path('M3 12a9 9 0 1 0 3-6.7L3 8'),
    KoIconShape.path('M3 3v5h5'),
  ], strokeWidth: 2.4);

  /// Tutup sheet.
  static const close = KoIconData([
    KoIconShape.path('M6 6l12 12M18 6 6 18'),
  ], strokeWidth: 2.8);

  /// Main (segitiga penuh).
  static const play = KoIconData([
    KoIconShape.path('M7 4.5v15l12.5-7.5z', paint: KoIconPaint.fillAndStroke),
  ], strokeWidth: 2);

  /// Lanjutkan fase jalan (segitiga penuh, garis lebih tipis dari [play]).
  static const resume = KoIconData([
    KoIconShape.path('M7 4.5v15l12.5-7.5z', paint: KoIconPaint.fillAndStroke),
  ], strokeWidth: 1.5);

  /// Jeda fase jalan (dua batang).
  static const pause = KoIconData([
    KoIconShape.rrect(
      Rect.fromLTWH(6, 4.5, 4.2, 15),
      1.4,
      paint: KoIconPaint.fill,
    ),
    KoIconShape.rrect(
      Rect.fromLTWH(13.8, 4.5, 4.2, 15),
      1.4,
      paint: KoIconPaint.fill,
    ),
  ], strokeWidth: 0);

  /// Maju satu langkah.
  static const stepForward = KoIconData([
    KoIconShape.path('M6 5l9 7-9 7z', paint: KoIconPaint.fillAndStroke),
    KoIconShape.path('M19 5v14'),
  ], strokeWidth: 2.4);

  /// Mundur satu langkah (putar ulang, desain 09).
  static const stepBack = KoIconData([
    KoIconShape.path('M18 5l-9 7 9 7z', paint: KoIconPaint.fillAndStroke),
    KoIconShape.path('M5 5v14'),
  ], strokeWidth: 2.4);

  /// Level terkunci (gembok).
  static const lock = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(5, 11, 14, 10), 2.5),
    KoIconShape.path('M8 11V8a4 4 0 0 1 8 0v3'),
  ], strokeWidth: 2.4);

  /// Badge gembok kotak bos di peta: [lock] dengan garis lebih tebal.
  static const lockBold = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(5, 11, 14, 10), 2.5),
    KoIconShape.path('M8 11V8a4 4 0 0 1 8 0v3'),
  ], strokeWidth: 2.6);

  /// Pengaturan (penggeser).
  static const settings = KoIconData([
    KoIconShape.path('M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M20 18h0'),
    KoIconShape.circle(Offset(16, 6), 2),
    KoIconShape.circle(Offset(10, 12), 2),
    KoIconShape.circle(Offset(18, 18), 2),
  ], strokeWidth: 2.2);

  /// Ulangi di layar Berhasil: [reset] dengan garis lebih tebal.
  static const restart = KoIconData([
    KoIconShape.path('M3 12a9 9 0 1 0 3-6.7L3 8'),
    KoIconShape.path('M3 3v5h5'),
  ], strokeWidth: 2.6);

  /// Coba Lagi di layar vas pecah: [reset] dengan garis paling tebal.
  static const retry = KoIconData([
    KoIconShape.path('M3 12a9 9 0 1 0 3-6.7L3 8'),
    KoIconShape.path('M3 3v5h5'),
  ], strokeWidth: 2.8);

  /// Lanjut (panah kanan, di kanan label).
  static const next = KoIconData([
    KoIconShape.path('M9 5l7 7-7 7'),
  ], strokeWidth: 2.8);

  /// Putar Ulang (lingkaran dan segitiga putar).
  static const replay = KoIconData([
    KoIconShape.circle(Offset(12, 12), 9),
    KoIconShape.path('M10 8.5v7l5.5-3.5z', paint: KoIconPaint.fillAndStroke),
  ], strokeWidth: 2.6);

  /// Atur Lagi (pensil).
  static const edit = KoIconData([
    KoIconShape.path('M12 20h9'),
    KoIconShape.path('M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z'),
  ], strokeWidth: 2.6);

  /// Oyen muter terus (panah melingkar searah jarum jam).
  static const loop = KoIconData([
    KoIconShape.path('M21 12a9 9 0 1 1-3-6.7L21 8'),
    KoIconShape.path('M21 3v5h-5'),
  ], strokeWidth: 2.6);

  /// Jumlah langkah (jejak kaki, viewBox -10 -12 20 20).
  static const steps = KoIconData(
    [
      KoIconShape.ellipse(Offset(0, 3), 5, 4.3, paint: KoIconPaint.fill),
      KoIconShape.circle(Offset(-5.2, -3.6), 2, paint: KoIconPaint.fill),
      KoIconShape.circle(Offset(-1.8, -6.6), 2, paint: KoIconPaint.fill),
      KoIconShape.circle(Offset(1.8, -6.6), 2, paint: KoIconPaint.fill),
      KoIconShape.circle(Offset(5.2, -3.6), 2, paint: KoIconPaint.fill),
    ],
    strokeWidth: 0,
    viewBox: Rect.fromLTWH(-10, -12, 20, 20),
  );

  /// Jumlah benda dipakai (kardus terbuka).
  static const items = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(4, 7, 16, 13), 2),
    KoIconShape.path('M4 7l3-3h10l3 3M10 11h4'),
  ], strokeWidth: 2.4);

  /// Syarat bintang tercapai (centang).
  static const check = KoIconData([
    KoIconShape.path('M5 12.5l4.5 4.5L19 7.5'),
  ], strokeWidth: 3.4);

  /// Babak selesai di kartu babak: [check] dengan garis lebih tebal.
  static const checkBold = KoIconData([
    KoIconShape.path('M5 12.5l4.5 4.5L19 7.5'),
  ], strokeWidth: 3.6);

  /// Tambah koin ("+" di chip koin). Tidak ada di desain; garis seperti
  /// [checkBold].
  static const plus = KoIconData([
    KoIconShape.path('M12 5v14M5 12h14'),
  ], strokeWidth: 3.6);

  /// Bonus harian (kado) di sheet Tambah Koin. Tidak ada di desain; gaya
  /// garis seperti [ad].
  static const gift = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(4, 11, 16, 9), 2),
    KoIconShape.rrect(Rect.fromLTWH(3, 7.5, 18, 3.5), 1.5),
    KoIconShape.path('M12 7.5V20'),
    KoIconShape.path(
      'M12 7.5C10.5 4.5 7 4 7 6.2c0 1.3 2.5 1.3 5 1.3zM12 7.5c1.5-3 5-3.5 5-1.3 0 1.3-2.5 1.3-5 1.3z',
    ),
  ], strokeWidth: 2.2);

  /// Panah →, ↻, dan ↺ di teks kartu aturan. Tidak ada di desain sebagai
  /// ikon (desain menulis karakternya), tapi font Fredoka dan Nunito yang
  /// dibundel tidak punya glyph itu.
  static const arrowRight = KoIconData([
    KoIconShape.path('M4 12h15M13 6l6 6-6 6'),
  ], strokeWidth: 2.6);

  static const turnClockwise = KoIconData([
    KoIconShape.path('M15.5 5.94A7 7 0 1 1 8.5 5.94'),
    KoIconShape.path('M6.54 10.54 8.5 5.94 3.54 5.34'),
  ], strokeWidth: 2.6);

  static const turnCounterClockwise = KoIconData([
    KoIconShape.path('M8.5 5.94A7 7 0 1 0 15.5 5.94'),
    KoIconShape.path('M17.46 10.54 15.5 5.94 20.46 5.34'),
  ], strokeWidth: 2.6);

  /// Tab Toko (desain 20, `TabToko.dc.html`): barang, kucing, aksesoris,
  /// dan makanan.
  static const shop = KoIconData([
    KoIconShape.path('M5 11V8a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v3'),
    KoIconShape.path('M3 13a2 2 0 0 1 4 0v2h10v-2a2 2 0 0 1 4 0v5H3z'),
    KoIconShape.path('M6 18v2M18 18v2'),
  ], strokeWidth: 2.2);

  static const kitty = KoIconData([
    KoIconShape.path(
      'M5 9 4.5 3.5 9 6.5h6l4.5-3L19 9c1.3 1.4 2 3 2 4.8C21 17.8 17 20.5 12 '
      '20.5S3 17.8 3 13.8C3 12 3.7 10.4 5 9z',
    ),
    KoIconShape.path('M9 13h.01M15 13h.01M11 16.2l1 .8 1-.8'),
  ], strokeWidth: 2.2);

  static const accessory = KoIconData([
    KoIconShape.path('M12 12 4 7v10z'),
    KoIconShape.path('M12 12l8-5v10z'),
    KoIconShape.circle(Offset(12, 12), 2.2),
  ], strokeWidth: 2.2);

  static const snack = KoIconData([
    KoIconShape.path('M3 12c3-5 9-6 14-2l4-3v10l-4-3c-5 4-11 3-14-2z'),
    KoIconShape.circle(Offset(8, 11), 0.8),
  ], strokeWidth: 2.2);

  /// "Lihat di kamar" di sheet beli dan badge "Tinggal di kamar"
  /// (desain 20).
  static const house = KoIconData([
    KoIconShape.path('M4 11 12 4l8 7v9H4z'),
    KoIconShape.path('M10 20v-5h4v5'),
  ], strokeWidth: 2.4);

  /// Catatan "milikmu selamanya" di sheet beli aksesoris (desain 20).
  static const shield = KoIconData([
    KoIconShape.path('M12 3 4 7v5c0 5 3.4 8 8 9 4.6-1 8-4 8-9V7z'),
    KoIconShape.path('M8.5 12l2.5 2.5 4.5-5'),
  ], strokeWidth: 2.4);

  /// Toko di panel bawah kamar (etalase, `Kamar.dc.html`).
  static const store = KoIconData([
    KoIconShape.path('M4 9.5 5.5 4h13L20 9.5'),
    KoIconShape.path(
      'M4 9.5a2.7 2.7 0 0 0 5.3 0 2.7 2.7 0 0 0 5.4 0 2.7 2.7 0 0 0 5.3 0',
    ),
    KoIconShape.path('M5.5 12v8h13v-8M10 20v-4.5h4V20'),
  ], strokeWidth: 2.2);

  /// Tombol Hias (rol cat, `TombolHias.dc.html`).
  static const decorate = KoIconData([
    KoIconShape.rrect(Rect.fromLTWH(3, 3, 15, 6), 2),
    KoIconShape.path('M18 6h2a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-8v3'),
    KoIconShape.rrect(Rect.fromLTWH(10, 14, 4, 7), 1),
  ], strokeWidth: 2.2);

  /// Baki Gudang (kotak, `BakiGudang.dc.html`).
  static const storage = KoIconData([
    KoIconShape.path('M3 8l9-4 9 4v9l-9 4-9-4z'),
    KoIconShape.path('M3 8l9 4 9-4M12 12v9'),
  ], strokeWidth: 2.2);

  /// Elus di kartu kucing (`Kamar.dc.html`).
  static const heart = KoIconData([
    KoIconShape.path(
      'M12 20s-7-4.4-7-9.6A4 4 0 0 1 12 8a4 4 0 0 1 7 2.4C19 15.6 12 20 12 20z',
    ),
  ], strokeWidth: 2.4);

  /// Hati yang melayang sesudah dielus (terisi, `Kamar.dc.html`).
  static const heartFill = KoIconData([
    KoIconShape.path(
      'M12 21s-8-5-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 10c0 6-8 11-8 11z',
      paint: KoIconPaint.fill,
    ),
  ], strokeWidth: 0);

  /// Chip "Seret barang ke tempat baru" (panah empat arah, `Kamar.dc.html`).
  static const move = KoIconData([
    KoIconShape.path(
      'M12 3v18M3 12h18M12 3l-3 3M12 3l3 3M12 21l-3-3M12 21l3-3M3 12l3-3'
      'M3 12l3 3M21 12l-3-3M21 12l-3 3',
    ),
  ], strokeWidth: 2.4);

  /// Gagang seret di pojok barang saat menghias (enam titik).
  static const grip = KoIconData([
    KoIconShape.circle(Offset(8, 6), 2.4, paint: KoIconPaint.fill),
    KoIconShape.circle(Offset(16, 6), 2.4, paint: KoIconPaint.fill),
    KoIconShape.circle(Offset(8, 12), 2.4, paint: KoIconPaint.fill),
    KoIconShape.circle(Offset(16, 12), 2.4, paint: KoIconPaint.fill),
    KoIconShape.circle(Offset(8, 18), 2.4, paint: KoIconPaint.fill),
    KoIconShape.circle(Offset(16, 18), 2.4, paint: KoIconPaint.fill),
  ], strokeWidth: 0);

  /// Jam: label "Terisi lagi" di atas mangkuk kosong (`Kamar.dc.html`).
  static const clock = KoIconData([
    KoIconShape.circle(Offset(12, 12), 9),
    KoIconShape.path('M12 7v5l3 2'),
  ], strokeWidth: 2.6);
}

/// Menggambar [KoIconData] seukuran [size] dengan warna [color]. Hiasan
/// saja: label untuk pembaca layar dipasang oleh tombolnya.
class KoIcon extends StatelessWidget {
  const KoIcon(this.icon, {super.key, required this.size, required this.color});

  final KoIconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _KoIconPainter(icon, color),
      ),
    );
  }
}

class _KoIconPainter extends CustomPainter {
  _KoIconPainter(this.icon, this.color);

  final KoIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final box = icon.viewBox;
    canvas
      ..scale(size.width / box.width)
      ..translate(-box.left, -box.top);
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = icon.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final shape in icon.shapes) {
      final path = shape.toPath();
      if (shape.paint != KoIconPaint.stroke) canvas.drawPath(path, fill);
      if (shape.paint != KoIconPaint.fill) canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_KoIconPainter old) =>
      old.icon != icon || old.color != color;
}
