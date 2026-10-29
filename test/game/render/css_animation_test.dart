import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/css_animation.dart';
import 'package:kucing_oren/game/render/design_svg_home.dart';
import 'package:kucing_oren/game/render/svg_template.dart';

final _kitty = CssKeyframes.parse(kittyKeyframes);
final _items = CssKeyframes.parse(roomItemKeyframes);

CssTransformFn _fn(CssFrame frame) => frame.transform!.single;

void main() {
  test('semua @keyframes desain terurai', () {
    expect(_kitty, hasLength(15));
    expect(_items, hasLength(10));
    expect(CssKeyframes.parse(roomBadgeKeyframes).keys, ['gkBob', 'tlBob']);
  });

  test('kedip: mata 0,12 di 96% dari 4,6 detik, terbuka di awal', () {
    final style = CssStyle.parse(
      'transform-box: fill-box; transform-origin: center; '
      'animation: kcBlink 4.6s infinite; animation-delay: 0s',
    );
    expect(
      _fn(style.frameAt(4.6 * 0.96, _kitty)!).args[1],
      closeTo(0.12, 1e-9),
    );
    expect(_fn(style.frameAt(0, _kitty)!).args[1], 1);
    expect(style.centerOrigin && style.fillBox, isTrue);
  });

  test('ekor: −8° di tengah 2,6 detik; delay negatif menggeser fase', () {
    final style = CssStyle.parse(
      'transform-origin: 73px 77px; animation: kcTail 2.6s ease-in-out infinite',
    );
    expect(_fn(style.frameAt(1.3, _kitty)!).args.single, closeTo(-8, 1e-6));
    expect(
      _fn(style.frameAt(2.6 + 1.3, _kitty)!).args.single,
      closeTo(-8, 1e-6),
    );
    expect((style.originX, style.originY), (73, 77));
    final late = CssStyle.parse(
      'animation: kcTail 2.6s ease-in-out infinite; animation-delay: -1.3s',
    );
    expect(_fn(late.frameAt(0, _kitty)!).args.single, closeTo(-8, 1e-6));
  });

  test('angguk makan alternate: 2,6 px di 0,45 detik, kembali di 0,9', () {
    final style = CssStyle.parse(
      'animation: kcNom 0.45s ease-in-out infinite alternate',
    );
    expect(_fn(style.frameAt(0.45, _kitty)!).args, [0, closeTo(2.6, 1e-9)]);
    expect(_fn(style.frameAt(0.9, _kitty)!).args[1], closeTo(0, 1e-9));
  });

  test('burung lompat: (−8, 0) di 20% dari 2,6 detik', () {
    final style = CssStyle.parse('animation: brgHop 2.6s ease-in-out infinite');
    expect(_fn(style.frameAt(0.52, _items)!).args, [
      closeTo(-8, 1e-9),
      closeTo(0, 1e-9),
    ]);
  });

  test('opasitas per properti: Zzz terlihat penuh di 30%', () {
    final style = CssStyle.parse('animation: kcZzz 2.4s ease-out infinite');
    final frame = style.frameAt(2.4 * 0.3, _kitty)!;
    expect(frame.opacity, closeTo(1, 1e-9));
    // Transform tidak ditulis di 30%: tetap di antara 0% dan 100%.
    expect(frame.transform!.single.args[1], inExclusiveRange(-8, 4));
  });

  test('easing CSS', () {
    expect(cssEase('ease-in-out', 0.5), closeTo(0.5, 1e-6));
    expect(cssEase('linear', 0.3), 0.3);
    expect(cssEase('ease-out', 0.5), greaterThan(0.5));
    expect(() => cssEase('steps', 0.5), throwsFormatException);
  });

  test('gaya tidak dikenal gagal, gaya kosong tanpa animasi', () {
    expect(() => CssStyle.parse('color: red'), throwsFormatException);
    expect(CssStyle.parse('').frameAt(1, _kitty), isNull);
  });

  group('SvgTemplate dengan waktu', () {
    final template = SvgTemplate('''
<g style="transform-origin: 0px 0px; animation: kcTail 2.6s ease-in-out infinite">
  <rect x="10" y="0" width="10" height="2" fill="#FF0000"></rect>
</g>
<path style="{{tw}}" d="M0 30 L10 30 L10 40 L0 40 Z" fill="#00FF00"></path>
''', keyframes: _kitty);
    const twinkle =
        'transform-box: fill-box; transform-origin: center; '
        'animation: kcTwinkle 1.2s ease-in-out infinite';

    test('time null = diam, sama dengan tanpa gaya', () {
      final still = template.render({'tw': twinkle});
      expect(still.bounds, const Rect.fromLTRB(0, 0, 20, 40));
    });

    test('rotasi di sekitar transform-origin pada waktu tertentu', () {
      final moved = template.render({'tw': ''}, time: 1.3);
      // Diputar −8°: ujung kanan rect naik di atas 0.
      expect(moved.bounds.top, lessThan(-1));
    });

    test('fill-box center: kilau mengecil di sekitar pusatnya', () {
      final small = template.render({'tw': twinkle}, time: 0.6);
      expect(small.bounds.bottom, closeTo(35 + 5 * 0.6, 1e-6));
    });

    test('transform dan animasi di satu elemen gagal', () {
      final bad = SvgTemplate(
        '<rect transform="translate(1 1)" style="animation: kcTail 1s infinite" '
        'x="0" y="0" width="1" height="1" fill="#000000"></rect>',
        keyframes: _kitty,
      );
      expect(() => bad.render({}, time: 0.5), throwsFormatException);
      expect(bad.render({}).length, 1);
    });
  });
}
