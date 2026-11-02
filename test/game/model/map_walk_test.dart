import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/map_walk.dart';

/// [walk] dimajukan sampai detik [to] dalam langkah 1/60 detik.
void _advance(MapWalk walk, double from, double to) {
  for (var t = from; t < to - 1e-9; t += 1 / 60) {
    walk.tick(1 / 60);
  }
}

void main() {
  test('jeda dulu, lalu jalan dengan easeInOut', () {
    final walk = MapWalk(autoOpen: true, still: false);
    walk.tick(0.2);
    expect(walk.t, 0);
    expect(walk.walking, isFalse);
    walk.tick(0.6); // 0,8 detik: tengah jalan.
    expect(walk.t, closeTo(0.5, 1e-9));
    expect(walk.walking, isTrue);
    walk.tick(0.5); // 1,3 detik: sampai.
    expect(walk.t, 1);
    expect(walk.walking, isFalse);
    expect(walk.arrived, isTrue);
    expect(walk.takeOpen(), isFalse);
  });

  test('buka tepat sekali sesudah diam sebentar', () {
    final walk = MapWalk(autoOpen: true, still: false);
    _advance(walk, 0, 1.5);
    expect(walk.takeOpen(), isFalse);
    _advance(walk, 1.5, 1.6);
    expect(walk.takeOpen(), isTrue);
    expect(walk.takeOpen(), isFalse);
    walk.tick(1);
    expect(walk.takeOpen(), isFalse);
    expect(walk.done, isTrue);
  });

  test('batal: jalan tetap selesai, tidak pernah buka', () {
    final walk = MapWalk(autoOpen: true, still: false);
    walk.tick(0.5);
    walk.cancel();
    expect(walk.cancelled, isTrue);
    walk.tick(0.8);
    expect(walk.t, 1);
    expect(walk.done, isTrue);
    walk.tick(5);
    expect(walk.takeOpen(), isFalse);
  });

  test('tanpa buka otomatis: selesai saat sampai', () {
    final walk = MapWalk(autoOpen: false, still: false);
    walk.tick(1.0);
    expect(walk.done, isFalse);
    walk.tick(0.3);
    expect(walk.done, isTrue);
    walk.tick(5);
    expect(walk.takeOpen(), isFalse);
  });

  test('kurangi gerak: langsung di tujuan, buka sesudah 0,6 detik', () {
    final walk = MapWalk(autoOpen: true, still: true);
    expect(walk.t, 1);
    expect(walk.walking, isFalse);
    walk.tick(0.5);
    expect(walk.takeOpen(), isFalse);
    walk.tick(0.1);
    expect(walk.takeOpen(), isTrue);

    final cancelled = MapWalk(autoOpen: true, still: true)..cancel();
    cancelled.tick(2);
    expect(cancelled.takeOpen(), isFalse);
    expect(cancelled.done, isTrue);
  });

  test('satu tick besar tetap membuka sekali', () {
    final walk = MapWalk(autoOpen: true, still: false);
    walk.tick(5);
    expect(walk.t, 1);
    expect(walk.takeOpen(), isTrue);
    expect(walk.takeOpen(), isFalse);
  });
}
