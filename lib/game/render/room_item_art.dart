import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../model/home_items.dart';
import '../model/snacks.dart';
import 'css_animation.dart';
import 'design_svg_home.dart';
import 'kitty.dart';
import 'kitty_painter.dart';
import 'svg_template.dart';

final _keyframes = CssKeyframes.parse(roomItemKeyframes);
final _back = <String, SvgTemplate>{
  for (final MapEntry(:key, :value) in roomItemBackSvgs.entries)
    key: SvgTemplate(value, keyframes: _keyframes),
};
final _front = <String, SvgTemplate>{
  for (final MapEntry(:key, :value) in roomItemFrontSvgs.entries)
    key: SvgTemplate(value, keyframes: _keyframes),
};
final _cache = <(String, bool), (SvgDrawing?, SvgDrawing?)>{};

/// Barang yang sedang dipakai kucing (`Barang.dc.html` dengan `dipakai`):
/// kotaknya membesar ke [size], gambar barang bergeser [artOffset] di
/// dalamnya, dan kucing seukuran [catSize] digambar di [catOffset] dalam
/// pose [pose], di antara lapisan belakang dan depan barang.
class ItemInUse {
  const ItemInUse(
    this.size,
    this.artOffset,
    this.catOffset,
    this.catSize,
    this.pose,
  );

  final Size size;
  final Offset artOffset;
  final Offset catOffset;
  final double catSize;
  final KittyPose pose;
}

/// Tabel `D` (ukuran dipakai), `offs`, dan `cats` di `Barang.dc.html`.
const _inUse = <RoomItemId, ItemInUse>{
  RoomItemId.kardus: ItemInUse(
    Size(122, 124),
    Offset(0, 42),
    Offset(11, 0),
    100,
    KittyPose.idle,
  ),
  RoomItemId.bola: ItemInUse(
    Size(110, 100),
    Offset.zero,
    Offset.zero,
    100,
    KittyPose.play,
  ),
  RoomItemId.tikus: ItemInUse(
    Size(110, 100),
    Offset.zero,
    Offset.zero,
    100,
    KittyPose.play,
  ),
  RoomItemId.karpet: ItemInUse(
    Size(184, 100),
    Offset(0, 40),
    Offset(42, 2),
    100,
    KittyPose.sleep,
  ),
  RoomItemId.kasur: ItemInUse(
    Size(150, 112),
    Offset(0, 36),
    Offset(26, 6),
    96,
    KittyPose.sleep,
  ),
  RoomItemId.catnip: ItemInUse(
    Size(130, 100),
    Offset(78, 26),
    Offset.zero,
    100,
    KittyPose.happy,
  ),
  RoomItemId.tiang: ItemInUse(
    Size(130, 152),
    Offset(58, 0),
    Offset(0, 52),
    100,
    KittyPose.scratch,
  ),
  RoomItemId.akuarium: ItemInUse(
    Size(152, 104),
    Offset(60, 14),
    Offset(0, 4),
    100,
    KittyPose.scratch,
  ),
  RoomItemId.rumah: ItemInUse(
    Size(122, 132),
    Offset.zero,
    Offset(34, 76),
    54,
    KittyPose.idle,
  ),
  RoomItemId.lukisan: ItemInUse(
    Size(110, 160),
    Offset(36, 0),
    Offset(0, 66),
    92,
    KittyPose.happy,
  ),
  RoomItemId.jam: ItemInUse(
    Size(128, 168),
    Offset(52, 0),
    Offset(0, 46),
    100,
    KittyPose.scratch,
  ),
  RoomItemId.rak: ItemInUse(
    Size(104, 104),
    Offset(0, 70),
    Offset(4, 0),
    80,
    KittyPose.idle,
  ),
  RoomItemId.mangkuk: ItemInUse(
    Size(100, 100),
    Offset.zero,
    Offset.zero,
    100,
    KittyPose.eat,
  ),
  RoomItemId.terowongan: ItemInUse(
    Size(166, 80),
    Offset(14, 16),
    Offset(-2, 0),
    70,
    KittyPose.rebah,
  ),
  RoomItemId.pancingan: ItemInUse(
    Size(140, 110),
    Offset(30, 40),
    Offset(0, 6),
    100,
    KittyPose.play,
  ),
  RoomItemId.bantalIkan: ItemInUse(
    Size(130, 96),
    Offset(0, 40),
    Offset(14, 0),
    96,
    KittyPose.sleep,
  ),
  RoomItemId.sofaMini: ItemInUse(
    Size(140, 123),
    Offset(0, 37),
    Offset(20, 0),
    92,
    KittyPose.rebah,
  ),
  RoomItemId.monstera: ItemInUse(
    Size(120, 110),
    Offset(50, 0),
    Offset(6, 26),
    84,
    KittyPose.idle,
  ),
  RoomItemId.jendelaBurung: ItemInUse(
    Size(110, 104),
    Offset(10, 0),
    Offset(0, 30),
    66,
    KittyPose.play,
  ),
  RoomItemId.lampuBulan: ItemInUse(
    Size(100, 130),
    Offset(20, 0),
    Offset(6, 52),
    80,
    KittyPose.sleep,
  ),
  RoomItemId.hammock: ItemInUse(
    Size(120, 82),
    Offset(0, 12),
    Offset(22, 0),
    76,
    KittyPose.sleep,
  ),
};

/// Barang yang gambarnya sendiri disembunyikan saat dipakai (sprite kucing
/// yang menggambar bola, tikus, atau mangkuknya).
const _hidesSelf = {RoomItemId.bola, RoomItemId.tikus, RoomItemId.mangkuk};

/// Barang yang tiangnya sudah digambar sendiri, jadi kucing menggaruk tanpa
/// tiang (`tiangOn` desain).
const _ownPost = {RoomItemId.tiang, RoomItemId.akuarium, RoomItemId.jam};

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

  static ItemInUse inUse(RoomItemId id) => _inUse[id]!;

  /// Kotak barang [id] saat dipakai, kalau kotak diamnya [box]: pojok
  /// gambar barang tetap di tempatnya, kotaknya melebar untuk kucingnya.
  static Rect inUseBox(RoomItemId id, Rect box) {
    final use = inUse(id);
    final k = box.width / sizeOf(id).width;
    return (box.topLeft - use.artOffset * k) & use.size * k;
  }
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

/// Lapisan gambar [code]: belakang lalu depan (yang menutupi kucing yang
/// memakainya). Gambar diam disimpan di cache.
(SvgDrawing?, SvgDrawing?) _layers(String code, bool full, double? time) {
  (SvgDrawing?, SvgDrawing?) render() {
    final vals = <String, Object>{'penuh': full, 'kosong': !full};
    return (
      _back[code]?.render(vals, time: time),
      _front[code]?.render(vals, time: time),
    );
  }

  return time == null ? _cache.putIfAbsent((code, full), render) : render();
}

Float64List _matrix(CssMatrix m) => Float64List.fromList([
  m.$1, m.$2, 0, 0, //
  m.$3, m.$4, 0, 0,
  0, 0, 1, 0,
  m.$5, m.$6, 0, 1,
]);

/// Gaya CSS [style] yang dievaluasi di detik [time] ke [canvas].
void _animate(Canvas canvas, String style, double time) {
  final css = CssStyle.parse(style);
  final frame = css.frameAt(time, _keyframes);
  if (frame != null) {
    canvas.transform(_matrix(frame.matrix(css.originX, css.originY)));
  }
}

void _paintLayers(Canvas canvas, String code, bool full, double? time) {
  final (x, y, _, _) = _viewBox(code);
  canvas.save();
  canvas.translate(-x, -y);
  final (back, front) = _layers(code, full, time);
  back?.paint(canvas);
  front?.paint(canvas);
  canvas.restore();
}

void _paint(Canvas canvas, String code, Size? box, bool full, double? time) {
  final art = _sizeOf(code);
  canvas.save();
  if (box != null) _fit(canvas, art, box);
  _paintLayers(canvas, code, full, time);
  canvas.restore();
}

void _fit(Canvas canvas, Size art, Size box) {
  final scale = RoomItemArt.fitScale(art, box);
  canvas.translate(
    (box.width - art.width * scale) / 2,
    (box.height - art.height * scale) / 2,
  );
  canvas.scale(scale);
}

/// Menggambar barang kamar [id] di pojok kiri atas kanvas. Dengan [box]
/// gambarnya diskalakan supaya muat dan dipusatkan di kotak itu. [full] =
/// isi mangkuk. [time] = detik animasi barang (null = diam). Dengan [user]
/// barangnya digambar sedang dipakai kucing itu (pose, mainan, dan tiang
/// mengikuti barangnya; kotaknya [RoomItemArt.inUseBox]).
void paintRoomItemArt(
  Canvas canvas,
  RoomItemId id, {
  Size? box,
  bool full = true,
  double? time,
  KittyLook? user,
}) {
  final code = id.name;
  final hammock = id == RoomItemId.hammock && time != null;
  if (user == null && !hammock) return _paint(canvas, code, box, full, time);
  final use = user == null ? null : RoomItemArt.inUse(id);
  final art = use?.size ?? _sizeOf(code);
  canvas.save();
  if (box != null) _fit(canvas, art, box);
  if (hammock) {
    _animate(
      canvas,
      'transform-origin: ${art.width / 2}px 0px; '
      'animation: brgHam 3.2s ease-in-out infinite',
      time,
    );
  }
  if (use == null) {
    _paintLayers(canvas, code, full, time);
    canvas.restore();
    return;
  }
  final (back, front) = _hidesSelf.contains(id)
      ? (null, null)
      : _layers(code, full, time);
  void paintLayer(SvgDrawing? layer) {
    if (layer == null) return;
    final (x, y, _, _) = _viewBox(code);
    canvas.save();
    canvas.translate(use.artOffset.dx, use.artOffset.dy);
    if (id == RoomItemId.lukisan) {
      // Lukisan miring saat diketuk kucing (`ip` desain).
      canvas.translate(36, 2);
      canvas.rotate(-9 * math.pi / 180);
      canvas.translate(-36, -2);
    }
    canvas.translate(-x, -y);
    layer.paint(canvas);
    canvas.restore();
  }

  paintLayer(back);
  canvas.save();
  canvas.translate(use.catOffset.dx, use.catOffset.dy);
  paintKitty(
    canvas,
    user!.copyWith(
      pose: use.pose,
      facing: KittyFacing.down,
      toy: switch (id) {
        RoomItemId.bola => KittyToy.ball,
        RoomItemId.tikus => KittyToy.mouse,
        _ => KittyToy.none,
      },
      post: !_ownPost.contains(id),
    ),
    size: use.catSize,
  );
  canvas.restore();
  paintLayer(front);
  canvas.restore();
}

/// Menggambar camilan [id], seperti [paintRoomItemArt].
void paintSnackArt(Canvas canvas, SnackId id, {Size? box, double? time}) =>
    _paint(canvas, id.name, box, true, time);
