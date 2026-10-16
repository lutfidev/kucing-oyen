import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/gestures.dart' show Drag;

import 'components/board_component.dart';
import 'components/cat_component.dart';
import 'render/render.dart';
import 'sim/pos.dart';

/// Seretan yang dimulai di papan, sudah diterjemahkan ke petak. Diterapkan
/// oleh layar level, yang memutuskan lewat `LevelSession`.
abstract interface class BoardInput {
  /// Jari mulai menyeret di petak [tile], di posisi layar [global].
  /// Mengembalikan penerima sisa seretan itu (geseran, lepas, batal), atau
  /// null kalau tidak ada benda yang diangkat.
  Drag? pickUp(Pos tile, Offset global);
}

/// Papan level sebagai game Flame: [BoardComponent] (petak dan benda) dan
/// [CatComponent] (Oyen), keduanya menggambar lewat `lib/game/render/`.
///
/// Kamera beresolusi tetap 350×450 (koordinat papan desain) dengan (0, 0) di
/// pojok kiri atas papan, diskalakan seragam ke ukuran widget.
///
/// Game tidak menyimpan aturan: layar mengisi [scene] dari `LevelSession`,
/// dan seretan di papan diteruskan ke [input].
///
/// Mesin hanya jalan selama ada petak menyala yang berkedip dan [animate]
/// aktif. Selain itu tiap perubahan digambar satu bingkai lalu mesin
/// berhenti sendiri, jadi `pumpAndSettle` di test tidak macet.
class KucingGame extends FlameGame {
  KucingGame({required this._scene, this.input, this._animate = true})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: BoardScene.width,
          height: BoardScene.height,
        ),
      ) {
    camera.viewfinder.anchor = Anchor.topLeft;
    world.addAll([
      BoardComponent()..priority = 0,
      CatComponent()..priority = 1,
    ]);
  }

  /// Penerima seretan di papan; null = papan hanya untuk dilihat.
  BoardInput? input;

  BoardScene _scene;
  bool _animate;
  double _seconds = 0;

  /// Isi papan yang digambar.
  BoardScene get scene => _scene;
  set scene(BoardScene value) {
    if (identical(value, _scene)) return;
    _scene = value;
    _invalidate();
  }

  /// False = petak menyala diam, tidak berkedip (setelan "kurangi animasi").
  bool get animate => _animate;
  set animate(bool value) {
    if (value == _animate) return;
    _animate = value;
    _invalidate();
  }

  bool get _blinking => _animate && _scene.tiles.any((t) => t.glow);

  /// Opasitas kotak menyala di bingkai ini, lihat [tileGlowOpacity].
  double get glowOpacity => _blinking ? tileGlowOpacity(_seconds) : 1;

  /// Petak di titik [point] koordinat papan (0..350 × 0..450), atau null di
  /// luar papan.
  static Pos? tileAtPoint(Offset point) {
    final inside =
        point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx < BoardScene.width &&
        point.dy < BoardScene.height;
    if (!inside) return null;
    return Pos(point.dx ~/ Tile.size, point.dy ~/ Tile.size);
  }

  /// Petak di bawah posisi layar [global], atau null di luar papan atau
  /// sebelum game terpasang.
  Pos? tileAtGlobal(Offset global) {
    if (!isAttached) return null;
    final canvas = convertGlobalToLocalCoordinate(global.toVector2());
    return tileAtPoint(camera.globalToLocal(canvas).toOffset());
  }

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void update(double dt) {
    final blinking = _blinking;
    _seconds = blinking ? _seconds + dt : 0;
    super.update(dt);
    if (!blinking) pauseEngine();
  }

  /// Minta satu bingkai baru; [update] menghentikan mesin lagi kalau diam.
  void _invalidate() {
    if (paused) resumeEngine();
  }
}
