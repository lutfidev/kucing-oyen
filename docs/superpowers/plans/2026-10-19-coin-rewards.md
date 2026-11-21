# Koin Tambahan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (CLAUDE.md: rencana dijalankan di sesi utama) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pemain bisa menambah koin dengan menonton iklan berhadiah (dibatasi per hari) dan mengambil bonus koin harian, dari sheet "Tambah Koin" yang dibuka lewat chip koin Beranda dan Lemari Kostum.

**Architecture:** Model Dart murni `DailyRewards` (hari klaim bonus, hari dan jumlah iklan) di `lib/game/model/rewards.dart`, hari = nomor hari kalender lokal. `ProgressController` memegang `DailyRewards` dan jam yang bisa diganti (`clock`), menyimpannya lewat `ProgressStore`. Tiga `_CoinChip` yang sekarang ada (Beranda, Lemari Kostum, sheet Petunjuk) disatukan menjadi `KoCoinChip` di `lib/widgets/` yang bisa ditekan. Sheet baru `CoinSheet` di `lib/screens/coins/` memakai bingkai `showLevelSheet`/`LevelSheet`.

**Tech Stack:** Flutter, go_router, shared_preferences (`SharedPreferencesAsync`), flutter_test.

**Spec:** tidak ada dokumen terpisah: pemilik repo meminta langsung dikerjakan dengan angka yang masuk akal (19 Oktober 2026). Keputusan di bagian "Keputusan" di bawah, dicatat juga di `docs/DESIGN_NOTES.md` (Task 5). Sumber lain: `docs/ROADMAP.md` langkah 14, `docs/superpowers/specs/2026-10-17-hints-coins-design.md`.

## Keputusan (semua keputusan saya)

- **Iklan:** +20 koin per iklan yang selesai, paling banyak 5 iklan per hari (100 koin/hari). Iklan gagal tidak menambah dan tidak dihitung.
- **Bonus harian:** 20 koin, sekali per hari kalender lokal. Tidak ada beruntun (streak).
- **Hari** = tanggal kalender lokal dari `clock()`. Jam mundur (hari ini lebih awal dari hari tersimpan): bonus dan iklan tertahan sampai tanggalnya terlewati lagi. Jam maju tidak dicegah (game offline).
- **Tempat:** chip koin Beranda (kiri atas) dan Lemari Kostum (kanan atas) bisa ditekan dan membuka sheet "Tambah Koin". Chip yang bisa ditekan mendapat tombol "+" kecil di ujung kanan; chip Beranda juga mendapat titik merah bata selama bonus hari itu belum diambil. Chip di sheet Petunjuk tetap tidak bisa ditekan (sheet di atas sheet).
- **Bukan tujuan:** "koin ×2" di layar hasil, bonus beruntun, sheet terbuka sendiri saat aplikasi dibuka, SDK iklan asli (langkah 15).
- Ikon `plus` dan `gift` (desain belum punya) digambar dengan gaya garis ikon desain (garis 2,4, ujung bulat).

## Global Constraints

- `dailyBonusCoins = 20`, `adRewardCoins = 20`, `maxAdsPerDay = 5`.
- Teks persis: judul "Tambah Koin"; kalimat "Koin buat petunjuk dan kostum Oyen. Ambil bonus tiap hari, atau tonton iklan."; kartu "Bonus harian" (subjudul "Sekali sehari" / "Sudah diambil hari ini"; tombol "Ambil 20 koin" / "Ambil lagi besok"); kartu "Tonton iklan" (subjudul "Sisa N kali hari ini" / "Jatah hari ini habis"; tombol "+20 koin" / "Besok ada lagi"); iklan gagal "Iklannya belum bisa diputar. Coba lagi nanti, ya." (sama dengan sheet Petunjuk).
- Tidak ada warna/ukuran hardcode di widget; tambah token kalau perlu.
- Model di `lib/game/model/` tanpa import Flutter/Flame.
- Iklan tetap lewat `RewardedAds` (`ProgressController.ads`, sama dengan petunjuk).
- Commit kecil, pesan Inggris, tanpa atribusi Claude. Selesai: `flutter analyze` → `No issues found!`, `flutter test` hijau.

## Review Focus

1. Ketuk tombol iklan dua kali cepat → satu iklan, koin +20 sekali (Task 2: `watchAdForCoins` dua kali tanpa `await` → kedua `busy`).
2. Ketuk "Ambil 20 koin" dua kali cepat → koin +20 sekali (Task 2).
3. Jam perangkat dimundurkan sesudah klaim → bonus tidak bisa diambil lagi (Task 1).
4. Simpanan rusak (`rewards.daily` bukan JSON, field negatif/bertipe salah) → aplikasi jalan dengan `DailyRewards.initial` untuk field itu (Task 1 dan Task 2).
5. Saldo 99999 dan teks 130% di 360×640 dengan sheet terbuka → tanpa overflow (Task 4).

---

### Task 1: Model hadiah harian

**Files:**
- Create: `lib/game/model/rewards.dart`
- Test: `test/game/model/rewards_test.dart`

**Interfaces:**
- Produces:
  - `const dailyBonusCoins = 20; const adRewardCoins = 20; const maxAdsPerDay = 5;`
  - `int dayNumber(DateTime time)` = jumlah hari sejak 1970-01-01 untuk tanggal kalender `time` (pakai `DateTime.utc(y, m, d)`, supaya pergantian jam musim panas tidak menggeser hari).
  - `class DailyRewards { const DailyRewards({int? bonusDay, int? adDay, int adsWatched = 0}); static const initial; bool canClaimBonus(int today); int adsLeft(int today); DailyRewards claimBonus(int today); DailyRewards watchedAd(int today); Map<String, Object?> toJson(); factory DailyRewards.fromJson(Map<String, dynamic>); }` dengan `==`/`hashCode`.
  - `canClaimBonus` = `bonusDay == null || today > bonusDay`. `adsLeft`: `adDay == null || today > adDay` → 5; `today == adDay` → `max(0, 5 - adsWatched)`; `today < adDay` → 0. `claimBonus` → `bonusDay = today`. `watchedAd` → hari sama: `adsWatched + 1` (paling banyak 5); hari lain: `adDay = today, adsWatched = 1`.
  - JSON `{"bonusDay": n, "adDay": n, "ads": n}`; field null tidak ditulis. `fromJson` membuang field yang bukan int atau negatif (iklan juga di atas 5 → dibuang); `ads` tanpa `adDay` → 0.

- [ ] **Step 1: Tulis test gagal**
  - `dayNumber(DateTime(1970, 1, 2, 23, 59)) == 1`; `dayNumber(DateTime(2026, 10, 19, 0, 1)) == dayNumber(DateTime(2026, 10, 19, 23, 59))`; hari berikutnya +1.
  - `initial`: `canClaimBonus(100)` true, `adsLeft(100) == 5`.
  - `initial.claimBonus(100)`: `canClaimBonus(100)` false, `canClaimBonus(101)` true, `canClaimBonus(99)` false.
  - Lima `watchedAd(100)` → `adsLeft(100) == 0`, keenam tetap `adsLeft == 0` dan `adsWatched == 5`; `adsLeft(101) == 5`; `adsLeft(99) == 0`; `watchedAd(101)` sesudahnya → `adsLeft(101) == 4`.
  - JSON pulang-pergi sama; `fromJson({'bonusDay': 'x', 'adDay': -1, 'ads': 9})` → `== initial`; `fromJson({'bonusDay': 5, 'adDay': 7, 'ads': 2})` → `adsLeft(7) == 3`, `canClaimBonus(5)` false.
- [ ] **Step 2:** `flutter test test/game/model/rewards_test.dart` → gagal (berkas belum ada).
- [ ] **Step 3:** Tulis `rewards.dart` sesuai Interfaces.
- [ ] **Step 4:** Test yang sama → lulus.
- [ ] **Step 5:** `git commit -m "feat(model): daily coin rewards"`

### Task 2: Simpanan dan ProgressController

**Files:**
- Modify: `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`, `lib/app/rewarded_ads.dart` (komentar: iklan juga untuk koin), `test/test_helpers.dart`
- Test: `test/app/progress_test.dart` (grup baru `koin tambahan`)

**Interfaces:**
- Consumes: Task 1.
- Produces:
  - `ProgressStore.loadRewards() → Future<DailyRewards>` (`initial` kalau belum ada/rusak), `saveRewards(DailyRewards) → Future<void>`. `PrefsProgressStore.rewardsKey = 'rewards.daily'` (string JSON). `MemoryProgressStore.rewards` (field, default `initial`).
  - `enum AdReward { rewarded, failed, limitReached, busy }` di `progress_scope.dart`.
  - `ProgressController({..., DailyRewards? rewards, DateTime Function()? clock})`; `load(..., DateTime Function()? clock)`; `final DateTime Function() clock` (default `DateTime.now`); getter `bool canClaimBonus`, `int adsLeft` (dihitung dari `clock()` tiap dibaca); `Future<bool> claimDailyBonus()` (false tanpa efek kalau sudah; berhasil: ubah `_rewards` dan `_coins += 20`, `notifyListeners`, lalu simpan keduanya); `Future<AdReward> watchAdForCoins()` (`busy` kalau iklan koin sedang diputar; `limitReached` kalau `adsLeft == 0`; panggil `ads.show()` dengan penanganan error seperti `unlockHint`; gagal → `failed` tanpa efek; selesai → `watchedAd(hari saat itu)`, +20, simpan, `rewarded`). Iklan yang selesai tetap diberi hadiah walau hari berganti selama iklan.
  - `testProgressWith({..., DailyRewards? rewards, DateTime Function()? clock})`.

- [ ] **Step 1: Tulis test gagal** (jam = variabel `var now = DateTime(2026, 10, 19, 9)` lewat `clock: () => now`)
  - Prefs: simpan lalu muat `DailyRewards(bonusDay: 3, adDay: 4, adsWatched: 2)` → sama; kosong → `initial`; `rewards.daily = 'bukan json'` → `initial`; `rewards.daily` disimpan sebagai int → `initial`.
  - `claimDailyBonus` → true, `coins` +20, `canClaimBonus` false, store `coins` dan `rewards` tersimpan; panggilan kedua → false, koin tetap. `now` maju sehari → `canClaimBonus` true. Dua panggilan tanpa `await` → satu true, koin +20 sekali.
  - `watchAdForCoins` (iklan palsu berhasil) → `rewarded`, koin +20, `adsLeft == 4`, tersimpan. Iklan gagal (`FakeRewardedAds(succeed: false)`) → `failed`, koin dan `adsLeft` tetap, `rewards` store tidak berubah. Lima kali → keenam `limitReached` dan `ads.shown == 5`. Dua panggilan tanpa `await` → satu `rewarded`, satu `busy`, `shown == 1`. Iklan yang melempar error → `failed`.
  - `ProgressController.load` memuat `rewards` dari store.
- [ ] **Step 2:** `flutter test test/app/progress_test.dart` → gagal (API belum ada).
- [ ] **Step 3:** Tulis sesuai Interfaces.
- [ ] **Step 4:** Test yang sama → lulus.
- [ ] **Step 5:** `git commit -m "feat(app): daily bonus and ad coins in progress"`

### Task 3: Chip koin bersama

**Files:**
- Create: `lib/widgets/ko_coin_chip.dart` (ekspor di `widgets.dart`)
- Modify: `lib/screens/home/home_screen.dart`, `lib/screens/closet/closet_parts.dart`, `lib/screens/level/hint_sheet.dart` (hapus ketiga `_CoinChip`), `lib/widgets/ko_icon.dart` (`KoIcons.plus`, `KoIcons.gift`), token baru seperlunya di `lib/theme/`
- Test: `test/widgets/ko_coin_chip_test.dart`

**Interfaces:**
- Produces:
  - `enum KoCoinChipStyle { raised, outlined, compact }`: `raised` = Beranda (tinggi `chip`, koin `iconLarge`, jarak 8, `koType.chip`, bayangan `coinChip`, padding kanan 14); `outlined` = Lemari Kostum (tinggi `chip`, koin `iconMedium`, jarak 6, `numberCoinLarge` ink, garis `line`); `compact` = sheet (tinggi `chipMedium`, koin `icon`, jarak 6, `numberCoin`, garis, padding kanan 12). Tampilan tanpa `onPressed` harus sama dengan chip lama.
  - `KoCoinChip({required int coins, KoCoinChipStyle style = raised, VoidCallback? onPressed, bool badge = false})`. Dengan `onPressed`: `KoPressable` (raised: `edgeColor: line`, `depth` 2, `glow` bayangan lembut `coinChip`, jadi tampak sama dan turun saat ditekan), lingkaran "+" oranye kecil di kanan angka, label pembaca layar "N koin, tambah koin". `badge`: titik `brick` bergaris `surface` di pojok kanan atas, label ditambah ", bonus harian siap". Tanpa `onPressed`: label "N koin", `liveRegion` seperti sekarang.

- [ ] **Step 1: Tulis test gagal**
  - Tanpa `onPressed`: `find.bySemanticsLabel('120 koin')`, tidak ada `KoPressable`.
  - Dengan `onPressed`: ketuk → dipanggil sekali; semantik tombol berlabel `'120 koin, tambah koin'`.
  - `badge: true` → label `'120 koin, tambah koin, bonus harian siap'`, titik ada (`find.byKey(const ValueKey('coin-badge'))`).
- [ ] **Step 2:** `flutter test test/widgets/ko_coin_chip_test.dart` → gagal.
- [ ] **Step 3:** Tulis `KoCoinChip`, ganti ketiga `_CoinChip` (Beranda `raised`, Lemari `outlined`, Petunjuk `compact`, semua belum ditekan), tambah ikon.
- [ ] **Step 4:** `flutter test` penuh → lulus (test lama yang mencari label "N koin" tetap lulus).
- [ ] **Step 5:** `git commit -m "refactor(widgets): shared coin chip"`

### Task 4: Sheet Tambah Koin

**Files:**
- Create: `lib/screens/coins/coin_sheet.dart`
- Modify: `lib/screens/level/level_sheet.dart` (pindahkan `_TierButton` dari `hint_sheet.dart` ke sini sebagai `SheetButton` publik, dipakai kedua sheet; komentar: bingkai juga dipakai Beranda dan Lemari Kostum), `lib/screens/level/hint_sheet.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/closet/closet_parts.dart` + `closet_screen.dart`
- Test: `test/screens/coin_sheet_test.dart`, `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`

**Interfaces:**
- Consumes: Task 2 (`canClaimBonus`, `adsLeft`, `claimDailyBonus`, `watchAdForCoins`, `AdReward`), Task 3 (`KoCoinChip`).
- Produces:
  - `Future<void> showCoinSheet(BuildContext context, ProgressController progress)` (`barrierLabel: 'Tutup tambah koin'`, `scrimLight`).
  - `CoinSheet({required ProgressController progress, required VoidCallback onClose})`: `ListenableBuilder` pada `progress`; kepala = koin dalam lingkaran `iconButton`, judul "Tambah Koin" (`header`), `KoCoinChip(style: compact)`, tombol tutup; kalimat; kartu `RewardCard` berkunci `coin-bonus` dan `coin-ad` (lingkaran `chipSmall` ikon `gift`/`ad`, `ink`; sudah habis → `success` + ikon `check`; judul `cardTitle`, subjudul `controlLabel` `inkSoft` dengan `liveRegion`; satu `SheetButton` penuh lebar: bonus oranye bergaris `orange`/`orangeDeep` dengan koin polos, iklan `surface` dengan ikon `ad`; habis/menunggu = nonaktif). Iklan menunggu: tombol nonaktif; gagal: pesan merah bata di bawah tombol iklan sampai ketukan berikutnya.
  - Beranda: `KoCoinChip(onPressed: () => showCoinSheet(context, progress), badge: progress.canClaimBonus)`. Lemari Kostum: `ClosetBar(onCoins:)` → chip `outlined` dengan `onPressed`, tanpa badge.

- [ ] **Step 1: Tulis test gagal** (`coin_sheet_test.dart`, `pumpApp` + `testProgressWith(coins:, rewards:, ads:, clock:)`)
  - Beranda: titik ada saat bonus belum diambil; ketuk chip → "Tambah Koin" tampil, kedua kartu siap ("Sekali sehari", "Sisa 5 kali hari ini").
  - Ketuk "Ambil 20 koin" → saldo 20 (chip sheet), subjudul "Sudah diambil hari ini", tombol "Ambil lagi besok" nonaktif; tutup → titik Beranda hilang.
  - Ketuk "+20 koin" → saldo +20, "Sisa 4 kali hari ini"; iklan gagal → pesan gagal, saldo tetap; `rewards` dengan 5 iklan hari ini → "Jatah hari ini habis", "Besok ada lagi" nonaktif.
  - Iklan yang belum selesai (`Completer`) → tombol iklan nonaktif selama menunggu.
  - Lemari Kostum: ketuk chip → sheet tampil; beli koin lalu harga kartu berubah setelah sheet ditutup (saldo cukup untuk Kacamata).
  - Tutup lewat tombol "Tutup", latar, dan tombol kembali sistem → kembali ke layar asal.
- [ ] **Step 2:** `flutter test test/screens/coin_sheet_test.dart` → gagal.
- [ ] **Step 3:** Tulis sesuai Interfaces.
- [ ] **Step 4:** Test yang sama → lulus.
- [ ] **Step 5:** Overflow: sheet Tambah Koin dibuka dari Beranda bersaldo 99999 di semua ukuran dan skala teks `overflow_test.dart`, dua keadaan (siap semua; bonus diambil + iklan habis + iklan gagal). Potret layar: `14-tambah-koin` (siap) dan `14-tambah-koin-habis`. Jalankan `flutter test test/screens/overflow_test.dart` dan `flutter test test/screenshots --dart-define=SCREENSHOTS=true`, lihat PNG-nya; perbaiki tampilan kalau janggal.
- [ ] **Step 6:** `git commit -m "feat(coins): coin sheet with daily bonus and rewarded ads"`

### Task 5: Dokumen

**Files:**
- Modify: `CLAUDE.md` (Struktur: `rewards.dart`, API `ProgressController` baru, `KoCoinChip`, `lib/screens/coins/`, `SheetButton`, test baru), `docs/DESIGN_NOTES.md` (bagian "Langkah 14": semua keputusan di atas + token/ikon baru), `docs/ROADMAP.md` (centang 14, paragraf "Selesai", hapus butir "satukan dua `_CoinChip`" dari prompt langkah 15 karena sudah dikerjakan)

- [ ] **Step 1:** Tulis perubahan dokumen.
- [ ] **Step 2:** `dart format .`, `flutter analyze` → `No issues found!`, `flutter test` → semua lulus.
- [ ] **Step 3:** `git commit -m "docs: record step 14, mark it done"`
