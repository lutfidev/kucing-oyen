import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../game/sim/item.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'gallery_page.dart';

/// Galeri token dan komponen, untuk dicek terhadap lembar desain
/// `13-design-token-komponen-ui.html`.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return GalleryPage(
      overline: 'Kucing Oren · sistem desain',
      title: 'Token & komponen',
      backTo: AppRoutes.home,
      backLabel: 'Kembali ke Beranda',
      children: [
        GallerySection(
          title: 'Gambar papan, Oyen, kucing kamar, dan suara',
          child: Wrap(
            spacing: space.s12,
            runSpacing: space.s16,
            children: [
              KoButton(
                label: 'Elemen papan',
                kind: KoButtonKind.secondary,
                onPressed: () => context.go(AppRoutes.galleryBoard),
              ),
              KoButton(
                label: 'Oyen',
                kind: KoButtonKind.secondary,
                onPressed: () => context.go(AppRoutes.galleryOyen),
              ),
              KoButton(
                label: 'Suara',
                kind: KoButtonKind.secondary,
                onPressed: () => context.go(AppRoutes.gallerySound),
              ),
            ],
          ),
        ),
        const GallerySection(title: 'Warna', child: _ColorGrid()),
        const GallerySection(title: 'Tipografi', child: _TypeScale()),
        const GallerySection(
          title: 'Jarak, radius, bayangan',
          child: _SpaceRadiusShadow(),
        ),
        const GallerySection(title: 'Komponen UI', child: _Components()),
      ],
    );
  }
}

/// Label kecil kapital di atas contoh komponen.
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.koType.overline.copyWith(
            color: context.koColors.inkSoft,
          ),
        ),
        SizedBox(height: context.koSpace.s10),
        child,
      ],
    );
  }
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

typedef _Swatch = (String name, String token, List<Color> colors, String use);

class _ColorGrid extends StatelessWidget {
  const _ColorGrid();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final swatches = <_Swatch>[
      ('Krem dasar', 'cream', [c.cream], 'Latar semua layar'),
      ('Permukaan', 'surface', [c.surface], 'Kartu, tombol sekunder'),
      ('Garis', 'line', [c.line], 'Border kartu & chip'),
      ('Tinta', 'ink', [c.ink], 'Teks utama, ikon'),
      ('Tinta lembut', 'inkSoft', [c.inkSoft], 'Teks sekunder'),
      (
        'Lantai',
        'floor / floorAlt',
        [c.floor, c.floorAlt],
        'Petak kotak-kotak',
      ),
      ('Oranye', 'orange', [c.orange], 'Tombol utama, benda pemain'),
      ('Oranye dalam', 'orangeDeep', [c.orangeDeep], 'Bayangan tekan, garis'),
      ('Bulu Oyen', 'fur / furStripe', [c.fur, c.furStripe], 'Badan, belang'),
      ('Air', 'water', [c.water], 'Genangan, isi ember'),
      ('Air dalam', 'waterDeep', [c.waterDeep], 'Mangkuk & ember'),
      ('Kardus', 'box / boxEdge', [c.box, c.boxEdge], 'Kardus, tepinya'),
      ('Toska', 'success', [c.success], 'Berhasil, tercapai'),
      ('Toska dalam', 'successDeep', [c.successDeep], 'Judul, bayangan'),
      ('Merah bata', 'brick', [c.brick], 'Vas Ibu, peringatan'),
      ('Bata dalam', 'brickDeep', [c.brickDeep], 'Teks peringatan'),
      ('Kayu', 'wood / woodDeep', [c.wood, c.woodDeep], 'Tembok & perabot'),
      ('Bintang', 'star / starEdge', [c.star, c.starEdge], 'Bintang, koin'),
      ('Garis dalam', 'lineDeep', [c.lineDeep], 'Bayangan sekunder, slot'),
      ('Garis seret', 'orangeLine', [c.orangeLine], 'Slot yang diseret'),
      ('Di atas toska', 'onSuccess', [c.onSuccess], 'Teks tombol sukses'),
      (
        'Bintang kosong',
        'starEmpty / muted',
        [c.starEmpty, c.muted],
        'Belum didapat',
      ),
      ('Terkunci', 'locked', [c.locked], 'Kartu terkunci'),
      (
        'Nonaktif',
        'disabled / onDisabled',
        [c.disabled, c.onDisabled],
        'Tombol nonaktif',
      ),
      (
        'Petunjuk',
        'hint / hintLine / hintDeep',
        [c.hint, c.hintLine, c.hintDeep],
        'Tombol petunjuk',
      ),
      ('Bingkai papan', 'boardRing', [c.boardRing], 'Cincin papan'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;
        final width =
            (constraints.maxWidth - space.s12 * (columns - 1)) / columns;
        return Wrap(
          spacing: space.s12,
          runSpacing: space.s12,
          children: [
            for (final swatch in swatches)
              SizedBox(width: width, child: _SwatchCard(swatch)),
          ],
        );
      },
    );
  }
}

class _SwatchCard extends StatelessWidget {
  const _SwatchCard(this.swatch);

  final _Swatch swatch;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final (name, token, colors, use) = swatch;
    final radius = Radius.circular(context.koRadius.slot);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.all(radius),
        border: Border.all(color: c.line, width: context.koSize.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: context.koSize.slot,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, color) in colors.indexed)
                  Expanded(
                    flex: i == 0 ? 3 : 1,
                    child: ColoredBox(color: color),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(space.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: t.labelSmall),
                Text(
                  '$token\n${colors.map(_hex).join(' / ')}',
                  style: t.body.copyWith(
                    color: c.inkSoft,
                    fontSize: t.overline.fontSize,
                  ),
                ),
                Text(
                  use,
                  style: t.body.copyWith(
                    color: c.inkSoft,
                    fontSize: t.overline.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final rows = <(String, TextStyle, String)>[
      ('display', t.display, 'Berhasil!'),
      ('title', t.title, 'Aturan Oyen'),
      ('heading', t.heading, 'Level 13 · Vas Ibu'),
      ('number', t.number, '6 · 14/60 · 120'),
      (
        'body',
        t.body,
        'Ketemu genangan atau ember, Oyen kaget lalu balik badan.',
      ),
      ('label', t.label, 'Pengaturan'),
      ('overline', t.overline.copyWith(color: c.inkSoft), 'BABAK 1'),
      ('buttonHero', t.buttonHero, 'Main'),
      ('button', t.button, 'Bangunkan Oyen'),
      ('chip', t.chip, '14/60'),
      ('numberSmall', t.numberSmall, '1'),
      ('badge', t.badge, '2'),
      ('labelSmall', t.labelSmall, 'Langkah'),
    ];
    return KoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, (name, style, sample)) in rows.indexed) ...[
            if (i > 0) Divider(color: c.line, height: context.koSpace.s16),
            Text(
              '$name · ${style.fontFamily} '
              '${style.fontWeight!.value}/${style.fontSize!.round()}',
              style: t.labelSmall.copyWith(color: c.inkSoft),
            ),
            Text(sample, style: style),
          ],
        ],
      ),
    );
  }
}

class _SpaceRadiusShadow extends StatelessWidget {
  const _SpaceRadiusShadow();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final r = context.koRadius;
    final shadow = context.koShadow;
    final s = context.koSize;
    final demo = Size(s.slot, s.iconButton);

    Widget box({
      required double radius,
      required Color color,
      Color? border,
      List<BoxShadow>? shadows,
    }) {
      return Container(
        width: demo.width,
        height: demo.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: border == null
              ? null
              : Border.all(color: border, width: s.border),
          boxShadow: shadows,
        ),
      );
    }

    return KoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: space.s16,
            runSpacing: space.s12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final (name, value) in [
                ('s4', space.s4),
                ('s8', space.s8),
                ('s12', space.s12),
                ('s16', space.s16),
                ('s24', space.s24),
                ('s32', space.s32),
              ])
                _Caption(
                  caption: name,
                  child: Container(
                    width: value,
                    height: demo.height,
                    decoration: BoxDecoration(
                      color: c.orange,
                      borderRadius: BorderRadius.circular(space.s4),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: space.s24),
          Wrap(
            spacing: space.s12,
            runSpacing: space.s12,
            children: [
              for (final (name, value) in [
                ('8 · petak', r.tile),
                ('14 · ikon', r.icon),
                ('16 · slot', r.slot),
                ('20 · tombol', r.button),
                ('24 · utama', r.primary),
                ('28 · sheet', r.sheet),
                ('pill · chip', r.pill),
              ])
                _Caption(
                  caption: name,
                  child: box(radius: value, color: c.floorAlt, border: c.wood),
                ),
            ],
          ),
          SizedBox(height: space.s24),
          Wrap(
            spacing: space.s24,
            runSpacing: space.s24,
            children: [
              _Caption(
                caption: 'press\n0 6 0 orangeDeep',
                child: box(
                  radius: r.icon,
                  color: c.orange,
                  shadows: KoShadow.solid(c.orangeDeep, shadow.press),
                ),
              ),
              _Caption(
                caption: 'card\n0 6 16 · 14%',
                child: box(
                  radius: r.icon,
                  color: c.surface,
                  border: c.line,
                  shadows: shadow.card,
                ),
              ),
              _Caption(
                caption: 'board\nring 4 + 0 14 28',
                child: box(
                  radius: space.s12,
                  color: c.floor,
                  shadows: shadow.board,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Contoh dengan keterangan kecil di bawahnya.
class _Caption extends StatelessWidget {
  const _Caption({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: context.koSpace.s6),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: context.koType.labelSmall.copyWith(
            color: context.koColors.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _Components extends StatelessWidget {
  const _Components();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    void noop() {}

    return KoCard(
      padding: EdgeInsets.all(space.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Labeled(
            label: 'Tombol utama',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KoButton(
                  label: 'Main',
                  size: KoButtonSize.hero,
                  icon: KoIcons.play,
                  onPressed: noop,
                ),
                SizedBox(height: space.s24),
                KoButton(
                  label: 'Bangunkan Oyen',
                  size: KoButtonSize.large,
                  icon: KoIcons.wake,
                  onPressed: noop,
                ),
                SizedBox(height: space.s24),
                KoButton(label: 'Lanjut', onPressed: noop),
                SizedBox(height: space.s16),
                const KoButton(label: 'Belum bisa', onPressed: null),
              ],
            ),
          ),
          SizedBox(height: space.s24),
          Wrap(
            spacing: space.s24,
            runSpacing: space.s24,
            children: [
              _Labeled(
                label: 'Sukses',
                child: KoButton(
                  label: 'Lihat hasil',
                  kind: KoButtonKind.success,
                  onPressed: noop,
                ),
              ),
              _Labeled(
                label: 'Sekunder',
                child: KoButton(
                  label: 'Ulangi',
                  kind: KoButtonKind.secondary,
                  onPressed: noop,
                ),
              ),
            ],
          ),
          SizedBox(height: space.s24),
          _Labeled(
            label: 'Ikon',
            child: Wrap(
              spacing: space.s10,
              runSpacing: space.s12,
              children: [
                KoIconButton(
                  icon: KoIcons.back,
                  semanticLabel: 'Kembali',
                  onPressed: noop,
                ),
                KoIconButton(
                  icon: KoIcons.hint,
                  semanticLabel: 'Petunjuk',
                  tone: KoIconButtonTone.hint,
                  onPressed: noop,
                ),
                KoIconButton(
                  icon: KoIcons.rules,
                  semanticLabel: 'Aturan',
                  label: 'Aturan',
                  onPressed: noop,
                ),
                KoIconButton(
                  icon: KoIcons.reset,
                  semanticLabel: 'Kosongkan papan',
                  tone: KoIconButtonTone.floor,
                  iconSize: s.iconSmall,
                  onPressed: noop,
                ),
                KoIconButton(
                  icon: KoIcons.close,
                  semanticLabel: 'Tutup',
                  tone: KoIconButtonTone.flat,
                  iconSize: s.iconSmall,
                  onPressed: noop,
                ),
              ],
            ),
          ),
          SizedBox(height: space.s24),
          _Labeled(
            label: 'Chip',
            child: Wrap(
              spacing: space.s8,
              runSpacing: space.s8,
              children: [
                KoChip(
                  leading: KoStar(size: s.icon),
                  text: '14/60',
                ),
                const KoChip.dark(label: 'Langkah', text: '1'),
              ],
            ),
          ),
          SizedBox(height: space.s24),
          _Labeled(
            label: 'Slot baki',
            child: Padding(
              // Badge keluar dari sudut slot.
              padding: EdgeInsets.only(top: s.badgeInset, right: s.badgeInset),
              child: Wrap(
                spacing: space.s16,
                runSpacing: space.s16,
                children: const [
                  TraySlot(
                    count: 2,
                    semanticLabel: 'Kardus, sisa 2',
                    child: ItemArtView(Item.box),
                  ),
                  TraySlot(
                    count: 0,
                    semanticLabel: 'Kardus, sedang diseret, sisa 0',
                    child: ItemArtView(Item.box, ghost: true),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: space.s24),
          _Labeled(label: 'Bintang', child: const KoStars(earned: 2)),
          SizedBox(height: space.s24),
          _Labeled(
            label: 'Kartu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KoCard(
                  padding: EdgeInsets.all(space.s10),
                  child: _CardText(
                    title: 'Air? Putar balik',
                    body: 'Ketemu genangan atau ember, Oyen kaget lalu balik badan.',
                  ),
                ),
                SizedBox(height: space.s10),
                KoCard(
                  padding: EdgeInsets.all(space.s10),
                  locked: true,
                  child: _CardText(
                    title: 'Kardus: ???',
                    body: 'Belum dipelajari. Nanti juga kenalan sendiri.',
                    color: c.onDisabled,
                  ),
                ),
                SizedBox(height: space.s16),
                KoCard(
                  elevated: true,
                  child: Text(
                    'Kartu dengan bayangan lembut.',
                    style: t.body.copyWith(color: c.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  const _CardText({required this.title, required this.body, this.color});

  final String title;
  final String body;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.heading.copyWith(color: color ?? c.ink)),
        SizedBox(height: context.koSpace.s2),
        Text(body, style: t.body.copyWith(color: color ?? c.inkSoft)),
      ],
    );
  }
}
