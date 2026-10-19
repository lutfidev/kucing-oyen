import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  RunFrame frame(StepKind kind, {Pos? changed}) => RunFrame(
    step: 1,
    pos: const Pos(1, 1),
    dir: Direction.right,
    action: SimStep(kind, const Pos(1, 1), Direction.right, changed: changed),
  );

  test('suara tiap jenis langkah', () {
    expect(
      {for (final kind in StepKind.values) kind: stepSound(frame(kind))},
      {
        StepKind.sit: null,
        StepKind.knockGlass: GameSound.glass,
        StepKind.knockVase: GameSound.vase,
        StepKind.scared: GameSound.scared,
        StepKind.turn: null,
        StepKind.eat: GameSound.eat,
        StepKind.enterBox: GameSound.box,
        StepKind.walk: null,
      },
    );
  });

  test('langkah 0 senyap', () {
    expect(
      stepSound(const RunFrame(step: 0, pos: Pos(1, 1), dir: Direction.right)),
      isNull,
    );
  });

  test('berkas suara dan lagu', () {
    expect(GameSound.tap.asset, 'audio/sfx/tap.ogg');
    expect(GameSound.pickUp.asset, 'audio/sfx/pick_up.ogg');
    expect(MusicTrack.home.asset, 'audio/music/home.ogg');
    expect(MusicTrack.level.asset, 'audio/music/level.ogg');
    final assets = [for (final s in GameSound.values) s.asset];
    expect(assets.toSet(), hasLength(GameSound.values.length));
  });
}
