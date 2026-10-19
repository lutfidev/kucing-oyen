import '../game/model/hints.dart';
import '../game/sim/sim.dart';
import 'app_localizations.dart';

export '../game/model/hints.dart' show HintText;

/// Kalimat kartu petunjuk yang sudah dibuka (desain 10) dalam bahasa [l].
/// Kalimat tingkat 2 ember persis desain; ikan dan kardus dibuat senada.
String hintTextFor(AppLocalizations l, HintText hint) {
  switch (hint.tier) {
    case 1:
      return l.hintTier1Text;
    case 2:
      return switch (hint.item!) {
        Item.fish => l.hintPlaceFish,
        Item.water => l.hintPlaceWater,
        Item.box => l.hintPlaceBox,
      };
    default:
      final parts = [for (final (item, n) in hint.items) _count(l, item, n)];
      final items = switch (parts.length) {
        1 => parts.single,
        2 => l.listPair(parts[0], parts[1]),
        _ => l.listLast(
          parts.sublist(0, parts.length - 1).join(', '),
          parts.last,
        ),
      };
      final tail = hint.hasVase ? l.hintSolutionVaseSafe : l.hintSolutionStars;
      final count = hint.items.fold(0, (sum, item) => sum + item.$2);
      final text = l.hintSolution(items, count, tail);
      return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}

/// "dua ikan asin": jumlah dengan kata (1–3) atau angka.
String _count(AppLocalizations l, Item item, int n) {
  final count = switch (n) {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    _ => 'other',
  };
  return switch (item) {
    Item.fish => l.hintFishCount(count, n),
    Item.water => l.hintWaterCount(count, n),
    Item.box => l.hintBoxCount(count, n),
  };
}
