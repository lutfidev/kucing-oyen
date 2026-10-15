import 'direction.dart';

/// Koordinat petak (kolom, baris), dihitung dari 0 di pojok kiri atas.
class Pos {
  const Pos(this.x, this.y);

  final int x;
  final int y;

  Pos operator +(Direction d) => Pos(x + d.dx, y + d.dy);

  /// Petak sejauh [distance] ke arah [d].
  Pos shift(Direction d, int distance) =>
      Pos(x + d.dx * distance, y + d.dy * distance);

  @override
  bool operator ==(Object other) =>
      other is Pos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}
