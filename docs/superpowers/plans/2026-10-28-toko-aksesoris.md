# Toko dan aksesoris (langkah 22) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task (sesi utama, sesuai `CLAUDE.md`). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Layar Toko di rute `/toko` untuk membeli barang, kucing, aksesoris (dengan pratinjau langsung), dan camilan dengan koin, beserta gambar kucing kamar, barang, camilan, dan ikon aksesoris dari desain.

**Architecture:** Gambar baru disalin utuh dari `<svg>` desain ke `lib/game/render/design_svg.dart` dan digambar lewat `SvgTemplate` (diperluas untuk nama bertitik `{{c.fur}}` dan `sc-for`). Sprite kucing kamar = satu template dengan 12 pose, 9 palet warna, dan 16 aksesoris di grup kepala; `KittyLook` data Dart murni, `paintKitty` fungsi `Canvas`, gerakan baru dihidupkan di langkah 24. Layar Toko = `StatefulWidget` dengan empat tab di satu `Scaffold`; pembelian barang/kucing/aksesoris lewat sheet `showBuySheet` (`showKoSheet`), camilan langsung dari kartunya seperti desain. Semua aksi memakai `ProgressController` yang sudah ada dari langkah 21.

**Tech Stack:** Flutter (Material + token `KoTheme`), `go_router`, `SvgTemplate` sendiri, `flutter_test`, `flutter gen-l10n`.

**Spec:** `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md` (Toko, Aksesoris, Koin, Format gambar, Teks baru) + prompt langkah 22 di `docs/ROADMAP.md`. Desain: `docs/design/rumah-oyen/project/` (`Toko.dc.html`, `TabToko`, `KartuToko`, `SheetBeli`, `ChipKoin`, `Kucing`, `Barang`, `IkonAksesoris`, `AksesorisPreview`, artboard `Toko*`).

## Global Constraints

- Harga, urutan katalog, teks Indonesia, warna, ukuran, dan tata letak: dari desain. Katalog sudah ada di `lib/game/model/` (langkah 21) — jangan ubah harga atau urutannya.
- Gambar desain tidak diketik ulang: isi `<svg>` disalin utuh ke `design_svg.dart`, dijaga `test/game/render/design_sync_test.dart` (dilewati kalau `docs/design/` tidak ada).
- Tidak ada warna, ukuran, atau gaya teks hardcode di widget: semuanya lewat `context.koColors/koType/koSpace/koRadius/koShadow/koSize`.
- Semua teks pemain dan label pembaca layar ada di keempat ARB (`app_en.arb` template lebih dulu beserta deskripsinya, lalu `id`, `pt`, `ru`; jamak ICU termasuk tiga bentuk Rusia), lalu `flutter gen-l10n`. Nama dan deskripsi katalog lewat `lib/l10n/names.dart`. Model Dart murni mengembalikan data, bukan kalimat.
- Nada santai dan jenaka yang sama di keempat bahasa; nama katalog diterjemahkan artinya, hanya "Oyen" dan "Ginger Logic" sama di semua bahasa.
- Gagal tanpa efek, dua ketukan tidak membayar dua kali, saldo tidak pernah negatif: semua lewat `ProgressController.buyItem/buyKitty/buyAccessory/buySnack/wearAccessory`.
- Tidak ada `pumpAndSettle` yang tidak pernah selesai: pesan reaksi (`flash`) hilang sendiri lewat `Timer`, dan mati saat `MediaQuery.disableAnimations`.
- `flutter analyze` bersih dan `flutter test` hijau sebelum selesai (`/check`).

## Keputusan saya (dicatat di `docs/DESIGN_NOTES.md` "Langkah 22")

- **Sprite kucing diport penuh (12 pose, 9 kucing, 16 aksesoris) tanpa gerakan.** Semua nilai gaya animasi desain (`tailStyle`, `blinkStyle`, …) diisi string kosong; langkah 24 menggantinya dengan fungsi waktu. `KittyLook` sudah menerima `time` supaya pemanggil langkah 24 tidak berubah.
- **Varian "sedang dipakai" barang (`dipakai`)** disalin ke repo tapi belum diport: `itemVals` selalu `pakai: false`. Langkah 23 memakainya.
- **Camilan dibeli langsung dari kartunya** (ikut desain, tanpa sheet konfirmasi); barang, kucing, dan aksesoris lewat sheet.
- **"Lihat di kamar"** menuju Beranda sampai langkah 23.
- **Tombol Toko di Beranda** memakai `_MenuButton` yang sudah ada, jadi barisnya tiga tombol; dilepas di langkah 23.
- **Pratinjau aksesoris** dimulai dari aksesoris pertama katalog (Pita) dan kucing Oyen; "Coba di:" hanya kucing yang dimiliki.
- **Gambar aksesoris di pose tidur** memakai skala 0,72 dan geseran desain (`accT`), dan ujung syal/lonceng/bandana disembunyikan di pose rebahan, lesu, dan tidur — ikut desain.

## Review Focus

- Koin tepat sama dengan harga (`coins == price`): tombol beli aktif dan pembelian berhasil. Test di Task 8.
- Dua ketukan cepat di tombol "Beli" sheet dan di tombol beli camilan: koin terpotong sekali. Test di Task 8 dan Task 9.
- Stok camilan sudah 99: tombol beli tidak menambah stok dan tidak memotong koin. Test di Task 9.
- Kucing yang baru dibeli langsung muncul di "Coba di:", dan aksesoris yang dipakai kucing lain tetap bisa dipakai kucing ini. Test di Task 10.
- Kartu dan sheet di 360×640 dengan teks 130% di keempat bahasa (nama panjang Rusia): tidak ada overflow dan semuanya bisa digulir. Test di Task 11.

---

### Task 1: `SvgTemplate` mengerti nama bertitik dan `sc-for`

Sprite kucing desain memakai `{{c.fur}}`, `{{a.pita}}`, dan `<sc-for list="{{c.pBody}}" as="q">` dengan `{{q.cx}}`. Tanpa ini isi `<svg>` tidak bisa disalin utuh.

**Files:**
- Modify: `lib/game/render/svg_template.dart`
- Test: `test/game/render/svg_template_test.dart`

**Interfaces:**
- Produces: `SvgTemplate.render(Map<String, Object> vals)` menerima nilai bersarang (`'c': {'fur': '#F29A3A', 'pBody': [{'cx': 1, …}]}`); `{{a.b}}` dibaca dari `vals['a']['b']`, `sc-if value="{{a.b}}"` memakai bool di sana, dan `<sc-for list="{{c.pBody}}" as="q">` mengulang anak-anaknya dengan `q` terikat tiap elemen daftar (tiap elemen `Map<String, Object>`).

- [ ] **Step 1: Tulis test yang gagal** di `test/game/render/svg_template_test.dart`:
  - `test('nama bertitik dibaca dari map bersarang')`: template `<circle cx="{{p.x}}" cy="1" r="1" fill="{{c.fur}}"></circle>` dengan `{'p': {'x': 5}, 'c': {'fur': '#112233'}}` → `length` 1 dan `bounds` berpusat di x 5.
  - `test('sc-if bertitik')`: `<sc-if value="{{a.pita}}">` tampil kalau `{'a': {'pita': true}}`, hilang kalau false, dan hilang kalau kuncinya tidak ada.
  - `test('sc-for mengulang anak per elemen daftar')`: `<sc-for list="{{c.p}}" as="q"><ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="1" ry="1" fill="{{q.f}}"></ellipse></sc-for>` dengan dua elemen → `length` 2, `bounds` mencakup kedua titik.
  - `test('sc-for daftar kosong tidak menggambar')` → `length` 0.
  - `test('nama yang tidak ada tetap melempar')`: `{{c.tidakAda}}` → `ArgumentError`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/game/render/svg_template_test.dart` → FAIL (nama bertitik tidak dikenal / `<sc-for>` belum didukung).
- [ ] **Step 3: Implementasi.** Ganti pola `_placeholder` supaya menerima `(\w+(?:\.\w+)*)`, dan tambahkan `Object? _lookup(String path, Map<String, Object> vals)` yang menuruni map per titik. `_emit` menangani `el.name == 'sc-for'`: baca `list` lewat `_lookup` (harus `List`), ambil nama dari atribut `as`, lalu untuk tiap elemen `_emit(el.children, {...vals, as: elemen}, …)`. `sc-for` tanpa `list`/`as` atau dengan nilai bukan `List` melempar `FormatException`/`ArgumentError` seperti `sc-if`.
- [ ] **Step 4: Jalankan test** `flutter test test/game/render/svg_template_test.dart` → PASS, dan `flutter test test/game/render` → PASS (template lama tidak berubah).
- [ ] **Step 5: Commit** `feat(render): nested vals and sc-for in SvgTemplate`.

### Task 2: SVG desain baru disalin ke `design_svg.dart`

**Files:**
- Modify: `lib/game/render/design_svg.dart`, `test/game/render/design_sync_test.dart`
- Scratch: skrip sekali pakai di direktori scratchpad untuk menyalin (tidak di-commit)

**Interfaces:**
- Produces: `const kittySvg` (isi `<svg>` `Kucing.dc.html`), `const accessoryIconSvg` (isi `<svg>` `IkonAksesoris.dc.html`), `const roomItemBackSvgs` dan `const roomItemFrontSvgs` (`Map<String, String>`, kunci = kode desain seperti `kardus`, `ikanAsin`; isi = anak-anak `<svg>` di blok `sc-if value="{{v.<kode>}}"` lapisan belakang dan lapisan depan `Barang.dc.html`), `const kittyUsedItemSvg`? tidak ada — varian `dipakai` ikut di `roomItemFrontSvgs`/`roomItemBackSvgs` hanya kalau memang ada di lapisan itu.

- [ ] **Step 1: Salin isi SVG dengan skrip** (bukan tangan): dari `docs/design/rumah-oyen/project/Kucing.dc.html` dan `IkonAksesoris.dc.html` ambil isi `<svg …>\n(…)\n</svg>` yang pertama; dari `Barang.dc.html` ambil tiap blok `<sc-if value="{{v.<kode>}}" …>` → isi `<svg>`-nya, lapisan pertama ke `roomItemBackSvgs`, lapisan kedua (blok yang muncul sesudah `sc-if value="{{pakai}}"`) ke `roomItemFrontSvgs`. Tulis hasilnya sebagai `const` raw string (`r'''…'''`) di `design_svg.dart`, dengan komentar sumbernya seperti konstanta yang sudah ada.
- [ ] **Step 2: Tulis test sinkron** di `design_sync_test.dart`: tambahkan `const _home = 'docs/design/rumah-oyen/project'` beserta `_readHome`/`_innerHome` seperti `_read`/`_inner`, dan grup `isi SVG sama dengan desain rumah Oyen` dengan test:
  - `Kucing.dc.html` → `expect(_lf(kittySvg), _innerHome('Kucing.dc.html'))`
  - `IkonAksesoris.dc.html` → sama untuk `accessoryIconSvg`
  - `Barang.dc.html` → untuk tiap kunci `roomItemBackSvgs`/`roomItemFrontSvgs`, blok `sc-if` ke-n di desain berisi isi `<svg>` yang sama, dan jumlah kuncinya 24 (belakang) dan 8 (depan)
  - test dilewati dengan `skip: missing` seperti grup yang sudah ada.
- [ ] **Step 3: Jalankan test** `flutter test test/game/render/design_sync_test.dart` → PASS (atau skip di komputer tanpa desain).
- [ ] **Step 4: Commit** `feat(render): copy kitty, item, and accessory icon svg from design`.

### Task 3: Sprite kucing kamar

**Files:**
- Create: `lib/game/render/kitty.dart`, `lib/game/render/kitty_painter.dart`
- Modify: `lib/game/render/render.dart` (export)
- Test: `test/game/render/kitty_test.dart`

**Interfaces:**
- Consumes: `kittySvg` (Task 2), `SvgTemplate` bersarang (Task 1), `KittyId` (`lib/game/model/kitties.dart`), `AccessoryId` (`lib/game/model/accessories.dart`).
- Produces:
  - `enum KittyPose { idle, lick, walk1, walk2, sleep, eat, play, scratch, happy, lesu, rebah, petted }`
  - `enum KittyFacing { down, left, right }`
  - `enum KittyToy { ball, mouse, none }`
  - `class KittyLook` dengan `const KittyLook({required KittyId kitty, KittyPose pose = KittyPose.idle, KittyFacing facing = KittyFacing.down, AccessoryId? accessory, KittyToy toy = KittyToy.ball, bool post = true, double time = 0})`, `static const viewBox = 100.0`, `copyWith`, `==`/`hashCode` (dipakai cache).
  - `class KittyColors` + `const kittyPalette = <KittyId, KittyColors>{…}` (port tabel `P` desain, termasuk corak `pBody`/`pScratch`/`pLesu`/`pHead`/`pSleepBody`/`pSleepHead`, `maskOn`, `blazeOn`, `earTipOn`, `stripes`, `edge`).
  - `Map<String, Object> kittyVals(KittyLook look)` (port `renderVals()` `Kucing.dc.html`; semua nilai gaya animasi `''`).
  - `void paintKitty(Canvas canvas, KittyLook look, {double size = KittyLook.viewBox})` — menggambar di pojok kiri atas, `overflow: visible` (topi boleh keluar kotak), hasil `render` di-cache per `KittyLook`.

- [ ] **Step 1: Tulis test yang gagal** di `test/game/render/kitty_test.dart` (pola `test/game/render/painters_test.dart`: gambar ke `Image`, sampler warna piksel di koordinat desain 100×100 dengan tepi, `_near` toleransi 2):
  - `test('semua kombinasi kucing, pose, dan aksesoris tergambar')`: untuk tiap `KittyId` × `KittyPose` × (`null` + semua `AccessoryId`) `paintKitty` tidak melempar dan `kittyVals` punya semua kunci yang dipakai template (cukup: tidak melempar).
  - `test('warna bulu per kucing di tengah badan')`: pose `idle`, piksel (50, 71) = `kittyPalette[KittyId.oyen]!.fur` (`#F29A3A`), dan untuk `arang` `#2E2929`.
  - `test('pita digambar di kepala kanan')`: Oyen `idle` + `AccessoryId.pita`, piksel di simpul pita (64, 21) ≈ `#D9607A`, dan tanpa aksesoris titik itu bukan warna pita.
  - `test('aksesoris mengikuti pose')`: `AccessoryId.mahkotaRaja` di pose `idle` (permata tengah di (50, 18.4) ≈ `#E0453A`) dan di pose `sleep` (mahkota diskala 0,72 dan digeser, permata di titik `accT` yang sama ≈ warna mahkota), lalu pose `lesu` menyembunyikan lonceng `AccessoryId.kalung` (titik lonceng = warna latar).
  - `test('menghadap kanan dicerminkan')`: `facing: right` → piksel ekor ada di sisi kiri gambar.
  - `test('Mochi bertopeng dan Bos bergaris putih')`: piksel topeng (50, 52.5) ≈ `#7A5842` untuk `mochi`; blaze putih (50, 35) = `#FFFFFF` untuk `bos`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/game/render/kitty_test.dart` → FAIL (`kitty.dart` belum ada).
- [ ] **Step 3: Implementasi `kitty.dart`** (data + palet, Dart murni tanpa Flutter) **lalu `kitty_painter.dart`** (`kittyVals` + `paintKitty`). `kittyVals` mengikuti desain: `flipT`, `headT` per pose, `faceT` samping, `earLT`/`earRT` (lesu −58°/58°), jalur ekor per pose (`tails`), `pawL`/`pawR` per langkah jalan, mata/mulut per pose, `blushOp` (petted 0,8), `neckOn`, `dangleOn`, `acc2On`, `accT` (`translate(-2 30.8) scale(0.72)` saat tidur), `dangle2`, `toyBall`/`toyMouse`, `showPost`. Pose `walk` tidak ada di enum: pemanggil memilih `walk1`/`walk2`.
- [ ] **Step 4: Jalankan test** `flutter test test/game/render/kitty_test.dart` → PASS.
- [ ] **Step 5: Commit** `feat(render): room kitty sprite with poses and accessories`.

### Task 4: Gambar barang, camilan, dan ikon aksesoris

**Files:**
- Create: `lib/game/render/room_item_art.dart`, `lib/game/render/accessory_icon.dart`
- Modify: `lib/game/render/render.dart`
- Test: `test/game/render/room_item_art_test.dart`

**Interfaces:**
- Consumes: `roomItemBackSvgs`/`roomItemFrontSvgs`/`accessoryIconSvg` (Task 2), `RoomItemId`, `SnackId`, `AccessoryId`.
- Produces:
  - `abstract final class RoomItemArt { static Size sizeOf(RoomItemId id); static Size snackSizeOf(SnackId id); static const maxScale = 2.2; static double fitScale(Size art, Size box); }` — `sizeOf` dari tabel `D` desain (ukuran diam), `fitScale` = `min(box.width / art.width, box.height / art.height, maxScale)`.
  - `void paintRoomItemArt(Canvas canvas, RoomItemId id, {Size? box, bool full = true})` — menggambar lapisan belakang lalu depan di koordinat `sizeOf(id)`; dengan `box` diskalakan `fitScale` dan dipusatkan di `box`. `full` = isi mangkuk.
  - `void paintSnackArt(Canvas canvas, SnackId id, {Size? box})`.
  - `abstract final class AccessoryIconArt { static const viewBox = 48.0; }` + `void paintAccessoryIcon(Canvas canvas, AccessoryId? id, {double size = AccessoryIconArt.viewBox})` (null = ikon "tanpa aksesoris" desain).
- [ ] **Step 1: Tulis test yang gagal** di `test/game/render/room_item_art_test.dart` (sampler piksel seperti Task 3):
  - `test('semua barang, camilan, dan ikon aksesoris tergambar')`: tiap `RoomItemId`, `SnackId`, dan `AccessoryId` (plus null) tidak melempar.
  - `test('ukuran gambar sama dengan desain')`: `RoomItemArt.sizeOf(RoomItemId.kasur)` = `Size(150, 76)`, `kardus` = `Size(122, 82)`, `tiang` = `Size(50, 152)`, `snackSizeOf(SnackId.susu)` = `Size(42, 20)`.
  - `test('lapisan depan digambar di atas lapisan belakang')`: `kardus` → piksel di badan kardus (55, 50) ≈ `#C8955A` (lapisan depan), bukan warna tutup belakang `#7E5228`.
  - `test('mangkuk kosong beda dari penuh')`: piksel isi mangkuk berbeda antara `full: true` dan `full: false`.
  - `test('fitScale mengecilkan ke kotak kartu dan dibatasi 2,2')`: `fitScale(Size(150, 76), Size(128, 80))` ≈ 128/150; `fitScale(Size(32, 30), Size(128, 80))` = 2.2.
  - `test('ikon aksesoris memakai viewBox 48')`: piksel pita ikon di (24, 23) ≈ `#D9607A`; ikon null bergaris putus-putus warna `#CDB48C`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/game/render/room_item_art_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** kedua berkas. `itemVals` mengisi `v.<kode>` (hanya barang yang diminta true), `penuh`/`kosong`, dan `pakai: false`; `viewBox` yang mulai di x negatif (`kardus` `-6 0 122 82`) digeser saat menggambar.
- [ ] **Step 4: Jalankan test** → PASS. Juga `flutter test test/game/render` → PASS.
- [ ] **Step 5: Commit** `feat(render): room item, snack, and accessory icon art`.

### Task 5: Teks katalog dan teks Toko di keempat ARB

**Files:**
- Modify: `lib/l10n/app_en.arb`, `app_id.arb`, `app_pt.arb`, `app_ru.arb`, `lib/l10n/names.dart`, `lib/l10n/app_localizations*.dart` (hasil `gen-l10n`)
- Test: `test/l10n/names_test.dart`, `test/l10n/arb_test.dart` (sudah umum), `test/l10n/plural_test.dart`

**Interfaces:**
- Produces di `names.dart`:
  - `String roomItemName(AppLocalizations l, RoomItemId id)` dan `roomItemDesc`
  - `String kittyName(AppLocalizations l, KittyId id)` dan `kittyDesc` (Oyen juga punya deskripsi, dipakai galeri)
  - `String accessoryName(AppLocalizations l, AccessoryId id)` dan `accessoryDesc`
  - `String snackName(AppLocalizations l, SnackId id)` dan `snackDesc`
  - `String rarityName(AppLocalizations l, Rarity rarity)`
  - `String kittyLabel(AppLocalizations l, KittyLook look)` (nama + pose + aksesoris, seperti `aria-label` desain)
- Produces kunci ARB (nama kunci pasti, nilai Indonesia dari desain):
  - katalog: `roomItem<Kode>` + `roomItem<Kode>Desc` (20 barang + `roomItemMangkuk` tanpa Desc), `kitty<Kode>` + `kitty<Kode>Desc` (9 kucing; Oyen punya Desc untuk galeri), `accessory<Kode>` + `accessory<Kode>Desc` (16), `snack<Kode>` + `snack<Kode>Desc` (5)
  - kelangkaan: `rarityCommon`, `rarityRare`, `raritySpecial`
  - layar: `shopTitle`, `shopBack`, `shopTabItems`, `shopTabKitties`, `shopTabAccessories`, `shopTabSnacks`, `shopKittyIntro`, `shopSnackIntro`, `shopOwnedTag`, `shopLivesHere`, `shopNotEnough`, `shopShortBy(n)` (jamak), `shopAdopt(n)`, `shopBuy(n)`, `shopStock(n)`, `shopTryOn`, `shopPreviewOf(name)`, `shopWearFree`, `shopRemoveFree`, `shopNotEnoughBy(n)`, `shopPlayFirst`, `shopWornBy(names)`, `shopFlashNice`, `shopFlashRemoved`, `shopFlashSpent(n)` (jamak)
  - sheet: `buySheetLabel(name)`, `buySuccessOverline`, `buySuccessItem(name)`, `buySuccessItemBody`, `buySuccessKitty(name)`, `buySuccessKittyBody`, `buySuccessAccessory(name)`, `buySuccessAccessoryBody(name)`, `buyAccessoryInfo`, `buyPay(n)` (jamak), `buyLater`, `buyAgain`, `buySeeRoom`, `buyWearOn(name)`, `buyNotEnoughHelp`
  - pembaca layar: `shopCardBuyLabel(name, n)`, `shopCardShortLabel(name, n)`, `shopCardOwnedLabel(name)`, `shopCardWornLabel(name, who)`, `shopCardLivesLabel(name)`, `shopAccessoryBuyLabel(name, n)`, `shopAccessoryShortLabel(name, n)`, `shopAccessoryOwnedLabel(name)`, `shopAccessoryWornLabel(name, who)`, `shopSnackBuyLabel(name, n)`, `shopSnackShortLabel(name, n)`, `shopPreviewPick(name)`, `kittyLabel(name, pose)` + `kittyLabelAccessory(name, pose, accessory)` (`select` ICU untuk pose), `shopFlashLabel`
  - tombol Beranda sementara: `shop` (label tombol "Toko")
- [ ] **Step 1: Tulis test yang gagal** di `test/l10n/names_test.dart`: grup `katalog`:
  - nama Indonesia tiap `RoomItemId`, `KittyId`, `AccessoryId`, `SnackId` sama dengan daftar literal yang disalin dari `Toko.dc.html` (mis. `RoomItemId.kardus` → `'Kardus Nyaman'`, `KittyId.kopiSusu` → `'Kopi Susu'`, `AccessoryId.mahkotaRaja` → `'Mahkota Raja'`, `SnackId.puding` → `'Puding Ikan'`).
  - deskripsi Indonesia tiap barang/kucing/aksesoris/camilan sama dengan desain untuk tiga contoh per jenis, dan tidak kosong untuk semuanya.
  - nama dan deskripsi di `en`, `pt`, `ru` tidak kosong dan tidak sama dengan nilai Indonesia untuk tiga contoh per jenis (mis. `roomItemKardus` en ≠ id).
  - `rarityName` ketiga nilai per bahasa tidak kosong.
  - `kittyLabel` Oyen pose `idle` tanpa aksesoris = `'Oyen duduk diam'`, dengan `AccessoryId.pita` = `'Oyen duduk diam, memakai pita'`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/l10n` → FAIL.
- [ ] **Step 3: Tambah kunci** ke `app_en.arb` (beserta `@kunci` deskripsi) lalu `app_id.arb` (nilai desain apa adanya), `app_pt.arb`, `app_ru.arb` (jamak tiga bentuk), jalankan `flutter gen-l10n`, dan tulis fungsi `names.dart`.
- [ ] **Step 4: Jalankan test** `flutter test test/l10n` → PASS; `flutter analyze` bersih.
- [ ] **Step 5: Commit** `feat(l10n): shop catalog names, descriptions, and copy`.

### Task 6: Token tema, ikon, widget pembungkus, dan galeri

**Files:**
- Modify: `lib/theme/ko_colors.dart`, `lib/theme/ko_type.dart`, `lib/theme/ko_size.dart`, `lib/widgets/ko_icon.dart`, `lib/widgets/game_art.dart`, `lib/gallery/gallery_screen.dart`, `lib/app/routes.dart`, `lib/app/router.dart`
- Create: `lib/gallery/gallery_kitty_screen.dart`
- Test: `test/widgets/game_art_test.dart`, `test/theme/theme_test.dart` (kalau ada daftar token), `test/screens/overflow_test.dart` (rute galeri baru ditambah di Task 11)

**Interfaces:**
- Produces:
  - Token warna baru dari desain: `successSoft` `#D4F1EB`, `rareChip` `#D6ECF7`, `onRareChip` `#1F5E80`, `specialChip` `#F6DDF0`, `onSpecialChip` `#84336F`, `tabTrack` `#F3E3C6`, `shortFill` `#EADBC2`, `priceMuted` `#8A7259` (pakai token yang sudah ada kalau nilainya sama: `inkSoft` `#6B4F3A`, `brickDeep` `#9A3520`, `success`, `successDeep`, `onSuccess`, `surface`, `line`, `lineDeep`, `muted`).
  - Gaya teks baru hanya kalau belum ada yang nilainya sama: tab 12,5/800 Nunito, nama kartu 15/800, harga Fredoka 18/600, chip 13/800, kelangkaan 11/800, nama kucing Fredoka 22/700, deskripsi 13/700, judul sheet Fredoka 26/700, isi sheet 15/700.
  - `KoIcons.shop`, `KoIcons.kitty`, `KoIcons.accessory`, `KoIcons.snack`, `KoIcons.home`, `KoIcons.shield` — path disalin dari `TabToko.dc.html`, `KartuToko.dc.html`, dan `SheetBeli.dc.html`.
  - Widget: `KittyView({required KittyLook look, required double size})`, `RoomItemView({required RoomItemId id, required Size box, bool full})`, `SnackView({required SnackId id, required Size box})`, `AccessoryIconView({AccessoryId? id, double size})` — semuanya `CustomPaint` dengan `Semantics(label:)` dari `lib/l10n/names.dart` (Task 6) atau `excludeSemantics` kalau label disediakan pemanggil.
  - `AppRoutes.galleryKitty = '/galeri/kucing'` + `GalleryKittyScreen` (bagian: 9 kucing pose `idle`, 12 pose Oyen, 16 aksesoris di Oyen, 20 barang + mangkuk, 5 camilan, 16 ikon aksesoris) dan kartunya di `gallery_screen.dart`.
- [ ] **Step 1: Tulis test yang gagal** di `test/widgets/game_art_test.dart`: `KittyView`, `RoomItemView`, `SnackView`, `AccessoryIconView` masing-masing dipompa di `testApp` dan menghasilkan satu `CustomPaint` dengan ukuran yang diminta, plus label pembaca layar (`find.bySemanticsLabel`) yang memuat nama katalog bahasa Indonesia.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/widgets/game_art_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** token, ikon, widget, dan galeri; label pembaca layar memakai fungsi `names.dart` dari Task 5.
- [ ] **Step 4: Jalankan test** `flutter test test/widgets test/theme` → PASS; `flutter test test/screens/navigation_test.dart` → PASS.
- [ ] **Step 5: Commit** `feat(widgets): kitty, item, snack, and accessory art views`.

### Task 7: Rute `/toko` dan tombol Toko sementara di Beranda

**Files:**
- Modify: `lib/app/routes.dart`, `lib/app/router.dart`, `lib/screens/home/home_screen.dart`
- Create: `lib/screens/shop/shop_screen.dart` (kerangka: bar atas + tab kosong)
- Test: `test/screens/navigation_test.dart`

**Interfaces:**
- Produces: `AppRoutes.shop({String? tab})` → `/toko`, atau `/toko?tab=<nama>` kalau `tab` diberikan (`routes.dart` tidak mengimpor layar); `enum ShopTab { items, kitties, accessories, snacks }` dengan `ShopTab.parse(String?)` → tab itu atau `ShopTab.items` (di `shop_screen.dart`); `ShopScreen({ShopTab initialTab = ShopTab.items})`; rute `toko` di bawah `/` seperti `kostum`, dibangun dengan `ShopTab.parse(state.uri.queryParameters['tab'])`; tombol `Toko` di baris menu Beranda.
- [ ] **Step 1: Tulis test yang gagal** di `test/screens/navigation_test.dart`: `Beranda → Toko → kembali ke Beranda` (ketuk tombol "Toko", judul "Toko" muncul, tombol kembali membawa ke Beranda), dan `/toko?tab=aksesoris` membuka tab Aksesoris (cari tab terpilih lewat `find.bySemanticsLabel` atau `Tab` aktif).
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/screens/navigation_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** rute dan tombol Toko di Beranda, lalu kerangka `ShopScreen`: bar atas (tombol kembali `KoIconButton` + judul `koType.title` + `KoCoinChip` yang membuka `showCoinSheet`) dan `ShopTabs` (empat tab seperti `TabToko.dc.html`) dengan isi tiap tab masih kosong; isinya ditambahkan di Task 7–9.
- [ ] **Step 4: Jalankan test** `flutter test test/screens/navigation_test.dart test/screens/home_chapter_test.dart` → PASS.
- [ ] **Step 5: Commit** `feat(shop): route and temporary home button`.

### Task 8: Tab Barang dan sheet konfirmasi beli

**Files:**
- Create: `lib/screens/shop/shop_parts.dart`, `lib/screens/shop/buy_sheet.dart`
- Modify: `lib/screens/shop/shop_screen.dart`
- Test: `test/screens/shop_screen_test.dart`

**Interfaces:**
- Consumes: `ProgressController.buyItem/coins/home`, `showKoSheet`/`KoSheet`/`SheetButton`, `RoomItemView`, `KoCoinChip`, teks Task 5.
- Produces:
  - `shop_parts.dart`: `ShopBar({required int coins, required bool bonus, required VoidCallback onBack, required VoidCallback onCoins})`, `ShopTabs({required ShopTab active, required ValueChanged<ShopTab> onPick})`, `ItemCard({required RoomItemId id, required ShopCardState state, required VoidCallback? onPressed})`, `enum ShopCardState { buy, short, owned, livesHere }`, `ShopFlash({required String text})` (hilang sendiri; `Semantics(liveRegion: true)`), `ShopIntro({required String text})`.
  - `buy_sheet.dart`: `sealed class BuyTarget` dengan `BuyItem(RoomItemId)`, `BuyKitty(KittyId)`, `BuyAccessory(AccessoryId)`; `Future<void> showBuySheet(BuildContext context, {required BuyTarget target, required ProgressController progress, KittyId previewKitty = KittyId.oyen, void Function(AccessoryId id)? onWear})` — tahap konfirmasi → sukses di sheet yang sama, tombol "Lihat di kamar" (`context.go(AppRoutes.home)`) untuk barang/kucing dan "Pakai di <kucing>" untuk aksesoris, tombol bawah "Nanti dulu"/"Belanja lagi".
  - Kunci widget untuk test: `ValueKey('shop-item-<kode>')`, `ValueKey('buy-confirm')`, `ValueKey('buy-close')`.
- [ ] **Step 1: Tulis test yang gagal** di `test/screens/shop_screen_test.dart` (grup `tab Barang`, memakai `pumpApp(location: AppRoutes.shop())` dan `testProgressWith(coins: …, home: …)`):
  - `test('kartu barang menampilkan harga, Punyamu, dan koin kurang')`: saldo 100 → Kardus Nyaman "50" bisa ditekan, Akuarium berlabel "Koin kurang"; barang yang dimiliki berlabel "Punyamu" dan tidak membuka sheet.
  - `test('beli barang lewat sheet konfirmasi')`: ketuk kartu → sheet berisi nama, deskripsi, dan "Beli · 50 koin"; ketuk → tahap sukses "Kardus Nyaman jadi punyamu!", saldo berkurang 50, `progress.home.room.owned` memuat kardus; tombol "Lihat di kamar" menuju Beranda.
  - `test('koin pas cukup')`: saldo tepat 50 → tombol beli aktif dan pembelian berhasil.
  - `test('koin kurang: sheet tanpa tombol beli')`: saldo 10 → sheet menampilkan "Koin kurang · 40" nonaktif dan saldo tidak berubah.
  - `test('dua ketukan hanya memotong sekali')`: dua `tap` tanpa `pump` di antara → saldo berkurang 50 sekali.
  - `test('pembaca layar: label kartu')`: `find.bySemanticsLabel` untuk label beli, koin kurang, dan sudah punya.
  - `test('sheet ditutup lewat Nanti dulu dan tombol kembali sistem')`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/screens/shop_screen_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** `shop_parts.dart`, `buy_sheet.dart`, dan tab Barang di `shop_screen.dart` (grid 2 kolom, jarak 12, kartu seperti `KartuToko` jenis `barang`).
- [ ] **Step 4: Jalankan test** → PASS.
- [ ] **Step 5: Commit** `feat(shop): items tab and buy sheet`.

### Task 9: Tab Kucing dan tab Makanan

**Files:**
- Modify: `lib/screens/shop/shop_screen.dart`, `lib/screens/shop/shop_parts.dart`
- Test: `test/screens/shop_screen_test.dart`

**Interfaces:**
- Produces: `KittyCard({required KittyId id, required ShopCardState state, required int short, required VoidCallback? onPressed})`, `SnackCard({required SnackId id, required int stock, required bool short, required VoidCallback? onBuy})`; kunci `ValueKey('shop-kitty-<kode>')`, `ValueKey('shop-snack-<kode>')`.
- [ ] **Step 1: Tulis test yang gagal** (grup `tab Kucing` dan `tab Makanan`):
  - `test('tab berganti')`: ketuk tab Kucing → kartu Salju muncul dan kartu barang hilang; ketuk tab Makanan → kartu Susu muncul.
  - `test('adopsi kucing lewat sheet')`: saldo 300 → "Adopsi · 300"; beli → "Salju pindah ke kamar!", `progress.home.kitties` memuat Salju, kartu jadi "Tinggal di kamar".
  - `test('kucing koin kurang menampilkan selisih')`: saldo 100 untuk Salju → "Kurang 200 koin".
  - `test('beli camilan langsung menambah stok')`: saldo 100 → ketuk "Beli · 15" di Susu → stok 1, saldo 85, pesan "-15 koin" muncul lalu hilang.
  - `test('dua ketukan camilan memotong sekali')`.
  - `test('stok penuh tidak menambah')`: `Pantry({SnackId.susu: 99})` → ketuk beli → stok tetap 99 dan saldo tidak berubah.
  - `test('camilan koin kurang: tombol mati')`: saldo 5 → tombol beli nonaktif, label pembaca layar menyebut koin kurang.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/screens/shop_screen_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** kedua tab (paragraf pembuka, daftar kartu, chip stok, tombol beli langsung + `ShopFlash`).
- [ ] **Step 4: Jalankan test** → PASS.
- [ ] **Step 5: Commit** `feat(shop): kitties and snacks tabs`.

### Task 10: Tab Aksesoris dengan pratinjau langsung

**Files:**
- Modify: `lib/screens/shop/shop_screen.dart`, `lib/screens/shop/shop_parts.dart`, `lib/screens/shop/buy_sheet.dart`
- Test: `test/screens/shop_screen_test.dart`

**Interfaces:**
- Produces: `AccessoryPreview({required KittyId kitty, required AccessoryId selected, required bool owned, required bool worn, required int coins, required VoidCallback onBuy, required VoidCallback onWear, required VoidCallback onRemove})`, `KittyPicker({required List<KittyId> kitties, required KittyId active, required ValueChanged<KittyId> onPick})`, `AccessoryCard({required AccessoryId id, required KittyId preview, required ShopCardState state, required bool selected, required String wornBy, required VoidCallback onPressed})`; kunci `ValueKey('shop-accessory-<kode>')`, `ValueKey('shop-preview-<kode kucing>')`.
- [ ] **Step 1: Tulis test yang gagal** (grup `tab Aksesoris`):
  - `test('kartu aksesoris hanya mengganti pratinjau')`: ketuk kartu Beanie → panel pratinjau menyebut "Beanie", saldo tidak berubah, tidak ada sheet.
  - `test('beli aksesoris lalu pakai dari sheet')`: saldo 200 → "Beli · 180" (panel) → sheet "Beanie milikmu selamanya!" → "Pakai di Oyen" → `progress.home.closet.wearingOf(KittyId.oyen)` = beanie, pesan "Cakep!" muncul.
  - `test('pakai dan lepas aksesoris yang dimiliki gratis')`: closet punya Pita → tombol "Pakai · Gratis" lalu "Lepas · Gratis", saldo tidak berubah.
  - `test('aksesoris sama boleh dipakai dua kucing')`: punya Salju dan Pita yang dipakai Salju → pilih Oyen di "Coba di:" → "Pakai · Gratis" → kedua kucing memakainya, kartu menyebut "Dipakai Oyen, Salju".
  - `test('kucing yang baru dibeli muncul di Coba di:')`: beli Salju di tab Kucing → kembali ke tab Aksesoris → tombol pratinjau Salju ada.
  - `test('koin kurang: tombol koin kurang dan pesan')`: saldo 10 untuk Mahkota Raja → "Koin kurang · 790" dan pesan "Main puzzle dulu, koinnya nyusul."
  - `test('pembaca layar: tombol pratinjau dan kartu aksesoris')`.
- [ ] **Step 2: Jalankan dan pastikan gagal.** Run: `flutter test test/screens/shop_screen_test.dart` → FAIL.
- [ ] **Step 3: Implementasi** panel pratinjau (`KittyView` ukuran 126 di kotak 146×176 dengan garis lantai desain), picker, grid kartu (`KittyView` 84 memakai aksesoris kartu itu), dan tombol aksi; `showBuySheet` untuk aksesoris memakai `previewKitty` dan `onWear`.
- [ ] **Step 4: Jalankan test** → PASS.
- [ ] **Step 5: Commit** `feat(shop): accessories tab with live preview`.

### Task 11: Overflow, potret layar, dan dokumentasi

**Files:**
- Modify: `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`, `CLAUDE.md` (bagian "Struktur"), `docs/DESIGN_NOTES.md` (bagian "Langkah 22"), `docs/ROADMAP.md` (centang langkah 22)
- Test: seluruh suite

- [ ] **Step 1: Tambah rute ke `overflow_test`**: `AppRoutes.shop()` dan `AppRoutes.galleryKitty` ke daftar `routes`; grup baru yang memompa `/toko` bersaldo 99999 di keempat tab, pratinjau aksesoris, dan sheet konfirmasi (barang dan aksesoris) di 360×640 dan 412×915, teks 100% dan 130%, keempat bahasa (finder lewat `lookupAppLocalizations`).
- [ ] **Step 2: Jalankan** `flutter test test/screens/overflow_test.dart` → PASS (perbaiki tata letak kartu/sheet kalau ada overflow; ikuti catatan `n360`: pratinjau 146→120, kartu 2 kolom, tab ikon di atas label).
- [ ] **Step 3: Tambah potret layar**: `20-toko-barang`, `20-toko-kucing`, `20-toko-makanan`, `20-toko-aksesoris`, `20-toko-beli`, `20-toko-sukses` di `_screens`/blok sendiri (saldo 480 seperti contoh desain), plus `20-toko-barang` per bahasa di blok bahasa, dan `galeri-kucing` + `galeri-kucing-penuh`. Jalankan `flutter test test/screenshots --dart-define=SCREENSHOTS=true` dan bandingkan dengan artboard desain.
- [ ] **Step 4: Perbarui dokumentasi**: bagian "Struktur" `CLAUDE.md` (render kucing/barang/ikon aksesoris, `lib/screens/shop/`, rute `/toko` dan `/galeri/kucing`, test baru), "Langkah 22" di `docs/DESIGN_NOTES.md` (keputusan di atas), dan centang langkah 22 di `docs/ROADMAP.md`.
- [ ] **Step 5: Jalankan `/check`** (format, `flutter analyze` → `No issues found!`, `flutter test` hijau) lalu commit `docs: step 22 notes, roadmap, and structure`.
