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

/// Musik latar: [home] untuk Beranda, peta, Lemari Kostum, dan Pengaturan;
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
