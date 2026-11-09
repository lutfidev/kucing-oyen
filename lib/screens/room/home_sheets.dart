import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
import '../../game/model/snacks.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/cat_rig.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/v2/ui_components.dart';
import '../../widgets/v2/ui_sheet.dart';
import '../shop/shop_tab.dart';
import 'home_labels.dart';
import 'home_scene.dart';

enum _CatPanel { snacks, accessories }

/// Every sheet observes the controller: activity, location, eligibility and
/// balance can all change while it is open. A sheet never owns a house clock.
class HomeSheets {
  HomeSheets(this.context, this.c, this.pack);
  final BuildContext context;
  final ProgressController c;
  final ArtPack? pack;
  AppLocalizations get l => context.l10n;
  bool get busy => c.householdBusy || c.householdSaveFailed;

  Widget _live(Widget Function(BuildContext) builder) =>
      AnimatedBuilder(animation: c, builder: (context, _) => builder(context));

  Widget _portrait(KittyId kitty) => SizedBox(
    width: 64,
    height: 64,
    child: pack == null
        ? const Icon(Icons.pets, color: KoUi.ink)
        : CustomPaint(
            painter: HomeCatPainter(
              pack!,
              CatRig(cat: kitty, accessory: c.home.closet.wearingOf(kitty)),
            ),
          ),
  );

  Widget _error() => c.householdSaveFailed
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(l.homeSaveFailed, style: KoUi.body),
            ),
            UiButton(label: l.homeRetry, onPressed: () => c.retrySaves()),
            const SizedBox(height: KoUi.s8),
          ],
        )
      : const SizedBox.shrink();

  Future<void> find(KittyId kitty) async {
    final area = c.household.routine.findArea(kitty);
    if (area == null || busy) return;
    c.selectHomeKitty(kitty);
    await c.setHomeArea(area);
  }

  Future<void> collection() => showUiSheet<void>(
    context,
    title: l.homeCats,
    closeLabel: l.close,
    body: _live(
      (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _error(),
          for (final kitty in KittyId.values.where(c.home.ownsKitty))
            Padding(
              padding: const EdgeInsets.only(bottom: KoUi.s12),
              child: Container(
                decoration: KoUi.card(),
                padding: const EdgeInsets.all(KoUi.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ExcludeSemantics(child: _portrait(kitty)),
                        const SizedBox(width: KoUi.s8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(kittyName(l, kitty), style: KoUi.heading),
                              if (c.home.isFresh(kitty))
                                Text(l.kittyNewTag, style: KoUi.small),
                              Text(
                                homeAreaLabel(
                                  l,
                                  c.household.routine.findArea(kitty)!,
                                ),
                                style: KoUi.small,
                              ),
                              Text(
                                homeKittyStatus(l, c, kitty),
                                style: KoUi.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ..._needs(kitty),
                    UiButton(
                      key: ValueKey('home-find-${kitty.name}'),
                      label: l.homeFind,
                      kind: UiButtonKind.secondary,
                      onPressed: busy
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              find(kitty);
                            },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    footer: const SizedBox.shrink(),
  );

  List<Widget> _needs(KittyId kitty) {
    final needs = c.catNeeds(kitty);
    return [
      const SizedBox(height: KoUi.s8),
      UiNeed(
        label: l.homeFood,
        value: needs.hunger,
        lowLabel: l.uiLowNeed,
        icon: Icons.restaurant,
      ),
      const SizedBox(height: KoUi.s8),
      UiNeed(
        label: l.needJoy,
        value: needs.joy,
        lowLabel: l.uiLowNeed,
        icon: Icons.favorite_border,
      ),
      const SizedBox(height: KoUi.s8),
    ];
  }

  Future<void> cat(KittyId kitty) async {
    c.seeKitty(kitty);
    final panel = await showUiSheet<_CatPanel>(
      context,
      title: kittyName(l, kitty),
      closeLabel: l.close,
      body: _live(
        (sheetContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _error(),
            Center(child: _portrait(kitty)),
            Text(homeKittyStatus(l, c, kitty), style: KoUi.body),
            ..._needs(kitty),
            for (final activity in HomeActivity.values)
              Padding(
                padding: const EdgeInsets.only(bottom: KoUi.s8),
                child: UiButton(
                  key: ValueKey('home-invite-${activity.name}'),
                  label: l.homeInviteFor(
                    kittyName(l, kitty),
                    l.homeActivity(activity.name),
                  ),
                  kind: UiButtonKind.secondary,
                  onPressed: busy ? null : () => c.inviteKitty(kitty, activity),
                ),
              ),
            if (c.household.routine.invitations.containsKey(kitty) ||
                c.household.routine.activities.containsKey(kitty))
              UiButton(
                label: c.household.routine.activities.containsKey(kitty)
                    ? l.homeCancelAfter
                    : l.homeCancelInvitation,
                kind: UiButtonKind.secondary,
                onPressed: busy ? null : () => c.cancelInvitation(kitty),
              ),
            const SizedBox(height: KoUi.s12),
            UiButton(
              label: l.snackPanel,
              kind: UiButtonKind.secondary,
              onPressed: () {
                Navigator.of(sheetContext).pop(_CatPanel.snacks);
              },
            ),
            const SizedBox(height: KoUi.s8),
            UiButton(
              label: l.accessories,
              kind: UiButtonKind.secondary,
              onPressed: () {
                Navigator.of(sheetContext).pop(_CatPanel.accessories);
              },
            ),
          ],
        ),
      ),
      footer: _live(
        (sheetContext) => UiButton(
          label: l.homeFind,
          onPressed: busy
              ? null
              : () {
                  Navigator.of(sheetContext).pop();
                  find(kitty);
                },
        ),
      ),
    );
    // Restore the first sheet's trigger before opening another modal, so it
    // cannot steal focus back from the next sheet's heading.
    if (!context.mounted) return;
    switch (panel) {
      case _CatPanel.snacks:
        await snacksFor(kitty);
      case _CatPanel.accessories:
        await accessoriesFor(kitty);
      case null:
        break;
    }
  }

  Future<void> rewards() => showUiSheet<void>(
    context,
    title: l.homeRewards,
    closeLabel: l.close,
    body: _live(
      (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _error(),
          if (c.claimableKitties.isEmpty)
            Text(l.homeRewardNone, style: KoUi.body),
          for (final kitty in c.claimableKitties)
            Padding(
              padding: const EdgeInsets.only(bottom: KoUi.s8),
              child: Row(
                children: [
                  ExcludeSemantics(child: _portrait(kitty)),
                  const SizedBox(width: KoUi.s8),
                  Expanded(
                    child: Text(kittyName(l, kitty), style: KoUi.heading),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    footer: _live(
      (_) => UiButton(
        key: const ValueKey('home-claim-all'),
        label: l.homeClaimAll(c.householdRewardCoins),
        onPressed: busy || c.householdRewardCoins == 0
            ? null
            : () => c.claimAllKittyRewards(),
      ),
    ),
  );

  Future<void> snacksFor(KittyId kitty) => showUiSheet<void>(
    context,
    title: l.snackPanel,
    closeLabel: l.close,
    body: _live((_) {
      final full = c.catNeeds(kitty).isFull;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _error(),
          Text(
            full ? l.snackFullNote(kittyName(l, kitty)) : l.snackPick,
            style: KoUi.body,
          ),
          for (final snack in snacks)
            Padding(
              padding: const EdgeInsets.only(top: KoUi.s8),
              child: UiButton(
                label: l.snackGive(
                  snackName(l, snack.id),
                  c.home.pantry.countOf(snack.id),
                ),
                kind: UiButtonKind.secondary,
                onPressed: busy || full || c.home.pantry.countOf(snack.id) == 0
                    ? null
                    : () => c.feed(kitty, snack.id),
              ),
            ),
        ],
      );
    }),
    footer: Builder(
      builder: (sheetContext) => UiButton(
        label: l.uiShop,
        onPressed: () {
          Navigator.of(sheetContext).pop();
          context.go(AppRoutes.shop(tab: ShopTab.snacks));
        },
      ),
    ),
  );

  Future<void> accessoriesFor(KittyId kitty) => showUiSheet<void>(
    context,
    title: l.accessories,
    closeLabel: l.close,
    body: _live(
      (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _error(),
          Center(child: _portrait(kitty)),
          UiButton(
            label: l.accessoryRemove,
            kind: UiButtonKind.secondary,
            onPressed: busy || c.home.closet.wearingOf(kitty) == null
                ? null
                : () => c.wearAccessory(kitty, null),
          ),
          for (final id in c.home.closet.owned)
            Padding(
              padding: const EdgeInsets.only(top: KoUi.s8),
              child: UiButton(
                label: accessoryName(l, id),
                kind: UiButtonKind.secondary,
                selected: c.home.closet.wearingOf(kitty) == id,
                onPressed: busy ? null : () => c.wearAccessory(kitty, id),
              ),
            ),
        ],
      ),
    ),
    footer: Builder(
      builder: (sheetContext) => UiButton(
        label: l.accessoryShopLink,
        onPressed: () {
          Navigator.of(sheetContext).pop();
          context.go(AppRoutes.shop(tab: ShopTab.accessories));
        },
      ),
    ),
  );
}
