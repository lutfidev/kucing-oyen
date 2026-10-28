import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../game/model/sounds.dart';

/// Pemutar suara perangkat. [GameAudio] memutuskan kapan suara boleh
/// berbunyi; pemutar hanya menjalankannya. Test memakai [FakeSoundPlayer].
abstract interface class SoundPlayer {
  /// Memutar satu efek suara, boleh bertumpuk dengan yang lain.
  Future<void> play(GameSound sound);

  /// Menyiapkan semua efek suara lebih dulu, supaya bunyi pertama tiap efek
  /// tidak telat.
  Future<void> preload();

  /// Memutar [track] berulang, menggantikan lagu yang sedang jalan.
  Future<void> playMusic(MusicTrack track);

  Future<void> stopMusic();
  Future<void> pauseMusic();
  Future<void> resumeMusic();
}

/// Pemutar palsu: tidak berbunyi, hanya mencatat yang diminta.
class FakeSoundPlayer implements SoundPlayer {
  /// Efek suara yang diputar, berurutan.
  final played = <GameSound>[];

  /// Lagu yang sedang diputar (juga selama dijeda); null = berhenti.
  MusicTrack? music;

  bool musicPaused = false;

  /// Berapa kali lagu mulai diputar ([playMusic]).
  int musicStarts = 0;

  /// [preload] sudah dipanggil.
  bool preloaded = false;

  @override
  Future<void> play(GameSound sound) async => played.add(sound);

  @override
  Future<void> preload() async => preloaded = true;

  @override
  Future<void> playMusic(MusicTrack track) async {
    music = track;
    musicPaused = false;
    musicStarts++;
  }

  @override
  Future<void> stopMusic() async {
    music = null;
    musicPaused = false;
  }

  @override
  Future<void> pauseMusic() async => musicPaused = true;

  @override
  Future<void> resumeMusic() async => musicPaused = false;
}

/// Pemutar asli lewat paket `audioplayers`. Efek suara memakai satu
/// [AudioPool] per suara (dibuat [preload] saat aplikasi dibuka, atau saat
/// pertama dibutuhkan); musik berulang
/// di satu [AudioPlayer] dan berganti lagu dengan crossfade. Semua suara
/// bercampur dengan musik (tidak saling merebut fokus audio). Error
/// platform ditelan supaya game tetap jalan tanpa suara.
class AudioplayersSoundPlayer implements SoundPlayer {
  /// [newDeck] dan [setUpContext] hanya diganti di test, supaya crossfade
  /// bisa diuji tanpa platform audio.
  AudioplayersSoundPlayer({
    MusicDeck Function()? newDeck,
    this._setUpContext = true,
  }) : _newDeck = newDeck ?? _AudioplayersDeck.new;

  final MusicDeck Function() _newDeck;
  final bool _setUpContext;

  /// Volume musik di bawah efek suara.
  static const musicVolume = 0.5;
  static const fadeTime = Duration(milliseconds: 400);
  static const _fadeSteps = 10;

  /// Efek suara yang sama boleh bertumpuk paling banyak sekian.
  static const _maxOverlap = 3;

  final _pools = <GameSound, Future<AudioPool>>{};
  MusicDeck? _music;
  MusicTrack? _track;

  /// Lagu lama yang sedang dipudarkan.
  MusicDeck? _fading;
  Timer? _fade;
  Future<void>? _context;

  /// Perintah musik dijalankan berurutan, supaya jeda yang datang saat lagu
  /// baru masih dimuat tidak terlewat.
  Future<void> _queue = Future.value();

  Future<void> _ensureContext() => _context ??= _setUpContext
      ? _safe(
          () => AudioPlayer.global.setAudioContext(
            AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
                .build(),
          ),
        )
      : Future.value();

  Future<void> _serial(Future<void> Function() action) =>
      _queue = _queue.then((_) => _safe(action));

  Future<AudioPool> _pool(GameSound sound) => _pools[sound] ??=
      AudioPool.createFromAsset(path: sound.asset, maxPlayers: _maxOverlap);

  @override
  Future<void> play(GameSound sound) => _safe(() async {
    await _ensureContext();
    await (await _pool(sound)).start();
  });

  @override
  Future<void> preload() async {
    await _ensureContext();
    for (final sound in GameSound.values) {
      await _safe(() => _pool(sound));
    }
  }

  @override
  Future<void> playMusic(MusicTrack track) => _serial(() async {
    if (track == _track && _music != null) return;
    await _ensureContext();
    await _finishFade();
    final old = _music;
    final next = _newDeck();
    try {
      await next.start(track, old == null ? musicVolume : 0);
    } on Object {
      // Lagu lama tetap jalan dan tetap bisa dijeda atau dihentikan.
      await _safe(next.dispose);
      rethrow;
    }
    _music = next;
    _track = track;
    if (old == null) return;
    _fading = old;
    var step = 0;
    _fade = Timer.periodic(fadeTime ~/ _fadeSteps, (timer) {
      step++;
      final t = step / _fadeSteps;
      unawaited(_safe(() => next.setVolume(musicVolume * t)));
      unawaited(_safe(() => old.setVolume(musicVolume * (1 - t))));
      if (step == _fadeSteps) {
        // Antrean bisa sibuk; jangan sampai volume lewat batas sambil
        // menunggu lagu lama dibuang.
        timer.cancel();
        unawaited(_serial(_finishFade));
      }
    });
  });

  /// Crossfade yang belum selesai langsung diselesaikan: lagu lama dibuang,
  /// lagu baru di volume penuh.
  Future<void> _finishFade() async {
    final fading = _fading;
    if (fading == null) return;
    _fade?.cancel();
    _fade = null;
    _fading = null;
    await _music?.setVolume(musicVolume);
    await fading.dispose();
  }

  @override
  Future<void> stopMusic() => _serial(() async {
    await _finishFade();
    final music = _music;
    _music = null;
    _track = null;
    await music?.dispose();
  });

  @override
  Future<void> pauseMusic() => _serial(() async {
    await _finishFade();
    await _music?.pause();
  });

  @override
  Future<void> resumeMusic() => _serial(() async => _music?.resume());

  static Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error) {
      debugPrint('Suara gagal diputar: $error');
    }
  }
}

/// Satu pemutar lagu berulang. [AudioplayersSoundPlayer] memakai dua
/// sekaligus saat crossfade.
abstract interface class MusicDeck {
  /// Memutar [track] berulang dari awal di [volume].
  Future<void> start(MusicTrack track, double volume);
  Future<void> setVolume(double volume);
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}

class _AudioplayersDeck implements MusicDeck {
  final _player = AudioPlayer();

  @override
  Future<void> start(MusicTrack track, double volume) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(volume);
    await _player.play(AssetSource(track.asset));
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> dispose() => _player.dispose();
}
