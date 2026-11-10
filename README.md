# 🐱 Ginger Logic

**Oyen won't listen. You do the thinking.**

Game puzzle mobile tentang kucing oren yang bergerak sendiri mengikuti aturan tetap. Pemain mengatur ikan, air dan kardus agar Oyen sampai ke mangkuk tanpa memecahkan vas Ibu.

## Arah baru

Pada 8 November 2026, pemilik repo memilih perombakan seluruh visual mengikuti **konsep A — satu area per layar**, termasuk bentuk kucing, furnitur, UI dan layar puzzle. Rumah v2 sudah berjalan dengan Beranda Santai, Area Makan, Bermain dan Perawatan berilustrasi, aktivitas otomatis serta ajakan pemain. Seluruh layar pemain memakai v2; pengujian perangkat dan persiapan rilis berlanjut mengikuti roadmap.

![Acuan baru Rumah Oyen — pilih konsep A di kiri](docs/design-brief/rumah-oyen-area/preview-perbandingan.png)

- [Roadmap baru, berikutnya langkah 15](docs/ROADMAP.md)
- [Audit animasi, suara, aksesibilitas dan performa v2](docs/design-v2/polish/REVIEW.md)
- [Tutorial, petunjuk, koin dan Pengaturan v2](docs/design-v2/guidance/REVIEW.md)
- [Peta, hasil, dan replay v2](docs/design-v2/journey/REVIEW.md)
- [Visual puzzle v2](docs/design-v2/puzzle/REVIEW.md)
- [Toko, koleksi, dan Hias per area v2](docs/design-v2/shop/REVIEW.md)
- [Spesifikasi dan mockup desain v2 — disetujui](docs/design-v2/README.md)
- [Brief arah desain](docs/design-brief/rumah-oyen-area/ARAH_DESAIN.md)
- [Keputusan aktif](docs/DESIGN_NOTES.md)

Screenshot berikut berasal dari runtime v2. Materi empat bahasa, ikon dan grafis fitur tersedia di [paket toko](docs/store/README.md); [hasil pemeriksaan langkah 14](docs/design-v2/store/REVIEW.md).

| Santai | Makan | Bermain | Perawatan |
| --- | --- | --- | --- |
| ![Santai](docs/screenshots/01-santai.png) | ![Makan](docs/screenshots/02-makan.png) | ![Bermain](docs/screenshots/03-main.png) | ![Perawatan](docs/screenshots/04-rawat.png) |

| Toko | Peta | Puzzle | Berhasil |
| --- | --- | --- | --- |
| ![Toko](docs/screenshots/05-toko-aksesoris.png) | ![Peta](docs/screenshots/06-peta-babak-2.png) | ![Puzzle](docs/screenshots/07-fase-atur-level-13.png) | ![Berhasil](docs/screenshots/08-berhasil-level-13.png) |

## Fondasi game yang sudah berjalan

- Dua babak, 20 level, tiga bintang per level, solver dan putar ulang langkah demi langkah.
- Petunjuk, koin, bonus harian dan iklan berhadiah pilihan pemain.
- Rumah, koleksi sembilan kucing, barang, aksesoris dan kebutuhan; menjadi fondasi migrasi ke desain beberapa area.
- Progres tersimpan di perangkat; bahasa Inggris, Indonesia, Portugis Brasil dan Rusia.
- Flutter + Flame, Android portrait. Package ID `com.gingerlogic.app`.

Aturan dan data puzzle tetap mengacu [GDD](docs/GDD.md), `assets/levels/chapter1-2.json` dan [simulator acuan](docs/reference/oyen_simulator.py). Pergantian nomor roadmap tidak mereset progres pemain.

## Menjalankan dan memeriksa

Gunakan Flutter yang memenuhi `pubspec.yaml`.

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Galeri komponen tersedia melalui `flutter run --route /galeri`.
Galeri aset desain v2 (sembilan karakter, animasi, aksesoris, barang, empat area) tersedia melalui `flutter run --route /galeri/aset-v2`; [render dan hasil pemeriksaan](docs/design-v2/assets/REVIEW.md).

Galeri fondasi UI v2 tersedia melalui `flutter run --route /galeri/ui-v2`; [render empat bahasa dan pemeriksaan komponen](docs/design-v2/ui/REVIEW.md).

Area Makan v2 tersedia dari tab Makan: mangkuk interaktif, ajakan/otomatis,
antrean dan jatah per kucing. [Render dan verifikasi langkah 6](docs/design-v2/dining/REVIEW.md).

Area Bermain v2: satu mainan bergantian, ajakan/otomatis, antrean dan cooldown.
[Render dan verifikasi langkah 7](docs/design-v2/play/REVIEW.md).

Area Perawatan v2: elus/sikat, antrean, batas Senang gabungan dan reaksi kucing.
[Render dan verifikasi langkah 8](docs/design-v2/care/REVIEW.md).

Generator v2 dan pemeriksa inventaris:

```sh
flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true
flutter test test/screenshots/screenshot_test.dart --dart-define=SCREENSHOTS=true --dart-define=SCREENSHOT_DIR=docs/screenshots
python tool/store_assets.py
python tool/store_assets.py --check
```

Perintah Python mengekspor PNG toko RGB tanpa mengubah piksel tampilan dan mencatat hash aset. `--sheets` membuat lembar tinjauan di `build/store-review/`.

## Struktur

| Folder | Isi |
| --- | --- |
| `lib/game/sim/` | Simulator dan solver Dart murni |
| `lib/game/model/` | Sesi level, progres, rumah, kebutuhan dan rutinitas |
| `lib/game/render/` | Renderer runtime; diganti bertahap mengikuti desain baru |
| `lib/screens/` | Rumah, Toko, peta, level, hasil, replay dan Pengaturan |
| `lib/widgets/`, `lib/theme/` | Komponen dan token UI |
| `lib/app/` | Router, penyimpanan, suara dan iklan |
| `docs/design-brief/rumah-oyen-area/` | Acuan visual baru dan brief |
| `docs/store/` | Listing, privasi dan panduan release yang dipertahankan |

Rincian kode dan alur kerja ada di [CLAUDE.md](CLAUDE.md). [Baseline performa 8 November](docs/performance-room-2026-11-08.md) berlaku untuk visual sebelumnya, bukan kelulusan desain baru.

## Kredit

Font Fredoka dan Nunito memakai SIL Open Font License (`assets/fonts/`). Kredit suara ada di `assets/audio/LICENSE-sfx.txt`. Sumber dan lisensi aset visual baru dicatat bersama paket asetnya.
