import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/chapter/map_node.dart';
import 'package:kucing_oren/screens/chapter/map_token.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

final _chapters = chaptersOf(testLevels);
final _chapter2 = _chapters[1];

Future<int> _pumpNode(
  WidgetTester tester, {
  required int id,
  required NodeState state,
  int stars = 0,
  bool compact = false,
}) async {
  var taps = 0;
  final level = testLevels[id - 1];
  await tester.pumpWidget(
    testApp(
      home: Scaffold(
        body: Center(
          child: PictureNode(
            level: level,
            chapter: _chapters[level.chapter - 1],
            state: state,
            stars: stars,
            compact: compact,
            onPressed: () => taps++,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return taps;
}

void main() {
  testWidgets('node saat ini: label, "Main", dan bisa diketuk', (tester) async {
    var taps = 0;
    final level = testLevels[12];
    await tester.pumpWidget(
      testApp(
        home: Scaffold(
          body: Center(
            child: PictureNode(
              level: level,
              chapter: _chapter2,
              state: NodeState.current,
              stars: 0,
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('Level 13, main sekarang'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PictureNode),
        matching: find.byType(ScaleTransition),
      ),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Level 13, main sekarang'));
    expect(taps, 1);
  });

  testWidgets('node terkunci: gembok, tidak bisa diketuk', (tester) async {
    await _pumpNode(tester, id: 14, state: NodeState.locked);
    expect(find.bySemanticsLabel('Level 14, terkunci'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is KoIcon && w.icon == KoIcons.lockBold),
      findsOneWidget,
    );
    expect(find.byType(KoPressable), findsNothing);
    expect(find.text('Main'), findsNothing);
  });

  testWidgets('node selesai: bintang terisi sesuai hasil', (tester) async {
    await _pumpNode(tester, id: 12, state: NodeState.done, stars: 2);
    expect(find.bySemanticsLabel('Level 12, 2 bintang'), findsOneWidget);
    final stars = tester.widgetList<KoStar>(find.byType(KoStar));
    expect(stars.map((s) => s.filled), [true, true, false]);
  });

  testWidgets('bos: label pembaca layar lama dan tag nama bos', (tester) async {
    await _pumpNode(tester, id: 20, state: NodeState.current);
    expect(
      find.bySemanticsLabel('Level 20, bos Hari Lebaran, main sekarang'),
      findsOneWidget,
    );
    expect(find.text('Bos · Hari Lebaran'), findsOneWidget);
  });

  testWidgets('ukuran desain 66/100, layar kecil 54/84', (tester) async {
    await _pumpNode(tester, id: 13, state: NodeState.current);
    expect(tester.getSize(find.byType(KoPressable)).width, 66);
    await _pumpNode(tester, id: 13, state: NodeState.current, compact: true);
    expect(tester.getSize(find.byType(KoPressable)).width, 54);
    await _pumpNode(tester, id: 20, state: NodeState.current);
    expect(tester.getSize(find.byType(KoPressable)).width, 100);
    await _pumpNode(tester, id: 20, state: NodeState.current, compact: true);
    expect(tester.getSize(find.byType(KoPressable)).width, 84);
  });

  testWidgets('tanpa animasi: cincin denyut tidak tampil', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pumpNode(tester, id: 13, state: NodeState.current);
    expect(
      find.descendant(
        of: find.byType(PictureNode),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );
    expect(find.text('Main'), findsOneWidget);
  });

  testWidgets('token Oyen 64×76 tanpa label pembaca layar', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      testApp(
        home: const Scaffold(
          body: Center(
            child: MapToken(pose: KittyPose.idle, facing: KittyFacing.down),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(MapToken)), PictureMapArt.tokenSize);
    expect(find.bySemanticsLabel(RegExp('Oyen')), findsNothing);
    expect(
      tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.size == const Size.square(PictureMapArt.tokenSprite),
        ),
      ),
      Size.square(PictureMapArt.tokenSprite),
    );
    semantics.dispose();
  });
}
