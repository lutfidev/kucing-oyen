# Kamar Oyen sebagai Beranda (langkah 23) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rute `/` berubah dari Beranda lama menjadi kamar Oyen yang bisa dihias, dengan kartu kucing untuk camilan, elus, dan aksesoris, sekaligus menghapus Lemari Kostum beserta kostum lama.

**Architecture:** Geometri kamar dipisah sebagai Dart murni (`room_geometry.dart`) yang memetakan `Spot` (pecahan 0–1 yang sudah ada di model) ke kotak layar, jadi satu rumus dipakai untuk menggambar, menyeret, dan tes. Gambar baru (jendela kamar, dekor lantai, tanda lesu) disalin dari `<svg>` desain ke `design_svg_home.dart` dan digambar lewat `SvgTemplate` di `room_art.dart`. Layar kamar adalah `Stack`: latar `CustomPaint`, barang dan kucing sebagai `Positioned`, lalu lapisan header, panel bawah, kartu kucing, dan reaksi. Semua aksi lewat `ProgressController` yang sudah ada (langkah 21), tanpa model baru selain satu field katalog.

**Tech Stack:** Flutter (Material + widget sendiri), `go_router`, token tema `lib/theme/`, `SvgTemplate`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md` (bagian "Kamar", "Kebutuhan dan hadiah", "Aksesoris") dan prompt langkah 23 di `docs/ROADMAP.md`. Desain: `docs/design/rumah-oyen/project/Kamar.dc.html` (+ `KamarKartu`, `KamarHias`, `KamarBaru`, `KamarAksesoris`, `KamarHadiah`), `TombolHias`, `BakiGudang`, `BarKebutuhan`, `TandaLesu`, `Barang.dc.html`, `Kucing.dc.html`, dan catatan `n360` di `canvas.json`.

## Global Constraints

- Logika Dart murni di `lib/game/model/` dan `lib/game/sim/` tanpa import Flutter; kalimat pemain ada di `lib/l10n/`.
- Semua teks pemain dan label pembaca layar masuk ke **keempat** ARB (`app_en.arb` lebih dulu beserta deskripsi, lalu `id`, `pt`, `ru`), lalu `flutter gen-l10n`. Nada santai dan jenaka seperti teks yang sudah ada. Teks Indonesia diambil persis dari desain.
- Tidak ada warna, ukuran, atau jarak hardcode di widget: tambah token di `lib/theme/` kalau butuh nilai baru.
- Gambar dari desain **tidak diketik ulang**: isi `<svg>` disalin utuh ke `design_svg_home.dart` dan diurai `SvgTemplate`.
- Jangan ada animasi berulang tanpa akhir di kamar: langkah 23 kamar diam (keputusan pemilik repo 29 Okt 2026). Hanya reaksi dan pujian yang bergerak, keduanya sekali jalan lalu selesai, jadi `pumpAndSettle` tetap bisa dipakai.
- Kegagalan simpan memihak pemain: urutan tulis `ProgressController` jangan diubah; barang disimpan sebelum koin.
- `flutter analyze` harus `No issues found!` dan `flutter test` hijau sebelum langkah dianggap selesai (`/check`).
- Commit kecil, pesan bahasa Inggris (`feat(room): ...`, `test: ...`, `docs: ...`), tanpa atribusi Claude.

## Review Focus

1. **Barang di Gudang saat mode normal** — barang yang dimiliki tapi tidak ditaruh tidak boleh digambar di kamar dan tidak boleh membuat error (Task 3 test "barang di Gudang tidak digambar").
2. **Sembilan kucing di kamar** — posisi acak tidak boleh keluar area lantai atau menumpuk persis di satu titik (Task 3 test "sembilan kucing: semua di dalam area lantai, tidak satu titik").
3. **`Spot` ekstrem dari simpanan** — `Spot(0,0)` dan `Spot(1,1)` untuk barang terbesar tetap di dalam zonanya (Task 1 test "spot 0 dan 1 tetap di dalam zona").
4. **Layar pendek dengan teks 130%** — kartu kucing bisa digulir dan panel bawah tidak overflow (Task 4 test "kartu kucing di 360×640 teks 130% bisa digulir" + Task 7 `overflow_test`).
5. **Ketukan ganda cepat** — dua ketukan Camilan hanya memotong satu stok, dua ketukan Selesai hanya memberi satu bonus menghias (Task 4 dan Task 5 test "ketukan ganda").

Plus kurangi gerak: reaksi tetap muncul tanpa bergerak dan hilang sendiri (Task 4 test "kurangi gerak").

---

### Task 1: Geometri kamar dan urutan gambar

**Files:**
- Modify: `lib/game/model/home_items.dart` (tambah field `flat` di `RoomItem`)
- Create: `lib/screens/room/room_geometry.dart`
- Test: `test/game/model/home_items_test.dart` (tambahan), `test/screens/room_geometry_test.dart`

**Interfaces:**
- Consumes: `RoomItem`, `RoomItemId`, `RoomZone`, `Spot`, `spotAt`, `positionOf`, konstanta `wallLeft`…`floorBottom` (`lib/game/model/home_items.dart`); `KittyId`.
- Produces:
  - `RoomItem.flat` (`bool`, true hanya untuk `RoomItemId.karpet`).
  - `class RoomGeometry` dengan `RoomGeometry(Size room)`, `final Size room`, `double get scale`, `double get artScale`, `Rect get wall`, `Rect get trim`, `Rect get floor`, `Size sizeOf(RoomItem item)`, `Rect rangeOf(RoomZone zone, Size box)`, `Rect boxOf(RoomItem item, Spot spot)`, `Spot spotFor(RoomItem item, Offset topLeft)`, `double catSize(KittyId kitty)`, `Rect catBoxOf(KittyId kitty, Spot spot)`, `double feetOf(Rect catBox)`, `Rect fromDesign(Rect design, {bool stretch = false})` (kotak tetap desain 390×844 — jendela, bidang kosong pemain baru, panduan zona — ke layar: x × `scale`; y di atas `designFloorTop` dipetakan sebanding ke `wall`, selain itu ke `floor`; ukuran × `artScale` untuk gambar, atau lebar × `scale` dan tinggi sebanding zonanya untuk panduan zona lewat `fromDesign(design, stretch: true)`).
  - Konstanta desain di file yang sama: `designRoomWidth = 390.0`, `designRoomHeight = 652.0`, `designWallHeight = 412.0`, `designTrimHeight = 14.0`, `designFloorTop = 426.0`, `oyenRoomSize = 116.0`, `kittyRoomSize = 96.0`, `catFeetFactor = 0.92`.
  - `sealed class RoomSprite` dengan `final Rect box`; `class ItemSprite extends RoomSprite` (`RoomItemId id`, `bool flat`), `class KittySprite extends RoomSprite` (`KittyId kitty`); `List<RoomSprite> roomSprites({required Map<RoomItemId, Spot> items, required Map<KittyId, Spot> cats, required RoomGeometry geo})`.

- [ ] **Step 1: Tulis test yang gagal untuk `flat`**

```dart
test('karpet digambar rata di lantai, barang lain tidak', () {
  expect(roomItemOf(RoomItemId.karpet).flat, isTrue);
  expect(roomItems.where((i) => i.flat).map((i) => i.id), [RoomItemId.karpet]);
});
```

- [ ] **Step 2: Jalankan test, pastikan gagal**

Run: `flutter test test/game/model/home_items_test.dart`
Expected: FAIL, `flat` belum ada.

- [ ] **Step 3: Tambah `final bool flat` (default false) ke `RoomItem` dan `flat: true` di entri `karpet`**

Komentar singkat menyebut `flat: true` di `BASE.karpet` (`Kamar.dc.html`) sebagai sumbernya.

- [ ] **Step 4: Jalankan test, pastikan lulus**

Run: `flutter test test/game/model/home_items_test.dart`
Expected: PASS

- [ ] **Step 5: Tulis test geometri yang gagal**

`test/screens/room_geometry_test.dart`, pakai `RoomGeometry(const Size(390, 652))` sebagai "kamar desain" dan `const Size(360, 480)` sebagai layar kecil (360×640 sesudah header dan panel):

```dart
test('kamar desain: dinding, trim, dan lantai seperti Kamar.dc.html', () {
  final geo = RoomGeometry(const Size(390, 652));
  expect(geo.scale, 1);
  expect(geo.artScale, 1);
  expect(geo.wall, const Rect.fromLTRB(0, 0, 390, 412));
  expect(geo.trim, const Rect.fromLTRB(0, 412, 390, 426));
  expect(geo.floor, const Rect.fromLTRB(0, 426, 390, 652));
});

test('rentang barang dinding dan lantai sama dengan batas seret desain', () {
  final geo = RoomGeometry(const Size(390, 652));
  final lukisan = roomItemOf(RoomItemId.lukisan);
  final wall = geo.rangeOf(RoomZone.wall, geo.sizeOf(lukisan));
  expect(wall.left, wallLeft);
  expect(wall.right, wallRight - lukisan.width);
  expect(wall.top, wallTop);
  expect(wall.bottom, wallBottom - lukisan.height);
  final kasur = roomItemOf(RoomItemId.kasur);
  final floor = geo.rangeOf(RoomZone.floor, geo.sizeOf(kasur));
  expect(floor.left, floorLeft);
  expect(floor.right, floorRight - kasur.width);
  expect(floor.top, floorTop - kasur.height);
  expect(floor.bottom, floorBottom - kasur.height);
});

test('posisi bawaan digambar di koordinat desain', () {
  final geo = RoomGeometry(const Size(390, 652));
  for (final (id, left, top) in [
    (RoomItemId.kasur, 246.0, 448.0),
    (RoomItemId.lukisan, 206.0, 150.0),
    (RoomItemId.mangkuk, 298.0, 596.0),
  ]) {
    final item = roomItemOf(id);
    final box = geo.boxOf(item, item.defaultSpot);
    expect(box.left, closeTo(left, 0.01));
    expect(box.top, closeTo(top, 0.01));
    expect(box.size, Size(item.width, item.height));
  }
});

test('spotFor adalah kebalikan boxOf dan menjepit di luar zona', () {
  final geo = RoomGeometry(const Size(412, 700));
  final item = roomItemOf(RoomItemId.bola);
  final spot = Spot(0.3, 0.8);
  expect(geo.spotFor(item, geo.boxOf(item, spot).topLeft).x, closeTo(0.3, 0.001));
  expect(geo.spotFor(item, geo.boxOf(item, spot).topLeft).y, closeTo(0.8, 0.001));
  expect(geo.spotFor(item, const Offset(-500, -500)), Spot(0, 0));
  expect(geo.spotFor(item, const Offset(5000, 5000)), Spot(1, 1));
});

test('spot 0 dan 1 tetap di dalam zona untuk semua barang', () {
  for (final size in const [Size(360, 480), Size(412, 720)]) {
    final geo = RoomGeometry(size);
    for (final item in roomItems) {
      for (final spot in [Spot(0, 0), Spot(1, 1)]) {
        final box = geo.boxOf(item, spot);
        expect(box.left, greaterThanOrEqualTo(0), reason: '${item.id}');
        expect(box.right, lessThanOrEqualTo(size.width), reason: '${item.id}');
        expect(box.top, greaterThanOrEqualTo(0), reason: '${item.id}');
        if (item.zone == RoomZone.wall) {
          expect(box.bottom, lessThanOrEqualTo(geo.wall.bottom), reason: '${item.id}');
        } else {
          expect(box.bottom, greaterThan(geo.floor.top), reason: '${item.id}');
          expect(box.bottom, lessThanOrEqualTo(geo.floor.bottom), reason: '${item.id}');
        }
      }
    }
  }
});

test('fromDesign: jendela di koordinat desain, ikut mengecil di layar kecil', () {
  final design = RoomGeometry(const Size(390, 652));
  const window = Rect.fromLTWH(26, 124, 140, 134);
  expect(design.fromDesign(window), window);
  final small = RoomGeometry(const Size(360, 480)).fromDesign(window);
  expect(small.width, closeTo(140 * 0.83, 2));
  expect(small.top, closeTo(124 * 303 / 412, 2));
});

test('layar 360×640 mengecil seperti catatan n360', () {
  final geo = RoomGeometry(const Size(360, 480));
  expect(geo.artScale, closeTo(0.83, 0.02));
  expect(geo.wall.height / geo.room.height, closeTo(0.63, 0.01));
  expect(geo.catSize(KittyId.oyen), closeTo(96, 3));
});

test('kucing: Oyen lebih besar, kaki di 92% kotak', () {
  final geo = RoomGeometry(const Size(390, 652));
  expect(geo.catSize(KittyId.oyen), oyenRoomSize);
  expect(geo.catSize(KittyId.salju), kittyRoomSize);
  final box = geo.catBoxOf(KittyId.oyen, Spot(0.5, 0.5));
  expect(geo.feetOf(box), box.top + box.height * catFeetFactor);
});

test('urutan gambar: karpet, barang dinding, lalu lantai dan kucing urut bawah', () {
  final geo = RoomGeometry(const Size(390, 652));
  final sprites = roomSprites(
    items: {
      RoomItemId.karpet: roomItemOf(RoomItemId.karpet).defaultSpot,
      RoomItemId.lukisan: roomItemOf(RoomItemId.lukisan).defaultSpot,
      RoomItemId.bola: Spot(0.5, 1),
      RoomItemId.kasur: Spot(0.5, 0),
    },
    cats: {KittyId.oyen: Spot(0.5, 0.5)},
    geo: geo,
  );
  expect(sprites.whereType<ItemSprite>().first.id, RoomItemId.karpet);
  expect(sprites[1], isA<ItemSprite>().having((s) => s.id, 'id', RoomItemId.lukisan));
  final bottoms = [
    for (final s in sprites.skip(2)) s is ItemSprite ? s.box.bottom : geo.feetOf(s.box),
  ];
  expect(bottoms, orderedEquals([...bottoms]..sort()));
  expect(bottoms, hasLength(3));
});
```

- [ ] **Step 6: Jalankan test, pastikan gagal**

Run: `flutter test test/screens/room_geometry_test.dart`
Expected: FAIL, `room_geometry.dart` belum ada.

- [ ] **Step 7: Buat `lib/screens/room/room_geometry.dart`**

Rumus (pakai persis ini, karena menghasilkan koordinat desain di 390×652 dan nilai `n360` di layar kecil):

- `scale = room.width / designRoomWidth`
- `heightScale = room.height / designRoomHeight`
- `artScale = ((scale + heightScale) / 2).clamp(0.6, 1.2)`
- `wall = Rect.fromLTWH(0, 0, room.width, room.height * designWallHeight / designRoomHeight)`
- `trim` tinggi `designTrimHeight * scale` di bawah `wall`; `floor` dari `trim.bottom` sampai `room.height`
- `sizeOf(item) = Size(item.width, item.height) * artScale`
- `rangeOf(wall, box)`: kiri `wallLeft * scale`, kanan `room.width - (designRoomWidth - wallRight) * scale - box.width`, atas `wall.height * wallTop / designWallHeight`, bawah `wall.height * wallBottom / designWallHeight - box.height`
- `rangeOf(floor, box)`: kiri `floorLeft * scale`, kanan `room.width - (designRoomWidth - floorRight) * scale - box.width`, atas `floor.top + floor.height * (floorTop - designFloorTop) / (designRoomHeight - designFloorTop) - box.height`, bawah idem dengan `floorBottom`
- `boxOf(item, spot)` = pojok kiri-atas `range.topLeft + Offset(spot.x * range.width, spot.y * range.height)` dengan `sizeOf(item)`; `spotFor` kebalikannya (pembagian dengan lebar/tinggi 0 → 0, `Spot` sudah menjepit)
- `catSize(kitty)` = (`oyenRoomSize` untuk Oyen, selain itu `kittyRoomSize`) × `artScale`; `catBoxOf` memakai `rangeOf(RoomZone.floor, Size.square(catSize))`
- `roomSprites`: `flat` dulu (urut katalog), lalu barang dinding (urut katalog), lalu barang lantai dan kucing digabung dan diurutkan menurut tepi bawah (`box.bottom` untuk barang, `feetOf` untuk kucing)

- [ ] **Step 8: Jalankan test, pastikan lulus**

Run: `flutter test test/screens/room_geometry_test.dart test/game/model/home_items_test.dart`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add lib/game/model/home_items.dart lib/screens/room/room_geometry.dart test/screens/room_geometry_test.dart test/game/model/home_items_test.dart
git commit -m "feat(room): room geometry and draw order"
```

---

### Task 2: Gambar latar kamar dan tanda lesu

**Files:**
- Modify: `lib/game/render/design_svg_home.dart` (tambah sumber SVG)
- Create: `lib/game/render/room_art.dart`
- Modify: `lib/game/render/render.dart` (ekspor), `lib/widgets/game_art.dart` (widget), `lib/theme/ko_colors.dart`, `lib/theme/ko_size.dart`
- Test: `test/game/render/room_art_test.dart`, `test/game/render/design_sync_test.dart` (tambahan)

**Interfaces:**
- Consumes: `SvgTemplate`, `SvgDrawing` (`lib/game/render/svg_template.dart`).
- Produces:
  - Di `design_svg_home.dart`: `roomWindowSvg`, `roomFloorDecorSvg`, `sadMarkSvg` (isi `<svg>` disalin utuh dari desain).
  - Di `room_art.dart`: `abstract final class RoomArt` dengan `windowViewBox = Rect.fromLTRB(-8, 0, 132, 134)`, `windowBox = Rect.fromLTWH(26, 124, 140, 134)` (koordinat desain 390×844), `floorDecorViewBox = Rect.fromLTRB(0, 426, 390, 652)`, `sadMarkViewBox = Size(48, 52)`; fungsi `void paintRoomWindow(Canvas canvas, {required Rect box})`, `void paintRoomFloorDecor(Canvas canvas, {required Rect floor})`, `void paintSadMark(Canvas canvas, {required bool hungry, double width = 48})`.
  - Di `game_art.dart`: `class SadMarkView extends StatelessWidget` (`bool hungry`, `double size`), label pembaca layar dari `lib/l10n/names.dart` (`sadMarkLabel(l, hungry: ...)`).
  - Token baru `KoColors`: `roomWall` `0xFFFCE6C8`, `roomWallStripe` `0x24E2AA6E` (rgba(226,170,110,.14)), `roomWallMark` `0x80D4A971`, `roomTrimLight` `0xFFC99466`, `roomFloorBoards` `0xFFEBC896`, `roomFloorLine` `0x40B07A4F` (rgba(176,122,79,.25)), `needHungerTile` `0xFFFDE3C2`, `needHungerInk` `0xFFA9530A`, `needJoyTile` `0xFFCDEFE8`, `needLowTile` `0xFFF6D3CA`, `heart` `0xFFF07F9A`.

- [ ] **Step 1: Salin SVG desain ke `design_svg_home.dart`**

Ambil tiga potongan, tanpa mengetik ulang isinya:
- `roomWindowSvg`: isi `<svg width="140" height="134" viewBox="-8 0 140 134">` di `Kamar.dc.html` (jendela dinding).
- `roomFloorDecorSvg`: isi `<svg aria-hidden="true" width="390" height="844" viewBox="0 0 390 844" ...>` di `Kamar.dc.html` (bidang cahaya dan goresan lantai).
- `sadMarkSvg`: isi `<svg ... viewBox="0 0 48 52" ...>` di `TandaLesu.dc.html`; ganti `{{isLapar}}`/`{{isSedih}}` seperti pola berkas ini (nilai `s.lapar`/`s.sedih`).

- [ ] **Step 2: Tulis test yang gagal**

`test/game/render/room_art_test.dart` dengan pola `test/game/render/room_item_art_test.dart` (render ke `Picture`, baca piksel di koordinat desain):

```dart
test('jendela: langit biru di tengah, rumput hijau di bawah', () async {
  // piksel di dalam RoomArt.windowBox
});

test('dekor lantai: bidang cahaya lebih terang dari lantai kosong', () async {});

test('tanda lesu lapar dan sedih berbeda', () async {
  // piksel awan #B9C7DA hanya ada di varian sedih
});
```

- [ ] **Step 3: Jalankan test, pastikan gagal**

Run: `flutter test test/game/render/room_art_test.dart`
Expected: FAIL, `room_art.dart` belum ada.

- [ ] **Step 4: Buat `room_art.dart` dan ekspor dari `render.dart`**

Pola `accessory_icon.dart`: satu `SvgTemplate` per sumber, hasil `render` di-cache, `canvas.save/scale/translate` sesuai `viewBox`. `paintRoomFloorDecor` menskala `floorDecorViewBox` (lebar dan tinggi terpisah) ke `floor`. `paintSadMark` memilih varian lewat `vals` `{'s': {'lapar': hungry, 'sedih': !hungry}}`.

- [ ] **Step 5: Tambah token warna dan `SadMarkView`**

Token di `KoColors.standard` dengan komentar rgba seperti token yang ada; `SadMarkView` mengikuti pola `AccessoryIconView`. Label pembaca layarnya lewat `sadMarkLabel(l, {required bool hungry})` di `names.dart`, dengan kunci ARB baru `sadMarkHungry` "Lesu: lapar" dan `sadMarkSad` "Lesu: kurang perhatian" di keempat ARB, lalu `flutter gen-l10n`.

- [ ] **Step 6: Tambah cek sinkron desain**

Di `test/game/render/design_sync_test.dart`, grup rumah Oyen: `roomWindowSvg` dan `roomFloorDecorSvg` ada di `Kamar.dc.html` (`contains`), `sadMarkSvg` sama dengan isi `<svg>` `TandaLesu.dc.html` (pola `_innerHome`).

- [ ] **Step 7: Jalankan test, pastikan lulus**

Run: `flutter test test/game/render/room_art_test.dart test/game/render/design_sync_test.dart test/theme`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/game/render lib/widgets/game_art.dart lib/theme test/game/render
git commit -m "feat(room): room background and sad mark art"
```

---

### Task 3: Kamar di rute `/` (mode normal)

**Files:**
- Create: `lib/screens/room/room_screen.dart`, `lib/screens/room/room_view.dart`, `lib/screens/room/room_parts.dart`
- Delete: `lib/screens/home/home_screen.dart` (beserta folder), `paintHomePaws` + `MapArt.checkerPattern` + token `KoColors.checker`, `KoSize.oyenHome`, `KoSize.oyenHomeOverlap` kalau tidak terpakai lagi
- Modify: `lib/app/router.dart`, `lib/app/app.dart` (`roomRandom`), `test/test_helpers.dart` (`pumpApp(roomRandom:)`), `lib/widgets/game_logo.dart` (varian satu baris), `lib/widgets/ko_icon.dart` (ikon baru), `lib/theme/ko_size.dart`, `lib/theme/ko_type.dart`, keempat ARB, `lib/l10n/names.dart`
- Test: `test/screens/room_screen_test.dart` (baru), `test/screens/home_chapter_test.dart` (grup Beranda dihapus), `test/screens/navigation_test.dart`, `test/game/render/map_art_test.dart` atau test jejak kaki yang ikut dihapus

**Interfaces:**
- Consumes: `RoomGeometry`, `roomSprites`, `RoomArt`, `SadMarkView`, `ProgressScope`, `ProgressController` (`home`, `coins`, `canClaimBonus`, `currentChapter`, `progress.totalStars`, `maxStars`, `catNeeds`), `KittyView`, `RoomItemView`, `KoCoinChip`, `KoButton`, `KoPressable`, `showCoinSheet`, `AppRoutes`.
- Produces:
  - `class RoomScreen extends StatelessWidget` (rute `/`): `RoomScreen({Random? random})`, membaca `ProgressScope.of(context)` lalu membangun `RoomView`.
  - `class RoomView extends StatefulWidget` dengan `RoomView({required ProgressController progress, Random? random, Key? key})`.
  - Seed acak sampai ke rute supaya potret layar dan `overflow_test` selalu sama: `createRouter({String initialLocation, Random Function()? roomRandom})` → `RoomScreen(random: roomRandom?.call())`, `KucingOrenApp(..., roomRandom:)` meneruskannya, dan `pumpApp(..., roomRandom:)` di `test/test_helpers.dart` memakai default `() => Random(1)`. `main` tidak mengisinya (acak sungguhan).
  - Di `room_parts.dart`: `class RoomHeader` (`coins`, `bonus`, `stars`, `maxStars`, `onCoins`), `class RoomMenu` (`onPlay`, `onShop`, `onAccessories`, `onSettings`, `shopDot`, `accessoryDot`), `class RoomMenuButton`, `class EmptyRoomHints` (`onShop`), `class RoomStarChip`.
  - `GameLogo({bool inline = false})`: `inline` = satu baris "Ginger Logic" (Fredoka 700, token `KoType.logoRow`).
  - Fungsi murni untuk titik merah, di `room_view.dart`: `bool shopHasAffordable(Home home, int coins)` dan `bool accessoriesHaveAffordable(Home home, int coins)` (camilan tidak dihitung).

- [ ] **Step 1: Tulis test yang gagal**

`test/screens/room_screen_test.dart`, helper `pumpRoom(tester, {progress, size, random})` yang memompa `RoomView` di dalam `testApp` + `ProgressScope`:

```dart
testWidgets('kamar kosong: ajakan ke Toko dan dua bidang kosong', (tester) async {
  await pumpRoom(tester, progress: testProgressWith());
  expect(find.text('Kamar masih sepi. Ke Toko, yuk!'), findsOne);
  expect(find.text('Hiasan dinding?'), findsOne);
  expect(find.text('Kasur, mungkin?'), findsOne);
});

testWidgets('header: chip koin, logo, dan total bintang', (tester) async {
  await pumpRoom(tester, progress: testProgressWith(best: {1: 3}, coins: 480));
  expect(find.text('480'), findsOne);
  expect(find.text('3/60', findRichText: true), findsOne); // "3" + "/60" pudar
  expect(find.bySemanticsLabel(l10nId.starsOf(3, 60)), findsOne);
  expect(find.byType(KoCoinChip), findsOne);
});

testWidgets('barang yang ditaruh digambar di posisinya', (tester) async {
  // Room dengan kasur di Spot(0.2, 0.9); bandingkan tester.getRect(RoomItemView kasur)
  // dengan RoomGeometry(...).boxOf(kasur, spot) relatif kotak kamar.
});

testWidgets('barang di Gudang tidak digambar', (tester) async {
  // owned berisi bola tanpa placed → tidak ada RoomItemView bola.
});

testWidgets('kucing yang dimiliki tampil dengan aksesorisnya', (tester) async {
  // Oyen + Salju, Salju memakai Pita → KittyView look.accessory == AccessoryId.pita.
});

testWidgets('sembilan kucing: semua di dalam area lantai, tidak satu titik', (tester) async {
  // posisi dari tester.getRect tiap KittyView: unik, dan di dalam geo.floor (± kotak).
});

testWidgets('posisi kucing acak tapi tetap selama kamar terbuka', (tester) async {
  // random: Random(1) → catat posisi, pump lagi (setState lewat ketuk chip koin lalu tutup)
  // → posisi sama. Random(2) → paling tidak satu kucing di posisi lain.
});

testWidgets('tombol: Main, Toko, Aksesoris, Pengaturan', (tester) async {
  // pumpApp(location: AppRoutes.home) lalu ketuk satu-satu, cek lokasi router.
});

testWidgets('titik merah Toko dan Aksesoris mengikuti saldo', (tester) async {
  // coins 0 → tidak ada titik; coins 99999 → dua titik; aksesoris habis dibeli → titik Aksesoris mati.
});

testWidgets('pembaca layar: kucing bisa diketuk, barang punya nama', (tester) async {
  // semantics label Oyen mengandung 'Ketuk untuk lihat kartunya'.
});

testWidgets('"Lihat di kamar" dari Toko menampilkan barang yang baru dibeli', (tester) async {
  // pumpApp(location: AppRoutes.shop(), progress: saldo cukup) → beli Kardus Nyaman →
  // 'Lihat di kamar' → RoomView tampil dengan RoomItemView kardus di posisi bawaannya.
  // `buy_sheet` sudah menuju AppRoutes.home, jadi tidak ada kode yang diubah.
});
```

Di `test/screens/navigation_test.dart`: ubah test Beranda yang memakai teks lama (tagline/logo) menjadi penanda kamar (mis. tombol `Main` + `find.byType(RoomView)`), dan tambah "Beranda → Aksesoris membuka Toko tab Aksesoris".

- [ ] **Step 2: Jalankan test, pastikan gagal**

Run: `flutter test test/screens/room_screen_test.dart`
Expected: FAIL, `RoomView` belum ada.

- [ ] **Step 3: Tambah teks baru ke keempat ARB lalu `flutter gen-l10n`**

Teks Indonesia persis dari desain: `roomEmptyBubble` "Kamar masih sepi. Ke Toko, yuk!", `roomEmptyWall` "Hiasan dinding?", `roomEmptyWallHint` "Kosong. Cari hiasan dinding di Toko", `roomEmptyFloor` "Kasur, mungkin?", `roomEmptyFloorHint` "Kosong. Cari kasur atau mainan di Toko", `accessories` "Aksesoris", `shopHasNew` "ada yang baru terjangkau" (dipakai di label pembaca layar tombol), `kittyTapHint` "{name}. Ketuk untuk lihat kartunya", `kittyTapHintHungry` "{name}, lapar. Ketuk untuk lihat kartunya".

Ikon baru di `KoIcons` (path disalin dari desain): `decorate` (ikon tombol Hias di `TombolHias.dc.html`), `storage` (ikon Gudang di `BakiGudang.dc.html`), `heart` (tombol Elus di `Kamar.dc.html`), `move` (ikon chip "Seret barang ke tempat baru"). Ikon Lapar di `BarKebutuhan` sama dengan `KoIcons.snack` — pakai yang sudah ada kalau path-nya identik.

- [ ] **Step 4: Buat layar kamar**

- Tata letak `RoomScreen` (desain 390×844 termasuk status bar, jadi kamar digambar mulai dari tepi atas layar):
  - `Scaffold` berlatar `roomFloorBoards` (supaya sudut bulat panel bawah memperlihatkan lantai), `Column`: `Expanded` → `LayoutBuilder` → kamar (`Stack`), lalu `RoomMenu` dibungkus `SafeArea(top: false)`.
  - `RoomGeometry(constraints.biggest)` = kotak kamar dari tepi atas layar sampai atas panel.
  - Header melayang di atas kamar pada `MediaQuery.paddingOf(context).top + space.s6` (desain `top: 50` = status bar 44 + 6), tombol Hias di bawah header dengan jarak desain (`top: 106` − 50 = 56 dari header).
  - Panel bawah ringkas kalau tinggi layar < 700 (catatan `n360`): Main 60 bukan 70, tiga tombol 52 bukan 58, label 12 px. Batasnya token `roomCompactHeight`.
- Latar: `CustomPainter` memakai token `roomWall`, `roomWallStripe` (garis vertikal tiap 36 × scale, lebar 18), `wood` + `roomTrimLight` untuk trim, `roomFloorBoards` + `roomFloorLine` (garis tiap 35 × scale), lalu `paintRoomFloorDecor` dan `paintRoomWindow`.
- Barang dan kucing: `roomSprites` → `Positioned` + `RoomItemView` / `KittyView` (`KittyLook(kitty: ..., accessory: home.closet.wearingOf(kitty))`, pose `KittyPose.idle`). Mangkuk memakai `full: !progress.needs.bowl.isEmptyFor(progress.home.kitties, progress.clock())`.
- Kucing = tombol transparan seluas kotak sprite (`Semantics(button: true, label: kittyTapHint…)` + `GestureDetector`, tanpa bayangan tekan); ketukan mengisi `_selected` (Task 4). Label memakai `kittyTapHintHungry` kalau `hunger <= sadThreshold`.
- Posisi kucing: daftar 12 slot pecahan di `room_view.dart` (4 kolom × 3 baris, `Spot` 0,08–0,92), diacak sekali di `initState` dengan `widget.random ?? Random()` lalu dipakai urut `KittyId` yang dimiliki.
- Tanda lesu: `SadMarkView` (diam, tanpa naik-turun) di atas kucing yang `catNeeds(kitty).isSad`, varian lapar kalau `hunger <= sadThreshold`, selain itu sedih.
- `EmptyRoomHints` kalau `home.room.placed` hanya mangkuk: dua bidang garis putus-putus (`KoDashedBorder`; dinding `Rect.fromLTWH(214, 150, 110, 84)` radius 14, lantai `Rect.fromLTWH(252, 470, 118, 64)` elips) lewat `geo.fromDesign`, dan gelembung ajakan di desain `left: 20, top: 590` (diam); ketiganya menuju `/toko`.
- `RoomMenu`: `KoButton` hero "Main", lalu tiga `RoomMenuButton` (ikon di atas label, tinggi token `roomMenuButton` 58) dengan titik merah opsional.

- [ ] **Step 5: Tukar rute dan buang Beranda lama**

`router.dart` rute `/` → `RoomScreen`; hapus `lib/screens/home/`, `paintHomePaws`, `MapArt.checkerPattern`, token `checker`, `oyenHome`, `oyenHomeOverlap`, dan test yang khusus mengujinya (grup Beranda di `home_chapter_test.dart`).

- [ ] **Step 6: Jalankan test, pastikan lulus**

Run: `flutter test test/screens/room_screen_test.dart test/screens/navigation_test.dart test/screens/home_chapter_test.dart test/game/render`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib test
git commit -m "feat(room): room screen replaces home"
```

---

### Task 4: Kartu kucing (bar, Elus, Camilan, Aksesoris, reaksi)

**Files:**
- Create: `lib/screens/room/kitty_card.dart`, `lib/screens/room/room_reaction.dart`
- Modify: `lib/screens/room/room_view.dart`, `lib/theme/ko_size.dart`, `lib/theme/ko_type.dart`, keempat ARB, `lib/l10n/names.dart`
- Test: `test/screens/room_screen_test.dart` (grup `kartu kucing`)

**Interfaces:**
- Consumes: `ProgressController.catNeeds/feed/pet/wearAccessory`, `Home.pantry`, `AccessoryCloset`, `snacks`, `kittyName`/`kittyDesc`/`snackName`/`accessoryName` (`names.dart`), `AccessoryIconView`, `RoomItemView`-setara untuk camilan (`SnackView`), `KoCard`, `KoPressable`, `KoIcon`.
- Produces:
  - `class KittyCard extends StatefulWidget`: `KittyCard({required ProgressController progress, required KittyId kitty, required void Function(RoomReaction) onReaction, required VoidCallback onClose})`.
  - `class NeedBar extends StatelessWidget` (`label`, `value`, `bool joy`), termasuk `Semantics` meter dan baris "Hampir habis!".
  - Di `room_reaction.dart`: `class RoomReaction` (`String text`, `bool hearts`), `class ReactionOverlay extends StatefulWidget` (`RoomReaction? reaction`, `Rect anchor`, `VoidCallback onDone`) dan `class PraiseToast extends StatefulWidget` (`VoidCallback onDone`) — keduanya sekali jalan (1,6 s dan 2,4 s) dan tidak bergerak kalau `MediaQuery.disableAnimationsOf(context)`.

- [ ] **Step 1: Tulis test yang gagal**

```dart
testWidgets('ketuk kucing membuka kartu dengan nama, keterangan, dan bar', (tester) async {
  // tap Oyen → 'Oyen', l10nId.kittyOyenDesc, 'Lapar', 'Senang', nilai 100.
  // Keterangan memakai kittyDesc yang sudah ada (Toko), bukan teks contoh desain.
});

testWidgets('Elus menambah Senang dan memunculkan reaksi', (tester) async {
  // needs Senang 50 → tap 'Elus' → '+10 senang' tampil, progress.catNeeds(oyen).joy == 60.
});

testWidgets('batas elus: elusan keempat tidak menambah', (tester) async {
  // tiga elusan = +30, keempat tidak mengubah nilai: hanya hati yang muncul, tanpa
  // angka "+10 senang", supaya ketukan tetap terasa (keputusan builder, dicatat).
});

testWidgets('Camilan: memberi Ikan Asin mengurangi stok dan menambah Lapar', (tester) async {
  // pantry {ikanAsin: 2} → buka panel Camilan → tap kartu → '+25 kenyang', stok ×1.
});

testWidgets('camilan habis: tombolnya mati', (tester) async {});

testWidgets('ketukan ganda camilan hanya memotong satu stok', (tester) async {});

testWidgets('Aksesoris: memasang dan melepas dari kartu', (tester) async {
  // closet owned {pita} → panel Aksesoris → tap Pita → 'Dipakai', sprite kamar pakai pita,
  // tap 'Lepas' → wearingOf(oyen) == null.
});

testWidgets('Toko aksesoris → membuka Toko tab Aksesoris', (tester) async {});

testWidgets('kartu ditutup lewat tombol X, latar, dan tombol kembali sistem', (tester) async {});

testWidgets('tanda lesu di atas kucing yang Lapar <= 20', (tester) async {});

testWidgets('kartu kucing di 360×640 teks 130% bisa digulir', (tester) async {
  // setScreenSize + setTextScale, buka kartu dengan panel Camilan, tidak ada overflow,
  // kartu bisa digulir sampai tombol terakhir.
});

testWidgets('kurangi gerak: reaksi tetap muncul lalu hilang', (tester) async {
  // disableAnimations: true → '+10 senang' muncul, sesudah pumpAndSettle hilang.
});
```

- [ ] **Step 2: Jalankan test, pastikan gagal**

Run: `flutter test test/screens/room_screen_test.dart -n "kartu kucing"`
Expected: FAIL

- [ ] **Step 3: Tambah teks kartu ke keempat ARB lalu `flutter gen-l10n`**

`needHunger` "Lapar", `needJoy` "Senang", `needValueLabel` "{label} {value} dari 100", `needValueLow` "{label} {value} dari 100, hampir habis", `needLowHunger` "Hampir habis! Perutnya keroncongan.", `needLowJoy` "Hampir habis! Elus dulu, dong.", `kittyCardLabel` "Kartu {name}", `kittyCardClose` "Tutup kartu", `petAction` "Elus", `snackPanel` "Camilan", `snackPick` "Pilih dari stok", `snackGive` "Beri {name}, stok {count}", `snackGiveEmpty` "Beri {name}, stok {count}, habis", `accessoryPanelTitle` "Punyamu · ganti gratis", `accessoryShopLink` "Toko aksesoris →", `accessoryRemove` "Lepas", `accessoryWornTag` "Dipakai", `accessoryWearLabel` "Pasang {accessory} di {name}", `accessoryWornLabel` "Pasang {accessory} di {name}, sedang dipakai", `accessoryRemoveLabel` "Lepas aksesoris {name}", `reactionFed` "+{hunger} kenyang", `reactionFedJoy` "+{hunger} kenyang, +{joy} senang", `reactionJoy` "+{joy} senang", `reactionNice` "Cakep!", `reactionRelieved` "Lega!". Reaksi camilan memakai `reactionFedJoy` kalau Senang camilan ≥ 15 (desain), selain itu `reactionFed`.

- [ ] **Step 4: Buat `KittyCard`, `NeedBar`, dan lapisan reaksi**

Susunan dari `KamarKartu.dc.html`: scrim gelap (`c.scrim`) yang bisa diketuk untuk menutup, kartu `left/right 16`, `top 96`, radius 26, isi: baris avatar (`KittyView` 54 di kotak 60, disembunyikan kalau lebar < token `roomCardAvatarMinWidth` 380) + nama + keterangan + tombol tutup 44; kotak `cream` berisi dua `NeedBar`; tiga tombol (Camilan / Elus / Aksesoris) 54 dengan tombol panel aktif berwarna `orange`; panel Camilan = baris bergulir kartu 94×86 dengan `SnackView`, nama, dan badge `×N`; panel Aksesoris = tiga kolom kartu "Lepas" + aksesoris yang dimiliki, yang dipakai bertanda `Dipakai` dan berbingkai `success`. Seluruh isi kartu dalam `SingleChildScrollView`. `PopScope` menutup kartu.

- [ ] **Step 5: Sambungkan reaksi dan `isSad` ke kamar**

`RoomView` menyimpan `RoomReaction?` + kucing yang bereaksi, menampilkan `ReactionOverlay` di atas kotak kucing itu (angka melayang + tiga hati kalau `hearts`).

- [ ] **Step 6: Jalankan test, pastikan lulus**

Run: `flutter test test/screens/room_screen_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib test
git commit -m "feat(room): kitty card with snacks, petting, and accessories"
```

---

### Task 5: Mode hias (seret, Gudang, Selesai)

**Files:**
- Create: `lib/screens/room/decorate.dart` (tombol Hias/Selesai, chip petunjuk, panduan zona, baki Gudang)
- Modify: `lib/screens/room/room_view.dart`, `lib/screens/room/room_parts.dart`, `lib/theme/*`, keempat ARB
- Test: `test/screens/room_screen_test.dart` (grup `mode hias`)

**Interfaces:**
- Consumes: `RoomGeometry.spotFor/boxOf`, `ProgressController.placeItem/storeItem/finishDecorating`, `Room.stored`, `RoomItem.builtIn`, `KoDashedBorder`, `PraiseToast`.
- Produces:
  - `class DecorateButton extends StatelessWidget` (`bool done`, `VoidCallback onPressed`).
  - `class DecorateHint extends StatelessWidget`, `class ZoneGuides extends StatelessWidget` (`RoomGeometry geo`).
  - `class StorageTray extends StatelessWidget` (`List<RoomItemId> items`, `void Function(RoomItemId) onPlace`), `GlobalKey` trayKey dipegang `RoomView` untuk mendeteksi lepasan.

- [ ] **Step 1: Tulis test yang gagal**

```dart
testWidgets('Hias: garis putus-putus, baki Gudang, dan Selesai', (tester) async {
  // tap 'Hias' → 'Seret barang ke tempat baru', 'Gudang', 'Selesai', 'Area lantai', 'Area dinding';
  // tombol Main hilang; ketuk kucing tidak membuka kartu.
});

testWidgets('seret barang lantai mengubah posisinya dan menyimpannya', (tester) async {
  // drag kasur +40,-30 → progress.home.room.spotOf(kasur) berubah sesuai geo.spotFor.
});

testWidgets('seret tidak bisa keluar zonanya', (tester) async {
  // lukisan (dinding) diseret 400 px ke bawah → tetap di area dinding (y <= geo.wall.bottom).
});

testWidgets('lepas di atas baki memasukkan barang ke Gudang', (tester) async {
  // drag bola ke tengah baki → RoomItemView bola hilang dari kamar, muncul di baki,
  // progress.home.room.isPlaced(bola) == false.
});

testWidgets('mangkuk tidak bisa masuk Gudang', (tester) async {});

testWidgets('ketuk barang di Gudang menaruhnya di posisi bawaan', (tester) async {});

testWidgets('Selesai: pujian dan +5 Senang untuk semua kucing', (tester) async {
  // Senang 50 → tap 'Selesai' → 'Kamar makin cakep!', catNeeds(oyen).joy == 55, mode normal.
});

testWidgets('ketukan ganda Selesai hanya memberi satu bonus', (tester) async {});

testWidgets('tata letak tersimpan sesudah aplikasi dibuka ulang', (tester) async {
  // seret, lalu ProgressController.load dari store yang sama → spot sama.
});

testWidgets('pembaca layar: barang punya aksi Simpan ke Gudang', (tester) async {});
```

- [ ] **Step 2: Jalankan test, pastikan gagal**

Run: `flutter test test/screens/room_screen_test.dart -n "mode hias"`
Expected: FAIL

- [ ] **Step 3: Tambah teks mode hias ke keempat ARB lalu `flutter gen-l10n`**

`decorate` "Hias", `decorateDone` "Selesai", `decorateHint` "Seret barang ke tempat baru", `zoneWall` "Area dinding", `zoneFloor` "Area lantai", `storage` "Gudang", `storageCount` "{count, plural, other{{count} barang}}", `storageTapHint` "Ketuk untuk menaruh", `storageEmpty` "Gudangnya kosong. Semua barang sudah dipajang, Oyen bangga.", `storagePlaceLabel` "Taruh {item} di kamar", `storeItemAction` "Simpan ke Gudang", `decoratePraise` "Kamar makin cakep!", `decoratePraiseJoy` "+{joy} Senang untuk semua kucing".

- [ ] **Step 4: Buat mode hias**

- `RoomView` menyimpan `bool _decorating`, `RoomItemId? _dragging`, dan `Spot?` sementara barang yang sedang diseret.
- Barang saat hias: `Listener`/`GestureDetector` (`onPanStart/Update/End`) di atas `RoomItemView`, garis putus-putus `waterDeep` + isian 7% (`KoDashedBorder`), badge titik-titik seret di pojok kanan atas.
- Saat diangkat: bayangan elips (`c.shadowLift`), geser −16 × artScale, skala 1,06. Ikon tangan di desain tidak dipakai (penunjuk mouse prototipe) — catat di `DESIGN_NOTES`.
- Seretan seperti desain (`ox + dx`): pojok kiri-atas barang saat mulai diseret + selisih pointer sejak mulai, lalu `spotFor` (`Spot` menjepit otomatis). Barang tidak melompat ke bawah jari.
- Lepasan: kalau titik pointer ada di dalam kotak `StorageTray` dan barang bukan `builtIn` → `storeItem`, selain itu `placeItem(id, spot)`. Keduanya langsung disimpan (keputusan pemilik repo: tiap lepas langsung).
- Panel bawah berganti `StorageTray` selama hias; kucing `IgnorePointer` dan kartu kucing tertutup saat masuk mode hias.
- `Selesai` → `finishDecorating()` lalu `PraiseToast` (pujian + "+5 Senang untuk semua kucing"), mode kembali normal. Tombol dimatikan selama panggilan berjalan supaya ketukan ganda tidak dobel.
- Tombol kembali sistem saat hias = sama dengan menekan Selesai (bonus dan pujian juga), bukan keluar aplikasi. Satu jalan keluar saja, karena tata letaknya sudah tersimpan per lepasan.

- [ ] **Step 5: Jalankan test, pastikan lulus**

Run: `flutter test test/screens/room_screen_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "feat(room): decorate mode with storage tray"
```

---

### Task 6: Hapus Lemari Kostum dan kostum lama

**Files:**
- Delete: `lib/screens/closet/`, `lib/game/model/costumes.dart`, `lib/game/render/closet_art.dart`, `test/screens/closet_screen_test.dart`, `test/game/model/costumes_test.dart`
- Modify: `lib/app/routes.dart`, `lib/app/router.dart`, `lib/app/progress_scope.dart`, `lib/app/progress_store.dart`, `lib/game/render/oyen.dart`, `oyen_painter.dart`, `board_scene.dart`, `design_svg.dart`, `render.dart`, `lib/widgets/game_art.dart`, `lib/widgets/ko_icon.dart`, `lib/screens/level/{level_screen,level_view,tutorial}.dart`, `lib/screens/result/{result_view,result_art}.dart`, `lib/screens/replay/replay_view.dart`, `lib/screens/shop/shop_screen.dart`, `lib/gallery/gallery_oyen_screen.dart`, `lib/theme/ko_size.dart`, `lib/l10n/names.dart`, keempat ARB
- Test: `test/test_helpers.dart`, `test/app/progress_test.dart`, `test/screens/{level_view,result_view,replay_view,progress_flow,navigation,overflow,settings_screen}_test.dart`, `test/game/render/{painters,board_scene,result_art,design_sync}_test.dart`, `test/l10n/names_test.dart`, `test/screenshots/screenshot_test.dart`

**Interfaces:**
- Produces: `OyenLook` tanpa `costume`; `BoardScene` tanpa `dressed`; `LevelView`, `ResultView`, `ReplayView`, `TutorialOverlay`, `SuccessArt`, `VaseArt` tanpa prop `costume`; `ProgressController` tanpa `wardrobe`/`buyCostume`/`wearCostume`; `ProgressStore` tanpa `loadWardrobe`/`saveWardrobe`; `AppRoutes` tanpa `closet`.
- `PrefsProgressStore.loadHome()` (simpanan yang menggantikan lemari) menghapus kunci `costume.owned` dan `costume.wearing` sebelum membaca `home.state`; gagal hapus ditelan, seperti simpanan lain yang tidak pernah melempar.

- [ ] **Step 1: Tulis test yang gagal**

```dart
// test/screens/navigation_test.dart
testWidgets('/kostum tidak ada lagi', (tester) async {
  await pumpApp(tester, location: '/kostum');
  // layar "rute tidak ada" dengan tombol kembali ke kamar
});

// test/app/progress_test.dart, grup simpanan
test('kunci kostum lama diabaikan dan dihapus saat dimuat', () async {
  // prefs berisi costume.owned/costume.wearing → sesudah load, kunci hilang.
});
```

- [ ] **Step 2: Jalankan test, pastikan gagal**

Run: `flutter test test/screens/navigation_test.dart test/app/progress_test.dart`
Expected: FAIL

- [ ] **Step 3: Hapus kode kostum**

Urutan aman: model (`costumes.dart`, `Wardrobe`, `_Part.wardrobe`, aksi controller, `ProgressStore`) → gambar (`OyenCostume`, `dressed`, `closet_art.dart`, Peci dan Sarung di `design_svg.dart`, `ClosetArt`, `KoIcons.costume`) → layar (folder `closet`, prop `costume` di level/hasil/putar ulang/tutorial, tombol Lemari Kostum, `AppRoutes.closet` dan rutenya, `shop_screen` yang menyebut kostum) → galeri (bagian kostum di `gallery_oyen_screen.dart`) → token `KoSize` kostum yang jadi tak terpakai → ARB (`closet`, `costume*`) dan `costumeName` di `names.dart`.

- [ ] **Step 4: Sesuaikan test yang memakai kostum**

`test_helpers.dart` (`testProgressWith(wardrobe:)`, `FailingProgressStore` bagian `wardrobe`), grup `kostum` di `progress_test`, `level_view_test`, `result_view_test`, `replay_view_test`, `progress_flow_test`; `navigation_test` (nav Lemari Kostum, galeri Oyen "pose dan kostum"), `overflow_test` (`AppRoutes.closet` dari daftar rute dan kasus Lemari Kostum), `names_test`, `painters_test`/`board_scene_test`/`result_art_test`/`design_sync_test` (Peci/Sarung), `screenshot_test` (potret Lemari Kostum), `test/screenshots/brand_test.dart` (potret toko `12-lemari-kostum` memakai `AppRoutes.closet`: buang potretnya; potret toko baru dan listing jadi urusan langkah 26). Daftar ini bukan pegangan utama: sesudah Step 3, `flutter analyze` menunjukkan setiap pemakaian yang tersisa, dan `grep -rn "costume\|Costume\|wardrobe\|Wardrobe\|AppRoutes.closet" lib test` harus kosong (kecuali komentar sejarah di `accessories.dart`). Grup kostum yang masih relevan diganti test aksesoris di kamar (sudah ada di Task 4) — hapus yang hanya menguji kostum.

- [ ] **Step 5: Jalankan seluruh test dan analyze**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` dan semua test lulus.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: remove costume closet and Oyen costumes"
```

---

### Task 7: `overflow_test`, potret layar, dan dokumen

**Files:**
- Modify: `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`, `test/screenshots/scenes.dart` (kalau butuh adegan kamar), `docs/DESIGN_NOTES.md`, `CLAUDE.md`, `docs/ROADMAP.md`, `docs/translations/review-{en,pt,ru}.md` (dibuat ulang)

- [ ] **Step 1: Tambah kasus `overflow_test`**

Rute `/` sudah ada di daftar `routes` (kamar kosong). Tambah kasus bersaldo 99999:
- kamar penuh: 20 barang ditaruh dan 9 kucing, semuanya beraksesoris
- mode hias (tombol Hias ditekan, baki Gudang berisi beberapa barang)
- kartu kucing dengan panel Camilan, lalu panel Aksesoris (stok dan aksesoris lengkap)

Semua di 360×640 sampai 412×915, teks 100% dan 130%, keempat bahasa, dan `AppRoutes.closet` dihapus dari daftar rute.

- [ ] **Step 2: Jalankan `overflow_test`**

Run: `flutter test test/screens/overflow_test.dart`
Expected: PASS (perbaiki tata letak kalau ada overflow, jangan melonggarkan test)

- [ ] **Step 3: Perbarui potret layar**

`screenshot_test.dart`: adegan Beranda jadi kamar (beberapa barang ditaruh, 3 kucing, salah satunya beraksesoris, `roomRandom: () => Random(1)` supaya gambarnya sama tiap kali) per bahasa; adegan Lemari Kostum dihapus.

Run: `flutter test test/screenshots --dart-define=SCREENSHOTS=true`
Expected: PASS, berkas di `build/screenshots/390x844/<bahasa>/` diperiksa sendiri (kamar sesuai desain 19).

- [ ] **Step 4: Catat keputusan di `docs/DESIGN_NOTES.md` bagian "Langkah 23"**

Minimal: rumus skala kamar dan pembagian dinding/lantai (termasuk `n360`), posisi kucing diacak tiap kamar dibuka (seed lewat `roomRandom` di test), tiap lepas langsung disimpan, definisi titik merah Toko/Aksesoris, keterangan kartu kucing memakai `kittyDesc` Toko (desain menulis teks contoh lain untuk 4 kucing), elusan yang kena batas hanya memunculkan hati, tombol kembali saat hias = Selesai, animasi kamar (termasuk bob tanda lesu, gelembung koin, label mangkuk, dan tag "Baru!") ditunda ke langkah 24, ikon tangan desain tidak dipakai, kostum lama dihapus tanpa migrasi, dan yang masih menyebut kostum di luar kode (listing toko yang masih menyebut peci dan sarung, kebijakan privasi, potret toko `12-lemari-kostum`, GDD) ditinggal untuk langkah 26 sesuai roadmap.

- [ ] **Step 4b: Buat ulang berkas tinjauan terjemahan**

ARB berubah, jadi jalankan `python tool/translations/make_review.py` dan commit `docs/translations/review-{en,pt,ru}.md` hasilnya (jangan diedit tangan).

- [ ] **Step 5: Perbarui `CLAUDE.md` bagian "Struktur" dan centang langkah 23 di `docs/ROADMAP.md`**

Tambahkan `lib/screens/room/`, `lib/game/render/room_art.dart`, `RoomGeometry`/`roomSprites`, token baru, dan hapus semua penyebutan Lemari Kostum, `costumes.dart`, `OyenCostume`, `dressed`, serta test kostum. Isi ringkasan "Selesai:" langkah 23 seperti langkah 21–22.

- [ ] **Step 6: Jalankan `/check`**

Run: `flutter analyze && flutter test`
Expected: `No issues found!`, semua test lulus.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "docs: step 23 notes, roadmap, and structure"
```

---

## Sesudah semua task

1. `superpowers:requesting-code-review` dengan satu subagent effort high, lalu `superpowers:receiving-code-review` untuk menimbang temuannya.
2. `superpowers:verification-before-completion` sebelum push.
3. `git push -u origin feat/kamar-oyen-beranda` lalu `gh pr create --base main` dengan judul `feat: Kamar Oyen sebagai Beranda, tanpa Lemari Kostum` dan badan bahasa Indonesia (pembuka "Langkah 23 roadmap: ...", daftar perubahan, asumsi baru, baris "Verifikasi:").
