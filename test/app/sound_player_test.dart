import 'dart:async';

import 'package:kucing_oren/app/effect_pool.dart';
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

/// Pool efek palsu: menghitung bunyi yang dimulai.
class _Pool implements EffectPool {
  int started = 0;
  int active = 0;
  @override
  Future<void> start() async {
    started++;
    active++;
  }

  @override
  Future<void> stop() async => active = 0;
}

class _Voice implements EffectVoice {
  bool active = false;
  int starts = 0;
  @override
  bool get playing => active;
  @override
  Future<void> resume() async {
    active = true;
    starts++;
  }

  @override
  Future<void> stop() async => active = false;
  void complete() => active = false;
}

void main() {
  test(
    'hold during voice expansion never starts the newly loaded voice',
    () async {
      final first = _Voice();
      final second = _Voice();
      final gate = Completer<EffectVoice>();
      var loads = 0;
      final pool = EffectPool(
        loadVoice: () async => ++loads == 1 ? first : await gate.future,
      );
      final player = AudioplayersSoundPlayer(
        setUpContext: false,
        newPool: (_) async => pool,
      );
      await player.play(GameSound.tap);
      final expanding = player.play(GameSound.tap);
      await Future<void>.delayed(Duration.zero);
      expect(loads, 2);
      await player.stopEffects();
      gate.complete(second);
      await expanding;
      expect(first.playing, isFalse);
      expect(second.starts, 0);
      await player.play(GameSound.tap);
      expect(first.playing || second.playing, isTrue);
      await player.stopEffects();
    },
  );
  test(
    'effects reuse completed voices without stopping newer playback',
    () async {
      final voices = <_Voice>[];
      final pool = EffectPool(
        loadVoice: () async {
          final voice = _Voice();
          voices.add(voice);
          return voice;
        },
      );
      for (var i = 0; i < 3; i++) {
        await pool.start();
        voices.single.complete();
      }
      expect(voices, hasLength(1));
      await pool.start();
      await pool.start();
      expect(voices, hasLength(2));
      expect(voices.every((v) => v.playing), isTrue);
      for (var i = 0; i < 20; i++) {
        await pool.start();
      }
      expect(voices, hasLength(EffectPool.maxVoices));
      expect(voices.every((v) => v.playing), isTrue);
      await pool.stop();
      expect(voices.every((v) => !v.playing), isTrue);
    },
  );

  test('stopping cancels queued effects and pending loads', () async {
    final pool = _Pool();
    final gate = Completer<EffectPool>();
    final player = AudioplayersSoundPlayer(
      setUpContext: false,
      newPool: (_) => gate.future,
    );
    final pending = player.play(GameSound.meow);
    final queued = player.play(GameSound.meow);
    await Future<void>.delayed(Duration.zero);
    await player.stopEffects();
    gate.complete(pool);
    await Future.wait([pending, queued]);
    expect(pool.started, 0);
    await player.play(GameSound.meow);
    expect(pool.active, 1);
    await player.stopEffects();
    expect(pool.active, 0);
  });
  group('efek suara', () {
    test(
      'pool yang gagal dibuat dicoba lagi saat diputar berikutnya',
      () async {
        final made = <GameSound>[];
        var fail = true;
        final pool = _Pool();
        final player = AudioplayersSoundPlayer(
          setUpContext: false,
          newPool: (sound) async {
            made.add(sound);
            if (fail) throw StateError('pool gagal');
            return pool;
          },
        );
        await player.preload();
        expect(made, GameSound.values);

        fail = false;
        await player.play(GameSound.tap);
        expect(pool.started, 1);
        await player.play(GameSound.tap);
        expect(pool.started, 2);
        // Pool yang berhasil dipakai ulang, tidak dibuat lagi.
        expect(made.where((s) => s == GameSound.tap), hasLength(2));
      },
    );
  });

  test(
    'pool yang selalu gagal dicoba paling banyak maxPoolTries kali',
    () async {
      var made = 0;
      final player = AudioplayersSoundPlayer(
        setUpContext: false,
        newPool: (sound) async {
          made++;
          throw StateError('pool gagal');
        },
      );
      for (var i = 0; i < 10; i++) {
        await player.play(GameSound.tap);
      }
      expect(made, AudioplayersSoundPlayer.maxPoolTries);
    },
  );

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
