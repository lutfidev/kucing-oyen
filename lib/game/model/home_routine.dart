import 'dart:math';

import 'home_areas.dart';
import 'home_items.dart';
import 'kitties.dart';
import 'needs.dart';

enum HomeActivity {
  rest(HomeArea.santai, 0),
  eat(HomeArea.makan, 4),
  play(HomeArea.main, 8),
  brush(HomeArea.rawat, 6),
  pet(HomeArea.rawat, 2);

  const HomeActivity(this.area, this.seconds);
  final HomeArea area;
  final double seconds;
}

enum RoutineNotice { ineligible, cancelled, facilityRemoved }

class HomeInvitation {
  const HomeInvitation(
    this.kind,
    this.order, {
    this.player = true,
    this.arrived = false,
  });
  final HomeActivity kind;
  final int order;
  final bool player;
  final bool arrived;
  HomeInvitation atFacility() =>
      HomeInvitation(kind, order, player: player, arrived: true);
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'order': order,
    'player': player,
    'arrived': arrived,
  };
}

class HomeAction {
  const HomeAction(
    this.id,
    this.kind,
    this.left, {
    this.player = true,
    this.facility,
  });
  final int id;
  final HomeActivity kind;
  final double left;
  final bool player;
  final RoomItemId? facility;
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'left': left,
    'player': player,
    'facility': facility?.name,
  };
}

/// A paired transfer owns both occupied slots. One threshold transaction
/// commits both identities. A normal transfer reserves one empty target slot.
class HomeJourney {
  const HomeJourney(
    this.id,
    this.kitty,
    this.from,
    this.to, {
    this.other,
    this.elapsed = 0,
  });
  final int id;
  final KittyId kitty;
  final KittyId? other;
  final HomeArea from;
  final HomeArea to;
  final double elapsed;
  bool get committed => elapsed >= .5;
  Iterable<KittyId> get cats => [kitty, ?other];
  HomeJourney at(double value) =>
      HomeJourney(id, kitty, from, to, other: other, elapsed: value);
  Map<String, Object?> toJson() => {
    'id': id,
    'kitty': kitty.name,
    'other': other?.name,
    'from': from.name,
    'to': to.name,
    'elapsed': elapsed,
  };
}

/// Immutable, renderer-independent scheduler. Only time supplied to [advance]
/// runs activities; calendar time is solely for needs/cooldowns. New actions
/// never consume the dt that created them, so the caller can persist their ID
/// before the next advance can complete them.
class HomeRoutine {
  HomeRoutine._({
    required Map<KittyId, HomeArea> locations,
    Map<KittyId, HomeInvitation> invitations = const {},
    Map<KittyId, HomeAction> activities = const {},
    List<HomeJourney> journeys = const [],
    Map<KittyId, double> idle = const {},
    Map<KittyId, DateTime> brushedAt = const {},
    Map<KittyId, RoutineNotice> notices = const {},
    Map<HomeArea, int> streaks = const {},
    Set<KittyId> sleeping = const {},
    this.serial = 0,
  }) : locations = Map.unmodifiable(locations),
       invitations = Map.unmodifiable(invitations),
       activities = Map.unmodifiable(activities),
       journeys = List.unmodifiable(journeys),
       idle = Map.unmodifiable(idle),
       brushedAt = Map.unmodifiable(brushedAt),
       notices = Map.unmodifiable(notices),
       streaks = Map.unmodifiable(streaks),
       sleeping = Set.unmodifiable(sleeping);

  final Map<KittyId, HomeArea> locations;
  final Map<KittyId, HomeInvitation> invitations;
  final Map<KittyId, HomeAction> activities;
  final List<HomeJourney> journeys;

  /// Time until next automatic decision; sleeping uses 12–20 seconds.
  final Map<KittyId, double> idle;
  final Map<KittyId, DateTime> brushedAt;
  final Map<KittyId, RoutineNotice> notices;
  final Map<HomeArea, int> streaks;
  final int serial;
  final Set<KittyId> sleeping;

  factory HomeRoutine.initial(Iterable<KittyId> owned) =>
      HomeRoutine._(locations: {}).sync(owned);

  HomeRoutine _copy({
    Map<KittyId, HomeArea>? locations,
    Map<KittyId, HomeInvitation>? invitations,
    Map<KittyId, HomeAction>? activities,
    List<HomeJourney>? journeys,
    Map<KittyId, double>? idle,
    Map<KittyId, DateTime>? brushedAt,
    Map<KittyId, RoutineNotice>? notices,
    Map<HomeArea, int>? streaks,
    Set<KittyId>? sleeping,
    int? serial,
  }) => HomeRoutine._(
    locations: locations ?? this.locations,
    invitations: invitations ?? this.invitations,
    activities: activities ?? this.activities,
    journeys: journeys ?? this.journeys,
    idle: idle ?? this.idle,
    brushedAt: brushedAt ?? this.brushedAt,
    notices: notices ?? this.notices,
    streaks: streaks ?? this.streaks,
    serial: serial ?? this.serial,
    sleeping: sleeping ?? this.sleeping,
  );

  List<KittyId> present(HomeArea area) => [
    for (final k in KittyId.values)
      if (locations[k] == area) k,
  ];
  int reserved(HomeArea area) => journeys
      .where(
        (j) =>
            !j.committed && j.other == null && j.to == area && j.from != j.to,
      )
      .length;
  bool moving(KittyId kitty) => journeys.any((j) => j.cats.contains(kitty));

  /// The same service order is used by the scheduler and visible queue.
  List<KittyId> queueFor(HomeArea area) {
    final orders = invitations.entries
        .where((e) => e.value.kind.area == area)
        .toList();
    final preferAuto =
        (streaks[area] ?? 0) >= 2 && orders.any((e) => !e.value.player);
    orders.sort((a, b) {
      final ap = a.value.player == !preferAuto ? 0 : 1;
      final bp = b.value.player == !preferAuto ? 0 : 1;
      return ap != bp
          ? ap.compareTo(bp)
          : a.value.order.compareTo(b.value.order);
    });
    return orders.map((e) => e.key).toList();
  }

  HomeArea? findArea(KittyId kitty) {
    for (final j in journeys) {
      if (j.kitty == kitty) return j.to;
      if (j.other == kitty) return j.from;
    }
    return locations[kitty];
  }

  HomeRoutine sync(Iterable<KittyId> owned) {
    final cats = {KittyId.oyen, ...owned};
    final map = {
      for (final e in locations.entries)
        if (cats.contains(e.key)) e.key: e.value,
    };
    var live = journeys.where((j) => j.cats.every(cats.contains)).toList();
    HomeArea? freeArea() => HomeArea.values
        .where(
          (a) =>
              map.values.where((v) => v == a).length +
                  live
                      .where(
                        (j) =>
                            !j.committed &&
                            j.other == null &&
                            j.from != j.to &&
                            j.to == a,
                      )
                      .length <
              a.capacity,
        )
        .firstOrNull;
    for (final k in KittyId.values.where(cats.contains)) {
      if (map.containsKey(k)) continue;
      var area = freeArea();
      // Adoption can fill the last raw vacancy while a trip reserves it.
      // Reclaim only a pre-threshold empty-slot reservation, at the safe
      // origin. Its invitation remains queued and can reroute via a swap.
      while (area == null) {
        final reclaim = live
            .where((j) => !j.committed && j.other == null && j.from != j.to)
            .lastOrNull;
        if (reclaim == null) throw StateError('Invalid household capacity');
        live = live.where((j) => j.id != reclaim.id).toList();
        area = freeArea();
      }
      map[k] = area;
    }
    return _copy(
      locations: map,
      invitations: {
        for (final e in invitations.entries)
          if (cats.contains(e.key)) e.key: e.value,
      },
      activities: {
        for (final e in activities.entries)
          if (cats.contains(e.key)) e.key: e.value,
      },
      journeys: live,
    );
  }

  HomeRoutine invite(KittyId kitty, HomeActivity kind, {bool player = true}) {
    if (!locations.containsKey(kitty)) return this;
    final old = invitations[kitty];
    if (old?.kind == kind && old?.player == player) return this;
    if (activities[kitty]?.kind == kind && old == null) return this;
    final state = cancel(kitty);
    return state._copy(
      invitations: {
        ...state.invitations,
        kitty: HomeInvitation(kind, serial + 1, player: player),
      },
      notices: {...state.notices}..remove(kitty),
      serial: serial + 1,
      sleeping: {...state.sleeping}..remove(kitty),
    );
  }

  HomeRoutine cancel(KittyId kitty) {
    if (!locations.containsKey(kitty)) return this;
    return _copy(
      invitations: {...invitations}..remove(kitty),
      journeys: journeys
          .where((j) => j.committed || !j.cats.contains(kitty))
          .toList(),
      notices: {...notices, kitty: RoutineNotice.cancelled},
    );
  }

  static bool eligible(
    HomeActivity kind,
    KittyId kitty,
    HomeNeeds needs,
    DateTime now,
  ) {
    final cat = needs.of(kitty, now);
    return switch (kind) {
      HomeActivity.rest => true,
      HomeActivity.eat => needs.canEatFromBowl(kitty, now),
      HomeActivity.play => !cat.isJoyFull && cat.played(now) != null,
      HomeActivity.brush ||
      HomeActivity.pet => !cat.isJoyFull && cat.petted(now) != null,
    };
  }

  /// A removed optional facility can interrupt an action without its effect.
  /// Basic bowl/ball/brush cannot be disabled by room decoration.
  HomeRoutine interrupt(KittyId kitty) => _copy(
    activities: {...activities}..remove(kitty),
    invitations: {...invitations}..remove(kitty),
    notices: {...notices, kitty: RoutineNotice.facilityRemoved},
  );

  ({HomeRoutine routine, HomeNeeds needs}) advance(
    double dt,
    HomeNeeds needs,
    DateTime now, {
    Random? random,
    bool paused = false,
    RoomItemId? toy,
  }) {
    if (paused || !dt.isFinite || dt < 0) return (routine: this, needs: needs);
    final rng = random ?? Random();
    var state = this;
    final positions = {...locations};
    final requests = {...invitations};
    final travels = <HomeJourney>[];
    for (final j in journeys) {
      final next = j.at(min(1, j.elapsed + dt));
      if (!j.committed && next.committed) {
        positions[j.kitty] = j.to;
        if (j.other case final other?) positions[other] = j.from;
      }
      if (next.elapsed < 1) {
        travels.add(next);
      } else {
        for (final k in next.cats) {
          final request = requests[k];
          if (request != null && request.kind.area == positions[k]) {
            requests[k] = request.atFacility();
          }
        }
      }
    }
    final actions = <KittyId, HomeAction>{};
    final brushed = {...brushedAt};
    final timers = {
      for (final k in locations.keys) k: max(0.0, (idle[k] ?? 4) - dt),
    };
    for (final e in activities.entries) {
      final action = e.value;
      if (action.left > dt) {
        actions[e.key] = HomeAction(
          action.id,
          action.kind,
          action.left - dt,
          player: action.player,
          facility: action.facility,
        );
      } else {
        // Recheck quotas at commit, even for an already-started action.
        needs = switch (action.kind) {
          HomeActivity.eat => needs.eatFromBowl(e.key, now) ?? needs,
          HomeActivity.play =>
            !needs.of(e.key, now).isJoyFull
                ? needs.play(e.key, now) ?? needs
                : needs,
          HomeActivity.brush || HomeActivity.pet =>
            !needs.of(e.key, now).isJoyFull
                ? needs.pet(e.key, now) ?? needs
                : needs,
          HomeActivity.rest => needs,
        };
        if (action.kind == HomeActivity.brush && !action.player) {
          brushed[e.key] = now;
        }
        timers[e.key] = 4 + rng.nextDouble() * 4;
      }
    }
    state = state._copy(
      locations: positions,
      journeys: travels,
      activities: actions,
      idle: timers,
      brushedAt: brushed,
      invitations: requests,
    );

    // Pending player invitations always get first opportunity to reserve slots.
    state = state._schedule(needs, now, toy: toy);
    for (final k in KittyId.values.where(locations.containsKey)) {
      if (state.moving(k) ||
          state.activities.containsKey(k) ||
          state.invitations.containsKey(k) ||
          (state.idle[k] ?? 4) > 0) {
        continue;
      }
      HomeActivity? automatic;
      if (eligible(HomeActivity.eat, k, needs, now)) {
        automatic = HomeActivity.eat;
      } else if (needs.of(k, now).joy < 70 &&
          eligible(HomeActivity.play, k, needs, now)) {
        automatic = HomeActivity.play;
      } else {
        final last = brushed[k];
        if ((last == null ||
                !now.isBefore(last.add(const Duration(minutes: 30)))) &&
            eligible(HomeActivity.brush, k, needs, now) &&
            rng.nextInt(4) == 0) {
          automatic = HomeActivity.brush;
        }
      }
      if (automatic != null) state = state.invite(k, automatic, player: false);
      final sleep = automatic == null && rng.nextBool();
      state = state._copy(
        idle: {
          ...state.idle,
          k: sleep ? 12 + rng.nextDouble() * 8 : 4 + rng.nextDouble() * 4,
        },
        sleeping: sleep
            ? {...state.sleeping, k}
            : ({...state.sleeping}..remove(k)),
      );
    }
    state = state._schedule(needs, now, toy: toy);
    return (routine: state, needs: needs);
  }

  HomeRoutine _schedule(HomeNeeds needs, DateTime now, {RoomItemId? toy}) {
    var state = this;
    for (final area in HomeArea.values) {
      final orders = state.queueFor(area);
      var facilityTurn = true;
      for (final k in orders) {
        final request = state.invitations[k]!;
        if (state.activities.containsKey(k)) continue;
        if (!eligible(request.kind, k, needs, now)) {
          state = state._copy(
            invitations: {...state.invitations}..remove(k),
            notices: {...state.notices, k: RoutineNotice.ineligible},
          );
          continue;
        }
        final canStart = facilityTurn;
        facilityTurn = false;
        if (state.moving(k)) continue;
        if (state.locations[k] != area ||
            (!request.arrived && request.kind != HomeActivity.rest)) {
          final from = state.locations[k]!;
          KittyId? other;
          if (from != area &&
              state.present(area).length + state.reserved(area) >=
                  area.capacity) {
            final candidates = state
                .present(area)
                .where(
                  (c) => !state.moving(c) && !state.activities.containsKey(c),
                )
                .toList();
            candidates.sort((a, b) {
              final ap = state.invitations.containsKey(a) ? 1 : 0,
                  bp = state.invitations.containsKey(b) ? 1 : 0;
              return ap != bp ? ap.compareTo(bp) : a.index.compareTo(b.index);
            });
            if (candidates.isEmpty) continue;
            other = candidates.first;
          }
          state = state._copy(
            journeys: [
              ...state.journeys,
              HomeJourney(state.serial + 1, k, from, area, other: other),
            ],
            serial: state.serial + 1,
          );
        } else if (request.kind == HomeActivity.rest) {
          state = state._copy(
            invitations: {...state.invitations}..remove(k),
            idle: {...state.idle, k: 4},
          );
        } else if (canStart &&
            !state.activities.values.any((a) => a.kind.area == area)) {
          state = state._copy(
            activities: {
              ...state.activities,
              k: HomeAction(
                state.serial + 1,
                request.kind,
                request.kind.seconds,
                player: request.player,
                facility: request.kind == HomeActivity.play
                    ? toy
                    : request.kind == HomeActivity.eat
                    ? RoomItemId.mangkuk
                    : null,
              ),
            },
            invitations: {...state.invitations}..remove(k),
            streaks: {
              ...state.streaks,
              area: request.player ? min(2, (state.streaks[area] ?? 0) + 1) : 0,
            },
            serial: state.serial + 1,
          );
          // One facility start per scheduling pass; fairness gets recalculated
          // when it finishes, rather than carrying an old sorted order.
          break;
        }
      }
    }
    return state;
  }

  Map<String, Object?> toJson() => {
    'locations': {for (final e in locations.entries) e.key.name: e.value.name},
    'invitations': {
      for (final e in invitations.entries) e.key.name: e.value.toJson(),
    },
    'activities': {
      for (final e in activities.entries) e.key.name: e.value.toJson(),
    },
    'journeys': journeys.map((j) => j.toJson()).toList(),
    'idle': {for (final e in idle.entries) e.key.name: e.value},
    'brushedAt': {
      for (final e in brushedAt.entries)
        e.key.name: e.value.millisecondsSinceEpoch,
    },
    'streaks': {for (final e in streaks.entries) e.key.name: e.value},
    'serial': serial,
    'sleeping': [
      for (final k in KittyId.values)
        if (sleeping.contains(k)) k.name,
    ],
  };

  factory HomeRoutine.fromJson(
    Map<String, dynamic> json,
    Iterable<KittyId> owned,
  ) {
    final cats = {KittyId.oyen, ...owned};
    final positions = <KittyId, HomeArea>{};
    final rawLocations = json['locations'];
    for (final k in KittyId.values.where(cats.contains)) {
      final area = rawLocations is Map
          ? HomeArea.values.asNameMap()[rawLocations[k.name]]
          : null;
      if (area != null &&
          positions.values.where((a) => a == area).length < area.capacity) {
        positions[k] = area;
      }
    }
    var state = HomeRoutine._(locations: positions).sync(cats);
    var serial = json['serial'] is int ? max(0, json['serial'] as int) : 0;
    final requests = <KittyId, HomeInvitation>{};
    final actions = <KittyId, HomeAction>{};
    final timers = <KittyId, double>{};
    final brushed = <KittyId, DateTime>{};
    for (final k in KittyId.values.where(cats.contains)) {
      Object? entry(String key) =>
          json[key] is Map ? (json[key] as Map)[k.name] : null;
      if (entry('invitations')
          case {
            'kind': final String name,
            'order': final int order,
            'player': final bool player,
          }
          when order >= 0) {
        final kind = HomeActivity.values.asNameMap()[name];
        if (kind != null) {
          requests[k] = HomeInvitation(
            kind,
            order,
            player: player,
            arrived: (entry('invitations') as Map)['arrived'] == true,
          );
          serial = max(serial, order);
        }
      }
      if (entry('activities')
          case {
            'kind': final String name,
            'id': final int id,
            'left': final num left,
            'player': final bool player,
          }
          when id > 0 && left.isFinite && left >= 0) {
        final kind = HomeActivity.values.asNameMap()[name];
        final rawFacility = (entry('activities') as Map)['facility'];
        final facility = RoomItemId.values.asNameMap()[rawFacility];
        if (kind != null &&
            (rawFacility == null || facility != null) &&
            kind != HomeActivity.rest &&
            state.locations[k] == kind.area &&
            left <= kind.seconds &&
            !actions.values.any(
              (a) => a.kind.area == kind.area || a.id == id,
            )) {
          actions[k] = HomeAction(
            id,
            kind,
            left.toDouble(),
            player: player,
            facility: facility,
          );
          serial = max(serial, id);
        }
      }
      if (entry('idle') case final num n when n.isFinite && n >= 0 && n <= 20) {
        timers[k] = n.toDouble();
      }
      if (entry('brushedAt') case final int ms
          when ms >= 0 && ms <= 32503680000000) {
        brushed[k] = DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    state = state._copy(
      invitations: requests,
      activities: actions,
      idle: timers,
      brushedAt: brushed,
      serial: serial,
    );
    final travels = <HomeJourney>[];
    if (json['journeys'] case final List list) {
      for (final raw in list) {
        if (raw
            case {
              'id': final int id,
              'kitty': final String name,
              'from': final String f,
              'to': final String t,
              'elapsed': final num elapsed,
            }
            when id > 0 && elapsed.isFinite && elapsed >= 0 && elapsed < 1) {
          final k = KittyId.values.asNameMap()[name],
              other = KittyId.values.asNameMap()[raw['other']];
          final from = HomeArea.values.asNameMap()[f],
              to = HomeArea.values.asNameMap()[t];
          if (k == null ||
              !cats.contains(k) ||
              from == null ||
              to == null ||
              (from == to && raw['other'] != null) ||
              (raw['other'] != null && other == null)) {
            continue;
          }
          final j = HomeJourney(
            id,
            k,
            from,
            to,
            other: other,
            elapsed: elapsed.toDouble(),
          );
          if (other == k ||
              (other != null && !cats.contains(other)) ||
              j.cats.any(
                (c) =>
                    actions.containsKey(c) ||
                    travels.any((p) => p.cats.contains(c)),
              ) ||
              state.locations[k] != (j.committed ? to : from) ||
              (other != null &&
                  state.locations[other] != (j.committed ? from : to)) ||
              (other == null &&
                  from != to &&
                  !j.committed &&
                  state.present(to).length +
                          travels
                              .where(
                                (p) =>
                                    p.other == null &&
                                    !p.committed &&
                                    p.to == to,
                              )
                              .length >=
                      to.capacity) ||
              actions.values.any((a) => a.id == id) ||
              travels.any((p) => p.id == id)) {
            continue;
          }
          travels.add(j);
          serial = max(serial, id);
        }
      }
    }
    final streaks = <HomeArea, int>{};
    if (json['streaks'] case final Map map) {
      for (final a in HomeArea.values) {
        if (map[a.name] case final int n when n >= 0 && n <= 2) streaks[a] = n;
      }
    }
    return state._copy(
      journeys: travels,
      serial: serial,
      streaks: streaks,
      sleeping: {
        if (json['sleeping'] case final List list)
          for (final k in KittyId.values)
            if (cats.contains(k) &&
                list.contains(k.name) &&
                !actions.containsKey(k) &&
                !travels.any((j) => j.cats.contains(k)))
              k,
      },
    );
  }
}
