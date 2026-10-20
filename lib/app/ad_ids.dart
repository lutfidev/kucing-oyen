import 'package:flutter/foundation.dart';

/// ID unit iklan berhadiah uji Google untuk Android. Selalu dipakai di
/// build debug dan profile, supaya iklan asli tidak pernah diklik saat
/// mencoba.
const testRewardedUnit = 'ca-app-pub-3940256099942544/5224354917';

// TEMPEL ID ASLI DI SINI: ID unit iklan berhadiah dari AdMob (Aplikasi →
// Unit iklan). Dua unit supaya laporan petunjuk dan koin terpisah; kalau
// hanya satu unit dibuat, tempel ID yang sama di keduanya. Selama masih ID
// uji, build release juga memakai iklan uji (lihat docs/store/README.md).
// ID aplikasi AdMob ditempel di android/app/build.gradle.kts (admobAppId).

/// Unit iklan berhadiah untuk membuka petunjuk (release).
const hintRewardedUnit = testRewardedUnit;

/// Unit iklan berhadiah untuk koin tambahan (release).
const coinRewardedUnit = testRewardedUnit;

/// Tempat iklan berhadiah diputar.
enum AdPlacement { hint, coin }

/// ID unit untuk [placement]: debug dan profile selalu [testRewardedUnit],
/// release memakai ID tempelan.
String rewardedUnitFor(AdPlacement placement, {bool release = kReleaseMode}) {
  if (!release) return testRewardedUnit;
  return switch (placement) {
    AdPlacement.hint => hintRewardedUnit,
    AdPlacement.coin => coinRewardedUnit,
  };
}

/// Build release masih memakai ID uji (ID asli belum ditempel).
bool get releaseUsesTestAds =>
    hintRewardedUnit == testRewardedUnit ||
    coinRewardedUnit == testRewardedUnit;
