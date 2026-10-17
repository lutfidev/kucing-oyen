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

/// Isi kartu sheet Petunjuk untuk level tanpa benda (level 1 dan 2).
const noItemsHintText = 'Level ini nggak butuh benda. Langsung bangunkan Oyen!';

/// Nama benda di tengah kalimat petunjuk.
String _name(Item item) => switch (item) {
  Item.fish => 'ikan asin',
  Item.water => 'ember air',
  Item.box => 'kardus',
};

/// Akibat benda pada Oyen, untuk teks tingkat 2. Kalimat ember persis
/// desain 10; ikan dan kardus dibuat senada.
String hintEffect(Item item) => switch (item) {
  Item.water => 'Oyen bakal kaget dan balik badan.',
  Item.fish => 'Oyen bakal ngejar dan makan ikannya.',
  Item.box => 'Oyen bakal masuk dan duduk di situ.',
};

/// Teks kartu tingkat [tier] (1–3) yang sudah dibuka.
String hintText(Level level, int tier) {
  final solution = level.solution;
  switch (tier) {
    case 1:
      return 'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.';
    case 2:
      final item = solution.first.item;
      return 'Taruh ${_name(item)} di petak yang menyala. ${hintEffect(item)}';
    case 3:
      // Benda sejenis dikelompokkan, urut kemunculan pertama di solusi.
      final counts = <Item, int>{};
      for (final p in solution) {
        counts[p.item] = (counts[p.item] ?? 0) + 1;
      }
      final parts = [
        for (final MapEntry(key: item, value: n) in counts.entries)
          switch (n) {
            1 => _name(item),
            2 => 'dua ${_name(item)}',
            3 => 'tiga ${_name(item)}',
            _ => '$n ${_name(item)}',
          },
      ];
      final list = parts.length == 1
          ? parts.first
          : parts.length == 2
          ? '${parts[0]} dan ${parts[1]}'
          : '${parts.sublist(0, parts.length - 1).join(', ')}, '
                'dan ${parts.last}';
      final hasVase = level.board.copyCells().contains(Cell.tableVase);
      return '${list[0].toUpperCase()}${list.substring(1)} di petak yang '
          'menyala. ${hasVase ? 'Vas aman, 3 bintang.' : '3 bintang!'}';
    default:
      throw ArgumentError.value(tier, 'tier', 'harus 1–$maxHintTier');
  }
}
