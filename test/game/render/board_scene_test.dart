import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/board_scene.dart';
import 'package:kucing_oren/game/render/oyen.dart';
import 'package:kucing_oren/game/render/tile.dart';
import 'package:kucing_oren/game/sim/sim.dart';

/// Huruf ringkas untuk jenis petak supaya peta harapan mudah dibaca.
const _codes = {
  TileKind.wall: 'W',
  TileKind.cupboard: 'L',
  TileKind.shelf: 'R',
  TileKind.fridge: 'K',
  TileKind.floor: '.',
  TileKind.bowl: 'T',
  TileKind.table: 'M',
  TileKind.tableGlass: 'G',
  TileKind.tableVase: 'V',
  TileKind.tableBroken: 'X',
};

List<String> _kinds(BoardScene scene) => [
  for (var r = 0; r < BoardScene.rows; r++)
    [
      for (var c = 0; c < BoardScene.columns; c++)
        _codes[scene.tileAt(Pos(c, r)).kind],
    ].join(),
];

Map<Pos, TileItem> _items(BoardScene scene) => {
  for (var r = 0; r < BoardScene.rows; r++)
    for (var c = 0; c < BoardScene.columns; c++)
      if (scene.tileAt(Pos(c, r)).item != TileItem.none)
        Pos(c, r): scene.tileAt(Pos(c, r)).item,
};

void main() {
  // Dart murni: data level dibaca langsung dari file, tanpa rootBundle.
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  final level13 = levels[12];
  final level18 = levels[17];

  test('level 13: jenis petak, Oyen tidur, panah arah hadap', () {
    final scene = BoardScene.fromMap(level13.map);
    expect(_kinds(scene), [
      'WLRKLRW',
      'W..L..W',
      'W..L..W',
      'W.V...W',
      'WG.T..W',
      'W.....W',
      'W.....W',
      'W..M..W',
      'WWWWWWW',
    ]);
    expect(_items(scene), isEmpty);
    expect(
      scene.oyen,
      BoardOyen.at(
        const Pos(4, 3),
        const OyenLook(
          pose: OyenPose.sleep,
          dir: Direction.left,
          bubble: OyenBubble.zzz,
        ),
      ),
    );
    expect(scene.showFacing, isTrue);
  });

  test('level 18: tembok dalam jadi lemari, ikan bawaan', () {
    final scene = BoardScene.fromMap(level18.map);
    expect(_kinds(scene), [
      'WLRKLRW',
      'W....LW',
      'WTV...W',
      'W...L.W',
      'W..LL.W',
      'W..L..W',
      'W..L..W',
      'W....LW',
      'WWWWWWW',
    ]);
    expect(_items(scene), {const Pos(2, 4): TileItem.fish});
    expect(scene.oyen!.col, 5);
    expect(scene.oyen!.row, 2);
    expect(scene.oyen!.look.dir, Direction.up);
  });

  test('peta bawaan Board.dc.html sama dengan peta level 13', () {
    expect(BoardScene.designMap, level13.map);
  });

  test('genangan dan kardus bawaan jadi benda di lantai', () {
    final scene = BoardScene.fromMap(levels[14].map); // level 15
    expect(_items(scene), {
      const Pos(1, 4): TileItem.fish,
      const Pos(2, 4): TileItem.box,
    });
    final level7 = BoardScene.fromMap(levels[6].map);
    expect(_items(level7), {const Pos(5, 4): TileItem.water});
  });

  test('lantai selang-seling kalau kolom + baris ganjil', () {
    final scene = BoardScene.fromMap(level13.map);
    for (var r = 0; r < BoardScene.rows; r++) {
      for (var c = 0; c < BoardScene.columns; c++) {
        expect(scene.tileAt(Pos(c, r)).alt, (c + r).isOdd, reason: '($c,$r)');
      }
    }
  });

  test('benda pemain, petak menyala, dan vas pecah', () {
    final scene = BoardScene.fromMap(
      level13.map,
      items: {
        const Pos(3, 3): TileItem.bucketP,
        const Pos(2, 4): TileItem.fishP,
      },
      glow: {const Pos(1, 1), const Pos(5, 6)},
      broken: true,
    );
    expect(_items(scene), {
      const Pos(3, 3): TileItem.bucketP,
      const Pos(2, 4): TileItem.fishP,
    });
    expect(scene.tileAt(const Pos(2, 3)).kind, TileKind.tableBroken);
    expect(
      [
        for (var i = 0; i < scene.tiles.length; i++)
          if (scene.tiles[i].glow) Pos(i % 7, i ~/ 7),
      ],
      [const Pos(1, 1), const Pos(5, 6)],
    );
  });

  test('Oyen bisa diganti atau disembunyikan; panah hanya saat tidur', () {
    final awake = BoardScene.fromMap(
      level13.map,
      oyen: BoardOyen.at(
        const Pos(4, 4),
        const OyenLook(pose: OyenPose.walk, dir: Direction.left),
      ),
    );
    expect(awake.oyen!.look.pose, OyenPose.walk);
    expect(awake.showFacing, isFalse);

    expect(BoardScene.fromMap(level13.map, showOyen: false).oyen, isNull);
    expect(BoardScene.fromMap(level13.map, facing: false).showFacing, isFalse);
  });

  test('baris atau kolom yang kurang dianggap tembok', () {
    final scene = BoardScene.fromMap(['#...']);
    expect(scene.tileAt(const Pos(1, 0)).kind, TileKind.floor);
    expect(scene.tileAt(const Pos(5, 0)).kind, TileKind.shelf);
    expect(scene.tileAt(const Pos(3, 4)).kind, TileKind.cupboard);
    expect(scene.tileAt(const Pos(0, 4)).kind, TileKind.wall);
    expect(scene.oyen, isNull);
  });

  test('label Oyen dan papan sama dengan desain', () {
    expect(
      const OyenLook(pose: OyenPose.box, dir: Direction.right).label,
      'Oyen duduk dalam kardus, menghadap kanan',
    );
    expect(BoardScene.label, 'Papan permainan 7 kali 9 petak');
  });

  test('benda petunjuk samar di petak kosong', () {
    final scene = BoardScene.fromMap(
      BoardScene.designMap,
      ghosts: {const Pos(3, 3): Item.water, const Pos(2, 4): Item.fish},
      glow: {const Pos(3, 3)},
    );
    expect(scene.tileAt(const Pos(3, 3)).ghost, Item.water);
    expect(scene.tileAt(const Pos(3, 3)).glow, isTrue);
    expect(scene.tileAt(const Pos(2, 4)).ghost, Item.fish);
    expect(scene.tileAt(const Pos(1, 1)).ghost, isNull);
    expect(
      const Tile(ghost: Item.box),
      isNot(const Tile()),
      reason: 'ghost ikut ==',
    );
    expect(const Tile().copyWith(ghost: Item.box).ghost, Item.box);
  });

  group('dressed', () {
    test('Oyen memakai kostum, isi papan lain tetap', () {
      final scene = BoardScene.fromMap(BoardScene.designMap);
      final dressed = scene.dressed(OyenCostume.peci);
      expect(dressed.oyen!.look.costume, OyenCostume.peci);
      expect(dressed.oyen!.look.pose, scene.oyen!.look.pose);
      expect(dressed.tiles, scene.tiles);
      expect(dressed.facing, scene.facing);
      expect(dressed.showFacing, scene.showFacing);
    });

    test('tanpa Oyen atau kostum sama: papan yang sama', () {
      final hidden = BoardScene.fromMap(BoardScene.designMap, showOyen: false);
      expect(identical(hidden.dressed(OyenCostume.koki), hidden), isTrue);
      final plain = BoardScene.fromMap(BoardScene.designMap);
      expect(identical(plain.dressed(OyenCostume.none), plain), isTrue);
    });
  });
}
