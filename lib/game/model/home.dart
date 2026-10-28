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
  }) : room = room ?? Room.initial,
       kitties = Set.unmodifiable({KittyId.oyen, ...kitties}),
       closet = closet ?? AccessoryCloset.initial,
       pantry = pantry ?? Pantry.empty;

  /// Awal permainan: hanya Oyen dan mangkuk.
  static final initial = Home();

  final Room room;

  /// Kucing yang tinggal di kamar; Oyen selalu ada.
  final Set<KittyId> kitties;

  final AccessoryCloset closet;
  final Pantry pantry;

  bool ownsKitty(KittyId id) => kitties.contains(id);

  /// Belum dimiliki dan [coins] cukup untuk harganya.
  bool canBuyKitty(KittyId id, int coins) =>
      !ownsKitty(id) && coins >= kittyOf(id).price;

  Home copyWith({
    Room? room,
    Iterable<KittyId>? kitties,
    AccessoryCloset? closet,
    Pantry? pantry,
  }) => Home(
    room: room ?? this.room,
    kitties: kitties ?? this.kitties,
    closet: closet ?? this.closet,
    pantry: pantry ?? this.pantry,
  );

  Map<String, Object?> toJson() => {
    'room': room.toJson(),
    'kitties': [
      for (final k in kitties)
        if (k != KittyId.oyen) k.name,
    ],
    'closet': closet.toJson(),
    'pantry': pantry.toJson(),
  };

  /// Bagian yang rusak kembali ke awal. Aksesoris yang dipakai kucing
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
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Home &&
      other.room == room &&
      other.kitties.length == kitties.length &&
      other.kitties.containsAll(kitties) &&
      other.closet == closet &&
      other.pantry == pantry;

  @override
  int get hashCode =>
      Object.hash(room, Object.hashAllUnordered(kitties), closet, pantry);

  @override
  String toString() => 'Home(${toJson()})';
}
