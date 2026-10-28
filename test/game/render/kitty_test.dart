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

  test('tanpa gerakan: semua gaya animasi kosong di langkah ini', () {
    final vals = kittyVals(const KittyLook(kitty: KittyId.oyen));
    for (final key in ['tailStyle', 'blinkStyle', 'headAnim', 'zzzAnim']) {
      expect(vals[key], '', reason: key);
    }
  });

  test('waktu belum mengubah gambar, jadi aman jadi kunci cache', () {
    const look = KittyLook(kitty: KittyId.oyen, pose: KittyPose.walk1);
    expect(
      kittyVals(look.copyWith(time: 3.5)).toString(),
      kittyVals(look).toString(),
    );
  });
}
