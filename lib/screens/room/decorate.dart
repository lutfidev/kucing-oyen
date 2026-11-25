import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/model/home_items.dart';
import '../../game/model/house.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'room_geometry.dart';

/// Tombol Hias, atau Selesai kalau [done] (`TombolHias.dc.html`).
class DecorateButton extends StatelessWidget {
  const DecorateButton({
    super.key,
    required this.done,
    required this.onPressed,
  });

  final bool done;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final label = done ? l.decorateDone : l.decorate;
    final ink = done ? c.onSuccess : c.ink;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: done ? c.success : c.surface,
      edgeColor: done ? c.successDeep : c.lineDeep,
      depth: done
          ? context.koShadow.pressSecondary
          : context.koShadow.pressIcon,
      borderColor: done ? null : c.line,
      borderWidth: done ? 0 : s.border,
      radius: context.koRadius.pill,
      height: s.roomDecorateButton,
      padding: EdgeInsetsDirectional.only(
        start: done ? space.s14 : space.s12,
        end: done ? space.s16 + space.s2 : space.s16,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(
            done ? KoIcons.check : KoIcons.decorate,
            size: done ? s.iconCompact : s.iconSmall,
            color: ink,
          ),
          SizedBox(width: space.s8),
          Text(
            label,
            maxLines: 1,
            style: (done ? t.buttonDone : t.label).copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}

/// Tombol Rapikan di mode hias (langkah 40, tidak ada di desain): gaya
/// tombol Hias, ikon geser.
class TidyButton extends StatelessWidget {
  const TidyButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final label = context.l10n.decorateTidy;
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
      padding: EdgeInsetsDirectional.only(start: space.s12, end: space.s16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(KoIcons.move, size: s.iconSmall, color: c.ink),
          SizedBox(width: space.s8),
          Text(
            label,
            maxLines: 1,
            style: context.koType.label.copyWith(color: c.ink),
          ),
        ],
      ),
    );
  }
}

/// Pesan sesudah Rapikan: "Sudah rapi!", plus tombol Batalkan kalau ada
/// yang bergeser ([onUndo]). Hilang sendiri sesudah [duration]
/// ([onDone]); diam saat kurangi gerak.
class TidyToast extends StatefulWidget {
  const TidyToast({super.key, required this.onDone, this.onUndo});

  /// Lebih lama dari pujian Selesai supaya Batalkan sempat diketuk.
  static const duration = Duration(milliseconds: 4000);

  final VoidCallback onDone;
  final VoidCallback? onUndo;

  @override
  State<TidyToast> createState() => _TidyToastState();
}

class _TidyToastState extends State<TidyToast>
    with SingleTickerProviderStateMixin {
  bool _gone = false;
  late final AnimationController _time =
      AnimationController(
          vsync: this,
          duration: TidyToast.duration,
          animationBehavior: AnimationBehavior.preserve,
        )
        ..forward().whenComplete(() {
          if (mounted && !_gone) {
            _gone = true;
            widget.onDone();
          }
        });

  @override
  void initState() {
    super.initState();
    _time; // Mulai menghitung.
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final undo = widget.onUndo;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsetsDirectional.only(
          start: space.s16,
          end: undo == null ? space.s16 : space.s8,
          top: space.s8,
          bottom: space.s8,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.tray),
          border: Border.all(color: c.success, width: s.artBorder),
          boxShadow: [
            ...KoShadow.solid(c.successDeep, context.koShadow.pressHero - 2),
            ...context.koShadow.dialog,
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                l.decorateTidyDone,
                style: t.numberCompact.copyWith(color: c.successDeep),
              ),
            ),
            if (undo != null) ...[
              SizedBox(width: space.s12),
              KoButton(
                key: const ValueKey('decorate-tidy-undo'),
                label: l.decorateTidyUndo,
                kind: KoButtonKind.secondary,
                size: KoButtonSize.medium,
                onPressed: () {
                  if (_gone) return;
                  _gone = true;
                  undo();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip "Seret barang ke tempat baru" saat menghias.
class DecorateHint extends StatelessWidget {
  const DecorateHint({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Container(
      constraints: BoxConstraints(minHeight: s.roomDecorateButton),
      padding: EdgeInsetsDirectional.only(
        start: space.s10,
        end: space.s14,
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
          KoIcon(KoIcons.move, size: s.iconCompact, color: c.waterDeep),
          SizedBox(width: space.s8),
          Flexible(
            child: Text(
              context.l10n.decorateHint,
              style: context.koType.cardBodyStrong.copyWith(color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panduan mode Hias (`AdeganTengah.dc.html`/`AdeganTeras.dc.html` mode
/// `hias`): area dinding (ruang tengah), area lantai, jalur pintu yang
/// diarsir, dan di teras titik gantung hammock dan lampu bulan; dengan
/// labelnya. [time] = detik denyut titik gantung (null = diam).
///
/// Dua lapisan: garis dan arsir ([labels] false) di lapisan lantai, di
/// bawah barang, supaya barang yang diangkat tetap di atasnya; chip
/// ([labels] true) di atas barang dan kucing seperti desain (z 890),
/// supaya chip jalur pintu tidak tertutup kasur.
class ZoneGuides extends StatelessWidget {
  const ZoneGuides({
    super.key,
    required this.geo,
    this.time,
    this.labels = false,
  });

  final RoomGeometry geo;
  final double? time;
  final bool labels;

  // Letak desain area rumah 390×652.
  static const wall = Rect.fromLTWH(88, 150, 214, 182);
  static const wallRadius = 14.0;
  static const floor = [
    Offset(84, 398),
    Offset(306, 398),
    Offset(386, 508),
    Offset(386, 646),
    Offset(4, 646),
    Offset(4, 508),
  ];
  static const wallLabel = Offset(96, 302);
  static const floorLabel = Offset(14, 616);
  static const livingDoorLabel = Offset(252, 534);
  static const terraceDoorLabel = Offset(50, 518);

  /// Titik gantung teras: G1 dan G2 hammock, G3 lampu bulan.
  static const hangHammock = [Offset(150.4, 158), Offset(239.8, 158)];
  static const hangLamp = Offset(305, 158);
  static const hangRadius = 12.0;
  static const hangLineY = 174.0;

  /// Label titik gantung, tengah-atas. Desain menaruhnya berdampingan di
  /// (146, 182) dan (266, 182), tapi label hammock lebih lebar dari celah
  /// itu (juga di kanvas): label hammock di tengah G1–G2, label lampu satu
  /// baris lebih bawah di bawah G3.
  static const hammockLabel = Offset(195.1, 182);
  static const lampLabel = Offset(305, 210);

  /// Denyut cincin (`rmDenyut` 5 detik: opasitas 0,78 → 1 → 0,78).
  static double pulse(double? time) {
    if (time == null) return 1;
    final t = (time % 5) / 5;
    final half = t < 0.5 ? t * 2 : 2 - t * 2;
    return 0.78 + 0.22 * Curves.easeInOut.transform(half);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final l = context.l10n;
    final terrace = geo.which == HouseRoom.terrace;
    Widget label(Offset design, Widget chip) {
      final at = geo.toScreen(design.dx, design.dy);
      return Positioned(left: at.dx, top: at.dy, child: chip);
    }

    Widget centered(Offset design, Widget chip) {
      final at = geo.toScreen(design.dx, design.dy);
      return Positioned(
        left: at.dx,
        top: at.dy,
        child: FractionalTranslation(
          translation: const Offset(-0.5, 0),
          child: chip,
        ),
      );
    }

    // Ruang tengah punya dua jalur: pintu teras dan pintu depan.
    final doors = [
      for (final path in const HouseFloor().doorPaths(geo.which))
        [for (final p in path) Offset(p.x, p.y)],
    ];
    if (!labels) {
      return IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ZonePainter(
            sx: geo.sx,
            sy: geo.sy,
            wall: terrace ? null : wall,
            floor: floor,
            doors: doors,
            hang: terrace,
            // Hanya cincin teras yang berdenyut: ruang tengah tidak
            // digambar ulang tiap bingkai.
            pulse: terrace ? pulse(time) : 1,
            colors: c,
          ),
        ),
      );
    }
    return IgnorePointer(
      child: Stack(
        children: [
          if (!terrace) label(wallLabel, _ZoneLabel(l.zoneWall)),
          label(floorLabel, _ZoneLabel(l.zoneFloor)),
          label(
            terrace ? terraceDoorLabel : livingDoorLabel,
            _ZoneLabel(
              l.zoneDoorPath,
              color: c.roomDoorPathChip,
              icon: KoIcons.noEntry,
            ),
          ),
          if (terrace) ...[
            centered(hammockLabel, _ZoneLabel(l.zoneHangHammock)),
            centered(lampLabel, _ZoneLabel(l.zoneHangLamp, outlined: true)),
          ],
        ],
      ),
    );
  }
}

class _ZonePainter extends CustomPainter {
  _ZonePainter({
    required this.sx,
    required this.sy,
    required this.wall,
    required this.floor,
    required this.doors,
    required this.hang,
    required this.pulse,
    required this.colors,
  });

  final double sx;
  final double sy;
  final Rect? wall;
  final List<Offset> floor;
  final List<List<Offset>> doors;
  final bool hang;
  final double pulse;
  final KoColors colors;

  // Garis desain: area `6 5` 2 px, jalur pintu `7 5` 2,4 px, arsir 4 px tiap
  // 10 px miring 45°, cincin 2,6 px (G3 `4 3`), garis G1–G2 `3 3` 2 px.
  static const _areaDash = [6.0, 5.0];
  static const _doorDash = [7.0, 5.0];
  static const _lampDash = [4.0, 3.0];
  static const _lineDash = [3.0, 3.0];

  static Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);

  static Path _dashed(Path source, List<double> dash) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var d = 0.0;
      var i = 0;
      while (d < metric.length) {
        final len = dash[i % dash.length];
        if (i.isEven) out.addPath(metric.extractPath(d, d + len), Offset.zero);
        d += len;
        i++;
      }
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(sx, sy);
    Paint stroke(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()..color = colors.roomZoneFill;
    final wall = this.wall;
    if (wall != null) {
      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            wall,
            const Radius.circular(ZoneGuides.wallRadius),
          ),
        );
      canvas
        ..drawPath(path, fill)
        ..drawPath(_dashed(path, _areaDash), stroke(colors.roomZoneLine, 2));
    }
    final floorPath = _polygon(floor);
    canvas
      ..drawPath(floorPath, Paint()..color = colors.roomFloorZoneFill)
      ..drawPath(_dashed(floorPath, _areaDash), stroke(colors.roomZoneLine, 2));

    final hatch = Paint()
      ..color = colors.roomDoorPathHatch
      ..strokeWidth = 4;
    for (final door in doors) {
      final doorPath = _polygon(door);
      canvas
        ..save()
        ..clipPath(doorPath)
        ..drawPath(doorPath, Paint()..color = colors.roomDoorPathFill);
      final bounds = doorPath.getBounds();
      // Garis miring 45° tiap 10 px (pola `rotate(45)` desain).
      for (
        var x = bounds.left - bounds.height;
        x < bounds.right + bounds.height;
        x += 10 * 1.4142
      ) {
        canvas.drawLine(
          Offset(x, bounds.bottom),
          Offset(x + bounds.height, bounds.top),
          hatch,
        );
      }
      canvas
        ..restore()
        ..drawPath(
          _dashed(doorPath, _doorDash),
          stroke(colors.orangeDeep, 2.4),
        );
    }

    if (hang) {
      final ringFill = Paint()
        ..color = colors.roomHangFill.withValues(
          alpha: colors.roomHangFill.a * pulse,
        );
      final ring = stroke(colors.waterDeep.withValues(alpha: pulse), 2.6);
      for (final g in ZoneGuides.hangHammock) {
        canvas
          ..drawCircle(g, ZoneGuides.hangRadius, ringFill)
          ..drawCircle(g, ZoneGuides.hangRadius, ring);
      }
      final lamp = Path()
        ..addOval(
          Rect.fromCircle(
            center: ZoneGuides.hangLamp,
            radius: ZoneGuides.hangRadius,
          ),
        );
      canvas
        ..drawPath(lamp, ringFill)
        ..drawPath(_dashed(lamp, _lampDash), ring);
      final line = Path()
        ..moveTo(ZoneGuides.hangHammock[0].dx, ZoneGuides.hangLineY)
        ..lineTo(ZoneGuides.hangHammock[1].dx, ZoneGuides.hangLineY);
      canvas.drawPath(_dashed(line, _lineDash), stroke(colors.waterDeep, 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ZonePainter old) =>
      old.sx != sx ||
      old.sy != sy ||
      old.hang != hang ||
      old.pulse != pulse ||
      old.wall != wall ||
      old.colors != colors;
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel(this.text, {this.color, this.icon, this.outlined = false});

  final String text;

  /// Warna chip; null = biru zona.
  final Color? color;
  final KoIconData? icon;

  /// Chip terang bergaris biru ("Lampu bulan").
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final ink = outlined ? c.waterDeep : c.onWaterDeep;
    final icon = this.icon;
    return Container(
      height: s.roomZoneChip,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: outlined ? c.surface : (color ?? c.waterDeep),
        borderRadius: BorderRadius.circular(context.koRadius.pill),
        border: outlined
            ? Border.all(color: c.waterDeep, width: s.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            KoIcon(icon, size: s.iconMicro, color: ink),
            SizedBox(width: space.s4),
          ],
          Text(
            text,
            maxLines: 1,
            style: context.koType.tagSmall.copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}

/// Garis putus-putus dan gagang di sekeliling barang saat menghias.
class DecorOutline extends StatelessWidget {
  const DecorOutline({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final radius = context.koRadius.tag;
    final out = -s.roomItemOutline;
    // Desain: gagang 24 px di kanan -16, atas -16.
    final grip = -(s.roomGrip - s.roomItemOutline * 2);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: out,
          top: out,
          right: out,
          bottom: out,
          child: KoDashedBorder(
            color: c.waterDeep,
            radius: radius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.roomItemDecorFill,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
        Positioned(
          right: grip,
          top: grip,
          child: Container(
            width: s.roomGrip,
            height: s.roomGrip,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.waterDeep,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: s.border),
            ),
            child: KoIcon(
              KoIcons.grip,
              size: s.iconMicro,
              color: c.onWaterDeep,
            ),
          ),
        ),
      ],
    );
  }
}

/// Baki Gudang di panel bawah saat menghias (`BakiGudang.dc.html`): barang
/// yang dimiliki tapi tidak ditaruh; ketuk untuk menaruhnya di posisi
/// bawaan. Barang yang dilepas di atas baki masuk ke Gudang.
///
/// Barang [dimmed] tidak bisa dipasang di ruangan ini (barang dinding di
/// teras): diredupkan, dan ketukannya memanggil [onDimmed]. [selected]
/// diberi garis (slot yang keterangannya sedang tampil). Kedua callback
/// menerima kotak slot di layar, untuk keterangan di atasnya.
class StorageTray extends StatelessWidget {
  const StorageTray({
    super.key,
    required this.items,
    required this.compact,
    required this.onPlace,
    this.dimmed = const {},
    this.selected,
    this.onDimmed,
  });

  final List<RoomItemId> items;
  final bool compact;
  final void Function(RoomItemId id, Rect slot) onPlace;
  final Set<RoomItemId> dimmed;
  final RoomItemId? selected;
  final void Function(RoomItemId id, Rect slot)? onDimmed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final radius = context.koRadius.slot;
    return Semantics(
      container: true,
      label: l.storageLabel,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          space.s14,
          space.s12,
          space.s14,
          space.s14,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.primary),
          border: Border.all(color: c.line, width: s.border),
          boxShadow: context.koShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                KoIcon(KoIcons.storage, size: s.icon, color: c.inkSoft),
                SizedBox(width: space.s8),
                Text(l.storage, style: t.chip.copyWith(color: c.ink)),
                SizedBox(width: space.s8),
                Container(
                  height: s.roomZoneChip,
                  padding: EdgeInsets.symmetric(horizontal: space.s8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.tabTrack,
                    borderRadius: BorderRadius.circular(context.koRadius.pill),
                  ),
                  child: Text(
                    l.storageCount(items.length),
                    maxLines: 1,
                    style: t.tagSmall.copyWith(color: c.ink),
                  ),
                ),
                SizedBox(width: space.s8),
                Expanded(
                  child: Text(
                    l.storageTapHint,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.cardTextSmall.copyWith(color: c.inkSoft),
                  ),
                ),
              ],
            ),
            SizedBox(height: space.s10),
            Expanded(
              child: items.isEmpty
                  ? KoDashedBorder(
                      color: c.line,
                      radius: radius,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: space.s12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l.storageEmpty,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: t.cardBody.copyWith(color: c.inkSoft),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(width: space.s10),
                      itemBuilder: (context, i) => _TraySlot(
                        id: items[i],
                        compact: compact,
                        dimmed: dimmed.contains(items[i]),
                        selected: selected == items[i],
                        onPressed: (slot) => dimmed.contains(items[i])
                            ? onDimmed?.call(items[i], slot)
                            : onPlace(items[i], slot),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraySlot extends StatelessWidget {
  /// Tinggi baris nama barang (`BakiGudang.dc.html`: `line-height: 1.15`).
  static const double nameHeight = 1.15;

  const _TraySlot({
    required this.id,
    required this.compact,
    required this.dimmed,
    required this.selected,
    required this.onPressed,
  });

  final RoomItemId id;
  final bool compact;
  final bool dimmed;
  final bool selected;
  final void Function(Rect slot) onPressed;

  /// Slot redup: opasitas 0,42 dan `grayscale(0.5)` desain.
  static const dimOpacity = 0.42;
  static const _grayscale = ColorFilter.matrix([
    0.6063, 0.3576, 0.0361, 0, 0, //
    0.1063, 0.8576, 0.0361, 0, 0, //
    0.1063, 0.3576, 0.5361, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final name = roomItemName(l, id);
    final width = compact ? s.roomTraySlotWidthCompact : s.roomTraySlotWidth;
    final height = compact ? s.roomTraySlotHeightCompact : s.roomTraySlotHeight;
    void tap() {
      final box = context.findRenderObject() as RenderBox?;
      onPressed(
        box == null || !box.hasSize
            ? Rect.zero
            : box.localToGlobal(Offset.zero) & box.size,
      );
    }

    Widget slot = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.floor,
                borderRadius: BorderRadius.circular(context.koRadius.slot),
                border: Border.all(color: c.lineDeep, width: s.border),
                boxShadow: KoShadow.solid(
                  c.lineDeep,
                  context.koShadow.pressIcon,
                ),
              ),
              child: RoomItemView(
                id: id,
                box:
                    Size(s.roomTrayArtWidth, s.roomTrayArtHeight) *
                    (height / s.roomTraySlotHeight),
              ),
            ),
            SizedBox(height: space.s4),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: context.koType.tagTiny.copyWith(
                color: c.ink,
                height: nameHeight,
              ),
            ),
          ],
        ),
      ),
    );
    if (dimmed) {
      slot = Opacity(
        opacity: dimOpacity,
        child: ColorFiltered(colorFilter: _grayscale, child: slot),
      );
    }
    if (selected) {
      slot = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.koRadius.slot),
          border: Border.all(
            color: c.roomTraySelect,
            width: s.roomTraySelect,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: slot,
      );
    }
    return Semantics(
      button: true,
      label: dimmed ? l.storageLivingOnly(name) : l.storagePlaceLabel(name),
      excludeSemantics: true,
      onTap: tap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: slot,
      ),
    );
  }
}

/// Keterangan gelap di atas slot Gudang (`Teras.dc.html` keadaan `hias`):
/// "Bisa dipasang di ruang tengah" atau "Gantung di balok atap", dengan
/// panah ke slot di [arrowX] (dari tepi kiri keterangan).
class TrayTip extends StatelessWidget {
  const TrayTip({super.key, required this.text, required this.arrowX});

  final String text;
  final double arrowX;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final tail = s.roomBubbleTail;
    return Semantics(
      liveRegion: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: arrowX - tail / 2,
            bottom: -tail / 2,
            child: Transform.rotate(
              angle: math.pi / 4,
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
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: space.s12,
              vertical: space.s8,
            ),
            decoration: BoxDecoration(
              color: c.ink,
              borderRadius: BorderRadius.circular(context.koRadius.control),
              boxShadow: context.koShadow.card,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: context.koType.cardBodyStrong.copyWith(color: c.cream),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
