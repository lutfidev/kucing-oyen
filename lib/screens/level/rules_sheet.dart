import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/rules.dart';
import '../../game/render/render.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Membuka sheet "Aturan Oyen" (desain 05) di atas layar level. Ditutup
/// dengan tombol tutup, ketuk latar gelap, tombol kembali sistem, atau
/// tarik ke bawah.
Future<void> showRulesSheet(
  BuildContext context, {
  required Set<OyenRule> learned,
}) {
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup aturan',
    barrierColor: context.koColors.scrim,
    transitionDuration: reduceMotion ? Duration.zero : RulesSheet.openTime,
    pageBuilder: (context, _, _) => RulesSheet(
      learned: learned,
      onClose: () => Navigator.of(context).pop(),
    ),
    transitionBuilder: (context, animation, _, child) {
      final t = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return AnimatedBuilder(
        animation: t,
        builder: (context, child) => Opacity(
          opacity: t.value,
          child: Transform.translate(
            offset: Offset(0, RulesSheet.openRise * (1 - t.value)),
            child: child,
          ),
        ),
        child: child,
      );
    },
  );
}

/// Isi sheet Aturan Oyen: pegangan, judul, tombol tutup, dan lima kartu
/// aturan urut cek per langkah. Kartu yang belum ada di [learned] terkunci.
/// Sheet setinggi isinya dan digulir kalau tidak muat; bar atas layar
/// level tetap terlihat di atasnya seperti desain.
class RulesSheet extends StatefulWidget {
  const RulesSheet({super.key, required this.learned, required this.onClose});

  final Set<OyenRule> learned;
  final VoidCallback onClose;

  /// Sheet naik [openRise] sambil muncul dalam [openTime] (`koSheet`).
  static const openTime = Duration(milliseconds: 350);
  static const double openRise = 60;

  /// Tarikan ke bawah sejauh [closeDrag], atau lebih cepat dari
  /// [closeFling] (px/detik), menutup sheet.
  static const double closeDrag = 80;
  static const double closeFling = 700;

  @override
  State<RulesSheet> createState() => _RulesSheetState();
}

class _RulesSheetState extends State<RulesSheet> with TickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: RuleArt.quarterTime,
  );

  /// Sheet kembali ke tempatnya kalau tarikan kurang jauh.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(_onSettle);

  double _drag = 0;
  double _settleFrom = 0;

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
    _settle.dispose();
    super.dispose();
  }

  void _onSettle() => setState(
    () => _drag = _settleFrom * (1 - Curves.easeOut.transform(_settle.value)),
  );

  void _dragBy(DragUpdateDetails details) {
    _settle.stop();
    setState(() => _drag = math.max(0, _drag + details.delta.dy));
  }

  void _release(DragEndDetails details) {
    final fling = details.primaryVelocity ?? 0;
    if (_drag > RulesSheet.closeDrag || fling > RulesSheet.closeFling) {
      widget.onClose();
    } else {
      _settleFrom = _drag;
      _settle.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final media = MediaQuery.of(context);
    // Bar atas layar level (desain: sheet mulai 18 px di bawahnya).
    final top = media.padding.top + space.s8 + s.iconButton + space.s16;
    final sheetRadius = Radius.circular(context.koRadius.sheet);

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _dragBy,
      onVerticalDragEnd: _release,
      child: Column(
        children: [
          Container(
            width: s.sheetHandle,
            height: s.sheetHandleThickness,
            decoration: BoxDecoration(
              color: c.sheetHandle,
              borderRadius: BorderRadius.circular(context.koRadius.pill),
            ),
          ),
          SizedBox(height: space.s10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text('Aturan Oyen', style: t.title),
                    ),
                    SizedBox(height: space.s2),
                    Text(
                      'Tiap langkah dicek urut dari atas. Yang pertama '
                      'cocok, itu yang dia lakukan.',
                      style: t.bodySmall.copyWith(color: c.inkSoft),
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.s12),
              KoIconButton(
                icon: KoIcons.close,
                semanticLabel: 'Tutup',
                tone: KoIconButtonTone.flat,
                iconSize: s.iconSmall,
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, media.size.height - top),
        ),
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: 'Aturan Oyen',
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.cream,
                  borderRadius: BorderRadius.vertical(top: sheetRadius),
                  boxShadow: context.koShadow.sheet,
                ),
                padding: EdgeInsets.fromLTRB(
                  space.s16,
                  space.s10,
                  space.s16,
                  space.s24 + media.padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    SizedBox(height: space.s10),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(top: space.s4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final rule in OyenRule.values) ...[
                              if (rule != OyenRule.values.first)
                                SizedBox(height: space.s10),
                              RuleCard(
                                rule: rule,
                                learned: widget.learned.contains(rule),
                                turn: _turn,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
        Text(_title(rule), style: t.cardTitle),
        ...switch (rule) {
          OyenRule.knock => [
            Text(
              'Ada gelas atau vas di meja sebelah? Disenggol. Pasti.',
              style: body,
            ),
          ],
          OyenRule.fish => [
            Text('Yang kelihatan lurus saja. Kalau seri:', style: body),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'depan '),
                  arrow(KoIcons.arrowRight, c.ink),
                  const TextSpan(text: ' searah jarum jam '),
                  arrow(KoIcons.turnClockwise, c.turnClockwise),
                  const TextSpan(text: ' '),
                  arrow(KoIcons.arrowRight, c.ink),
                  const TextSpan(text: ' berlawanan jarum jam '),
                  arrow(KoIcons.turnCounterClockwise, c.brickDeep),
                  const TextSpan(text: ' '),
                  arrow(KoIcons.arrowRight, c.ink),
                  const TextSpan(text: ' belakang'),
                ],
              ),
              style: strong,
              semanticsLabel:
                  'Urutan seri: depan, searah jarum jam, berlawanan jarum '
                  'jam, belakang.',
            ),
          ],
          OyenRule.water => [
            Text(
              'Ketemu genangan atau ember, Oyen kaget lalu balik badan.',
              style: body,
            ),
          ],
          OyenRule.wall => [
            Text.rich(
              TextSpan(
                children: [
                  arrow(KoIcons.arrowRight, c.ink),
                  const TextSpan(text: ' Oyen berputar searah jarum jam '),
                  arrow(KoIcons.turnClockwise, c.ink),
                ],
              ),
              style: strong,
              semanticsLabel: 'Oyen berputar searah jarum jam.',
            ),
            Text('Seperempat putaran, lalu jalan lagi.', style: body),
          ],
          OyenRule.box => [
            Text(
              'Duduk 2 langkah sampai kardusnya penyok dan hilang. '
              'Ikan di balik kardus nggak kelihatan.',
              style: body,
            ),
          ],
        },
      ];
    } else {
      lines = [
        Text(
          '${_lockedName(rule)}: ???',
          style: t.cardTitle.copyWith(color: c.onDisabled),
        ),
        Text(
          'Belum dipelajari. Nanti juga kenalan sendiri.',
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
        label: 'Aturan $n, terkunci, belum dipelajari',
        excludeSemantics: true,
        child: card,
      );
    }
    return MergeSemantics(
      child: Semantics(label: 'Aturan $n', child: card),
    );
  }

  static String _title(OyenRule rule) => switch (rule) {
    OyenRule.knock => 'Jatuhkan barang di sebelahnya',
    OyenRule.fish => 'Kejar ikan terdekat',
    OyenRule.water => 'Air? Putar balik',
    OyenRule.wall => 'Mentok tembok atau meja',
    OyenRule.box => 'Kardus? Masuk, duduk',
  };

  static String _lockedName(OyenRule rule) => switch (rule) {
    OyenRule.knock => 'Barang di meja',
    OyenRule.fish => 'Ikan',
    OyenRule.water => 'Air',
    OyenRule.wall => 'Tembok',
    OyenRule.box => 'Kardus',
  };
}
