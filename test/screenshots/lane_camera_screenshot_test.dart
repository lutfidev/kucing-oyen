// Potret kamera menembus pintu (langkah 38, artboard 6 dan 12): bingkai
// pergi dan pulang, dengan kasur bawaan dan kamar berisi; lalu Gang Depan
// di keempat bahasa (`38-*` di folder per bahasa).
//   flutter test test/screenshots/lane_camera_screenshot_test.dart --dart-define=SCREENSHOTS=true
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/room/lane_camera.dart';
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

  // Gang Depan di keempat bahasa; Rusia juga di 360×640.
  final night = DateTime(2026, 11, 23, 3);
  final midVisit = laneVisitsOn(night).first.start
      .add(const Duration(minutes: 1));
  for (final language in AppLanguage.supported) {
    final l = lookupAppLocalizations(Locale(language.name));
    for (final small in [false, if (language == AppLanguage.ru) true]) {
      final size = small ? const Size(360, 640) : _size;
      final suffix = small ? '-360x640' : '';
      final folder = '390x844/${language.name}';

      Widget app({required bool met, required DateTime now}) => capturable(
        KucingOrenApp(
          roomLife: true,
          progress: testProgressWith(
            best: const {1: 3},
            coins: 120,
            language: language,
            metNeighbor: met,
            clock: () => now,
            home: _home(full: true),
            needs: HomeNeeds(rewardDays: {KittyId.oyen: dayNumber(night)}),
          ),
          // Seed 2: Oyen di ruang tengah saat kunjungan paksa datang.
          roomRandom: () => Random(2),
        ),
      );

      Future<void> toLane(WidgetTester tester) async {
        await tester.tap(find.byKey(const ValueKey('front-door')));
        for (var ms = 0; ms <= laneCameraMs + 50; ms += 16) {
          await tester.pump(_frame);
        }
        await tester.pump();
      }

      Future<void> until(WidgetTester tester, bool Function() done) async {
        for (var i = 0; i < 400 && !done(); i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      testWidgets('$folder/38-tengah-ekor$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: false, now: night));
          await until(
            tester,
            () =>
                find.byKey(const ValueKey('kumis-tail')).evaluate().isNotEmpty,
          );
          // Tahap menoleh dengan "!" (desain 4b).
          await _to(tester, 1500, 0);
          await capture(tester, '$folder/38-tengah-ekor$suffix');
        });
      }, skip: !screenshotsEnabled);

      testWidgets('$folder/38-tengah-penanda$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: true, now: midVisit));
          await settle(tester);
          await capture(tester, '$folder/38-tengah-penanda$suffix');
        });
      }, skip: !screenshotsEnabled);

      testWidgets('$folder/38-gang-utama$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: true, now: midVisit));
          await settle(tester);
          await toLane(tester);
          await capture(tester, '$folder/38-gang-utama$suffix');
        });
      }, skip: !screenshotsEnabled);

      testWidgets('$folder/38-gang-pertemuan$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: false, now: night));
          await until(
            tester,
            () =>
                find.byKey(const ValueKey('lane-marker')).evaluate().isNotEmpty,
          );
          await toLane(tester);
          // Kumis bergeser, Oyen naik, saling mengendus (desain 10).
          await _to(tester, 1600, 0);
          await capture(tester, '$folder/38-gang-pertemuan$suffix');
        });
      }, skip: !screenshotsEnabled);

      testWidgets('$folder/38-gang-kosong$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: true, now: night));
          await settle(tester);
          await toLane(tester);
          await capture(tester, '$folder/38-gang-kosong$suffix');
        });
      }, skip: !screenshotsEnabled);

      testWidgets('$folder/38-gang-kartu-oyen$suffix', (tester) async {
        setScreenSize(tester, size);
        await withShadows(() async {
          await tester.pumpWidget(app(met: true, now: midVisit));
          await settle(tester);
          await toLane(tester);
          final handle = tester.ensureSemantics();
          tester.semantics.tap(
            find.semantics.byLabel(l.kittyTapHint(kittyName(l, KittyId.oyen))),
          );
          handle.dispose();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await capture(tester, '$folder/38-gang-kartu-oyen$suffix');
        });
      }, skip: !screenshotsEnabled);
    }
  }
}
