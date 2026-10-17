import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/theme/theme.dart';

/// Skala gambar uji: titik di koordinat desain dikali 4 supaya tepi bentuk
/// tidak ikut tersampel.
const _scale = 4.0;

typedef _Sampler = Color Function(double x, double y);

Future<_Sampler> _render(
  void Function(Canvas canvas) paint, {
  double size = ItemArt.viewBox,
  double margin = 0,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(_scale)
    ..translate(margin, margin);
  paint(canvas);
  final side = ((size + 2 * margin) * _scale).toInt();
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final px = ((x + margin) * _scale).floor();
    final py = ((y + margin) * _scale).floor();
    final i = (py * side + px) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

Matcher _near(int argb) => predicate<Color>((c) {
  final expected = Color(argb);
  int ch(double v) => (v * 255).round();
  return (ch(c.a) - ch(expected.a)).abs() <= 2 &&
      (ch(c.r) - ch(expected.r)).abs() <= 2 &&
      (ch(c.g) - ch(expected.g)).abs() <= 2 &&
      (ch(c.b) - ch(expected.b)).abs() <= 2;
}, 'mendekati ${Color(argb)}');

final _transparent = predicate<Color>((c) => c.a == 0, 'transparan');

void main() {
  test('benda pemain di petak memakai gambar bercincin', () {
    expect(ItemArt.tileItem(Item.fish), TileItem.fishP);
    expect(ItemArt.tileItem(Item.water), TileItem.bucketP);
    expect(ItemArt.tileItem(Item.box), TileItem.boxP);
  });

  group('gambar slot baki (desain 03)', () {
    // Titik ikan di koordinat grupnya, diputar -24° di (25, 25) seperti
    // `rotate(-24 25 25)`: (16, 25) badan, (13, 24) mata, (6, 25) cincin.
    const body = (16.78, 28.66);
    const eye = (13.63, 28.97);
    const ring = (7.64, 32.73);

    test('ikan: badan, mata, dan cincin oranye', () async {
      final at = await _render((c) => paintItemArt(c, Item.fish));
      expect(at(body.$1, body.$2), _near(0xFFCDB892));
      expect(at(eye.$1, eye.$2), _near(0xFF3A2618));
      expect(at(ring.$1, ring.$2), _near(0xFFF28C28));
    });

    test('bayangan ikan tanpa cincin', () async {
      final at = await _render((c) => paintItemArt(c, Item.fish, ghost: true));
      expect(at(body.$1, body.$2), _near(0xFFCDB892));
      expect(at(ring.$1, ring.$2), _transparent);
    });

    test('ember: air, cincin oranye di atas lingkaran krem', () async {
      final at = await _render((c) => paintItemArt(c, Item.water));
      expect(at(25, 20), _near(0xFF8FD3F0));
      expect(at(25, 38), _near(0xFF2F86B8));
      expect(at(25, 40.6), _near(0xFFFFFBF3));
      expect(at(25, 43), _near(0xFFF28C28));
    });

    test('bayangan ember tanpa cincin dan lingkaran krem', () async {
      final at = await _render((c) => paintItemArt(c, Item.water, ghost: true));
      expect(at(25, 20), _near(0xFF8FD3F0));
      expect(at(25, 38), _near(0xFF2F86B8));
      expect(at(25, 40.6), _transparent);
      expect(at(25, 43), _transparent);
    });

    test('kardus bercincin, bayangannya tanpa cincin', () async {
      final box = await _render((c) => paintItemArt(c, Item.box));
      expect(box(25, 25), _near(0xFF7E5228));
      expect(box(10, 25), _near(0xFFC8955A));
      expect(box(4.5, 25), _near(0xFFF28C28));
      expect(box(2, 25), _transparent);

      final ghost = await _render(
        (c) => paintItemArt(c, Item.box, ghost: true),
      );
      expect(ghost(25, 25), _near(0xFF7E5228));
      expect(ghost(4.5, 25), _transparent);
    });
  });

  test('benda diseret: miring, membesar, dengan bayangan jatuh', () async {
    const margin = 20.0;
    final at = await _render(
      (c) =>
          paintLiftedItem(c, Item.water, shadow: KoColors.standard.shadowLift),
      size: ItemArt.liftSize,
      margin: margin,
    );
    // (25, 20) gambar ember = 5 px di atas pusat, dikali 64/50 × 1,12 lalu
    // diputar -8°: (31, 24,9) di kotak 64 px.
    expect(at(31, 24.9), _near(0xFF8FD3F0));
    // Cincin bawah ember (r 18) tanpa miring ada di y = 32 + 18 × 1,43.
    expect(at(32, 32 + 18 * 1.4336), _near(0xFFF28C28));
    // Bayangan jatuh 12 px ke bawah dikali skala: di bawah kotak 64 px.
    expect(at(32, 70).a, greaterThan(0));
    expect(at(-15, -15), _transparent);
  });

  group('koin (desain 01 dan 10)', () {
    test('koin dengan huruf S', () async {
      final at = await _render(paintCoin, size: CoinArt.viewBox);
      expect(at(14, 4), _near(0xFFFFC83D));
      expect(at(14, 5.5), _near(0xFFE0A100));
      expect(at(14, 14.5), _near(0xFFB57F00));
      expect(at(1, 1), _transparent);
    });

    test('koin polos tanpa huruf', () async {
      final at = await _render(
        (canvas) => paintCoin(canvas, plain: true),
        size: CoinArt.viewBox,
      );
      expect(at(14, 14.5), _near(0xFFFFC83D));
      expect(at(14, 5.5), _near(0xFFE0A100));
    });
  });
}
