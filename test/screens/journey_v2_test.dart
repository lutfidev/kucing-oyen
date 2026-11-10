import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/render/v2/cat_rig.dart';
import 'package:kucing_oren/game/render/v2/journey_art.dart';
import 'package:kucing_oren/game/render/v2/puzzle_cat_sources.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

final _captureKey = GlobalKey();
const _export = bool.fromEnvironment('JOURNEY_REVIEW');

Future<void> _capture(WidgetTester t, String name) async {
  if (!_export) return;
  await t.runAsync(() async {
    final boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/design-v2/journey/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Widget _app(
  Widget child, {
  String lang = 'id',
  double scale = 1,
  bool still = true,
}) => MaterialApp(
  locale: Locale(lang),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: KoUi.theme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: still),
    child: child!,
  ),
  home: RepaintBoundary(
    key: _captureKey,
    child: Scaffold(body: child),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'NunitoUi': 'Nunito-Variable.ttf',
      'Fredoka': 'Fredoka-SemiBold.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load('assets/fonts/${entry.value}'))).load();
    }
  });

  for (final size in const [Size(360, 640), Size(390, 844), Size(412, 915)]) {
    for (final lang in ['id', 'en', 'pt', 'ru']) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'journey ${size.width} $lang $scale all states and reachable actions',
          (t) async {
            setScreenSize(t, size);
            final chapters = chaptersOf(levels);
            final screens = <String, Widget>{
              for (final ch in chapters)
                'map${ch.number}': ChapterView(
                  chapter: ch,
                  other: ch == chapters.first ? chapters.last : chapters.first,
                  progress: Progress({
                    for (var i = 1; i <= (ch.number == 1 ? 4 : 14); i++)
                      i: i % 3 + 1,
                  }),
                  onBack: () {},
                  onOpen: (_) {},
                  onPlay: (_) {},
                  oyenAccessory: AccessoryId.mahkotaRaja,
                ),
              'locked': ChapterView(
                chapter: chapters.last,
                other: chapters.first,
                progress: Progress(),
                onBack: () {},
                onOpen: (_) {},
                onPlay: (_) {},
              ),
              'intro': ChapterView(
                chapter: chapters.last,
                other: chapters.first,
                progress: Progress({for (var i = 1; i <= 10; i++) i: 3}),
                intro: true,
                onBack: () {},
                onOpen: (_) {},
                onPlay: (_) {},
              ),
              'success': ResultView(
                session: resultOf(levels[12], levels[12].solution),
                coins: 30,
                onArrange: () {},
                onRestart: () {},
                onNext: () {},
                onReplay: () {},
              ),
              'two-stars': ResultView(
                session: resultOf(levels[14], twoStars),
                onArrange: () {},
                onRestart: () {},
                onNext: () {},
                onReplay: () {},
              ),
              'vase': ResultView(
                session: resultOf(levels[12], fishOnly),
                coins: 10,
                onArrange: () {},
                onRestart: () {},
                onNext: () {},
                onReplay: () {},
              ),
              'loop': ResultView(
                session: resultOf(levels[12]),
                onArrange: () {},
                onRestart: () {},
                onNext: () {},
                onReplay: () {},
              ),
              'limit': ResultView(
                session: resultOf(longWalk),
                onArrange: () {},
                onRestart: () {},
                onNext: () {},
                onReplay: () {},
              ),
              'replay': ReplayView(
                session: resultOf(longWalk),
                onBack: () {},
                onMap: () {},
              ),
            };
            for (final entry in screens.entries) {
              // Dispose the previous session, including its animation and scroll state.
              await t.pumpWidget(const SizedBox());
              await t.pumpWidget(_app(entry.value, lang: lang, scale: scale));
              await t.pump();
              expect(t.takeException(), isNull, reason: entry.key);
              if (size.width == 360 &&
                      (lang == 'id' || (lang == 'ru' && scale == 1.3)) ||
                  size.width == 390 && lang == 'id' && scale == 1) {
                await _capture(
                  t,
                  '${entry.key}-$lang-${(scale * 100).round()}-${size.width.round()}',
                );
              }
              if (entry.key == 'replay') {
                final end = find.bySemanticsLabel(switch (lang) {
                  'id' => 'Akhir',
                  'en' => 'End',
                  'pt' => 'Fim',
                  _ => 'Конец',
                });
                await t.ensureVisible(end);
                await t.tap(end);
                await t.pumpAndSettle();
                final slider = t.widget<ReplaySlider>(
                  find.byType(ReplaySlider),
                );
                expect(slider.value, slider.max);
                if (size.width == 390 && lang == 'id' && scale == 1) {
                  await _capture(t, 'replay-end-id-390');
                }
              }
              if (['success', 'vase', 'loop', 'replay'].contains(entry.key)) {
                final l = AppLocalizations.of(
                  t.element(find.byType(Scaffold).first),
                );
                final action = find.text(switch (entry.key) {
                  'success' || 'vase' => l.watchReplay,
                  'loop' => l.arrangeAgain,
                  _ => l.backToMap,
                });
                await t.ensureVisible(action);
                await t.pump();
                expect(action.hitTestable(), findsOneWidget);
                if (size.width == 360 && lang == 'ru' && scale == 1.3) {
                  await _capture(t, '${entry.key}-actions-ru-130-360');
                }
              }
            }
          },
        );
      }
    }
  }

  testWidgets(
    'replay speed, endpoints and background pause preserve recorded result',
    (t) async {
      setScreenSize(t, const Size(390, 844));
      final session = resultOf(levels[12], levels[12].solution);
      final result = session.result;
      await t.pumpWidget(
        _app(
          ReplayView(session: session, onBack: () {}, onMap: () {}),
          still: false,
        ),
      );
      await t.pumpAndSettle();
      expect(t.widget<UiButton>(find.byType(UiButton)).label, '×1');
      await t.tap(
        find.byWidgetPredicate(
          (w) => w is UiButton && w.semanticLabel == 'Percepat dua kali',
        ),
      );
      await t.pumpAndSettle();
      expect(t.widget<UiButton>(find.byType(UiButton)).selected, isTrue);
      expect(t.widget<UiButton>(find.byType(UiButton)).label, '×2');
      await _capture(t, 'replay-speed-id-390');
      await t.tap(find.bySemanticsLabel('Putar otomatis'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 360));
      expect(t.widget<ReplaySlider>(find.byType(ReplaySlider)).value, 1);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await t.pump(const Duration(seconds: 5));
      expect(t.widget<ReplaySlider>(find.byType(ReplaySlider)).value, 1);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.tap(find.bySemanticsLabel('Akhir'));
      await t.pumpAndSettle();
      expect(
        t.widget<ReplaySlider>(find.byType(ReplaySlider)).value,
        result!.steps,
      );
      await t.tap(find.bySemanticsLabel('Awal'));
      await t.pumpAndSettle();
      expect(t.widget<ReplaySlider>(find.byType(ReplaySlider)).value, 0);
      expect(session.result, same(result));
    },
  );

  testWidgets(
    'all map accessory directions use identical source and valid anchors',
    (t) async {
      for (final entry in navigationAccessorySources.entries) {
        final source = File('assets/art/v2/${entry.key}.svg')
            .readAsStringSync();
        expect(
          entry.value,
          source.substring(
            source.indexOf('>') + 1,
            source.lastIndexOf('</svg>'),
          ),
        );
      }
      final manifest = jsonDecode(
        File('assets/art/v2/manifest.json').readAsStringSync(),
      ) as Map;
      for (final entry in navigationAccessoryMetadata.entries) {
        expect(entry.value, manifest['assets'][entry.key]);
      }
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      for (final id in AccessoryId.values) {
        for (final direction in CatDirection.values) {
          JourneyArt.cat(
            canvas,
            const Rect.fromLTWH(0, 0, 128, 128),
            accessory: id,
            direction: direction,
          );
        }
      }
      recorder.endRecording().dispose();
      if (_export) {
        final recorder = ui.PictureRecorder();
        final c = Canvas(recorder);
        c.drawRect(
          const Rect.fromLTWH(0, 0, 600, 600),
          Paint()..color = KoUi.cream,
        );
        for (final (i, object) in PictureMapArt.objects.indexed) {
          c.save();
          c.translate(20 + i % 5 * 118.0, 12 + i ~/ 5 * 105.0);
          JourneyArt.node(c, object, 64);
          final text = TextPainter(
            text: TextSpan(text: '${i + 1} · $object', style: KoUi.caption),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: 115);
          text.paint(c, const Offset(0, 65));
          text.dispose();
          c.restore();
        }
        for (final dir in CatDirection.values) {
          JourneyArt.cat(
            c,
            Rect.fromLTWH(dir.index * 145, 450, 128, 128),
            accessory: AccessoryId.mahkotaRaja,
            direction: dir,
          );
        }
        final picture = recorder.endRecording();
        await t.runAsync(() async {
          final image = await picture.toImage(600, 600);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('docs/design-v2/journey/art-catalog.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        picture.dispose();
      }
    },
  );
}
