import 'package:flutter/material.dart';

import '../../game/model/chapter.dart';
import '../../game/render/render.dart';
import '../../game/render/v2/journey_art.dart';
import '../../game/render/v2/cat_rig.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Kartu "Babak baru terbuka!" di atas peta babak yang baru terbuka
/// (desain 23c, `PetaBergambar` mode `pindah`): lapisan krem, konfeti,
/// judul babak, Oyen berjalan ke pintu, jumlah level dan nama bos, dan
/// tombol "Ayo masuk!". Ditutup lewat tombol atau ketuk latar; tombol
/// kembali ditangani [ChapterView]. Masuk dengan geser turun 0,4 detik
/// (`pbSlide`), tanpa animasi saat kurangi gerak.
class ChapterIntroCard extends StatefulWidget {
  const ChapterIntroCard({
    super.key,
    required this.chapter,
    required this.onClose,
  });

  final Chapter chapter;
  final VoidCallback onClose;

  /// Kunci kartu (untuk test letak).
  static const cardKey = ValueKey('chapter-intro-card');

  /// Kartu di tengah layar (desain: y 236 di layar 844), 24 px dari kedua
  /// sisi, selebar desain paling lebar.
  static const double side = 24;
  static const double padding = 22;

  /// Tinggi baris judul babak (`line-height: 1.05`).
  static const double titleHeight = 1.05;

  /// Masuk: geser dari −24 px sambil muncul.
  static const slide = Duration(milliseconds: 400);
  static const double slideFrom = -24;

  /// Gambar pintu: tinggi 150, pintu 300 lebar di kanan, Oyen 112 px di
  /// kiri 36 dari bawah 6, jejak 80×30 di kiri 4 dari bawah 14 (pudar 0,5).
  static const double pictureHeight = 150;
  static const Size doorBox = Size(300, 150);
  static const double oyen = 112;
  static const Offset oyenAt = Offset(36, 6);
  static const Size pawsBox = Size(80, 30);
  static const Offset pawsAt = Offset(4, 14);
  static const double pawsOpacity = 0.5;

  /// Garis papan di gambar pintu: 2 px tiap 32 px.
  static const double plankRow = 32;
  static const double plankLine = 2;

  @override
  State<ChapterIntroCard> createState() => _ChapterIntroCardState();
}

class _ChapterIntroCardState extends State<ChapterIntroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: ChapterIntroCard.slide,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
    } else if (_enter.value == 0 && !_enter.isAnimating) {
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final l = context.l10n;
    final chapter = widget.chapter;
    final curve = _curve;
    // Peta di belakang kartu tidak bisa dicapai pembaca layar.
    return BlockSemantics(
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              button: true,
              label: l.close,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: ColoredBox(color: c.introScrim),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                child: const CustomPaint(
                  size: Size(390, 844),
                  painter: _Confetti(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ChapterIntroCard.side),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth:
                          PictureMapArt.screenWidth - 2 * ChapterIntroCard.side,
                    ),
                    child: AnimatedBuilder(
                      animation: curve,
                      builder: (context, child) => Opacity(
                        opacity: curve.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            ChapterIntroCard.slideFrom * (1 - curve.value),
                          ),
                          child: child,
                        ),
                      ),
                      child: Semantics(
                        scopesRoute: true,
                        namesRoute: true,
                        explicitChildNodes: true,
                        label: l.chapterIntroLabel,
                        child: Container(
                          key: ChapterIntroCard.cardKey,
                          padding: EdgeInsets.fromLTRB(
                            ChapterIntroCard.padding,
                            ChapterIntroCard.padding,
                            ChapterIntroCard.padding,
                            space.s24,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(
                              context.koRadius.boss,
                            ),
                            boxShadow: [
                              ...KoShadow.solid(
                                c.lineDeep,
                                context.koShadow.press,
                              ),
                              ...context.koShadow.dialog,
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.chapterIntroOverline.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: context.koType.overlineLarge.copyWith(
                                  color: c.orangeDeep,
                                ),
                              ),
                              SizedBox(height: space.s8),
                              Text(
                                chapterTitle(l, chapter),
                                textAlign: TextAlign.center,
                                style: context.koType.headline.copyWith(
                                  color: c.ink,
                                  height: ChapterIntroCard.titleHeight,
                                ),
                              ),
                              SizedBox(height: space.s14),
                              const _Picture(),
                              SizedBox(height: space.s8),
                              Text(
                                l.chapterIntroInfo(
                                  chapter.levels.length,
                                  bossName(l, chapter),
                                ),
                                textAlign: TextAlign.center,
                                style: context.koType.paragraph.copyWith(
                                  color: c.inkSoft,
                                ),
                              ),
                              SizedBox(height: space.s14),
                              KoButton(
                                label: l.chapterIntroEnter,
                                kind: KoButtonKind.primary,
                                size: KoButtonSize.large,
                                onPressed: widget.onClose,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gambar pintu dengan Oyen berjalan ke kanan.
class _Picture extends StatelessWidget {
  const _Picture();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.koRadius.tray),
        child: SizedBox(
          height: ChapterIntroCard.pictureHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _Planks(c.mapFloor, c.plank),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: CustomPaint(
                    size: ChapterIntroCard.doorBox,
                    painter: const _Svg(_Art.door),
                  ),
                ),
                Positioned(
                  left: ChapterIntroCard.pawsAt.dx,
                  bottom: ChapterIntroCard.pawsAt.dy,
                  child: Opacity(
                    opacity: ChapterIntroCard.pawsOpacity,
                    child: CustomPaint(
                      size: ChapterIntroCard.pawsBox,
                      painter: const _Svg(_Art.paws),
                    ),
                  ),
                ),
                Positioned(
                  left: ChapterIntroCard.oyenAt.dx,
                  bottom: ChapterIntroCard.oyenAt.dy,
                  child: const CustomPaint(
                    size: Size.square(ChapterIntroCard.oyen),
                    painter: _IntroCat(),
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

enum _Art { door, paws }

class _Svg extends CustomPainter {
  const _Svg(this.art);

  final _Art art;

  @override
  void paint(Canvas canvas, Size size) => switch (art) {
    _Art.door => JourneyArt.door(canvas),
    _Art.paws => _paws(canvas),
  };

  void _paws(Canvas canvas) {
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(10 + i * 20.0, i.isEven ? 8 : 22);
      JourneyArt.paw(canvas);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Svg old) => old.art != art;
}

class _Confetti extends CustomPainter {
  const _Confetti();

  @override
  void paint(Canvas canvas, Size size) => JourneyArt.confetti(canvas);

  @override
  bool shouldRepaint(_Confetti old) => false;
}

/// Lantai papan gambar pintu (`repeating-linear-gradient` 30–32 px).
class _Planks extends CustomPainter {
  _Planks(this.floor, this.line);

  final Color floor;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = floor);
    final paint = Paint()..color = line;
    const row = ChapterIntroCard.plankRow;
    const width = ChapterIntroCard.plankLine;
    for (var y = row - width; y < size.height; y += row) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, width), paint);
    }
  }

  @override
  bool shouldRepaint(_Planks old) => old.floor != floor || old.line != line;
}

class _IntroCat extends CustomPainter {
  const _IntroCat();
  @override
  void paint(Canvas canvas, Size size) => JourneyArt.cat(
    canvas,
    Offset.zero & size,
    motion: CatMotion.walk,
    direction: CatDirection.right,
  );
  @override
  bool shouldRepaint(_IntroCat old) => false;
}
