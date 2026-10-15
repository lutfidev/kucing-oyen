import 'cell.dart';
import 'direction.dart';
import 'pos.dart';

/// Peta awal level yang sudah diurai. Petak Oyen dianggap lantai.
class Board {
  Board._(this.width, this.height, this._cells, this.start, this.startDir);

  /// Mengurai peta teks: setiap baris satu string, setiap huruf satu petak.
  factory Board.parse(List<String> rows) {
    if (rows.isEmpty) throw const FormatException('Peta kosong');
    final width = rows.first.length;
    final cells = <Cell>[];
    Pos? start;
    Direction? startDir;
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      if (row.length != width) {
        throw FormatException('Baris $y panjangnya ${row.length}, '
            'seharusnya $width');
      }
      for (var x = 0; x < width; x++) {
        final symbol = row[x];
        final dir = Direction.fromSymbol(symbol);
        if (dir != null) {
          if (start != null) {
            throw FormatException('Oyen muncul dua kali: $start dan ($x,$y)');
          }
          start = Pos(x, y);
          startDir = dir;
          cells.add(Cell.floor);
          continue;
        }
        final cell = Cell.fromSymbol(symbol);
        if (cell == null) {
          throw FormatException('Huruf peta tidak dikenal "$symbol" di ($x,$y)');
        }
        cells.add(cell);
      }
    }
    if (start == null) throw const FormatException('Oyen tidak ada di peta');
    return Board._(
        width, rows.length, List.unmodifiable(cells), start, startDir!);
  }

  final int width;
  final int height;
  final List<Cell> _cells;

  /// Posisi dan arah hadap awal Oyen.
  final Pos start;
  final Direction startDir;

  bool contains(Pos p) => p.x >= 0 && p.x < width && p.y >= 0 && p.y < height;

  /// Isi petak; di luar peta dianggap tembok.
  Cell cellAt(Pos p) => contains(p) ? _cells[p.y * width + p.x] : Cell.wall;

  /// Benda pemain hanya boleh ditaruh di lantai kosong, bukan di petak Oyen.
  bool canPlace(Pos p) => cellAt(p) == Cell.floor && p != start;

  /// Semua petak yang bisa diisi benda, urut baris lalu kolom.
  List<Pos> get emptyCells => [
        for (var y = 0; y < height; y++)
          for (var x = 0; x < width; x++)
            if (canPlace(Pos(x, y))) Pos(x, y),
      ];

  /// Salinan isi petak (baris demi baris) yang boleh diubah simulasi.
  List<Cell> copyCells() => List.of(_cells);
}
