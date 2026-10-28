import 'dart:math' as math;

/// Koin bonus harian (sekali per hari kalender).
const dailyBonusCoins = 20;

/// Koin untuk satu iklan berhadiah yang ditonton sampai selesai.
const adRewardCoins = 20;

/// Iklan berhadiah koin paling banyak per hari.
const maxAdsPerDay = 10;

/// Nomor hari tanggal kalender [time] sejak 1970-01-01. Jamnya diabaikan,
/// jadi pergantian jam musim panas tidak menggeser hari.
int dayNumber(DateTime time) =>
    DateTime.utc(time.year, time.month, time.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// Hari terakhir bonus harian diambil, dan iklan koin yang ditonton pada
/// [adDay]. Hari = [dayNumber]. Kalau jam perangkat mundur (hari ini sebelum
/// hari tersimpan), bonus dan iklan tertahan sampai tanggalnya terlewati.
class DailyRewards {
  const DailyRewards({this.bonusDay, this.adDay, this.adsWatched = 0});

  static const initial = DailyRewards();

  /// Null = bonus belum pernah diambil.
  final int? bonusDay;

  /// Hari iklan koin terakhir ditonton; null = belum pernah.
  final int? adDay;

  /// Iklan koin yang ditonton pada [adDay] (0–[maxAdsPerDay]).
  final int adsWatched;

  bool canClaimBonus(int today) => bonusDay == null || today > bonusDay!;

  int adsLeft(int today) {
    final day = adDay;
    if (day == null || today > day) return maxAdsPerDay;
    if (today < day) return 0;
    return math.max(0, maxAdsPerDay - adsWatched);
  }

  DailyRewards claimBonus(int today) =>
      DailyRewards(bonusDay: today, adDay: adDay, adsWatched: adsWatched);

  DailyRewards watchedAd(int today) => DailyRewards(
    bonusDay: bonusDay,
    adDay: today,
    adsWatched: adDay == today ? math.min(maxAdsPerDay, adsWatched + 1) : 1,
  );

  Map<String, Object?> toJson() => {
    'bonusDay': ?bonusDay,
    'adDay': ?adDay,
    if (adDay != null) 'ads': adsWatched,
  };

  /// Hari yang bukan angka atau negatif dibuang. Jumlah iklan yang rusak
  /// atau di luar 0–[maxAdsPerDay] pada hari yang sah dianggap jatah habis,
  /// supaya simpanan rusak tidak memberi iklan koin tambahan.
  factory DailyRewards.fromJson(Map<String, dynamic> json) {
    int? day(Object? value) => value is int && value >= 0 ? value : null;
    final adDay = day(json['adDay']);
    final ads = json['ads'];
    return DailyRewards(
      bonusDay: day(json['bonusDay']),
      adDay: adDay,
      adsWatched: adDay == null
          ? 0
          : ads is int && ads >= 0 && ads <= maxAdsPerDay
          ? ads
          : maxAdsPerDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DailyRewards &&
      other.bonusDay == bonusDay &&
      other.adDay == adDay &&
      other.adsWatched == adsWatched;

  @override
  int get hashCode => Object.hash(bonusDay, adDay, adsWatched);
}
