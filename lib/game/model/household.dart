import 'dart:math';

import 'home.dart';
import 'home_areas.dart';
import 'home_items.dart';
import 'home_routine.dart';
import 'kitties.dart';
import 'needs.dart';

/// Persisted v2 house state. Selection of a cat is deliberately session-only.
class Household {
  const Household({
    required this.areas,
    required this.routine,
    required this.effectiveAt,
    this.lastArea = HomeArea.santai,
    this.reducedMotion = false,
    this.migrationNotice = false,
  });
  final HomeAreas areas;
  final HomeRoutine routine;
  final DateTime effectiveAt;
  final HomeArea lastArea;
  final bool reducedMotion;
  final bool migrationNotice;

  factory Household.migrate(Home home, DateTime now, {bool existing = false}) =>
      Household(
        areas: HomeAreas.migrate(home),
        routine: HomeRoutine.initial(home.kitties),
        effectiveAt: now,
        migrationNotice: existing,
      );

  DateTime time(DateTime now) => now.isBefore(effectiveAt) ? effectiveAt : now;
  KittyId? get initialSelection {
    final present = routine.present(lastArea);
    return present.contains(KittyId.oyen) ? KittyId.oyen : present.firstOrNull;
  }

  Household copyWith({
    HomeAreas? areas,
    HomeRoutine? routine,
    DateTime? effectiveAt,
    HomeArea? lastArea,
    bool? reducedMotion,
    bool? migrationNotice,
  }) => Household(
    areas: areas ?? this.areas,
    routine: routine ?? this.routine,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    lastArea: lastArea ?? this.lastArea,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    migrationNotice: migrationNotice ?? this.migrationNotice,
  );

  Household sync(Home before, Home after) => copyWith(
    areas: areas.sync(before, after),
    routine: routine.sync(after.kitties),
  );

  ({Household household, HomeNeeds needs}) advance(
    double seconds,
    HomeNeeds needs,
    DateTime now, {
    Random? random,
    bool paused = false,
  }) {
    final at = time(now);
    final result = routine.advance(
      seconds,
      needs,
      at,
      random: random,
      paused: paused,
      toy: RoomItemId.values
          .where(
            (id) =>
                areas.placed[id]?.area == HomeArea.main && roomItemOf(id).toy,
          )
          .firstOrNull,
    );
    return (
      household: copyWith(routine: result.routine, effectiveAt: at),
      needs: result.needs,
    );
  }

  Map<String, Object?> toJson() => {
    'areas': areas.toJson(),
    'routine': routine.toJson(),
    'at': effectiveAt.millisecondsSinceEpoch,
    'lastArea': lastArea.name,
    'reducedMotion': reducedMotion,
    'migrationNotice': migrationNotice,
  };
  factory Household.fromJson(
    Map<String, dynamic> json,
    Home home,
    DateTime now,
  ) {
    final at = json['at'];
    return Household(
      areas: json['areas'] is Map<String, dynamic>
          ? HomeAreas.fromJson(json['areas'] as Map<String, dynamic>, home)
          : HomeAreas.migrate(home),
      routine: json['routine'] is Map<String, dynamic>
          ? HomeRoutine.fromJson(
              json['routine'] as Map<String, dynamic>,
              home.kitties,
            )
          : HomeRoutine.initial(home.kitties),
      effectiveAt: at is int && at >= 0 && at <= 32503680000000
          ? DateTime.fromMillisecondsSinceEpoch(at)
          : now,
      lastArea:
          HomeArea.values.asNameMap()[json['lastArea']] ?? HomeArea.santai,
      reducedMotion: json['reducedMotion'] == true,
      migrationNotice: json['migrationNotice'] == true,
    );
  }
}
