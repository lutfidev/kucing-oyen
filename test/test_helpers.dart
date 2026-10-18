import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';
import 'package:kucing_oren/theme/theme.dart';

/// Level dibaca langsung dari berkas, tanpa `rootBundle`.
final testLevels = parseLevels(File(chapter1to2Asset).readAsStringSync());

/// Level yang punya tutorial.
final tutorialLevels = {
  for (final level in testLevels)
    if (tutorialFor(level.id) != null) level.id,
};

/// Progres untuk test: [best] = bintang terbaik per level, disimpan di
/// memori. Semua tutorial dianggap sudah selesai kecuali [tutorialsDone]
/// diberikan, supaya overlay tutorial (yang bergerak terus) tidak menutupi
/// layar di test lain.
ProgressController testProgress([
  Map<int, int> best = const {},
  Set<int>? tutorialsDone,
]) => testProgressWith(best: best, tutorialsDone: tutorialsDone);

/// Seperti [testProgress], ditambah saldo [coins], tingkat petunjuk
/// [hints] per level, kostum [wardrobe], hadiah harian [rewards], iklan
/// [ads] (default iklan palsu yang berhasil), dan jam [clock].
ProgressController testProgressWith({
  Map<int, int> best = const {},
  Set<int>? tutorialsDone,
  int coins = 0,
  Map<int, int> hints = const {},
  Wardrobe? wardrobe,
  DailyRewards rewards = DailyRewards.initial,
  RewardedAds? ads,
  DateTime Function()? clock,
}) {
  final progress = Progress(best);
  final tutorials = tutorialsDone ?? tutorialLevels;
  return ProgressController(
    levels: testLevels,
    store: MemoryProgressStore(progress, tutorials)
      ..coins = coins
      ..hints = hints
      ..wardrobe = wardrobe ?? Wardrobe.initial
      ..rewards = rewards,
    progress: progress,
    tutorialsDone: tutorials,
    coins: coins,
    hints: hints,
    wardrobe: wardrobe,
    rewards: rewards,
    ads: ads,
    clock: clock,
  );
}

/// Semua level sampai [last] menang dengan [stars] bintang.
Map<int, int> wonUpTo(int last, {int stars = 3}) => {
  for (var id = 1; id <= last; id++) id: stars,
};

/// Ukuran layar logis (dpr 1), dipulihkan setelah test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Skala teks sistem (mis. 1.3 = 130%), dipulihkan setelah test.
void setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Pompa aplikasi lengkap di [location] dengan [progress] (default:
/// progres kosong), lalu [settle]. Mengembalikan progres yang dipakai.
Future<ProgressController> pumpApp(
  WidgetTester tester, {
  String location = '/',
  ProgressController? progress,
}) async {
  final controller = progress ?? testProgress();
  await tester.pumpWidget(
    KucingOrenApp(progress: controller, initialLocation: location),
  );
  await settle(tester);
  return controller;
}

/// Seperti `pumpAndSettle`, tapi berhenti tanpa gagal setelah [max]: node
/// level saat ini di peta babak berdenyut terus.
Future<void> settle(
  WidgetTester tester, {
  Duration max = const Duration(seconds: 3),
}) async {
  const frame = Duration(milliseconds: 100);
  var elapsed = Duration.zero;
  do {
    await tester.pump(frame);
    elapsed += frame;
  } while (tester.binding.hasScheduledFrame && elapsed < max);
}

/// Dekorasi [Container] pertama di dalam [of] (permukaan tombol, chip, slot).
BoxDecoration decorationOf(WidgetTester tester, Finder of) {
  final box = tester.widget<Container>(
    find.descendant(of: of, matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

/// Pompa satu widget dengan tema Kucing Oren.
Future<void> pumpThemed(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: KoTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
