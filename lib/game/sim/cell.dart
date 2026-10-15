/// Isi satu petak peta.
enum Cell {
  wall('#'),
  floor('.'),
  bowl('T'),
  table('M'),
  tableGlass('G'),
  tableVase('V'),
  fish('F'),
  water('A'),
  box('K');

  const Cell(this.symbol);

  /// Huruf di peta level.
  final String symbol;

  bool get isTable => this == table || this == tableGlass || this == tableVase;

  /// Meja yang ada barangnya (gelas atau vas) dan bisa dijatuhkan Oyen.
  bool get hasKnockable => this == tableGlass || this == tableVase;

  /// Menghalangi pandangan Oyen ke ikan. Air tidak menghalangi.
  bool get blocksSight => this == wall || isTable || this == box;

  /// Benda (ikan, air, kardus) yang ikut dicatat di keadaan untuk deteksi
  /// mondar-mandir.
  bool get isItem => this == fish || this == water || this == box;

  static Cell? fromSymbol(String symbol) {
    for (final c in values) {
      if (c.symbol == symbol) return c;
    }
    return null;
  }
}
