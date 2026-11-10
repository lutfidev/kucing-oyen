# Tinjauan peta, hasil, dan replay v2 — langkah 11

10 November 2026. Basis `f6fcb50`, sesudah PR #49 di-merge.
Rencana: [langkah 11](../../superpowers/plans/2026-11-10-v2-journey.md).

## Implementasi

`journey_art.dart` menggambar dua peta, dekor dapur/ruang tamu, pita jalur,
jejak kaki, pictogram 20 node, area bos, pintu babak baru, konfeti serta
ilustrasi hasil. Seni Canvas orisinal memakai palet v2; tidak ada unduhan,
dependency, atau bitmap runtime baru. Geometri node dan kurva perjalanan
tetap memakai `PictureMapArt`, termasuk varian layar pendek. Node terkunci,
terbuka, bintang, bos, pembatalan dengan ketukan/Kembali dan pembukaan level
berikutnya mempertahankan kontrak lama.

Token peta dan kartu babak memakai CatRig Oyen rumah. Aksesoris yang sedang
dipakai tetap muncul, termasuk arah samping/belakang. Generator menyertakan
20 bagian aksesoris beserta pivot/jangkar dari manifest, di samping 15 bagian
Oyen. Inventaris navigasi tetap 35 bagian dengan 22.580 byte sumber SVG;
bukan cache kombinasi pose, frame atau waktu. Pack puzzle 15 bagian tetap
terpisah dan terbatas. Angka ini bukan pengukuran RSS atau delta APK.

Hasil menang dua/tiga bintang, vas pecah satu bintang dan gagal loop/batas
memakai token v2. Ilustrasi menang dan vas digambar ulang; vas pecah sekarang
juga menyediakan tautan replay. Label semantik ilustrasi diperbarui dalam
empat bahasa agar sesuai gambar. Statistik menaruh angka dan label pada
baris terpisah. Tombol ikon pada tema puzzle/peta/hasil/replay dan tautan
replay memiliki target minimum 48 dp; matriks memeriksa ukuran kontrol Akhir.
Layar portrait
pendek/teks besar dapat digulir, menjaga ilustrasi tetap tampil dan kontrol
tetap dapat dicapai; screenshot awal bukan seluruh isi gulir.

Replay memakai warna jejak dan nomor v2, dengan cache paragraf maksimal
256 entri. Tombol Awal/Akhir melengkapi slider serta mundur/maju satu langkah;
jumlah langkah tampil eksplisit. Putar/jeda dan toggle ×1/×2 memakai rekaman
`SimResult.trace`, tanpa simulasi atau pemberian hadiah ulang. Aplikasi masuk
latar menghentikan pemutaran. Kurangi gerak menyembunyikan putar otomatis
dan kecepatan, tetapi slider serta navigasi manual tetap tersedia.

Tidak mengubah simulator, solver, solusi, penilaian bintang, ekonomi atau
skema penyimpanan. Ilustrasi vas statis; animasi bintang, transisi babak dan
perjalanan peta tetap mengikuti pilihan kurangi gerak. Renderer v1 murni dan
helper galeri historis dipertahankan; bukan sumber gambar runtime baru.

## Bukti visual

47 PNG widget nyata, memakai font aplikasi:

- `map1-*`, `map2-*`, `locked-*`, `intro-*`: kedua babak, kunci, node/bos,
  bintang, aksesoris Oyen dan kartu babak baru.
- `success-*`, `two-stars-*`, `vase-*`, `loop-*`, `limit-*`: seluruh hasil.
- `replay-*`: awal, langkah 80, kecepatan, serta kontrol bawah.
- `*-actions-ru-130-360.png`: posisi setelah gulir ke kontrol hasil/replay.
- `art-catalog.png`: 20 pictogram dan arah rig beraksesoris.

Ekspor: `flutter test test/screens/journey_v2_test.dart
--dart-define=JOURNEY_REVIEW=true`.
Matriks otomatis mencakup 360×640, 390×844, 412×915; en/id/pt/ru;
teks 100%/130%, masing-masing melalui sepuluh keadaan layar.
Ekspor gambar mencakup Indonesia 100/130% dan Rusia 130% di 360×640,
serta Indonesia 100% pada 390×844. Seluruh gambar ditinjau melalui lembar
kontak; katalog, hasil, replay dan teks Rusia juga diperiksa ukuran penuh.

Temuan yang diperbaiki: statistik terlalu mengecil; nama kartu babak panjang
mengecil; ilustrasi hasil hilang pada layar pendek; ruang hasil kurang tiga
pixel pada viewport regresi; deskripsi vas masih menyebut ilustrasi lama.
Test piksel diperbarui untuk warna jejak v2. Test pose peta kini memeriksa
API `MapToken`, bukan child `KittyView` v1. Tidak menambah skip atau menghapus
test perilaku untuk meluluskan perubahan.

## Verifikasi

- 26 test baru: 24 kombinasi layar/bahasa/skala, kecepatan/awal/akhir/jeda
  lifecycle tanpa mengubah rekaman hasil, serta kesamaan sumber/metadata
  dan seluruh aksesoris pada empat arah.
- 3.045 test lulus /135 skip historis pada suite penuh; solver dan solusi
  20 level, progres/hadiah peningkatan bintang, hasil berulang, navigasi
  antarlevel/babak, ketukan saat transisi dan Kembali ikut diuji.
- 126 test terarah peta/intro/hasil/replay/renderer lulus. Sesudah perbaikan
  ruang portrait, 83 test layout, hasil, replay dan progres lulus kembali.
- `flutter analyze`: `No issues found!`; format 288 file tanpa perubahan;
  cek terjemahan, generator aset/subset dan `git diff --check` bersih.
- APK debug dari entrypoint biasa berhasil: 219.975.258 byte,
  `build/app/outputs/flutter-apk/app-debug.apk`, SHA-256
  `EDA21EA125BD88E853910395D63ABDB56D0464353F3F6D2899D294DF93F247D2`.
  `kernel_blob.bin` terkemas memuat `journey_art.dart` dan `replayProgress`.

## Batas

Review kode/visual dilakukan dalam sesi utama, tanpa reviewer independen.
Belum menguji APK pada HP, TalkBack nyata, profil frame/RSS, suara atau
penerimaan visual pemilik repo. Render host dan build debug tidak membuktikan
60 fps pada perangkat. Gerak lengkap/performa dan verifikasi perangkat tetap
pekerjaan langkah 13–15. Tutorial/sheet petunjuk/koin/Pengaturan mengikuti
langkah 12; perubahan ini tidak menyatakan seluruh rute sudah bermigrasi.
