import 'package:flutter/widgets.dart';

import '../game/model/rules.dart';
import '../game/render/render.dart';
import '../game/sim/item.dart';
import '../theme/theme.dart';

/// Satu petak seukuran [size] px (desain 50 px). Hiasan saja.
class TileView extends StatelessWidget {
  const TileView(this.tile, {super.key, this.size = Tile.size});

  final Tile tile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _TilePainter(tile)),
    );
  }
}

class _TilePainter extends CustomPainter {
  _TilePainter(this.tile);

  final Tile tile;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / Tile.size);
    paintTile(canvas, tile);
  }

  @override
  bool shouldRepaint(_TilePainter old) => old.tile != tile;
}

/// Gambar benda pemain seukuran [size] px seperti di slot baki (desain 50 px
/// di slot 64 px). [ghost] = bayangan di slot yang sisanya 0. Hiasan saja.
class ItemArtView extends StatelessWidget {
  const ItemArtView(
    this.item, {
    super.key,
    this.ghost = false,
    this.size = ItemArt.viewBox,
  });

  final Item item;
  final bool ghost;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ItemArtPainter(item, ghost),
      ),
    );
  }
}

class _ItemArtPainter extends CustomPainter {
  _ItemArtPainter(this.item, this.ghost);

  final Item item;
  final bool ghost;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / ItemArt.viewBox);
    paintItemArt(canvas, item, ghost: ghost);
  }

  @override
  bool shouldRepaint(_ItemArtPainter old) =>
      old.item != item || old.ghost != ghost;
}

/// Benda yang sedang diseret jari: kotak 64 px, miring dan diperbesar
/// dengan bayangan jatuh. Hiasan saja.
class LiftedItemView extends StatelessWidget {
  const LiftedItemView(this.item, {super.key});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size.square(ItemArt.liftSize),
        painter: _LiftedItemPainter(item, context.koColors.shadowLift),
      ),
    );
  }
}

class _LiftedItemPainter extends CustomPainter {
  _LiftedItemPainter(this.item, this.shadow);

  final Item item;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) =>
      paintLiftedItem(canvas, item, shadow: shadow);

  @override
  bool shouldRepaint(_LiftedItemPainter old) =>
      old.item != item || old.shadow != shadow;
}

/// Oyen seukuran [size] px. Gelembung dan topi boleh keluar dari kotaknya,
/// jadi beri ruang di atas dan kanan.
class OyenView extends StatelessWidget {
  const OyenView(this.look, {super.key, required this.size});

  final OyenLook look;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: look.label,
      child: CustomPaint(size: Size.square(size), painter: _OyenPainter(look)),
    );
  }
}

class _OyenPainter extends CustomPainter {
  _OyenPainter(this.look);

  final OyenLook look;

  @override
  void paint(Canvas canvas, Size size) =>
      paintOyen(canvas, look, size: size.width);

  @override
  bool shouldRepaint(_OyenPainter old) => old.look != look;
}

/// Papan 350×450 lengkap dengan bingkai dan bayangan. Mengecil kalau
/// tempatnya kurang lebar; bingkai menempati 4 px di luar kotaknya.
class BoardView extends StatelessWidget {
  const BoardView(this.scene, {super.key});

  final BoardScene scene;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: BoardScene.label,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: CustomPaint(
          size: const Size(BoardScene.width, BoardScene.height),
          painter: _BoardPainter(scene),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.scene);

  final BoardScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    paintBoardFrame(canvas);
    paintBoard(canvas, scene);
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.scene != scene;
}

/// Gambar kartu aturan [rule] seukuran [RuleArt.size]. Kartu 4 yang
/// [learned] berputar seperempat terus (`koQuarter`) kalau [turn] (0–1 tiap
/// [RuleArt.quarterTime]) diberikan. Hiasan saja.
class RuleArtView extends StatelessWidget {
  const RuleArtView(this.rule, {super.key, required this.learned, this.turn});

  final OyenRule rule;
  final bool learned;
  final Animation<double>? turn;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size.square(RuleArt.size),
        painter: _RuleArtPainter(rule, learned, turn),
      ),
    );
  }
}

class _RuleArtPainter extends CustomPainter {
  _RuleArtPainter(this.rule, this.learned, this.turn) : super(repaint: turn);

  final OyenRule rule;
  final bool learned;
  final Animation<double>? turn;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / RuleArt.size);
    final t = turn?.value ?? 0;
    paintRuleArt(
      canvas,
      rule,
      learned: learned,
      catAngle: RuleArt.quarterAngle(t),
    );
  }

  @override
  bool shouldRepaint(_RuleArtPainter old) =>
      old.rule != rule || old.learned != learned || old.turn != turn;
}
