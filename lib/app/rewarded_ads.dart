/// Iklan berhadiah: pemain menonton iklan sampai selesai lalu mendapat
/// hadiah (membuka satu tingkat petunjuk, atau koin). SDK iklan asli
/// dipasang di langkah rilis; sampai itu dipakai [FakeRewardedAds].
abstract interface class RewardedAds {
  /// Menampilkan satu iklan. True kalau ditonton sampai hadiahnya boleh
  /// diberikan; false kalau gagal dimuat atau ditutup lebih dulu.
  Future<bool> show();
}

/// Iklan palsu: langsung selesai tanpa layar iklan.
class FakeRewardedAds implements RewardedAds {
  FakeRewardedAds({this.succeed = true});

  /// Hasil setiap [show]; false untuk menguji iklan yang gagal.
  final bool succeed;

  /// Berapa kali [show] dipanggil.
  int shown = 0;

  @override
  Future<bool> show() async {
    shown++;
    return succeed;
  }
}
