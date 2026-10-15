import 'board.dart';
import 'cell.dart';
import 'direction.dart';
import 'item.dart';
import 'pos.dart';

/// Batas langkah sebelum Oyen dianggap kelamaan.
const maxSteps = 80;

/// Aksi Oyen dalam satu langkah.
enum StepKind {
  /// Diam di dalam kardus.
  sit,

  /// Menjatuhkan gelas plastik dari meja sebelah (aman).
  knockGlass,

  /// Menjatuhkan vas Ibu dari meja sebelah (pecah).
  knockVase,

  /// Ada air di depan: kaget, putar balik di tempat.
  scared,

  /// Ada tembok atau meja di depan: berputar searah jarum jam di tempat.
  turn,

  /// Maju dan memakan ikan.
  eat,

  /// Maju masuk kardus, lalu duduk 2 langkah.
  enterBox,

  /// Maju ke lantai atau mangkuk.
  walk,
}

/// Satu langkah Oyen.
class SimStep {
  const SimStep(this.kind, this.pos, this.dir, {this.changed, this.chasing});

  final StepKind kind;

  /// Posisi dan arah hadap Oyen setelah langkah ini.
  final Pos pos;
  final Direction dir;

  /// Petak yang berubah di langkah ini: meja yang barangnya jatuh, ikan yang
  /// dimakan, atau kardus yang penyok.
  final Pos? changed;

  /// Ikan terdekat yang terlihat dan membuat Oyen menghadap ke sana.
  final Pos? chasing;

  @override
  String toString() => '${kind.name}$pos${dir.symbol}';
}

enum FailReason {
  /// Keadaan berulang persis sama (mondar-mandir).
  loop,

  /// Lewat [maxSteps] langkah (kelamaan).
  tooManySteps,
}

class SimResult {
  const SimResult({
    required this.win,
    required this.vaseBroken,
    required this.steps,
    required this.trace,
    this.failReason,
  });

  final bool win;
  final bool vaseBroken;

  /// Jumlah langkah, sama dengan `steps` di simulator acuan. Saat kelamaan
  /// nilainya [maxSteps], walau [trace] berisi `maxSteps + 1` aksi.
  final int steps;

  /// Null kalau menang.
  final FailReason? failReason;

  /// Semua aksi Oyen berurutan; langkah ke-n ada di `trace[n - 1]`.
  final List<SimStep> trace;

  /// Nomor langkah (mulai dari 1) saat vas pecah, atau null.
  int? get vaseBrokenAtStep {
    final i = trace.indexWhere((s) => s.kind == StepKind.knockVase);
    return i < 0 ? null : i + 1;
  }
}

/// Menjalankan Oyen di [board] dengan benda pemain [placed] sampai menang,
/// mondar-mandir, atau kelamaan.
///
/// Harus identik dengan `simulate()` di `docs/reference/oyen_simulator.py`.
SimResult simulate(Board board, [Iterable<Placement> placed = const []]) {
  final width = board.width;
  final grid = board.copyCells();
  int index(Pos p) => p.y * width + p.x;
  for (final p in placed) {
    if (!board.canPlace(p.pos) || grid[index(p.pos)] != Cell.floor) {
      throw ArgumentError.value(p, 'placed', 'Bukan petak lantai kosong');
    }
    grid[index(p.pos)] = p.item.cell;
  }

  Cell cell(Pos p) => board.contains(p) ? grid[index(p)] : Cell.wall;

  var pos = board.start;
  var dir = board.startDir;
  final knocked = <Pos>{};
  var vase = false;
  var sit = 0;
  final seen = <String>{};
  final trace = <SimStep>[];

  SimResult end(int steps, {FailReason? fail}) => SimResult(
        win: fail == null,
        vaseBroken: vase,
        steps: steps,
        trace: List.unmodifiable(trace),
        failReason: fail,
      );

  for (var step = 0; step <= maxSteps; step++) {
    if (cell(pos) == Cell.bowl) return end(step);
    if (!seen.add(_stateKey(pos, dir, sit, grid, knocked, width))) {
      return end(step, fail: FailReason.loop);
    }
    if (sit > 0) {
      sit--;
      Pos? crushed;
      if (sit == 0) {
        grid[index(pos)] = Cell.floor; // kardus penyok
        crushed = pos;
      }
      trace.add(SimStep(StepKind.sit, pos, dir, changed: crushed));
      continue;
    }

    // 1. jatuhkan barang di meja sebelah
    Pos? target;
    for (final d in dir.lookOrder) {
      final q = pos + d;
      if (cell(q).hasKnockable && !knocked.contains(q)) {
        target = q;
        break;
      }
    }
    if (target != null) {
      knocked.add(target);
      final isVase = cell(target) == Cell.tableVase;
      if (isVase) vase = true;
      trace.add(SimStep(
        isVase ? StepKind.knockVase : StepKind.knockGlass,
        pos,
        dir,
        changed: target,
      ));
      continue;
    }

    // 2. ikan terlihat
    ({int dist, Direction dir, Pos pos})? best;
    for (final d in dir.lookOrder) {
      for (var dist = 1;; dist++) {
        final q = pos.shift(d, dist);
        final c = cell(q);
        if (c.blocksSight) break;
        if (c == Cell.fish) {
          if (best == null || dist < best.dist) {
            best = (dist: dist, dir: d, pos: q);
          }
          break;
        }
      }
    }
    if (best != null) dir = best.dir;
    final chasing = best?.pos;

    // 3. petak depan
    final next = pos + dir;
    final c = cell(next);
    if (c == Cell.water) {
      dir = dir.opposite;
      trace.add(SimStep(StepKind.scared, pos, dir, chasing: chasing));
      continue;
    }
    if (c == Cell.wall || c.isTable) {
      dir = dir.clockwise;
      trace.add(SimStep(StepKind.turn, pos, dir, chasing: chasing));
      continue;
    }
    pos = next;
    if (c == Cell.fish) {
      grid[index(next)] = Cell.floor;
      trace.add(SimStep(StepKind.eat, pos, dir, changed: next, chasing: chasing));
    } else if (c == Cell.box) {
      sit = 2;
      trace.add(SimStep(StepKind.enterBox, pos, dir, chasing: chasing));
    } else {
      trace.add(SimStep(StepKind.walk, pos, dir, chasing: chasing));
    }
  }
  return end(maxSteps, fail: FailReason.tooManySteps);
}

/// Keadaan untuk deteksi mondar-mandir: posisi, arah, sisa duduk, letak semua
/// benda (ikan, air, kardus), dan meja yang barangnya sudah jatuh.
String _stateKey(Pos pos, Direction dir, int sit, List<Cell> grid,
    Set<Pos> knocked, int width) {
  final key = StringBuffer('${pos.x},${pos.y},${dir.index},$sit|');
  for (var i = 0; i < grid.length; i++) {
    if (grid[i].isItem) key.write('$i,');
  }
  key.write('|');
  key.writeAll([for (final p in knocked) p.y * width + p.x]..sort(), ',');
  return key.toString();
}
