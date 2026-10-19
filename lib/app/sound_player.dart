import '../game/model/sounds.dart';

/// Pemutar suara perangkat. [GameAudio] memutuskan kapan suara boleh
/// berbunyi; pemutar hanya menjalankannya. Test memakai [FakeSoundPlayer].
abstract interface class SoundPlayer {
  /// Memutar satu efek suara, boleh bertumpuk dengan yang lain.
  Future<void> play(GameSound sound);

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

  @override
  Future<void> play(GameSound sound) async => played.add(sound);

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
