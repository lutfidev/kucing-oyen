import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../game/render/render.dart';
import '../game/sim/sim.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'gallery_page.dart';

/// Petak dan papan. Cek terhadap `15-elemen-papan.html` dan
/// `18-komponen-papan-7x9.html`.
class GalleryBoardScreen extends StatelessWidget {
  const GalleryBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return GalleryPage(
      overline: 'Petak 50 × 50 · ditampilkan 160%',
      title: 'Elemen papan',
      description:
          'Benda pemain = versi bawaan + garis tepi oranye, supaya selalu '
          'kebaca mana yang bisa dipindah. Huruf = kode peta level.',
      backTo: AppRoutes.gallery,
      backLabel: 'Kembali ke galeri',
      children: [
        GallerySection(
          title: 'Petak',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, group) in _groups.indexed) ...[
                if (i > 0) SizedBox(height: space.s16),
                _TileGroup(group),
              ],
            ],
          ),
        ),
        const GallerySection(title: 'Papan 7×9', child: _Boards()),
      ],
    );
  }
}

/// Angka dari halaman desain 15 (bukan UI game, jadi bukan token).
abstract final class _Spec {
  /// Petak 50 px ditampilkan 160%.
  static const double previewScale = 1.6;
  static const double previewRadius = 10;
  static const double previewRing = 1.5;
}

typedef _Group = (String title, List<(Tile tile, String label)> tiles);

const _groups = <_Group>[
  (
    'Tembok & perabot  (#)',
    [
      (Tile(kind: TileKind.wall), 'Tembok'),
      (Tile(kind: TileKind.cupboard), 'Lemari'),
      (Tile(kind: TileKind.shelf), 'Rak'),
      (Tile(kind: TileKind.fridge), 'Kulkas'),
    ],
  ),
  (
    'Lantai & tujuan',
    [
      (Tile(), 'Lantai (.)'),
      (Tile(alt: true), 'Lantai selang'),
      (Tile(kind: TileKind.bowl), 'Mangkuk (T)'),
      (Tile(glow: true), 'Petak tujuan'),
    ],
  ),
  (
    'Meja',
    [
      (Tile(kind: TileKind.table), 'Kosong (M)'),
      (Tile(kind: TileKind.tableGlass), 'Gelas (G)'),
      (Tile(kind: TileKind.tableVase), 'Vas Ibu (V)'),
      (Tile(kind: TileKind.tableBroken), 'Vas pecah'),
    ],
  ),
  (
    'Benda bawaan',
    [
      (Tile(item: TileItem.fish), 'Ikan asin'),
      (Tile(item: TileItem.water), 'Genangan'),
      (Tile(item: TileItem.box), 'Kardus'),
    ],
  ),
  (
    'Benda pemain',
    [
      (Tile(item: TileItem.fishP), 'Ikan asin'),
      (Tile(item: TileItem.bucketP), 'Ember air'),
      (Tile(item: TileItem.boxP), 'Kardus'),
    ],
  ),
];

class _TileGroup extends StatelessWidget {
  const _TileGroup(this.group);

  final _Group group;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final (title, tiles) = group;
    return KoCard(
      padding: EdgeInsets.fromLTRB(space.s16, space.s14, space.s16, space.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.koType.heading),
          SizedBox(height: space.s10),
          Wrap(
            spacing: space.s14,
            runSpacing: space.s12,
            children: [
              for (final (tile, label) in tiles) _TilePreview(tile, label),
            ],
          ),
        ],
      ),
    );
  }
}

class _TilePreview extends StatelessWidget {
  const _TilePreview(this.tile, this.label);

  final Tile tile;
  final String label;

  @override
  Widget build(BuildContext context) {
    const size = Tile.size * _Spec.previewScale;
    final radius = BorderRadius.circular(_Spec.previewRadius);
    return SizedBox(
      width: size,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: context.koColors.lineDeep,
                  spreadRadius: _Spec.previewRing,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: TileView(tile, size: size),
            ),
          ),
          SizedBox(height: context.koSpace.s6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.koType.overline.copyWith(letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _Boards extends StatelessWidget {
  const _Boards();

  @override
  Widget build(BuildContext context) {
    const map = BoardScene.designMap;
    final boards = [
      (
        'Fase atur',
        'Seperti layar 03: Oyen tidur dengan Zzz dan panah arah hadap, satu '
            'petak menyala. Tembok di dalam ruangan jadi lemari.',
        BoardScene.fromMap(map, glow: {const Pos(3, 3)}),
      ),
      (
        'Fase jalan',
        'Seperti layar 04 langkah 5: ember dan ikan pemain, Oyen berjalan ke '
            'kiri.',
        BoardScene.fromMap(
          map,
          items: {
            const Pos(3, 3): TileItem.bucketP,
            const Pos(2, 4): TileItem.fishP,
          },
          oyen: BoardOyen.at(
            const Pos(4, 4),
            const OyenLook(pose: OyenPose.walk, dir: Direction.left),
          ),
        ),
      ),
      (
        'Vas pecah',
        'Ikan pemain saja di bawah vas: di langkah 2 Oyen menjatuhkan vas.',
        BoardScene.fromMap(
          map,
          items: {const Pos(2, 4): TileItem.fishP},
          broken: true,
          oyen: BoardOyen.at(
            const Pos(3, 3),
            const OyenLook(pose: OyenPose.knock, dir: Direction.left),
          ),
        ),
      ),
    ];
    final space = context.koSpace;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (title, caption, scene)) in boards.indexed) ...[
          if (i > 0) SizedBox(height: space.s24),
          Text(title, style: context.koType.label),
          Text(
            caption,
            style: context.koType.body.copyWith(
              color: context.koColors.inkSoft,
            ),
          ),
          SizedBox(height: space.s16),
          Padding(
            // Ruang untuk cincin bingkai papan.
            padding: EdgeInsets.symmetric(horizontal: space.s4),
            child: BoardView(scene),
          ),
        ],
      ],
    );
  }
}
