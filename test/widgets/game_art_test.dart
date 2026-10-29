import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/snacks.dart';
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

  testWidgets('CoinView hiasan saja, seukuran permintaan', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(tester, const CoinView(size: 22, kind: CoinKind.plain));
    expect(tester.getSize(find.byType(CoinView)), const Size.square(22));
    expect(tester.getSemantics(find.byType(CoinView)).label, isEmpty);
    semantics.dispose();
  });

  testWidgets('KittyView berlabel nama, pose, dan aksesorisnya', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const KittyView(
        look: KittyLook(
          kitty: KittyId.salju,
          pose: KittyPose.sleep,
          accessory: AccessoryId.pita,
        ),
        size: 94,
      ),
    );
    expect(
      find.bySemanticsLabel('Salju tidur melingkar, memakai Pita'),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(KittyView)), const Size.square(94));
    semantics.dispose();
  });

  testWidgets('RoomItemView dan SnackView berlabel nama katalog', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const Column(
        children: [
          RoomItemView(id: RoomItemId.kardus, box: Size(128, 80)),
          SnackView(id: SnackId.tuna, box: Size(52, 40)),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Kardus Nyaman'), findsOneWidget);
    expect(find.bySemanticsLabel('Tuna Kaleng'), findsOneWidget);
    expect(tester.getSize(find.byType(RoomItemView)), const Size(128, 80));
    expect(tester.getSize(find.byType(SnackView)), const Size(52, 40));
    semantics.dispose();
  });

  testWidgets('AccessoryIconView hiasan saja, seukuran permintaan', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const AccessoryIconView(id: AccessoryId.kalung, size: 24),
    );
    expect(
      tester.getSize(find.byType(AccessoryIconView)),
      const Size.square(24),
    );
    expect(tester.getSemantics(find.byType(AccessoryIconView)).label, isEmpty);
    semantics.dispose();
  });

  testWidgets('SadMarkView berlabel jenis lesunya, selebar permintaan', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const Column(
        children: [
          SadMarkView(hungry: true, size: 40),
          SadMarkView(hungry: false),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Lesu: lapar'), findsOneWidget);
    expect(find.bySemanticsLabel('Lesu: kurang perhatian'), findsOneWidget);
    expect(
      tester.getSize(find.byType(SadMarkView).first),
      const Size(40, 40 * 52 / 48),
    );
    semantics.dispose();
  });
}
