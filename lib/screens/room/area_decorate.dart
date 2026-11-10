import 'package:flutter/material.dart';

import '../../app/progress_scope.dart';
import '../../game/model/home_areas.dart';
import '../../game/model/home_items.dart';
import '../../game/render/v2/art_pack.dart';
import '../../game/render/v2/painted_scenery.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/catalog_art.dart';
import '../../widgets/v2/ui_button.dart';
import 'home_labels.dart';
import 'area_layout_preview.dart';

Future<void> showAreaDecorate(
  BuildContext context,
  ProgressController c,
  ArtPack pack,
) async {
  if (c.householdBusy || c.householdSaveFailed || c.householdDecorating) return;
  c.pauseHousehold(HouseholdPause.decorating);
  final route = MaterialPageRoute<void>(
    builder: (_) => AreaDecorate(progress: c, pack: pack),
  );
  try {
    await Navigator.of(context).push<void>(route);
    await route.completed;
  } finally {
    c.resumeHousehold(HouseholdPause.decorating);
  }
}

/// One local draft. Only Save publishes to the controller and durable snapshot.
class AreaDecorate extends StatefulWidget {
  const AreaDecorate({super.key, required this.progress, required this.pack});
  final ProgressController progress;
  final ArtPack pack;
  @override
  State<AreaDecorate> createState() => _AreaDecorateState();
}

class _AreaDecorateState extends State<AreaDecorate> {
  ProgressController get c => widget.progress;
  late HomeAreas draft = c.household.areas;
  late HomeArea area = c.household.lastArea;
  RoomItemId? selected;
  bool storageOnly = false;
  String? error;
  bool leaving = false, dialog = false;
  bool get dirty => draft != c.household.areas;
  bool get blocked => c.householdBusy || c.householdSaveFailed;
  void place(RoomItemId id, AreaSlot slot) {
    if (blocked) return;
    final next = draft.place(c.home, id, slot);
    setState(() {
      if (next.placed[id] != slot) {
        error = context.l10n.decorateInvalid;
      } else {
        draft = next;
        selected = id;
        error = null;
      }
    });
  }

  Future<void> close() async {
    if (leaving || c.householdBusy || dialog) return;
    if (!dirty && !c.householdSaveFailed) {
      leave();
      return;
    }
    dialog = true;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        final l = context.l10n;
        return AlertDialog(
          title: Text(l.decorateUnsaved, style: KoUi.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiButton(
                label: c.householdSaveFailed
                    ? l.homeRetry
                    : l.decorateSaveLayout,
                onPressed: () => Navigator.pop(context, 'save'),
              ),
              const SizedBox(height: KoUi.s12),
              UiButton(
                key: const ValueKey('decorate-discard'),
                label: l.decorateDiscard,
                kind: UiButtonKind.danger,
                onPressed: () => Navigator.pop(context, 'discard'),
              ),
              const SizedBox(height: KoUi.s12),
              UiButton(
                label: l.decorateContinue,
                kind: UiButtonKind.secondary,
                onPressed: () => Navigator.pop(context, 'continue'),
              ),
            ],
          ),
        );
      },
    );
    dialog = false;
    if (!mounted) return;
    if (choice == 'save') {
      await save();
    }
    if (choice == 'discard') {
      if (c.householdSaveFailed && !c.discardAreaLayoutSave(draft)) return;
      leave();
    }
  }

  void leave() {
    setState(() => leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> save() async {
    if (c.householdBusy) return;
    if (c.householdSaveFailed) {
      await c.retrySaves();
    } else if (dirty) {
      await c.saveAreaLayout(draft);
    }
    if (mounted && !c.householdSaveFailed && draft == c.household.areas) {
      leave();
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: KoUi.theme(),
    child: AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final l = context.l10n;
        return PopScope(
          canPop: leaving,
          onPopInvokedWithResult: (popped, _) {
            if (!popped) close();
          },
          child: Scaffold(
            backgroundColor: KoUi.homeBackground,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(KoUi.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.decorateArea(homeAreaLabel(l, area)),
                          style: KoUi.title,
                        ),
                        Text(l.decoratePaused, style: KoUi.caption),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: KoUi.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: KoUi.s8,
                            runSpacing: KoUi.s8,
                            children: [
                              for (final a in HomeArea.values)
                                UiButton(
                                  key: ValueKey('decorate-area-${a.name}'),
                                  label: homeAreaLabel(l, a),
                                  kind: UiButtonKind.secondary,
                                  selected: a == area,
                                  onPressed: blocked
                                      ? null
                                      : () => setState(() => area = a),
                                ),
                            ],
                          ),
                          const SizedBox(height: KoUi.s12),
                          Text(l.decorateInstructions, style: KoUi.small),
                          const SizedBox(height: KoUi.s12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              KoUi.cardRadius,
                            ),
                            child: AreaLayoutPreview(
                              pack: widget.pack,
                              draft: draft,
                              area: area,
                            ),
                          ),
                          const SizedBox(height: KoUi.s12),
                          Container(
                            decoration: KoUi.homeCard(),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: .35,
                                    child: Image(
                                      image: switch (area) {
                                        HomeArea.santai =>
                                          PaintedScenery.lounge,
                                        HomeArea.makan => PaintedScenery.dining,
                                        HomeArea.main => PaintedScenery.play,
                                        HomeArea.rawat => PaintedScenery.care,
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(KoUi.s8),
                                  child: Column(
                                    children: [
                                      slots(RoomZone.wall, 3),
                                      const SizedBox(height: KoUi.s16),
                                      slots(RoomZone.floor, 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: KoUi.s12),
                          if (error != null)
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                error!,
                                style: KoUi.label.copyWith(color: KoUi.danger),
                              ),
                            ),
                          if (c.householdSaveFailed) ...[
                            Semantics(
                              liveRegion: true,
                              child: Text(l.homeSaveFailed, style: KoUi.body),
                            ),
                            UiButton(
                              key: const ValueKey('decorate-retry'),
                              label: l.homeRetry,
                              loading: c.householdBusy,
                              onPressed: save,
                            ),
                          ],
                          if (selected case final id?) ...[
                            Text(roomItemName(l, id), style: KoUi.heading),
                            Text(
                              l.decorateAllowed(
                                allowedItemAreas(id)
                                    .map((a) => homeAreaLabel(l, a))
                                    .join(', '),
                              ),
                              style: KoUi.small,
                            ),
                            if (id == RoomItemId.mangkuk)
                              Text(l.decorateBowlFixed, style: KoUi.small)
                            else
                              UiButton(
                                key: const ValueKey('decorate-store'),
                                label: l.decorateStoreItem,
                                kind: UiButtonKind.secondary,
                                onPressed:
                                    blocked || !draft.placed.containsKey(id)
                                    ? null
                                    : () => setState(() {
                                        draft = draft.store(id);
                                        error = null;
                                      }),
                              ),
                          ],
                          const SizedBox(height: KoUi.s16),
                          Wrap(
                            spacing: KoUi.s8,
                            runSpacing: KoUi.s8,
                            children: [
                              UiButton(
                                label: l.shopOwnedCollection,
                                selected: !storageOnly,
                                kind: UiButtonKind.secondary,
                                onPressed: () =>
                                    setState(() => storageOnly = false),
                              ),
                              UiButton(
                                key: const ValueKey('decorate-storage'),
                                label:
                                    '${l.storage} · ${l.storageCount(c.home.room.owned.where((id) => !draft.placed.containsKey(id)).length)}',
                                semanticLabel: l.storage,
                                selected: storageOnly,
                                kind: UiButtonKind.secondary,
                                onPressed: () =>
                                    setState(() => storageOnly = true),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: KoUi.s8,
                            runSpacing: KoUi.s8,
                            children: [
                              for (final id in RoomItemId.values.where(
                                (id) =>
                                    c.home.room.owns(id) &&
                                    (!storageOnly ||
                                        !draft.placed.containsKey(id)),
                              ))
                                SizedBox(
                                  width: 144,
                                  child: Draggable<RoomItemId>(
                                    data: id,
                                    maxSimultaneousDrags:
                                        blocked || id == RoomItemId.mangkuk
                                        ? 0
                                        : 1,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: CatalogArt(
                                        pack: widget.pack,
                                        item: id,
                                        size: 80,
                                      ),
                                    ),
                                    onDragEnd: (details) {
                                      if (!details.wasAccepted && mounted) {
                                        setState(
                                          () => error = l.decorateInvalid,
                                        );
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        CatalogArt(
                                          pack: widget.pack,
                                          item: id,
                                          size: 64,
                                        ),
                                        UiButton(
                                          key: ValueKey(
                                            'decorate-item-${id.name}',
                                          ),
                                          homeStyle: true,
                                          label: roomItemName(l, id),
                                          selected: selected == id,
                                          kind: UiButtonKind.secondary,
                                          onPressed: blocked
                                              ? null
                                              : () => setState(() {
                                                  selected = id;
                                                  error = null;
                                                }),
                                        ),
                                        Text(
                                          draft.placed[id] == null
                                              ? l.shopInStorage
                                              : l.shopInArea(
                                                  homeAreaLabel(
                                                    l,
                                                    draft.placed[id]!.area,
                                                  ),
                                                ),
                                          style: KoUi.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (c.home.room.owned.length == 1 ||
                              (storageOnly &&
                                  c.home.room.owned.every(
                                    draft.placed.containsKey,
                                  )))
                            Text(l.storageEmpty, style: KoUi.small),
                          const SizedBox(height: KoUi.s24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(KoUi.s12),
                    child: Row(
                      children: [
                        Expanded(
                          child: UiButton(
                            key: const ValueKey('decorate-cancel'),
                            homeStyle: true,
                            label: l.cancel,
                            kind: UiButtonKind.secondary,
                            onPressed: c.householdBusy ? null : close,
                          ),
                        ),
                        const SizedBox(width: KoUi.s8),
                        Expanded(
                          child: UiButton(
                            key: const ValueKey('decorate-save'),
                            homeStyle: true,
                            label: l.decorateSaveLayout,
                            loading: c.householdBusy,
                            onPressed: blocked || !dirty ? null : save,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget slots(RoomZone zone, int count) {
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, box) => Wrap(
        spacing: KoUi.s8,
        runSpacing: KoUi.s8,
        children: [
          if (selected case final id?)
            SizedBox(
              width: box.maxWidth,
              child: Draggable<RoomItemId>(
                key: ValueKey('decorate-drag-${zone.name}'),
                data: id,
                maxSimultaneousDrags: blocked || id == RoomItemId.mangkuk
                    ? 0
                    : 1,
                feedback: Material(
                  color: Colors.transparent,
                  child: CatalogArt(pack: widget.pack, item: id, size: 80),
                ),
                onDragEnd: (details) {
                  if (!details.wasAccepted && mounted) {
                    setState(() => error = l.decorateInvalid);
                  }
                },
                child: Row(
                  children: [
                    CatalogArt(pack: widget.pack, item: id, size: 64),
                    const SizedBox(width: KoUi.s8),
                    Expanded(
                      child: Text(roomItemName(l, id), style: KoUi.heading),
                    ),
                    const Icon(Icons.drag_indicator, color: KoUi.homeLine),
                  ],
                ),
              ),
            ),

          for (var n = 0; n < count; n++)
            SizedBox(
              width: (box.maxWidth - KoUi.s8) / 2,
              child: Builder(
                builder: (context) {
                  final slot = AreaSlot(area, zone, n);
                  final id = draft.placed.entries
                      .where((e) => e.value == slot)
                      .firstOrNull
                      ?.key;
                  final label = l.decorateSlot(
                    zone == RoomZone.wall ? l.decorateWall : l.decorateFloor,
                    n + 1,
                  );
                  return DragTarget<RoomItemId>(
                    onWillAcceptWithDetails: (d) =>
                        !blocked &&
                        draft.place(c.home, d.data, slot).placed[d.data] ==
                            slot,
                    onAcceptWithDetails: (d) => place(d.data, slot),
                    builder: (context, candidates, rejected) => Container(
                      decoration: KoUi.card(
                        color: rejected.isNotEmpty ? KoUi.peach : KoUi.paper,
                      ),
                      padding: const EdgeInsets.all(KoUi.s4),
                      child: Column(
                        children: [
                          if (id != null)
                            CatalogArt(pack: widget.pack, item: id, size: 60)
                          else
                            const SizedBox(
                              height: 60,
                              child: Center(
                                child: Icon(Icons.add, color: KoUi.homeLine),
                              ),
                            ),
                          UiButton(
                            key: ValueKey('decorate-slot-${zone.name}-$n'),
                            compact: true,
                            label: label,
                            semanticLabel:
                                '$label, ${id == null ? l.storageTapHint : roomItemName(l, id)}',
                            selected: selected != null && id == selected,
                            kind: UiButtonKind.secondary,
                            onPressed: blocked
                                ? null
                                : () {
                                    if (selected == null && id != null) {
                                      setState(() => selected = id);
                                    } else if (selected != null) {
                                      place(selected!, slot);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
