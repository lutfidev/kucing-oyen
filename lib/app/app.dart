import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';
import 'language.dart';
import 'progress_scope.dart';
import 'router.dart';
import 'routes.dart';

class KucingOrenApp extends StatefulWidget {
  const KucingOrenApp({
    super.key,
    required this.progress,
    this.initialLocation = AppRoutes.home,
  });

  /// Data level dan progres pemain, dibagikan ke semua layar.
  final ProgressController progress;
  final String initialLocation;

  @override
  State<KucingOrenApp> createState() => _KucingOrenAppState();
}

class _KucingOrenAppState extends State<KucingOrenApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation,
  );
  final ThemeData _theme = KoTheme.light();

  /// Aplikasi yang kembali dari latar belakang esok hari menampilkan bonus
  /// harian dan jatah iklan baru.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => widget.progress.refreshDay(),
  );

  /// Bahasa yang sedang dipakai; aplikasi dibangun ulang hanya saat
  /// pilihan bahasa berubah, bukan tiap progres berubah.
  late AppLanguage _language = widget.progress.language;

  @override
  void initState() {
    super.initState();
    _lifecycle;
    WidgetsBinding.instance.addObserver(this);
    widget.progress.addListener(_onProgress);
  }

  void _onProgress() {
    final language = widget.progress.language;
    if (language != _language) setState(() => _language = language);
  }

  /// Bahasa HP berganti saat aplikasi terbuka.
  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    WidgetsBinding.instance.removeObserver(this);
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: widget.progress,
      child: MaterialApp.router(
        title: appName,
        debugShowCheckedModeBanner: false,
        locale: resolveLocale(
          _language,
          WidgetsBinding.instance.platformDispatcher.locales,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: _theme,
        routerConfig: _router,
      ),
    );
  }
}
