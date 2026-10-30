import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Kamar di rute `/` seukuran desain 390×844.
Future<ProgressController> pumpRoom(
  WidgetTester tester, {
  ProgressController? progress,
  Size size = const Size(390, 844),
  Random Function()? random,
  bool life = false,
}) async {
  setScreenSize(tester, size);
  return pumpApp(
    tester,
    progress: progress ?? testProgressWith(),
    roomRandom: random,
    roomLife: life,
  );
}

Finder itemView(RoomItemId id) =>
    find.byWidgetPredicate((w) => w is RoomItemView && w.id == id);

Finder kittyView(KittyId kitty) =>
    find.byWidgetPredicate((w) => w is KittyView && w.look.kitty == kitty);

/// Kotak kamar di layar dan geometrinya.
(Rect, RoomGeometry) roomOf(WidgetTester tester) {
  final rect = tester.getRect(find.byKey(const ValueKey('room-area')));
  return (rect, RoomGeometry(rect.size));
}

const allKitties = KittyId.values;

/// Semua barang ditaruh di posisi bawaannya.
Room fullRoom() {
  var room = Room();
  for (final item in shopItems) {
    room = room.buy(item.id);
  }
  return room;
}

/// Jam tetap untuk test kebutuhan kucing.
final roomNow = DateTime(2026, 10, 29, 9);

/// Progres dengan Lapar/Senang tiap kucing di [cats] pada [roomNow].
ProgressController withNeeds(
  Map<KittyId, (double, double)> cats, {
  Home? home,
  int coins = 0,
}) => testProgressWith(
  home: home,
  coins: coins,
  clock: () => roomNow,
  needs: HomeNeeds(
    cats: {
      for (final MapEntry(key: kitty, value: (hunger, joy)) in cats.entries)
        kitty: CatNeeds(hunger: hunger, joy: joy, at: roomNow),
    },
  ),
);
