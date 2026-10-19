import '../sim/sim.dart';
import 'run_frames.dart';

/// Penghalang di depan Oyen saat berputar.
enum Obstacle { table, wall }

/// Air yang membuat Oyen kaget: genangan bawaan peta atau ember pemain.
enum WaterSource { puddle, bucket }

/// Jenis caption fase jalan (desain 04).
enum RunTextKind {
  wake,
  atBowl,
  chase,
  smellFish,
  walk,
  scared,
  turn,
  eat,
  enterBox,
  sit,
  boxGone,
  knockGlass,
  knockVase,
}

/// Isi caption satu langkah fase jalan sebagai data; kalimatnya disusun
/// per bahasa di lapisan teks (`runCaptionText`).
class RunText {
  const RunText(this.kind, {this.dir, this.obstacle});

  final RunTextKind kind;

  /// Arah layar yang disebut caption (hadap, jalan, kejar, bau ikan).
  final Direction? dir;

  /// Yang membuat Oyen berputar ([RunTextKind.turn]).
  final Obstacle? obstacle;

  @override
  bool operator ==(Object other) =>
      other is RunText &&
      other.kind == kind &&
      other.dir == dir &&
      other.obstacle == obstacle;

  @override
  int get hashCode => Object.hash(kind, dir, obstacle);

  @override
  String toString() =>
      'RunText(${kind.name}'
      '${dir == null ? '' : ', ${dir!.name}'}'
      '${obstacle == null ? '' : ', ${obstacle!.name}'})';
}

/// Caption langkah ke-[step] fase jalan (desain 04) dengan arah layar.
///
/// [frames] dari `runFrames`; [board] dipakai untuk tahu Oyen mentok tembok
/// atau meja.
RunText runCaption(Board board, List<RunFrame> frames, int step) {
  final frame = frames[step];
  final action = frame.action;
  if (action == null) return RunText(RunTextKind.wake, dir: frame.dir);
  final dir = action.dir;
  switch (action.kind) {
    case StepKind.walk:
      if (frame.atBowl) return const RunText(RunTextKind.atBowl);
      if (action.chasing != null) return RunText(RunTextKind.chase, dir: dir);
      final next = step + 1 < frames.length ? frames[step + 1].action : null;
      final fish = next?.chasing;
      if (fish != null) {
        return RunText(RunTextKind.smellFish, dir: toward(action.pos, fish));
      }
      return RunText(RunTextKind.walk, dir: dir);
    case StepKind.scared:
      return const RunText(RunTextKind.scared);
    case StepKind.turn:
      return RunText(
        RunTextKind.turn,
        dir: dir,
        obstacle: obstacleAt(board, action.pos + dir.counterClockwise),
      );
    case StepKind.eat:
      return const RunText(RunTextKind.eat);
    case StepKind.enterBox:
      return const RunText(RunTextKind.enterBox);
    case StepKind.sit:
      return RunText(
        action.changed == null ? RunTextKind.sit : RunTextKind.boxGone,
      );
    case StepKind.knockGlass:
      return const RunText(RunTextKind.knockGlass);
    case StepKind.knockVase:
      return const RunText(RunTextKind.knockVase);
  }
}

/// Penghalang di petak [pos]: meja, atau tembok untuk lainnya.
Obstacle obstacleAt(Board board, Pos pos) =>
    board.cellAt(pos).isTable ? Obstacle.table : Obstacle.wall;

/// Arah dari [from] ke [to] yang sebaris atau sekolom.
Direction toward(Pos from, Pos to) {
  if (to.x > from.x) return Direction.right;
  if (to.x < from.x) return Direction.left;
  return to.y > from.y ? Direction.down : Direction.up;
}
