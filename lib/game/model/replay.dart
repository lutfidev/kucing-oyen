import '../sim/sim.dart';
import 'run_caption.dart';
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

/// Jenis caption putar ulang (desain 09).
enum ReplayTextKind {
  asleep,
  finished,
  chase,
  chaseVaseSafe,
  seeFish,
  walk,
  scared,
  turn,
  eat,
  enterBox,
  sit,
  boxGone,
  knockGlass,
  knockVase,
  loopStart,
  loopStep,
  tooManySteps,
}

/// Isi caption satu langkah putar ulang sebagai data; kalimatnya disusun
/// per bahasa di lapisan teks (`replayCaptionText`).
class ReplayText {
  const ReplayText(
    this.kind, {
    this.dir,
    this.obstacle,
    this.water,
    this.number,
  });

  final ReplayTextKind kind;

  /// Arah layar yang disebut caption.
  final Direction? dir;

  /// Yang membuat Oyen berputar ([ReplayTextKind.turn]).
  final Obstacle? obstacle;

  /// Air yang membuat Oyen kaget ([ReplayTextKind.scared]).
  final WaterSource? water;

  /// Jumlah langkah ([ReplayTextKind.finished]), langkah yang terulang
  /// ([ReplayTextKind.loopStep]), atau batas langkah
  /// ([ReplayTextKind.tooManySteps]).
  final int? number;

  @override
  bool operator ==(Object other) =>
      other is ReplayText &&
      other.kind == kind &&
      other.dir == dir &&
      other.obstacle == obstacle &&
      other.water == water &&
      other.number == number;

  @override
  int get hashCode => Object.hash(kind, dir, obstacle, water, number);

  @override
  String toString() =>
      'ReplayText(${kind.name}'
      '${dir == null ? '' : ', ${dir!.name}'}'
      '${obstacle == null ? '' : ', ${obstacle!.name}'}'
      '${water == null ? '' : ', ${water!.name}'}'
      '${number == null ? '' : ', $number'})';
}

/// Caption tiap langkah putar ulang (desain 09), langkah 0 sampai terakhir:
/// rekap singkat dengan arah layar.
///
/// Langkah terakhir yang gagal menjelaskan sebabnya: keadaan yang sama
/// dengan langkah sebelumnya (mondar-mandir) atau batas [maxSteps].
List<ReplayText> replayCaptions(
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
        const ReplayText(ReplayTextKind.tooManySteps, number: maxSteps)
      else
        _caption(board, frames, step, hasVase: hasVase),
  ];
}

ReplayText _caption(
  Board board,
  List<RunFrame> frames,
  int step, {
  required bool hasVase,
}) {
  final frame = frames[step];
  final action = frame.action;
  if (action == null) return ReplayText(ReplayTextKind.asleep, dir: frame.dir);
  final dir = action.dir;
  switch (action.kind) {
    case StepKind.walk:
      if (frame.atBowl) {
        return ReplayText(ReplayTextKind.finished, number: frames.length - 1);
      }
      if (action.chasing != null) {
        return hasVase && !frame.vaseBroken
            ? const ReplayText(ReplayTextKind.chaseVaseSafe)
            : ReplayText(ReplayTextKind.chase, dir: dir);
      }
      final next = step + 1 < frames.length ? frames[step + 1].action : null;
      final fish = next?.chasing;
      if (fish != null) {
        return ReplayText(
          ReplayTextKind.seeFish,
          dir: toward(action.pos, fish),
        );
      }
      return ReplayText(ReplayTextKind.walk, dir: dir);
    case StepKind.scared:
      // Arah sesudah putar balik; airnya di belakang Oyen sekarang.
      return ReplayText(
        ReplayTextKind.scared,
        water: board.cellAt(action.pos + dir.opposite) == Cell.water
            ? WaterSource.puddle
            : WaterSource.bucket,
      );
    case StepKind.turn:
      return ReplayText(
        ReplayTextKind.turn,
        dir: dir,
        obstacle: obstacleAt(board, action.pos + dir.counterClockwise),
      );
    case StepKind.eat:
      return const ReplayText(ReplayTextKind.eat);
    case StepKind.enterBox:
      return const ReplayText(ReplayTextKind.enterBox);
    case StepKind.sit:
      return ReplayText(
        action.changed == null ? ReplayTextKind.sit : ReplayTextKind.boxGone,
      );
    case StepKind.knockGlass:
      return const ReplayText(ReplayTextKind.knockGlass);
    case StepKind.knockVase:
      return const ReplayText(ReplayTextKind.knockVase);
  }
}

/// Langkah terakhir mondar-mandir: keadaannya sama persis dengan langkah
/// sebelumnya (posisi, arah, sisa duduk di kardus, benda, barang jatuh).
ReplayText _loopCaption(List<RunFrame> frames) {
  final last = frames.last;
  final same = frames.indexWhere((f) => _sameState(f, last));
  return same == 0
      ? const ReplayText(ReplayTextKind.loopStart)
      : ReplayText(ReplayTextKind.loopStep, number: same);
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
