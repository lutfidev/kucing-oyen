import 'dart:math' as math;
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import '../../../theme/ko_ui.dart';
import '../../model/accessories.dart';
import '../picture_map_art.dart';
import '../tile.dart';
import 'art_pack.dart';
import 'cat_rig.dart';
import 'puzzle_art.dart';
import 'puzzle_cat_sources.dart';

/// Finite vector inventory shared by map tokens and chapter transitions.
abstract final class JourneyArt {
  static final cats = ArtPack.oyen({
    ...puzzleCatSources,
    ...navigationAccessorySources,
  }, metadata: navigationAccessoryMetadata);

  static void cat(
    Canvas c,
    Rect rect, {
    CatMotion motion = CatMotion.idle,
    CatDirection direction = CatDirection.front,
    AccessoryId? accessory,
    double? time,
  }) {
    c.save();
    c.translate(rect.left, rect.top);
    c.scale(rect.width / 128, rect.height / 128);
    CatRig(
      motion: motion,
      direction: direction,
      accessory: accessory,
      time: time,
    ).paint(c, cats, props: false);
    c.restore();
  }

  static void floor(Canvas c, Size size) {
    c.drawRect(Offset.zero & size, Paint()..color = PuzzleArt.floor);
    for (var row = 0; row * 42 < size.height; row++) {
      final y = row * 42.0;
      if (row.isOdd) {
        c.drawRect(
          Rect.fromLTWH(0, y, size.width, 42),
          Paint()..color = PuzzleArt.floorAlt,
        );
      }
      PuzzleArt.line(
        c,
        Offset(0, y),
        Offset(size.width, y),
        color: KoUi.homeLine.withValues(alpha: .3),
      );
      for (var x = row.isOdd ? 42.0 : 112.0; x < size.width; x += 140) {
        PuzzleArt.line(
          c,
          Offset(x, y),
          Offset(x, y + 42),
          color: KoUi.homeLine.withValues(alpha: .3),
        );
      }
    }
  }

  static void paw(Canvas c) {
    PuzzleArt.oval(
      c,
      const Rect.fromLTWH(-5, -1, 10, 8),
      KoUi.homeLine,
      outline: false,
    );
    for (final p in const [
      Offset(-6, -5),
      Offset(-2, -8),
      Offset(3, -8),
      Offset(7, -4),
    ]) {
      c.drawOval(
        Rect.fromCenter(center: p, width: 4, height: 5),
        Paint()..color = KoUi.homeLine,
      );
    }
  }

  static void rays(Canvas c) {
    for (var i = 0; i < 12; i++) {
      c.save();
      c.rotate(i * math.pi / 6);
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(-65, -310)
          ..lineTo(65, -310)
          ..close(),
        Paint()..color = KoUi.honey.withValues(alpha: .16),
      );
      c.restore();
    }
  }

  static void confetti(Canvas c) {
    for (var i = 0; i < 24; i++) {
      final at = Offset(
        16 + (i * 73 % 360).toDouble(),
        60 + (i * 97 % 700).toDouble(),
      );
      c.save();
      c.translate(at.dx, at.dy);
      c.rotate(i * .7);
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(0, 0, 5, 12),
        [KoUi.orange, KoUi.honey, KoUi.homeLeaf][i % 3],
        radius: 2,
        outline: false,
      );
      c.restore();
    }
  }

  /// Decorations stay outside the playable route. Both chapters share geometry.
  static void map(Canvas c, int chapter, List<Offset> points) {
    final kitchen = chapter == 1;
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(18, 152, 354, 58),
      KoUi.peach,
      radius: 18,
    );
    for (var x = 32.0; x < 360; x += 42) {
      PuzzleArt.line(c, Offset(x, 164), Offset(x, 198), color: KoUi.homeLine);
    }
    if (kitchen) {
      tile(c, const Rect.fromLTWH(20, 150, 58, 58), TileKind.fridge);
      tile(c, const Rect.fromLTWH(299, 150, 58, 58), TileKind.shelf);
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(126, 157, 132, 37),
        KoUi.paper,
        radius: 12,
      );
      for (var x = 142.0; x < 250; x += 32) {
        PuzzleArt.oval(c, Rect.fromLTWH(x, 165, 20, 20), KoUi.water);
      }
    } else {
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(116, 158, 160, 36),
        KoUi.homeLeaf,
        radius: 12,
      );
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(126, 149, 65, 31),
        KoUi.homeLeaf,
        radius: 9,
      );
      PuzzleArt.box(
        c,
        const Rect.fromLTWH(201, 149, 65, 31),
        KoUi.homeLeaf,
        radius: 9,
      );
      plant(c, const Offset(42, 185));
      plant(c, const Offset(346, 185));
    }
    // A broad paper ribbon keeps the trail distinct from the wooden floor.
    final road = parseSvgPathData(PictureMapArt.roadD(points));
    c.drawPath(
      road,
      Paint()
        ..color = KoUi.homeLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 37
        ..strokeCap = StrokeCap.round,
    );
    c.drawPath(
      road,
      Paint()
        ..color = KoUi.paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 33
        ..strokeCap = StrokeCap.round,
    );
    // Small side props give each map a recognizable room identity.
    if (kitchen) {
      tile(c, const Rect.fromLTWH(18, 328, 43, 43), TileKind.cupboard);
      tile(c, const Rect.fromLTWH(318, 463, 47, 47), TileKind.tableGlass);
    } else {
      plant(c, const Offset(38, 366));
      tile(c, const Rect.fromLTWH(318, 467, 47, 47), TileKind.tableVase);
    }
    PuzzleArt.box(
      c,
      Rect.fromCenter(center: points.last, width: 170, height: 132),
      KoUi.peach,
      radius: 36,
    );
    for (final dx in [-68.0, 68.0]) {
      c.drawCircle(
        points.last + Offset(dx, -44),
        5,
        Paint()..color = KoUi.orange,
      );
    }
  }

  static void tile(Canvas c, Rect rect, TileKind kind) {
    c.save();
    c.translate(rect.left, rect.top);
    c.scale(rect.width / 50, rect.height / 50);
    paintPuzzleTile(c, Tile(kind: kind));
    c.restore();
  }

  static void plant(Canvas c, Offset at) {
    PuzzleArt.line(c, at + const Offset(0, -24), at, width: 3);
    PuzzleArt.oval(
      c,
      Rect.fromCenter(
        center: at + const Offset(-7, -19),
        width: 18,
        height: 10,
      ),
      KoUi.homeLeaf,
    );
    PuzzleArt.oval(
      c,
      Rect.fromCenter(center: at + const Offset(7, -28), width: 18, height: 10),
      KoUi.homeLeaf,
    );
    PuzzleArt.box(
      c,
      Rect.fromCenter(center: at + const Offset(0, 5), width: 24, height: 20),
      KoUi.peach,
      radius: 5,
    );
  }

  /// Twenty household pictograms, with one stable identity per existing level.
  static void node(Canvas c, String object, double size) {
    c.save();
    c.scale(size / 64);
    final i = PictureMapArt.objects.indexOf(object);
    switch (i) {
      case 0:
        tile(c, const Rect.fromLTWH(5, 4, 54, 54), TileKind.fridge);
      case 2 || 5 || 12 || 17:
        PuzzleArt.box(
          c,
          const Rect.fromLTWH(8, 9, 48, 43),
          i == 5 ? KoUi.water : KoUi.honey,
        );
        for (final y in [23.0, 40.0]) {
          PuzzleArt.line(c, Offset(11, y), Offset(53, y));
          for (var x = 16.0; x < 50; x += 13) {
            PuzzleArt.box(
              c,
              Rect.fromLTWH(x, y - 11, 8, 10),
              i == 17 ? KoUi.homeLeaf : KoUi.paper,
              radius: 2,
            );
          }
        }
      case 10:
        PuzzleArt.box(
          c,
          const Rect.fromLTWH(9, 18, 46, 33),
          KoUi.homeLeaf,
          radius: 10,
        );
        PuzzleArt.box(
          c,
          const Rect.fromLTWH(15, 10, 34, 27),
          KoUi.homeLeaf,
          radius: 10,
        );
        for (final x in [8.0, 47.0]) {
          PuzzleArt.box(c, Rect.fromLTWH(x, 28, 10, 22), KoUi.peach);
        }
      case 11:
        tile(c, const Rect.fromLTWH(5, 4, 54, 54), TileKind.tableGlass);
      case 13:
        plant(c, const Offset(32, 39));
      case 14:
        PuzzleArt.line(c, const Offset(32, 20), const Offset(32, 53), width: 4);
        PuzzleArt.box(c, const Rect.fromLTWH(18, 49, 28, 5), KoUi.honey);
        PuzzleArt.shape(
          c,
          Path()
            ..moveTo(22, 7)
            ..lineTo(42, 7)
            ..lineTo(53, 30)
            ..lineTo(11, 30)
            ..close(),
          KoUi.peach,
        );
      case 15 || 16:
        PuzzleArt.oval(
          c,
          const Rect.fromLTWH(10, 7, 44, 44),
          i == 16 ? KoUi.paper : KoUi.water,
        );
        if (i == 16) {
          PuzzleArt.line(
            c,
            const Offset(32, 29),
            const Offset(32, 16),
            width: 3,
          );
          PuzzleArt.line(
            c,
            const Offset(32, 29),
            const Offset(43, 34),
            width: 3,
          );
        } else {
          for (var k = 0; k < 3; k++) {
            final a = k * math.pi * 2 / 3;
            PuzzleArt.oval(
              c,
              Rect.fromCenter(
                center: Offset(32 + math.cos(a) * 10, 29 + math.sin(a) * 10),
                width: 18,
                height: 11,
              ),
              KoUi.paper,
            );
          }
        }
      case 3:
        PuzzleArt.shape(
          c,
          Path()
            ..moveTo(8, 43)
            ..quadraticBezierTo(10, 9, 32, 9)
            ..quadraticBezierTo(54, 9, 56, 43)
            ..close(),
          KoUi.homeLeaf,
        );
        PuzzleArt.oval(c, const Rect.fromLTWH(6, 39, 52, 12), KoUi.honey);
        PuzzleArt.box(c, const Rect.fromLTWH(28, 4, 8, 8), KoUi.honey);
      case 4:
        PuzzleArt.box(
          c,
          const Rect.fromLTWH(10, 18, 44, 34),
          KoUi.paper,
          radius: 12,
        );
        PuzzleArt.oval(c, const Rect.fromLTWH(10, 10, 44, 20), KoUi.peach);
        PuzzleArt.box(c, const Rect.fromLTWH(23, 6, 18, 7), KoUi.honey);
        PuzzleArt.box(c, const Rect.fromLTWH(26, 34, 12, 10), KoUi.orange);
      case 19:
        PuzzleArt.line(
          c,
          const Offset(32, 3),
          const Offset(32, 14),
          color: KoUi.homeLeaf,
          width: 4,
        );
        PuzzleArt.shape(
          c,
          Path()
            ..moveTo(32, 12)
            ..lineTo(54, 33)
            ..lineTo(32, 55)
            ..lineTo(10, 33)
            ..close(),
          KoUi.homeLeaf,
        );
        for (final shift in [-8.0, 4.0]) {
          PuzzleArt.line(
            c,
            Offset(22 + shift, 23),
            Offset(42 + shift, 43),
            color: KoUi.paper,
            width: 3,
          );
          PuzzleArt.line(
            c,
            Offset(22 + shift, 43),
            Offset(42 + shift, 23),
            color: KoUi.paper,
            width: 3,
          );
        }
      case 9:
        PuzzleArt.oval(c, const Rect.fromLTWH(5, 25, 54, 24), KoUi.honey);
        for (var k = 0; k < 3; k++) {
          PuzzleArt.oval(
            c,
            Rect.fromLTWH(12 + k * 12, 19 - k % 2 * 5, 15, 11),
            PuzzleArt.fish,
          );
        }
      default:
        final jar = [7, 8, 18].contains(i);
        PuzzleArt.box(
          c,
          Rect.fromLTWH(
            jar ? 18 : 9,
            jar ? 12 : 22,
            jar ? 28 : 46,
            jar ? 40 : 29,
          ),
          i == 7 ? KoUi.water : KoUi.peach,
          radius: 10,
        );
        PuzzleArt.box(
          c,
          Rect.fromLTWH(jar ? 17 : 13, jar ? 8 : 17, jar ? 30 : 38, 8),
          KoUi.honey,
        );
        if (i == 1) {
          for (final x in [20.0, 44.0]) {
            PuzzleArt.oval(
              c,
              Rect.fromCenter(center: Offset(x, 29), width: 15, height: 8),
              KoUi.ink,
            );
          }
        } else if (i == 6) {
          PuzzleArt.line(
            c,
            const Offset(23, 28),
            const Offset(46, 9),
            width: 7,
          );
        } else if (i == 18) {
          for (final at in const [
            Offset(26, 31),
            Offset(38, 39),
            Offset(27, 44),
          ]) {
            PuzzleArt.oval(
              c,
              Rect.fromCenter(center: at, width: 10, height: 10),
              KoUi.honey,
            );
            c.drawCircle(at, 1.5, Paint()..color = KoUi.ink);
          }
        } else if (i == 8) {
          for (final y in [30.0, 37.0, 44.0]) {
            PuzzleArt.oval(
              c,
              Rect.fromCenter(center: Offset(32, y), width: 15, height: 6),
              KoUi.paper,
            );
          }
        } else {
          PuzzleArt.oval(c, const Rect.fromLTWH(24, 30, 16, 12), KoUi.paper);
        }
    }
    c.restore();
  }

  static void door(Canvas c) {
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(136, 8, 118, 139),
      KoUi.honey,
      radius: 18,
    );
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(147, 19, 96, 128),
      KoUi.peach,
      radius: 12,
    );
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(159, 33, 71, 52),
      KoUi.paper,
      radius: 8,
    );
    c.drawCircle(const Offset(225, 104), 4, Paint()..color = KoUi.ink);
  }

  static void result(Canvas c, Size size, {bool broken = false}) {
    floor(c, size);
    PuzzleArt.box(
      c,
      Rect.fromLTWH(0, 0, size.width, size.height * .43),
      KoUi.peach,
      radius: 0,
      outline: false,
    );
    PuzzleArt.line(
      c,
      Offset(0, size.height * .43),
      Offset(size.width, size.height * .43),
      color: KoUi.homeLine,
      width: 3,
    );
    final center = size.width / 2;
    PuzzleArt.oval(
      c,
      Rect.fromCenter(
        center: Offset(center, size.height * .81),
        width: size.width * .72,
        height: size.height * .25,
      ),
      KoUi.peach,
    );
    cat(
      c,
      Rect.fromLTWH(center - 86, size.height - 185, 172, 172),
      motion: broken ? CatMotion.startled : CatMotion.win,
    );
    final bowl = Offset(center, size.height - 29);
    PuzzleArt.shape(
      c,
      Path()
        ..moveTo(bowl.dx - 27, bowl.dy - 4)
        ..lineTo(bowl.dx - 22, bowl.dy + 15)
        ..quadraticBezierTo(bowl.dx, bowl.dy + 25, bowl.dx + 22, bowl.dy + 15)
        ..lineTo(bowl.dx + 27, bowl.dy - 4)
        ..close(),
      KoUi.orange,
    );
    PuzzleArt.oval(
      c,
      Rect.fromCenter(center: bowl, width: 58, height: 23),
      KoUi.paper,
    );
    PuzzleArt.oval(
      c,
      Rect.fromCenter(center: bowl, width: 44, height: 13),
      KoUi.honey,
    );
    for (final dx in [-12.0, 0.0, 12.0]) {
      c.drawCircle(
        bowl + Offset(dx, dx == 0 ? -2 : 1),
        2.5,
        Paint()..color = KoUi.ink,
      );
    }
    if (broken) {
      for (var k = 0; k < 4; k++) {
        final x = center + 60 + k % 2 * 19.0;
        final y = size.height - 48 + k ~/ 2 * 15.0;
        PuzzleArt.shape(
          c,
          Path()
            ..moveTo(x, y)
            ..lineTo(x + 13, y - 8)
            ..lineTo(x + 10, y + 6)
            ..close(),
          const Color(0xFFCD8B79),
        );
      }
    } else {
      for (final dx in [-105.0, 105.0]) {
        final at = Offset(center + dx, size.height * .3);
        PuzzleArt.line(
          c,
          at - const Offset(5, 0),
          at + const Offset(5, 0),
          color: KoUi.orange,
          width: 3,
        );
        PuzzleArt.line(
          c,
          at - const Offset(0, 5),
          at + const Offset(0, 5),
          color: KoUi.orange,
          width: 3,
        );
      }
    }
  }
}
