import '../model/replay.dart';
import '../model/run_frames.dart';
import '../sim/sim.dart';
import 'board_scene.dart';
import 'item_art.dart';
import 'oyen.dart';
import 'tile.dart';

/// Tampilan Oyen di [frame] fase jalan (desain 04).
///
/// - jalan: `walk`, dengan gelembung ikan kalau sedang mengejar ikan;
///   langkah terakhir di mangkuk: `eat` seperti desain.
/// - kaget: `shock` dan gelembung kaget, masih menghadap air (seperti
///   desain); arah sesudah putar balik baru tampil di langkah berikutnya.
/// - berputar: `idle` dengan arah baru.
/// - masuk kardus dan duduk: `box`; saat kardusnya penyok: `idle`.
/// - menjatuhkan: `knock` menghadap bawah (GDD: "menatap pemain"),
///   dicerminkan kalau mejanya di kiri supaya tangannya ke arah meja.
/// - makan: `eat`.
OyenLook runLook(RunFrame frame) {
  final action = frame.action;
  final dir = frame.dir;
  if (action == null) return OyenLook(dir: dir);
  return switch (action.kind) {
    StepKind.walk when frame.atBowl => OyenLook(pose: OyenPose.eat, dir: dir),
    StepKind.walk => OyenLook(
      pose: OyenPose.walk,
      dir: dir,
      bubble: action.chasing == null ? OyenBubble.none : OyenBubble.ikan,
    ),
    StepKind.scared => OyenLook(
      pose: OyenPose.shock,
      dir: dir.opposite,
      bubble: OyenBubble.kaget,
    ),
    StepKind.turn => OyenLook(dir: dir),
    StepKind.enterBox || StepKind.sit => OyenLook(
      pose: frame.inBox ? OyenPose.box : OyenPose.idle,
      dir: dir,
    ),
    StepKind.knockGlass || StepKind.knockVase => OyenLook(
      pose: OyenPose.knock,
      mirror: action.changed!.x < frame.pos.x,
    ),
    StepKind.eat => OyenLook(pose: OyenPose.eat, dir: dir),
  };
}

/// Papan di langkah ke-[step] fase jalan ([frames] dari `runFrames`): peta
/// [map] dengan benda pemain [placed], tanpa benda yang sudah hilang (ikan
/// dimakan, kardus penyok), barang yang sudah jatuh, jalur Oyen sampai
/// langkah ini (desain 04), dan Oyen ([runLook]).
///
/// Selama Oyen duduk di kardus, kardusnya ikut digambar pose `box`, jadi
/// petaknya dikosongkan.
BoardScene runScene(
  List<String> map,
  Iterable<Placement> placed,
  List<RunFrame> frames,
  int step,
) {
  final frame = frames[step];
  return _scene(
    map,
    placed,
    frames,
    step,
    BoardOyen.at(frame.pos, runLook(frame)),
    hideBox: frame.inBox,
  );
}

/// Papan layar gagal (desain 08): keadaan papan di langkah terakhir dengan
/// seluruh jalur Oyen, dan Oyen tertidur lagi (Zzz) di petak terakhirnya
/// menghadap arah terakhirnya, tanpa panah arah hadap. Kardus tempat Oyen
/// duduk tetap tergambar di bawahnya.
BoardScene restScene(
  List<String> map,
  Iterable<Placement> placed,
  List<RunFrame> frames,
) {
  final frame = frames.last;
  return _scene(
    map,
    placed,
    frames,
    frames.length - 1,
    BoardOyen.at(
      frame.pos,
      OyenLook(pose: OyenPose.sleep, dir: frame.dir, bubble: OyenBubble.zzz),
    ),
    facing: false,
  );
}

/// Papan putar ulang (desain 09) di langkah ke-[step]: keadaan papan dan
/// Oyen seperti fase jalan ([runScene]), tapi dengan seluruh jalur Oyen dan
/// nomor jejak [trail] (dari `replayTrail`) sejak langkah 0; nomor petak
/// langkah ini menyala. Di langkah 0 Oyen masih tidur, tanpa Zzz dan panah
/// arah hadap (desain).
BoardScene replayScene(
  List<String> map,
  Iterable<Placement> placed,
  List<RunFrame> frames,
  List<TrailMark> trail,
  int step,
) {
  final frame = frames[step];
  return _scene(
    map,
    placed,
    frames,
    step,
    BoardOyen.at(
      frame.pos,
      step == 0
          ? OyenLook(pose: OyenPose.sleep, dir: frame.dir)
          : runLook(frame),
    ),
    hideBox: frame.inBox,
    facing: false,
    pathTo: frames.length - 1,
    trail: [
      for (final mark in trail)
        BoardMark(mark.pos, mark.label, active: mark.steps.contains(step)),
    ],
  );
}

/// Jalur digambar sampai langkah [pathTo] (bawaan: [step]).
BoardScene _scene(
  List<String> map,
  Iterable<Placement> placed,
  List<RunFrame> frames,
  int step,
  BoardOyen oyen, {
  bool hideBox = false,
  bool facing = true,
  int? pathTo,
  List<BoardMark> trail = const [],
}) {
  final frame = frames[step];
  final path = <Pos>[];
  for (final f in frames.take((pathTo ?? step) + 1)) {
    if (path.isEmpty || path.last != f.pos) path.add(f.pos);
  }
  return BoardScene.fromMap(
    map,
    items: {
      for (final p in placed) p.pos: ItemArt.tileItem(p.item),
      for (final pos in frame.cleared) pos: TileItem.none,
      if (hideBox) frame.pos: TileItem.none,
    },
    knocked: frame.knocked,
    oyen: oyen,
    facing: facing,
    path: path,
    trail: trail,
  );
}
