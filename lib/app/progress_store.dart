import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/model/hints.dart';
import '../game/model/home.dart';
import '../game/model/needs.dart';
import '../game/model/progress.dart';
import '../game/model/rewards.dart';
import '../game/model/sounds.dart';
import 'language.dart';

/// Tempat menyimpan [Progress], tutorial yang sudah selesai, saldo koin,
/// tingkat petunjuk yang terbuka, rumah Oyen dan kebutuhan kucingnya,
/// hadiah harian, bahasa, dan sakelar suara di perangkat. Antarmukanya kecil
/// supaya test bisa memakai [MemoryProgressStore].
abstract interface class ProgressStore {
  Future<Progress> load();
  Future<void> save(Progress progress);

  /// Id level yang tutorialnya sudah selesai.
  Future<Set<int>> loadTutorials();
  Future<void> saveTutorials(Set<int> levels);

  /// Saldo koin; null kalau belum pernah disimpan atau rusak.
  Future<int?> loadCoins();
  Future<void> saveCoins(int coins);

  /// Id level → tingkat petunjuk tertinggi yang terbuka (1–3).
  Future<Map<int, int>> loadHints();
  Future<void> saveHints(Map<int, int> tiers);

  /// Barang, tata letak, kucing, aksesoris, dan stok camilan;
  /// [Home.initial] kalau belum pernah disimpan atau rusak.
  Future<Home> loadHome();
  Future<void> saveHome(Home home);

  /// Kebutuhan kucing, mangkuk, dan hari hadiah kucing; [HomeNeeds.empty]
  /// kalau belum pernah disimpan atau rusak.
  Future<HomeNeeds> loadNeeds();
  Future<void> saveNeeds(HomeNeeds needs);

  /// Bonus harian dan iklan koin; [DailyRewards.initial] kalau belum pernah
  /// disimpan atau rusak.
  Future<DailyRewards> loadRewards();
  Future<void> saveRewards(DailyRewards rewards);

  /// Bahasa pilihan pemain; [AppLanguage.system] kalau belum pernah
  /// disimpan atau rusak.
  Future<AppLanguage> loadLanguage();
  Future<void> saveLanguage(AppLanguage language);

  /// Sakelar Musik dan Efek suara; yang belum pernah disimpan atau rusak
  /// dianggap menyala.
  Future<SoundSettings> loadSound();
  Future<void> saveSound(SoundSettings sound);
}

/// Simpanan di memori (test, atau kalau penyimpanan perangkat tidak ada).
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([this.saved = Progress.empty, this.tutorials = const {}]);

  /// Saldo yang terakhir disimpan; null = belum pernah.
  int? coins;

  /// Tingkat petunjuk yang terakhir disimpan.
  Map<int, int> hints = const {};

  /// Rumah yang terakhir disimpan.
  Home home = Home.initial;

  /// Kebutuhan kucing yang terakhir disimpan.
  HomeNeeds needs = HomeNeeds.empty;

  /// Hadiah harian yang terakhir disimpan.
  DailyRewards rewards = DailyRewards.initial;

  /// Bahasa yang terakhir disimpan.
  AppLanguage language = AppLanguage.system;

  /// Sakelar suara yang terakhir disimpan.
  SoundSettings sound = SoundSettings.on;

  /// Progres yang terakhir disimpan.
  Progress saved;

  /// Tutorial selesai yang terakhir disimpan.
  Set<int> tutorials;

  /// Berapa kali [save] dipanggil.
  int saves = 0;

  @override
  Future<Progress> load() async => saved;

  @override
  Future<void> save(Progress progress) async {
    saved = progress;
    saves++;
  }

  @override
  Future<Set<int>> loadTutorials() async => tutorials;

  @override
  Future<void> saveTutorials(Set<int> levels) async => tutorials = levels;

  @override
  Future<int?> loadCoins() async => coins;

  @override
  Future<void> saveCoins(int coins) async => this.coins = coins;

  @override
  Future<Map<int, int>> loadHints() async => hints;

  @override
  Future<void> saveHints(Map<int, int> tiers) async => hints = tiers;

  @override
  Future<Home> loadHome() async => home;

  @override
  Future<void> saveHome(Home home) async => this.home = home;

  @override
  Future<HomeNeeds> loadNeeds() async => needs;

  @override
  Future<void> saveNeeds(HomeNeeds needs) async => this.needs = needs;

  @override
  Future<DailyRewards> loadRewards() async => rewards;

  @override
  Future<void> saveRewards(DailyRewards rewards) async =>
      this.rewards = rewards;

  @override
  Future<AppLanguage> loadLanguage() async => language;

  @override
  Future<void> saveLanguage(AppLanguage language) async =>
      this.language = language;

  @override
  Future<SoundSettings> loadSound() async => sound;

  @override
  Future<void> saveSound(SoundSettings sound) async => this.sound = sound;
}

/// Simpanan lokal lewat `shared_preferences`: JSON `{"id level": bintang}`,
/// daftar id level yang tutorialnya selesai, saldo koin, JSON
/// `{"id level": tingkat petunjuk}`, JSON rumah dan kebutuhan kucing, JSON hadiah harian, nama
/// bahasa, dan sakelar suara.
class PrefsProgressStore implements ProgressStore {
  PrefsProgressStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const key = 'progress.stars';
  static const tutorialsKey = 'tutorial.done';
  static const coinsKey = 'coins';
  static const hintsKey = 'hints.tier';

  /// Kunci Lemari Kostum lama (dihapus di langkah 23), dibuang saat rumah
  /// dimuat.
  static const oldCostumeKeys = ['costume.owned', 'costume.wearing'];
  static const homeKey = 'home.state';
  static const needsKey = 'home.needs';
  static const rewardsKey = 'rewards.daily';
  static const languageKey = 'settings.language';
  static const musicKey = 'settings.music';
  static const effectsKey = 'settings.sfx';

  final SharedPreferencesAsync _prefs;

  /// Data yang tidak bisa dibaca dianggap kosong, supaya aplikasi tetap
  /// terbuka.
  @override
  Future<Progress> load() async {
    final raw = await _prefs.getString(key);
    if (raw == null) return Progress.empty;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic>
          ? Progress.fromJson(json)
          : Progress.empty;
    } on FormatException {
      return Progress.empty;
    }
  }

  @override
  Future<void> save(Progress progress) =>
      _prefs.setString(key, jsonEncode(progress.toJson()));

  /// Id yang bukan angka dibuang.
  @override
  Future<Set<int>> loadTutorials() async => {
    for (final id in await _prefs.getStringList(tutorialsKey) ?? const [])
      ?int.tryParse(id),
  };

  @override
  Future<void> saveTutorials(Set<int> levels) => _prefs.setStringList(
    tutorialsKey,
    [for (final id in levels.toList()..sort()) '$id'],
  );

  /// Saldo negatif atau bukan angka dianggap belum pernah disimpan.
  @override
  Future<int?> loadCoins() async {
    try {
      final coins = await _prefs.getInt(coinsKey);
      return coins != null && coins >= 0 ? coins : null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> saveCoins(int coins) => _prefs.setInt(coinsKey, coins);

  /// Entri yang tidak sah (id bukan angka, tingkat bukan 1–3) dibuang.
  @override
  Future<Map<int, int>> loadHints() async {
    final raw = await _prefs.getString(hintsKey);
    if (raw == null) return const {};
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return const {};
      return {
        for (final MapEntry(:key, :value) in json.entries)
          if ((int.tryParse(key), value) case (final int id, final int tier)
              when tier >= 1 && tier <= maxHintTier)
            id: tier,
      };
    } on FormatException {
      return const {};
    }
  }

  @override
  Future<void> saveHints(Map<int, int> tiers) => _prefs.setString(
    hintsKey,
    jsonEncode({
      for (final id in tiers.keys.toList()..sort()) '$id': tiers[id],
    }),
  );

  /// JSON di [key] lewat [parse]; [empty] kalau belum pernah disimpan,
  /// bukan objek JSON, atau bertipe salah.
  Future<T> _loadJson<T>(
    String key,
    T Function(Map<String, dynamic>) parse,
    T empty,
  ) async {
    try {
      final raw = await _prefs.getString(key);
      if (raw == null) return empty;
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? parse(json) : empty;
    } on FormatException {
      return empty;
    } on TypeError {
      return empty;
    } on ArgumentError {
      // Mis. waktu di luar jangkauan DateTime yang lolos dari pemeriksaan.
      return empty;
    }
  }

  /// Juga membuang simpanan Lemari Kostum lama; gagal hapus diabaikan.
  @override
  Future<Home> loadHome() async {
    for (final key in oldCostumeKeys) {
      try {
        await _prefs.remove(key);
      } on Object {
        // Tidak apa-apa: kunci ini tidak pernah dibaca lagi.
      }
    }
    return _loadJson(homeKey, Home.fromJson, Home.initial);
  }

  @override
  Future<void> saveHome(Home home) =>
      _prefs.setString(homeKey, jsonEncode(home.toJson()));

  @override
  Future<HomeNeeds> loadNeeds() =>
      _loadJson(needsKey, HomeNeeds.fromJson, HomeNeeds.empty);

  @override
  Future<void> saveNeeds(HomeNeeds needs) =>
      _prefs.setString(needsKey, jsonEncode(needs.toJson()));

  @override
  Future<DailyRewards> loadRewards() =>
      _loadJson(rewardsKey, DailyRewards.fromJson, DailyRewards.initial);

  @override
  Future<void> saveRewards(DailyRewards rewards) =>
      _prefs.setString(rewardsKey, jsonEncode(rewards.toJson()));

  @override
  Future<AppLanguage> loadLanguage() async {
    try {
      return AppLanguage.parse(await _prefs.getString(languageKey));
    } on TypeError {
      return AppLanguage.system;
    }
  }

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _prefs.setString(languageKey, language.name);

  @override
  Future<SoundSettings> loadSound() async {
    Future<bool> read(String key) async {
      try {
        return await _prefs.getBool(key) ?? true;
      } on TypeError {
        return true;
      }
    }

    return SoundSettings(
      music: await read(musicKey),
      effects: await read(effectsKey),
    );
  }

  @override
  Future<void> saveSound(SoundSettings sound) => Future.wait([
    _prefs.setBool(musicKey, sound.music),
    _prefs.setBool(effectsKey, sound.effects),
  ]);
}
