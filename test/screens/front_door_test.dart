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
import 'package:kucing_oren/screens/room/front_door.dart';

import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

/// Jam test: 03.00, jauh dari jadwal kunjungan (08.00–22.00), jadi hanya
/// kunjungan paksa yang datang.
final _night = DateTime(2026, 11, 23, 3);

/// Kamar hidup seukuran desain dengan level 1 menang (gang terbuka).
Future<ProgressController> _pump(
  WidgetTester tester, {
  DateTime Function()? clock,
  Map<int, int> best = const {1: 3},
  bool metNeighbor = false,
  GameAudio? audio,
}) async {
  setScreenSize(tester, const Size(390, 844));
  return pumpApp(
    tester,
    progress: testProgressWith(
      best: best,
      clock: clock ?? () => _night,
      metNeighbor: metNeighbor,
      // Hadiah Oyen hari ini sudah diambil: ikon hadiah tidak menggantikan
      // penanda "Oyen di gang".
      needs: HomeNeeds(rewardDays: {KittyId.oyen: dayNumber(_night)}),
    ),
    audio: audio,
    // Seed 2: Oyen tetap di ruang tengah sampai kunjungan paksa datang.
    roomRandom: () => Random(2),
    roomLife: true,
  );
}

/// Pompa per 100 ms sampai [done] atau [max] habis.
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

Finder get _tail => find.byKey(const ValueKey('kumis-tail'));
Finder get _marker => find.byKey(const ValueKey('lane-marker'));
Finder get _passing => find.byKey(const ValueKey('passing-oyen'));

/// Oyen terlihat di rumah: sprite sendiri atau di dalam barang (mangkuk).
bool _oyenShown() =>
    kittyView(KittyId.oyen).evaluate().isNotEmpty ||
    find
        .byWidgetPredicate(
          (w) => w is RoomItemView && w.user?.kitty == KittyId.oyen,
        )
        .evaluate()
        .isNotEmpty;

void main() {
  group('linimasa pintu kucing', () {
    test('ekor 1,2 detik, menoleh 0,8 detik, mereda 0,8 detik', () {
      expect(tailPhaseAt(0), TailPhase.tail);
      expect(tailPhaseAt(1.3), TailPhase.notice);
      expect(tailPhaseAt(2.1), TailPhase.settle);
      expect(tailPhaseAt(tailMomentSeconds), isNull);
      expect(tailVisibleAt(1.9), isTrue);
      expect(tailVisibleAt(2.1), isFalse);
    });

    test('pintu kucing 20° → sekitar 9° → 0° (desain 4c)', () {
      expect(tailFlapAt(0.5), tailFlapDeg);
      expect(tailFlapAt(2.0 + tailSettleSeconds / 2), closeTo(9, 0.5));
      expect(tailFlapAt(tailMomentSeconds), closeTo(0, 1e-9));
    });

    test('ayunan sesudah Oyen lewat mulai dari sudutnya lalu diam', () {
      expect(flapSwingAt(0, flapOutDeg), flapOutDeg);
      expect(flapSwingAt(flapSwingSeconds, flapOutDeg), 0);
      expect(flapSwingAt(flapSwingSeconds / 2, flapInDeg).abs(), lessThan(12));
    });
  });

  testWidgets('kunjungan paksa: ekor, Oyen menyelinap, lalu penanda', (
    tester,
  ) async {
    final audio = testAudio();
    await _pump(tester, audio: audio);
    expect(_tail, findsNothing);
    expect(await _until(tester, () => _tail.evaluate().isNotEmpty), isTrue);
    expect(playedBy(audio), contains(GameSound.meow));
    expect(await _until(tester, () => _passing.evaluate().isNotEmpty), isTrue);
    expect(
      await _until(
        tester,
        () => _marker.evaluate().isNotEmpty && !_oyenShown(),
      ),
      isTrue,
    );
    expect(_tail, findsNothing);
    expect(playedBy(audio), contains(GameSound.flap));
  });

  testWidgets('pengumuman Oyen menyelinap dan label pintu depan', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);
    expect(find.bySemanticsLabel(l10nId.frontDoorTo), findsOneWidget);
    tester.takeAnnouncements();
    expect(await _until(tester, () => _marker.evaluate().isNotEmpty), isTrue);
    expect(
      tester.takeAnnouncements().map((a) => a.message),
      contains(l10nId.oyenWentOut('Oyen')),
    );
    expect(find.bySemanticsLabel(l10nId.frontDoorOyenOut), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('kartu Oyen terbuka: belum keluar sampai kartu ditutup', (
    tester,
  ) async {
    await _pump(tester);
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(
      find.semantics.byLabel(RegExp(r'^Oyen.*Ketuk untuk lihat kartunya$')),
    );
    semantics.dispose();
    await tester.pump();
    expect(find.bySemanticsLabel('Tutup kartu'), findsOneWidget);
    await _until(tester, () => false, max: const Duration(seconds: 25));
    expect(_tail, findsNothing);
    expect(_marker, findsNothing);
    await tester.tap(find.bySemanticsLabel('Tutup kartu'));
    expect(await _until(tester, () => _tail.evaluate().isNotEmpty), isTrue);
    expect(await _until(tester, () => _marker.evaluate().isNotEmpty), isTrue);
  });

  testWidgets('kunjungan habis: Oyen masuk lagi dan penanda hilang', (
    tester,
  ) async {
    var now = _night;
    await _pump(tester, clock: () => now);
    expect(await _until(tester, () => _marker.evaluate().isNotEmpty), isTrue);
    now = now.add(const Duration(minutes: 20));
    expect(await _until(tester, () => _passing.evaluate().isNotEmpty), isTrue);
    expect(
      await _until(tester, () => _oyenShown() && _passing.evaluate().isEmpty),
      isTrue,
    );
    expect(_marker, findsNothing);
  });

  testWidgets('kurangi gerak: tanpa ekor, Oyen langsung keluar', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pump(tester);
    expect(_oyenShown(), isTrue);
    await tester.pump(laneForcedDelay);
    await tester.pump();
    expect(_tail, findsNothing);
    expect(_passing, findsNothing);
    expect(_marker, findsOneWidget);
    expect(_oyenShown(), isFalse);
  });

  testWidgets('belum menang level 1: tidak ada ekor', (tester) async {
    await _pump(tester, best: const {});
    await _until(tester, () => false, max: const Duration(seconds: 25));
    expect(_tail, findsNothing);
    expect(_marker, findsNothing);
    expect(_oyenShown(), isTrue);
  });

  testWidgets('sudah pernah bertemu: tidak ada kunjungan paksa', (
    tester,
  ) async {
    await _pump(tester, metNeighbor: true);
    await _until(tester, () => false, max: const Duration(seconds: 25));
    expect(_tail, findsNothing);
  });

  testWidgets('dibuka di tengah kunjungan: Oyen sudah di luar, tanpa ekor', (
    tester,
  ) async {
    final visit = laneVisitsOn(_night).first;
    final now = visit.start.add(const Duration(minutes: 1));
    await _pump(tester, clock: () => now);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_tail, findsNothing);
    expect(_passing, findsNothing);
    expect(_marker, findsOneWidget);
    expect(_oyenShown(), isFalse);
  });
}
