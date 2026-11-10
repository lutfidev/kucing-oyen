import 'package:flutter/material.dart';

import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/render/v2/journey_art.dart';
import '../../game/sim/sim.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Keadaan satu level di peta.
enum NodeState {
  /// Sudah menang: bintangnya di bawah node.
  done,

  /// Terbuka dan belum menang: berdenyut dengan label "Main".
  current,

  /// Belum terbuka: pudar dengan gembok.
  locked;

  static NodeState of(Progress progress, Level level) =>
      progress.isWon(level.id)
      ? done
      : (progress.isUnlocked(level.id) ? current : locked);
}

/// Node bergambar (desain 23, `TitikLevel.dc.html`): badge bulat (bos:
/// kotak) dengan gambar benda rumah, chip nomor, gembok kalau terkunci,
/// denyut dan label "Main" kalau saat ini, bintang kalau selesai, dan
/// label nama bos di bawah kotak bos.
class PictureNode extends StatelessWidget {
  const PictureNode({
    super.key,
    required this.level,
    required this.chapter,
    required this.state,
    required this.stars,
    required this.onPressed,
    this.compact = false,
    this.labelBelow = false,
  });

  final Level level;
  final Chapter chapter;
  final NodeState state;
  final int stars;
  final VoidCallback onPressed;

  /// Layar kecil (`n360`): node 54, bos 84.
  final bool compact;

  /// Label "Main" di bawah node, bukan di atas (node sebelumnya tepat di
  /// atasnya, supaya bintangnya tidak tertutup).
  final bool labelBelow;

  bool get _boss => level.id == chapter.boss.id;

  /// Sisi badge node (bos: kotak), menurut ukuran layar.
  static double sizeOf(
    BuildContext context, {
    required bool boss,
    required bool compact,
  }) {
    final s = context.koSize;
    return boss
        ? (compact ? s.bossCompact : s.boss)
        : (compact ? s.nodeCompact : s.node);
  }

  /// Label pembaca layar node level biasa.
  static String labelOf(
    AppLocalizations l,
    Level level,
    NodeState state,
    int stars,
  ) => l.levelNodeLabel(level.id, nodeStatus(l, state, stars));

  /// Label pembaca layar kotak bos [chapter].
  static String bossLabelOf(
    AppLocalizations l,
    Chapter chapter,
    NodeState state,
    int stars,
  ) => l.bossNodeLabel(
    chapter.boss.id,
    bossName(l, chapter),
    nodeStatus(l, state, stars),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final shadow = context.koShadow;
    final l = context.l10n;
    final boss = _boss;
    final size = sizeOf(context, boss: boss, compact: compact);
    final locked = state == NodeState.locked;
    final edge = boss ? c.brick : c.orange;
    final press = boss ? c.brickEdge : c.orangeDeep;
    final radius = boss ? context.koRadius.boss : size / 2;
    final label = boss
        ? bossLabelOf(l, chapter, state, stars)
        : labelOf(l, level, state, stars);
    final iconSize =
        (boss ? s.bossArt : s.nodeIcon) *
        size /
        sizeOf(context, boss: boss, compact: false);

    Widget icon = CustomPaint(
      size: Size.square(iconSize),
      painter: _NodeIcon(PictureMapArt.objectOf(level)),
    );
    if (locked) {
      icon = Opacity(
        opacity: PictureMapArt.lockedIconOpacity,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscale),
          child: icon,
        ),
      );
    }

    final Widget face = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          left: -PictureMapArt.chipOut,
          bottom: -PictureMapArt.chipOut,
          child: _Chip(number: level.id, locked: locked),
        ),
        if (locked)
          Positioned(
            right: -PictureMapArt.lockOut,
            top: -PictureMapArt.lockOut,
            child: const _Lock(),
          ),
      ],
    );

    final Widget badge = locked
        ? Semantics(
            image: true,
            label: label,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: c.nodeLocked,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: KoShadow.solid(
                  c.nodeLockedEdge,
                  shadow.pressNode - 1,
                ),
              ),
              // Garis putus-putus di belakang chip nomor dan gembok.
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: KoDashedBorder(
                      color: boss ? c.brick : c.muted,
                      radius: radius,
                      width: s.nodeDash,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  face,
                ],
              ),
            ),
          )
        : KoPressable(
            onPressed: onPressed,
            semanticLabel: label,
            color: state == NodeState.done ? c.surface : c.cream,
            edgeColor: press,
            depth: shadow.pressNode,
            borderColor: edge,
            borderWidth: s.nodeRing,
            radius: boss ? radius : 0,
            circle: !boss,
            glow: shadow.node,
            width: size,
            height: size,
            child: face,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == NodeState.current)
          _Current(
            ring: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: edge, width: s.nodeRing),
              ),
            ),
            labelBelow: labelBelow,
            child: badge,
          )
        else
          badge,
        if (state == NodeState.done) ...[
          SizedBox(height: space.s8),
          _NodeStars(stars: stars),
        ],
        if (boss) ...[
          SizedBox(height: space.s12),
          ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: space.s12,
                vertical: space.s4,
              ),
              decoration: BoxDecoration(
                color: c.brick,
                borderRadius: BorderRadius.circular(context.koRadius.tag),
                boxShadow: KoShadow.solid(c.brickEdge, shadow.pressIcon),
              ),
              child: Text(
                l.bossTag(bossName(l, chapter)),
                maxLines: 1,
                style: context.koType.badge.copyWith(color: c.onBrick),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// `filter: grayscale(0.85)` CSS.
const _grayscale = <double>[
  0.3713, 0.6086, 0.0201, 0, 0, //
  0.1810, 0.7983, 0.0207, 0, 0, //
  0.1810, 0.6086, 0.2104, 0, 0, //
  0, 0, 0, 1, 0,
];

class _NodeIcon extends CustomPainter {
  _NodeIcon(this.object);

  final String object;

  @override
  void paint(Canvas canvas, Size size) =>
      JourneyArt.node(canvas, object, size.width);

  @override
  bool shouldRepaint(_NodeIcon old) => old.object != object;
}

/// Nomor level di kiri bawah node.
class _Chip extends StatelessWidget {
  const _Chip({required this.number, required this.locked});

  final int number;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return ExcludeSemantics(
      child: Container(
        constraints: BoxConstraints(minWidth: s.nodeChip),
        height: s.nodeChip,
        padding: EdgeInsets.symmetric(horizontal: context.koSpace.s4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: locked ? c.nodeLockedInk : c.ink,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          boxShadow: [
            BoxShadow(color: c.cream, spreadRadius: PictureMapArt.ringOut),
          ],
        ),
        child: Text(
          '$number',
          maxLines: 1,
          style: context.koType.numberBadge.copyWith(color: c.cream),
        ),
      ),
    );
  }
}

/// Gembok di kanan atas node terkunci.
class _Lock extends StatelessWidget {
  const _Lock();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return Container(
      width: s.bossBadge,
      height: s.bossBadge,
      decoration: BoxDecoration(
        color: c.ink,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: c.cream, spreadRadius: PictureMapArt.ringOut),
        ],
      ),
      child: Center(
        child: KoIcon(KoIcons.lockBold, size: s.iconChip, color: c.cream),
      ),
    );
  }
}

/// Node level saat ini: cincin berdenyut di belakangnya dan label "Main"
/// di atasnya (atau di bawahnya, [labelBelow]).
class _Current extends StatelessWidget {
  /// Tinggi baris label "Main" (`TitikLevel.dc.html`: `line-height: 1.2`).
  static const double labelHeight = 1.2;

  const _Current({
    required this.ring,
    required this.child,
    this.labelBelow = false,
  });

  /// Bentuk cincin seukuran [child].
  final Widget ring;
  final Widget child;
  final bool labelBelow;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: _Pulse(child: ring)),
        child,
        Positioned(
          top: labelBelow ? null : -MapArt.labelAbove,
          bottom: labelBelow ? -MapArt.labelAbove : null,
          left: -MapArt.labelAbove * 2,
          right: -MapArt.labelAbove * 2,
          child: Center(
            child: ExcludeSemantics(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: space.s10,
                  vertical: space.s4,
                ),
                decoration: BoxDecoration(
                  color: c.ink,
                  borderRadius: BorderRadius.circular(context.koRadius.pill),
                ),
                child: Text(
                  context.l10n.play,
                  maxLines: 1,
                  style: context.koType.tagSmall.copyWith(
                    color: c.cream,
                    height: labelHeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Cincin yang membesar sambil memudar terus (`tlvPulse`). Tanpa animasi
/// (`disableAnimations`), cincinnya tidak tampil.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MapArt.pulseTime,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: PictureMapArt.pulseScale,
  ).animate(_curve);
  late final Animation<double> _opacity = Tween(
    begin: MapArt.pulseOpacity,
    end: 0.0,
  ).animate(_curve);
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_still) return const SizedBox.shrink();
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

/// Tiga bintang kecil di bawah node yang sudah selesai.
class _NodeStars extends StatelessWidget {
  const _NodeStars({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    final c = context.koColors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < Progress.maxStars; i++) ...[
            if (i > 0) const SizedBox(width: PictureMapArt.starGap),
            KoStar(
              filled: i < stars,
              size: s.mapStar,
              strokeWidth: MapArt.starStroke,
              emptyColor: c.nodeLocked,
            ),
          ],
        ],
      ),
    );
  }
}

/// Keadaan node untuk pembaca layar: bintang, main sekarang, atau terkunci.
String nodeStatus(AppLocalizations l, NodeState state, int stars) =>
    switch (state) {
      NodeState.done => l.nodeStars(stars),
      NodeState.current => l.statusPlayNow,
      NodeState.locked => l.statusLocked,
    };
