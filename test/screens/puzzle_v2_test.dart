import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/puzzle_art.dart';
import 'package:kucing_oren/game/render/v2/puzzle_cat_sources.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

final levels = parseLevels(
  File('assets/levels/chapter1-2.json').readAsStringSync(),
);
final captureKey = GlobalKey();

Future<void> capture(WidgetTester t, String name) async {
  if (!const bool.fromEnvironment('PUZZLE_REVIEW')) return;
  await t.runAsync(() async {
    final boundary =
        captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/design-v2/puzzle/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'NunitoUi': 'assets/fonts/Nunito-Variable.ttf',
      'Fredoka': 'assets/fonts/Fredoka-SemiBold.ttf',
    }.entries) {
      if (!File(entry.value).existsSync()) continue;
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
  });

  test('embedded Oyen remains identical to the house asset sources', () {
    expect(puzzleCatSources.length, 4 + ArtPack.expressions.length);
    for (final entry in puzzleCatSources.entries) {
      final svg = File('assets/art/v2/${entry.key}.svg').readAsStringSync();
      expect(
        entry.value,
        svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>')),
      );
    }
  });

  testWidgets('runtime vectors cover all cells, directions and poses', (
    t,
  ) async {
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);
    for (final kind in TileKind.values) {
      for (final item in TileItem.values) {
        c.save();
        c.translate(kind.index * 60.0 + 5, item.index * 60.0 + 5);
        paintPuzzleTile(
          c,
          Tile(kind: kind, item: item, glow: true),
          glowOpacity: .5,
        );
        c.restore();
      }
    }
    for (final item in Item.values) {
      c.save();
      c.translate(item.index * 60.0 + 5, 425);
      paintPuzzleTile(c, Tile(glow: true, ghost: item));
      c.restore();
    }
    for (final pose in OyenPose.values) {
      for (final dir in Direction.values) {
        for (final bubble in OyenBubble.values) {
          c.save();
          c.translate(pose.index * 75.0, 480 + dir.index * 75.0);
          paintPuzzleOyen(
            c,
            OyenLook(pose: pose, dir: dir, bubble: bubble),
            size: 62,
          );
          c.restore();
        }
      }
    }
    final picture = recorder.endRecording();
    final image = await t.runAsync(() => picture.toImage(600, 780));
    expect(image, isNotNull);
    if (const bool.fromEnvironment('PUZZLE_REVIEW')) {
      await t.runAsync(() async {
        final data = await image!.toByteData(format: ui.ImageByteFormat.png);
        final file = File('docs/design-v2/puzzle/art-catalog.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(data!.buffer.asUint8List());
      });
    }
    image!.dispose();
    picture.dispose();
  });

  testWidgets(
    'actual board uses wood and player marker; hint stays below item',
    (t) async {
      Future<ui.Color> at(BoardScene scene, int x, int y) async {
        final recorder = ui.PictureRecorder();
        paintBoard(Canvas(recorder), scene);
        final picture = recorder.endRecording();
        final image = (await t.runAsync(() => picture.toImage(350, 450)))!;
        final data = (await t.runAsync(image.toByteData))!;
        final i = (y * 350 + x) * 4;
        final color = Color.fromARGB(
          data.getUint8(i + 3),
          data.getUint8(i),
          data.getUint8(i + 1),
          data.getUint8(i + 2),
        );
        image.dispose();
        picture.dispose();
        return color;
      }

      BoardScene scene({
        Map<Pos, TileItem> items = const {},
        Map<Pos, Item> ghosts = const {},
      }) => BoardScene.fromMap(
        BoardScene.designMap,
        showOyen: false,
        items: items,
        ghosts: ghosts,
      );
      expect(await at(scene(), 75, 75), PuzzleArt.floor);
      expect(await at(scene(), 125, 75), PuzzleArt.floorAlt);
      const pos = Pos(3, 3);
      final player = scene(items: {pos: TileItem.bucketP});
      expect(await at(player, 154, 175), KoUi.orange);
      expect(await at(player, 175, 171), KoUi.water);
      expect(
        await at(
          scene(items: {pos: TileItem.bucketP}, ghosts: {pos: Item.fish}),
          175,
          171,
        ),
        await at(player, 175, 171),
      );
      expect(
        await at(scene(ghosts: {pos: Item.water}), 175, 171),
        isNot(await at(player, 175, 171)),
      );
    },
  );

  for (final size in [
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
  ]) {
    for (final lang in ['id', 'en', 'pt', 'ru']) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('puzzle $lang $size text $scale arrange and run', (
          t,
        ) async {
          setScreenSize(t, size);
          setTextScale(t, scale);
          await t.pumpWidget(
            RepaintBoundary(
              key: captureKey,
              child: testApp(
                locale: Locale(lang),
                home: LevelView(
                  level: levels[12],
                  backLabel: 'Back',
                  onBack: () {},
                  onNext: () {},
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final board = find.byType(GameWidget<KucingGame>);
          final rect = t.getRect(board);
          expect(rect.width / rect.height, closeTo(7 / 9, .001));
          expect(rect.height, greaterThan(200));
          final context = t.element(find.byType(LevelView));
          final l = AppLocalizations.of(context);
          final wake = find.widgetWithText(KoButton, l.wakeOyen);
          expect(t.getRect(wake).bottom, lessThanOrEqualTo(size.height));
          if (size.width == 360 ||
              (size.width == 390 && lang == 'id' && scale == 1)) {
            await capture(
              t,
              'atur-$lang-${(scale * 100).round()}-${size.width.round()}',
            );
          }
          await t.tap(wake);
          await t.pump();
          await t.pump(const Duration(milliseconds: 100));
          expect(t.takeException(), isNull);
          if (size.width == 360 ||
              (size.width == 390 && lang == 'id' && scale == 1)) {
            await capture(
              t,
              'jalan-$lang-${(scale * 100).round()}-${size.width.round()}',
            );
          }
          await t.pumpWidget(const SizedBox());
          await t.pump();
        });
      }
    }
  }
}
