import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/gallery/gallery_v2_screen.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';

import '../test_helpers.dart';

void main() {
  testWidgets(
    'bundled gallery loads and animation controls work at small size',
    (tester) async {
      setScreenSize(tester, const Size(360, 640));
      setTextScale(tester, 1.3);
      late ArtPack pack;
      await tester.runAsync(() async {
        pack = await ArtPack.load();
      });
      await tester.pumpWidget(
        testApp(home: GalleryV2Screen(load: () async => pack)),
      );
      await tester.pump();
      await tester.pump(const Duration(microseconds: 799500));
      expect(tester.takeException(), isNull);
      expect(find.text('Galeri aset baru'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is DropdownButtonFormField),
        findsNWidgets(4),
      );
      await tester.ensureVisible(find.text('Putar animasi'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('v2-Kucing')),
        -200,
      );
      await tester.tap(find.byKey(const ValueKey('v2-Kucing')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('salju').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sprite · salju · idle'), 200);
      expect(find.text('Sprite · salju · idle'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'failed load offers retry and reduced motion disables animation',
    (tester) async {
      late ArtPack pack;
      await tester.runAsync(() async {
        pack = await ArtPack.load();
      });
      var attempts = 0;
      await tester.pumpWidget(
        testApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: GalleryV2Screen(
              load: () async {
                if (attempts++ == 0) throw StateError('fixture');
                return pack;
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Aset gagal dimuat.'), findsOneWidget);
      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Putar animasi'));
      final toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.value, false);
      expect(toggle.onChanged, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('gallery ticker stops in background and under TickerMode', (
    tester,
  ) async {
    late ArtPack pack;
    await tester.runAsync(() async {
      pack = await ArtPack.load();
    });
    await tester.pumpWidget(
      testApp(home: GalleryV2Screen(load: () async => pack)),
    );
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(
      testApp(
        home: TickerMode(
          enabled: false,
          child: GalleryV2Screen(load: () async => pack),
        ),
      ),
    );
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
