import '../sim/item.dart';

/// Jenis petak di `Tile.dc.html` (prop `kind`).
enum TileKind {
  floor,
  wall,
  cupboard,
  shelf,
  fridge,
  bowl,
  table,
  tableGlass,
  tableVase,
  tableBroken;

  /// Tembok dan perabot dinding: tanpa lantai di bawahnya.
  bool get isWallish =>
      this == wall || this == cupboard || this == shelf || this == fridge;

  bool get isTable =>
      this == table ||
      this == tableGlass ||
      this == tableVase ||
      this == tableBroken;
}

/// Benda di atas petak (prop `item`). Akhiran `P` = benda pemain, digambar
/// dengan garis tepi oranye supaya kebaca bisa dipindah.
enum TileItem { none, fish, water, box, fishP, bucketP, boxP }

/// Satu petak 50×50: data saja, digambar oleh `paintTile`.
class Tile {
  const Tile({
    this.kind = TileKind.floor,
    this.item = TileItem.none,
    this.alt = false,
    this.glow = false,
    this.ghost,
  });

  final TileKind kind;
  final TileItem item;

  /// Lantai warna selang-seling.
  final bool alt;

  /// Petak menyala: boleh diisi benda yang sedang diseret, atau ditunjuk
  /// petunjuk.
  final bool glow;

  /// Benda petunjuk yang digambar samar di petak kosong; tidak tampil kalau
  /// petak sudah berisi [item].
  final Item? ghost;

  /// Ukuran petak di koordinat desain.
  static const double size = 50;

  Tile copyWith({
    TileKind? kind,
    TileItem? item,
    bool? alt,
    bool? glow,
    Item? ghost,
  }) => Tile(
    kind: kind ?? this.kind,
    item: item ?? this.item,
    alt: alt ?? this.alt,
    glow: glow ?? this.glow,
    ghost: ghost ?? this.ghost,
  );

  @override
  bool operator ==(Object other) =>
      other is Tile &&
      other.kind == kind &&
      other.item == item &&
      other.alt == alt &&
      other.glow == glow &&
      other.ghost == ghost;

  @override
  int get hashCode => Object.hash(kind, item, alt, glow, ghost);

  @override
  String toString() =>
      'Tile(${kind.name}, ${item.name}'
      '${alt ? ', alt' : ''}${glow ? ', glow' : ''}'
      '${ghost == null ? '' : ', ghost ${ghost!.name}'})';
}
