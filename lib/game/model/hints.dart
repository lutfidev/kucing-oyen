import '../sim/sim.dart';

/// Koin untuk tiap bintang yang pertama kali didapat di sebuah level.
const coinsPerStar = 10;

/// Koin yang didapat saat bintang terbaik sebuah level naik dari [before]
/// ke [after]; 0 kalau tidak naik, jadi mengulang level tidak menambah koin.
int coinsForStars(int before, int after) =>
    after > before ? (after - before) * coinsPerStar : 0;

/// Tingkat petunjuk paling tinggi per level: (1) sorot petak benda pertama,
/// (2) jenis benda untuk petak itu, (3) solusi bintang 3 lengkap.
const maxHintTier = 3;

/// Harga tingkat [tier] (1–3) dalam koin, persis desain 10.
int hintCost(int tier) => switch (tier) {
  1 => 20,
  2 => 40,
  3 => 80,
  _ => throw ArgumentError.value(tier, 'tier', 'harus 1–$maxHintTier'),
};

/// Petak yang ditunjukkan petunjuk sampai tingkat [tier] (0–3), dengan
/// bendanya kalau jenisnya sudah dibuka (null = jenis belum dibuka).
/// Sumbernya `level.solution`; benda pertama = `solution[0]`.
Map<Pos, Item?> hintMarks(Level level, int tier) {
  final solution = level.solution;
  if (tier <= 0 || solution.isEmpty) return const {};
  final first = solution.first;
  return switch (tier) {
    1 => {first.pos: null},
    2 => {first.pos: first.item},
    _ => {for (final p in solution) p.pos: p.item},
  };
}

/// Isi kartu tingkat petunjuk yang sudah dibuka, sebagai data; kalimatnya
/// disusun per bahasa di lapisan teks (`hintTextFor`).
class HintText {
  const HintText(
    this.tier, {
    this.item,
    this.items = const [],
    this.hasVase = false,
  });

  /// Tingkat 1–3.
  final int tier;

  /// Benda pertama solusi (tingkat 2).
  final Item? item;

  /// Benda solusi dan jumlahnya, sejenis dikelompokkan, urut kemunculan
  /// pertama (tingkat 3).
  final List<(Item, int)> items;

  /// Peta punya vas (tingkat 3: "Vas aman, 3 bintang.").
  final bool hasVase;

  @override
  bool operator ==(Object other) =>
      other is HintText &&
      other.tier == tier &&
      other.item == item &&
      other.hasVase == hasVase &&
      other.items.length == items.length &&
      [for (var i = 0; i < items.length; i++) other.items[i] == items[i]]
          .every((same) => same);

  @override
  int get hashCode => Object.hash(tier, item, hasVase, Object.hashAll(items));

  @override
  String toString() => 'HintText($tier, $item, $items, vase: $hasVase)';
}

/// Isi kartu tingkat [tier] (1–3) yang sudah dibuka.
HintText hintText(Level level, int tier) {
  final solution = level.solution;
  switch (tier) {
    case 1:
      return const HintText(1);
    case 2:
      return HintText(2, item: solution.first.item);
    case 3:
      final counts = <Item, int>{};
      for (final p in solution) {
        counts[p.item] = (counts[p.item] ?? 0) + 1;
      }
      return HintText(
        3,
        items: [
          for (final MapEntry(:key, :value) in counts.entries) (key, value),
        ],
        hasVase: level.board.copyCells().contains(Cell.tableVase),
      );
    default:
      throw ArgumentError.value(tier, 'tier', 'harus 1–$maxHintTier');
  }
}
