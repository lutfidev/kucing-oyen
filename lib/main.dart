import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/game_audio.dart';
import 'app/progress_scope.dart';
import 'app/progress_store.dart';
import 'app/rewarded_ads.dart';
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
  final progress = await ProgressController.load(
    levels: await loadLevels(),
    store: store,
    // Musik dijeda selama iklan berhadiah diputar.
    ads: audio.pauseDuringAds(FakeRewardedAds()),
  );
  runApp(KucingOrenApp(progress: progress, audio: audio));
}
