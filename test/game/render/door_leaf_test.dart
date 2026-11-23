import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/door_leaf.dart';

Matcher _at(double x, double y) => predicate<({double x, double y})>(
  (p) => (p.x - x).abs() <= 0.6 && (p.y - y).abs() <= 0.6,
  'mendekati ($x, $y)',
);

/// Warna piksel di koordinat desain 390×652 sesudah [paint].
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

void main() {
  test('pintu depan tertutup = bukaan dinding kiri (kPintuDepan)', () {
    const f = DoorLeafSide.front;
    expect(doorLeafPoint(f, 0, 0, 0), _at(70, 212));
    expect(doorLeafPoint(f, 0, 1, 0), _at(8, 203));
    expect(doorLeafPoint(f, 0, 1, 1), _at(8, 489));
    expect(doorLeafPoint(f, 0, 0, 1), _at(70, 403));
  });

  test('pintu pulang tertutup = bukaan dinding kanan, terbuka 8° di x 363', () {
    const h = DoorLeafSide.home;
    expect(doorLeafPoint(h, 0, 0, 0), _at(320, 212));
    expect(doorLeafPoint(h, 0, 1, 0), _at(382, 203));
    expect(doorLeafPoint(h, 0, 1, 1), _at(382, 489));
    expect(doorLeafPoint(h, 0, 0, 1), _at(320, 403));
    expect(doorLeafPoint(h, 8, 1, 0).x, closeTo(363, 0.6));
  });

  test('pintu kucing tertutup (kPintuDepan)', () {
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 0, 0), _at(61, 344));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 1, 0), _at(25, 375));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 1, 1), _at(25, 455));
    expect(doorFlapPoint(DoorLeafSide.front, 0, 0, 0, 1), _at(61, 407));
  });

  test('sisi yang terlihat berganti di sekitar 27°', () {
    expect(doorShowsOutside(DoorLeafSide.front, 0), isFalse);
    expect(doorShowsOutside(DoorLeafSide.front, 20), isFalse);
    expect(doorShowsOutside(DoorLeafSide.front, 40), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 0), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 20), isTrue);
    expect(doorShowsOutside(DoorLeafSide.home, 40), isFalse);
  });

  test('daun pintu depan tertutup bercat kayu di tengah daun', () async {
    final color = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0, flapDeg: 0),
      45,
      323,
    );
    expect(color, const Color(0xFFC99466));
  });

  test('tanpa pintu kucing (flapDeg null) lubangnya tembus', () async {
    // Tengah lubang pintu kucing: u 0,5, v 0,8.
    final p = doorLeafPoint(DoorLeafSide.front, 0, 0.5, 0.8);
    final open = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0),
      p.x,
      p.y,
    );
    expect(open.a, 0);
    final closed = await _pixel(
      (c) => paintDoorLeaf(c, DoorLeafSide.front, angleDeg: 0, flapDeg: 0),
      p.x,
      p.y,
    );
    expect(closed.a, greaterThan(0.9));
  });

  group('daun pintu menutup gambar di belakangnya', () {
    // Kasur bawaan `AdeganTengah` `barang('kasur', 118, 434)`: 150×76 ×
    // skala kedalaman 0,815 di kaki y 434.
    const s = 0.75 + 0.4 * (434 - 392) / 260;
    const bed = DoorCoverTarget(
      Rect.fromLTWH(118, 434 - 76 * s, 150 * s, 76 * s),
      feet: 434,
    );

    /// Piksel daun yang tergambar di atas [targets] pada [deg].
    Future<int> covered(
      double deg,
      List<DoorCoverTarget> targets, {
      DoorLeafSide side = DoorLeafSide.front,
    }) async {
      final recorder = PictureRecorder();
      paintDoorLeafCover(
        Canvas(recorder),
        side,
        angleDeg: deg,
        flapDeg: 0,
        targets: targets,
      );
      final image = await recorder.endRecording().toImage(390, 652);
      final bytes = (await image.toByteData())!;
      var n = 0;
      for (var i = 3; i < bytes.lengthInBytes; i += 4) {
        if (bytes.getUint8(i) > 0) n++;
      }
      return n;
    }

    test('pintu tertutup tidak menutup kasur', () async {
      expect(await covered(0, const [bed]), 0);
    });

    test('70–88°: tepi daun menutup bagian belakang kasur, bertahap', () async {
      final area = bed.box.width * bed.box.height;
      final out = [
        for (var d = 70; d <= 88; d++) await covered(d.toDouble(), const [bed]),
      ];
      final back = [
        for (var d = 88; d >= 70; d--) await covered(d.toDouble(), const [bed]),
      ];
      expect(out.first, greaterThan(0));
      // Pergi dan pulang melewati bingkai yang sama.
      expect(back.reversed.toList(), out);
      for (var i = 1; i < out.length; i++) {
        // Tidak ada lompatan: per derajat berubah < 4% luas kasur.
        expect(
          (out[i] - out[i - 1]).abs(),
          lessThan(area * 0.04),
          reason: '${70 + i}°',
        );
      }
      // Bagian depan kasur (di depan bidang daun) tetap di atas daun.
      expect(out.every((n) => n < area * 0.5), isTrue);
    });

    test(
      '0–70°: tutupan mulai dari nol dan naik pelan saat tepi lewat',
      () async {
        final area = bed.box.width * bed.box.height;
        var last = 0;
        for (var d = 0; d <= 70; d++) {
          final n = await covered(d.toDouble(), const [bed]);
          expect((n - last).abs(), lessThan(area * 0.04), reason: '$d°');
          last = n;
        }
      },
    );

    test(
      'kamar berisi: tiang di kanan dan kucing di depan pintu tidak tertutup',
      () async {
        // Tiang bawaan kaki (285,6, 414), 50×152 × skala; kucing di ambang
        // (70, 470) tegak di depan daun.
        const t = 0.75 + 0.4 * (414 - 392) / 260;
        const tiang = DoorCoverTarget(
          Rect.fromLTWH(266, 414 - 152 * t, 50 * t, 152 * t),
          feet: 414,
        );
        const cat = DoorCoverTarget(
          Rect.fromLTWH(30, 380, 90, 90),
          feet: 470,
          depth: DoorCoverTarget.upright,
        );
        for (var d = 70; d <= 88; d++) {
          expect(
            await covered(d.toDouble(), const [tiang, cat]),
            0,
            reason: '$d°',
          );
        }
      },
    );

    test(
      'pintu pulang: kucing di belakang bidang daun tertutup, di depan tidak',
      () async {
        const front = DoorCoverTarget(
          Rect.fromLTWH(255, 400, 90, 90),
          feet: 490,
          depth: DoorCoverTarget.upright,
        );
        const behind = DoorCoverTarget(
          Rect.fromLTWH(230, 330, 70, 70),
          feet: 400,
          depth: DoorCoverTarget.upright,
        );
        expect(await covered(80, const [front], side: DoorLeafSide.home), 0);
        expect(
          await covered(80, const [behind], side: DoorLeafSide.home),
          greaterThan(0),
        );
      },
    );
  });
}
