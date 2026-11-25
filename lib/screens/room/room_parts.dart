import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../game/model/house.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'room_geometry.dart';

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

/// Kamar baru (hanya mangkuk): gelembung ajakan ke Toko (`Kamar.dc.html`,
/// keadaan `baru`). Dua bidang kosong desain dihapus atas permintaan
/// pemilik repo (langkah 40).
class EmptyRoomHints extends StatelessWidget {
  const EmptyRoomHints({
    super.key,
    required this.geo,
    required this.onShop,
    this.time,
  });

  final RoomGeometry geo;
  final VoidCallback onShop;

  /// Detik anggukan gelembung (null = diam, mis. kurangi gerak).
  final double? time;

  // Letak desain area rumah 390×652 (`AdeganTengah.dc.html` isi `baru`,
  // `RuangTengah.dc.html`).
  static const bubbleAt = Offset(20, 570);

  /// Satu anggukan `rtNudge` (detik): naik lalu turun, `ease-in-out`.
  static const nodSeconds = 1.8;

  /// Geser vertikal anggukan pada detik [time], 0 sampai 1 (kali tinggi
  /// anggukan): 0 → 1 → 0 dalam [nodSeconds].
  static double nod(double? time) {
    if (time == null) return 0;
    final t = (time % nodSeconds) / nodSeconds;
    final half = t < 0.5 ? t * 2 : 2 - t * 2;
    return Curves.easeInOut.transform(half);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    final l = context.l10n;
    final bubble = geo.fromDesign(bubbleAt & Size.zero).topLeft;
    final lift = nod(time) * s.roomBubbleNod * geo.artScale;
    return Stack(
      children: [
        Positioned(
          left: bubble.dx,
          top: bubble.dy - lift,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: min(
                s.roomBubbleMax * geo.sx,
                geo.room.width - bubble.dx * 2,
              ),
            ),
            child: _InviteBubble(text: l.roomEmptyBubble, onTap: onShop),
          ),
        ),
      ],
    );
  }
}

/// Teras baru (`AdeganTeras.dc.html` isi `baru`): empat tempat nyaman
/// sebagai elips putus-putus `rx 40s ry 12s` dengan ikon tapak, tanpa
/// semantik. Petunjuk Toko hanya ada di ruang tengah.
class EmptyTerraceSpots extends StatelessWidget {
  const EmptyTerraceSpots({super.key, required this.geo});

  final RoomGeometry geo;

  /// Titik kaki desain: petak matahari, dekat pagar, dekat pot, ambang.
  static const spots = [
    Offset(182, 600),
    Offset(282, 432),
    Offset(296, 556),
    Offset(46, 456),
  ];
  static const radiusX = 40.0;
  static const radiusY = 12.0;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final unit = geo.artScale;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            for (final spot in spots)
              () {
                final k = depthScale(spot.dy) * unit;
                final at = geo.toScreen(spot.dx, spot.dy);
                return Positioned.fromRect(
                  key: ValueKey('terrace-spot-${spot.dx.round()}'),
                  rect: Rect.fromCenter(
                    center: at,
                    width: radiusX * 2 * k,
                    height: radiusY * 2 * k,
                  ),
                  child: CustomPaint(
                    painter: _DashedOval(
                      fill: c.roomPlaceFill,
                      line: c.roomPlaceLine,
                      width: s.border,
                    ),
                    child: Center(
                      child: KoIcon(
                        KoIcons.paw,
                        size: s.iconCompact * unit,
                        color: c.roomPlaceInk,
                      ),
                    ),
                  ),
                );
              }(),
          ],
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
/// selebar isinya. N dibulatkan ke atas; sisa di bawah satu jam = "Terisi
/// sebentar lagi".
class BowlRefillLabel extends StatelessWidget {
  const BowlRefillLabel({super.key, required this.left});

  /// Sisa waktu sampai mangkuk terisi.
  final Duration left;

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
            left < const Duration(hours: 1)
                ? context.l10n.bowlRefillSoon
                : context.l10n.bowlRefill((left.inSeconds / 3600).ceil()),
            maxLines: 1,
            softWrap: false,
            style: context.koType.tagSmall.copyWith(color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Tag "Baru!" di atas kucing yang baru diadopsi (desain 19, keadaan
/// `salju`). Hanya hiasan: pembaca layar mendengarnya di label kucing.
class NewKittyTag extends StatelessWidget {
  const NewKittyTag({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Container(
          height: s.roomNewTag,
          padding: EdgeInsets.symmetric(horizontal: context.koSpace.s10),
          decoration: BoxDecoration(
            color: c.success,
            borderRadius: BorderRadius.circular(context.koRadius.pill),
            boxShadow: KoShadow.solid(
              c.successDeep,
              context.koShadow.pressIcon,
            ),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              context.l10n.kittyNewTag,
              maxLines: 1,
              softWrap: false,
              style: context.koType.newTag.copyWith(color: c.onSuccess),
            ),
          ),
        ),
      ),
    );
  }
}

/// Menaruh anak seukuran aslinya di [at], digeser masuk supaya paling
/// sedikit [margin] dari tepi kiri dan kanan dan tidak di atas [top].
/// [centered]: [at] adalah tengah atas anak, bukan pojok kiri atasnya.
class KeepInside extends SingleChildLayoutDelegate {
  const KeepInside(
    this.at, {
    this.margin = 0,
    this.top = double.negativeInfinity,
    this.centered = false,
  });

  final Offset at;
  final double margin;
  final double top;
  final bool centered;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = centered ? at.dx - childSize.width / 2 : at.dx;
    return Offset(
      x.clamp(margin, max(margin, size.width - childSize.width - margin)),
      max(top, at.dy),
    );
  }

  @override
  bool shouldRelayout(KeepInside old) =>
      old.at != at ||
      old.margin != margin ||
      old.top != top ||
      old.centered != centered;
}

/// Elips berisi [fill] dengan garis putus-putus [line] setebal [width]
/// (CSS `border-radius: 50%; border: 2px dashed`), garis di dalam kotak.
class _DashedOval extends CustomPainter {
  _DashedOval({required this.fill, required this.line, required this.width});

  final Color fill;
  final Color line;
  final double width;

  /// Pola putus CSS untuk garis 2 px (`dashed`: garis dan celah 2× tebal).
  static const _dash = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final oval = (Offset.zero & size).deflate(width / 2);
    canvas.drawOval(oval, Paint()..color = fill);
    final dashed = dashPath(
      Path()..addOval(oval),
      dashArray: CircularIntervalList([width * _dash, width * _dash]),
    );
    canvas.drawPath(
      dashed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_DashedOval old) =>
      old.fill != fill || old.line != line || old.width != width;
}
