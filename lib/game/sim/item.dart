import 'cell.dart';
import 'pos.dart';

/// Benda yang ditaruh pemain dari baki.
enum Item {
  fish('fish', Cell.fish),
  water('water', Cell.water),
  box('box', Cell.box);

  const Item(this.key, this.cell);

  /// Kunci di data level (`inventory` dan `solution`).
  final String key;

  /// Isi petak setelah benda ditaruh.
  final Cell cell;

  static Item fromKey(String key) {
    for (final item in values) {
      if (item.key == key) return item;
    }
    throw FormatException('Benda tidak dikenal: "$key"');
  }
}

/// Satu benda yang ditaruh di satu petak.
class Placement {
  const Placement(this.item, this.pos);

  final Item item;
  final Pos pos;

  @override
  bool operator ==(Object other) =>
      other is Placement && other.item == item && other.pos == pos;

  @override
  int get hashCode => Object.hash(item, pos);

  @override
  String toString() => '${item.key}$pos';
}
