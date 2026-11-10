# Tinjauan Area Perawatan v2 — langkah 8

10 November 2026, basis `main` setelah PR #46.

## Perilaku

- Tab Rawat memakai latar ilustrasi, alas gratis, target sikat 48 dp,
  satu posisi rawat dan satu menunggu. Target sikat membuka sheet koleksi.
- Elus 2 detik, sikat 6 detik. Efek +10 Senang baru diterapkan saat selesai,
  dengan batas gabungan +30/jam per kucing dari model v1. Tidak ada mandi,
  kebersihan, penalti offline atau perubahan ekonomi.
- `CareState` memproyeksikan siap/penuh/batas beserta menit tersisa dengan
  waktu efektif controller. UI panel, sheet dan kartu lengkap memakai data ini.
  Tombol kegiatan yang sama dengan kegiatan/ajakan aktif dinonaktifkan;
  tindakan lain dapat menjadi ajakan sesudah kegiatan aktif.
- Sikat otomatis tetap pilihan sesekali scheduler, maksimal sekali/30 menit,
  dan tetap memakai jatah gabungan. Elus hanya atas ajakan pemain.
- Antrean dan pembatalan memakai scheduler bersama. Batalkan sebelum mulai
  tidak memberi efek; kegiatan aktif diselesaikan sekali dengan label
  “Batal setelah ini”. Pindah tab tidak membatalkan perawatan.
- Snapshot/lifecycle tetap memakai transaksi rumah yang sama. Reload
  mempertahankan ID dan sisa durasi; penyimpanan gagal menahan perubahan
  sampai retry. Puzzle, latar belakang, iklan dan Hias menjeda kegiatan.

## Visual dan aksesibilitas

Latar adalah gambar statis tanpa kucing/perlengkapan interaktif; kucing,
alas dan sikat tetap dirender live. Sumber dan prompt ada di
[PAINTED_ASSET.md](PAINTED_ASSET.md). Fallback vektor tetap tersedia.

- [Dua kucing dan antrean](rawat-antrean-id.png), 390×844.
- [Sheet elus/sikat dan batal](rawat-sheet-id.png).
- [Kosong](rawat-kosong-id.png), [Senang penuh](rawat-penuh-id.png),
  [jatah gabungan habis](rawat-batas-id.png).
- Render layar kecil 360×640, teks 100%/130%, untuk sistem/en/id/pt/ru:
  misalnya [Indonesia 130%](rawat-id-360-130.png),
  [Rusia 130%](rawat-ru-360-130.png).

Panel/daftar bergulir; navigasi dan Main Puzzle tetap tersedia pada layar
kecil. Tab area bergulir horizontal agar label panjang tidak dikecilkan.
Status fasilitas memakai live region; sikat dan kedua tindakan memiliki
label semantik. Kurangi gerak mempertahankan frame statis dan meniadakan
transisi posisi, tanpa mematikan durasi/efek kegiatan model.

## Temuan dan perbaikan

1. Target sikat bersinggungan dengan target kucing aktif. Posisi rawat
   disamakan dengan slot aman Bermain; regresi memeriksa kedua target
   dan ukuran sikat minimal 48 dp.
2. Penulisan awal lewat shell merusak karakter Cyrillic dan aksen Portugis.
   ARB diperbaiki melalui patch Unicode, generator dan screenshot diulang.
3. Test semantik awal melepas handle terlalu lambat di teardown. Handle
   sekarang dilepas di dalam test setelah pengecekan label.

Tinjauan kode sesi utama memeriksa kuota, jam efektif, larangan duplikasi,
status aktif/antrean, retry, dan batas snapshot. Skill superpowers yang
disebut panduan repo tidak tersedia di sesi ini; tidak ada review subagent.

## Verifikasi

- Baseline: `flutter pub get`, analyze bersih, 2.948 test lulus / 135 skip.
- Terarah: 86 test lulus untuk alur perawatan dan layar rumah/Makan/Bermain.
- Final: analyze bersih (`No issues found!`); format 276 file tanpa perubahan;
  seluruh suite 2.968 test lulus / 135 skip historis, termasuk solusi 20 level;
  berkas review terjemahan sesuai.
- APK debug berhasil (`assembleDebug` 31,9 detik), 219.975.258 byte;
  SHA-256 `63217a41ef3800fa6b9048479d4156b169f316383665238aba048fa4269291ee`.
  Lokasi lokal `build/app/outputs/flutter-apk/app-debug.apk`.
  Pengukur APK memvalidasi 215 entry art v2, termasuk latar Rawat 127.354 byte;
  total art 848.407 byte / 635.334 byte terkompresi. Ini bukan delta APK
  terhadap v1 atau estimasi release.
- Generator vektor: 209 aset sesuai; aset raster ditambahkan terpisah.
- Ekspor: `flutter test test/screens/care_v2_test.dart --dart-define=CARE_REVIEW=true`.

Batas: screenshot dan test semantik Flutter bukan uji TalkBack di HP.
Belum dilakukan penerimaan visual pemilik repo, pengukuran performa HP,
atau uji sentuhan/gerak langsung di Android. Pengujian perangkat menyeluruh
mengikuti langkah 13/15. Review tidak mengklaim kandidat rilis.
