import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/css_animation.dart';
import 'package:kucing_oren/game/render/svg_template.dart';

/// Panggilan gambar [drawing] di kanvas perekam.
List<Invocation> _record(SvgDrawing drawing) {
  final canvas = TestRecordingCanvas();
  drawing.paint(canvas);
  return [for (final call in canvas.invocations) call.invocation];
}

Iterable<Paint> _paints(List<Invocation> calls) => calls
    .where((c) => c.memberName == #drawPath)
    .map((c) => c.positionalArguments[1] as Paint);

void main() {
  test('sc-if bersarang mengikuti nilai; nama yang tidak ada = false', () {
    final template = SvgTemplate('''
  <sc-if value="{{a}}" hint-placeholder-val="{{ true }}">
    <rect x="0" y="0" width="10" height="10" fill="#FF0000"></rect>
    <sc-if value="{{b}}">
      <circle cx="5" cy="5" r="2" fill="#00FF00"></circle>
    </sc-if>
  </sc-if>
  <ellipse cx="5" cy="5" rx="3" ry="2" fill="#0000FF"></ellipse>
''');
    expect(template.render({'a': true, 'b': true}).length, 3);
    expect(template.render({'a': true, 'b': false}).length, 2);
    expect(template.render({'b': true}).length, 1);
    expect(() => template.render({'a': 'ya'}), throwsArgumentError);
  });

  test('atribut {{nama}} diisi; yang tidak ada ditolak', () {
    final template = SvgTemplate(
      '<rect x="0" y="0" width="10" height="10" fill="{{warna}}"></rect>',
    );
    final paint = _paints(_record(template.render({'warna': '#12AB34'})))
        .single;
    expect(paint.color.toARGB32(), 0xFF12AB34);
    expect(() => template.render({}), throwsArgumentError);
  });

  test('isian bawaan hitam, garis hanya kalau ada stroke', () {
    final calls = _record(
      SvgTemplate(
        '<path d="M0 0 L10 0 L10 10 Z"></path>'
        '<path d="M0 0 L10 10" fill="none" stroke="#3A2618" '
        'stroke-width="2.6" stroke-linecap="round" '
        'stroke-linejoin="round"></path>',
      ).render({}),
    );
    final paints = _paints(calls).toList();
    expect(paints, hasLength(2));
    expect(paints[0].color.toARGB32(), 0xFF000000);
    expect(paints[0].style, PaintingStyle.fill);
    expect(paints[1].style, PaintingStyle.stroke);
    expect(paints[1].color.toARGB32(), 0xFF3A2618);
    expect(paints[1].strokeWidth, closeTo(2.6, 1e-6));
    expect(paints[1].strokeCap, StrokeCap.round);
    expect(paints[1].strokeJoin, StrokeJoin.round);
  });

  test('opacity dan fill-opacity jadi alfa warna', () {
    final paints = _paints(
      _record(
        SvgTemplate(
          '<ellipse cx="5" cy="5" rx="3" ry="2" fill="#7A4A1F" '
          'opacity="0.16"></ellipse>'
          '<rect x="0" y="0" width="5" height="5" fill="#F59A33" '
          'fill-opacity="0.28"></rect>',
        ).render({}),
      ),
    ).toList();
    expect(paints[0].color.a, closeTo(0.16, 0.002));
    expect(paints[1].color.a, closeTo(0.28, 0.002));
  });

  test('opacity pada isian + garis digambar di satu lapisan', () {
    final calls = _record(
      SvgTemplate(
        '<circle cx="5" cy="5" r="4" fill="#FFFFFF" stroke="#000000" '
        'opacity="0.5"></circle>',
      ).render({}),
    );
    expect(calls.first.memberName, #saveLayer);
    final layer = calls.first.positionalArguments[1] as Paint;
    expect(layer.color.a, closeTo(0.5, 0.002));
    for (final paint in _paints(calls)) {
      expect(paint.color.a, 1);
    }
    expect(calls.last.memberName, #restore);
  });

  test('opacity pada <g>: semua anaknya di satu lapisan', () {
    final drawing = SvgTemplate('''
<g opacity="0.8" transform="translate(10 0)">
  <rect x="0" y="0" width="4" height="4" fill="#000000"></rect>
  <circle cx="10" cy="2" r="2" fill="#FFFFFF" opacity="0.5"></circle>
</g>
''').render({});
    expect(drawing.bounds, const Rect.fromLTRB(10, 0, 22, 4));
    final calls = _record(drawing);
    expect(calls.first.memberName, #saveLayer);
    final layer = calls.first.positionalArguments[1] as Paint;
    expect(layer.color.a, closeTo(0.8, 0.002));
    // Opasitas anak tetap jadi alfa warnanya sendiri, di dalam lapisan.
    expect(_paints(calls).map((p) => p.color.a), [1, closeTo(0.5, 0.002)]);
    expect(calls.last.memberName, #restore);
  });

  test('stroke-dasharray memotong garis jadi putus-putus', () {
    final calls = _record(
      SvgTemplate(
        '<circle cx="25" cy="25" r="21" fill="none" stroke="#2BB5A0" '
        'stroke-width="2" stroke-dasharray="4 4"></circle>',
      ).render({}),
    );
    final path = calls.single.positionalArguments[0] as Path;
    final metrics = path.computeMetrics().toList();
    // Keliling 2π·21 ≈ 132 dibagi pola 8 → 17 garis.
    expect(metrics, hasLength(17));
    // Lingkaran diwakili kurva, jadi panjangnya hampir pas.
    expect(metrics.first.length, closeTo(4, 0.15));
  });

  test('transform: translate, scale, dan rotate di sekitar titik', () {
    final calls = _record(
      SvgTemplate('''
<g transform="translate(100 0) scale(-1 1)">
  <ellipse cx="18" cy="15" rx="6" ry="2.6" fill="#5BA96A" transform="rotate(90 25 25)"></ellipse>
</g>
''').render({}),
    );
    expect(calls.first.memberName, #save);
    final m = calls[1].positionalArguments[0] as Float64List;
    // Titik (50, 25) diputar 90° di sekitar (25, 25) → (25, 50), lalu
    // dicerminkan di x = 50 → (75, 50).
    const x = 50.0, y = 25.0;
    expect(m[0] * x + m[4] * y + m[12], closeTo(75, 1e-9));
    expect(m[1] * x + m[5] * y + m[13], closeTo(50, 1e-9));
  });

  test('transform skewY di sekitar transform-origin', () {
    final calls = _record(
      SvgTemplate('''
<rect x="204" y="22" width="34" height="118" fill="#C99466" transform="skewY(45)" transform-origin="204 22"></rect>
''').render({}),
    );
    final m = calls[1].positionalArguments[0] as Float64List;
    // skewY(45): y' = y + tan(45°)·x, di sekitar (204, 22): titik
    // (214, 22) turun 10 px, titik asal tetap.
    expect(m[0] * 214 + m[4] * 22 + m[12], closeTo(214, 1e-9));
    expect(m[1] * 214 + m[5] * 22 + m[13], closeTo(32, 1e-9));
    expect(m[0] * 204 + m[4] * 22 + m[12], closeTo(204, 1e-9));
    expect(m[1] * 204 + m[5] * 22 + m[13], closeTo(22, 1e-9));
  });

  test('bounds: semua bentuk sesudah transform, tanpa tebal garis', () {
    final drawing = SvgTemplate('''
<rect x="0" y="0" width="10" height="4" fill="#000000" stroke="#000000" stroke-width="6"></rect>
<g transform="translate(20 0)"><circle cx="0" cy="10" r="2" fill="#000000"></circle></g>
''').render({});
    expect(drawing.bounds, const Rect.fromLTRB(0, 0, 22, 12));
  });

  test('teks: atribut huruf diwariskan dari <g>', () {
    final calls = _record(
      SvgTemplate('''
<g transform="translate(0 0)" fill="#2F86B8" font-family="Fredoka, sans-serif" font-weight="700">
  <text x="80" y="16" font-size="18">Z</text>
</g>
''').render({}),
    );
    final draw = calls.singleWhere((c) => c.memberName == #drawParagraph);
    final paragraph = draw.positionalArguments[0] as Paragraph;
    final offset = draw.positionalArguments[1] as Offset;
    expect(offset.dx, 80);
    // y adalah garis dasar huruf.
    expect(offset.dy + paragraph.alphabeticBaseline, closeTo(16, 1e-6));
  });

  test('elemen atau sintaks yang belum didukung ditolak', () {
    expect(
      () =>
          SvgTemplate('<pattern id="p" width="1" height="1"></pattern>')
              .render({}),
      throwsUnsupportedError,
    );
    expect(
      () => SvgTemplate(
        '<rect x="0" y="0" width="1" height="1" fill="url(#tidak-ada)"></rect>',
      ).render({}),
      throwsFormatException,
    );
    expect(() => SvgTemplate('<rect x="0">'), throwsFormatException);
    expect(() => SvgTemplate('<rect></circle>'), throwsFormatException);
    expect(
      () => SvgTemplate(
        '<rect x="0" y="0" width="1" height="1" transform="skewX(10)"></rect>',
      ).render({}),
      throwsFormatException,
    );
  });

  test('nama bertitik dibaca dari map bersarang', () {
    final template = SvgTemplate(
      '<circle cx="{{p.x}}" cy="10" r="1" fill="{{c.fur}}"></circle>',
    );
    final drawing = template.render({
      'p': {'x': 5},
      'c': {'fur': '#112233'},
    });
    expect(drawing.length, 1);
    expect(drawing.bounds.center, const Offset(5, 10));
    final paint = _paints(_record(drawing)).single;
    expect(paint.color.toARGB32(), 0xFF112233);
  });

  test('sc-if bertitik mengikuti bool di map; tanpa kunci = false', () {
    final template = SvgTemplate(
      '<sc-if value="{{a.pita}}" hint-placeholder-val="{{ false }}">'
      '<circle cx="5" cy="5" r="2" fill="#F07F9A"></circle>'
      '</sc-if>',
    );
    expect(
      template.render({
        'a': {'pita': true},
      }).length,
      1,
    );
    expect(
      template.render({
        'a': {'pita': false},
      }).length,
      0,
    );
    expect(template.render({'a': const <String, Object>{}}).length, 0);
    expect(template.render({}).length, 0);
  });

  test('sc-for mengulang anaknya sekali per elemen daftar', () {
    final template = SvgTemplate(
      '<sc-for list="{{c.p}}" as="q" hint-placeholder-count="0">'
      '<ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="1" ry="1" fill="{{q.f}}">'
      '</ellipse>'
      '</sc-for>',
    );
    final drawing = template.render({
      'c': {
        'p': [
          {'cx': 10, 'cy': 20, 'f': '#AABBCC'},
          {'cx': 30, 'cy': 40, 'f': '#DDEEFF'},
        ],
      },
    });
    expect(drawing.length, 2);
    expect(drawing.bounds, const Rect.fromLTRB(9, 19, 31, 41));
    expect(_paints(_record(drawing)).map((p) => p.color.toARGB32()), [
      0xFFAABBCC,
      0xFFDDEEFF,
    ]);
  });

  test('sc-for daftar kosong tidak menggambar apa pun', () {
    final template = SvgTemplate(
      '<sc-for list="{{c.p}}" as="q">'
      '<circle cx="{{q.cx}}" cy="1" r="1"></circle>'
      '</sc-for>',
    );
    expect(
      template.render({
        'c': {'p': const <Object>[]},
      }).length,
      0,
    );
  });

  test('nama bertitik yang tidak ada tetap ditolak', () {
    final template = SvgTemplate(
      '<circle cx="1" cy="1" r="1" fill="{{c.tidakAda}}"></circle>',
    );
    expect(
      () => template.render({
        'c': {'fur': '#112233'},
      }),
      throwsArgumentError,
    );
  });

  group('lapisan rumah: poligon, gradien, clip, kelas', () {
    test('polygon terisi, polyline dan line jadi garis', () async {
      final px = await _pixels(
        SvgTemplate(
          '<polygon points="0,0 20,0 20,20" fill="#FF0000"></polygon>'
          '<polyline points="0,30 20,30" fill="none" stroke="#00FF00" '
          'stroke-width="4"></polyline>'
          '<line x1="0" y1="38" x2="20" y2="38" stroke="#0000FF" '
          'stroke-width="4"></line>',
        ).render({}),
        const Size(20, 40),
      );
      expect(px(15, 5), 0xFFFF0000);
      expect(px(5, 15), 0x00000000);
      expect(px(10, 30), 0xFF00FF00);
      expect(px(10, 38), 0xFF0000FF);
    });

    test('rgba() jadi alfa warna isian dan garis', () {
      final paints = _paints(
        _record(
          SvgTemplate(
            '<rect x="0" y="0" width="5" height="5" '
            'fill="rgba(176,122,79,0.26)" stroke="rgba(0,0,0,0.5)"></rect>',
          ).render({}),
        ),
      ).toList();
      expect(paints[0].color.a, closeTo(0.26, 0.002));
      expect((paints[0].color.r * 255).round(), 176);
      expect(paints[1].color.a, closeTo(0.5, 0.002));
    });

    test('linearGradient di kotak isi bentuk', () async {
      final px = await _pixels(
        SvgTemplate(
          '<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
          '<stop offset="0" stop-color="#FF0000"></stop>'
          '<stop offset="1" stop-color="#0000FF" stop-opacity="0.5"></stop>'
          '</linearGradient></defs>'
          '<rect x="0" y="10" width="20" height="20" fill="url(#g)"></rect>',
        ).render({}),
        const Size(20, 40),
      );
      expect(px(10, 5), 0x00000000);
      expect(px(10, 10) >> 16 & 0xFF, greaterThan(230));
      final bottom = px(10, 29);
      expect(bottom & 0xFF, greaterThan(bottom >> 16 & 0xFF));
      expect(bottom >> 24 & 0xFF, closeTo(130, 12));
    });

    test('radialGradient: tengah warna stop pertama', () async {
      final px = await _pixels(
        SvgTemplate(
          '<defs><radialGradient id="r" cx="0.5" cy="0.5" r="0.5">'
          '<stop offset="0" stop-color="#FFFFFF"></stop>'
          '<stop offset="1" stop-color="#000000" stop-opacity="0"></stop>'
          '</radialGradient></defs>'
          '<rect x="0" y="0" width="40" height="40" fill="url(#r)"></rect>',
        ).render({}),
        const Size(40, 40),
      );
      expect(px(20, 20) >> 24 & 0xFF, greaterThan(240));
      expect(px(1, 1) >> 24 & 0xFF, lessThan(10));
    });

    test('clip-path di <g> memotong isinya', () async {
      final px = await _pixels(
        SvgTemplate(
          '<defs><clipPath id="c"><polygon points="0,0 20,0 0,20">'
          '</polygon></clipPath></defs>'
          '<g clip-path="url(#c)"><rect x="0" y="0" width="20" height="20" '
          'fill="#FF0000"></rect></g>',
        ).render({}),
        const Size(20, 20),
      );
      expect(px(3, 3), 0xFFFF0000);
      expect(px(17, 17), 0x00000000);
    });

    test('class memakai gaya dari classes seperti style', () {
      final keyframes = CssKeyframes.parse(
        '@keyframes geser{0%{transform:translateX(0px)}'
        '100%{transform:translateX(10px)}}',
      );
      final withClass = SvgTemplate(
        '<g class="awan rm-anim"><rect x="0" y="0" width="2" height="2" '
        'fill="#000000"></rect></g>',
        keyframes: keyframes,
        classes: const {'awan': 'animation: geser 8s linear infinite'},
      );
      final withStyle = SvgTemplate(
        '<g style="animation: geser 8s linear infinite"><rect x="0" y="0" '
        'width="2" height="2" fill="#000000"></rect></g>',
        keyframes: keyframes,
      );
      for (final t in [4.0, 6.0]) {
        expect(
          withClass.render({}, time: t).bounds,
          withStyle.render({}, time: t).bounds,
        );
      }
      expect(withClass.render({}, time: 4).bounds.left, closeTo(5, 1e-6));
      expect(withClass.animated, isTrue);
      expect(withClass.bind({}).render(time: 4).bounds.left, closeTo(5, 1e-6));
    });

    test('gradien ikut transform bentuknya', () async {
      final px = await _pixels(
        SvgTemplate(
          '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="0">'
          '<stop offset="0" stop-color="#FF0000"></stop>'
          '<stop offset="1" stop-color="#0000FF"></stop>'
          '</linearGradient></defs>'
          '<g transform="translate(20 0)"><rect x="0" y="0" width="20" '
          'height="10" fill="url(#g)"></rect></g>',
        ).render({}),
        const Size(40, 10),
      );
      expect(px(5, 5), 0x00000000);
      final left = px(21, 5);
      final right = px(38, 5);
      expect(left >> 16 & 0xFF, greaterThan(left & 0xFF));
      expect(right & 0xFF, greaterThan(right >> 16 & 0xFF));
    });

    test('bind: poligon bergradien dengan opasitas berdenyut', () async {
      final keyframes = CssKeyframes.parse(
        '@keyframes denyut{0%{opacity:0.2}100%{opacity:1}}',
      );
      final template = SvgTemplate(
        '<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" stop-color="#FF0000"></stop>'
        '<stop offset="1" stop-color="#FF0000"></stop>'
        '</linearGradient></defs>'
        '<polygon class="denyut" points="0,0 20,0 20,20 0,20" '
        'fill="url(#g)"></polygon>',
        keyframes: keyframes,
        classes: const {'denyut': 'animation: denyut 2s linear infinite'},
      );
      final bound = template.bind(const {});
      for (final t in [0.0, 1.0]) {
        final expected = await _pixels(
          template.render(const {}, time: t),
          const Size(20, 20),
        );
        final actual = await _pixels(bound.render(time: t), const Size(20, 20));
        expect(actual(10, 10), expected(10, 10), reason: 'waktu $t');
        expect(actual(10, 10) >> 16 & 0xFF, 0xFF, reason: 'waktu $t');
      }
      final start = await _pixels(bound.render(time: 0), const Size(20, 20));
      final mid = await _pixels(bound.render(time: 1), const Size(20, 20));
      expect(start(10, 10) >> 24 & 0xFF, closeTo(51, 3));
      expect(mid(10, 10) >> 24 & 0xFF, closeTo(153, 3));
    });

    test('<g clip-path opacity>: dipotong lalu transparan', () async {
      final px = await _pixels(
        SvgTemplate(
          '<defs><clipPath id="c"><polygon points="0,0 10,0 10,20 0,20">'
          '</polygon></clipPath></defs>'
          '<g clip-path="url(#c)" opacity="0.5"><rect x="0" y="0" '
          'width="20" height="20" fill="#000000"></rect></g>',
        ).render({}),
        const Size(20, 20),
      );
      expect(px(5, 5) >> 24 & 0xFF, closeTo(128, 2));
      expect(px(15, 5), 0x00000000);
    });
  });
}

/// Warna ARGB piksel (x, y) dari [drawing] yang digambar seukuran [size].
Future<int Function(int, int)> _pixels(SvgDrawing drawing, Size size) async {
  final recorder = PictureRecorder();
  drawing.paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final data = (await image.toByteData(
    format: ImageByteFormat.rawStraightRgba,
  ))!;
  final w = size.width.toInt();
  return (x, y) {
    final i = (y * w + x) * 4;
    return data.getUint8(i + 3) << 24 |
        data.getUint8(i) << 16 |
        data.getUint8(i + 1) << 8 |
        data.getUint8(i + 2);
  };
}
