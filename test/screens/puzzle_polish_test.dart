import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/v2/puzzle_art.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/widgets/widgets.dart';

/// Pixels of [paint] drawn on a [w]×[h] canvas.
Future<ByteData> pixels(
  WidgetTester t,
  void Function(Canvas) paint, {
  int w = 50,
  int h = 50,
}) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final picture = recorder.endRecording();
  return (await t.runAsync(() async {
    final image = await picture.toImage(w, h);
    final data = await image.toByteData();
    image.dispose();
    return data!;
  }))!;
}

Color at(ByteData d, int w, int x, int y) {
  final i = (y * w + x) * 4;
  return Color.fromARGB(
    d.getUint8(i + 3),
    d.getUint8(i),
    d.getUint8(i + 1),
    d.getUint8(i + 2),
  );
}

bool near(Color a, Color b, [int tol = 8]) =>
    ((a.r - b.r) * 255).abs() <= tol &&
    ((a.g - b.g) * 255).abs() <= tol &&
    ((a.b - b.b) * 255).abs() <= tol;

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (la > lb ? la + .05 : lb + .05) / (la > lb ? lb + .05 : la + .05);
}

void main() {
  group('benda pemain menyatu dengan petak', () {
    for (final item in [TileItem.fishP, TileItem.bucketP, TileItem.boxP]) {
      testWidgets('$item tanpa kotak kertas', (t) async {
        final d = await pixels(
          t,
          (c) => paintPuzzleTile(c, Tile(kind: TileKind.floor, item: item)),
        );
        // Pojok bekas stiker (4..46) sekarang lantai, bukan kertas/oranye.
        for (final (x, y) in [(6, 7), (43, 7), (5, 25), (45, 25)]) {
          expect(
            near(at(d, 50, x, y), PuzzleArt.floor),
            isTrue,
            reason: '($x,$y) = ${at(d, 50, x, y)}',
          );
        }
        // Penanda lantai oranye di bawah benda.
        final mark = at(d, 50, 25, 45);
        expect(near(mark, PuzzleArt.floor), isFalse, reason: '$mark');
        expect(mark.r, greaterThan(mark.b + .2));
      });
    }

    testWidgets('baki tanpa bingkai oranye ganda', (t) async {
      final d = await pixels(
        t,
        (c) => paintPuzzleItem(c, Item.fish, player: false),
      );
      for (var x = 4; x <= 46; x++) {
        expect(near(at(d, 50, x, 5), KoUi.orange, 30), isFalse);
      }
    });

    testWidgets('ItemArtView (baki) tanpa kotak kertas', (t) async {
      final key = GlobalKey();
      await t.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: key,
            child: const ItemArtView(Item.box, size: 50),
          ),
        ),
      );
      final boundary = key.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final d = (await t.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        image.dispose();
        return data!;
      }))!;
      expect(at(d, 50, 6, 7).a, lessThan(.1), reason: '${at(d, 50, 6, 7)}');
    });
  });

  test('tembok kontras dengan lantai', () {
    expect(contrast(PuzzleArt.wall, PuzzleArt.floor), greaterThan(1.3));
  });
}
