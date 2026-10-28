import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/ad_consent.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/privacy.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/render/oyen.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';
import 'package:kucing_oren/screens/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart' show pumpFor;

Finder _language(AppLanguage language) =>
    find.byKey(ValueKey('language-${language.name}'));

/// Tombol di layar Pengaturan, digulir dulu supaya terlihat.
Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await settle(tester);
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Ginger Logic',
      packageName: 'com.example.kucing_oren',
      version: '1.2.3',
      buildNumber: '7',
      buildSignature: '',
    );
  });

  testWidgets('Beranda → Pengaturan → kembali', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Pengaturan'));
    await settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Kembali ke Beranda'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  group('suara', () {
    Finder sound(String name) => find.byKey(ValueKey('sound-$name'));

    testWidgets('bagian Suara paling atas, dua sakelar menyala', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, location: AppRoutes.settings);
      expect(find.text('SUARA'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('SUARA')).dy,
        lessThan(tester.getTopLeft(find.text('BAHASA')).dy),
      );
      for (final (name, label) in [
        ('music', 'Musik'),
        ('effects', 'Efek suara'),
      ]) {
        expect(
          tester.getSemantics(sound(name)),
          isSemantics(
            label: label,
            isToggled: true,
            hasToggledState: true,
            hasTapAction: true,
          ),
        );
      }
      semantics.dispose();
    });

    testWidgets('sakelar mematikan musik dan efek suara, tersimpan', (
      tester,
    ) async {
      final store = MemoryProgressStore();
      final player = FakeSoundPlayer();
      final audio = GameAudio(player: player, store: store);
      await pumpApp(tester, location: AppRoutes.settings, audio: audio);
      expect(player.music, MusicTrack.home);

      await tester.tap(sound('music'));
      await settle(tester);
      expect(audio.musicOn, isFalse);
      expect(player.music, isNull);
      expect(store.sound, const SoundSettings(music: false));
      expect(
        tester.getSemantics(sound('music')),
        isSemantics(isToggled: false, hasToggledState: true),
      );

      await tester.tap(sound('effects'));
      await settle(tester);
      expect(audio.effectsOn, isFalse);
      expect(store.sound, const SoundSettings(music: false, effects: false));

      // Dinyalakan lagi.
      player.played.clear();
      await tester.tap(sound('music'));
      await settle(tester);
      expect(player.music, MusicTrack.home);
      await tester.tap(sound('effects'));
      await settle(tester);
      expect(audio.effectsOn, isTrue);
      expect(store.sound, SoundSettings.on);
    });

    testWidgets('memuat sakelar tersimpan saat dibuka', (tester) async {
      final audio = testAudio(settings: const SoundSettings(effects: false));
      await pumpApp(tester, location: AppRoutes.settings, audio: audio);
      expect(
        tester.getSemantics(sound('effects')),
        isSemantics(isToggled: false, hasToggledState: true),
      );
    });
  });

  group('bahasa', () {
    testWidgets('lima pilihan, nama bahasa dalam bahasanya sendiri', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.settings);
      for (final text in [
        'Ikuti bahasa HP',
        'English',
        'Bahasa Indonesia',
        'Português (Brasil)',
        'Русский',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(
        tester.getSemantics(_language(AppLanguage.id)),
        isSemantics(isSelected: true, isButton: true),
      );
      expect(
        tester.getSemantics(_language(AppLanguage.en)),
        isSemantics(isSelected: false, isButton: true),
      );
    });

    testWidgets('nama bahasa bertag bahasanya untuk pembaca layar', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.settings);
      List<StringAttribute> attributes(AppLanguage language) => tester
          .getSemantics(_language(language))
          .getSemanticsData()
          .attributedLabel
          .attributes;
      for (final language in AppLanguage.supported) {
        final tags = attributes(language);
        expect(tags, hasLength(1), reason: language.name);
        final tag = tags.single as LocaleStringAttribute;
        expect(tag.locale, Locale(language.name));
        expect(
          tag.range,
          TextRange(start: 0, end: language.nativeName!.length),
        );
      }
      // "Ikuti bahasa HP" ditulis dalam bahasa yang sedang dipakai.
      expect(attributes(AppLanguage.system), isEmpty);
    });

    testWidgets('memilih bahasa langsung mengganti teks dan tersimpan', (
      tester,
    ) async {
      final progress = await pumpApp(tester, location: AppRoutes.settings);
      await tester.tap(_language(AppLanguage.en));
      await settle(tester);
      expect(progress.language, AppLanguage.en);
      expect((progress.store as MemoryProgressStore).language, AppLanguage.en);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Use phone language'), findsOneWidget);

      await tester.tap(_language(AppLanguage.ru));
      await settle(tester);
      expect(find.text('Настройки'), findsOneWidget);
    });

    testWidgets('ikuti bahasa HP kembali ke bahasa perangkat', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('pt', 'BR')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final progress = await pumpApp(tester, location: AppRoutes.settings);
      await tester.tap(_language(AppLanguage.system));
      await settle(tester);
      expect(progress.language, AppLanguage.system);
      expect(find.text('Configurações'), findsOneWidget);
    });
  });

  testWidgets('lihat tutorial lagi: tutorial level 1 muncul lagi', (
    tester,
  ) async {
    final progress = await pumpApp(tester, location: AppRoutes.settings);
    expect(progress.isTutorialDone(1), isTrue);
    await _tapText(tester, 'Lihat tutorial lagi');
    expect(progress.tutorialsDone, isEmpty);
    expect(find.text('Siap! Tutorialnya muncul lagi.'), findsOneWidget);

    // Level 1 dibuka lagi: tutorialnya tampil (cincin bergerak terus).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      KucingOrenApp(
        progress: progress,
        initialLocation: AppRoutes.level(1, chapter: 1),
      ),
    );
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text('Lewati'), findsOneWidget);
  });

  group('reset progres', () {
    ProgressController filled() => testProgressWith(
      best: wonUpTo(5),
      coins: 240,
      hints: {3: 2},
      wardrobe: Wardrobe(owned: {OyenCostume.peci}, wearing: OyenCostume.peci),
      rewards: const DailyRewards(bonusDay: 5),
    );

    testWidgets('batal: tidak ada yang berubah', (tester) async {
      final progress = await pumpApp(
        tester,
        location: AppRoutes.settings,
        progress: filled(),
      );
      await _tapText(tester, 'Reset progres');
      expect(find.text('Hapus semua progres?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await pumpFor(tester, KoSheet.openTime * 2);
      expect(find.text('Hapus semua progres?'), findsNothing);
      expect(progress.progress.totalStars, 15);
      expect(progress.coins, 240);
    });

    testWidgets('hapus: bintang, koin, petunjuk, kostum, tutorial hilang; '
        'bonus harian dan bahasa tetap', (tester) async {
      final progress = await pumpApp(
        tester,
        location: AppRoutes.settings,
        progress: filled(),
      );
      await _tapText(tester, 'Reset progres');
      await tester.tap(find.text('Hapus'));
      await pumpFor(tester, KoSheet.openTime * 2);
      expect(find.text('Hapus semua progres?'), findsNothing);
      expect(progress.progress, Progress.empty);
      expect(progress.coins, 0);
      expect(progress.hintTier(3), 0);
      expect(progress.wardrobe.wearing, OyenCostume.none);
      expect(progress.tutorialsDone, isEmpty);
      expect(progress.language, AppLanguage.id);
      expect(
        (progress.store as MemoryProgressStore).rewards,
        const DailyRewards(bonusDay: 5),
      );
      expect(find.text('Progres dihapus. Mulai lagi, yuk!'), findsOneWidget);
    });

    testWidgets('sheet konfirmasi bisa ditutup dengan tombol kembali', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.settings, progress: filled());
      await _tapText(tester, 'Reset progres');
      await tester.binding.handlePopRoute();
      await pumpFor(tester, KoSheet.openTime * 2);
      expect(find.text('Hapus semua progres?'), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('tentang', () {
    testWidgets('nama game, versi, kredit font', (tester) async {
      await pumpApp(tester, location: AppRoutes.settings);
      expect(find.text('Ginger Logic'), findsOneWidget);
      expect(find.text('Versi 1.2.3'), findsOneWidget);
      expect(
        find.text('Font: Fredoka dan Nunito (SIL Open Font License).'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Efek suara: Kenney dan OpenGameArt (CC0). Musiknya dibuat khusus '
          'untuk Ginger Logic.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Lisensi membuka halaman lisensi', (tester) async {
      await pumpApp(tester, location: AppRoutes.settings);
      await _tapText(tester, 'Lisensi');
      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  group('privasi', () {
    late _FakeLauncher launcher;

    setUp(() {
      launcher = _FakeLauncher();
      UrlLauncherPlatform.instance = launcher;
    });

    Finder button(String name) => find.byKey(ValueKey('privacy-$name'));

    testWidgets('bagian Privasi di antara Progres dan Tentang', (tester) async {
      await pumpApp(tester, location: AppRoutes.settings);
      // Judul bagian ditulis kapital.
      double top(String title) =>
          tester.getTopLeft(find.text(title.toUpperCase())).dy;
      final privacy = top(l10nId.privacySection);
      expect(privacy, greaterThan(top(l10nId.progressSection)));
      expect(privacy, lessThan(top(l10nId.about)));
      expect(find.text(l10nId.privacyInfo), findsOneWidget);
    });

    testWidgets('Kebijakan privasi membuka URL kebijakan di browser', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.settings);
      await _tapText(tester, l10nId.privacyPolicy);
      expect(launcher.launched, [privacyPolicyUrl]);
      expect(
        launcher.options.single.mode,
        PreferredLaunchMode.externalApplication,
      );
      expect(find.text(l10nId.privacyLinkFailed), findsNothing);
    });

    testWidgets('browser gagal dibuka: pesan kecil', (tester) async {
      launcher.succeed = false;
      await pumpApp(tester, location: AppRoutes.settings);
      await _tapText(tester, l10nId.privacyPolicy);
      expect(find.text(l10nId.privacyLinkFailed), findsOneWidget);
    });

    testWidgets('launcher melempar: pesan kecil, tidak crash', (tester) async {
      launcher.error = true;
      await pumpApp(tester, location: AppRoutes.settings);
      await _tapText(tester, l10nId.privacyPolicy);
      expect(find.text(l10nId.privacyLinkFailed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tombol persetujuan hanya kalau UMP memintanya', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.settings,
        consent: FakeAdConsent(),
      );
      expect(button('consent'), findsNothing);
      expect(button('policy'), findsOneWidget);
    });

    testWidgets('Atur persetujuan iklan membuka formulir UMP', (tester) async {
      final consent = FakeAdConsent(privacyOptionsRequired: true);
      await pumpApp(tester, location: AppRoutes.settings, consent: consent);
      await _tapText(tester, l10nId.adConsent);
      expect(consent.optionsShown, 1);
    });

    testWidgets('dua ketukan cepat membuka formulir sekali', (tester) async {
      final consent = _SlowConsent();
      await pumpApp(tester, location: AppRoutes.settings, consent: consent);
      await _tapText(tester, l10nId.adConsent);
      await _tapText(tester, l10nId.adConsent);
      expect(consent.optionsShown, 1);
      consent.close();
      await tester.pump();
      await _tapText(tester, l10nId.adConsent);
      expect(consent.optionsShown, 2);
    });

    testWidgets('persetujuan diwajibkan belakangan: tombol muncul', (
      tester,
    ) async {
      final consent = FakeAdConsent();
      await pumpApp(tester, location: AppRoutes.settings, consent: consent);
      expect(button('consent'), findsNothing);
      consent.privacyOptionsRequired = true;
      await settle(tester);
      expect(button('consent'), findsOneWidget);
    });
  });
}

/// Peluncur URL palsu: mencatat URL, hasilnya bisa diatur.
class _FakeLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final launched = <String>[];
  final options = <LaunchOptions>[];
  bool succeed = true;
  bool error = false;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (error) throw PlatformException(code: 'gagal');
    launched.add(url);
    this.options.add(options);
    return succeed;
  }
}

/// Persetujuan yang formulirnya tetap terbuka sampai [close].
class _SlowConsent extends FakeAdConsent {
  _SlowConsent() : super(privacyOptionsRequired: true);

  Completer<void>? _open;

  void close() => _open?.complete();

  @override
  Future<void> showPrivacyOptions() {
    optionsShown++;
    return (_open = Completer<void>()).future;
  }
}
