import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/result/result_art.dart';
import 'package:kucing_oren/screens/result/result_parts.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

/// Tombol yang ditekan di layar hasil.
final _taps = <String>[];

Future<void> pumpResult(
  WidgetTester tester,
  LevelSession session, {
  Size size = const Size(390, 844),
  bool disableAnimations = false,
  int coins = 0,
}) async {
  _taps.clear();
  setScreenSize(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      theme: KoTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: ResultView(
          session: session,
          onArrange: () => _taps.add('atur'),
          onRestart: () => _taps.add('ulangi'),
          onNext: () => _taps.add('lanjut'),
          coins: coins,
        ),
      ),
    ),
  );
}

String _stat(WidgetTester tester, String label) {
  final stat = tester.widget<ResultStat>(
    find.byWidgetPredicate((w) => w is ResultStat && w.label == label),
  );
  return '${stat.value} ${stat.label}';
}

/// Opasitas bintang ke-[i] (0..2) di deret bintang hasil; 1 kalau tidak
/// sedang dianimasikan.
double _starOpacity(WidgetTester tester, int i) {
  final star = find.descendant(
    of: find.byType(ResultStars),
    matching: find.byType(KoStar),
  );
  final opacity = find.ancestor(of: star.at(i), matching: find.byType(Opacity));
  if (opacity.evaluate().isEmpty) return 1;
  return tester.widget<Opacity>(opacity.first).opacity;
}

void main() {
  group('Berhasil', () {
    testWidgets('solusi level 13: 3 bintang, 6 langkah, 2 benda', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpResult(tester, resultOf(levels[12], levels[12].solution));
      await pumpFor(tester, const Duration(seconds: 2));

      expect(find.text('LEVEL 13 · VAS IBU'), findsOneWidget);
      expect(find.text('Berhasil!'), findsOneWidget);
      expect(find.bySemanticsLabel('3 dari 3 bintang'), findsOneWidget);
      expect(_stat(tester, 'langkah'), '6 langkah');
      expect(_stat(tester, 'benda dipakai'), '2 benda dipakai');
      expect(find.text('Sampai mangkuk'), findsOneWidget);
      expect(find.text('Vas Ibu aman'), findsOneWidget);
      expect(find.text('Benda paling sedikit'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('tercapai')), findsNWidgets(3));
      expect(find.text('Belum'), findsNothing);
      expect(find.byType(SuccessArt), findsOneWidget);
      expect(find.byType(ResultRays), findsOneWidget);

      // Putar ulang menunggu langkah 10.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tonton putar ulang')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      semantics.dispose();
    });

    testWidgets('Ulangi dan Lanjut', (tester) async {
      await pumpResult(tester, resultOf(levels[12], levels[12].solution));
      await tester.tap(find.text('Ulangi'));
      await tester.tap(find.text('Lanjut'));
      await tester.tap(find.text('Tonton putar ulang'));
      expect(_taps, ['ulangi', 'lanjut']);
    });

    testWidgets('benda lebih dari target: 2 bintang, syarat 3 "Belum"', (
      tester,
    ) async {
      await pumpResult(tester, resultOf(levels[14], twoStars));
      await pumpFor(tester, const Duration(seconds: 2));
      expect(find.bySemanticsLabel('2 dari 3 bintang'), findsOneWidget);
      expect(_stat(tester, 'benda dipakai'), '2 benda dipakai');
      expect(find.bySemanticsLabel(RegExp('tercapai')), findsNWidgets(2));
      expect(find.text('Belum'), findsOneWidget);
    });

    testWidgets('level tanpa benda: 0 benda dipakai, 3 bintang', (
      tester,
    ) async {
      await pumpResult(tester, resultOf(levels[0]));
      await pumpFor(tester, const Duration(seconds: 2));
      expect(find.text('LEVEL 1 · BANGUNKAN OYEN'), findsOneWidget);
      expect(find.bySemanticsLabel('3 dari 3 bintang'), findsOneWidget);
      expect(_stat(tester, 'benda dipakai'), '0 benda dipakai');
    });

    testWidgets('bintang muncul satu per satu seperti koStar', (tester) async {
      await pumpResult(tester, resultOf(levels[12], levels[12].solution));
      expect([for (var i = 0; i < 3; i++) _starOpacity(tester, i)], [0, 0, 0]);

      // Bintang kedua mulai 0,35 detik: di 0,4 detik baru muncul sedikit.
      await pumpFor(tester, const Duration(milliseconds: 400));
      expect(_starOpacity(tester, 0), greaterThan(0.5));
      expect(_starOpacity(tester, 1), inExclusiveRange(0, 0.5));
      expect(_starOpacity(tester, 2), 0);

      await pumpFor(tester, const Duration(milliseconds: 800));
      expect([for (var i = 0; i < 3; i++) _starOpacity(tester, i)], [1, 1, 1]);
    });

    testWidgets('bintang yang tidak didapat langsung tampil pudar', (
      tester,
    ) async {
      await pumpResult(tester, resultOf(levels[14], twoStars));
      expect(_starOpacity(tester, 2), 1);
      final star = tester.widget<KoStar>(
        find
            .descendant(
              of: find.byType(ResultStars),
              matching: find.byType(KoStar),
            )
            .at(2),
      );
      expect(star.filled, isFalse);
    });

    testWidgets('tanpa animasi: bintang langsung tampil, sinar diam', (
      tester,
    ) async {
      await pumpResult(
        tester,
        resultOf(levels[12], levels[12].solution),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      expect([for (var i = 0; i < 3; i++) _starOpacity(tester, i)], [1, 1, 1]);
    });

    test('keyframe koStar', () {
      expect(ResultStars.popAt(0), (0.0, -30.0, 0.0));
      final (scale, degrees, opacity) = ResultStars.popAt(0.7);
      expect(scale, closeTo(1.2, 1e-9));
      expect(degrees, closeTo(6, 1e-9));
      expect(opacity, 1);
      expect(ResultStars.popAt(1), (1.0, 0.0, 1.0));
    });
  });

  group('koin', () {
    testWidgets('Berhasil dengan koin baru: kotak "+30 koin"', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpResult(
        tester,
        resultOf(levels[12], levels[12].solution),
        coins: 30,
      );
      await pumpFor(tester, const Duration(seconds: 2));
      expect(find.text('+30'), findsOneWidget);
      expect(find.text('koin'), findsOneWidget);
      expect(find.bySemanticsLabel('+30 koin'), findsOneWidget);
      expect(find.byType(ResultStat), findsNWidgets(3));
      semantics.dispose();
    });

    testWidgets('tanpa koin baru: tanpa kotak koin', (tester) async {
      await pumpResult(tester, resultOf(levels[12], levels[12].solution));
      await pumpFor(tester, const Duration(seconds: 2));
      expect(find.text('koin'), findsNothing);
      expect(find.byType(ResultStat), findsNWidgets(2));
    });

    testWidgets('vas pecah dengan koin baru: "+10 koin"', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpResult(tester, resultOf(levels[12], fishOnly), coins: 10);
      await pumpFor(tester, const Duration(seconds: 1));
      expect(find.bySemanticsLabel('+10 koin'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('vas pecah', () {
    testWidgets('ikan saja di (2,4): seperti contoh desain 07', (tester) async {
      final semantics = tester.ensureSemantics();
      final session = resultOf(levels[12], fishOnly);
      expect(session.stars, 1);
      await pumpResult(tester, session);
      await pumpFor(tester, const Duration(seconds: 1));

      expect(find.text('LEVEL 13 · VAS IBU'), findsOneWidget);
      expect(find.text('Sampai sih...\ntapi vas Ibu?'), findsOneWidget);
      expect(find.bySemanticsLabel('1 dari 3 bintang'), findsOneWidget);
      expect(find.text('Dapat'), findsOneWidget);
      expect(find.text('Pecah di langkah 2'), findsOneWidget);
      expect(find.text('Belum'), findsOneWidget);
      expect(_stat(tester, 'langkah'), '10 langkah');
      expect(_stat(tester, 'benda dipakai'), '1 benda dipakai');
      expect(find.bySemanticsLabel(VaseArt.label), findsOneWidget);
      expect(find.byType(ResultRays), findsNothing);
      semantics.dispose();
    });

    testWidgets('Coba Lagi dan Lanjut Saja', (tester) async {
      await pumpResult(tester, resultOf(levels[12], fishOnly));
      await tester.tap(find.text('Coba Lagi'));
      await tester.tap(find.text('Lanjut Saja'));
      expect(_taps, ['atur', 'lanjut']);
    });

    test('goyangan PRANG: -4° → 4° → -4°', () {
      expect(VaseArt.swingAt(0), closeTo(-4, 1e-9));
      expect(VaseArt.swingAt(0.25), closeTo(0, 1e-9));
      expect(VaseArt.swingAt(0.5), closeTo(4, 1e-9));
      expect(VaseArt.swingAt(0.999), closeTo(-4, 1e-3));
    });
  });

  group('Oyen bosan', () {
    testWidgets('tanpa benda di level 13: mondar-mandir', (tester) async {
      final session = resultOf(levels[12]);
      expect(session.result!.failReason, FailReason.loop);
      await pumpResult(tester, session);
      await tester.pumpAndSettle();

      expect(find.text('LEVEL 13 · GAGAL'), findsOneWidget);
      expect(find.text('Oyen bosan mondar-mandir.'), findsOneWidget);
      expect(find.text('Muter terus'), findsOneWidget);
      expect(
        find.text(
          'Jalannya muter-muter terus, nggak ketemu mangkuk. '
          'Ya sudah, tidur lagi.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ResultStars), findsNothing);

      // Papan terakhir dengan Oyen tertidur lagi.
      final scene = tester.widget<RestBoard>(find.byType(RestBoard)).scene;
      final last = session.result!.trace[session.result!.steps - 1];
      expect(scene.oyen!.look.pose, OyenPose.sleep);
      expect(scene.oyen!.look.bubble, OyenBubble.zzz);
      expect((scene.oyen!.col, scene.oyen!.row), (last.pos.x, last.pos.y));
      expect(scene.showFacing, isFalse);
    });

    testWidgets('Atur Lagi; Putar Ulang menunggu langkah 10', (tester) async {
      await pumpResult(tester, resultOf(levels[12]));
      await tester.tap(find.text('Putar Ulang'));
      await tester.tap(find.text('Atur Lagi'));
      expect(_taps, ['atur']);
      expect(
        tester
            .widget<KoButton>(find.widgetWithText(KoButton, 'Putar Ulang'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('kelamaan: lewat 80 langkah', (tester) async {
      final session = resultOf(longWalk);
      expect(session.result!.failReason, FailReason.tooManySteps);
      await pumpResult(tester, session);
      await tester.pumpAndSettle();
      expect(find.text('LEVEL 21 · GAGAL'), findsOneWidget);
      expect(find.text('Oyen bosan jalan terus.'), findsOneWidget);
      expect(find.text('Lewat $maxSteps langkah'), findsOneWidget);
      expect(
        find.text(
          'Sudah $maxSteps langkah, mangkuknya belum ketemu juga. '
          'Capek, ah. Tidur lagi.',
        ),
        findsOneWidget,
      );
    });
  });

  group('ukuran layar', () {
    testWidgets('360×640: ilustrasi mengecil atau disembunyikan', (
      tester,
    ) async {
      setTextScale(tester, 1.3);
      for (final session in [
        resultOf(levels[12], levels[12].solution),
        resultOf(levels[12], fishOnly),
        resultOf(levels[12]),
        resultOf(longWalk),
      ]) {
        await pumpResult(tester, session, size: const Size(360, 640));
        await pumpFor(tester, const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('390×844: kartu ilustrasi seukuran desain', (tester) async {
      await pumpResult(tester, resultOf(levels[12], levels[12].solution));
      await tester.pump();
      expect(tester.getSize(find.byType(SuccessArt)), ResultArt.successCard);
      await pumpResult(tester, resultOf(levels[12], fishOnly));
      await tester.pump();
      expect(tester.getSize(find.byType(VaseArt)), ResultArt.vaseCard);
    });
  });
}
