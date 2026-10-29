import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../game/render/render.dart';
import '../game/sim/direction.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'gallery_page.dart';

/// Sprite Oyen: arah hadap dan pose. Cek terhadap
/// `14-sprite-oyen-arah-pose.html`.
class GalleryOyenScreen extends StatelessWidget {
  const GalleryOyenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return GalleryPage(
      overline: 'Karakter orisinal',
      title: 'Oyen',
      description:
          'Kucing oren belang, bulat, pipi tembam, mata besar setengah '
          'ngantuk. Sprite 100×100 unit; di papan dirender 62 px (petak 50 '
          'px), menghadap kanan = cermin dari kiri.',
      backTo: AppRoutes.gallery,
      backLabel: 'Kembali ke galeri',
      children: [
        GallerySection(
          title: 'Arah hadap',
          child: GalleryGrid(
            minWidth: _Spec.dirMinWidth,
            children: [
              for (final (dir, label) in _dirs)
                _OyenCard(
                  look: OyenLook(pose: OyenPose.walk, dir: dir),
                  size: _Spec.dirSize,
                  label: label,
                  minHeight: _Spec.cardHeight,
                  gap: space.s4,
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Pose',
          child: GalleryGrid(
            minWidth: _Spec.poseMinWidth,
            children: [
              for (final (pose, bubble, label) in _poses)
                _OyenCard(
                  look: OyenLook(pose: pose, bubble: bubble),
                  size: _Spec.poseSize,
                  label: label,
                  minHeight: _Spec.cardHeight,
                  gap: space.s6,
                  alignEnd: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Angka dari halaman desain 14 (bukan UI game, jadi bukan token).
abstract final class _Spec {
  static const double dirSize = 104;
  static const double poseSize = 88;
  static const double cardHeight = 150;

  /// Lebar kartu paling sempit sebelum kisi turun satu kolom. Kartu pose
  /// diberi ruang untuk gelembung kaget yang keluar di kanan atas.
  static const double dirMinWidth = 132;
  static const double poseMinWidth = 112;
}

const _dirs = [
  (Direction.down, 'Bawah'),
  (Direction.left, 'Kiri'),
  (Direction.right, 'Kanan'),
  (Direction.up, 'Atas'),
];

const _poses = [
  (OyenPose.sleep, OyenBubble.zzz, 'Tidur'),
  (OyenPose.walk, OyenBubble.none, 'Jalan'),
  (OyenPose.shock, OyenBubble.kaget, 'Kaget'),
  (OyenPose.box, OyenBubble.none, 'Duduk di kardus'),
  (OyenPose.knock, OyenBubble.none, 'Menjatuhkan'),
  (OyenPose.eat, OyenBubble.none, 'Makan'),
  (OyenPose.happy, OyenBubble.none, 'Senang'),
];

class _OyenCard extends StatelessWidget {
  const _OyenCard({
    required this.look,
    required this.size,
    required this.label,
    required this.minHeight,
    required this.gap,
    this.alignEnd = false,
  });

  final OyenLook look;
  final double size;
  final String label;
  final double minHeight;
  final double gap;

  /// Oyen dan label rata bawah (kartu pose).
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final oyen = OyenView(look, size: size);
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: context.koType.labelSmall,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: KoCard(
        padding: EdgeInsets.all(context.koSpace.s12),
        child: Column(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
          children: [
            oyen,
            SizedBox(height: gap),
            text,
          ],
        ),
      ),
    );
  }
}
