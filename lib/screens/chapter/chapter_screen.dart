import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/chapter.dart';
import '../../game/model/progress.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'chapter_header.dart';
import 'chapter_map.dart';

/// Rute `/babak/:chapter`: peta babak dari [ProgressScope].
class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key, required this.chapter});

  /// Nomor babak; null kalau path-nya bukan angka.
  final int? chapter;

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    final number = chapter;
    final current = number == null ? null : controller.chapter(number);
    void home() => context.go(AppRoutes.home);
    if (current == null) return _NotFound(onBack: home);

    final chapters = controller.chapters;
    final i = chapters.indexOf(current);
    final other = i > 0
        ? chapters[i - 1]
        : (i + 1 < chapters.length ? chapters[i + 1] : null);
    return ChapterView(
      key: ValueKey(current.number),
      chapter: current,
      other: other,
      progress: controller.progress,
      onBack: home,
      onOpen: (chapter) => context.go(AppRoutes.chapter(chapter.number)),
      onPlay: (level) =>
          context.go(AppRoutes.level(level.id, chapter: level.chapter)),
    );
  }
}

/// Peta babak (desain 02): judul tetap di atas, peta di bawahnya bisa
/// digulir kalau layarnya pendek. Peta selebar layar dengan skala lebar
/// layar ÷ 390, dan dibuka dengan level saat ini di tengah.
class ChapterView extends StatefulWidget {
  const ChapterView({
    super.key,
    required this.chapter,
    required this.other,
    required this.progress,
    required this.onBack,
    required this.onOpen,
    required this.onPlay,
  });

  final Chapter chapter;
  final Chapter? other;
  final Progress progress;
  final VoidCallback onBack;
  final ValueChanged<Chapter> onOpen;
  final ValueChanged<Level> onPlay;

  @override
  State<ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  /// Gulir awal: level saat ini di tengah tempat peta.
  double _initialOffset(double scale, double viewport) {
    final levels = widget.chapter.levels;
    final id = widget.progress.current(widget.chapter.ids);
    if (id == null) return 0;
    final index = levels.indexWhere((level) => level.id == id);
    final y = ChapterMap.pointOf(index).dy * scale;
    final max = ChapterMap.size.height * scale - viewport;
    return (y - viewport / 2).clamp(0, math.max(0, max)).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    return Scaffold(
      backgroundColor: c.mapFloor,
      body: CustomMultiChildLayout(
        delegate: _HeaderOverMap(),
        children: [
          LayoutId(id: _Slot.map, child: _map(context)),
          LayoutId(
            id: _Slot.header,
            child: ChapterHeader(
              chapter: widget.chapter,
              other: widget.other,
              progress: widget.progress,
              onBack: widget.onBack,
              onOpen: widget.onOpen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _map(BuildContext context) {
    final c = context.koColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final viewport = constraints.maxHeight;
        final scale = width / ChapterMap.size.width;
        final height = ChapterMap.size.height * scale;
        _scroll ??= ScrollController(
          initialScrollOffset: _initialOffset(scale, viewport),
        );
        return SingleChildScrollView(
          controller: _scroll,
          child: CustomPaint(
            painter: _Floor(c.plank, c.plankJoint, scale),
            child: SizedBox(
              width: width,
              height: math.max(height, viewport),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: FittedBox(
                    child: ChapterMap(
                      chapter: widget.chapter,
                      progress: widget.progress,
                      onPlay: widget.onPlay,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _Slot { header, map }

/// Judul di atas; peta mulai dari awal pudar judul ([MapArt.headerFade]
/// dari bawah judul) sampai bawah layar, digambar di bawah judul.
class _HeaderOverMap extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final header = layoutChild(
      _Slot.header,
      BoxConstraints(maxWidth: size.width, maxHeight: size.height),
    );
    positionChild(_Slot.header, Offset.zero);
    final top = math.max(0.0, header.height - MapArt.headerFade);
    layoutChild(
      _Slot.map,
      BoxConstraints.tightFor(
        width: size.width,
        height: math.max(0.0, size.height - top),
      ),
    );
    positionChild(_Slot.map, Offset(0, top));
  }

  @override
  bool shouldRelayout(_HeaderOverMap old) => false;
}

/// Lantai kayu: garis antarpapan tiap 48 px dan sambungan papan tiap
/// 142 px (`repeating-linear-gradient` desain 02), di koordinat layar
/// desain dikali [scale]. Peta mulai di y [MapArt.mapTop] layar desain.
class _Floor extends CustomPainter {
  _Floor(this.plank, this.joint, this.scale);

  final Color plank;
  final Color joint;
  final double scale;

  static const double _row = 48;
  static const double _column = 142;
  static const double _line = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = Paint()..color = plank;
    final first = ((MapArt.mapTop - _row) / _row).floor();
    for (var k = first; ; k++) {
      final top = (k * _row + _row - _line - MapArt.mapTop) * scale;
      if (top > size.height) break;
      canvas.drawRect(Rect.fromLTWH(0, top, size.width, _line * scale), rows);
    }
    final columns = Paint()..color = joint;
    for (var k = 0; ; k++) {
      final left = (k * _column + _column - _line) * scale;
      if (left > size.width) break;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, _line * scale, size.height),
        columns,
      );
    }
  }

  @override
  bool shouldRepaint(_Floor old) =>
      old.plank != plank || old.joint != joint || old.scale != scale;
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KoIconButton(
                icon: KoIcons.back,
                semanticLabel: context.l10n.backToHome,
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.chapterMissing,
                    textAlign: TextAlign.center,
                    style: context.koType.body.copyWith(
                      color: context.koColors.inkSoft,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
