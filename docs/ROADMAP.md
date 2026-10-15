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
- [ ] 4. Fondasi UI: token desain, font, komponen dasar
- [ ] 5. Gambar petak, papan, dan Oyen
- [ ] 6. Gameplay fase atur
- [ ] 7. Gameplay fase jalan
- [ ] 8. Hasil: berhasil, vas pecah, Oyen bosan
- [ ] 9. Beranda, peta babak, progres tersimpan
- [ ] 10. Putar ulang
- [ ] 11. Kartu aturan dan tutorial
- [ ] 12. Petunjuk dan koin
- [ ] 13. Lemari kostum
- [ ] 14. Polish dan rilis Android

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

## 4. Fondasi UI

**Hasil:** token desain, font, komponen dasar, kerangka app dengan rute galeri, dan perkakas test layar.

> Baca `docs/design/source/13-design-token-komponen-ui.html` (warna, tipografi, jarak, radius, bayangan, komponen) dan `01-beranda.html` untuk gaya umum. Buat `lib/theme/` dengan semua token dalam satu `ThemeExtension` (desain menulis "Nama token disiapkan untuk Flutter: satu ThemeExtension") dan gaya teks display, title, heading, number, body, label, overline (Fredoka 500–700, Nunito 600–800). Font dibundel sebagai aset, bukan diunduh saat aplikasi jalan. Komponen di `lib/widgets/`: tombol utama, sukses, sekunder, dan ikon (dengan efek tekan "press"), chip, slot baki, kartu. Kerangka app: `MaterialApp.router` + `go_router`, rute `/` sementara dan `/galeri` yang menampilkan semua komponen. Tidak ada warna atau ukuran hardcode di widget; tambah token kalau butuh nilai baru. Test: widget test komponen, test overflow semua rute di 360×640 sampai 412×915 dengan teks 130% (rute baru di langkah berikutnya ditambahkan ke test ini), dan potret layar `flutter test test/screenshots --dart-define=SCREENSHOTS=true` → `build/screenshots/390x844/*.png` dengan font asli, di-skip di test biasa. Pola yang sudah jalan bisa dicontoh dari repo `D:\Dev\personal\game\busy_network` (`lib/theme/`, `test/screens/overflow_test.dart`, `test/screenshots/`).

## 5. Gambar petak, papan, dan Oyen

**Hasil:** semua gambar papan dan Oyen dari desain tergambar di `Canvas` dan bisa dicek di galeri.

> Baca `docs/design/source/Tile.dc.html`, `Oyen.dc.html`, `Board.dc.html`, lalu halaman `14-sprite-oyen-arah-pose.html`, `15-elemen-papan.html`, `16-komponen-oyen.html`, `17-komponen-petak.html`. Port ketiga komponen ke `lib/game/render/` sebagai fungsi gambar `Canvas` murni yang bisa dipakai Flutter maupun Flame:
>
> - Petak 50×50: `kind` floor/wall/cupboard/shelf/fridge/bowl/table/tableGlass/tableVase/tableBroken, `item` none/fish/water/box/fishP/bucketP/boxP, `alt`, `glow`. Ikuti `renderVals()` persis.
> - Oyen (viewBox 100×100): `pose` idle/walk/sleep/shock/box/knock/eat/happy, `dir` down/left/right/up, `costume` none/peci/sarung/koki/kacamata, `bubble` none/zzz/kaget.
> - Papan 350×450 mengikuti `Board.dc.html`: `#` di baris 0 = [wall, cupboard, shelf, fridge, cupboard, shelf, wall], `#` di bagian dalam = cupboard, `#` lainnya = wall; lantai `alt` kalau (kolom + baris) ganjil; Oyen 62 px di (kolom·50 − 6, baris·50 − 12); panah arah hadap saat Oyen tidur; bingkai dan bayangan papan.
>
> Salin string `d` path SVG apa adanya lalu urai dengan `parseSvgPathData` dari package `path_drawing`; jangan menyalin ulang koordinat dengan tangan. Gelas yang sudah jatuh tidak punya gambar di desain: pakai `table` kosong dan catat. Tambahkan halaman petak dan Oyen (seperti halaman desain 14 dan 15) ke `/galeri`. Test: pemetaan peta → jenis petak untuk level 13 dan 18 (Dart murni) dan galeri tergambar tanpa error. Sebelum PR, ambil potret galeri dan periksa hasilnya dengan membandingkan angka di file desain.

## 6. Gameplay fase atur

**Hasil:** layar level bisa dibuka; pemain bisa menaruh, memindah, dan mengembalikan benda.

> Baca `docs/design/source/03-gameplay-fase-atur.html`, `18-komponen-papan-7x9.html`, dan GDD bagian "Alur satu level" serta "Pembagian komponen Flame". Tambah `flame` (busy_network memakai `flame: ^1.38.2` dengan versi Flutter yang sama). Buat `KucingGame` (`FlameGame`) dengan kamera beresolusi tetap 350×450 (koordinat papan desain), lalu `BoardComponent` dan `CatComponent` yang menggambar lewat `lib/game/render/`. Layar `/level/:id` memuat level lewat `loadLevels()` dan memakai `LevelSession`: bar atas (kembali, "Level 13 · Vas Ibu", target bintang 3 "pakai N benda", tombol Aturan yang belum berfungsi), papan dengan Oyen tidur + Zzz + panah arah hadap, baki dengan angka sisa, petunjuk "Taruh di petak yang menyala", dan tombol "Bangunkan Oyen". Seret benda dari baki ke papan: petak yang boleh diisi menyala (`glow`) dan benda menempel ke petak. Benda di papan bisa diseret ke petak lain atau kembali ke baki. Logika tetap di `LevelSession`; komponen Flame hanya menerjemahkan sentuhan ke koordinat petak. "Bangunkan Oyen" cukup memanggil `wake()` dan menampilkan hasil sementara berupa teks; animasinya di langkah 7. Test: widget test menyeret benda (buat helper seret ke petak), penolakan petak tidak sah, angka baki berubah. Tambah rute ini ke test overflow.

## 7. Gameplay fase jalan

**Hasil:** Oyen bergerak langkah demi langkah mengikuti `SimResult.trace`.

> Baca `docs/design/source/04-gameplay-fase-jalan.html` (termasuk daftar `steps` dan caption-nya), `16-komponen-oyen.html`, dan GDD bagian "Alur satu level". Setelah "Bangunkan Oyen", mainkan `trace` satu langkah demi satu langkah: 4 langkah per detik sesuai GDD (desain memakai transisi 0,35 detik; ikuti GDD dan catat), tombol ×2, Jeda/Lanjutkan, penghitung "Langkah N", status vas dan jumlah benda dipakai seperti desain. Pose per `StepKind`: `walk` → walk; `scared` → shock + gelembung kaget (desain menampilkan kaget masih menghadap air, sedangkan `SimStep.dir` adalah arah sesudah putar balik); `turn` → idle dengan arah baru; `enterBox`/`sit` → box; `knockGlass`/`knockVase` → knock (gelas jatuh jadi meja kosong, vas jadi `tableBroken`); `eat` → eat dan ikannya hilang. Kardus hilang pada langkah `sit` yang punya `changed`. Langkah terakhir di mangkuk memakai pose seperti desain. Gelembung pikiran bergambar ikan saat `SimStep.chasing` tidak null disebut di GDD tapi tidak ada di desain: buat dengan gaya gelembung kaget dan catat. Selesai → tombol "Lihat hasil" (layar hasil di langkah 8; sementara kembali ke fase atur). Kalau `MediaQuery.disableAnimations`, langsung ke keadaan akhir. Test: urutan pose dan posisi untuk solusi level 13 dan level 15 (kardus), keadaan papan akhir, jeda, dan ×2.

## 8. Hasil: berhasil, vas pecah, Oyen bosan

**Hasil:** ketiga layar hasil tersambung ke fase jalan dan fase atur.

> Baca `docs/design/source/06-hasil-berhasil.html`, `07-hasil-vas-pecah.html`, `08-gagal-oyen-bosan.html`, dan GDD bagian "Bintang". Buat ketiga layar dengan teks persis seperti desain. Berhasil: animasi bintang, jumlah langkah, benda dipakai, penjelasan bintang, Ulangi/Lanjut, dan "Tonton putar ulang" (nonaktif sampai langkah 10). Vas pecah: "Sampai sih... tapi vas Ibu?", "Pecah di langkah N" dari `vaseBrokenAtStep`, Coba Lagi/Lanjut Saja. Oyen bosan untuk `FailReason.loop`; desain belum punya teks untuk `FailReason.tooManySteps` (kelamaan), jadi buat teks santai yang senada dan catat. Atur Lagi → fase atur dengan susunan tetap; Ulangi → papan kosong; Lanjut → level berikutnya. Angka bintang dari `LevelSession`. Test untuk level 13: solusi JSON (berhasil, 3 bintang), ikan saja di (2,4) ("Pecah di langkah 2", 10 langkah, 1 benda, sama dengan contoh desain), tanpa benda (Oyen bosan). Tambah rute ke test overflow.

## 9. Beranda, peta babak, progres tersimpan

**Hasil:** game bisa dimainkan dari Beranda sampai level 20, dan progres tidak hilang.

> Baca `docs/design/source/01-beranda.html`, `02-peta-babak-2-ruang-tamu.html`, dan GDD bagian "Babak 1" serta "Babak 2". Beranda: logo, Oyen tidur, total bintang `x/60`, tombol Main, Lemari Kostum dan Pengaturan (belum berfungsi). Peta babak: desain hanya punya Babak 2 – Ruang Tamu; buat Babak 1 – Dapur (level 1–10, bos "Pesta Ikan Asin") dengan tata letak dan gaya yang sama, lalu catat. Tiap level menampilkan 0–3 bintang; level terkunci pudar dengan gembok; level saat ini menonjol; level bos lebih besar. Progres (bintang terbaik per level) disimpan lokal dengan `shared_preferences` di balik antarmuka kecil supaya mudah diuji. Level n+1 terbuka setelah level n menang (aturan ini belum ada di GDD; catat). Sambungkan Beranda → Peta → Level → Hasil → Lanjut atau kembali ke Peta. Test: simpan dan muat progres, buka kunci, total bintang, alur navigasi. Tambah rute ke test overflow.

## 10. Putar ulang

**Hasil:** pemain bisa memutar ulang langkah Oyen maju dan mundur.

> Baca `docs/design/source/09-putar-ulang.html` (slider, mundur/maju satu langkah, jejak langkah bernomor, garis jalur, caption per langkah). Bangun ulang keadaan papan di tiap langkah dari `SimResult.trace` (barang jatuh, ikan dimakan, kardus penyok) tanpa menjalankan ulang simulasi. Caption dibuat dari `StepKind` dengan arah layar (atas, bawah, kiri, kanan) dan bahasa santai seperti contoh caption di desain 04 dan 09; teks aturan tetap memakai "berputar searah jarum jam". Putar ulang dibuka dari layar Berhasil ("Tonton putar ulang") dan Oyen bosan ("Putar Ulang"). Test: keadaan papan di langkah 0, tengah, dan akhir untuk level 13 dan 15; caption untuk tiap `StepKind`.

## 11. Kartu aturan dan tutorial

**Hasil:** tombol Aturan membuka kartu aturan sesuai yang sudah dipelajari, dan level pengenalan punya tutorial.

> Baca `docs/design/source/05-kartu-aturan-oyen.html`, `11-tutorial-level-1.html`, dan kolom "Hal baru" di tabel level GDD. Kartu aturan (bottom sheet dari tombol Aturan) berisi lima kartu urut seperti desain. Kartu terbuka saat pemain sudah membuka level yang memperkenalkannya: tembok/meja di level 2, ikan di level 3, air di level 6, jatuhkan barang di level 12, kardus di level 14 (desain menampilkan kartu kardus masih "???", cocok untuk pemain yang baru sampai level 13 seperti layar contoh lainnya). Tutorial level 1 berupa overlay seperti desain, dengan teks persis. Desain 11 memakai peta dan nama level 1 versi lama ("Halo, Oyen"); pakai data level 1 dari JSON dan ambil gaya serta teks overlay-nya saja. GDD juga meminta tutorial level 3 (ikan) dan level 6 (ember) yang belum ada desainnya: buat dengan gaya yang sama dan teks pendek yang santai, lalu catat. Status tutorial selesai disimpan. Test: kartu terkunci/terbuka per level, tutorial hanya muncul sekali.

## 12. Petunjuk dan koin

**Hasil:** tiga tingkat petunjuk bisa dibuka dengan iklan berhadiah (palsu dulu) atau koin.

> Baca `docs/design/source/10-petunjuk.html` dan GDD bagian "Petunjuk". GDD belum mengatur cara pemain mendapat koin: tanyakan ke pemilik repo di awal sesi sebelum menulis kode, lalu catat jawabannya. Tiga tingkat dibuka berurutan: (1) sorot petak benda pertama, (2) tunjukkan jenis benda untuk petak itu, (3) tampilkan solusi bintang 3 lengkap. Sumbernya `level.solution`, yang di langkah 2 sudah terbukti termasuk solusi minimum. Tiap tingkat dibuka dengan "Tonton iklan" atau koin, dengan harga persis seperti desain. Iklan lewat antarmuka `RewardedAds` dengan implementasi palsu yang selalu berhasil; SDK iklan asli dipasang di langkah 14. Koin dan petunjuk yang sudah terbuka disimpan per level. Test: urutan buka tingkat, koin berkurang, petunjuk tampil di papan.

## 13. Lemari kostum

**Hasil:** kostum bisa dibeli dengan koin dan dipakai Oyen.

> Fitur ini tidak ada di daftar "Isi versi pertama" GDD, tapi tombolnya ada di Beranda dan desainnya sudah jadi. Baca `docs/design/source/12-lemari-kostum.html` dan `14-sprite-oyen-arah-pose.html`. Grid kostum (peci, sarung, koki, kacamata) dengan pratinjau Oyen, harga koin persis desain, beli, pakai, dan simpan pilihan. Oyen di papan dan di layar hasil memakai kostum terpilih (gambar Oyen dari langkah 5 sudah mendukung `costume`). Test: beli, pakai, koin tidak cukup.

## 14. Polish dan rilis Android

**Hasil:** app bundle release yang siap diunggah ke Play Console.

> Tanyakan dulu ke pemilik repo: `applicationId` final (sekarang `com.example.kucing_oren`), ID AdMob, dan isi layar Pengaturan (GDD dan desain belum mengaturnya; minimal reset progres). Lalu: nama app "Kucing Oren", ikon launcher dan splash dari palet desain, layar Pengaturan, iklan berhadiah asli (`google_mobile_ads`) menggantikan implementasi palsu dari langkah 12, signing release dengan keystore di luar repo, dan `flutter build appbundle`. Centang daftar "Isi versi pertama" di GDD.
