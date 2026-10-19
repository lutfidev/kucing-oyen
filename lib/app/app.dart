import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';
import 'game_audio.dart';
import 'language.dart';
import 'progress_scope.dart';
import 'progress_store.dart';
import 'router.dart';
import 'routes.dart';
import 'sound_player.dart';

class KucingOrenApp extends StatefulWidget {
  const KucingOrenApp({
    super.key,
    required this.progress,
    this.audio,
    this.initialLocation = AppRoutes.home,
  });

  /// Data level dan progres pemain, dibagikan ke semua layar. Tidak boleh
  /// diganti sesudah aplikasi dibuat (router, pendengar bahasa, dan
  /// pendengar siklus hidup terikat ke controller pertama).
  final ProgressController progress;

  /// Musik dan efek suara; null = senyap ([FakeSoundPlayer]). Sama seperti
  /// [progress], tidak boleh diganti sesudah aplikasi dibuat.
  final GameAudio? audio;
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
  late final GameAudio _audio =
      widget.audio ??
      GameAudio(player: FakeSoundPlayer(), store: MemoryProgressStore());

  /// Aplikasi yang kembali dari latar belakang esok hari menampilkan bonus
  /// harian dan jatah iklan baru. Musik dijeda selama aplikasi tidak
  /// terlihat.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => widget.progress.refreshDay(),
    onHide: () => _audio.hold(AudioHold.background),
    onShow: () => _audio.release(AudioHold.background),
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
    _router.routerDelegate.addListener(_onRoute);
    _onRoute();
  }

  /// Lagu berganti mengikuti layar.
  void _onRoute() => _audio.setTrack(
    musicFor(_router.routerDelegate.currentConfiguration.uri.path),
  );

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
    _router.routerDelegate.removeListener(_onRoute);
    WidgetsBinding.instance.removeObserver(this);
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudioScope(
      audio: _audio,
      child: ProgressScope(
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
      ),
    );
  }
}
