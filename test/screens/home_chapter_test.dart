import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/chapter/chapter_header.dart';
import 'package:kucing_oren/screens/chapter/chapter_map.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Progres contoh desain: Babak 1 selesai dengan 26 bintang, level 11
/// (3 bintang) dan 12 (2 bintang) menang.
final _design = {...wonUpTo(8), 9: 1, 10: 1, 11: 3, 12: 2};

Finder _label(String label) => find.bySemanticsLabel(label);

/// Jejak kaki di peta: (jelas, pudar).
(int, int) _paws(WidgetTester tester) {
  final opacities = tester
      .widgetList<Opacity>(
        find.ancestor(
          of: find.byWidgetPredicate(
            (w) => w is KoIcon && w.icon == KoIcons.steps,
          ),
          matching: find.byType(Opacity),
        ),
      )
      .map((o) => o.opacity);
  return (
    opacities.where((o) => o == MapArt.pawOpacity).length,
    opacities.where((o) => o == MapArt.pawDimOpacity).length,
  );
}

void main() {
  group('peta babak', () {
    testWidgets('Babak 2 seperti desain: selesai, saat ini, terkunci', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(_design),
      );
      expect(find.text('BABAK 2'), findsOneWidget);
      expect(find.text('Ruang Tamu'), findsOneWidget);
      expect(_label('5 dari 30 bintang'), findsOneWidget);
      expect(
        _label('Babak 1 – Dapur, selesai, 26 dari 30 bintang'),
        findsOneWidget,
      );
      expect(find.text('Selesai'), findsOneWidget);

      expect(_label('Level 11, 3 bintang'), findsOneWidget);
      expect(_label('Level 12, 2 bintang'), findsOneWidget);
      expect(_label('Level 13, main sekarang'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      // Cincin denyut hanya di node level saat ini.
      expect(
        find.descendant(
          of: find.byType(ChapterMap),
          matching: find.byType(ScaleTransition),
        ),
        findsOneWidget,
      );
      for (var id = 14; id <= 19; id++) {
        expect(_label('Level $id, terkunci'), findsOneWidget);
      }
      expect(_label('Level 20, bos Hari Lebaran, terkunci'), findsOneWidget);
      expect(find.text('Bos · Hari Lebaran'), findsOneWidget);

      // Bintang di bawah node selesai: 3 + 3, lima di antaranya kuning.
      final stars = tester.widgetList<KoStar>(
        find.byWidgetPredicate(
          (w) => w is KoStar && w.size == KoSize.standard.mapStar,
        ),
      );
      expect(stars, hasLength(6));
      expect(stars.where((s) => s.filled), hasLength(5));

      // Jejak sesudah level 11 dan 12 jelas, sisanya pudar.
      expect(_paws(tester), (4, 14));
    });

    testWidgets('Babak 1 baru: level 1 saat ini, Babak 2 terkunci', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.chapter(1));
      expect(find.text('Dapur'), findsOneWidget);
      expect(_label('0 dari 30 bintang'), findsWidgets);
      expect(
        _label('Babak 2 – Ruang Tamu, terkunci, 0 dari 30 bintang'),
        findsOneWidget,
      );
      expect(find.text('Terkunci'), findsOneWidget);
      expect(_label('Level 1, main sekarang'), findsOneWidget);
      expect(_label('Level 10, bos Pesta Ikan Asin, terkunci'), findsOneWidget);
      expect(_paws(tester), (0, 18));
    });

    testWidgets(
      'label Main di bawah node kalau node sebelumnya tepat di atas',
      (tester) async {
        Future<(Rect, Rect)> labelAndNode(
          Map<int, int> best,
          String node,
        ) async {
          await pumpApp(
            tester,
            location: AppRoutes.chapter(1),
            progress: testProgress(best),
          );
          return (
            tester.getRect(find.text('Main')),
            tester.getRect(_label(node)),
          );
        }

        // Level 3: seperti desain (level 13), label di atas.
        final (above, three) = await labelAndNode({
          1: 3,
          2: 2,
        }, 'Level 3, main sekarang');
        expect(above.bottom, lessThan(three.top));

        // Level 4 dan 7 tepat di bawah level 3 dan 6: label di bawah supaya
        // bintang level sebelumnya tidak tertutup.
        for (final (best, node, previous) in [
          ({1: 3, 2: 2, 3: 1}, 'Level 4, main sekarang', 'Level 3, 1 bintang'),
          (wonUpTo(6), 'Level 7, main sekarang', 'Level 6, 3 bintang'),
        ]) {
          final (label, rect) = await labelAndNode(best, node);
          expect(label.top, greaterThan(rect.bottom), reason: node);
          final stars = tester.getRect(
            find.descendant(
              of: find.ancestor(
                of: _label(previous),
                matching: find.byType(LevelNode),
              ),
              matching: find.byType(Row),
            ),
          );
          expect(label.overlaps(stars), isFalse, reason: node);
        }
      },
    );

    testWidgets('Babak 2 terbuka tapi belum selesai: tanpa badge', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(1),
        progress: testProgress(wonUpTo(10, stars: 2)),
      );
      expect(_label('Babak 2 – Ruang Tamu, 0 dari 30 bintang'), findsOneWidget);
      expect(find.text('Selesai'), findsNothing);
      expect(find.text('Terkunci'), findsNothing);
      expect(_label('20 dari 30 bintang'), findsOneWidget);
      expect(
        _label('Level 10, bos Pesta Ikan Asin, 2 bintang'),
        findsOneWidget,
      );
    });

    testWidgets('bos saat ini: berdenyut dengan label Main, bisa dibuka', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(wonUpTo(19)),
      );
      final boss = _label('Level 20, bos Hari Lebaran, main sekarang');
      expect(boss, findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      // Denyut berjalan terus.
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.tap(boss);
      await settle(tester);
      expect(find.text('Level 20 · BOS: Hari Lebaran'), findsOneWidget);
    });

    testWidgets('semua selesai: tidak ada yang berdenyut', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(wonUpTo(20)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Main'), findsNothing);
      expect(_label('Level 20, bos Hari Lebaran, 3 bintang'), findsOneWidget);
      expect(_paws(tester), (18, 0));
    });

    testWidgets('tanpa animasi: cincin denyut tidak tampil', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpApp(tester, location: AppRoutes.chapter(1));
      await tester.pumpAndSettle();
      expect(find.text('Main'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ChapterMap),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
    });

    testWidgets('peta selebar layar, mengikuti desain 390', (tester) async {
      setScreenSize(tester, const Size(412, 915));
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(wonUpTo(10)),
      );
      final node = tester.getCenter(_label('Level 11, main sekarang'));
      const scale = 412 / 390;
      expect(node.dx, closeTo(MapArt.points.first.dx * scale, 0.5));
    });

    testWidgets('layar pendek: dibuka dengan level saat ini terlihat', (
      tester,
    ) async {
      setScreenSize(tester, const Size(360, 640));
      await pumpApp(
        tester,
        location: AppRoutes.chapter(1),
        progress: testProgress(wonUpTo(9)),
      );
      final boss = tester.getRect(
        _label('Level 10, bos Pesta Ikan Asin, main sekarang'),
      );
      final header = tester.getRect(find.byType(ChapterHeader));
      expect(boss.bottom, lessThanOrEqualTo(640));
      expect(boss.top, greaterThan(header.bottom));
      // Bisa digulir kembali ke level 1.
      await tester.drag(find.byType(Scrollable), const Offset(0, 600));
      await settle(tester);
      expect(_label('Level 1, 3 bintang').hitTestable(), findsOneWidget);
    });
  });

  test('keadaan node dari progres', () {
    final level = testLevels[1];
    expect(NodeState.of(testProgress().progress, level), NodeState.locked);
    expect(
      NodeState.of(testProgress({1: 1}).progress, level),
      NodeState.current,
    );
    expect(
      NodeState.of(testProgress({1: 1, 2: 3}).progress, level),
      NodeState.done,
    );
  });
}
