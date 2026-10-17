import '../sim/sim.dart';
import 'run_frames.dart';

/// Nomor jejak di satu petak papan putar ulang (desain 09): langkah-langkah
/// saat Oyen berada di petak itu.
class TrailMark {
  TrailMark(this.pos, List<int> steps) : steps = List.unmodifiable(steps);

  final Pos pos;

  /// Nomor langkah (mulai 1), urut naik.
  final List<int> steps;

  /// Teks nomor yang muat di petak. Satu kunjungan: "4", dua langkah
  /// berturut-turut "2·3" (desain), tiga atau lebih "5–7". Beberapa
  /// kunjungan: langkah pertama tiap kunjungan, "12·24", paling banyak dua
  /// lalu "…".
  String get label {
    final runs = <(int, int)>[];
    for (final step in steps) {
      if (runs.isNotEmpty && runs.last.$2 == step - 1) {
        runs.last = (runs.last.$1, step);
      } else {
        runs.add((step, step));
      }
    }
    if (runs.length > 1) {
      return [
        for (final (start, _) in runs.take(2)) '$start',
        if (runs.length > 2) '…',
      ].join('·');
    }
    final (start, end) = runs.single;
    return switch (end - start) {
      0 => '$start',
      1 => '$start·$end',
      _ => '$start–$end',
    };
  }

  @override
  String toString() => 'TrailMark($pos, $label)';
}

/// Nomor jejak semua petak yang ditempati Oyen di langkah 1 sampai terakhir,
/// urut kunjungan pertama. Langkah 0 (Oyen baru bangun) tidak bernomor.
List<TrailMark> replayTrail(List<RunFrame> frames) {
  final steps = <Pos, List<int>>{};
  for (final frame in frames.skip(1)) {
    (steps[frame.pos] ??= []).add(frame.step);
  }
  return [
    for (final MapEntry(:key, :value) in steps.entries) TrailMark(key, value),
  ];
}

/// Caption tiap langkah putar ulang (desain 09), langkah 0 sampai terakhir:
/// rekap singkat dengan arah layar (atas, bawah, kiri, kanan).
///
/// Langkah terakhir yang gagal menjelaskan sebabnya: keadaan yang sama
/// dengan langkah sebelumnya (mondar-mandir) atau batas [maxSteps].
List<String> replayCaptions(
  Board board,
  SimResult result,
  List<RunFrame> frames,
) {
  final hasVase = board.copyCells().contains(Cell.tableVase);
  final last = frames.length - 1;
  return [
    for (var step = 0; step <= last; step++)
      if (step == last && result.failReason == FailReason.loop)
        _loopCaption(frames)
      else if (step == last && result.failReason == FailReason.tooManySteps)
        'Langkah ke-$maxSteps, mangkuknya belum ketemu. Oyen bosan.'
      else
        _caption(board, frames, step, hasVase: hasVase),
  ];
}

String _caption(
  Board board,
  List<RunFrame> frames,
  int step, {
  required bool hasVase,
}) {
  final frame = frames[step];
  final action = frame.action;
  if (action == null) return 'Awal: Oyen tidur menghadap ${frame.dir.label}.';
  final dir = action.dir;
  switch (action.kind) {
    case StepKind.walk:
      if (frame.atBowl) {
        return 'Masuk mangkuk. Selesai dalam ${frames.length - 1} langkah.';
      }
      if (action.chasing != null) {
        return hasVase && !frame.vaseBroken
            ? 'Kejar ikan. Vas tetap aman.'
            : 'Kejar ikan ke ${dir.label}.';
      }
      final next = step + 1 < frames.length ? frames[step + 1].action : null;
      final fish = next?.chasing;
      if (fish != null) {
        return 'Ikan asin kelihatan lurus di ${_toward(action.pos, fish).label}.';
      }
      return 'Jalan lurus ke ${dir.label}.';
    case StepKind.scared:
      // Arah sesudah putar balik; airnya di belakang Oyen sekarang.
      final water = board.cellAt(action.pos + dir.opposite) == Cell.water
          ? 'genangan air'
          : 'ember air';
      return 'Ketemu $water, kaget, putar balik.';
    case StepKind.turn:
      final ahead = board.cellAt(action.pos + dir.counterClockwise);
      final what = ahead.isTable ? 'meja' : 'tembok';
      return 'Mentok $what, berputar menghadap ${dir.label}.';
    case StepKind.eat:
      return 'Hap! Ikan asin dimakan.';
    case StepKind.enterBox:
      return 'Masuk kardus, duduk dulu.';
    case StepKind.sit:
      return action.changed == null
          ? 'Masih duduk di kardus.'
          : 'Kardusnya penyok dan hilang.';
    case StepKind.knockGlass:
      return 'Gelas didorong jatuh. Aman, plastik.';
    case StepKind.knockVase:
      return 'Vas Ibu didorong jatuh. Pecah!';
  }
}

/// Langkah terakhir mondar-mandir: keadaannya sama persis dengan langkah
/// sebelumnya (posisi, arah, sisa duduk di kardus, benda, barang jatuh).
String _loopCaption(List<RunFrame> frames) {
  final last = frames.last;
  final same = frames.indexWhere((f) => _sameState(f, last));
  final when = same == 0 ? 'awal' : 'langkah $same';
  return 'Balik lagi seperti $when. Oyen muter terus, jadi bosan.';
}

bool _sameState(RunFrame a, RunFrame b) =>
    a.pos == b.pos &&
    a.dir == b.dir &&
    _sitLeft(a) == _sitLeft(b) &&
    a.cleared.length == b.cleared.length &&
    a.knocked.length == b.knocked.length;

/// Sisa langkah duduk di kardus sesudah [frame].
int _sitLeft(RunFrame frame) => switch (frame.action) {
  SimStep(kind: StepKind.enterBox) => 2,
  SimStep(kind: StepKind.sit, changed: null) => 1,
  _ => 0,
};

/// Arah dari [from] ke [to] yang sebaris atau sekolom.
Direction _toward(Pos from, Pos to) {
  if (to.x > from.x) return Direction.right;
  if (to.x < from.x) return Direction.left;
  return to.y > from.y ? Direction.down : Direction.up;
}
