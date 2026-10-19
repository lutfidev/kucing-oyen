import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';

/// Keadaan satu level di peta.
enum NodeState {
  /// Sudah menang: oranye dengan bintangnya.
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

/// Isi peta babak di koordinat desain 02: lebar 390, mulai y
/// [MapArt.mapTop]. Pemanggil yang memperbesar atau memperkecilnya.
class ChapterMap extends StatelessWidget {
  const ChapterMap({
    super.key,
    required this.chapter,
    required this.progress,
    required this.onPlay,
  });

  final Chapter chapter;
  final Progress progress;
  final ValueChanged<Level> onPlay;

  /// Ukuran isi peta (koordinat desain).
  static final size = Size(
    MapArt.screen.width,
    MapArt.screen.height - MapArt.mapTop,
  );

  /// Tengah node level ke-[index] babak (koordinat [size]).
  static Offset pointOf(int index) =>
      MapArt.points[index] - const Offset(0, MapArt.mapTop);

  @override
  Widget build(BuildContext context) {
    final levels = chapter.levels;
    assert(levels.length <= MapArt.points.length);
    final states = [for (final level in levels) NodeState.of(progress, level)];
    final pawColor = context.koColors.wood;
    const paw = MapArt.pawSize;

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _BossArea())),
          for (var i = 0; i + 1 < levels.length; i++)
            for (final at in MapArt.pawsBetween(pointOf(i), pointOf(i + 1)))
              Positioned(
                left: at.dx - paw / 2,
                top: at.dy - paw / 2,
                child: Opacity(
                  opacity: states[i] == NodeState.done
                      ? MapArt.pawOpacity
                      : MapArt.pawDimOpacity,
                  child: Transform.rotate(
                    angle:
                        MapArt.pawAngle(pointOf(i), pointOf(i + 1)) *
                        math.pi /
                        180,
                    child: KoIcon(KoIcons.steps, size: paw, color: pawColor),
                  ),
                ),
              ),
          _place(
            context,
            pointOf(levels.length - 1),
            BossNode(
              chapter: chapter,
              state: states.last,
              stars: progress.starsOf(chapter.boss.id),
              onPressed: () => onPlay(chapter.boss),
            ),
            boss: true,
          ),
          for (var i = 0; i + 1 < levels.length; i++)
            _place(
              context,
              pointOf(i),
              LevelNode(
                level: levels[i],
                state: states[i],
                stars: progress.starsOf(levels[i].id),
                onPressed: () => onPlay(levels[i]),
                labelBelow: _labelBelow(context, i),
              ),
            ),
        ],
      ),
    );
  }

  /// Label "Main" pindah ke bawah node kalau node sebelumnya tepat di
  /// atasnya, supaya bintang node itu tidak tertutup (level 4 dan 7 tiap
  /// babak). Desain hanya menampilkan level 13 sebagai level saat ini.
  static bool _labelBelow(BuildContext context, int index) {
    if (index == 0) return false;
    final s = context.koSize;
    final d = pointOf(index) - pointOf(index - 1);
    // Atas label sampai bawah bintang node sebelumnya.
    final reach = s.node + MapArt.labelAbove + context.koSpace.s6 + s.mapStar;
    return d.dy > 0 && d.dy < reach && d.dx.abs() < s.node;
  }

  /// Node dengan tengah lingkaran (atau kotak bos) di [center]. Kotaknya
  /// dibuat lebar supaya label di bawah atau di atasnya bisa lebih lebar
  /// dari node.
  Widget _place(
    BuildContext context,
    Offset center,
    Widget node, {
    bool boss = false,
  }) {
    final s = context.koSize;
    final half = (boss ? s.boss : s.node) / 2;
    const width = MapArt.nodeSlot;
    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - half,
      width: width,
      child: Align(alignment: Alignment.topCenter, child: node),
    );
  }
}

/// Node bulat level biasa (desain 02 dan lembar token "Node level").
class LevelNode extends StatelessWidget {
  const LevelNode({
    super.key,
    required this.level,
    required this.state,
    required this.stars,
    required this.onPressed,
    this.labelBelow = false,
  });

  final Level level;
  final NodeState state;
  final int stars;
  final VoidCallback onPressed;

  /// Label "Main" di bawah node, bukan di atas.
  final bool labelBelow;

  /// Label pembaca layar, sama dengan `aria-label` desain.
  static String labelOf(
    AppLocalizations l,
    Level level,
    NodeState state,
    int stars,
  ) => l.levelNodeLabel(level.id, _status(l, state, stars));

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final label = labelOf(context.l10n, level, state, stars);
    final number = Text(
      '${level.id}',
      style: context.koType.numberMedium.copyWith(color: c.ink),
    );

    final Widget circle = switch (state) {
      NodeState.locked => Semantics(
        image: true,
        label: label,
        child: Container(
          width: s.node,
          height: s.node,
          decoration: BoxDecoration(
            color: c.nodeLocked,
            shape: BoxShape.circle,
          ),
          child: KoDashedBorder(
            color: c.muted,
            radius: s.node / 2,
            width: s.nodeDash,
            child: Center(
              child: KoIcon(KoIcons.lock, size: s.icon, color: c.nodeLockedInk),
            ),
          ),
        ),
      ),
      _ => KoPressable(
        onPressed: onPressed,
        semanticLabel: label,
        color: state == NodeState.done ? c.orange : c.surface,
        edgeColor: c.orangeDeep,
        depth: context.koShadow.pressNode,
        borderColor: state == NodeState.current ? c.orange : null,
        borderWidth: s.nodeRing,
        circle: true,
        glow: state == NodeState.done ? context.koShadow.node : const [],
        width: s.node,
        height: s.node,
        child: Center(child: number),
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == NodeState.current)
          _Current(
            ring: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.orange, width: s.nodeRing),
              ),
            ),
            labelBelow: labelBelow,
            child: circle,
          )
        else
          circle,
        if (state == NodeState.done) ...[
          SizedBox(height: context.koSpace.s6),
          _NodeStars(stars: stars),
        ],
      ],
    );
  }
}

/// Kotak level bos: lebih besar, gambar bos, dan label nama bos.
class BossNode extends StatelessWidget {
  const BossNode({
    super.key,
    required this.chapter,
    required this.state,
    required this.stars,
    required this.onPressed,
  });

  final Chapter chapter;
  final NodeState state;
  final int stars;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final radius = context.koRadius;
    final locked = state == NodeState.locked;
    final l = context.l10n;
    final label = l.bossNodeLabel(
      chapter.boss.id,
      bossName(l, chapter),
      _status(l, state, stars),
    );
    final art = CustomPaint(
      size: Size.square(s.bossArt),
      painter: _BossArt(chapter.number),
    );

    final Widget box = locked
        ? Semantics(
            image: true,
            label: label,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Opacity(
                  opacity: MapArt.bossLockedOpacity,
                  child: Container(
                    width: s.boss,
                    height: s.boss,
                    decoration: BoxDecoration(
                      color: c.boss,
                      borderRadius: BorderRadius.circular(radius.boss),
                      border: Border.all(color: c.brick, width: s.nodeRing),
                      boxShadow: KoShadow.solid(
                        c.bossEdge,
                        context.koShadow.press,
                      ),
                    ),
                    child: Center(child: art),
                  ),
                ),
                Positioned(
                  right: -MapArt.bossBadgeOut,
                  top: -MapArt.bossBadgeOut,
                  child: Container(
                    width: s.bossBadge,
                    height: s.bossBadge,
                    decoration: BoxDecoration(
                      color: c.ink,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: KoIcon(
                        KoIcons.lockBold,
                        size: s.iconChip,
                        color: c.cream,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : KoPressable(
            onPressed: onPressed,
            semanticLabel: label,
            color: c.boss,
            edgeColor: c.bossEdge,
            depth: context.koShadow.press,
            borderColor: c.brick,
            borderWidth: s.nodeRing,
            radius: radius.boss,
            width: s.boss,
            height: s.boss,
            child: Center(child: art),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == NodeState.current)
          _Current(
            ring: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius.boss),
                border: Border.all(color: c.orange, width: s.nodeRing),
              ),
            ),
            child: box,
          )
        else
          box,
        const SizedBox(height: MapArt.bossLabelGap),
        ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: space.s12,
              vertical: space.s4,
            ),
            decoration: BoxDecoration(
              color: c.brick,
              borderRadius: BorderRadius.circular(radius.tag),
              boxShadow: KoShadow.solid(
                c.brickEdge,
                context.koShadow.pressIcon,
              ),
            ),
            child: Text(
              l.bossTag(bossName(l, chapter)),
              maxLines: 1,
              style: context.koType.badge.copyWith(color: c.onBrick),
            ),
          ),
        ),
        if (state == NodeState.done) ...[
          SizedBox(height: space.s6),
          _NodeStars(stars: stars),
        ],
      ],
    );
  }
}

/// Node level saat ini: cincin berdenyut di belakangnya dan label "Main"
/// di atasnya (atau di bawahnya, [labelBelow]).
class _Current extends StatelessWidget {
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
                  style: context.koType.tagSmall.copyWith(color: c.cream),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Cincin yang membesar sambil memudar terus (`koPulse`). Tanpa animasi
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
    end: MapArt.pulseScale,
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
    final empty = context.koColors.nodeLocked;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < Progress.maxStars; i++) ...[
            if (i > 0) SizedBox(width: context.koSpace.s2),
            KoStar(
              filled: i < stars,
              size: s.mapStar,
              strokeWidth: MapArt.starStroke,
              emptyColor: empty,
            ),
          ],
        ],
      ),
    );
  }
}

class _BossArt extends CustomPainter {
  _BossArt(this.chapter);

  final int chapter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / MapArt.bossArtViewBox);
    paintBossArt(canvas, chapter);
  }

  @override
  bool shouldRepaint(_BossArt old) => old.chapter != chapter;
}

/// Area bos (koordinat layar desain) di koordinat [ChapterMap].
class _BossArea extends CustomPainter {
  const _BossArea();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, -MapArt.mapTop);
    paintBossArea(canvas);
  }

  @override
  bool shouldRepaint(_BossArea old) => false;
}

/// Keadaan node untuk pembaca layar: bintang, main sekarang, atau terkunci.
String _status(AppLocalizations l, NodeState state, int stars) =>
    switch (state) {
      NodeState.done => l.nodeStars(stars),
      NodeState.current => l.statusPlayNow,
      NodeState.locked => l.statusLocked,
    };
