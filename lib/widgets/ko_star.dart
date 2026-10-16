import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/theme.dart';

/// Satu bintang (viewBox 24): kuning kalau [filled], krem pudar kalau belum
/// didapat.
class KoStar extends StatelessWidget {
  const KoStar({super.key, this.filled = true, this.size});

  final bool filled;

  /// Default [KoSize.star].
  final double? size;

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
  _StarPainter({required this.fill, required this.edge});

  static final _path = parseSvgPathData(
    'M12 2.5l2.9 5.9 6.5.9-4.7 4.6 1.1 6.5L12 17.3l-5.8 3.1 1.1-6.5L2.6 9.3l6.5-.9z',
  );
  static const _viewBox = 24.0;
  static const _strokeWidth = 1.4;

  final Color fill;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);
    canvas.drawPath(_path, Paint()..color = fill);
    canvas.drawPath(
      _path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill || old.edge != edge;
}
