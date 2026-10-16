import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/theme.dart';

/// Satu bintang (viewBox 24): kuning kalau [filled], krem pudar kalau belum
/// didapat.
class KoStar extends StatelessWidget {
  const KoStar({
    super.key,
    this.filled = true,
    this.size,
    this.strokeWidth = defaultStrokeWidth,
    this.shine = false,
  });

  final bool filled;

  /// Default [KoSize.star].
  final double? size;

  /// Tebal garis tepi di viewBox 24.
  final double strokeWidth;

  /// Kilau kecil di kiri atas bintang kuning (bintang besar layar Berhasil).
  final bool shine;

  /// Garis tepi bintang di lembar token.
  static const double defaultStrokeWidth = 1.4;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final side = size ?? context.koSize.star;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(side),
        painter: _StarPainter(
          fill: filled ? c.star : c.starEmpty,
          edge: filled ? c.starEdge : c.muted,
          strokeWidth: strokeWidth,
          shine: filled && shine ? c.starShine : null,
        ),
      ),
    );
  }
}

/// Deret bintang: [earned] kuning dari kiri, sisanya pudar.
class KoStars extends StatelessWidget {
  const KoStars({super.key, required this.earned, this.total = 3, this.size});

  final int earned;
  final int total;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final gap = context.koSpace.s2;
    return Semantics(
      label: '$earned dari $total bintang',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) SizedBox(width: gap),
            KoStar(filled: i < earned, size: size),
          ],
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.fill,
    required this.edge,
    required this.strokeWidth,
    required this.shine,
  });

  static final _path = parseSvgPathData(
    'M12 2.5l2.9 5.9 6.5.9-4.7 4.6 1.1 6.5L12 17.3l-5.8 3.1 1.1-6.5L2.6 9.3l6.5-.9z',
  );
  static final _shinePath = parseSvgPathData('M9 9.5l2-.4');
  static const _viewBox = 24.0;
  static const _shineWidth = 1.2;

  final Color fill;
  final Color edge;
  final double strokeWidth;
  final Color? shine;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);
    canvas.drawPath(_path, Paint()..color = fill);
    canvas.drawPath(
      _path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
    final shine = this.shine;
    if (shine != null) {
      canvas.drawPath(
        _shinePath,
        Paint()
          ..color = shine
          ..style = PaintingStyle.stroke
          ..strokeWidth = _shineWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.fill != fill ||
      old.edge != edge ||
      old.strokeWidth != strokeWidth ||
      old.shine != shine;
}
