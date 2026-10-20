import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
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
/// [ads] untuk petunjuk dan koin (default iklan palsu yang berhasil), jam
/// [clock], dan bahasa [language] (default Indonesia, supaya test bisa
/// mencari teks Indonesia; [AppLanguage.system] untuk menguji bahasa HP).
ProgressController testProgressWith({
  Map<int, int> best = const {},
  Set<int>? tutorialsDone,
  int coins = 0,
  Map<int, int> hints = const {},
  Wardrobe? wardrobe,
  DailyRewards rewards = DailyRewards.initial,
  RewardedAds? ads,
  DateTime Function()? clock,
  AppLanguage language = AppLanguage.id,
}) {
  final progress = Progress(best);
  final tutorials = tutorialsDone ?? tutorialLevels;
  return ProgressController(
    levels: testLevels,
    store: MemoryProgressStore(progress, tutorials)
      ..coins = coins
      ..hints = hints
      ..wardrobe = wardrobe ?? Wardrobe.initial
      ..rewards = rewards
      ..language = language,
    progress: progress,
    tutorialsDone: tutorials,
    coins: coins,
    hints: hints,
    wardrobe: wardrobe,
    rewards: rewards,
    language: language,
    hintAds: ads,
    coinAds: ads,
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
/// progres kosong) dan [audio] (default: [testAudio]), lalu [settle].
/// Mengembalikan progres yang dipakai.
Future<ProgressController> pumpApp(
  WidgetTester tester, {
  String location = '/',
  ProgressController? progress,
  GameAudio? audio,
}) async {
  final controller = progress ?? testProgress();
  await tester.pumpWidget(
    KucingOrenApp(
      progress: controller,
      audio: audio ?? testAudio(),
      initialLocation: location,
    ),
  );
  await settle(tester);
  return controller;
}

/// Suara dengan pemutar palsu ([FakeSoundPlayer] di `audio.player`).
GameAudio testAudio({SoundSettings settings = SoundSettings.on}) => GameAudio(
  player: FakeSoundPlayer(),
  store: MemoryProgressStore(),
  settings: settings,
);

/// Efek suara yang sudah diputar [audio] dari [testAudio].
List<GameSound> playedBy(GameAudio audio) =>
    (audio.player as FakeSoundPlayer).played;

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

/// Teks Indonesia, untuk mencari teks di test yang berbahasa Indonesia.
final l10nId = lookupAppLocalizations(const Locale('id'));

/// [MaterialApp] dengan tema dan teks aplikasi, untuk memompa satu layar
/// tanpa rute. Bahasanya Indonesia kecuali [locale] diberikan.
Widget testApp({
  Widget? home,
  TransitionBuilder? builder,
  Locale locale = const Locale('id'),
  GameAudio? audio,
}) {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: KoTheme.light(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: builder,
    home: home,
  );
  return audio == null ? app : AudioScope(audio: audio, child: app);
}

/// Pompa satu widget dengan tema dan teks aplikasi.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  GameAudio? audio,
}) async {
  await tester.pumpWidget(
    testApp(
      home: Scaffold(body: Center(child: child)),
      audio: audio,
    ),
  );
}
