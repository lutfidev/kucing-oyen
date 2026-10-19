import '../game/model/replay.dart';
import '../game/model/run_caption.dart';
import 'app_localizations.dart';

export '../game/model/replay.dart' show ReplayText, ReplayTextKind;
export '../game/model/run_caption.dart'
    show Obstacle, RunText, RunTextKind, WaterSource;

/// Kalimat caption fase jalan (desain 04) dalam bahasa [l].
String runCaptionText(AppLocalizations l, RunText text) {
  final dir = text.dir?.name ?? '';
  final obstacle = text.obstacle?.name ?? '';
  return switch (text.kind) {
    RunTextKind.wake => l.runWake(dir),
    RunTextKind.atBowl => l.runAtBowl,
    RunTextKind.chase => l.chaseFish(dir),
    RunTextKind.smellFish => l.runSmellFish(dir),
    RunTextKind.walk => l.runWalk(dir),
    RunTextKind.scared => l.runScared,
    RunTextKind.turn => l.runTurn(obstacle, dir),
    RunTextKind.eat => l.runEat,
    RunTextKind.enterBox => l.runEnterBox,
    RunTextKind.sit => l.runSit,
    RunTextKind.boxGone => l.runBoxGone,
    RunTextKind.knockGlass => l.runKnockGlass,
    RunTextKind.knockVase => l.runKnockVase,
  };
}

/// Kalimat caption putar ulang (desain 09) dalam bahasa [l].
String replayCaptionText(AppLocalizations l, ReplayText text) {
  final dir = text.dir?.name ?? '';
  final number = text.number ?? 0;
  return switch (text.kind) {
    ReplayTextKind.asleep => l.replayAsleep(dir),
    ReplayTextKind.finished => l.replayFinished(number),
    ReplayTextKind.chase => l.chaseFish(dir),
    ReplayTextKind.chaseVaseSafe => l.replayChaseVaseSafe,
    ReplayTextKind.seeFish => l.replaySeeFish(dir),
    ReplayTextKind.walk => l.replayWalk(dir),
    ReplayTextKind.scared => l.replayScared(text.water?.name ?? ''),
    ReplayTextKind.turn => l.replayTurn(text.obstacle?.name ?? '', dir),
    ReplayTextKind.eat => l.replayEat,
    ReplayTextKind.enterBox => l.replayEnterBox,
    ReplayTextKind.sit => l.replaySit,
    ReplayTextKind.boxGone => l.replayBoxGone,
    ReplayTextKind.knockGlass => l.replayKnockGlass,
    ReplayTextKind.knockVase => l.replayKnockVase,
    ReplayTextKind.loopStart => l.replayLoopStart,
    ReplayTextKind.loopStep => l.replayLoopStep(number),
    ReplayTextKind.tooManySteps => l.replayTooManySteps(number),
  };
}
