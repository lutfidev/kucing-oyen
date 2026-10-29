import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Reaksi kucing sesudah aksi di kartu: angka yang melayang ([text], null
/// = tanpa angka, mis. elusan yang sudah kena batas) dan hati ([hearts]).
class RoomReaction {
  const RoomReaction({this.text, this.hearts = true});

  final String? text;
  final bool hearts;
}

/// Kurva `@keyframes` desain sebagai fungsi waktu 0–1.
double _between(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);

/// Angka dan hati yang melayang dari atas kucing di [anchor] (`kmFloat`
/// 1,6 detik, `kmHeart` 1,4 detik), sekali jalan lalu [onDone]. Dengan
/// kurangi gerak, reaksinya tampil diam selama waktu yang sama.
class ReactionOverlay extends StatefulWidget {
  const ReactionOverlay({
    super.key,
    required this.reaction,
    required this.anchor,
    required this.onDone,
  });

  static const duration = Duration(milliseconds: 1600);

  final RoomReaction reaction;
  final Rect anchor;
  final VoidCallback onDone;

  @override
  State<ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<ReactionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
    vsync: this,
    duration: ReactionOverlay.duration,
  )..forward().whenComplete(() => mounted ? widget.onDone() : null);

  // Hati: ukuran, posisi (kiri/atas di kotak 120×60, kiri null = tengah),
  // jeda mulai, dan warnanya (oranye untuk yang ketiga).
  static const _heartLife = 1400 / 1600;

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final still = MediaQuery.disableAnimationsOf(context);
    final width = s.roomReactionWidth;
    final height = s.roomReactionHeight;
    final text = widget.reaction.text;
    return Positioned(
      left: widget.anchor.center.dx - width / 2,
      top: widget.anchor.top - height / 2 - context.koSpace.s4,
      width: width,
      height: height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _time,
          builder: (context, _) {
            final t = _time.value;
            Widget heart(double size, double delay, Color color) {
              final h = still ? 0.5 : _between(t, delay, delay + _heartLife);
              final opacity = still
                  ? 1.0
                  : (h < 0.25 ? h / 0.25 : 1 - (h - 0.25) / 0.75);
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, still ? 0 : 4 - 34 * h),
                  child: Transform.scale(
                    scale: still ? 1 : 0.6 + 0.4 * h,
                    child: KoIcon(KoIcons.heartFill, size: size, color: color),
                  ),
                ),
              );
            }

            // kmFloat: muncul di 15%, mulai pudar di 80%.
            final f = t;
            final textOpacity = still
                ? 1.0
                : f < 0.15
                ? f / 0.15
                : f < 0.8
                ? 1.0
                : 1 - (f - 0.8) / 0.2;
            final rise = still
                ? 0.0
                : f < 0.15
                ? 6 * (1 - f / 0.15)
                : -s.roomReactionRise * (f - 0.15) / 0.85;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.reaction.hearts)
                  Positioned.fill(
                    key: const ValueKey('reaction-hearts'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: width * 0.12,
                          top: height * 0.13,
                          child: heart(s.iconCompact, 0, c.heart),
                        ),
                        Positioned(
                          right: width * 0.13,
                          top: height * 0.03,
                          child: heart(s.iconTiny, 200 / 1600, c.heart),
                        ),
                        Positioned(
                          left: width / 2,
                          top: -height * 0.1,
                          child: heart(s.iconMicro, 350 / 1600, c.orange),
                        ),
                      ],
                    ),
                  ),
                if (text != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: height * 0.3,
                    child: Opacity(
                      opacity: textOpacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, rise),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: context.koType.reaction.copyWith(
                            color: c.orangeDeep,
                            shadows: [
                              Shadow(
                                color: c.surface,
                                offset: Offset(0, s.border),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Pujian sesudah menghias (`kmToast` 2,4 detik), sekali jalan lalu
/// [onDone]. Diumumkan pembaca layar. Kilau yang berkedip terus di desain
/// tidak dipakai (animasi tak berujung).
class PraiseToast extends StatefulWidget {
  const PraiseToast({
    super.key,
    required this.title,
    this.subtitle,
    required this.onDone,
  });

  static const duration = Duration(milliseconds: 2400);

  final String title;

  /// Bonus Senang; null kalau bonus sejam ini sudah diberikan.
  final String? subtitle;
  final VoidCallback onDone;

  @override
  State<PraiseToast> createState() => _PraiseToastState();
}

class _PraiseToastState extends State<PraiseToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
    vsync: this,
    duration: PraiseToast.duration,
  )..forward().whenComplete(() => mounted ? widget.onDone() : null);

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final still = MediaQuery.disableAnimationsOf(context);
    final card = Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: space.s16,
          vertical: space.s14,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.tray),
          border: Border.all(color: c.success, width: s.artBorder),
          boxShadow: [
            ...KoShadow.solid(c.successDeep, context.koShadow.pressHero - 2),
            ...context.koShadow.dialog,
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: t.numberCompact.copyWith(color: c.successDeep),
            ),
            if (widget.subtitle case final subtitle?)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: t.labelSmall.copyWith(color: c.inkSoft),
              ),
          ],
        ),
      ),
    );
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _time,
        child: card,
        builder: (context, child) {
          if (still) return child!;
          final v = _time.value;
          final enter = _between(v, 0, 0.12);
          final opacity = v < 0.12
              ? enter
              : v < 0.85
              ? 1.0
              : 1 - _between(v, 0.85, 1);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, -16 * (1 - enter)),
              child: Transform.scale(scale: 0.9 + 0.1 * enter, child: child),
            ),
          );
        },
      ),
    );
  }
}
