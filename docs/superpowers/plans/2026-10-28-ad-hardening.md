# Pengerasan Iklan dan Rilis Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Langkah 18 roadmap: sepuluh temuan kecil review langkah 17 (PR #19) dibereskan tanpa mengubah perilaku yang sudah dites.

**Architecture:** Perubahan ada di alur `AdMobRewardedAds`/`GameAds` (`lib/app/admob_ads.dart`, diuji lewat celah `RewardedAdHandle`/`RewardedAdLoader`), sambungan SDK (`admob_sdk.dart`, tanpa test), Pengaturan, dan konfigurasi Android.

**Tech Stack:** Flutter, `google_mobile_ads` 9.1.0, Gradle Kotlin DSL.

**Spec:** prompt langkah 18 di `docs/ROADMAP.md`; latar di `docs/DESIGN_NOTES.md` "Langkah 17".

## Global Constraints

- Jangan mengubah ID iklan, alur persetujuan, atau teks pemain.
- `show()` tetap tidak pernah melempar; ketukan kedua selagi iklan berjalan tetap false.
- Test yang gagal dulu untuk setiap perilaku yang bisa diuji.
- Keputusan dicatat di `docs/DESIGN_NOTES.md` bagian "Langkah 18".

## Review Focus

- Hadiah datang sesudah `onClosed`, lalu `onClosed` dipanggil lagi: hasil tetap true, ad di-dispose sekali.
- SDK sedang dinyalakan lalu gagal: `show()` false dan coba ulang tetap dipicu (`_onUnavailable`).
- Pemuat melempar sinkron berulang kali: `preload` dan `show` tetap bisa memuat lagi.
- Batas pengaman tampil habis sesudah hadiah tanpa ditutup: true (hadiah tidak hilang).
- `flutter build apk --release`/`assembleRelease` tanpa `key.properties` tetap jalan.

---

### Task 1: Hadiah sesudah ditutup dan batas pengaman tampil (temuan 1, 4)

**Files:** Modify `lib/app/admob_ads.dart` (`_present`, konstruktor). Test `test/app/admob_ads_test.dart`.

**Interfaces:** Produces `AdMobRewardedAds({..., Duration rewardGrace = defaultRewardGrace, Duration showTimeout = defaultShowTimeout})`, `static const defaultRewardGrace = Duration(milliseconds: 400)`, `static const defaultShowTimeout = Duration(minutes: 10)`.

- [ ] Test `hadiah sesudah ditutup dalam jeda = true`: `ad.onClosed!(); ad.onReward!();` → `await result` true, `ad.disposed` true.
- [ ] Test `hadiah sesudah jeda lewat = false`: `rewardGrace: 10 ms`, `onClosed`, tunggu 30 ms, `onReward` → false.
- [ ] Test `ditutup tanpa hadiah menunggu jeda lalu false` (yang lama tetap lulus).
- [ ] Test `tidak pernah ditutup: batas pengaman`: `showTimeout: 20 ms`, tanpa callback → false, `ad.disposed`, `show()` berikutnya bisa memuat; varian dengan `onReward` tanpa `onClosed` → true.
- [ ] Implementasi: `onReward` mencatat `earned` dan menyelesaikan true kalau sudah ditutup; `onClosed` menyelesaikan true kalau `earned`, selain itu `Timer(rewardGrace)` → false; seluruh tunggu dibungkus `.timeout(showTimeout, onTimeout: () => earned)`.
- [ ] `flutter test test/app/admob_ads_test.dart` lulus, commit `fix(ads): keep late rewards and cap ad show time`.

### Task 2: Pemuat melempar sinkron (temuan 3)

**Files:** `lib/app/admob_ads.dart` (`_startLoad`), test.

- [ ] Test `pemuat melempar sinkron tidak macet`: pemuat non-async yang melempar di panggilan pertama lalu mengembalikan `_FakeLoader`; `show()` false, `show()` kedua memanggil pemuat lagi dan true sesudah ditonton.
- [ ] Implementasi: `_loadOne()` async; `_startLoad` menyimpan future di variabel lokal, `_loading = loading`, lalu `whenComplete` mengosongkan `_loading` hanya kalau `identical`.
- [ ] Test lulus, commit `fix(ads): recover when the ad loader throws synchronously`.

### Task 3: Tunggu SDK yang sedang dinyalakan (temuan 5) dan test `gather` lambat (temuan 10)

**Files:** `lib/app/admob_ads.dart` (`AdMobRewardedAds.show`, `GameAds`), test.

**Interfaces:** `AdMobRewardedAds({..., Future<void>? Function()? starting})`: future SDK yang sedang dinyalakan, atau null. `GameAds` menyimpan `Future<void>? _startingSdk` menggantikan `bool _starting`.

- [ ] Test `AdMobRewardedAds`: `canLoad` false dan `starting` mengembalikan future yang lalu membuat `canLoad` true → iklan dimuat dan tampil, true. Varian: SDK tidak selesai dalam `loadTimeout` 10 ms → false dan `onUnavailable` terpanggil.
- [ ] Test `GameAds`: `startSdk` menunggu `Completer`; `show()` selagi menyala → sesudah SDK selesai dan iklan dimuat, tampil, true.
- [ ] Test `GameAds` temuan 10: `gather()` lambat yang lebih dulu mengubah `canRequestAds = true` (persetujuan sesi lalu) → sebelum `gather` selesai SDK sudah menyala sekali dan kedua unit memuat; sesudah selesai `started` tetap 1.
- [ ] Implementasi: `show()` menunggu `starting` lalu iklan dalam satu batas `loadTimeout`; kalau sesudahnya `canLoad` masih false → `_onUnavailable`, false.
- [ ] Test lulus, commit `fix(ads): wait for the SDK that is starting before failing an ad`.

### Task 4: SDK, persetujuan dua kali, komentar (temuan 2, 7, 9)

**Files:** `lib/app/admob_sdk.dart`, `lib/screens/settings/settings_screen.dart`, `lib/app/rewarded_ads.dart`, `test/screens/settings_screen_test.dart`.

- [ ] Test grup `privasi`: persetujuan palsu yang `showPrivacyOptions` menunggu `Completer`; dua ketukan cepat → `optionsShown` 1; sesudah selesai, ketukan lagi → 2.
- [ ] Implementasi: `_consentOpen` di state Pengaturan, dikosongkan di `finally`. `loadAdMobRewarded`: `isCompleted` dijaga di `onAdLoaded` (iklan dobel di-dispose) dan `onAdFailedToLoad`. Komentar `RewardedAds`: iklan asli `AdMobRewardedAds`, palsu untuk test.
- [ ] Test lulus, commit `fix: open the consent form once per tap and guard ad load callbacks`.

### Task 5: Android (temuan 6, 8)

**Files:** `android/app/src/main/res/values-v31/styles.xml`, `android/app/build.gradle.kts`, `test/app/android_project_test.dart`, `docs/store/README.md`.

- [ ] Test: `LaunchTheme` v31 memuat `android:windowBackground` `@color/cream`; Gradle memuat `bundleRelease` dan `GradleException`.
- [ ] Implementasi: `windowBackground` `@color/cream` (bukan `launch_background`, supaya kepala tidak melompat sesudah splash sistem). `bundleRelease` tanpa `key.properties` → `GradleException` berpesan jelas; tugas release lain tetap peringatan.
- [ ] Cek: `gradlew bundleRelease --dry-run` gagal dengan pesan, `gradlew assembleRelease --dry-run` jalan.
- [ ] README: bagian peringatan dan Signing. Commit `build(android): refuse unsigned app bundles and cream splash fallback`.

### Task 6: Catatan dan penutup

- [ ] `docs/DESIGN_NOTES.md` "Langkah 18", centang roadmap + ringkasan "Selesai", `CLAUDE.md` Struktur (`rewardGrace`, `showTimeout`, `starting`).
- [ ] `/check`, review, PR.
