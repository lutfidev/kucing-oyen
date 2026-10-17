import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/model/progress.dart';

/// Tempat menyimpan [Progress] di perangkat. Antarmukanya kecil supaya test
/// bisa memakai [MemoryProgressStore].
abstract interface class ProgressStore {
  Future<Progress> load();
  Future<void> save(Progress progress);
}

/// Simpanan di memori (test, atau kalau penyimpanan perangkat tidak ada).
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([this.saved = Progress.empty]);

  /// Progres yang terakhir disimpan.
  Progress saved;

  /// Berapa kali [save] dipanggil.
  int saves = 0;

  @override
  Future<Progress> load() async => saved;

  @override
  Future<void> save(Progress progress) async {
    saved = progress;
    saves++;
  }
}

/// Simpanan lokal lewat `shared_preferences`: satu kunci berisi JSON
/// `{"id level": bintang}`.
class PrefsProgressStore implements ProgressStore {
  PrefsProgressStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const key = 'progress.stars';

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
}
