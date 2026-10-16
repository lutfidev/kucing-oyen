import '../sim/sim.dart';

/// Keadaan papan sesudah satu langkah fase jalan, dibangun ulang dari
/// `SimResult.trace` tanpa menjalankan ulang simulasi.
class RunFrame {
  const RunFrame({
    required this.step,
    required this.pos,
    required this.dir,
    this.action,
    this.cleared = const {},
    this.knocked = const {},
    this.vaseBroken = false,
    this.atBowl = false,
  });

  /// Nomor langkah: 0 = Oyen baru bangun, belum melakukan apa-apa.
  final int step;

  /// Aksi di langkah ini; null di langkah 0.
  final SimStep? action;

  /// Posisi dan arah hadap Oyen sesudah langkah ini.
  final Pos pos;
  final Direction dir;

  /// Petak yang bendanya sudah hilang: ikan dimakan, kardus penyok. Benda
  /// bawaan peta maupun benda pemain.
  final Set<Pos> cleared;

  /// Meja yang barangnya sudah jatuh.
  final Set<Pos> knocked;

  final bool vaseBroken;

  /// Oyen sampai di mangkuk.
  final bool atBowl;

  /// Oyen duduk di kardus: baru masuk, atau duduk sebelum kardusnya penyok.
  bool get inBox => switch (action) {
    SimStep(kind: StepKind.enterBox) => true,
    SimStep(kind: StepKind.sit, changed: null) => true,
    _ => false,
  };

  @override
  String toString() => 'RunFrame($step, ${action ?? '$pos${dir.symbol}'})';
}

/// Keadaan papan di langkah 0 sampai `result.steps` dari Oyen yang berjalan
/// di [board].
///
/// Saat kelamaan, `trace` berisi satu aksi lebih banyak dari `steps`; aksi
/// terakhir itu tidak diputar.
List<RunFrame> runFrames(Board board, SimResult result) {
  var cleared = const <Pos>{};
  var knocked = const <Pos>{};
  var vaseBroken = false;
  final frames = [RunFrame(step: 0, pos: board.start, dir: board.startDir)];
  for (var i = 0; i < result.steps; i++) {
    final action = result.trace[i];
    final changed = action.changed;
    if (changed != null) {
      switch (action.kind) {
        case StepKind.knockGlass || StepKind.knockVase:
          knocked = Set.unmodifiable({...knocked, changed});
        default:
          cleared = Set.unmodifiable({...cleared, changed});
      }
    }
    if (action.kind == StepKind.knockVase) vaseBroken = true;
    frames.add(
      RunFrame(
        step: i + 1,
        action: action,
        pos: action.pos,
        dir: action.dir,
        cleared: cleared,
        knocked: knocked,
        vaseBroken: vaseBroken,
        atBowl: board.cellAt(action.pos) == Cell.bowl,
      ),
    );
  }
  return List.unmodifiable(frames);
}
