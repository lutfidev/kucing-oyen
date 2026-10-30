import 'package:flutter/material.dart';

import '../app/game_audio.dart';
import '../app/routes.dart';
import '../game/model/sounds.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'gallery_page.dart';

/// Semua efek suara dan kedua lagu, untuk didengar di perangkat
/// (`flutter run --route /galeri/suara`). Kartunya tidak berbunyi "tap"
/// supaya suara yang dicoba terdengar sendiri. Sakelar Pengaturan tetap
/// berlaku.
class GallerySoundScreen extends StatelessWidget {
  const GallerySoundScreen({super.key});

  static const _sounds = [
    (GameSound.tap, 'Tombol'),
    (GameSound.pickUp, 'Angkat benda'),
    (GameSound.place, 'Taruh benda'),
    (GameSound.back, 'Kembali ke baki'),
    (GameSound.wake, 'Oyen bangun'),
    (GameSound.eat, 'Makan ikan'),
    (GameSound.scared, 'Kaget air'),
    (GameSound.box, 'Masuk kardus'),
    (GameSound.glass, 'Gelas jatuh'),
    (GameSound.vase, 'PRANG! vas pecah'),
    (GameSound.star, 'Bintang'),
    (GameSound.bored, 'Oyen bosan'),
    (GameSound.coin, 'Koin'),
    (GameSound.purr, 'Dengkur (dielus)'),
    (GameSound.meow, 'Meong (diketuk)'),
    (GameSound.munch, 'Makan camilan'),
    (GameSound.reward, 'Hadiah koin kucing'),
    (GameSound.buy, 'Beli di Toko'),
    (GameSound.wear, 'Pasang aksesoris'),
  ];

  static const _tracks = [
    (MusicTrack.home, 'Lagu Beranda'),
    (MusicTrack.level, 'Lagu level'),
  ];

  @override
  Widget build(BuildContext context) {
    final audio = AudioScope.of(context);
    return GalleryPage(
      overline: 'Audio',
      title: 'Suara',
      description:
          'Efek suara dari bunyi CC0 (Kenney, OpenGameArt), musik dibuat '
          'sendiri (tool/audio/). Ketuk untuk mendengar.',
      backTo: AppRoutes.gallery,
      backLabel: 'Kembali ke galeri',
      children: [
        GallerySection(
          title: 'Efek suara',
          child: GalleryGrid(
            minWidth: _minWidth,
            children: [
              for (final (sound, label) in _sounds)
                _SoundCard(
                  key: ValueKey('sound-${sound.name}'),
                  label: label,
                  file: sound.asset,
                  onTap: () => audio.play(sound),
                ),
            ],
          ),
        ),
        GallerySection(
          title: 'Musik',
          child: GalleryGrid(
            minWidth: _minWidth,
            children: [
              for (final (track, label) in _tracks)
                _SoundCard(
                  key: ValueKey('music-${track.name}'),
                  label: label,
                  file: track.asset,
                  onTap: () => audio.setTrack(track),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Lebar kartu paling kecil di grid.
  static const _minWidth = 150.0;
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    super.key,
    required this.label,
    required this.file,
    required this.onTap,
  });

  final String label;
  final String file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: KoCard(
          child: Row(
            children: [
              KoIcon(
                KoIcons.play,
                size: context.koSize.iconCompact,
                color: c.ink,
              ),
              SizedBox(width: context.koSpace.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: t.cardLabel.copyWith(color: c.ink)),
                    Text(file, style: t.caption.copyWith(color: c.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
