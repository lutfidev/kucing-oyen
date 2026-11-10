import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/run_frames.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/svg_template.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/cat_rig.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/screens/room/home_view.dart';

import '../../tool/profile_fixture.dart';
import '../test_helpers.dart';
import 'result_fixtures.dart';

const _export = bool.fromEnvironment('POLISH_REVIEW');
const _profile = bool.fromEnvironment('POLISH_PROFILE');

void main() {
  late ArtPack pack;
  setUpAll(() async {
    pack = await ArtPack.load();
    for (final entry in {
      'NunitoUi': 'Nunito-Variable.ttf',
      'Fredoka': 'Fredoka-SemiBold.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load('assets/fonts/${entry.value}'))).load();
    }
  });

  for (final variant in ['id', 'ru']) {
    testWidgets(
      'full v2 house $variant: safe capacity, labels, touch targets and large text',
      (t) async {
        setScreenSize(
          t,
          variant == 'id' ? const Size(390, 844) : const Size(360, 640),
        );
        t.platformDispatcher.textScaleFactorTestValue = variant == 'id'
            ? 1
            : 1.3;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final c = await profileProgress(levels);
        await c.setLanguage(variant == 'id' ? AppLanguage.id : AppLanguage.ru);
        final key = GlobalKey();
        final semantics = t.ensureSemantics();
        await t.pumpWidget(
          RepaintBoundary(
            key: key,
            child: KucingOrenApp(
              progress: c,
              roomLife: false,
              homeBuilder: (_) =>
                  HomeView(progress: c, life: false, loadArt: () async => pack),
            ),
          ),
        );
        await t.pump();
        await t.runAsync(() async {
          final context = t.element(find.byType(HomeView));
          for (final image in [
            PaintedScenery.lounge,
            PaintedScenery.dining,
            PaintedScenery.play,
            PaintedScenery.care,
          ]) {
            await precacheImage(image, context);
          }
        });
        expect(c.home.kitties.length, 9);
        expect(
          c.household.areas.placed.values.toSet().length,
          c.household.areas.placed.length,
        );
        for (final area in HomeArea.values) {
          expect(c.household.routine.present(area).length, area.capacity);
          await c.setHomeArea(area);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(t, meetsGuideline(androidTapTargetGuideline));
          if (_export) {
            await t.runAsync(() async {
              final boundary =
                  key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                'docs/design-v2/polish/${area.name}-$variant.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
        await t.pumpWidget(const SizedBox());
        semantics.dispose();
        c.dispose();
      },
    );
  }

  testWidgets('host renderer diagnostic (not device FPS)', (t) async {
    await t.runAsync(() async {
      final c = await profileProgress(levels);
      final frames = runFrames(
        levels[12].board,
        resultOf(levels[12], levels[12].solution).result!,
      );
      final output = <String, Object>{
        'kind': 'host_debug_picture_recording_not_device_fps',
        'os': Platform.operatingSystem,
        'dart': Platform.version,
        'pack_parts': pack.parts.length,
        'source_bytes': pack.sourceBytes,
        'owned_items': c.home.room.owned.length,
        'placed_items': c.household.areas.placed.length,
        'stored_items':
            c.home.room.owned.length - c.household.areas.placed.length,
      };
      Map<String, Object> measure(void Function(Canvas, int) draw) {
        final times = <double>[];
        for (var i = 0; i < 330; i++) {
          final watch = Stopwatch()..start();
          final recorder = ui.PictureRecorder();
          draw(Canvas(recorder), i);
          recorder.endRecording().dispose();
          watch.stop();
          if (i >= 30) times.add(watch.elapsedMicroseconds / 1000);
        }
        times.sort();
        return {
          'samples': times.length,
          'mean_ms': times.reduce((a, b) => a + b) / times.length,
          'p90_ms': times[(times.length * .9).floor()],
          'p99_ms': times[(times.length * .99).floor()],
        };
      }

      final rss = ProcessInfo.currentRss;
      for (final motion in [
        CatMotion.idle,
        CatMotion.walk,
        CatMotion.eat,
        CatMotion.play,
        CatMotion.brush,
      ]) {
        output['nine_${motion.name}'] = measure((canvas, frame) {
          for (final cat in KittyId.values) {
            CatRig(
              cat: cat,
              motion: motion,
              time: frame / 60,
              accessory: c.home.closet.wearingOf(cat),
            ).paint(canvas, pack);
          }
        });
      }
      output['puzzle_run_13'] = measure((canvas, frame) {
        paintBoard(
          canvas,
          runScene(
            levels[12].map,
            levels[12].solution,
            frames,
            frame % frames.length,
          ),
        );
      });
      output['rss_before_bytes'] = rss;
      output['rss_after_bytes'] = ProcessInfo.currentRss;
      output['svg_paths'] = SvgTemplate.cachedPaths;
      expect(
        SvgTemplate.cachedPaths,
        lessThanOrEqualTo(SvgTemplate.pathCacheLimit),
      );
      final file = File('docs/design-v2/polish/host-profile.json');
      await file.parent.create(recursive: true);
      await file.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(output)}\n',
      );
      c.dispose();
    });
  }, skip: !_profile);
}
