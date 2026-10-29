import 'package:flutter/widgets.dart';

import '../game/model/accessories.dart';
import '../game/model/home_items.dart';
import '../game/model/rules.dart';
import '../game/model/snacks.dart';
import '../game/render/render.dart';
import '../game/sim/item.dart';
import '../l10n/l10n.dart';
import '../l10n/names.dart';
import '../theme/theme.dart';

export '../game/render/coin_art.dart' show CoinKind;

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

/// Koin seukuran [size] px (desain 14–28 px), gambar [kind].
/// Hiasan saja.
class CoinView extends StatelessWidget {
  const CoinView({
    super.key,
    this.size = CoinArt.viewBox,
    this.kind = CoinKind.full,
  });

  final double size;
  final CoinKind kind;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _CoinPainter(kind)),
    );
  }
}

class _CoinPainter extends CustomPainter {
  _CoinPainter(this.kind);

  final CoinKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / CoinArt.viewBox);
    paintCoin(canvas, kind: kind);
  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.kind != kind;
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
      label: oyenLabel(context.l10n, look),
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
      label: context.l10n.boardLabel,
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

/// Kucing kamar seukuran [size] px (desain 100 px). Topi dan mainan boleh
/// keluar dari kotaknya, seperti sprite di desain.
class KittyView extends StatelessWidget {
  const KittyView({super.key, required this.look, required this.size});

  final KittyLook look;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: kittyLabel(context.l10n, look),
      child: CustomPaint(size: Size.square(size), painter: _KittyPainter(look)),
    );
  }
}

class _KittyPainter extends CustomPainter {
  _KittyPainter(this.look);

  final KittyLook look;

  @override
  void paint(Canvas canvas, Size size) =>
      paintKitty(canvas, look, size: size.width);

  @override
  bool shouldRepaint(_KittyPainter old) => old.look != look;
}

/// Barang kamar yang diskalakan supaya muat dan dipusatkan di [box].
/// [full] = isi mangkuk.
class RoomItemView extends StatelessWidget {
  const RoomItemView({
    super.key,
    required this.id,
    required this.box,
    this.full = true,
    this.time,
    this.user,
  });

  final RoomItemId id;
  final Size box;
  final bool full;

  /// Detik animasi barang; null = diam.
  final double? time;

  /// Kucing yang sedang memakai barang ini; [box] = kotak dipakai
  /// ([RoomItemArt.inUseBox]).
  final KittyLook? user;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: roomItemName(context.l10n, id),
      child: CustomPaint(
        size: box,
        painter: _RoomItemPainter(id, full, time, user),
      ),
    );
  }
}

class _RoomItemPainter extends CustomPainter {
  _RoomItemPainter(this.id, this.full, this.time, this.user);

  final RoomItemId id;
  final bool full;
  final double? time;
  final KittyLook? user;

  @override
  void paint(Canvas canvas, Size size) => paintRoomItemArt(
    canvas,
    id,
    box: size,
    full: full,
    time: time,
    user: user,
  );

  @override
  bool shouldRepaint(_RoomItemPainter old) =>
      old.id != id || old.full != full || old.time != time || old.user != user;
}

/// Camilan yang diskalakan supaya muat dan dipusatkan di [box].
class SnackView extends StatelessWidget {
  const SnackView({super.key, required this.id, required this.box});

  final SnackId id;
  final Size box;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: snackName(context.l10n, id),
      child: CustomPaint(size: box, painter: _SnackPainter(id)),
    );
  }
}

class _SnackPainter extends CustomPainter {
  _SnackPainter(this.id);

  final SnackId id;

  @override
  void paint(Canvas canvas, Size size) => paintSnackArt(canvas, id, box: size);

  @override
  bool shouldRepaint(_SnackPainter old) => old.id != id;
}

/// Ikon aksesoris seukuran [size] px (desain 48 px); null = ikon "tanpa
/// aksesoris". Hiasan saja: namanya ditulis di sebelahnya.
class AccessoryIconView extends StatelessWidget {
  const AccessoryIconView({
    super.key,
    required this.id,
    this.size = AccessoryIconArt.viewBox,
  });

  final AccessoryId? id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AccessoryIconPainter(id),
      ),
    );
  }
}

class _AccessoryIconPainter extends CustomPainter {
  _AccessoryIconPainter(this.id);

  final AccessoryId? id;

  @override
  void paint(Canvas canvas, Size size) =>
      paintAccessoryIcon(canvas, id, size: size.width);

  @override
  bool shouldRepaint(_AccessoryIconPainter old) => old.id != id;
}

/// Tanda lesu di atas kucing kamar selebar [size] (`TandaLesu.dc.html`).
class SadMarkView extends StatelessWidget {
  const SadMarkView({
    super.key,
    required this.hungry,
    this.size = 48,
    this.time,
  });

  final bool hungry;
  final double size;

  /// Detik naik-turun (`tlBob`); null = diam.
  final double? time;

  @override
  Widget build(BuildContext context) {
    final box = RoomArt.sadMarkViewBox;
    final scale = size / box.width;
    return Semantics(
      image: true,
      label: sadMarkLabel(context.l10n, hungry: hungry),
      child: Transform.translate(
        offset: Offset(0, RoomArt.sadMarkBob(time) * scale),
        child: CustomPaint(size: box * scale, painter: _SadMarkPainter(hungry)),
      ),
    );
  }
}

/// Gelembung hadiah koin di atas kucing yang dirawat (desain 21,
/// `GelembungKoin.dc.html`) selebar [size]: koin, kilau, dan label "+N".
/// Diketuk untuk mengambil hadiahnya.
class CoinBubbleView extends StatelessWidget {
  const CoinBubbleView({
    super.key,
    required this.coins,
    required this.label,
    required this.onTap,
    this.size = 64,
    this.time,
  });

  final int coins;

  /// Label pembaca layar.
  final String label;
  final VoidCallback onTap;
  final double size;

  /// Detik naik-turun (`gkBob`); null = diam.
  final double? time;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final box = RoomArt.coinBubbleViewBox;
    final scale = size / box.width;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, RoomArt.coinBubbleBob(time) * scale),
          child: SizedBox.fromSize(
            size: box * scale,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _CoinBubblePainter()),
                ),
                Positioned(
                  top: RoomArt.coinBubbleLabelTop * scale,
                  child: Container(
                    height: s.roomBubbleLabel * scale,
                    padding: EdgeInsets.symmetric(
                      horizontal: s.roomBubbleLabelPad * scale,
                    ),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: c.ink,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      '+$coins',
                      maxLines: 1,
                      softWrap: false,
                      textScaler: TextScaler.noScaling,
                      style: context.koType.badge.copyWith(
                        color: c.cream,
                        fontWeight: FontWeight.w700,
                        fontSize: context.koType.badge.fontSize! * scale,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinBubblePainter extends CustomPainter {
  const _CoinBubblePainter();

  @override
  void paint(Canvas canvas, Size size) =>
      paintCoinBubble(canvas, width: size.width);

  @override
  bool shouldRepaint(_CoinBubblePainter old) => false;
}

class _SadMarkPainter extends CustomPainter {
  _SadMarkPainter(this.hungry);

  final bool hungry;

  @override
  void paint(Canvas canvas, Size size) =>
      paintSadMark(canvas, hungry: hungry, width: size.width);

  @override
  bool shouldRepaint(_SadMarkPainter old) => old.hungry != hungry;
}
