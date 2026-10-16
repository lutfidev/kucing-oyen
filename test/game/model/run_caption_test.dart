import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_caption.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  List<String> captions(Level level, [List<Placement>? placed]) {
    final board = level.board;
    final frames = runFrames(board, simulate(board, placed ?? level.solution));
    return [
      for (var i = 0; i < frames.length; i++) runCaption(board, frames, i),
    ];
  }

  test('solusi level 13: caption desain 04', () {
    expect(captions(level(13)), [
      'Oyen bangun, menghadap kiri.',
      'Ada air! Oyen kaget, lalu putar balik.',
      'Jalan lurus ke kanan, santai.',
      'Mentok tembok. Berputar, sekarang menghadap bawah.',
      'Eh, ada bau ikan asin di kiri!',
      // Desain: "Kejar ikan ke kiri. Vas aman di atas sana."
      'Kejar ikan ke kiri.',
      'Sampai di mangkuk! Nyam nyam.',
    ]);
  });

  test('level 15: makan ikan dan duduk di kardus', () {
    final c = captions(level(15));
    expect(c.sublist(1, 4), [
      'Eh, ada bau ikan asin di atas!',
      'Kejar ikan ke atas.',
      'Hap! Ikan asinnya dimakan.',
    ]);
    expect(c[6], 'Mentok meja. Berputar, sekarang menghadap bawah.');
    expect(c.sublist(7, 10), [
      'Ada kardus! Oyen masuk lalu duduk.',
      'Duduk manis di dalam kardus.',
      'Kardusnya penyok, lalu hilang.',
    ]);
  });

  test('barang jatuh: gelas aman, vas pecah', () {
    expect(captions(level(12))[6], 'Gelas didorong jatuh. Untung plastik!');
    expect(
      captions(level(13), [const Placement(Item.fish, Pos(2, 4))])[2],
      'Waduh! Vas Ibu jatuh dan pecah.',
    );
  });

  test('setiap langkah 20 solusi punya caption', () {
    for (final l in levels) {
      for (final caption in captions(l)) {
        expect(caption, isNotEmpty, reason: '$l');
      }
    }
  });
}
