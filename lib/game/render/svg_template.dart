import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

/// Template SVG dari komponen desain (`docs/design/source/*.dc.html`).
///
/// Isi `<svg>` disalin apa adanya dari desain, termasuk blok
/// `<sc-if value="{{nama}}">` dan atribut `{{nama}}`. [render] mengisi
/// nilai dari port `renderVals()` lalu menghasilkan [SvgDrawing] yang bisa
/// digambar ke `Canvas` mana pun: `CustomPainter` Flutter maupun komponen
/// Flame. String `d` path diurai dengan `parseSvgPathData`.
///
/// Hanya subset yang dipakai desain: elemen `g`, `rect`, `circle`,
/// `ellipse`, `path`, `text`; atribut `fill`, `stroke`, `stroke-width`,
/// `stroke-linecap`, `stroke-linejoin`, `stroke-dasharray`, `opacity`,
/// `fill-opacity`, `transform` (translate, scale, rotate), dan atribut huruf.
/// Elemen lain membuat [render] gagal supaya tidak ada yang hilang diam-diam.
class SvgTemplate {
  SvgTemplate(String source) : _nodes = _parse(source);

  final List<_Element> _nodes;

  /// [vals] berisi nilai `{{nama}}`. Blok `sc-if` tampil kalau nilainya
  /// `true`; nama yang tidak ada dianggap `false`.
  SvgDrawing render(Map<String, Object> vals) {
    final ops = <_Op>[];
    _emit(_nodes, vals, const {}, _Affine.identity, ops);
    return SvgDrawing._(List.unmodifiable(ops));
  }
}

/// Hasil [SvgTemplate.render]: daftar perintah gambar di koordinat viewBox.
class SvgDrawing {
  const SvgDrawing._(this._ops);

  final List<_Op> _ops;

  /// Jumlah bentuk dan teks.
  int get length => _ops.length;

  /// Kotak pembatas semua bentuk dan teks tanpa tebal garis, seperti
  /// `fill-box` CSS (mis. titik putar `transform-origin: center`).
  Rect get bounds =>
      _ops.map((op) => op.bounds).reduce((a, b) => a.expandToInclude(b));

  void paint(Canvas canvas) {
    for (final op in _ops) {
      op.paint(canvas);
    }
  }
}

// ---------------------------------------------------------------------------
// Urai

class _Element {
  _Element(this.name, this.attrs);

  final String name;
  final Map<String, String> attrs;
  final children = <_Element>[];
  String text = '';
}

final _tokenPattern = RegExp(
  r'<(/?)([A-Za-z][\w:-]*)((?:\s+[\w:-]+="[^"]*")*)\s*(/?)>|([^<]+)',
);
final _attrPattern = RegExp(r'([\w:-]+)="([^"]*)"');

List<_Element> _parse(String source) {
  final root = _Element('', const {});
  final stack = [root];
  var index = 0;
  for (final m in _tokenPattern.allMatches(source)) {
    if (m.start != index) {
      throw FormatException('Potongan SVG tidak dikenal', source, index);
    }
    index = m.end;
    final text = m[5];
    if (text != null) {
      stack.last.text += text.trim();
      continue;
    }
    final name = m[2]!;
    if (m[1] == '/') {
      if (stack.length == 1 || stack.last.name != name) {
        throw FormatException('Tag </$name> tidak cocok', source, m.start);
      }
      stack.removeLast();
      continue;
    }
    final element = _Element(name, {
      for (final a in _attrPattern.allMatches(m[3]!)) a[1]!: a[2]!,
    });
    stack.last.children.add(element);
    if (m[4] != '/') stack.add(element);
  }
  if (index != source.length) {
    throw FormatException('Potongan SVG tidak dikenal', source, index);
  }
  if (stack.length != 1) {
    throw FormatException('Tag <${stack.last.name}> tidak ditutup', source);
  }
  return root.children;
}

// ---------------------------------------------------------------------------
// Isi nilai dan susun perintah gambar

/// Atribut yang diwariskan `<g>` ke anaknya.
const _inherited = {
  'fill',
  'fill-opacity',
  'stroke',
  'stroke-width',
  'stroke-linecap',
  'stroke-linejoin',
  'stroke-dasharray',
  'font-family',
  'font-size',
  'font-weight',
  'text-anchor',
};

final _placeholder = RegExp(r'\{\{\s*(\w+)\s*\}\}');

String _resolve(String raw, Map<String, Object> vals) =>
    raw.replaceAllMapped(_placeholder, (m) {
      final value = vals[m[1]];
      if (value == null) throw ArgumentError('Nilai {{${m[1]}}} tidak ada');
      return '$value';
    });

bool _condition(String raw, Map<String, Object> vals) {
  final key = _placeholder.firstMatch(raw)?[1];
  if (key == null) throw FormatException('sc-if tanpa {{nama}}', raw);
  final value = vals[key] ?? false;
  if (value is! bool) throw ArgumentError('{{$key}} harus bool: $value');
  return value;
}

void _emit(
  List<_Element> nodes,
  Map<String, Object> vals,
  Map<String, String> inherited,
  _Affine matrix,
  List<_Op> ops,
) {
  for (final el in nodes) {
    if (el.name == 'sc-if') {
      if (_condition(el.attrs['value'] ?? '', vals)) {
        _emit(el.children, vals, inherited, matrix, ops);
      }
      continue;
    }
    final attrs = {
      ...inherited,
      for (final MapEntry(:key, :value) in el.attrs.entries)
        key: _resolve(value, vals),
    };
    // `transform` tidak diwariskan, jadi selalu milik elemen ini.
    final transform = attrs['transform'];
    final m = transform == null ? matrix : matrix * _parseTransform(transform);
    switch (el.name) {
      case 'g':
        if (el.attrs.containsKey('opacity')) {
          throw UnsupportedError('opacity di <g> belum didukung');
        }
        _emit(
          el.children,
          vals,
          {
            for (final MapEntry(:key, :value) in attrs.entries)
              if (_inherited.contains(key)) key: value,
          },
          m,
          ops,
        );
      case 'text':
        ops.add(_TextOp.from(attrs, el.text, m));
      case 'rect' || 'circle' || 'ellipse' || 'path':
        ops.add(_ShapeOp.from(el.name, attrs, m));
      default:
        throw UnsupportedError('Elemen <${el.name}> belum didukung');
    }
  }
}

double _num(Map<String, String> a, String key, [double fallback = 0]) {
  final v = a[key];
  return v == null ? fallback : double.parse(v);
}

Color? _color(String value) {
  if (value == 'none') return null;
  final hex = value.startsWith('#') ? value.substring(1) : null;
  if (hex != null && hex.length == 6) {
    return Color(0xFF000000 | int.parse(hex, radix: 16));
  }
  if (hex != null && hex.length == 3) {
    final full = hex.split('').map((ch) => '$ch$ch').join();
    return Color(0xFF000000 | int.parse(full, radix: 16));
  }
  throw FormatException('Warna tidak dikenal', value);
}

final _pathCache = <String, Path>{};

Path _geometry(String name, Map<String, String> a) {
  switch (name) {
    case 'path':
      final d = a['d'] ?? '';
      return _pathCache.putIfAbsent(d, () => parseSvgPathData(d));
    case 'circle':
      final r = _num(a, 'r');
      return Path()..addOval(
        Rect.fromCircle(
          center: Offset(_num(a, 'cx'), _num(a, 'cy')),
          radius: r,
        ),
      );
    case 'ellipse':
      return Path()..addOval(
        Rect.fromCenter(
          center: Offset(_num(a, 'cx'), _num(a, 'cy')),
          width: 2 * _num(a, 'rx'),
          height: 2 * _num(a, 'ry'),
        ),
      );
    default:
      final rx = a['rx'] ?? a['ry'];
      final ry = a['ry'] ?? a['rx'];
      return _rectPath(
        _num(a, 'x'),
        _num(a, 'y'),
        _num(a, 'width'),
        _num(a, 'height'),
        rx == null ? 0 : double.parse(rx),
        ry == null ? 0 : double.parse(ry),
      );
  }
}

/// Persegi dengan urutan titik seperti spesifikasi SVG (mulai dari ujung
/// sudut kiri atas, searah jarum jam) supaya garis putus-putusnya sama.
Path _rectPath(double x, double y, double w, double h, double rx, double ry) {
  if (rx <= 0 || ry <= 0) return Path()..addRect(Rect.fromLTWH(x, y, w, h));
  rx = math.min(rx, w / 2);
  ry = math.min(ry, h / 2);
  final r = Radius.elliptical(rx, ry);
  return Path()
    ..moveTo(x + rx, y)
    ..lineTo(x + w - rx, y)
    ..arcToPoint(Offset(x + w, y + ry), radius: r)
    ..lineTo(x + w, y + h - ry)
    ..arcToPoint(Offset(x + w - rx, y + h), radius: r)
    ..lineTo(x + rx, y + h)
    ..arcToPoint(Offset(x, y + h - ry), radius: r)
    ..lineTo(x, y + ry)
    ..arcToPoint(Offset(x + rx, y), radius: r)
    ..close();
}

List<double> _numbers(String s) =>
    s.trim().split(RegExp(r'[\s,]+')).map(double.parse).toList();

// ---------------------------------------------------------------------------
// Perintah gambar

abstract class _Op {
  const _Op(this.matrix);

  /// Null kalau tanpa transformasi.
  final Float64List? matrix;

  void paint(Canvas canvas) {
    final m = matrix;
    if (m == null) return draw(canvas);
    canvas
      ..save()
      ..transform(m);
    draw(canvas);
    canvas.restore();
  }

  void draw(Canvas canvas);

  /// Bentuk yang dibatasi [bounds], sebelum [matrix].
  Path get outline;

  Rect get bounds {
    final m = matrix;
    return m == null ? outline.getBounds() : outline.transform(m).getBounds();
  }
}

class _ShapeOp extends _Op {
  _ShapeOp(
    super.matrix, {
    required this.path,
    required this.fill,
    required this.strokePath,
    required this.stroke,
    required this.layerOpacity,
  });

  factory _ShapeOp.from(String name, Map<String, String> a, _Affine m) {
    final path = _geometry(name, a);
    final opacity = _num(a, 'opacity', 1);
    final fillColor = _color(a['fill'] ?? '#000000');
    final strokeColor = _color(a['stroke'] ?? 'none');
    final strokeWidth = _num(a, 'stroke-width', 1);
    final hasStroke = strokeColor != null && strokeWidth > 0;
    // Satu elemen berisi isian dan garis yang transparan digambar di lapisan
    // sendiri, seperti `opacity` SVG. Sisanya cukup alfa warnanya.
    final layer = opacity < 1 && fillColor != null && hasStroke;
    final alpha = layer ? 1.0 : opacity;

    Paint? fill;
    if (fillColor != null) {
      fill = Paint()
        ..color = fillColor.withValues(
          alpha: fillColor.a * _num(a, 'fill-opacity', 1) * alpha,
        );
    }

    Paint? stroke;
    var strokePath = path;
    if (hasStroke) {
      stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor.withValues(alpha: strokeColor.a * alpha)
        ..strokeCap = switch (a['stroke-linecap']) {
          'round' => StrokeCap.round,
          'square' => StrokeCap.square,
          _ => StrokeCap.butt,
        }
        ..strokeJoin = switch (a['stroke-linejoin']) {
          'round' => StrokeJoin.round,
          'bevel' => StrokeJoin.bevel,
          _ => StrokeJoin.miter,
        };
      final dashes = a['stroke-dasharray'];
      if (dashes != null && dashes != 'none') {
        strokePath = dashPath(
          path,
          dashArray: CircularIntervalList(_numbers(dashes)),
        );
      }
    }

    return _ShapeOp(
      m.storage,
      path: path,
      fill: fill,
      strokePath: strokePath,
      stroke: stroke,
      layerOpacity: layer ? opacity : 1,
    );
  }

  final Path path;
  final Paint? fill;
  final Path strokePath;
  final Paint? stroke;

  /// Di bawah 1: isian dan garis digambar di satu lapisan transparan.
  final double layerOpacity;

  @override
  Path get outline => path;

  @override
  void draw(Canvas canvas) {
    final layer = layerOpacity < 1;
    if (layer) {
      canvas.saveLayer(
        null,
        Paint()..color = Color.fromRGBO(0, 0, 0, layerOpacity),
      );
    }
    if (fill != null) canvas.drawPath(path, fill!);
    if (stroke != null) canvas.drawPath(strokePath, stroke!);
    if (layer) canvas.restore();
  }
}

class _TextOp extends _Op {
  _TextOp(super.matrix, this.paragraph, this.offset);

  /// `x` dan `y` di SVG adalah awal (atau tengah, untuk `text-anchor`
  /// middle) garis dasar huruf.
  factory _TextOp.from(Map<String, String> a, String text, _Affine m) {
    final family = (a['font-family'] ?? '')
        .split(',')
        .first
        .trim()
        .replaceAll(RegExp('[\'"]'), '');
    final weight = FontWeight.values.firstWhere(
      (w) => w.value == int.parse(a['font-weight'] ?? '400'),
    );
    final size = _num(a, 'font-size', 16);
    final color = _color(a['fill'] ?? '#000000') ?? const Color(0x00000000);
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              fontFamily: family,
              fontSize: size,
              fontWeight: weight,
              textDirection: TextDirection.ltr,
            ),
          )
          ..pushStyle(
            TextStyle(
              color: color,
              fontFamily: family,
              fontSize: size,
              fontWeight: weight,
            ),
          )
          ..addText(text);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: double.infinity));
    final width = paragraph.maxIntrinsicWidth;
    paragraph.layout(ParagraphConstraints(width: width.ceilToDouble()));
    final shift = switch (a['text-anchor']) {
      'middle' => width / 2,
      'end' => width,
      _ => 0.0,
    };
    return _TextOp(
      m.storage,
      paragraph,
      Offset(_num(a, 'x') - shift, _num(a, 'y') - paragraph.alphabeticBaseline),
    );
  }

  final Paragraph paragraph;
  final Offset offset;

  @override
  Path get outline =>
      Path()..addRect(offset & Size(paragraph.width, paragraph.height));

  @override
  void draw(Canvas canvas) => canvas.drawParagraph(paragraph, offset);
}

// ---------------------------------------------------------------------------
// Transformasi 2D

/// Matriks afin SVG `matrix(a b c d e f)`: x' = a·x + c·y + e,
/// y' = b·x + d·y + f.
class _Affine {
  const _Affine(this.a, this.b, this.c, this.d, this.e, this.f);

  const _Affine.translate(double x, double y) : this(1, 0, 0, 1, x, y);

  static const identity = _Affine(1, 0, 0, 1, 0, 0);

  factory _Affine.rotate(double degrees) {
    final r = degrees * math.pi / 180;
    final cos = math.cos(r);
    final sin = math.sin(r);
    return _Affine(cos, sin, -sin, cos, 0, 0);
  }

  final double a, b, c, d, e, f;

  _Affine operator *(_Affine o) => _Affine(
    a * o.a + c * o.b,
    b * o.a + d * o.b,
    a * o.c + c * o.d,
    b * o.c + d * o.d,
    a * o.e + c * o.f + e,
    b * o.e + d * o.f + f,
  );

  bool get isIdentity =>
      a == 1 && b == 0 && c == 0 && d == 1 && e == 0 && f == 0;

  /// Matriks 4×4 kolom-utama untuk `Canvas.transform`, atau null kalau
  /// identitas.
  Float64List? get storage => isIdentity
      ? null
      : Float64List.fromList([a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, e, f, 0, 1]);
}

final _transformPattern = RegExp(r'(translate|scale|rotate)\s*\(([^)]*)\)');

_Affine _parseTransform(String value) {
  var m = _Affine.identity;
  var index = 0;
  for (final t in _transformPattern.allMatches(value)) {
    if (value.substring(index, t.start).trim().isNotEmpty) {
      throw FormatException('transform tidak dikenal', value, index);
    }
    index = t.end;
    final n = _numbers(t[2]!);
    m =
        m *
        switch (t[1]) {
          'translate' => _Affine.translate(n[0], n.length > 1 ? n[1] : 0),
          'scale' => _Affine(n[0], 0, 0, n.length > 1 ? n[1] : n[0], 0, 0),
          _ when n.length == 3 =>
            _Affine.translate(n[1], n[2]) *
                _Affine.rotate(n[0]) *
                _Affine.translate(-n[1], -n[2]),
          _ => _Affine.rotate(n[0]),
        };
  }
  if (value.substring(index).trim().isNotEmpty) {
    throw FormatException('transform tidak dikenal', value, index);
  }
  return m;
}
