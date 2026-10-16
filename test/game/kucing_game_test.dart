import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  group('tileAtPoint: koordinat papan 350×450 → petak', () {
    test('pojok dan tepi petak', () {
      expect(KucingGame.tileAtPoint(Offset.zero), const Pos(0, 0));
      expect(KucingGame.tileAtPoint(const Offset(49.9, 49.9)), const Pos(0, 0));
      expect(KucingGame.tileAtPoint(const Offset(50, 50)), const Pos(1, 1));
      expect(KucingGame.tileAtPoint(const Offset(175, 175)), const Pos(3, 3));
      expect(
        KucingGame.tileAtPoint(const Offset(349.9, 449.9)),
        const Pos(6, 8),
      );
    });

    test('di luar papan atau NaN: null', () {
      for (final p in const [
        Offset(-0.1, 10),
        Offset(10, -0.1),
        Offset(BoardScene.width, 10),
        Offset(10, BoardScene.height),
        Offset(double.nan, 10),
      ]) {
        expect(KucingGame.tileAtPoint(p), isNull, reason: '$p');
      }
    });
  });

  test('sebelum terpasang ke widget, tidak ada petak di bawah jari', () {
    final game = KucingGame(scene: BoardScene.fromMap(BoardScene.designMap));
    expect(game.tileAtGlobal(const Offset(100, 100)), isNull);
  });

  test('petak menyala berkedip hanya kalau animasi aktif', () {
    final game = KucingGame(
      scene: BoardScene.fromMap(BoardScene.designMap, glow: {const Pos(3, 3)}),
    )..update(0.25);
    expect(game.glowOpacity, tileGlowOpacity(0.25));
    expect(game.paused, isFalse);

    game.animate = false;
    game.update(0.25);
    expect(game.glowOpacity, 1);
    expect(game.paused, isTrue);
  });
}
