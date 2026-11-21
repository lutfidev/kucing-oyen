# Langkah 14b — Rapikan Toko, layar hasil, dan puzzle

Disetujui pemilik repo 21 November 2026. Sumber: tinjauan screenshot
`docs/screenshots/` terhadap konsep A (roadmap 14b).

## Tujuan
- Toko: judul tepat di tengah layar; semua harga (barang, adopsi kucing,
  aksesoris, camilan) memakai ikon koin emas `CoinView`; pratinjau aksesoris
  ringkas (gambar ±130 px di kiri, info kanan), kelangkaan sebagai `UiChip`,
  "Coba di:" satu baris chip yang bisa digeser (`UiEdgeFade`).
- Hasil: sinar memenuhi layar tanpa tepi lurus (memudar ke tepi); mangkuk di
  samping Oyen, tidak menimpa kaki.
- Puzzle: benda pemain tanpa kotak kertas/bingkai oranye ("stiker"); penanda
  benda pemain = bayangan elips oranye lembut di lantai. Baki tanpa bingkai
  ganda. Panah arah di dekat kaki sisi hadap, tidak menutupi wajah. Tembok
  lebih gelap/hangat supaya kontras dengan lantai.

## Bukan tujuan
Aturan simulasi, hitbox, ukuran petak, skema simpanan, teks ARB baru (kecuali
perlu), header/panel rumah (14c), pose kamar (14d).

## Pendekatan
Perbaiki di renderer v2 (`puzzle_art.dart`, `board_painter.dart`,
`journey_art.dart`/`result_art.dart`) dan `shop_screen.dart`, bukan renderer v1.
Alternatif (komponen Toko baru, aset raster) ditolak: lebih besar dari
kebutuhan langkah ini.

## Verifikasi
Test widget/piksel baru untuk tiap butir, overflow 4 bahasa tetap lulus,
screenshot dokumentasi + materi toko dibuat ulang dan diperiksa.
