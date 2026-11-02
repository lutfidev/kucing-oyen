# Peta Bergambar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (sesuai `CLAUDE.md`: rencana dijalankan di sesi utama). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Peta babak diganti ilustrasi ruangan (desain 23) dengan node bergambar dan token Oyen. "Lanjut" sesudah menang membuka peta, memperlihatkan Oyen berjalan ke level berikutnya, lalu level itu terbuka sendiri.

**Architecture:**
- **Geometri dan gambar** (titik, kurva jalur, posisi di kurva, SVG desain) ada di `lib/game/render/`, Dart tanpa widget.
- **Linimasa jalan** (jeda → jalan → diam → buka; batal) adalah model Dart murni `MapWalk` di `lib/game/model/`, diuji per waktu seperti `RunClock`.
- **`ChapterView`** memegang satu `Ticker` yang memajukan `MapWalk`, menggambar token di posisi kurva, memasang lapisan penangkap sentuhan, dan memanggil `onPlay` sekali.
- **Rute** membawa `?dari=<id>&baru=1`, yang dihitung `LevelScreen._next`.

**Tech Stack:** Flutter, `go_router`, `SvgTemplate` (render sendiri), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-02-peta-bergambar-design.md` (induk: `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md`, "Peta bergambar"). Desain: `docs/design/rumah-oyen/project/{PetaBergambar,PetaDapur,PetaJalan,PetaPindah,TitikLevel,TokenOyenPeta}.dc.html`.

## Global Constraints

- Isi `<svg>` desain disalin utuh ke `lib/game/render/design_svg_home.dart`, jangan diketik ulang. Nilai `{{...}}` diisi `SvgTemplate`.
- Tidak ada warna atau ukuran hardcode di widget: tambah token di `KoColors`/`KoSize`. Warna di dalam SVG desain boleh tetap di SVG.
- Semua teks pemain ada di keempat ARB (`app_en.arb` template dengan deskripsi, lalu `id`, `pt`, `ru`). Jalankan `flutter gen-l10n`. Teks Indonesia mengikuti desain: "Babak baru terbuka!", "Ayo masuk!", "10 level baru · Bos: Hari Lebaran".
- Label pembaca layar node tidak berubah: `levelNodeLabel` "Level {id}, {status}" dan `bossNodeLabel`. Test lama yang mencari label ini harus tetap lulus.
- Titik desain 23: `[[86, 262], [200, 236], [306, 282], [300, 378], [190, 404], [84, 446], [96, 546], [206, 574], [306, 612], [196, 724]]`.
- Ukuran:
  - node 66, bos 100, ikon 46/74, chip nomor 26, gembok 28, bintang 17, label bos jarak 12
  - token 64×76, sprite 56 di (4, 12), token di titik + (18, −92)
  - ruang atas peta 56
  - n360: node 54, bos 84, jarak vertikal antartitik 88%
- Waktu (`MapWalk`):
  - `delay` 0,3 detik
  - `walkTime` 1,0 detik dengan kurva `easeInOut`
  - `rest` 0,25 detik
  - kurangi gerak: tanpa jalan, buka sesudah 0,6 detik
- Jejak kaki: t 0,38/0,62, geser ±5, opacity 0,95 sebelum level saat ini (`i < curIdx`), selain itu 0,35.
- Animasi: denyut node dan jalan Oyen mati lewat `TickerMode` dan `MediaQuery.disableAnimations`. Test yang menampilkan peta memakai `settle`, bukan `pumpAndSettle`.
- Selesai = `flutter analyze` bersih dan `flutter test` hijau (`/check`).

## Review Focus

1. **Lanjut dari dalam aplikasi**: `ChapterView` sudah terpasang di bawah rute level (rute bersarang). Jadi `?dari=` datang lewat `didUpdateWidget`, bukan `initState`. Jalan harus mulai dan gulir harus menuju token di jalur ini. Ini dites di Task 5 lewat alur menang → Lanjut, bukan hanya `pumpApp(location: '/babak/2?dari=12')`.
2. **Layar ditutup di tengah jalan** (kembali sistem, atau ganti rute): `Ticker` dan buka otomatis berhenti, dan `onPlay` tidak pernah dipanggil sesudahnya. Ini dites di Task 4.
3. **Buka dua kali**: `onPlay` dipanggil tepat sekali, juga kalau Ticker masih jalan beberapa bingkai sesudah waktunya. Pemain juga tidak bisa mengetuk node selama jalan. Ini dites di Task 2 dan Task 4.
4. **Query rusak**, misalnya `dari=abc`, `dari=99`, `dari` dari babak lain, atau `dari` level terakhir babak: diabaikan, tanpa jalan dan tanpa crash. Ini dites di Task 5.
5. **Teks 130% dan layar 360×640**: header lebih tinggi, tapi token tidak tertutup saat gulir awal, dan kartu pindah babak tidak terpotong. Ini dites di Task 6 (`overflow_test` dan cek posisi token di `home_chapter_test`).

---

### Task 1: Gambar peta dari desain 23 (SVG, titik, kurva)

**Files:**
- Modify: `lib/game/render/design_svg_home.dart` (konstanta SVG baru)
- Create: `lib/game/render/picture_map_art.dart` (ekspor lewat `render.dart`)
- Test: `test/game/render/picture_map_art_test.dart`, `test/game/render/design_sync_test.dart` (grup baru di `isi SVG sama dengan desain rumah Oyen`)

**Interfaces:**
- Produces, SVG:
  - `mapKitchenDecorSvg` (isi `sc-if isDapur`), `mapLivingDecorSvg` (isi `sc-if isTamu`)
  - `mapBossAreaSvg` (dua `rect` area bos)
  - `mapRoadSvg` (dua `path` dengan `{{roadD}}`), `mapPawSvg` (isi `<svg>` jejak, viewBox −10 −12 20 20)
  - `mapNodeIconSvgs` (`Map<String, String>` 20 kunci desain, isi tiap `sc-if b.<kunci>`, viewBox 48)
  - `mapNodeLockSvg`, `mapTokenBaseSvg` (dua elips `TokenOyenPeta`)
  - `chapterIntroConfettiSvg`, `chapterIntroDoorSvg`, `chapterIntroPawsSvg` (kartu pindah)
- Produces, `abstract final class PictureMapArt`:
  - `points` (`List<Offset>`, titik desain 23), `mapTop` 140, `topPad` 56
  - `objects1`/`objects2` (`List<String>` kunci `D1`/`D2` urut level), `objectOf(Level level)` → kunci
  - `pawSteps` [0,38, 0,62], `pawSide` 5, `pawOpacity` 0,95, `pawDimOpacity` 0,35
  - `tokenSize` Size(64, 76), `tokenSprite` 56, `tokenSpriteAt` Offset(4, 12), `tokenOffset` Offset(18, −92)
  - `compactRowFactor` 0,88
  - `static List<Offset> pointsFor({required bool compact})`: y dirapatkan ke arah titik pertama
  - `static Path roadPath(List<Offset> pts)` dan `static String roadD(List<Offset> pts)`: kurva desain, kontrol c1 = p1 + (p2 − p0)/6, c2 = p2 − (p3 − p1)/6, ujung diulang
  - `static Offset onRoad(List<Offset> pts, int segment, double t)`: titik bezier kubik segmen itu pada t 0–1
- Produces, gambar: `paintMapDecor(Canvas, int chapter)`, `paintMapBossArea`, `paintMapRoad(Canvas, List<Offset>)`, `paintNodeIcon(Canvas, String object, {required double size})` (cache per kunci, seperti `kittyDrawing`), `paintTokenBase`.

- [ ] **Step 1: Write failing tests**

  `picture_map_art_test.dart`:
  - `points` sama dengan 10 titik di Global Constraints.
  - `roadD(points)` diawali `'M86 262 C'`, dan segmen pertama `'C105.0 257.7 163.3 232.7 200 236'` (hitung dari rumus desain dengan `toFixed(1)`).
  - `onRoad(points, 1, 0) == points[1]`, `onRoad(points, 1, 1) == points[2]`, dan `onRoad(points, 1, 0.5)` tidak di garis lurus (jaraknya ke tengah segmen > 0,5).
  - `objectOf(level 13) == 'rakTV'`, `objectOf(level 10) == 'pestaIkanAsin'`, `objectOf(level 20) == 'ketupat'`.
  - `pointsFor(compact: true)[9].dy == 262 + (724 − 262) * 0.88`, dan x-nya tetap.
  - Piksel: `paintNodeIcon` untuk `kulkas` di kanvas 46 tidak transparan di tengah.

  `design_sync_test.dart`, grup `PetaBergambar.dc.html dan TitikLevel.dc.html`:
  - Setiap SVG baru, baris per baris, ada di berkas sumbernya (pola `linesIn`).
  - `mapNodeIconSvgs.keys` sama dengan daftar `list` di `TitikLevel`.
  - Sumber berisi `const pts = [...]` yang sama dengan `PictureMapArt.points`, `[0.38, 0.62].forEach`, dan `(i < curIdx ? 0.95 : 0.35)`.
  - `tx = p[0] + 18; ty = p[1] - 92;` ada di sumber.
- [ ] **Step 2: Run** `flutter test test/game/render/picture_map_art_test.dart test/game/render/design_sync_test.dart` → FAIL (simbol belum ada).
- [ ] **Step 3: Implement.** Salin SVG dari berkas desain. `roadPath` membangun `Path` dari kontrol yang sama dengan `roadD`, dan jalur digambar lewat `SvgTemplate(mapRoadSvg).render({'roadD': roadD(pts)})`. Kalau `SvgTemplate` belum mengurai `C` di atribut `d`, tambahkan dan beri test di `svg_template_test`.
- [ ] **Step 4: Run** perintah yang sama → PASS.
- [ ] **Step 5: Commit** `feat(render): picture map art from design 23`.

### Task 2: `MapWalk`, linimasa Oyen berjalan

**Files:**
- Create: `lib/game/model/map_walk.dart`
- Test: `test/game/model/map_walk_test.dart`

**Interfaces:**
- Produces:
  - `class MapWalk { MapWalk({required bool autoOpen, required bool still}); }`
  - `static const delay = 0.3, walkTime = 1.0, rest = 0.25, stillWait = 0.6`
  - `void tick(double seconds)`
  - `double get t`: posisi di segmen 0–1 sesudah `Curves.easeInOut` (rumusnya disalin supaya tetap Dart murni). Nilainya 1 sejak awal kalau `still`.
  - `bool get walking`: dalam jendela jalan dan tidak `still`.
  - `bool get arrived`
  - `bool takeOpen()`: true tepat sekali, saat waktu ≥ `delay + walkTime + rest` (atau ≥ `stillWait` kalau `still`), `autoOpen`, dan belum `cancel`.
  - `void cancel()`, `bool get cancelled`
  - `bool get done`: sampai, dan buka sudah diambil atau tidak akan terjadi. Ticker boleh berhenti.

- [ ] **Step 1: Write failing tests**
  - Pada 0,2 detik: `t == 0` dan `!walking`.
  - Pada 0,8 detik: `t == 0.5` (tengah easeInOut) dan `walking`.
  - Pada 1,3 detik: `t == 1` dan `arrived`, tapi `takeOpen()` false.
  - Pada 1,55 detik: `takeOpen()` true, lalu false di pemanggilan kedua dan sesudah `tick` berikutnya.
  - `cancel()` pada 0,5 detik: jalan tetap selesai (`t == 1` pada 1,3), `takeOpen()` tidak pernah true, dan `done` pada 1,3.
  - `autoOpen: false`: tidak pernah buka, dan `done` saat sampai.
  - `still: true`: `t == 1` sejak 0 dan `takeOpen()` true pada 0,6. Dengan `cancel` sebelum itu, tidak pernah.
  - `tick` dengan dt besar (5 detik sekaligus) tetap membuka sekali.
- [ ] **Step 2: Run** `flutter test test/game/model/map_walk_test.dart` → FAIL.
- [ ] **Step 3: Implement** `MapWalk` (field waktu berjalan dan `_opened`).
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(model): map walk timeline`.

### Task 3: Node bergambar dan token Oyen

**Files:**
- Create: `lib/screens/chapter/map_node.dart` (`PictureNode`), `lib/screens/chapter/map_token.dart` (`MapToken`)
- Modify: `lib/screens/chapter/chapter_map.dart` (`LevelNode`/`BossNode` diganti `PictureNode`; `NodeState`, `LevelNode.labelOf`, dan `_Pulse` tetap dipakai), `lib/theme/` (token `KoSize.pictureNode` 66, `pictureBoss` 100, `pictureNodeCompact` 54, `pictureBossCompact` 84, `nodeIcon` 46, `bossIcon` 74, `nodeChip` 26, `nodeLock` 28; warna node dari desain: latar selesai `#FFFBF3`, saat ini `#FFF4E2`, terkunci `#E8D6B8`, garis terkunci `#CDB48C`, bayangan terkunci `#D5BE98`, chip terkunci `#8A7259`; pakai token yang sudah ada kalau nilainya sama)
- Test: `test/screens/map_node_test.dart`

**Interfaces:**
- Consumes: `paintNodeIcon`, `PictureMapArt.objectOf`, `paintTokenBase` (Task 1), `NodeState`, `LevelNode.labelOf`, `bossNodeLabel`, `KittyView`.
- Produces:
  - `PictureNode({required Level level, required bool boss, required Chapter chapter, required NodeState state, required int stars, required VoidCallback onPressed, bool compact = false})`. Bentuk desain `TitikLevel`: badge bulat (bos kotak radius 30), ikon benda (pudar abu-abu kalau terkunci), chip nomor di kiri bawah, gembok di kanan atas kalau terkunci, denyut dan label "Main" (`l.play`) kalau saat ini, bintang kalau selesai, label "Bos · nama" (`l.bossTag`) di bawah bos. Ketuk node terbuka memanggil `onPressed` lewat `KoPressable`.
  - `static double sizeOf(BuildContext, {required bool boss, required bool compact})`
  - `MapToken({required KittyPose pose, required KittyFacing facing, AccessoryId? accessory, double? time})`: kotak 64×76, alas + `KittyView` Oyen, dibungkus `ExcludeSemantics`.

- [ ] **Step 1: Write failing tests** (`testApp`):
  - Node level 13 saat ini: label semantik `Level 13, main sekarang`, teks `Main` ada, dan ketuk memanggil `onPressed`.
  - Node terkunci: `Level 14, terkunci`, ketukan tidak memanggil apa-apa, dan gembok tampil.
  - Node selesai 2 bintang: `Level 12, 2 bintang`, dengan dua bintang terisi.
  - Bos: label `bossNodeLabel` sama dengan sebelumnya, dan teks `Bos · Hari Lebaran` ada.
  - `sizeOf` 66/100, dan compact 54/84.
  - `disableAnimations`: cincin denyut tidak tampil.
  - `MapToken` tidak punya semantik dan berukuran 64×76.
- [ ] **Step 2: Run** `flutter test test/screens/map_node_test.dart` → FAIL.
- [ ] **Step 3: Implement** kedua widget dari desain `TitikLevel`/`TokenOyenPeta`.
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(chapter): picture level node and Oyen token`.

### Task 4: Peta bergambar dan jalan Oyen di `ChapterView`

**Files:**
- Modify: `lib/screens/chapter/chapter_map.dart` (`ChapterMap` digambar ulang), `lib/screens/chapter/chapter_screen.dart` (`ChapterView`), `lib/screens/chapter/chapter_header.dart` (kalau pudar header perlu disesuaikan)
- Delete: `_Floor` dan `_BossArea` lama, plus konstanta `MapArt` peta lama yang tidak dipakai lagi (`points`, `pawSteps`, dan lain-lain). Gambar Beranda/ikon babak yang masih dipakai tetap. Perbarui test `design_sync` desain 02 yang menunjuk konstanta itu.
- Test: `test/screens/home_chapter_test.dart` (diperbarui dan ditambah grup `Oyen berjalan`)

**Interfaces:**
- Consumes: Task 1–3, `MapWalk`.
- Produces:
  - `ChapterMap({required Chapter chapter, required Progress progress, required ValueChanged<Level> onPlay, required MapTokenSpot? token, bool compact = false})`. Ukurannya `Size(390, 844 − mapTop + topPad)`, dan semua titik digeser `(0, topPad − mapTop)`.
  - `static Offset pointOf(int index, {bool compact})`.
  - `MapTokenSpot({required Offset at, KittyPose pose, KittyFacing facing})`, dengan `at` = titik pijakan (titik node) di koordinat peta.
  - `ChapterView` mendapat `int? walkFrom`, `bool chapterIntro`, `AccessoryId? oyenAccessory` (penambahan untuk Task 5).
  - `ChapterView.tokenIndexOf(Chapter, Progress, {int? walkFrom})`:
    - `walkFrom` sah (level babak ini, bukan bos) → indeksnya + 1.
    - Kalau tidak, indeks `progress.current`.
    - Babak selesai → bos.
    - Babak terkunci → null.

  Perilaku:
  - Latar per babak:
    - Dapur: `#F5EBDD` dengan kotak 56 px `rgba(143,211,240,0.22)`.
    - Ruang Tamu: `mapFloor` dengan garis papan yang sudah ada.
    - Urutan gambar: dekor → area bos → jalur → jejak → node → token.
  - Gulir awal: tengah tempat peta = titik pijakan token − 40 (tengah tubuh token).
  - Jalan:
    - Kalau `walkFrom` sah dan bukan bos, `MapWalk(autoOpen: !accessibleNavigation, still: disableAnimations)` dimulai.
    - Token di `onRoad(points, walkFrom index, walk.t)`. Pose `KittyLook.walkPose(time)` selama `walking`, selain itu idle. Hadap kanan/kiri menurut tanda dx segmen.
    - Selama `!walk.done && autoOpen`, `Positioned.fill` `Listener(onPointerDown: cancel, behavior: opaque)` menutupi seluruh layar, termasuk header.
    - `PopScope` membatalkan jalan saat kembali.
    - `takeOpen()` → `onPlay(level berikutnya)`.
    - Saat sampai dan `accessibleNavigation`: `SemanticsService.announce(l.mapOyenArrived(id))`.
  - Sesudah level 20 (`walkFrom` = bos babak terakhir): token di bos dengan pose `happy`, tanpa `MapWalk`.
  - `didUpdateWidget`: `walkFrom` baru → jalan baru dan gulir menuju token (`jumpTo`). `walkFrom` jadi null → jalan dihentikan, token kembali ke `progress.current`.
  - `TickerMode` mati → Ticker diam, dan waktu tidak maju.

- [ ] **Step 1: Write failing tests** (`home_chapter_test`; peta dibuka dengan `pumpApp(location: '/babak/2?dari=12', progress: testProgress(wonUpTo(12)))` sesudah Task 5, atau sementara dengan `ChapterView` langsung):
  - Test lama yang mencari label node tetap lulus, dan cek jejak kaki/skala diperbarui ke titik desain 23.
  - Token ada di atas node level saat ini. Kiri token = x node + 18 − 32 (skala 1).
  - Gulir awal: token terlihat di bawah header, di 390×844 dan 360×640.
  - Dengan `walkFrom: 12`: pada +0,8 detik token ada di antara node 12 dan 13 (bukan di salah satunya), pada +1,3 detik di node 13, dan pada +1,6 detik `onPlay` dipanggil sekali dengan level 13.
  - Ketuk pada +0,5 detik di atas node 12: `onPlay` tidak pernah dipanggil, termasuk untuk level 12. Token tetap sampai di 13.
  - Kembali sistem pada +0,5 detik: `onPlay` tidak dipanggil. Widget dibuang di tengah jalan: tidak ada error, dan tidak ada panggilan sesudahnya.
  - `disableAnimations`: token langsung di 13, dan `onPlay` pada +0,6 detik.
  - `accessibleNavigation`: tidak ada `onPlay` sesudah 3 detik. Pengumuman `Oyen sampai di level 13.` ada di `tester.takeAnnouncements()`, dan node 13 masih bisa diketuk.
  - `walkFrom: 20` di Babak 2 yang selesai: token di bos, tanpa `onPlay`.
  - Babak 1 berlatar dapur (warna piksel di pojok kosong peta = `#F5EBDD`), dan Babak 2 berlatar papan.
- [ ] **Step 2: Run** `flutter test test/screens/home_chapter_test.dart` → FAIL.
- [ ] **Step 3: Implement** perilaku di atas.
- [ ] **Step 4: Run** → PASS. Jalankan juga `test/screens/navigation_test.dart`, yang harus tetap hijau.
- [ ] **Step 5: Commit** `feat(chapter): picture map with walking Oyen`.

### Task 5: Rute, "Lanjut", dan kartu "Babak baru terbuka!"

**Files:**
- Modify: `lib/app/routes.dart`, `lib/app/router.dart`, `lib/screens/chapter/chapter_screen.dart`, `lib/screens/level/level_screen.dart` (jadi `StatefulWidget` yang mencatat `isWon` saat dibuka)
- Create: `lib/screens/chapter/chapter_intro.dart` (`ChapterIntroCard`)
- Modify: `lib/l10n/app_{en,id,pt,ru}.arb`, lalu `flutter gen-l10n`
- Test: `test/screens/progress_flow_test.dart`, `test/screens/navigation_test.dart`, `test/screens/chapter_intro_test.dart`

**Interfaces:**
- Produces:
  - `AppRoutes.chapter(int number, {int? from, bool intro = false})` → `/babak/n`, `/babak/n?dari=12`, atau `/babak/2?dari=10&baru=1`. `musicFor` tidak berubah.
  - Router: `ChapterScreen(chapter:, walkFrom: int.tryParse(dari), intro: baru == '1')`.
  - `ChapterScreen` meneruskan `walkFrom` hanya kalau level itu ada di babak ini dan bukan bos babak itu. Pengecualiannya level terakhir permainan, yang diteruskan ke "token di bos". Dia juga meneruskan `oyenAccessory: controller.home.closet.wearingOf(KittyId.oyen)`.
  - `LevelScreen._next`:
    - Ada level berikutnya di babak yang sama → `AppRoutes.chapter(level.chapter, from: level.id)`.
    - Level bos dan ada babak berikutnya → `AppRoutes.chapter(next.chapter, intro: !wonWhenOpened)`.
    - Level terakhir → `AppRoutes.chapter(level.chapter, from: level.id)`.
  - `ChapterIntroCard({required Chapter chapter, required VoidCallback onClose})`: desain 23c, yaitu lapis krem 0,72, konfeti, kartu dengan overline, judul `chapterTitle`, gambar pintu dengan `KittyView` Oyen jalan kanan 112, `l.chapterIntroInfo(count, bossName)`, dan tombol `l.chapterIntroEnter`. Kartu ditutup lewat tombol, ketuk latar, atau `PopScope`. Animasi `pbSlide` 0,4 detik, dan tanpa animasi saat `disableAnimations`. Semantik `l.chapterIntroLabel` sebagai dialog (`scopesRoute`, `namesRoute`).
  - ARB baru:
    - `chapterIntroOverline` "Babak baru terbuka!"
    - `chapterIntroEnter` "Ayo masuk!"
    - `chapterIntroInfo` "{count, plural, other{{count} level baru}} · Bos: {boss}"
    - `chapterIntroLabel` "Babak baru terbuka"
    - `mapOyenArrived` "Oyen sampai di level {id}."
    - Bentuk Rusia memakai tiga bentuk jamak.

- [ ] **Step 1: Write failing tests**
  - `progress_flow_test`:
    - **Menang level 1 → Lanjut**: `ChapterView` tampil, `LevelView` tidak. Sesudah ±1,6 detik (`pumpFor`), `Level 2 · Belok Kanan` tampil sendiri. Kembali ke peta: token di level 2.
    - **Level lama**: dengan `wonUpTo(8)`, main level 3 → Lanjut → level 4 terbuka sendiri. Kembali ke peta: token di level 9.
    - **Dibatalkan**: Lanjut, lalu ketuk pada +0,5 detik. Sesudah 3 detik tetap di peta, dan node 2 `main sekarang`.
    - **Sesudah level 10 pertama kali**: peta Babak 2, `Babak baru terbuka!` tampil, dan token di level 11. Sesudah 3 detik tidak ada level yang terbuka. "Ayo masuk!" menutup kartu.
    - **Level 10 diulang** (`wonUpTo(10)`): tanpa kartu.
    - **Sesudah level 20**: peta Babak 2, token di bos, tanpa level terbuka sesudah 3 detik. Ini mengganti dua test lama "Lanjut sesudah ...".
  - `navigation_test`:
    - "Main" dari kamar membuka peta tanpa jalan, dan tidak ada level terbuka sesudah 3 detik.
    - `/babak/1?dari=abc`, `/babak/1?dari=99`, `/babak/1?dari=15`, dan `/babak/1?dari=10` membuka peta tanpa jalan dan tanpa error.
  - `chapter_intro_test`: isi teks per bahasa (`lookupAppLocalizations`), cara menutup (tombol, latar, kembali sistem), dan tanpa animasi saat kurangi gerak.
- [ ] **Step 2: Run** ketiga berkas → FAIL.
- [ ] **Step 3: Implement** rute, `_next`, kartu, dan ARB. Jalankan `flutter gen-l10n` dan `test/l10n/`.
- [ ] **Step 4: Run** ketiga berkas dan `test/l10n` → PASS.
- [ ] **Step 5: Commit** `feat: Lanjut walks Oyen to the next level`.

### Task 6: Layar kecil, overflow, galeri, dan potret

**Files:**
- Modify: `lib/screens/chapter/chapter_screen.dart` (`compact` = tinggi layar < `roomCompactHeight`), `test/screens/overflow_test.dart`, `test/screenshots/` (potret peta per bahasa), `lib/gallery/gallery_screen.dart` (`PictureNode` tiga keadaan + bos, dan `MapToken`, kalau galeri menampilkan node lama)
- Test: `test/screens/overflow_test.dart`, `test/screens/home_chapter_test.dart`

- [ ] **Step 1: Write failing tests**
  - `home_chapter_test`: di 360×640, node berukuran 54 dan jarak y node 1→10 = (724 − 262) × 0,88 × skala.
  - `overflow_test` per bahasa, 360×640 sampai 412×915, teks 100%/130%:
    - `/babak/1` dan `/babak/2`
    - `/babak/2?dari=12` pada +0,8 detik (sedang jalan)
    - `/babak/2?baru=1` (kartu pindah tampil)
  - Teks Rusia dan Portugis pada kartu pindah tidak terpotong.
- [ ] **Step 2: Run** → FAIL untuk ukuran compact.
- [ ] **Step 3: Implement** `compact`. Potret: tambah `chapter1`/`chapter2` ke `test/screenshots` per bahasa (pola Beranda), lalu cek gambarnya dengan mata terhadap desain 23a/23d.
- [ ] **Step 4: Run** `flutter test test/screens/overflow_test.dart test/screens/home_chapter_test.dart` → PASS, dan `flutter test test/screenshots --dart-define=SCREENSHOTS=true` menghasilkan PNG peta.
- [ ] **Step 5: Commit** `test: picture map overflow and screenshots`.

### Task 7: Dokumen dan verifikasi akhir

**Files:**
- Modify:
  - `docs/DESIGN_NOTES.md`: bagian "Langkah 25" berisi keputusan [saya] dari spesifikasi, ditambah yang muncul saat membangun.
  - `CLAUDE.md` "Struktur": `PictureMapArt`, `MapWalk`, `PictureNode`, `MapToken`, `ChapterIntroCard`, `AppRoutes.chapter(n, from:, intro:)`, dan test baru. Hapus yang sudah dibuang (`_Floor`, `MapArt.points`).
  - `docs/ROADMAP.md`: langkah 25 dicentang dan bertanda ✅.
  - `docs/translations/`: `python tool/translations/make_review.py`.

- [ ] **Step 1:** `/check` (format, `flutter analyze` → `No issues found!`, `flutter test` hijau, termasuk solusi ke-20 level).
- [ ] **Step 2:** Review lewat `superpowers:requesting-code-review` (satu subagent, effort high), lalu `superpowers:receiving-code-review`, dan perbaiki temuannya.
- [ ] **Step 3:** `superpowers:verification-before-completion`, lalu commit `docs: step 25 notes, roadmap, structure`.
- [ ] **Step 4:** `git push -u origin feat/peta-bergambar` dan `gh pr create --base main`. Judul `feat: Peta bergambar dan Oyen berjalan ke level berikutnya`, badan PR sesuai `CLAUDE.md`.
