import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/ad_consent.dart';
import '../../app/game_audio.dart';
import '../../app/privacy.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../theme/puzzle_theme.dart';
import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/v2/ui_panel.dart';
import '../../widgets/widgets.dart';
import 'settings_parts.dart';
import '../room/home_help.dart';

/// Pengaturan (rute `/pengaturan`, tidak ada di desain; gaya kartu Toko
/// dan sheet Petunjuk): sakelar musik dan efek suara, bahasa, lihat
/// tutorial lagi, reset progres dengan konfirmasi, privasi (kebijakan dan
/// persetujuan iklan), dan tentang game.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Pesan yang tampil di bawah tombol sesudah ditekan.
enum _Notice { tutorials, reset, privacyFailed }

class _SettingsScreenState extends State<SettingsScreen> {
  /// Versi aplikasi; null selama dimuat atau kalau tidak bisa dibaca.
  String? _version;
  _Notice? _notice;

  /// Formulir persetujuan sedang terbuka: ketukan berikutnya diabaikan.
  bool _consentOpen = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } on Object {
      // Versi tidak bisa dibaca (mis. di test): barisnya tidak ditampilkan.
    }
  }

  Future<void> _showConsent(AdConsent consent) async {
    if (_consentOpen) return;
    setState(() => _consentOpen = true);
    try {
      await consent.showPrivacyOptions();
    } on Object {
      if (mounted) setState(() => _notice = _Notice.privacyFailed);
    } finally {
      if (mounted) setState(() => _consentOpen = false);
    }
  }

  Future<void> _replayTutorials(ProgressController progress) async {
    await progress.replayTutorials();
    if (mounted) {
      setState(() => _notice = progress.saveFailed ? null : _Notice.tutorials);
    }
  }

  Future<void> _confirmReset(ProgressController progress) async {
    progress.pauseHousehold(HouseholdPause.reset);
    try {
      await showKoSheet(
        context,
        barrierLabel: context.l10n.closeReset,
        builder: (context, onClose) => ResetSheet(
          onClose: onClose,
          onReset: () async {
            final ok = await progress.resetProgress();
            if (ok && mounted) setState(() => _notice = _Notice.reset);
            return ok;
          },
        ),
      );
      if (mounted && _notice == _Notice.reset) context.go(AppRoutes.home);
    } finally {
      progress.resumeHousehold(HouseholdPause.reset);
    }
  }

  Future<void> _openPolicy() async {
    final opened = await openPrivacyPolicy();
    if (!mounted) return;
    setState(() => _notice = opened ? null : _Notice.privacyFailed);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final consent = AdConsentScope.maybeOf(context);
    final audio = AudioScope.of(context);
    final version = _version;

    return Theme(
      data: puzzleTheme(),
      child: Builder(
        builder: (context) =>
            _content(context, progress, consent, audio, version),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ProgressController progress,
    AdConsent? consent,
    GameAudio audio,
    String? version,
  ) {
    final c = context.koColors;
    final space = context.koSpace;
    final l = context.l10n;
    return Scaffold(
      backgroundColor: c.cream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: space.s8),
              SettingsBar(onBack: () => context.go(AppRoutes.home)),
              SizedBox(height: space.s16),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: space.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (progress.saveFailed || audio.saveFailed)
                        UiSaveNotice(
                          onRetry: () async {
                            await progress.retrySaves();
                            await audio.retrySettings();
                            if (mounted) setState(() {});
                          },
                        ),
                      SettingsSection(
                        title: l.soundSection,
                        child: SoundCard(
                          music: audio.musicOn,
                          effects: audio.effectsOn,
                          onMusic: (on) => unawaited(audio.setMusicOn(on)),
                          onEffects: (on) => unawaited(audio.setEffectsOn(on)),
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.language,
                        child: LanguageCard(
                          selected: progress.language,
                          onSelect: (language) =>
                              unawaited(progress.setLanguage(language)),
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.guidanceMotion,
                        child: UiPanel(
                          child: Column(
                            children: [
                              SettingsSwitchRow(
                                key: const ValueKey('reduced-motion'),
                                label: l.guidanceMotion,
                                on: progress.household.reducedMotion,
                                onChanged: progress.householdBusy
                                    ? null
                                    : (value) async {
                                        await progress.setReducedMotion(value);
                                        if (mounted) setState(() {});
                                      },
                              ),
                              Text(l.guidanceMotionInfo, style: KoUi.small),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.guidanceHomeTitle,
                        child: UiButton(
                          label: l.guidanceHomeTitle,
                          kind: UiButtonKind.secondary,
                          onPressed: () => showHomeHelp(context),
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.tutorialsSection,
                        child: ActionCard(
                          text: l.replayTutorialsInfo,
                          button: SheetButton(
                            label: l.replayTutorials,
                            icon: KoIcon(
                              KoIcons.replay,
                              size: context.koSize.iconCompact,
                              color: c.ink,
                            ),
                            color: c.surface,
                            line: c.line,
                            edge: c.lineDeep,
                            onPressed: () => _replayTutorials(progress),
                          ),
                          message: _notice == _Notice.tutorials
                              ? l.tutorialsBack
                              : null,
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.progressSection,
                        child: ActionCard(
                          text: l.resetProgressInfo,
                          button: SheetButton(
                            label: l.resetProgress,
                            icon: KoIcon(
                              KoIcons.reset,
                              size: context.koSize.iconCompact,
                              color: c.brickDeep,
                            ),
                            color: c.surface,
                            line: c.line,
                            edge: c.lineDeep,
                            labelColor: c.brickDeep,
                            onPressed: () => _confirmReset(progress),
                          ),
                          message: _notice == _Notice.reset
                              ? l.resetDone
                              : null,
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.privacySection,
                        child: PrivacyCard(
                          waiting: _consentOpen,
                          onPolicy: () => unawaited(_openPolicy()),
                          onConsent:
                              consent != null && consent.privacyOptionsRequired
                              ? () => unawaited(_showConsent(consent))
                              : null,
                          message: _notice == _Notice.privacyFailed
                              ? l.privacyLinkFailed
                              : null,
                        ),
                      ),
                      SizedBox(height: space.s16),
                      SettingsSection(
                        title: l.about,
                        child: AboutCard(
                          version: version,
                          onLicenses: () => showLicensePage(
                            context: context,
                            applicationName: appName,
                            applicationVersion: version,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
