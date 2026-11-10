import 'dart:ui';

import '../../../theme/ko_ui.dart';
import '../../sim/direction.dart';
import '../../sim/item.dart';
import '../item_art.dart';
import '../oyen.dart';
import '../tile.dart';
import 'art_pack.dart';
import 'cat_rig.dart';
import 'puzzle_cat_sources.dart';

/// Native vector art in the existing 50px grid. Geometry/hitboxes stay intact.
abstract final class PuzzleArt {
  static const floor = Color(0xFFF4D6A5);
  static const floorAlt = Color(0xFFEDC791);
  static const wood = Color(0xFFC18B52);
  static const fish = Color(0xFFB0C6B5);
  static const blue = Color(0xFF498BA7);
  static final cat = ArtPack.oyen(puzzleCatSources);

  static void line(
    Canvas c,
    Offset a,
    Offset b, {
    Color color = KoUi.ink,
    double width = 1.5,
  }) => c.drawLine(
    a,
    b,
    Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round,
  );

  static void oval(Canvas c, Rect rect, Color color, {bool outline = true}) {
    c.drawOval(rect, Paint()..color = color);
    if (outline) {
      c.drawOval(
        rect,
        Paint()
          ..color = KoUi.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  static void box(
    Canvas c,
    Rect rect,
    Color color, {
    double radius = 4,
    bool outline = true,
  }) {
    final r = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    c.drawRRect(r, Paint()..color = color);
    if (outline) {
      c.drawRRect(
        r,
        Paint()
          ..color = KoUi.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  static void shape(Canvas c, Path path, Color color) {
    c.drawPath(path, Paint()..color = color);
    c.drawPath(
      path,
      Paint()
        ..color = KoUi.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }
}

void paintPuzzleItem(
  Canvas c,
  Item item, {
  bool ghost = false,
  bool player = true,
}) {
  if (player && !ghost) {
    PuzzleArt.box(c, const Rect.fromLTWH(4, 5, 42, 40), KoUi.paper, radius: 12);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 5, 42, 40),
        const Radius.circular(12),
      ),
      Paint()
        ..color = KoUi.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
  switch (item) {
    case Item.fish:
      c.save();
      c.translate(25, 25);
      c.rotate(-0.25);
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(7, 0)
          ..lineTo(16, -8)
          ..lineTo(16, 8)
          ..close(),
        PuzzleArt.fish,
      );
      PuzzleArt.oval(c, const Rect.fromLTWH(-17, -9, 26, 18), PuzzleArt.fish);
      c.drawCircle(const Offset(-10, -2), 1.7, Paint()..color = KoUi.ink);
      PuzzleArt.line(c, const Offset(0, -5), const Offset(-2, 5));
      PuzzleArt.line(c, const Offset(4, -3), const Offset(2, 4));
      c.restore();
    case Item.water:
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(12, 19)
          ..lineTo(16, 37)
          ..quadraticBezierTo(25, 44, 34, 37)
          ..lineTo(38, 19)
          ..close(),
        PuzzleArt.blue,
      );
      PuzzleArt.oval(c, const Rect.fromLTWH(12, 13, 26, 13), KoUi.water);
      PuzzleArt.line(
        c,
        const Offset(17, 18),
        const Offset(29, 18),
        color: KoUi.paper,
      );
      c.drawArc(
        const Rect.fromLTWH(14, 6, 22, 26),
        3.14,
        3.14,
        false,
        Paint()
          ..color = KoUi.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    case Item.box:
      PuzzleArt.box(c, const Rect.fromLTWH(11, 20, 28, 20), KoUi.honey);
      PuzzleArt.oval(c, const Rect.fromLTWH(11, 12, 28, 15), KoUi.ink);
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(11, 18)
          ..lineTo(5, 23)
          ..lineTo(16, 29)
          ..lineTo(24, 24)
          ..close(),
        PuzzleArt.floor,
      );
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(39, 18)
          ..lineTo(45, 23)
          ..lineTo(34, 29)
          ..lineTo(26, 24)
          ..close(),
        PuzzleArt.floor,
      );
      PuzzleArt.line(
        c,
        const Offset(25, 29),
        const Offset(25, 39),
        color: PuzzleArt.wood,
      );
  }
}

void paintPuzzleTile(Canvas c, Tile tile, {double glowOpacity = 1}) {
  c.drawRect(
    const Rect.fromLTWH(0, 0, 50, 50),
    Paint()..color = tile.alt ? PuzzleArt.floorAlt : PuzzleArt.floor,
  );
  // A visible grid and quiet wood grain, kept away from item silhouettes.
  PuzzleArt.line(
    c,
    const Offset(0, 0),
    const Offset(50, 0),
    color: PuzzleArt.wood.withValues(alpha: .5),
    width: 1,
  );
  PuzzleArt.line(
    c,
    const Offset(0, 0),
    const Offset(0, 50),
    color: PuzzleArt.wood.withValues(alpha: .5),
    width: 1,
  );
  PuzzleArt.line(
    c,
    const Offset(5, 45),
    const Offset(19, 45),
    color: PuzzleArt.wood.withValues(alpha: .3),
    width: 1,
  );
  final kind = tile.kind;
  if (kind.isWallish) {
    PuzzleArt.box(c, const Rect.fromLTWH(1, 1, 48, 48), KoUi.peach, radius: 3);
    PuzzleArt.line(
      c,
      const Offset(2, 41),
      const Offset(48, 41),
      color: PuzzleArt.wood,
      width: 4,
    );
    if (kind == TileKind.wall) {
      for (final x in [12.0, 36.0]) {
        PuzzleArt.line(
          c,
          Offset(x, 5),
          Offset(x, 35),
          color: PuzzleArt.wood.withValues(alpha: .35),
          width: 2,
        );
      }
    } else if (kind == TileKind.fridge) {
      PuzzleArt.box(c, const Rect.fromLTWH(7, 3, 36, 43), KoUi.paper);
      PuzzleArt.line(c, const Offset(8, 18), const Offset(42, 18));
      PuzzleArt.line(c, const Offset(13, 24), const Offset(13, 32), width: 3);
      PuzzleArt.line(c, const Offset(13, 9), const Offset(13, 13), width: 3);
    } else {
      PuzzleArt.box(c, const Rect.fromLTWH(5, 5, 40, 37), KoUi.honey);
      if (kind == TileKind.cupboard) {
        PuzzleArt.line(c, const Offset(25, 6), const Offset(25, 41));
        for (final x in [20.0, 30.0]) {
          c.drawCircle(Offset(x, 25), 1.8, Paint()..color = KoUi.ink);
        }
      } else {
        for (final x in [11.0, 20.0, 30.0]) {
          PuzzleArt.box(
            c,
            Rect.fromLTWH(x, 10, 6, 20),
            x == 20 ? PuzzleArt.fish : KoUi.paper,
            radius: 1,
          );
        }
        PuzzleArt.line(c, const Offset(6, 33), const Offset(44, 33), width: 3);
      }
    }
  }
  if (kind.isTable) {
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(8, 16, 5, 30),
      PuzzleArt.wood,
      radius: 2,
    );
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(37, 16, 5, 30),
      PuzzleArt.wood,
      radius: 2,
    );
    PuzzleArt.box(c, const Rect.fromLTWH(3, 10, 44, 26), KoUi.honey, radius: 8);
    PuzzleArt.line(
      c,
      const Offset(9, 30),
      const Offset(41, 30),
      color: PuzzleArt.wood,
    );
    if (kind == TileKind.tableGlass) {
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(19, 12)
          ..lineTo(21, 26)
          ..quadraticBezierTo(25, 29, 29, 26)
          ..lineTo(31, 12)
          ..close(),
        KoUi.water,
      );
      PuzzleArt.line(
        c,
        const Offset(22, 15),
        const Offset(28, 15),
        color: KoUi.paper,
      );
    }
    if (kind == TileKind.tableVase) {
      PuzzleArt.shape(
        c,
        Path()
          ..moveTo(21, 12)
          ..lineTo(20, 18)
          ..cubicTo(10, 34, 40, 34, 30, 18)
          ..lineTo(29, 12)
          ..close(),
        const Color(0xFFCD8B79),
      );
      PuzzleArt.line(
        c,
        const Offset(25, 12),
        const Offset(24, 3),
        color: KoUi.success,
      );
      PuzzleArt.oval(c, const Rect.fromLTWH(20, 1, 8, 6), KoUi.paper);
    }
    if (kind == TileKind.tableBroken) {
      for (final x in [13.0, 24.0, 35.0]) {
        PuzzleArt.shape(
          c,
          Path()
            ..moveTo(x, 18)
            ..lineTo(x - 4, 26)
            ..lineTo(x + 5, 24)
            ..close(),
          const Color(0xFFCD8B79),
        );
      }
    }
  }
  if (kind == TileKind.bowl) {
    PuzzleArt.oval(
      c,
      const Rect.fromLTWH(6, 27, 38, 16),
      KoUi.shadow,
      outline: false,
    );
    PuzzleArt.box(
      c,
      const Rect.fromLTWH(9, 20, 32, 19),
      KoUi.orange,
      radius: 9,
    );
    PuzzleArt.oval(c, const Rect.fromLTWH(8, 14, 34, 17), KoUi.paper);
    PuzzleArt.oval(c, const Rect.fromLTWH(13, 18, 24, 9), PuzzleArt.wood);
    for (final x in [18.0, 25.0, 31.0]) {
      c.drawCircle(Offset(x, 22), 2, Paint()..color = KoUi.ink);
    }
  }
  if (tile.glow && glowOpacity > 0) {
    final r = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 44, 44),
      const Radius.circular(10),
    );
    c.drawRRect(
      r,
      Paint()..color = KoUi.paper.withValues(alpha: .45 * glowOpacity),
    );
    c.drawRRect(
      r,
      Paint()
        ..color = KoUi.orange.withValues(alpha: glowOpacity)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    for (final p in [const Offset(9, 9), const Offset(41, 41)]) {
      c.drawCircle(
        p,
        2,
        Paint()..color = KoUi.ink.withValues(alpha: glowOpacity),
      );
    }
  }
  final item = tile.item;
  if (item == TileItem.water) {
    PuzzleArt.oval(c, const Rect.fromLTWH(5, 13, 40, 25), KoUi.water);
    c.drawArc(
      const Rect.fromLTWH(12, 18, 26, 12),
      .1,
      2.7,
      false,
      Paint()
        ..color = KoUi.paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  } else if (item != TileItem.none) {
    paintPuzzleItem(
      c,
      switch (item) {
        TileItem.fish || TileItem.fishP => Item.fish,
        TileItem.bucketP => Item.water,
        _ => Item.box,
      },
      player:
          item == TileItem.fishP ||
          item == TileItem.bucketP ||
          item == TileItem.boxP,
    );
  } else if (tile.ghost case final ghost?) {
    c.saveLayer(
      const Rect.fromLTWH(0, 0, 50, 50),
      Paint()..color = const Color.fromRGBO(0, 0, 0, ItemArt.hintOpacity),
    );
    paintPuzzleItem(c, ghost, ghost: true);
    c.restore();
  }
}

CatRig puzzleRig(OyenLook look) => CatRig(
  motion: switch (look.pose) {
    OyenPose.idle => CatMotion.idle,
    OyenPose.walk => CatMotion.walk,
    OyenPose.sleep => CatMotion.sleep,
    OyenPose.shock => CatMotion.startled,
    OyenPose.box => CatMotion.box,
    OyenPose.knock => CatMotion.drop,
    OyenPose.eat => CatMotion.fish,
    OyenPose.happy => CatMotion.happy,
  },
  direction: switch (look.dir) {
    Direction.up => CatDirection.back,
    Direction.down => CatDirection.front,
    Direction.left => CatDirection.left,
    Direction.right => CatDirection.right,
  },
);

void paintPuzzleOyen(Canvas c, OyenLook look, {required double size}) {
  c.save();
  if (look.mirror) {
    c.translate(size, 0);
    c.scale(-1, 1);
  }
  c.scale(size / 128);
  puzzleRig(look).paint(c, PuzzleArt.cat, props: false);
  if (look.pose == OyenPose.box) {
    c.save();
    c.translate(14, 79);
    c.scale(2, 1);
    paintPuzzleItem(c, Item.box, player: false);
    c.restore();
  }
  if (look.bubble != OyenBubble.none) {
    PuzzleArt.oval(c, const Rect.fromLTWH(88, 4, 35, 25), KoUi.paper);
    if (look.bubble == OyenBubble.ikan) {
      c.save();
      c.translate(90, 1);
      c.scale(.6);
      paintPuzzleItem(c, Item.fish, player: false);
      c.restore();
    } else if (look.bubble == OyenBubble.kaget) {
      PuzzleArt.line(c, const Offset(106, 9), const Offset(106, 18), width: 3);
      c.drawCircle(const Offset(106, 23), 1.5, Paint()..color = KoUi.ink);
    } else {
      for (final x in [96.0, 106.0]) {
        PuzzleArt.line(c, Offset(x, 12), Offset(x + 6, 12));
        PuzzleArt.line(c, Offset(x + 6, 12), Offset(x, 21));
        PuzzleArt.line(c, Offset(x, 21), Offset(x + 6, 21));
      }
    }
  }
  c.restore();
}

void paintPuzzleLiftedItem(Canvas c, Item item, {required Color shadow}) {
  const half = ItemArt.liftSize / 2;
  c.save();
  c.translate(half, half);
  c.rotate(ItemArt.liftTilt);
  c.scale(ItemArt.liftScale);
  c.translate(-half, -half);
  c.saveLayer(
    null,
    Paint()
      ..imageFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5)
      ..colorFilter = ColorFilter.mode(shadow, BlendMode.srcIn),
  );
  c.translate(0, 12);
  c.scale(ItemArt.liftSize / 50);
  paintPuzzleItem(c, item);
  c.restore();
  c.scale(ItemArt.liftSize / 50);
  paintPuzzleItem(c, item);
  c.restore();
}
