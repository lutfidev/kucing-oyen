import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'room_geometry.dart';

/// Dinding bergaris, trim kayu, lantai papan, bidang cahaya, dan jendela
/// (`Kamar.dc.html`), mengikuti [geo].
class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key, required this.geo});

  final RoomGeometry geo;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(painter: _RoomPainter(geo, context.koColors)),
  );
}

class _RoomPainter extends CustomPainter {
  _RoomPainter(this.geo, this.c);

  final RoomGeometry geo;
  final KoColors c;

  // Pola desain: garis dinding 18 px tiap 36 px (`repeating-linear-gradient`
  // 90deg), sambungan papan 2 px tiap 35 px (180deg), tepi terang trim 3 px.
  static const _stripe = 18.0;
  static const _stripeEvery = 36.0;
  static const _board = 35.0;
  static const _boardLine = 2.0;
  static const _trimLight = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final s = geo.scale;
    final wall = Rect.fromLTRB(0, 0, geo.room.width, geo.trim.bottom);
    canvas.drawRect(wall, Paint()..color = c.roomWall);
    final stripe = Paint()..color = c.roomWallStripe;
    for (var x = 0.0; x < wall.width; x += _stripeEvery * s) {
      canvas.drawRect(Rect.fromLTWH(x, 0, _stripe * s, wall.height), stripe);
    }
    final trim = geo.trim;
    canvas.drawRect(trim, Paint()..color = c.wood);
    canvas.drawRect(
      Rect.fromLTWH(trim.left, trim.top, trim.width, _trimLight * s),
      Paint()..color = c.roomTrimLight,
    );
    final floor = geo.floor;
    canvas.drawRect(floor, Paint()..color = c.roomFloorBoards);
    final line = Paint()..color = c.roomFloorLine;
    for (
      var y = floor.top + (_board - _boardLine) * s;
      y < floor.bottom;
      y += _board * s
    ) {
      canvas.drawRect(Rect.fromLTWH(0, y, floor.width, _boardLine * s), line);
    }
    paintRoomFloorDecor(canvas, floor: floor);
    paintRoomWindow(canvas, box: geo.fromDesign(RoomArt.windowBox));
  }

  @override
  bool shouldRepaint(_RoomPainter old) =>
      old.geo.room != geo.room || old.c != c;
}

/// Header kamar: chip koin, logo satu baris, dan total bintang.
class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.coins,
    required this.bonus,
    required this.stars,
    required this.maxStars,
    required this.onCoins,
  });

  final int coins;
  final bool bonus;
  final int stars;
  final int maxStars;
  final VoidCallback onCoins;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Row(
      children: [
        KoCoinChip(coins: coins, badge: bonus, onPressed: onCoins),
        SizedBox(width: space.s8),
        const Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: GameLogo(inline: true),
            ),
          ),
        ),
        SizedBox(width: space.s8),
        RoomStarChip(stars: stars, maxStars: maxStars),
      ],
    );
  }
}

/// "★ 31/60" di header kamar.
class RoomStarChip extends StatelessWidget {
  const RoomStarChip({super.key, required this.stars, required this.maxStars});

  final int stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      label: context.l10n.starsOf(stars, maxStars),
      excludeSemantics: true,
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(start: space.s8, end: space.s12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          boxShadow: KoShadow.solid(c.line, s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoStar(size: s.icon),
            SizedBox(width: space.s6),
            Text.rich(
              TextSpan(
                text: '$stars',
                children: [
                  TextSpan(
                    text: '/$maxStars',
                    style: TextStyle(color: c.inkSoft),
                  ),
                ],
              ),
              maxLines: 1,
              style: t.numberCoinLarge.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi panel bawah kamar ([RoomPanel]): "Main", lalu Toko, Aksesoris, dan
/// Pengaturan.
/// [compact] untuk layar pendek (catatan `n360`).
class RoomMenu extends StatelessWidget {
  const RoomMenu({
    super.key,
    required this.compact,
    required this.shopDot,
    required this.accessoryDot,
    required this.onPlay,
    required this.onShop,
    required this.onAccessories,
    required this.onSettings,
  });

  final bool compact;
  final bool shopDot;
  final bool accessoryDot;
  final VoidCallback onPlay;
  final VoidCallback onShop;
  final VoidCallback onAccessories;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.koSize;
    final space = context.koSpace;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KoButton(
          label: l.play,
          size: KoButtonSize.hero,
          icon: KoIcons.play,
          height: compact ? s.roomPlayCompact : s.roomPlay,
          style: context.koType.buttonRoom,
          onPressed: onPlay,
        ),
        SizedBox(height: compact ? space.s12 : space.s16),
        Row(
          children: [
            Expanded(
              child: RoomMenuButton(
                icon: KoIcons.store,
                label: l.shop,
                dot: shopDot,
                dotKey: const ValueKey('room-dot-shop'),
                compact: compact,
                onPressed: onShop,
              ),
            ),
            SizedBox(width: space.s10),
            Expanded(
              child: RoomMenuButton(
                icon: KoIcons.accessory,
                label: l.accessories,
                dot: accessoryDot,
                dotKey: const ValueKey('room-dot-accessories'),
                compact: compact,
                onPressed: onAccessories,
              ),
            ),
            SizedBox(width: space.s10),
            Expanded(
              child: RoomMenuButton(
                icon: KoIcons.settings,
                label: l.settings,
                compact: compact,
                onPressed: onSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lembar krem bersudut bulat di bawah kamar (menu, atau baki Gudang saat
/// menghias).
class RoomPanel extends StatelessWidget {
  const RoomPanel({super.key, required this.compact, required this.child});

  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final radius = Radius.circular(context.koRadius.sheet);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.cream,
        borderRadius: BorderRadius.vertical(top: radius),
        boxShadow: context.koShadow.sheet,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          space.s16 + space.s4,
          compact ? space.s12 : space.s16,
          space.s16 + space.s4,
          max(MediaQuery.paddingOf(context).bottom, space.s16),
        ),
        child: child,
      ),
    );
  }
}

/// Tombol krem di panel bawah kamar: ikon di atas label, titik merah
/// kalau ada yang baru terjangkau.
class RoomMenuButton extends StatelessWidget {
  const RoomMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.compact,
    required this.onPressed,
    this.dot = false,
    this.dotKey,
  });

  final KoIconData icon;
  final String label;
  final bool compact;
  final VoidCallback onPressed;
  final bool dot;
  final Key? dotKey;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: dot ? l.menuButtonNew(label, l.shopHasNew) : label,
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.control,
      height: compact ? s.roomMenuButtonCompact : s.roomMenuButton,
      padding: EdgeInsets.symmetric(horizontal: space.s6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KoIcon(icon, size: s.icon, color: c.ink),
                  SizedBox(height: space.s2),
                  Text(
                    label,
                    maxLines: 1,
                    style: (compact ? t.tagSmall : t.labelSmall).copyWith(
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (dot)
            PositionedDirectional(
              top: space.s6,
              end: space.s4,
              child: Container(
                key: dotKey,
                width: s.dot + s.border * 2,
                height: s.dot + s.border * 2,
                decoration: BoxDecoration(
                  color: c.brick,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: s.border),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kamar baru (hanya mangkuk): dua bidang kosong bergaris putus-putus dan
/// gelembung ajakan ke Toko (`Kamar.dc.html`, keadaan `baru`).
class EmptyRoomHints extends StatelessWidget {
  const EmptyRoomHints({super.key, required this.geo, required this.onShop});

  final RoomGeometry geo;
  final VoidCallback onShop;

  // Letak desain 390×844.
  static const wallSpot = Rect.fromLTWH(214, 150, 110, 84);
  static const floorSpot = Rect.fromLTWH(252, 470, 118, 64);
  static const bubbleAt = Offset(20, 590);

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final l = context.l10n;
    final wall = geo.fromDesign(wallSpot);
    final floor = geo.fromDesign(floorSpot);
    final bubble = geo.fromDesign(bubbleAt & Size.zero).topLeft;
    return Stack(
      children: [
        Positioned.fromRect(
          rect: wall,
          child: _EmptySpot(
            label: l.roomEmptyWall,
            hint: l.roomEmptyWallHint,
            line: c.roomHintWallLine,
            ink: c.roomHintWallInk,
            radius: context.koRadius.icon,
            icon: s.icon,
            onTap: onShop,
          ),
        ),
        Positioned.fromRect(
          rect: floor,
          child: _EmptySpot(
            label: l.roomEmptyFloor,
            hint: l.roomEmptyFloorHint,
            line: c.roomHintFloorLine,
            ink: c.roomHintFloorInk,
            radius: floor.height / 2,
            icon: s.iconSmall,
            onTap: onShop,
          ),
        ),
        Positioned(
          left: bubble.dx,
          top: bubble.dy,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: geo.room.width - bubble.dx * 2,
            ),
            child: _InviteBubble(text: l.roomEmptyBubble, onTap: onShop),
          ),
        ),
      ],
    );
  }
}

class _EmptySpot extends StatelessWidget {
  const _EmptySpot({
    required this.label,
    required this.hint,
    required this.line,
    required this.ink,
    required this.radius,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String hint;
  final Color line;
  final Color ink;
  final double radius;
  final double icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Semantics(
      button: true,
      label: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: KoDashedBorder(
          color: line,
          radius: radius,
          width: context.koSize.roomHintBorder,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(space.s4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KoIcon(KoIcons.plus, size: icon, color: ink),
                    Text(
                      label,
                      maxLines: 1,
                      style: context.koType.tagSmall.copyWith(color: ink),
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

/// Gelembung gelap "Kamar masih sepi. Ke Toko, yuk!" dengan ekor di kiri
/// bawah. Diam (gerak naik-turun desain menyusul di langkah 24).
class _InviteBubble extends StatelessWidget {
  const _InviteBubble({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  // Ekor desain: kiri 44, bawah -7, diputar 45°.
  static const _tailLeft = 44.0;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final tail = s.roomBubbleTail;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              start: _tailLeft,
              bottom: -tail / 2,
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                  width: tail,
                  height: tail,
                  decoration: BoxDecoration(
                    color: c.ink,
                    borderRadius: BorderRadius.circular(space.s2),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: space.s14,
                vertical: space.s8,
              ),
              decoration: BoxDecoration(
                color: c.ink,
                borderRadius: BorderRadius.circular(context.koRadius.slot),
                boxShadow: context.koShadow.card,
              ),
              child: Text(
                text,
                style: context.koType.cardBodyStrong.copyWith(color: c.cream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label "Terisi lagi N jam" di atas mangkuk kosong (`Kamar.dc.html`),
/// selebar isinya.
class BowlRefillLabel extends StatelessWidget {
  const BowlRefillLabel({super.key, required this.hours});

  final int hours;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Container(
      constraints: BoxConstraints(minHeight: s.roomBowlLabel),
      padding: EdgeInsets.symmetric(horizontal: s.roomBowlLabelPad),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: StadiumBorder(
          side: BorderSide(color: c.line, width: space.s2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(KoIcons.clock, size: s.roomBowlLabelIcon, color: c.inkSoft),
          SizedBox(width: space.s4),
          Text(
            context.l10n.bowlRefill(hours),
            maxLines: 1,
            softWrap: false,
            style: context.koType.tagSmall.copyWith(color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Menaruh anak seukuran aslinya di [at], digeser masuk supaya paling
/// sedikit [margin] dari tepi kiri dan kanan.
class KeepInside extends SingleChildLayoutDelegate {
  const KeepInside(this.at, {this.margin = 0});

  final Offset at;
  final double margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    at.dx.clamp(margin, max(margin, size.width - childSize.width - margin)),
    at.dy,
  );

  @override
  bool shouldRelayout(KeepInside old) => old.at != at || old.margin != margin;
}
