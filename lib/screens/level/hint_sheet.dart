import 'package:flutter/material.dart';

import '../../app/hint_source.dart';
import '../../app/progress_scope.dart';
import '../coins/coin_sheet.dart';
import '../../widgets/v2/ui_button.dart';
import '../../game/model/hints.dart';
import '../../game/sim/sim.dart';
import '../../l10n/hint_texts.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/widgets.dart';
import '../../widgets/v2/ui_panel.dart';

/// Membuka sheet Petunjuk (desain 10) untuk [level]. Ditutup dengan tombol
/// tutup, ketuk latar gelap, tombol kembali sistem, atau tarik ke bawah.
Future<void> showHintSheet(
  BuildContext context, {
  required Level level,
  required HintSource hints,
}) => showKoSheet(
  context,
  barrierLabel: context.l10n.closeHints,
  barrierColor: context.koColors.scrimLight,
  builder: (context, onClose) =>
      HintSheet(level: level, hints: hints, onClose: onClose),
);

/// Isi sheet Petunjuk: bohlam, judul, saldo koin, tombol tutup, lalu tiga
/// kartu tingkat ([HintTierCard]) yang dibuka berurutan. Level tanpa benda
/// hanya berisi satu pesan. Dibangun ulang saat [hints] berubah.
class HintSheet extends StatefulWidget {
  const HintSheet({
    super.key,
    required this.level,
    required this.hints,
    required this.onClose,
  });

  final Level level;
  final HintSource hints;
  final VoidCallback onClose;

  @override
  State<HintSheet> createState() => _HintSheetState();
}

class _HintSheetState extends State<HintSheet> {
  /// Tingkat yang sedang menunggu iklan.
  int? _waiting;
  HintPay? _payment;

  /// Tingkat yang iklannya terakhir gagal.
  int? _failed;

  Future<void> _unlock(int tier, HintPay pay) async {
    if (_waiting != null) return;
    setState(() {
      _failed = null;
      _waiting = tier;
      _payment = pay;
    });
    final result = await widget.hints.unlockHint(widget.level.id, tier, pay);
    if (!mounted) return;
    setState(() {
      _waiting = null;
      _payment = null;
      if (result == HintUnlock.adFailed) _failed = tier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return ListenableBuilder(
      listenable: widget.hints,
      builder: (context, _) {
        final coins = widget.hints.coins;
        final opened = widget.hints.hintTier(widget.level.id);
        final header = UiSheetHeader(
          title: context.l10n.hintsTitle,
          subtitle: context.l10n.hintsIntro,
          trailing: KoCoinChip(coins: coins, style: KoCoinChipStyle.compact),
          onClose: widget.onClose,
        );
        final List<Widget> cards;
        if (widget.level.solution.isEmpty) {
          cards = [
            UiPanel(
              borderColor: c.success,
              child: _Reveal(context.l10n.noItemsHint),
            ),
          ];
        } else {
          cards = [
            for (var tier = 1; tier <= maxHintTier; tier++) ...[
              if (tier > 1) SizedBox(height: space.s10),
              HintTierCard(
                key: ValueKey('hint-tier-$tier'),
                tier: tier,
                open: tier <= opened,
                ready: tier == opened + 1,
                text: hintTextFor(context.l10n, hintText(widget.level, tier)),
                coins: coins,
                waiting: _waiting == tier,
                saving: _waiting == tier && _payment == HintPay.coins,
                blocked:
                    widget.hints is ProgressController &&
                    (widget.hints as ProgressController).saveFailed,
                adFailed: _failed == tier,
                onWatch: () => _unlock(tier, HintPay.ad),
                onPay: () => _unlock(tier, HintPay.coins),
              ),
            ],
          ];
        }
        return KoSheet(
          label: context.l10n.hintsTitle,
          onClose: widget.onClose,
          header: header,
          children: [
            if (widget.hints case final ProgressController progress
                when progress.saveFailed)
              UiSaveNotice(
                onRetry: () async {
                  await progress.retrySaves();
                  if (mounted) setState(() {});
                },
              ),
            ...cards,
            if (widget.hints case final ProgressController progress) ...[
              SizedBox(height: space.s16),
              UiButton(
                label: context.l10n.coinsTitle,
                kind: UiButtonKind.secondary,
                onPressed: _waiting != null
                    ? null
                    : () => showCoinSheet(context, progress),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Satu tingkat petunjuk: terbuka (teks petunjuk), siap dibuka (tombol
/// "Tonton iklan" dan bayar koin), atau terkunci sampai tingkat sebelumnya
/// terbuka.
class HintTierCard extends StatelessWidget {
  const HintTierCard({
    super.key,
    required this.tier,
    required this.open,
    required this.ready,
    required this.text,
    required this.coins,
    required this.onWatch,
    required this.onPay,
    this.waiting = false,
    this.saving = false,
    this.blocked = false,
    this.adFailed = false,
  });

  /// 1–3.
  final int tier;
  final bool open;

  /// Tingkat berikutnya yang boleh dibuka.
  final bool ready;

  /// Teks petunjuk, tampil kalau [open].
  final String text;

  /// Saldo, untuk label tombol koin.
  final int coins;
  final VoidCallback onWatch;
  final VoidCallback onPay;

  /// Iklan tingkat ini sedang diputar: kedua tombol nonaktif.
  final bool waiting;
  final bool saving;
  final bool blocked;

  /// Iklan tingkat ini terakhir gagal.
  final bool adFailed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final locked = !open && !ready;
    final cost = hintCost(tier);
    final enabled = ready && !waiting && !blocked;
    final l = context.l10n;
    final title = switch (tier) {
      1 => l.hintTier1Title,
      2 => l.hintTier2Title,
      _ => l.hintTier3Title,
    };

    final head = Row(
      children: [
        Container(
          width: s.chipSmall,
          height: s.chipSmall,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: open ? c.success : c.ink,
            shape: BoxShape.circle,
          ),
          child: ExcludeSemantics(
            child: Text(
              '$tier',
              style: t.numberTier.copyWith(color: open ? c.onSuccess : c.cream),
            ),
          ),
        ),
        SizedBox(width: space.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.cardTitle),
              Text(
                open
                    ? l.hintOpened
                    : ready
                    ? l.hintTier(tier)
                    : l.hintUnlockFirst(tier - 1),
                style: t.controlLabel.copyWith(color: c.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );

    final body = open
        ? _Reveal(text)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetButton(
                label: waiting
                    ? (saving ? l.guidanceSaving : l.guidanceLoading)
                    : l.watchAd,
                icon: KoIcon(KoIcons.ad, size: s.iconCompact, color: c.ink),
                color: c.surface,
                line: c.line,
                edge: c.lineDeep,
                onPressed: enabled ? onWatch : null,
              ),
              SizedBox(height: space.s8),
              SheetButton(
                label: coins >= cost
                    ? l.coinsAmount(cost)
                    : l.notEnoughCoins(cost),
                icon: CoinView(size: s.iconCompact, kind: CoinKind.plain),
                color: c.orange,
                line: c.orange,
                edge: c.orangeDeep,
                onPressed: enabled && coins >= cost ? onPay : null,
              ),
              if (adFailed) ...[
                SizedBox(height: space.s8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l.adFailed,
                    style: t.controlLabel.copyWith(color: c.brickDeep),
                  ),
                ),
              ],
            ],
          );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        SizedBox(height: space.s10),
        body,
      ],
    );
    final card = UiPanel(
      locked: locked,
      borderColor: open ? c.success : null,
      child: content,
    );
    return locked ? Opacity(opacity: s.lockedOpacity, child: card) : card;
  }
}

/// Kotak teks petunjuk yang sudah dibuka.
class _Reveal extends StatelessWidget {
  const _Reveal(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s10),
      decoration: BoxDecoration(
        color: KoUi.cream,
        borderRadius: BorderRadius.circular(context.koRadius.icon),
      ),
      child: Text(text, style: KoUi.label.copyWith(color: KoUi.ink)),
    );
  }
}
