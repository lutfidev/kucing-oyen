import 'dart:math' as math;

/// Animasi CSS desain (`@keyframes` dan atribut `style`) sebagai fungsi
/// waktu, supaya gerak di `*.dc.html` bisa digambar tanpa diketik ulang.
///
/// Hanya subset yang dipakai desain: fungsi transform `rotate`,
/// `translate(X|Y)`, `scale(X|Y)`, properti `opacity`, `transform-origin`
/// (px atau `center`), `transform-box: fill-box`, `animation` (nama, durasi,
/// easing, `infinite`, `alternate`), dan `animation-delay`. Yang lain
/// membuat pengurai gagal supaya tidak ada gerak yang hilang diam-diam.

/// Satu fungsi transform, dinormalkan: `rotate` [derajat], `translate`
/// [x, y], `scale` [x, y].
class CssTransformFn {
  const CssTransformFn(this.name, this.args);

  final String name;
  final List<double> args;

  CssTransformFn get identity => CssTransformFn(
    name,
    name == 'scale' ? const [1, 1] : List.filled(args.length, 0),
  );

  @override
  bool operator ==(Object other) =>
      other is CssTransformFn &&
      other.name == name &&
      other.args.length == args.length &&
      Iterable.generate(args.length).every((i) => other.args[i] == args[i]);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(args));

  @override
  String toString() => '$name(${args.join(', ')})';
}

/// Matriks afin SVG (a b c d e f): x' = a·x + c·y + e, y' = b·x + d·y + f.
typedef CssMatrix = (double, double, double, double, double, double);

const CssMatrix cssIdentity = (1, 0, 0, 1, 0, 0);

CssMatrix cssMultiply(CssMatrix m, CssMatrix o) {
  final (a, b, c, d, e, f) = m;
  final (oa, ob, oc, od, oe, of) = o;
  return (
    a * oa + c * ob,
    b * oa + d * ob,
    a * oc + c * od,
    b * oc + d * od,
    a * oe + c * of + e,
    b * oe + d * of + f,
  );
}

CssMatrix _fnMatrix(CssTransformFn fn) => switch (fn.name) {
  'rotate' => () {
    final r = fn.args[0] * math.pi / 180;
    return (math.cos(r), math.sin(r), -math.sin(r), math.cos(r), 0.0, 0.0);
  }(),
  'translate' => (1.0, 0.0, 0.0, 1.0, fn.args[0], fn.args[1]),
  _ => (fn.args[0], 0.0, 0.0, fn.args[1], 0.0, 0.0),
};

/// Nilai animasi pada satu waktu: daftar transform (null = tidak
/// dianimasikan) dan opasitas (null = tidak dianimasikan).
class CssFrame {
  const CssFrame({this.transform, this.opacity});

  final List<CssTransformFn>? transform;
  final double? opacity;

  /// Matriks transform di sekitar titik asal ([ox], [oy]), seperti
  /// `transform-origin`.
  CssMatrix matrix(double ox, double oy) {
    final fns = transform;
    if (fns == null || fns.isEmpty) return cssIdentity;
    var m = (1.0, 0.0, 0.0, 1.0, ox, oy);
    for (final fn in fns) {
      m = cssMultiply(m, _fnMatrix(fn));
    }
    return cssMultiply(m, (1.0, 0.0, 0.0, 1.0, -ox, -oy));
  }
}

final _fnPattern = RegExp(r'(\w+)\s*\(([^)]*)\)');

double _length(String raw) {
  final v = raw.trim();
  final n = v.endsWith('deg') || v.endsWith('px')
      ? v.substring(0, v.length - (v.endsWith('deg') ? 3 : 2))
      : v;
  return double.parse(n);
}

/// `transform` CSS ke daftar fungsi ternormal.
List<CssTransformFn> parseCssTransform(String value) {
  if (value.trim() == 'none') return const [];
  final fns = <CssTransformFn>[];
  var index = 0;
  for (final m in _fnPattern.allMatches(value)) {
    if (value.substring(index, m.start).trim().isNotEmpty) {
      throw FormatException('transform CSS tidak dikenal', value, index);
    }
    index = m.end;
    final n = m[2]!.split(',').map(_length).toList();
    fns.add(switch (m[1]) {
      'rotate' => CssTransformFn('rotate', [n[0]]),
      'translate' => CssTransformFn('translate', [
        n[0],
        n.length > 1 ? n[1] : 0,
      ]),
      'translateX' => CssTransformFn('translate', [n[0], 0]),
      'translateY' => CssTransformFn('translate', [0, n[0]]),
      'scale' => CssTransformFn('scale', [n[0], n.length > 1 ? n[1] : n[0]]),
      'scaleX' => CssTransformFn('scale', [n[0], 1]),
      'scaleY' => CssTransformFn('scale', [1, n[0]]),
      _ => throw FormatException('transform CSS tidak dikenal', value),
    });
  }
  if (value.substring(index).trim().isNotEmpty) {
    throw FormatException('transform CSS tidak dikenal', value, index);
  }
  return fns;
}

Map<String, String> _declarations(String body) {
  final out = <String, String>{};
  for (final part in body.split(';')) {
    if (part.trim().isEmpty) continue;
    final colon = part.indexOf(':');
    if (colon < 0) throw FormatException('Deklarasi CSS rusak', body);
    out[part.substring(0, colon).trim()] = part.substring(colon + 1).trim();
  }
  return out;
}

/// Satu `@keyframes`: titik transform dan opasitas per properti, seperti
/// CSS (offset yang tidak menulis properti itu dilewati; 0% dan 100% yang
/// tidak ditulis memakai nilai dasar).
class CssKeyframes {
  CssKeyframes._(this._transform, this._opacity);

  final List<(double, List<CssTransformFn>)> _transform;
  final List<(double, double)> _opacity;

  /// Semua `@keyframes` di [css] menurut namanya.
  static Map<String, CssKeyframes> parse(String css) {
    final out = <String, CssKeyframes>{};
    final head = RegExp(r'@keyframes\s+([\w-]+)\s*\{');
    for (final m in head.allMatches(css)) {
      var depth = 1;
      var i = m.end;
      while (depth > 0) {
        if (i >= css.length) throw FormatException('@keyframes terbuka', css);
        if (css[i] == '{') depth++;
        if (css[i] == '}') depth--;
        i++;
      }
      out[m[1]!] = _parseBody(css.substring(m.end, i - 1));
    }
    return out;
  }

  static CssKeyframes _parseBody(String body) {
    final transform = <(double, List<CssTransformFn>)>[];
    final opacity = <(double, double)>[];
    for (final m in RegExp(r'([^{}]+)\{([^{}]*)\}').allMatches(body)) {
      final decls = _declarations(m[2]!);
      for (final key in decls.keys) {
        if (key != 'transform' && key != 'opacity') {
          throw FormatException('Properti keyframe tidak dikenal', key);
        }
      }
      for (final sel in m[1]!.split(',')) {
        final s = sel.trim();
        final offset = s == 'from'
            ? 0.0
            : s == 'to'
            ? 1.0
            : double.parse(s.substring(0, s.length - 1)) / 100;
        if (decls['transform'] case final t?) {
          transform.add((offset, parseCssTransform(t)));
        }
        if (decls['opacity'] case final o?) {
          opacity.add((offset, double.parse(o)));
        }
      }
    }
    transform.sort((a, b) => a.$1.compareTo(b.$1));
    opacity.sort((a, b) => a.$1.compareTo(b.$1));
    return CssKeyframes._(transform, opacity);
  }

  /// Nilai pada kemajuan [progress] 0–1 dengan [easing] per segmen.
  CssFrame at(double progress, [String easing = 'ease']) => CssFrame(
    transform: _transform.isEmpty
        ? null
        : _sample<List<CssTransformFn>>(
            _transform,
            progress,
            easing,
            _lerpTransforms,
            const [],
          ),
    opacity: _opacity.isEmpty
        ? null
        : _sample<double>(_opacity, progress, easing, _lerp, 1.0),
  );
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

List<CssTransformFn> _lerpTransforms(
  List<CssTransformFn> a,
  List<CssTransformFn> b,
  double t,
) {
  final from = a.isEmpty ? [for (final fn in b) fn.identity] : a;
  final to = b.isEmpty ? [for (final fn in a) fn.identity] : b;
  if (from.length != to.length ||
      Iterable.generate(from.length).any((i) => from[i].name != to[i].name)) {
    throw FormatException('Keyframe transform tidak sejenis', '$a → $b');
  }
  return [
    for (var i = 0; i < from.length; i++)
      CssTransformFn(from[i].name, [
        for (var j = 0; j < from[i].args.length; j++)
          _lerp(from[i].args[j], to[i].args[j], t),
      ]),
  ];
}

T _sample<T>(
  List<(double, T)> frames,
  double p,
  String easing,
  T Function(T, T, double) lerp,
  T base,
) {
  final points = [
    if (frames.first.$1 > 0) (0.0, base),
    ...frames,
    if (frames.last.$1 < 1) (1.0, base),
  ];
  for (var i = 0; i < points.length - 1; i++) {
    final (o1, v1) = points[i];
    final (o2, v2) = points[i + 1];
    if (p <= o2 || i == points.length - 2) {
      final span = o2 - o1;
      final t = span <= 0 ? 1.0 : ((p - o1) / span).clamp(0.0, 1.0);
      return lerp(v1, v2, cssEase(easing, t));
    }
  }
  return points.last.$2;
}

const _easings = {
  'linear': (0.0, 0.0, 1.0, 1.0),
  'ease': (0.25, 0.1, 0.25, 1.0),
  'ease-in': (0.42, 0.0, 1.0, 1.0),
  'ease-out': (0.0, 0.0, 0.58, 1.0),
  'ease-in-out': (0.42, 0.0, 0.58, 1.0),
};

/// Kurva easing CSS bernama pada [t] 0–1.
double cssEase(String name, double t) {
  final curve = _easings[name];
  if (curve == null) throw FormatException('Easing tidak dikenal', name);
  final (x1, y1, x2, y2) = curve;
  if (name == 'linear') return t;
  double bezier(double a, double b, double s) =>
      3 * a * (1 - s) * (1 - s) * s + 3 * b * (1 - s) * s * s + s * s * s;
  // Cari s dengan x(s) = t (bagi dua; x monoton).
  var lo = 0.0;
  var hi = 1.0;
  for (var i = 0; i < 30; i++) {
    final mid = (lo + hi) / 2;
    if (bezier(x1, x2, mid) < t) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return bezier(y1, y2, (lo + hi) / 2);
}

/// Atribut `style` desain yang menggerakkan satu elemen.
class CssStyle {
  const CssStyle({
    this.originX = 0,
    this.originY = 0,
    this.fillBox = false,
    this.centerOrigin = false,
    this.animation,
    this.duration = 0,
    this.easing = 'ease',
    this.alternate = false,
    this.delay = 0,
  });

  /// Kosong (`''`) = tanpa gaya.
  factory CssStyle.parse(String style) {
    final d = _declarations(style);
    var originX = 0.0;
    var originY = 0.0;
    var center = false;
    String? name;
    var duration = 0.0;
    var easing = 'ease';
    var alternate = false;
    var delay = 0.0;
    for (final MapEntry(:key, :value) in d.entries) {
      switch (key) {
        case 'transform-origin':
          if (value == 'center') {
            center = true;
          } else {
            final parts = value.split(RegExp(r'\s+'));
            originX = _length(parts[0]);
            originY = parts.length > 1 ? _length(parts[1]) : originX;
          }
        case 'transform-box':
          if (value != 'fill-box') {
            throw FormatException('transform-box tidak dikenal', value);
          }
        case 'animation':
          if (value == 'none') break;
          for (final word in value.split(RegExp(r'\s+'))) {
            if (word.endsWith('s') && double.tryParse(_dropS(word)) != null) {
              duration = double.parse(_dropS(word));
            } else if (_easings.containsKey(word)) {
              easing = word;
            } else if (word == 'infinite') {
              continue;
            } else if (word == 'alternate') {
              alternate = true;
            } else {
              if (name != null) {
                throw FormatException('animation tidak dikenal', value);
              }
              name = word;
            }
          }
        case 'animation-delay':
          delay = double.parse(_dropS(value));
        default:
          throw FormatException('Gaya CSS tidak dikenal', key);
      }
    }
    return CssStyle(
      originX: originX,
      originY: originY,
      fillBox: d['transform-box'] == 'fill-box',
      centerOrigin: center,
      animation: name,
      duration: duration,
      easing: easing,
      alternate: alternate,
      delay: delay,
    );
  }

  final double originX;
  final double originY;
  final bool fillBox;

  /// `transform-origin: center` (pusat kotak isi kalau [fillBox]).
  final bool centerOrigin;

  final String? animation;
  final double duration;
  final String easing;
  final bool alternate;
  final double delay;

  /// Nilai animasi pada detik [time]; null kalau tanpa animasi atau belum
  /// mulai (delay positif, tanpa `fill-mode`).
  CssFrame? frameAt(double time, Map<String, CssKeyframes> keyframes) {
    final name = animation;
    if (name == null || duration <= 0) return null;
    final frames = keyframes[name];
    if (frames == null) throw ArgumentError('@keyframes $name tidak ada');
    final elapsed = time - delay;
    if (elapsed < 0) return null;
    final cycles = elapsed / duration;
    final iteration = cycles.floor();
    var p = cycles - iteration;
    if (alternate && iteration.isOdd) p = 1 - p;
    return frames.at(p, easing);
  }
}

String _dropS(String v) => v.substring(0, v.length - 1);
