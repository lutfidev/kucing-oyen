import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../game/sim/item.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Jari mulai menyeret [item] dari slot baki di posisi layar [global].
/// Mengembalikan penerima seretan, atau null kalau ditolak.
typedef TrayDragStart = Drag? Function(Item item, Offset global);

/// Baki di bawah papan: label "Benda", satu slot per jenis benda dengan
/// angka sisa, petunjuk "Taruh di petak yang menyala", dan tombol kosongkan
/// papan.
///
/// Slot yang angkanya 0 tidak bisa diseret. Kalau tempat kurang, slot
/// mengecil dan petunjuk disembunyikan. Pembaca layar bisa memilih benda
/// tanpa seret ([onSelect]), lalu menaruhnya lewat petak papan.
class TrayPanel extends StatelessWidget {
  const TrayPanel({
    super.key,
    required this.counts,
    required this.onDragStart,
    required this.onClear,
    this.dragging,
    this.slotKeys = const {},
    this.selected,
    this.onSelect,
  });

  /// Angka yang tampil di tiap slot, urut seperti di baki level.
  final Map<Item, int> counts;

  /// Benda yang sedang diseret dari baki (slotnya diberi label "sedang
  /// diseret").
  final Item? dragging;

  final TrayDragStart onDragStart;

  /// Kosongkan papan; null = nonaktif.
  final VoidCallback? onClear;

  /// Kunci slot per benda, untuk mengukur letaknya (sorotan tutorial).
  final Map<Item, GlobalKey> slotKeys;

  /// Benda baki yang sedang dipilih pembaca layar.
  final Item? selected;

  /// Ketuk dua kali di slot (pembaca layar): pilih atau batal pilih.
  final ValueChanged<Item>? onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final gap = space.s12;

    return TrayBox(
      shadow: true,
      padding: EdgeInsetsDirectional.only(start: space.s16, end: space.s12),
      child: Row(
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              context.l10n.trayLabel.toUpperCase(),
              maxLines: 1,
              style: t.overline.copyWith(color: c.inkSoft),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final n = counts.length;
                final slotsWidth = n * s.slot + (n - 1) * gap;
                final Widget slots = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final MapEntry(key: item, value: count)
                        in counts.entries) ...[
                      if (item != counts.keys.first) SizedBox(width: gap),
                      _TrayItem(
                        key: slotKeys[item],
                        item: item,
                        count: count,
                        dragging: item == dragging,
                        selected: item == selected,
                        onDragStart: onDragStart,
                        onSelect: onSelect,
                      ),
                    ],
                  ],
                );
                if (slotsWidth > constraints.maxWidth) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FittedBox(fit: BoxFit.scaleDown, child: slots),
                  );
                }
                final hintWidth = constraints.maxWidth - slotsWidth - gap;
                final showHint =
                    hintWidth >=
                    MediaQuery.textScalerOf(context).scale(s.trayHint);
                return Row(
                  children: [
                    slots,
                    if (showHint) ...[
                      SizedBox(width: gap),
                      const Expanded(child: _TrayHint()),
                    ],
                  ],
                );
              },
            ),
          ),
          SizedBox(width: gap),
          KoIconButton(
            icon: KoIcons.reset,
            semanticLabel: context.l10n.clearBoard,
            tone: KoIconButtonTone.floor,
            iconSize: s.iconSmall,
            // Bunyi benda kembali menggantikan tap.
            silent: true,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _TrayHint extends StatelessWidget {
  const _TrayHint();

  @override
  Widget build(BuildContext context) {
    final t = context.koType;
    final space = context.koSpace;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: space.s4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.trayHintTop, maxLines: 1, style: t.labelSmall),
            SizedBox(height: space.s2),
            Text(
              context.l10n.trayHintBottom,
              maxLines: 1,
              style: t.caption.copyWith(color: context.koColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu slot baki yang bisa diseret. Seretan langsung dimulai saat jari
/// menempel, sama seperti benda di papan.
class _TrayItem extends StatelessWidget {
  const _TrayItem({
    super.key,
    required this.item,
    required this.count,
    required this.dragging,
    required this.selected,
    required this.onDragStart,
    required this.onSelect,
  });

  final Item item;
  final int count;
  final bool dragging;
  final bool selected;
  final TrayDragStart onDragStart;
  final ValueChanged<Item>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = itemName(l, item);
    return RawGestureDetector(
      gestures: {
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              ImmediateMultiDragGestureRecognizer
            >(
              ImmediateMultiDragGestureRecognizer.new,
              (recognizer) =>
                  recognizer.onStart = (global) =>
                      count > 0 ? onDragStart(item, global) : null,
            ),
      },
      child: TraySlot(
        count: count,
        semanticLabel: dragging
            ? l.traySlotDragging(name, count)
            : selected
            ? l.traySlotSelected(name, count)
            : l.traySlotLabel(name, count),
        selected: selected,
        onSemanticTap: switch (onSelect) {
          final select? when count > 0 || selected => () => select(item),
          _ => null,
        },
        semanticTapHint: selected
            ? l.traySlotUnselectHint
            : l.traySlotSelectHint,
        child: ItemArtView(item, ghost: count == 0),
      ),
    );
  }
}

/// Panel baki tanpa benda: teks kecil pudar di tengah ("Level ini belum
/// butuh benda.").
class TrayMessage extends StatelessWidget {
  const TrayMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.koType;
    final space = context.koSpace;
    return TrayBox(
      padding: EdgeInsets.symmetric(horizontal: space.s16),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: t.bodySmall.copyWith(color: context.koColors.inkSoft),
        ),
      ),
    );
  }
}

/// Kotak panel baki 88 px: permukaan krem bergaris, sudut 22.
class TrayBox extends StatelessWidget {
  const TrayBox({
    super.key,
    required this.child,
    this.padding,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Bayangan lembut (baki berisi benda di desain 03; baki kosong di desain
  /// 11 tanpa bayangan).
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return Container(
      height: s.tray,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(context.koRadius.tray),
        border: Border.all(color: c.line, width: s.border),
        boxShadow: shadow ? context.koShadow.tray : null,
      ),
      child: child,
    );
  }
}
