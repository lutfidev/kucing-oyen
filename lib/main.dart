import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app/ad_ids.dart';
import 'app/admob_ads.dart';
import 'app/admob_sdk.dart';
import 'app/app.dart';
import 'app/game_audio.dart';
import 'app/progress_scope.dart';
import 'app/progress_store.dart';
import 'app/sound_player.dart';
import 'game/level_loader.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Font dibundel di assets/fonts; lisensinya ikut halaman lisensi aplikasi.
  LicenseRegistry.addLicense(() async* {
    for (final family in const [KoFonts.fredoka, KoFonts.nunito]) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
    // Efek suara dari bunyi CC0 (Kenney dan OpenGameArt).
    yield LicenseEntryWithLineBreaks([
      'Ginger Logic sound effects',
    ], await rootBundle.loadString('assets/audio/LICENSE-sfx.txt'));
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Level, progres, dan sakelar suara dimuat sebelum layar pertama, jadi
  // layar tidak perlu menunggu.
  final store = PrefsProgressStore();
  final audio = await GameAudio.load(
    store: store,
    player: AudioplayersSoundPlayer(),
  );
  // Iklan berhadiah AdMob; SDK baru dinyalakan setelah persetujuan (UMP).
  final ads = GameAds(
    consent: UmpAdConsent(),
    startSdk: startAdMob,
    load: loadAdMobRewarded,
  );
  if (kReleaseMode && releaseUsesTestAds) {
    debugPrint('Ginger Logic: build release masih memakai iklan uji.');
  }
  final progress = await ProgressController.load(
    levels: await loadLevels(),
    store: store,
    // Musik dijeda selama iklan berhadiah diputar.
    hintAds: audio.pauseDuringAds(ads.hints),
    coinAds: audio.pauseDuringAds(ads.coins),
  );
  runApp(KucingOrenApp(progress: progress, audio: audio));
  // Formulir persetujuan muncul di atas layar pertama, tanpa menahannya.
  unawaited(ads.start());
}
