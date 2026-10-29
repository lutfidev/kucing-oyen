import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/render/render.dart';

/// Warna piksel di koordinat gambar barang (0,0 = pojok kiri atas gambar).
Future<Color Function(double x, double y)> _sampler(
  void Function(Canvas canvas) paint,
  Size size,
) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(
    size.width.ceil(),
    size.height.ceil(),
  );
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i = (y.floor() * image.width + x.floor()) * 4;
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
  test('semua barang, camilan, dan ikon aksesoris tergambar', () {
    final canvas = Canvas(PictureRecorder());
    for (final id in RoomItemId.values) {
      paintRoomItemArt(canvas, id);
      paintRoomItemArt(canvas, id, box: const Size(128, 80));
    }
    for (final id in SnackId.values) {
      paintSnackArt(canvas, id);
      paintSnackArt(canvas, id, box: const Size(52, 40));
    }
    for (final id in <AccessoryId?>[null, ...AccessoryId.values]) {
      paintAccessoryIcon(canvas, id);
    }
  });

  test('ukuran gambar sama dengan desain', () {
    expect(RoomItemArt.sizeOf(RoomItemId.kasur), const Size(150, 76));
    expect(RoomItemArt.sizeOf(RoomItemId.kardus), const Size(122, 82));
    expect(RoomItemArt.sizeOf(RoomItemId.tiang), const Size(50, 152));
    expect(RoomItemArt.sizeOf(RoomItemId.mangkuk), const Size(54, 30));
    expect(RoomItemArt.snackSizeOf(SnackId.susu), const Size(42, 20));
    expect(RoomItemArt.snackSizeOf(SnackId.puding), const Size(40, 34));
  });

  test('lapisan depan digambar di atas lapisan belakang', () async {
    final sample = await _sampler(
      (canvas) => paintRoomItemArt(canvas, RoomItemId.kardus),
      RoomItemArt.sizeOf(RoomItemId.kardus),
    );
    // Tutup belakang #7E5228 dan badan kardus depan #C8955A bertumpuk di
    // (40; 28) koordinat desain; viewBox mulai di x -6.
    expect(sample(46, 28), _near(_hex('#C8955A')));
  });

  test('mangkuk kosong beda dari mangkuk penuh', () async {
    final size = RoomItemArt.sizeOf(RoomItemId.mangkuk);
    final full = await _sampler(
      (canvas) => paintRoomItemArt(canvas, RoomItemId.mangkuk),
      size,
    );
    final empty = await _sampler(
      (canvas) => paintRoomItemArt(canvas, RoomItemId.mangkuk, full: false),
      size,
    );
    expect(full(27, 7), _near(_hex('#B07A4F')));
    expect(empty(27, 9), _near(_hex('#1F5E80')));
  });

  test('camilan tergambar di ukurannya sendiri', () async {
    final sample = await _sampler(
      (canvas) => paintSnackArt(canvas, SnackId.ikanAsin),
      RoomItemArt.snackSizeOf(SnackId.ikanAsin),
    );
    expect(sample(16, 11), _near(_hex('#D9C08E')));
  });

  test('fitScale mengecilkan ke kotak kartu dan dibatasi 2,2', () {
    expect(
      RoomItemArt.fitScale(const Size(150, 76), const Size(128, 80)),
      closeTo(128 / 150, 1e-9),
    );
    expect(
      RoomItemArt.fitScale(const Size(122, 132), const Size(220, 130)),
      closeTo(130 / 132, 1e-9),
    );
    expect(
      RoomItemArt.fitScale(const Size(32, 30), const Size(128, 80)),
      RoomItemArt.maxScale,
    );
  });

  test('gambar dipusatkan dan diskalakan di dalam kotaknya', () async {
    const box = Size(128, 80);
    final sample = await _sampler(
      (canvas) => paintRoomItemArt(canvas, RoomItemId.mangkuk, box: box),
      box,
    );
    // Mangkuk 54×30 diskala 2,2 jadi 118,8×66 dan dipusatkan: isi mangkuk
    // ada di tengah kotak.
    expect(sample(64, 23), _near(_hex('#B07A4F')));
    expect(sample(2, 2).a, 0);
  });

  test('ikon aksesoris memakai viewBox 48', () async {
    const size = Size(AccessoryIconArt.viewBox, AccessoryIconArt.viewBox);
    final bow = await _sampler(
      (canvas) => paintAccessoryIcon(canvas, AccessoryId.pita),
      size,
    );
    expect(bow(24, 23), _near(_hex('#D9607A')));
    final none = await _sampler(
      (canvas) => paintAccessoryIcon(canvas, null),
      size,
    );
    expect(none(24, 24), _near(_hex('#CDB48C')));
  });

  group('dipakai dan bergerak', () {
    Future<List<int>> pixels(void Function(Canvas) paint, Size size) async {
      final recorder = PictureRecorder();
      paint(Canvas(recorder));
      final image = await recorder.endRecording().toImage(
        size.width.ceil(),
        size.height.ceil(),
      );
      return (await image.toByteData())!.buffer.asUint8List();
    }

    const oyen = KittyLook(kitty: KittyId.oyen);

    test('kotak dipakai mengikuti tabel desain', () {
      expect(
        RoomItemArt.inUseBox(
          RoomItemId.kardus,
          const Rect.fromLTWH(0, 42, 122, 82),
        ),
        const Rect.fromLTWH(0, 0, 122, 124),
      );
      // Skala ikut kotak diam: kasur ×0,85 seperti kamar desain.
      final box = RoomItemArt.inUseBox(
        RoomItemId.kasur,
        const Rect.fromLTWH(246, 448, 150 * 0.85, 76 * 0.85),
      );
      expect(box.top, closeTo(448 - 36 * 0.85, 1e-9));
      expect(box.width, closeTo(150 * 0.85, 1e-9));
      expect(box.height, closeTo(112 * 0.85, 1e-9));
      for (final id in RoomItemId.values) {
        expect(RoomItemArt.inUse(id).size.width, greaterThan(0));
      }
    });

    test('semua barang dipakai semua kucing tergambar', () {
      final canvas = Canvas(PictureRecorder());
      for (final id in RoomItemId.values) {
        for (final kitty in KittyId.values) {
          paintRoomItemArt(canvas, id, user: KittyLook(kitty: kitty, time: 1));
        }
      }
    });

    test('bola dipakai: bola lantai disembunyikan, kucing main', () async {
      const size = Size(110, 100);
      final used = await _sampler(
        (c) => paintRoomItemArt(c, RoomItemId.bola, user: oyen),
        size,
      );
      final cat = await _sampler(
        (c) => paintKitty(
          c,
          const KittyLook(
            kitty: KittyId.oyen,
            pose: KittyPose.play,
            toy: KittyToy.ball,
          ),
        ),
        size,
      );
      for (final (x, y) in [(50.0, 60.0), (20.0, 80.0), (80.0, 85.0)]) {
        expect(used(x, y), cat(x, y), reason: '($x, $y)');
      }
    });

    test('kucing di antara lapisan: depan kardus menutupi badan', () async {
      final used = await _sampler(
        (c) => paintRoomItemArt(c, RoomItemId.kardus, user: oyen),
        const Size(122, 124),
      );
      // Depan kardus (rect 6,24 98×56 di viewBox −6) bergeser 42 ke bawah.
      expect(used(30, 42 + 40), _near(_hex('#C8955A')));
    });

    test('catnip bergoyang: setengah periode beda dari diam', () async {
      const size = Size(52, 74);
      void paint(Canvas c, double? t) =>
          paintRoomItemArt(c, RoomItemId.catnip, time: t);
      final still = await pixels((c) => paint(c, null), size);
      expect(await pixels((c) => paint(c, 0), size), isNot(still));
      expect(await pixels((c) => paint(c, 1.6), size), isNot(still));
    });

    test('hammock berayun walau tidak dipakai', () async {
      const size = Size(120, 70);
      final still = await pixels(
        (c) => paintRoomItemArt(c, RoomItemId.hammock),
        size,
      );
      final swung = await pixels(
        (c) => paintRoomItemArt(c, RoomItemId.hammock, time: 0),
        size,
      );
      expect(swung, isNot(still));
    });
  });
}
