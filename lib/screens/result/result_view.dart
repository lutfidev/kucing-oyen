import 'package:flutter/material.dart';

import '../../app/game_audio.dart';
import '../../game/model/level_session.dart';
import '../../game/model/run_frames.dart';
import '../../game/model/sounds.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'result_art.dart';
import 'result_parts.dart';

/// Layar hasil satu percobaan dari [session] (fase hasil): Berhasil (desain
/// 06), vas pecah (desain 07), atau Oyen bosan (desain 08).
class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.session,
    required this.onArrange,
    required this.onRestart,
    required this.onNext,
    this.onReplay,
    this.coins = 0,
  });

  final LevelSession session;

  /// Koin yang baru didapat; tampil di layar Berhasil dan vas pecah kalau
  /// lebih dari 0.
  final int coins;

  /// "Coba Lagi" dan "Atur Lagi": fase atur dengan susunan benda tetap.
  final VoidCallback onArrange;

  /// "Ulangi": fase atur dengan papan kosong.
  final VoidCallback onRestart;

  /// "Lanjut" dan "Lanjut Saja": level berikutnya.
  final VoidCallback onNext;

  /// "Tonton putar ulang" (Berhasil) dan "Putar Ulang" (Oyen bosan); null =
  /// nonaktif. Layar vas pecah tidak punya tombol putar ulang (desain 07).
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final level = session.level;
    final result = session.result!;
    final title = levelTitle(context.l10n, level);
    if (!result.win) {
      return BoredResult(
        levelId: level.id,
        reason: result.failReason!,
        scene: restScene(
          level.map,
          session.placed,
          runFrames(level.board, result),
        ),
        onArrange: onArrange,
        onReplay: onReplay,
      );
    }
    final brokenAt = result.vaseBrokenAtStep;
    if (brokenAt != null) {
      return VaseResult(
        title: title,
        steps: result.steps,
        itemsUsed: session.itemsUsed,
        brokenAt: brokenAt,
        onRetry: onArrange,
        onNext: onNext,
        coins: coins,
      );
    }
    return SuccessResult(
      title: title,
      stars: session.stars!,
      steps: result.steps,
      itemsUsed: session.itemsUsed,
      onRestart: onRestart,
      onNext: onNext,
      onReplay: onReplay,
      coins: coins,
    );
  }
}

/// Kotak "+N koin" di layar hasil.
ResultStat _coinStat(BuildContext context, int coins, {bool compact = false}) =>
    ResultStat(
      value: coins,
      prefix: '+',
      label: context.l10n.coinsUnit(coins),
      compact: compact,
      leading: CoinView(size: context.koSize.iconMedium),
    );

/// Layar Berhasil (desain 06): bintang muncul satu per satu di depan sinar
/// yang berputar, Oyen makan, jumlah langkah dan benda, syarat bintang,
/// Ulangi/Lanjut, dan "Tonton putar ulang".
class SuccessResult extends StatelessWidget {
  const SuccessResult({
    super.key,
    required this.title,
    required this.stars,
    required this.steps,
    required this.itemsUsed,
    required this.onRestart,
    required this.onNext,
    this.onReplay,
    this.coins = 0,
  });

  /// "Level 13 · Vas Ibu".
  final String title;

  /// Koin yang baru didapat; 0 = tanpa kotak koin.
  final int coins;

  /// 2 atau 3 (vas tidak pecah).
  final int stars;
  final int steps;
  final int itemsUsed;
  final VoidCallback onRestart;
  final VoidCallback onNext;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return ResultPage(
      background: c.cream,
      children: [
        // Sinar dipasang di sini supaya tergambar di belakang judul dan
        // bintang, dan di belakang kartu-kartu di bawahnya.
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: -ResultArt.raysBelowStars,
              height: 0,
              child: Center(child: ResultRays()),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultHeader(
                  kicker: title,
                  gap: space.s2,
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.l10n.success,
                      maxLines: 1,
                      style: t.display.copyWith(color: c.successDeep),
                    ),
                  ),
                ),
                SizedBox(height: space.s16),
                ResultStars(
                  earned: stars,
                  size: s.resultStar,
                  midSize: s.resultStarMid,
                  raise: space.s14,
                  strokeWidth: ResultArt.successStarStroke,
                  midStrokeWidth: ResultArt.successMidStarStroke,
                  shine: true,
                  pop: true,
                  afterSound: coins > 0 ? GameSound.coin : null,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: space.s10),
        Expanded(
          child: ResultArtSlot(
            size: ResultArt.successCard,
            child: const SuccessArt(),
          ),
        ),
        SizedBox(height: space.s16),
        ResultStats(
          children: [
            ResultStat(
              icon: KoIcons.steps,
              value: steps,
              label: l.stepsUnit(steps),
            ),
            ResultStat(
              icon: KoIcons.items,
              value: itemsUsed,
              label: l.itemsUsedUnit(itemsUsed),
            ),
            if (coins > 0) _coinStat(context, coins),
          ],
        ),
        SizedBox(height: space.s16),
        ResultRules(
          padding: space.s6,
          rules: [
            ResultRule(stars: 1, text: l.goalBowl, status: null),
            ResultRule(stars: 2, text: l.goalVase, status: null),
            ResultRule(
              stars: 3,
              text: l.goalItems,
              status: stars < 3 ? l.goalNotYet : null,
            ),
          ],
        ),
        SizedBox(height: space.s24),
        ResultButtons(
          flex: (5, 7),
          first: KoButton(
            label: l.restart,
            kind: KoButtonKind.secondary,
            icon: KoIcons.restart,
            onPressed: onRestart,
          ),
          second: KoButton(
            label: l.next,
            trailingIcon: KoIcons.next,
            onPressed: onNext,
          ),
        ),
        SizedBox(height: space.s14),
        _ReplayLink(onPressed: onReplay),
      ],
    );
  }
}

/// "Tonton putar ulang": tautan bergaris bawah di bawah tombol.
class _ReplayLink extends StatelessWidget {
  const _ReplayLink({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final enabled = onPressed != null;
    final color = enabled ? c.ink : c.muted;
    final label = context.l10n.watchReplay;
    final onTap = tapSound(context, onPressed);
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: context.koType.chipLabel.copyWith(
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layar vas pecah (desain 07): Oyen sampai tapi vas pecah, hanya 1 bintang.
class VaseResult extends StatelessWidget {
  const VaseResult({
    super.key,
    required this.title,
    required this.steps,
    required this.itemsUsed,
    required this.brokenAt,
    required this.onRetry,
    required this.onNext,
    this.coins = 0,
  });

  /// "Level 13 · Vas Ibu".
  final String title;

  /// Koin yang baru didapat; 0 = tanpa kotak koin.
  final int coins;
  final int steps;
  final int itemsUsed;

  /// Langkah vas pecah (`SimResult.vaseBrokenAtStep`).
  final int brokenAt;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return ResultPage(
      background: c.cream,
      children: [
        ResultHeader(
          kicker: title,
          gap: space.s6,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l.vaseHeadlineTop}\n'),
                TextSpan(
                  text: l.vaseHeadlineBottom,
                  style: TextStyle(color: c.brickDeep),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: t.headline,
          ),
        ),
        SizedBox(height: space.s6),
        ResultStars(
          earned: 1,
          size: s.partialStar,
          midSize: s.partialStarMid,
          raise: space.s10,
          strokeWidth: ResultArt.vaseStarStroke,
          afterSound: coins > 0 ? GameSound.coin : null,
        ),
        SizedBox(height: space.s6),
        Expanded(
          child: ResultArtSlot(
            size: ResultArt.vaseCard,
            child: const VaseArt(),
          ),
        ),
        SizedBox(height: space.s16),
        ResultRules(
          padding: space.s4,
          rules: [
            ResultRule(
              text: l.goalBowl,
              status: l.goalGot,
              statusColor: c.successText,
            ),
            ResultRule(
              text: l.goalVase,
              status: l.brokenAtStep(brokenAt),
              statusColor: c.brickDeep,
            ),
            ResultRule(text: l.goalItems, status: l.goalNotYet),
          ],
        ),
        SizedBox(height: space.s12),
        ResultStats(
          children: [
            ResultStat(value: steps, label: l.stepsUnit(steps), compact: true),
            ResultStat(
              value: itemsUsed,
              label: l.itemsUsedUnit(itemsUsed),
              compact: true,
            ),
            if (coins > 0) _coinStat(context, coins, compact: true),
          ],
        ),
        SizedBox(height: space.s16),
        ResultButtons(
          flex: (7, 5),
          first: KoButton(
            label: l.tryAgain,
            icon: KoIcons.retry,
            onPressed: onRetry,
          ),
          second: KoButton(
            label: l.nextAnyway,
            kind: KoButtonKind.secondary,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

/// Layar gagal (desain 08): Oyen tertidur lagi di papan yang pudar.
/// Mondar-mandir memakai teks desain; kelamaan (lewat [maxSteps] langkah)
/// belum ada di desain.
class BoredResult extends StatelessWidget {
  const BoredResult({
    super.key,
    required this.levelId,
    required this.reason,
    required this.scene,
    required this.onArrange,
    this.onReplay,
  });

  final int levelId;
  final FailReason reason;

  /// Papan terakhir dengan Oyen tidur ([restScene]).
  final BoardScene scene;
  final VoidCallback onArrange;
  final VoidCallback? onReplay;

  /// Judul, chip di atas papan, dan pesan di kartu.
  static (String, KoIconData, String, String) textsFor(
    AppLocalizations l,
    FailReason reason,
  ) => switch (reason) {
    FailReason.loop => (l.loopTitle, KoIcons.loop, l.loopBadge, l.loopMessage),
    FailReason.tooManySteps => (
      l.tooLongTitle,
      KoIcons.steps,
      l.tooLongBadge(maxSteps),
      l.tooLongMessage(maxSteps),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final (title, icon, badge, message) = textsFor(l, reason);
    final ring = context.koShadow.board.first.spreadRadius;
    return ResultPage(
      background: c.creamDim,
      children: [
        ResultHeader(
          kicker: l.failedKicker(levelId),
          gap: space.s4,
          // Satu baris seperti desain; mengecil kalau tidak muat.
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, maxLines: 1, style: t.headlineSmall),
          ),
        ),
        SizedBox(height: space.s24),
        Expanded(
          child: RestBoard(
            scene: scene,
            badge: RestBadge(icon: icon, text: badge),
          ),
        ),
        SizedBox(height: space.s16 + ring),
        KoCard(
          padding: EdgeInsets.symmetric(
            horizontal: space.s16,
            vertical: space.s14,
          ),
          child: Row(
            children: [
              Container(
                width: s.avatar,
                height: s.avatar,
                decoration: BoxDecoration(
                  color: c.creamDim,
                  borderRadius: BorderRadius.circular(context.koRadius.avatar),
                ),
                alignment: Alignment.center,
                child: ExcludeSemantics(
                  child: OyenView(
                    const OyenLook(pose: OyenPose.sleep),
                    size: ResultArt.restOyen,
                  ),
                ),
              ),
              SizedBox(width: space.s12),
              Expanded(child: Text(message, style: t.paragraph)),
            ],
          ),
        ),
        SizedBox(height: space.s24),
        ResultButtons(
          first: KoButton(
            label: l.replay,
            kind: KoButtonKind.secondary,
            icon: KoIcons.replay,
            onPressed: onReplay,
          ),
          second: KoButton(
            label: l.arrangeAgain,
            icon: KoIcons.edit,
            onPressed: onArrange,
          ),
        ),
      ],
    );
  }
}
