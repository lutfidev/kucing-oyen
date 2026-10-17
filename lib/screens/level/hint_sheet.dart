import 'package:flutter/material.dart';

import '../../app/hint_source.dart';
import '../../game/model/hints.dart';
import '../../game/sim/sim.dart';
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
  barrierLabel: 'Tutup petunjuk',
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
                      'Petunjuk',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.title,
                    ),
                  ),
                ),
                SizedBox(width: space.s10),
                _CoinChip(coins: coins),
                SizedBox(width: space.s10),
                KoIconButton(
                  icon: KoIcons.close,
                  semanticLabel: 'Tutup',
                  tone: KoIconButtonTone.flat,
                  iconSize: s.iconSmall,
                  onPressed: widget.onClose,
                ),
              ],
            ),
            // Desain: jarak 12 dikurangi margin -4.
            SizedBox(height: space.s8),
            Text(
              'Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil.',
              style: t.bodySmall.copyWith(color: c.inkSoft),
            ),
          ],
        );
        final List<Widget> cards;
        if (widget.level.solution.isEmpty) {
          cards = [
            KoCard(borderColor: c.success, child: _Reveal(noItemsHintText)),
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
                text: hintText(widget.level, tier),
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
          label: 'Petunjuk',
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

  static const _titles = [
    'Sorot petak pertama',
    'Tunjukkan jenis benda',
    'Tampilkan solusi lengkap',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final locked = !open && !ready;
    final cost = hintCost(tier);
    final enabled = ready && !waiting;

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
              Text(_titles[tier - 1], style: t.cardTitle),
              Text(
                open
                    ? 'Terbuka'
                    : ready
                    ? 'Tingkat $tier'
                    : 'Buka tingkat ${tier - 1} dulu',
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
                    child: _TierButton(
                      label: 'Tonton iklan',
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
                    child: _TierButton(
                      label: coins >= cost
                          ? '$cost koin'
                          : 'Koin kurang · $cost',
                      icon: CoinView(size: s.iconCompact, plain: true),
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
                    'Iklannya belum bisa diputar. Coba lagi nanti, ya.',
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

/// Tombol "Tonton iklan" atau bayar koin di kartu tingkat. Nonaktif =
/// abu-abu tanpa bayangan.
class _TierButton extends StatelessWidget {
  const _TierButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.line,
    required this.edge,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final Color color;
  final Color line;
  final Color edge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final enabled = onPressed != null;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: enabled ? color : c.disabled,
      borderColor: enabled ? line : c.disabledLine,
      borderWidth: s.border,
      edgeColor: enabled ? edge : null,
      depth: context.koShadow.pressIcon,
      radius: context.koRadius.icon,
      height: s.hintButton,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: space.s6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: context.koType.chipLabel.copyWith(
                  color: enabled ? c.ink : c.onLockedSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saldo koin di kepala sheet: koin 22 px dan angka.
class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$coins koin',
      excludeSemantics: true,
      child: Container(
        height: s.chipMedium,
        padding: EdgeInsetsDirectional.only(start: space.s6, end: space.s12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoinView(size: s.icon),
            SizedBox(width: space.s6),
            Text('$coins', maxLines: 1, style: context.koType.numberCoin),
          ],
        ),
      ),
    );
  }
}
