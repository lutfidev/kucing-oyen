import 'package:flutter/material.dart';

import '../../app/hint_source.dart';
import '../../game/model/hints.dart';
import '../../game/sim/sim.dart';
import '../../l10n/hint_texts.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'level_sheet.dart';

/// Membuka sheet Petunjuk (desain 10) untuk [level]. Ditutup dengan tombol
/// tutup, ketuk latar gelap, tombol kembali sistem, atau tarik ke bawah.
Future<void> showHintSheet(
  BuildContext context, {
  required Level level,
  required HintSource hints,
}) => showLevelSheet(
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

  /// Tingkat yang iklannya terakhir gagal.
  int? _failed;

  Future<void> _unlock(int tier, HintPay pay) async {
    if (_waiting != null) return;
    setState(() {
      _failed = null;
      if (pay == HintPay.ad) _waiting = tier;
    });
    final result = await widget.hints.unlockHint(widget.level.id, tier, pay);
    if (!mounted) return;
    setState(() {
      _waiting = null;
      if (result == HintUnlock.adFailed) _failed = tier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    return ListenableBuilder(
      listenable: widget.hints,
      builder: (context, _) {
        final coins = widget.hints.coins;
        final opened = widget.hints.hintTier(widget.level.id);
        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: s.iconButton,
                  height: s.iconButton,
                  decoration: BoxDecoration(
                    color: c.hint,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.hintLine, width: s.border),
                  ),
                  alignment: Alignment.center,
                  child: KoIcon(KoIcons.hint, size: s.icon, color: c.ink),
                ),
                SizedBox(width: space.s10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      context.l10n.hintsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.title,
                    ),
                  ),
                ),
                SizedBox(width: space.s10),
                KoCoinChip(coins: coins, style: KoCoinChipStyle.compact),
                SizedBox(width: space.s10),
                KoIconButton(
                  icon: KoIcons.close,
                  semanticLabel: context.l10n.close,
                  tone: KoIconButtonTone.flat,
                  iconSize: s.iconSmall,
                  onPressed: widget.onClose,
                ),
              ],
            ),
            // Desain: jarak 12 dikurangi margin -4.
            SizedBox(height: space.s8),
            Text(
              context.l10n.hintsIntro,
              style: t.bodySmall.copyWith(color: c.inkSoft),
            ),
          ],
        );
        final List<Widget> cards;
        if (widget.level.solution.isEmpty) {
          cards = [
            KoCard(
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
                adFailed: _failed == tier,
                onWatch: () => _unlock(tier, HintPay.ad),
                onPay: () => _unlock(tier, HintPay.coins),
              ),
            ],
          ];
        }
        return LevelSheet(
          label: context.l10n.hintsTitle,
          onClose: widget.onClose,
          header: header,
          children: cards,
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
    final enabled = ready && !waiting;
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
              Row(
                children: [
                  Expanded(
                    child: SheetButton(
                      label: l.watchAd,
                      icon: KoIcon(
                        KoIcons.ad,
                        size: s.iconCompact,
                        color: enabled ? c.ink : c.onLockedSoft,
                      ),
                      color: c.surface,
                      line: c.line,
                      edge: c.lineDeep,
                      onPressed: enabled ? onWatch : null,
                    ),
                  ),
                  SizedBox(width: space.s8),
                  Expanded(
                    child: SheetButton(
                      label: coins >= cost
                          ? l.coinsAmount(cost)
                          : l.notEnoughCoins(cost),
                      icon: CoinView(size: s.iconCompact, kind: CoinKind.plain),
                      color: c.orange,
                      line: c.orange,
                      edge: c.orangeDeep,
                      onPressed: enabled ? onPay : null,
                    ),
                  ),
                ],
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
    final card = KoCard(
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
    final c = context.koColors;
    final space = context.koSpace;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s10),
      decoration: BoxDecoration(
        color: c.successSoft,
        borderRadius: BorderRadius.circular(context.koRadius.icon),
      ),
      child: Text(
        text,
        style: context.koType.hintReveal.copyWith(color: c.onSuccess),
      ),
    );
  }
}
