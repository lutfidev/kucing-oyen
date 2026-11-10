import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../game/model/sounds.dart';
import 'effect_pool.dart';

/// Pemutar suara perangkat. [GameAudio] memutuskan kapan suara boleh
/// berbunyi; pemutar hanya menjalankannya. Test memakai [FakeSoundPlayer].
abstract interface class SoundPlayer {
  /// Memutar satu efek suara, boleh bertumpuk dengan yang lain.
  Future<void> play(GameSound sound);

  /// Stop effects already playing and cancel starts still loading.
  Future<void> stopEffects();

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
  int effectsStops = 0;

  @override
  Future<void> stopEffects() async => effectsStops++;

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
/// [EffectPool] per suara (dibuat [preload] saat aplikasi dibuka, atau saat
/// pertama dibutuhkan); musik berulang
/// di satu [AudioPlayer] dan berganti lagu dengan crossfade. Semua suara
/// bercampur dengan musik (tidak saling merebut fokus audio). Error
/// platform ditelan supaya game tetap jalan tanpa suara.
class AudioplayersSoundPlayer implements SoundPlayer {
  /// [newDeck], [newPool], dan [setUpContext] hanya diganti di test, supaya
  /// crossfade dan pool efek bisa diuji tanpa platform audio.
  AudioplayersSoundPlayer({
    MusicDeck Function()? newDeck,
    Future<EffectPool> Function(GameSound sound)? newPool,
    this._setUpContext = true,
  }) : _newDeck = newDeck ?? _AudioplayersDeck.new,
       _newPool = newPool ?? _createPool;

  final MusicDeck Function() _newDeck;
  final Future<EffectPool> Function(GameSound sound) _newPool;

  static Future<EffectPool> _createPool(GameSound sound) =>
      EffectPool.load(sound);
  final bool _setUpContext;

  /// Volume musik di bawah efek suara.
  static const musicVolume = 0.5;
  static const fadeTime = Duration(milliseconds: 400);
  static const _fadeSteps = 10;

  final _pools = <GameSound, Future<EffectPool>>{};
  final _effectQueues = <GameSound, Future<void>>{};
  final _readyEffects = <GameSound, EffectPool>{};
  int _effectsRevision = 0;

  /// Berapa kali pool tiap suara gagal dibuat.
  final _poolFailures = <GameSound, int>{};

  /// Pool yang gagal sebanyak ini tidak dicoba lagi sepanjang sesi: tiap
  /// percobaan yang gagal dibatasi supaya aset rusak tidak dimuat berulang.
  /// Pemutar yang gagal dimuat dibuang oleh EffectPool.
  static const maxPoolTries = 3;
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

  /// Pool yang gagal dibuat dibuang dari cache, jadi dicoba lagi saat suara
  /// itu diputar berikutnya, paling banyak [maxPoolTries] kali.
  Future<EffectPool> _pool(GameSound sound) {
    final cached = _pools[sound];
    if (cached != null) return cached;
    late final Future<EffectPool> pool;
    pool = _newPool(sound)
        .then((value) {
          _readyEffects[sound] = value;
          return value;
        })
        .catchError((Object error, StackTrace stack) {
          final failures = _poolFailures[sound] =
              (_poolFailures[sound] ?? 0) + 1;
          if (failures < maxPoolTries && identical(_pools[sound], pool)) {
            _pools.remove(sound);
          }
          Error.throwWithStackTrace(error, stack);
        });
    return _pools[sound] = pool;
  }

  @override
  Future<void> play(GameSound sound) {
    final revision = _effectsRevision;
    return _effectQueues[sound] = (_effectQueues[sound] ?? Future.value()).then(
      (_) => _safe(() async {
        await _ensureContext();
        if (revision != _effectsRevision) return;
        final pool = await _pool(sound);
        if (revision != _effectsRevision) return;
        await pool.start();
        if (revision != _effectsRevision) {
          await pool.stop();
        }
      }),
    );
  }

  @override
  Future<void> stopEffects() async {
    _effectsRevision++;
    await Future.wait(_readyEffects.values.map((pool) => _safe(pool.stop)));
  }

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
