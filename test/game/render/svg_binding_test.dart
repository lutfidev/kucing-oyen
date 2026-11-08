import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/css_animation.dart';
import 'package:kucing_oren/game/render/design_svg_home.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/svg_template.dart';

Future<List<int>> pixels(SvgDrawing drawing) async {
  final recorder = PictureRecorder();
  drawing.paint(Canvas(recorder)..translate(40, 40));
  final picture = recorder.endRecording();
  final image = await picture.toImage(180, 180);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  final result = bytes.toList();
  image.dispose();
  picture.dispose();
  return result;
}

void main() {
  test('production cache preserves time and variants after eviction', () async {
    final template = SvgTemplate(
      kittySvg,
      keyframes: CssKeyframes.parse(kittyKeyframes),
    );
    const original = KittyLook(
      kitty: KittyId.oyen,
      accessory: AccessoryId.pita,
      time: .317,
    );
    // Lebih dari 96 varian: kucing asli harus tetap benar saat dibuat ulang.
    for (final kitty in KittyId.values) {
      for (final pose in KittyPose.values) {
        kittyDrawing(KittyLook(kitty: kitty, pose: pose, time: 1));
      }
    }
    for (final look in [
      original,
      original.copyWith(time: 4.416),
      original.copyWith(mirror: true, toy: KittyToy.none, post: false),
      original.copyWith(
        accessory: AccessoryId.mahkotaRaja,
        pose: KittyPose.sleep,
      ),
      original.copyWith(still: true),
    ]) {
      expect(
        await pixels(kittyDrawing(look)),
        await pixels(template.render(kittyVals(look), time: look.time)),
        reason: '$look',
      );
    }
  });

  test('binding validates unsupported animation and opacity conflicts', () {
    final keyframes = CssKeyframes.parse(kittyKeyframes);
    final opacity = SvgTemplate(
      '<g opacity="0.5" style="animation: kcZzz 2.4s infinite"><circle r="5"/></g>',
      keyframes: keyframes,
    );
    expect(() => opacity.bind({}), throwsFormatException);
    final transform = SvgTemplate(
      '<circle r="5" transform="translate(1 1)" style="animation: kcTail 1s infinite"/>',
      keyframes: keyframes,
    ).bind({});
    expect(() => transform.render(time: .5), throwsFormatException);
    expect(transform.render().length, 1);
  });

  test(
    'bound animation matches reference at arbitrary times and reduced motion',
    () async {
      final template = SvgTemplate(
        kittySvg,
        keyframes: CssKeyframes.parse(kittyKeyframes),
      );
      for (final kitty in KittyId.values) {
        for (final pose in KittyPose.values) {
          final look = KittyLook(
            kitty: kitty,
            pose: pose,
            facing: KittyFacing.values[kitty.index % 3],
            accessory: AccessoryId
                .values[(kitty.index + pose.index) % AccessoryId.values.length],
            time: 0,
          );
          final vals = kittyVals(look);
          final bound = template.bind(vals);
          for (final time in <double?>[null, .317, 4.416]) {
            final expected = template.render(vals, time: time);
            final actual = bound.render(time: time);
            expect(actual.bounds, expected.bounds, reason: '$look at $time');
            expect(
              await pixels(actual),
              await pixels(expected),
              reason: '$look at $time',
            );
          }
        }
      }
    },
  );

  test('binding snapshots values and preserves nested group opacity', () async {
    final template = SvgTemplate(
      '''<g opacity="0.5"><sc-for list="{{dots}}" as="dot"><circle cx="{{dot.x}}" cy="10" r="8" fill="#ff0000"/><circle cx="{{dot.x}}" cy="13" r="8" fill="#00ff00"/></sc-for></g>''',
    );
    final dots = <Map<String, Object>>[
      {'x': 10},
    ];
    final vals = <String, Object>{'dots': dots};
    final expected = await pixels(template.render(vals));
    final bound = template.bind(vals);
    dots.first['x'] = 70;
    expect(await pixels(bound.render(time: 20)), expected);
  });
}
