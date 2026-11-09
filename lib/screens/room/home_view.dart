import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_routine.dart';
import '../../game/model/kitties.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/cat_rig.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/v2/ui_components.dart';
import '../coins/coin_sheet.dart';
import 'home_labels.dart';
import 'home_scene.dart';
import 'home_sheets.dart';

/// The v2 player home. Model changes publish only after their snapshot saves.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.progress,
    this.life = true,
    this.loadArt,
  });
  final ProgressController progress;
  final bool life;
  final Future<ArtPack> Function()? loadArt;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<ArtPack> _art = _load();
  Future<ArtPack> _load() => (widget.loadArt ?? ArtPack.load)();
  ProgressController get c => widget.progress;

  void _map() => context.go(AppRoutes.chapter(c.currentChapter.number));

  @override
  Widget build(BuildContext context) => Theme(
    data: KoUi.theme(),
    child: Builder(
      builder: (context) => AnimatedBuilder(
        animation: c,
        builder: (context, _) => FutureBuilder<ArtPack>(
          future: _art,
          builder: (context, snapshot) => _buildHome(context, snapshot),
        ),
      ),
    ),
  );

  Widget _buildHome(BuildContext context, AsyncSnapshot<ArtPack> snapshot) {
    final l = context.l10n;
    final area = c.household.lastArea;
    final selected = c.selectedHomeKitty;
    final present = c.household.routine.present(area);
    final pack = snapshot.data;
    final sheets = HomeSheets(context, c, pack);
    final still =
        MediaQuery.disableAnimationsOf(context) || c.household.reducedMotion;
    final twoLineHeader =
        c.coins >= 10000 ||
        MediaQuery.textScalerOf(context).scale(KoUi.heading.fontSize!) > 22;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    key: const ValueKey('home-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      KoUi.s16,
                      KoUi.s8,
                      KoUi.s16,
                      KoUi.s8,
                    ),
                    children: [
                      if (twoLineHeader) ...[
                        Text(
                          appName,
                          textAlign: TextAlign.center,
                          style: KoUi.heading,
                        ),
                        const SizedBox(height: KoUi.s4),
                      ],
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              UiButton(
                                key: const ValueKey('home-balance'),
                                label: '${c.coins}',
                                semanticLabel: [
                                  l.coinsAmount(c.coins),
                                  l.coinChipAdd,
                                  if (c.canClaimBonus) l.coinChipBonus,
                                ].join(', '),
                                icon: Icons.paid_outlined,
                                kind: UiButtonKind.secondary,
                                onPressed: () => showCoinSheet(context, c),
                              ),
                              if (c.canClaimBonus)
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: ExcludeSemantics(
                                    child: Icon(
                                      Icons.circle,
                                      key: ValueKey('coin-badge'),
                                      color: KoUi.danger,
                                      size: KoUi.s8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: KoUi.s8),
                          if (twoLineHeader)
                            const Spacer()
                          else
                            Expanded(
                              child: Text(
                                appName,
                                textAlign: TextAlign.center,
                                style: KoUi.heading,
                              ),
                            ),
                          const SizedBox(width: KoUi.s8),
                          UiButton(
                            label: '${c.progress.totalStars}/${c.maxStars}',
                            semanticLabel: l.starsOf(
                              c.progress.totalStars,
                              c.maxStars,
                            ),
                            icon: Icons.star_outline,
                            kind: UiButtonKind.secondary,
                            onPressed: _map,
                          ),
                        ],
                      ),
                      const SizedBox(height: KoUi.s8),
                      UiAreaTabs(
                        labels: [
                          for (final a in HomeArea.values)
                            l.homeAreaCount(
                              homeAreaLabel(l, a),
                              c.household.routine.present(a).length,
                              a.capacity,
                            ),
                        ],
                        selected: area.index,
                        onChanged: (i) async {
                          if (c.householdBusy || c.householdSaveFailed) return;
                          await c.setHomeArea(HomeArea.values[i]);
                        },
                      ),
                      const SizedBox(height: KoUi.s8),
                      Text(homeAreaLabel(l, area), style: KoUi.heading),
                      const SizedBox(height: KoUi.s8),
                      if (c.household.migrationNotice)
                        _notice(
                          l.homeMigration,
                          () => c.acknowledgeHomeMigration(),
                          l.close,
                        ),
                      if (c.householdSaveFailed)
                        _notice(
                          l.homeSaveFailed,
                          () => c.retrySaves(),
                          l.homeRetry,
                        ),
                      if (pack != null)
                        SizedBox(
                          height: (box.maxHeight - 510).clamp(
                            240.0,
                            math.min(390.0, box.maxWidth),
                          ),
                          child: HomeScene(
                            pack: pack,
                            progress: c,
                            area: area,
                            selected: selected,
                            animate: widget.life && !still,
                            onSelect: (kitty) {
                              c.selectHomeKitty(kitty);
                              c.seeKitty(kitty);
                            },
                          ),
                        )
                      else
                        Container(
                          height: 240,
                          alignment: Alignment.center,
                          decoration: KoUi.card(),
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
                                  onPressed: () => setState(() {
                                    _art = _load();
                                  }),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: KoUi.s8),
                      if (present.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(KoUi.s8),
                          child: Text(l.homeEmpty, style: KoUi.small),
                        ),
                      if (selected != null)
                        _selection(context, selected, sheets, pack)
                      else
                        UiButton(
                          label: l.homeChoose,
                          icon: Icons.pets,
                          kind: UiButtonKind.secondary,
                          onPressed: sheets.collection,
                        ),
                      const SizedBox(height: KoUi.s8),
                      UiButton(
                        key: const ValueKey('home-rewards'),
                        label: c.householdRewardCoins > 0
                            ? l.homeRewardAvailable(c.householdRewardCoins)
                            : l.homeRewardNone,
                        icon: Icons.redeem,
                        kind: UiButtonKind.secondary,
                        onPressed: sheets.rewards,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KoUi.s16,
                    KoUi.s8,
                    KoUi.s16,
                    KoUi.s12,
                  ),
                  child: UiNavigation(
                    puzzleLabel: l.uiPlayPuzzle,
                    labels: [l.uiShop, l.homeCats, l.settings],
                    selected: -1,
                    onPuzzle: _map,
                    onChanged: (i) {
                      if (i == 0) context.go(AppRoutes.shop());
                      if (i == 1) sheets.collection();
                      if (i == 2) context.go(AppRoutes.settings);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notice(String text, VoidCallback action, String label) => Padding(
    padding: const EdgeInsets.only(bottom: KoUi.s8),
    child: Container(
      decoration: KoUi.card(),
      padding: const EdgeInsets.all(KoUi.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(liveRegion: true, child: Text(text, style: KoUi.small)),
          const SizedBox(height: KoUi.s8),
          UiButton(
            label: label,
            kind: UiButtonKind.secondary,
            onPressed: c.householdBusy ? null : action,
          ),
        ],
      ),
    ),
  );

  Widget _selection(
    BuildContext context,
    KittyId kitty,
    HomeSheets sheets,
    ArtPack? pack,
  ) {
    final l = context.l10n;
    final r = c.household.routine;
    final here = r.locations[kitty] == c.household.lastArea;
    final busy = c.householdBusy || c.householdSaveFailed;
    final area = c.household.lastArea;
    final actions = switch (area) {
      HomeArea.santai => [HomeActivity.play, HomeActivity.brush],
      HomeArea.makan => [HomeActivity.eat, HomeActivity.rest],
      HomeArea.main => [HomeActivity.play, HomeActivity.rest],
      HomeArea.rawat => [HomeActivity.brush, HomeActivity.pet],
    };
    return Container(
      key: const ValueKey('home-selection'),
      decoration: KoUi.card(),
      padding: const EdgeInsets.all(KoUi.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => sheets.cat(kitty),
            borderRadius: BorderRadius.circular(KoUi.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(KoUi.s4),
              child: Row(
                children: [
                  if (pack != null)
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CustomPaint(
                          painter: HomeCatPainter(
                            pack,
                            CatRig(
                              cat: kitty,
                              accessory: c.home.closet.wearingOf(kitty),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: KoUi.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kittyName(l, kitty), style: KoUi.heading),
                        Text(homeKittyStatus(l, c, kitty), style: KoUi.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: KoUi.ink),
                ],
              ),
            ),
          ),
          const SizedBox(height: KoUi.s4),
          if (!here || r.moving(kitty))
            UiButton(
              label: l.homeViewArea,
              kind: UiButtonKind.secondary,
              onPressed: busy ? null : () => sheets.find(kitty),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < actions.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : KoUi.s8),
                      child: UiButton(
                        label: switch (actions[i]) {
                          HomeActivity.play => l.homeInvitePlay,
                          HomeActivity.brush => l.homeInviteCare,
                          HomeActivity.eat => l.homeInviteEat,
                          HomeActivity.pet => l.petAction,
                          HomeActivity.rest => l.homeRest,
                        },
                        kind: UiButtonKind.secondary,
                        onPressed: busy
                            ? null
                            : () => c.inviteKitty(kitty, actions[i]),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
