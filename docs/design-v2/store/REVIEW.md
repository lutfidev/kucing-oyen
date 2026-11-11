# Tinjauan langkah 14 — merek dan materi toko v2

Implementasi 10 November 2026, branch `feat/design-v2-store-assets`, basis
`0f6b020` (PR #52 merged). Materi tersedia untuk tinjauan visual pemilik repo.
Tidak ada unggahan ke Play Console atau publikasi.

## Hasil

- [Ikon toko 512×512](../../store/icon-512.png), memakai kepala Oyen dari SVG
  rig rumah v2 yang sama dengan puzzle. Crop menjaga outline/telinga utuh.
- Launcher legacy, adaptif dan monokrom pada lima densitas; splash kepala
  v2 dan branding Inggris/Indonesia/Portugis/Rusia. Android Indonesia tetap
  memakai qualifier `in`. Latar berasal dari KoUi v2.
- [Pratinjau bentuk ikon dan splash empat bahasa](launcher-splash-preview.png).
  Ini komposisi host untuk memeriksa gambar, bukan tangkapan splash OS.
- Grafis fitur 1024×500: [Inggris](../../store/feature-graphic.png),
  [Indonesia](../../store/feature-graphic-id.png),
  [Portugis](../../store/feature-graphic-pt.png),
  [Rusia](../../store/feature-graphic-ru.png), menggunakan CatRig dan logo.
- Delapan potret toko per bahasa (32 total), 1080×1920:
  [en](../../store/screenshots/en/01-santai.png),
  [id](../../store/screenshots/id/01-santai.png),
  [pt](../../store/screenshots/pt/01-santai.png),
  [ru](../../store/screenshots/ru/01-santai.png).
  Urutan: Santai, Makan, Main, Rawat, pratinjau aksesoris, peta babak 2,
  atur level 13, dan hasil tiga bintang. Semua file berada di folder yang sama
  dengan contoh bahasa masing-masing, bernomor 01–08.
- 29 potret dokumentasi: delapan potret yang sama plus
  [fase jalan](../../screenshots/09-fase-jalan-level-13.png) dalam Indonesia,
  serta peta babak 1, Toko barang, koleksi, makanan dan Pengaturan dalam
  empat bahasa di `docs/screenshots/<bahasa>/`. Galeri README menampilkan
  delapan layar utama.
- Listing empat bahasa kini menjelaskan empat area, ajakan makan/main/sikat
  dan klaim hadiah bersama. Tidak menjanjikan mandi atau kebutuhan baru.
  Review terjemahan dibuat ulang. [Teks alternatif](../../store/alt-text.md)
  disediakan untuk aset toko; tinjauan penutur asli belum diklaim.

## Generator dan sumber

```sh
flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true
flutter test test/screenshots/screenshot_test.dart --dart-define=SCREENSHOTS=true --dart-define=SCREENSHOT_DIR=docs/screenshots
python tool/store_assets.py
python tool/store_assets.py --check
```

Dua suite dapat dijalankan bersama dengan kedua define diaktifkan. Fixture
merek memakai SnapshotStore terisolasi, jam tetap 10 Nov 2026 pukul 12,
sembilan kucing tersebar melalui migrasi runtime normal (3/2/2/2), kebutuhan
55, saldo 480 dan progres contoh sampai level 12. Gerak rumah dibekukan;
render puzzle jalan dipause melalui kontrol pemain, hasil dicapai dengan
menaruh solusi lewat input sebenarnya. Tidak mengakses data pemain.

Ukuran logis toko 432×768 dp, DPR ekspor 2,5; dokumentasi utama DPR 2.
Rute tambahan memakai 390×844 dp, DPR 2. Generator screenshot lama yang
memotret galeri/desain v1 diganti dengan rute pemain v2. Pengujian perilaku,
solver, layout dan semantik yang terpisah tetap dijalankan; penurunan jumlah
skip suite biasa berasal dari penggantian exporter opt-in tersebut.

Sumber kepala di `brand_art.dart` memakai `puzzleCatSources`, subset sinkron
aset rig rumah; grafis fitur memakai `CatRig`. Tidak ada seni AI baru pada
langkah ini. Sumber/lisensi latar dan karakter mengikuti
[README aset v2](../../../assets/art/v2/README.md).

`tool/store_assets.py` mengubah representasi PNG screenshot/grafis fitur dari
RGBA opaque menjadi RGB 24 bit secara lossless; piksel tampilan tidak disentuh.
Ikon toko tetap RGBA. Pemeriksa menolak screenshot kurang/berlebih, empat
potret area yang identik, alpha tidak opaque, ukuran salah, piksel di luar
lingkaran aman Android, listing melewati batas dan manifest basi.
[Manifest](../../store/assets-v2.json) mencatat 106 PNG, ukuran/mode/hash dan
panjang listing. Total PNG 26.994.130 byte. Materi dokumentasi/toko tidak
dibundel sebagai aset aplikasi; resource Android mengganti gambar lama dan
tetap menjadi bagian APK.

Ketentuan format diperiksa pada 10 November 2026 terhadap
[panduan resmi Google Play](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en):
ikon 512×512, grafis fitur 1024×500, screenshot/grafis fitur RGB tanpa alpha,
maksimal delapan screenshot per jenis perangkat. Pemeriksaan formulir,
target audiens dan SDK produksi tetap langkah 16.

## Tinjauan dan perbaikan

Sesi utama meninjau seluruh 32 screenshot toko, 20 potret rute tambahan,
sembilan potret dokumentasi utama, empat grafis fitur dan pratinjau merek.
Lembar kontak QA dapat dibuat ulang dengan `--sheets` ke `build/store-review/`.
Review independen oleh subagent tidak dilakukan pada sesi ini.

Dua temuan generator ditutup: fixture MemoryProgressStore lama menolak
perubahan area, menghasilkan empat potret Santai; fixture sekarang atomik dan
mengassert hasil setHomeArea/lastArea sebelum render. Ketukan aksesoris lama
berada di luar viewport; sekarang di-scroll sampai terlihat, diketuk, lalu
bagian pratinjau dibawa kembali ke atas. Kedua kasus diperiksa ulang melalui
gambar final. Panel rumah/toko/peta memang dapat digulir; potret menunjukkan
bagian awal layar, tanpa menempelkan konten tambahan di luar runtime.

## Verifikasi

- Baseline dari main: pub get, analyze bersih, 3.105 test lulus / 136 skip.
- Generator final: 36 test lulus, tidak ada peringatan ketukan atau overflow.
  Dua eksekusi lengkap menghasilkan seluruh 106 aset manifest identik byte
  demi byte sesudah ekspor RGB.
- Test kepala merek/piksel dan konfigurasi Android: 18 lulus.
- Format 297 file bersih; analyze bersih; review terjemahan dan subset sumber
  SVG sesuai. Pemeriksaan inventaris/RGB/hash/lingkaran aman lulus.
- APK debug berhasil: `build/app/outputs/flutter-apk/app-debug.apk`.
- Suite akhir: 3.105 test lulus / 60 skip, termasuk solusi seluruh 20 level.

## Batas dan langkah berikutnya

Screenshot adalah render widget host dengan aset runtime sebenarnya, tanpa
status/navigation bar Android. Tidak membuktikan launcher OEM, ikon tema,
splash native Android lama/12+, atau transisi splash ke frame Flutter.
Belum diuji di HP dan belum ada penerimaan visual final pemilik repo.
Lanjutkan pemeriksaan tersebut bersama TalkBack/audio/performa yang masih
terbuka dari langkah 13 pada langkah 15. APK debug bukan kandidat rilis
bertanda tangan produksi. Merge dan penerimaan visual dilakukan pemilik repo;
listing/aset belum diunggah ke Play Console.
