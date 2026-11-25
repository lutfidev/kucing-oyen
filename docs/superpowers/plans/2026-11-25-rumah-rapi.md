# Rumah yang rapi (langkah 40) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task (CLAUDE.md: rencana dijalankan di sesi utama). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rumah penuh terlihat tenang dan rapi: satu gelembung hadiah bergiliran,
paling banyak dua kucing berjalan, barang tidak menumpuk (beli, rapikan sekali,
tombol Rapikan), kotak petunjuk kosong hilang, dan barang baru Rak Buku dengan
pose baca.

**Architecture:** Aturan tumpang tindih, perapian, dan penempatan barang baru
ditulis Dart murni di `lib/game/model/house.dart` dan `room.dart`. Pengatur
giliran jalan ditambahkan ke `RoomLife`. Layar (`room_view.dart`,
`decorate.dart`, `buy_sheet.dart`) hanya memakai API itu. Gambar rak buku dan
pose baca disalin dari kanvas Gang Depan lewat `tool/design/make_lane_svg.py`.

**Tech Stack:** Flutter, Dart, Flame (tidak disentuh), Python 3 untuk alat salin desain.

**Spec:** `docs/superpowers/specs/2026-11-25-rumah-rapi-design.md`

## Global Constraints

- Logika di `lib/game/model/` tanpa impor Flutter; test unit ber-seed.
- Semua teks baru ada di `app_{en,id,pt,ru}.arb` (Indonesia ditulis dulu, nada santai), lalu `flutter gen-l10n` dan `python tool/translations/make_review.py`.
- Tidak ada warna atau ukuran hardcode di widget; token baru di `lib/theme/`.
- Gambar desain tidak diketik tangan; `design_sync_test` menjaga salinannya.
- Hadiah tetap 10 koin, sekali sehari per kucing, Lapar dan Senang ≥ 70.
- "Menumpuk" = kotak gambar barang belakang tertutup barang depan > 25 % luasnya (barang dinding: > 25 % luas yang lebih kecil). Karpet (`flat`) dan gantungan teras tidak dihitung.
- Rak Buku: `RoomItemId.rakBuku`, 220 koin, lantai, `ItemUse.read`, hanya ruang tengah, ukuran `Barang.dc.html` 112×140, dipakai `[112, 140, 150, 152]`, offset `[38, 8]`, kucing `[0, 52, 100, 'baca']` menghadap kanan.
- Rutinitas: diam 8–20 detik, pakai 8–14, tidur/lounge 20–40, maks 2 kucing berjalan per ruangan, mulai bergerak 2,5 detik sesudah ruangan dibuka, dorongan sesudah 8 detik diam.
- Commit kecil berbahasa Inggris; tanpa atribusi Claude.
- Selesai = `flutter analyze` bersih + `flutter test` hijau (`/check`).

## Review Focus

1. Ketukan ganda di "Rapikan" atau "Batalkan": efeknya hanya sekali; Batalkan sesudah pemain memindah barang lagi tidak menghapus pindahan itu (pesan hilang saat barang diseret). → test di Task 5.
2. Rumah penuh 21 barang + 9 kucing: perapian tidak membuang mangkuk, tidak memindah barang ke ruangan lain, dan hasilnya stabil (merapikan dua kali = sama). → test di Task 3.
3. Simpanan lama tanpa tanda `tidy` dimuat dua kali (aplikasi dibuka ulang): perapian hanya sekali, dan susunan pemain sesudahnya tidak dirapikan lagi. → test di Task 3.
4. Kucing yang memberi hadiah pindah ruangan, lesu, atau bertag "Baru!": gelembung pindah ke kucing berikutnya dan "+N lagi" ikut berubah. → test di Task 6.
5. Kurangi gerak: rutinitas mati, jadi dorongan tidak boleh memaksa jalan; geser barang Rapikan langsung tanpa animasi. → test di Task 5 dan Task 7.

---

### Task 1: Hapus bidang kosong "Hiasan dinding?" / "Kasur, mungkin?"

**Files:**
- Modify: `lib/screens/room/room_parts.dart:292-380` (`EmptyRoomHints`)
- Modify: `lib/l10n/app_{en,id,pt,ru}.arb` (hapus `roomEmptyWall`, `roomEmptyWallHint`, `roomEmptyFloor`, `roomEmptyFloorHint` dan blok `@`-nya)
- Test: `test/screens/room_screen_test.dart` (grup kamar kosong)

**Interfaces:**
- Produces: `EmptyRoomHints(geo:, onShop:, time:)` tetap, hanya berisi gelembung ajakan (`bubbleAt`, `nod`).

- [ ] **Step 1:** Ubah test kamar baru: `expect(find.text(l10nId.roomEmptyBubble), findsOneWidget)` tetap, dan finder label bidang kosong (`'Hiasan dinding?'`, `'Kasur, mungkin?'`) → `findsNothing`. Hapus assertion lain yang memakai `wallSpot`/`floorSpot`.
- [ ] **Step 2:** `flutter test test/screens/room_screen_test.dart` → FAIL (teks masih ada).
- [ ] **Step 3:** Hapus `wallSpot`, `floorSpot`, dan kedua bidang putus-putus dari `EmptyRoomHints.build`; hapus kunci ARB; `flutter gen-l10n`; `python tool/translations/make_review.py`.
- [ ] **Step 4:** `flutter test test/screens/room_screen_test.dart test/l10n test/screens/overflow_test.dart` → PASS; `flutter analyze` bersih.
- [ ] **Step 5:** Commit `feat(room): drop empty-room wall and floor hint boxes`.

### Task 2: Aturan tumpang tindih kotak gambar

**Files:**
- Modify: `lib/game/model/house.dart` (`HouseFloor`, `ItemFootprint`)
- Test: `test/game/model/house_test.dart`

**Interfaces:**
- Produces:
  - `ItemFootprint itemBox(RoomItem item, Spot spot)`: kotak gambar desain 390×652. Barang lantai = `itemFeet` ± setengah `itemSize` lebar, tinggi `itemSize.height` di atas kaki. Barang dinding = rumus `RoomGeometry.boxOf` cabang dinding (`houseWallLeft…houseWallBottom`, ukuran × `houseWallScale`) tanpa `artScale`.
  - `double ItemFootprint.overlapArea(ItemFootprint other)`, `double get area`.
  - `const itemCoverLimit = 0.25;`
  - `bool stacks(({RoomItem item, Spot spot}) a, ({RoomItem item, Spot spot}) b)`: false kalau salah satu `flat`, zonanya beda, atau `terraceHangers` dan ruangan teras (cukup: pemanggil tidak mengirim gantungan). Lantai: barang belakang = kaki y lebih kecil; true kalau `overlapArea > itemCoverLimit * belakang.area`. Dinding: `overlapArea > itemCoverLimit * min(area)`.
  - `freeSpot(item, room, spot, others)` memakai `stacks` (lantai dan dinding), bukan `footprint.overlaps`. Barang dinding tidak dicek jalur pintu. Kisi 41×41 tetap. `footprint` tetap untuk `blocksDoor`.
- Consumes: `RoomItem.baseWidth/baseHeight`, `depthScale`.

- [ ] **Step 1: Test:**
  - `itemBox lantai = kaki dan ukuran desain`: kasur di `spotAtFeet(150, 500)` → `bottom == 500`, `width == 150 * depthScale(500)` (kasur `baseWidth`).
  - `tiang di belakang kasur yang menutupi > 25 % menumpuk`: tiang kaki (150, 470), kasur kaki (150, 500) → `stacks == true`.
  - `menutupi sedikit bagian bawah tidak menumpuk`: kaki tiang (150, 420), kasur kaki (150, 520) → `stacks == false` bila tumpang tindih ≤ 25 % luas tiang (pilih posisi yang memenuhi, assert `overlapArea / area` di test).
  - `karpet tidak pernah menumpuk`.
  - `dua lukisan di posisi sama menumpuk; berjauhan tidak`.
  - `freeSpot memindah barang yang menumpuk dan null kalau penuh` (isi lantai dengan banyak barang besar).
- [ ] **Step 2:** `flutter test test/game/model/house_test.dart` → FAIL (`itemBox` belum ada).
- [ ] **Step 3:** Implementasi di `house.dart`.
- [ ] **Step 4:** `flutter test test/game/model` → PASS (test `room_test` lama untuk barang penutup jalur pintu harus tetap hijau; kalau posisi hasil berubah karena aturan baru, perbarui angka harapannya, bukan perilakunya).
- [ ] **Step 5:** Commit `feat(house): image-box overlap rule for placing items`.

### Task 3: `Room.tidy`, barang baru tidak menumpuk, rapikan sekali saat muat

**Files:**
- Modify: `lib/game/model/room.dart`
- Test: `test/game/model/room_test.dart`

**Interfaces:**
- Consumes: `HouseFloor.stacks`, `freeSpot` (Task 2).
- Produces:
  - `Room tidy(HouseRoom room, {HouseFloor floor = const HouseFloor()})`. Urutan proses: mangkuk (kalau di ruangan itu), lalu barang lain urut katalog (`roomItems`). Barang dipertahankan kalau tidak `stacks` dengan yang sudah dipertahankan dan tidak `blocksDoor`. Selain itu → `freeSpot`; null → Gudang (mangkuk → `allowedSpot`). Gantungan teras (`terraceHangers` di teras) dan karpet dilewati (tetap). Hanya `room` yang disentuh.
  - `Set<RoomItemId> movedBy(Room before, HouseRoom room)` atau padanannya: barang yang spot-nya berubah atau masuk Gudang (dipakai layar untuk animasi dan pesan).
  - `({Room room, HouseRoom? at}) buyPlaced(RoomItemId id)`: `buy` sekarang = beli + taruh di tempat pertama yang muat: `freeSpot` ruang tengah dari `defaultSpot` → teras (kalau `canPlaceIn`, dari `defaultSpot`) → Gudang (`at == null`). `Room buy(id)` = `buyPlaced(id).room`.
  - `bool tidied` + JSON `"tidy": 1`. `Room.fromJson` tanpa `tidy` → hasil `Room(...)` lalu `tidy(living)` dan `tidy(terrace)`, `tidied = true`. `Room.initial` dan `Room()` baru: `tidied = true`. `toJson` selalu menulis `tidy: 1`. Ikut `==`/`hashCode`.
- [ ] **Step 1: Test:**
  - `tidy memindah barang yang menumpuk, sisanya tetap` (kasur dan sofa di spot sama → satu pindah, lukisan berjauhan tetap).
  - `tidy dua kali sama dengan sekali`.
  - `tidy ruangan penuh → Gudang, tidak ke ruangan lain` (21 barang ditumpuk di ruang tengah: `placedIn(terrace)` tidak bertambah, `stored` tidak kosong, mangkuk tetap ditaruh).
  - `tidy tidak menyentuh ruangan lain`.
  - `buy barang yang spot bawaannya terisi → tempat kosong terdekat`, `buy saat ruang tengah penuh → teras`, `barang dinding penuh → Gudang (at null)`.
  - `fromJson tanpa tidy merapikan; dengan tidy tidak` (simpanan tumpuk + `tidy: 1` → spot persis sama).
  - `toJson menulis tidy 1`.
- [ ] **Step 2:** `flutter test test/game/model/room_test.dart` → FAIL.
- [ ] **Step 3:** Implementasi.
- [ ] **Step 4:** `flutter test test/game/model test/app/progress_test.dart` → PASS (perbarui harapan beli lama di `progress_test` grup `rumah` hanya kalau posisinya memang berubah).
- [ ] **Step 5:** Commit `feat(room): tidy rooms, place new items where they fit, tidy old saves once`.

### Task 4: Controller rapikan + batalkan, sheet beli memberi tahu Gudang

**Files:**
- Modify: `lib/app/progress_scope.dart` (`ProgressController`)
- Modify: `lib/screens/shop/buy_sheet.dart`
- Modify: ARB (kunci baru `buyStoredNote`: id "Rumah penuh, jadi {name} disimpan di Gudang dulu.")
- Test: `test/app/progress_test.dart` (grup `rumah`), `test/screens/shop_screen_test.dart`

**Interfaces:**
- Consumes: `Room.tidy`, `Room.buyPlaced` (Task 3).
- Produces:
  - `Future<Room?> tidyRoom(HouseRoom room)`: simpan dan kembalikan susunan sebelum dirapikan (untuk Batalkan); null kalau tidak ada yang berubah (tidak menyimpan).
  - `Future<void> restoreRoom(Room before)`: kembalikan susunan (dipanggil Batalkan), simpan.
  - `buyItem` tetap `Future<bool>`; sheet sukses membaca `progress.home.room.isPlaced(id)` untuk tahu barangnya masuk Gudang.
- [ ] **Step 1: Test:**
  - `tidyRoom` mengembalikan susunan lama dan tersimpan di store.
  - `tidyRoom` di ruangan yang sudah rapi → null, tanpa tulis.
  - `restoreRoom` mengembalikan susunan lama.
  - Sheet sukses untuk barang yang masuk Gudang menampilkan `buyStoredNote`; tombol `buy-room` tetap ada.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementasi; kunci ARB keempat bahasa; `flutter gen-l10n`; `make_review.py`.
- [ ] **Step 4:** `flutter test test/app/progress_test.dart test/screens/shop_screen_test.dart` → PASS.
- [ ] **Step 5:** Commit `feat(home): tidy and undo in the controller; tell when a new item went to storage`.

### Task 5: Tombol "Rapikan" di mode Hias

**Files:**
- Modify: `lib/screens/room/decorate.dart` (widget baru `TidyButton`, `TidyToast`)
- Modify: `lib/screens/room/room_view.dart:1455-1500` (baris tombol), animasi geser barang
- Modify: `lib/theme/ko_size.dart` bila perlu token; ARB: `decorateTidy` ("Rapikan"), `decorateTidyDone` ("Sudah rapi!"), `decorateTidyUndo` ("Batalkan")
- Test: `test/screens/decorate_test.dart`, `test/screens/overflow_test.dart`

**Interfaces:**
- Consumes: `tidyRoom`, `restoreRoom` (Task 4).
- Produces: kunci widget `decorate-tidy`, `decorate-tidy-undo`.

Letak: di baris mode hias `[DecorateHint (Flexible)] [TidyButton] [DecorateButton Selesai]`. Spec bilang "di kiri"; di kiri sudah ada `DecorateHint`, jadi tombolnya kuletakkan di kiri tombol Selesai. Ini keputusan pembangun, dicatat di DESIGN_NOTES. Gaya tombol mengikuti `DecorateButton` versi tidak-`done` (permukaan, garis), ikon `KoIcons.decorate` atau ikon baru dari desain kalau ada, label `decorateTidy`.

- Barang yang bergeser: `AnimatedPositioned` 300 ms `easeOut` (langsung saat `MediaQuery.disableAnimations`).
- Toast: memakai pola `PraiseToast` (2,4 detik). Teks `decorateTidyDone`, plus tombol `decorateTidyUndo` hanya kalau `tidyRoom` mengembalikan susunan.
- Toast hilang saat barang diseret, Gudang diketuk, atau Selesai.
- Undo hanya sekali; ketukan kedua diabaikan.

- [ ] **Step 1: Test:**
  - `Rapikan memindah barang menumpuk di ruangan yang dibuka saja`.
  - `Batalkan mengembalikan`.
  - `Batalkan dua kali = sekali`.
  - `ruangan rapi: "Sudah rapi!" tanpa Batalkan`.
  - `seret barang sesudah Rapikan menghapus Batalkan`.
  - `kurangi gerak: barang langsung di tempat baru`.
  - `teras: Rapikan ada`.
  - Overflow: mode hias dengan toast di 360×640 teks 130 % keempat bahasa.
- [ ] **Step 2:** Run `flutter test test/screens/decorate_test.dart` → FAIL.
- [ ] **Step 3:** Implementasi + ARB + gen-l10n + review files.
- [ ] **Step 4:** `flutter test test/screens/decorate_test.dart test/screens/overflow_test.dart` → PASS.
- [ ] **Step 5:** Commit `feat(decorate): tidy button with undo`.

### Task 6: Hadiah koin bergiliran

**Files:**
- Create: `lib/game/model/reward_turn.dart`
- Modify: `lib/screens/room/room_view.dart:1828-1858`, `lib/widgets/game_art.dart` (`CoinBubbleView` diberi `more`), ARB `kittyRewardMore` (jamak ICU: id "+{count} lagi", en "+{count} more", pt "+{count}", ru "ещё +{count}")
- Test: `test/game/model/reward_turn_test.dart`, `test/screens/room_life_test.dart` (grup gelembung hadiah)

**Interfaces:**
- Produces: `({KittyId? kitty, int more}) rewardTurn(Iterable<KittyId> inRoom, bool Function(KittyId) eligible)`. `inRoom` diurutkan menurut `KittyId.index`; `kitty` = pertama yang `eligible`, `more` = sisa yang `eligible`.
- `eligible` di layar = `canClaimKittyReward && !isSad && !home.isFresh`.
- `CoinBubbleView(..., more: int)`: chip gelap kecil "+N lagi" di bawah gelembung, hanya kalau `more > 0`; `more` ikut label semantik.
- [ ] **Step 1: Test:**
  - Unit: urutan, tanpa yang eligible → `(null, 0)`, `more` benar.
  - Widget (3 kucing siap di ruang tengah): satu `reward-*`, teks `+2 lagi`; ketuk → kucing berikutnya, `+1 lagi`; ketuk lagi → tanpa chip; ketuk ketiga → tidak ada gelembung.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementasi.
- [ ] **Step 4:** `flutter test test/game/model/reward_turn_test.dart test/screens/room_life_test.dart test/screens/overflow_test.dart` → PASS.
- [ ] **Step 5:** Commit `feat(room): one reward bubble at a time with a count of the rest`.

### Task 7: Rutinitas tenang (giliran jalan, dorongan, jarak antar kucing)

**Files:**
- Modify: `lib/game/model/room_life.dart`
- Modify: `lib/screens/room/room_view.dart` (isi `_life.watching` saat ruangan dibuka/berganti, null saat di gang)
- Test: `test/game/model/room_life_test.dart`

**Interfaces:**
- Produces:
  - Konstanta:
    - `lifeIdleMin = 8.0`, `lifeIdleMax = 20.0`, `lifeUseMin = 8.0`, `lifeUseMax = 14.0`, `lifeSleepMin = 20.0`, `lifeSleepMax = 40.0`.
    - `lifeMaxWalkers = 2`, `lifeStartSeconds = 2.5`, `lifeNudgeSeconds = 8.0`, `lifeWaitSeconds = 3.0` (tunggu saat slot penuh), `lifeCatSpacing = 40.0` px desain.
    - `lifeIdleSeconds`, `lifeUseSeconds`, `lifeSleepSeconds` dihapus.
    - Pemakai di `lane.dart`/`lane_life.dart` diganti dengan konstanta sendiri di sana, nilainya sama dengan nilai lama, supaya gang tidak berubah.
    - Tempat nyaman `idle` memakai `lifeIdleMax`; `lounge`/`sleep` memakai `lifeSleepMin`–`lifeSleepMax`.
  - `HouseRoom? watching`. Saat nilainya berganti, `_still` diset ke `lifeNudgeSeconds − lifeStartSeconds`.
  - Kucing baru di `sync` mulai dengan `remaining = random * lifeIdleMax`.
  - `bool walking(CatLife)`: activity walking/climbing/descending/leaving/entering.
  - `bool lively(CatLife)`: walking, atau `using` barang mainan atau `ItemUse.read`.
  - Di `_next`: kalau undian memilih pindah (barang, tempat, pindah ruangan) dan `walking` di ruangan itu ≥ `lifeMaxWalkers`, pilihan itu batal. Kucing istirahat dengan `remaining = lifeWaitSeconds`. Pengecualian: kucing lapar ke mangkuk, kucing yang diajak, dan kucing yang keluar ke gang.
  - Dorongan, di `advance` (tidak saat `paused`): untuk `watching`, kalau tidak ada kucing `lively`, `_still += seconds`. Kalau `_still ≥ lifeNudgeSeconds`, satu kucing `idle` yang tidak lesu dan tidak di barang dipilih acak lalu `_next(cat, events, move: true)` (opsi diam dibuang). `_still = 0` saat ada yang `lively`.
  - Jarak antar kucing: opsi barang atau tempat yang `stand`-nya < `lifeCatSpacing` dari kaki atau tujuan kucing lain seruangan dibuang dari undian. Tidak berlaku untuk mangkuk; kucing lapar tetap ke mangkuk.
- [ ] **Step 1: Test** (seed tetap, 9 kucing, rumah penuh):
  - `paling banyak 2 kucing berjalan per ruangan` (advance 0,1 detik × 3000, cek tiap tick).
  - `ruangan yang ditonton bergerak dalam 3 detik` (sesudah `watching = living`).
  - `tidak pernah 8,5 detik tanpa kucing lively di ruangan ditonton` (selama ada kucing idle yang bisa didorong).
  - `diam 8–20 detik`, `tidur 20–40 detik`.
  - `tujuan diam tidak dalam 40 px dari kucing lain`.
  - `kucing lapar tetap ke mangkuk walau slot penuh`.
  - `paused: tidak ada dorongan`.
  - Test lama yang memakai angka 2,6/3/6 detik: majukan waktu memakai konstanta baru.
- [ ] **Step 2:** `flutter test test/game/model/room_life_test.dart` → FAIL.
- [ ] **Step 3:** Implementasi + `watching` di `RoomView` (pager `onRoom`/`onArrive`, `_inLane`).
- [ ] **Step 4:** `flutter test test/game/model test/screens/room_life_test.dart test/screens/house_pager_test.dart test/screens/lane_*` → PASS.
- [ ] **Step 5:** Commit `feat(life): calmer routine with walker cap, nudge, and spacing`.

### Task 8: Mangkuk di tepi dan label mangkuk

**Files:**
- Modify: `lib/screens/room/room_geometry.dart` (`userBoxOf`/`catBoxOf` mangkuk dijepit ke dalam ruangan) atau batas spot mangkuk di `HouseFloor.allowedSpot` untuk `RoomItemId.mangkuk` (pilih satu; yang lebih kecil dampaknya)
- Modify: `lib/screens/room/room_view.dart` (`BowlRefillLabel`: disembunyikan selama ada kucing di/menuju mangkuk, atau diletakkan di bawah mangkuk)
- Test: `test/screens/room_geometry_test.dart`, `test/screens/room_life_test.dart`

- [ ] **Step 1: Test:**
  - `kucing makan di mangkuk paling kanan tetap di dalam lebar ruangan`: `userBoxOf(mangkuk, boxOf(mangkuk, Spot(1, 1)))` → `right <= room.width`, `left >= 0`.
  - `label mangkuk tidak menimpa kucing yang makan`: rect label ∩ rect kucing kosong, atau label tidak ada.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementasi.
- [ ] **Step 4:** Run → PASS; potret `flutter test test/screenshots --dart-define=SCREENSHOTS=true`, cek `19-kamar*.png` dengan mata.
- [ ] **Step 5:** Commit `fix(room): keep the eating cat and bowl label inside the room`.

### Task 9: Pose baca dan salinan gambar rak buku

**Files:**
- Modify: `tool/design/make_lane_svg.py` (`--kitty` juga menulis `roomItemBackSvgs`, `roomItemFrontSvgs`, `roomItemViewBoxes` dari `Barang.dc.html` Gang Depan, regex sama dengan `design_sync_test`)
- Modify (dibuat alat): `lib/game/render/design_svg_home.dart`
- Modify: `lib/game/render/kitty.dart` (`KittyPose.baca`, `kittyVals`: `isBaca`, `kacaBaca`, `bacaInk`, `bukuT`, `pawLine`, `pageOn`, `pageAnim`, `readAnim`, transform `baca`, ekor `kcTail 3.8s`, mata/mulut seperti desain; persis logika `Kucing.dc.html` baris `renderVals`)
- Modify: `test/game/render/design_sync_test.dart` (grup Barang membaca `_lane` Barang.dc.html; harapan back 25, front 9)
- Modify: `lib/l10n/names.dart` + ARB (label pose `kittyPoseBaca` "membaca buku", `kittyReadingGlasses` "berkacamata baca" mengikuti pola label pose yang ada)
- Modify: `lib/gallery/` (pose baca di `/galeri/kucing` dan `/galeri/gerak`)
- Test: `test/game/render/kitty_test.dart`

**Interfaces:**
- Produces: `KittyPose.baca`; `roomItemBackSvgs['rakBuku']`, `roomItemFrontSvgs['rakBuku']`, `roomItemViewBoxes['rakBuku'] == (0, 0, 112, 140)`.
- [ ] **Step 1: Test** (`kitty_test`):
  - `baca: kacamata baca tampil tanpa aksesoris` (piksel bingkai di koordinat lensa kiri `(37, 47.6)` desain berwarna `#8E5A30` untuk Oyen).
  - `baca + kacamata: hanya kacamata aksesoris` (`kittyVals(...)['kacaBaca'] == false`).
  - `Arang: bacaInk terang #D8A86F`.
  - `halaman dibalik bergerak hanya saat time != null`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Jalankan `python tool/design/make_lane_svg.py docs/design/gang-depan/project lib/game/render/design_svg_lane.dart --kitty lib/game/render/design_svg_home.dart`, lalu implementasi `kitty.dart`, label, dan galeri.
- [ ] **Step 4:** `flutter test test/game/render` → PASS (termasuk `design_sync_test` dan `svg_binding_test`).
- [ ] **Step 5:** Commit `feat(render): reading pose with auto reading glasses; bookshelf art from the design`.

### Task 10: Rak Buku di katalog, Toko, dan rutinitas

**Files:**
- Modify: `lib/game/model/home_items.dart` (`ItemUse.read`; `RoomItemId.rakBuku` sesudah `rak` di enum dan `roomItems`; `RoomItem(rakBuku, 220, floor, ItemUse.read, 112, 140, defaultX, defaultY)` dengan `defaultSpot` di kaki desain ±(258, 410))
- Modify: `lib/game/model/house.dart` (`canPlaceIn`: rak buku hanya ruang tengah)
- Modify: `lib/game/render/room_item_art.dart` (`_inUse[rakBuku]`: ukuran 150×152, `artOffset (38, 8)`, `catOffset (0, 52)`, `catSize 100`, `pose KittyPose.baca`, menghadap kanan)
- Modify: `lib/game/model/room_life.dart` (`lifeUseWeights[ItemUse.read] = 2`)
- Modify: `lib/l10n/names.dart` + ARB (`roomItemName`/`roomItemDesc` rakBuku, id "Rak Buku" / "Buku cerita ikan. Kucing yang baca pakai kacamata, biar kelihatan pintar.")
- Modify: `tool/profile_room.dart`, `test/screens/overflow_test.dart`, `test/screenshots/*` (21 barang)
- Test: `test/game/model/home_items_test.dart`, `test/game/render/room_item_art_test.dart`, `test/screens/shop_screen_test.dart`, `test/game/model/room_life_test.dart`

- [ ] **Step 1: Test:**
  - `21 barang toko; rakBuku 220, lantai, read`.
  - `defaultSpot kaki ±(258, 410)`.
  - `tidak boleh di teras`.
  - `inUse rakBuku = tabel desain`.
  - `kartu shop-item-rakBuku di tab Barang`.
  - `kucing di rak buku berpose baca` (`RoomLife` + `pathTo` sampai `using` → `ItemInUse.pose == KittyPose.baca`).
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementasi + ARB + gen-l10n + review files. Perbarui hitungan 20 → 21 di test, alat profil, dan CLAUDE.md.
- [ ] **Step 4:** `flutter test` (semua) → PASS.
- [ ] **Step 5:** Commit `feat(home): bookshelf item where cats read`.

### Task 11: Dokumen, potret, cek akhir, PR

**Files:**
- Modify: `CLAUDE.md` (bagian Struktur: API baru `itemBox`/`stacks`/`tidy`/`buyPlaced`/`tidied`, `tidyRoom`/`restoreRoom`, `rewardTurn`, `watching`/konstanta rutinitas, `KittyPose.baca`, `ItemUse.read`, 21 barang, generator `--kitty` menulis barang, bidang kosong dihapus)
- Modify: `docs/ROADMAP.md` (langkah 40 dicentang), `docs/DESIGN_NOTES.md` (letak tombol Rapikan, 25 %, harga 220, baca hanya di rak, angka rutinitas)

- [ ] **Step 1:** Potret `flutter test test/screenshots --dart-define=SCREENSHOTS=true`. Cek `19-kamar*` dan `19-teras*`: tidak ada barang bertumpuk, hanya satu gelembung, ada rak buku.
- [ ] **Step 2:** Tulis dokumen.
- [ ] **Step 3:** `/check` → format, analyze `No issues found!`, test semua lulus.
- [ ] **Step 4:** `superpowers:requesting-code-review` (satu subagent effort high), `receiving-code-review`, perbaiki, `verification-before-completion`.
- [ ] **Step 5:** Commit `docs: step 40 tidy house`, `git push -u origin feat/rumah-rapi`, `gh pr create --base main --title "feat: rumah yang rapi"`. Badan PR berbahasa Indonesia ("Langkah 40 roadmap: …", daftar perubahan, asumsi, Verifikasi). Kirim link.
