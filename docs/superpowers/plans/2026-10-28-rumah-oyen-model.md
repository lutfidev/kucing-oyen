# Rumah Oyen: model (langkah 21) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task (sesi utama, sesuai `CLAUDE.md`). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Data dan aturan rumah Oyen (barang, kucing, aksesoris, camilan, tata letak, kebutuhan, mangkuk, hadiah) sebagai Dart murni yang tersimpan dan teruji, tanpa layar baru.

**Architecture:** Katalog dan nilai tak berubah di `lib/game/model/` (satu berkas per konsep). `Home` (satu JSON `home.state`) memegang `Room`, kucing dimiliki, `AccessoryCloset`, `Pantry`; `HomeNeeds` (JSON `home.needs`) memegang `CatNeeds` per kucing, `Bowl`, hari hadiah, dan waktu menghias. `ProgressController` memakai keduanya lewat antrean simpan `_Part` yang sudah ada.

**Tech Stack:** Dart 3, Flutter `ChangeNotifier`, `shared_preferences` (`SharedPreferencesAsync`), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md` (Kebutuhan dan hadiah, Aksesoris, Toko, Koin, Model data) + prompt langkah 21 di `docs/ROADMAP.md`.

## Global Constraints

- Model Dart murni: tidak mengimpor Flutter atau Flame.
- Harga, efek camilan, kelangkaan, jangkar, urutan katalog: dari `Toko.dc.html`, `Kamar.dc.html`, `BarangKamar.dc.html`, `Barang.dc.html`, `AksesorisPreview.dc.html`.
- Lapar habis 12 jam, Senang 16 jam; bar 0–100, berhenti di 0; jam mundur tidak menaikkan bar.
- Elus +10, paling banyak +30 per jam; main +10, sekali per 30 menit; menghias +5 semua kucing, sekali per jam.
- Mangkuk: satu isi tiap 4 jam, tiap kucing sekali per isi, +40 Lapar, hanya kalau Lapar < 70.
- Hadiah 10 koin per kucing per hari kalender (`dayNumber`) saat Lapar dan Senang ≥ 70; jam mundur menahan.
- Stok camilan paling banyak 99 per jenis.
- Semua `fromJson` membuang entri rusak, tidak pernah melempar.
- Gagal tanpa efek, dua ketukan tidak membayar dua kali (ubah keadaan sinkron sebelum `await`), barang disimpan sebelum koin.
- `maxAdsPerDay` = 10.
- Belum ada teks atau layar baru. Kostum lama dan Lemari Kostum tetap.

## Keputusan saya (dicatat di `docs/DESIGN_NOTES.md` "Langkah 21")

- **Mangkuk** (`mangkuk`) masuk `RoomItemId` sebagai barang bawaan berharga 0: selalu dimiliki, selalu ditaruh, tidak bisa ke Gudang dan tidak dijual. `shopItems` = 20 barang lain.
- **Spot** = pecahan 0–1 dari rentang pojok kiri-atas barang yang muat di area (batas seret `Kamar.dc.html`): dinding x 14..376−w, y 112..402−h; lantai x 8..382−w, dan tepi bawah 436..646. Jadi spot apa pun di 0–1 selalu sah untuk ukuran barang itu, dan y lantai = urutan gambar.
- **Ukuran barang di kamar** = ukuran `Barang.dc.html` × skala `BASE` `Kamar.dc.html`; barang yang tidak ada di `BASE` skala 1.
- **Posisi bawaan**: 9 barang + mangkuk dari `BASE` `Kamar.dc.html`; 11 lainnya saya pilih (boleh tumpang tindih; pemain menata). Kardus bawaan (tepi bawah 648) dijepit ke 646.
- **Cara dipakai** dari pose `dipakai` di `Barang.dc.html`: karpet = tidur (desain), bukan rebahan seperti spesifikasi. `toy` = daftar mainan spesifikasi (bola, tikus, tiang, catnip, akuarium, pancingan, terowongan, jendela burung).
- **Isi mangkuk dimulai saat kucing pertama makan dari isi itu**; isi berikutnya 4 jam sesudahnya. Mangkuk yang tidak disentuh tetap penuh, jadi hasilnya tidak bergantung kapan layar dibuka.
- **Batas elus** = jendela 1 jam sejak elusan pertama di jendela itu; **batas main** = 30 menit sejak main terakhir; **menghias** = 1 jam sejak bonus terakhir. Jam mundur tidak membuka jendela baru.
- **Aksesoris dibeli tidak langsung dipakai** (desain: sesudah "Milikmu selamanya" ada tombol Pakai).
- **Urutan simpan**: `hints, wardrobe, home, coins, needs, progress, rewards, tutorials, language`. Barang sebelum koin; koin hadiah kucing sebelum hari hadiahnya. Akibatnya memberi camilan menulis stok sebelum bar (kalau aplikasi mati di antaranya, efek satu camilan hilang); ini dipilih supaya koin selalu memihak pemain.
- **Reset**: `Home.initial`; kebutuhan hanya Oyen, penuh sekarang; mangkuk, hari hadiah, dan waktu menghias tetap.

## Review Focus

- Simpanan lama tanpa `home.state`/`home.needs` (pemain lama): Oyen dimiliki dengan bar 100, mangkuk di posisi bawaan. Test `memuat tanpa simpanan rumah` di Task 6.
- JSON rumah berisi nilai NaN/tak hingga/string di tempat angka: dibuang, tidak melempar. Test di Task 2 dan Task 5.
- Kucing dibeli lalu bar dibaca berjam-jam kemudian tanpa aksi: turun lurus dari waktu beli. Test di Task 6.
- Ketukan ganda semua aksi beli (barang, kucing, aksesoris, camilan). Test di Task 6.
- Aksesoris dipakai kucing yang tidak dimiliki / aksesoris tidak dimiliki di JSON: dibuang saat dibaca. Test di Task 3 dan Task 4.

---

### Task 1: `maxAdsPerDay` jadi 10

**Files:** Modify `lib/game/model/rewards.dart`, `test/game/model/rewards_test.dart`, `test/app/progress_test.dart` (grup `koin tambahan`), `test/screens/coin_sheet_test.dart`, `docs/DESIGN_NOTES.md` (Langkah 14, catatan).

- [ ] Ubah test: `maxAdsPerDay` 10, `adsLeft` awal 10, loop sepuluh iklan, "Sisa 10 kali hari ini" / "Sisa 9 kali hari ini", test "sepuluh iklan per hari".
- [ ] Jalankan, pastikan gagal; ubah konstanta; jalankan test terkait sampai lulus. Teks `adsLeftToday` sudah berparameter, ARB tidak berubah.
- [ ] Commit `feat(rewards): ten coin ads per day`.

### Task 2: Katalog barang, `Spot`, dan `Room`

**Files:** Create `lib/game/model/home_items.dart`, `lib/game/model/room.dart`; Test `test/game/model/home_items_test.dart`, `test/game/model/room_test.dart`.

**Interfaces (Produces):**
- `enum RoomZone { floor, wall }`; `enum ItemUse { sleep, play, scratch, watch, sit, hide, lounge, eat }`.
- `enum RoomItemId` urut `Toko.dc.html` B lalu `mangkuk`: `tikus, akuarium, rumah, kasur, catnip, jam, kardus, bola, karpet, tiang, lukisan, rak, pancingan, lampuBulan, bantalIkan, monstera, terowongan, hammock, sofaMini, jendelaBurung, mangkuk`.
- `class RoomItem { id, price, zone, use, toy, width, height, defaultX, defaultY; Spot get defaultSpot; bool get builtIn }`, `roomItems` (21), `shopItems` (20, tanpa mangkuk), `roomItemOf(id)`.
- `class Spot { const Spot(x, y) dijepit 0–1; toJson [x, y]; static Spot? fromJson(Object?) }`, `Spot spotAt(RoomItem item, double left, double top)`, `(double, double) positionOf(RoomItem item, Spot spot)`, konstanta area `wallLeft 14, wallRight 376, wallTop 112, wallBottom 402, floorLeft 8, floorRight 382, floorTop 436, floorBottom 646`.
- `class Room { Room({Iterable<RoomItemId> owned, Map<RoomItemId, Spot> placed}); static final initial; owned (selalu memuat mangkuk), placed (hanya yang dimiliki; mangkuk selalu), stored (Gudang, urut katalog), owns, isPlaced, spotOf, canBuy(id, coins), buy(id) (ditaruh di defaultSpot), place(id, spot), store(id) (mangkuk ditolak); toJson; factory fromJson(Map) }`. Nilai sama (`==`) kalau isi sama.

Data (harga Toko; zona BarangKamar; ukuran Barang×BASE; posisi BASE atau pilihan saya):

| id | harga | zona | pakai | toy | w×h | x,y |
|---|---|---|---|---|---|---|
| tikus | 120 | lantai | play | ya | 46×28 | 330,560 |
| akuarium | 600 | lantai | watch | ya | 92×90 | 180,446 |
| rumah | 900 | lantai | hide | – | 122×132 | 70,340 |
| kasur | 200 | lantai | sleep | – | 150×76 ×0,85 | 246,448 |
| catnip | 180 | lantai | play | ya | 52×74 ×0,9 | 44,520 |
| jam | 240 | dinding | play | – | 52×86 ×0,9 | 164,126 |
| kardus | 50 | lantai | hide | – | 122×82 | 166,566 |
| bola | 80 | lantai | play | ya | 36×36 | 100,592 |
| karpet | 150 | lantai | sleep | – | 184×60 ×1,25 | 80,500 |
| tiang | 220 | lantai | scratch | ya | 50×152 ×0,95 | 20,330 |
| lukisan | 140 | dinding | watch | – | 72×66 ×1,15 | 206,150 |
| rak | 160 | dinding | sit | – | 104×34 ×1,1 | 250,336 |
| pancingan | 60 | lantai | play | ya | 80×70 | 12,566 |
| lampuBulan | 120 | dinding | sleep | – | 60×60 | 306,156 |
| bantalIkan | 160 | lantai | sleep | – | 130×56 | 240,560 |
| monstera | 200 | lantai | hide | – | 70×110 | 312,330 |
| terowongan | 260 | lantai | hide | ya | 152×64 | 200,520 |
| hammock | 380 | dinding | sleep | – | 120×70 | 230,240 |
| sofaMini | 450 | lantai | lounge | – | 140×86 | 110,470 |
| jendelaBurung | 700 | dinding | watch | ya | 100×96 | 30,160 |
| mangkuk | 0 | lantai | eat | – | 54×30 ×1,15 | 298,596 |

Tests:
- [ ] `home_items_test`: 20 barang toko, harga persis tabel, total 5.370; 14 lantai + 6 dinding; mainan = 8 barang spesifikasi; `positionOf(item, item.defaultSpot)` = (defaultX, defaultY) ±0,01 untuk semua kecuali kardus (y 564).
- [ ] `room_test`: awal hanya mangkuk ditaruh; beli → dimiliki di defaultSpot, beli lagi tidak berubah, `canBuy` koin kurang/pas/mangkuk; `store` ke Gudang lalu `place` kembali; `store(mangkuk)` dan `place` barang tak dimiliki tidak berubah; `Spot` dijepit (−1 → 0, 2 → 1, NaN → 0); JSON bolak-balik; `fromJson` rusak (nama asing, spot `"a"`, `[1]`, `[NaN, 0]`, `placed` untuk barang tak dimiliki, `owned` bukan list) dibuang tanpa melempar.
- [ ] Implementasi, test lulus, commit `feat(home): room items, spots, and room layout`.

### Task 3: Kucing, aksesoris, camilan

**Files:** Create `lib/game/model/kitties.dart`, `accessories.dart`, `snacks.dart`; Test `test/game/model/kitties_test.dart`, `accessories_test.dart`, `snacks_test.dart`.

**Interfaces (Produces):**
- `enum KittyId { oyen, salju, telon, arang, mendung, kopiSusu, mochi, bos, kembang }` (Oyen lalu urutan Toko K); `class Kitty { id, price }`; `kitties` (Oyen 0, Salju 300, Telon 550, Arang 400, Mendung 350, Kopi Susu 300, Mochi 450, Bos 600, Kembang 700); `kittyOf`.
- `enum Rarity { common, rare, special }`; `enum AccessoryAnchor { headTop, headSideRight, headSideLeft, neck, face }`; `enum AccessoryId` urut Toko AK: `pita, jepitBunga, bandana, dasiKupu, kalung, syal, beanie, topiKoki, baret, kacamata, headphone, tandukRusa, topiPesta, topiPenyihir, mahkota, mahkotaRaja`; `class Accessory { id, price, rarity, anchor }`, `accessories`, `accessoryOf`.
- `class AccessoryCloset { AccessoryCloset({Iterable<AccessoryId> owned, Map<KittyId, AccessoryId> wearing}) (yang tidak dimiliki dibuang); static final initial; owns, canBuy(id, coins), buy(id) (tidak dipakai otomatis), wearingOf(kitty) → AccessoryId?, wear(kitty, AccessoryId? id) (null = lepas; tak dimiliki = tidak berubah); toJson {owned: [...], wearing: {kitty: acc}}; factory fromJson; == }`.
- `enum SnackId { ikanAsin, susu, tuna, biskuit, puding }`; `class Snack { id, price, hunger, joy }` (20/25/5, 15/15/5, 40/40/5, 10/10/2, 90/60/15); `snacks`, `snackOf`; `const maxSnackStock = 99`; `class Pantry { Pantry([Map<SnackId,int>]) (0 dibuang, >99 jadi 99); static const empty; countOf, canAdd(id), add(id), take(id) → Pantry? (null kalau 0); toJson; factory fromJson (bukan int/negatif dibuang); == }`.

Tests:
- [ ] Harga dan urutan persis desain; total kucing 3.650, aksesoris 4.260; kelangkaan dan jangkar per tabel spesifikasi (pita `headSideRight`, jepit bunga `headSideLeft`).
- [ ] Lemari: satu aksesoris dipakai Oyen dan Arang sekaligus; ganti; lepas; pakai yang tidak dimiliki tidak berubah; `fromJson` membuang aksesoris/kucing asing dan `wearing` aksesoris yang tidak dimiliki.
- [ ] Pantry: tambah sampai 99 lalu `canAdd` false; `take` 0 → null; JSON rusak dibuang.
- [ ] Implementasi, lulus, commit `feat(home): kitties, accessories, and snacks`.

### Task 4: `Home` (state `home.state`)

**Files:** Create `lib/game/model/home.dart`; Test `test/game/model/home_test.dart`.

**Interfaces (Produces):** `class Home { Home({Room? room, Iterable<KittyId> kitties, AccessoryCloset? closet, Pantry pantry}); static final initial; room, kitties (selalu memuat oyen), closet, pantry; ownsKitty, canBuyKitty(id, coins); copyWith({room, kitties, closet, pantry}); toJson {room, kitties, closet, pantry}; factory fromJson (bagian rusak = awal; aksesoris dipakai kucing tak dimiliki dibuang); == }`.

- [ ] Test: awal = Oyen + mangkuk; JSON bolak-balik; bagian rusak per kunci; `wearing` kucing tak dimiliki dibuang.
- [ ] Implementasi, lulus, commit `feat(home): home state`.

### Task 5: Kebutuhan, mangkuk, hadiah (`home.needs`)

**Files:** Create `lib/game/model/needs.dart`; Test `test/game/model/needs_test.dart`.

**Interfaces (Produces):**
- Konstanta: `hungerHours 12, joyHours 16, bowlRefillHours 4, bowlFood 40, bowlHungerLimit 70, rewardCoins 10, rewardThreshold 70, sadThreshold 20, petJoy 10, petJoyPerHour 30, playJoy 10, playMinutes 30, decorateJoy 5, decorateMinutes 60, maxNeed 100`.
- `class CatNeeds { CatNeeds({hunger, joy, at, petAt, petted, playedAt}); factory CatNeeds.full(DateTime now); decayed(now); fed(Snack, now); ateFromBowl(now); CatNeeds? petted(now); CatNeeds? played(now); withJoy(int, now); isSad (≤ 20 salah satu); canEatFromBowl (hunger < 70); canReward (keduanya ≥ 70); toJson; static CatNeeds? fromJson }`. Nilai `double`; `decayed` dengan `now <= at` mengembalikan `this`.
- `class Bowl { Bowl({DateTime? filledAt, Iterable<KittyId> eaten}); static final full; isActive(now) (filledAt ≠ null && now < filledAt+4j); hasEaten(kitty, now); eat(kitty, now); refillAt (null kalau belum pernah); isEmptyFor(kitties, now); toJson; factory fromJson }`.
- `class HomeNeeds { HomeNeeds({Map<KittyId, CatNeeds> cats, Bowl? bowl, Map<KittyId,int> rewardDays, DateTime? decoratedAt}); static final empty; of(kitty, now) → CatNeeds (tersimpan, diturunkan; penuh sekarang kalau tidak ada); withKitties(Iterable<KittyId>, now) (menambah yang belum ada, penuh); update(kitty, CatNeeds); canEatFromBowl(kitty, now); eatFromBowl(kitty, now) → HomeNeeds?; canClaim(kitty, today, now); claim(kitty, today, now) → HomeNeeds?; finishDecorating(kitties, now) → HomeNeeds?; reset(now) (Oyen penuh; mangkuk, hari hadiah, waktu menghias tetap); toJson; factory fromJson }`.

Tests (jam tetap `DateTime(2026, 10, 28, 8)`):
- [ ] Turun: 6 jam → Lapar 50, Senang 62,5; 12 jam → Lapar 0; 20 jam → keduanya 0 (tidak negatif); jam mundur 3 jam → tidak berubah, lalu maju lagi dihitung dari `at` lama.
- [ ] Camilan: Ikan Asin +25/+5 dan dijepit 100.
- [ ] Elus: tiga kali +10, keempat null dalam jam yang sama; 1 jam sesudah elusan pertama boleh lagi; jam mundur tetap tertahan.
- [ ] Main: sekali, 29 menit null, 30 menit boleh.
- [ ] Mangkuk: penuh awal; Oyen makan (+40) lalu tidak boleh lagi di isi yang sama; Arang boleh; kosong untuk {Oyen, Arang}; 4 jam sesudah makan pertama isi baru; Lapar ≥ 70 tidak boleh makan; jam mundur sebelum `filledAt` tetap isi lama.
- [ ] Hadiah: ≥ 70 keduanya → boleh, sekali per hari; besok lagi; jam mundur (hari < hari hadiah) tertahan; < 70 tidak boleh.
- [ ] Menghias: +5 semua kucing, kedua kali dalam 1 jam null, 60 menit boleh.
- [ ] JSON bolak-balik; rusak (NaN, string, kucing asing, `at` bukan int) dibuang tanpa melempar; `reset`.
- [ ] Implementasi, lulus, commit `feat(home): cat needs, bowl, and kitty rewards`.

### Task 6: Simpanan dan `ProgressController`

**Files:** Modify `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`, `test/test_helpers.dart` (`FailingProgressStore` + `testProgressWith(home:, needs:)`), `test/app/progress_test.dart` (grup `PrefsProgressStore`, grup baru `rumah`, `simpanan gagal`, reset).

**Interfaces:**
- Consumes: Task 2–5.
- Produces: `ProgressStore.loadHome()/saveHome(Home)` kunci `home.state`, `loadNeeds()/saveNeeds(HomeNeeds)` kunci `home.needs`; `MemoryProgressStore.home`, `.needs`; `ProgressController({Home? home, HomeNeeds? needs})`, getter `home`, `needs`, `catNeeds(KittyId)` (diturunkan ke `clock()`), `canClaimKittyReward(KittyId)`, `canEatFromBowl(KittyId)`; aksi `Future<bool>`: `buyItem(RoomItemId)`, `buyKitty(KittyId)`, `buyAccessory(AccessoryId)`, `buySnack(SnackId)`, `wearAccessory(KittyId, AccessoryId?)`, `placeItem(RoomItemId, Spot)`, `storeItem(RoomItemId)`, `feed(KittyId, SnackId)`, `pet(KittyId)`, `play(KittyId, RoomItemId)` (mainan yang ditaruh), `finishDecorating()`, `eatFromBowl(KittyId)`, `claimKittyReward(KittyId)` (+10 koin). `_Part` urut `hints, wardrobe, home, coins, needs, progress, rewards, tutorials, language`.

- [ ] Test Prefs: rumah dan kebutuhan simpan/muat; belum pernah = awal; JSON rusak/bertipe salah = awal.
- [ ] Test controller (grup `rumah`): beli barang/kucing/aksesoris/camilan memotong koin, tersimpan, pendengar sekali; koin kurang tanpa efek; dua ketukan bersamaan tiap jenis hanya sekali; stok 99 menolak; kucing baru bar 100 di waktu beli lalu turun; barang disimpan sebelum koin (`writes` `['home', 'coins']`, kucing `['home', 'coins', 'needs']`); pakai aksesoris (tidak dimiliki/kucing tidak dimiliki ditolak); taruh/simpan barang; feed mengurangi stok dan menaikkan bar (`['home', 'needs']`); elus/main/menghias/mangkuk memakai batas model; hadiah +10 sekali per hari (`['coins', 'needs']`); memuat tanpa simpanan rumah = Oyen penuh di jam muat.
- [ ] Test reset: barang, kucing, aksesoris, stok, tata letak terhapus; Oyen 100; hari hadiah tetap (hadiah hari ini tidak bisa diambil lagi).
- [ ] Tambahkan `'home'`, `'needs'` ke test "semua aksi selesai tanpa error walau simpanan rusak" beserta aksi rumah.
- [ ] Implementasi, `flutter analyze`, test lulus, commit `feat(progress): home and needs in progress controller`.

### Task 7: Dokumen

- [ ] `docs/DESIGN_NOTES.md`: bagian "Langkah 21" (keputusan di atas) dan catatan langkah 14 (10 iklan).
- [ ] `CLAUDE.md` "Struktur": berkas model baru, kunci simpanan, API controller.
- [ ] `docs/ROADMAP.md`: centang 21, ringkasan "Selesai".
- [ ] `/check`, review subagent, PR.
