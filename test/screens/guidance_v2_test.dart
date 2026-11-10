import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/rules.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/coins/coin_sheet.dart';
import 'package:kucing_oren/screens/level/hint_sheet.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/screens/level/rules_sheet.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';
import 'package:kucing_oren/screens/room/home_help.dart';
import 'package:kucing_oren/screens/room/room_screen.dart';
import 'package:kucing_oren/screens/settings/settings_parts.dart';
import 'package:kucing_oren/screens/settings/settings_screen.dart';
import 'package:kucing_oren/theme/puzzle_theme.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../test_helpers.dart';
import '../app/household_progress_test.dart' show AtomicTestStore;

final _capture = GlobalKey();
const _export = bool.fromEnvironment('GUIDANCE_REVIEW');

Future<void> _picture(WidgetTester t, String name) async {
  if (!_export) return;
  await t.runAsync(() async {
    final boundary =
        _capture.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await boundary.toImage();
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final f = File('docs/design-v2/guidance/$name.png');
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes!.buffer.asUint8List());
    img.dispose();
  });
}

Widget _app(
  Widget child,
  ProgressController c,
  GameAudio audio,
  String lang,
  double scale,
) => ProgressScope(
  progress: c,
  child: AudioScope(
    audio: audio,
    child: MaterialApp(
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: puzzleTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: RepaintBoundary(
        key: _capture,
        child: Scaffold(
          body: KeyedSubtree(key: UniqueKey(), child: child),
        ),
      ),
    ),
  ),
);

class _Ad implements RewardedAds {
  final done = Completer<bool>();
  int calls = 0;
  @override
  Future<bool> show() {
    calls++;
    return done.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => PackageInfo.setMockInitialValues(
      appName: appName,
      packageName: 'com.gingerlogic.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    ),
  );
  setUpAll(() async {
    for (final e in {
      'NunitoUi': 'Nunito-Variable.ttf',
      'Fredoka': 'Fredoka-SemiBold.ttf',
    }.entries) {
      await (FontLoader(
        e.key,
      )..addFont(rootBundle.load('assets/fonts/${e.value}'))).load();
    }
  });

  for (final size in const [Size(360, 640), Size(390, 844), Size(412, 915)]) {
    for (final lang in ['id', 'en', 'pt', 'ru']) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'guidance ${size.width} $lang $scale wraps and reaches last actions',
          (t) async {
            setScreenSize(t, size);
            final c = testProgressWith(coins: 99999);
            final opened = testProgressWith(coins: 99999, hints: {13: 3});
            final audio = testAudio();
            final capture =
                (lang == 'id' && size.width == 390 && scale == 1) ||
                (lang == 'ru' && size.width == 360 && scale == 1.3);
            final tag = '$lang-${(scale * 100).round()}-${size.width.round()}';
            final states = <String, Widget>{
              'settings': const SettingsScreen(),
              'rules': RulesSheet(
                learned: OyenRule.values.toSet(),
                onClose: () {},
              ),
              'rules-locked': RulesSheet(
                learned: const {OyenRule.knock},
                onClose: () {},
              ),
              'hints': HintSheet(
                level: testLevels[12],
                hints: c,
                onClose: () {},
              ),
              'hints-open': HintSheet(
                level: testLevels[12],
                hints: opened,
                onClose: () {},
              ),
              'hints-free': HintSheet(
                level: testLevels.first,
                hints: c,
                onClose: () {},
              ),
              'coins': CoinSheet(progress: c, onClose: () {}),
              'reset': ResetSheet(onClose: () {}, onConfirm: () {}),
              for (final id in [1, 3, 6])
                'tutorial$id': LevelView(
                  level: testLevels[id - 1],
                  backLabel: 'Back',
                  onBack: () {},
                  onNext: () {},
                  tutorial: tutorialFor(id),
                  onTutorialDone: () {},
                ),
            };
            for (final state in states.entries) {
              await t.pumpWidget(_app(state.value, c, audio, lang, scale));
              await t.pumpAndSettle();
              expect(t.takeException(), isNull, reason: state.key);
              if (capture) await _picture(t, '${state.key}-$tag');
              final scrolls = find.byType(SingleChildScrollView);
              if (scrolls.evaluate().isNotEmpty) {
                await t.drag(scrolls.first, const Offset(0, -2200));
                await t.pumpAndSettle();
                expect(
                  t.takeException(),
                  isNull,
                  reason: '${state.key} scrolled',
                );
                if (capture &&
                    ['settings', 'rules', 'hints'].contains(state.key)) {
                  await _picture(t, '${state.key}-bottom-$tag');
                }
              }
              if (state.key == 'settings') {
                final l = AppLocalizations.of(_capture.currentContext!);
                expect(find.text(l.licenses).hitTestable(), findsOneWidget);
              }
              if (state.key == 'hints') {
                final l = AppLocalizations.of(_capture.currentContext!);
                expect(find.text(l.coinsTitle).hitTestable(), findsOneWidget);
              }
              if (state.key == 'reset') {
                final l = AppLocalizations.of(_capture.currentContext!);
                expect(find.text(l.resetConfirm).hitTestable(), findsOneWidget);
              }
            }
            await t.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }

  testWidgets(
    'reset failure stays in sheet and cancellation preserves all areas',
    (t) async {
      final store = AtomicTestStore()
        ..coins = 170
        ..language = AppLanguage.id;
      final c = await ProgressController.load(levels: testLevels, store: store);
      await pumpApp(t, progress: c, location: AppRoutes.settings);
      final before = store.snapshot.toString();
      await t.ensureVisible(find.text(l10nId.resetProgress));
      await t.tap(find.text(l10nId.resetProgress));
      await settle(t);
      expect(c.householdPaused, isTrue);
      store.fail = true;
      await t.ensureVisible(find.text(l10nId.resetConfirm));
      await t.tap(find.text(l10nId.resetConfirm));
      await settle(t);
      expect(find.text(l10nId.guidanceSaveFailed), findsOneWidget);
      expect(c.coins, 170);
      expect(store.snapshot.toString(), before);
      await t.tap(find.text(l10nId.cancel));
      await settle(t);
      expect(find.byType(ResetSheet), findsNothing);
      expect(c.coins, 170);
    },
  );

  testWidgets('pending coin ad announces loading, cancellation adds no coins', (
    t,
  ) async {
    final ads = _Ad();
    final c = testProgressWith(ads: ads);
    setScreenSize(t, const Size(360, 640));
    await t.pumpWidget(
      _app(CoinSheet(progress: c, onClose: () {}), c, testAudio(), 'id', 1.3),
    );
    await t.pumpAndSettle();
    final button = find.text(l10nId.adRewardButton(20));
    await t.ensureVisible(button);
    await t.tap(button);
    await t.pump();
    expect(find.text(l10nId.guidanceLoading), findsOneWidget);
    final action = t.widget<UiButton>(
      find.ancestor(of: button, matching: find.byType(UiButton)),
    );
    expect(action.onPressed, isNull);
    ads.done.complete(false);
    await t.pumpAndSettle();
    expect(find.text(l10nId.adFailed), findsOneWidget);
    expect(c.coins, 0);
    expect(c.adsLeft, maxAdsPerDay);
  });

  testWidgets(
    'saved reduce motion reaches tutorial and system preference remains on',
    (t) async {
      final store = AtomicTestStore();
      final c = await ProgressController.load(levels: testLevels, store: store);
      await c.setLanguage(AppLanguage.id);
      await c.setReducedMotion(true);
      await pumpApp(t, progress: c, location: AppRoutes.level(1, chapter: 1));
      expect(
        MediaQuery.disableAnimationsOf(t.element(find.byType(TutorialOverlay))),
        isTrue,
      );
      expect(find.text(l10nId.skip).hitTestable(), findsOneWidget);
    },
  );

  testWidgets(
    'home introduction is optional and repeatable; closing keeps puzzle available',
    (t) async {
      await pumpApp(t);
      final context = t.element(find.byType(RoomScreen));
      for (var i = 0; i < 2; i++) {
        unawaited(showHomeHelp(context));
        await settle(t);
        expect(find.text(l10nId.guidanceHomeBody), findsOneWidget);
        await t.binding.handlePopRoute();
        await settle(t);
        expect(find.text(l10nId.uiPlayPuzzle).hitTestable(), findsOneWidget);
      }
    },
  );
  testWidgets(
    'opened hint text meets normal-text contrast on its actual panel',
    (t) async {
      final c = testProgressWith(hints: {13: 3});
      await t.pumpWidget(
        _app(
          HintSheet(level: testLevels[12], hints: c, onClose: () {}),
          c,
          testAudio(),
          'id',
          1,
        ),
      );
      await t.pumpAndSettle();
      final text = find.text(
        'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.',
      );
      final foreground = t.widget<Text>(text).style!.color!;
      Color? background;
      t.element(text).visitAncestorElements((element) {
        final w = element.widget;
        if (w is Container && w.decoration is BoxDecoration) {
          final box = w.decoration! as BoxDecoration;
          if (box.color != null) {
            background = box.color;
            return false;
          }
        }
        return true;
      });
      expect(background, isNotNull);
      final a = foreground.computeLuminance(),
          b = background!.computeLuminance();
      expect(
        ((a > b ? a : b) + .05) / ((a < b ? a : b) + .05),
        greaterThanOrEqualTo(4.5),
      );
    },
  );
}
