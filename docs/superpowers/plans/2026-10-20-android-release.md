# Rencana langkah 17: Polish dan rilis Android

> **Untuk pelaksana:** jalankan dengan `superpowers:executing-plans` di sesi utama (aturan CLAUDE.md). Langkah memakai kotak centang (`- [ ]`).

**Tujuan:** app bundle release `com.gingerlogic.app` dengan ikon dan splash Oyen, iklan berhadiah AdMob asli dengan persetujuan UMP, bagian Privasi di Pengaturan, dan dokumen toko di `docs/store/`.

**Arsitektur:** SDK iklan dan UMP dibungkus celah kecil yang bisa dipalsukan (pola `MusicDeck`): `AdConsent`, `RewardedAdLoader`/`RewardedAdHandle`, dan `GameAds` yang menyalakan SDK hanya setelah persetujuan. Gambar ikon, splash, dan toko dirender dari `oyenSvg` lewat generator berbasis `flutter test` lalu ikut di-commit. Android memakai splash tema (API 31+ dan cadangan `launch_background`), bukan layar Flutter.

**Teknologi:** Flutter 3.47.5, `google_mobile_ads` (UMP ikut), `url_launcher`, Gradle Kotlin DSL.

**Spec:** `docs/superpowers/specs/2026-10-19-android-release-design.md`

## Batasan global

- `applicationId` dan `namespace` = `com.gingerlogic.app`; versi `1.0.0+1`; nama paket Dart tetap `kucing_oren`.
- ID uji Google: aplikasi `ca-app-pub-3940256099942544~3347511713`, unit berhadiah `ca-app-pub-3940256099942544/5224354917`. ID asli ditempel hanya di `android/app/build.gradle.kts` (`admobAppId`) dan `lib/app/ad_ids.dart`, keduanya berkomentar `TEMPEL ID ASLI DI SINI`.
- Iklan: tidak ditandai untuk anak, tidak ditandai under age of consent, rating konten maksimum `G`. `show()` tidak pernah melempar.
- URL kebijakan `https://yoluvy.my.id/ginger-logic/privacy/`; pengembang "Yoluvy"; kontak `yoluvy.dev@gmail.com`.
- Warna latar ikon dan splash = `KoColors.cream` `#FFF4E2`. Tidak ada warna atau ukuran hardcode di widget.
- Teks baru di keempat ARB (Indonesia ditulis dulu, lalu `en` dengan deskripsi, `pt`, `ru`), lalu `flutter gen-l10n`.
- Test yang ada tetap tanpa SDK iklan (`FakeRewardedAds`, `FakeAdConsent`). Baseline 1830 test lulus, analyze bersih.
- Auto Backup tetap aktif (manifest tidak menyetel `allowBackup="false"`).

## Fokus review

1. **Iklan selesai dimuat sesudah `show()` habis waktu:** `show()` sudah mengembalikan false; iklan yang datang terlambat disimpan untuk `show()` berikutnya, tidak ditampilkan tiba-tiba dan tidak bocor. Test di Tugas 4.
2. **Ketukan ganda saat iklan tampil:** `show()` kedua selagi yang pertama berjalan langsung false, tidak memuat atau menampilkan iklan kedua. Test di Tugas 4.
3. **Urutan callback SDK:** ditutup tanpa hadiah = false; hadiah lalu ditutup = true; gagal tampil = false; sesudah semua itu iklan berikutnya dimuat. Test di Tugas 4.
4. **Persetujuan belum ada atau ditolak:** `gather()` lambat, gagal, atau `canRequestAds` false → SDK tidak dinyalakan, `show()` cepat false, layar tidak tertahan; kalau persetujuan berubah jadi boleh (lewat formulir privasi), SDK dinyalakan tepat sekali. Test di Tugas 4.
5. **Crash saat dibuka karena konfigurasi Android:** meta-data `APPLICATION_ID` AdMob hilang, resource splash berbahasa salah folder (`drawable-id` bukan `drawable-in`), atau PNG ikon salah ukuran. Test `android_project_test.dart` di Tugas 3 dan 9, plus `flutter build appbundle` di Tugas 11.

---

### Tugas 1: Awal langkah

- [ ] **Langkah 1:** pastikan `gh pr list --state open` kosong dan branch `feat/android-release` bercabang dari `origin/main` (`5d6d38d`). Jalankan `flutter pub get && flutter analyze && flutter test`. Harapan: `No issues found!`, 1830 lulus.
- [ ] **Langkah 2:** commit spec dan rencana ini.

```bash
git add docs/superpowers/specs/2026-10-19-android-release-design.md docs/superpowers/plans/2026-10-20-android-release.md
git commit -m "docs: android release design and plan"
```

### Tugas 2: Polish model dan controller (temuan langkah 13 dan 14)

**Berkas:** `lib/game/model/rewards.dart`, `lib/app/progress_scope.dart`, `lib/screens/closet/closet_screen.dart`, `lib/screens/coins/coin_sheet.dart`; test `test/game/model/rewards_test.dart`, `test/app/progress_test.dart`.

- [ ] **Langkah 1: test gagal.** Di `rewards_test.dart`: `DailyRewards.fromJson({'adDay': d, 'ads': 'x'})`, `{'adDay': d, 'ads': -1}`, dan `{'adDay': d, 'ads': 99}` → `adsWatched == maxAdsPerDay` dan `adsLeft(d) == 0`; `{'ads': 3}` tanpa `adDay` → `adsWatched == 0`. Di grup `kostum` `progress_test.dart`: store yang `saveCoins` melempar sesudah `saveWardrobe` selesai → setelah `load` ulang, kostum dimiliki (urutan simpan: lemari dulu).
- [ ] **Langkah 2:** jalankan kedua berkas test, harapan GAGAL di kasus baru.
- [ ] **Langkah 3:** `fromJson`: `adDay` sah tetapi `ads` rusak atau di luar 0..`maxAdsPerDay` = `maxAdsPerDay`. `buyCostume`: `await store.saveWardrobe(...)` lalu `await store.saveCoins(...)` berurutan (perubahan di memori tetap sebelum menyimpan). `unawaited(...)` untuk `buyCostume`/`wearCostume` di `ClosetScreen` dan `claimDailyBonus` di `coin_sheet.dart`.
- [ ] **Langkah 4:** test berkas tadi plus `closet_screen_test.dart` dan `coin_sheet_test.dart` LULUS.
- [ ] **Langkah 5:** commit `fix: treat broken ad count as used up, save costume before coins`.

### Tugas 3: Polish widget dan pemindahan sheet

**Berkas:**
- Pindah: `lib/screens/level/level_sheet.dart` → `lib/widgets/ko_sheet.dart` (diekspor `widgets/widgets.dart`). Ganti nama `showLevelSheet` → `showKoSheet`, `LevelSheet` → `KoSheet`; `SheetButton` tetap. Perbarui semua impor di `lib/` dan `test/` (10 tempat).
- Ubah: `lib/widgets/ko_pressable.dart`, `lib/widgets/ko_coin_chip.dart`, `lib/screens/closet/closet_screen.dart`, `lib/screens/closet/closet_parts.dart`, `lib/game/render/design_svg.dart`, `lib/game/render/coin_art.dart`, `lib/widgets/game_art.dart`, `lib/app/progress_scope.dart`, `test/test_helpers.dart`.
- Test: `test/widgets/ko_coin_chip_test.dart`, `test/screens/closet_screen_test.dart`.

**Antarmuka:**
- `KoPressable` tambah `double sink = 0` (turun saat ditekan kalau tidak ada `edgeColor`) dan `bool liveRegion = false` (diteruskan ke `Semantics`).
- `CoinView` tambah gaya koin harga (mis. `CoinStyle { full, plain, price }` menggantikan `plain`; pilih yang paling sedikit mengubah pemakai).

- [ ] **Langkah 1: test gagal.** `ko_coin_chip_test.dart`: chip `outlined` dengan `onPressed`, `tester.startGesture` di tengahnya → `tester.getTopLeft` permukaan turun `KoShadow.coinChip.first.offset.dy`; chip yang bisa ditekan (ketiga gaya) punya `SemanticsFlag.isLiveRegion`.
- [ ] **Langkah 2:** jalankan, harapan GAGAL.
- [ ] **Langkah 3:** pasang `sink`/`liveRegion` di `KoPressable`, chip `outlined` memakai `sink`, semua chip yang bisa ditekan `liveRegion: true`.
- [ ] **Langkah 4:** koin label harga kartu kostum: salin SVG koin harga dari `docs/design/source/12-lemari-kostum.html` (garis 2,4) utuh ke `design_svg.dart` sebagai `coinPriceSvg`, gambar lewat `coin_art.dart`. Kalau `docs/design/` tidak ada, berhenti dan beri tahu pemilik repo.
- [ ] **Langkah 5:** tinggi pratinjau Lemari Kostum: jarak yang dipakai Column dan perhitungan `rest` diambil dari satu sumber (mis. record `_ClosetGaps` yang dipakai keduanya), dan tinggi judul diukur dengan `TextPainter` (gaya `heading`, `textScaler`) alih-alih `fontSize * 1.25`. Perilaku sama: `closet_screen_test` dan `overflow_test` tetap lulus.
- [ ] **Langkah 6:** pindahkan sheet, ganti nama, rapikan komentar dokumentasi > 80 kolom di `progress_scope.dart`, `test_helpers.dart`, dan `ko_sheet.dart`. Cek: `grep -rnE '^\s*///.{77,}' lib/app/progress_scope.dart test/test_helpers.dart lib/widgets/ko_sheet.dart` kosong.
- [ ] **Langkah 7:** `flutter analyze` bersih, `flutter test` lulus.
- [ ] **Langkah 8:** commit terpisah per butir (`refactor: move sheet to widgets as KoSheet`, `fix(widgets): coin chip sinks when pressed and stays a live region`, `fix(closet): price coin stroke from design 12`, `refactor(closet): preview height from shared gaps`, `style: wrap long doc comments`).

### Tugas 4: Iklan berhadiah dan persetujuan (Dart, tanpa SDK)

**Berkas:**
- Buat: `lib/app/ad_ids.dart`, `lib/app/ad_consent.dart`, `lib/app/admob_ads.dart`.
- Test: `test/app/admob_ads_test.dart`, `test/app/ad_ids_test.dart`.

**Antarmuka (dipakai Tugas 5 dan 6):**

```dart
// ad_ids.dart
const testRewardedUnit = 'ca-app-pub-3940256099942544/5224354917';
// TEMPEL ID ASLI DI SINI (dua unit; kalau hanya satu, tempel ID yang sama).
const hintRewardedUnit = testRewardedUnit;
const coinRewardedUnit = testRewardedUnit;
enum AdPlacement { hint, coin }
/// Debug/profile selalu ID uji; release memakai konstanta di atas.
String rewardedUnitFor(AdPlacement placement, {bool release = kReleaseMode});
/// Release masih memakai ID uji (dicatat di log saat mulai).
bool get releaseUsesTestAds;

// ad_consent.dart
abstract class AdConsent extends ChangeNotifier {
  Future<void> gather();          // tidak melempar, tidak menahan layar
  bool get canRequestAds;
  bool get privacyOptionsRequired;
  Future<void> showPrivacyOptions();
}
class FakeAdConsent extends AdConsent { /* field bisa diubah + notify, gathered, optionsShown */ }
class UmpAdConsent extends AdConsent { /* Tugas 5 */ }

// admob_ads.dart
abstract interface class RewardedAdHandle {
  void show({required VoidCallback onReward, required VoidCallback onClosed});
  void dispose();
}
/// null = gagal dimuat.
typedef RewardedAdLoader = Future<RewardedAdHandle?> Function(String unitId);
class AdMobRewardedAds implements RewardedAds {
  AdMobRewardedAds({required String unitId, required bool Function() canLoad,
      required RewardedAdLoader load, Duration loadTimeout = defaultLoadTimeout});
  static const defaultLoadTimeout = Duration(seconds: 10);
  void preload();
  @override Future<bool> show();
}
class GameAds {
  GameAds({required AdConsent consent, required Future<void> Function() startSdk,
      required RewardedAdLoader load, bool release = kReleaseMode});
  final AdConsent consent;
  late final AdMobRewardedAds hints, coins;
  bool get sdkReady;
  Future<void> start();
}
```

Perilaku `AdMobRewardedAds`: `preload()` memuat satu iklan kalau `canLoad()`, belum ada iklan, dan tidak sedang memuat. `show()`: false kalau sedang tampil atau `!canLoad()`; pakai iklan siap atau tunggu muatan dengan `loadTimeout`; selesai saat `onClosed` dengan hasil = `onReward` sudah terjadi; sesudah ditutup `dispose` lalu `preload()`. Iklan gagal dimuat tidak dicoba ulang otomatis; `show()` berikutnya memuat lagi. Semua error ditelan jadi false. `GameAds.start()`: dengarkan `consent`, `await consent.gather()` (error ditelan), lalu setiap kali `canRequestAds` true dan SDK belum menyala: `startSdk()` sekali, `sdkReady = true`, `preload()` kedua unit. `canLoad` kedua unit = `() => sdkReady`.

- [ ] **Langkah 1: test gagal** di `admob_ads_test.dart` dengan `_FakeLoader` (mencatat `unitId`, mengembalikan `Completer` yang dikendalikan test) dan `_FakeHandle` (mencatat `shown`, `disposed`, memicu callback):
  - `show tanpa iklan siap memuat lalu true kalau onReward lalu onClosed`
  - `ditutup tanpa hadiah = false`; `onClosed saja dari gagal tampil = false`
  - `sesudah ditutup handle di-dispose dan iklan berikutnya dimuat` (loader dipanggil 2×)
  - `gagal dimuat (null) = false, show berikutnya memuat lagi`
  - `loader melempar = false`; `handle.show melempar = false`
  - `waktu habis = false; iklan yang datang terlambat dipakai show berikutnya tanpa memuat lagi` (`loadTimeout: Duration(milliseconds: 10)`)
  - `show kedua selagi tampil = false, loader tidak dipanggil lagi`
  - `canLoad false = false tanpa memanggil loader`; `preload saat canLoad false tidak memuat`
  - `GameAds`: `gather lalu canRequestAds true → startSdk sekali dan kedua unit dimuat dengan ID uji`; `canRequestAds false → startSdk tidak dipanggil, hints.show() false`; `gather melempar → start selesai tanpa error`; `persetujuan berubah jadi true sesudahnya → startSdk sekali` (notify dua kali, tetap sekali); `startSdk melempar → sdkReady false, show false`.
  - `ad_ids_test.dart`: `rewardedUnitFor(p, release: false) == testRewardedUnit` untuk kedua tempat; `release: true` = `hintRewardedUnit`/`coinRewardedUnit`; ID mengikuti pola `ca-app-pub-\d+/\d+`.
- [ ] **Langkah 2:** `flutter test test/app/admob_ads_test.dart test/app/ad_ids_test.dart`, harapan GAGAL (berkas belum ada).
- [ ] **Langkah 3:** tulis ketiga berkas sesuai antarmuka di atas (tanpa impor `google_mobile_ads`; `UmpAdConsent` dan loader asli di Tugas 5).
- [ ] **Langkah 4:** test LULUS.
- [ ] **Langkah 5:** commit `feat(ads): rewarded ads and consent behind fakeable seams`.

### Tugas 5: SDK asli, dua unit iklan, dan identitas Android

**Berkas:**
- Ubah: `pubspec.yaml` (`flutter pub add google_mobile_ads url_launcher`; dev `url_launcher_platform_interface plugin_platform_interface`; `version: 1.0.0+1`), `lib/app/admob_ads.dart` (loader asli), `lib/app/ad_consent.dart` (`UmpAdConsent`), `lib/app/progress_scope.dart`, `lib/main.dart`, `test/test_helpers.dart`.
- Android: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, pindah `android/app/src/main/kotlin/com/example/kucing_oren/MainActivity.kt` → `.../kotlin/com/gingerlogic/app/MainActivity.kt` (`package com.gingerlogic.app`).
- Test: `test/app/android_project_test.dart`, `test/app/progress_test.dart`.

**Antarmuka:**
- `ProgressController({..., RewardedAds? hintAds, RewardedAds? coinAds})` dan `load(...)` yang sama; field `hintAds` (dipakai `unlockHint`), `coinAds` (dipakai `watchAdForCoins`); `ads` dihapus. `testProgressWith(ads:)` tetap satu parameter dan mengisi keduanya.
- `Future<RewardedAdHandle?> loadAdMobRewarded(String unitId)` dan `Future<void> startAdMob()` di `admob_ads.dart` (`startAdMob` = `updateRequestConfiguration(RequestConfiguration(maxAdContentRating: MaxAdContentRating.g, tagForChildDirectedTreatment: TagForChildDirectedTreatment.no, tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no))` lalu `initialize()`).
- `UmpAdConsent.gather()`: baca `canRequestAds()` sisa sesi lalu (pemain lama dapat iklan cepat), `requestConsentInfoUpdate`, `loadAndShowConsentFormIfRequired`, perbarui `canRequestAds` dan `privacyOptionsRequired` (`getPrivacyOptionsRequirementStatus() == required`), `notifyListeners()`. `showPrivacyOptions()` = `showPrivacyOptionsForm` lalu perbarui dan notify.

- [ ] **Langkah 1:** `flutter pub add ...`; baca API `google_mobile_ads` dan `url_launcher` versi terpasang dari pub cache (`RewardedAd.load`, `FullScreenContentCallback`, `ConsentInformation`, `ConsentForm`, `RequestConfiguration`) sebelum menulis kode. Catat versi dan minSdk yang diminta.
- [ ] **Langkah 2: test gagal.** `progress_test.dart`: `unlockHint(..., HintPay.ad)` memanggil `hintAds` saja dan `watchAdForCoins` memanggil `coinAds` saja (dua `FakeRewardedAds` terpisah, cek `shown`). `android_project_test.dart` (baca berkas sebagai teks):
  - `build.gradle.kts` memuat `applicationId = "com.gingerlogic.app"`, `namespace = "com.gingerlogic.app"`, `admobAppId`, dan `TEMPEL ID ASLI DI SINI`.
  - manifest memuat `com.google.android.gms.ads.APPLICATION_ID` dengan `${admobAppId}`, tidak memuat `allowBackup="false"`, dan memuat `<queries>` VIEW `https`.
  - `MainActivity.kt` ada di `kotlin/com/gingerlogic/app/` dengan `package com.gingerlogic.app`.
  - `pubspec.yaml` `version: 1.0.0+1`.
- [ ] **Langkah 3:** jalankan, harapan GAGAL.
- [ ] **Langkah 4:** Gradle:
  - `val admobAppId = "ca-app-pub-3940256099942544~3347511713" // TEMPEL ID ASLI DI SINI` → `manifestPlaceholders["admobAppId"]`, dan `logger.warn` saat tugas release kalau masih ID uji.
  - Signing: baca `rootProject.file("key.properties")` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`); ada = `signingConfigs.release`, tidak ada = debug key + `logger.warn`.
  - minSdk sesuai kebutuhan paket kalau di atas `flutter.minSdkVersion`.
- [ ] **Langkah 5:** manifest meta-data AdMob dan `<queries>` https; pindah `MainActivity`.
- [ ] **Langkah 6:** pisahkan `hintAds`/`coinAds` di controller; `UmpAdConsent`, `loadAdMobRewarded`, `startAdMob`. `main.dart`:
  - `consent = UmpAdConsent()` dan `ads = GameAds(consent:, startSdk: startAdMob, load: loadAdMobRewarded)`.
  - `hintAds: audio.pauseDuringAds(ads.hints)`, `coinAds: audio.pauseDuringAds(ads.coins)`.
  - `runApp(KucingOrenApp(..., consent: consent))` lalu `unawaited(ads.start())`.
  - `debugPrint` peringatan kalau `kReleaseMode && releaseUsesTestAds`.
  - `consent:` di `KucingOrenApp` baru ada di Tugas 6; sampai itu jangan dioper.
- [ ] **Langkah 7:** `flutter analyze` bersih, `flutter test` lulus, `flutter build apk --debug` berhasil.
- [ ] **Langkah 8:** commit terpisah: `feat(android): com.gingerlogic.app, version 1.0.0, release signing`, `feat(ads): AdMob rewarded ads and UMP consent for hints and coins`.

### Tugas 6: Bagian Privasi di Pengaturan

**Berkas:**
- Buat: `lib/app/privacy.dart`.
- Ubah: `lib/app/app.dart`, `lib/screens/settings/settings_screen.dart`, `settings_parts.dart`, empat ARB, `lib/main.dart`, `test/test_helpers.dart` (`pumpApp(consent:)`).
- Test: `test/screens/settings_screen_test.dart`, `test/screens/overflow_test.dart`.

**Antarmuka:**
- `privacy.dart`: `const privacyPolicyUrl = 'https://yoluvy.my.id/ginger-logic/privacy/';` dan `Future<bool> openPrivacyPolicy()` (`launchUrl(..., mode: LaunchMode.externalApplication)`, error = false).
- `KucingOrenApp({..., AdConsent? consent})` dipasang lewat `AdConsentScope` (`InheritedNotifier<AdConsent>`, `maybeOf(context)`; null = tombol persetujuan tidak tampil).
- `PrivacyCard({required VoidCallback onPolicy, VoidCallback? onConsent, String? message})`, tombol berkunci `privacy-policy` dan `privacy-consent`, gaya `ActionCard`/`SheetButton`.
- Kunci ARB (id / en): `privacySection` "Privasi" / "Privacy"; `privacyInfo` "Progresmu tersimpan di HP sendiri. Iklannya dari Google AdMob." / "Your progress stays on your phone. Ads come from Google AdMob."; `privacyPolicy` "Kebijakan privasi" / "Privacy policy"; `adConsent` "Atur persetujuan iklan" / "Ad consent settings"; `privacyLinkFailed` "Browser-nya belum mau kebuka. Coba lagi nanti, ya." / "Couldn't open the browser. Try again later, okay?". PT dan RU dengan nada yang sama.

- [ ] **Langkah 1: test gagal** di `settings_screen_test.dart` (fake `UrlLauncherPlatform` dengan `MockPlatformInterfaceMixin`, mencatat URL, hasil bisa diatur):
  - bagian Privasi ada di antara Progres dan Tentang (urutan `getTopLeft().dy`)
  - ketuk `privacy-policy` → URL tercatat sama dengan `privacyPolicyUrl`; launcher false → pesan `privacyLinkFailed` tampil
  - `FakeAdConsent(privacyOptionsRequired: false)` → `privacy-consent` tidak ada; `true` → ada, ketuk → `optionsShown == 1`; consent berubah jadi true sesudah layar tampil → tombol muncul tanpa membuka ulang.
- [ ] **Langkah 2:** jalankan, harapan GAGAL.
- [ ] **Langkah 3:** ARB keempat bahasa, `flutter gen-l10n`, `privacy.dart`, `AdConsentScope`, `PrivacyCard`, pasang di Pengaturan; `main.dart` mengoper `consent`.
- [ ] **Langkah 4:** `overflow_test.dart`: Pengaturan digulir sampai Tentang dengan `FakeAdConsent(privacyOptionsRequired: true)` dan `false`, di keempat bahasa dan teks 130%, plus pesan `privacyLinkFailed` tampil.
- [ ] **Langkah 5:** `flutter test test/screens test/l10n` LULUS, analyze bersih.
- [ ] **Langkah 6:** commit `feat(settings): privacy section with policy link and ad consent`.

### Tugas 7: Gambar merek (kepala Oyen dan logo)

**Berkas:**
- Buat: `lib/game/render/brand_art.dart` (ekspor `render.dart`), `lib/widgets/game_logo.dart` (ekspor `widgets.dart`).
- Ubah: `lib/screens/home/home_screen.dart` (pakai `GameLogo`), empat ARB (`splashTagline`).
- Test: `test/game/render/brand_art_test.dart`.

**Antarmuka:**
- `BrandArt.headBox = Rect.fromLTRB(16, 8, 84, 68)` (kotak kepala di viewBox Oyen 100).
- `paintOyenHead(Canvas canvas, {required double width})`: Oyen depan, `OyenPose.idle` (mata ngantuk), dari `SvgTemplate(oyenSvg)` dengan `{...oyenVals(look), 'isNormal': false, 'showTailSide': false}`, dipotong ke `headBox` (bayangan di y ≥ 85 ikut terbuang), diskalakan supaya lebar `headBox` = `width`, pojok kiri atas di titik asal.
- `paintOyenHeadMono(Canvas canvas, {required double width, required Color color})`: kepala yang sama di `saveLayer` dengan `ColorFilter.matrix` ambang luminans 0,6: petak terang (bulu, moncong, telinga dalam) jadi `color` buram, yang gelap (mata, hidung, mulut, belang) jadi lubang transparan.
- `GameLogo()`: "Ginger" `logoSmall` tinta di atas "Logic" `logo` oranye dengan `KoShadow.logo`, `Semantics(header: true, label: appName)`. Beranda memakainya tanpa perubahan tampilan.
- ARB `splashTagline`: EN "Let's play!", ID "Ayo main!", PT "Bora jogar!", RU "Играем!".

- [ ] **Langkah 1: test gagal** di `brand_art_test.dart` (pakai helper warna piksel test render yang ada):
  - `paintOyenHead(width: 68)` → piksel (34, 34) (tengah kepala) = oranye kepala `#F5A447`, piksel moncong (34, 48) = `#FDE6C4`, piksel mata (20, 37) gelap `#3A2618`, dan piksel di luar kepala (2, 58) transparan.
  - `paintOyenHeadMono(width: 68, color: white)` → tengah kepala putih buram, mata (20, 37) transparan, garis belang dahi (34, 12) transparan, luar kepala transparan.
- [ ] **Langkah 2:** jalankan, harapan GAGAL.
- [ ] **Langkah 3:** tulis `brand_art.dart`, `GameLogo`, kunci `splashTagline`, `flutter gen-l10n`.
- [ ] **Langkah 4:** `flutter test test/game/render test/screens/home_chapter_test.dart test/l10n` LULUS (geser koordinat piksel test kalau titik yang dipilih ternyata di garis tepi, bukan mengubah gambarnya).
- [ ] **Langkah 5:** commit `feat(render): Oyen head brand art and shared game logo`.

### Tugas 8: Generator ikon, splash, dan gambar toko

**Berkas:**
- Buat: `test/screenshots/brand_test.dart`, `test/screenshots/scenes.dart` (pindahan `_place`/`_showResult` dari `screenshot_test.dart`).
- Ubah: `test/screenshots/capture.dart` (tambah `captureFile`).
- Keluaran (di-commit): `android/app/src/main/res/` dan `docs/store/`.

**Antarmuka:**
- `const brandEnabled = bool.fromEnvironment('BRAND');`
- `Future<void> captureFile(WidgetTester tester, String path, {double pixelRatio = 2})`. `capture` memakainya.
- Perintah: `flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true`. Tanpa define, semua dilewati.

Keluaran (ukuran dalam dp; densitas `mdpi` ×1, `hdpi` ×1,5, `xhdpi` ×2, `xxhdpi` ×3, `xxxhdpi` ×4; isi di tengah):

| Berkas | Ukuran | Isi |
|---|---|---|
| `mipmap-<dpi>/ic_launcher_foreground.png` | 108 | kepala lebar 56 (muat di zona aman 66), latar transparan |
| `mipmap-<dpi>/ic_launcher_monochrome.png` | 108 | kepala mono putih lebar 56 |
| `mipmap-<dpi>/ic_launcher.png` | 48 | lingkaran krem 46 + kepala lebar 34 (Android < 8) |
| `drawable-<dpi>/splash_icon.png` | 288 | kepala lebar 150 (muat di lingkaran 192), transparan |
| `drawable[-in\|-pt\|-ru]-<dpi>/splash_branding.png` | 200×80 | `GameLogo` + `splashTagline` per bahasa (default Inggris), `FittedBox`, transparan |
| `values/colors.xml` | | `<color name="cream">` dari `KoColors.cream` |
| `docs/store/icon-512.png` | 512 px | kotak krem penuh, kepala lebar 300 px |
| `docs/store/feature-graphic.png` | 1024×500 px | krem; Oyen tidur (`OyenPose.sleep`, Zzz) di kiri, `GameLogo` + `tagline` Inggris di kanan |
| `docs/store/screenshots/<en\|id\|pt\|ru>/NN-nama.png` | 360×640 × 3 = 1080×1920 px | `01-beranda`, `02-peta-babak-2`, `03-fase-atur-level-13`, `04-fase-jalan-level-13` (langkah 2), `06-berhasil-level-13`, `12-lemari-kostum`; progres seperti potret desain, saldo 120 |

Folder Indonesia memakai kualifier Android `-in`, bukan `-id`.

- [ ] **Langkah 1:** pindahkan `_place`/`_showResult` ke `scenes.dart`, tambah `captureFile`; `flutter test test/screenshots --dart-define=SCREENSHOTS=true` tetap menghasilkan potret yang sama.
- [ ] **Langkah 2:** tulis `brand_test.dart`, jalankan dengan `BRAND=true`.
- [ ] **Langkah 3: cek hasil.** Lihat PNG lewat Read:
  - ikon dengan masker lingkaran dan squircle di atasnya (buat pratinjau di scratchpad, tidak di-commit)
  - monokrom
  - splash di atas krem
  - branding keempat bahasa (Sirilik memakai Nunito cadangan)
  - feature graphic
  - satu potret toko per bahasa

  Perbaiki ukuran atau letak sampai rapi dan tidak terpotong.
- [ ] **Langkah 4:** commit `feat(brand): generator for launcher icon, splash, and store images` (kode dan PNG).

### Tugas 9: Ikon adaptif dan splash Android

**Berkas:**
- Buat: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (`<adaptive-icon>`: `background` `@color/cream`, `foreground` dan `monochrome` mipmap Tugas 8), `res/values-v31/styles.xml`.
- Ubah: `res/values/styles.xml`, `res/drawable/launch_background.xml`.
- Hapus: `res/values-night/styles.xml`, `res/drawable-v21/launch_background.xml` (game tanpa mode gelap; satu versi krem).
- Test: `test/app/android_project_test.dart`.

Isi:
- `values/styles.xml`: `LaunchTheme` `windowBackground` = `@drawable/launch_background`; `NormalTheme` `windowBackground` = `@color/cream` (tanpa kedip putih).
- `values-v31/styles.xml`: `LaunchTheme` dengan `android:windowSplashScreenBackground` `@color/cream`, `android:windowSplashScreenAnimatedIcon` `@drawable/splash_icon` (nama atribut yang benar; spec menulis "AnimatableIcon"), `android:windowSplashScreenBrandingImage` `@drawable/splash_branding`; `NormalTheme` sama dengan `values`.
- `launch_background.xml`: krem, `splash_icon` di tengah, `splash_branding` di bawah tengah dengan jarak bawah 48dp.

- [ ] **Langkah 1: test gagal** di `android_project_test.dart`:
  - setiap PNG tabel Tugas 8 ada untuk kelima densitas, dengan lebar×tinggi dari header IHDR = dp × faktor densitas (dibulatkan)
  - `splash_branding.png` ada di default, `-in`, `-pt`, `-ru`, dan tidak ada folder `drawable-id*`
  - `values/colors.xml` cream = `KoColors.cream` dari `KoTheme.light()`
  - `ic_launcher.xml` merujuk `@color/cream`, `ic_launcher_foreground`, `ic_launcher_monochrome`
  - `values-v31/styles.xml` memuat ketiga atribut splash
  - `values-night/` tidak ada
- [ ] **Langkah 2:** jalankan, harapan GAGAL di bagian XML.
- [ ] **Langkah 3:** tulis XML di atas.
- [ ] **Langkah 4:** test LULUS; `flutter build apk --debug` berhasil. Kalau ada HP atau emulator (`adb devices`): pasang, cek ikon di launcher, ikon tema, splash, dan iklan uji di petunjuk dan Tambah Koin. Kalau tidak ada, tulis di PR bahwa cek di perangkat belum dilakukan.
- [ ] **Langkah 5:** commit `feat(android): adaptive launcher icon and themed splash`.

### Tugas 10: Dokumen toko

**Berkas (buat):** `docs/store/README.md`, `docs/store/listing-{en,id,pt,ru}.md`, `docs/store/privacy/index.html`, `docs/store/privacy/README.md`.

- [ ] **Langkah 1:** periksa panduan Google terkini (WebFetch/WebSearch): data yang dikumpulkan AdMob untuk formulir Data safety, Auto Backup ke akun Google (bukan "dikumpulkan" pengembang), dan kuesioner rating konten IARC. Simpan tautannya untuk README.
- [ ] **Langkah 2:** `listing-en.md` dulu, lalu `id`, `pt`, `ru`. Isinya:
  - judul sesuai spec
  - deskripsi singkat ≤ 80 karakter
  - deskripsi panjang ≤ 4000 karakter, nada santai dan jenaka; pakai "turns clockwise" untuk aturan
- [ ] **Langkah 3:** `privacy/index.html`: satu halaman statis tanpa skrip luar, bagian ber-anchor `#en`, `#id`, `#pt`, `#ru`, dengan isi sesuai spec dan tanggal berlaku 20 Oktober 2026. `privacy/README.md`: salin ke `ginger-logic/privacy/index.html` di repo GitHub Pages `yoluvy.my.id`, lalu cek URL-nya terbuka.
- [ ] **Langkah 3a:** cek isi kebijakan privasi mencakup:
  - tanpa akun dan tanpa server sendiri
  - progres di HP dan Auto Backup Android (bisa dimatikan pemain)
  - AdMob: ID iklan, perkiraan lokasi dari IP, info perangkat; iklan dipersonalisasi hanya dengan persetujuan
  - menarik persetujuan lewat Pengaturan → Privasi
  - anak di bawah 13
  - kontak dan nama pengembang
- [ ] **Langkah 4:** `README.md`:
  - isi folder dan pemetaan ke kolom Play Console
  - jawaban Data safety dan rating konten beserta tautan dari langkah 1
  - **daftar wajib sebelum produksi:** `admobAppId` di `build.gradle.kts`, `hintRewardedUnit`/`coinRewardedUnit` di `ad_ids.dart`, unggah kebijakan privasi
  - perintah `keytool -genkey -v -keystore <di luar repo>/ginger-logic-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`, contoh `android/key.properties`, pengingat backup keystore dan sandi, Play App Signing
  - perintah generator gambar
  - `flutter build appbundle` dan lokasi `.aab`
- [ ] **Langkah 5:** cek panjang: skrip kecil di scratchpad menghitung karakter judul (≤ 30), deskripsi singkat (≤ 80), dan panjang (≤ 4000) tiap bahasa. Semua lolos.
- [ ] **Langkah 6:** commit `docs(store): listings, privacy policy, and release guide`.

### Tugas 11: Dokumen proyek, verifikasi, dan PR

- [ ] **Langkah 1:** centang "Isi versi pertama" di `docs/GDD.md` dan langkah 17 di `docs/ROADMAP.md` (beri baris "Selesai: ..." seperti langkah 16).
- [ ] **Langkah 1a:** `docs/DESIGN_NOTES.md` bagian "Langkah 17" mencatat:
  - ikon, monokrom, dan splash (ukuran dp di atas)
  - tagline splash, judul toko, rating `G`
  - jalur URL privasi, nama "Yoluvy"
  - perilaku ID uji di release
  - feature graphic dan potret toko 1080×1920
  - pemindahan sheet ke `KoSheet`
  - batas waktu muat iklan 10 detik dan tanpa coba ulang otomatis
- [ ] **Langkah 2:** perbarui "Struktur" di `CLAUDE.md`:
  - `ad_ids.dart`, `ad_consent.dart`, `admob_ads.dart`, `privacy.dart`, `AdConsentScope`
  - `hintAds`/`coinAds`, `KoSheet`/`showKoSheet` (ganti semua sebutan `showLevelSheet`/`LevelSheet`)
  - `GameLogo`, `brand_art.dart`
  - generator `brand_test.dart` dengan perintahnya, `docs/store/`
  - signing `key.properties`, `applicationId`
  - test `admob_ads_test`, `android_project_test`
- [ ] **Langkah 3:** commit `docs: step 17 notes, structure, and roadmap`.
- [ ] **Langkah 4:** `/check` (format, analyze, test). Harapan: `No issues found!` dan semua test lulus (catat jumlahnya).
- [ ] **Langkah 5:** `flutter build appbundle`. Harapan: berhasil dengan peringatan debug key dan ID uji; `build/app/outputs/bundle/release/app-release.aab` ada (catat ukurannya).
- [ ] **Langkah 6:** review: `superpowers:requesting-code-review` (satu subagent effort high), lalu `superpowers:receiving-code-review`, perbaiki, lalu `superpowers:verification-before-completion`.
- [ ] **Langkah 7:** `git push -u origin feat/android-release` dan `gh pr create --base main`.
  - Judul: `feat: Polish dan rilis Android`.
  - Badan dibuka "Langkah 17 roadmap: ...", lalu daftar perubahan.
  - Asumsi baru: keputusan 1–10 yang disetujui.
  - Bagian **"Wajib sebelum rilis produksi"**: ID AdMob asli, keystore + `key.properties`, unggah kebijakan privasi.
  - Baris "Verifikasi:" berisi analyze, jumlah test, build appbundle, generator gambar, dan cek perangkat (atau "belum").
  - Tanpa atribusi Claude. Kirim link PR.
