import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/render/v2/puzzle_art.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';
import 'package:kucing_oren/widgets/v2/ui_edge_fade.dart';

// Langkah 14a: perbaikan visual cepat sesudah tinjauan screenshot.
void main() {
  Widget host(Widget child) => MaterialApp(
    theme: KoUi.theme(),
    home: Scaffold(body: child),
  );

  group('UiEdgeFade', () {
    testWidgets('memudar di bawah hanya saat masih ada isi tersembunyi', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 200,
            child: UiEdgeFade(
              child: ListView(
                controller: controller,
                children: [
                  for (var i = 0; i < 20; i++)
                    SizedBox(height: 40, child: Text('baris $i')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final state = tester.state(find.byType(UiEdgeFade)) as dynamic;
      expect(state.debugEdges, (false, true));

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      expect(state.debugEdges, (true, false));
    });

    testWidgets('isi pendek tidak memudar dan posisi gulir tetap', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 200,
            child: UiEdgeFade(
              child: ListView(
                controller: controller,
                children: const [SizedBox(height: 40, child: Text('satu'))],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final state = tester.state(find.byType(UiEdgeFade)) as dynamic;
      expect(state.debugEdges, (false, false));
      expect(find.byKey(const ValueKey('edge-fade')), findsOneWidget);
    });
  });

  testWidgets('tombol rumah yang terpilih berwarna oranye', (tester) async {
    await tester.pumpWidget(
      host(
        Row(
          children: [
            UiButton(
              key: const ValueKey('on'),
              homeStyle: true,
              selected: true,
              kind: UiButtonKind.secondary,
              label: 'Aksesoris',
              onPressed: () {},
            ),
            UiButton(
              key: const ValueKey('off'),
              homeStyle: true,
              selected: false,
              kind: UiButtonKind.secondary,
              label: 'Barang',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    List<Color> colors(String key) {
      final box = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final gradient =
          (box.decoration! as BoxDecoration).gradient! as LinearGradient;
      return gradient.colors;
    }

    expect(colors('on'), [KoUi.homeGold, KoUi.orange]);
    expect(colors('off'), [KoUi.homePaper, KoUi.homeCream]);
  });

  test('ikon benda di luar papan tanpa kotak lantai', () async {
    Future<ui.Image> draw({required bool floor}) {
      final recorder = ui.PictureRecorder();
      paintPuzzleTile(
        Canvas(recorder),
        const Tile(kind: TileKind.tableGlass),
        floor: floor,
      );
      return recorder.endRecording().toImage(50, 50);
    }

    Future<int> alphaAt(ui.Image image, int x, int y) async {
      final bytes = (await image.toByteData())!;
      return bytes.getUint8((y * image.width + x) * 4 + 3);
    }

    final withFloor = await draw(floor: true);
    final bare = await draw(floor: false);
    // Pojok petak: lantai menutup di papan, kosong untuk ikon peta.
    expect(await alphaAt(withFloor, 2, 2), 255);
    expect(await alphaAt(bare, 2, 2), 0);
    // Meja tetap tergambar di tengah.
    expect(await alphaAt(bare, 25, 30), 255);
  });
}
