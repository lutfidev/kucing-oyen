import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Kerangka halaman galeri: tombol kembali, overline, judul, keterangan, lalu
/// isi yang bisa digulir.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.overline,
    required this.title,
    this.description,
    required this.backTo,
    required this.backLabel,
    required this.children,
  });

  final String overline;
  final String title;
  final String? description;

  /// Rute tombol kembali dan label pembaca layarnya.
  final String backTo;
  final String backLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.gutter),
          children: [
            Row(
              children: [
                KoIconButton(
                  icon: KoIcons.back,
                  semanticLabel: backLabel,
                  onPressed: () => context.go(backTo),
                ),
                SizedBox(width: space.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overline.toUpperCase(),
                        style: t.overline.copyWith(color: c.inkSoft),
                      ),
                      Text(title, style: t.title),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              SizedBox(height: space.s12),
              Text(description!, style: t.body.copyWith(color: c.inkSoft)),
            ],
            SizedBox(height: space.s24),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Bagian galeri: judul lalu isinya.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Padding(
      padding: EdgeInsets.only(bottom: space.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.koType.heading),
          SizedBox(height: space.s12),
          child,
        ],
      ),
    );
  }
}

/// Kisi kartu selebar sama: sebanyak mungkin kolom yang masing-masing
/// paling sempit [minWidth].
class GalleryGrid extends StatelessWidget {
  const GalleryGrid({
    super.key,
    required this.minWidth,
    required this.children,
  });

  final double minWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.koSpace.s12;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + gap) / (minWidth + gap))
            .floor()
            .clamp(1, children.length);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
