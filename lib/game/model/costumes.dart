import '../render/oyen.dart';

/// Kostum di Lemari Kostum (desain 12): id gambar Oyen, nama, dan harga
/// dalam koin.
class Costume {
  const Costume(this.id, this.name, this.price);

  final OyenCostume id;
  final String name;
  final int price;
}

/// Semua pilihan kostum, urutan dan harga persis desain 12.
const costumes = [
  Costume(OyenCostume.none, 'Polos', 0),
  Costume(OyenCostume.peci, 'Peci', 60),
  Costume(OyenCostume.sarung, 'Sarung', 90),
  Costume(OyenCostume.koki, 'Topi Koki', 150),
  Costume(OyenCostume.kacamata, 'Kacamata', 45),
];

Costume costumeOf(OyenCostume id) => costumes.firstWhere((c) => c.id == id);

/// Tombol aksi Lemari Kostum untuk kostum yang dipilih: "Sedang dipakai",
/// "Pakai", "Beli · N koin", atau "Koin kurang · N".
enum CostumeAction { wearing, wear, buy, notEnoughCoins }

/// Kostum yang dimiliki pemain dan yang sedang dipakai Oyen. Polos selalu
/// dimiliki; kostum dipakai yang tidak dimiliki kembali ke Polos.
class Wardrobe {
  Wardrobe({
    Iterable<OyenCostume> owned = const [],
    OyenCostume wearing = OyenCostume.none,
  }) : owned = Set.unmodifiable({OyenCostume.none, ...owned}),
       wearing = owned.contains(wearing) ? wearing : OyenCostume.none;

  /// Awal permainan: hanya Polos.
  static final initial = Wardrobe();

  final Set<OyenCostume> owned;
  final OyenCostume wearing;

  bool owns(OyenCostume id) => owned.contains(id);

  /// Belum dimiliki dan [coins] cukup untuk harganya.
  bool canBuy(OyenCostume id, int coins) =>
      !owns(id) && coins >= costumeOf(id).price;

  /// Kostum [id] menjadi milik pemain dan langsung dipakai (desain 12).
  /// Koin dipotong pemanggil.
  Wardrobe buy(OyenCostume id) =>
      owns(id) ? this : Wardrobe(owned: {...owned, id}, wearing: id);

  /// Memakai [id]; tidak berubah kalau belum dimiliki.
  Wardrobe wear(OyenCostume id) =>
      owns(id) && id != wearing ? Wardrobe(owned: owned, wearing: id) : this;

  CostumeAction actionFor(OyenCostume id, int coins) {
    if (id == wearing) return CostumeAction.wearing;
    if (owns(id)) return CostumeAction.wear;
    return canBuy(id, coins) ? CostumeAction.buy : CostumeAction.notEnoughCoins;
  }

  @override
  bool operator ==(Object other) =>
      other is Wardrobe &&
      other.wearing == wearing &&
      other.owned.length == owned.length &&
      other.owned.containsAll(owned);

  @override
  int get hashCode => Object.hash(wearing, Object.hashAllUnordered(owned));

  @override
  String toString() =>
      'Wardrobe(${[for (final c in owned) c.name].join(', ')}; '
      'dipakai ${wearing.name})';
}
