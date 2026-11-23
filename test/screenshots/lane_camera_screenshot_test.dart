// Potret kamera menembus pintu (langkah 38, artboard 6 dan 12): bingkai
// pergi dan pulang, dengan kasur bawaan dan kamar berisi.
//   flutter test test/screenshots/lane_camera_screenshot_test.dart --dart-define=SCREENSHOTS=true
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/room.dart';

import '../test_helpers.dart';
import 'capture.dart';

const _size = Size(390, 844);
const _frame = Duration(milliseconds: 16);

/// Kasur bawaan saja, atau kamar berisi semua barang toko.
Home _home({required bool full}) {
  var room = Room().buy(RoomItemId.kasur);
  if (full) {
    for (final item in shopItems) {
      if (item.id != RoomItemId.kasur) room = room.buy(item.id);
    }
  }
  return Home(room: room);
}

Widget _app(Home home) => capturable(
  KucingOrenApp(
    roomLife: false,
    progress: testProgressWith(best: const {1: 3}, coins: 120, home: home),
    roomRandom: () => Random(1),
  ),
);

/// Maju sampai [ms] sejak kamera dimulai, per bingkai.
Future<void> _to(WidgetTester tester, int ms, int now) async {
  for (var t = now; t < ms; t += _frame.inMilliseconds) {
    await tester.pump(_frame);
  }
}

void main() {
  const frames = [0, 480, 640, 860, 1000, 1150, 1400, 1600];
  for (final full in [false, true]) {
    final name = full ? 'berisi' : 'kasur';
    testWidgets('390x844/38-kamera-$name', (tester) async {
      setScreenSize(tester, _size);
      await withShadows(() async {
        await tester.pumpWidget(_app(_home(full: full)));
        await settle(tester);
        await tester.tap(find.byKey(const ValueKey('front-door')));
        await tester.pump();
        var now = 0;
        for (final ms in frames) {
          await _to(tester, ms, now);
          now = ms;
          await capture(tester, '390x844/38-kamera-$name-pergi-$ms');
        }
        await settle(tester);
        await capture(tester, '390x844/38-kamera-$name-gang');
        await tester.binding.handlePopRoute();
        await tester.pump();
        now = 0;
        for (final ms in frames) {
          await _to(tester, ms, now);
          now = ms;
          await capture(tester, '390x844/38-kamera-$name-pulang-$ms');
        }
      });
    }, skip: !screenshotsEnabled);
  }
}
