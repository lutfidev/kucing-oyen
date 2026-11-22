import 'package:flutter/material.dart';

import '../../game/render/render.dart';
import '../../theme/theme.dart';
import 'room_geometry.dart';

/// Tali gantungan teras (`AdeganTeras.dc.html`: `#B07A4F`, ujung bulat):
/// garis [ropes] di layar setebal [width].
class HangRopes extends StatelessWidget {
  const HangRopes({super.key, required this.ropes, required this.width});

  final List<(Offset, Offset)> ropes;
  final double width;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      painter: _RopePainter(ropes, width, context.koColors.wood),
    ),
  );
}

class _RopePainter extends CustomPainter {
  _RopePainter(this.ropes, this.width, this.color);

  final List<(Offset, Offset)> ropes;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in ropes) {
      canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(_RopePainter old) =>
      old.width != width || old.color != color || old.ropes != ropes;
}

/// Bayangan lembut di kaki kucing atau barang: elips [oval] (layar) dengan
/// [opacity] warna `roomShadow`.
class SceneShadow {
  const SceneShadow(this.oval, this.opacity);

  final Rect oval;
  final double opacity;

  /// Opasitas desain (`AdeganTengah.dc.html`).
  static const cat = 0.2;
  static const item = 0.18;
  static const lifted = 0.1;

  /// Bayangan kucing berkotak [box] (kaki [feet]): lebar 0,68 × kotak,
  /// diangkat 0,4 ×; tinggi 0,2 × lebarnya, 2 px desain di atas kaki.
  factory SceneShadow.ofCat(
    Rect box,
    double feet, {
    required double unit,
    bool lifted = false,
  }) => SceneShadow(
    _oval(box.center.dx, feet - 2 * unit, box.width * (lifted ? 0.2 : 0.34)),
    lifted ? SceneShadow.lifted : cat,
  );

  /// Bayangan barang lantai berkotak [box]: lebar 0,8 × gambar.
  factory SceneShadow.ofItem(Rect box, {required double unit}) => SceneShadow(
    _oval(box.center.dx, box.bottom - 2 * unit, box.width * 0.4),
    item,
  );

  static Rect _oval(double cx, double cy, double rw) =>
      Rect.fromCenter(center: Offset(cx, cy), width: rw * 2, height: rw * 0.4);
}

/// Satu ruangan rumah dari bawah ke atas (desain `kSkala`): latar dan
/// cahaya lantai, bayangan, [floor] (cincin pilih, panduan Hias), kucing
/// yang sedang lewat pintu ([passing], di belakang kusen), kusen pintu
/// depan, [sprites] (barang dan kucing urut kaki), lalu cahaya udara.
class RoomScene extends StatelessWidget {
  const RoomScene({
    super.key,
    required this.geo,
    required this.sprites,
    this.time,
    this.shadows = const [],
    this.floor = const [],
    this.passing = const [],
  });

  final RoomGeometry geo;

  /// Detik animasi lapisan (awan, daun, cahaya); null = diam.
  final double? time;
  final List<SceneShadow> shadows;
  final List<Widget> floor;
  final List<Widget> passing;
  final List<Widget> sprites;

  /// Blur bayangan (desain `filter: blur(1.5px)`), px desain.
  static const shadowBlur = 1.5;

  @override
  Widget build(BuildContext context) {
    Widget layers(List<HouseLayer> list) => Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(painter: _LayerPainter(geo, list, time)),
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        layers(const [HouseLayer.back, HouseLayer.floorLight]),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ShadowPainter(
                shadows,
                context.koColors.roomShadow,
                shadowBlur * geo.artScale,
              ),
            ),
          ),
        ),
        ...floor,
        ...passing,
        layers(const [HouseLayer.frame]),
        ...sprites,
        layers(const [HouseLayer.airLight]),
      ],
    );
  }
}

class _LayerPainter extends CustomPainter {
  _LayerPainter(this.geo, this.layers, this.time);

  final RoomGeometry geo;
  final List<HouseLayer> layers;
  final double? time;

  /// Lapisan diam (kusen) tidak ikut waktu, jadi tidak digambar ulang
  /// tiap bingkai.
  late final double? _time =
      layers.any((layer) => houseLayerAnimated(geo.which, layer)) ? time : null;

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      paintHouseLayer(canvas, geo.which, layer, size: size, time: _time);
    }
  }

  @override
  bool shouldRepaint(_LayerPainter old) =>
      old._time != _time ||
      old.geo.room != geo.room ||
      old.geo.which != geo.which;
}

class _ShadowPainter extends CustomPainter {
  _ShadowPainter(this.shadows, this.color, this.blur);

  final List<SceneShadow> shadows;
  final Color color;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    for (final shadow in shadows) {
      canvas.drawOval(
        shadow.oval,
        Paint()
          ..color = color.withValues(alpha: shadow.opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }
  }

  @override
  bool shouldRepaint(_ShadowPainter old) => true;
}
