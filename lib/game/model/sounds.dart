import '../sim/sim.dart';
import 'run_frames.dart';

/// Efek suara game. Berkasnya `assets/<asset>`.
enum GameSound {
  /// Tombol ditekan.
  tap('tap'),

  /// Benda diangkat dari baki atau papan.
  pickUp('pick_up'),

  /// Benda ditaruh di petak menyala.
  place('place'),

  /// Benda kembali ke baki (dilepas di luar papan, batal, atau Kosongkan).
  back('back'),

  /// Oyen dibangunkan.
  wake('wake'),

  /// Oyen makan ikan.
  eat('eat'),

  /// Oyen kaget melihat air.
  scared('scared'),

  /// Oyen masuk kardus.
  box('box'),

  /// Gelas plastik jatuh dari meja.
  glass('glass'),

  /// "PRANG!": vas Ibu pecah.
  vase('vase'),

  /// Satu bintang muncul di layar hasil.
  star('star'),

  /// Oyen bosan (mondar-mandir atau kelamaan).
  bored('bored'),

  /// Koin bertambah.
  coin('coin');

  const GameSound(this.file);

  /// Nama berkas tanpa ekstensi.
  final String file;

  /// Path aset relatif ke `assets/`.
  String get asset => 'audio/sfx/$file.ogg';
}

/// Musik latar: [home] untuk kamar, peta, Toko, dan Pengaturan;
/// [level] untuk layar level (fase atur, jalan, hasil, putar ulang).
enum MusicTrack {
  home,
  level;

  /// Path aset relatif ke `assets/`.
  String get asset => 'audio/music/$name.ogg';
}

/// Efek suara langkah fase jalan [frame]; null kalau langkahnya senyap
/// (jalan, berputar, dan duduk terlalu sering untuk diberi suara).
GameSound? stepSound(RunFrame frame) => switch (frame.action?.kind) {
  StepKind.eat => GameSound.eat,
  StepKind.scared => GameSound.scared,
  StepKind.enterBox => GameSound.box,
  StepKind.knockGlass => GameSound.glass,
  StepKind.knockVase => GameSound.vase,
  StepKind.sit || StepKind.turn || StepKind.walk || null => null,
};

/// Sakelar Musik dan Efek suara di Pengaturan; default keduanya menyala.
class SoundSettings {
  const SoundSettings({this.music = true, this.effects = true});

  static const on = SoundSettings();

  final bool music;
  final bool effects;

  SoundSettings copyWith({bool? music, bool? effects}) => SoundSettings(
    music: music ?? this.music,
    effects: effects ?? this.effects,
  );

  @override
  bool operator ==(Object other) =>
      other is SoundSettings &&
      other.music == music &&
      other.effects == effects;

  @override
  int get hashCode => Object.hash(music, effects);

  @override
  String toString() => 'SoundSettings(music: $music, effects: $effects)';
}
