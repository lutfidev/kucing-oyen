# Petunjuk dan Koin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. (Proyek ini: `superpowers:executing-plans` di sesi utama, lihat `CLAUDE.md`.)

**Goal:** Pemain mendapat 10 koin per bintang baru dan bisa membuka tiga tingkat petunjuk per level dengan iklan (palsu) atau koin; petunjuk tampil di papan, saldo tampil di Beranda, sheet Petunjuk, dan layar hasil.

**Architecture:** Isi petunjuk dan hitungan koin adalah Dart murni (`lib/game/model/hints.dart`). Saldo dan tingkat per level disimpan lewat `ProgressStore` dan dikelola `ProgressController`, yang juga memanggil `RewardedAds` dan memenuhi antarmuka `HintSource`. `LevelView` hanya membaca `HintSource`: tombol bohlam membuka sheet Petunjuk (bingkai sheet dipakai bersama dengan sheet Aturan), dan tanda petunjuk digambar di `BoardScene` sebagai petak menyala + benda samar.

**Tech Stack:** Flutter, Flame, `shared_preferences` (`SharedPreferencesAsync`), go_router, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-17-hints-coins-design.md`

## Global Constraints

- Harga petunjuk persis desain 10: tingkat 1 = 20, tingkat 2 = 40, tingkat 3 = 80 koin. Koin per bintang baru = 10. Saldo awal 0 (kecuali pemain lama: total bintang × 10).
- Teks persis desain 10: "Petunjuk", "Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil.", "Sorot petak pertama", "Tunjukkan jenis benda", "Tampilkan solusi lengkap", "Tingkat N", "Terbuka", "Buka tingkat N dulu", "Tonton iklan", "N koin", tingkat 1 "Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.", ember "Oyen bakal kaget dan balik badan."
- Teks keputusan spek: "Koin kurang · N", "Level ini nggak butuh benda. Langsung bangunkan Oyen!", "Iklannya belum bisa diputar. Coba lagi nanti, ya."
- Tidak ada warna/ukuran hardcode di widget: nilai dari `docs/design/source/10-petunjuk.html` (dan 01 untuk chip koin Beranda) masuk token `lib/theme/` kalau belum ada.
- SVG desain (koin) disalin utuh ke `design_svg.dart`, jangan diketik ulang.
- `lib/game/model/` dan `lib/game/sim/` tanpa import Flutter/Flame.
- Teks game Bahasa Indonesia santai. Pesan commit bahasa Inggris, tanpa atribusi Claude.
- Selesai = `flutter analyze` "No issues found!" dan `flutter test` lulus.

## Review Focus

1. Ketuk "Tonton iklan" atau tombol koin dua kali cepat → tingkat hanya terbuka sekali dan koin hanya berkurang sekali (test di Task 2: dua `unlockHint` bersamaan).
2. Membuka ulang level yang petunjuknya sudah dibeli → tanda langsung tampil di papan tanpa membuka sheet (test di Task 6).
3. Benda dipindah keluar dari petak petunjuk → petak menyala lagi; benda salah di petak yang jenisnya sudah dibuka → tetap menyala; di tingkat 1 benda apa pun memadamkan (test di Task 6).
4. Data tersimpan rusak (koin negatif/bukan angka, tingkat 0 atau 7, id bukan angka) → dibuang, aplikasi tetap terbuka (test di Task 2).
5. Fase jalan, layar hasil, dan putar ulang tidak menampilkan tanda petunjuk; "Atur Lagi" menampilkannya lagi (test di Task 6).

---

### Task 1: Model petunjuk dan koin (Dart murni)

**Files:**
- Create: `lib/game/model/hints.dart`
- Test: `test/game/model/hints_test.dart`

**Interfaces:**
- Produces:
  - `const coinsPerStar = 10;`
  - `int coinsForStars(int before, int after)` → `(after - before) * coinsPerStar` kalau positif, selain itu 0.
  - `const maxHintTier = 3;` `int hintCost(int tier)` → 20/40/80 untuk tier 1/2/3, `ArgumentError` di luar 1–3.
  - `Map<Pos, Item?> hintMarks(Level level, int tier)` → tier 0: `{}`; 1: `{solution[0].pos: null}`; 2: `{solution[0].pos: solution[0].item}`; 3: semua `solution` dengan bendanya. Level tanpa solusi → `{}`.
  - `String hintText(Level level, int tier)` untuk tier 1–3.
  - `const noItemsHintText = 'Level ini nggak butuh benda. Langsung bangunkan Oyen!';`

- [ ] **Step 1: Tulis test yang gagal** (`testLevels` dari `test/test_helpers.dart`, `byId` lokal)

```dart
test('koin hanya dari bintang baru', () {
  expect(coinsForStars(0, 2), 20);
  expect(coinsForStars(2, 3), 10);
  expect(coinsForStars(3, 3), 0);
  expect(coinsForStars(2, 1), 0);
  expect(coinsForStars(0, 0), 0);
});
test('harga tingkat', () {
  expect([for (var t = 1; t <= 3; t++) hintCost(t)], [20, 40, 80]);
  expect(() => hintCost(0), throwsArgumentError);
});
test('tanda per tingkat level 13', () {
  final l = byId(13);
  expect(hintMarks(l, 0), isEmpty);
  expect(hintMarks(l, 1), {const Pos(3, 3): null});
  expect(hintMarks(l, 2), {const Pos(3, 3): Item.water});
  expect(hintMarks(l, 3), {const Pos(3, 3): Item.water, const Pos(2, 4): Item.fish});
  expect(hintMarks(byId(1), 3), isEmpty);
});
test('teks level 13', () {
  final l = byId(13);
  expect(hintText(l, 1), 'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.');
  expect(hintText(l, 2), 'Taruh ember air di petak yang menyala. Oyen bakal kaget dan balik badan.');
  expect(hintText(l, 3), 'Ember air dan ikan asin di petak yang menyala. Vas aman, 3 bintang.');
});
test('teks tingkat 3 lain', () {
  expect(hintText(byId(5), 3), 'Dua ikan asin di petak yang menyala. 3 bintang!');
  expect(hintText(byId(10), 3), 'Ember air dan dua ikan asin di petak yang menyala. 3 bintang!');
  expect(hintText(byId(19), 3), 'Ember air, ikan asin, dan kardus di petak yang menyala. 3 bintang!');
});
test('teks tingkat 2 menyebut benda pertama di semua level 3–20', () {
  for (final l in testLevels.where((l) => l.solution.isNotEmpty)) {
    final name = {Item.fish: 'ikan asin', Item.water: 'ember air', Item.box: 'kardus'}[l.solution.first.item]!;
    expect(hintText(l, 2), startsWith('Taruh $name di petak yang menyala. '));
  }
});
```

Cek dulu peta level 5, 10, 19: kalau ada vas (`Cell.tableVase`), ekspektasinya berakhir "Vas aman, 3 bintang." dan test disesuaikan.

- [ ] **Step 2: Jalankan, pastikan gagal** — `flutter test test/game/model/hints_test.dart` → gagal kompilasi (`hints.dart` belum ada).

- [ ] **Step 3: Implementasi di `lib/game/model/hints.dart`**

Nama benda huruf kecil: ikan asin, ember air, kardus. Akibat tingkat 2: ember "Oyen bakal kaget dan balik badan.", ikan "Oyen bakal ngejar dan makan ikannya.", kardus "Oyen bakal masuk dan duduk di situ.". Tingkat 3: kelompokkan `solution` per jenis urut kemunculan pertama; jumlah 1 = nama, 2 = "dua …", 3 = "tiga …"; gabung "A dan B" / "A, B, dan C"; huruf pertama kapital; lalu " di petak yang menyala." + (peta punya vas ? " Vas aman, 3 bintang." : " 3 bintang!"). Vas dicek dari `level.board.copyCells().contains(Cell.tableVase)` (pola `_hasVase` di `level_view.dart`).

- [ ] **Step 4: Jalankan test, pastikan lulus.**
- [ ] **Step 5: Commit** — `feat(model): hint marks, hint texts, and coins per new star`

---

### Task 2: Simpanan koin dan petunjuk, iklan palsu, `ProgressController`

**Files:**
- Create: `lib/app/rewarded_ads.dart`, `lib/app/hint_source.dart`
- Modify: `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`, `test/test_helpers.dart`
- Test: `test/app/progress_test.dart`

**Interfaces:**
- Consumes: `coinsForStars`, `hintCost`, `maxHintTier`, `coinsPerStar` (Task 1).
- Produces:
  - `abstract interface class RewardedAds { Future<bool> show(); }` dan `class FakeRewardedAds implements RewardedAds { FakeRewardedAds({this.succeed = true}); final bool succeed; int shown; }` (`shown` dihitung tiap `show`).
  - `enum HintPay { ad, coins }`, `enum HintUnlock { opened, notEnoughCoins, adFailed, notReady }`.
  - `abstract interface class HintSource implements Listenable { int get coins; int hintTier(int levelId); Future<HintUnlock> unlockHint(int levelId, int tier, HintPay pay); }`
  - `ProgressStore` bertambah `Future<int?> loadCoins()`, `Future<void> saveCoins(int coins)`, `Future<Map<int, int>> loadHints()`, `Future<void> saveHints(Map<int, int> tiers)`. `MemoryProgressStore` bertambah field `int? coins` dan `Map<int, int> hints` (parameter bernama di konstruktor). `PrefsProgressStore`: kunci `coins` (int) dan `hints.tier` (JSON `{"13": 2}`).
  - `ProgressController implements HintSource`: konstruktor bertambah `int coins = 0`, `Map<int, int> hints = const {}`, `RewardedAds? ads` (default `FakeRewardedAds()`); `load(levels:, store:, ads:)`; `int coinsFor(int id, int stars)`; `record` menambah koin.
  - `test/test_helpers.dart`: `ProgressController testProgressWith({Map<int, int> best = const {}, Set<int>? tutorialsDone, int coins = 0, Map<int, int> hints = const {}, RewardedAds? ads})`; `testProgress` memanggilnya.

- [ ] **Step 1: Tulis test yang gagal** di `test/app/progress_test.dart`

```dart
test('record memberi koin hanya untuk bintang baru', () async {
  final c = testProgressWith();
  expect(c.coinsFor(13, 2), 20);
  await c.record(13, 2);
  expect(c.coins, 20);
  await c.record(13, 3);
  expect(c.coins, 30);
  await c.record(13, 3);
  await c.record(14, 0);
  expect(c.coins, 30);
  expect((c.store as MemoryProgressStore).coins, 30);
});
test('pemain lama: saldo awal dari total bintang', () async {
  final store = MemoryProgressStore(Progress(wonUpTo(4)));   // coins null
  final c = await ProgressController.load(levels: testLevels, store: store);
  expect(c.coins, 120);
});
test('tingkat dibuka berurutan dengan koin', () async {
  final c = testProgressWith(coins: 100);
  expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.notReady);
  expect(await c.unlockHint(13, 1, HintPay.coins), HintUnlock.opened);
  expect(await c.unlockHint(13, 2, HintPay.coins), HintUnlock.opened);
  expect(c.coins, 40);
  expect(await c.unlockHint(13, 3, HintPay.coins), HintUnlock.notEnoughCoins);
  expect(c.coins, 40);
  expect(c.hintTier(13), 2);
  expect((c.store as MemoryProgressStore).hints, {13: 2});
});
test('iklan membuka tanpa koin; iklan gagal tidak membuka', () async {
  final ok = testProgressWith(ads: FakeRewardedAds());
  expect(await ok.unlockHint(3, 1, HintPay.ad), HintUnlock.opened);
  expect(ok.coins, 0);
  final fail = testProgressWith(ads: FakeRewardedAds(succeed: false));
  expect(await fail.unlockHint(3, 1, HintPay.ad), HintUnlock.adFailed);
  expect(fail.hintTier(3), 0);
});
test('dua ketukan bersamaan hanya membuka sekali', () async {
  final c = testProgressWith(coins: 100);
  final r = await Future.wait([
    c.unlockHint(13, 1, HintPay.coins),
    c.unlockHint(13, 1, HintPay.coins),
  ]);
  expect(r.where((x) => x == HintUnlock.opened), hasLength(1));
  expect(c.coins, 80);
});
// PrefsProgressStore dengan InMemorySharedPreferencesAsync (pola test yang ada):
// simpan-muat koin dan petunjuk; koin tersimpan -5 atau "x" → loadCoins null;
// hints {"13": 2, "x": 1, "4": 0, "5": 7} → {13: 2}.
```

- [ ] **Step 2: Jalankan, pastikan gagal** — `flutter test test/app/progress_test.dart`.
- [ ] **Step 3: Implementasi**
  - `unlockHint`: tolak `notReady` kalau `tier != hintTier(id) + 1` atau `tier > maxHintTier`. Iklan: `await ads.show()`; gagal → `adFailed`; sesudah `await`, cek tier lagi (bisa sudah dibuka panggilan lain) → `notReady`. Koin: saldo < `hintCost(tier)` → `notEnoughCoins`, selain itu kurangi. Lalu set tier, `notifyListeners()`, simpan koin dan petunjuk. Supaya Review Focus #1 aman, catat tier yang sedang diproses per level dan tolak panggilan kedua selama `await` berjalan.
  - `record`: hitung `coinsFor` sebelum `_progress` berubah; kalau > 0 tambahkan, simpan juga koin.
  - `load`: `coins = await store.loadCoins() ?? progress.totalStars * coinsPerStar`.
  - `main.dart` tidak perlu diubah (default `FakeRewardedAds`).
- [ ] **Step 4: Jalankan `flutter test test/app` dan seluruh `flutter test`** (pemanggil `MemoryProgressStore` dan `testProgress` lama tetap jalan).
- [ ] **Step 5: Commit** — `feat(app): save coins and hint tiers, fake rewarded ads`

---

### Task 3: Gambar koin dan tanda petunjuk di papan

**Files:**
- Modify: `lib/game/render/design_svg.dart`, `lib/game/render/tile.dart`, `lib/game/render/board_scene.dart`, `lib/game/render/tile_painter.dart`, `lib/game/render/render.dart` (ekspor), `lib/widgets/game_art.dart`
- Create: `lib/game/render/coin_art.dart`
- Test: `test/game/render/painters_test.dart` (atau file render yang sesuai), `test/game/render/board_scene_test.dart` jika ada, `test/widgets/game_art_test.dart`

**Interfaces:**
- Produces:
  - `coinSvg` (28×28 dengan huruf S, dari desain 01/10) dan `coinPlainSvg` (tanpa S, tombol desain 10), disalin utuh. `void paintCoin(Canvas canvas, {bool plain = false})` di kotak 0..28.
  - `CoinView({double size, bool plain = false})` di `lib/widgets/game_art.dart`, hiasan (`ExcludeSemantics`).
  - `Tile` bertambah `final Item? ghost;` (ikut `==`, `hashCode`, `copyWith`, `toString`). `BoardScene.fromMap(..., Map<Pos, Item> ghosts = const {})`.
  - `paintTile` menggambar `paintItemArt(item, ghost: true)` di atas petak, sebelum kotak menyala, dengan opasitas `BoardArt.hintOpacity` (0,55; keputusan baru, catat di `DESIGN_NOTES`). Benda pemain di petak yang sama menutupinya (petak dengan `item != none` tidak menggambar ghost).

- [ ] **Step 1: Test gagal**: `BoardScene.fromMap(designMap, ghosts: {Pos(3,3): Item.water}, glow: {Pos(3,3)}).tileAt(Pos(3,3))` punya `ghost == Item.water` dan `glow`; warna piksel di tengah petak (3,3) pada gambar papan berbeda dari papan tanpa ghost dan lebih pucat dari benda pemain (`bucketP`); `CoinView` tergambar tanpa error (pola test piksel yang sudah ada di `painters_test.dart`).
- [ ] **Step 2: Jalankan, pastikan gagal.**
- [ ] **Step 3: Implementasi.**
- [ ] **Step 4: Jalankan `flutter test test/game/render test/widgets`.**
- [ ] **Step 5: Commit** — `feat(render): coin art and faint hint items on the board`

---

### Task 4: Bingkai sheet bersama

**Files:**
- Create: `lib/screens/level/level_sheet.dart`
- Modify: `lib/screens/level/rules_sheet.dart`
- Test: `test/screens/rules_tutorial_test.dart` (tetap hijau, tanpa perubahan perilaku)

**Interfaces:**
- Produces:
  - `Future<void> showLevelSheet(BuildContext context, {required String barrierLabel, required Widget Function(BuildContext context, VoidCallback onClose) builder})`: pindahan `showGeneralDialog` + transisi `koSheet` + `onClose` yang hanya menutup sheet ini dari `showRulesSheet`.
  - `LevelSheet({required String label, required Widget header, required List<Widget> children, required VoidCallback onClose})`: pegangan, tarik untuk menutup (`closeDrag` 80, `closeFling` 700, kembali ke tempat 200 ms), kotak krem radius `sheet`, bayangan, padding 10/16/24 + inset bawah, tinggi maksimal sampai bawah bar atas level, isi digulir. `LevelSheet.openTime`/`openRise` pindah dari `RulesSheet`.
  - `showRulesSheet` dan `RulesSheet` memakai keduanya; animasi kucing kartu 4 tetap di `RulesSheet`.

- [ ] **Step 1: Pindahkan kode, tanpa mengubah perilaku.**
- [ ] **Step 2: Jalankan `flutter test test/screens/rules_tutorial_test.dart test/screens/overflow_test.dart`** → lulus.
- [ ] **Step 3: Commit** — `refactor(level): share the sheet frame between rules and hints`

---

### Task 5: Sheet Petunjuk

**Files:**
- Create: `lib/screens/level/hint_sheet.dart`
- Modify: `lib/theme/ko_colors.dart`, `ko_size.dart`, `ko_type.dart`, `ko_shadow.dart`, `ko_radius.dart` (token baru dari desain 10 bila belum ada), `lib/screens/level/level_bar.dart`
- Test: `test/screens/hint_sheet_test.dart`

**Interfaces:**
- Consumes: `HintSource`, `HintPay`, `HintUnlock` (Task 2), `hintText`, `hintCost`, `noItemsHintText` (Task 1), `CoinView` (Task 3), `showLevelSheet`/`LevelSheet` (Task 4).
- Produces:
  - `Future<void> showHintSheet(BuildContext context, {required Level level, required HintSource hints})`.
  - `HintSheet({required Level level, required HintSource hints, required VoidCallback onClose})`: dibangun ulang saat `hints` berubah (`ListenableBuilder`). Kepala: lingkaran bohlam 44 (`KoIcons.hint`), judul "Petunjuk", chip saldo (koin polos 22 + angka, `Semantics` "N koin", live region), tombol tutup. Kalimat pembuka. `level.solution` kosong → satu kartu terbuka berisi `noItemsHintText`; selain itu tiga `HintTierCard`.
  - `HintTierCard`: keadaan terbuka (border hijau, badge hijau, subjudul "Terbuka", kotak teks `hintText`), siap ("Tingkat N", dua tombol), terkunci (latar `#EFE3CF`, garis putus-putus `#CDB48C`, opasitas 0,75, "Buka tingkat N-1 dulu", tombol nonaktif). Tombol koin: saldo cukup → "N koin", kurang → "Koin kurang · N" (ditekan tidak melakukan apa-apa). Selama iklan berjalan kedua tombol kartu itu nonaktif. `adFailed` → teks "Iklannya belum bisa diputar. Coba lagi nanti, ya." di bawah tombol kartu itu sampai ditekan lagi.
  - `HintButton({required VoidCallback onPressed})` di `level_bar.dart`: tombol bulat 44 `#FFE6A8`, border `#F0C55A`, bayangan padat `#D9A92E` (pakai `KoPressable`/`KoIconButton` dengan tone baru bila perlu), label pembaca layar "Petunjuk".

- [ ] **Step 1: Test gagal** (`pumpThemed` + `testProgressWith`, sheet dibuka dari tombol di halaman test kecil; jangan `pumpAndSettle` kalau papan ikut tampil)

```dart
testWidgets('urutan buka tingkat dan koin berkurang', (tester) async {
  final hints = testProgressWith(coins: 120);
  // buka sheet level 13
  expect(find.text('120'), findsOneWidget);
  expect(find.text('Buka tingkat 1 dulu'), findsOneWidget);
  expect(find.text('Buka tingkat 2 dulu'), findsOneWidget);
  await tester.tap(find.text('20 koin'));
  await tester.pump();
  expect(find.text('100'), findsOneWidget);
  expect(find.text('Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.'), findsOneWidget);
  expect(find.text('Terbuka'), findsOneWidget);
  expect(find.text('Tingkat 2'), findsOneWidget);
  await tester.tap(find.text('Tonton iklan').first);   // kartu tingkat 2 (tingkat 1 sudah tanpa tombol)
  await tester.pump();
  expect(hints.coins, 100);
  expect(hints.hintTier(13), 2);
  expect(find.text('Koin kurang · 80'), findsNothing);   // 100 ≥ 80
});
testWidgets('koin kurang', ...);         // coins: 10 → "Koin kurang · 20", ketuk → tingkat tetap 0
testWidgets('iklan gagal', ...);         // FakeRewardedAds(succeed: false) → teks gagal tampil, tingkat 0
testWidgets('level tanpa benda', ...);   // level 1 → noItemsHintText, tanpa "Tonton iklan"
testWidgets('ditutup dengan tombol, latar, kembali, tarik', ...);   // seperti test sheet Aturan
```

- [ ] **Step 2: Jalankan, pastikan gagal.**
- [ ] **Step 3: Implementasi** (ukuran, warna, teks dari `10-petunjuk.html`: kartu padding 12 radius 20 gap 10, badge 32, judul Fredoka 600 17, subjudul 13/700 `inkSoft`, kotak teks padding 10/12 radius 14 `#E3F5F1`/`#12352F` 14/800, tombol tinggi 46 radius 14 Nunito 800 14, ikon iklan 18 (path desain ke `KoIcons.ad`), koin polos 18).
- [ ] **Step 4: Jalankan `flutter test test/screens/hint_sheet_test.dart`.**
- [ ] **Step 5: Commit** — `feat(level): hint sheet with ad and coin unlocks`

---

### Task 6: Petunjuk di layar level

**Files:**
- Modify: `lib/screens/level/level_view.dart`, `lib/screens/level/level_screen.dart`
- Test: `test/screens/hint_level_test.dart` (baru), `test/screens/level_view_test.dart` (pemanggil `LevelView` bila perlu)

**Interfaces:**
- Consumes: `HintSource` (Task 2), `hintMarks` (Task 1), `BoardScene.fromMap(ghosts:)` (Task 3), `showHintSheet`, `HintButton` (Task 5).
- Produces:
  - `LevelView` bertambah `final HintSource? hints;` (null = tanpa tombol bohlam). `LevelView` mendaftar listener di `hints` (`initState`/`didUpdateWidget`/`dispose`) dan membangun ulang papan saat berubah.
  - `onResult` berubah jadi `final int Function(int stars)? onResult;` yang mengembalikan koin yang didapat; nilainya disimpan untuk layar hasil (Task 7).
  - `LevelScreen`: `hints: progress`, `onResult: (stars) { final earned = progress.coinsFor(level.id, stars); unawaited(progress.record(level.id, stars)); return earned; }`.
  - Baris di bawah bar atas selalu tampil di fase atur: `TargetChip` di kiri (kalau baki tidak kosong), `HintButton` di kanan (desain 03). Di fase jalan baris tetap `RunStatus` seperti sekarang (hanya kalau baki tidak kosong); tinggi papan tidak boleh berubah saat Oyen dibangunkan, jadi baris disisakan juga di fase jalan untuk level tanpa benda.
  - `_buildScene` fase atur: untuk tiap `(pos, item)` di `hintMarks(level, hints.hintTier(level.id))`: `placed = _session.itemAt(pos)`; menyala kalau `placed == null || (item != null && placed != item)`; ghost kalau `item != null && placed == null` (benda yang sedang diangkat dari petak itu dihitung kosong). Digabung dengan `glow` seretan.
  - Tombol bohlam membatalkan seretan dulu (seperti `_openRules`), hanya di fase atur.

- [ ] **Step 1: Test gagal** (level dari `testLevels`, `testProgressWith(hints: {13: 1})`, papan dibaca dari `KucingGame.scene` lewat `tester.widget<GameWidget<KucingGame>>(...).game!.scene` atau cara yang sudah dipakai `level_view_test.dart`; jangan `pumpAndSettle` setelah tanda tampil)

```dart
testWidgets('tanda tersimpan langsung tampil', ...);   // hints {13: 2}: tile (3,3) glow + ghost water
testWidgets('membeli tingkat dari sheet memperbarui papan', ...);  // 0 → sheet → 20 koin → tutup → (3,3) glow, tanpa ghost
testWidgets('tingkat 1: benda apa pun memadamkan', ...);  // hints {13: 1}, taruh ikan di (3,3) → tidak glow
testWidgets('tingkat 2: benda salah tetap menyala, pindah keluar menyala lagi', ...);
testWidgets('fase jalan dan hasil tanpa tanda; Atur Lagi menampilkannya lagi', ...);
testWidgets('level 1 punya tombol Petunjuk dan papan tidak berubah ukuran saat dibangunkan', ...);
```

- [ ] **Step 2: Jalankan, pastikan gagal.**
- [ ] **Step 3: Implementasi.**
- [ ] **Step 4: Jalankan `flutter test test/screens`** (tutorial level 1/3/6 dan `progress_flow_test` tetap hijau).
- [ ] **Step 5: Commit** — `feat(level): hint button and hint marks on the board`

---

### Task 7: Koin di Beranda dan layar hasil

**Files:**
- Modify: `lib/screens/home/home_screen.dart`, `lib/screens/result/result_view.dart`, `lib/screens/result/result_parts.dart`, `lib/screens/level/level_view.dart`
- Test: `test/screens/home_chapter_test.dart`, `test/screens/result_view_test.dart`, `test/screens/progress_flow_test.dart`

**Interfaces:**
- Consumes: `CoinView` (Task 3), `ProgressController.coins`, nilai `onResult` (Task 6).
- Produces:
  - `CoinChip` di Beranda (kiri atas, desain 01: tinggi 40, padding 0 14 0 6, gap 8, `surface`, bayangan `0 2 0 #EAD3AE, 0 6 14 rgba(120,70,20,.10)`, Fredoka 600 18, koin 28; `Semantics` "N koin"; belum bisa ditekan). Komentar "Pengaturan (langkah 14)" jadi langkah 15.
  - `ResultView(..., int coins = 0)` → `SuccessResult(coins:)` dan `VaseResult(coins:)`. Kalau `coins > 0`, `ResultStats` mendapat kotak ketiga: `ResultStat(value: coins, label: 'koin', prefix: '+', leading: CoinView(...))` (ikon `leading` menggantikan `icon`; `compact` di layar vas pecah). `ResultStat` bertambah `String prefix = ''` dan `Widget? leading`; pembaca layar "+20 koin".
  - `LevelView` meneruskan koin dari `onResult` ke `ResultView`.

- [ ] **Step 1: Test gagal**: Beranda `testProgressWith(coins: 120)` menampilkan "120" dengan label "120 koin"; layar Berhasil level 13 dengan `coins: 30` menampilkan "+30" dan "koin", dengan `coins: 0` tidak; vas pecah dengan `coins: 10` menampilkan "+10"; alur penuh (`progress_flow_test`): menang level 1 dari progres kosong → layar hasil "+30", kembali ke Beranda → chip "30"; ulangi level 1 → layar hasil tanpa kotak koin.
- [ ] **Step 2: Jalankan, pastikan gagal.**
- [ ] **Step 3: Implementasi.**
- [ ] **Step 4: Jalankan `flutter test test/screens`.**
- [ ] **Step 5: Commit** — `feat: show coins on home and result screens`

---

### Task 8: Overflow, potret layar, dokumen

**Files:**
- Modify: `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`, `CLAUDE.md`, `docs/DESIGN_NOTES.md`, `docs/ROADMAP.md`

- [ ] **Step 1: Overflow**: sheet Petunjuk level 13 (semua tertutup, 120 koin; satu terbuka; ketiganya terbuka, digulir sampai kartu terakhir), sheet level 1, Beranda dengan koin 4 digit (`9999`), Berhasil dan Vas pecah dengan `coins: 30` — di semua ukuran dan skala teks yang sudah dipakai file itu.
- [ ] **Step 2: Potret**: `10-petunjuk` (level 13, 120 koin, tingkat 1 terbuka seperti desain), `10-petunjuk-papan` (sheet ditutup, tingkat 3), `01-beranda` sudah ada (kini dengan chip), Berhasil dengan "+30". Jalankan `flutter test test/screenshots --dart-define=SCREENSHOTS=true`, buka PNG-nya, bandingkan dengan angka desain 10 dan 01.
- [ ] **Step 3: Dokumen**:
  - `CLAUDE.md` "Struktur": `hints.dart`, `rewarded_ads.dart`, `hint_source.dart`, koin/petunjuk di `ProgressController`/`ProgressStore` (kunci `coins`, `hints.tier`), `testProgressWith`, `level_sheet.dart`, `hint_sheet.dart`, `HintButton`, `CoinView`/`paintCoin`, `Tile.ghost`, `ResultView(coins:)`, chip koin Beranda; catatan test: selama tanda petunjuk tampil papan berkedip terus, jangan `pumpAndSettle`. "seperti 12 dan 14" → "12 dan 15", "di langkah 14" (ikon launcher) → 15.
  - `docs/DESIGN_NOTES.md`: bagian langkah 12 (sumber koin + pemain lama, petunjuk tanpa potongan bintang, teks tingkat 2/3 buatan, level tanpa benda, "Koin kurang · N", iklan gagal, ghost 0,55 dan aturan nyala, "+N koin" di layar hasil, baris bohlam di level 1–2), dan perbarui catatan Beranda baris 88 (chip koin sudah ada).
  - `docs/ROADMAP.md`: centang 12 + ringkasan "Selesai"; sisipkan "14. Koin tambahan: tonton iklan dan bonus harian" (hasil + prompt: baca spek ini, tonton iklan menambah koin lewat `RewardedAds`, bonus harian, desain belum ada → gaya yang sama, tanyakan angka hadiah di awal sesi, test); ganti nomor Polish dan rilis Android jadi 15 (Status dan judul) dan sebut di prompt-nya bahwa iklan koin dari langkah 14 juga memakai SDK asli.
- [ ] **Step 4: `/check`** (format, `flutter analyze` → "No issues found!", `flutter test` lulus).
- [ ] **Step 5: Commit** — `docs: record step 12 notes, add coin step to roadmap, mark step 12 done` (test overflow/potret boleh commit terpisah `test: ...`).

Sesudah Task 8: review (`superpowers:requesting-code-review`, satu subagent effort high), `superpowers:receiving-code-review`, perbaiki, `superpowers:verification-before-completion`, push, PR (alur git `CLAUDE.md`).
