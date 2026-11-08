import 'package:flutter/material.dart';

import '../game/render/v2/art_pack.dart';
import '../game/render/v2/cat_rig.dart';
import '../game/render/v2/room_art.dart';
import '../l10n/l10n.dart';
import '../theme/ko_ui.dart';
import '../widgets/v2/ui_button.dart';
import '../widgets/v2/ui_components.dart';
import '../widgets/v2/ui_sheet.dart';

/// Development fixtures only; no transactions or home model mutations.
class GalleryUiV2Screen extends StatefulWidget {
  const GalleryUiV2Screen({super.key, this.pack});
  final ArtPack? pack;
  @override
  State<GalleryUiV2Screen> createState() => _GalleryUiV2ScreenState();
}

class _GalleryUiV2ScreenState extends State<GalleryUiV2Screen> {
  String? language;
  int area = 0, nav = 0;
  late final Future<ArtPack> pack = widget.pack == null
      ? ArtPack.load()
      : Future.value(widget.pack);
  @override
  Widget build(BuildContext context) => Theme(
    data: KoUi.theme(),
    child: Localizations.override(
      context: context,
      locale: language == null
          ? Localizations.localeOf(context)
          : Locale(language!),
      child: Builder(builder: _build),
    ),
  );
  Widget _build(BuildContext context) {
    final l = context.l10n;
    final areas = [l.uiAreaLounge, l.uiAreaDining, l.uiAreaPlay, l.uiAreaCare];
    void sheet() => showUiSheet<void>(
      context,
      title: l.uiViewActivity,
      closeLabel: l.close,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.uiActivityNote, style: KoUi.body),
          const SizedBox(height: KoUi.s16),
          for (var i = 0; i < 12; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: KoUi.s12),
              child: UiChip(label: areas[i % 4], icon: Icons.pets),
            ),
        ],
      ),
      footer: Builder(
        builder: (sheetContext) => UiButton(
          label: l.uiInvite,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                key: const ValueKey('ui-v2-scroll'),
                padding: const EdgeInsets.all(KoUi.s16),
                children: [
                  Text('Fondasi UI v2', style: KoUi.display),
                  Text('Pratinjau komponen · data contoh', style: KoUi.small),
                  DropdownButton<String>(
                    value:
                        language ??
                        Localizations.localeOf(context).languageCode,
                    isExpanded: true,
                    items: [
                      for (final code in ['id', 'en', 'pt', 'ru'])
                        DropdownMenuItem(
                          value: code,
                          child: Text(code.toUpperCase()),
                        ),
                    ],
                    onChanged: (v) => setState(() => language = v),
                  ),
                  UiHeader(
                    title: appName,
                    balanceLabel: '99999',
                    onBalance: sheet,
                    settingsLabel: l.settings,
                    onSettings: sheet,
                  ),
                  const SizedBox(height: KoUi.s16),
                  UiAreaTabs(
                    labels: areas,
                    selected: area,
                    onChanged: (v) => setState(() => area = v),
                  ),
                  const SizedBox(height: KoUi.s12),
                  Text(areas[area], style: KoUi.heading),
                  const SizedBox(height: KoUi.s12),
                  FutureBuilder<ArtPack>(
                    future: pack,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Aset pratinjau gagal dimuat. Buka ulang galeri.',
                        );
                      }
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 240,
                          child: Center(child: Text('Memuat aset…')),
                        );
                      }
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              KoUi.cardRadius,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CustomPaint(
                                painter: _UiArt(
                                  snapshot.data!,
                                  area: ArtArea.values[area],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: KoUi.s16),
                          UiCatCard(
                            name: 'Oyen',
                            status: areas[area],
                            action: l.uiViewActivity,
                            onPressed: sheet,
                            portrait: CustomPaint(
                              painter: _UiArt(snapshot.data!),
                            ),
                            needs: [
                              UiNeed(
                                label: l.needHunger,
                                value: 15,
                                lowLabel: l.uiLowNeed,
                                icon: Icons.restaurant,
                              ),
                              UiNeed(
                                label: l.needJoy,
                                value: 80,
                                lowLabel: l.uiLowNeed,
                                icon: Icons.favorite_border,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: KoUi.s24),
                  Text('Keadaan komponen', style: KoUi.title),
                  const SizedBox(height: KoUi.s12),
                  UiChip(label: l.uiAreaLounge, icon: Icons.pets),
                  const SizedBox(height: KoUi.s12),
                  UiButton(label: l.uiInvite, onPressed: sheet),
                  const SizedBox(height: KoUi.s12),
                  UiButton(label: l.uiInvite, onPressed: null),
                  const SizedBox(height: KoUi.s12),
                  UiButton(
                    label: l.uiInviting,
                    loading: true,
                    onPressed: sheet,
                  ),
                  const SizedBox(height: KoUi.s12),
                  UiButton(
                    label: l.cancel,
                    kind: UiButtonKind.danger,
                    onPressed: sheet,
                  ),
                  const SizedBox(height: KoUi.s24),
                  Wrap(
                    spacing: KoUi.s8,
                    runSpacing: KoUi.s8,
                    children: [
                      for (final entry in {
                        'cream': KoUi.cream,
                        'paper': KoUi.paper,
                        'peach': KoUi.peach,
                        'honey': KoUi.honey,
                        'orange': KoUi.orange,
                        'ink': KoUi.ink,
                        'success': KoUi.success,
                        'water': KoUi.water,
                        'danger': KoUi.danger,
                      }.entries)
                        Container(
                          padding: const EdgeInsets.all(KoUi.s12),
                          decoration: KoUi.card(color: entry.value),
                          child: Text(
                            entry.key,
                            style: KoUi.small.copyWith(
                              color:
                                  [
                                    KoUi.ink,
                                    KoUi.success,
                                    KoUi.danger,
                                  ].contains(entry.value)
                                  ? KoUi.paper
                                  : KoUi.ink,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: KoUi.s24),
                  Text('Типографика · Oyen · Coleção', style: KoUi.heading),
                  Text('Nunito 16/22 · Fredoka 20/26', style: KoUi.body),
                  Text('14/20 · 12/18', style: KoUi.caption),
                ],
              ),
            ),
            Container(
              color: KoUi.cream,
              padding: const EdgeInsets.all(KoUi.s12),
              child: UiNavigation(
                puzzleLabel: l.uiPlayPuzzle,
                labels: [l.uiHome, l.uiCollection, l.uiShop],
                selected: nav,
                onPuzzle: sheet,
                onChanged: (v) => setState(() => nav = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UiArt extends CustomPainter {
  const _UiArt(this.pack, {this.area});
  final ArtPack pack;
  final ArtArea? area;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / (area == null ? 128 : 390),
      size.height / (area == null ? 128 : 390),
    );
    if (area == null) {
      const CatRig().paint(canvas, pack, portrait: true);
    } else {
      paintAreaArt(canvas, pack, area!);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_UiArt old) => old.pack != pack || old.area != area;
}
