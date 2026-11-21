import 'package:flutter/material.dart';

import '../../game/model/house.dart';
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
