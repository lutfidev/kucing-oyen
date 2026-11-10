# Tinjauan visual puzzle v2 — langkah 10

10 November 2026, basis `e3fc67f`, sesudah PR #48 merged.
Rencana: [langkah 10](../../superpowers/plans/2026-11-10-v2-puzzle.md).

## Implementasi

Papan runtime Flame dan CustomPainter memakai `v2/puzzle_art.dart`:
lantai papan kayu dengan grid, wallpaper/batas, lemari, rak, kulkas,
meja, gelas, vas/pecahan, mangkuk, ikan, genangan, ember dan kardus.
Seni Canvas orisinal mengikuti palet v2 tanpa unduhan atau dependency baru.
Benda pemain memiliki bidang paper dan bingkai oranye; benda bawaan
tanpa bingkai. Air bawaan berupa genangan, air pemain berupa ember.
Tujuan sah memakai bingkai bulat dan tanda sudut, ditambah denyut lama;
petunjuk tetap samar 70% di atas sorotan dan di bawah benda terpasang.
Baki dan benda di tangan memakai gambar yang sama dengan papan.

Oyen menggunakan `CatRig` dan 15 bagian SVG yang identik dengan rumah.
`embed_puzzle.py` menghasilkan subset Dart sinkron agar Flame dapat
menggambar tanpa IO atau placeholder saat paint. Kesamaan sumber diuji,
dan `--check` memeriksa hasil generator. Sumber SVG subset 18.178 byte
termasuk wrapper; data terurai hanya satu pack terbatas sepanjang proses,
tanpa cache kombinasi pose/waktu. Ini bukan pengukuran RSS atau delta APK.

Delapan pose puzzle dipetakan ke rig idle/jalan/tidur/kaget/kardus/
menjatuhkan/makan/senang dengan empat arah dan mirror. Prop rumah dimatikan
agar tidak menggambar mangkuk atau ikan kedua di atas papan; kardus dan
gelembung pikiran/ZZ/kaget ditangani oleh renderer puzzle. Pergeseran antar
petak tetap mengikuti RunFrame dan jam simulasi, termasuk kurangi gerak.

`puzzle_theme.dart` memasang token v2 pada kontrol yang sudah memiliki
seretan, fokus dan semantik. Slot terpilih sekarang mendapat bingkai
tambahan. Judul membungkus pada bahasa panjang; tombol Aturan berupa ikon
pada lebar di bawah 390 dp dengan label semantik lengkap. Test overflow
mengakses tombol melalui label tersebut, termasuk saat ikon saja.

Grid/hitbox tetap 50 unit, 7×9, skala seragam. Tidak mengubah simulator,
solver, inventory, solusi, bintang, ekonomi atau penyimpanan. Renderer
v1 murni tetap untuk galeri/ilustrasi historis; test piksel papan runtime
telah diperbarui mengikuti warna dan penanda v2. Peta/ilustrasi hasil,
kontrol replay dan tutorial/sheet mengikuti langkah 11–12.

## Bukti visual

- `atur-{id,en,pt,ru}-{100,130}-360.png` dan `jalan-…`: 16 render
  widget nyata pada 360×640, termasuk teks 130%.
- `atur-id-100-390.png`, `jalan-id-100-390.png`: acuan 390×844.
- `art-catalog.png`: seluruh jenis petak/benda, petunjuk, delapan pose
  dan empat arah; kombinasi tidak sah juga dirender untuk audit geometri.

Ekspor: `flutter test test/screens/puzzle_v2_test.dart
--dart-define=PUZZLE_REVIEW=true`. Font aplikasi dimuat oleh harness.
Judul Rusia yang mengecil pada render awal diperbaiki menjadi membungkus;
kontrol tetap terjangkau. Grid di 360×640 teks besar memang lebih kecil
daripada 390×844; jalur pilih-benda-lalu-ketuk/semantik tetap tersedia.

## Verifikasi

- **3.019 test lulus /135 skip historis**, tanpa kegagalan. Termasuk
  solver minimum benda, seluruh solusi 20 level menang/vas aman/langkah
  sesuai JSON, seretan, pilih-ketuk, hint, reduced motion dan replay.
- **27 test baru**: kesamaan subset, inventaris vector, piksel runtime,
  dan 24 kombinasi ukuran (360?640/390?844/412?915), empat bahasa,
  teks 100/130%; masing-masing melalui fase atur dan jalan.
- **40 test terarah lulus** pada ekspor puzzle baru dan renderer papan;
  regresi interaksi level juga lulus dalam suite penuh.
- `flutter analyze`: `No issues found!`; format 286 file tanpa perubahan,
  `git diff --check`, cek terjemahan dan kedua generator aset sesuai.
- 19 render ditinjau melalui contact sheet dan gambar penuh untuk
  katalog, acuan 390?844 dan Rusia 130%.
- APK debug dari entrypoint biasa berhasil: 219.975.258 byte,
  `build/app/outputs/flutter-apk/app-debug.apk`, SHA-256
  `C5219EFA92B7C7994D7BD49F2FE6DC7F69FC5A4EB82F11E76733A0C4AC772136`.
  `kernel_blob.bin` terkemas memuat renderer dan subset Oyen v2.

Temuan yang diperbaiki: judul Rusia terlalu kecil pada render awal;
judul sekarang membungkus dan Aturan menjadi ikon pada layar sempit.
Test overflow lama diperbarui untuk menemukan tombol melalui label
semantik, sehingga tetap benar-benar membuka serta menguji sheet aturan.
Tidak ada test perilaku yang dihapus atau ditambahkan skip.

## Batas

Pemeriksaan kode/visual dilakukan dalam sesi utama; tidak ada reviewer
independen pada sesi ini. Belum menguji APK pada HP, TalkBack nyata,
profil frame/RSS, suara atau penerimaan visual pemilik repo. APK debug
dan render host tidak membuktikan kelancaran 60 fps di HP. Langkah 13–15
tetap mencakup animasi lengkap, performa, aksesibilitas dan uji perangkat.
