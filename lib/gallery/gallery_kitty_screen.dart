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
          'gerakannya di halaman Gerak.',
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

/// Gerak kucing dan barang (`AnimasiKucing.dc.html`, desain 21c), berjalan
/// terus. Diam kalau gerak dikurangi.
class GalleryMotionScreen extends StatefulWidget {
  const GalleryMotionScreen({super.key});

  @override
  State<GalleryMotionScreen> createState() => _GalleryMotionScreenState();
}

/// Kartu desain 21c: kucing, pose, arah, aksesoris, judul.
const _motionCats = [
  (KittyId.oyen, KittyPose.idle, KittyFacing.down, null, 'Kedip'),
  (KittyId.arang, KittyPose.idle, KittyFacing.down, AccessoryId.kalung, 'Ekor'),
  (KittyId.oyen, KittyPose.walk1, KittyFacing.right, null, 'Jalan'),
  (
    KittyId.mendung,
    KittyPose.sleep,
    KittyFacing.down,
    AccessoryId.beanie,
    'Tidur',
  ),
  (KittyId.oyen, KittyPose.eat, KittyFacing.down, null, 'Makan'),
  (KittyId.telon, KittyPose.play, KittyFacing.down, AccessoryId.pita, 'Main'),
  (
    KittyId.oyen,
    KittyPose.scratch,
    KittyFacing.down,
    AccessoryId.bandana,
    'Garuk tiang',
  ),
  (KittyId.salju, KittyPose.petted, KittyFacing.down, null, 'Dielus'),
  (
    KittyId.oyen,
    KittyPose.happy,
    KittyFacing.down,
    AccessoryId.topiPesta,
    'Senang',
  ),
  (
    KittyId.kopiSusu,
    KittyPose.walk1,
    KittyFacing.right,
    AccessoryId.syal,
    'Syal saat jalan',
  ),
  (
    KittyId.mochi,
    KittyPose.idle,
    KittyFacing.down,
    AccessoryId.headphone,
    'Headphone',
  ),
];

/// Barang dipakai kucing (null = tidak dipakai) di desain 21c.
const _motionItems = [
  (RoomItemId.akuarium, null),
  (RoomItemId.bola, null),
  (RoomItemId.catnip, null),
  (RoomItemId.jam, null),
  (RoomItemId.pancingan, KittyId.oyen),
  (RoomItemId.jendelaBurung, KittyId.kopiSusu),
  (RoomItemId.lampuBulan, null),
  (RoomItemId.hammock, KittyId.oyen),
  (RoomItemId.monstera, null),
  (RoomItemId.terowongan, KittyId.kembang),
  (RoomItemId.sofaMini, KittyId.bos),
  (RoomItemId.kasur, KittyId.mendung),
  (RoomItemId.kardus, KittyId.oyen),
  (RoomItemId.rak, KittyId.arang),
];

class _GalleryMotionScreenState extends State<GalleryMotionScreen>
    with SingleTickerProviderStateMixin {
  late final _ticker = createTicker(
    (elapsed) => setState(() => _time = elapsed.inMicroseconds / 1e6),
  );
  double _time = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (!still && !_ticker.isActive) _ticker.start();
    if (still && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = _ticker.isActive ? _time : null;
    return GalleryPage(
      overline: 'Rumah Oyen',
      title: 'Gerak kucing & barang',
      description:
          'Desain 21c: kedip, ekor, napas, jalan dua bingkai, makan, main, '
          'garuk, dielus, senang, dan barang yang bergerak. Semua fungsi '
          'waktu; kurangi gerak membuatnya diam.',
      backTo: AppRoutes.gallery,
      backLabel: 'Kembali ke galeri',
      children: [
        GallerySection(
          title: 'Kucing',
          child: GalleryGrid(
            minWidth: _Spec.poseMinWidth,
            children: [
              for (final (kitty, pose, facing, accessory, title) in _motionCats)
                _ArtCard(
                  label: title,
                  height: _Spec.cardHeight,
                  child: KittyView(
                    look: KittyLook(
                      kitty: kitty,
                      pose: pose == KittyPose.walk1 && time != null
                          ? KittyLook.walkPose(time)
                          : pose,
                      facing: facing,
                      accessory: accessory,
                      time: time,
                    ),
                    size: _Spec.poseSize,
                  ),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Barang hidup dan dipakai',
          child: GalleryGrid(
            minWidth: _Spec.itemMinWidth,
            children: [
              for (final (item, user) in _motionItems)
                _ArtCard(
                  label: roomItemName(context.l10n, item),
                  height: _Spec.itemCardHeight,
                  child: RoomItemView(
                    id: item,
                    box: _Spec.itemBox,
                    time: time,
                    user: user == null
                        ? null
                        : KittyLook(kitty: user, time: time),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
