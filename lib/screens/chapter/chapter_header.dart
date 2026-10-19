import 'package:flutter/material.dart';

import '../../app/game_audio.dart';
import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Judul peta babak (desain 02): kembali, "BABAK 2 / Ruang Tamu", bintang
/// babak, lalu kartu babak lain. Latarnya krem dan memudar setinggi
/// [MapArt.headerFade] di bawah, menutupi peta yang digulir.
class ChapterHeader extends StatelessWidget {
  const ChapterHeader({
    super.key,
    required this.chapter,
    required this.other,
    required this.progress,
    required this.onBack,
    required this.onOpen,
  });

  final Chapter chapter;

  /// Babak di kartu: babak sebelumnya, atau berikutnya untuk Babak 1.
  final Chapter? other;
  final Progress progress;
  final VoidCallback onBack;
  final ValueChanged<Chapter> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final other = this.other;

    return CustomPaint(
      painter: _Fade(c.cream),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          space.gutter,
          MediaQuery.paddingOf(context).top + space.s8,
          space.gutter,
          MapArt.headerFade / 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                KoIconButton(
                  icon: KoIcons.back,
                  semanticLabel: context.l10n.backToHome,
                  onPressed: onBack,
                ),
                SizedBox(width: space.s12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FitStart(
                          Text(
                            context.l10n
                                .chapterNumber(chapter.number)
                                .toUpperCase(),
                            maxLines: 1,
                            style: t.overline.copyWith(color: c.inkSoft),
                          ),
                        ),
                        _FitStart(
                          Text(
                            chapterName(context.l10n, chapter),
                            maxLines: 1,
                            style: t.title.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: space.s12),
                _StarChip(
                  stars: chapter.stars(progress),
                  maxStars: chapter.maxStars,
                ),
              ],
            ),
            if (other != null) ...[
              SizedBox(height: space.s14),
              ChapterCard(
                chapter: other,
                progress: progress,
                onOpen: () => onOpen(other),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kartu babak lain: ikon, nama, status ("Selesai" atau "Terkunci"), dan
/// bintangnya. Bisa ditekan kalau babaknya terbuka.
class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.progress,
    required this.onOpen,
  });

  final Chapter chapter;
  final Progress progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    final s = context.koSize;
    final unlocked = chapter.isUnlocked(progress);
    final onTap = tapSound(context, unlocked ? onOpen : null);
    final done = chapter.isDone(progress);
    final stars = chapter.stars(progress);
    final l = context.l10n;
    final title = chapterTitle(l, chapter);

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: [
        title,
        if (done) l.statusDone else if (!unlocked) l.statusLocked,
        l.starsOf(stars, chapter.maxStars),
      ].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: s.chapterCard,
          padding: EdgeInsetsDirectional.only(start: space.s8, end: space.s12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(context.koRadius.slot),
            border: Border.all(color: c.line, width: s.border),
          ),
          child: Row(
            children: [
              CustomPaint(
                size: Size.square(s.chapterIcon),
                painter: _ChapterIcon(chapter.number),
              ),
              SizedBox(width: space.s10),
              Expanded(
                child: _FitStart(
                  Text(
                    title,
                    maxLines: 1,
                    style: t.chipLabel.copyWith(color: c.ink),
                  ),
                ),
              ),
              if (done || !unlocked) ...[
                SizedBox(width: space.s10),
                _StatusBadge(done: done),
              ],
              SizedBox(width: space.s10),
              KoStar(size: s.iconChip, strokeWidth: MapArt.starStroke),
              SizedBox(width: space.s2),
              Text(
                '$stars/${chapter.maxStars}',
                maxLines: 1,
                style: t.numberChipSmall.copyWith(color: c.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "✓ Selesai" (desain 02) atau "🔒 Terkunci" (tidak ada di desain).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final (bg, fg) = done
        ? (c.success, c.onSuccess)
        : (c.nodeLocked, c.nodeLockedInk);
    return Container(
      height: s.badge,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KoIcon(
            done ? KoIcons.checkBold : KoIcons.lockBold,
            size: s.iconMicro,
            color: fg,
          ),
          SizedBox(width: space.s4),
          Text(
            done ? context.l10n.chapterDone : context.l10n.chapterLocked,
            maxLines: 1,
            style: context.koType.tag.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

/// "★ 5/30" di kanan judul.
class _StarChip extends StatelessWidget {
  const _StarChip({required this.stars, required this.maxStars});

  final int stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      label: context.l10n.starsOf(stars, maxStars),
      excludeSemantics: true,
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(start: space.s10, end: space.s14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoStar(size: s.icon),
            SizedBox(width: space.s6),
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
              maxLines: 1,
              style: context.koType.chip.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teks rata kiri yang mengecil kalau tidak muat.
class _FitStart extends StatelessWidget {
  const _FitStart(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: AlignmentDirectional.centerStart,
    child: child,
  );
}

class _ChapterIcon extends CustomPainter {
  _ChapterIcon(this.chapter);

  final int chapter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / MapArt.chapterIconViewBox);
    paintChapterIcon(canvas, chapter);
  }

  @override
  bool shouldRepaint(_ChapterIcon old) => old.chapter != chapter;
}

/// Latar judul: krem penuh, lalu memudar sampai bening setinggi
/// [MapArt.headerFade] di bawah (`linear-gradient(#FFF4E2 76%, transparan)`).
class _Fade extends CustomPainter {
  _Fade(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fadeTop = size.height - MapArt.headerFade;
    canvas
      ..drawRect(
        Rect.fromLTWH(0, 0, size.width, fadeTop),
        Paint()..color = color,
      )
      ..drawRect(
        Rect.fromLTWH(0, fadeTop, size.width, MapArt.headerFade),
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withValues(alpha: 0)],
              ).createShader(
                Rect.fromLTWH(0, fadeTop, size.width, MapArt.headerFade),
              ),
      );
  }

  @override
  bool shouldRepaint(_Fade old) => old.color != color;
}
