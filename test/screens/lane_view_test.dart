import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/screens/lane/lane_scene.dart';
import 'package:kucing_oren/screens/room/lane_camera.dart';
import 'package:kucing_oren/screens/room/room_reaction.dart';
import 'package:kucing_oren/screens/room/room_view.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// 03.00: hanya kunjungan paksa yang datang (jadwal 08.00–22.00).
final _night = DateTime(2026, 11, 23, 3);

Future<ProgressController> _pump(
  WidgetTester tester, {
  DateTime Function()? clock,
  bool metNeighbor = false,
  GameAudio? audio,
}) async {
  setScreenSize(tester, const Size(390, 844));
  return pumpApp(
    tester,
    progress: testProgressWith(
      best: const {1: 3},
      clock: clock ?? () => _night,
      metNeighbor: metNeighbor,
      needs: HomeNeeds(rewardDays: {KittyId.oyen: dayNumber(_night)}),
    ),
    audio: audio,
    // Seed 2: Oyen di ruang tengah saat kunjungan paksa datang.
    roomRandom: () => Random(2),
    roomLife: true,
  );
}

Future<bool> _until(
  WidgetTester tester,
  bool Function() done, {
  Duration max = const Duration(seconds: 40),
}) async {
  const frame = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < max; t += frame) {
    if (done()) return true;
    await tester.pump(frame);
  }
  return done();
}

Finder get _kumis => find.byKey(const ValueKey('lane-kumis'));
Finder get _oyen => find.byKey(const ValueKey('lane-oyen'));
Finder get _marker => find.byKey(const ValueKey('lane-marker'));
bool _found(Finder f) => f.evaluate().isNotEmpty;

/// Ketuk pintu depan dan selesaikan kamera.
Future<void> _toLane(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('front-door')));
  for (var ms = 0; ms <= laneCameraMs + 50; ms += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump();
  expect(find.byType(LaneScene), findsOneWidget);
}

/// Pulang lewat chip dan selesaikan kamera.
Future<void> _home(WidgetTester tester) async {
  await tester.tap(find.text(l10nId.roomName('living')));
  for (var ms = 0; ms <= laneCameraMs + 50; ms += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump();
}

/// Tunggu Oyen menyelinap (kunjungan paksa sesudah 20 detik).
Future<void> _followTail(WidgetTester tester) async {
  expect(await _until(tester, () => _found(_marker)), isTrue);
}

void main() {
  testWidgets('ikuti ekor: Kumis masih ada, pertemuan pertama tersimpan', (
    tester,
  ) async {
    final progress = await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    expect(_kumis, findsOneWidget);
    expect(_oyen, findsOneWidget);
    expect(progress.metNeighbor, isFalse);
    expect(await _until(tester, () => progress.metNeighbor), isTrue);
    await tester.pump();
    expect(progress.hasUnsavedChanges, isFalse);
  });

  testWidgets('pertemuan pertama: kepulan endus muncul lalu hilang', (
    tester,
  ) async {
    final progress = await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    final puff = find.byType(LanePuffView);
    expect(puff, findsNothing);
    expect(await _until(tester, () => _found(puff)), isTrue);
    expect(progress.metNeighbor, isFalse);
    expect(await _until(tester, () => !_found(puff)), isTrue);
    expect(await _until(tester, () => progress.metNeighbor), isTrue);
  });

  testWidgets('kamera berangkat: penanda gang tidak ikut diperbesar', (
    tester,
  ) async {
    await _pump(tester);
    await _followTail(tester);
    await tester.tap(find.byKey(const ValueKey('front-door')));
    for (var ms = 0; ms < laneCameraMs - 100; ms += 16) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(_marker, findsNothing, reason: 'di $ms ms');
    }
  });

  testWidgets('pulang lewat chip sebelum duduk bersama: belum bertemu', (
    tester,
  ) async {
    final progress = await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await _home(tester);
    await _until(tester, () => false, max: const Duration(seconds: 15));
    expect(progress.metNeighbor, isFalse);
  });

  testWidgets('tombol kembali sistem di tengah pertemuan: belum bertemu', (
    tester,
  ) async {
    final progress = await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    await tester.binding.handlePopRoute();
    await _until(tester, () => false, max: const Duration(seconds: 15));
    expect(progress.metNeighbor, isFalse);
  });

  testWidgets('membuka Toko di tengah pertemuan: belum bertemu', (
    tester,
  ) async {
    final progress = await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    await tester.tap(find.text(l10nId.shop));
    await _until(tester, () => false, max: const Duration(seconds: 15));
    expect(progress.metNeighbor, isFalse);
  });

  testWidgets('di gang melewati akhir jadwal: Kumis tetap, pulang = selesai', (
    tester,
  ) async {
    var now = _night;
    await _pump(tester, clock: () => now, metNeighbor: true);
    // Sudah pernah bertemu: tidak ada kunjungan paksa, jadi mulai di
    // tengah kunjungan terjadwal pertama hari itu.
    final visit = laneVisitsOn(_night).first;
    now = visit.start.add(const Duration(seconds: 5));
    await tester.pump(roomRefreshInterval);
    await _until(tester, () => _found(_marker));
    await _toLane(tester);
    expect(_kumis, findsOneWidget);
    // 20 menit di gang, jam maju bersama penyegaran.
    for (var i = 0; i < 40; i++) {
      now = now.add(roomRefreshInterval);
      await tester.pump(roomRefreshInterval);
    }
    expect(_kumis, findsOneWidget);
    await _home(tester);
    now = now.add(const Duration(minutes: 2));
    await tester.pump(roomRefreshInterval);
    expect(
      await _until(tester, () => !_found(_marker)),
      isTrue,
      reason: 'Oyen pulang',
    );
    await _toLane(tester);
    expect(_kumis, findsNothing);
    expect(_oyen, findsNothing);
  });

  testWidgets('gang tanpa kunjungan: tanpa kucing', (tester) async {
    await _pump(tester, metNeighbor: true);
    await _toLane(tester);
    expect(_kumis, findsNothing);
    expect(_oyen, findsNothing);
  });

  testWidgets('ketuk Kumis: meong dan hati, tanpa kartu', (tester) async {
    final audio = testAudio();
    await _pump(tester, audio: audio);
    await _followTail(tester);
    await _toLane(tester);
    await _until(tester, () => false, max: const Duration(seconds: 6));
    playedBy(audio).clear();
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(
      find.semantics.byLabel(l10nId.neighborTapHint('Kumis')),
    );
    semantics.dispose();
    await tester.pump();
    expect(playedBy(audio), contains(GameSound.meow));
    expect(find.byType(ReactionOverlay), findsOneWidget);
    expect(find.bySemanticsLabel('Tutup kartu'), findsNothing);
  });

  testWidgets('ketuk Oyen di gang: kartu tanpa tombol ajak', (tester) async {
    await _pump(tester);
    await _followTail(tester);
    await _toLane(tester);
    await _until(tester, () => false, max: const Duration(seconds: 6));
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(
      find.semantics.byLabel(RegExp(r'^Oyen.*Ketuk untuk lihat kartunya$')),
    );
    semantics.dispose();
    await tester.pump();
    expect(find.bySemanticsLabel('Tutup kartu'), findsOneWidget);
    expect(find.byKey(const ValueKey('kitty-invite')), findsNothing);
    expect(find.text(l10nId.kittyInRoom('lane')), findsOneWidget);
  });

  testWidgets('dibuka di tengah kunjungan: keduanya di bangku tanpa ekor', (
    tester,
  ) async {
    final visit = laneVisitsOn(_night).first;
    final now = visit.start.add(const Duration(minutes: 1));
    await _pump(tester, clock: () => now, metNeighbor: true);
    expect(find.byKey(const ValueKey('kumis-tail')), findsNothing);
    await _toLane(tester);
    expect(_kumis, findsOneWidget);
    expect(_oyen, findsOneWidget);
    // Di bangku: kaki di dudukan (y desain 396,5).
    final area = tester.getRect(find.byType(LaneScene));
    final seat = area.top + laneBenchLeft.y * area.height / 652;
    for (final f in [_kumis, _oyen]) {
      final box = tester.getRect(f);
      expect(box.top + box.height * 0.92, closeTo(seat, 1));
    }
  });

  testWidgets('kurangi gerak: sprite gang diam', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final visit = laneVisitsOn(_night).first;
    final now = visit.start.add(const Duration(minutes: 1));
    await _pump(tester, clock: () => now, metNeighbor: true);
    await tester.tap(find.byKey(const ValueKey('front-door')));
    await tester.pump();
    await tester.pump(Duration(milliseconds: laneFadeMs.toInt()));
    await tester.pump();
    final views = tester.widgetList<KittyView>(
      find.descendant(of: _kumis, matching: find.byType(KittyView)),
    );
    expect(views, isNotEmpty);
    expect(views.every((v) => v.look.time == null), isTrue);
  });

  group('temuan review', () {
    /// Aplikasi ke latar belakang lalu kembali (urutan siklus hidup).
    Future<void> background(WidgetTester tester) async {
      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
    }

    Future<void> resume(WidgetTester tester) async {
      for (final state in const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
    }

    testWidgets('menyusul di tengah momen ekor: Oyen di gang = Oyen di luar', (
      tester,
    ) async {
      await _pump(tester);
      expect(
        await _until(
          tester,
          () => _found(find.byKey(const ValueKey('kumis-tail'))),
        ),
        isTrue,
      );
      await _toLane(tester);
      // Tepat sesudah kamera: Oyen di rumah belum sempat keluar sendiri.
      final semantics = tester.ensureSemantics();
      tester.semantics.tap(
        find.semantics.byLabel(RegExp(r'^Oyen.*Ketuk untuk lihat kartunya$')),
      );
      semantics.dispose();
      await tester.pump();
      expect(find.byKey(const ValueKey('kitty-invite')), findsNothing);
      expect(find.text(l10nId.kittyInRoom('lane')), findsOneWidget);
    });

    testWidgets('kurangi gerak: kunjungan yang mulai saat aplikasi terbuka '
        'tetap terlihat di gang', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      var now = _night;
      await _pump(tester, clock: () => now, metNeighbor: true);
      now = laneVisitsOn(_night).first.start.add(const Duration(seconds: 5));
      await tester.pump(roomRefreshInterval);
      expect(_marker, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('front-door')));
      await tester.pump();
      await tester.pump(Duration(milliseconds: laneFadeMs.toInt()));
      await tester.pump();
      final area = tester.getRect(find.byType(LaneScene));
      final seat = area.top + laneBenchLeft.y * area.height / 652;
      for (final f in [_kumis, _oyen]) {
        final box = tester.getRect(f);
        expect(box.top + box.height * 0.92, closeTo(seat, 1));
      }
      expect(
        find.descendant(
          of: _kumis,
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity == 0,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('latar belakang di gang: kunjungan tidak ditahan, kembali = '
        'gang kosong dan Oyen di rumah', (tester) async {
      final visit = laneVisitsOn(_night).first;
      var now = visit.start.add(const Duration(minutes: 1));
      await _pump(tester, clock: () => now, metNeighbor: true);
      await _toLane(tester);
      expect(_kumis, findsOneWidget);
      await background(tester);
      for (var i = 0; i < 60; i++) {
        now = now.add(roomRefreshInterval);
        await tester.pump(roomRefreshInterval);
      }
      await resume(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(_kumis, findsNothing);
      expect(_oyen, findsNothing);
      await _home(tester);
      expect(_marker, findsNothing);
      expect(find.byKey(const ValueKey('passing-oyen')), findsNothing);
    });

    testWidgets('kunjungan mulai saat aplikasi di latar belakang: kembali = '
        'Oyen sudah di luar, tanpa ekor', (tester) async {
      var now = _night;
      await _pump(tester, clock: () => now, metNeighbor: true);
      await background(tester);
      now = laneVisitsOn(_night).first.start.add(const Duration(minutes: 1));
      await tester.pump(roomRefreshInterval);
      await resume(tester);
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 30; i++) {
        expect(find.byKey(const ValueKey('kumis-tail')), findsNothing);
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(_marker, findsOneWidget);
    });

    testWidgets('kunjungan paksa tidak terpakai saat pemain di gang', (
      tester,
    ) async {
      await _pump(tester);
      await _toLane(tester);
      await _until(tester, () => false, max: const Duration(seconds: 25));
      expect(_kumis, findsNothing);
      await _home(tester);
      expect(
        await _until(
          tester,
          () => _found(find.byKey(const ValueKey('kumis-tail'))),
        ),
        isTrue,
      );
    });
  });
}
