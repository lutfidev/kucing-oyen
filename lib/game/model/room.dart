import 'home_items.dart';
import 'house.dart';

/// Barang rumah yang dimiliki pemain, letaknya, dan ruangannya. Barang yang
/// dimiliki tapi tidak ditaruh ada di Gudang. Mangkuk bawaan selalu
/// dimiliki dan selalu ditaruh di ruang tengah. Barang lantai tidak pernah
/// menutup jalur pintu ([HouseFloor.allowedSpot]).
class Room {
  /// Barang yang dibaca dari simpanan dan menutup jalur pintu (mis. tiang
  /// garukan lama di jalur pintu depan) dipindah ke tempat bebas terdekat
  /// ([HouseFloor.freeSpot]), urut katalog sesudah barang yang tidak
  /// menutup; kalau ruangannya penuh, barang itu masuk Gudang. Mangkuk
  /// tidak pernah ke Gudang. Barang lain tidak bergeser. [floor] hanya
  /// diganti di test.
  factory Room({
    Iterable<RoomItemId> owned = const [],
    Map<RoomItemId, Spot> placed = const {},
    Map<RoomItemId, HouseRoom> rooms = const {},
    HouseFloor floor = const HouseFloor(),
  }) {
    final all = {RoomItemId.mangkuk, ...owned};
    final spots = {
      RoomItemId.mangkuk: roomItemOf(RoomItemId.mangkuk).defaultSpot,
      for (final MapEntry(:key, :value) in placed.entries)
        if (all.contains(key)) key: value,
    };
    final terrace = {
      for (final MapEntry(:key, :value) in rooms.entries)
        if (spots.containsKey(key) &&
            value == HouseRoom.terrace &&
            canPlaceIn(key, value))
          key: value,
    };
    HouseRoom roomOf(RoomItemId id) => terrace[id] ?? HouseRoom.living;
    final kept = <RoomItemId, Spot>{};
    final blocked = <RoomItem>[];
    for (final item in roomItems) {
      final spot = spots[item.id];
      if (spot == null) continue;
      if (floor.blocksDoor(item, roomOf(item.id), spot)) {
        blocked.add(item);
      } else {
        kept[item.id] = spot;
      }
    }
    for (final item in blocked) {
      final room = roomOf(item.id);
      final free = floor.freeSpot(item, room, spots[item.id]!, [
        for (final MapEntry(:key, :value) in kept.entries)
          if (roomOf(key) == room) (item: roomItemOf(key), spot: value),
      ]);
      if (free != null) {
        kept[item.id] = free;
      } else if (item.builtIn) {
        kept[item.id] = floor.allowedSpot(item, room, spots[item.id]!);
      } else {
        terrace.remove(item.id);
      }
    }
    return Room._(all, kept, terrace);
  }

  Room._(
    Set<RoomItemId> owned,
    Map<RoomItemId, Spot> placed,
    Map<RoomItemId, HouseRoom> rooms,
  ) : owned = Set.unmodifiable(owned),
      placed = Map.unmodifiable(placed),
      _rooms = Map.unmodifiable(rooms);

  /// Awal permainan: rumah kosong dengan mangkuk.
  static final initial = Room();

  static Spot _allowed(RoomItemId id, HouseRoom room, Spot spot) =>
      const HouseFloor().allowedSpot(roomItemOf(id), room, spot);

  final Set<RoomItemId> owned;
  final Map<RoomItemId, Spot> placed;

  /// Hanya barang teras; selain itu ruang tengah.
  final Map<RoomItemId, HouseRoom> _rooms;

  bool owns(RoomItemId id) => owned.contains(id);

  bool isPlaced(RoomItemId id) => placed.containsKey(id);

  /// Letak [id]; null kalau tidak ditaruh.
  Spot? spotOf(RoomItemId id) => placed[id];

  /// Ruangan barang [id] (barang di Gudang: ruang tengah).
  HouseRoom roomOf(RoomItemId id) => _rooms[id] ?? HouseRoom.living;

  /// Barang yang ditaruh di [room].
  Map<RoomItemId, Spot> placedIn(HouseRoom room) => {
    for (final MapEntry(:key, :value) in placed.entries)
      if (roomOf(key) == room) key: value,
  };

  /// Barang di Gudang, urut katalog.
  List<RoomItemId> get stored => [
    for (final item in roomItems)
      if (owns(item.id) && !isPlaced(item.id)) item.id,
  ];

  /// Dijual, belum dimiliki, dan [coins] cukup untuk harganya.
  bool canBuy(RoomItemId id, int coins) {
    final item = roomItemOf(id);
    return !item.builtIn && !owns(id) && coins >= item.price;
  }

  /// [id] menjadi milik pemain dan ditaruh di tempat pertama yang muat
  /// ([buyPlaced]). Koin dipotong pemanggil.
  Room buy(RoomItemId id) => buyPlaced(id).room;

  /// Beli [id] (spec langkah 40, G5): ditaruh di posisi bawaannya di ruang
  /// tengah atau tempat bebas terdekat ([HouseFloor.freeSpot]); kalau ruang
  /// tengah penuh, di teras (kalau boleh); selain itu di Gudang (`at` =
  /// null). Tidak berubah kalau sudah dimiliki atau barang bawaan.
  ({Room room, HouseRoom? at}) buyPlaced(
    RoomItemId id, {
    HouseFloor floor = const HouseFloor(),
  }) {
    final item = roomItemOf(id);
    if (owns(id) || item.builtIn) return (room: this, at: roomOf(id));
    for (final room in HouseRoom.values) {
      if (!canPlaceIn(id, room)) continue;
      // Gantungan teras punya tempat tetap.
      final spot = room == HouseRoom.terrace && terraceHangers.contains(id)
          ? item.defaultSpot
          : floor.freeSpot(item, room, item.defaultSpot, _others(room));
      if (spot == null) continue;
      return (
        room: Room._({...owned, id}, {...placed, id: spot}, {
          ..._rooms,
          if (room == HouseRoom.terrace) id: room,
        }),
        at: room,
      );
    }
    return (room: Room._({...owned, id}, placed, _rooms), at: null);
  }

  /// Tempat [id] saat diketuk dari Gudang (langkah 40): spot bawaannya
  /// kalau bebas, selain itu tempat bebas terdekat di [room]
  /// ([HouseFloor.freeSpot]); kalau ruangan penuh tetap spot bawaan
  /// (pemain bisa menggesernya). Gantungan teras selalu di tempatnya.
  Spot freeSpotFor(
    RoomItemId id,
    HouseRoom room, {
    HouseFloor floor = const HouseFloor(),
  }) {
    final item = roomItemOf(id);
    if (room == HouseRoom.terrace && terraceHangers.contains(id)) {
      return item.defaultSpot;
    }
    final others = [
      for (final o in _others(room))
        if (o.item.id != id) o,
    ];
    return floor.freeSpot(item, room, item.defaultSpot, others) ??
        item.defaultSpot;
  }

  /// Barang [room] yang ikut dihitung saat mencari tempat bebas (tanpa
  /// gantungan teras, yang tempatnya tetap).
  List<({RoomItem item, Spot spot})> _others(HouseRoom room) => [
    for (final MapEntry(:key, :value) in placedIn(room).entries)
      if (!(room == HouseRoom.terrace && terraceHangers.contains(key)))
        (item: roomItemOf(key), spot: value),
  ];

  /// Merapikan [room] (spec langkah 40, G6): mangkuk lebih dulu, lalu
  /// barang lain urut katalog. Barang yang tidak menutup jalur pintu dan
  /// tidak menumpuk dengan barang yang sudah diproses ([HouseFloor.stacks])
  /// tetap di tempatnya; selain itu pindah ke tempat bebas terdekat di
  /// ruangan itu, atau ke Gudang kalau penuh (mangkuk tidak pernah ke
  /// Gudang). Karpet dan gantungan teras tidak disentuh, ruangan lain
  /// juga tidak.
  Room tidy(HouseRoom room, {HouseFloor floor = const HouseFloor()}) {
    final here = placedIn(room);
    final order = [
      if (here.containsKey(RoomItemId.mangkuk)) roomItemOf(RoomItemId.mangkuk),
      for (final item in roomItems)
        if (!item.builtIn && here.containsKey(item.id)) item,
    ];
    final kept = <({RoomItem item, Spot spot})>[];
    final spots = {...placed};
    final rooms = {..._rooms};
    for (final item in order) {
      final spot = here[item.id]!;
      if (item.flat ||
          (room == HouseRoom.terrace && terraceHangers.contains(item.id))) {
        continue;
      }
      final free =
          floor.freeSpot(item, room, spot, kept) ??
          (item.builtIn ? floor.allowedSpot(item, room, spot) : null);
      if (free == null) {
        spots.remove(item.id);
        rooms.remove(item.id);
        continue;
      }
      spots[item.id] = free;
      kept.add((item: item, spot: free));
    }
    return Room._(owned, spots, rooms);
  }

  /// Barang yang letaknya berbeda dari [before]: pindah tempat, pindah
  /// ruangan, atau masuk/keluar Gudang.
  Set<RoomItemId> movedFrom(Room before) => {
    for (final id in owned)
      if (spotOf(id) != before.spotOf(id) ||
          (isPlaced(id) && roomOf(id) != before.roomOf(id)))
        id,
  };

  /// Menaruh [id] di [spot] di [room] (juga dari Gudang); tidak berubah
  /// kalau belum dimiliki atau tidak boleh di ruangan itu ([canPlaceIn]).
  Room place(RoomItemId id, Spot spot, {HouseRoom room = HouseRoom.living}) =>
      owns(id) && canPlaceIn(id, room)
      ? Room._(
          owned,
          {...placed, id: _allowed(id, room, spot)},
          {
            for (final MapEntry(:key, :value) in _rooms.entries)
              if (key != id) key: value,
            if (room == HouseRoom.terrace) id: room,
          },
        )
      : this;

  /// Memindahkan [id] ke Gudang; mangkuk dan barang yang tidak ditaruh
  /// tidak berubah.
  Room store(RoomItemId id) => roomItemOf(id).builtIn || !isPlaced(id)
      ? this
      : Room._(owned, {...placed}..remove(id), {..._rooms}..remove(id));

  Map<String, Object?> toJson() => {
    'tidy': 1,
    'owned': [
      for (final item in roomItems)
        if (owns(item.id) && !item.builtIn) item.id.name,
    ],
    'placed': {
      for (final MapEntry(:key, :value) in placed.entries)
        key.name: value.toJson(),
    },
    'terrace': [
      for (final item in roomItems)
        if (_rooms.containsKey(item.id)) item.id.name,
    ],
  };

  /// Nama barang yang tidak dikenal, letak yang rusak, dan letak barang
  /// yang tidak dimiliki dibuang. Tanpa `terrace` (simpanan v1), semua
  /// barang di ruang tengah; barang yang tidak boleh di teras juga. Tanpa
  /// `tidy: 1` (simpanan sebelum langkah 40), kedua ruangan dirapikan
  /// sekali ([tidy]); [toJson] selalu menulis tandanya.
  factory Room.fromJson(
    Map<String, dynamic> json, {
    HouseFloor floor = const HouseFloor(),
  }) {
    final names = RoomItemId.values.asNameMap();
    final owned = json['owned'];
    final placed = json['placed'];
    final terrace = json['terrace'];
    final room = Room(
      owned: [
        if (owned is List)
          for (final name in owned) ?names[name],
      ],
      placed: {
        if (placed is Map<String, dynamic>)
          for (final MapEntry(:key, :value) in placed.entries)
            if ((names[key], Spot.fromJson(value)) case (
              final RoomItemId id,
              final Spot spot,
            ))
              id: spot,
      },
      rooms: {
        if (terrace is List)
          for (final name in terrace)
            if (names[name] case final RoomItemId id) id: HouseRoom.terrace,
      },
      floor: floor,
    );
    if (json['tidy'] == 1) return room;
    return room
        .tidy(HouseRoom.living, floor: floor)
        .tidy(HouseRoom.terrace, floor: floor);
  }

  @override
  bool operator ==(Object other) =>
      other is Room &&
      other.owned.length == owned.length &&
      other.owned.containsAll(owned) &&
      other.placed.length == placed.length &&
      placed.entries.every((e) => other.placed[e.key] == e.value) &&
      other._rooms.length == _rooms.length &&
      _rooms.keys.every(other._rooms.containsKey);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(owned),
    Object.hashAllUnordered([
      for (final e in placed.entries) Object.hash(e.key, e.value),
    ]),
    Object.hashAllUnordered(_rooms.keys),
  );

  @override
  String toString() {
    final spots = [
      for (final e in placed.entries)
        '${e.key.name} ${roomOf(e.key).name} ${e.value}',
    ];
    return 'Room(${spots.join(', ')}; gudang ${stored.join(', ')})';
  }
}
