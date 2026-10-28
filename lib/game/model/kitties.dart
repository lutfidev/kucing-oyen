/// Kucing kamar: Oyen lalu kucing koleksi, urut kartu tab Kucing
/// (`Toko.dc.html`). Nama dan keterangannya ditambahkan bersama layar Toko.
enum KittyId {
  oyen,
  salju,
  telon,
  arang,
  mendung,
  kopiSusu,
  mochi,
  bos,
  kembang,
}

/// Kucing dan harganya di Toko. Oyen gratis dan selalu dimiliki.
class Kitty {
  const Kitty(this.id, this.price);

  final KittyId id;
  final int price;
}

/// Harga dari `Toko.dc.html`.
const kitties = [
  Kitty(KittyId.oyen, 0),
  Kitty(KittyId.salju, 300),
  Kitty(KittyId.telon, 550),
  Kitty(KittyId.arang, 400),
  Kitty(KittyId.mendung, 350),
  Kitty(KittyId.kopiSusu, 300),
  Kitty(KittyId.mochi, 450),
  Kitty(KittyId.bos, 600),
  Kitty(KittyId.kembang, 700),
];

Kitty kittyOf(KittyId id) => kitties[id.index];
