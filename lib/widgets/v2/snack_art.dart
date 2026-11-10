import 'package:flutter/widgets.dart';

import '../../game/model/snacks.dart';
import '../../theme/ko_ui.dart';

/// Original v2 catalog illustrations; no text baked into the artwork.
class SnackArt extends StatelessWidget {
  const SnackArt({super.key, required this.id});
  final SnackId id;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(painter: _SnackArt(id)),
    ),
  );
}

class _SnackArt extends CustomPainter {
  const _SnackArt(this.id);
  final SnackId id;
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = KoUi.homeGold;
    final line = Paint()
      ..color = KoUi.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    void oval(Rect rect, Color color) {
      fill.color = color;
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, line);
    }

    void shape(Path path, Color color) {
      fill.color = color;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, line);
    }

    canvas.save();
    canvas.scale(size.width / 96, size.height / 96);
    canvas.drawOval(
      const Rect.fromLTWH(12, 76, 72, 10),
      Paint()..color = KoUi.homeShade,
    );
    switch (id) {
      case SnackId.ikanAsin:
        shape(
          Path()
            ..moveTo(65, 49)
            ..lineTo(84, 32)
            ..lineTo(84, 66)
            ..close(),
          KoUi.honey,
        );
        oval(const Rect.fromLTWH(10, 29, 58, 38), KoUi.water);
        canvas.drawCircle(const Offset(25, 44), 3, Paint()..color = KoUi.ink);
        canvas.drawArc(const Rect.fromLTWH(15, 32, 22, 31), -1, 2, false, line);
      case SnackId.susu:
        shape(
          Path()
            ..moveTo(26, 28)
            ..lineTo(37, 13)
            ..lineTo(64, 13)
            ..lineTo(74, 28)
            ..lineTo(74, 78)
            ..lineTo(26, 78)
            ..close(),
          KoUi.paper,
        );
        fill.color = KoUi.water;
        canvas.drawRect(const Rect.fromLTWH(27, 47, 46, 22), fill);
        canvas.drawLine(const Offset(26, 28), const Offset(74, 28), line);
        canvas.drawCircle(const Offset(50, 55), 8, Paint()..color = KoUi.paper);
      case SnackId.tuna:
        shape(
          Path()
            ..moveTo(15, 38)
            ..lineTo(15, 72)
            ..quadraticBezierTo(48, 90, 81, 72)
            ..lineTo(81, 38)
            ..close(),
          KoUi.water,
        );
        oval(const Rect.fromLTWH(15, 25, 66, 26), KoUi.paper);
        oval(const Rect.fromLTWH(39, 31, 18, 10), KoUi.honey);
        canvas.drawLine(const Offset(21, 63), const Offset(75, 63), line);
      case SnackId.biskuit:
        for (final p in [
          const Offset(34, 49),
          const Offset(61, 59),
          const Offset(54, 30),
        ]) {
          oval(Rect.fromCircle(center: p, radius: 20), KoUi.honey);
          for (final delta in [
            const Offset(-6, -5),
            const Offset(6, 1),
            const Offset(-2, 7),
          ]) {
            canvas.drawCircle(p + delta, 2.5, Paint()..color = KoUi.ink);
          }
        }
      case SnackId.puding:
        oval(const Rect.fromLTWH(10, 67, 76, 15), KoUi.paper);
        shape(
          Path()
            ..moveTo(30, 27)
            ..lineTo(19, 68)
            ..quadraticBezierTo(48, 81, 77, 68)
            ..lineTo(66, 27)
            ..close(),
          KoUi.peach,
        );
        oval(const Rect.fromLTWH(30, 19, 36, 18), KoUi.honey);
        canvas.drawCircle(
          const Offset(48, 19),
          7,
          Paint()..color = KoUi.danger,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SnackArt old) => old.id != id;
}
