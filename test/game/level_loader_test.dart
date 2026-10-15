import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('memuat 20 level dari aset', () async {
    final levels = await loadLevels();
    expect(levels, hasLength(20));

    final level13 = levels[12];
    expect(level13.name, 'Vas Ibu');
    expect(level13.chapter, 2);
    expect(level13.board.start, const Pos(4, 3));
    expect(level13.board.startDir, Direction.left);
    expect(level13.board.cellAt(const Pos(2, 3)), Cell.tableVase);
    expect(level13.inventory, {Item.fish: 1, Item.water: 1});
  });

  test('solusi muat di baki dan jumlahnya sama dengan bintang 3', () async {
    for (final level in await loadLevels()) {
      expect(level.solution, hasLength(level.starItems), reason: '$level');
      for (final item in Item.values) {
        final used = level.solution.where((p) => p.item == item).length;
        expect(
          used,
          lessThanOrEqualTo(level.inventory[item] ?? 0),
          reason: '$level: ${item.key}',
        );
      }
      for (final p in level.solution) {
        expect(level.board.canPlace(p.pos), isTrue, reason: '$level: $p');
      }
    }
  });
}
