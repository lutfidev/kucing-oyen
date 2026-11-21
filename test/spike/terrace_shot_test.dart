// PROTOTIPE teras (spike): potret kamar + teras.
//   flutter test test/spike --dart-define=TERAS=true
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/room/terrace.dart';

import '../screenshots/capture.dart';
import '../test_helpers.dart';

void main() {
  testWidgets('teras', (tester) async {
    setScreenSize(tester, const Size(390, 844));
    var room = Room();
    for (final id in [
      RoomItemId.karpet,
      RoomItemId.lukisan,
      RoomItemId.tiang,
      RoomItemId.kasur,
      RoomItemId.bola,
      RoomItemId.kardus,
    ]) {
      room = room.buy(id);
    }
    final home = Home(
      room: room,
      kitties: const [
        KittyId.oyen,
        KittyId.arang,
        KittyId.mendung,
        KittyId.salju,
        KittyId.telon,
      ],
    );
    await withShadows(() async {
      await tester.pumpWidget(
        capturable(
          KucingOrenApp(
            progress: testProgressWith(coins: 200, home: home),
            roomRandom: () => Random(3),
          ),
        ),
      );
      await settle(tester, max: const Duration(milliseconds: 600));
      await capture(tester, 'teras/01-awal');
      for (var i = 0; i < 25; i++) {
        await settle(tester, max: const Duration(seconds: 1));
      }
      await capture(tester, 'teras/02-ruang-tengah-25s');
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-400, 0),
      );
      await settle(tester, max: const Duration(milliseconds: 800));
      await capture(tester, 'teras/03-teras');
      for (var i = 0; i < 20; i++) {
        await settle(tester, max: const Duration(seconds: 1));
      }
      await capture(tester, 'teras/04-teras-45s');
    });
  }, skip: !terraceSpike);
}
