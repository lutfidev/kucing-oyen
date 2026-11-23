import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/house.dart';
import '../../game/model/needs.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'room_geometry.dart';

/// Pintu terbuka ke ruangan sebelah: kotak ketuk tak terlihat di bukaan
/// pintu ([RoomGeometry.doorTap]), tombol "Pergi ke …" untuk pembaca layar.
class DoorButton extends StatelessWidget {
  const DoorButton({
    super.key,
    required this.geo,
    required this.label,
    required this.onTap,
  });

  final RoomGeometry geo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
    rect: geo.doorTap,
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
    ),
  );
}

/// Penanda "‹ Ruang tengah" di teras (`HeaderRumah.dc.html`, `chipRuang`):
/// ketuk = kembali ke ruang tengah. Penanda, bukan menu.
class RoomChip extends StatelessWidget {
  const RoomChip({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final label = context.l10n.roomName(HouseRoom.living.name);
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressIcon,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.pill,
      height: s.roomDecorateButton,
      padding: EdgeInsetsDirectional.only(start: space.s8, end: space.s16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(KoIcons.roomBack, size: s.iconSmall, color: c.ink),
          SizedBox(width: space.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.label.copyWith(color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pintu menyala saat kucing diangkat (`AdeganTengah.dc.html` mode
/// `angkat`): bukaan diisi kuning lembut dengan garis tebal yang
/// berdenyut (`rmDenyut`), lalu garis putus oranye di atasnya. [time] =
/// detik denyut, null = diam (kurangi gerak).
class DoorGlow extends StatelessWidget {
  const DoorGlow({super.key, required this.geo, this.time});

  final RoomGeometry geo;
  final double? time;

  /// Opasitas desain: isi 0,3, garis tebal 0,45; denyut 0,78–1 tiap 5 detik.
  static const fillOpacity = 0.3;
  static const ringOpacity = 0.45;
  static const pulseLow = 0.78;
  static const pulseSeconds = 5.0;

  /// Tebal garis (px desain): garis tebal 10, garis putus 3,5 (8 garis, 6
  /// celah).
  static const ringWidth = 10.0;
  static const dashWidth = 3.5;
  static const dash = 8.0;
  static const gap = 6.0;

  /// Kekuatan denyut pada detik [time] (1 = penuh).
  static double pulse(double? time) {
    if (time == null) return 1;
    final phase = (time % pulseSeconds) / pulseSeconds;
    return pulseLow +
        (1 - pulseLow) * (0.5 - 0.5 * math.cos(2 * math.pi * phase));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DoorGlowPainter(
          door: geo.door,
          glow: c.star,
          line: c.orange,
          pulse: pulse(time),
          unit: geo.artScale,
        ),
      ),
    );
  }
}

class _DoorGlowPainter extends CustomPainter {
  _DoorGlowPainter({
    required this.door,
    required this.glow,
    required this.line,
    required this.pulse,
    required this.unit,
  });

  final Path door;
  final Color glow;
  final Color line;
  final double pulse;
  final double unit;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      door,
      Paint()..color = glow.withValues(alpha: DoorGlow.fillOpacity * pulse),
    );
    canvas.drawPath(
      door,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = DoorGlow.ringWidth * unit
        ..color = glow.withValues(alpha: DoorGlow.ringOpacity * pulse),
    );
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = DoorGlow.dashWidth * unit
      ..color = line;
    for (final metric in door.computeMetrics()) {
      for (
        var d = 0.0;
        d < metric.length;
        d += (DoorGlow.dash + DoorGlow.gap) * unit
      ) {
        canvas.drawPath(
          metric.extractPath(d, d + DoorGlow.dash * unit),
          dashPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DoorGlowPainter old) =>
      old.pulse != pulse || old.door != door || old.unit != unit;
}

/// Status saat kucing diangkat (`HeaderRumah.dc.html`, `isAngkat`):
/// "Bawa ke pintu untuk ajak ke …", dibacakan pembaca layar.
class LiftStatus extends StatelessWidget {
  const LiftStatus({super.key, required this.to});

  /// Ruangan tujuan kalau kucing dilepas di pintu.
  final HouseRoom to;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        constraints: BoxConstraints(minHeight: s.roomDecorateButton),
        padding: EdgeInsetsDirectional.only(
          start: space.s10,
          end: space.s16,
          top: space.s4,
          bottom: space.s4,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          boxShadow: KoShadow.solid(c.line, s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoIcon(KoIcons.door, size: s.iconCompact, color: c.orangeDeep),
            SizedBox(width: space.s8),
            Flexible(
              child: Text(
                context.l10n.liftHint(to.name),
                style: context.koType.cardBodyStrong.copyWith(color: c.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ikon perhatian di dekat pintu untuk kucing di ruangan sebelah
/// (`AdeganTengah`/`AdeganTeras` isi `ikon`): tanda lapar atau lesu, atau
/// gelembung hadiah koin. Hanya penanda: tidak bisa diketuk dan tanpa
/// semantik sendiri (label pintunya yang menyebut kucingnya).
class DoorAttention extends StatelessWidget {
  const DoorAttention({
    super.key,
    required this.geo,
    required this.need,
    this.time,
    this.front = false,
  });

  final RoomGeometry geo;
  final DoorNeed need;

  /// Ikon di pintu depan ruang tengah (Oyen di gang): letak cermin pintu
  /// teras, sama dengan penanda "Oyen di gang" (15, 238).
  final bool front;

  /// Detik naik-turun; null = diam.
  final double? time;

  /// Letak desain ikon di area rumah 390×652.
  static const _mark = {
    HouseRoom.living: Offset(327, 238),
    HouseRoom.terrace: Offset(15, 238),
  };
  static const _bubble = {
    HouseRoom.living: Offset(319, 226),
    HouseRoom.terrace: Offset(7, 226),
  };

  @override
  Widget build(BuildContext context) {
    final reward = need == DoorNeed.reward;
    final side = front ? HouseRoom.terrace : geo.which;
    final at = (reward ? _bubble : _mark)[side]!;
    final view = reward ? RoomArt.coinBubbleViewBox : RoomArt.sadMarkViewBox;
    final box = geo.fromDesign(at & view);
    return Positioned.fromRect(
      rect: box,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: reward
              ? CoinBubbleView(
                  coins: kittyRewardCoins,
                  label: '',
                  onTap: () {},
                  size: box.width,
                  time: time,
                )
              : SadMarkView(
                  hungry: need == DoorNeed.hungry,
                  size: box.width,
                  time: time,
                ),
        ),
      ),
    );
  }
}
