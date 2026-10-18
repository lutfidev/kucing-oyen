import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/model/costumes.dart';
import '../game/model/hints.dart';
import '../game/model/progress.dart';
import '../game/render/oyen.dart';

/// Tempat menyimpan [Progress], tutorial yang sudah selesai, saldo koin,
/// tingkat petunjuk yang terbuka, dan kostum Oyen di perangkat. Antarmukanya kecil
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

  /// Kostum yang dimiliki dan dipakai; [Wardrobe.initial] kalau belum
  /// pernah disimpan.
  Future<Wardrobe> loadWardrobe();
  Future<void> saveWardrobe(Wardrobe wardrobe);
}

/// Simpanan di memori (test, atau kalau penyimpanan perangkat tidak ada).
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([this.saved = Progress.empty, this.tutorials = const {}]);

  /// Saldo yang terakhir disimpan; null = belum pernah.
  int? coins;

  /// Tingkat petunjuk yang terakhir disimpan.
  Map<int, int> hints = const {};

  /// Kostum yang terakhir disimpan.
  Wardrobe wardrobe = Wardrobe.initial;

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
  Future<Wardrobe> loadWardrobe() async => wardrobe;

  @override
  Future<void> saveWardrobe(Wardrobe wardrobe) async =>
      this.wardrobe = wardrobe;
}

/// Simpanan lokal lewat `shared_preferences`: JSON `{"id level": bintang}`,
/// daftar id level yang tutorialnya selesai, saldo koin, JSON
/// `{"id level": tingkat petunjuk}`, dan nama kostum yang dimiliki dan
/// dipakai.
class PrefsProgressStore implements ProgressStore {
  PrefsProgressStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const key = 'progress.stars';
  static const tutorialsKey = 'tutorial.done';
  static const coinsKey = 'coins';
  static const hintsKey = 'hints.tier';
  static const ownedKey = 'costume.owned';
  static const wearingKey = 'costume.wearing';

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

  /// Nama kostum yang tidak dikenal dibuang; [Wardrobe] mengembalikan
  /// kostum dipakai yang tidak dimiliki ke Polos.
  @override
  Future<Wardrobe> loadWardrobe() async {
    OyenCostume? parse(String? name) => OyenCostume.values.asNameMap()[name];
    return Wardrobe(
      owned: [
        for (final name in await _prefs.getStringList(ownedKey) ?? const [])
          ?parse(name),
      ],
      wearing: parse(await _prefs.getString(wearingKey)) ?? OyenCostume.none,
    );
  }

  @override
  Future<void> saveWardrobe(Wardrobe wardrobe) => Future.wait([
    _prefs.setStringList(ownedKey, [
      for (final c in OyenCostume.values)
        if (wardrobe.owns(c)) c.name,
    ]),
    _prefs.setString(wearingKey, wardrobe.wearing.name),
  ]);
}
