import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../game/model/accessories.dart';
import '../game/model/home_items.dart';
import '../game/model/kitties.dart';
import '../game/model/snacks.dart';
import '../game/render/render.dart';
import '../l10n/l10n.dart';
import '../l10n/names.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'gallery_page.dart';

/// Sprite kucing kamar, aksesoris, barang, dan camilan. Cek terhadap
/// `SpriteKucing.dc.html`, `AksesorisPreview.dc.html`, dan
/// `BarangKamar.dc.html`.
class GalleryKittyScreen extends StatelessWidget {
  const GalleryKittyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      overline: 'Rumah Oyen',
      title: 'Kucing & barang',
      description:
          'Sembilan kucing koleksi dengan 12 pose dan 16 aksesoris, plus 20 '
          'barang kamar, mangkuk bawaan, dan 5 camilan. Sprite 100×100 unit; '
          'gerakannya ditambahkan di langkah 24.',
      backTo: AppRoutes.gallery,
      backLabel: 'Kembali ke galeri',
      children: [
        GallerySection(
          title: 'Kucing koleksi',
          child: GalleryGrid(
            minWidth: _Spec.kittyMinWidth,
            children: [
              for (final kitty in KittyId.values)
                _ArtCard(
                  label: kittyName(context.l10n, kitty),
                  height: _Spec.cardHeight,
                  child: KittyView(
                    look: KittyLook(kitty: kitty),
                    size: _Spec.kittySize,
                  ),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Pose Oyen',
          child: GalleryGrid(
            minWidth: _Spec.poseMinWidth,
            children: [
              for (final pose in KittyPose.values)
                _ArtCard(
                  label: pose.name,
                  height: _Spec.cardHeight,
                  child: KittyView(
                    look: KittyLook(kitty: KittyId.oyen, pose: pose),
                    size: _Spec.poseSize,
                  ),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Aksesoris di Oyen',
          child: GalleryGrid(
            minWidth: _Spec.poseMinWidth,
            children: [
              for (final accessory in AccessoryId.values)
                _ArtCard(
                  label: accessoryName(context.l10n, accessory),
                  height: _Spec.accessoryCardHeight,
                  child: KittyView(
                    look: KittyLook(kitty: KittyId.oyen, accessory: accessory),
                    size: _Spec.poseSize,
                  ),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Ikon aksesoris',
          child: GalleryGrid(
            minWidth: _Spec.iconMinWidth,
            children: [
              for (final accessory in <AccessoryId?>[
                null,
                ...AccessoryId.values,
              ])
                _ArtCard(
                  label: accessory == null
                      ? 'Tanpa aksesoris'
                      : accessoryName(context.l10n, accessory),
                  height: _Spec.iconCardHeight,
                  child: AccessoryIconView(id: accessory),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Barang kamar',
          child: GalleryGrid(
            minWidth: _Spec.itemMinWidth,
            children: [
              for (final item in RoomItemId.values)
                _ArtCard(
                  label: roomItemName(context.l10n, item),
                  height: _Spec.itemCardHeight,
                  child: RoomItemView(id: item, box: _Spec.itemBox),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Camilan',
          child: GalleryGrid(
            minWidth: _Spec.iconMinWidth,
            children: [
              for (final snack in SnackId.values)
                _ArtCard(
                  label: snackName(context.l10n, snack),
                  height: _Spec.iconCardHeight,
                  child: SnackView(id: snack, box: _Spec.snackBox),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Angka galeri (bukan UI game, jadi bukan token).
abstract final class _Spec {
  static const double kittySize = 104;
  static const double poseSize = 92;
  static const double cardHeight = 164;
  static const double accessoryCardHeight = 176;
  static const double iconCardHeight = 108;
  static const double itemCardHeight = 150;
  static const double kittyMinWidth = 132;
  static const double poseMinWidth = 120;
  static const double iconMinWidth = 104;
  static const double itemMinWidth = 150;
  static const Size itemBox = Size(128, 96);
  static const Size snackBox = Size(60, 44);
}

class _ArtCard extends StatelessWidget {
  const _ArtCard({
    required this.label,
    required this.height,
    required this.child,
  });

  final String label;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return KoCard(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: Center(child: child)),
            SizedBox(height: space.s8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.koType.labelSmall.copyWith(color: c.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
