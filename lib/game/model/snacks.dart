/// Camilan, urut kartu tab Makanan (`Toko.dc.html`).
enum SnackId { ikanAsin, susu, tuna, biskuit, puding }

/// Camilan: harga Toko, lalu Lapar dan Senang yang ditambahkan saat
/// diberikan lewat kartu kucing.
class Snack {
  const Snack(this.id, this.price, this.hunger, this.joy);

  final SnackId id;
  final int price;
  final int hunger;
  final int joy;
}

/// Harga dari `Toko.dc.html`, Lapar dan Senang dari `Kamar.dc.html`.
const snacks = [
  Snack(SnackId.ikanAsin, 20, 25, 5),
  Snack(SnackId.susu, 15, 15, 5),
  Snack(SnackId.tuna, 40, 40, 5),
  Snack(SnackId.biskuit, 10, 10, 2),
  Snack(SnackId.puding, 90, 60, 15),
];

Snack snackOf(SnackId id) => snacks[id.index];

/// Stok paling banyak per jenis camilan.
const maxSnackStock = 99;

/// Stok camilan yang sudah dibeli.
class Pantry {
  /// Jumlah 0 atau kurang dibuang, lebih dari [maxSnackStock] dijepit.
  Pantry([Map<SnackId, int> stock = const {}])
    : stock = Map.unmodifiable({
        for (final MapEntry(:key, :value) in stock.entries)
          if (value > 0) key: value > maxSnackStock ? maxSnackStock : value,
      });

  static final empty = Pantry();

  final Map<SnackId, int> stock;

  int countOf(SnackId id) => stock[id] ?? 0;

  bool canAdd(SnackId id) => countOf(id) < maxSnackStock;

  /// Satu [id] masuk stok; tidak berubah kalau sudah penuh.
  Pantry add(SnackId id) =>
      canAdd(id) ? Pantry({...stock, id: countOf(id) + 1}) : this;

  /// Satu [id] diambil dari stok; null kalau habis.
  Pantry? take(SnackId id) =>
      countOf(id) > 0 ? Pantry({...stock, id: countOf(id) - 1}) : null;

  Map<String, int> toJson() => {
    for (final s in snacks)
      if (countOf(s.id) > 0) s.id.name: countOf(s.id),
  };

  /// Nama yang tidak dikenal dan jumlah yang bukan bilangan bulat dibuang.
  factory Pantry.fromJson(Map<String, dynamic> json) {
    final names = SnackId.values.asNameMap();
    return Pantry({
      for (final MapEntry(:key, :value) in json.entries)
        if ((names[key], value) case (final SnackId id, final int count))
          id: count,
    });
  }

  @override
  bool operator ==(Object other) =>
      other is Pantry &&
      other.stock.length == stock.length &&
      stock.entries.every((e) => other.stock[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final e in stock.entries) Object.hash(e.key, e.value),
  ]);

  @override
  String toString() => 'Pantry(${toJson()})';
}
