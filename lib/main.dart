import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/progress_scope.dart';
import 'app/progress_store.dart';
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
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Level dan progres dimuat sebelum layar pertama, jadi layar tidak perlu
  // menunggu.
  final progress = await ProgressController.load(
    levels: await loadLevels(),
    store: PrefsProgressStore(),
  );
  runApp(KucingOrenApp(progress: progress));
}
