import 'package:flutter/material.dart';

import '../../game/model/level_session.dart';
import '../../game/model/run_frames.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
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
  });

  final LevelSession session;

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
    final title = 'Level ${level.id} · ${level.name}';
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
    );
  }
}

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
  });

  /// "Level 13 · Vas Ibu".
  final String title;

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
                      'Berhasil!',
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
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: space.s10),
        const Expanded(
          child: ResultArtSlot(
            size: ResultArt.successCard,
            child: SuccessArt(),
          ),
        ),
        SizedBox(height: space.s16),
        ResultStats(
          children: [
            ResultStat(icon: KoIcons.steps, value: steps, label: 'langkah'),
            ResultStat(
              icon: KoIcons.items,
              value: itemsUsed,
              label: 'benda dipakai',
            ),
          ],
        ),
        SizedBox(height: space.s16),
        ResultRules(
          padding: space.s6,
          rules: [
            const ResultRule(stars: 1, text: 'Sampai mangkuk', status: null),
            const ResultRule(stars: 2, text: 'Vas Ibu aman', status: null),
            ResultRule(
              stars: 3,
              text: 'Benda paling sedikit',
              status: stars < 3 ? 'Belum' : null,
            ),
          ],
        ),
        SizedBox(height: space.s24),
        ResultButtons(
          flex: (5, 7),
          first: KoButton(
            label: 'Ulangi',
            kind: KoButtonKind.secondary,
            icon: KoIcons.restart,
            onPressed: onRestart,
          ),
          second: KoButton(
            label: 'Lanjut',
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

  static const label = 'Tonton putar ulang';

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final enabled = onPressed != null;
    final color = enabled ? c.ink : c.muted;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onPressed,
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
  });

  /// "Level 13 · Vas Ibu".
  final String title;
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
    return ResultPage(
      background: c.cream,
      children: [
        ResultHeader(
          kicker: title,
          gap: space.s6,
          title: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Sampai sih...\n'),
                TextSpan(
                  text: 'tapi vas Ibu?',
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
        ),
        SizedBox(height: space.s6),
        const Expanded(
          child: ResultArtSlot(size: ResultArt.vaseCard, child: VaseArt()),
        ),
        SizedBox(height: space.s16),
        ResultRules(
          padding: space.s4,
          rules: [
            ResultRule(
              text: 'Sampai mangkuk',
              status: 'Dapat',
              statusColor: c.successText,
            ),
            ResultRule(
              text: 'Vas Ibu aman',
              status: 'Pecah di langkah $brokenAt',
              statusColor: c.brickDeep,
            ),
            const ResultRule(text: 'Benda paling sedikit', status: 'Belum'),
          ],
        ),
        SizedBox(height: space.s12),
        ResultStats(
          children: [
            ResultStat(value: steps, label: 'langkah', compact: true),
            ResultStat(value: itemsUsed, label: 'benda dipakai', compact: true),
          ],
        ),
        SizedBox(height: space.s16),
        ResultButtons(
          flex: (7, 5),
          first: KoButton(
            label: 'Coba Lagi',
            icon: KoIcons.retry,
            onPressed: onRetry,
          ),
          second: KoButton(
            label: 'Lanjut Saja',
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
  static (String, KoIconData, String, String) textsFor(FailReason reason) =>
      switch (reason) {
        FailReason.loop => (
          'Oyen bosan mondar-mandir.',
          KoIcons.loop,
          'Muter terus',
          'Jalannya muter-muter terus, nggak ketemu mangkuk. '
              'Ya sudah, tidur lagi.',
        ),
        FailReason.tooManySteps => (
          'Oyen bosan jalan terus.',
          KoIcons.steps,
          'Lewat $maxSteps langkah',
          'Sudah $maxSteps langkah, mangkuknya belum ketemu juga. '
              'Capek, ah. Tidur lagi.',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final (title, icon, badge, message) = textsFor(reason);
    final ring = context.koShadow.board.first.spreadRadius;
    return ResultPage(
      background: c.creamDim,
      children: [
        ResultHeader(
          kicker: 'Level $levelId · Gagal',
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
            label: 'Putar Ulang',
            kind: KoButtonKind.secondary,
            icon: KoIcons.replay,
            onPressed: onReplay,
          ),
          second: KoButton(
            label: 'Atur Lagi',
            icon: KoIcons.edit,
            onPressed: onArrange,
          ),
        ),
      ],
    );
  }
}
