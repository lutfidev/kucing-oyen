import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../../game/render/render.dart';

/// Satu petak papan untuk pembaca layar.
class BoardTileSemantics {
  const BoardTileSemantics({
    required this.label,
    this.onTap,
    this.onTapHint,
    this.onReturn,
    this.returnLabel,
    this.selected = false,
  });

  /// "Baris 4, kolom 4: lantai".
  final String label;

  /// Ketuk dua kali: taruh, ambil, atau batal; null = tanpa aksi.
  final VoidCallback? onTap;

  /// Melengkapi "Ketuk dua kali untuk ...".
  final String? onTapHint;

  /// Aksi kustom "Kembalikan ke baki" ([returnLabel]); null = tanpa aksi.
  final VoidCallback? onReturn;
  final String? returnLabel;

  /// Benda di petak ini sedang dipilih untuk dipindah.
  final bool selected;
}

/// Lapisan pembaca layar di atas papan Flame: [BoardScene.columns] ×
/// [BoardScene.rows] petak urut baris, tanpa gambar. Sentuhan jari tembus
/// ke papan di bawahnya; hanya aksi pembaca layar yang ditangani di sini.
class BoardSemantics extends StatefulWidget {
  const BoardSemantics({super.key, required this.tiles})
    : assert(tiles.length == BoardScene.columns * BoardScene.rows);

  /// Daftar yang sama (identik) dengan sebelumnya tidak dibangun ulang,
  /// mis. selama seretan.
  final List<BoardTileSemantics> tiles;

  @override
  State<BoardSemantics> createState() => _BoardSemanticsState();
}

class _BoardSemanticsState extends State<BoardSemantics> {
  List<BoardTileSemantics>? _builtFor;
  Widget? _built;

  @override
  Widget build(BuildContext context) {
    final tiles = widget.tiles;
    final built = _built;
    if (built != null && identical(tiles, _builtFor)) return built;
    _builtFor = tiles;
    return _built = Column(
      children: [
        for (var r = 0; r < BoardScene.rows; r++)
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < BoardScene.columns; c++)
                  Expanded(child: _tile(tiles[r * BoardScene.columns + c])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tile(BoardTileSemantics tile) {
    final onReturn = tile.onReturn;
    return Semantics(
      container: true,
      label: tile.label,
      selected: tile.selected ? true : null,
      onTap: tile.onTap,
      onTapHint: tile.onTap == null ? null : tile.onTapHint,
      customSemanticsActions: onReturn == null
          ? null
          : {CustomSemanticsAction(label: tile.returnLabel!): onReturn},
      // Tanpa anak yang bisa disentuh: hit test gagal, sentuhan tembus.
      child: const SizedBox.expand(),
    );
  }
}
