import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ad_consent.dart';
import 'ad_ids.dart';
import 'rewarded_ads.dart';

/// Satu iklan berhadiah yang sudah dimuat (celah di depan SDK, supaya
/// alurnya bisa diuji tanpa SDK).
abstract interface class RewardedAdHandle {
  /// Menampilkan iklan. [onReward] saat hadiah boleh diberikan, [onClosed]
  /// saat iklan ditutup atau gagal tampil.
  void show({required VoidCallback onReward, required VoidCallback onClosed});

  void dispose();
}

/// Memuat satu iklan untuk unit [unitId]; null kalau gagal dimuat.
typedef RewardedAdLoader = Future<RewardedAdHandle?> Function(String unitId);

/// Iklan berhadiah AdMob untuk satu unit. Satu iklan dimuat lebih dulu
/// ([preload]) supaya pemain tidak menunggu; iklan yang gagal dimuat tidak
/// dicoba ulang sampai [show] berikutnya.
class AdMobRewardedAds implements RewardedAds {
  AdMobRewardedAds({
    required this.unitId,
    required this._canLoad,
    required this._load,
    this.loadTimeout = defaultLoadTimeout,
  });

  /// Batas tunggu [show] kalau iklan belum siap.
  static const defaultLoadTimeout = Duration(seconds: 10);

  final String unitId;
  final Duration loadTimeout;
  final bool Function() _canLoad;
  final RewardedAdLoader _load;

  RewardedAdHandle? _ready;
  Future<void>? _loading;
  bool _showing = false;

  /// Memuat satu iklan kalau boleh, belum ada yang siap, dan tidak sedang
  /// memuat.
  void preload() {
    if (_canLoad() && _ready == null && _loading == null) {
      unawaited(_startLoad());
    }
  }

  /// Iklan yang selesai dimuat (juga sesudah [show] habis waktu) disimpan
  /// untuk [show] berikutnya.
  Future<void> _startLoad() => _loading = () async {
    RewardedAdHandle? ad;
    try {
      ad = await _load(unitId);
    } on Object {
      ad = null;
    }
    _loading = null;
    if (ad != null) _ready = ad;
  }();

  /// True hanya kalau pemain menonton sampai hadiah. False kalau sedang
  /// menampilkan iklan lain, belum boleh memuat, gagal dimuat, habis waktu,
  /// ditutup lebih dulu, atau error. Tidak pernah melempar.
  @override
  Future<bool> show() async {
    if (_showing || !_canLoad()) return false;
    _showing = true;
    try {
      if (_ready == null) {
        await (_loading ?? _startLoad()).timeout(loadTimeout, onTimeout: () {});
      }
      final ad = _ready;
      _ready = null;
      if (ad == null) return false;
      return await _present(ad);
    } on Object {
      return false;
    } finally {
      _showing = false;
    }
  }

  Future<bool> _present(RewardedAdHandle ad) async {
    final closed = Completer<bool>();
    var earned = false;
    try {
      ad.show(
        onReward: () => earned = true,
        onClosed: () {
          if (!closed.isCompleted) closed.complete(earned);
        },
      );
      return await closed.future;
    } on Object {
      return false;
    } finally {
      ad.dispose();
      preload();
    }
  }
}

/// Persetujuan, SDK, dan dua unit iklan berhadiah (petunjuk dan koin). SDK
/// baru dinyalakan setelah persetujuan membolehkan iklan.
class GameAds {
  GameAds({
    required this.consent,
    required this._startSdk,
    required RewardedAdLoader load,
    bool release = kReleaseMode,
  }) {
    AdMobRewardedAds unit(AdPlacement placement) => AdMobRewardedAds(
      unitId: rewardedUnitFor(placement, release: release),
      canLoad: () => _sdkReady,
      load: load,
    );
    hints = unit(AdPlacement.hint);
    coins = unit(AdPlacement.coin);
  }

  final AdConsent consent;
  final Future<void> Function() _startSdk;

  late final AdMobRewardedAds hints;
  late final AdMobRewardedAds coins;

  bool _sdkReady = false;
  bool _starting = false;

  /// SDK sudah dinyalakan dan iklan boleh dimuat.
  bool get sdkReady => _sdkReady;

  /// Dipanggil sekali tanpa ditunggu saat aplikasi mulai: minta
  /// persetujuan, lalu nyalakan SDK kalau boleh. Kalau persetujuan baru
  /// boleh belakangan (formulir di Pengaturan), SDK dinyalakan saat itu.
  Future<void> start() async {
    consent.addListener(_onConsent);
    try {
      await consent.gather();
    } on Object {
      // Formulir gagal: iklan menunggu persetujuan berikutnya.
    }
    await _startIfAllowed();
  }

  void _onConsent() => unawaited(_startIfAllowed());

  Future<void> _startIfAllowed() async {
    if (_sdkReady || _starting || !consent.canRequestAds) return;
    _starting = true;
    try {
      await _startSdk();
      _sdkReady = true;
      hints.preload();
      coins.preload();
    } on Object {
      // SDK gagal dinyalakan: iklan gagal sampai aplikasi dibuka lagi.
    } finally {
      _starting = false;
    }
  }
}
