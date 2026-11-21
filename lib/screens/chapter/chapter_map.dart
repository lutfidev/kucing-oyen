import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/accessories.dart';
import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import 'map_node.dart';
import 'map_token.dart';

export 'map_node.dart' show NodeState, PictureNode;

/// Letak token Oyen di peta: titik pijakan [at] (koordinat [ChapterMap])
/// dengan pose dan arah hadapnya.
class MapTokenSpot {
  const MapTokenSpot({
    required this.at,
    this.pose = KittyPose.idle,
    this.facing = KittyFacing.down,
    this.time,
  });

  final Offset at;
  final KittyPose pose;
  final KittyFacing facing;

  /// Detik animasi sprite; null = diam.
  final double? time;
}

/// Isi peta bergambar (desain 23) di koordinat layar desain: lebar 390,
/// mulai y [PictureMapArt.mapTop] dengan ruang kosong
/// [PictureMapArt.topPad] di atasnya. Pemanggil yang memperbesar atau
/// memperkecilnya; latar lantai digambar pemanggil.
class ChapterMap extends StatelessWidget {
  const ChapterMap({
    super.key,
    required this.chapter,
    required this.progress,
    required this.onPlay,
    this.token,
    this.oyenAccessory,
    this.compact = false,
  });

  final Chapter chapter;
  final Progress progress;
  final ValueChanged<Level> onPlay;

  /// Token Oyen; null = tanpa token (babak terkunci).
  final MapTokenSpot? token;

  /// Aksesoris yang sedang dipakai Oyen di rumah.
  final AccessoryId? oyenAccessory;

  /// Layar kecil (`n360`): node lebih kecil, jalur dirapatkan.
  final bool compact;

  /// Ukuran isi peta (koordinat desain). Dekor dan area bos tetap di
  /// tempat desain, jadi ukurannya sama juga di layar kecil.
  static const size = Size(
    390,
    844 - PictureMapArt.mapTop + PictureMapArt.topPad,
  );

  /// Geser dari koordinat layar desain ke koordinat peta.
  static const shift = Offset(0, PictureMapArt.topPad - PictureMapArt.mapTop);

  /// Titik node babak di koordinat peta.
  static List<Offset> pointsFor({required bool compact}) => [
    for (final p in PictureMapArt.pointsFor(compact: compact)) p + shift,
  ];

  /// Tengah node level ke-[index] babak (koordinat peta).
  static Offset pointOf(int index, {bool compact = false}) =>
      pointsFor(compact: compact)[index];

  /// Titik pijakan token di jalur dari node [segment] ke berikutnya pada
  /// [t] 0–1 (koordinat peta).
  static Offset onRoad(int segment, double t, {bool compact = false}) =>
      PictureMapArt.onRoad(pointsFor(compact: compact), segment, t);

  @override
  Widget build(BuildContext context) {
    final levels = chapter.levels;
    final points = pointsFor(compact: compact);
    assert(levels.length <= points.length);
    final states = [for (final level in levels) NodeState.of(progress, level)];
    final current = states.indexWhere((s) => s != NodeState.done);
    final reached = current == -1 ? levels.length : current;
    const paw = PictureMapArt.pawSize;

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MapArt(chapter.number, compact)),
          ),
          for (var i = 0; i + 1 < levels.length; i++)
            for (final (k, t) in PictureMapArt.pawSteps.indexed)
              Positioned(
                left: _paw(points, i, t, k).dx - paw / 2,
                top: _paw(points, i, t, k).dy - paw / 2,
                child: MapPaw(
                  angle: MapArt.pawAngle(points[i], points[i + 1]),
                  opacity: i < reached
                      ? PictureMapArt.pawOpacity
                      : PictureMapArt.pawDimOpacity,
                ),
              ),
          for (var i = 0; i < levels.length; i++)
            _place(
              context,
              points[i],
              PictureNode(
                level: levels[i],
                chapter: chapter,
                state: states[i],
                stars: progress.starsOf(levels[i].id),
                onPressed: () => onPlay(levels[i]),
                compact: compact,
                labelBelow: _labelBelow(context, points, i),
              ),
              boss: i == levels.length - 1,
            ),
          if (token case final token?)
            Positioned(
              left: token.at.dx + PictureMapArt.tokenOffset.dx,
              top: token.at.dy + PictureMapArt.tokenOffset.dy,
              child: IgnorePointer(
                child: MapToken(
                  pose: token.pose,
                  facing: token.facing,
                  accessory: oyenAccessory,
                  time: token.time,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Jejak ke-[k] di garis node [i] → berikutnya pada [t], digeser ke
  /// samping garis (`[0.38, 0.62].forEach` desain).
  static Offset _paw(List<Offset> points, int i, double t, int k) {
    final a = points[i];
    final b = points[i + 1];
    final d = b - a;
    final normal = Offset(-d.dy, d.dx) / (d.distance == 0 ? 1 : d.distance);
    final side = k == 0 ? PictureMapArt.pawSide : -PictureMapArt.pawSide;
    return a + d * t + normal * side;
  }

  /// Label "Main" pindah ke bawah node kalau node sebelumnya tepat di
  /// atasnya, supaya bintang node itu tidak tertutup (level 4 dan 7 tiap
  /// babak). Desain hanya menampilkan level 13 sebagai level saat ini.
  bool _labelBelow(BuildContext context, List<Offset> points, int index) {
    if (index == 0) return false;
    final s = context.koSize;
    final node = PictureNode.sizeOf(context, boss: false, compact: compact);
    final d = points[index] - points[index - 1];
    // Atas label sampai bawah bintang node sebelumnya.
    final reach = node + MapArt.labelAbove + context.koSpace.s8 + s.mapStar;
    return d.dy > 0 && d.dy < reach && d.dx.abs() < node;
  }

  /// Node dengan tengah badge di [center]. Kotaknya dibuat lebar supaya
  /// label di bawah atau di atasnya bisa lebih lebar dari node.
  Widget _place(
    BuildContext context,
    Offset center,
    Widget node, {
    bool boss = false,
  }) {
    final half = PictureNode.sizeOf(context, boss: boss, compact: compact) / 2;
    const width = MapArt.nodeSlot;
    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - half,
      width: width,
      child: Align(alignment: Alignment.topCenter, child: node),
    );
  }
}

/// Satu jejak kaki di jalur, diputar searah jalan.
class MapPaw extends StatelessWidget {
  const MapPaw({super.key, required this.angle, required this.opacity});

  /// Derajat searah jarum jam, 0 = ke atas.
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: const CustomPaint(
          size: Size.square(PictureMapArt.pawSize),
          painter: _Paw(),
        ),
      ),
    );
  }
}

class _Paw extends CustomPainter {
  const _Paw();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    paintMapPaw(canvas);
  }

  @override
  bool shouldRepaint(_Paw old) => false;
}

/// Dekor ruangan, area bos, dan jalur (koordinat layar desain) di
/// koordinat peta.
class _MapArt extends CustomPainter {
  const _MapArt(this.chapter, this.compact);

  final int chapter;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, ChapterMap.shift.dy);
    paintPictureMap(
      canvas,
      chapter: chapter,
      points: PictureMapArt.pointsFor(compact: compact),
    );
  }

  @override
  bool shouldRepaint(_MapArt old) =>
      old.chapter != chapter || old.compact != compact;
}
