import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Nama game: merek yang sama di semua bahasa, tidak diterjemahkan.
const appName = 'Ginger Logic';

extension L10nContext on BuildContext {
  /// Teks dalam bahasa yang sedang dipakai.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
