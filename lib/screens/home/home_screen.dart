import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Beranda (desain 01): Oyen tidur di atas logo, total bintang, tombol Main
/// ke peta babak yang sedang dimainkan, Lemari Kostum, dan Pengaturan yang
/// belum berfungsi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final progress = ProgressScope.of(context);

    return Scaffold(
      body: CustomPaint(
        painter: _HomeBackground(c.checker),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              space.s24,
              space.s8,
              space.s24,
              space.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _CoinChip(coins: progress.coins),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _Title(
                        stars: progress.progress.totalStars,
                        maxStars: progress.maxStars,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: space.s16),
                KoButton(
                  label: 'Main',
                  size: KoButtonSize.hero,
                  icon: KoIcons.play,
                  onPressed: () => context.go(
                    AppRoutes.chapter(progress.currentChapter.number),
                  ),
                ),
                // Desain: jarak 16 + margin 8.
                SizedBox(height: space.s24),
                SizedBox(
                  height: s.menuButton,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MenuButton(
                          icon: KoIcons.costume,
                          label: 'Lemari Kostum',
                          onPressed: () => context.go(AppRoutes.closet),
                        ),
                      ),
                      SizedBox(width: space.s12),
                      // Pengaturan belum berfungsi (langkah 15).
                      const Expanded(
                        child: _MenuButton(
                          icon: KoIcons.settings,
                          label: 'Pengaturan',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Saldo koin di kiri atas (desain 01). Belum bisa ditekan.
class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      container: true,
      label: '$coins koin',
      excludeSemantics: true,
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(start: space.s6, end: space.s14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          boxShadow: context.koShadow.coinChip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoinView(size: s.iconLarge),
            SizedBox(width: space.s8),
            Text('$coins', maxLines: 1, style: context.koType.chip),
          ],
        ),
      ),
    );
  }
}

/// Oyen tidur, logo, tagline, dan total bintang.
class _Title extends StatelessWidget {
  const _Title({required this.stars, required this.maxStars});

  final int stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    const oyen = OyenLook(
      pose: OyenPose.sleep,
      dir: Direction.down,
      bubble: OyenBubble.zzz,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo menutupi bagian bawah Oyen (desain: margin bawah -34).
        Align(
          alignment: Alignment.topCenter,
          heightFactor: (s.oyenHome - s.oyenHomeOverlap) / s.oyenHome,
          child: OyenView(oyen, size: s.oyenHome),
        ),
        SizedBox(height: space.s4),
        Semantics(
          header: true,
          label: 'Kucing Oren',
          child: ExcludeSemantics(
            child: Column(
              children: [
                Text('Kucing', style: t.logoSmall.copyWith(color: c.ink)),
                Text(
                  'Oren',
                  style: t.logo.copyWith(
                    color: c.logo,
                    shadows: context.koShadow.logo,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Desain: jarak 4 + margin 18.
        SizedBox(height: space.s16 + space.s6),
        Text(
          'Oyen nggak bisa disuruh. Kamu yang mikir.',
          textAlign: TextAlign.center,
          style: t.bodyLarge.copyWith(color: c.inkSoft),
        ),
        // Desain: jarak 4 + margin 22.
        SizedBox(height: space.s24 + space.s2),
        _StarTotal(stars: stars, maxStars: maxStars),
      ],
    );
  }
}

/// "★ 31/60 bintang".
class _StarTotal extends StatelessWidget {
  const _StarTotal({required this.stars, required this.maxStars});

  final int stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    return Semantics(
      label: '$stars dari $maxStars bintang',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: space.s16 + space.s2,
            vertical: space.s10,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(context.koRadius.pill),
            border: Border.all(color: c.line, width: s.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KoStar(size: s.starHome),
              SizedBox(width: space.s10),
              Text.rich(
                TextSpan(
                  text: '$stars',
                  children: [
                    TextSpan(
                      text: '/$maxStars',
                      style: TextStyle(color: c.inkSoft),
                    ),
                  ],
                ),
                style: t.numberChip.copyWith(color: c.ink),
              ),
              SizedBox(width: space.s10),
              Text('bintang', style: t.bodySmall.copyWith(color: c.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol krem kecil di bawah "Main". Belum berfungsi: tidak bisa ditekan,
/// tampilannya tetap seperti desain.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.icon, required this.label, this.onPressed});

  final KoIconData icon;
  final String label;

  /// Null = belum bisa ditekan.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.control,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KoIcon(icon, size: s.icon, color: c.ink),
              SizedBox(width: space.s8),
              Text(
                label,
                maxLines: 1,
                style: context.koType.label.copyWith(color: c.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Latar Beranda: kotak-kotak krem (`conic-gradient`, petak kanan atas dan
/// kiri bawah tiap pola) dan jejak kaki di sudut.
class _HomeBackground extends CustomPainter {
  _HomeBackground(this.checker);

  final Color checker;

  @override
  void paint(Canvas canvas, Size size) {
    const pattern = MapArt.checkerPattern;
    const half = pattern / 2;
    final path = Path();
    for (var y = 0.0; y < size.height; y += pattern) {
      for (var x = 0.0; x < size.width; x += pattern) {
        path
          ..addRect(Rect.fromLTWH(x + half, y, half, half))
          ..addRect(Rect.fromLTWH(x, y + half, half, half));
      }
    }
    canvas.drawPath(path, Paint()..color = checker);
    paintHomePaws(canvas, size);
  }

  @override
  bool shouldRepaint(_HomeBackground old) => old.checker != checker;
}
