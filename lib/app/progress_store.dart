import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/model/progress.dart';

/// Tempat menyimpan [Progress] dan tutorial yang sudah selesai di
/// perangkat. Antarmukanya kecil supaya test bisa memakai
/// [MemoryProgressStore].
abstract interface class ProgressStore {
  Future<Progress> load();
  Future<void> save(Progress progress);

  /// Id level yang tutorialnya sudah selesai.
  Future<Set<int>> loadTutorials();
  Future<void> saveTutorials(Set<int> levels);
}

/// Simpanan di memori (test, atau kalau penyimpanan perangkat tidak ada).
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([this.saved = Progress.empty, this.tutorials = const {}]);

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
}

/// Simpanan lokal lewat `shared_preferences`: satu kunci berisi JSON
/// `{"id level": bintang}`, satu lagi daftar id level yang tutorialnya
/// selesai.
class PrefsProgressStore implements ProgressStore {
  PrefsProgressStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const key = 'progress.stars';
  static const tutorialsKey = 'tutorial.done';

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
}
