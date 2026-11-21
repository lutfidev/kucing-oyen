# Langkah 13: Lemari kostum

Dokumen desain hasil brainstorming dengan pemilik repo (18 Oktober 2026). Sumber lain tetap berlaku: `docs/ROADMAP.md` langkah 13, GDD layar 12 "Lemari Kostum", desain `docs/design/source/12-lemari-kostum.html` (tata letak, harga, teks, warna diambil persis dari sana) dan `14-sprite-oyen-arah-pose.html`.

## Maksud

Koin dari bintang (langkah 12) sekarang punya tujuan selain petunjuk: kostum kosmetik untuk Oyen. Pemain mengejar 3 bintang supaya bisa mendandani Oyen, lalu melihat Oyen berkostum itu di papan dan di layar hasil. Kostum hanya tampilan; tidak mengubah aturan main.

## Tujuan

1. **Layar Lemari Kostum** di rute baru `/kostum`, dibuka dari tombol "Lemari Kostum" di Beranda (sekarang belum bisa ditekan). Kembali = Beranda.
2. **Lima pilihan, harga persis desain 12:** Polos 0, Peci 60, Sarung 90, Topi Koki 150, Kacamata 45, urutan seperti desain (Polos, Peci, Sarung, Topi Koki, Kacamata). Nama tampil: "Polos", "Peci", "Sarung", "Topi Koki", "Kacamata".
3. **Pilih, beli, pakai** mengikuti logika desain 12 (lihat Rincian).
4. **Tersimpan:** kostum yang dimiliki dan kostum yang dipakai disimpan di perangkat.
5. **Oyen memakai kostum terpilih** di papan fase atur dan fase jalan, putar ulang, layar Berhasil dan Vas pecah, papan pudar layar Oyen bosan, dan tutorial.

## Bukan tujuan

- Kostum baru di luar empat kostum desain, atau gabungan dua kostum sekaligus.
- Sumber koin baru (langkah 14).
- Layar Pengaturan (langkah 15). Tombolnya tetap tidak bisa ditekan.
- Kartu aturan (desain 05): kucing di kartu adalah diagram aturan, tetap tanpa kostum.

## Jangan sampai

- Koin terpotong dua kali untuk kostum yang sama, atau kostum terbeli dengan saldo kurang.
- Saldo menjadi negatif.
- Menekan kartu langsung mengganti kostum yang dipakai (menekan kartu hanya pratinjau).
- Gambar Oyen atau kostum diketik ulang; semua tetap lewat `paintOyen` dan `OyenLook.costume` dari langkah 5.

## Rincian yang sudah diputuskan

### Layar

Tata letak persis desain 12 (layar 390×844):

- Bar atas: tombol kembali 44 px (`aria-label` "Kembali ke Beranda"), judul "Lemari Kostum" (Fredoka 700/24), chip koin di kanan (sama dengan chip koin sheet Petunjuk; `aria-live`).
- Pratinjau: lemari kayu (SVG 300×236 desain, disalin utuh ke `design_svg.dart`), Oyen pose `happy` menghadap bawah ukuran 168 dengan kostum yang sedang **dipilih**, lalu nama kostum terpilih di bawahnya (Fredoka 600/20).
- Grid 2 kolom, jarak 10, kartu tinggi 104, radius 20: kotak 64×64 berisi Oyen pose `idle` ukuran 56 dengan kostum kartu itu, nama (Fredoka 600/16), dan label:
  - "Dipakai" (isi `#2BB5A0`, teks `#12352F`) kalau sedang dipakai,
  - "Punyamu" (isi `#EFE3CF`) kalau dimiliki tapi tidak dipakai,
  - ikon koin kecil + harga (isi `#FFF1C9`) kalau belum dimiliki.
  - Kartu terpilih berbingkai oranye `#F59A33` dengan bayangan `#C9650C`, yang lain bingkai `#EAD3AE` bayangan `#E2C79C`. Kartu adalah tombol dengan status `pressed` = terpilih untuk pembaca layar.
- Tombol aksi di bawah, tinggi 66 (Fredoka 700/22):
  - "Sedang dipakai" kalau kostum terpilih sedang dipakai (nonaktif),
  - "Pakai" kalau dimiliki,
  - "Beli · N koin" kalau belum dimiliki dan koin cukup,
  - "Koin kurang · N" kalau koin kurang (nonaktif, warna tombol nonaktif yang sudah ada di token).
- Warna dan ukuran lewat token tema (`KoColors`, `KoType`, `KoSize`, ...); tambah token kalau belum ada. Tidak ada nilai hardcode di widget.
- Layar pendek dan teks 130%: harus lolos `overflow_test` (rute baru ditambahkan ke daftar `routes`). Cara menyesuaikan diserahkan ke pembangun (mis. pratinjau mengecil atau isi bisa digulir, seperti layar lain).

### Logika

- Saat layar dibuka, kartu terpilih = kostum yang sedang dipakai (keputusan saya; contoh desain memilih Peci hanya untuk pamer).
- Menekan kartu hanya memilih: pratinjau dan nama berganti, kostum yang dipakai tidak berubah. Keluar layar tanpa menekan aksi tidak mengubah apa pun.
- "Pakai": kostum terpilih menjadi yang dipakai.
- "Beli · N koin": koin dipotong N, kostum menjadi milik pemain dan langsung dipakai. Tanpa dialog konfirmasi (desain tidak punya).
- Awal permainan: hanya Polos yang dimiliki dan dipakai. Polos selalu dimiliki.

### Model dan simpanan

- Model Dart murni (mis. `lib/game/model/costumes.dart`): daftar kostum dengan id `OyenCostume`, nama, dan harga; aturan beli (koin cukup, belum dimiliki). Bentuk persisnya diserahkan ke pembangun. `OyenCostume` sudah ada di `lib/game/render/oyen.dart`; kalau model murni tidak boleh bergantung ke `render/`, pembangun boleh memindahkan enum atau memakai id string, asal satu sumber.
- `ProgressController` menambah: kostum yang dimiliki, kostum yang dipakai, `buyCostume` (gagal tanpa efek kalau sudah dimiliki atau koin kurang; berhasil = potong koin, tambah ke milik, pakai), `wearCostume` (hanya kostum yang dimiliki). Keduanya memberi tahu pendengar lalu menyimpan, seperti `unlockHint`.
- `ProgressStore` menambah `loadCostumes`/`saveCostumes` (atau dua pasang terpisah), `PrefsProgressStore` memakai kunci `costume.owned` (daftar id) dan `costume.wearing` (id). Data rusak: id tak dikenal dibuang, Polos selalu dimiliki, kostum dipakai yang tidak dimiliki kembali ke Polos. `MemoryProgressStore` ikut.
- Saldo koin disimpan lewat `saveCoins` yang sudah ada.

### Oyen berkostum

- Kostum dipakai dibaca dari `ProgressScope` dan dioper ke gambar Oyen di: papan `LevelView` (fase atur dan jalan, lewat `BoardScene`), `ReplayView`, `SuccessArt`/`VaseArt` (pose makan), `RestBoard`/layar Oyen bosan, dan `TutorialOverlay`. Cara mengoper (parameter `costume` di `runScene`/`restScene`/`replayScene`/`BoardScene.fromMap`, atau helper yang mengganti kostum pada `BoardScene`) diserahkan ke pembangun; yang penting simulasi dan `RunFrame` tidak tahu soal kostum.
- Desain Oyen menyembunyikan peci, topi koki, dan kacamata saat tidur, dan sarung hanya tampil di pose normal (bukan tidur, bukan di kardus). Jadi Oyen tidur (Beranda, awal fase atur, layar Oyen bosan) tampak polos; itu sesuai desain, bukan bug. Beranda boleh ikut dioper kostum demi konsistensi, tidak wajib.

## Test

- Model: harga dan urutan persis desain, aturan beli.
- `ProgressController`: beli dengan koin cukup (koin berkurang, dimiliki, dipakai, tersimpan), koin kurang (tidak berubah apa pun), beli dua kali tidak memotong lagi, pakai kostum dimiliki, pakai kostum tak dimiliki ditolak, muat ulang dari store.
- `PrefsProgressStore`: simpan/muat, data rusak.
- Layar: label kartu dan tombol per keadaan, pilih kartu tidak mengganti yang dipakai, beli, pakai, koin kurang (tombol nonaktif), chip koin ikut berkurang, kembali ke Beranda, tombol Beranda membuka layar.
- Oyen berkostum di papan level (mis. `KucingGame.scene` atau `BoardScene` memuat kostum) dan di layar hasil.
- `overflow_test`: rute `/kostum` di semua ukuran dan skala teks, termasuk saldo besar.
- Potret layar `test/screenshots/` untuk layar Lemari Kostum, dibandingkan dengan desain 12.
- `docs/design/` sinkron: `design_sync_test.dart` mencakup SVG lemari baru kalau polanya sudah begitu.

## Dokumen

- `CLAUDE.md` bagian Struktur: layar baru, model, API `ProgressController`/`ProgressStore`, test baru.
- `docs/DESIGN_NOTES.md` bagian langkah 13: keputusan di dokumen ini yang bertanda "keputusan saya" dan penyesuaian tata letak layar pendek.
- `docs/ROADMAP.md`: centang langkah 13.
