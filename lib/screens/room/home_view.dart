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
import '../../widgets/game_art.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/v2/ui_edge_fade.dart';
import 'home_chrome.dart';
import 'home_help.dart';
import '../coins/coin_sheet.dart';
import 'home_labels.dart';
import 'home_scene.dart';
import 'home_sheets.dart';
import 'area_decorate.dart';

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
      backgroundColor: KoUi.homeBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            return Column(
              children: [
                Expanded(
                  child: UiEdgeFade(
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
                                  homeStyle: true,
                                  key: const ValueKey('home-balance'),
                                  label: '${c.coins}',
                                  semanticLabel: [
                                    l.coinsAmount(c.coins),
                                    l.coinChipAdd,
                                    if (c.canClaimBonus) l.coinChipBonus,
                                  ].join(', '),
                                  leading: const CoinView(size: KoUi.coinIcon),
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
                              homeStyle: true,
                              label: '${c.progress.totalStars}/${c.maxStars}',
                              semanticLabel: l.starsOf(
                                c.progress.totalStars,
                                c.maxStars,
                              ),
                              leading: const Icon(
                                Icons.star_rounded,
                                color: KoUi.homeStar,
                              ),
                              kind: UiButtonKind.secondary,
                              onPressed: _map,
                            ),
                          ],
                        ),
                        const SizedBox(height: KoUi.s8),
                        HomeAreaStrip(
                          semantics: [
                            for (final a in HomeArea.values)
                              l.homeAreaCount(
                                homeAreaLabel(l, a),
                                c.household.routine.present(a).length,
                                a.capacity,
                              ),
                          ],
                          labels: [
                            for (final a in HomeArea.values)
                              a == HomeArea.main
                                  ? l.homeActivity('play')
                                  : a == HomeArea.rawat
                                  ? l.homeInviteCare
                                  : homeAreaLabel(l, a),
                          ],
                          selected: area.index,
                          onChanged: (i) async {
                            if (c.householdBusy || c.householdSaveFailed) {
                              return;
                            }
                            await c.setHomeArea(HomeArea.values[i]);
                          },
                        ),
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
                        SizedBox(
                          height: _sceneHeight(context, box, twoLineHeader),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: pack != null
                                    ? HomeScene(
                                        pack: pack,
                                        progress: c,
                                        area: area,
                                        selected: selected,
                                        animate: widget.life && !still,
                                        onBowl: sheets.dining,
                                        onToy: sheets.playing,
                                        onCare: sheets.caring,
                                        onSelect: (kitty) {
                                          c.selectHomeKitty(kitty);
                                          c.seeKitty(kitty);
                                        },
                                      )
                                    : _loading(context, snapshot),
                              ),
                              Positioned(
                                top: KoUi.s4,
                                right: KoUi.s4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HomeIconButton(
                                      key: const ValueKey('home-help'),
                                      icon: Icons.help_outline_rounded,
                                      label: l.guidanceHomeTitle,
                                      onPressed: () => showHomeHelp(context),
                                    ),
                                    HomeIconButton(
                                      key: const ValueKey('home-decorate'),
                                      icon: Icons.edit_outlined,
                                      label: l.decorate,
                                      onPressed:
                                          pack == null ||
                                              c.householdBusy ||
                                              c.householdSaveFailed
                                          ? null
                                          : () => showAreaDecorate(
                                              context,
                                              c,
                                              pack,
                                            ),
                                    ),
                                  ],
                                ),
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
                            homeStyle: true,
                            label: l.homeChoose,
                            icon: Icons.pets,
                            kind: UiButtonKind.secondary,
                            onPressed: sheets.collection,
                          ),
                        const SizedBox(height: KoUi.s8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: KoUi.s8,
                          runSpacing: KoUi.s8,
                          children: [
                            ?_areaChip(context, area, sheets),
                            _chip(
                              key: const ValueKey('home-rewards'),
                              icon: Icons.redeem,
                              label: c.householdRewardCoins > 0
                                  ? l.homeRewardAvailable(
                                      c.householdRewardCoins,
                                    )
                                  : l.homeRewardLater,
                              highlight: c.householdRewardCoins > 0,
                              onPressed: sheets.rewards,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                HomeNavigation(
                  puzzleLabel: l.uiPlayPuzzle,
                  labels: [l.uiShop, l.homeCats, l.settings],
                  onPuzzle: _map,
                  onChanged: (i) {
                    if (i == 0) context.go(AppRoutes.shop());
                    if (i == 1) sheets.collection();
                    if (i == 2) context.go(AppRoutes.settings);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Room height = what is left after the compact chrome (bottom navigation
  /// included), clamped by the old cap of screen width ×1.16. The square
  /// painted backdrop may stretch up to ~1.26× at 390 dp; cats and props are
  /// drawn separately and keep their proportions.
  double _sceneHeight(BuildContext context, BoxConstraints box, bool twoLine) {
    final grow = MediaQuery.textScalerOf(context).scale(16) - 16;
    final chrome = 396 + grow * 6 + (twoLine ? 30 : 0);
    return (box.maxHeight - chrome).clamp(
      240.0,
      math.min(480.0, box.maxWidth * 1.16),
    );
  }

  Widget _loading(BuildContext context, AsyncSnapshot<ArtPack> snapshot) {
    final l = context.l10n;
    return Container(
      alignment: Alignment.center,
      decoration: KoUi.homeCard(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            snapshot.hasError ? l.homeLoadFailed : l.homeLoading,
            style: KoUi.body,
          ),
          if (snapshot.hasError)
            UiButton(
              homeStyle: true,
              label: l.homeRetry,
              onPressed: () => setState(() {
                _art = _load();
              }),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool highlight = false,
    bool live = false,
  }) => Semantics(
    // Area status changes (e.g. "X is getting care" → "Mat is free") are
    // announced, as the old area panels did.
    liveRegion: live,
    child: UiButton(
      key: key,
      homeStyle: true,
      compact: true,
      kind: highlight ? UiButtonKind.primary : UiButtonKind.secondary,
      padding: const EdgeInsets.symmetric(
        horizontal: KoUi.s12,
        vertical: KoUi.s8,
      ),
      label: label,
      icon: icon,
      onPressed: onPressed,
    ),
  );

  /// One short line about the area's shared facility; details and the queue
  /// (with cancel) live in the area sheet it opens.
  Widget? _areaChip(BuildContext context, HomeArea area, HomeSheets sheets) {
    final l = context.l10n;
    String withQueue(String text, int waiting) =>
        waiting == 0 ? text : '$text · ${l.homeStatusQueue(waiting)}';
    return switch (area) {
      HomeArea.santai => null,
      HomeArea.makan => _chip(
        key: const ValueKey('dining-choose'),
        live: true,
        icon: Icons.restaurant_rounded,
        label: withQueue(
          c.dining.eating != null
              ? l.diningUsing(kittyName(l, c.dining.eating!))
              : c.dining.portionsLeft == 0
              ? l.homeStatusBowlEmpty
              : l.homeStatusBowl(c.dining.portionsLeft, c.dining.owned.length),
          c.dining.queue.length,
        ),
        onPressed: sheets.dining,
      ),
      HomeArea.main => _chip(
        key: const ValueKey('play-choose'),
        live: true,
        icon: Icons.sports_baseball_rounded,
        label: withQueue(
          c.playing.playing != null
              ? l.playUsing(kittyName(l, c.playing.playing!))
              : l.homeStatusToy,
          c.playing.queue.length,
        ),
        onPressed: sheets.playing,
      ),
      HomeArea.rawat => _chip(
        key: const ValueKey('care-choose'),
        live: true,
        icon: Icons.brush_rounded,
        label: withQueue(
          c.caring.using != null
              ? l.careUsing(kittyName(l, c.caring.using!))
              : l.homeStatusCare,
          c.caring.queue.length,
        ),
        onPressed: sheets.caring,
      ),
    };
  }

  Widget _notice(String text, VoidCallback action, String label) => Padding(
    padding: const EdgeInsets.only(bottom: KoUi.s8),
    child: Container(
      decoration: KoUi.homeCard(),
      padding: const EdgeInsets.all(KoUi.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(liveRegion: true, child: Text(text, style: KoUi.small)),
          const SizedBox(height: KoUi.s8),
          UiButton(
            homeStyle: true,
            label: label,
            kind: UiButtonKind.secondary,
            onPressed: c.householdBusy ? null : action,
          ),
        ],
      ),
    ),
  );

  /// Icon (20) + gap (8) + side padding (2×8) + outline and rounding slack.
  static const _actionChrome = 20 + KoUi.s8 + 2 * KoUi.s8 + 6;

  /// Avatar, a short name and the divider; below this the panel stacks.
  static const _panelIdentityMin = 48 + KoUi.s4 + 56 + 2 * KoUi.s8 + KoUi.s8;

  double _longestWord(BuildContext context, String text) {
    var widest = 0.0;
    for (final word in text.split(RegExp(r'\s+'))) {
      final painter = TextPainter(
        text: TextSpan(
          text: word,
          style: KoUi.small.copyWith(fontWeight: FontWeight.w700),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    return widest;
  }

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
    final large = MediaQuery.textScalerOf(context).scale(14) > 16;
    Widget identity() => InkWell(
      onTap: () => sheets.cat(kitty),
      borderRadius: BorderRadius.circular(KoUi.buttonRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KoUi.s4),
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
                        motion: CatMotion.happy,
                        accessory: c.home.closet.wearingOf(kitty),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: KoUi.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Long names shrink instead of being cut off.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      kittyName(l, kitty),
                      style: KoUi.heading,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    homeKittyStatus(l, c, kitty),
                    style: KoUi.caption,
                    maxLines: large ? null : 2,
                    overflow: large ? null : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    String label(int i) => switch (actions[i]) {
      HomeActivity.play => l.homeInvitePlay,
      HomeActivity.brush => l.homeActivity('brush'),
      HomeActivity.eat => l.homeInviteEat,
      HomeActivity.pet => l.petAction,
      HomeActivity.rest => l.homeRest,
    };
    // Wide enough for the longest word, so labels wrap between words only
    // ("Расчёсывание" must not break mid-word), within 28–40% of the panel.
    double actionNeed(String text) =>
        _longestWord(context, text) + _actionChrome;
    double actionWidth(int i, double panel) =>
        actionNeed(label(i)).clamp(panel * .28, panel * .45);
    Widget action(int i) => UiButton(
      homeStyle: true,
      compact: true,
      padding: const EdgeInsets.symmetric(
        horizontal: KoUi.s8,
        vertical: KoUi.s8,
      ),
      icon: switch (actions[i]) {
        HomeActivity.play => Icons.sports_esports_rounded,
        HomeActivity.brush => Icons.brush_rounded,
        HomeActivity.eat => Icons.restaurant_rounded,
        HomeActivity.pet => Icons.favorite_rounded,
        HomeActivity.rest => Icons.weekend_rounded,
      },
      label: label(i),
      onPressed:
          busy ||
              (actions[i] == HomeActivity.eat && !c.canEatFromBowl(kitty)) ||
              (actions[i] == HomeActivity.play && !c.canInvitePlay(kitty)) ||
              ((actions[i] == HomeActivity.brush ||
                      actions[i] == HomeActivity.pet) &&
                  !c.canInviteCare(kitty, actions[i]))
          ? null
          : () => c.inviteKitty(kitty, actions[i]),
    );
    final local = here && !r.moving(kitty);
    return Container(
      key: const ValueKey('home-selection'),
      decoration: KoUi.homeCard(),
      padding: const EdgeInsets.symmetric(
        horizontal: KoUi.s8,
        vertical: KoUi.s4,
      ),
      child: LayoutBuilder(
        builder: (context, box) =>
            large ||
                (local &&
                    actionNeed(label(0)) +
                            actionNeed(label(1)) +
                            _panelIdentityMin >
                        box.maxWidth)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity(),
                  if (local &&
                      [
                        for (var i = 0; i < actions.length; i++)
                          actionNeed(label(i)),
                      ].every((need) => need <= (box.maxWidth - KoUi.s8) / 2))
                    Row(
                      children: [
                        for (var i = 0; i < actions.length; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : KoUi.s8,
                              ),
                              child: action(i),
                            ),
                          ),
                      ],
                    )
                  else if (local)
                    // A word wider than half the panel: one action per row.
                    for (var i = 0; i < actions.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : KoUi.s8),
                        child: action(i),
                      )
                  else
                    UiButton(
                      homeStyle: true,
                      label: l.homeViewArea,
                      kind: UiButtonKind.secondary,
                      onPressed: busy ? null : () => sheets.find(kitty),
                    ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity()),
                  Container(
                    width: KoUi.outline,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: KoUi.s8),
                    color: KoUi.homeLine,
                  ),
                  if (local) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: actionWidth(0, box.maxWidth),
                      ),
                      child: action(0),
                    ),
                    const SizedBox(width: KoUi.s8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: actionWidth(1, box.maxWidth),
                      ),
                      child: action(1),
                    ),
                  ] else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: box.maxWidth * .45),
                      child: UiButton(
                        homeStyle: true,
                        compact: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: KoUi.s8,
                          vertical: KoUi.s8,
                        ),
                        icon: Icons.visibility_outlined,
                        label: l.homeViewArea,
                        kind: UiButtonKind.secondary,
                        onPressed: busy ? null : () => sheets.find(kitty),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
