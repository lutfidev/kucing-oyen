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
import '../../widgets/widgets.dart';
import 'settings_parts.dart';

/// Pengaturan (rute `/pengaturan`, tidak ada di desain; gaya kartu Lemari
/// Kostum dan sheet Petunjuk): sakelar musik dan efek suara, bahasa, lihat
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
    _consentOpen = true;
    try {
      await consent.showPrivacyOptions();
    } finally {
      _consentOpen = false;
    }
  }

  void _replayTutorials(ProgressController progress) {
    unawaited(progress.replayTutorials());
    setState(() => _notice = _Notice.tutorials);
  }

  Future<void> _confirmReset(ProgressController progress) => showKoSheet(
    context,
    barrierLabel: context.l10n.closeReset,
    barrierColor: context.koColors.scrimLight,
    builder: (context, onClose) => ResetSheet(
      onClose: onClose,
      onConfirm: () {
        onClose();
        unawaited(progress.resetProgress());
        setState(() => _notice = _Notice.reset);
      },
    ),
  );

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
    final c = context.koColors;
    final space = context.koSpace;
    final l = context.l10n;
    final version = _version;

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
