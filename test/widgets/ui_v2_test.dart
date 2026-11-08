import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/gallery/gallery_ui_v2_screen.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';
import 'package:kucing_oren/widgets/v2/ui_components.dart';
import 'package:kucing_oren/widgets/v2/ui_sheet.dart';

import '../test_helpers.dart';

Widget app(Widget home, {String locale = 'id'}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: KoUi.theme(),
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

Future<void> export(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UI_REVIEW')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('capture')),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/design-v2/ui/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  late ArtPack pack;
  setUpAll(() async {
    pack = await ArtPack.load();
  });
  test('normal text combinations meet 4.5:1 including button states', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
    }

    for (final bg in [
      KoUi.orange,
      KoUi.paper,
      KoUi.cream,
      KoUi.peach,
      KoUi.honey,
      KoUi.water,
    ]) {
      expect(contrast(KoUi.ink, bg), greaterThanOrEqualTo(4.5));
    }
    expect(contrast(KoUi.mutedInk, KoUi.paper), greaterThanOrEqualTo(4.5));
    for (final bg in [KoUi.danger, KoUi.success]) {
      expect(contrast(KoUi.paper, bg), greaterThanOrEqualTo(4.5));
    }
  });
  testWidgets('button press, cancellation, keyboard, disabled and loading', (
    tester,
  ) async {
    var calls = 0;
    Future<void> pump({bool loading = false, bool enabled = true}) =>
        tester.pumpWidget(
          app(
            Scaffold(
              body: Center(
                child: UiButton(
                  label: loading ? 'Mengundang' : 'Ajak',
                  loading: loading,
                  autofocus: true,
                  onPressed: enabled ? () => calls++ : null,
                ),
              ),
            ),
          ),
        );
    await pump();
    await settle(tester);
    final semantics = tester.ensureSemantics();

    expect(
      tester.getSize(find.byType(UiButton)).height,
      greaterThanOrEqualTo(48),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(UiButton)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    final box = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(box.transform!.storage[13], 3);
    expect(box.decoration, isA<BoxDecoration>());
    expect((box.decoration! as BoxDecoration).color, KoUi.orange);
    await gesture.cancel();
    await settle(tester);
    expect(calls, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(calls, 1);
    await tester.tap(find.byType(UiButton));
    expect(calls, 2);
    await pump(loading: true);
    await tester.pump();
    await tester.tap(find.byType(UiButton));
    expect(calls, 2);
    expect(
      tester.getSemantics(find.byType(UiButton)),
      matchesSemantics(
        label: 'Mengundang',
        isButton: true,
        hasEnabledState: true,
        isLiveRegion: true,
      ),
    );
    await pump(enabled: false);
    await settle(tester);
    await tester.tap(find.byType(UiButton));
    expect(calls, 2);
    expect(find.byIcon(Icons.block), findsOneWidget);
    semantics.dispose();
  });
  for (final locale in ['id', 'en', 'pt', 'ru']) {
    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(412, 915),
    ]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          '$locale $size text $scale: gallery, tabs, sheet and pinned actions',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await tester.pumpWidget(
              RepaintBoundary(
                key: const ValueKey('capture'),
                child: app(GalleryUiV2Screen(pack: pack), locale: locale),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
            final context = tester.element(find.byType(UiHeader));
            final l = AppLocalizations.of(context);
            final puzzle = find.text(l.uiPlayPuzzle);
            expect(puzzle.hitTestable(), findsOneWidget);
            for (final paragraph
                in find
                    .descendant(
                      of: find.byType(UiNavigation),
                      matching: find.byType(RichText),
                    )
                    .evaluate()) {
              final render = paragraph.renderObject! as RenderParagraph;
              final painter = TextPainter(
                text: render.text,
                textDirection: TextDirection.ltr,
                textScaler: render.textScaler,
              )..layout(maxWidth: render.size.width);
              expect(painter.computeLineMetrics().length, 1);
            }
            if (size.width == 360 && scale == 1.3) {
              await export(tester, '$locale-small');
            }
            // Programmatic selection must reveal the complete final tab.
            final tabs = tester.widget<UiAreaTabs>(find.byType(UiAreaTabs));
            tabs.onChanged(3);
            await tester.pump();
            await settle(tester);
            final care = find.descendant(
              of: find.byType(UiAreaTabs),
              matching: find.text(l.uiAreaCare),
            );
            expect(care.hitTestable(), findsOneWidget);
            await tester.tap(puzzle);
            await settle(tester);
            expect(find.byType(UiSheet), findsOneWidget);
            final confirm = find.descendant(
              of: find.byType(UiSheet),
              matching: find.text(l.uiInvite),
            );
            expect(confirm.hitTestable(), findsOneWidget);
            final sheetBox = tester.getRect(find.byType(UiSheet));
            expect(sheetBox.height, lessThanOrEqualTo(size.height * .9 + 1));
            if (locale == 'ru' && size.width == 360 && scale == 1.3) {
              await export(tester, 'ru-sheet');
            }
            await tester.drag(
              find.descendant(
                of: find.byType(UiSheet),
                matching: find.byType(SingleChildScrollView),
              ),
              const Offset(0, -900),
            );
            await settle(tester);
            expect(confirm.hitTestable(), findsOneWidget);
            await tester.tap(confirm);
            await settle(tester);
            expect(find.byType(UiSheet), findsNothing);
            await tester.scrollUntilVisible(
              find.byType(UiCatCard),
              200,
              scrollable: find
                  .descendant(
                    of: find.byKey(const ValueKey('ui-v2-scroll')),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            await tester.ensureVisible(find.byType(UiCatCard));
            await tester.pump();
            if (size.width == 360 && scale == 1.3) {
              await export(tester, '$locale-card');
            }
            await tester.scrollUntilVisible(
              find.text(l.cancel),
              200,
              scrollable: find
                  .descendant(
                    of: find.byKey(const ValueKey('ui-v2-scroll')),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            await tester.ensureVisible(find.text(l.cancel));
            await tester.pump();
            if (locale == 'id' && size.width == 360 && scale == 1.3) {
              await export(tester, 'id-tokens');
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
  testWidgets('component state review with scaled text', (tester) async {
    setScreenSize(tester, const Size(390, 844));
    setTextScale(tester, 1.3);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('capture'),
        child: app(
          Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(KoUi.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tombol & status', style: KoUi.title),
                    const SizedBox(height: KoUi.s16),
                    UiButton(label: 'Ajak ke area', onPressed: () {}),
                    const SizedBox(height: KoUi.s16),
                    const UiButton(label: 'Ajak ke area', onPressed: null),
                    const SizedBox(height: KoUi.s16),
                    UiButton(
                      label: 'Mengundang...',
                      loading: true,
                      onPressed: () {},
                    ),
                    const SizedBox(height: KoUi.s16),
                    UiButton(
                      label: 'Batal',
                      kind: UiButtonKind.danger,
                      onPressed: () {},
                    ),
                    const SizedBox(height: KoUi.s24),
                    const UiChip(
                      label: 'Sedang beristirahat',
                      icon: Icons.pets,
                    ),
                    const SizedBox(height: KoUi.s16),
                    const UiNeed(
                      label: 'Lapar',
                      value: 15,
                      lowLabel: 'Kebutuhan rendah',
                      icon: Icons.restaurant,
                    ),
                    const SizedBox(height: KoUi.s16),
                    const UiNeed(
                      label: 'Senang',
                      value: 80,
                      lowLabel: 'Kebutuhan rendah',
                      icon: Icons.favorite_border,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await export(tester, 'id-states');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'reduced motion uses a static loading glyph; sheet restores trigger focus',
    (tester) async {
      final trigger = FocusNode();
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Scaffold(
                body: Column(
                  children: [
                    const UiButton(
                      label: 'Loading',
                      loading: true,
                      onPressed: null,
                    ),
                    Focus(
                      focusNode: trigger,
                      child: Builder(
                        builder: (context) => UiButton(
                          label: 'Open',
                          onPressed: () => showUiSheet<void>(
                            context,
                            title: 'Details',
                            closeLabel: 'Close',
                            body: const Text('Body'),
                            footer: const Text('Footer'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      trigger.requestFocus();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      await tester.tap(find.text('Open'));
      await settle(tester);
      await tester.tap(find.text('Close'));
      await settle(tester);
      expect(trigger.hasFocus, true);
      await tester.pumpWidget(const SizedBox());
      trigger.dispose();
    },
  );
  testWidgets(
    'need status has value and warning semantics; text scales without clipping',
    (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        app(
          const Scaffold(
            body: UiNeed(
              label: 'Lapar',
              value: 15,
              lowLabel: 'Rendah',
              icon: Icons.restaurant,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Lapar'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Lapar')),
        matchesSemantics(label: 'Lapar', value: '15%, Rendah'),
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      handle.dispose();
    },
  );
}
