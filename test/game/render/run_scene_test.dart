import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  List<RunFrame> frames(Level level, [List<Placement>? placed]) =>
      runFrames(level.board, simulate(level.board, placed ?? level.solution));

  /// "pose arah (kolom,baris) gelembung" tiap langkah, mulai langkah 1.
  List<String> looks(List<RunFrame> frames) => [
    for (final f in frames.skip(1))
      [
        runLook(f).pose.name,
        runLook(f).dir.name,
        '${f.pos}',
        if (runLook(f).bubble != OyenBubble.none) runLook(f).bubble.name,
        if (runLook(f).mirror) 'mirror',
      ].join(' '),
  ];

  test('solusi level 13: pose dan posisi seperti desain 04', () {
    expect(looks(frames(level(13))), [
      'shock left (4,3) kaget',
      'walk right (5,3)',
      'idle down (5,3)',
      'walk down (5,4)',
      'walk left (4,4) ikan',
      'eat left (3,4)',
    ]);
  });

  test('solusi level 15: makan ikan, duduk di kardus, ke mangkuk', () {
    expect(looks(frames(level(15))), [
      'walk left (1,6)',
      'walk up (1,5) ikan',
      'eat up (1,4)',
      'walk up (1,3)',
      'eat right (2,3)',
      'idle down (2,3)',
      'box down (2,4)',
      'box down (2,4)',
      'idle down (2,4)',
      'walk down (2,5)',
      'walk down (2,6)',
      'eat down (2,7)',
    ]);
  });

  test('menjatuhkan: menghadap bawah, tangan ke arah meja', () {
    // Level 13 ikan saja: vas di kiri Oyen.
    final vase = frames(level(13), [const Placement(Item.fish, Pos(2, 4))]);
    expect(looks(vase)[1], 'knock down (3,3) mirror');
    // Level 19: gelas di (4,4), kiri Oyen di (5,4).
    expect(looks(frames(level(19)))[13], 'knock down (5,4) mirror');
    // Level 12: gelas di (1,1) di atas Oyen, gelas (4,2) di kanannya.
    final glass = looks(frames(level(12)));
    expect(glass[5], 'knock down (1,2)');
    expect(glass[9], 'knock down (3,2)');
  });

  test('papan akhir level 15: ikan dimakan, kardus hilang', () {
    final l = level(15);
    final f = frames(l);
    final start = runScene(l.map, l.solution, f, 0);
    expect(start.tileAt(const Pos(2, 3)).item, TileItem.fishP);
    expect(start.tileAt(const Pos(1, 4)).item, TileItem.fish);
    expect(start.tileAt(const Pos(2, 4)).item, TileItem.box);
    expect(start.oyen!.look, const OyenLook(dir: Direction.left));

    // Selama duduk, kardusnya digambar pose box, bukan petak.
    expect(
      runScene(l.map, l.solution, f, 7).tileAt(const Pos(2, 4)).item,
      TileItem.none,
    );

    final end = runScene(l.map, l.solution, f, f.length - 1);
    for (final pos in const [Pos(2, 3), Pos(1, 4), Pos(2, 4)]) {
      expect(end.tileAt(pos).item, TileItem.none, reason: '$pos');
    }
    expect(end.tileAt(const Pos(2, 7)).kind, TileKind.bowl);
    expect(end.oyen, BoardOyen.at(const Pos(2, 7), runLook(f.last)));
    expect(end.showFacing, isFalse);
  });

  test('papan akhir level 13 ikan saja: vas pecah, gelas tetap', () {
    final l = level(13);
    const placed = [Placement(Item.fish, Pos(2, 4))];
    final f = frames(l, placed);
    final end = runScene(l.map, placed, f, f.length - 1);
    expect(end.tileAt(const Pos(2, 3)).kind, TileKind.tableBroken);
    expect(end.tileAt(const Pos(1, 4)).kind, TileKind.tableGlass);
    // Ikan pemain tidak termakan: Oyen sampai di mangkuk lebih dulu.
    expect(end.tileAt(const Pos(2, 4)).item, TileItem.fishP);
  });

  test('jalur Oyen sampai langkah yang tampil, tanpa petak berulang', () {
    final l = level(13);
    final f = frames(l);
    List<Pos> path(int step) => runScene(l.map, l.solution, f, step).path;
    // Langkah 1 (kaget) belum pindah petak.
    expect(path(1), [const Pos(4, 3)]);
    expect(path(3), [const Pos(4, 3), const Pos(5, 3)]);
    expect(path(6), const [
      Pos(4, 3),
      Pos(5, 3),
      Pos(5, 4),
      Pos(4, 4),
      Pos(3, 4),
    ]);
  });

  test('layar gagal: Oyen tidur lagi di petak terakhir, jalur penuh', () {
    final l = level(13);
    final f = frames(l, const []);
    final scene = restScene(l.map, const [], f);
    final last = f.last;
    expect(
      scene.oyen,
      BoardOyen.at(
        last.pos,
        OyenLook(pose: OyenPose.sleep, dir: last.dir, bubble: OyenBubble.zzz),
      ),
    );
    expect(scene.showFacing, isFalse);
    expect(scene.path, runScene(l.map, const [], f, f.length - 1).path);
    expect(scene.path.length, greaterThan(1));
    // Vas yang jatuh selama mondar-mandir tetap pecah.
    expect(scene.tileAt(const Pos(2, 3)).kind, TileKind.tableBroken);
  });

  test('layar gagal: kardus tempat Oyen duduk tetap tergambar', () {
    final l = level(15);
    // Langkah 7 solusi level 15: Oyen duduk di kardus bawaan (2,4).
    final f = frames(l).sublist(0, 8);
    expect(f.last.inBox, isTrue);
    expect(
      runScene(l.map, l.solution, f, 7).tileAt(const Pos(2, 4)).item,
      TileItem.none,
    );
    final scene = restScene(l.map, l.solution, f);
    expect(scene.tileAt(const Pos(2, 4)).item, TileItem.box);
    expect(scene.oyen!.look.pose, OyenPose.sleep);
  });

  test('gelas jatuh jadi meja kosong', () {
    final l = level(12);
    final f = frames(l);
    final end = runScene(l.map, l.solution, f, f.length - 1);
    expect(end.tileAt(const Pos(1, 1)).kind, TileKind.table);
    expect(end.tileAt(const Pos(4, 2)).kind, TileKind.table);
  });
}
