# Roadmap Kucing Oren

Satu langkah = satu sesi = satu PR. Pemilik repo `/clear` setelah tiap sesi, jadi setiap langkah harus bisa dikerjakan dari nol tanpa ingatan sesi sebelumnya.

## Cara memakai

- Langkah berikutnya = langkah pertama yang belum dicentang di **Status**. Mulai dan akhiri langkah sesuai "Alur git per langkah roadmap" di `CLAUDE.md`.
- Cukup ketik "kerjakan langkah berikutnya di docs/ROADMAP.md", atau tempel prompt langkahnya.
- Baca file yang disebut di prompt dan kode yang sudah ada sebelum menulis. Nama kelas dan file di prompt adalah usulan; kalau langkah sebelumnya sudah memakai nama lain, ikuti kode. Jangan memakai API yang belum dibaca.
- Ukuran, warna, dan teks diambil persis dari `docs/design/source/*.html`. Angka di prompt ini hanya penunjuk letak.
- Kalau sumber bertentangan: aturan main ikut GDD dan simulator, isi level ikut `assets/levels/chapter1-2.json`, tampilan ikut desain. Catat keputusannya di `docs/DESIGN_NOTES.md`.
- Hal di luar lingkup langkah tidak dikerjakan; tulis sebagai saran di badan PR.
- Sebelum PR: centang langkahnya di **Status** dan perbarui bagian "Struktur" di `CLAUDE.md`.

## Status

- [x] 1. Simulasi Oyen di Dart murni dan loader level
- [x] 2. Solver dan cek data level
- [x] 3. Model sesi level (baki, penempatan, bintang)
- [x] 4. Fondasi UI: token desain, font, komponen dasar
- [x] 5. Gambar petak, papan, dan Oyen
- [x] 6. Gameplay fase atur
- [x] 7. Gameplay fase jalan
- [x] 8. Hasil: berhasil, vas pecah, Oyen bosan
- [x] 9. Beranda, peta babak, progres tersimpan
- [x] 10. Putar ulang
- [x] 11. Kartu aturan dan tutorial
- [x] 12. Petunjuk dan koin
- [x] 13. Lemari kostum
- [x] 14. Koin tambahan: tonton iklan dan bonus harian
- [x] 15. Bahasa dan Pengaturan
- [x] 16. Musik dan efek suara
- [x] 17. Polish dan rilis Android
- [x] 18. Pengerasan iklan dan rilis (temuan kecil review langkah 17)
- [x] 19. Saran lama dari PR sebelumnya (aksesibilitas, navigasi, simpanan, suara)
- [x] 20. Sisa saran: putar otomatis, terjemahan, dan rapi-rapi kecil
- [x] 21. Rumah Oyen: model kamar, kucing, aksesoris, makanan, dan kebutuhan
- [x] 22. Toko dan aksesoris
- [ ] 23. Kamar Oyen sebagai Beranda, tanpa Lemari Kostum
- [ ] 24. Kamar hidup: animasi, rutinitas, kebutuhan, dan hadiah
- [ ] 25. Peta bergambar dan Oyen berjalan ke level berikutnya
- [ ] 26. Potret toko dan rapi-rapi rumah Oyen

Langkah 15–17 dipecah dari "Polish dan rilis Android" lama (diskusi dengan pemilik repo, 19 Okt 2026). Keputusan pasar, bahasa, iklan, dan isi Pengaturan dicatat di `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 15"; prompt di bawah tidak perlu menanyakannya lagi.

Langkah 21–26 (rumah Oyen) diputuskan saat brainstorming 26 Okt 2026 dan dikerjakan sesudah langkah 18–20. Desainnya sudah dibuat pemilik repo di Claude Design (28 Okt 2026); lihat bagian "Sebelum langkah 21" di bawah.

---

## 1. Simulasi Oyen di Dart murni ✅

Selesai langsung di `main` (commit `47fc414`), sebelum alur PR dipakai. Isinya `lib/game/sim/`, `lib/game/level_loader.dart`, test 20 solusi, dan test level 13. Simulasi sudah dibandingkan dengan `oyen_simulator.py` pada 93.829 kasus (semua penempatan isi baki di 20 level, papan acak, lorong di batas 80 langkah) dan log per langkahnya identik.

## 2. Solver dan cek data level ✅

**Hasil:** solver Dart yang hasilnya sama dengan `solve()` Python, dan test yang membuktikan angka bintang 3 di data level benar.

Selesai: `lib/game/sim/solver.dart` dan `test/game/sim/solver_test.dart`. Semua solusi minimum dari Dart identik dengan Python di 40 kasus (20 level, dengan dan tanpa syarat vas aman, total 78 solusi). Ke-20 level selesai sekitar 1 detik.

> Baca `docs/reference/oyen_simulator.py` (`solve`, `empty_cells`) dan `lib/game/sim/`. Port solver ke `lib/game/sim/solver.dart`, Dart murni. Diberi `Board` dan isi baki, solver mencari jumlah benda paling sedikit yang menang tanpa vas pecah (`need_safe=True`), mulai dari 0 benda, beserta semua solusi minimum tanpa duplikat (benda sejenis yang bertukar tempat dihitung satu). Petak calon = `Board.emptyCells`. Test untuk ke-20 level: jumlah minimum sama dengan `starItems`, solusi di JSON termasuk solusi minimum, dan jumlah solusi minimum = 3 untuk level 3, 5, 19, 20; 2 untuk level 9, 10, 17, 18; 1 untuk level lainnya (angka dari solver Python, sudah dicek). Kalau hasilnya beda, cari salahnya di port; jangan ubah data level. Solver Python butuh sekitar 11 detik untuk ke-20 level. Versi Dart jangan membuat `flutter test` lambat: enumerasi kombinasi petak per jenis benda, bukan permutasi seperti Python.

## 3. Model sesi level ✅

**Hasil:** alur fase atur → jalan → hasil ada di model Dart murni yang bisa diuji tanpa layar.

Selesai: `lib/game/model/level_session.dart` dan `test/game/model/level_session_test.dart` (22 test). Selain aksi di prompt, ada `finish()` (fase jalan → layar hasil), `arrangeAgain()` (Atur Lagi/Coba Lagi, dari fase jalan atau hasil), dan `canPlaceAt(pos)` untuk petak yang menyala. Gagal juga lewat fase `result` (layar Oyen bosan), lalu `arrangeAgain()`. Test 2 bintang memakai level 15: solusi JSON + ember di (1,1).

> Baca GDD bagian "Alur satu level" dan "Bintang", lalu `lib/game/sim/`. Buat `lib/game/model/level_session.dart` (Dart murni, tanpa Flutter). `LevelSession(level)` menyimpan fase (`arrange`, `running`, `result`), benda yang ditaruh pemain, dan sisa baki (`inventory` dikurangi benda terpasang). Aksi: `place(item, pos)` (hanya di petak `board.canPlace` yang belum terisi dan kalau sisa baki > 0), `move(from, to)`, `remove(pos)` (kembali ke baki), `reset()`. `wake()` menjalankan `simulate` dan menyimpan `SimResult`. Bintang: 0 kalau gagal, 1 kalau menang, 2 kalau menang dan vas aman, 3 kalau juga jumlah benda dipakai ≤ `starItems`. Gagal atau "Atur Lagi" kembali ke fase atur dengan susunan benda tetap. Model harus bisa membedakan benda pemain dari benda bawaan peta, karena desain menggambarnya berbeda. Unit test semua aksi termasuk penolakan, dan bintang untuk level 13: solusi JSON (3 bintang), ikan saja di (2,4) (1 bintang, vas pecah), tanpa benda (gagal). Belum ada UI.

## 4. Fondasi UI ✅

**Hasil:** token desain, font, komponen dasar, kerangka app dengan rute galeri, dan perkakas test layar.

Selesai: `lib/theme/` (KoColors, KoType, KoSpace, KoRadius, KoShadow, KoSize, `KoTheme.light()`, akses `context.koColors` dst.), `lib/widgets/` (`KoButton`, `KoIconButton`, `KoChip`, `TraySlot`, `KoCard`, `KoStars`, `KoIcons`), `lib/app/` (go_router: `/` sementara, `/galeri`), dan font di `assets/fonts/`. Token dipisah per grup seperti lembar token, bukan satu `ThemeExtension`; alasan dan keputusan lain di `docs/DESIGN_NOTES.md`. Semua test memakai font asli lewat `test/flutter_test_config.dart`. Node level menunggu langkah 9.

> Baca `docs/design/source/13-design-token-komponen-ui.html` (warna, tipografi, jarak, radius, bayangan, komponen) dan `01-beranda.html` untuk gaya umum. Buat `lib/theme/` dengan semua token dalam satu `ThemeExtension` (desain menulis "Nama token disiapkan untuk Flutter: satu ThemeExtension") dan gaya teks display, title, heading, number, body, label, overline (Fredoka 500–700, Nunito 600–800). Font dibundel sebagai aset, bukan diunduh saat aplikasi jalan. Komponen di `lib/widgets/`: tombol utama, sukses, sekunder, dan ikon (dengan efek tekan "press"), chip, slot baki, kartu. Kerangka app: `MaterialApp.router` + `go_router`, rute `/` sementara dan `/galeri` yang menampilkan semua komponen. Tidak ada warna atau ukuran hardcode di widget; tambah token kalau butuh nilai baru. Test: widget test komponen, test overflow semua rute di 360×640 sampai 412×915 dengan teks 130% (rute baru di langkah berikutnya ditambahkan ke test ini), dan potret layar `flutter test test/screenshots --dart-define=SCREENSHOTS=true` → `build/screenshots/390x844/*.png` dengan font asli, di-skip di test biasa. Pola yang sudah jalan bisa dicontoh dari repo `D:\Dev\personal\game\busy_network` (`lib/theme/`, `test/screens/overflow_test.dart`, `test/screenshots/`).

## 5. Gambar petak, papan, dan Oyen ✅

**Hasil:** semua gambar papan dan Oyen dari desain tergambar di `Canvas` dan bisa dicek di galeri.

Selesai: `lib/game/render/` (`Tile`, `OyenLook`, `BoardScene.fromMap` Dart murni; `paintTile`, `paintOyen`, `paintBoard`, `paintBoardFrame`, `tileGlowOpacity`), `lib/widgets/game_art.dart` (`TileView`, `OyenView`, `BoardView`), dan galeri `/galeri/papan` serta `/galeri/oyen`. Isi `<svg>` desain disalin utuh ke `design_svg.dart` dan digambar oleh pengurai SVG kecil (`SvgTemplate`), bukan diketik ulang. Warna piksel di koordinat dari angka desain dicek di `painters_test.dart`. Gelas jatuh, arah pose menjatuhkan, dan hal yang ditunda ke langkah 6, 7, 10 dicatat di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/Tile.dc.html`, `Oyen.dc.html`, `Board.dc.html`, lalu halaman `14-sprite-oyen-arah-pose.html`, `15-elemen-papan.html`, `16-komponen-oyen.html`, `17-komponen-petak.html`. Port ketiga komponen ke `lib/game/render/` sebagai fungsi gambar `Canvas` murni yang bisa dipakai Flutter maupun Flame:
>
> - Petak 50×50: `kind` floor/wall/cupboard/shelf/fridge/bowl/table/tableGlass/tableVase/tableBroken, `item` none/fish/water/box/fishP/bucketP/boxP, `alt`, `glow`. Ikuti `renderVals()` persis.
> - Oyen (viewBox 100×100): `pose` idle/walk/sleep/shock/box/knock/eat/happy, `dir` down/left/right/up, `costume` none/peci/sarung/koki/kacamata, `bubble` none/zzz/kaget.
> - Papan 350×450 mengikuti `Board.dc.html`: `#` di baris 0 = [wall, cupboard, shelf, fridge, cupboard, shelf, wall], `#` di bagian dalam = cupboard, `#` lainnya = wall; lantai `alt` kalau (kolom + baris) ganjil; Oyen 62 px di (kolom·50 − 6, baris·50 − 12); panah arah hadap saat Oyen tidur; bingkai dan bayangan papan.
>
> Salin string `d` path SVG apa adanya lalu urai dengan `parseSvgPathData` dari package `path_drawing`; jangan menyalin ulang koordinat dengan tangan. Gelas yang sudah jatuh tidak punya gambar di desain: pakai `table` kosong dan catat. Tambahkan halaman petak dan Oyen (seperti halaman desain 14 dan 15) ke `/galeri`. Test: pemetaan peta → jenis petak untuk level 13 dan 18 (Dart murni) dan galeri tergambar tanpa error. Sebelum PR, ambil potret galeri dan periksa hasilnya dengan membandingkan angka di file desain.

## 6. Gameplay fase atur ✅

**Hasil:** layar level bisa dibuka; pemain bisa menaruh, memindah, dan mengembalikan benda.

Selesai: `lib/game/kucing_game.dart` (`KucingGame`, `BoardInput`), `lib/game/components/` (`BoardComponent`, `CatComponent`), `lib/screens/level/` (rute `/level/:id`, `LevelView`, baki), gambar benda baki dari desain 03 (`paintItemArt`, `paintLiftedItem`), dan tombol 1–20 di Beranda sementara. Yang menyala hanya petak tujuan di bawah jari (desain 03 dan 15). Benda papan yang dilepas di luar papan kembali ke baki; di petak tidak sah kembali ke petak asal. Hasil `wake()` sementara berupa teks dengan tombol "Atur Lagi". `loadLevels()` kini tanpa cache `rootBundle` supaya bisa dimuat di banyak widget test. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/03-gameplay-fase-atur.html`, `18-komponen-papan-7x9.html`, dan GDD bagian "Alur satu level" serta "Pembagian komponen Flame". Tambah `flame` (busy_network memakai `flame: ^1.38.2` dengan versi Flutter yang sama). Buat `KucingGame` (`FlameGame`) dengan kamera beresolusi tetap 350×450 (koordinat papan desain), lalu `BoardComponent` dan `CatComponent` yang menggambar lewat `lib/game/render/`. Layar `/level/:id` memuat level lewat `loadLevels()` dan memakai `LevelSession`: bar atas (kembali, "Level 13 · Vas Ibu", target bintang 3 "pakai N benda", tombol Aturan yang belum berfungsi), papan dengan Oyen tidur + Zzz + panah arah hadap, baki dengan angka sisa, petunjuk "Taruh di petak yang menyala", dan tombol "Bangunkan Oyen". Seret benda dari baki ke papan: petak yang boleh diisi menyala (`glow`) dan benda menempel ke petak. Benda di papan bisa diseret ke petak lain atau kembali ke baki. Logika tetap di `LevelSession`; komponen Flame hanya menerjemahkan sentuhan ke koordinat petak. "Bangunkan Oyen" cukup memanggil `wake()` dan menampilkan hasil sementara berupa teks; animasinya di langkah 7. Test: widget test menyeret benda (buat helper seret ke petak), penolakan petak tidak sah, angka baki berubah. Tambah rute ini ke test overflow.

## 7. Gameplay fase jalan ✅

**Hasil:** Oyen bergerak langkah demi langkah mengikuti `SimResult.trace`.

Selesai: keadaan papan per langkah dibangun ulang dari `trace` tanpa simulasi ulang (`runFrames`), jam pemutar 4 langkah per detik dengan jeda, ×2, dan maju satu langkah (`RunClock`), caption per `StepKind` (`runCaption`), pose dan papan per langkah (`runLook`, `runScene`, termasuk garis jalur putus-putus desain 04), Oyen digeser antarpetak di `CatComponent`, dan layar fase jalan desain 04 (`run_panel.dart`). Gelembung ikan dan pose menjatuhkan yang dicerminkan ke arah meja dibuat dengan gaya desain. "Lihat hasil" membuka teks hasil sementara langkah 6 sampai langkah 8. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/04-gameplay-fase-jalan.html` (termasuk daftar `steps` dan caption-nya), `16-komponen-oyen.html`, dan GDD bagian "Alur satu level". Setelah "Bangunkan Oyen", mainkan `trace` satu langkah demi satu langkah: 4 langkah per detik sesuai GDD (desain memakai transisi 0,35 detik; ikuti GDD dan catat), tombol ×2, Jeda/Lanjutkan, penghitung "Langkah N", status vas dan jumlah benda dipakai seperti desain. Pose per `StepKind`: `walk` → walk; `scared` → shock + gelembung kaget (desain menampilkan kaget masih menghadap air, sedangkan `SimStep.dir` adalah arah sesudah putar balik); `turn` → idle dengan arah baru; `enterBox`/`sit` → box; `knockGlass`/`knockVase` → knock (gelas jatuh jadi meja kosong, vas jadi `tableBroken`); `eat` → eat dan ikannya hilang. Kardus hilang pada langkah `sit` yang punya `changed`. Langkah terakhir di mangkuk memakai pose seperti desain. Gelembung pikiran bergambar ikan saat `SimStep.chasing` tidak null disebut di GDD tapi tidak ada di desain: buat dengan gaya gelembung kaget dan catat. Selesai → tombol "Lihat hasil" (layar hasil di langkah 8; sementara kembali ke fase atur). Kalau `MediaQuery.disableAnimations`, langsung ke keadaan akhir. Test: urutan pose dan posisi untuk solusi level 13 dan level 15 (kardus), keadaan papan akhir, jeda, dan ×2.

## 8. Hasil: berhasil, vas pecah, Oyen bosan ✅

**Hasil:** ketiga layar hasil tersambung ke fase jalan dan fase atur.

Selesai: `lib/screens/result/` (`ResultView` memilih `SuccessResult`, `VaseResult`, atau `BoredResult` dari `LevelSession`) yang menutupi layar level setelah "Lihat hasil", tanpa rute baru. Sinar berputar, bintang `koStar`, Ibu `koPeek`, dan "PRANG!" `koShake` dibuat seperti desain, dengan SVG 06 dan 07 disalin utuh. Papan Oyen bosan memakai keadaan papan terakhir (`restScene`). Ulangi = papan kosong, Coba Lagi/Atur Lagi = susunan tetap, Lanjut = level berikutnya (sesudah level 20 ke Beranda). Putar ulang nonaktif sampai langkah 10. Kelamaan tidak bisa terjadi di 20 level sekarang; teksnya dibuat dan diuji dengan peta buatan. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/06-hasil-berhasil.html`, `07-hasil-vas-pecah.html`, `08-gagal-oyen-bosan.html`, dan GDD bagian "Bintang". Buat ketiga layar dengan teks persis seperti desain. Berhasil: animasi bintang, jumlah langkah, benda dipakai, penjelasan bintang, Ulangi/Lanjut, dan "Tonton putar ulang" (nonaktif sampai langkah 10). Vas pecah: "Sampai sih... tapi vas Ibu?", "Pecah di langkah N" dari `vaseBrokenAtStep`, Coba Lagi/Lanjut Saja. Oyen bosan untuk `FailReason.loop`; desain belum punya teks untuk `FailReason.tooManySteps` (kelamaan), jadi buat teks santai yang senada dan catat. Atur Lagi → fase atur dengan susunan tetap; Ulangi → papan kosong; Lanjut → level berikutnya. Angka bintang dari `LevelSession`. Test untuk level 13: solusi JSON (berhasil, 3 bintang), ikan saja di (2,4) ("Pecah di langkah 2", 10 langkah, 1 benda, sama dengan contoh desain), tanpa benda (Oyen bosan). Tambah rute ke test overflow.

## 9. Beranda, peta babak, progres tersimpan ✅

**Hasil:** game bisa dimainkan dari Beranda sampai level 20, dan progres tidak hilang.

Selesai: `Progress` dan `Chapter` (Dart murni, `lib/game/model/`), `ProgressStore` (`shared_preferences`, versi memori untuk test) dan `ProgressController`/`ProgressScope` di `lib/app/`, Beranda (desain 01), dan peta babak `/babak/:n` (desain 02) untuk kedua babak. Level pindah ke `/babak/:n/level/:id` supaya kembali menuju peta; bintang dicatat saat layar hasil dibuka. Babak 1 memakai tata letak desain 02 dengan gambar bos dan ikon babak yang dirakit dari gambar desain. Chip koin di Beranda menunggu langkah 12. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/01-beranda.html`, `02-peta-babak-2-ruang-tamu.html`, dan GDD bagian "Babak 1" serta "Babak 2". Beranda: logo, Oyen tidur, total bintang `x/60`, tombol Main, Lemari Kostum dan Pengaturan (belum berfungsi). Peta babak: desain hanya punya Babak 2 – Ruang Tamu; buat Babak 1 – Dapur (level 1–10, bos "Pesta Ikan Asin") dengan tata letak dan gaya yang sama, lalu catat. Tiap level menampilkan 0–3 bintang; level terkunci pudar dengan gembok; level saat ini menonjol; level bos lebih besar. Progres (bintang terbaik per level) disimpan lokal dengan `shared_preferences` di balik antarmuka kecil supaya mudah diuji. Level n+1 terbuka setelah level n menang (aturan ini belum ada di GDD; catat). Sambungkan Beranda → Peta → Level → Hasil → Lanjut atau kembali ke Peta. Test: simpan dan muat progres, buka kunci, total bintang, alur navigasi. Tambah rute ke test overflow.

## 10. Putar ulang ✅

**Hasil:** pemain bisa memutar ulang langkah Oyen maju dan mundur.

Selesai: nomor jejak dan caption rekap (`replayTrail`, `replayCaptions`, Dart murni di `lib/game/model/replay.dart`), papan per langkah (`replayScene`, `paintBoardTrail`) dari `runFrames` tanpa simulasi ulang, dan layar `ReplayView` (desain 09) yang dibuka dari "Tonton putar ulang" (Berhasil) dan "Putar Ulang" (Oyen bosan) di atas layar hasil, tanpa rute baru. Caption solusi level 13 persis desain 09. Langkah terakhir yang gagal menyebut langkah yang terulang atau batas 80 langkah. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/09-putar-ulang.html` (slider, mundur/maju satu langkah, jejak langkah bernomor, garis jalur, caption per langkah). Bangun ulang keadaan papan di tiap langkah dari `SimResult.trace` (barang jatuh, ikan dimakan, kardus penyok) tanpa menjalankan ulang simulasi. Caption dibuat dari `StepKind` dengan arah layar (atas, bawah, kiri, kanan) dan bahasa santai seperti contoh caption di desain 04 dan 09; teks aturan tetap memakai "berputar searah jarum jam". Putar ulang dibuka dari layar Berhasil ("Tonton putar ulang") dan Oyen bosan ("Putar Ulang"). Test: keadaan papan di langkah 0, tengah, dan akhir untuk level 13 dan 15; caption untuk tiap `StepKind`.

## 11. Kartu aturan dan tutorial ✅

**Hasil:** tombol Aturan membuka kartu aturan sesuai yang sudah dipelajari, dan level pengenalan punya tutorial.

Selesai: `OyenRule` dan `learnedRules` (Dart murni, `lib/game/model/rules.dart`), sheet "Aturan Oyen" (desain 05) dari tombol Aturan di fase atur dengan lima kartu urut cek per langkah, terkunci sampai level pengenalannya terbuka, dan overlay tutorial (desain 11) di level 1, 3, dan 6 yang selesai saat yang disorot dipakai atau "Lewati", disimpan di `ProgressStore` sehingga hanya muncul sekali. Kartu dan tutorial yang tidak ada di desain dibuat dengan gaya yang sama. Keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/05-kartu-aturan-oyen.html`, `11-tutorial-level-1.html`, dan kolom "Hal baru" di tabel level GDD. Kartu aturan (bottom sheet dari tombol Aturan) berisi lima kartu urut seperti desain. Kartu terbuka saat pemain sudah membuka level yang memperkenalkannya: tembok/meja di level 2, ikan di level 3, air di level 6, jatuhkan barang di level 12, kardus di level 14 (desain menampilkan kartu kardus masih "???", cocok untuk pemain yang baru sampai level 13 seperti layar contoh lainnya). Tutorial level 1 berupa overlay seperti desain, dengan teks persis. Desain 11 memakai peta dan nama level 1 versi lama ("Halo, Oyen"); pakai data level 1 dari JSON dan ambil gaya serta teks overlay-nya saja. GDD juga meminta tutorial level 3 (ikan) dan level 6 (ember) yang belum ada desainnya: buat dengan gaya yang sama dan teks pendek yang santai, lalu catat. Status tutorial selesai disimpan. Test: kartu terkunci/terbuka per level, tutorial hanya muncul sekali.

## 12. Petunjuk dan koin ✅

**Hasil:** tiga tingkat petunjuk bisa dibuka dengan iklan berhadiah (palsu dulu) atau koin.

Selesai: 10 koin per bintang yang pertama kali didapat (sumber koin yang disepakati dengan pemilik repo; pemain lama mendapat total bintang × 10), isi petunjuk dan teksnya (Dart murni, `lib/game/model/hints.dart`), koin dan tingkat petunjuk per level tersimpan lewat `ProgressStore`, `RewardedAds` dengan `FakeRewardedAds`, sheet Petunjuk (desain 10) dari tombol bohlam di fase atur, tanda petunjuk di papan (petak menyala + benda samar) yang tetap ada setelah sheet ditutup, chip koin di Beranda, dan "+N koin" di layar Berhasil dan vas pecah. Petunjuk tidak mengurangi bintang. Desain dan rencana di `docs/superpowers/`; keputusan lain di `docs/DESIGN_NOTES.md`.

> Baca `docs/design/source/10-petunjuk.html` dan GDD bagian "Petunjuk". GDD belum mengatur cara pemain mendapat koin: tanyakan ke pemilik repo di awal sesi sebelum menulis kode, lalu catat jawabannya. Tiga tingkat dibuka berurutan: (1) sorot petak benda pertama, (2) tunjukkan jenis benda untuk petak itu, (3) tampilkan solusi bintang 3 lengkap. Sumbernya `level.solution`, yang di langkah 2 sudah terbukti termasuk solusi minimum. Tiap tingkat dibuka dengan "Tonton iklan" atau koin, dengan harga persis seperti desain. Iklan lewat antarmuka `RewardedAds` dengan implementasi palsu yang selalu berhasil; SDK iklan asli dipasang di langkah 15. Koin dan petunjuk yang sudah terbuka disimpan per level. Test: urutan buka tingkat, koin berkurang, petunjuk tampil di papan.

## 13. Lemari kostum ✅

**Hasil:** kostum bisa dibeli dengan koin dan dipakai Oyen.

Selesai: layar Lemari Kostum (desain 12, rute `/kostum`) dari tombol di Beranda, dengan pratinjau Oyen di lemari, grid lima kostum dengan harga desain (Polos 0, Peci 60, Sarung 90, Topi Koki 150, Kacamata 45), serta tombol beli dan pakai. Kostum yang dimiliki dan dipakai tersimpan lewat `ProgressStore` (model Dart murni `Wardrobe` di `lib/game/model/costumes.dart`). Oyen memakai kostum terpilih di papan, putar ulang, layar hasil, dan tutorial. Desain dan rencana di `docs/superpowers/`; keputusan lain di `docs/DESIGN_NOTES.md`.

> Fitur ini tidak ada di daftar "Isi versi pertama" GDD, tapi tombolnya ada di Beranda dan desainnya sudah jadi. Baca `docs/design/source/12-lemari-kostum.html` dan `14-sprite-oyen-arah-pose.html`. Grid kostum (peci, sarung, koki, kacamata) dengan pratinjau Oyen, harga koin persis desain, beli, pakai, dan simpan pilihan. Oyen di papan dan di layar hasil memakai kostum terpilih (gambar Oyen dari langkah 5 sudah mendukung `costume`). Test: beli, pakai, koin tidak cukup.

## 14. Koin tambahan: tonton iklan dan bonus harian ✅

**Hasil:** pemain bisa menambah koin dengan menonton iklan berhadiah dan mendapat bonus koin harian.

Selesai: sheet "Tambah Koin" dari chip koin Beranda (bertitik selama bonus belum diambil) dan Lemari Kostum, dengan bonus harian 20 koin sekali per hari kalender dan iklan berhadiah +20 koin paling banyak 5 kali sehari (angka keputusan saya atas permintaan pemilik repo). Hari klaim dan jatah iklan tersimpan lewat `ProgressStore` (model Dart murni `DailyRewards` di `lib/game/model/rewards.dart`), jam bisa diganti di test (`ProgressController.clock`), iklan tetap lewat `RewardedAds` palsu. Ketiga chip koin disatukan menjadi `KoCoinChip`. Rencana di `docs/superpowers/plans/`; keputusan lain di `docs/DESIGN_NOTES.md`.

> Disetujui pemilik repo saat brainstorming langkah 12. Baca `docs/superpowers/specs/2026-10-17-hints-coins-design.md`, `docs/DESIGN_NOTES.md` bagian langkah 12, dan kode koin yang ada (`ProgressController.coins`, `RewardedAds`, `FakeRewardedAds`, chip koin Beranda). Tanyakan dulu ke pemilik repo: berapa koin per iklan, batas iklan per hari (kalau ada), besar bonus harian, dan di mana tombolnya (mis. "Tonton iklan, koin ×2" di layar Berhasil, atau chip koin Beranda). Desainnya belum ada: buat dengan gaya desain yang ada (lihat sheet Petunjuk dan Lemari Kostum), cek lewat potret layar, dan catat. Iklan tetap lewat `RewardedAds` (palsu sampai langkah 15). Bonus harian butuh tanggal: simpan hari terakhir klaim lewat `ProgressStore` dan buat jam bisa diganti di test. Test: koin bertambah sekali per iklan yang selesai, iklan gagal tidak menambah, bonus hanya sekali per hari, saldo tersimpan.

## 15. Bahasa dan Pengaturan ✅

**Hasil:** game bisa dimainkan dalam bahasa Inggris (utama), Indonesia, Portugis Brasil, dan Rusia, dan tombol Pengaturan di Beranda membuka layar Pengaturan.

Selesai: nama game "Ginger Logic" (pilihan pemilik repo, sama di semua bahasa; logo "Ginger"/"Logic", `android:label`), semua teks pemain di `lib/l10n/app_{en,id,pt,ru}.arb` lewat `gen-l10n` dengan teks Indonesia persis seperti sebelumnya, model Dart murni yang mengembalikan data (`RunText`, `ReplayText`, `HintText`, nama lewat `lib/l10n/names.dart`), bahasa awal dari HP dan pilihan pemain tersimpan (`AppLanguage`, `settings.language`), cadangan Nunito untuk huruf Rusia yang diuji, layar Pengaturan `/pengaturan` (bahasa, lihat tutorial lagi, reset progres dengan konfirmasi, tentang), `overflow_test` untuk keempat bahasa, dan potret layar per bahasa. Desain dan rencana di `docs/superpowers/`; keputusan lain di `docs/DESIGN_NOTES.md` bagian "Langkah 15".

> Baca dulu `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 15" (keputusan pasar, bahasa, dan isi Pengaturan sudah diambil). Tanyakan dulu ke pemilik repo: nama game dan logo di tiap bahasa (tetap "Kucing Oren" sebagai merek, atau diterjemahkan), dan nama Oyen serta "Ibu" (vas Ibu) di bahasa lain. Lalu: pindahkan semua teks yang tampil ke pemain (juga label pembaca layar, nama level di `chapter1-2.json` lewat id level, nama babak, kostum, kartu aturan, tutorial, petunjuk, caption fase jalan dan putar ulang, arah layar `Direction.label`) ke berkas terjemahan, usulan `flutter_localizations` + `gen-l10n` dengan ARB di `lib/l10n/`. Model Dart murni yang sekarang menyusun kalimat (`runCaption`, `replayCaptions`, `hintText`, `rules.dart`, dll.) jangan mengimpor Flutter: kembalikan data terstruktur atau terima objek teks, dan pakai bentuk jamak ICU (Rusia punya tiga bentuk: 1 шаг, 2 шага, 5 шагов). Bahasa awal = bahasa HP kalau didukung, selain itu Inggris; pilihan pemain (termasuk "Ikuti bahasa HP") disimpan lewat `ProgressStore`. Terjemahan ditulis dengan nada santai dan jenaka yang sama; aturan tetap "turns clockwise" dan sejenisnya, bukan "turns right"; caption memakai arah layar. Fredoka tidak punya huruf Sirilik: pasang Nunito tebal sebagai `fontFamilyFallback` gaya Fredoka supaya teks Rusia tidak jatuh ke font sistem. Layar Pengaturan (rute baru, usulan `/pengaturan`; desain belum ada, buat dengan gaya kartu dan sheet yang ada, cek lewat potret layar, catat): Bahasa (lima pilihan), Lihat tutorial lagi (tutorial level 1, 3, 6 muncul lagi), Reset progres dengan konfirmasi (hapus bintang, koin, kostum, petunjuk, dan tutorial; jatah bonus harian/iklan dan bahasa tetap), Tentang (versi app, kredit font, `showLicensePage`). Sakelar musik/efek suara dan bagian Privasi baru ditambah di langkah 16 dan 17; jangan pasang tempat kosong. Test: bahasa awal mengikuti HP dan jatuh ke Inggris, pilihan tersimpan, reset menghapus yang disepakati dan tidak menghapus sisanya, bentuk jamak Rusia, tidak ada teks yang ketinggalan di ARB mana pun (semua kunci ada di keempat bahasa). Test lama boleh tetap berbahasa Indonesia dengan memasang locale `id` di helper; `overflow_test.dart` dijalankan untuk keempat bahasa (Rusia dan Portugis biasanya paling panjang) dan rute Pengaturan ditambahkan. Potret layar per bahasa untuk Beranda, fase atur, dan Pengaturan. Perbarui aturan teks di `CLAUDE.md` (bagian pembuka dan "Aturan penting") dan baris Bahasa di GDD.

## 16. Musik dan efek suara ✅

**Hasil:** game punya musik latar dan efek suara, dan keduanya bisa dimatikan terpisah di Pengaturan.

Selesai: efek suara dari bunyi CC0 (Kenney dan OpenGameArt, dibuat ulang lewat `tool/audio/make_sfx.py`) dan dua lagu buatan sendiri (`tool/audio/make_music.py`: lagu Beranda dan lagu level, berganti dengan crossfade), pemutaran lewat `SoundPlayer` (`audioplayers`; `FakeSoundPlayer` di test) dan `GameAudio`, sakelar Musik dan Efek suara di bagian pertama Pengaturan (tersimpan, tidak ikut reset progres), musik dijeda di latar belakang dan selama iklan (`pauseDuringAds`), kredit di Tentang dan halaman Lisensi, galeri `/galeri/suara` untuk mendengar semuanya. Desain dan rencana di `docs/superpowers/`; sumber tiap berkas dan momen yang bersuara di `docs/DESIGN_NOTES.md` bagian "Langkah 16". Langkah 17 tinggal membungkus iklan asli dengan `audio.pauseDuringAds`.

> Tanyakan dulu ke pemilik repo: sumber audio (berkas milik sendiri, atau pustaka CC0/bebas royalti yang boleh dipakai komersial seperti Kenney untuk efek suara; lisensi tiap berkas dicatat dan kreditnya masuk bagian Tentang di Pengaturan) dan suasana musik yang diinginkan (satu lagu untuk semua layar, atau beda untuk Beranda/peta dan level). Lalu: musik latar berulang dan efek suara untuk momen penting, usulan: angkat dan taruh benda, benda kembali ke baki, Oyen bangun, makan ikan, kaget air, masuk kardus, gelas jatuh, "PRANG!" vas pecah, bintang muncul di layar Berhasil, Oyen bosan, koin bertambah, tombol. Usulan paket `flame_audio` atau `audioplayers`. Sakelar Musik dan Efek suara di Pengaturan, tersimpan lewat `ProgressStore`, default menyala. Musik berhenti saat aplikasi ke latar belakang atau iklan diputar, dan lanjut sesudahnya. Pemutaran lewat antarmuka (seperti `RewardedAds`) dengan implementasi palsu, supaya test tidak memutar suara dan bisa memeriksa suara mana yang diminta. Test: sakelar mematikan musik/efek dan tersimpan, efek dipicu di momen yang benar (fase jalan per `StepKind`, layar hasil), musik berhenti di latar belakang. Berkas audio dibuat kecil (OGG/MP3 terkompresi) dan ukurannya dicek. Catat sumber dan lisensi di `docs/DESIGN_NOTES.md`.

## 17. Polish dan rilis Android ✅

**Hasil:** app bundle release yang siap diunggah ke Play Console.

Selesai: `applicationId` `com.gingerlogic.app` dan versi 1.0.0, signing release dari `android/key.properties` (keystore di luar repo, cadangan debug key), ikon launcher adaptif dan ikon tema dari kepala Oyen bermata ngantuk di latar krem, splash tema Android (Android 12+ dan cadangan lama) dengan logo dan tagline per bahasa, iklan berhadiah AdMob asli untuk petunjuk dan koin (dua unit, rating maksimum G, tidak ditandai untuk anak) dengan persetujuan UMP sebelum SDK dinyalakan, bagian Privasi di Pengaturan (kebijakan privasi dan "Atur persetujuan iklan"), dokumen toko di `docs/store/` (listing empat bahasa, kebijakan privasi, ikon 512, feature graphic, potret ponsel per bahasa, panduan rilis), dan temuan kecil review langkah 13 dan 14. Gambar dibuat ulang dengan `test/screenshots/brand_test.dart`. **ID AdMob asli belum ditempel** (masih ID uji Google): lihat `docs/store/README.md` sebelum rilis produksi. Desain dan rencana di `docs/superpowers/`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 17".

> Baca dulu `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 15" (keputusan iklan dan target audiens). Tanyakan dulu ke pemilik repo: `applicationId` final (sekarang `com.example.kucing_oren`), ID aplikasi AdMob dan ID unit iklan berhadiah (pemilik repo sudah punya akun AdMob dan Play Console; build debug memakai ID uji Google), dan di mana kebijakan privasi akan dihosting (mis. GitHub Pages). Lalu: nama app "Ginger Logic" dari langkah 15 (sama di semua bahasa; judul listing toko boleh ditambah subjudul per bahasa), ikon launcher dan splash dari palet desain (belum ada desainnya: mulai dengan brainstorming, cek lewat potret layar, catat), iklan berhadiah asli (`google_mobile_ads`) menggantikan `FakeRewardedAds` (dipakai petunjuk dan iklan koin), iklan **tidak** ditandai untuk anak (keputusan pemilik repo; target audiens Play Console 13+), formulir persetujuan iklan (UMP, ikut `google_mobile_ads`) sebelum iklan pertama di wilayah yang mewajibkan, bagian Privasi di Pengaturan (tautan kebijakan privasi, "Atur persetujuan iklan" kalau UMP memintanya), draf kebijakan privasi dan teks toko (judul, deskripsi singkat dan panjang) dalam keempat bahasa di `docs/store/`, signing release dengan keystore di luar repo, dan `flutter build appbundle`. Centang daftar "Isi versi pertama" di GDD. Bereskan juga temuan kecil review langkah 13: di `buyCostume` simpan kostum dulu baru koin supaya kegagalan menguntungkan pemain; `unawaited(...)` untuk `buyCostume`/`wearCostume` di `ClosetScreen`; hitungan tinggi pratinjau Lemari Kostum (`rest`) yang mengulang jarak Column dan faktor 1,25; koin label harga kartu kostum memakai garis 2,4 seperti desain 12 (sekarang `coinPlainSvg` 2); komentar dokumentasi yang lewat 80 kolom di `progress_scope.dart`, `test_helpers.dart`, dan `level_sheet.dart`. Temuan kecil review langkah 14: chip koin Lemari Kostum (`KoCoinChipStyle.outlined`) tidak bergerak saat ditekan; chip koin yang bisa ditekan kehilangan `liveRegion` (saldo baru tidak diumumkan pembaca layar); tombol bonus harian di `coin_sheet.dart` membuang `Future` (`unawaited(progress.claimDailyBonus())`); `showLevelSheet`/`LevelSheet`/`SheetButton` sudah dipakai di luar layar level, pindahkan dari `lib/screens/level/` ke tempat bersama; jumlah iklan rusak di `rewards.daily` dibaca 0 (lebih ketat: anggap jatah habis).

## 18. Pengerasan iklan dan rilis ✅

**Hasil:** iklan berhadiah dan build release tahan terhadap kasus tepi yang ditemukan review langkah 17, tanpa mengubah perilaku yang sudah dites.

Selesai: hadiah yang datang sampai 400 ms sesudah iklan ditutup tetap diberikan, batas pengaman tampil 10 menit, iklan yang diminta selagi SDK menyala menunggu SDK dalam batas 10 detik, pemuat atau SDK yang melempar sinkron tidak membuat muatan macet, callback muat AdMob dijaga `isCompleted`, formulir persetujuan tidak terbuka dua kali, splash Android 12+ berlatar krem, `flutter build appbundle` tanpa `android/key.properties` gagal dengan pesan jelas, dan test `GameAds` untuk `gather` lambat. Rencana di `docs/superpowers/plans/2026-10-28-ad-hardening.md`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 18".

> Baca dulu `docs/DESIGN_NOTES.md` bagian "Langkah 17", `lib/app/admob_ads.dart`, `lib/app/admob_sdk.dart`, `lib/app/ad_consent.dart`, `test/app/admob_ads_test.dart`, dan API `google_mobile_ads` versi terpasang di pub cache. Bereskan temuan kecil review langkah 17 (PR #19), masing-masing dengan test yang gagal dulu kalau perilakunya bisa diuji: (1) hadiah yang datang sesudah iklan ditutup hilang: di `_present` (`admob_ads.dart`) tunggu sebentar (usulan 300–500 ms) sesudah `onClosed` sebelum menyelesaikan dan `dispose`, dan selesaikan true langsung kalau hadiah datang di jeda itu (penting kalau nanti memakai mediasi); (2) `Completer` di `loadAdMobRewarded` (`admob_sdk.dart`) dijaga `isCompleted` di `onAdLoaded` dan `onAdFailedToLoad`; (3) `_startLoad` macet selamanya kalau pemuat melempar secara sinkron (`_loading` tidak pernah kembali null): simpan future di variabel lokal dan kosongkan hanya kalau `identical`, test dengan pemuat yang melempar sinkron; (4) `show()` tanpa batas atas kalau SDK tidak pernah memanggil ditutup/gagal tampil: beri batas pengaman panjang supaya `_showing` dan `_watchingAd` tidak tertahan selama sesi; (5) `show()` langsung gagal selama beberapa detik `MobileAds.initialize()` berjalan sesudah persetujuan: tunggu SDK yang sedang dinyalakan dalam batas `loadTimeout`; (6) `values-v31/styles.xml` `LaunchTheme` belum punya `windowBackground`, jadi pembukaan yang melewati splash sistem sempat putih: tambahkan `@drawable/launch_background` atau `@color/cream` (perbarui `android_project_test`); (7) tombol "Atur persetujuan iklan" yang diketuk cepat dua kali membuka formulir dua kali: jaga dengan penanda sedang terbuka di `UmpAdConsent.showPrivacyOptions` atau di Pengaturan; (8) peringatan Gradle "Ginger Logic: ..." hanya terlihat dengan `-v`: buat `bundleRelease` gagal dengan pesan jelas kalau `android/key.properties` tidak ada (`assembleRelease` dan `flutter run --release` tetap boleh memakai debug key), lalu perbarui `docs/store/README.md` dan `android_project_test`; (9) komentar usang di `lib/app/rewarded_ads.dart` yang masih menyebut iklan palsu sampai langkah rilis; (10) test `GameAds` untuk `gather()` yang lambat sementara persetujuan sesi lalu sudah memberi tahu lebih dulu (SDK menyala sekali, iklan bisa dimuat sebelum `gather` selesai). Jangan mengubah ID iklan, alur persetujuan, atau teks pemain di luar yang disebut. Catat keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 18".

## 19. Saran lama dari PR sebelumnya ✅

**Hasil:** saran "di luar lingkup" dari PR langkah 4–17 yang masih terbuka di kode dibereskan atau diputuskan, dicek ulang 20 Okt 2026 (yang sudah selesai di langkah lain tidak dimasukkan).

Selesai: benda bisa ditaruh, dipindah, dan dikembalikan lewat pembaca layar tanpa seret (slot baki dan 63 petak bersemantik, pengumuman, aksi "Kembalikan ke baki"), chip Langkah hanya diumumkan saat dijeda atau selesai, nama bahasa bertag locale, judul level rata kiri, kembali sistem di fase jalan dan layar hasil ke fase atur, simpanan yang gagal tidak melempar dan dicoba lagi dengan urutan yang memihak pemain, bunyi sakelar efek dibalik, tap tumpuk dihapus, dan pool efek disiapkan di awal. Cache `Picture` papan diputuskan tidak perlu (diukur ≈ 0,24 ms per bingkai). Rencana di `docs/superpowers/plans/2026-10-28-saran-lama.md`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 19".

> Baca dulu `docs/DESIGN_NOTES.md` dan bagian "Saran di luar lingkup" di PR yang disebut (`gh pr view <nomor>`). Sebelum mengubah, pastikan saran itu masih berlaku di kode sekarang; kalau sudah beres, tulis di PR dan lewati. Kerjakan dengan test yang gagal dulu kalau perilakunya bisa diuji: (1) **Aksesibilitas** (PR #6, #7, #17): cara menaruh, memindah, dan mengambil benda tanpa seret untuk pembaca layar (usulan: aksi semantik di slot baki dan petak; mulai dengan `superpowers:brainstorming` karena belum ada desainnya, teks baru di keempat ARB); chip "Langkah" di fase jalan (`liveRegion` di `run_panel.dart`) diumumkan tiap langkah pada 4 langkah per detik, batasi (mis. hanya saat dijeda, maju satu langkah, atau selesai); baris pilihan bahasa di Pengaturan diberi tag bahasa untuk pembaca layar (`attributedLabel` dengan `LocaleStringAttribute`) supaya "Русский" tidak dibacakan dengan suara Inggris. (2) **Tampilan** (PR #7): judul level di bar atas tampil di tengah karena `FittedBox` (`level_bar.dart`), sedangkan desain 03/04 rata kiri; samakan dengan desain. (3) **Navigasi** (PR #8): tombol kembali sistem di fase jalan dan layar hasil sekarang keluar ke peta babak, sedangkan tombol kembali di layar (desain 04) kembali ke fase atur; samakan supaya kembali sistem di fase jalan = kembali ke fase atur, dan putuskan perilakunya di layar hasil. (4) **Simpanan** (PR #9, #12): penyimpanan yang gagal (I/O) tidak diberi tahu dan error-nya bisa lolos dari `ProgressController`; tangani tanpa crash (keadaan di memori tetap, coba lagi atau pesan kecil); koin dan petunjuk (juga koin dan hadiah harian) ditulis ke dua kunci terpisah lewat `Future.wait`, jadi aplikasi yang mati di antaranya bisa kehilangan salah satu; urutkan supaya kegagalan menguntungkan pemain (seperti `buyCostume`) atau gabungkan. (5) **Kinerja** (PR #5): papan Flame menggambar ulang 63 petak tiap bingkai; rekam bagian statis ke `Picture` sekali dan gambar ulang hanya saat isinya berubah, ukur dulu di profil supaya tidak mengoptimasi yang tidak lambat. (6) **Suara** (PR #18): sakelar Efek suara berbunyi saat dimatikan dan senyap saat dinyalakan, balik; beberapa tombol berbunyi tumpuk (tap + bunyinya sendiri: Bangunkan Oyen, Kosongkan, bonus harian), pilih satu; bunyi pertama tiap efek mungkin telat karena `AudioPool` dibuat saat pertama dipakai, buat pool di awal (atau `PlayerMode.lowLatency`) dan cek di HP. Tombol putar otomatis, `Tile.copyWith`, cek terjemahan, dan jarak huruf Material ada di langkah 20. Catat keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 19".

## 20. Sisa saran: putar otomatis, terjemahan, dan rapi-rapi kecil ✅

**Hasil:** saran PR lama yang tidak masuk langkah 19 diputuskan dan dikerjakan.

Selesai: tombol putar otomatis di putar ulang (kiri slider, 0,7 detik per langkah, berhenti di akhir, dihentikan slider dan tombol langkah, tidak tampil saat kurangi gerak), berkas tinjauan terjemahan `docs/translations/` untuk penutur asli Inggris, Portugis Brasil, dan Rusia (belum ada masukan), `Tile.copyWith(clearGhost:)`, dan jarak huruf Material yang ternyata masih bocor ke teks (diperbaiki di tema, dijaga test). Rencana di `docs/superpowers/plans/2026-10-28-sisa-saran.md`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 20".

> Baca dulu `docs/DESIGN_NOTES.md`, `lib/screens/replay/`, dan bagian "Saran di luar lingkup" di PR yang disebut (`gh pr view <nomor>`). Pastikan tiap saran masih berlaku di kode sekarang sebelum mengubah. Kerjakan dengan test yang gagal dulu kalau perilakunya bisa diuji: (1) **Putar otomatis di putar ulang** (PR #10): desainnya belum ada. Mulai dengan `superpowers:brainstorming` bersama pemilik repo (tombol putar/jeda di `ReplayControls`, kecepatan, berhenti di langkah terakhir, perilaku saat slider digeser, kurangi gerak), buat dengan gaya kontrol fase jalan (desain 04), cek lewat potret layar, tambahkan ke `overflow_test`, teks baru di keempat ARB, dan catat. Test: maju sendiri per langkah, berhenti di akhir, jeda, slider menghentikan putar otomatis, pembaca layar. (2) **Terjemahan oleh penutur asli** (PR #17): siapkan berkas tinjauan untuk pemilik repo, mis. `docs/translations/review-<bahasa>.md` berisi setiap kunci ARB, teks Inggris, teks bahasa itu, dan deskripsinya, plus listing toko di `docs/store/`, supaya bisa dikirim ke penutur asli Inggris, Portugis Brasil, dan Rusia. Tanyakan dulu ke pemilik repo apakah sudah ada masukan; kalau ada, terapkan ke ARB dan listing (nada santai dan jenaka, aturan "turns clockwise", caption memakai arah layar), jalankan `flutter gen-l10n` dan `overflow_test`. (3) **`Tile.copyWith` tidak bisa menghapus `ghost`** (PR #12): tambahkan cara menghapusnya (mis. `clearGhost` atau nilai sentinel) dengan test, hanya kalau masih belum bisa. (4) **Jarak huruf Material 0,25** (PR #8): dicek 20 Okt 2026 sudah tidak terjadi (`letterSpacing` gaya teks tema null); tambahkan test di `test/theme/` yang menjaga teks tanpa gaya eksplisit tidak mendapat jarak huruf bawaan Material, supaya tidak kembali. Catat keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 20".

## Sebelum langkah 21: desain rumah Oyen

Pemilik repo memutuskan langkah 21–26 saat brainstorming 26 Okt 2026. Desainnya dibuat di Claude Design dan diterima 28 Okt 2026. Langkah ini dikerjakan sesudah langkah 18–20.

Sumber utama:
- `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md`: aturan, angka, model data, dan daftar berkas desain. Bagian "Perubahan 28 Oktober" menjelaskan Peci/Sarung yang dihapus, Lemari Kostum yang diganti Aksesoris, dan animasi.
- `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 21".
- Desain: `docs/design/rumah-oyen/project/*.dc.html`.

**Desainnya diambil dari link kanvas** yang tercantum di spesifikasi.
- Kalau folder desain belum ada, unduh dulu lewat alat Artifact: aksi `read` dengan `paths` semua berkas `project/*` dan `out_dir` `docs/design/rumah-oyen`.
- Kalau link tidak bisa dibuka, berhenti sebelum bercabang dan beri tahu pemilik repo.

**Kalau desain bertentangan dengan spesifikasi:**
- Tampilan, teks, dan harga ikut desain.
- Aturan yang tidak tampak di desain ikut spesifikasi.
- Catat keputusannya di `docs/DESIGN_NOTES.md`.

## 21. Rumah Oyen: model kamar, kucing, aksesoris, makanan, dan kebutuhan ✅

**Hasil:** data dan aturan rumah Oyen tersedia sebagai Dart murni yang tersimpan dan teruji: barang, kucing koleksi, aksesoris, camilan, tata letak, kebutuhan, mangkuk, dan hadiah. Belum ada layar baru.

Selesai: katalog (`home_items.dart`, `kitties.dart`, `accessories.dart`, `snacks.dart`), `Room`, `Home` (`home.state`), `HomeNeeds` (`home.needs`), aksi rumah di `ProgressController`, dan 10 iklan koin per hari. Rencana di `docs/superpowers/plans/2026-10-28-rumah-oyen-model.md`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 21".

> **Baca dulu:**
> - spesifikasi rumah Oyen bagian Kebutuhan dan hadiah, Aksesoris, Toko, Koin, dan Model data
> - skrip katalog di `Toko.dc.html` dan `Kamar.dc.html` desain
> - `lib/game/model/costumes.dart` dan `lib/game/model/rewards.dart`
> - `ProgressController`, `ProgressStore`/`PrefsProgressStore`/`MemoryProgressStore`, dan `test/app/progress_test.dart`
>
> **Lalu buat:**
> - **Katalog** dengan harga dari desain:
>   - 20 barang: zona lantai/dinding, cara dipakai, posisi bawaan
>   - kucing koleksi: Oyen + 8
>   - 16 aksesoris: harga, kelangkaan, jangkar
>   - 5 camilan: Lapar dan Senang menurut spesifikasi, beserta `Pantry`
> - **`Room`**: barang dimiliki, posisi barang yang ditaruh (pecahan 0–1), dan Gudang.
> - **`AccessoryCloset`**: aksesoris dimiliki, dan yang dipakai per kucing. Satu kucing satu aksesoris. Aksesoris yang sama boleh dipakai beberapa kucing.
> - **`CatNeeds`**:
>   - Lapar habis dalam 12 jam, Senang dalam 16 jam. Keduanya turun mengikuti jam, juga saat aplikasi ditutup. Jam mundur tidak menaikkan bar.
>   - Elus +10, paling banyak +30 per jam.
>   - Main +10, paling banyak sekali per 30 menit.
>   - Selesai menghias +5, paling banyak sekali per jam.
> - **`Bowl`**: satu isi tiap 4 jam; tiap kucing boleh makan sekali per isi (+40).
> - **Hadiah**: 10 koin per kucing per hari kalender, kalau kedua bar ≥ 70.
> - **Simpanan**:
>   - Semua `toJson`/`fromJson` membuang entri rusak.
>   - Kunci baru lewat `ProgressStore`: `home.state` (satu JSON untuk barang, tata letak, kucing, aksesoris, dan stok) dan `home.needs`.
> - **`ProgressController`**:
>   - `home`, `needs`
>   - `buyItem`/`buyKitty`/`buyAccessory`/`buySnack` → `Future<bool>`. Gagal tanpa efek, dua ketukan tidak membayar dua kali, dan barang disimpan sebelum koin.
>   - `wearAccessory`, `placeItem`, `storeItem`, `feed`, `pet`, `play`, `finishDecorating`, `eatFromBowl`, `claimKittyReward`
>   - `resetProgress` juga menghapus barang, kucing, aksesoris, stok, dan tata letak. Bar Oyen kembali 100; hari hadiah tetap.
> - **`maxAdsPerDay` jadi 10.** Sesuaikan teks "Sisa N kali hari ini" dan test koin tambahan, lalu tambahkan catatan di `docs/DESIGN_NOTES.md` bagian langkah 14.
>
> Kostum lama dan Lemari Kostum masih dibiarkan; keduanya dihapus di langkah 23. Belum ada layar dan teks baru di langkah ini, kecuali yang dibutuhkan test.
>
> **Test:**
> - katalog dan harga sama dengan desain
> - beli, koin kurang, dua ketukan, simpanan rusak
> - aksesoris dipakai beberapa kucing, ganti, lepas, dan aksesoris yang tidak dimiliki dibuang saat dibaca
> - kebutuhan turun per jam dan berhenti di 0; jam mundur
> - mangkuk per isi
> - hadiah sekali sehari, dan tertahan saat jam mundur
> - batas elus dan batas menghias
> - reset
> - `maxAdsPerDay` 10
>
> Perbarui bagian "Struktur" di `CLAUDE.md`.

## 22. Toko dan aksesoris ✅

**Hasil:** layar Toko di rute `/toko` untuk membeli barang, kucing, aksesoris (dengan pratinjau langsung), dan camilan dengan koin.

Selesai: sprite kucing kamar (`kitty.dart`, `kitty_painter.dart`: 9 kucing, 12 pose, 16 aksesoris, tanpa gerakan), gambar barang dan camilan (`room_item_art.dart`), ikon aksesoris, layar `lib/screens/shop/` dengan empat tab plus `showBuySheet`, tombol Toko sementara di Beranda, galeri `/galeri/kucing`, dan teks katalog di keempat ARB. Rencana di `docs/superpowers/plans/2026-10-28-toko-aksesoris.md`; keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 22".

> **Baca dulu:**
> - spesifikasi rumah Oyen bagian Toko dan Aksesoris
> - desain `Toko.dc.html`, `TabToko`, `KartuToko`, `SheetBeli`, `ChipKoin`, `IkonAksesoris`, `Kucing.dc.html` (sprite, warna, aksesoris), `AksesorisPreview.dc.html`, `Barang.dc.html`, dan artboard `Toko*.dc.html`
> - `lib/screens/closet/` (pola layar beli), `lib/screens/coins/`, dan `lib/widgets/ko_sheet.dart`
>
> **Lalu buat:**
> - **Gambar**: salin `<svg>` dari desain ke `lib/game/render/` lewat `SvgTemplate`. Jangan diketik ulang.
>   - Sprite kucing kamar dibuat sebagai fungsi `Canvas` yang menerima kucing, pose, arah, aksesoris, dan waktu animasi. Bagian sprite (kepala, mata, ekor) tetap terpisah, karena langkah 24 menganimasikannya.
>   - Gambar aksesoris mengikuti jangkar di semua pose.
>   - Buat juga ikon aksesoris, barang (diam), dan camilan, beserta widget pembungkusnya.
> - **Layar Toko**:
>   - bar atas: kembali, judul, chip koin yang membuka sheet Tambah Koin
>   - empat tab
>   - kartu dengan keadaan sesuai desain
>   - tab Aksesoris dengan pratinjau langsung: pilih kucing yang dimiliki dan aksesorisnya; tombol beli atau pakai
>   - sheet konfirmasi lewat `showKoSheet`, keadaan koin kurang, dan keadaan sukses ("Lihat di kamar" untuk barang/kucing, "Milikmu selamanya" untuk aksesoris)
> - **Tombol sementara**: tambahkan tombol Toko ke Beranda lama dengan gaya tombol menu yang ada, dan catat. Tombol ini diganti di langkah 23. Sampai langkah 23, "Lihat di kamar" menuju Beranda.
> - **Teks baru** di keempat ARB, lalu `flutter gen-l10n`. Nama dan deskripsi lewat `lib/l10n/names.dart`.
> - **`overflow_test`**: tambahkan `/toko` bersaldo 99999 untuk keempat tab, pratinjau aksesoris, dan sheet konfirmasi.
> - **Galeri dan potret layar**: tampilkan sprite dan aksesoris di galeri (`/galeri`), dan buat potret layar Toko.
>
> **Test:**
> - tab
> - beli dengan konfirmasi, koin kurang, dua ketukan
> - stok camilan bertambah
> - pratinjau aksesoris tidak membeli
> - pakai aksesoris yang dimiliki
> - pembaca layar
> - test gambar: aksesoris digambar di jangkarnya untuk beberapa pose (warna piksel di koordinat desain, seperti `test/game/render/`)
>
> Perbarui bagian "Struktur" di `CLAUDE.md`.

## 23. Kamar Oyen sebagai Beranda, tanpa Lemari Kostum

**Hasil:** Beranda berubah jadi kamar Oyen. Barang yang dibeli tampil dan bisa ditata bebas, kucing tampil dan bisa diketuk, aksesoris bisa diganti dari kartu kucing, dan Lemari Kostum beserta kostum lama hilang.

> **Baca dulu:**
> - spesifikasi rumah Oyen bagian Kamar, "Perubahan 28 Oktober", dan Aksesoris (bagian "Di puzzle")
> - desain `Kamar.dc.html` beserta artboard `Kamar*.dc.html`, `TombolHias`, `BakiGudang`, `BarKebutuhan`, `TandaLesu`, `GelembungKoin`, `BarangKamar.dc.html`, dan catatan `n360` di `canvas.json`
> - `lib/screens/home/`, `lib/screens/closet/`, `lib/game/render/oyen.dart` (`OyenCostume`), dan `lib/screens/level/` (pola seret)
> - `test/screens/home_chapter_test.dart`, `navigation_test.dart`, dan test kostum yang disebut di `CLAUDE.md`
>
> **Lalu, untuk kamar:**
> - **Isi `HomeScreen`** di rute `/` diganti kamar sesuai desain:
>   - logo dan chip koin
>   - tombol Main/Toko/Aksesoris/Pengaturan; Aksesoris membuka `/toko` di tab Aksesoris
>   - keadaan pemain baru
>   - tombol Toko sementara dari langkah 22 dilepas
> - **Area dinding dan lantai** dari ruang yang tersisa, ukuran 360×640 sampai 412×915, teks 130%. Ikuti catatan `n360`.
> - **Barang dan kucing**:
>   - barang yang ditaruh digambar di posisinya, urut menurut y
>   - kucing dalam pose diam dengan aksesorisnya, di tempat acak yang tetap
>   - mangkuk bawaan
> - **Ketuk kucing** membuka kartu kucing sesuai desain:
>   - bar, Elus
>   - panel Camilan, yang memberi camilan dari stok
>   - panel Aksesoris: pasang/lepas lewat `wearAccessory`, dan "Toko aksesoris →"
>   - reaksi teks dan hati
> - **Mode hias**:
>   - tombol Hias
>   - seret bebas di dalam zonanya; lepas ke Gudang; ketuk di Gudang untuk menaruh
>   - Selesai menyimpan lewat `placeItem`/`storeItem`/`finishDecorating` dan menampilkan pujian
> - **"Lihat di kamar"** dari Toko kini menuju kamar.
>
> **Lalu, hapus Lemari Kostum dan kostum lama:**
> - rute `/kostum`, `lib/screens/closet/`, `costumes.dart`/`Wardrobe`, `OyenCostume`, prop `costume`/`dressed`
> - kostum di papan, putar ulang, layar hasil, dan tutorial; Oyen di area puzzle tampil tanpa aksesoris
> - kunci `costume.*` (dibuang saat dibaca), dan teks kostum di keempat ARB
> - test kostum: yang masih relevan diganti test aksesoris
> - gambar Peci dan Sarung, termasuk di `design_svg.dart` dan galeri
>
> Kucing berjalan, animasi, gelembung hadiah, dan jam mangkuk dikerjakan di langkah 24, kecuali yang dibutuhkan test.
>
> **Teks baru** di keempat ARB.
>
> **`overflow_test`**:
> - kamar kosong
> - kamar penuh: 20 barang dan 9 kucing beraksesoris
> - mode hias
> - kartu kucing dengan panel Camilan dan Aksesoris
> - semuanya bersaldo 99999
> - `/kostum` dihapus dari daftar rute
>
> **Potret layar** Beranda per bahasa diperbarui.
>
> **Test:**
> - barang tampil di posisinya
> - seret di dalam zona, dan tidak bisa keluar zona
> - Gudang
> - tata letak tersimpan sesudah aplikasi dibuka ulang
> - ganti aksesoris dari kartu
> - navigasi dari kamar (`navigation_test` disesuaikan)
> - `/kostum` tidak ada lagi
> - pembaca layar
>
> Catat di `docs/DESIGN_NOTES.md` bagian "Langkah 23", dan perbarui bagian "Struktur" di `CLAUDE.md`.

## 24. Kamar hidup: animasi, rutinitas, kebutuhan, dan hadiah

**Hasil:**
- Kucing di kamar berkedip, mengibaskan ekor, dan bernapas.
- Kucing berjalan sendiri ke barang lalu memakainya.
- Barang ikut bergerak.
- Lapar dan Senang mengikuti jam.
- Kucing yang dirawat memberi hadiah koin.

> **Baca dulu:**
> - spesifikasi rumah Oyen bagian Kamar hidup, dan Kebutuhan dan hadiah
> - desain `AnimasiKucing.dc.html` (angka animasi dan rutinitas), `Kucing.dc.html` (pose dan bagian yang dianimasikan), `Barang.dc.html` (barang dipakai dan bergerak), dan `Kamar.dc.html` (rutinitas dan reaksi)
> - `lib/game/model/run_clock.dart`, `lib/game/model/sounds.dart`, `lib/app/game_audio.dart`, dan `tool/audio/`
>
> **Lalu buat:**
> - **Animasi sebagai fungsi waktu**, dengan angka dari desain 21c: kedip, ekor, napas, jalan 2 bingkai, makan, main, garuk, dielus, senang, plus akuarium, bola, catnip, dan jam.
> - **Rutinitas kamar sebagai Dart murni**:
>   - keadaan per kucing: diam, jalan, memakai barang, makan di mangkuk, lesu, bereaksi
>   - tujuan acak berbobot, dengan `Random` ber-seed
>   - satu barang tidak dipakai dua kucing sekaligus
>   - bola dan mangkuk disembunyikan saat dipakai; kardus, kasur, dan rak berganti keadaan "dipakai"
>   - dimajukan oleh satu jam kamar yang bisa diganti di test
> - **Jeda dan hemat**:
>   - rutinitas berhenti saat kartu terbuka, saat mode hias, dan saat reaksi berlangsung
>   - kucing di luar layar tidak dianimasikan
> - **Kurangi gerak**: semua loop berhenti, kucing diam di posenya.
> - **Kebutuhan dan hadiah**:
>   - kucing lapar menuju mangkuk
>   - gelembung hadiah dan tanda lesu
>   - jam isi ulang mangkuk
>   - reaksi saat dielus, diberi camilan, dan memasang aksesoris
> - **Animasi berhenti lewat `TickerMode`** saat layar lain menutupi kamar. Test kamar memakai `settle`; catat ini di `CLAUDE.md`, seperti denyut peta.
> - **Simpan kebutuhan** saat ada aksi dan saat aplikasi masuk ke latar belakang.
> - **Efek suara baru** dari sumber CC0 lewat `tool/audio/make_sfx.py`: dengkur, meong, makan, koin hadiah, beli, pasang aksesoris. Catat lisensinya, dan naikkan batas `audio_assets_test` seperlunya dengan alasan.
> - **Galeri** pose dan animasi.
> - **Teks baru** di keempat ARB.
> - **`overflow_test` dan potret layar** kamar dengan gelembung hadiah.
>
> **Test:**
> - nilai animasi pada waktu tertentu (mata tertutup di tengah kedip, sudut ekor)
> - rutinitas dengan seed: kucing mencapai barang lalu memakainya, dan tidak berebut
> - kebutuhan turun saat waktu dimajukan dan saat aplikasi dibuka lagi
> - makan dari mangkuk sekali per isi
> - camilan mengurangi stok
> - hadiah sekali sehari menambah koin
> - kurangi gerak
> - suara per aksi, dan efek suara yang dimatikan
>
> Catat di `docs/DESIGN_NOTES.md` bagian "Langkah 24", dan perbarui bagian "Struktur" di `CLAUDE.md`.

## 25. Peta bergambar dan Oyen berjalan ke level berikutnya

**Hasil:**
- Peta babak berupa ilustrasi ruangan, dengan titik level bergambar dan token Oyen.
- "Lanjut" memperlihatkan Oyen berjalan ke level berikutnya, lalu level itu terbuka.

> **Baca dulu:**
> - spesifikasi rumah Oyen bagian Peta bergambar
> - desain `PetaBergambar.dc.html`, `PetaDapur`, `PetaJalan`, `PetaPindah`, `TitikLevel`, dan `TokenOyenPeta`
> - `lib/screens/chapter/`, `MapArt` di `lib/game/render/`, dan `lib/screens/level/level_screen.dart` (`_next`)
> - `test/screens/home_chapter_test.dart`, `progress_flow_test.dart`, dan `navigation_test.dart`
>
> **Lalu buat:**
> - **`ChapterMap`** sesuai desain:
>   - ilustrasi Babak 1 dan Babak 2
>   - titik level bergambar dengan keadaan selesai, saat ini, dan terkunci
>   - bos di ujung peta
>   - token Oyen di level saat ini
>   - gulir awal menuju Oyen
> - **"Lanjut" sesudah menang**:
>   1. Kembali ke peta babak level id+1.
>   2. Oyen berjalan dari titik level tadi, sekitar 1 detik. Dengan kurangi gerak, Oyen langsung pindah.
>   3. Level id+1 terbuka sendiri.
>   4. Ketukan selama Oyen berjalan membatalkan pembukaan otomatis.
>
>   Ini juga berlaku untuk level lama yang diulang.
> - **Sesudah level 10**: peta Babak 2, Oyen di level 11, judul babak baru, tanpa buka otomatis.
> - **Sesudah level 20**: Oyen berdiri di bos, tanpa buka otomatis.
> - **"Main" dari kamar** hanya membuka peta.
> - **Teks baru** di keempat ARB.
> - **`overflow_test`**: peta kedua babak, termasuk saat Oyen berjalan.
> - **Potret layar** peta per bahasa.
>
> **Test:**
> - Lanjut biasa
> - pembukaan dibatalkan dengan ketukan
> - level lama
> - sesudah level 10 dan 20
> - kurangi gerak
> - label pembaca layar node
> - gulir awal
>
> Catat di `docs/DESIGN_NOTES.md` bagian "Langkah 25", dan perbarui bagian "Struktur" di `CLAUDE.md`.

## 26. Potret toko dan rapi-rapi rumah Oyen

**Hasil:**
- Listing Play Store, potret ponsel, feature graphic, dan dokumen memperlihatkan rumah Oyen.
- Temuan kecil review langkah 21–25 dibereskan.

> **Baca dulu:**
> - `docs/store/README.md` dan listing di `docs/store/`
> - `test/screenshots/`
> - GDD
> - bagian "Saran di luar lingkup" PR langkah 21–25 (`gh pr view <nomor>`)
>
> **Lalu:**
> - **Potret ponsel** per bahasa: tambahkan kamar penuh, Toko aksesoris dengan pratinjau, dan peta bergambar. Kamar tampil pertama.
> - **Feature graphic**: buat ulang kalau masih memakai Beranda lama atau Oyen berkostum.
> - **Listing toko** dalam empat bahasa: sebut kamar yang bisa dihias, kucing yang bisa diadopsi, dan aksesoris, dengan nada santai dan jenaka.
> - **GDD**:
>   - bagian Monetisasi menyebut aksesoris, bukan "Kostum Oyen: peci, sarung, ..."
>   - bagian Layar dan prompt Claude Design lama diberi catatan bahwa Lemari Kostum sudah diganti
>   - aturan main tidak berubah
> - **Data safety**: cek ulang.
> - **Saran kecil** dari PR 21–25 yang masih berlaku, masing-masing dengan test kalau bisa diuji.
> - **Jalankan ulang** `brand_test.dart` dan potret layar.
>
> Catat di `docs/DESIGN_NOTES.md` bagian "Langkah 26".
