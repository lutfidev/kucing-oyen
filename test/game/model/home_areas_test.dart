import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/room.dart';

void main() {
  test('migration preserves ownership, storage and bounded catalog slots', () {
    final home = Home(
      room: Room(
        owned: RoomItemId.values,
        placed: {
          for (final i in RoomItemId.values) i: roomItemOf(i).defaultSpot,
        },
      ),
    );
    final areas = HomeAreas.migrate(home);
    expect(areas.placed[RoomItemId.mangkuk]?.area, HomeArea.makan);
    for (final area in HomeArea.values) {
      for (final zone in RoomZone.values) {
        final slots = areas.placed.values.where(
          (s) => s.area == area && s.zone == zone,
        );
        expect(slots.length, lessThanOrEqualTo(zone == RoomZone.floor ? 4 : 3));
        expect(slots.map((s) => s.index).toSet().length, slots.length);
      }
    }
    expect(areas.placed[RoomItemId.tikus]?.area, HomeArea.main);
    expect(areas.placed[RoomItemId.akuarium]?.area, HomeArea.santai);
    expect(areas.placed.length, lessThan(home.room.owned.length));
    expect(HomeAreas.fromJson(areas.toJson(), home).toJson(), areas.toJson());
    expect(home.room.owned, containsAll(RoomItemId.values));
  });

  test('storage, invalid destinations and built-in bowl are respected', () {
    final home = Home(
      room: Room(
        owned: [RoomItemId.bola, RoomItemId.jam],
        placed: {RoomItemId.jam: roomItemOf(RoomItemId.jam).defaultSpot},
      ),
    );
    final areas = HomeAreas.migrate(home);
    expect(areas.placed.containsKey(RoomItemId.bola), isFalse);
    expect(
      areas.place(
        home,
        RoomItemId.bola,
        const AreaSlot(HomeArea.rawat, RoomZone.floor, 1),
      ),
      same(areas),
    );
    expect(areas.store(RoomItemId.mangkuk), same(areas));
    final placed = areas.place(
      home,
      RoomItemId.bola,
      const AreaSlot(HomeArea.main, RoomZone.floor, 0),
    );
    expect(placed.placed.containsKey(RoomItemId.bola), isTrue);
    expect(
      placed.store(RoomItemId.bola).placed.containsKey(RoomItemId.bola),
      isFalse,
    );
    expect(
      HomeAreas.fromJson({
        'placed': {
          'alien': {},
          'jam': {'area': 'bad'},
        },
      }, home).placed.keys,
      contains(RoomItemId.mangkuk),
    );
  });
}
