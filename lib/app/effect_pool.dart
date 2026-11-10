import 'package:audioplayers/audioplayers.dart';

import '../game/model/sounds.dart';

/// A finite pool of reusable voices. Uses current player state instead of
/// retaining AudioPool stop callbacks after their playback has completed.
/// Calls are serialized by AudioplayersSoundPlayer for each sound.
class EffectPool {
  EffectPool({required this._loadVoice});

  static const maxVoices = 3;
  final Future<EffectVoice> Function() _loadVoice;
  final _voices = <EffectVoice>[];
  int _revision = 0;

  static Future<EffectPool> load(GameSound sound) async {
    final pool = EffectPool(loadVoice: () => _DeviceVoice.load(sound));
    pool._voices.add(await pool._loadVoice());
    return pool;
  }

  Future<void> start() async {
    final revision = _revision;
    var voice = _voices.where((v) => !v.playing).firstOrNull;
    voice ??= _voices.length < maxVoices ? await _loadVoice() : _voices.first;
    _voices.remove(voice);
    _voices.add(voice); // Oldest active voice is evicted only at capacity.
    if (revision != _revision) return;
    await voice.stop();
    if (revision != _revision) return;
    await voice.resume();
    if (revision != _revision) await voice.stop();
  }

  Future<void> stop() async {
    _revision++;
    await Future.wait(_voices.map((voice) => voice.stop()));
  }
}

abstract interface class EffectVoice {
  bool get playing;
  Future<void> resume();
  Future<void> stop();
}

class _DeviceVoice implements EffectVoice {
  _DeviceVoice(this._player);
  final AudioPlayer _player;

  static Future<_DeviceVoice> load(GameSound sound) async {
    final player = AudioPlayer();
    try {
      await player.setSource(AssetSource(sound.asset));
      await player.setReleaseMode(ReleaseMode.stop);
      return _DeviceVoice(player);
    } on Object {
      await player.dispose();
      rethrow;
    }
  }

  @override
  bool get playing => _player.state == PlayerState.playing;
  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();
}
