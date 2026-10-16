import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/theme.dart';

/// Garis putus-putus di sekeliling [child] (CSS `border: 2px dashed`).
/// Flutter tidak punya border putus-putus, jadi digambar sendiri; [child]
/// diberi jarak setebal garis seperti border biasa.
class KoDashedBorder extends StatelessWidget {
  const KoDashedBorder({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: color,
        width: s.border,
        radius: radius,
        dash: s.dash,
        gap: s.dashGap,
      ),
      child: Padding(padding: EdgeInsets.all(s.border), child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.width,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double width;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    // Garis di tengah tebal border, seperti border CSS.
    final rect = (Offset.zero & size).deflate(width / 2);
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius - width / 2)),
      );
    canvas.drawPath(
      dashPath(outline, dashArray: CircularIntervalList([dash, gap])),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.width != width ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap;
}
