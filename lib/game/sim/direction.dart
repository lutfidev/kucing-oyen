/// Arah hadap Oyen. Urutan enum mengikuti jarum jam, mulai dari atas.
enum Direction {
  up(0, -1, '^'),
  right(1, 0, '>'),
  down(0, 1, 'v'),
  left(-1, 0, '<');

  const Direction(this.dx, this.dy, this.symbol);

  final int dx;
  final int dy;

  /// Huruf di peta: `^ > v <`.
  final String symbol;

  Direction get clockwise => values[(index + 1) % 4];
  Direction get counterClockwise => values[(index + 3) % 4];
  Direction get opposite => values[(index + 2) % 4];

  /// Urutan cek barang di meja dan pemecah seri jarak ikan:
  /// depan, searah jarum jam, berlawanan jarum jam, belakang.
  List<Direction> get lookOrder => [
    this,
    clockwise,
    counterClockwise,
    opposite,
  ];

  static Direction? fromSymbol(String symbol) {
    for (final d in values) {
      if (d.symbol == symbol) return d;
    }
    return null;
  }
}
