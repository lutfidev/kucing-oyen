import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('OyenView berlabel untuk pembaca layar', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const OyenView(
        OyenLook(pose: OyenPose.sleep, dir: Direction.left),
        size: 62,
      ),
    );
    expect(find.bySemanticsLabel('Oyen tidur, menghadap kiri'), findsOneWidget);
    expect(tester.getSize(find.byType(OyenView)), const Size.square(62));
    semantics.dispose();
  });

  testWidgets('TileView hiasan saja, seukuran permintaan', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const TileView(Tile(item: TileItem.fishP), size: 80),
    );
    expect(tester.getSize(find.byType(TileView)), const Size.square(80));
    expect(tester.getSemantics(find.byType(TileView)).label, isEmpty);
    semantics.dispose();
  });

  testWidgets('BoardView 350×450, mengecil kalau tempatnya sempit', (
    tester,
  ) async {
    final scene = BoardScene.fromMap(BoardScene.designMap);
    await pumpThemed(tester, BoardView(scene));
    expect(tester.getSize(find.byType(BoardView)), const Size(350, 450));
    expect(find.bySemanticsLabel('Papan permainan 7 kali 9 petak'), findsOne);

    await pumpThemed(tester, SizedBox(width: 280, child: BoardView(scene)));
    expect(tester.getSize(find.byType(BoardView)), const Size(280, 360));
    expect(tester.takeException(), isNull);
  });
}
