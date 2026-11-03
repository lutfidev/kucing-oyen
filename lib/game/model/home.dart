import 'accessories.dart';
import 'kitties.dart';
import 'room.dart';
import 'snacks.dart';

/// Isi rumah Oyen yang dibeli pemain: kamar dan tata letaknya, kucing,
/// aksesoris, dan stok camilan. Disimpan sebagai satu JSON, supaya satu
/// pembelian tidak terbelah di dua simpanan.
class Home {
  Home({
    Room? room,
    Iterable<KittyId> kitties = const [],
    AccessoryCloset? closet,
    Pantry? pantry,
    Iterable<KittyId> fresh = const [],
  }) : this._(
         room ?? Room.initial,
         Set.unmodifiable({KittyId.oyen, ...kitties}),
         closet ?? AccessoryCloset.initial,
         pantry ?? Pantry.empty,
         fresh,
       );

  Home._(
    this.room,
    this.kitties,
    this.closet,
    this.pantry,
    Iterable<KittyId> fresh,
  ) : fresh = Set.unmodifiable({
        for (final k in fresh)
          if (k != KittyId.oyen && kitties.contains(k)) k,
      });

  /// Awal permainan: hanya Oyen dan mangkuk.
  static final initial = Home();

  final Room room;

  /// Kucing yang tinggal di kamar; Oyen selalu ada.
  final Set<KittyId> kitties;

  final AccessoryCloset closet;
  final Pantry pantry;

  /// Kucing yang baru diadopsi dan kartunya belum pernah dibuka (tag
  /// "Baru!"); Oyen tidak pernah baru.
  final Set<KittyId> fresh;

  bool ownsKitty(KittyId id) => kitties.contains(id);

  /// Belum dimiliki dan [coins] cukup untuk harganya.
  bool canBuyKitty(KittyId id, int coins) =>
      !ownsKitty(id) && coins >= kittyOf(id).price;

  bool isFresh(KittyId id) => fresh.contains(id);

  /// [id] mulai tinggal di kamar dan ditandai baru.
  Home adopt(KittyId id) =>
      copyWith(kitties: {...kitties, id}, fresh: {...fresh, id});

  /// Kartu [id] sudah dibuka: tanda barunya hilang.
  Home seen(KittyId id) =>
      isFresh(id) ? copyWith(fresh: {...fresh}..remove(id)) : this;

  Home copyWith({
    Room? room,
    Iterable<KittyId>? kitties,
    AccessoryCloset? closet,
    Pantry? pantry,
    Iterable<KittyId>? fresh,
  }) => Home(
    room: room ?? this.room,
    kitties: kitties ?? this.kitties,
    closet: closet ?? this.closet,
    pantry: pantry ?? this.pantry,
    fresh: fresh ?? this.fresh,
  );

  Map<String, Object?> toJson() => {
    'room': room.toJson(),
    'kitties': [
      for (final k in kitties)
        if (k != KittyId.oyen) k.name,
    ],
    'closet': closet.toJson(),
    'pantry': pantry.toJson(),
    'fresh': [
      for (final k in KittyId.values)
        if (fresh.contains(k)) k.name,
    ],
  };

  /// Bagian yang rusak kembali ke awal; simpanan tanpa `fresh` = tidak ada
  /// kucing baru. Aksesoris yang dipakai kucing
  /// yang tidak dimiliki dibuang.
  factory Home.fromJson(Map<String, dynamic> json) {
    T part<T>(String key, T Function(Map<String, dynamic>) parse, T empty) =>
        switch (json[key]) {
          final Map<String, dynamic> value => parse(value),
          _ => empty,
        };
    final names = KittyId.values.asNameMap();
    final kitties = {
      KittyId.oyen,
      if (json['kitties'] case final List list)
        for (final name in list) ?names[name],
    };
    final closet = part(
      'closet',
      AccessoryCloset.fromJson,
      AccessoryCloset.initial,
    );
    return Home(
      room: part('room', Room.fromJson, Room.initial),
      kitties: kitties,
      closet: AccessoryCloset(
        owned: closet.owned,
        wearing: {
          for (final MapEntry(:key, :value) in closet.wearing.entries)
            if (kitties.contains(key)) key: value,
        },
      ),
      pantry: part('pantry', Pantry.fromJson, Pantry.empty),
      fresh: [
        if (json['fresh'] case final List list)
          for (final name in list) ?names[name],
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Home &&
      other.room == room &&
      other.kitties.length == kitties.length &&
      other.kitties.containsAll(kitties) &&
      other.closet == closet &&
      other.pantry == pantry &&
      other.fresh.length == fresh.length &&
      other.fresh.containsAll(fresh);

  @override
  int get hashCode => Object.hash(
    room,
    Object.hashAllUnordered(kitties),
    closet,
    pantry,
    Object.hashAllUnordered(fresh),
  );

  @override
  String toString() => 'Home(${toJson()})';
}
