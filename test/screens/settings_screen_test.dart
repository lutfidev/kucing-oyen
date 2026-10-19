import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/render/oyen.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/screens/level/level_sheet.dart';
import 'package:kucing_oren/screens/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      await pumpFor(tester, LevelSheet.openTime * 2);
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
      await pumpFor(tester, LevelSheet.openTime * 2);
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
      await pumpFor(tester, LevelSheet.openTime * 2);
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
    });

    testWidgets('Lisensi membuka halaman lisensi', (tester) async {
      await pumpApp(tester, location: AppRoutes.settings);
      await _tapText(tester, 'Lisensi');
      expect(find.byType(LicensePage), findsOneWidget);
    });
  });
}
