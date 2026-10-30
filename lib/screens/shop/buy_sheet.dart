import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/sounds.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Yang sedang dibeli di sheet konfirmasi (`SheetBeli.dc.html`).
sealed class BuyTarget {
  const BuyTarget();

  int get price;
}

class BuyItem extends BuyTarget {
  const BuyItem(this.id);

  final RoomItemId id;

  @override
  int get price => roomItemOf(id).price;
}

class BuyKitty extends BuyTarget {
  const BuyKitty(this.id);

  final KittyId id;

  @override
  int get price => kittyOf(id).price;
}

class BuyAccessory extends BuyTarget {
  const BuyAccessory(this.id);

  final AccessoryId id;

  @override
  int get price => accessoryOf(id).price;
}

/// Sheet konfirmasi beli: gambar besar, nama, deskripsi, lalu tombol beli,
/// "Koin kurang · N", atau — sesudah berhasil — "Lihat di kamar" atau
/// "Pakai di `<kucing>`". [previewKitty] = kucing yang memakai aksesorisnya.
/// [onWear] dipanggil kalau pemain memakai aksesoris yang baru dibeli.
Future<void> showBuySheet(
  BuildContext context, {
  required BuyTarget target,
  required ProgressController progress,
  KittyId previewKitty = KittyId.oyen,
  void Function(AccessoryId id)? onWear,
}) {
  final l = context.l10n;
  return showKoSheet(
    context,
    barrierLabel: l.close,
    builder: (context, onClose) => _BuySheet(
      target: target,
      progress: progress,
      previewKitty: previewKitty,
      onWear: onWear,
      onClose: onClose,
    ),
  );
}

class _BuySheet extends StatefulWidget {
  const _BuySheet({
    required this.target,
    required this.progress,
    required this.previewKitty,
    required this.onWear,
    required this.onClose,
  });

  final BuyTarget target;
  final ProgressController progress;
  final KittyId previewKitty;
  final void Function(AccessoryId id)? onWear;
  final VoidCallback onClose;

  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  bool _bought = false;
  bool _paying = false;

  Future<void> _buy() async {
    if (_paying || _bought) return;
    setState(() => _paying = true);
    final progress = widget.progress;
    final ok = await switch (widget.target) {
      BuyItem(:final id) => progress.buyItem(id),
      BuyKitty(:final id) => progress.buyKitty(id),
      BuyAccessory(:final id) => progress.buyAccessory(id),
    };
    if (!mounted) return;
    if (ok) AudioScope.maybeRead(context)?.play(GameSound.buy);
    setState(() {
      _paying = false;
      _bought = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.koColors;
    final space = context.koSpace;
    final target = widget.target;
    final previewName = kittyName(l, widget.previewKitty);
    final name = switch (target) {
      BuyItem(:final id) => roomItemName(l, id),
      BuyKitty(:final id) => kittyName(l, id),
      BuyAccessory(:final id) => accessoryName(l, id),
    };
    final description = switch (target) {
      BuyItem(:final id) => roomItemDesc(l, id),
      BuyKitty(:final id) => kittyDesc(l, id),
      BuyAccessory(:final id) => accessoryDesc(l, id),
    };
    final (title, body) = _bought
        ? switch (target) {
            BuyItem() => (l.buySuccessItem(name), l.buySuccessItemBody),
            BuyKitty() => (l.buySuccessKitty(name), l.buySuccessKittyBody),
            BuyAccessory() => (
              l.buySuccessAccessory(name),
              l.buySuccessAccessoryBody(previewName),
            ),
          }
        : (name, description);
    final short = widget.progress.coins < target.price;

    return KoSheet(
      label: _bought ? title : l.buySheetLabel(name),
      onClose: widget.onClose,
      header: const SizedBox.shrink(),
      children: [
        _Art(
          target: target,
          previewKitty: widget.previewKitty,
          bought: _bought,
        ),
        SizedBox(height: space.s16),
        if (_bought) ...[
          Text(
            l.buySuccessOverline,
            textAlign: TextAlign.center,
            style: context.koType.overlineLarge.copyWith(color: c.successText),
          ),
          SizedBox(height: space.s8),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.koType.title.copyWith(color: c.ink),
        ),
        SizedBox(height: space.s8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.koType.paragraph.copyWith(color: c.inkSoft),
        ),
        SizedBox(height: space.s16),
        if (target is BuyAccessory && !_bought) ...[
          _Info(l.buyAccessoryInfo),
          SizedBox(height: space.s16),
        ],
        if (_bought)
          switch (target) {
            BuyAccessory(:final id) => KoButton(
              key: const ValueKey('buy-wear'),
              label: l.buyWearOn(previewName),
              kind: KoButtonKind.success,
              icon: KoIcons.check,
              onPressed: () {
                widget.onClose();
                widget.onWear?.call(id);
              },
            ),
            _ => KoButton(
              key: const ValueKey('buy-room'),
              label: l.buySeeRoom,
              kind: KoButtonKind.success,
              icon: KoIcons.house,
              onPressed: () {
                widget.onClose();
                context.go(AppRoutes.home);
              },
            ),
          }
        else if (short) ...[
          KoButton(
            label: l.notEnoughCoins(target.price - widget.progress.coins),
            icon: KoIcons.lock,
            onPressed: null,
          ),
          SizedBox(height: space.s8),
          Text(
            l.buyNotEnoughHelp,
            textAlign: TextAlign.center,
            style: context.koType.controlLabel.copyWith(color: c.inkSoft),
          ),
        ] else
          KoButton(
            key: const ValueKey('buy-confirm'),
            label: l.buyPay(target.price),
            icon: KoIcons.plus,
            onPressed: _paying ? null : _buy,
          ),
        SizedBox(height: space.s12),
        SheetButton(
          key: const ValueKey('buy-close'),
          label: _bought ? l.buyAgain : l.buyLater,
          icon: const SizedBox.shrink(),
          color: c.surface,
          line: c.line,
          edge: c.lineDeep,
          onPressed: widget.onClose,
        ),
      ],
    );
  }
}

/// Catatan hijau "milikmu selamanya" di sheet aksesoris.
class _Info extends StatelessWidget {
  const _Info(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: space.s12, vertical: space.s6),
      decoration: BoxDecoration(
        color: c.ownedChip,
        borderRadius: BorderRadius.circular(context.koRadius.statCompact),
      ),
      child: Row(
        children: [
          KoIcon(
            KoIcons.shield,
            size: context.koSize.iconMicro,
            color: c.onSuccess,
          ),
          SizedBox(width: space.s6),
          Expanded(
            child: Text(
              text,
              style: context.koType.cardTextSmall.copyWith(color: c.onSuccess),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak ilustrasi sheet: barang, kucing, atau kucing beraksesoris; latar
/// hijau sesudah pembelian berhasil.
class _Art extends StatelessWidget {
  const _Art({
    required this.target,
    required this.previewKitty,
    required this.bought,
  });

  final BuyTarget target;
  final KittyId previewKitty;
  final bool bought;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final pose = bought ? KittyPose.happy : KittyPose.idle;
    return Container(
      height: s.buyWell,
      decoration: BoxDecoration(
        color: bought ? c.ownedChip : c.floor,
        borderRadius: BorderRadius.circular(context.koRadius.art),
      ),
      alignment: Alignment.center,
      child: switch (target) {
        BuyItem(:final id) => RoomItemView(
          id: id,
          box: Size(s.buyItemArtWidth, s.buyItemArtHeight),
        ),
        BuyKitty(:final id) => KittyView(
          look: KittyLook(kitty: id, pose: pose),
          size: s.buyKittyArt,
        ),
        BuyAccessory(:final id) => KittyView(
          look: KittyLook(kitty: previewKitty, pose: pose, accessory: id),
          size: s.buyAccessoryArt,
        ),
      },
    );
  }
}
