import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart' show Drag;

import '../kucing_game.dart';
import '../render/render.dart';

/// Petak dan benda papan 350×450 (`paintBoardTiles`), dipotong sudut papan.
///
/// Seretan di papan diterjemahkan ke petak lalu diteruskan ke
/// [KucingGame.input]; komponen ini tidak tahu benda mana yang boleh
/// diangkat atau ke mana boleh ditaruh.
class BoardComponent extends PositionComponent
    with HasGameReference<KucingGame>, DragCallbacks {
  BoardComponent() : super(size: Vector2(BoardScene.width, BoardScene.height));

  /// Jari yang sedang menyeret benda dari papan dan penerima seretannya.
  int? _pointer;
  Drag? _drag;

  @override
  void render(Canvas canvas) {
    canvas
      ..save()
      ..clipRRect(BoardArt.rrect);
    paintBoardTiles(canvas, game.scene, glowOpacity: game.glowOpacity);
    canvas.restore();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final input = game.input;
    final tile = KucingGame.tileAtPoint(event.localPosition.toOffset());
    if (_drag != null || input == null || tile == null) return;
    final drag = input.pickUp(tile, event.devicePosition.toOffset());
    if (drag == null) return;
    _drag = drag;
    _pointer = event.pointerId;
  }

  /// Penerima melacak jari dengan menjumlah geseran: posisi di event pertama
  /// setelah seretan diterima masih posisi awal sentuhan.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (event.pointerId == _pointer) _drag?.update(event.raw);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.pointerId != _pointer) return;
    final drag = _drag;
    _release();
    drag?.end(event.raw);
  }

  /// Batal dulu: bawaan mixin meneruskan batal sebagai [onDragEnd], yang
  /// akan menaruh benda.
  @override
  void onDragCancel(DragCancelEvent event) {
    if (event.pointerId == _pointer) {
      final drag = _drag;
      _release();
      drag?.cancel();
    }
    super.onDragCancel(event);
  }

  void _release() {
    _pointer = null;
    _drag = null;
  }
}
