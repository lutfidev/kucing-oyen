import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/chapter.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/screens/chapter/chapter_header.dart';
import 'package:kucing_oren/screens/chapter/chapter_map.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/chapter/map_token.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart' show pumpFor;

/// Progres contoh desain: Babak 1 selesai dengan 26 bintang, level 11
/// (3 bintang) dan 12 (2 bintang) menang.
final _design = {...wonUpTo(8), 9: 1, 10: 1, 11: 3, 12: 2};

Finder _label(String label) => find.bySemanticsLabel(label);

/// Jejak kaki di peta: (jelas, pudar).
(int, int) _paws(WidgetTester tester) {
  final opacities = tester
      .widgetList<MapPaw>(find.byType(MapPaw))
      .map((p) => p.opacity);
  return (
    opacities.where((o) => o == PictureMapArt.pawOpacity).length,
    opacities.where((o) => o == PictureMapArt.pawDimOpacity).length,
  );
}

/// Skala peta: lebar layar ÷ 390.
double _scale(WidgetTester tester) =>
    tester.getSize(find.byType(Scaffold).last).width / 390;

/// Titik pijakan token Oyen (tengah node tempatnya berdiri), dari kotaknya.
Offset _tokenFoot(WidgetTester tester) =>
    tester.getRect(find.byType(MapToken)).topLeft -
    PictureMapArt.tokenOffset * _scale(tester);

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
                matching: find.byType(PictureNode),
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
      expect(node.dx, closeTo(PictureMapArt.points.first.dx * scale, 0.5));
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

  group('token Oyen dan latar', () {
    testWidgets('token di kanan atas node level saat ini', (tester) async {
      setScreenSize(tester, const Size(390, 844));
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(_design),
      );
      final token = tester.getRect(find.byType(MapToken));
      final center = tester.getCenter(_label('Level 13, main sekarang'));
      expect(token.left, closeTo(center.dx + 18, 0.5));
      expect(token.top, closeTo(center.dy - 92, 0.5));
    });

    testWidgets('babak selesai: token di bos', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(1),
        progress: testProgress(wonUpTo(12)),
      );
      final boss = tester.getCenter(
        _label('Level 10, bos Pesta Ikan Asin, 3 bintang'),
      );
      expect((_tokenFoot(tester) - boss).distance, lessThan(0.5));
    });

    testWidgets('babak terkunci: tanpa token', (tester) async {
      await pumpApp(tester, location: AppRoutes.chapter(2));
      expect(find.byType(MapToken), findsNothing);
    });

    for (final size in const [Size(390, 844), Size(360, 640)]) {
      testWidgets('gulir awal: token level 2 utuh di bawah judul $size', (
        tester,
      ) async {
        setScreenSize(tester, size);
        await pumpApp(
          tester,
          location: AppRoutes.chapter(1),
          progress: testProgress({1: 3}),
        );
        final token = tester.getRect(find.byType(MapToken));
        final header = tester.getRect(find.byType(ChapterHeader));
        expect(token.top, greaterThanOrEqualTo(header.bottom));
        expect(token.bottom, lessThanOrEqualTo(size.height));
      });
    }

    testWidgets('latar Babak 1: krem v2', (tester) async {
      await pumpApp(tester, location: AppRoutes.chapter(1));
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
        KoUi.cream,
      );
    });

    testWidgets('latar Babak 2: krem v2', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2),
        progress: testProgress(wonUpTo(10)),
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
        KoUi.cream,
      );
    });
  });

  testWidgets('layar kecil 360×640: node 54, jalur dirapatkan 12%', (
    tester,
  ) async {
    setScreenSize(tester, const Size(360, 640));
    await pumpApp(
      tester,
      location: AppRoutes.chapter(1),
      progress: testProgress(wonUpTo(9)),
    );
    final node = find.ancestor(
      of: _label('Level 9, 3 bintang'),
      matching: find.byType(PictureNode),
    );
    final pressable = find.descendant(
      of: node,
      matching: find.byType(KoPressable),
    );
    final scale = _scale(tester);
    expect(tester.getRect(pressable).width, closeTo(54 * scale, 0.01));
    final first = tester.getCenter(_label('Level 1, 3 bintang'));
    final boss = tester.getCenter(
      _label('Level 10, bos Pesta Ikan Asin, main sekarang'),
    );
    expect(boss.dy - first.dy, closeTo((724 - 262) * 0.88 * scale, 0.5));
    expect(
      tester
          .getRect(
            find.descendant(
              of: find.ancestor(
                of: _label('Level 10, bos Pesta Ikan Asin, main sekarang'),
                matching: find.byType(PictureNode),
              ),
              matching: find.byType(KoPressable),
            ),
          )
          .width,
      closeTo(84 * scale, 0.01),
    );
  });

  group('Oyen berjalan', () {
    final chapters = chaptersOf(testLevels);

    /// [ChapterView] babak [chapter] dengan level 1–[won] menang, dibuka
    /// dari "Lanjut" level [from]. Mengembalikan level yang dibuka.
    Future<List<int>> pumpWalk(
      WidgetTester tester, {
      required int won,
      required int? from,
      int chapter = 2,
    }) async {
      final opened = <int>[];
      await tester.pumpWidget(
        testApp(
          home: ChapterView(
            chapter: chapters[chapter - 1],
            other: chapters[2 - chapter],
            progress: testProgress(wonUpTo(won)).progress,
            onBack: () {},
            onOpen: (_) {},
            onPlay: (level) => opened.add(level.id),
            walkFrom: from,
          ),
        ),
      );
      return opened;
    }

    Offset nodeCenter(WidgetTester tester, String label) =>
        tester.getCenter(_label(label));

    Future<void> pumpTime(WidgetTester tester, double seconds) async {
      for (var t = 0.0; t < seconds - 1e-9; t += 1 / 60) {
        await tester.pump(const Duration(microseconds: 16667));
      }
    }

    testWidgets('jalan menyusuri jalur lalu level berikutnya terbuka sekali', (
      tester,
    ) async {
      final opened = await pumpWalk(tester, won: 12, from: 12);
      final from = nodeCenter(tester, 'Level 12, 3 bintang');
      final to = nodeCenter(tester, 'Level 13, main sekarang');
      expect((_tokenFoot(tester) - from).distance, lessThan(0.5));
      await pumpTime(tester, 0.8);
      final mid = _tokenFoot(tester);
      expect((mid - from).distance, greaterThan(10));
      expect((mid - to).distance, greaterThan(10));
      final pose = tester.widget<MapToken>(find.byType(MapToken)).pose;
      expect(pose, anyOf(KittyPose.walk1, KittyPose.walk2));
      await pumpTime(tester, 0.5);
      expect((_tokenFoot(tester) - to).distance, lessThan(0.5));
      expect(opened, isEmpty);
      await pumpTime(tester, 0.4);
      expect(opened, [13]);
      await pumpTime(tester, 1);
      expect(opened, [13]);
    });

    testWidgets('ketukan membatalkan buka otomatis tanpa menekan node', (
      tester,
    ) async {
      final opened = await pumpWalk(tester, won: 12, from: 12);
      await pumpTime(tester, 0.5);
      await tester.tap(_label('Level 12, 3 bintang'), warnIfMissed: false);
      await pumpTime(tester, 3);
      expect(opened, isEmpty);
      final to = nodeCenter(tester, 'Level 13, main sekarang');
      expect((_tokenFoot(tester) - to).distance, lessThan(0.5));
      // Sesudah sampai, node bisa diketuk lagi seperti biasa.
      await tester.tap(_label('Level 13, main sekarang'));
      expect(opened, [13]);
    });

    testWidgets('kembali sistem membatalkan buka otomatis', (tester) async {
      final opened = <int>[];
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        testApp(
          home: Navigator(
            key: navigator,
            onGenerateRoute: (_) =>
                MaterialPageRoute<void>(builder: (_) => const SizedBox()),
          ),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => ChapterView(
              chapter: chapters[1],
              other: chapters[0],
              progress: testProgress(wonUpTo(12)).progress,
              onBack: () {},
              onOpen: (_) {},
              onPlay: (level) => opened.add(level.id),
              walkFrom: 12,
            ),
          ),
        ),
      );
      await tester.pump();
      await pumpTime(tester, 0.5);
      await navigator.currentState!.maybePop();
      await pumpTime(tester, 3);
      expect(opened, isEmpty);
    });

    testWidgets('layar dibuang di tengah jalan: tanpa buka, tanpa error', (
      tester,
    ) async {
      final opened = await pumpWalk(tester, won: 12, from: 12);
      await pumpTime(tester, 0.5);
      await tester.pumpWidget(testApp(home: const SizedBox()));
      await pumpTime(tester, 3);
      expect(opened, isEmpty);
    });

    testWidgets('kurangi gerak: langsung di tujuan, buka sesudah 0,6 detik', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final opened = await pumpWalk(tester, won: 12, from: 12);
      await tester.pump();
      final to = nodeCenter(tester, 'Level 13, main sekarang');
      expect((_tokenFoot(tester) - to).distance, lessThan(0.5));
      await pumpTime(tester, 0.5);
      expect(opened, isEmpty);
      await pumpTime(tester, 0.2);
      expect(opened, [13]);
    });

    testWidgets('pembaca layar: tanpa buka otomatis, sampai diumumkan', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final opened = await pumpWalk(tester, won: 12, from: 12);
      await pumpTime(tester, 3);
      expect(opened, isEmpty);
      expect(
        tester.takeAnnouncements().map((a) => a.message),
        contains('Oyen sampai di level 13.'),
      );
      await tester.tap(_label('Level 13, main sekarang'));
      expect(opened, [13]);
    });

    testWidgets('sesudah level 20: Oyen senang di bos, tanpa buka', (
      tester,
    ) async {
      final opened = await pumpWalk(tester, won: 20, from: 20);
      await pumpTime(tester, 3);
      expect(opened, isEmpty);
      final boss = nodeCenter(tester, 'Level 20, bos Hari Lebaran, 3 bintang');
      expect((_tokenFoot(tester) - boss).distance, lessThan(0.5));
      expect(
        tester.widget<MapToken>(find.byType(MapToken)).pose,
        KittyPose.happy,
      );
    });

    testWidgets(
      'lompatan waktu besar (aplikasi di latar): tidak langsung buka',
      (tester) async {
        final opened = await pumpWalk(tester, won: 12, from: 12);
        await pumpTime(tester, 0.5);
        await tester.pump(const Duration(seconds: 30));
        expect(opened, isEmpty);
        await pumpTime(tester, 1.6);
        expect(opened, [13]);
      },
    );

    testWidgets('arah hadap mengikuti jalur: turun lurus = hadap depan', (
      tester,
    ) async {
      // Level 3 → 4 di Babak 1 hampir lurus ke bawah (dx −6, dy 96).
      await pumpWalk(tester, won: 3, from: 3, chapter: 1);
      await pumpTime(tester, 0.8);
      final look = tester.widget<MapToken>(find.byType(MapToken));
      expect(look.pose, anyOf(KittyPose.walk1, KittyPose.walk2));
      expect(look.facing, KittyFacing.down);
    });

    testWidgets('walkFrom hilang (level dibuka di atas peta): gulir diam', (
      tester,
    ) async {
      setScreenSize(tester, const Size(360, 640));
      await pumpWalk(tester, won: 18, from: 12);
      final offset = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;
      await pumpWalk(tester, won: 18, from: null);
      await tester.pump();
      expect(
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
        offset,
      );
    });

    testWidgets('walkFrom datang belakangan (peta di bawah level)', (
      tester,
    ) async {
      await pumpWalk(tester, won: 12, from: null);
      await settle(tester);
      final to = nodeCenter(tester, 'Level 13, main sekarang');
      expect((_tokenFoot(tester) - to).distance, lessThan(0.5));
      // Lanjut dari level 12 ke peta yang sama (ChapterView tetap terpasang).
      final opened = await pumpWalk(tester, won: 12, from: 12);
      await tester.pump();
      final from = nodeCenter(tester, 'Level 12, 3 bintang');
      expect((_tokenFoot(tester) - from).distance, lessThan(0.5));
      await pumpTime(tester, 1.7);
      expect(opened, [13]);
    });
  });

  group('temuan review', () {
    // Lanjut dari dalam aplikasi: peta sudah terpasang dan tergulir ke
    // level 9, lalu level 3 dimainkan ulang dan "Lanjut" kembali ke peta
    // yang sama (`didUpdateWidget`). Token harus terlihat di bawah judul.
    for (final scale in const [1.0, 1.3]) {
      testWidgets('Lanjut di peta yang sudah tergulir, teks ${scale * 100}%', (
        tester,
      ) async {
        setScreenSize(tester, const Size(360, 640));
        setTextScale(tester, scale);
        await pumpApp(
          tester,
          location: AppRoutes.chapter(1),
          progress: testProgress(wonUpTo(8)),
        );
        final router = GoRouter.of(tester.element(find.byType(ChapterView)));
        router.go(AppRoutes.level(3, chapter: 1));
        await tester.pumpAndSettle();
        router.go(AppRoutes.chapter(1, from: 3));
        await tester.pump();
        await tester.pump();
        final token = tester.getRect(find.byType(MapToken));
        final header = tester.getRect(find.byType(ChapterHeader));
        expect(token.top, greaterThanOrEqualTo(header.bottom - 1));
        expect(token.bottom, lessThanOrEqualTo(640));
        await pumpFor(tester, const Duration(milliseconds: 1700));
        await tester.pumpAndSettle();
        expect(find.text('Level 4 · Ikan Terdekat'), findsOneWidget);
      });
    }

    testWidgets('kartu babak baru menutup peta dari pembaca layar', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        location: AppRoutes.chapter(2, intro: true),
        progress: testProgress(wonUpTo(10)),
      );
      expect(find.bySemanticsLabel('Babak baru terbuka'), findsOneWidget);
      expect(find.bySemanticsLabel('Level 11, main sekarang'), findsNothing);
      await tester.tap(find.text('Ayo masuk!'));
      await settle(tester);
      expect(find.bySemanticsLabel('Level 11, main sekarang'), findsOneWidget);
      semantics.dispose();
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
