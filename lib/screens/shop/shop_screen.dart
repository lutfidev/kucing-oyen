import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/snacks.dart';
import '../../game/model/sounds.dart';
import '../../game/render/v2/art_pack.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/catalog_art.dart';
import '../../widgets/v2/snack_art.dart';
import '../../widgets/v2/ui_button.dart';
import '../coins/coin_sheet.dart';
import '../room/home_labels.dart';
import 'buy_sheet.dart';
import 'shop_tab.dart';
export 'shop_tab.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.initialTab = ShopTab.items, this.loadArt});
  final ShopTab initialTab;
  final Future<ArtPack> Function()? loadArt;
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late ShopTab tab = widget.initialTab;
  late Future<ArtPack> art = (widget.loadArt ?? ArtPack.load)();

  KittyId preview = KittyId.oyen;
  AccessoryId selected = accessories.first.id;
  String? flash;
  Timer? timer;
  ProgressController get c => ProgressScope.of(context);
  bool get busy => c.householdBusy || c.householdSaveFailed;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void message(String text) {
    timer?.cancel();
    setState(() => flash = text);
    timer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => flash = null);
    });
  }

  Future<void> wear({required bool on}) async {
    final ok = await c.wearAccessory(preview, on ? selected : null);
    if (!mounted || !ok) return;
    if (on) AudioScope.maybeRead(context)?.play(GameSound.wear);
    message(on ? context.l10n.shopFlashNice : context.l10n.shopFlashRemoved);
  }

  Future<void> buySnack(SnackId id) async {
    if (busy) return;
    final ok = await c.buySnack(id);
    if (!mounted || !ok) return;
    AudioScope.maybeRead(context)?.play(GameSound.buy);
    message(context.l10n.shopFlashSpent(snackOf(id).price));
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: KoUi.theme(),
    child: Builder(
      builder: (context) {
        final l = context.l10n;
        return Scaffold(
          backgroundColor: KoUi.homeBackground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(KoUi.s16),
                  child: Row(
                    children: [
                      UiButton(
                        homeStyle: true,
                        label: '',
                        semanticLabel: l.backToHome,
                        compact: true,
                        icon: Icons.arrow_back_rounded,
                        kind: UiButtonKind.secondary,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                      const SizedBox(width: KoUi.s8),
                      Expanded(
                        child: Text(
                          l.shop,
                          textAlign: TextAlign.center,
                          style: KoUi.title,
                        ),
                      ),
                      const SizedBox(width: KoUi.s8),
                      Flexible(
                        child: UiButton(
                          homeStyle: true,
                          label: '${c.coins}',
                          semanticLabel:
                              '${l.coinsAmount(c.coins)}, ${l.coinChipAdd}',
                          icon: Icons.pets_rounded,
                          kind: UiButtonKind.secondary,
                          onPressed: () => showCoinSheet(context, c),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: KoUi.s16),
                  child: Row(
                    children: [
                      for (final t in ShopTab.values)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: KoUi.s8,
                            bottom: KoUi.s8,
                          ),
                          child: UiButton(
                            key: ValueKey('shop-tab-${t.name}'),
                            homeStyle: true,
                            selected: t == tab,
                            kind: UiButtonKind.secondary,
                            label: switch (t) {
                              ShopTab.items => l.shopTabItems,
                              ShopTab.kitties => l.shopTabKitties,
                              ShopTab.accessories => l.shopTabAccessories,
                              ShopTab.snacks => l.shopTabSnacks,
                            },
                            onPressed: () => setState(() {
                              tab = t;
                              flash = null;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                if (c.householdSaveFailed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: KoUi.s16),
                    child: Column(
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Text(l.homeSaveFailed, style: KoUi.small),
                        ),
                        UiButton(
                          label: l.homeRetry,
                          loading: c.householdBusy,
                          onPressed: () => c.retrySaves(),
                        ),
                      ],
                    ),
                  ),
                if (flash != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(flash!, style: KoUi.label),
                  ),
                Expanded(
                  child: FutureBuilder<ArtPack>(
                    future: art,
                    builder: (context, snapshot) {
                      if (snapshot.data case final pack?) {
                        return SingleChildScrollView(
                          key: ValueKey(tab),
                          padding: const EdgeInsets.all(KoUi.s16),
                          child: switch (tab) {
                            ShopTab.items => items(pack),
                            ShopTab.kitties => cats(pack),
                            ShopTab.accessories => accessoryPanel(pack),
                            ShopTab.snacks => snacksPanel(),
                          },
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.hasError
                                  ? l.homeLoadFailed
                                  : l.homeLoading,
                              style: KoUi.body,
                            ),
                            if (snapshot.hasError)
                              UiButton(
                                label: l.homeRetry,
                                onPressed: () =>
                                    setState(() => art = ArtPack.load()),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  Widget card({
    required String name,
    required Widget art,
    required Widget child,
  }) => Container(
    decoration: KoUi.homeCard(),
    padding: const EdgeInsets.all(KoUi.s12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: art),
        Text(name, style: KoUi.heading),
        const SizedBox(height: KoUi.s8),
        child,
      ],
    ),
  );
  Widget grid(List<Widget> children) => LayoutBuilder(
    builder: (context, box) {
      final columns =
          box.maxWidth >= 320 && MediaQuery.textScalerOf(context).scale(14) < 17
          ? 2
          : 1;
      return Wrap(
        spacing: KoUi.s12,
        runSpacing: KoUi.s12,
        children: [
          for (final child in children)
            SizedBox(
              width: (box.maxWidth - KoUi.s12 * (columns - 1)) / columns,
              child: child,
            ),
        ],
      );
    },
  );
  Widget items(ArtPack pack) {
    final l = context.l10n;
    return grid([
      for (final item in shopItems)
        Builder(
          builder: (context) {
            final owned = c.home.room.owns(item.id);
            final slot = owned
                ? c.household.areas.placed[item.id]
                : c.itemPurchaseSlot(item.id);
            final name = roomItemName(l, item.id);
            return card(
              name: name,
              art: CatalogArt(pack: pack, item: item.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    owned
                        ? slot == null
                              ? l.shopInStorage
                              : l.shopInArea(homeAreaLabel(l, slot.area))
                        : slot == null
                        ? l.shopStored
                        : l.shopDestination(homeAreaLabel(l, slot.area)),
                    style: KoUi.small,
                  ),
                  const SizedBox(height: KoUi.s8),
                  if (!owned && c.coins < item.price)
                    Text(l.shopNotEnoughTag, style: KoUi.small),
                  UiButton(
                    key: ValueKey('shop-item-${item.id.name}'),
                    homeStyle: true,
                    semanticLabel: owned
                        ? l.shopCardOwnedLabel(name)
                        : c.coins < item.price
                        ? l.shopCardShortLabel(name, item.price)
                        : l.shopCardBuyLabel(name, item.price),
                    label: owned ? l.shopOwnedTag : '${item.price}',
                    icon: owned ? Icons.check : Icons.pets_rounded,
                    kind: UiButtonKind.secondary,
                    onPressed: owned || busy
                        ? null
                        : () => showBuySheet(
                            context,
                            target: BuyItem(item.id),
                            progress: c,
                            pack: pack,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
    ]);
  }

  Widget cats(ArtPack pack) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.shopAdoptIntro, style: KoUi.body),
        for (final owned in [true, false]) ...[
          const SizedBox(height: KoUi.s16),
          if (owned) Text(l.shopOwnedCollection, style: KoUi.heading),
          for (final kitty in kitties.where(
            (k) => c.home.ownsKitty(k.id) == owned,
          ))
            Padding(
              padding: const EdgeInsets.only(top: KoUi.s12),
              child: card(
                name: kittyName(l, kitty.id),
                art: CatalogArt(
                  pack: pack,
                  kitty: kitty.id,
                  accessory: c.home.closet.wearingOf(kitty.id),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (c.home.isFresh(kitty.id))
                      Text(l.kittyNewTag, style: KoUi.label),
                    Text(
                      owned
                          ? '${homeAreaLabel(l, c.household.routine.findArea(kitty.id)!)}, ${homeKittyStatus(l, c, kitty.id)}'
                          : l.shopDestination(
                              homeAreaLabel(l, c.kittyAdoptionArea(kitty.id)!),
                            ),
                      style: KoUi.small,
                    ),
                    const SizedBox(height: KoUi.s8),
                    UiButton(
                      key: ValueKey('shop-kitty-${kitty.id.name}'),
                      homeStyle: true,
                      semanticLabel: owned
                          ? l.shopCardLivesLabel(kittyName(l, kitty.id))
                          : c.coins < kitty.price
                          ? l.shopCardShortLabel(
                              kittyName(l, kitty.id),
                              kitty.price,
                            )
                          : l.shopCardBuyLabel(
                              kittyName(l, kitty.id),
                              kitty.price,
                            ),
                      label: owned
                          ? l.homeFind
                          : c.coins < kitty.price
                          ? l.shopShortBy(kitty.price - c.coins)
                          : l.shopAdopt(kitty.price),
                      kind: UiButtonKind.secondary,
                      onPressed: busy
                          ? null
                          : owned
                          ? () async {
                              c.selectHomeKitty(kitty.id);
                              final area = c.household.routine.findArea(
                                kitty.id,
                              );
                              if (area != null &&
                                  await c.setHomeArea(area) &&
                                  mounted) {
                                if (context.mounted) context.go(AppRoutes.home);
                              }
                            }
                          : () => showBuySheet(
                              context,
                              target: BuyKitty(kitty.id),
                              progress: c,
                              pack: pack,
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget snacksPanel() {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.shopSnackIntro, style: KoUi.body),
        for (final snack in snacks)
          Padding(
            padding: const EdgeInsets.only(top: KoUi.s12),
            child: card(
              name: snackName(l, snack.id),
              art: SnackArt(id: snack.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(snackDesc(l, snack.id), style: KoUi.small),
                  Text(
                    '${l.needHunger} +${snack.hunger} · ${l.needJoy} +${snack.joy}',
                    style: KoUi.small,
                  ),
                  Text(
                    l.shopStock(c.home.pantry.countOf(snack.id)),
                    style: KoUi.label,
                  ),
                  const SizedBox(height: KoUi.s8),
                  UiButton(
                    key: ValueKey('shop-snack-${snack.id.name}'),
                    homeStyle: true,
                    label: !c.home.pantry.canAdd(snack.id)
                        ? l.shopStockFull
                        : l.buyPay(snack.price),
                    semanticLabel: !c.home.pantry.canAdd(snack.id)
                        ? l.shopSnackFullLabel(snackName(l, snack.id))
                        : c.coins < snack.price
                        ? l.shopSnackShortLabel(
                            snackName(l, snack.id),
                            snack.price,
                          )
                        : l.shopSnackBuyLabel(
                            snackName(l, snack.id),
                            snack.price,
                          ),
                    onPressed:
                        busy ||
                            c.coins < snack.price ||
                            !c.home.pantry.canAdd(snack.id)
                        ? null
                        : () => buySnack(snack.id),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget accessoryPanel(ArtPack pack) {
    final l = context.l10n;
    final owned = c.home.closet.owns(selected);
    final worn = c.home.closet.wearingOf(preview) == selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.shopPreviewOf(kittyName(l, preview)), style: KoUi.heading),
        card(
          name: accessoryName(l, selected),
          art: CatalogArt(
            pack: pack,
            kitty: preview,
            accessory: selected,
            size: 180,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                rarityName(l, accessoryOf(selected).rarity),
                style: KoUi.label,
              ),
              Text(accessoryDesc(l, selected), style: KoUi.small),
              if (!owned && c.coins < accessoryOf(selected).price)
                Text(l.shopPlayFirst, style: KoUi.small),
              const SizedBox(height: KoUi.s8),
              UiButton(
                key: ValueKey(
                  owned
                      ? worn
                            ? 'shop-preview-remove'
                            : 'shop-preview-wear'
                      : c.coins < accessoryOf(selected).price
                      ? 'shop-preview-short'
                      : 'shop-preview-buy',
                ),
                homeStyle: true,
                label: owned
                    ? worn
                          ? l.accessoryRemove
                          : l.buyWearOn(kittyName(l, preview))
                    : c.coins < accessoryOf(selected).price
                    ? l.notEnoughCoins(accessoryOf(selected).price - c.coins)
                    : l.buyPay(accessoryOf(selected).price),
                onPressed:
                    busy || (!owned && c.coins < accessoryOf(selected).price)
                    ? null
                    : owned
                    ? () => wear(on: !worn)
                    : () => showBuySheet(
                        context,
                        target: BuyAccessory(selected),
                        progress: c,
                        previewKitty: preview,
                        pack: pack,
                        onWear: (_) => wear(on: true),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KoUi.s12),
        Text(l.shopTryOn, style: KoUi.label),
        Wrap(
          spacing: KoUi.s8,
          runSpacing: KoUi.s8,
          children: [
            for (final kitty in kitties.where((k) => c.home.ownsKitty(k.id)))
              UiButton(
                key: ValueKey('shop-preview-${kitty.id.name}'),
                label: kittyName(l, kitty.id),
                semanticLabel: l.shopPreviewPickLabel(kittyName(l, kitty.id)),
                selected: preview == kitty.id,
                kind: UiButtonKind.secondary,
                onPressed: () => setState(() => preview = kitty.id),
              ),
          ],
        ),
        const SizedBox(height: KoUi.s16),
        grid([
          for (final a in accessories)
            card(
              name: accessoryName(l, a.id),
              art: CatalogArt(pack: pack, kitty: preview, accessory: a.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(rarityName(l, a.rarity), style: KoUi.small),
                  if (wornBy(a.id).isNotEmpty)
                    Text(l.shopWornBy(wornBy(a.id)), style: KoUi.small),
                  UiButton(
                    key: ValueKey('shop-accessory-${a.id.name}'),
                    homeStyle: true,
                    selected: selected == a.id,
                    kind: UiButtonKind.secondary,
                    label: c.home.closet.owns(a.id)
                        ? l.shopOwnedTag
                        : l.coinsAmount(a.price),
                    semanticLabel: accessoryLabel(a.id),
                    onPressed: () => setState(() => selected = a.id),
                  ),
                ],
              ),
            ),
        ]),
      ],
    );
  }

  String accessoryLabel(AccessoryId id) {
    final l = context.l10n, name = accessoryName(context.l10n, id);
    final who = [
      for (final k in kitties)
        if (c.home.closet.wearingOf(k.id) == id) kittyName(l, k.id),
    ].join(', ');
    if (c.home.closet.owns(id)) {
      return who.isEmpty
          ? l.shopAccessoryOwnedLabel(name)
          : l.shopAccessoryWornLabel(name, who);
    }
    final price = accessoryOf(id).price;
    return c.coins < price
        ? l.shopAccessoryShortLabel(name, price)
        : l.shopAccessoryBuyLabel(name, price);
  }

  String wornBy(AccessoryId id) => [
    for (final kitty in kitties)
      if (c.home.closet.wearingOf(kitty.id) == id)
        kittyName(context.l10n, kitty.id),
  ].join(', ');
}
