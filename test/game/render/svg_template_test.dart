import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
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
      () => SvgTemplate('<polygon points="0,0 1,1"></polygon>').render({}),
      throwsUnsupportedError,
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
}
