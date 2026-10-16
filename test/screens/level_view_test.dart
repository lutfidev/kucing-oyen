import 'dart:io';

import 'package:flame/game.dart' hide RouterComponent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/run_clock.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/screens/level/level_bar.dart';
import 'package:kucing_oren/screens/level/level_view.dart';
import 'package:kucing_oren/screens/level/run_panel.dart';
import 'package:kucing_oren/screens/level/tray.dart';
import 'package:kucing_oren/screens/result/result_view.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Level dibaca langsung dari berkas, tanpa `rootBundle`.
final _levels = parseLevels(File(chapter1to2Asset).readAsStringSync());

/// Berapa kali "Lanjut" di layar hasil ditekan sejak [_pumpLevel].
var _nextTaps = 0;

Future<void> _pumpLevel(
  WidgetTester tester,
  int id, {
  Size size = const Size(390, 844),
  bool disableAnimations = false,
}) async {
  _nextTaps = 0;
  setScreenSize(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      theme: KoTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: LevelView(
        level: _levels[id - 1],
        backLabel: 'Kembali',
        onBack: () {},
        onNext: () => _nextTaps++,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _board = find.byType(GameWidget<KucingGame>);

KucingGame _game(WidgetTester tester) =>
    tester.widget<GameWidget<KucingGame>>(_board).game!;

Tile _tile(WidgetTester tester, int col, int row) =>
    _game(tester).scene.tileAt(Pos(col, row));

/// Petak yang sedang menyala.
List<Pos> _glowing(WidgetTester tester) => [
  for (var r = 0; r < BoardScene.rows; r++)
    for (var c = 0; c < BoardScene.columns; c++)
      if (_tile(tester, c, r).glow) Pos(c, r),
];

/// Pusat petak (kolom, baris) di layar, mengikuti skala papan.
Offset _tileCenter(WidgetTester tester, int col, int row) {
  final rect = tester.getRect(_board);
  final scale = rect.width / BoardScene.width;
  return rect.topLeft +
      Offset((col + 0.5) * Tile.size, (row + 0.5) * Tile.size) * scale;
}

Finder _slot(Item item) => find.byWidgetPredicate(
  (w) => w is TraySlot && w.semanticLabel.startsWith('${itemName(item)},'),
);

TraySlot _slotOf(WidgetTester tester, Item item) =>
    tester.widget<TraySlot>(_slot(item));

/// Menyeret jari dari [from] ke [to] lewat beberapa titik antara. Tanpa
/// [release], jari tetap menempel di [to].
Future<TestGesture> _drag(
  WidgetTester tester,
  Offset from,
  Offset to, {
  bool release = true,
}) async {
  final gesture = await tester.startGesture(from);
  await tester.pump();
  for (final t in const [0.25, 0.5, 0.75, 1.0]) {
    await gesture.moveTo(Offset.lerp(from, to, t)!);
    await tester.pump();
  }
  if (release) {
    await gesture.up();
    await tester.pump();
  }
  return gesture;
}

/// Menyeret [item] dari baki ke petak (kolom, baris).
Future<TestGesture> _dragToTile(
  WidgetTester tester,
  Item item,
  int col,
  int row, {
  bool release = true,
}) => _drag(
  tester,
  tester.getCenter(_slot(item)),
  _tileCenter(tester, col, row),
  release: release,
);

/// Menyeret benda di papan dari petak [from] ke petak [to].
Future<TestGesture> _dragTile(
  WidgetTester tester,
  (int, int) from,
  (int, int) to, {
  bool release = true,
}) => _drag(
  tester,
  _tileCenter(tester, from.$1, from.$2),
  _tileCenter(tester, to.$1, to.$2),
  release: release,
);

void main() {
  group('tampilan', () {
    testWidgets('level 13: bar atas, target, Oyen tidur, baki, tombol', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      expect(find.text('Level 13 · Vas Ibu'), findsOneWidget);
      expect(find.byType(TargetChip), findsOneWidget);
      expect(find.text('pakai 2 benda'), findsOneWidget);
      expect(find.text('Aturan'), findsOneWidget);
      expect(find.text('Taruh di petak'), findsOneWidget);
      expect(find.text('yang menyala'), findsOneWidget);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(_slotOf(tester, Item.fish).count, 1);
      expect(_slotOf(tester, Item.water).count, 1);
      expect(_slot(Item.box), findsNothing);

      final scene = _game(tester).scene;
      expect(scene.oyen, isNotNull);
      expect((scene.oyen!.col, scene.oyen!.row), (4.0, 3.0));
      expect(
        scene.oyen!.look,
        const OyenLook(
          pose: OyenPose.sleep,
          dir: Direction.left,
          bubble: OyenBubble.zzz,
        ),
      );
      expect(scene.showFacing, isTrue);
      expect(_tile(tester, 2, 3).kind, TileKind.tableVase);
      expect(_glowing(tester), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('papan 350×450 penuh selebar konten di 390×844', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      final rect = tester.getRect(_board);
      // Lebar konten 358 = 390 − 2 × 16, dikurangi bingkai 4 px kiri-kanan.
      expect(rect.width, closeTo(350, 0.01));
      expect(rect.height, closeTo(450, 0.01));
      expect(rect.left, closeTo(20, 0.01));
    });

    testWidgets('tombol Aturan tampil tapi belum berfungsi', (tester) async {
      await _pumpLevel(tester, 13);
      final rules = tester.widget<KoIconButton>(
        find.widgetWithText(KoIconButton, 'Aturan'),
      );
      expect(rules.onPressed, isNull);
    });

    testWidgets('level tanpa benda: pesan di baki, tanpa target bintang', (
      tester,
    ) async {
      await _pumpLevel(tester, 1);
      expect(find.text('Level 1 · Bangunkan Oyen'), findsOneWidget);
      expect(find.text('Level ini belum butuh benda.'), findsOneWidget);
      expect(find.byType(TargetChip), findsNothing);
      expect(find.byType(TraySlot), findsNothing);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
    });

    testWidgets('level 19: tiga jenis benda di baki', (tester) async {
      await _pumpLevel(tester, 19);
      for (final item in Item.values) {
        expect(_slotOf(tester, item).count, 1, reason: item.name);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('seret dari baki', () {
    testWidgets('ikan ke petak menyala: tertaruh, angka baki jadi 0', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      expect(_tile(tester, 2, 4).item, TileItem.fishP);
      expect(_slotOf(tester, Item.fish).count, 0);
      expect(_slotOf(tester, Item.fish).semanticLabel, 'Ikan asin, sisa 0');
      expect(_slotOf(tester, Item.water).count, 1);
      expect(_glowing(tester), isEmpty);
      expect(find.byType(LiftedItemView), findsNothing);
    });

    testWidgets('selama diseret: hanya petak di bawah jari yang menyala', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      final gesture = await _dragToTile(
        tester,
        Item.water,
        3,
        3,
        release: false,
      );
      expect(_glowing(tester), [const Pos(3, 3)]);
      expect(find.byType(LiftedItemView), findsOneWidget);
      // Slot ember: sisa 0 dengan label "sedang diseret" (desain 03).
      final slot = _slotOf(tester, Item.water);
      expect(slot.count, 0);
      expect(slot.semanticLabel, 'Ember air, sedang diseret, sisa 0');

      // Benda di tangan mengikuti jari, sedikit di atasnya.
      final finger = _tileCenter(tester, 3, 3);
      expect(
        tester.getCenter(find.byType(LiftedItemView)),
        offsetMoreOrLessEquals(finger + ItemArt.liftFromFinger),
      );

      // Di atas tembok: tidak ada yang menyala.
      await gesture.moveTo(_tileCenter(tester, 0, 3));
      await tester.pump();
      expect(_glowing(tester), isEmpty);

      await gesture.moveTo(_tileCenter(tester, 3, 3));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(_tile(tester, 3, 3).item, TileItem.bucketP);
      expect(_slotOf(tester, Item.water).semanticLabel, 'Ember air, sisa 0');
    });

    testWidgets('petak tidak sah menolak benda, angka baki tetap', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      // Tembok, meja vas, meja gelas, petak Oyen, mangkuk, petak berisi
      // benda pemain.
      for (final (c, r) in const [
        (0, 3),
        (3, 1),
        (2, 3),
        (1, 4),
        (4, 3),
        (3, 4),
        (2, 4),
      ]) {
        final gesture = await _dragToTile(
          tester,
          Item.water,
          c,
          r,
          release: false,
        );
        expect(_glowing(tester), isEmpty, reason: '($c,$r)');
        await gesture.up();
        await tester.pump();
        expect(_slotOf(tester, Item.water).count, 1, reason: '($c,$r)');
      }
      expect(_tile(tester, 2, 4).item, TileItem.fishP);
      for (final tile in _game(tester).scene.tiles) {
        expect(tile.item, isNot(TileItem.bucketP));
      }
    });

    testWidgets('dilepas di luar papan: kembali ke baki', (tester) async {
      await _pumpLevel(tester, 13);
      await _drag(
        tester,
        tester.getCenter(_slot(Item.fish)),
        tester.getCenter(find.text('Bangunkan Oyen')),
      );
      expect(_slotOf(tester, Item.fish).count, 1);
      expect(find.byType(LiftedItemView), findsNothing);
    });

    testWidgets('slot yang habis tidak bisa diseret', (tester) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      final gesture = await _dragToTile(
        tester,
        Item.fish,
        1,
        5,
        release: false,
      );
      expect(find.byType(LiftedItemView), findsNothing);
      expect(_glowing(tester), isEmpty);
      await gesture.up();
      await tester.pump();
      expect(_tile(tester, 1, 5).item, TileItem.none);
    });
  });

  group('seret di papan', () {
    testWidgets('pindah ke petak lain; petak asal kosong selama diangkat', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      final gesture = await _dragTile(tester, (2, 4), (1, 5), release: false);
      expect(_tile(tester, 2, 4).item, TileItem.none);
      expect(_glowing(tester), [const Pos(1, 5)]);
      expect(find.byType(LiftedItemView), findsOneWidget);
      expect(_slotOf(tester, Item.fish).count, 0);

      await gesture.up();
      await tester.pump();
      expect(_tile(tester, 2, 4).item, TileItem.none);
      expect(_tile(tester, 1, 5).item, TileItem.fishP);
      expect(_slotOf(tester, Item.fish).count, 0);
    });

    testWidgets('ke petak tidak sah: kembali ke petak asal', (tester) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      await _dragToTile(tester, Item.water, 3, 3);
      for (final to in const [(0, 4), (2, 3), (3, 3), (4, 3)]) {
        await _dragTile(tester, (2, 4), to);
        expect(_tile(tester, 2, 4).item, TileItem.fishP, reason: '$to');
      }
      expect(_tile(tester, 3, 3).item, TileItem.bucketP);
      expect(_slotOf(tester, Item.fish).count, 0);
    });

    testWidgets('ke luar papan: kembali ke baki', (tester) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 3, 3);
      expect(_slotOf(tester, Item.water).count, 0);
      await _drag(
        tester,
        _tileCenter(tester, 3, 3),
        tester.getCenter(_slot(Item.water)),
      );
      expect(_tile(tester, 3, 3).item, TileItem.none);
      expect(_slotOf(tester, Item.water).count, 1);
    });

    testWidgets('petak tanpa benda pemain tidak bisa diseret', (tester) async {
      await _pumpLevel(tester, 15);
      // Lantai kosong, Oyen, ikan dan kardus bawaan peta.
      for (final from in const [(3, 5), (2, 6), (1, 4), (2, 4)]) {
        final gesture = await _dragTile(tester, from, (4, 2), release: false);
        expect(find.byType(LiftedItemView), findsNothing, reason: '$from');
        await gesture.up();
        await tester.pump();
      }
      expect(_tile(tester, 1, 4).item, TileItem.fish);
      expect(_tile(tester, 2, 4).item, TileItem.box);
      expect(_tile(tester, 4, 2).item, TileItem.none);
    });

    testWidgets('kardus pemain bisa dipindah (level 14)', (tester) async {
      await _pumpLevel(tester, 14);
      await _dragToTile(tester, Item.box, 2, 5);
      expect(_tile(tester, 2, 5).item, TileItem.boxP);
      await _dragTile(tester, (2, 5), (3, 5));
      expect(_tile(tester, 2, 5).item, TileItem.none);
      expect(_tile(tester, 3, 5).item, TileItem.boxP);
    });
  });

  testWidgets('Kosongkan papan mengembalikan semua benda', (tester) async {
    await _pumpLevel(tester, 13);
    KoIconButton clear() => tester.widget<KoIconButton>(
      find.byWidgetPredicate(
        (w) => w is KoIconButton && w.semanticLabel == 'Kosongkan papan',
      ),
    );
    expect(clear().onPressed, isNull, reason: 'papan masih kosong');

    await _dragToTile(tester, Item.fish, 2, 4);
    await _dragToTile(tester, Item.water, 3, 3);
    expect(clear().onPressed, isNotNull);

    await tester.tap(find.bySemanticsLabel('Kosongkan papan'));
    await tester.pumpAndSettle();
    expect(_tile(tester, 2, 4).item, TileItem.none);
    expect(_tile(tester, 3, 3).item, TileItem.none);
    expect(_slotOf(tester, Item.fish).count, 1);
    expect(_slotOf(tester, Item.water).count, 1);
  });

  testWidgets('layar 360×640: papan mengecil, seretan tetap kena petaknya', (
    tester,
  ) async {
    await _pumpLevel(tester, 13, size: const Size(360, 640));
    expect(tester.getSize(_board).width, lessThan(BoardScene.width));
    await _dragToTile(tester, Item.fish, 2, 4);
    await _dragToTile(tester, Item.water, 3, 3);
    expect(_tile(tester, 2, 4).item, TileItem.fishP);
    expect(_tile(tester, 3, 3).item, TileItem.bucketP);
    await _dragTile(tester, (2, 4), (5, 7));
    expect(_tile(tester, 5, 7).item, TileItem.fishP);
    expect(tester.takeException(), isNull);
  });

  group('kedip petak menyala', () {
    testWidgets('mesin jalan selama ada petak menyala, berhenti sesudahnya', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      expect(_game(tester).paused, isTrue);
      final gesture = await _dragToTile(
        tester,
        Item.fish,
        2,
        4,
        release: false,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(_game(tester).paused, isFalse);
      expect(_game(tester).glowOpacity, lessThan(1));

      await gesture.up();
      await tester.pump();
      await tester.pump();
      expect(_game(tester).paused, isTrue);
      expect(_game(tester).glowOpacity, 1);
    });

    testWidgets('tanpa animasi: petak menyala diam', (tester) async {
      await _pumpLevel(tester, 13, disableAnimations: true);
      final gesture = await _dragToTile(
        tester,
        Item.fish,
        2,
        4,
        release: false,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(_glowing(tester), [const Pos(2, 4)]);
      expect(_game(tester).paused, isTrue);
      expect(_game(tester).glowOpacity, 1);
      await gesture.up();
      await tester.pump();
    });
  });

  group('fase jalan', () {
    /// Menaruh solusi JSON level [id] lewat seretan dari baki.
    Future<void> placeSolution(WidgetTester tester, int id) async {
      for (final p in _levels[id - 1].solution) {
        await _dragToTile(tester, p.item, p.pos.x, p.pos.y);
      }
    }

    Future<void> wake(WidgetTester tester) async {
      await tester.tap(find.text('Bangunkan Oyen'));
      await tester.pump();
    }

    int step(WidgetTester tester) =>
        tester.widget<StepCounter>(find.byType(StepCounter)).step;

    String caption(WidgetTester tester) =>
        tester.widget<RunCaption>(find.byType(RunCaption)).text;

    BoardOyen oyen(WidgetTester tester) => _game(tester).scene.oyen!;

    /// Satu langkah: 0,25 detik.
    Future<void> nextStep(WidgetTester tester) =>
        tester.pump(RunClock.stepTime);

    /// Waktu [duration] berlalu dalam bingkai-bingkai 1/60 detik.
    Future<void> pumpFrames(WidgetTester tester, Duration duration) async {
      const frame = Duration(microseconds: 1000000 ~/ 60);
      for (var t = Duration.zero; t < duration; t += frame) {
        await tester.pump(duration - t < frame ? duration - t : frame);
      }
    }

    /// Layar hasil sampai bintang selesai muncul. Sinar layar Berhasil dan
    /// "PRANG!" bergerak terus, jadi tanpa `pumpAndSettle`.
    Future<void> showResult(WidgetTester tester) =>
        pumpFrames(tester, const Duration(milliseconds: 1500));

    testWidgets('solusi level 13: langkah demi langkah seperti desain 04', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await placeSolution(tester, 13);
      await wake(tester);

      // Langkah 1 langsung tampil: kaget, masih menghadap ember.
      expect(step(tester), 1);
      expect(find.text('Langkah'), findsOneWidget);
      expect(caption(tester), 'Ada air! Oyen kaget, lalu putar balik.');
      expect(find.text('Vas aman'), findsOneWidget);
      expect(find.text('2 benda dipakai'), findsOneWidget);
      expect(find.byType(TargetChip), findsNothing);
      expect(find.text('Aturan'), findsNothing);
      expect(find.byType(TraySlot), findsNothing);
      expect(find.text('Bangunkan Oyen'), findsNothing);
      expect(find.text('Jeda'), findsOneWidget);
      expect(
        oyen(tester),
        BoardOyen.at(
          const Pos(4, 3),
          const OyenLook(
            pose: OyenPose.shock,
            dir: Direction.left,
            bubble: OyenBubble.kaget,
          ),
        ),
      );

      final poses = [oyen(tester).look.pose];
      for (var i = 2; i <= 6; i++) {
        await nextStep(tester);
        expect(step(tester), i);
        poses.add(oyen(tester).look.pose);
      }
      expect(poses, [
        OyenPose.shock,
        OyenPose.walk,
        OyenPose.idle,
        OyenPose.walk,
        OyenPose.walk,
        OyenPose.eat,
      ]);
      expect(caption(tester), 'Sampai di mangkuk! Nyam nyam.');
      expect(oyen(tester).col, 3);
      expect(oyen(tester).row, 4);

      // Langkah terakhir: kontrol diganti "Lihat hasil".
      await tester.pumpAndSettle();
      expect(step(tester), 6);
      expect(find.text('Jeda'), findsNothing);
      expect(find.text('Lihat hasil'), findsOneWidget);
    });

    testWidgets('Oyen digeser ke petak baru selama satu langkah', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await placeSolution(tester, 13);
      await wake(tester);
      await tester.pump();
      expect(_game(tester).oyenShown, const Offset(4, 3));

      // Langkah 2: jalan dari (4,3) ke (5,3).
      await nextStep(tester);
      await tester.pump();
      expect(_game(tester).oyenShown, const Offset(4, 3));
      await tester.pump(RunClock.stepTime ~/ 2);
      expect(
        _game(tester).oyenShown!.dx,
        closeTo(4 + Curves.ease.transform(0.5), 1e-6),
      );
      await tester.pump(RunClock.stepTime ~/ 2);
      expect(_game(tester).oyenShown, const Offset(5, 3));
    });

    testWidgets('Lihat hasil: layar Berhasil menutupi layar level', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await placeSolution(tester, 13);
      await wake(tester);

      // Papan terkunci selama fase jalan.
      final gesture = await _dragTile(tester, (2, 4), (1, 5), release: false);
      expect(find.byType(LiftedItemView), findsNothing);
      await gesture.up();

      await tester.pumpAndSettle();
      // Ketukan ganda sebelum layar dibangun ulang tidak memicu error.
      await tester.tap(find.text('Lihat hasil'));
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Berhasil!'), findsOneWidget);
      expect(find.bySemanticsLabel('3 dari 3 bintang'), findsOneWidget);
      // Layar level tersembunyi di bawahnya, papan tetap di keadaan akhir.
      expect(find.byType(StepCounter), findsNothing);
      expect(_board, findsNothing);
      final hidden = tester.widget<GameWidget<KucingGame>>(
        find.byType(GameWidget<KucingGame>, skipOffstage: false),
      );
      expect(hidden.game!.scene.oyen!.look.pose, OyenPose.eat);
    });

    testWidgets('Berhasil → Ulangi: papan kosong, baki penuh', (tester) async {
      await _pumpLevel(tester, 13);
      await placeSolution(tester, 13);
      await wake(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);

      await tester.tap(find.text('Ulangi'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultView), findsNothing);
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(find.byType(StepCounter), findsNothing);
      expect(_tile(tester, 3, 3).item, TileItem.none);
      expect(_tile(tester, 2, 4).item, TileItem.none);
      expect(_slotOf(tester, Item.fish).count, 1);
      expect(_slotOf(tester, Item.water).count, 1);
      expect(oyen(tester).look.pose, OyenPose.sleep);
      expect(_game(tester).oyenShown, const Offset(4, 3));
      expect(_game(tester).scene.path, isEmpty);
    });

    testWidgets('Berhasil → Lanjut: level berikutnya', (tester) async {
      await _pumpLevel(tester, 1);
      await wake(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);
      await tester.tap(find.text('Lanjut'));
      expect(_nextTaps, 1);
    });

    testWidgets('ikan saja di (2,4): vas pecah di langkah 2', (tester) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      await wake(tester);
      expect(find.text('Vas aman'), findsOneWidget);
      expect(find.text('1 benda dipakai'), findsOneWidget);

      await nextStep(tester);
      expect(caption(tester), 'Waduh! Vas Ibu jatuh dan pecah.');
      expect(find.text('Vas pecah'), findsOneWidget);
      expect(_tile(tester, 2, 3).kind, TileKind.tableBroken);
      expect(oyen(tester).look.pose, OyenPose.knock);
      expect(oyen(tester).look.mirror, isTrue);

      await tester.pumpAndSettle();
      expect(step(tester), 10);
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);
      expect(find.text('Sampai sih...\ntapi vas Ibu?'), findsOneWidget);
      expect(find.text('Pecah di langkah 2'), findsOneWidget);
      expect(find.bySemanticsLabel('1 dari 3 bintang'), findsOneWidget);

      // Coba Lagi: fase atur dengan ikan tetap di (2,4).
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(_tile(tester, 2, 4).item, TileItem.fishP);
      expect(_slotOf(tester, Item.fish).count, 0);
      expect(_tile(tester, 2, 3).kind, TileKind.tableVase);
    });

    testWidgets('vas pecah → Lanjut Saja: level berikutnya', (tester) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      await wake(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);
      await tester.tap(find.text('Lanjut Saja'));
      expect(_nextTaps, 1);
    });

    testWidgets('Oyen bosan, lalu Atur Lagi dengan susunan tetap', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 1, 1);
      await wake(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat hasil'));
      await tester.pumpAndSettle();
      expect(find.text('Oyen bosan mondar-mandir.'), findsOneWidget);
      expect(find.text('Muter terus'), findsOneWidget);

      await tester.tap(find.text('Atur Lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(_tile(tester, 1, 1).item, TileItem.bucketP);
      expect(oyen(tester).look.pose, OyenPose.sleep);
    });

    testWidgets('level 15: ikan dimakan, kardus hilang di papan akhir', (
      tester,
    ) async {
      await _pumpLevel(tester, 15);
      await placeSolution(tester, 15);
      expect(_tile(tester, 2, 4).item, TileItem.box);
      await wake(tester);
      // Tidak ada vas di level 15.
      expect(find.textContaining('Vas'), findsNothing);
      expect(find.text('1 benda dipakai'), findsOneWidget);

      for (var i = 2; i <= 7; i++) {
        await nextStep(tester);
      }
      expect(oyen(tester).look.pose, OyenPose.box);
      expect(_tile(tester, 2, 4).item, TileItem.none);

      await tester.pumpAndSettle();
      expect(step(tester), 12);
      for (final pos in const [Pos(1, 4), Pos(2, 3), Pos(2, 4)]) {
        expect(_tile(tester, pos.x, pos.y).item, TileItem.none, reason: '$pos');
      }
      expect(oyen(tester).col, 2);
      expect(oyen(tester).row, 7);
    });

    testWidgets('Jeda menahan langkah; Lanjutkan meneruskan', (tester) async {
      await _pumpLevel(tester, 13);
      await wake(tester);
      await tester.tap(find.bySemanticsLabel('Jeda'));
      await tester.pump();
      expect(find.text('Lanjutkan'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(step(tester), 1);

      await tester.tap(find.bySemanticsLabel('Lanjutkan'));
      await tester.pump();
      expect(find.text('Jeda'), findsOneWidget);
      await nextStep(tester);
      expect(step(tester), 2);
    });

    testWidgets('Maju satu langkah: jeda lalu langkah berikutnya', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await wake(tester);
      await tester.tap(find.bySemanticsLabel('Maju satu langkah'));
      await tester.pump();
      expect(step(tester), 2);
      expect(find.text('Lanjutkan'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(step(tester), 2);
    });

    testWidgets('×2: 8 langkah per detik, Oyen digeser lebih cepat', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await wake(tester);
      final fast = find.bySemanticsLabel('Percepat dua kali');
      expect(
        tester.getSemantics(fast),
        isSemantics(isToggled: false, hasToggledState: true),
      );
      await tester.tap(fast);
      await tester.pump();
      expect(
        tester.getSemantics(fast),
        isSemantics(isToggled: true, hasToggledState: true),
      );
      expect(_game(tester).moveTime, 0.125);

      await pumpFrames(tester, const Duration(milliseconds: 500));
      expect(step(tester), 5);

      await tester.tap(fast);
      await tester.pump();
      expect(_game(tester).moveTime, 0.25);
      await pumpFrames(tester, const Duration(milliseconds: 500));
      expect(step(tester), 7);
    });

    testWidgets('bingkai yang tersendat tidak melompati langkah', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await wake(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(step(tester), 2);
    });

    testWidgets('kembali di fase jalan: ke fase atur, susunan tetap', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 3, 3);
      await wake(tester);
      await nextStep(tester);
      await tester.tap(find.bySemanticsLabel('Kembali ke fase atur'));
      await tester.pumpAndSettle();
      expect(find.text('Bangunkan Oyen'), findsOneWidget);
      expect(_tile(tester, 3, 3).item, TileItem.bucketP);
      expect(oyen(tester), BoardScene.fromMap(_levels[12].map).oyen);
      expect(_game(tester).paused, isTrue);
    });

    testWidgets('tanpa animasi: langsung ke keadaan akhir', (tester) async {
      await _pumpLevel(tester, 13, disableAnimations: true);
      await placeSolution(tester, 13);
      await wake(tester);
      expect(step(tester), 6);
      expect(find.text('Lihat hasil'), findsOneWidget);
      expect(oyen(tester).look.pose, OyenPose.eat);
      await tester.pump();
      expect(_game(tester).oyenShown, const Offset(3, 4));
      expect(_game(tester).paused, isTrue);
    });

    testWidgets('level tanpa benda: tanpa chip status', (tester) async {
      await _pumpLevel(tester, 1);
      await wake(tester);
      expect(find.byType(RunStatus), findsNothing);
      await tester.pumpAndSettle();
      expect(step(tester), _levels[0].solutionSteps);
    });

    testWidgets('papan tetap seukuran dari fase atur sampai hasil', (
      tester,
    ) async {
      await _pumpLevel(tester, 13, size: const Size(360, 640));
      await placeSolution(tester, 13);
      final size = tester.getSize(_board);
      expect(size.width, lessThan(BoardScene.width));

      await wake(tester);
      expect(tester.getSize(_board), size);
      await tester.pumpAndSettle();
      expect(tester.getSize(_board), size);
      await tester.tap(find.text('Lihat hasil'));
      await showResult(tester);
      await tester.tap(find.text('Ulangi'));
      await tester.pumpAndSettle();
      expect(tester.getSize(_board), size);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dibangunkan saat benda diseret: seretan batal', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      final gesture = await _dragToTile(
        tester,
        Item.fish,
        2,
        4,
        release: false,
      );
      // Tombol tetap aktif seperti desain 03; ditekan dengan jari lain.
      await wake(tester);
      expect(find.byType(LiftedItemView), findsNothing);
      expect(step(tester), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_tile(tester, 2, 4).item, TileItem.none);
      expect(_glowing(tester), isEmpty);
    });
  });

  group('seretan batal', () {
    testWidgets('kosongkan papan saat benda diangkat: seretan batal', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.fish, 2, 4);
      final gesture = await _dragTile(tester, (2, 4), (1, 5), release: false);
      await tester.tap(find.bySemanticsLabel('Kosongkan papan'));
      await tester.pump();
      expect(find.byType(LiftedItemView), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_tile(tester, 1, 5).item, TileItem.none);
      expect(_tile(tester, 2, 4).item, TileItem.none);
      expect(_slotOf(tester, Item.fish).count, 1);
    });

    testWidgets('layar ditutup saat benda diseret: tanpa error', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 3, 3);
      final fromTray = await _dragToTile(
        tester,
        Item.fish,
        2,
        4,
        release: false,
      );
      await tester.pumpWidget(const SizedBox());
      await fromTray.moveBy(const Offset(10, 10));
      await fromTray.up();
      await tester.pump();
      expect(tester.takeException(), isNull);

      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 3, 3);
      final fromBoard = await _dragTile(tester, (3, 3), (1, 5), release: false);
      await tester.pumpWidget(const SizedBox());
      await fromBoard.moveBy(const Offset(10, 10));
      await fromBoard.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('jari dari seretan yang batal tidak menggeser seretan baru', (
      tester,
    ) async {
      await _pumpLevel(tester, 13);
      await _dragToTile(tester, Item.water, 3, 3);
      final first = await _dragToTile(tester, Item.fish, 2, 4, release: false);
      await tester.tap(find.bySemanticsLabel('Kosongkan papan'));
      await tester.pump();

      final second = await _dragToTile(
        tester,
        Item.water,
        1,
        5,
        release: false,
      );
      await first.moveTo(_tileCenter(tester, 5, 7));
      await tester.pump();
      expect(_glowing(tester), [const Pos(1, 5)]);

      await first.up();
      await tester.pump();
      expect(find.byType(LiftedItemView), findsOneWidget);
      await second.up();
      await tester.pumpAndSettle();
      expect(_tile(tester, 1, 5).item, TileItem.bucketP);
      expect(_tile(tester, 5, 7).item, TileItem.none);
      expect(_slotOf(tester, Item.fish).count, 1);
    });
  });
}
