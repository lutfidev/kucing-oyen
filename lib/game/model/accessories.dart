import 'kitties.dart';

/// Aksesoris, urut kartu tab Aksesoris (`Toko.dc.html`). Namanya per
/// bahasa ditambahkan bersama layar Toko.
enum AccessoryId {
  pita,
  jepitBunga,
  bandana,
  dasiKupu,
  kalung,
  syal,
  beanie,
  topiKoki,
  baret,
  kacamata,
  headphone,
  tandukRusa,
  topiPesta,
  topiPenyihir,
  mahkota,
  mahkotaRaja,
}

/// Kelangkaan di kartu Toko: Biasa, Langka, Spesial.
enum Rarity { common, rare, special }

/// Tempat aksesoris di grup kepala sprite (desain 21b).
enum AccessoryAnchor { headTop, headSideRight, headSideLeft, neck, face }

class Accessory {
  const Accessory(this.id, this.price, this.rarity, this.anchor);

  final AccessoryId id;
  final int price;
  final Rarity rarity;
  final AccessoryAnchor anchor;
}

/// Harga dan kelangkaan dari `Toko.dc.html`, jangkar dari
/// `AksesorisPreview.dc.html`.
const accessories = [
  Accessory(AccessoryId.pita, 50, Rarity.common, AccessoryAnchor.headSideRight),
  Accessory(
    AccessoryId.jepitBunga,
    60,
    Rarity.common,
    AccessoryAnchor.headSideLeft,
  ),
  Accessory(AccessoryId.bandana, 80, Rarity.common, AccessoryAnchor.neck),
  Accessory(AccessoryId.dasiKupu, 90, Rarity.common, AccessoryAnchor.neck),
  Accessory(AccessoryId.kalung, 120, Rarity.common, AccessoryAnchor.neck),
  Accessory(AccessoryId.syal, 140, Rarity.common, AccessoryAnchor.neck),
  Accessory(AccessoryId.beanie, 180, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(AccessoryId.topiKoki, 200, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(AccessoryId.baret, 220, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(AccessoryId.kacamata, 250, Rarity.rare, AccessoryAnchor.face),
  Accessory(AccessoryId.headphone, 280, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(AccessoryId.tandukRusa, 320, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(AccessoryId.topiPesta, 350, Rarity.rare, AccessoryAnchor.headTop),
  Accessory(
    AccessoryId.topiPenyihir,
    520,
    Rarity.special,
    AccessoryAnchor.headTop,
  ),
  Accessory(AccessoryId.mahkota, 600, Rarity.special, AccessoryAnchor.headTop),
  Accessory(
    AccessoryId.mahkotaRaja,
    800,
    Rarity.special,
    AccessoryAnchor.headTop,
  ),
];

Accessory accessoryOf(AccessoryId id) => accessories[id.index];

/// Aksesoris yang dimiliki pemain dan yang dipakai tiap kucing. Sekali
/// beli, semua kucing boleh memakainya, juga beberapa kucing sekaligus;
/// satu kucing paling banyak satu aksesoris. Memasang dan melepas gratis.
class AccessoryCloset {
  /// Aksesoris dipakai yang tidak dimiliki dibuang.
  AccessoryCloset({
    Iterable<AccessoryId> owned = const [],
    Map<KittyId, AccessoryId> wearing = const {},
  }) : this._(Set.unmodifiable(owned), wearing);

  AccessoryCloset._(this.owned, Map<KittyId, AccessoryId> wearing)
    : wearing = Map.unmodifiable({
        for (final MapEntry(:key, :value) in wearing.entries)
          if (owned.contains(value)) key: value,
      });

  /// Awal permainan: belum punya aksesoris.
  static final initial = AccessoryCloset();

  final Set<AccessoryId> owned;
  final Map<KittyId, AccessoryId> wearing;

  bool owns(AccessoryId id) => owned.contains(id);

  /// Belum dimiliki dan [coins] cukup untuk harganya.
  bool canBuy(AccessoryId id, int coins) =>
      !owns(id) && coins >= accessoryOf(id).price;

  /// [id] menjadi milik pemain, belum dipakai siapa pun (desain: sesudah
  /// "Milikmu selamanya" ada tombol Pakai). Koin dipotong pemanggil.
  AccessoryCloset buy(AccessoryId id) =>
      owns(id) ? this : AccessoryCloset._({...owned, id}, wearing);

  /// Aksesoris yang dipakai [kitty]; null = tanpa aksesoris.
  AccessoryId? wearingOf(KittyId kitty) => wearing[kitty];

  /// [kitty] memakai [id], atau melepasnya kalau [id] null. Tidak berubah
  /// kalau [id] belum dimiliki.
  AccessoryCloset wear(KittyId kitty, AccessoryId? id) {
    if (id != null && !owns(id)) return this;
    if (wearing[kitty] == id) return this;
    return AccessoryCloset._(owned, {
      for (final MapEntry(:key, :value) in wearing.entries)
        if (key != kitty) key: value,
      kitty: ?id,
    });
  }

  Map<String, Object?> toJson() => {
    'owned': [
      for (final a in accessories)
        if (owns(a.id)) a.id.name,
    ],
    'wearing': {
      for (final MapEntry(:key, :value) in wearing.entries)
        key.name: value.name,
    },
  };

  /// Nama yang tidak dikenal dan aksesoris dipakai yang tidak dimiliki
  /// dibuang.
  factory AccessoryCloset.fromJson(Map<String, dynamic> json) {
    final ids = AccessoryId.values.asNameMap();
    final cats = KittyId.values.asNameMap();
    final owned = json['owned'];
    final wearing = json['wearing'];
    return AccessoryCloset(
      owned: [
        if (owned is List)
          for (final name in owned) ?ids[name],
      ],
      wearing: {
        if (wearing is Map<String, dynamic>)
          for (final MapEntry(:key, :value) in wearing.entries)
            if ((cats[key], ids[value]) case (
              final KittyId kitty,
              final AccessoryId id,
            ))
              kitty: id,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AccessoryCloset &&
      other.owned.length == owned.length &&
      other.owned.containsAll(owned) &&
      other.wearing.length == wearing.length &&
      wearing.entries.every((e) => other.wearing[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(owned),
    Object.hashAllUnordered([
      for (final e in wearing.entries) Object.hash(e.key, e.value),
    ]),
  );

  @override
  String toString() => 'AccessoryCloset(${toJson()})';
}
