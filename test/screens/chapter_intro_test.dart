import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/l10n/app_localizations.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/chapter/chapter_intro.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart' show pumpFor;

/// Peta Babak 2 sesudah level 10 pertama kali dimenangkan.
Future<void> _pumpIntro(WidgetTester tester, {AppLanguage? language}) async {
  await pumpApp(
    tester,
    location: AppRoutes.chapter(2, intro: true),
    progress: testProgressWith(
      best: wonUpTo(10),
      language: language ?? AppLanguage.id,
    ),
  );
  await pumpFor(tester, const Duration(milliseconds: 500));
}

void main() {
  testWidgets('isi kartu: judul babak, info, tombol', (tester) async {
    await _pumpIntro(tester);
    expect(find.byType(ChapterIntroCard), findsOneWidget);
    expect(find.text('BABAK BARU TERBUKA!'), findsOneWidget);
    expect(find.text('Babak 2 – Ruang Tamu'), findsWidgets);
    expect(find.text('10 level baru · Bos: Hari Lebaran'), findsOneWidget);
    expect(find.text('Ayo masuk!'), findsOneWidget);
    expect(find.bySemanticsLabel('Babak baru terbuka'), findsOneWidget);
  });

  for (final language in AppLanguage.supported) {
    testWidgets('teks kartu dalam ${language.name}', (tester) async {
      await _pumpIntro(tester, language: language);
      final l = lookupAppLocalizations(Locale(language.name));
      final chapter = chaptersOf(testLevels)[1];
      expect(find.text(l.chapterIntroOverline.toUpperCase()), findsOneWidget);
      expect(find.text(l.chapterIntroEnter), findsOneWidget);
      expect(
        find.text(l.chapterIntroInfo(10, bossName(l, chapter))),
        findsOneWidget,
      );
      expect(find.text(chapterTitle(l, chapter)), findsWidgets);
    });
  }

  testWidgets('ditutup lewat tombol', (tester) async {
    await _pumpIntro(tester);
    await tester.tap(find.text('Ayo masuk!'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(ChapterIntroCard), findsNothing);
    expect(find.bySemanticsLabel('Level 11, main sekarang'), findsOneWidget);
  });

  testWidgets('ditutup lewat ketuk latar', (tester) async {
    await _pumpIntro(tester);
    await tester.tapAt(const Offset(10, 10));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(ChapterIntroCard), findsNothing);
  });

  testWidgets('kembali sistem menutup kartu, bukan peta', (tester) async {
    await _pumpIntro(tester);
    await tester.binding.handlePopRoute();
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(ChapterIntroCard), findsNothing);
    expect(find.text('Ruang Tamu'), findsOneWidget);
  });

  testWidgets('kurangi gerak: kartu langsung tampil tanpa geser', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(
      tester,
      location: AppRoutes.chapter(2, intro: true),
      progress: testProgress(wonUpTo(10)),
    );
    await tester.pump();
    final card = find.byKey(ChapterIntroCard.cardKey);
    final top = tester.getRect(card).top;
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getRect(card).top, top);
  });
}
