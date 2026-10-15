import 'dart:math';

import 'board.dart';
import 'item.dart';
import 'pos.dart';
import 'simulator.dart';

/// Hasil [solve].
class SolveResult {
  const SolveResult(this.minItems, this.solutions);

  /// Jumlah benda paling sedikit yang membuat Oyen menang.
  final int minItems;

  /// Semua susunan [minItems] benda yang menang, tanpa duplikat. Benda di tiap
  /// susunan urut jenis ([Item.values]), lalu baris, lalu kolom.
  final List<List<Placement>> solutions;
}

/// Mencari jumlah benda paling sedikit dari [inventory] yang membuat Oyen
/// menang di [board], mulai dari 0 benda, beserta semua susunannya. Kalau
/// [needSafe], vas tidak boleh pecah. Null kalau tidak ada susunan yang menang.
///
/// Hasilnya sama dengan `solve()` di `docs/reference/oyen_simulator.py`, tapi
/// petak dipilih sebagai kombinasi per jenis benda, bukan permutasi, jadi
/// benda sejenis yang bertukar tempat hanya dicoba sekali.
SolveResult? solve(
  Board board,
  Map<Item, int> inventory, {
  bool needSafe = true,
}) {
  final cells = board.emptyCells;
  final total = inventory.values.fold(0, (sum, n) => sum + n);
  for (var k = 0; k <= total; k++) {
    final solutions = <List<Placement>>[];
    for (final items in _multisets(inventory, k)) {
      _forEachPlacement(cells, items, (placed) {
        final result = simulate(board, placed);
        if (result.win && !(needSafe && result.vaseBroken)) {
          solutions.add(List.unmodifiable(placed));
        }
      });
    }
    if (solutions.isNotEmpty) {
      return SolveResult(k, List.unmodifiable(solutions));
    }
  }
  return null;
}

/// Semua cara mengambil [k] benda dari [inventory], urut [Item.values].
Iterable<List<Item>> _multisets(
  Map<Item, int> inventory,
  int k, [
  int kind = 0,
]) sync* {
  if (kind == Item.values.length) {
    if (k == 0) yield const [];
    return;
  }
  final item = Item.values[kind];
  for (var n = min(inventory[item] ?? 0, k); n >= 0; n--) {
    for (final rest in _multisets(inventory, k - n, kind + 1)) {
      yield [for (var i = 0; i < n; i++) item, ...rest];
    }
  }
}

/// Memanggil [visit] untuk setiap cara menaruh [items] di petak [cells] yang
/// berbeda. Benda sejenis selalu mengisi petak dengan indeks naik, jadi
/// bertukar tempat tidak dihitung dua kali.
void _forEachPlacement(
  List<Pos> cells,
  List<Item> items,
  void Function(List<Placement> placed) visit,
) {
  final used = List.filled(cells.length, false);
  final placed = <Placement>[];
  void assign(int slot, int from) {
    if (slot == items.length) {
      visit(placed);
      return;
    }
    final item = items[slot];
    final sameAsPrevious = slot > 0 && items[slot - 1] == item;
    for (var i = sameAsPrevious ? from : 0; i < cells.length; i++) {
      if (used[i]) continue;
      used[i] = true;
      placed.add(Placement(item, cells[i]));
      assign(slot + 1, i + 1);
      placed.removeLast();
      used[i] = false;
    }
  }

  assign(0, 0);
}
