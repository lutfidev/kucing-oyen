import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/render.dart';

/// Tepi di luar viewBox 100×100: topi dan gelembung boleh keluar kotak.
const _margin = 40.0;

/// Warna piksel di koordinat sprite desain (x, y).
Future<Color Function(double x, double y)> _sampler(KittyLook look) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..translate(_margin, _margin);
  paintKitty(canvas, look);
  const size = KittyLook.viewBox + 2 * _margin;
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i =
        ((y.floor() + _margin.toInt()) * image.width +
            x.floor() +
            _margin.toInt()) *
        4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

Matcher _near(Color expected, {int tolerance = 2}) => predicate<Color>((c) {
  int ch(double v) => (v * 255).round();
  return (ch(c.r) - ch(expected.r)).abs() <= tolerance &&
      (ch(c.g) - ch(expected.g)).abs() <= tolerance &&
      (ch(c.b) - ch(expected.b)).abs() <= tolerance;
}, 'mendekati $expected');

void main() {
  test('semua kucing, pose, dan aksesoris tergambar', () {
    final canvas = Canvas(PictureRecorder());
    for (final kitty in KittyId.values) {
      for (final pose in KittyPose.values) {
        for (final accessory in <AccessoryId?>[null, ...AccessoryId.values]) {
          paintKitty(
            canvas,
            KittyLook(kitty: kitty, pose: pose, accessory: accessory),
          );
        }
      }
    }
  });

  test('warna bulu badan per kucing', () async {
    final oyen = await _sampler(const KittyLook(kitty: KittyId.oyen));
    // (50; 88) ada di badan, di bawah elips perut.
    expect(oyen(50, 88), _near(_hex(kittyPalette[KittyId.oyen]!.fur)));
    expect(oyen(50, 88), _near(_hex('#F29A3A')));
    final arang = await _sampler(const KittyLook(kitty: KittyId.arang));
    expect(arang(50, 88), _near(_hex('#2E2929')));
  });

  test('pita digambar di kepala kanan', () async {
    final withBow = await _sampler(
      const KittyLook(kitty: KittyId.oyen, accessory: AccessoryId.pita),
    );
    expect(withBow(64, 21), _near(_hex('#D9607A')));
    final plain = await _sampler(const KittyLook(kitty: KittyId.oyen));
    expect(plain(64, 21), isNot(_near(_hex('#D9607A'))));
  });

  test('aksesoris ikut pose: mahkota raja duduk dan tidur', () async {
    final sit = await _sampler(
      const KittyLook(kitty: KittyId.oyen, accessory: AccessoryId.mahkotaRaja),
    );
    expect(sit(50, 18), _near(_hex('#E0453A')));
    final sleep = await _sampler(
      const KittyLook(
        kitty: KittyId.oyen,
        pose: KittyPose.sleep,
        accessory: AccessoryId.mahkotaRaja,
      ),
    );
    // accT desain: translate(-2 30.8) scale(0.72) → permata (50; 18,4).
    expect(sleep(34, 44), _near(_hex('#E0453A')));
  });

  test(
    'lonceng kalung hilang saat rebahan dan lesu; syal juga saat tidur',
    () async {
      final sit = await _sampler(
        const KittyLook(kitty: KittyId.oyen, accessory: AccessoryId.kalung),
      );
      expect(sit(51, 71), _near(_hex('#FFC83D')));
      for (final pose in [KittyPose.rebah, KittyPose.lesu]) {
        final vals = kittyVals(
          KittyLook(
            kitty: KittyId.oyen,
            pose: pose,
            accessory: AccessoryId.kalung,
          ),
        );
        expect(vals['dangleOn'], false, reason: pose.name);
      }
      // Tidur memakai varian kecil yang tetap berlonceng; ujung syal yang
      // disembunyikan (desain 21b).
      final sleeping = kittyVals(
        const KittyLook(
          kitty: KittyId.oyen,
          pose: KittyPose.sleep,
          accessory: AccessoryId.syal,
        ),
      );
      expect(sleeping['dangleOn'], true);
      expect(sleeping['dangle2'], false);
    },
  );

  test('menghadap kanan dicerminkan', () async {
    final down = await _sampler(const KittyLook(kitty: KittyId.oyen));
    expect(down(92, 67), _near(_hex('#E8892B')));
    final right = await _sampler(
      const KittyLook(kitty: KittyId.oyen, facing: KittyFacing.right),
    );
    expect(right(8, 67), _near(_hex('#E8892B')));
    expect(right(92, 67), isNot(_near(_hex('#E8892B'))));
  });

  test('Mochi bertopeng dan Bos bergaris putih', () async {
    final mochi = await _sampler(const KittyLook(kitty: KittyId.mochi));
    final head = _hex(kittyPalette[KittyId.mochi]!.head);
    expect(mochi(36, 58).r, lessThan(head.r));
    expect(kittyPalette[KittyId.mochi]!.maskOn, isTrue);
    final bos = await _sampler(const KittyLook(kitty: KittyId.bos));
    expect(bos(50, 40), _near(const Color(0xFFFFFFFF)));
  });

  test('tanpa waktu (kurangi gerak): semua gaya animasi kosong', () {
    final vals = kittyVals(const KittyLook(kitty: KittyId.oyen));
    for (final key in ['tailStyle', 'blinkStyle', 'headAnim', 'zzzAnim']) {
      expect(vals[key], '', reason: key);
    }
    expect(vals['noteOn'], isFalse);
  });

  test('dengan waktu: gaya animasi desain, jeda kedip per kucing', () {
    final arang = kittyVals(const KittyLook(kitty: KittyId.arang, time: 0));
    expect(
      arang['blinkStyle'],
      'transform-box: fill-box; transform-origin: center; '
      'animation: kcBlink 4.6s infinite; animation-delay: -1.3s',
    );
    expect(
      arang['tailStyle'],
      'transform-origin: 73px 77px; animation: kcTail 2.6s ease-in-out infinite',
    );
    final happy = kittyVals(
      const KittyLook(kitty: KittyId.oyen, pose: KittyPose.happy, time: 0),
    );
    expect(happy['tailStyle'], contains('kcWag 0.9s'));
    // Mata senang tidak berkedip (desain: hanya mata terbuka).
    expect(happy['blinkStyle'], '');
  });

  test('kedip: mata Oyen tertutup di tengah kedip', () async {
    const look = KittyLook(kitty: KittyId.oyen);
    final eye = _hex(kittyPalette[KittyId.oyen]!.eye);
    final open = await _sampler(look.copyWith(time: 0));
    expect(open(37, 48.5), _near(eye));
    final shut = await _sampler(look.copyWith(time: 4.6 * 0.96));
    expect(shut(37, 48.5), isNot(_near(eye, tolerance: 30)));
  });

  test('ekor bergerak: gambar Arang di −8° beda dari diam', () async {
    const look = KittyLook(kitty: KittyId.arang);
    Future<List<int>> pixels(KittyLook l) async {
      final recorder = PictureRecorder();
      paintKitty(Canvas(recorder), l);
      final image = await recorder.endRecording().toImage(100, 100);
      return (await image.toByteData())!.buffer.asUint8List();
    }

    final still = await pixels(look);
    // Ekor tanpa delay: puncak −8° di 50% dari 2,6 detik, lurus di awal.
    expect(await pixels(look.copyWith(time: 1.3)), isNot(still));
    expect(await pixels(look.copyWith(time: 0)), still);
  });

  test('bingkai jalan bergantian tiap 220 ms', () {
    expect(KittyLook.walkPose(0.1), KittyPose.walk1);
    expect(KittyLook.walkPose(0.3), KittyPose.walk2);
    expect(KittyLook.walkPose(0.5), KittyPose.walk1);
  });

  test('sprite diam di-cache, sprite bergerak tidak', () {
    const look = KittyLook(kitty: KittyId.oyen);
    expect(identical(kittyDrawing(look), kittyDrawing(look)), isTrue);
    final moving = look.copyWith(time: 1);
    expect(identical(kittyDrawing(moving), kittyDrawing(moving)), isFalse);
    expect(look.copyWith(time: 1).copyWith(still: true), look);
  });
}
