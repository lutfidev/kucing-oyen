import 'package:flutter/material.dart';

import '../../game/model/home_items.dart';
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

/// Area dinding dan lantai bergaris putus-putus saat menghias, dengan
/// labelnya (`Kamar.dc.html`, keadaan `hias`).
class ZoneGuides extends StatelessWidget {
  const ZoneGuides({super.key, required this.geo});

  final RoomGeometry geo;

  // Letak desain 390×844.
  static const wall = Rect.fromLTWH(10, 104, 370, 302);
  static const floor = Rect.fromLTWH(10, 432, 370, 214);
  static const wallLabel = Offset(20, 376);
  static const floorLabel = Offset(20, 440);

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final l = context.l10n;
    final radius = context.koRadius.control;
    Widget area(Rect design) => Positioned.fromRect(
      rect: geo.fromDesign(design, stretch: true),
      child: KoDashedBorder(
        color: c.roomZoneLine,
        radius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.roomZoneFill,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
    Widget label(Offset design, String text) {
      final at = geo.fromDesign(design & Size.zero).topLeft;
      return Positioned(left: at.dx, top: at.dy, child: _ZoneLabel(text));
    }

    return IgnorePointer(
      child: Stack(
        children: [
          area(wall),
          area(floor),
          label(wallLabel, l.zoneWall),
          label(floorLabel, l.zoneFloor),
        ],
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Container(
      height: context.koSize.roomZoneChip,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.waterDeep,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: context.koType.tagSmall.copyWith(color: c.onWaterDeep),
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
class StorageTray extends StatelessWidget {
  const StorageTray({
    super.key,
    required this.items,
    required this.compact,
    required this.onPlace,
  });

  final List<RoomItemId> items;
  final bool compact;
  final void Function(RoomItemId id) onPlace;

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
                        onPressed: () => onPlace(items[i]),
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
  const _TraySlot({
    required this.id,
    required this.compact,
    required this.onPressed,
  });

  final RoomItemId id;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final name = roomItemName(l, id);
    final width = compact ? s.roomTraySlotWidthCompact : s.roomTraySlotWidth;
    final height = compact ? s.roomTraySlotHeightCompact : s.roomTraySlotHeight;
    return Semantics(
      button: true,
      label: l.storagePlaceLabel(name),
      excludeSemantics: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: FittedBox(
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
                  style: context.koType.tagTiny.copyWith(color: c.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
