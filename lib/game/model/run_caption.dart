import '../sim/sim.dart';
import 'run_frames.dart';

/// Caption langkah ke-[step] fase jalan (desain 04): bahasa santai dengan
/// arah layar (atas, bawah, kiri, kanan).
///
/// [frames] dari `runFrames`; [board] dipakai untuk tahu Oyen mentok tembok
/// atau meja.
String runCaption(Board board, List<RunFrame> frames, int step) {
  final frame = frames[step];
  final action = frame.action;
  if (action == null) return 'Oyen bangun, menghadap ${frame.dir.label}.';
  final dir = action.dir;
  switch (action.kind) {
    case StepKind.walk:
      if (frame.atBowl) return 'Sampai di mangkuk! Nyam nyam.';
      if (action.chasing != null) return 'Kejar ikan ke ${dir.label}.';
      final next = step + 1 < frames.length ? frames[step + 1].action : null;
      final fish = next?.chasing;
      if (fish != null) {
        return 'Eh, ada bau ikan asin di ${_toward(action.pos, fish).label}!';
      }
      return 'Jalan lurus ke ${dir.label}, santai.';
    case StepKind.scared:
      return 'Ada air! Oyen kaget, lalu putar balik.';
    case StepKind.turn:
      final ahead = board.cellAt(action.pos + dir.counterClockwise);
      final what = ahead.isTable ? 'meja' : 'tembok';
      return 'Mentok $what. Berputar, sekarang menghadap ${dir.label}.';
    case StepKind.eat:
      return 'Hap! Ikan asinnya dimakan.';
    case StepKind.enterBox:
      return 'Ada kardus! Oyen masuk lalu duduk.';
    case StepKind.sit:
      return action.changed == null
          ? 'Duduk manis di dalam kardus.'
          : 'Kardusnya penyok, lalu hilang.';
    case StepKind.knockGlass:
      return 'Gelas didorong jatuh. Untung plastik!';
    case StepKind.knockVase:
      return 'Waduh! Vas Ibu jatuh dan pecah.';
  }
}

/// Arah dari [from] ke [to] yang sebaris atau sekolom.
Direction _toward(Pos from, Pos to) {
  if (to.x > from.x) return Direction.right;
  if (to.x < from.x) return Direction.left;
  return to.y > from.y ? Direction.down : Direction.up;
}
