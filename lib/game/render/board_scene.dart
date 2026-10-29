import '../sim/direction.dart';
import '../sim/item.dart';
import '../sim/pos.dart';
import 'oyen.dart';
import 'tile.dart';

/// Oyen di papan: posisi petak (pecahan boleh, untuk animasi pindah petak)
/// dan tampilannya.
class BoardOyen {
  const BoardOyen({required this.col, required this.row, required this.look});

  BoardOyen.at(Pos pos, this.look)
    : col = pos.x.toDouble(),
      row = pos.y.toDouble();

  final double col;
  final double row;
  final OyenLook look;

  @override
  bool operator ==(Object other) =>
      other is BoardOyen &&
      other.col == col &&
      other.row == row &&
      other.look == look;

  @override
  int get hashCode => Object.hash(col, row, look);

  @override
  String toString() => 'BoardOyen($col, $row, $look)';
}

/// Nomor jejak putar ulang di pojok kiri atas petak [pos] (prop `trail` di
/// `Board.dc.html`). [active] = langkah yang sedang tampil ada di petak ini.
class BoardMark {
  const BoardMark(this.pos, this.label, {this.active = false});

  final Pos pos;
  final String label;
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is BoardMark &&
      other.pos == pos &&
      other.label == label &&
      other.active == active;

  @override
  int get hashCode => Object.hash(pos, label, active);

  @override
  String toString() => 'BoardMark($pos, $label${active ? ', active' : ''})';
}

/// Isi papan 7×9 yang siap digambar `paintBoard`: 63 petak (baris demi
/// baris), jalur dan nomor jejak, Oyen, dan panah arah hadap. Dart murni.
class BoardScene {
  BoardScene({
    required List<Tile> tiles,
    this.oyen,
    this.facing = true,
    List<Pos> path = const [],
    List<BoardMark> trail = const [],
  }) : tiles = List.unmodifiable(tiles),
       path = List.unmodifiable(path),
       trail = List.unmodifiable(trail) {
    if (tiles.length != columns * rows) {
      throw ArgumentError.value(
        tiles.length,
        'tiles',
        'harus ${columns * rows} petak',
      );
    }
  }

  /// Mengikuti `renderVals()` di `Board.dc.html`.
  ///
  /// [items] menimpa benda di peta (benda pemain memakai `fishP`, `bucketP`,
  /// `boxP`; `none` menghapus benda bawaan). [broken] mengganti semua vas
  /// dengan vas pecah. Di petak [knocked] barangnya sudah jatuh: gelas jadi
  /// meja kosong (tidak ada gambar gelas jatuh di desain), vas jadi vas
  /// pecah. Tanpa [oyen], Oyen tidur di petak awal peta dengan Zzz;
  /// [showOyen] false menyembunyikannya. [facing] menampilkan panah arah
  /// hadap saat Oyen tidur. [path] = jalur Oyen (garis putus-putus),
  /// [trail] = nomor jejak putar ulang. [ghosts] = benda petunjuk yang
  /// digambar samar.
  factory BoardScene.fromMap(
    List<String> map, {
    Map<Pos, TileItem> items = const {},
    Set<Pos> glow = const {},
    Map<Pos, Item> ghosts = const {},
    bool broken = false,
    Set<Pos> knocked = const {},
    BoardOyen? oyen,
    bool showOyen = true,
    bool facing = true,
    List<Pos> path = const [],
    List<BoardMark> trail = const [],
  }) {
    BoardOyen? mapOyen;
    final tiles = <Tile>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final line = r < map.length ? map[r] : '#######';
        final ch = c < line.length ? line[c] : '#';
        var kind = TileKind.floor;
        var item = TileItem.none;
        final dir = Direction.fromSymbol(ch);
        final fell = knocked.contains(Pos(c, r));
        switch (ch) {
          case '#':
            if (r == 0) {
              kind = topRow[c];
            } else if (c > 0 && c < 6 && r > 0 && r < 8) {
              kind = TileKind.cupboard;
            } else {
              kind = TileKind.wall;
            }
          case 'T':
            kind = TileKind.bowl;
          case 'M':
            kind = TileKind.table;
          case 'G':
            kind = fell ? TileKind.table : TileKind.tableGlass;
          case 'V':
            kind = broken || fell ? TileKind.tableBroken : TileKind.tableVase;
          case 'F':
            item = TileItem.fish;
          case 'A':
            item = TileItem.water;
          case 'K':
            item = TileItem.box;
          default:
            if (dir != null) {
              mapOyen = BoardOyen.at(
                Pos(c, r),
                OyenLook(
                  pose: OyenPose.sleep,
                  dir: dir,
                  bubble: OyenBubble.zzz,
                ),
              );
            }
        }
        final pos = Pos(c, r);
        tiles.add(
          Tile(
            kind: kind,
            item: items[pos] ?? item,
            alt: (c + r) % 2 == 1,
            glow: glow.contains(pos),
            ghost: ghosts[pos],
          ),
        );
      }
    }
    return BoardScene(
      tiles: tiles,
      oyen: showOyen ? oyen ?? mapOyen : null,
      facing: facing,
      path: path,
      trail: trail,
    );
  }

  static const int columns = 7;
  static const int rows = 9;

  /// Papan 350×450 di koordinat desain.
  static const double width = columns * Tile.size;
  static const double height = rows * Tile.size;

  /// Tembok baris paling atas: perabot dapur di dinding.
  static const topRow = [
    TileKind.wall,
    TileKind.cupboard,
    TileKind.shelf,
    TileKind.fridge,
    TileKind.cupboard,
    TileKind.shelf,
    TileKind.wall,
  ];

  /// Peta bawaan `Board.dc.html`, dipakai semua layar desain papan. Sama
  /// dengan peta level 13 (Vas Ibu).
  static const designMap = [
    '#######',
    '#..#..#',
    '#..#..#',
    '#.V.<.#',
    '#G.T..#',
    '#.....#',
    '#.....#',
    '#..M..#',
    '#######',
  ];

  final List<Tile> tiles;
  final BoardOyen? oyen;
  final bool facing;

  /// Petak-petak yang dilewati Oyen, berurutan (prop `path`). Digambar
  /// sebagai garis putus-putus lewat tengah petak kalau lebih dari satu.
  final List<Pos> path;

  /// Nomor jejak putar ulang, di atas jalur dan di bawah Oyen.
  final List<BoardMark> trail;

  Tile tileAt(Pos p) => tiles[p.y * columns + p.x];

  /// Panah arah hadap tampil hanya saat Oyen tidur.
  bool get showFacing =>
      oyen != null && facing && oyen!.look.pose == OyenPose.sleep;
}
