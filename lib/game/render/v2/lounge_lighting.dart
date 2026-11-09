import 'dart:ui';

/// Directional light and restrained material grain in the 390-unit room.
/// Painted behind decor/actors so blue glass, foliage and fur keep their color.
void paintLoungeLighting(Canvas canvas) {
  const wall = Rect.fromLTWH(0, 0, 390, 257);
  final plaster = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(wall)
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(130, 48, 130, 140),
        const Radius.circular(3),
      ),
    );
  canvas.save();
  canvas.clipPath(plaster);
  canvas.drawRect(
    wall,
    Paint()
      ..shader = Gradient.radial(
        const Offset(150, 84),
        275,
        [
          const Color(0x22FFFBEE),
          const Color(0x00FFFBEE),
          const Color(0x2384583E),
        ],
        [0, .5, 1],
      ),
  );
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 390, 18),
    Paint()
      ..shader = Gradient.linear(const Offset(0, 0), const Offset(0, 18), [
        const Color(0x187A4A2B),
        const Color(0x007A4A2B),
      ]),
  );
  final plasterGrain = Paint()..color = const Color(0x11875D38);
  for (var i = 0; i < 180; i++) {
    final x = (i * 97.123 + 7) % 390;
    final y = (i * 47.791 + 13) % 257;
    canvas.drawCircle(Offset(x, y), i.isEven ? .45 : .7, plasterGrain);
  }
  canvas.restore();

  const floor = Rect.fromLTWH(0, 253, 390, 137);
  canvas.save();
  canvas.clipRect(floor);
  canvas.drawRect(
    floor,
    Paint()
      ..shader = Gradient.linear(
        const Offset(0, 257),
        const Offset(0, 390),
        [
          const Color(0x24854B2F),
          const Color(0x00854B2F),
          const Color(0x16854B2F),
        ],
        [0, .22, 1],
      ),
  );
  final sun = Path()
    ..moveTo(134, 254)
    ..lineTo(257, 254)
    ..lineTo(335, 390)
    ..lineTo(71, 390)
    ..close();
  canvas.drawPath(
    sun,
    Paint()
      ..shader = Gradient.linear(
        const Offset(190, 255),
        const Offset(220, 390),
        [const Color(0x50FFF6DC), const Color(0x0CFFF6DC)],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
  );
  final mullion = Path()
    ..moveTo(191, 254)
    ..lineTo(197, 254)
    ..lineTo(217, 390)
    ..lineTo(204, 390)
    ..close();
  canvas.drawPath(
    mullion,
    Paint()
      ..color = const Color(0x128F6747)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
  );
  final grain = Paint()
    ..color = const Color(0x239A633B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = .7
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 24; i++) {
    final x = (i * 67.31) % 390;
    final y = 263 + (i * 19.37) % 123;
    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..cubicTo(x + 4, y - 1.5, x + 12, y + 1.5, x + 19, y),
      grain,
    );
  }
  canvas.restore();

  // Contact shadows establish the cabinet, window sill and doorway as depth
  // planes. Their illustrations are painted over these soft silhouettes.
  final shade = Paint()
    ..color = const Color(0x2E75492E)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  canvas.drawOval(const Rect.fromLTWH(15, 250, 98, 11), shade);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(122, 197, 154, 5),
      const Radius.circular(3),
    ),
    shade,
  );
  canvas.drawOval(const Rect.fromLTWH(304, 249, 80, 10), shade);
}
