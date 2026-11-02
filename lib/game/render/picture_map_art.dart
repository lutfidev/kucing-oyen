import 'dart:ui';

import '../sim/level.dart';
import 'design_svg_home.dart';
import 'svg_template.dart';

/// Letak dan ukuran peta bergambar (desain 23, `PetaBergambar.dc.html`,
/// `TitikLevel.dc.html`, `TokenOyenPeta.dc.html`) di koordinat layar desain
/// 390×844.
abstract final class PictureMapArt {
  /// Tengah node level 1–9 dan bos (titik terakhir), sama untuk kedua
  /// babak (`pts`).
  static const points = [
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
  ];

  /// Peta yang digulir mulai di y 140 layar desain (awal pudar judul).
  static const double mapTop = 140;

  /// Ruang kosong di atas peta supaya token di level 2 dan 12 tidak
  /// tertutup pudar judul saat gulir paling atas.
  static const double topPad = 56;

  /// Benda node per level, urut daftar `D1`/`D2` desain.
  static const objects = [
    'kulkas',
    'kompor',
    'rakPiring',
    'tudungSaji',
    'penanakNasi',
    'wastafel',
    'cobek',
    'galon',
    'kalengKerupuk',
    'pestaIkanAsin',
    'sofa',
    'mejaTamu',
    'rakTV',
    'potBunga',
    'lampu',
    'kipas',
    'jamDinding',
    'rakBuku',
    'toplesKue',
    'ketupat',
  ];

  /// Benda gambar node [level].
  static String objectOf(Level level) =>
      objects[(level.id - 1) % objects.length];

  /// Dua jejak kaki di antara dua node: letak di garis (0–1), geser ke
  /// samping, dan kejelasan sebelum dan sesudah level saat ini.
  static const pawSteps = [0.38, 0.62];
  static const double pawSide = 5;
  static const double pawSize = 18;
  static const double pawOpacity = 0.95;
  static const double pawDimOpacity = 0.35;

  /// Token Oyen: kotak 64×76, sprite 56 px di (4, 12), kiri atasnya di
  /// titik node + [tokenOffset].
  static const tokenSize = Size(64, 76);
  static const double tokenSprite = 56;
  static const tokenSpriteAt = Offset(4, 12);
  static const tokenOffset = Offset(18, -92);

  /// Layar kecil (`n360`): jalur dirapatkan 12%.
  static const double compactRowFactor = 0.88;

  /// Titik node; di layar kecil jarak vertikal dari titik pertama
  /// dirapatkan.
  static List<Offset> pointsFor({required bool compact}) => compact
      ? [
          for (final p in points)
            Offset(
              p.dx,
              points.first.dy + (p.dy - points.first.dy) * compactRowFactor,
            ),
        ]
      : points;

  /// Titik kontrol bezier segmen [i] → [i]+1 (rumus `roadD` desain).
  static (Offset, Offset) _controls(List<Offset> pts, int i) {
    final p0 = i > 0 ? pts[i - 1] : pts[i];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
    return (p1 + (p2 - p0) / 6, p2 - (p3 - p1) / 6);
  }

  /// Atribut `d` jalur, sama dengan `roadD` desain.
  static String roadD(List<Offset> pts) {
    String n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';
    String f(double v) => v.toStringAsFixed(1);
    final d = StringBuffer('M${n(pts[0].dx)} ${n(pts[0].dy)}');
    for (var i = 0; i + 1 < pts.length; i++) {
      final (c1, c2) = _controls(pts, i);
      d.write(
        ' C${f(c1.dx)} ${f(c1.dy)} ${f(c2.dx)} ${f(c2.dy)} '
        '${n(pts[i + 1].dx)} ${n(pts[i + 1].dy)}',
      );
    }
    return d.toString();
  }

  /// Titik di jalur segmen [segment] (dari node [segment] ke berikutnya)
  /// pada [t] 0–1.
  static Offset onRoad(List<Offset> pts, int segment, double t) {
    final (c1, c2) = _controls(pts, segment);
    final p0 = pts[segment];
    final p3 = pts[segment + 1];
    if (t <= 0) return p0;
    if (t >= 1) return p3;
    final u = 1 - t;
    return p0 * (u * u * u) +
        c1 * (3 * u * u * t) +
        c2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }
}

final _map = SvgTemplate(pictureMapSvg);
final _paw = SvgTemplate(mapPawSvg).render(const {});
final _icon = SvgTemplate(mapNodeIconSvg);
final _icons = <String, SvgDrawing>{};
final _tokenBase = SvgTemplate(mapTokenBaseSvg).render(const {});

/// Dekor ruangan babak [chapter] (1 dapur, selain itu ruang tamu), area
/// bos, dan jalur lewat [points], di koordinat layar desain.
void paintPictureMap(
  Canvas canvas, {
  required int chapter,
  required List<Offset> points,
}) => _map
    .render({
      'isDapur': chapter == 1,
      'isTamu': chapter != 1,
      'roadD': PictureMapArt.roadD(points),
    })
    .paint(canvas);

/// Satu jejak kaki dengan tengah di (0, 0), ukuran desain 18.
void paintMapPaw(Canvas canvas) {
  // viewBox -10 -12 20 20 di kotak 18: tengah kotak = (0, -2).
  const scale = PictureMapArt.pawSize / 20;
  canvas
    ..save()
    ..scale(scale)
    ..translate(0, 2);
  _paw.paint(canvas);
  canvas.restore();
}

/// Benda node [object] di kotak [size] × [size] (viewBox 48).
void paintNodeIcon(Canvas canvas, String object, {required double size}) {
  final drawing = _icons.putIfAbsent(
    object,
    () => _icon.render({
      'b': {for (final key in PictureMapArt.objects) key: key == object},
    }),
  );
  canvas
    ..save()
    ..scale(size / 48);
  drawing.paint(canvas);
  canvas.restore();
}

/// Alas token Oyen di kotak 64×76.
void paintTokenBase(Canvas canvas) => _tokenBase.paint(canvas);
