import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_clock.dart';

const _ms = Duration(milliseconds: 1);

void main() {
  test('langkah 1 langsung tampil, lalu 4 langkah per detik', () {
    final clock = RunClock(6);
    expect(clock.step, 1);
    expect(clock.playing, isTrue);
    expect(clock.interval, const Duration(milliseconds: 250));

    expect(clock.tick(_ms * 249), isFalse);
    expect(clock.step, 1);
    expect(clock.tick(_ms), isTrue);
    expect(clock.step, 2);
    // Satu tick panjang bisa melewati beberapa langkah.
    expect(clock.tick(_ms * 500), isTrue);
    expect(clock.step, 4);
  });

  test('berhenti di langkah terakhir', () {
    final clock = RunClock(3);
    clock.tick(const Duration(seconds: 5));
    expect(clock.step, 3);
    expect(clock.done, isTrue);
    expect(clock.playing, isFalse);
    expect(clock.tick(const Duration(seconds: 1)), isFalse);
    expect(clock.step, 3);
  });

  test('satu langkah saja: langsung selesai', () {
    final clock = RunClock(1);
    expect(clock.step, 1);
    expect(clock.done, isTrue);
  });

  test('jeda menahan waktu; lanjutkan meneruskan sisa langkah', () {
    final clock = RunClock(6)..tick(_ms * 200);
    clock.togglePause();
    expect(clock.playing, isFalse);
    expect(clock.tick(const Duration(seconds: 1)), isFalse);
    expect(clock.step, 1);

    clock.togglePause();
    expect(clock.playing, isTrue);
    expect(clock.tick(_ms * 50), isTrue);
    expect(clock.step, 2);
  });

  test('×2: 8 langkah per detik', () {
    final clock = RunClock(10)..toggleFast();
    expect(clock.fast, isTrue);
    expect(clock.interval, const Duration(milliseconds: 125));
    clock.tick(const Duration(milliseconds: 500));
    expect(clock.step, 5);

    clock.toggleFast();
    expect(clock.interval, const Duration(milliseconds: 250));
    clock.tick(const Duration(milliseconds: 500));
    expect(clock.step, 7);
  });

  test('×2 di tengah langkah: bagian yang sudah lewat tetap', () {
    final clock = RunClock(10)..tick(_ms * 200); // 80% langkah 1
    clock.toggleFast(); // sisa 20% dari 125 ms = 25 ms
    clock.tick(_ms * 24);
    expect(clock.step, 1);
    clock.tick(_ms);
    expect(clock.step, 2);
  });

  test('maju satu langkah: jeda lalu langkah berikutnya', () {
    final clock = RunClock(3)..tick(_ms * 200);
    clock.stepOnce();
    expect(clock.step, 2);
    expect(clock.playing, isFalse);
    clock.tick(const Duration(seconds: 1));
    expect(clock.step, 2);

    clock.stepOnce();
    expect(clock.step, 3);
    expect(clock.done, isTrue);
    clock.stepOnce();
    expect(clock.step, 3);
  });

  test('langsung ke akhir', () {
    final clock = RunClock(25)..skipToEnd();
    expect(clock.step, 25);
    expect(clock.done, isTrue);
  });
}
