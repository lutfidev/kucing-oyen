import 'dart:async';

import 'package:flutter/widgets.dart';

import '../game/model/sounds.dart';
import 'progress_store.dart';
import 'rewarded_ads.dart';
import 'sound_player.dart';

/// Alasan musik dijeda sementara.
enum AudioHold {
  /// Aplikasi di latar belakang.
  background,

  /// Iklan berhadiah sedang diputar.
  ad,
}

/// Musik latar dan efek suara: sakelar Pengaturan (tersimpan lewat
/// [store]), lagu yang diminta layar, dan jeda saat aplikasi di latar
/// belakang atau iklan diputar. Selama dijeda efek suara juga senyap.
/// Sakelarnya terpisah dari progres, jadi reset progres tidak mengubahnya.
class GameAudio extends ChangeNotifier {
  GameAudio({
    required this.player,
    required this.store,
    this._settings = SoundSettings.on,
  });

  static Future<GameAudio> load({
    required ProgressStore store,
    required SoundPlayer player,
  }) async => GameAudio(
    player: player,
    store: store,
    settings: await store.loadSound(),
  );

  final SoundPlayer player;
  final ProgressStore store;

  SoundSettings _settings;
  bool get musicOn => _settings.music;
  bool get effectsOn => _settings.effects;

  MusicTrack? _track;

  /// Lagu yang diminta layar sekarang; null sebelum layar pertama.
  MusicTrack? get track => _track;

  final _holds = <AudioHold>{};

  /// Lagu yang ada di [player] (juga selama dijeda); null = berhenti.
  MusicTrack? _loaded;
  bool _paused = false;

  void play(GameSound sound) {
    if (!effectsOn || _holds.isNotEmpty) return;
    unawaited(player.play(sound));
  }

  /// Tidak memberi tahu pendengar: dipanggil dari pendengar router, yang
  /// bisa jalan saat widget sedang dibangun.
  void setTrack(MusicTrack track) {
    if (track == _track) return;
    _track = track;
    _sync();
  }

  Future<void> setMusicOn(bool on) =>
      _setSettings(_settings.copyWith(music: on));

  Future<void> setEffectsOn(bool on) =>
      _setSettings(_settings.copyWith(effects: on));

  Future<void> _setSettings(SoundSettings settings) async {
    if (settings == _settings) return;
    _settings = settings;
    _sync();
    notifyListeners();
    await store.saveSound(settings);
  }

  void hold(AudioHold reason) {
    if (_holds.add(reason)) _sync();
  }

  void release(AudioHold reason) {
    if (_holds.remove(reason)) _sync();
  }

  /// Membungkus [ads] supaya musik dijeda selama iklan diputar, juga kalau
  /// iklannya gagal atau error.
  RewardedAds pauseDuringAds(RewardedAds ads) => _PausingAds(this, ads);

  /// Menyamakan [player] dengan sakelar, lagu yang diminta, dan jeda.
  void _sync() {
    final wanted = musicOn ? _track : null;
    if (wanted == null) {
      if (_loaded != null) unawaited(player.stopMusic());
      _loaded = null;
      _paused = false;
    } else if (_holds.isNotEmpty) {
      if (_loaded != null && !_paused) unawaited(player.pauseMusic());
      _paused = _loaded != null;
    } else if (_loaded != wanted) {
      unawaited(player.playMusic(wanted));
      _loaded = wanted;
      _paused = false;
    } else if (_paused) {
      unawaited(player.resumeMusic());
      _paused = false;
    }
  }
}

class _PausingAds implements RewardedAds {
  _PausingAds(this._audio, this._ads);

  final GameAudio _audio;
  final RewardedAds _ads;

  @override
  Future<bool> show() async {
    _audio.hold(AudioHold.ad);
    try {
      return await _ads.show();
    } finally {
      _audio.release(AudioHold.ad);
    }
  }
}

/// Membagikan [GameAudio] ke bawah.
class AudioScope extends InheritedNotifier<GameAudio> {
  const AudioScope({super.key, required GameAudio audio, required super.child})
    : super(notifier: audio);

  /// Dibangun ulang saat sakelar berubah (Pengaturan).
  static GameAudio of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudioScope>();
    assert(scope != null, 'AudioScope tidak ada di atas $context');
    return scope!.notifier!;
  }

  /// Untuk memutar efek suara; null tanpa [AudioScope] (mis. test widget),
  /// jadi tombol dan layar tetap senyap.
  static GameAudio? maybeRead(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AudioScope>()?.notifier;
}

/// [action] yang lebih dulu membunyikan [GameSound.tap]; null tetap null
/// (tombol nonaktif senyap).
VoidCallback? tapSound(BuildContext context, VoidCallback? action) =>
    action == null
    ? null
    : () {
        AudioScope.maybeRead(context)?.play(GameSound.tap);
        action();
      };
