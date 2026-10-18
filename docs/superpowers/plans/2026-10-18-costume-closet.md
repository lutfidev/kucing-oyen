# Lemari Kostum Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (CLAUDE.md: rencana dijalankan di sesi utama) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Layar Lemari Kostum (`/kostum`) untuk membeli dan memakai kostum Oyen dengan koin, tersimpan di perangkat, dan Oyen berkostum di papan, putar ulang, layar hasil, dan tutorial.

**Architecture:** Model Dart murni `Wardrobe` (milik + dipakai, aturan beli) di `lib/game/model/costumes.dart`; `ProgressController` memegang `Wardrobe` dan menyimpannya lewat `ProgressStore`. Layar baru di `lib/screens/closet/`. Kostum dioper sebagai parameter `costume` dari `LevelScreen` ke `LevelView` → `ResultView`/`ReplayView`/tutorial, dan papan memakai `BoardScene.dressed(costume)`; simulasi dan `RunFrame` tidak tahu soal kostum.

**Tech Stack:** Flutter, Flame, go_router, shared_preferences (`SharedPreferencesAsync`), flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-18-costume-closet-design.md`

## Global Constraints

- Harga dan urutan persis desain 12: Polos 0, Peci 60, Sarung 90, Topi Koki 150, Kacamata 45.
- Label persis desain 12: "Dipakai", "Punyamu", harga; tombol "Sedang dipakai", "Pakai", "Beli · N koin", "Koin kurang · N".
- Tidak ada warna/ukuran hardcode di widget: pakai `context.koColors`/`koType`/`koSize`/`koSpace`/`koRadius`/`koShadow`, tambah token kalau perlu (warna desain 12 yang belum ada: cek dulu `KoColors`, mis. `#2BB5A0` teal, `#EFE3CF`, `#FFF1C9`, `#F7E8CE`).
- SVG lemari disalin utuh dari `docs/design/source/12-lemari-kostum.html` ke `design_svg.dart`, tidak diketik ulang.
- Model di `lib/game/model/` tanpa import Flutter/Flame (`render/oyen.dart` Dart murni, boleh diimpor untuk `OyenCostume`).
- Semua teks Bahasa Indonesia santai. Commit kecil, pesan Inggris, tanpa atribusi Claude.
- Selesai: `flutter analyze` → `No issues found!`, `flutter test` hijau.

## Review Focus

1. Ketuk "Beli" dua kali cepat → koin hanya terpotong sekali (Task 2: `buyCostume` dipanggil dua kali tanpa `await`).
2. Koin tepat sama dengan harga (45 untuk Kacamata) → boleh beli, saldo jadi 0 (Task 1 dan Task 4).
3. Simpanan rusak (id tak dikenal, kostum dipakai tidak dimiliki, Polos hilang dari daftar) → aplikasi tetap jalan dengan Polos (Task 2).
4. Pilih kartu yang belum dibeli lalu keluar → kostum yang dipakai tidak berubah, buka lagi memilih kostum yang dipakai (Task 4).
5. Saldo besar (99999) dan teks 130% di layar pendek 360×640 → tanpa overflow (Task 4).

---

### Task 1: Model kostum dan lemari

**Files:**
- Create: `lib/game/model/costumes.dart`
- Test: `test/game/model/costumes_test.dart`

**Interfaces:**
- Produces:
  - `class Costume { const Costume(this.id, this.name, this.price); final OyenCostume id; final String name; final int price; }`
  - `const List<Costume> costumes` (urutan desain 12) dan `Costume costumeOf(OyenCostume id)`.
  - `enum CostumeAction { wearing, wear, buy, notEnoughCoins }`
  - `class Wardrobe { Wardrobe({Iterable<OyenCostume> owned, OyenCostume wearing}); static final initial; Set<OyenCostume> owned; OyenCostume wearing; bool owns(OyenCostume); bool canBuy(OyenCostume, int coins); Wardrobe buy(OyenCostume); Wardrobe wear(OyenCostume); CostumeAction actionFor(OyenCostume, int coins); }` dengan `==`/`hashCode`.
  - Konstruktor menormalkan: `owned` selalu memuat `none`; `wearing` yang tidak dimiliki menjadi `none`. `buy` = milik + langsung dipakai (kembalikan `this` kalau sudah dimiliki); `wear` kembalikan `this` kalau tidak dimiliki. `canBuy` = belum dimiliki dan `coins >= price`.

- [ ] **Step 1: Tulis test gagal** (`costumes_test.dart`)
  - `costumes` → id `[none, peci, sarung, koki, kacamata]`, nama `['Polos','Peci','Sarung','Topi Koki','Kacamata']`, harga `[0, 60, 90, 150, 45]`.
  - `Wardrobe.initial`: `owned == {none}`, `wearing == none`.
  - `Wardrobe(owned: {peci}, wearing: koki)` → `owned == {none, peci}`, `wearing == none`.
  - `canBuy(kacamata, 45)` true, `canBuy(kacamata, 44)` false, `canBuy(none, 0)` false (sudah dimiliki).
  - `initial.buy(peci)` → `owns(peci)`, `wearing == peci`; `buy` kostum yang sudah dimiliki → `identical` dengan asalnya.
  - `wear(sarung)` saat tidak dimiliki → `identical`; `wear(none)` setelah memakai peci → `wearing == none`, peci tetap dimiliki.
  - `actionFor`: dipakai → `wearing`; dimiliki → `wear`; belum dimiliki dan koin cukup → `buy`; kurang → `notEnoughCoins`.
- [ ] **Step 2:** `flutter test test/game/model/costumes_test.dart` → gagal (berkas belum ada).
- [ ] **Step 3:** Tulis `costumes.dart` sesuai Interfaces.
- [ ] **Step 4:** Test yang sama → lulus.
- [ ] **Step 5:** `git commit -m "feat(model): costumes and wardrobe"`

### Task 2: Simpanan dan ProgressController

**Files:**
- Modify: `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`, `test/test_helpers.dart`
- Test: `test/app/progress_test.dart`

**Interfaces:**
- Consumes: `Wardrobe`, `OyenCostume` (Task 1).
- Produces:
  - `ProgressStore.loadWardrobe() → Future<Wardrobe>`, `saveWardrobe(Wardrobe) → Future<void>`.
  - `PrefsProgressStore.ownedKey = 'costume.owned'` (string list nama enum), `wearingKey = 'costume.wearing'` (nama enum). Nama tak dikenal dibuang; normalisasi lewat konstruktor `Wardrobe`.
  - `MemoryProgressStore.wardrobe` (field, default `Wardrobe.initial`).
  - `ProgressController({..., Wardrobe? wardrobe})`, `load` memuat `store.loadWardrobe()`, getter `wardrobe`, `Future<bool> buyCostume(OyenCostume)` (gagal tanpa efek kalau sudah dimiliki atau koin kurang; berhasil: potong koin, `Wardrobe.buy`, `notifyListeners`, lalu simpan wardrobe + koin), `Future<bool> wearCostume(OyenCostume)` (gagal kalau tidak dimiliki; sudah dipakai = true tanpa simpan).
  - `testProgressWith({..., Wardrobe? wardrobe})` mengisi store dan controller.

- [ ] **Step 1: Tulis test gagal**
  - Prefs: simpan `Wardrobe(owned: {peci, koki}, wearing: koki)` lalu muat → sama. Kosong → `Wardrobe.initial`. Rusak: `costume.owned = ['peci','topi']`, `costume.wearing = 'sarung'` → `owned == {none, peci}`, `wearing == none`.
  - Controller (`MemoryProgressStore`): koin 100, `buyCostume(peci)` → true, `coins == 40`, `wardrobe.wearing == peci`, store `coins == 40` dan `wardrobe.owns(peci)`, pendengar dipanggil sekali.
  - Koin 59, `buyCostume(peci)` → false, koin dan wardrobe tidak berubah, store tidak disimpan.
  - Koin 100, `final a = c.buyCostume(peci); final b = c.buyCostume(peci);` → `await a` true, `await b` false, `coins == 40`.
  - `wearCostume(sarung)` tanpa memiliki → false; setelah membeli peci, `wearCostume(none)` → true, `wearing == none`, tersimpan.
  - `ProgressController.load` dari store berisi wardrobe → `wardrobe` sama.
- [ ] **Step 2:** `flutter test test/app/progress_test.dart` → gagal kompilasi/assert.
- [ ] **Step 3:** Implementasi sesuai Interfaces (pola sama dengan `loadHints`/`unlockHint`; validasi dan perubahan sinkron sebelum `await` supaya ketukan kedua melihat kostum sudah dimiliki).
- [ ] **Step 4:** `flutter test test/app` → lulus.
- [ ] **Step 5:** `git commit -m "feat(app): save wardrobe, buy and wear costumes"`

### Task 3: Gambar lemari dan papan berkostum

**Files:**
- Modify: `lib/game/render/design_svg.dart` (konstanta `closetSvg`), `lib/game/render/board_scene.dart`
- Create: `lib/game/render/closet_art.dart` (ekspor lewat `render/render.dart`)
- Test: `test/game/render/design_sync_test.dart`, `test/game/render/board_scene_test.dart` (atau berkas test papan yang sudah ada untuk `BoardScene`)

**Interfaces:**
- Produces:
  - `const closetSvg`: isi `<svg>` lemari desain 12 (viewBox 300×236).
  - `abstract final class ClosetArt { static const Size viewBox = Size(300, 236); }`, `void paintCloset(Canvas canvas)` (pola `paintSuccessBowl`: `SvgTemplate(closetSvg).render(const {})`).
  - `BoardScene BoardScene.dressed(OyenCostume costume)`: salinan dengan `oyen.look.copyWith(costume: costume)`; `this` kalau `oyen == null` atau kostum sudah sama.

- [ ] **Step 1: Tulis test gagal**
  - design sync (grup baru "lemari kostum"): baris `closetSvg` ada di `12-lemari-kostum.html` (pola test "disalin dari desain 06").
  - `BoardScene.fromMap(BoardScene.designMap).dressed(OyenCostume.peci).oyen!.look.costume == peci`, petak dan `facing` sama; scene tanpa Oyen (`showOyen: false`) → `identical`.
- [ ] **Step 2:** Jalankan kedua test → gagal.
- [ ] **Step 3:** Implementasi.
- [ ] **Step 4:** Test lulus (design sync hanya jalan kalau `docs/design/` ada; di mesin ini ada).
- [ ] **Step 5:** `git commit -m "feat(render): closet art and dressed board scene"`

### Task 4: Layar Lemari Kostum

**Files:**
- Create: `lib/screens/closet/closet_screen.dart`, `lib/screens/closet/closet_parts.dart`
- Modify: `lib/app/routes.dart`, `lib/app/router.dart`, `lib/screens/home/home_screen.dart`, `lib/widgets/game_art.dart` (kalau perlu `ClosetArtView`), `lib/theme/*` (token baru)
- Test: `test/screens/closet_screen_test.dart`, `test/screens/navigation_test.dart`, `test/screens/overflow_test.dart`

**Interfaces:**
- Consumes: `costumes`, `Wardrobe`, `CostumeAction` (Task 1); `ProgressController.wardrobe/coins/buyCostume/wearCostume` (Task 2); `paintCloset`, `ClosetArt` (Task 3).
- Produces:
  - `AppRoutes.closet = '/kostum'`; `GoRoute(path: 'kostum')` di bawah Beranda.
  - `ClosetScreen` (StatefulWidget, baca `ProgressScope.of`; state `selected` awal = `wardrobe.wearing`).
  - `closet_parts.dart`: `ClosetBar` (kembali `context.pop()`/`go(home)`, judul, chip koin), `ClosetPreview` (lemari + `OyenView(OyenLook(pose: happy, dir: down, costume: selected), size: 168)` + nama), `CostumeCard` (key `ValueKey('costume-${id.name}')`, `Semantics(button, selected: terpilih)`), `ClosetActionButton` (`KoButton`, `onPressed` null kalau `wearing`/`notEnoughCoins`).
  - Tombol "Lemari Kostum" di Beranda: `onPressed: () => context.go(AppRoutes.closet)`.

- [ ] **Step 1: Tulis test gagal** (`closet_screen_test.dart`, `pumpApp(location: AppRoutes.closet, progress: testProgressWith(coins: …, wardrobe: …))`)
  - Awal (koin 0, initial): lima kartu urut, nama terpilih "Polos", kartu Polos "Dipakai", Peci "60", tombol "Sedang dipakai" nonaktif.
  - Ketuk Peci dengan koin 120: nama "Peci", tombol "Beli · 60 koin", `wardrobe.wearing` tetap `none`; ketuk tombol → koin 60 di chip, kartu Peci "Dipakai", tombol "Sedang dipakai", store tersimpan.
  - Koin 45, ketuk Kacamata → "Beli · 45 koin", beli → chip "0".
  - Koin 30, ketuk Topi Koki → "Koin kurang · 150", tombol nonaktif, ketuk tidak mengubah apa pun.
  - Wardrobe `{peci}` dipakai `none`: kartu Peci "Punyamu", ketuk → "Pakai", ketuk → dipakai.
  - Ketuk Sarung (belum dibeli), kembali ke Beranda, buka lagi → terpilih kostum yang dipakai.
  - Pratinjau: `OyenView` ukuran 168 memakai kostum terpilih (cari widget `OyenView` dengan `look.costume`).
  - `navigation_test`: Beranda → tombol "Lemari Kostum" → `ClosetScreen`; tombol kembali dan kembali sistem → Beranda.
  - `overflow_test`: tambah `AppRoutes.closet` ke `routes`; test tambahan koin 99999 dengan Topi Koki terpilih (tombol terpanjang "Beli · 150 koin") di semua ukuran dan skala.
- [ ] **Step 2:** Jalankan ketiga berkas test → gagal.
- [ ] **Step 3:** Implementasi layar persis desain 12 (ukuran: bar atas 44, judul 24, chip 40, lemari 300×236, Oyen 168, nama 20, kartu tinggi 104 radius 20 bingkai 3 bayangan 4, kotak Oyen kecil 64 radius 16 Oyen 56, label 24 px font 12.5/800, tombol 66 radius 22 font 22). Layar pendek: kecilkan pratinjau atau gulir, pilih yang lolos overflow tanpa mengubah tata letak di 390×844.
- [ ] **Step 4:** `flutter test test/screens/closet_screen_test.dart test/screens/navigation_test.dart test/screens/overflow_test.dart` → lulus.
- [ ] **Step 5:** `git commit -m "feat(closet): costume closet screen"`

### Task 5: Oyen berkostum di level, putar ulang, hasil, tutorial

**Files:**
- Modify: `lib/screens/level/level_screen.dart`, `lib/screens/level/level_view.dart`, `lib/screens/result/result_view.dart`, `lib/screens/result/result_art.dart`, `lib/screens/replay/replay_view.dart`
- Test: `test/screens/level_view_test.dart`, `test/screens/result_view_test.dart`, `test/screens/replay_view_test.dart`, `test/screens/progress_flow_test.dart` (atau `navigation_test`)

**Interfaces:**
- Consumes: `BoardScene.dressed` (Task 3), `ProgressController.wardrobe` (Task 2).
- Produces: parameter `OyenCostume costume = OyenCostume.none` di `LevelView`, `ResultView`, `SuccessResult`, `VaseResult`, `BoredResult`, `ReplayView`, `SuccessArt`, `VaseArt`. `LevelScreen` mengisi dari `ProgressScope.read(context).wardrobe.wearing`. `LevelView._buildScene()` mengembalikan `….dressed(widget.costume)`; tutorial memakai `tutorial.look.copyWith(costume: widget.costume)`; `ReplayView` dan `BoredResult` mendandani `replayScene`/`restScene`.

- [ ] **Step 1: Tulis test gagal**
  - `level_view_test`: `LevelView(costume: peci)` → `game.scene.oyen!.look.costume == peci` di fase atur dan setelah `wake()` beberapa langkah.
  - `result_view_test`: `SuccessResult`/`VaseResult` dengan `costume: koki` → `OyenView` makan memakai `koki`; `BoredResult` → `RestBoard.scene.oyen!.look.costume == koki`.
  - `replay_view_test`: `ReplayView(costume: kacamata)` → papan langkah terakhir memakai kacamata.
  - Alur: progres dengan wardrobe peci dipakai, buka `AppRoutes.level(3, chapter: 1)` → `KucingGame.scene.oyen!.look.costume == peci`.
- [ ] **Step 2:** Jalankan → gagal.
- [ ] **Step 3:** Implementasi sesuai Interfaces.
- [ ] **Step 4:** `flutter test test/screens` → lulus.
- [ ] **Step 5:** `git commit -m "feat: Oyen wears the chosen costume in levels, replay, and results"`

### Task 6: Potret layar dan dokumen

**Files:**
- Modify: `test/screenshots/screenshot_test.dart`, `CLAUDE.md`, `docs/DESIGN_NOTES.md`, `docs/ROADMAP.md`

- [ ] **Step 1:** Tambah potret `12-lemari-kostum` (koin 120, wardrobe `{kacamata}` dipakai kacamata, ketuk Peci = keadaan contoh desain) dan satu potret papan level dengan kostum. Jalankan `flutter test test/screenshots --dart-define=SCREENSHOTS=true`, buka PNG di `build/screenshots/390x844/`, bandingkan dengan desain 12; perbaiki selisih.
- [ ] **Step 2:** `CLAUDE.md` Struktur: `costumes.dart`, API `ProgressController`/`ProgressStore` baru, `BoardScene.dressed`, `paintCloset`, `lib/screens/closet/`, rute `/kostum`, parameter `costume`, test baru. `DESIGN_NOTES.md` bagian langkah 13: keputusan "keputusan saya" dari spec dan penyesuaian layar pendek. `ROADMAP.md`: centang langkah 13 dan beri ✅ di judulnya.
- [ ] **Step 3:** `/check` (format, analyze, test) → `No issues found!` dan semua test lulus.
- [ ] **Step 4:** `git commit -m "docs: record step 13, mark it done"`
