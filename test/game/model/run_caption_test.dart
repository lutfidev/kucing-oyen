import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_caption.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/captions.dart';
import 'package:kucing_oren/l10n/l10n.dart';

import '../../test_helpers.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  List<RunText> texts(Level level, [List<Placement>? placed]) {
    final board = level.board;
    final frames = runFrames(board, simulate(board, placed ?? level.solution));
    return [
      for (var i = 0; i < frames.length; i++) runCaption(board, frames, i),
    ];
  }

  List<String> captions(
    Level level, [
    List<Placement>? placed,
    AppLocalizations? l,
  ]) => [
    for (final text in texts(level, placed)) runCaptionText(l ?? l10nId, text),
  ];

  test('caption sebagai data: arah dan penghalang', () {
    expect(texts(level(13)).take(4), const [
      RunText(RunTextKind.wake, dir: Direction.left),
      RunText(RunTextKind.scared),
      RunText(RunTextKind.walk, dir: Direction.right),
      RunText(RunTextKind.turn, dir: Direction.down, obstacle: Obstacle.wall),
    ]);
  });

  test('solusi level 13 dalam bahasa Inggris: arah layar, berputar', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(captions(level(13), null, en), [
      'Oyen wakes up, facing left.',
      'Water! Oyen jumps and turns back.',
      'Strolling to the right, no rush.',
      'Hit a wall. Turned, now facing down.',
      'Hey, salted fish to the left!',
      'Chasing the fish to the left.',
      'Made it to the bowl! Nom nom.',
    ]);
  });

  test('bahasa Rusia memakai bentuk arah yang berbeda', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final c = captions(level(13), null, ru);
    expect(c[2], 'Идёт прямо вправо, не спеша.');
    expect(c[4], 'Ого, слева пахнет солёной рыбкой!');
  });

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
