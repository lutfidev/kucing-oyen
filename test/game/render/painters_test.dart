import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';

/// Gambar papan ke piksel, dengan tepi 10 px untuk bingkainya.
Future<Image> _renderBoard(BoardScene scene) async {
  const margin = 10.0;
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..translate(margin, margin);
  paintBoardFrame(canvas);
  paintBoard(canvas, scene);
  return recorder.endRecording().toImage(
    (BoardScene.width + 2 * margin).toInt(),
    (BoardScene.height + 2 * margin).toInt(),
  );
}

/// Warna piksel di koordinat papan desain (x, y).
Future<Color Function(double x, double y)> _sampler(Image image) async {
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i = ((y.floor() + 10) * image.width + x.floor() + 10) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

Matcher _near(Color expected, {int tolerance = 2}) => predicate<Color>((c) {
  int ch(double v) => (v * 255).round();
  return (ch(c.r) - ch(expected.r)).abs() <= tolerance &&
      (ch(c.g) - ch(expected.g)).abs() <= tolerance &&
      (ch(c.b) - ch(expected.b)).abs() <= tolerance;
}, 'mendekati $expected');

void main() {
  test('semua kombinasi petak tergambar', () {
    final canvas = Canvas(PictureRecorder());
    for (final kind in TileKind.values) {
      for (final item in TileItem.values) {
        for (final alt in [false, true]) {
          for (final glow in [false, true]) {
            paintTile(
              canvas,
              Tile(kind: kind, item: item, alt: alt, glow: glow),
              glowOpacity: 0.5,
            );
          }
        }
      }
    }
  });

  test('semua kombinasi Oyen tergambar', () {
    final canvas = Canvas(PictureRecorder());
    for (final pose in OyenPose.values) {
      for (final dir in Direction.values) {
        for (final costume in OyenCostume.values) {
          for (final bubble in OyenBubble.values) {
            paintOyen(
              canvas,
              OyenLook(pose: pose, dir: dir, costume: costume, bubble: bubble),
              size: 62,
            );
          }
        }
      }
    }
  });

  test('renderVals petak mengikuti Tile.dc.html', () {
    final wall = tileVals(const Tile(kind: TileKind.shelf));
    expect(wall['hasFloor'], isFalse);
    expect(wall['isWallish'], isTrue);
    expect(wall['isShelf'], isTrue);

    final vase = tileVals(const Tile(kind: TileKind.tableVase, alt: true));
    expect(vase['isTable'], isTrue);
    expect(vase['isVase'], isTrue);
    expect(vase['floorFill'], '#F1DDBA');

    final fishP = tileVals(const Tile(item: TileItem.fishP));
    expect(fishP['itemFish'], isTrue);
    expect(fishP['player'], isTrue);
    expect(fishP['floorFill'], '#F7E8CE');

    final bucket = tileVals(const Tile(item: TileItem.bucketP));
    expect(bucket['itemBucket'], isTrue);
    expect(bucket['itemWater'], isFalse);
    expect(bucket['player'], isFalse);
  });

  test('renderVals Oyen mengikuti Oyen.dc.html', () {
    final right = oyenVals(
      const OyenLook(pose: OyenPose.walk, dir: Direction.right),
    );
    expect(right['flipT'], 'translate(100 0) scale(-1 1)');
    expect(right['headT'], 'translate(-5 0)');
    expect(right['faceT'], 'translate(-4 1)');
    expect(right['pawL'], 85);
    expect(right['pawR'], 91);

    final up = oyenVals(const OyenLook(dir: Direction.up));
    expect(up['back'], isTrue);
    expect(up['showTailBack'], isTrue);
    expect(up['showTailSide'], isFalse);

    final sleep = oyenVals(
      const OyenLook(
        pose: OyenPose.sleep,
        dir: Direction.left,
        costume: OyenCostume.peci,
        bubble: OyenBubble.zzz,
      ),
    );
    expect(sleep['notSleep'], isFalse);
    expect(sleep['headT'], 'translate(0 0)');
    expect(sleep['zzzT'], 'translate(-26 16)');
    expect(sleep['showPeci'], isFalse);

    final box = oyenVals(
      const OyenLook(
        pose: OyenPose.box,
        dir: Direction.up,
        costume: OyenCostume.sarung,
      ),
    );
    expect(box['back'], isFalse);
    expect(box['headT'], 'translate(0 8)');
    expect(box['showSarung'], isFalse);

    final shock = oyenVals(const OyenLook(pose: OyenPose.shock));
    expect(shock['headT'], 'translate(0 -3)');
    expect(shock['bodyY'], 69);
    expect(shock['eyeWide'], isTrue);
    expect(shock['mouthO'], isTrue);
    expect(shock['eyeSleepy'], isFalse);

    final glasses = oyenVals(
      const OyenLook(dir: Direction.up, costume: OyenCostume.kacamata),
    );
    expect(glasses['showGlasses'], isFalse);
  });

  test('kedip petak menyala: 1 → 0,45 → 1 tiap detik', () {
    expect(tileGlowOpacity(0), 1);
    expect(tileGlowOpacity(0.25), closeTo(0.725, 1e-9));
    expect(tileGlowOpacity(0.5), closeTo(0.45, 1e-9));
    expect(tileGlowOpacity(0.75), closeTo(0.725, 1e-9));
    expect(tileGlowOpacity(1.5), closeTo(0.45, 1e-9));
  });

  // Warna di koordinat yang dihitung dari angka Board.dc.html, Tile.dc.html,
  // dan Oyen.dc.html (petak 50 px, Oyen 62 px di (kolom·50 − 6,
  // baris·50 − 12), panah 18 px di tepi petak, cincin 4 px, sudut 16 px).
  test('piksel papan cocok dengan angka desain', () async {
    final scene = BoardScene.fromMap(
      BoardScene.designMap,
      glow: {const Pos(3, 3)},
    );
    final at = await _sampler(await _renderBoard(scene));

    // Lantai (1,1) biasa, (2,1) selang.
    expect(at(75, 75), _near(const Color(0xFFF7E8CE)));
    expect(at(125, 75), _near(const Color(0xFFF1DDBA)));
    // Bata tembok (0,4), lemari di dalam ruangan (3,1), kulkas (3,0).
    expect(at(5, 205), _near(const Color(0xFFB07A4F)));
    expect(at(160, 70), _near(const Color(0xFFC99466)));
    expect(at(175, 30), _near(const Color(0xFFEEF3F2)));
    // Petak menyala (3,3): #F59A33 28% di atas lantai #F7E8CE.
    expect(at(175, 175), _near(const Color(0xFFF6D2A3)));
    // Badan Oyen tidur, titik (80, 70) sprite: 194 + 80·0,62, 138 + 70·0,62.
    expect(at(244, 181), _near(const Color(0xFFF29A3A)));
    // Panah arah hadap kiri berpusat di (200, 175): isi oranye, cincin krem.
    expect(at(200, 182), _near(const Color(0xFFF59A33)));
    expect(at(200, 184), _near(const Color(0xFFFFFBF3)));
    // Cincin bingkai di luar papan dan di sudut yang terpotong.
    expect(at(-2, 225), _near(const Color(0xFF5E3B22)));
    expect(at(3, 3), _near(const Color(0xFF5E3B22)));
  });

  test('piksel Oyen berjalan dan benda pemain', () async {
    final scene = BoardScene.fromMap(
      BoardScene.designMap,
      items: {const Pos(3, 3): TileItem.bucketP},
      oyen: BoardOyen.at(
        const Pos(4, 4),
        const OyenLook(pose: OyenPose.walk, dir: Direction.left),
      ),
    );
    final at = await _sampler(await _renderBoard(scene));

    // Cincin oranye ember pemain: lingkaran r 18 di tengah petak (3,3).
    expect(at(175 + 18, 175), _near(const Color(0xFFF28C28)));
    // Air di ember.
    expect(at(175, 180), _near(const Color(0xFF8FD3F0)));
    // Perut Oyen (50, 77) sprite → 194 + 31, 188 + 47,74.
    expect(at(225, 236), _near(const Color(0xFFFBD9A8)));
  });

  test('piksel jalur Oyen: putus-putus 2 9 lewat tengah petak', () async {
    final scene = BoardScene.fromMap(
      BoardScene.designMap,
      showOyen: false,
      path: const [Pos(4, 3), Pos(5, 3), Pos(5, 4)],
    );
    final at = await _sampler(await _renderBoard(scene));
    const line = Color(0xFFE07A10);
    // Garis dari (225, 175): titik di 225–227, celah 9, titik 236–238.
    expect(at(226, 175), _near(line));
    expect(at(232, 175), _near(const Color(0xFFF1DDBA)));
    expect(at(237, 175), _near(line));
    // Tebal 4: 2 px di atas dan bawah garis.
    expect(at(226, 172), _near(const Color(0xFFF1DDBA)));
  });

  test('piksel nomor jejak putar ulang: pill 20 px di (3, 3)', () async {
    final scene = BoardScene.fromMap(
      BoardScene.designMap,
      showOyen: false,
      trail: const [
        BoardMark(Pos(1, 5), '12'),
        BoardMark(Pos(2, 5), '4', active: true),
      ],
    );
    final at = await _sampler(await _renderBoard(scene));
    // Tidak menyala: isi krem dengan cincin 1,5 px oranye tua.
    expect(at(52, 263), _near(const Color(0xFFE07A10)));
    expect(at(55, 263), _near(const Color(0xFFFFFBF3)));
    // Menyala: isi gelap dengan cincin 2 px oranye.
    expect(at(102, 263), _near(const Color(0xFFF59A33)));
    expect(at(105, 263), _near(const Color(0xFF3B2716)));
    // Tinggi 20: dari y 253 sampai 273, lalu lantai lagi.
    expect(at(113, 254), _near(const Color(0xFF3B2716)));
    expect(at(113, 278), isNot(_near(const Color(0xFF3B2716))));
  });

  group('Oyen fase jalan (tidak ada di desain)', () {
    /// Oyen 200 px (2 px per satuan viewBox) dengan tepi 60 px untuk
    /// gelembung; mengembalikan warna di titik viewBox (x, y).
    Future<Color Function(double x, double y)> renderOyen(OyenLook look) async {
      const margin = 60;
      const side = 200 + 2 * margin;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..translate(margin.toDouble(), margin.toDouble());
      paintOyen(canvas, look, size: 200);
      final image = await recorder.endRecording().toImage(side, side);
      final bytes = (await image.toByteData())!;
      return (x, y) {
        final i = ((y * 2).floor() + margin) * side + (x * 2).floor() + margin;
        return Color.fromARGB(
          bytes.getUint8(i * 4 + 3),
          bytes.getUint8(i * 4),
          bytes.getUint8(i * 4 + 1),
          bytes.getUint8(i * 4 + 2),
        );
      };
    }

    test('gelembung ikan di tempat gelembung kaget', () async {
      final at = await renderOyen(
        const OyenLook(
          pose: OyenPose.walk,
          dir: Direction.left,
          bubble: OyenBubble.ikan,
        ),
      );
      // Lingkaran besar (98, -12) r 13,5: putih di atas ikan, garis di tepi.
      expect(at(98, -23), _near(const Color(0xFFFFFFFF)));
      expect(at(98, -25.3), _near(const Color(0xFF3A2618)));
      // Badan ikan (17, 25) petak → diputar -24°, diperkecil 0,6 ke pusat
      // gelembung: (93,3; -10,05).
      expect(at(93.3, -10.05), _near(const Color(0xFFCDB892)));
    });

    test('dicerminkan: tangan menjatuhkan pindah ke kiri', () async {
      const knock = OyenLook(pose: OyenPose.knock);
      final normal = await renderOyen(knock);
      final mirrored = await renderOyen(knock.copyWith(mirror: true));
      // Telapak tangan (89, 50) jadi (11, 50).
      expect(normal(89, 50), _near(const Color(0xFFFBD9A8)));
      expect(normal(11, 50).a, 0);
      expect(mirrored(11, 50), _near(const Color(0xFFFBD9A8)));
      expect(mirrored(89, 50).a, 0);
    });
  });
}
