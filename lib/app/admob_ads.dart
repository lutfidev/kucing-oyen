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
    this.rewardGrace = defaultRewardGrace,
    this.showTimeout = defaultShowTimeout,
    DateTime Function()? clock,
    this._onUnavailable,
    this._starting,
  }) : _clock = clock ?? DateTime.now;

  /// Batas tunggu [show] kalau iklan belum siap.
  static const defaultLoadTimeout = Duration(seconds: 10);

  /// Umur maksimum iklan siap. Iklan berhadiah AdMob kedaluwarsa satu jam
  /// sesudah dimuat; yang lebih tua dari ini dibuang dan dimuat ulang.
  static const maxAdAge = Duration(minutes: 55);

  /// Jeda sesudah iklan ditutup untuk hadiah yang datang belakangan
  /// (sebagian SDK dan mediasi memberi hadiah sesudah ditutup).
  static const defaultRewardGrace = Duration(milliseconds: 400);

  /// Batas pengaman satu iklan tampil, kalau SDK tidak pernah memberi tahu
  /// iklan ditutup atau gagal tampil. Cukup panjang untuk pemain yang
  /// membuka toko dari iklan lalu kembali.
  static const defaultShowTimeout = Duration(minutes: 10);

  final String unitId;
  final Duration loadTimeout;
  final Duration rewardGrace;
  final Duration showTimeout;
  final bool Function() _canLoad;
  final RewardedAdLoader _load;
  final DateTime Function() _clock;

  /// Dipanggil saat [show] ditolak karena iklan belum boleh dimuat (mis.
  /// persetujuan atau SDK belum siap), supaya bisa dicoba lagi.
  final VoidCallback? _onUnavailable;

  /// SDK yang sedang dinyalakan (null kalau tidak sedang dinyalakan):
  /// [show] menunggunya dalam batas [loadTimeout] sebelum menyerah.
  final Future<void>? Function()? _starting;

  RewardedAdHandle? _ready;

  /// Waktu [_ready] selesai dimuat.
  DateTime? _readyAt;
  Future<void>? _loading;
  bool _showing = false;

  /// Memuat satu iklan kalau boleh, belum ada yang siap, dan tidak sedang
  /// memuat.
  void preload() {
    _dropExpired();
    if (_canLoad() && _ready == null && _loading == null) {
      unawaited(_startLoad());
    }
  }

  /// Iklan yang selesai dimuat (juga sesudah [show] habis waktu) disimpan
  /// untuk [show] berikutnya.
  Future<void> _startLoad() {
    final loading = _loadOne();
    _loading = loading;
    // Dikosongkan sesudah dipasang, juga kalau pemuat melempar sinkron
    // (muatan itu sudah selesai sebelum baris di atas berjalan).
    unawaited(
      loading.whenComplete(() {
        if (identical(_loading, loading)) _loading = null;
      }),
    );
    return loading;
  }

  Future<void> _loadOne() async {
    RewardedAdHandle? ad;
    try {
      ad = await _load(unitId);
    } on Object {
      ad = null;
    }
    if (ad != null) {
      _ready = ad;
      _readyAt = _clock();
    }
  }

  /// Membuang iklan siap yang sudah lewat [maxAdAge].
  void _dropExpired() {
    final at = _readyAt;
    if (_ready == null || at == null) return;
    if (_clock().difference(at) < maxAdAge) return;
    _ready!.dispose();
    _ready = null;
    _readyAt = null;
  }

  /// True hanya kalau pemain menonton sampai hadiah. False kalau sedang
  /// menampilkan iklan lain, belum boleh memuat, gagal dimuat, habis waktu,
  /// ditutup lebih dulu, atau error. Tidak pernah melempar.
  @override
  Future<bool> show() async {
    if (_showing) return false;
    _showing = true;
    try {
      _dropExpired();
      await _waitForAd().timeout(loadTimeout, onTimeout: () {});
      if (!_canLoad()) {
        _onUnavailable?.call();
        return false;
      }
      final ad = _ready;
      _ready = null;
      _readyAt = null;
      if (ad == null) return false;
      return await _present(ad);
    } on Object {
      return false;
    } finally {
      _showing = false;
    }
  }

  /// Menunggu SDK yang sedang dinyalakan, lalu iklan kalau belum siap.
  Future<void> _waitForAd() async {
    if (!_canLoad()) {
      final starting = _starting?.call();
      if (starting == null) return;
      await starting;
      if (!_canLoad()) return;
    }
    if (_ready == null) await (_loading ?? _startLoad());
  }

  Future<bool> _present(RewardedAdHandle ad) async {
    final done = Completer<bool>();
    var earned = false;
    var closed = false;
    Timer? grace;
    void finish(bool rewarded) {
      grace?.cancel();
      if (!done.isCompleted) done.complete(rewarded);
    }

    try {
      ad.show(
        onReward: () {
          earned = true;
          if (closed) finish(true);
        },
        onClosed: () {
          if (closed) return;
          closed = true;
          if (earned) {
            finish(true);
          } else {
            grace = Timer(rewardGrace, () => finish(false));
          }
        },
      );
      return await done.future.timeout(showTimeout, onTimeout: () => earned);
    } on Object {
      return false;
    } finally {
      grace?.cancel();
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
      onUnavailable: _retry,
      starting: () => _startingSdk,
    );
    hints = unit(AdPlacement.hint);
    coins = unit(AdPlacement.coin);
  }

  final AdConsent consent;
  final Future<void> Function() _startSdk;

  late final AdMobRewardedAds hints;
  late final AdMobRewardedAds coins;

  bool _sdkReady = false;
  bool _gathering = false;

  /// SDK yang sedang dinyalakan; iklan yang diminta saat itu menunggunya.
  Future<void>? _startingSdk;

  /// SDK sudah dinyalakan dan iklan boleh dimuat.
  bool get sdkReady => _sdkReady;

  /// Dipanggil sekali tanpa ditunggu saat aplikasi mulai: minta
  /// persetujuan, lalu nyalakan SDK kalau boleh. Kalau persetujuan baru
  /// boleh belakangan (formulir di Pengaturan), SDK dinyalakan saat itu.
  Future<void> start() async {
    consent.addListener(_onConsent);
    await _gatherAndStart();
  }

  Future<void> _gatherAndStart() async {
    if (_gathering) return;
    _gathering = true;
    try {
      await consent.gather();
    } on Object {
      // Formulir gagal: dicoba lagi saat pemain meminta iklan.
    } finally {
      _gathering = false;
    }
    await _startIfAllowed();
  }

  /// Iklan diminta sebelum SDK siap (mis. pembukaan pertama offline, atau
  /// SDK gagal dinyalakan): minta persetujuan dan nyalakan SDK lagi, supaya
  /// ketukan berikutnya bisa mendapat iklan tanpa membuka ulang aplikasi.
  void _retry() {
    if (!_sdkReady) unawaited(_gatherAndStart());
  }

  void _onConsent() => unawaited(_startIfAllowed());

  Future<void> _startIfAllowed() {
    if (_sdkReady || !consent.canRequestAds) return Future.value();
    final pending = _startingSdk;
    if (pending != null) return pending;
    final starting = _startSdkOnce();
    _startingSdk = starting;
    // Dikosongkan sesudah dipasang, juga kalau SDK melempar sinkron.
    unawaited(
      starting.whenComplete(() {
        if (identical(_startingSdk, starting)) _startingSdk = null;
      }),
    );
    return starting;
  }

  Future<void> _startSdkOnce() async {
    try {
      await _startSdk();
      _sdkReady = true;
      hints.preload();
      coins.preload();
    } on Object {
      // SDK gagal dinyalakan: dicoba lagi saat pemain meminta iklan.
    }
  }
}
