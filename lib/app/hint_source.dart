import 'package:flutter/foundation.dart';

/// Cara membuka satu tingkat petunjuk.
enum HintPay { ad, coins }

/// Hasil membuka satu tingkat petunjuk.
enum HintUnlock {
  opened,

  /// Saldo kurang dari harga tingkat itu.
  notEnoughCoins,

  /// Iklan gagal dimuat atau tidak ditonton sampai selesai.
  adFailed,

  /// Bukan tingkat berikutnya (belum urut, sudah terbuka, di luar 1–3, atau
  /// sedang dibuka ketukan lain).
  notReady,
}

/// Saldo koin dan petunjuk yang sudah terbuka, untuk layar level dan sheet
/// Petunjuk. Pendengar diberi tahu saat saldo atau tingkat berubah.
abstract interface class HintSource implements Listenable {
  int get coins;

  /// Tingkat petunjuk tertinggi yang terbuka di level [levelId] (0–3).
  int hintTier(int levelId);

  /// Membuka tingkat [tier] level [levelId] dengan iklan atau koin.
  Future<HintUnlock> unlockHint(int levelId, int tier, HintPay pay);
}
