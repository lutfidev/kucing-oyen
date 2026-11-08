import 'home.dart';
import 'home_items.dart';

/// Gameplay identity, independent of rendering and translated tab labels.
enum HomeArea {
  santai(3),
  makan(2),
  main(2),
  rawat(2);

  const HomeArea(this.capacity);
  final int capacity;
}

HomeArea initialItemArea(RoomItemId id) => switch (id) {
  RoomItemId.mangkuk => HomeArea.makan,
  RoomItemId.tikus ||
  RoomItemId.catnip ||
  RoomItemId.bola ||
  RoomItemId.tiang ||
  RoomItemId.pancingan ||
  RoomItemId.terowongan => HomeArea.main,
  _ => HomeArea.santai,
};

Set<HomeArea> allowedItemAreas(RoomItemId id) => switch (id) {
  RoomItemId.mangkuk => {HomeArea.makan},
  RoomItemId.tikus ||
  RoomItemId.catnip ||
  RoomItemId.bola ||
  RoomItemId.tiang ||
  RoomItemId.pancingan ||
  RoomItemId.terowongan => {HomeArea.main},
  RoomItemId.akuarium ||
  RoomItemId.jendelaBurung => {HomeArea.santai, HomeArea.main},
  RoomItemId.jam ||
  RoomItemId.lukisan ||
  RoomItemId.rak ||
  RoomItemId.monstera => HomeArea.values.toSet(),
  _ => {HomeArea.santai, HomeArea.rawat},
};

/// Discrete safe anchors; the room renderer maps these to its own canvas.
/// Floor anchors exclude the central doorway/activity lane, wall anchors
/// exclude the navigation band. No legacy pixel positions are reused.
class AreaSlot {
  const AreaSlot(this.area, this.zone, this.index);
  final HomeArea area;
  final RoomZone zone;
  final int index;
  bool get valid => index >= 0 && index < (zone == RoomZone.floor ? 4 : 3);

  /// Normalized anchor centers on the v2 room canvas. The center strip stays
  /// available for doorway travel and built-in activity animations.
  Spot get anchor => zone == RoomZone.wall
      ? Spot([.16, .5, .84][index], .25)
      : Spot(index.isEven ? .18 : .82, index < 2 ? .62 : .88);
  Map<String, Object?> toJson() => {
    'area': area.name,
    'zone': zone.name,
    'slot': index,
  };
  static AreaSlot? fromJson(Object? json) {
    if (json case {
      'area': final String a,
      'zone': final String z,
      'slot': final int n,
    }) {
      final area = HomeArea.values.asNameMap()[a];
      final zone = RoomZone.values.asNameMap()[z];
      if (area != null && zone != null) {
        final slot = AreaSlot(area, zone, n);
        if (slot.valid) return slot;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is AreaSlot &&
      other.area == area &&
      other.zone == zone &&
      other.index == index;
  @override
  int get hashCode => Object.hash(area, zone, index);
}

class HomeAreas {
  HomeAreas._(Map<RoomItemId, AreaSlot> placed)
    : placed = Map.unmodifiable(placed);
  final Map<RoomItemId, AreaSlot> placed;

  factory HomeAreas.migrate(Home home) {
    var areas = HomeAreas._({
      RoomItemId.mangkuk: const AreaSlot(HomeArea.makan, RoomZone.floor, 0),
    });
    for (final id in RoomItemId.values) {
      if (id != RoomItemId.mangkuk && home.room.isPlaced(id)) {
        areas = areas._add(home, id);
      }
    }
    return areas;
  }

  HomeAreas _add(Home home, RoomItemId id) {
    final zone = roomItemOf(id).zone;
    final area = initialItemArea(id);
    for (var n = 0; n < (zone == RoomZone.floor ? 4 : 3); n++) {
      final slot = AreaSlot(area, zone, n);
      if (!placed.containsValue(slot)) return place(home, id, slot);
    }
    return this; // Owned, safely in storage when the initial area is full.
  }

  /// New purchases get a safe slot; existing storage remains storage.
  HomeAreas sync(Home before, Home after) {
    var next = HomeAreas._({
      for (final e in placed.entries)
        if (after.room.owns(e.key) && after.room.isPlaced(e.key))
          e.key: e.value,
    });
    for (final id in RoomItemId.values) {
      if (after.room.isPlaced(id) &&
          (!before.room.owns(id) || !before.room.isPlaced(id))) {
        next = next._add(after, id);
      }
    }
    return next;
  }

  HomeAreas place(Home home, RoomItemId id, AreaSlot slot) {
    if (!home.room.owns(id) ||
        !slot.valid ||
        slot.zone != roomItemOf(id).zone ||
        !allowedItemAreas(id).contains(slot.area) ||
        placed.entries.any((e) => e.key != id && e.value == slot) ||
        (id == RoomItemId.mangkuk &&
            slot != const AreaSlot(HomeArea.makan, RoomZone.floor, 0))) {
      return this;
    }
    return HomeAreas._({...placed, id: slot});
  }

  HomeAreas store(RoomItemId id) =>
      id == RoomItemId.mangkuk || !placed.containsKey(id)
      ? this
      : HomeAreas._({...placed}..remove(id));
  Map<String, Object?> toJson() => {
    'placed': {
      for (final id in RoomItemId.values)
        if (placed.containsKey(id)) id.name: placed[id]!.toJson(),
    },
  };
  @override
  bool operator ==(Object other) =>
      other is HomeAreas &&
      placed.length == other.placed.length &&
      placed.entries.every((e) => other.placed[e.key] == e.value);
  @override
  int get hashCode => Object.hashAllUnordered(
    placed.entries.map((e) => Object.hash(e.key, e.value)),
  );
  factory HomeAreas.fromJson(Map<String, dynamic> json, Home home) {
    var result = HomeAreas._({
      RoomItemId.mangkuk: const AreaSlot(HomeArea.makan, RoomZone.floor, 0),
    });
    if (json['placed'] case final Map<String, dynamic> items) {
      for (final id in RoomItemId.values) {
        final slot = AreaSlot.fromJson(items[id.name]);
        if (slot != null) result = result.place(home, id, slot);
      }
    }
    return result;
  }
}
