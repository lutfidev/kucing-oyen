import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/chapter/chapter_intro.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/chapter/map_token.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'result_fixtures.dart';

/// Menaruh [placements] lewat seretan dari baki ke petaknya.
Future<void> _place(WidgetTester tester, List<Placement> placements) async {
  final board = tester.getRect(find.byType(GameWidget<KucingGame>));
  final scale = board.width / BoardScene.width;
  for (final Placement(:item, :pos) in placements) {
    final slot = find.byWidgetPredicate(
      (w) =>
          w is TraySlot &&
          w.semanticLabel.startsWith('${itemName(l10nId, item)},'),
    );
    final target =
        board.topLeft +
        Offset((pos.x + 0.5) * Tile.size, (pos.y + 0.5) * Tile.size) * scale;
    final gesture = await tester.startGesture(tester.getCenter(slot));
    await tester.pump();
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }
}

/// Membangunkan Oyen, memutar sampai selesai, lalu membuka layar hasil.
/// Peta di bawah layar level tertutup, jadi denyutnya diam dan
/// `pumpAndSettle` selesai; sinar layar Berhasil berputar terus.
Future<void> _play(WidgetTester tester) async {
  await tester.tap(find.text('Bangunkan Oyen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Lihat hasil'));
  await pumpFor(tester, const Duration(milliseconds: 1500));
}

Finder _back(String label) => find.byWidgetPredicate(
  (w) => w is KoIconButton && w.semanticLabel == label,
);

void main() {
  testWidgets('menang di level 1: tersimpan, Lanjut ke level 2 yang terbuka', (
    tester,
  ) async {
    final store = MemoryProgressStore()..language = AppLanguage.id;
    final progress = ProgressController(
      levels: testLevels,
      store: store,
      language: AppLanguage.id,
    );
    await pumpApp(tester, location: AppRoutes.chapter(1), progress: progress);
    expect(find.bySemanticsLabel('Level 2, terkunci'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Level 1, main sekarang'));
    await settle(tester);
    await _play(tester);
    expect(find.text('Berhasil!'), findsOneWidget);
    expect(progress.progress.starsOf(1), 3);
    expect(store.saved.starsOf(1), 3);

    await tester.tap(find.text('Lanjut'));
    await settle(tester);
    expect(find.text('Level 2 · Belok Kanan'), findsOneWidget);

    await tester.tap(_back('Kembali ke peta'));
    await settle(tester);
    expect(find.bySemanticsLabel('Level 1, 3 bintang'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 2, main sekarang'), findsOneWidget);
    expect(find.bySemanticsLabel('3 dari 30 bintang'), findsOneWidget);
  });

  testWidgets('Oyen bosan: tidak dicatat, level berikutnya tetap terkunci', (
    tester,
  ) async {
    final store = MemoryProgressStore(testProgress(wonUpTo(12)).progress)
      ..language = AppLanguage.id;
    final progress = await ProgressController.load(
      levels: testLevels,
      store: store,
    );
    await pumpApp(
      tester,
      location: AppRoutes.level(13, chapter: 2),
      progress: progress,
    );
    await _play(tester);
    expect(find.text('Atur Lagi'), findsOneWidget);
    expect(progress.progress.isWon(13), isFalse);
    expect(store.saves, 0);

    await tester.tap(find.text('Atur Lagi'));
    await tester.pumpAndSettle();
    await tester.tap(_back('Kembali ke peta'));
    await settle(tester);
    expect(find.bySemanticsLabel('Level 13, main sekarang'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 14, terkunci'), findsOneWidget);
  });

  testWidgets('vas pecah tetap menang (1 bintang); hasil lebih baik dicatat', (
    tester,
  ) async {
    final progress = testProgress(wonUpTo(12));
    await pumpApp(
      tester,
      location: AppRoutes.level(13, chapter: 2),
      progress: progress,
    );
    await _place(tester, fishOnly);
    await _play(tester);
    expect(progress.progress.starsOf(13), 1);
    expect(progress.progress.isUnlocked(14), isTrue);
    final before = progress.coins;
    expect(find.text('+10'), findsOneWidget);

    // Coba lagi dengan solusi: 3 bintang menggantikan 1 bintang.
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    await _place(tester, [
      for (final p in testLevels[12].solution)
        if (!fishOnly.contains(p)) p,
    ]);
    await _play(tester);
    expect(progress.progress.starsOf(13), 3);
    expect(find.text('+20'), findsOneWidget);
    expect(progress.coins, before + 20);
  });

  testWidgets('koin: menang pertama +30, ulang tanpa koin, saldo di Beranda', (
    tester,
  ) async {
    final progress = testProgress();
    await pumpApp(
      tester,
      location: AppRoutes.level(1, chapter: 1),
      progress: progress,
    );
    await _play(tester);
    expect(find.text('+30'), findsOneWidget);
    expect(progress.coins, 30);
    expect((progress.store as MemoryProgressStore).coins, 30);

    await tester.tap(find.text('Ulangi'));
    await tester.pumpAndSettle();
    await _play(tester);
    expect(find.text('Berhasil!'), findsOneWidget);
    expect(find.text('koin'), findsNothing);
    expect(progress.coins, 30);

    // Aplikasi dibuka ulang dengan progres yang sama: Beranda.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, progress: progress);
    expect(
      find.bySemanticsLabel('30 koin, tambah koin, bonus harian siap'),
      findsOneWidget,
    );
  });

  group('Lanjut: Oyen berjalan di peta', () {
    /// Menang di level [id] (solusi data level) lalu mengetuk "Lanjut".
    Future<ProgressController> winAndNext(
      WidgetTester tester,
      int id, {
      required Map<int, int> best,
    }) async {
      final progress = testProgress(best);
      await pumpApp(
        tester,
        location: AppRoutes.level(id, chapter: testLevels[id - 1].chapter),
        progress: progress,
      );
      await _place(tester, testLevels[id - 1].solution);
      await _play(tester);
      expect(find.text('Berhasil!'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pump();
      await tester.pump();
      return progress;
    }

    testWidgets('peta tampil dulu, lalu level berikutnya terbuka sendiri', (
      tester,
    ) async {
      await winAndNext(tester, 1, best: {});
      expect(find.byType(ChapterView), findsOneWidget);
      expect(find.byType(LevelView), findsNothing);
      expect(find.byType(MapToken), findsOneWidget);
      await pumpFor(tester, const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();
      expect(find.text('Level 2 · Belok Kanan'), findsOneWidget);

      await tester.tap(_back('Kembali ke peta'));
      await settle(tester);
      expect(find.byType(LevelView), findsNothing);
      expect(find.bySemanticsLabel('Level 2, main sekarang'), findsOneWidget);
    });

    testWidgets('ketukan selama Oyen berjalan: tetap di peta', (tester) async {
      await winAndNext(tester, 1, best: {});
      await pumpFor(tester, const Duration(milliseconds: 500));
      await tester.tapAt(const Offset(200, 500));
      await pumpFor(tester, const Duration(seconds: 3));
      expect(find.byType(LevelView), findsNothing);
      expect(find.bySemanticsLabel('Level 2, main sekarang'), findsOneWidget);
    });

    testWidgets('level lama: membuka level sesudahnya, peta kembali normal', (
      tester,
    ) async {
      await winAndNext(tester, 3, best: wonUpTo(8));
      await pumpFor(tester, const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();
      expect(find.text('Level 4 · Ikan Terdekat'), findsOneWidget);

      await tester.tap(_back('Kembali ke peta'));
      await settle(tester);
      expect(find.bySemanticsLabel('Level 9, main sekarang'), findsOneWidget);
    });

    testWidgets('sesudah level 10 pertama kali: Babak 2 dan kartu babak baru', (
      tester,
    ) async {
      await winAndNext(tester, 10, best: wonUpTo(9));
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(find.text('Ruang Tamu'), findsWidgets);
      expect(find.byType(ChapterIntroCard), findsOneWidget);
      expect(find.text('10 level baru · Bos: Hari Lebaran'), findsOneWidget);
      await tester.tap(find.text('Ayo masuk!'));
      await pumpFor(tester, const Duration(seconds: 3));
      expect(find.byType(ChapterIntroCard), findsNothing);
      expect(find.byType(LevelView), findsNothing);
      expect(find.bySemanticsLabel('Level 11, main sekarang'), findsOneWidget);
    });

    testWidgets('level 10 diulang: Babak 2 tanpa kartu, tanpa buka', (
      tester,
    ) async {
      await winAndNext(tester, 10, best: wonUpTo(12));
      await pumpFor(tester, const Duration(seconds: 3));
      expect(find.text('Ruang Tamu'), findsWidgets);
      expect(find.byType(ChapterIntroCard), findsNothing);
      expect(find.byType(LevelView), findsNothing);
    });

    testWidgets('sesudah level 20: Oyen di bos, tanpa buka', (tester) async {
      final progress = await winAndNext(tester, 20, best: wonUpTo(19));
      await pumpFor(tester, const Duration(seconds: 3));
      expect(find.byType(ChapterView), findsOneWidget);
      expect(find.byType(LevelView), findsNothing);
      expect(
        find.bySemanticsLabel('Level 20, bos Hari Lebaran, 3 bintang'),
        findsOneWidget,
      );
      expect(progress.progress.totalStars, 60);
    });
  });

  testWidgets('progres dimuat lagi saat aplikasi dibuka ulang', (tester) async {
    final store = MemoryProgressStore()..language = AppLanguage.id;
    await pumpApp(
      tester,
      location: AppRoutes.level(1, chapter: 1),
      progress: ProgressController(
        levels: testLevels,
        store: store,
        language: AppLanguage.id,
      ),
    );
    await _play(tester);

    // Buka ulang: progres baru dari simpanan yang sama.
    await tester.pumpWidget(const SizedBox());
    final reopened = await ProgressController.load(
      levels: testLevels,
      store: store,
    );
    await pumpApp(tester, progress: reopened);
    expect(find.bySemanticsLabel('3 dari 60 bintang'), findsOneWidget);
  });
}
