import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/css_animation.dart';
import 'package:kucing_oren/game/render/design_svg_home.dart';
import 'package:kucing_oren/game/render/render.dart';
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

  test(
    'alternate dengan easing tidak simetris: putaran balik = waktu dibalik',
    () {
      // Web Animations: easing keyframe dipakai pada kemajuan berarah, jadi
      // ease-in yang diputar balik tampak seperti ease-out (CSS Animations 1,
      // `animation-direction`).
      final fade = CssKeyframes.parse(
        '@keyframes fade { from { opacity: 0 } to { opacity: 1 } }',
      );
      final style = CssStyle.parse(
        'animation: fade 1s ease-in infinite alternate',
      );
      for (final x in [0.1, 0.25, 0.6, 0.9]) {
        final forward = style.frameAt(x, fade)!.opacity!;
        expect(forward, closeTo(cssEase('ease-in', x), 1e-9));
        // Putaran ke-2 (balik) pada 1 + (1 − x) sama dengan putaran maju di x.
        expect(style.frameAt(2 - x, fade)!.opacity, closeTo(forward, 1e-9));
      }
      // Awal putaran balik bergerak cepat (seperti ease-out), bukan pelan.
      final start = 1 - style.frameAt(1.1, fade)!.opacity!;
      expect(start, greaterThan(0.1));
    },
  );

  test('fill-box hanya dengan origin center', () {
    for (final style in [
      'transform-box: fill-box; transform-origin: 4px 6px; '
          'animation: kcTwinkle 1.2s ease-in-out infinite',
      'transform-box: fill-box; animation: kcTwinkle 1.2s ease-in-out infinite',
      'transform-origin: center; animation: kcTwinkle 1.2s ease-in-out infinite',
    ]) {
      expect(() => CssStyle.parse(style), throwsFormatException, reason: style);
    }
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

    test('opasitas animasi di elemen ber-opacity gagal', () {
      // CSS mengganti atribut `opacity`, bukan mengalikannya.
      for (final el in ['rect', 'g']) {
        final body = el == 'g'
            ? '<rect x="0" y="0" width="1" height="1" fill="#000000"></rect>'
            : '';
        final bad = SvgTemplate(
          '<$el opacity="0.5" style="animation: kcZzz 2.4s ease-out infinite" '
          'x="0" y="0" width="1" height="1" fill="#000000">$body</$el>',
          keyframes: _kitty,
        );
        expect(() => bad.render({}, time: 0.7), throwsFormatException);
        expect(bad.render({}).length, 1);
      }
    });
  });

  test('semua gambar bergerak desain lolos di berbagai waktu', () {
    final canvas = Canvas(PictureRecorder());
    const times = [0.0, 0.37, 1.3, 2.9, 7.1];
    for (final time in times) {
      for (final kitty in KittyId.values) {
        for (final pose in KittyPose.values) {
          for (final facing in KittyFacing.values) {
            for (final toy in KittyToy.values) {
              paintKitty(
                canvas,
                KittyLook(
                  kitty: kitty,
                  pose: pose,
                  facing: facing,
                  toy: toy,
                  time: time,
                ),
              );
            }
          }
        }
      }
      // Aksesoris tidak bergantung corak: cukup satu kucing per pose.
      for (final pose in KittyPose.values) {
        for (final accessory in AccessoryId.values) {
          paintKitty(
            canvas,
            KittyLook(
              kitty: KittyId.oyen,
              pose: pose,
              accessory: accessory,
              time: time,
            ),
          );
        }
      }
      for (final id in RoomItemId.values) {
        for (final full in [true, false]) {
          paintRoomItemArt(canvas, id, full: full, time: time);
          paintRoomItemArt(
            canvas,
            id,
            full: full,
            time: time,
            user: KittyLook(kitty: KittyId.oyen, time: time),
          );
        }
      }
    }
  });

  test('animated: hanya template yang punya atribut style', () {
    expect(
      SvgTemplate(
        '<rect x="0" y="0" width="1" height="1" fill="#000000"></rect>',
      ).animated,
      isFalse,
    );
    expect(
      SvgTemplate(
        '<g style="{{s}}"><rect x="0" y="0" width="1" height="1" '
        'fill="#000000"></rect></g>',
      ).animated,
      isTrue,
    );
  });
}
