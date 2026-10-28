import 'home_items.dart';

/// Barang kamar yang dimiliki pemain dan letak yang ditaruh. Barang yang
/// dimiliki tapi tidak ditaruh ada di Gudang. Mangkuk bawaan selalu
/// dimiliki dan selalu ditaruh.
class Room {
  factory Room({
    Iterable<RoomItemId> owned = const [],
    Map<RoomItemId, Spot> placed = const {},
  }) {
    final all = {RoomItemId.mangkuk, ...owned};
    return Room._(Set.unmodifiable(all), {
      RoomItemId.mangkuk: roomItemOf(RoomItemId.mangkuk).defaultSpot,
      for (final MapEntry(:key, :value) in placed.entries)
        if (all.contains(key)) key: value,
    });
  }

  Room._(this.owned, Map<RoomItemId, Spot> placed)
    : placed = Map.unmodifiable(placed);

  /// Awal permainan: kamar kosong dengan mangkuk.
  static final initial = Room();

  final Set<RoomItemId> owned;
  final Map<RoomItemId, Spot> placed;

  bool owns(RoomItemId id) => owned.contains(id);

  bool isPlaced(RoomItemId id) => placed.containsKey(id);

  /// Letak [id] di kamar; null kalau tidak ditaruh.
  Spot? spotOf(RoomItemId id) => placed[id];

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

  /// [id] menjadi milik pemain dan ditaruh di posisi bawaannya. Koin
  /// dipotong pemanggil.
  Room buy(RoomItemId id) => owns(id) || roomItemOf(id).builtIn
      ? this
      : Room._({...owned, id}, {...placed, id: roomItemOf(id).defaultSpot});

  /// Menaruh [id] di [spot] (juga dari Gudang); tidak berubah kalau belum
  /// dimiliki.
  Room place(RoomItemId id, Spot spot) =>
      owns(id) ? Room._(owned, {...placed, id: spot}) : this;

  /// Memindahkan [id] ke Gudang; mangkuk dan barang yang tidak ditaruh
  /// tidak berubah.
  Room store(RoomItemId id) => roomItemOf(id).builtIn || !isPlaced(id)
      ? this
      : Room._(owned, {...placed}..remove(id));

  Map<String, Object?> toJson() => {
    'owned': [
      for (final item in roomItems)
        if (owns(item.id) && !item.builtIn) item.id.name,
    ],
    'placed': {
      for (final MapEntry(:key, :value) in placed.entries)
        key.name: value.toJson(),
    },
  };

  /// Nama barang yang tidak dikenal, letak yang rusak, dan letak barang
  /// yang tidak dimiliki dibuang.
  factory Room.fromJson(Map<String, dynamic> json) {
    final names = RoomItemId.values.asNameMap();
    final owned = json['owned'];
    final placed = json['placed'];
    return Room(
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
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Room &&
      other.owned.length == owned.length &&
      other.owned.containsAll(owned) &&
      other.placed.length == placed.length &&
      placed.entries.every((e) => other.placed[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(owned),
    Object.hashAllUnordered([
      for (final e in placed.entries) Object.hash(e.key, e.value),
    ]),
  );

  @override
  String toString() {
    final spots = [for (final e in placed.entries) '${e.key.name} ${e.value}'];
    return 'Room(${spots.join(', ')}; gudang ${stored.join(', ')})';
  }
}
