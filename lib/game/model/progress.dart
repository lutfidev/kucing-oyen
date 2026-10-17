/// Progres pemain: bintang terbaik tiap level yang sudah dimenangkan.
///
/// Level 1 selalu terbuka; level n+1 terbuka setelah level n menang (minimal
/// 1 bintang). Aturan buka kunci memakai id level, jadi id level harus
/// berurutan dari 1 seperti di `assets/levels/chapter1-2.json`.
class Progress {
  /// [best]: id level → bintang terbaik 1–3. Level yang belum menang tidak
  /// ada di sini.
  Progress([Map<int, int> best = const {}]) : best = Map.unmodifiable(best);

  const Progress._empty() : best = const {};

  static const empty = Progress._empty();

  /// Bintang paling banyak satu level.
  static const maxStars = 3;

  final Map<int, int> best;

  /// Bintang terbaik level [id]; 0 kalau belum pernah menang.
  int starsOf(int id) => best[id] ?? 0;

  bool isWon(int id) => starsOf(id) > 0;

  bool isUnlocked(int id) => id <= 1 || isWon(id - 1);

  int get totalStars => best.values.fold(0, (sum, stars) => sum + stars);

  int starsIn(Iterable<int> ids) => ids.fold(0, (sum, id) => sum + starsOf(id));

  /// Level yang dimainkan berikutnya: level pertama di [ids] (urut main)
  /// yang belum menang, atau null kalau semuanya sudah menang.
  int? current(Iterable<int> ids) {
    for (final id in ids) {
      if (!isWon(id)) return id;
    }
    return null;
  }

  /// Progres sesudah level [id] selesai dengan [stars] bintang. Hanya
  /// bintang yang lebih baik yang dicatat; kalau tidak ada yang berubah
  /// (gagal, atau tidak lebih baik), hasilnya objek ini sendiri.
  Progress record(int id, int stars) {
    if (stars < 0 || stars > maxStars) {
      throw ArgumentError.value(stars, 'stars', 'harus 0–$maxStars');
    }
    if (stars <= starsOf(id)) return this;
    return Progress({...best, id: stars});
  }

  /// `{"13": 3}`: kunci JSON harus teks.
  Map<String, int> toJson() => {
    for (final e in best.entries) '${e.key}': e.value,
  };

  /// Kebalikan [toJson]. Entri yang tidak sah (kunci bukan angka, bintang
  /// bukan 1–3) dibuang, supaya data rusak tidak membuat aplikasi gagal.
  factory Progress.fromJson(Map<String, dynamic> json) {
    final best = <int, int>{};
    for (final MapEntry(:key, :value) in json.entries) {
      final id = int.tryParse(key);
      if (id != null && value is int && value > 0 && value <= maxStars) {
        best[id] = value;
      }
    }
    return Progress(best);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Progress || other.best.length != best.length) return false;
    for (final MapEntry(:key, :value) in best.entries) {
      if (other.best[key] != value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    best.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'Progress($best)';
}
