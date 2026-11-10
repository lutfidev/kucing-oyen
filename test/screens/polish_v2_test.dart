import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_routine.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/render/svg_template.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/room/home_scene.dart';
import 'package:kucing_oren/theme/ko_ui.dart';

import '../app/household_progress_test.dart' show AtomicTestStore;
import '../test_helpers.dart';
import 'result_fixtures.dart';

void main() {
  late ArtPack pack;
  final now = DateTime(2026, 11, 10, 12);
  setUpAll(() async => pack = await ArtPack.load());

  test('dynamic SVG path parsing cache stays bounded and eviction is safe', () {
    final original = SvgTemplate('<path d="M0 0 L1 1" fill="#000"/>')
        .render({});
    for (var i = 0; i < 1200; i++) {
      SvgTemplate('<path d="M0 0 L${i + 2} 1" fill="#000"/>').render({});
    }
    expect(SvgTemplate.cachedPaths, SvgTemplate.pathCacheLimit);
    final rebuilt = SvgTemplate('<path d="M0 0 L1 1" fill="#000"/>').render({});
    expect(rebuilt.bounds, original.bounds);
    expect(SvgTemplate.cachedPaths, SvgTemplate.pathCacheLimit);
  });

  testWidgets('covered replay stops until explicitly played again', (t) async {
    setScreenSize(t, const Size(390, 844));
    late StateSetter rebuild;
    var visible = true;
    await t.pumpWidget(
      testApp(
        home: StatefulBuilder(
          builder: (context, set) {
            rebuild = set;
            return TickerMode(
              enabled: visible,
              child: ReplayView(
                session: resultOf(levels[12], levels[12].solution),
                onBack: () {},
                onMap: () {},
              ),
            );
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    int step() => t.widget<ReplaySlider>(find.byType(ReplaySlider)).value;
    await t.tap(find.bySemanticsLabel('Putar otomatis'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    rebuild(() => visible = false);
    await t.pump();
    await t.pump(const Duration(seconds: 10));
    expect(step(), 0);
    rebuild(() => visible = true);
    await t.pump();
    await t.pump(const Duration(seconds: 2));
    expect(step(), 0);
    await t.tap(find.bySemanticsLabel('Putar otomatis'));
    await t.pump();
    await t.pump(ReplayView.autoStepTime);
    expect(step(), 1);
  });

  testWidgets(
    'house cues follow committed visible actions once, also in still mode',
    (t) async {
      setScreenSize(t, const Size(390, 844));
      final store = AtomicTestStore()
        ..home = Home(kitties: KittyId.values)
        ..needs = HomeNeeds(
          cats: {
            for (final cat in KittyId.values)
              cat: CatNeeds(hunger: 40, joy: 40, at: now),
          },
        );
      final c = await ProgressController.load(
        levels: testLevels,
        store: store,
        clock: () => now,
      );
      final player = FakeSoundPlayer();
      final audio = GameAudio(player: player, store: store);
      await c.setHomeArea(HomeArea.makan);
      await t.pumpWidget(
        testApp(
          audio: audio,
          home: Scaffold(
            body: AnimatedBuilder(
              animation: c,
              builder: (context, _) => SizedBox(
                width: 390,
                height: 390,
                child: HomeScene(
                  pack: pack,
                  progress: c,
                  area: c.household.lastArea,
                  selected: null,
                  onSelect: (_) {},
                  animate: false,
                ),
              ),
            ),
          ),
        ),
      );
      await t.pump();
      final cat = c.household.routine.present(HomeArea.makan).first;
      await c.inviteKitty(cat, HomeActivity.eat);
      await c.advanceHousehold(0);
      await t.pump();
      await c.advanceHousehold(1);
      await t.pump();
      expect(c.household.routine.activities[cat]?.kind, HomeActivity.eat);
      expect(player.played, [GameSound.munch]);
      await c.advanceHousehold(.25);
      await t.pump();
      expect(player.played, [GameSound.munch]);
      c.pauseHousehold(HouseholdPause.ad);
      await c.setHomeArea(HomeArea.rawat);
      await t.pump();
      expect(player.played, [GameSound.munch]);
      c.resumeHousehold(HouseholdPause.ad);
      await t.pumpWidget(const SizedBox());
      c.dispose();
    },
  );

  testWidgets('house handles zero viewport and preserves phase across pause', (
    t,
  ) async {
    setScreenSize(t, const Size(390, 844));
    final c = await ProgressController.load(
      levels: testLevels,
      store: AtomicTestStore(),
      clock: () => now,
    );
    late StateSetter rebuild;
    var size = Size.zero;
    await t.pumpWidget(
      testApp(
        home: Center(
          child: StatefulBuilder(
            builder: (context, set) {
              rebuild = set;
              return SizedBox.fromSize(
                size: size,
                child: HomeScene(
                  pack: pack,
                  progress: c,
                  area: HomeArea.santai,
                  selected: KittyId.oyen,
                  onSelect: (_) {},
                  animate: true,
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    rebuild(() => size = const Size(390, 390));
    await t.pump();
    await t.pump(const Duration(milliseconds: 350));
    HomeCatPainter painter() => t
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((p) => p.painter)
        .whereType<HomeCatPainter>()
        .first;
    final time = painter().time!.value;
    c.pauseHousehold(HouseholdPause.background);
    await t.pump(const Duration(seconds: 10));
    expect(painter().time!.value, time);
    c.resumeHousehold(HouseholdPause.background);
    await t.pump();
    expect(painter().time!.value, time);
    await t.pump(const Duration(milliseconds: 100));
    expect(painter().time!.value, closeTo(time + .1, .001));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    c.dispose();
  });

  test('v2 enabled text and status tokens meet contrast for normal text', () {
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
    }

    for (final background in [KoUi.paper, KoUi.cream, KoUi.homePaper]) {
      for (final foreground in [
        KoUi.ink,
        KoUi.mutedInk,
        KoUi.danger,
        KoUi.success,
      ]) {
        expect(ratio(foreground, background), greaterThanOrEqualTo(4.5));
      }
    }
    expect(ratio(KoUi.ink, KoUi.orange), greaterThanOrEqualTo(4.5));
  });
}
