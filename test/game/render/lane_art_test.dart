import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/render/house_art.dart';
import 'package:kucing_oren/game/render/lane_art.dart';

/// Warna piksel di koordinat desain (x, y) sesudah [paint] di kanvas
/// 390×652.
Future<Color> _pixel(void Function(Canvas) paint, double x, double y) async {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(390, 652);
  final bytes = (await image.toByteData())!;
  final i = (y.floor() * 390 + x.floor()) * 4;
  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

void Function(Canvas) _layer(LaneLayer layer) =>
    (c) => paintLaneLayer(c, layer, size: laneViewBox);

void main() {
  test('tenda warung merah di latar gang', () async {
    // `LatarGang.dc.html`: sisi tenda (50,4, 128,8)–(60,8, 156,2) #D9574A.
    expect(
      await _pixel(_layer(LaneLayer.back), 55, 145),
      const Color(0xFFD9574A),
    );
  });

  test(
    'dudukan bangku di lapisan belakang, tepinya di lapisan depan',
    () async {
      // `Bangku.dc.html`: dudukan #D4A170, tepi depan #B07A4F di y 406–415.
      expect(
        await _pixel(_layer(LaneLayer.benchBack), 160, 397),
        const Color(0xFFD4A170),
      );
      expect(
        await _pixel(_layer(LaneLayer.benchBack), 160, 412),
        isA<Color>().having((c) => c.a, 'alfa', 0),
      );
      expect(
        await _pixel(_layer(LaneLayer.benchFront), 160, 412),
        const Color(0xFFB07A4F),
      );
    },
  );

  test('kusen pintu pulang di tepi kanan', () async {
    expect(
      await _pixel(_layer(LaneLayer.frame), 388, 300),
      const Color(0xFFC99466),
    );
  });

  test('lapisan diam tidak digambar ulang tiap bingkai', () {
    expect(laneLayerAnimated(LaneLayer.frame), isFalse);
    expect(laneLayerAnimated(LaneLayer.benchBack), isFalse);
    expect(laneLayerAnimated(LaneLayer.back), isTrue);
    expect(laneLayerAnimated(LaneLayer.airLight), isTrue);
  });

  test('kusen ruang tengah memuat kusen pintu depan (kiri)', () async {
    // `KusenDepan.dc.html`: kusen (−2..9, 189..503) di tepi kiri.
    final color = await _pixel(
      (c) => paintHouseLayer(
        c,
        HouseRoom.living,
        HouseLayer.frame,
        size: houseViewBox,
      ),
      4,
      300,
    );
    expect(color.a, 1);
  });

  test(
    'ekor Kumis: ujung bengkok gelap, bergoyang di sekitar pangkalnya',
    () async {
      // `AdeganTengah.dc.html`: ujung ekor #55657A, kurva (52,2, 397,2) →
      // (62,2, 392,2); tengahnya di sekitar (56, 392,5).
      void still(Canvas c) => paintKumisTail(c, size: laneViewBox);
      expect(await _pixel(still, 56, 392), const Color(0xFF55657A));
      // Goyang ±8°: titik yang sama tidak selalu tertutup ekor.
      final a = await _pixel(
        (c) => paintKumisTail(c, size: laneViewBox, time: 0),
        62,
        392,
      );
      final b = await _pixel(
        (c) => paintKumisTail(c, size: laneViewBox, time: 0.55),
        62,
        392,
      );
      expect(a, isNot(b));
    },
  );
}
