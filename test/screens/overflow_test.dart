import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/costumes.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/level/hint_sheet.dart';
import 'package:kucing_oren/screens/level/level_sheet.dart';
import 'package:kucing_oren/screens/level/rules_sheet.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/screens/settings/settings_parts.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

/// Semua rute harus bebas overflow dari layar kecil sampai besar, juga
/// dengan teks sistem 130%, di keempat bahasa (Rusia dan Portugis biasanya
/// paling panjang). Overflow RenderFlex dilaporkan sebagai exception
/// sehingga test gagal. Rute baru di langkah roadmap berikutnya ditambahkan
/// ke daftar ini. Galeri (alat pengembang, berbahasa Indonesia) dicek
/// sekali di [galleryRoutes].
final routes = <String>[
  AppRoutes.home,
  AppRoutes.chapter(1),
  AppRoutes.chapter(2),
  AppRoutes.closet,
  AppRoutes.settings,
  // Tanpa benda, dua jenis benda, dan tiga jenis benda (baki terlebar).
  AppRoutes.level(1, chapter: 1),
  AppRoutes.level(13, chapter: 2),
  AppRoutes.level(19, chapter: 2),
];

/// Galeri hanya berbahasa Indonesia.
final galleryRoutes = <String>[
  AppRoutes.gallery,
  AppRoutes.galleryBoard,
  AppRoutes.galleryOyen,
];

const sizes = <Size>[
  Size(360, 640),
  Size(360, 740),
  Size(390, 844),
  Size(412, 915),
];

const textScales = <double>[1.0, 1.3];

void main() {
  for (final language in AppLanguage.supported) {
    group(language.name, () => _cases(language));
  }

  // Galeri: alat pengembang berbahasa Indonesia, cukup sekali.
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final route in galleryRoutes) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets('tanpa overflow: $route @ $label, teks ${scale * 100}%', (
          tester,
        ) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(tester, location: route);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('galeri bisa digulir sampai bawah di 360×640, teks 130%', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 640));
    setTextScale(tester, 1.3);
    await pumpApp(tester, location: AppRoutes.gallery);
    await tester.scrollUntilVisible(
      find.text('Kartu dengan bayangan lembut.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final (route, last) in [
    (AppRoutes.galleryBoard, find.text('Vas pecah')),
    (AppRoutes.galleryOyen, find.text('Kacamata')),
  ]) {
    testWidgets('$route bisa digulir sampai bawah di 360×640, teks 130%', (
      tester,
    ) async {
      setScreenSize(tester, const Size(360, 640));
      setTextScale(tester, 1.3);
      await pumpApp(tester, location: route);
      await tester.scrollUntilVisible(
        last,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

/// Semua kasus di bahasa [language].
void _cases(AppLanguage language) {
  final locale = Locale(language.name);
  final l = lookupAppLocalizations(locale);

  /// Progres test dalam bahasa ini.
  ProgressController p({
    Map<int, int> best = const {},
    Set<int>? tutorialsDone,
    int coins = 0,
    Map<int, int> hints = const {},
    Wardrobe? wardrobe,
    DailyRewards rewards = DailyRewards.initial,
    RewardedAds? ads,
    DateTime Function()? clock,
  }) => testProgressWith(
    best: best,
    tutorialsDone: tutorialsDone,
    coins: coins,
    hints: hints,
    wardrobe: wardrobe,
    rewards: rewards,
    ads: ads,
    clock: clock,
    language: language,
  );

  for (final size in sizes) {
    for (final scale in textScales) {
      for (final route in routes) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets('tanpa overflow: $route @ $label, teks ${scale * 100}%', (
          tester,
        ) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(tester, location: route, progress: p());
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // Tutorial level 1, 3, dan 6 (kartu teks di atas sorotan), dan sheet
  // Aturan (level 13: kardus terkunci, level 20: semua terbuka) yang bisa
  // digulir sampai kartu terakhir.
  for (final size in sizes) {
    for (final scale in textScales) {
      final label = '${size.width.toInt()}×${size.height.toInt()}';
      for (final id in tutorialLevels) {
        testWidgets(
          'tanpa overflow: tutorial level $id @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await pumpApp(
              tester,
              location: AppRoutes.level(id, chapter: levels[id - 1].chapter),
              progress: p(best: wonUpTo(id - 1), tutorialsDone: {}),
            );
            expect(tester.takeException(), isNull);
            final title = tester.getRect(
              find.text(tutorialTitle(l, tutorialFor(id)!)),
            );
            expect(title.top, greaterThanOrEqualTo(0));
            expect(title.right, lessThanOrEqualTo(size.width));
            expect(find.text(l.skip).hitTestable(), findsOneWidget);
          },
        );
      }
      for (final id in const [13, 20]) {
        testWidgets('tanpa overflow: kartu aturan level $id @ $label, '
            'teks ${scale * 100}%', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(
            tester,
            location: AppRoutes.level(id, chapter: 2),
            progress: p(best: wonUpTo(id - 1)),
          );
          await tester.tap(find.text(l.rules));
          await pumpFor(tester, LevelSheet.openTime * 2);
          expect(tester.takeException(), isNull);
          final last = find.byType(RuleCard).last;
          await tester.ensureVisible(last);
          await pumpFor(tester, const Duration(milliseconds: 300));
          expect(tester.getRect(last).bottom, lessThanOrEqualTo(size.height));
          expect(last.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // Sheet Petunjuk: level 13 semua tertutup dengan koin cukup, koin kurang
  // (label terpanjang), satu terbuka, dan ketiganya terbuka (digulir sampai
  // kartu terakhir); level 1 tanpa benda. Beranda dengan saldo 5 digit.
  final hintCases = <String, (int, int, Map<int, int>)>{
    'level 13 tertutup': (13, 120, {}),
    'level 13 koin kurang': (13, 0, {}),
    'level 13 tingkat 1': (13, 120, {13: 1}),
    'level 13 semua terbuka': (13, 120, {13: 3}),
    'level 19 semua terbuka': (19, 120, {19: 3}),
    'level 1': (1, 120, {}),
  };
  for (final size in sizes) {
    for (final scale in textScales) {
      final label = '${size.width.toInt()}×${size.height.toInt()}';
      for (final MapEntry(key: name, value: (id, coins, hints))
          in hintCases.entries) {
        testWidgets('tanpa overflow: petunjuk $name @ $label, '
            'teks ${scale * 100}%', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(
            tester,
            location: AppRoutes.level(id, chapter: levels[id - 1].chapter),
            progress: p(best: wonUpTo(id - 1), coins: coins, hints: hints),
          );
          await tester.tap(find.bySemanticsLabel(l.hint));
          await pumpFor(tester, LevelSheet.openTime * 2);
          expect(tester.takeException(), isNull);
          final cards = find.byType(HintTierCard);
          if (cards.evaluate().isNotEmpty) {
            await tester.ensureVisible(cards.last);
            await pumpFor(tester, const Duration(milliseconds: 300));
            expect(
              tester.getRect(cards.last).bottom,
              lessThanOrEqualTo(size.height),
            );
            expect(cards.last.hitTestable(), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        });
      }
      testWidgets('tanpa overflow: Beranda saldo 99999 @ $label, '
          'teks ${scale * 100}%', (tester) async {
        setScreenSize(tester, size);
        setTextScale(tester, scale);
        await pumpApp(tester, progress: p(coins: 99999));
        expect(find.text('99999'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets('tanpa overflow: Lemari Kostum saldo 99999, Topi Koki '
          'dipilih @ $label, teks ${scale * 100}%', (tester) async {
        setScreenSize(tester, size);
        setTextScale(tester, scale);
        await pumpApp(
          tester,
          location: AppRoutes.closet,
          progress: p(coins: 99999),
        );
        final koki = find.byKey(const ValueKey('costume-koki'));
        await tester.ensureVisible(koki);
        await tester.tap(koki);
        await settle(tester);
        expect(find.text(l.costumeActionBuy(150)), findsOneWidget);
        // Semua kartu dan tombol aksi bisa dicapai.
        for (final id in ['none', 'peci', 'sarung', 'koki', 'kacamata']) {
          final card = find.byKey(ValueKey('costume-$id'));
          await tester.ensureVisible(card);
          expect(card.hitTestable(), findsOneWidget);
        }
        await tester.ensureVisible(find.text(l.costumeActionBuy(150)));
        expect(
          find.text(l.costumeActionBuy(150)).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
      // Sheet Tambah Koin dari Beranda bersaldo 5 digit: siap semua, jatah
      // habis (label terpanjang), dan pesan iklan gagal.
      for (final state in ['siap', 'habis', 'iklan gagal']) {
        testWidgets('tanpa overflow: Tambah Koin $state @ $label, '
            'teks ${scale * 100}%', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          final now = DateTime(2026, 10, 19, 9);
          final today = dayNumber(now);
          await pumpApp(
            tester,
            progress: p(
              coins: 99999,
              clock: () => now,
              rewards: switch (state) {
                'siap' => DailyRewards.initial,
                'habis' => DailyRewards(
                  bonusDay: today,
                  adDay: today,
                  adsWatched: maxAdsPerDay,
                ),
                _ => DailyRewards(bonusDay: today),
              },
              ads: FakeRewardedAds(succeed: false),
            ),
          );
          await tester.tap(find.byType(KoCoinChip));
          await settle(tester);
          if (state == 'iklan gagal') {
            await tester.tap(find.text(l.adRewardButton(20)));
            await settle(tester);
            expect(find.text(l.adFailed), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          final last = find.byKey(const ValueKey('coin-ad'));
          await tester.ensureVisible(last);
          await settle(tester);
          expect(tester.getRect(last).bottom, lessThanOrEqualTo(size.height));
          expect(last.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // Fase jalan sampai layar hasil, tanpa benda: level 1 (tanpa chip
  // status, Berhasil), level 12 (gelas jatuh), level 13 (vas pecah,
  // mondar-mandir).
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final id in const [1, 12, 13]) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: fase jalan level $id @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await pumpApp(
              tester,
              location: AppRoutes.level(id, chapter: levels[id - 1].chapter),
              progress: p(),
            );
            await tester.tap(find.text(l.wakeOyen));
            await tester.pumpAndSettle();
            await tester.tap(find.text(l.seeResult));
            // Sinar layar Berhasil berputar terus: tanpa pumpAndSettle.
            await pumpFor(tester, const Duration(milliseconds: 1500));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Layar hasil langsung dari sesi: Berhasil 3 dan 2 bintang, vas pecah,
  // mondar-mandir, dan kelamaan; dengan kotak "+30 koin" (deret angka
  // terlebar).
  final results = <String, LevelSession Function()>{
    'Berhasil level 13': () => resultOf(levels[12], levels[12].solution),
    'Berhasil 2 bintang level 15': () => resultOf(levels[14], twoStars),
    'vas pecah level 13': () => resultOf(levels[12], fishOnly),
    'Oyen bosan level 20': () => resultOf(levels[19]),
    'kelamaan': () => resultOf(longWalk),
  };
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: session) in results.entries) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: hasil $name @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await tester.pumpWidget(
              testApp(
                locale: locale,
                home: Scaffold(
                  body: ResultView(
                    session: session(),
                    onArrange: () {},
                    onRestart: () {},
                    onNext: () {},
                    coins: 30,
                  ),
                ),
              ),
            );
            await pumpFor(tester, const Duration(milliseconds: 1500));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Putar ulang langsung dari sesi: 6 langkah, Oyen bosan (40 langkah,
  // judul level terpanjang), dan kelamaan (80 langkah), di langkah 0 dan
  // terakhir.
  final replays = <String, LevelSession Function()>{
    'level 13': () => resultOf(levels[12], levels[12].solution),
    'Oyen bosan level 20': () => resultOf(levels[19]),
    'kelamaan': () => resultOf(longWalk),
  };
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: session) in replays.entries) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets(
          'tanpa overflow: putar ulang $name @ $label, teks ${scale * 100}%',
          (tester) async {
            setScreenSize(tester, size);
            setTextScale(tester, scale);
            await tester.pumpWidget(
              testApp(
                locale: locale,
                home: Scaffold(
                  body: ReplayView(
                    session: session(),
                    onBack: () {},
                    onMap: () {},
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            // Langkah terakhir: ketuk ujung kanan slider.
            final track = tester.getRect(
              find.descendant(
                of: find.byType(ReplaySlider),
                matching: find.byType(CustomPaint),
              ),
            );
            await tester.tapAt(track.centerRight - const Offset(1, 0));
            await tester.pumpAndSettle();
            expect(find.byType(ReplayCaption), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  // Sheet konfirmasi reset di layar Pengaturan, dan layar Pengaturan
  // digulir sampai kartu Tentang.
  for (final size in sizes) {
    for (final scale in textScales) {
      final label = '${size.width.toInt()}×${size.height.toInt()}';
      testWidgets('tanpa overflow: reset progres @ $label, '
          'teks ${scale * 100}%', (tester) async {
        setScreenSize(tester, size);
        setTextScale(tester, scale);
        await pumpApp(tester, location: AppRoutes.settings, progress: p());
        final about = find.byType(AboutCard);
        await tester.ensureVisible(about);
        await settle(tester);
        expect(about.hitTestable(), findsOneWidget);
        final reset = find.text(l.resetProgress);
        await tester.ensureVisible(reset);
        await settle(tester);
        await tester.tap(reset);
        await pumpFor(tester, LevelSheet.openTime * 2);
        final confirm = find.text(l.resetConfirm);
        expect(confirm.hitTestable(), findsOneWidget);
        expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
