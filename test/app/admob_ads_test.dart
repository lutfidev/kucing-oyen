import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/ad_consent.dart';
import 'package:kucing_oren/app/ad_ids.dart';
import 'package:kucing_oren/app/admob_ads.dart';

/// Iklan palsu: mencatat tampil dan dispose; test memicu callback-nya.
class _FakeHandle implements RewardedAdHandle {
  _FakeHandle({this.throwOnShow = false});

  final bool throwOnShow;
  int shown = 0;
  bool disposed = false;
  VoidCallback? onReward;
  VoidCallback? onClosed;

  @override
  void show({required VoidCallback onReward, required VoidCallback onClosed}) {
    shown++;
    if (throwOnShow) throw StateError('gagal tampil');
    this.onReward = onReward;
    this.onClosed = onClosed;
  }

  @override
  void dispose() => disposed = true;

  /// Penonton menonton sampai hadiah lalu menutup iklan.
  void watchToEnd() {
    onReward!();
    onClosed!();
  }
}

/// Pemuat palsu: setiap panggilan menunggu [Completer] yang diselesaikan
/// test.
class _FakeLoader {
  final units = <String>[];
  final pending = <Completer<RewardedAdHandle?>>[];

  Future<RewardedAdHandle?> call(String unitId) {
    units.add(unitId);
    final c = Completer<RewardedAdHandle?>();
    pending.add(c);
    return c.future;
  }

  int get calls => units.length;

  /// Menyelesaikan muatan terakhir dengan [ad] (null = gagal dimuat).
  Future<void> finish(RewardedAdHandle? ad) async {
    pending.last.complete(ad);
    await pumpEventQueue();
  }
}

AdMobRewardedAds _ads(
  _FakeLoader loader, {
  bool Function()? canLoad,
  Duration loadTimeout = AdMobRewardedAds.defaultLoadTimeout,
  Duration rewardGrace = AdMobRewardedAds.defaultRewardGrace,
  Duration showTimeout = AdMobRewardedAds.defaultShowTimeout,
}) => AdMobRewardedAds(
  unitId: 'unit',
  canLoad: canLoad ?? () => true,
  load: loader.call,
  loadTimeout: loadTimeout,
  rewardGrace: rewardGrace,
  showTimeout: showTimeout,
);

/// Persetujuan yang `gather`-nya error.
class _BrokenConsent extends FakeAdConsent {
  _BrokenConsent() : super(canRequestAds: false);

  @override
  Future<void> gather() async => throw StateError('UMP rusak');
}

void main() {
  group('AdMobRewardedAds', () {
    test(
      'show tanpa iklan siap memuat lalu true kalau hadiah lalu ditutup',
      () async {
        final loader = _FakeLoader();
        final ads = _ads(loader);
        final result = ads.show();
        await pumpEventQueue();
        expect(loader.units, ['unit']);
        final ad = _FakeHandle();
        await loader.finish(ad);
        expect(ad.shown, 1);
        ad.watchToEnd();
        expect(await result, isTrue);
      },
    );

    test('ditutup tanpa hadiah = false', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader);
      final result = ads.show();
      final ad = _FakeHandle();
      await loader.finish(ad);
      ad.onClosed!();
      expect(await result, isFalse);
    });

    test('hadiah sesudah ditutup dalam jeda = true', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader);
      final result = ads.show();
      final ad = _FakeHandle();
      await loader.finish(ad);
      // Sebagian SDK (dan mediasi) memberi hadiah sesudah iklan ditutup.
      ad.onClosed!();
      await pumpEventQueue();
      ad.onReward!();
      expect(await result, isTrue);
      expect(ad.disposed, isTrue);
    });

    test('hadiah sesudah jeda lewat = false', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader, rewardGrace: const Duration(milliseconds: 10));
      var done = false;
      final result = ads.show().whenComplete(() => done = true);
      final ad = _FakeHandle();
      await loader.finish(ad);
      ad.onClosed!();
      await pumpEventQueue();
      // Menunggu jeda dulu, tidak langsung selesai.
      expect(done, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      ad.onReward!();
      expect(await result, isFalse);
    });

    test('tidak pernah ditutup: berhenti di batas pengaman', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader, showTimeout: const Duration(milliseconds: 20));
      final result = ads.show();
      final ad = _FakeHandle();
      await loader.finish(ad);
      expect(await result, isFalse);
      expect(ad.disposed, isTrue);
      // Tidak tertahan: show berikutnya memakai iklan yang sudah dimuat lagi.
      final next = _FakeHandle();
      await loader.finish(next);
      final again = ads.show();
      await pumpEventQueue();
      expect(next.shown, 1);
      next.watchToEnd();
      expect(await again, isTrue);
    });

    test('hadiah tanpa ditutup: batas pengaman tetap memberi hadiah', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader, showTimeout: const Duration(milliseconds: 20));
      final result = ads.show();
      final ad = _FakeHandle();
      await loader.finish(ad);
      ad.onReward!();
      expect(await result, isTrue);
    });

    test('gagal tampil (hanya onClosed) = false', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader)..preload();
      final ad = _FakeHandle();
      await loader.finish(ad);
      final result = ads.show();
      await pumpEventQueue();
      ad.onClosed!();
      expect(await result, isFalse);
    });

    test(
      'sesudah ditutup iklan di-dispose dan iklan berikutnya dimuat',
      () async {
        final loader = _FakeLoader();
        final ads = _ads(loader);
        final result = ads.show();
        final ad = _FakeHandle();
        await loader.finish(ad);
        ad.watchToEnd();
        await result;
        await pumpEventQueue();
        expect(ad.disposed, isTrue);
        expect(loader.calls, 2);

        // Iklan kedua sudah siap: show berikutnya tidak memuat lagi.
        final next = _FakeHandle();
        await loader.finish(next);
        final again = ads.show();
        await pumpEventQueue();
        expect(next.shown, 1);
        expect(loader.calls, 2);
        next.watchToEnd();
        expect(await again, isTrue);
      },
    );

    test('gagal dimuat = false, show berikutnya memuat lagi', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader);
      final first = ads.show();
      await loader.finish(null);
      expect(await first, isFalse);
      // Tidak dicoba ulang otomatis.
      expect(loader.calls, 1);
      unawaited(ads.show());
      await pumpEventQueue();
      expect(loader.calls, 2);
    });

    test('pemuat melempar = false', () async {
      final ads = AdMobRewardedAds(
        unitId: 'unit',
        canLoad: () => true,
        load: (_) async => throw StateError('SDK'),
      );
      expect(await ads.show(), isFalse);
    });

    test('iklan melempar saat tampil = false dan di-dispose', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader);
      final result = ads.show();
      final ad = _FakeHandle(throwOnShow: true);
      await loader.finish(ad);
      expect(await result, isFalse);
      expect(ad.disposed, isTrue);
    });

    test(
      'waktu habis = false; iklan yang terlambat dipakai show berikutnya',
      () async {
        final loader = _FakeLoader();
        final ads = _ads(loader, loadTimeout: const Duration(milliseconds: 10));
        expect(await ads.show(), isFalse);
        final late = _FakeHandle();
        await loader.finish(late);
        // Tidak tiba-tiba tampil di tengah permainan.
        expect(late.shown, 0);
        final again = ads.show();
        await pumpEventQueue();
        expect(late.shown, 1);
        expect(loader.calls, 1);
        late.watchToEnd();
        expect(await again, isTrue);
      },
    );

    test('show kedua selagi yang pertama berjalan = false', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader);
      final first = ads.show();
      await pumpEventQueue();
      expect(await ads.show(), isFalse);
      expect(loader.calls, 1);
      final ad = _FakeHandle();
      await loader.finish(ad);
      ad.watchToEnd();
      expect(await first, isTrue);
    });

    test(
      'iklan siap yang sudah kedaluwarsa dibuang dan dimuat ulang',
      () async {
        var now = DateTime(2026, 10, 20, 9);
        final loader = _FakeLoader();
        final ads = AdMobRewardedAds(
          unitId: 'unit',
          canLoad: () => true,
          load: loader.call,
          clock: () => now,
        )..preload();
        final old = _FakeHandle();
        await loader.finish(old);
        // Pemain kembali esok hari: iklan lama sudah kedaluwarsa di AdMob.
        now = now.add(AdMobRewardedAds.maxAdAge + const Duration(minutes: 1));
        final result = ads.show();
        await pumpEventQueue();
        expect(old.disposed, isTrue);
        expect(old.shown, 0);
        expect(loader.calls, 2);
        final fresh = _FakeHandle();
        await loader.finish(fresh);
        fresh.watchToEnd();
        expect(await result, isTrue);
      },
    );

    test('iklan siap yang masih baru dipakai tanpa memuat lagi', () async {
      var now = DateTime(2026, 10, 20, 9);
      final loader = _FakeLoader();
      final ads = AdMobRewardedAds(
        unitId: 'unit',
        canLoad: () => true,
        load: loader.call,
        clock: () => now,
      )..preload();
      final ad = _FakeHandle();
      await loader.finish(ad);
      now = now.add(AdMobRewardedAds.maxAdAge - const Duration(minutes: 1));
      final result = ads.show();
      await pumpEventQueue();
      expect(ad.shown, 1);
      expect(loader.calls, 1);
      ad.watchToEnd();
      expect(await result, isTrue);
    });

    test('canLoad false: show false dan preload tidak memuat', () async {
      final loader = _FakeLoader();
      final ads = _ads(loader, canLoad: () => false)..preload();
      expect(await ads.show(), isFalse);
      expect(loader.calls, 0);
    });

    test('preload dua kali hanya memuat sekali', () async {
      final loader = _FakeLoader();
      _ads(loader)
        ..preload()
        ..preload();
      expect(loader.calls, 1);
    });
  });

  group('GameAds', () {
    test(
      'persetujuan boleh: SDK dinyalakan sekali, kedua unit dimuat',
      () async {
        final loader = _FakeLoader();
        var started = 0;
        final consent = FakeAdConsent();
        final ads = GameAds(
          consent: consent,
          startSdk: () async => started++,
          load: loader.call,
          release: false,
        );
        await ads.start();
        expect(consent.gathered, 1);
        expect(started, 1);
        expect(ads.sdkReady, isTrue);
        expect(loader.units, [testRewardedUnit, testRewardedUnit]);
      },
    );

    test('persetujuan belum boleh: SDK mati, iklan langsung false', () async {
      final loader = _FakeLoader();
      var started = 0;
      final ads = GameAds(
        consent: FakeAdConsent(canRequestAds: false),
        startSdk: () async => started++,
        load: loader.call,
      );
      await ads.start();
      expect(started, 0);
      expect(await ads.hints.show(), isFalse);
      expect(await ads.coins.show(), isFalse);
      expect(loader.calls, 0);
    });

    test('gather error: start selesai tanpa error', () async {
      final ads = GameAds(
        consent: _BrokenConsent(),
        startSdk: () async {},
        load: _FakeLoader().call,
      );
      await expectLater(ads.start(), completes);
      expect(ads.sdkReady, isFalse);
    });

    test(
      'persetujuan berubah jadi boleh: SDK dinyalakan tepat sekali',
      () async {
        var started = 0;
        final consent = FakeAdConsent(canRequestAds: false);
        final ads = GameAds(
          consent: consent,
          startSdk: () async => started++,
          load: _FakeLoader().call,
        );
        await ads.start();
        expect(started, 0);
        consent.canRequestAds = true;
        consent.canRequestAds = true;
        await pumpEventQueue();
        expect(started, 1);
        expect(ads.sdkReady, isTrue);
      },
    );

    test('SDK gagal dinyalakan: iklan false', () async {
      final ads = GameAds(
        consent: FakeAdConsent(),
        startSdk: () async => throw StateError('SDK'),
        load: _FakeLoader().call,
      );
      await ads.start();
      expect(ads.sdkReady, isFalse);
      expect(await ads.hints.show(), isFalse);
    });

    test(
      'pertama kali offline: ketukan iklan mencoba persetujuan lagi',
      () async {
        var started = 0;
        final consent = _OfflineFirstConsent();
        final ads = GameAds(
          consent: consent,
          startSdk: () async => started++,
          load: _FakeLoader().call,
        );
        await ads.start();
        expect(ads.sdkReady, isFalse);
        // Pemain kembali online lalu mengetuk iklan: ketukan ini gagal, tapi
        // persetujuan diminta lagi dan SDK menyala untuk ketukan berikutnya.
        expect(await ads.coins.show(), isFalse);
        await pumpEventQueue();
        expect(consent.gathered, 2);
        expect(started, 1);
        expect(ads.sdkReady, isTrue);
      },
    );

    test('coba ulang tidak bertumpuk saat persetujuan masih diminta', () async {
      final consent = _SlowConsent();
      final ads = GameAds(
        consent: consent,
        startSdk: () async {},
        load: _FakeLoader().call,
      );
      unawaited(ads.start());
      await pumpEventQueue();
      expect(await ads.hints.show(), isFalse);
      expect(await ads.coins.show(), isFalse);
      expect(consent.gathered, 1);
      consent.done.complete();
      await pumpEventQueue();
      expect(await ads.hints.show(), isFalse);
      await pumpEventQueue();
      expect(consent.gathered, 2);
    });

    test('release memakai ID tempelan per tempat', () async {
      final loader = _FakeLoader();
      await GameAds(
        consent: FakeAdConsent(),
        startSdk: () async {},
        load: loader.call,
        release: true,
      ).start();
      expect(loader.units, [hintRewardedUnit, coinRewardedUnit]);
    });
  });
}

/// Persetujuan yang gagal diperbarui saat pertama (offline), lalu berhasil.
class _OfflineFirstConsent extends FakeAdConsent {
  _OfflineFirstConsent() : super(canRequestAds: false);

  @override
  Future<void> gather() async {
    gathered++;
    if (gathered >= 2) canRequestAds = true;
  }
}

/// Persetujuan yang `gather` pertamanya menunggu [done].
class _SlowConsent extends FakeAdConsent {
  _SlowConsent() : super(canRequestAds: false);

  final done = Completer<void>();

  @override
  Future<void> gather() async {
    gathered++;
    if (gathered == 1) await done.future;
  }
}
