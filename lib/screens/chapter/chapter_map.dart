import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'map_node.dart';

export 'map_node.dart' show NodeState, PictureNode;

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
            PictureNode(
              level: chapter.boss,
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
              PictureNode(
                level: levels[i],
                chapter: chapter,
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
    final reach = s.node + MapArt.labelAbove + context.koSpace.s8 + s.mapStar;
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
