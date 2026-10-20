import 'package:flutter/material.dart';

import '../../game/model/rules.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Membuka sheet "Aturan Oyen" (desain 05) di atas layar level. Ditutup
/// dengan tombol tutup, ketuk latar gelap, tombol kembali sistem, atau
/// tarik ke bawah.
Future<void> showRulesSheet(
  BuildContext context, {
  required Set<OyenRule> learned,
}) => showKoSheet(
  context,
  barrierLabel: context.l10n.closeRules,
  builder: (context, onClose) => RulesSheet(learned: learned, onClose: onClose),
);

/// Isi sheet Aturan Oyen: judul, tombol tutup, dan lima kartu aturan urut
/// cek per langkah. Kartu yang belum ada di [learned] terkunci.
class RulesSheet extends StatefulWidget {
  const RulesSheet({super.key, required this.learned, required this.onClose});

  final Set<OyenRule> learned;
  final VoidCallback onClose;

  @override
  State<RulesSheet> createState() => _RulesSheetState();
}

class _RulesSheetState extends State<RulesSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: RuleArt.quarterTime,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still || !widget.learned.contains(OyenRule.wall)) {
      _turn.reset();
    } else if (!_turn.isAnimating) {
      _turn.repeat();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    return KoSheet(
      label: context.l10n.rulesTitle,
      onClose: widget.onClose,
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(context.l10n.rulesTitle, style: t.title),
                ),
                SizedBox(height: space.s2),
                Text(
                  context.l10n.rulesIntro,
                  style: t.bodySmall.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
          SizedBox(width: space.s12),
          KoIconButton(
            icon: KoIcons.close,
            semanticLabel: context.l10n.close,
            tone: KoIconButtonTone.flat,
            iconSize: s.iconSmall,
            onPressed: widget.onClose,
          ),
        ],
      ),
      children: [
        for (final rule in OyenRule.values) ...[
          if (rule != OyenRule.values.first) SizedBox(height: space.s10),
          RuleCard(
            rule: rule,
            learned: widget.learned.contains(rule),
            turn: _turn,
          ),
        ],
      ],
    );
  }
}

/// Satu kartu aturan: gambar bernomor, judul, dan penjelasan. Kartu yang
/// belum [learned] pudar bergaris putus-putus dengan judul "???".
class RuleCard extends StatelessWidget {
  const RuleCard({
    super.key,
    required this.rule,
    required this.learned,
    this.turn,
  });

  final OyenRule rule;
  final bool learned;

  /// Putaran kucing kartu 4 (lihat [RuleArtView.turn]).
  final Animation<double>? turn;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final n = rule.number;

    final art = SizedBox.square(
      dimension: s.ruleArt,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RuleArtView(rule, learned: learned, turn: turn),
          PositionedDirectional(
            start: -space.s6,
            top: -space.s6,
            child: Container(
              width: s.ruleBadge,
              height: s.ruleBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: learned ? c.ink : c.nodeLockedInk,
                shape: BoxShape.circle,
              ),
              child: ExcludeSemantics(
                child: Text('$n', style: t.numberRule.copyWith(color: c.cream)),
              ),
            ),
          ),
        ],
      ),
    );

    final l = context.l10n;
    final List<Widget> lines;
    if (learned) {
      final body = t.cardBody.copyWith(color: c.inkSoft);
      final strong = t.cardBodyStrong.copyWith(color: c.ink);
      final arrowSize = MediaQuery.textScalerOf(context).scale(s.iconTiny);
      // Panah sebagai ikon: font yang dibundel tidak punya → ↻ ↺. Spasi
      // tak terputus menjaga panah tetap di baris kata sebelumnya.
      InlineSpan arrow(KoIconData icon, Color color) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: KoIcon(icon, size: arrowSize, color: color),
      );
      lines = [
        Text(_title(l, rule), style: t.cardTitle),
        ...switch (rule) {
          OyenRule.knock => [Text(l.ruleKnockBody, style: body)],
          OyenRule.fish => [
            Text(l.ruleFishBody, style: body),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l.tieAhead} '),
                  arrow(KoIcons.arrowRight, c.ink),
                  TextSpan(text: ' ${l.tieClockwise} '),
                  arrow(KoIcons.turnClockwise, c.turnClockwise),
                  const TextSpan(text: ' '),
                  arrow(KoIcons.arrowRight, c.ink),
                  TextSpan(text: ' ${l.tieCounterClockwise} '),
                  arrow(KoIcons.turnCounterClockwise, c.brickDeep),
                  const TextSpan(text: ' '),
                  arrow(KoIcons.arrowRight, c.ink),
                  TextSpan(text: ' ${l.tieBehind}'),
                ],
              ),
              style: strong,
              semanticsLabel: l.tieOrderLabel,
            ),
          ],
          OyenRule.water => [Text(l.ruleWaterBody, style: body)],
          OyenRule.wall => [
            Text.rich(
              TextSpan(
                children: [
                  arrow(KoIcons.arrowRight, c.ink),
                  TextSpan(text: ' ${l.ruleWallTurn} '),
                  arrow(KoIcons.turnClockwise, c.ink),
                ],
              ),
              style: strong,
              semanticsLabel: '${l.ruleWallTurn}.',
            ),
            Text(l.ruleWallBody, style: body),
          ],
          OyenRule.box => [Text(l.ruleBoxBody, style: body)],
        },
      ];
    } else {
      lines = [
        Text(
          l.ruleLockedTitle(_lockedName(l, rule)),
          style: t.cardTitle.copyWith(color: c.onDisabled),
        ),
        Text(
          l.ruleLockedBody,
          style: t.cardBody.copyWith(color: c.onLockedSoft),
        ),
      ];
    }

    final card = KoCard(
      locked: !learned,
      padding: EdgeInsets.all(space.s10),
      child: Row(
        children: [
          art,
          SizedBox(width: space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, line) in lines.indexed) ...[
                  if (i > 0) SizedBox(height: space.s2),
                  line,
                ],
              ],
            ),
          ),
        ],
      ),
    );
    if (!learned) {
      return Semantics(
        container: true,
        label: l.ruleLockedLabel(n),
        excludeSemantics: true,
        child: card,
      );
    }
    return MergeSemantics(
      child: Semantics(label: l.ruleLabel(n), child: card),
    );
  }

  static String _title(AppLocalizations l, OyenRule rule) => switch (rule) {
    OyenRule.knock => l.ruleKnockTitle,
    OyenRule.fish => l.ruleFishTitle,
    OyenRule.water => l.ruleWaterTitle,
    OyenRule.wall => l.ruleWallTitle,
    OyenRule.box => l.ruleBoxTitle,
  };

  static String _lockedName(AppLocalizations l, OyenRule rule) =>
      switch (rule) {
        OyenRule.knock => l.ruleKnockLocked,
        OyenRule.fish => l.ruleFishLocked,
        OyenRule.water => l.ruleWaterLocked,
        OyenRule.wall => l.ruleWallLocked,
        OyenRule.box => l.ruleBoxLocked,
      };
}
