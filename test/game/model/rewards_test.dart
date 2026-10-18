import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/rewards.dart';

void main() {
  test('angka hadiah', () {
    expect(dailyBonusCoins, 20);
    expect(adRewardCoins, 20);
    expect(maxAdsPerDay, 5);
  });

  group('dayNumber', () {
    test('hari sejak 1970-01-01 menurut tanggal kalender', () {
      expect(dayNumber(DateTime(1970, 1, 1)), 0);
      expect(dayNumber(DateTime(1970, 1, 2, 23, 59)), 1);
    });

    test('satu tanggal = satu hari, besok +1', () {
      final today = dayNumber(DateTime(2026, 10, 19, 0, 1));
      expect(dayNumber(DateTime(2026, 10, 19, 23, 59)), today);
      expect(dayNumber(DateTime(2026, 10, 20)), today + 1);
      expect(dayNumber(DateTime(2026, 11, 1)), today + 13);
    });
  });

  group('DailyRewards', () {
    const initial = DailyRewards.initial;

    test('awal: bonus siap, lima iklan', () {
      expect(initial.canClaimBonus(100), isTrue);
      expect(initial.adsLeft(100), 5);
    });

    test('bonus sekali sehari, tertahan kalau jam mundur', () {
      final claimed = initial.claimBonus(100);
      expect(claimed.canClaimBonus(100), isFalse);
      expect(claimed.canClaimBonus(101), isTrue);
      expect(claimed.canClaimBonus(99), isFalse);
    });

    test('lima iklan per hari, besok penuh lagi', () {
      var r = initial;
      for (var i = 0; i < 5; i++) {
        expect(r.adsLeft(100), 5 - i);
        r = r.watchedAd(100);
      }
      expect(r.adsLeft(100), 0);
      r = r.watchedAd(100);
      expect(r.adsLeft(100), 0);
      expect(r.adsWatched, 5);
      expect(r.adsLeft(101), 5);
      expect(r.adsLeft(99), 0);
      expect(r.watchedAd(101).adsLeft(101), 4);
    });

    test('bonus dan iklan tidak saling mengubah', () {
      final r = initial.claimBonus(100).watchedAd(100);
      expect(r.canClaimBonus(100), isFalse);
      expect(r.adsLeft(100), 4);
      expect(initial.watchedAd(100).canClaimBonus(100), isTrue);
    });

    test('JSON pulang-pergi', () {
      final r = initial.claimBonus(7).watchedAd(8).watchedAd(8);
      expect(DailyRewards.fromJson(r.toJson()), r);
      expect(initial.toJson(), isEmpty);
      expect(DailyRewards.fromJson(initial.toJson()), initial);
    });

    test('JSON rusak dibuang per field', () {
      expect(
        DailyRewards.fromJson({'bonusDay': 'x', 'adDay': -1, 'ads': 9}),
        initial,
      );
      expect(DailyRewards.fromJson({'ads': 3}), initial);
      final r = DailyRewards.fromJson({'bonusDay': 5, 'adDay': 7, 'ads': 2});
      expect(r.adsLeft(7), 3);
      expect(r.canClaimBonus(5), isFalse);
      expect(DailyRewards.fromJson({'adDay': 7, 'ads': 6}).adsLeft(7), 5);
    });
  });
}
