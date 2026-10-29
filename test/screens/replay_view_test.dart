import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/screens/replay/replay_parts.dart';
import 'package:kucing_oren/screens/replay/replay_view.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

/// Tombol yang ditekan di putar ulang.
final _taps = <String>[];

Future<void> _pumpReplay(
  WidgetTester tester,
  LevelSession session, {
  bool disableAnimations = false,
}) async {
  _taps.clear();
  setScreenSize(tester, const Size(390, 844));
  await tester.pumpWidget(
    testApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: ReplayView(
          session: session,
          onBack: () => _taps.add('hasil'),
          onMap: () => _taps.add('peta'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ReplayCaption _caption(WidgetTester tester) =>
    tester.widget<ReplayCaption>(find.byType(ReplayCaption));

int _sliderValue(WidgetTester tester) =>
    tester.widget<ReplaySlider>(find.byType(ReplaySlider)).value;

Finder _stepButton(String label) =>
    find.byWidgetPredicate((w) => w is KoPressable && w.semanticLabel == label);

Future<void> _tapStep(WidgetTester tester, String label) async {
  await tester.tap(_stepButton(label));
  await tester.pumpAndSettle();
}

void main() {
  group('ReplayView', () {
    testWidgets('solusi level 13: bar atas, langkah 0, dan angka 0–6', (
      tester,
    ) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      expect(find.text('LEVEL 13 · VAS IBU'), findsOneWidget);
      expect(find.text('Putar Ulang'), findsOneWidget);
      expect(find.text('Rekaman'), findsOneWidget);
      expect(find.text('WAKTU'), findsOneWidget);

      expect(_caption(tester).step, 0);
      expect(find.text('Awal'), findsOneWidget);
      expect(find.text('Awal: Oyen tidur menghadap kiri.'), findsOneWidget);
      for (var i = 0; i <= 6; i++) {
        expect(
          find.descendant(
            of: find.byType(ReplaySlider),
            matching: find.text('$i'),
          ),
          findsOneWidget,
        );
      }
      // Di langkah 0 tidak bisa mundur.
      expect(
        tester
            .widget<KoPressable>(_stepButton('Mundur satu langkah'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('maju dan mundur satu langkah', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      for (var i = 0; i < 4; i++) {
        await _tapStep(tester, 'Maju satu langkah');
      }
      expect(_caption(tester).step, 4);
      expect(_sliderValue(tester), 4);
      expect(find.text('Ikan asin kelihatan lurus di kiri.'), findsOneWidget);

      await _tapStep(tester, 'Mundur satu langkah');
      expect(_caption(tester).step, 3);
      expect(
        find.text('Mentok tembok, berputar menghadap bawah.'),
        findsOneWidget,
      );

      for (var i = 0; i < 5; i++) {
        await _tapStep(tester, 'Maju satu langkah');
      }
      // Berhenti di langkah terakhir.
      expect(_caption(tester).step, 6);
      expect(
        find.text('Masuk mangkuk. Selesai dalam 6 langkah.'),
        findsOneWidget,
      );
      expect(
        tester.widget<KoPressable>(_stepButton('Maju satu langkah')).onPressed,
        isNull,
      );
    });

    testWidgets('slider: geser ke ujung, ketuk awal, dan pembaca layar', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      final track = tester.getRect(
        find.descendant(
          of: find.byType(ReplaySlider),
          matching: find.byType(CustomPaint),
        ),
      );

      await tester.dragFrom(track.centerLeft, Offset(track.width, 0));
      await tester.pumpAndSettle();
      expect(_sliderValue(tester), 6);
      expect(_caption(tester).step, 6);

      // Angka 3 di tengah jalur.
      await tester.tapAt(track.center);
      await tester.pumpAndSettle();
      expect(_sliderValue(tester), 3);

      await tester.tapAt(track.centerLeft + const Offset(2, 0));
      await tester.pumpAndSettle();
      expect(_sliderValue(tester), 0);

      final node = tester.getSemantics(find.bySemanticsLabel('Waktu'));
      expect(node.value, 'Awal');
      expect(node.increasedValue, 'Langkah 1');
      tester.semantics.increase(find.semantics.byLabel('Waktu'));
      await tester.pumpAndSettle();
      expect(_sliderValue(tester), 1);
      semantics.dispose();
    });

    testWidgets('Oyen digeser 0,35 detik ke petak baru', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      // Langkah 1 kaget di tempat: tidak ada yang digeser.
      await tester.tap(_stepButton('Maju satu langkah'));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);

      await tester.tap(_stepButton('Maju satu langkah'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('tanpa animasi: Oyen langsung pindah', (tester) async {
      await _pumpReplay(
        tester,
        resultOf(levels[12], levels[12].solution),
        disableAnimations: true,
      );
      await tester.tap(_stepButton('Maju satu langkah'));
      await tester.pump();
      await tester.tap(_stepButton('Maju satu langkah'));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('kembali ke hasil dan kembali ke peta', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is KoIconButton && w.semanticLabel == 'Kembali ke hasil',
        ),
      );
      await tester.tap(find.text('Kembali ke peta'));
      expect(_taps, ['hasil', 'peta']);
    });

    testWidgets('mondar-mandir: langkah terakhir menyebut langkah terulang', (
      tester,
    ) async {
      await _pumpReplay(tester, resultOf(levels[12]));
      final track = tester.getRect(
        find.descendant(
          of: find.byType(ReplaySlider),
          matching: find.byType(CustomPaint),
        ),
      );
      await tester.tapAt(track.centerRight - const Offset(2, 0));
      await tester.pumpAndSettle();
      expect(_caption(tester).step, 25);
      expect(
        find.text(
          'Balik lagi seperti langkah 7. Oyen muter terus, jadi bosan.',
        ),
        findsOneWidget,
      );
      // 25 langkah tidak muat satu per satu: kelipatan 5.
      final ticks = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(ReplaySlider),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();
      expect(ticks, ['WAKTU', '0', '5', '10', '15', '20', '25']);
      expect(ticks, isNot(contains('1')));
    });
  });

  group('putar otomatis', () {
    Future<void> tapPlay(WidgetTester tester, String label) async {
      await tester.tap(_stepButton(label));
      await tester.pump();
    }

    Rect track(WidgetTester tester) => tester.getRect(
      find.descendant(
        of: find.byType(ReplaySlider),
        matching: find.byType(CustomPaint),
      ),
    );

    testWidgets('maju sendiri per langkah lalu berhenti di akhir', (
      tester,
    ) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tapPlay(tester, 'Putar otomatis');
      expect(_stepButton('Jeda'), findsOneWidget);
      for (var i = 1; i <= 6; i++) {
        await tester.pump(ReplayView.autoStepTime);
        expect(_sliderValue(tester), i);
        expect(_caption(tester).step, i);
      }
      await tester.pump(ReplayView.autoStepTime * 3);
      expect(_sliderValue(tester), 6);
      expect(_stepButton('Putar otomatis'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('bingkai panjang hanya memajukan satu langkah', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime * 4);
      expect(_sliderValue(tester), 1);
      await tapPlay(tester, 'Jeda');
    });

    testWidgets('jeda', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime);
      await tester.pump(ReplayView.autoStepTime);
      expect(_sliderValue(tester), 2);
      await tapPlay(tester, 'Jeda');
      for (var i = 0; i < 3; i++) {
        await tester.pump(ReplayView.autoStepTime);
      }
      expect(_sliderValue(tester), 2);
      expect(_stepButton('Putar otomatis'), findsOneWidget);
    });

    testWidgets('slider dan tombol langkah menghentikan putar otomatis', (
      tester,
    ) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime);
      await tester.pump(ReplayView.autoStepTime);
      await tester.tapAt(track(tester).centerLeft + const Offset(2, 0));
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        await tester.pump(ReplayView.autoStepTime);
      }
      expect(_sliderValue(tester), 0);
      expect(_stepButton('Putar otomatis'), findsOneWidget);

      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime);
      await tapPlay(tester, 'Maju satu langkah');
      for (var i = 0; i < 3; i++) {
        await tester.pump(ReplayView.autoStepTime);
      }
      expect(_sliderValue(tester), 2);
      expect(_stepButton('Putar otomatis'), findsOneWidget);
    });

    testWidgets('di langkah terakhir mulai lagi dari awal', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tester.dragFrom(
        track(tester).centerLeft,
        Offset(track(tester).width, 0),
      );
      await tester.pumpAndSettle();
      expect(_sliderValue(tester), 6);

      await tapPlay(tester, 'Putar otomatis');
      expect(_sliderValue(tester), 0);
      await tester.pump(ReplayView.autoStepTime);
      expect(_sliderValue(tester), 1);
      await tapPlay(tester, 'Jeda');
    });

    testWidgets('kurangi gerak: tanpa tombol putar', (tester) async {
      await _pumpReplay(
        tester,
        resultOf(levels[12], levels[12].solution),
        disableAnimations: true,
      );
      expect(_stepButton('Putar otomatis'), findsNothing);
      expect(find.byType(ReplayPlayButton), findsNothing);
    });

    testWidgets('kurangi gerak dinyalakan saat berputar: berhenti', (
      tester,
    ) async {
      var still = false;
      late StateSetter setOuter;
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        testApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: still),
                child: Scaffold(
                  body: ReplayView(
                    session: resultOf(levels[12], levels[12].solution),
                    onBack: () {},
                    onMap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime);
      expect(_sliderValue(tester), 1);

      setOuter(() => still = true);
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        await tester.pump(ReplayView.autoStepTime);
      }
      expect(_sliderValue(tester), 1);
      expect(find.byType(ReplayPlayButton), findsNothing);
    });

    testWidgets('pembaca layar: label tombol dan caption', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      expect(find.bySemanticsLabel('Putar otomatis'), findsOneWidget);
      expect(_caption(tester).announce, isTrue);

      await tapPlay(tester, 'Putar otomatis');
      expect(find.bySemanticsLabel('Jeda'), findsOneWidget);
      expect(_caption(tester).announce, isFalse);

      await tapPlay(tester, 'Jeda');
      expect(_caption(tester).announce, isTrue);
      semantics.dispose();
    });

    testWidgets('ditutup saat berputar tanpa error', (tester) async {
      await _pumpReplay(tester, resultOf(levels[12], levels[12].solution));
      await tapPlay(tester, 'Putar otomatis');
      await tester.pump(ReplayView.autoStepTime);
      await tester.pumpWidget(testApp(home: const SizedBox()));
      await tester.pump(ReplayView.autoStepTime);
      expect(tester.takeException(), isNull);
    });
  });

  group('angka slider', () {
    test('semua langkah kalau muat', () {
      expect(ReplaySlider.ticks(6, 310, 20), [0, 1, 2, 3, 4, 5, 6]);
      expect(ReplaySlider.ticks(0, 310, 20), [0]);
    });

    test('kelipatan 2, 5, 10, dan langkah terakhir', () {
      expect(ReplaySlider.ticks(12, 310, 24), [
        for (var i = 0; i <= 12; i++) i,
      ]);
      // 24 terlalu dekat dengan 25.
      expect(ReplaySlider.ticks(25, 310, 24), [
        for (var i = 0; i <= 22; i += 2) i,
        25,
      ]);
      expect(ReplaySlider.ticks(25, 310, 28), [0, 5, 10, 15, 20, 25]);
      // Langkah terakhir terlalu dekat dengan kelipatan sebelumnya.
      expect(ReplaySlider.ticks(32, 310, 28), [0, 5, 10, 15, 20, 25, 32]);
      expect(ReplaySlider.ticks(80, 310, 28), [
        for (var i = 0; i <= 80; i += 10) i,
      ]);
    });
  });

  group('dari layar hasil', () {
    Future<void> showResult(WidgetTester tester, int id) async {
      await pumpApp(
        tester,
        location: AppRoutes.level(id, chapter: levels[id - 1].chapter),
      );
      await tester.tap(find.text('Bangunkan Oyen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await pumpFor(tester, const Duration(milliseconds: 1500));
    }

    testWidgets('Berhasil → Tonton putar ulang → kembali ke hasil', (
      tester,
    ) async {
      await showResult(tester, 1);
      expect(find.byType(SuccessResult), findsOneWidget);

      await tester.tap(find.text('Tonton putar ulang'));
      await tester.pumpAndSettle();
      expect(find.byType(ReplayView), findsOneWidget);
      expect(find.byType(SuccessResult), findsNothing);
      expect(find.text('LEVEL 1 · BANGUNKAN OYEN'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is KoIconButton && w.semanticLabel == 'Kembali ke hasil',
        ),
      );
      await pumpFor(tester, const Duration(milliseconds: 100));
      expect(find.byType(ReplayView), findsNothing);
      expect(find.byType(SuccessResult), findsOneWidget);
      expect(find.byType(LevelView), findsOneWidget);
    });

    testWidgets('Oyen bosan → Putar Ulang; tombol kembali sistem', (
      tester,
    ) async {
      await showResult(tester, 13);
      expect(find.byType(BoredResult), findsOneWidget);

      await tester.tap(find.text('Putar Ulang'));
      await tester.pumpAndSettle();
      expect(find.byType(ReplayView), findsOneWidget);

      // Tombol kembali sistem menutup putar ulang, lalu ke fase atur, lalu
      // ke peta.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ReplayView), findsNothing);
      expect(find.byType(BoredResult), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(BoredResult), findsNothing);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.byType(ChapterView), findsOneWidget);
    });

    testWidgets('Kembali ke peta', (tester) async {
      await showResult(tester, 13);
      await tester.tap(find.text('Putar Ulang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kembali ke peta'));
      await settle(tester);
      expect(find.byType(ChapterView), findsOneWidget);
      expect(find.text('Ruang Tamu'), findsOneWidget);
    });

    testWidgets('Atur Lagi sesudah putar ulang: fase atur', (tester) async {
      await showResult(tester, 13);
      await tester.tap(find.text('Putar Ulang'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atur Lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(find.byType(ResultView), findsNothing);
    });
  });
}
