import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/sounds.dart';

/// Pemutar lagu palsu: mencatat volume dan keadaannya.
class _Deck implements MusicDeck {
  _Deck({this.fails = false});

  final bool fails;
  MusicTrack? track;
  final volumes = <double>[];
  bool paused = false;
  bool disposed = false;

  /// Kalau ada, [resume] menunggu sampai ini selesai.
  Completer<void>? resumeGate;

  double get volume => volumes.last;

  @override
  Future<void> start(MusicTrack track, double volume) async {
    if (fails) throw StateError('tidak bisa dimuat');
    this.track = track;
    volumes.add(volume);
  }

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);

  @override
  Future<void> pause() async => paused = true;

  @override
  Future<void> resume() async {
    await resumeGate?.future;
    paused = false;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  late List<_Deck> decks;
  late List<bool> failNext;

  AudioplayersSoundPlayer player() {
    decks = [];
    failNext = [];
    return AudioplayersSoundPlayer(
      newDeck: () {
        final deck = _Deck(fails: failNext.isNotEmpty && failNext.removeAt(0));
        decks.add(deck);
        return deck;
      },
      setUpContext: false,
    );
  }

  const full = AudioplayersSoundPlayer.musicVolume;
  final fade = AudioplayersSoundPlayer.fadeTime;

  testWidgets('lagu pertama langsung di volume penuh', (tester) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    expect(decks.single.track, MusicTrack.home);
    expect(decks.single.volume, full);
  });

  testWidgets('crossfade: lagu lama dibuang, volume tetap 0..penuh', (
    tester,
  ) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    await p.playMusic(MusicTrack.level);
    final [old, next] = decks;
    expect(next.volumes.first, 0);

    // Bingkai demi bingkai sampai lewat waktu crossfade.
    for (var i = 0; i < 40; i++) {
      await tester.pump(fade ~/ 10);
    }
    expect(old.disposed, isTrue);
    expect(next.disposed, isFalse);
    expect(next.volume, full);
    for (final v in [...old.volumes, ...next.volumes]) {
      expect(v, inInclusiveRange(0, full));
    }
  });

  testWidgets('antrean sibuk saat crossfade selesai: volume tidak lewat '
      'batas', (tester) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    await p.playMusic(MusicTrack.level);
    final [old, next] = decks;
    final gate = next.resumeGate = Completer<void>();
    await tester.pump(fade ~/ 2);
    final resumed = p.resumeMusic();
    for (var i = 0; i < 20; i++) {
      await tester.pump(fade ~/ 10);
    }
    for (final v in [...old.volumes, ...next.volumes]) {
      expect(v, inInclusiveRange(0, full));
    }
    gate.complete();
    await resumed;
    await tester.pump(fade);
    expect(old.disposed, isTrue);
    expect(next.volume, full);
  });

  testWidgets('lagu sama: tidak dimulai ulang', (tester) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    await p.playMusic(MusicTrack.home);
    expect(decks, hasLength(1));
  });

  testWidgets('lagu baru gagal dimuat: lagu lama tetap bisa dijeda dan '
      'dihentikan', (tester) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    failNext.add(true);
    await p.playMusic(MusicTrack.level);
    final [old, failed] = decks;
    expect(failed.disposed, isTrue);
    expect(old.disposed, isFalse);
    expect(old.volume, full);

    await p.pauseMusic();
    expect(old.paused, isTrue);
    await p.stopMusic();
    expect(old.disposed, isTrue);

    // Dicoba lagi sesudahnya: lagu dimuat.
    await p.playMusic(MusicTrack.level);
    expect(decks.last.track, MusicTrack.level);
  });

  testWidgets('dijeda di tengah crossfade: lagu lama langsung dibuang', (
    tester,
  ) async {
    final p = player();
    await p.playMusic(MusicTrack.home);
    await p.playMusic(MusicTrack.level);
    await tester.pump(fade ~/ 4);
    await p.pauseMusic();
    final [old, next] = decks;
    expect(old.disposed, isTrue);
    expect(next.paused, isTrue);
    expect(next.volume, full);
    await tester.pump(fade * 2);
    expect(next.volume, full);
  });

  testWidgets('dihentikan saat lagu masih dimuat: berhenti sesudahnya', (
    tester,
  ) async {
    final p = player();
    final playing = p.playMusic(MusicTrack.home);
    final stopped = p.stopMusic();
    await playing;
    await stopped;
    expect(decks.single.disposed, isTrue);
  });
}
