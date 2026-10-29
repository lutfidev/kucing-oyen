import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/ad_consent.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/screens/level/hint_sheet.dart';
import 'package:kucing_oren/screens/level/rules_sheet.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/screens/settings/settings_parts.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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
  AppRoutes.shop(),
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
  AppRoutes.galleryKitty,
  AppRoutes.gallerySound,
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
    (AppRoutes.galleryOyen, find.text('Senang')),
    (AppRoutes.galleryKitty, find.text('Puding Ikan')),
    (AppRoutes.gallerySound, find.text('Lagu level')),
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
    DailyRewards rewards = DailyRewards.initial,
    RewardedAds? ads,
    DateTime Function()? clock,
  }) => testProgressWith(
    best: best,
    tutorialsDone: tutorialsDone,
    coins: coins,
    hints: hints,
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
          await pumpFor(tester, KoSheet.openTime * 2);
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
          await pumpFor(tester, KoSheet.openTime * 2);
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
      // Toko bersaldo 5 digit: keempat tab bisa digulir sampai kartu
      // terakhir, dan pratinjau aksesoris muat berdampingan.
      for (final tab in ShopTab.values) {
        testWidgets('tanpa overflow: Toko ${tab.name} saldo 99999 @ $label, '
            'teks ${scale * 100}%', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          await pumpApp(
            tester,
            location: AppRoutes.shop(tab: tab),
            progress: p(coins: 99999),
          );
          await settle(tester);
          expect(find.text('99999'), findsOneWidget);
          final last = switch (tab) {
            ShopTab.items => const ValueKey('shop-item-jendelaBurung'),
            ShopTab.kitties => const ValueKey('shop-kitty-kembang'),
            ShopTab.accessories => const ValueKey('shop-accessory-mahkotaRaja'),
            ShopTab.snacks => const ValueKey('shop-snack-puding'),
          };
          final card = find.byKey(last);
          await tester.ensureVisible(card);
          await settle(tester);
          expect(card.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
      // Sheet konfirmasi beli: barang (gambar besar) dan aksesoris (catatan
      // "milikmu selamanya" plus pratinjau).
      for (final kind in ['barang', 'aksesoris']) {
        testWidgets('tanpa overflow: sheet beli $kind @ $label, '
            'teks ${scale * 100}%', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          final accessory = kind == 'aksesoris';
          await pumpApp(
            tester,
            location: AppRoutes.shop(
              tab: accessory ? ShopTab.accessories : ShopTab.items,
            ),
            progress: p(coins: 99999),
          );
          await settle(tester);
          if (accessory) {
            final card = find.byKey(const ValueKey('shop-accessory-syal'));
            await tester.ensureVisible(card);
            await tester.tap(card);
            await settle(tester);
            final buy = find.byKey(const ValueKey('shop-preview-buy'));
            await tester.ensureVisible(buy);
            await tester.tap(buy);
          } else {
            final card = find.byKey(const ValueKey('shop-item-rumah'));
            await tester.ensureVisible(card);
            await tester.tap(card);
          }
          await settle(tester);
          final confirm = find.byKey(const ValueKey('buy-confirm'));
          await tester.ensureVisible(confirm);
          expect(confirm.hitTestable(), findsOneWidget);
          expect(find.text(l.buyLater).hitTestable(), findsOneWidget);
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
        PackageInfo.setMockInitialValues(
          appName: appName,
          packageName: 'com.example.kucing_oren',
          version: '10.20.30',
          buildNumber: '1',
          buildSignature: '',
        );
        await pumpApp(tester, location: AppRoutes.settings, progress: p());
        final about = find.byType(AboutCard);
        await tester.ensureVisible(about);
        await settle(tester);
        expect(about.hitTestable(), findsOneWidget);
        expect(find.text(l.version('10.20.30')), findsOneWidget);
        final reset = find.text(l.resetProgress);
        await tester.ensureVisible(reset);
        await settle(tester);
        await tester.tap(reset);
        await pumpFor(tester, KoSheet.openTime * 2);
        final confirm = find.text(l.resetConfirm);
        expect(confirm.hitTestable(), findsOneWidget);
        expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Kartu Privasi dengan dan tanpa tombol persetujuan, plus pesan browser
  // gagal dibuka.
  for (final size in sizes) {
    for (final scale in textScales) {
      for (final required in [false, true]) {
        final label = '${size.width.toInt()}×${size.height.toInt()}';
        testWidgets('tanpa overflow: privasi @ $label, teks ${scale * 100}%, '
            'persetujuan ${required ? 'ada' : 'tidak ada'}', (tester) async {
          setScreenSize(tester, size);
          setTextScale(tester, scale);
          UrlLauncherPlatform.instance = _FailingLauncher();
          await pumpApp(
            tester,
            location: AppRoutes.settings,
            progress: p(),
            consent: FakeAdConsent(privacyOptionsRequired: required),
          );
          final policy = find.text(l.privacyPolicy);
          await tester.ensureVisible(policy);
          await settle(tester);
          await tester.tap(policy);
          await settle(tester);
          final failed = find.text(l.privacyLinkFailed);
          await tester.ensureVisible(failed);
          await settle(tester);
          expect(failed.hitTestable(), findsOneWidget);
          expect(
            find.text(l.adConsent),
            required ? findsOneWidget : findsNothing,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

/// Peluncur URL yang selalu gagal (browser tidak bisa dibuka).
class _FailingLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async => false;
}
