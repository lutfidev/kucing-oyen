import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent.dart';
import 'admob_ads.dart';

// Sambungan ke SDK Google Mobile Ads dan UMP. Hanya dipakai `main`; alurnya
// diuji lewat celah di admob_ads.dart dan ad_consent.dart.

/// Menyetel permintaan iklan lalu menyalakan SDK. Iklan tidak ditandai
/// untuk anak (target audiens 13+), dengan rating konten paling tinggi G
/// supaya cocok untuk pemain keluarga.
Future<void> startAdMob() async {
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
    ),
  );
  await MobileAds.instance.initialize();
}

/// Memuat satu iklan berhadiah AdMob; null kalau gagal dimuat.
Future<RewardedAdHandle?> loadAdMobRewarded(String unitId) {
  final loaded = Completer<RewardedAdHandle?>();
  unawaited(
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // Panggilan kedua (seharusnya tidak terjadi) dibuang, iklannya juga.
          if (loaded.isCompleted) {
            unawaited(ad.dispose());
          } else {
            loaded.complete(_AdMobHandle(ad));
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Iklan berhadiah gagal dimuat: $error');
          if (!loaded.isCompleted) loaded.complete(null);
        },
      ),
    ).catchError((Object error) {
      if (!loaded.isCompleted) loaded.complete(null);
    }),
  );
  return loaded.future;
}

class _AdMobHandle implements RewardedAdHandle {
  _AdMobHandle(this._ad);

  final RewardedAd _ad;

  @override
  void show({required VoidCallback onReward, required VoidCallback onClosed}) {
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => onClosed(),
      onAdFailedToShowFullScreenContent: (_, error) {
        debugPrint('Iklan berhadiah gagal tampil: $error');
        onClosed();
      },
    );
    unawaited(
      _ad
          .show(onUserEarnedReward: (_, _) => onReward())
          .catchError((Object _) => onClosed()),
    );
  }

  @override
  void dispose() => unawaited(_ad.dispose());
}

/// Persetujuan lewat UMP (Google User Messaging Platform).
class UmpAdConsent extends AdConsent {
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  Future<void> gather() async {
    try {
      // Persetujuan sesi lalu: pemain lama langsung bisa mendapat iklan.
      await _refresh();
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        updated.complete,
        (error) => updated.completeError(error.message),
      );
      await updated.future;
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('Formulir persetujuan: ${error.message}');
      });
    } on Object catch (error) {
      debugPrint('Persetujuan iklan gagal diperbarui: $error');
    }
    await _refresh();
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) debugPrint('Formulir privasi: ${error.message}');
      });
    } on Object catch (error) {
      debugPrint('Formulir privasi gagal dibuka: $error');
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      final info = ConsentInformation.instance;
      final can = await info.canRequestAds();
      final required =
          await info.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
      if (can == _canRequestAds && required == _privacyOptionsRequired) return;
      _canRequestAds = can;
      _privacyOptionsRequired = required;
      notifyListeners();
    } on Object catch (error) {
      debugPrint('Status persetujuan tidak terbaca: $error');
    }
  }
}
