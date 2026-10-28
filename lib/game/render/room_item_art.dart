import 'dart:math' as math;
import 'dart:ui';

import '../model/home_items.dart';
import '../model/snacks.dart';
import 'design_svg_home.dart';
import 'svg_template.dart';

final _back = <String, SvgTemplate>{
  for (final MapEntry(:key, :value) in roomItemBackSvgs.entries)
    key: SvgTemplate(value),
};
final _front = <String, SvgTemplate>{
  for (final MapEntry(:key, :value) in roomItemFrontSvgs.entries)
    key: SvgTemplate(value),
};
final _cache = <(String, bool), List<SvgDrawing>>{};

/// Ukuran dan skala gambar barang dan camilan (`Barang.dc.html`).
abstract final class RoomItemArt {
  /// Batas perbesaran gambar kecil di kotak besar (desain: 2,2).
  static const maxScale = 2.2;

  static Size sizeOf(RoomItemId id) => _sizeOf(id.name);

  static Size snackSizeOf(SnackId id) => _sizeOf(id.name);

  /// Skala gambar [art] supaya muat di [box], paling besar [maxScale].
  static double fitScale(Size art, Size box) => math.min(
    math.min(box.width / art.width, box.height / art.height),
    maxScale,
  );
}

(double, double, double, double) _viewBox(String code) {
  final box = roomItemViewBoxes[code];
  if (box == null) throw ArgumentError('Gambar $code tidak ada di desain');
  return box;
}

Size _sizeOf(String code) {
  final (_, _, width, height) = _viewBox(code);
  return Size(width, height);
}

/// Lapisan gambar [code]: belakang lalu depan (yang menutupi kucing di
/// kamar; keduanya digambar saat barangnya tidak dipakai).
List<SvgDrawing> _layers(String code, bool full) =>
    _cache.putIfAbsent((code, full), () {
      final vals = <String, Object>{'penuh': full, 'kosong': !full};
      return [
        for (final template in [_back[code], _front[code]])
          if (template != null) template.render(vals),
      ];
    });

void _paint(Canvas canvas, String code, Size? box, bool full) {
  final (x, y, width, height) = _viewBox(code);
  final art = Size(width, height);
  canvas.save();
  if (box != null) {
    final scale = RoomItemArt.fitScale(art, box);
    canvas.translate(
      (box.width - art.width * scale) / 2,
      (box.height - art.height * scale) / 2,
    );
    canvas.scale(scale);
  }
  canvas.translate(-x, -y);
  for (final layer in _layers(code, full)) {
    layer.paint(canvas);
  }
  canvas.restore();
}

/// Menggambar barang kamar [id] di pojok kiri atas kanvas. Dengan [box]
/// gambarnya diskalakan supaya muat dan dipusatkan di kotak itu. [full] =
/// isi mangkuk.
void paintRoomItemArt(
  Canvas canvas,
  RoomItemId id, {
  Size? box,
  bool full = true,
}) => _paint(canvas, id.name, box, full);

/// Menggambar camilan [id], seperti [paintRoomItemArt].
void paintSnackArt(Canvas canvas, SnackId id, {Size? box}) =>
    _paint(canvas, id.name, box, true);
