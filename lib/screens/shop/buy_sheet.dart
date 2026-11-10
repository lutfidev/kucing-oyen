import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/sounds.dart';
import '../../game/render/v2/art_pack.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/catalog_art.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/v2/ui_sheet.dart';
import '../room/home_labels.dart';

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

Future<void> showBuySheet(
  BuildContext context, {
  required BuyTarget target,
  required ProgressController progress,
  KittyId previewKitty = KittyId.oyen,
  void Function(AccessoryId id)? onWear,
  ArtPack? pack,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: KoUi.paper,
  barrierColor: KoUi.scrim,
  barrierLabel: context.l10n.close,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(duration: KoUi.tabTime),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(KoUi.sheetRadius)),
  ),
  builder: (_) => _BuySheet(
    target: target,
    progress: progress,
    previewKitty: previewKitty,
    onWear: onWear,
    pack: pack,
  ),
);

class _BuySheet extends StatefulWidget {
  const _BuySheet({
    required this.target,
    required this.progress,
    required this.previewKitty,
    required this.onWear,
    this.pack,
  });
  final BuyTarget target;
  final ProgressController progress;
  final KittyId previewKitty;
  final void Function(AccessoryId id)? onWear;
  final ArtPack? pack;
  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  bool attempted = false, paying = false;
  late final Future<ArtPack> art = widget.pack == null
      ? ArtPack.load()
      : Future.value(widget.pack);
  ProgressController get c => widget.progress;
  BuyTarget get target => widget.target;
  bool get owned => switch (target) {
    BuyItem(:final id) => c.home.room.owns(id),
    BuyKitty(:final id) => c.home.ownsKitty(id),
    BuyAccessory(:final id) => c.home.closet.owns(id),
  };
  HomeArea? get destination => switch (target) {
    BuyItem(:final id) =>
      (owned ? c.household.areas.placed[id] : c.itemPurchaseSlot(id))?.area,
    BuyKitty(:final id) =>
      owned ? c.household.routine.findArea(id) : c.kittyAdoptionArea(id),
    _ => null,
  };
  Future<void> buy() async {
    if (paying || owned || c.householdBusy || c.householdSaveFailed) return;
    setState(() {
      paying = true;
      attempted = true;
    });
    final ok = await switch (target) {
      BuyItem(:final id) => c.buyItem(id),
      BuyKitty(:final id) => c.buyKitty(id),
      BuyAccessory(:final id) => c.buyAccessory(id),
    };
    if (!mounted) return;
    if (ok) AudioScope.maybeRead(context)?.play(GameSound.buy);
    setState(() => paying = false);
  }

  Future<void> seeHome() async {
    final area = destination;
    if (target case BuyKitty(:final id)) {
      c.selectHomeKitty(id);
    }
    if (area != null &&
        area != c.household.lastArea &&
        !await c.setHomeArea(area)) {
      return;
    }
    if (!mounted) return;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: KoUi.theme(),
    child: AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final l = context.l10n;
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
        final success = attempted && owned;
        final blocked = paying || c.householdBusy || c.householdSaveFailed;
        final short = c.coins < target.price;
        final area = destination;
        return UiSheet(
          title: success ? l.buySuccessOverline : name,
          closeLabel: l.close,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<ArtPack>(
                future: art,
                builder: (context, snapshot) {
                  if (snapshot.data case final pack?) {
                    return Center(
                      child: CatalogArt(
                        pack: pack,
                        size: 160,
                        item: target is BuyItem ? (target as BuyItem).id : null,
                        kitty: target is BuyKitty
                            ? (target as BuyKitty).id
                            : widget.previewKitty,
                        accessory: target is BuyAccessory
                            ? (target as BuyAccessory).id
                            : null,
                      ),
                    );
                  }
                  return Text(
                    snapshot.hasError ? l.homeLoadFailed : l.homeLoading,
                    style: KoUi.small,
                  );
                },
              ),
              Text(
                success
                    ? switch (target) {
                        BuyItem() => l.buySuccessItem(name),
                        BuyKitty() => l.buySuccessKitty(name),
                        BuyAccessory() => l.buySuccessAccessory(name),
                      }
                    : name,
                style: KoUi.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KoUi.s8),
              Text(description, style: KoUi.body),
              const SizedBox(height: KoUi.s12),
              if (target is! BuyAccessory)
                Text(
                  area == null
                      ? l.shopStored
                      : l.shopDestination(homeAreaLabel(l, area)),
                  style: KoUi.label,
                ),
              if (!owned && !short)
                Text(
                  l.shopBalanceAfter(
                    (c.coins - target.price).clamp(0, c.coins),
                  ),
                  style: KoUi.small,
                ),
              if (!owned && short) Text(l.buyNotEnoughHelp, style: KoUi.small),
              if (owned && !attempted)
                Text(l.shopAlreadyOwned, style: KoUi.label),
              if (target is BuyAccessory)
                Text(l.buyAccessoryInfo, style: KoUi.small),
              if (c.householdSaveFailed) ...[
                const SizedBox(height: KoUi.s12),
                Semantics(
                  liveRegion: true,
                  child: Text(l.homeSaveFailed, style: KoUi.body),
                ),
                UiButton(
                  key: const ValueKey('buy-retry'),
                  label: l.homeRetry,
                  loading: c.householdBusy,
                  onPressed: () => c.retrySaves(),
                ),
              ],
            ],
          ),
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (owned)
                target is BuyAccessory
                    ? UiButton(
                        key: const ValueKey('buy-wear'),
                        homeStyle: true,
                        label: l.buyWearOn(kittyName(l, widget.previewKitty)),
                        onPressed: blocked || widget.onWear == null
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                widget.onWear!((target as BuyAccessory).id);
                              },
                      )
                    : UiButton(
                        key: const ValueKey('buy-room'),
                        homeStyle: true,
                        label: l.buySeeRoom,
                        onPressed: blocked ? null : seeHome,
                      )
              else
                UiButton(
                  key: const ValueKey('buy-confirm'),
                  homeStyle: true,
                  label: short
                      ? l.notEnoughCoins(target.price - c.coins)
                      : l.buyPay(target.price),
                  loading: paying || c.householdBusy,
                  onPressed: blocked || short ? null : buy,
                ),
              const SizedBox(height: KoUi.s8),
              UiButton(
                key: const ValueKey('buy-close'),
                homeStyle: true,
                label: success ? l.buyAgain : l.buyLater,
                kind: UiButtonKind.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    ),
  );
}
