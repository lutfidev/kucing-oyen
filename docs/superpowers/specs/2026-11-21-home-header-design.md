# Langkah 14c — Header dan panel rumah ringkas seperti konsep A

Sumber: roadmap 14c, `docs/design-brief/rumah-oyen-area/preview-perbandingan.png`
konsep A, screenshot `docs/screenshots/01-04`. Keputusan di bawah diambil sesi
utama mengikuti konsep A (CLAUDE.md: kerjakan sendiri); pemilik repo meninjau
lewat PR.

## Tujuan
- Kamar mendapat ruang layar lebih besar: baris judul area dan panel area yang
  tinggi dihapus dari layar utama.
- Tab area: satu baris chip ringkas (ikon di kiri label, tanpa hitungan
  terlihat). Hitungan `n/kapasitas` tetap di label pembaca layar.
- Bantuan (?) dan Hias menjadi tombol ikon bulat 48 dp di pojok kanan atas
  kamar (tooltip + label semantik), bukan baris sendiri.
- Panel kucing satu baris: avatar, nama (status satu baris kecil), dua aksi
  berikon. Teks besar tetap jatuh ke susunan kolom seperti sekarang.
- Di bawah panel: satu baris chip (`Wrap`): chip status area (Makan/Main/Rawat,
  teks pendek, membuka sheet area; kunci `dining-choose`/`play-choose`/
  `care-choose`) dan chip hadiah (`home-rewards`).
- Penjelasan aturan, stok/siklus mangkuk, ketersediaan per kucing, dan antrean
  beserta tombol batal (`<area>-cancel-<kucing>`) pindah ke sheet area.

## Bukan tujuan
Aturan, kuota, skema simpanan, pose/skala kamar (14d), latar area (14e),
navigasi bawah, logika rutinitas.

## Pendekatan
Dipilih: ubah `HomeView` (tata letak), `HomeAreaStrip` (chip satu baris),
sheet area di `HomeSheets` (ringkasan + batal), panel area jadi chip status.
Alternatif ditolak: (a) panel kucing menumpang di atas kamar seperti mockup —
menutupi kaki kucing dan mangkuk yang diposisikan pada 0,88 tinggi kamar;
(b) mempertahankan panel area tapi dilipat — tetap memakan baris dan butuh
interaksi tambahan. Tinggi kamar = sisa layar dikurangi perkiraan chrome,
dijepit 240…min(480, lebar layar×1,16) (batas lama; latar persegi `BoxFit.fill`
bisa teregang vertikal ±1,26× di 390 dp).

## Teks baru (empat ARB)
`homeStatusBowl`, `homeStatusBowlEmpty`, `homeStatusToy`, `homeStatusCare`,
`homeStatusQueue`, `homeRewardLater`.

## Verifikasi
Test tata letak 14c (tinggi kamar naik, tab satu baris, chip/aksi, Hias/bantuan
terjangkau), test area yang dipindah ke sheet, overflow empat bahasa
360×640–412×915 teks 100/130%, screenshot dokumentasi dan materi toko dibuat ulang.
