import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/level/rules_sheet.dart';
import 'package:kucing_oren/screens/level/run_panel.dart';
import 'package:kucing_oren/screens/level/tutorial.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Kucing kartu 4 dan overlay tutorial bergerak terus: majukan waktu per
/// bingkai, bukan `pumpAndSettle`.
Future<void> _pumpFor(WidgetTester tester, Duration time) async {
  const frame = Duration(milliseconds: 50);
  for (var t = Duration.zero; t < time; t += frame) {
    await tester.pump(frame);
  }
}

Future<ProgressController> _openLevel(
  WidgetTester tester,
  int id, {
  Map<int, int>? best,
  Set<int>? tutorialsDone,
}) {
  setScreenSize(tester, const Size(390, 844));
  return pumpApp(
    tester,
    location: AppRoutes.level(id, chapter: id <= 10 ? 1 : 2),
    progress: testProgress(best ?? wonUpTo(id - 1), tutorialsDone),
  );
}

Future<void> _openRules(WidgetTester tester) async {
  await tester.tap(find.text('Aturan'));
  await _pumpFor(tester, RulesSheet.openTime * 2);
}

const _titles = {
  'Jatuhkan barang di sebelahnya': 'Barang di meja: ???',
  'Kejar ikan terdekat': 'Ikan: ???',
  'Air? Putar balik': 'Air: ???',
  'Mentok tembok atau meja': 'Tembok: ???',
  'Kardus? Masuk, duduk': 'Kardus: ???',
};

void main() {
  group('kartu aturan', () {
    testWidgets('level 13: empat kartu terbuka, kardus terkunci (desain 05)', (
      tester,
    ) async {
      await _openLevel(tester, 13);
      await _openRules(tester);

      expect(find.text('Aturan Oyen'), findsOneWidget);
      expect(
        find.text(
          'Tiap langkah dicek urut dari atas. Yang pertama cocok, itu yang '
          'dia lakukan.',
        ),
        findsOneWidget,
      );
      for (final title in _titles.keys.take(4)) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text('Kardus: ???'), findsOneWidget);
      expect(
        find.text('Belum dipelajari. Nanti juga kenalan sendiri.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Aturan 5, terkunci, belum dipelajari'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('^Aturan 1\n')), findsOneWidget);

      // Urut desain: jatuhkan barang di atas, kardus di bawah.
      final y = [
        for (final title in _titles.keys.take(4))
          tester.getTopLeft(find.text(title)).dy,
        tester.getTopLeft(find.text('Kardus: ???')).dy,
      ];
      expect(y, orderedEquals([...y]..sort()));

      final cards = tester.widgetList<RuleCard>(find.byType(RuleCard));
      expect(cards.map((c) => c.rule.number), [1, 2, 3, 4, 5]);
      expect(cards.map((c) => c.learned), [true, true, true, true, false]);
    });

    final cases = <int, int>{1: 0, 2: 1, 3: 2, 6: 3, 12: 4, 14: 5};
    for (final MapEntry(key: id, value: open) in cases.entries) {
      testWidgets('level $id: $open kartu terbuka', (tester) async {
        await _openLevel(tester, id);
        await _openRules(tester);
        final learned = {
          for (final c in tester.widgetList<RuleCard>(find.byType(RuleCard)))
            if (c.learned) c.rule.level,
        };
        expect(learned, hasLength(open));
        expect(learned.every((level) => level <= id), isTrue);
      });
    }

    testWidgets('level 20: semua kartu terbuka, kardus dengan teksnya', (
      tester,
    ) async {
      await _openLevel(tester, 20);
      await _openRules(tester);
      for (final MapEntry(key: title, value: locked) in _titles.entries) {
        expect(find.text(title), findsOneWidget, reason: title);
        expect(find.text(locked), findsNothing, reason: locked);
      }
      expect(
        find.text(
          'Duduk 2 langkah sampai kardusnya penyok dan hilang. Ikan di balik '
          'kardus nggak kelihatan.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tombol Tutup menutup sheet', (tester) async {
      await _openLevel(tester, 13);
      await _openRules(tester);
      await tester.tap(find.bySemanticsLabel('Tutup'));
      await _pumpFor(tester, RulesSheet.openTime * 2);
      expect(find.text('Aturan Oyen'), findsNothing);
      expect(find.text('Level 13 · Vas Ibu'), findsOneWidget);
    });

    testWidgets('ketuk latar gelap di atas sheet menutupnya', (tester) async {
      await _openLevel(tester, 13);
      await _openRules(tester);
      await tester.tapAt(const Offset(195, 10));
      await _pumpFor(tester, RulesSheet.openTime * 2);
      expect(find.text('Aturan Oyen'), findsNothing);
    });

    testWidgets('tombol kembali sistem menutup sheet, bukan layar level', (
      tester,
    ) async {
      await _openLevel(tester, 13);
      await _openRules(tester);
      await tester.binding.handlePopRoute();
      await _pumpFor(tester, RulesSheet.openTime * 2);
      expect(find.text('Aturan Oyen'), findsNothing);
      expect(find.text('Level 13 · Vas Ibu'), findsOneWidget);
    });

    testWidgets('tarik ke bawah: jauh menutup, sedikit kembali', (
      tester,
    ) async {
      await _openLevel(tester, 13);
      await _openRules(tester);
      final title = find.text('Aturan Oyen');
      final before = tester.getTopLeft(title);

      await tester.timedDrag(
        title,
        const Offset(0, 30),
        const Duration(milliseconds: 500),
      );
      await _pumpFor(tester, const Duration(milliseconds: 400));
      expect(tester.getTopLeft(title), before);

      await tester.drag(title, const Offset(0, 200));
      await _pumpFor(tester, RulesSheet.openTime * 2);
      expect(title, findsNothing);
    });

    testWidgets('bar atas level tetap terlihat di atas sheet', (tester) async {
      await _openLevel(tester, 20);
      await _openRules(tester);
      final bar = tester.getBottomLeft(
        find.text('Level 20 · BOS: Hari Lebaran'),
      );
      expect(
        tester.getTopLeft(find.text('Aturan Oyen')).dy,
        greaterThan(bar.dy),
      );
    });
  });

  group('tutorial', () {
    const wakeTitle = 'Oyen nggak bisa disuruh. Bangunkan saja dia!';

    testWidgets('level 1: teks desain 11, tombol Bangunkan Oyen disorot', (
      tester,
    ) async {
      final progress = await _openLevel(tester, 1, tutorialsDone: {});
      expect(find.text(wakeTitle), findsOneWidget);
      expect(
        find.text('Dia jalan sendiri ke mangkuknya. Kamu tinggal nonton.'),
        findsOneWidget,
      );
      expect(find.text('Lewati'), findsOneWidget);

      // Di luar sorotan sentuhan ditahan: tombol kembali tidak jalan.
      await tester.tapAt(
        tester.getCenter(find.bySemanticsLabel('Kembali ke peta')),
      );
      await _pumpFor(tester, const Duration(milliseconds: 300));
      expect(find.text('Level 1 · Bangunkan Oyen'), findsOneWidget);
      expect(find.text(wakeTitle), findsOneWidget);

      // Kartu dan tangan di atas tombol yang disorot.
      final button = tester.getRect(find.text('Bangunkan Oyen'));
      final card = tester.getRect(find.text(wakeTitle));
      expect(card.bottom, lessThan(button.top));

      // Di sorotan sentuhan sampai ke tombol: Oyen bangun, tutorial selesai.
      await tester.tap(find.text('Bangunkan Oyen'));
      await tester.pump();
      expect(find.text(wakeTitle), findsNothing);
      expect(find.byType(StepCounter), findsOneWidget);
      expect(progress.isTutorialDone(1), isTrue);
      expect((progress.store as MemoryProgressStore).tutorials, {1});
    });

    testWidgets('Lewati menutup tutorial tanpa membangunkan Oyen', (
      tester,
    ) async {
      final progress = await _openLevel(tester, 1, tutorialsDone: {});
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();
      expect(find.text(wakeTitle), findsNothing);
      expect(find.text('Lewati'), findsNothing);
      expect(find.byType(StepCounter), findsNothing);
      expect(progress.isTutorialDone(1), isTrue);
    });

    testWidgets('hanya muncul sekali: dibuka lagi tanpa tutorial', (
      tester,
    ) async {
      final progress = await _openLevel(tester, 1, tutorialsDone: {});
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();

      // Aplikasi dibuka ulang dengan simpanan yang sama.
      final reopened = await ProgressController.load(
        levels: testLevels,
        store: progress.store,
      );
      await pumpApp(
        tester,
        location: AppRoutes.level(1, chapter: 1),
        progress: reopened,
      );
      expect(find.text(wakeTitle), findsNothing);
      expect(find.text('Lewati'), findsNothing);
    });

    testWidgets('level 3: slot ikan disorot, menyeret ikan menutupnya', (
      tester,
    ) async {
      final progress = await _openLevel(tester, 3, tutorialsDone: {});
      expect(find.text('Oyen nggak tahan bau ikan asin!'), findsOneWidget);

      final slot = find.byWidgetPredicate(
        (w) => w is TraySlot && w.semanticLabel.startsWith('Ikan asin,'),
      );
      final board = tester.getRect(find.byType(GameWidget<KucingGame>));
      final scale = board.width / BoardScene.width;
      final tile = board.topLeft + const Offset(3.5, 5.5) * Tile.size * scale;

      final from = tester.getCenter(slot);
      final gesture = await tester.startGesture(from);
      await tester.pump();
      expect(find.text('Oyen nggak tahan bau ikan asin!'), findsNothing);
      // Event geser pertama masih posisi awal sentuhan.
      for (final t in const [0.25, 0.5, 0.75, 1.0]) {
        await gesture.moveTo(Offset.lerp(from, tile, t)!);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      final game = tester
          .widget<GameWidget<KucingGame>>(find.byType(GameWidget<KucingGame>))
          .game!;
      expect(game.scene.tileAt(const Pos(3, 5)).item, TileItem.fishP);
      expect(progress.isTutorialDone(3), isTrue);
    });

    testWidgets('level 3: tombol Bangunkan Oyen tertutup overlay', (
      tester,
    ) async {
      final progress = await _openLevel(tester, 3, tutorialsDone: {});
      await tester.tapAt(tester.getCenter(find.text('Bangunkan Oyen')));
      await _pumpFor(tester, const Duration(milliseconds: 300));
      expect(find.byType(StepCounter), findsNothing);
      expect(progress.isTutorialDone(3), isFalse);
    });

    testWidgets('level 6: slot ember disorot', (tester) async {
      final progress = await _openLevel(tester, 6, tutorialsDone: {});
      expect(find.text('Oyen takut air. Banget.'), findsOneWidget);
      expect(
        find.text(
          'Taruh ember di jalannya. Ketemu air, dia kaget lalu putar balik.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();
      expect(progress.isTutorialDone(6), isTrue);
      expect(progress.isTutorialDone(1), isFalse);
    });

    for (final id in const [2, 4, 13]) {
      testWidgets('level $id tanpa tutorial', (tester) async {
        await _openLevel(tester, id, tutorialsDone: {});
        expect(find.byType(TutorialOverlay), findsNothing);
      });
    }

    test('tutorial hanya di level 1, 3, dan 6', () {
      expect(tutorialLevels, {1, 3, 6});
      expect(tutorialFor(1)!.item, isNull);
      expect(tutorialFor(3)!.item, Item.fish);
      expect(tutorialFor(6)!.item, Item.water);
    });
  });

  group('gambar', () {
    test('kucing kartu 4: diam, berputar seperempat, diam', () {
      expect(RuleArt.quarterAngle(0), 0);
      expect(RuleArt.quarterAngle(0.3), 0);
      expect(RuleArt.quarterAngle(0.45), closeTo(45, 0.01));
      expect(RuleArt.quarterAngle(0.6), 90);
      expect(RuleArt.quarterAngle(1), 90);
    });

    test('tangan turun 10 px di tengah ketukan', () {
      expect(RuleArt.handOffset(0), 0);
      expect(RuleArt.handOffset(0.5), RuleArt.handBob);
      expect(RuleArt.handOffset(1), 0);
    });
  });
}
