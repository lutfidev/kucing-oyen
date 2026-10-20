import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../game/model/rewards.dart';
import '../../game/model/sounds.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Membuka sheet Tambah Koin: bonus harian dan iklan berhadiah koin. Gaya
/// mengikuti sheet Petunjuk (desain 10); sheet ini tidak ada di desain.
Future<void> showCoinSheet(BuildContext context, ProgressController progress) =>
    showKoSheet(
      context,
      barrierLabel: context.l10n.closeCoins,
      barrierColor: context.koColors.scrimLight,
      builder: (context, onClose) =>
          CoinSheet(progress: progress, onClose: onClose),
    );

/// Isi sheet Tambah Koin: koin, judul, saldo, tombol tutup, lalu kartu
/// bonus harian dan kartu iklan. Dibangun ulang saat [progress] berubah.
class CoinSheet extends StatefulWidget {
  const CoinSheet({super.key, required this.progress, required this.onClose});

  final ProgressController progress;
  final VoidCallback onClose;

  @override
  State<CoinSheet> createState() => _CoinSheetState();
}

class _CoinSheetState extends State<CoinSheet> {
  /// Iklan sedang diputar.
  bool _waiting = false;

  /// Iklan terakhir gagal.
  bool _failed = false;

  Future<void> _watch() async {
    if (_waiting) return;
    setState(() {
      _waiting = true;
      _failed = false;
    });
    final result = await widget.progress.watchAdForCoins();
    if (!mounted) return;
    setState(() {
      _waiting = false;
      _failed = result == AdReward.failed;
    });
    if (result == AdReward.rewarded) _playCoin();
  }

  /// Saldo bertambah langsung (sebelum disimpan), jadi suaranya juga.
  void _claimBonus() {
    final progress = widget.progress;
    if (!progress.canClaimBonus) return;
    unawaited(progress.claimDailyBonus());
    _playCoin();
  }

  void _playCoin() => AudioScope.maybeRead(context)?.play(GameSound.coin);

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: widget.progress,
      builder: (context, _) {
        final progress = widget.progress;
        final bonus = progress.canClaimBonus;
        final adsLeft = progress.adsLeft;
        final canWatch = adsLeft > 0 && !_waiting;
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CoinView(size: s.iconButton),
                SizedBox(width: space.s10),
                Expanded(
                  // Mengecil di layar sempit, tidak terpotong.
                  child: Semantics(
                    header: true,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(l.coinsTitle, maxLines: 1, style: t.title),
                    ),
                  ),
                ),
                SizedBox(width: space.s10),
                KoCoinChip(
                  coins: progress.coins,
                  style: KoCoinChipStyle.compact,
                ),
                SizedBox(width: space.s10),
                KoIconButton(
                  icon: KoIcons.close,
                  semanticLabel: l.close,
                  tone: KoIconButtonTone.flat,
                  iconSize: s.iconSmall,
                  onPressed: widget.onClose,
                ),
              ],
            ),
            // Seperti sheet Petunjuk: jarak 12 dikurangi margin -4.
            SizedBox(height: space.s8),
            Text(l.coinsIntro, style: t.bodySmall.copyWith(color: c.inkSoft)),
          ],
        );
        return KoSheet(
          label: l.coinsTitle,
          onClose: widget.onClose,
          header: header,
          children: [
            RewardCard(
              key: const ValueKey('coin-bonus'),
              icon: KoIcons.gift,
              title: l.dailyBonus,
              status: bonus ? l.dailyBonusReady : l.dailyBonusTaken,
              done: !bonus,
              button: SheetButton(
                label: bonus ? l.claimCoins(dailyBonusCoins) : l.claimTomorrow,
                icon: CoinView(size: s.iconCompact, kind: CoinKind.plain),
                color: c.orange,
                line: c.orange,
                edge: c.orangeDeep,
                onPressed: bonus ? _claimBonus : null,
              ),
            ),
            SizedBox(height: space.s10),
            RewardCard(
              key: const ValueKey('coin-ad'),
              icon: KoIcons.ad,
              title: l.watchAd,
              status: adsLeft > 0 ? l.adsLeftToday(adsLeft) : l.adsUsedUp,
              done: adsLeft == 0,
              button: SheetButton(
                label: adsLeft > 0
                    ? l.adRewardButton(adRewardCoins)
                    : l.adsTomorrow,
                icon: KoIcon(
                  KoIcons.ad,
                  size: s.iconCompact,
                  color: canWatch ? c.ink : c.onLockedSoft,
                ),
                color: c.surface,
                line: c.line,
                edge: c.lineDeep,
                onPressed: canWatch ? _watch : null,
              ),
              message: _failed ? l.adFailed : null,
            ),
          ],
        );
      },
    );
  }
}

/// Satu cara mendapat koin: ikon dalam lingkaran, judul, keadaan, tombol,
/// dan pesan gagal. [done] = jatah hari ini sudah dipakai (lingkaran hijau
/// bercentang).
class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.done,
    required this.button,
    this.message,
  });

  final KoIconData icon;
  final String title;
  final String status;
  final bool done;
  final Widget button;

  /// Pesan merah bata di bawah tombol (iklan gagal).
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final message = this.message;
    return KoCard(
      borderColor: done ? c.success : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: s.chipSmall,
                height: s.chipSmall,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? c.success : c.ink,
                  shape: BoxShape.circle,
                ),
                child: KoIcon(
                  done ? KoIcons.check : icon,
                  size: s.iconCompact,
                  color: done ? c.onSuccess : c.cream,
                ),
              ),
              SizedBox(width: space.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.cardTitle),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        status,
                        style: t.controlLabel.copyWith(color: c.inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: space.s10),
          button,
          if (message != null) ...[
            SizedBox(height: space.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: t.controlLabel.copyWith(color: c.brickDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
