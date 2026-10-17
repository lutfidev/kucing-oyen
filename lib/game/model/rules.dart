import 'progress.dart';

/// Kartu aturan Oyen, urut seperti sheet Aturan (desain 05) dan urutan cek
/// per langkah. Sampai mangkuk dan sedang duduk di kardus tidak punya kartu.
enum OyenRule {
  /// Jatuhkan barang di meja sebelah.
  knock(12),

  /// Kejar ikan terdekat yang terlihat.
  fish(3),

  /// Air: putar balik.
  water(6),

  /// Mentok tembok atau meja: berputar searah jarum jam.
  wall(2),

  /// Kardus: masuk dan duduk.
  box(14);

  const OyenRule(this.level);

  /// Level yang memperkenalkan aturan ini (kolom "Hal baru" GDD).
  final int level;

  /// Nomor kartu, mulai 1.
  int get number => index + 1;

  /// Kartu terbuka kalau pemain sudah membuka level yang memperkenalkannya,
  /// atau sedang memainkan level itu atau sesudahnya (rute level tidak
  /// dijaga kunci).
  bool isLearned(Progress progress, int levelId) =>
      levelId >= level || progress.isUnlocked(level);
}

/// Kartu yang terbuka saat memainkan level [levelId].
Set<OyenRule> learnedRules(Progress progress, int levelId) => {
  for (final rule in OyenRule.values)
    if (rule.isLearned(progress, levelId)) rule,
};
