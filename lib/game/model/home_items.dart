/// Area tempat barang ditaruh di kamar.
enum RoomZone { floor, wall }

/// Cara kucing memakai barang (pose `dipakai` di `Barang.dc.html`).
enum ItemUse { sleep, play, scratch, watch, sit, hide, lounge, eat }

/// Barang kamar, urut kartu tab Barang (`Toko.dc.html`), lalu mangkuk
/// bawaan. Namanya per bahasa ditambahkan bersama layar Toko.
enum RoomItemId {
  tikus,
  akuarium,
  rumah,
  kasur,
  catnip,
  jam,
  kardus,
  bola,
  karpet,
  tiang,
  lukisan,
  rak,
  pancingan,
  lampuBulan,
  bantalIkan,
  monstera,
  terowongan,
  hammock,
  sofaMini,
  jendelaBurung,
  mangkuk,
}

// Batas pojok kiri-atas barang yang diseret di kamar (`Kamar.dc.html`,
// koordinat desain lebar 390). Barang lantai dibatasi tepi bawahnya.
const wallLeft = 14.0;
const wallRight = 376.0;
const wallTop = 112.0;
const wallBottom = 402.0;
const floorLeft = 8.0;
const floorRight = 382.0;
const floorTop = 436.0;
const floorBottom = 646.0;

/// Barang di katalog: harga Toko, area, cara dipakai, ukuran di kamar,
/// dan posisi bawaan (pojok kiri-atas, koordinat desain).
class RoomItem {
  const RoomItem(
    this.id,
    this.price,
    this.zone,
    this.use,
    this._width,
    this._height,
    this.defaultX,
    this.defaultY, {
    this.scale = 1,
    this.toy = false,
  });

  final RoomItemId id;
  final int price;
  final RoomZone zone;
  final ItemUse use;

  /// Memakainya menaikkan Senang (mainan, lihat `CatNeeds.played`).
  final bool toy;

  /// Ukuran gambar `Barang.dc.html` dan skalanya di kamar.
  final double _width;
  final double _height;
  final double scale;

  final double defaultX;
  final double defaultY;

  double get width => _width * scale;
  double get height => _height * scale;

  /// Barang bawaan (mangkuk): selalu ada, tidak dijual, tidak ke Gudang.
  bool get builtIn => id == RoomItemId.mangkuk;

  /// Tempat barang yang baru dibeli.
  Spot get defaultSpot => spotAt(this, defaultX, defaultY);
}

/// Harga dari `Toko.dc.html`, area dari `BarangKamar.dc.html`, ukuran dari
/// `Barang.dc.html`. Skala dan posisi bawaan dari `Kamar.dc.html`; barang
/// yang tidak ada di sana memakai skala 1 dan posisi pilihan (lihat
/// `docs/DESIGN_NOTES.md`, langkah 21).
const roomItems = [
  RoomItem(
    RoomItemId.tikus,
    120,
    RoomZone.floor,
    ItemUse.play,
    46,
    28,
    330,
    560,
    toy: true,
  ),
  RoomItem(
    RoomItemId.akuarium,
    600,
    RoomZone.floor,
    ItemUse.watch,
    92,
    90,
    180,
    446,
    toy: true,
  ),
  RoomItem(
    RoomItemId.rumah,
    900,
    RoomZone.floor,
    ItemUse.hide,
    122,
    132,
    70,
    340,
  ),
  RoomItem(
    RoomItemId.kasur,
    200,
    RoomZone.floor,
    ItemUse.sleep,
    150,
    76,
    246,
    448,
    scale: 0.85,
  ),
  RoomItem(
    RoomItemId.catnip,
    180,
    RoomZone.floor,
    ItemUse.play,
    52,
    74,
    44,
    520,
    scale: 0.9,
    toy: true,
  ),
  RoomItem(
    RoomItemId.jam,
    240,
    RoomZone.wall,
    ItemUse.play,
    52,
    86,
    164,
    126,
    scale: 0.9,
  ),
  RoomItem(
    RoomItemId.kardus,
    50,
    RoomZone.floor,
    ItemUse.hide,
    122,
    82,
    166,
    566,
  ),
  RoomItem(
    RoomItemId.bola,
    80,
    RoomZone.floor,
    ItemUse.play,
    36,
    36,
    100,
    592,
    toy: true,
  ),
  RoomItem(
    RoomItemId.karpet,
    150,
    RoomZone.floor,
    ItemUse.sleep,
    184,
    60,
    80,
    500,
    scale: 1.25,
  ),
  RoomItem(
    RoomItemId.tiang,
    220,
    RoomZone.floor,
    ItemUse.scratch,
    50,
    152,
    20,
    330,
    scale: 0.95,
    toy: true,
  ),
  RoomItem(
    RoomItemId.lukisan,
    140,
    RoomZone.wall,
    ItemUse.watch,
    72,
    66,
    206,
    150,
    scale: 1.15,
  ),
  RoomItem(
    RoomItemId.rak,
    160,
    RoomZone.wall,
    ItemUse.sit,
    104,
    34,
    250,
    336,
    scale: 1.1,
  ),
  RoomItem(
    RoomItemId.pancingan,
    60,
    RoomZone.floor,
    ItemUse.play,
    80,
    70,
    12,
    566,
    toy: true,
  ),
  RoomItem(
    RoomItemId.lampuBulan,
    120,
    RoomZone.wall,
    ItemUse.sleep,
    60,
    60,
    306,
    156,
  ),
  RoomItem(
    RoomItemId.bantalIkan,
    160,
    RoomZone.floor,
    ItemUse.sleep,
    130,
    56,
    240,
    560,
  ),
  RoomItem(
    RoomItemId.monstera,
    200,
    RoomZone.floor,
    ItemUse.hide,
    70,
    110,
    312,
    330,
  ),
  RoomItem(
    RoomItemId.terowongan,
    260,
    RoomZone.floor,
    ItemUse.hide,
    152,
    64,
    200,
    520,
    toy: true,
  ),
  RoomItem(
    RoomItemId.hammock,
    380,
    RoomZone.wall,
    ItemUse.sleep,
    120,
    70,
    230,
    240,
  ),
  RoomItem(
    RoomItemId.sofaMini,
    450,
    RoomZone.floor,
    ItemUse.lounge,
    140,
    86,
    110,
    470,
  ),
  RoomItem(
    RoomItemId.jendelaBurung,
    700,
    RoomZone.wall,
    ItemUse.watch,
    100,
    96,
    30,
    160,
    toy: true,
  ),
  RoomItem(
    RoomItemId.mangkuk,
    0,
    RoomZone.floor,
    ItemUse.eat,
    54,
    30,
    298,
    596,
    scale: 1.15,
  ),
];

/// Barang yang dijual di Toko (tanpa mangkuk bawaan).
final shopItems = [
  for (final item in roomItems)
    if (!item.builtIn) item,
];

RoomItem roomItemOf(RoomItemId id) => roomItems[id.index];

/// Letak barang sebagai pecahan 0–1 dari rentang pojok kiri-atas yang muat
/// di areanya ([spotAt]). Nilai di luar 0–1 dijepit, jadi setiap [Spot]
/// sah untuk ukuran barang apa pun. Di lantai, [y] = tepi bawah barang,
/// sekaligus urutan gambarnya.
class Spot {
  Spot(double x, double y) : x = _unit(x), y = _unit(y);

  final double x;
  final double y;

  static double _unit(double v) => v.isNaN ? 0 : v.clamp(0.0, 1.0);

  List<double> toJson() => [x, y];

  /// `[x, y]` dengan dua angka berhingga; selain itu null.
  static Spot? fromJson(Object? json) {
    if (json case [final num x, final num y] when x.isFinite && y.isFinite) {
      return Spot(x.toDouble(), y.toDouble());
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is Spot && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Spot($x, $y)';
}

/// Rentang pojok kiri-atas [item] di areanya: (kiri, kanan, atas, bawah).
(double, double, double, double) _range(RoomItem item) => switch (item.zone) {
  RoomZone.wall => (
    wallLeft,
    wallRight - item.width,
    wallTop,
    wallBottom - item.height,
  ),
  RoomZone.floor => (
    floorLeft,
    floorRight - item.width,
    floorTop - item.height,
    floorBottom - item.height,
  ),
};

/// [Spot] untuk [item] dengan pojok kiri-atas di ([left], [top]).
Spot spotAt(RoomItem item, double left, double top) {
  final (x0, x1, y0, y1) = _range(item);
  return Spot((left - x0) / (x1 - x0), (top - y0) / (y1 - y0));
}

/// Pojok kiri-atas [item] di [spot], koordinat desain.
(double, double) positionOf(RoomItem item, Spot spot) {
  final (x0, x1, y0, y1) = _range(item);
  return (x0 + spot.x * (x1 - x0), y0 + spot.y * (y1 - y0));
}
