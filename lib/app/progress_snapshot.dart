import '../game/model/hints.dart';
import '../game/model/home.dart';
import '../game/model/household.dart';
import '../game/model/needs.dart';
import '../game/model/progress.dart';
import '../game/model/rewards.dart';
import 'language.dart';

/// Optional capability. Production uses one replacement write for all gameplay
/// state. Legacy adapters retain the small per-part interface during migration.
abstract interface class SnapshotStore {
  Future<Map<String, dynamic>?> readSnapshot();
  Future<void> writeSnapshot(Map<String, Object?> snapshot);
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.progress,
    required this.tutorials,
    required this.coins,
    required this.hints,
    required this.home,
    required this.needs,
    required this.rewards,
    required this.language,
    required this.household,
  });
  final Progress progress;
  final Set<int> tutorials;
  final int coins;
  final Map<int, int> hints;
  final Home home;
  final HomeNeeds needs;
  final DailyRewards rewards;
  final AppLanguage language;
  final Household household;

  Map<String, Object?> toJson() => {
    'version': 2,
    'progress': progress.toJson(),
    'tutorials': tutorials.toList()..sort(),
    'coins': coins,
    'hints': {for (final e in hints.entries) '${e.key}': e.value},
    'home': home.toJson(),
    'needs': needs.toJson(),
    'rewards': rewards.toJson(),
    'language': language.name,
    'household': household.toJson(),
  };

  /// Recover each missing/invalid section from the pre-migration snapshot.
  factory ProgressSnapshot.fromJson(
    Map<String, dynamic> json,
    ProgressSnapshot fallback,
    DateTime now,
  ) {
    T part<T>(String key, T Function(Map<String, dynamic>) parse, T backup) {
      final raw = json[key];
      return raw is Map<String, dynamic> ? parse(raw) : backup;
    }

    final backupHome = fallback.home.toJson();
    final rawHome = json['home'];
    final homeJson = <String, dynamic>{...backupHome};
    if (rawHome is Map<String, dynamic>) {
      for (final key in ['room', 'closet', 'pantry']) {
        if (rawHome[key] is Map<String, dynamic>) homeJson[key] = rawHome[key];
      }
      for (final key in ['kitties', 'fresh']) {
        if (rawHome[key] is List) homeJson[key] = rawHome[key];
      }
    }
    final home = Home.fromJson(homeJson);
    final rawHints = json['hints'];
    return ProgressSnapshot(
      progress: part('progress', Progress.fromJson, fallback.progress),
      tutorials: json['tutorials'] is List
          ? {
              for (final id in json['tutorials'] as List)
                if (id is int && id > 0) id,
            }
          : fallback.tutorials,
      coins: json['coins'] is int && (json['coins'] as int) >= 0
          ? json['coins'] as int
          : fallback.coins,
      hints: rawHints is Map<String, dynamic>
          ? {
              for (final e in rawHints.entries)
                if ((int.tryParse(e.key), e.value)
                    case (final int id, final int tier)
                    when id > 0 && tier >= 1 && tier <= maxHintTier)
                  id: tier,
            }
          : fallback.hints,
      home: home,
      needs: part('needs', HomeNeeds.fromJson, fallback.needs),
      rewards: part('rewards', DailyRewards.fromJson, fallback.rewards),
      language:
          json['language'] is String &&
              AppLanguage.values.asNameMap().containsKey(json['language'])
          ? AppLanguage.parse(json['language'] as String)
          : fallback.language,
      household: part(
        'household',
        (v) => Household.fromJson(v, home, now),
        Household.migrate(home, now),
      ),
    );
  }
}
