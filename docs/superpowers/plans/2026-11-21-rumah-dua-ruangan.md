# Rumah Oyen dua ruangan: rencana implementasi

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Proyek ini memakai `superpowers:executing-plans` di sesi utama (`CLAUDE.md`, "Skill dan effort").

**Goal:** Beranda menjadi rumah dua ruangan berperspektif (ruang tengah + teras) yang dihubungkan satu pintu. Kucing menyebar ke tempat nyaman, berjalan sendiri lewat pintu, dan bisa diajak pindah.

**Architecture:**
- Matematika lantai perspektif dan aturan ruangan ada di model Dart murni (`lib/game/model/house.dart`). `Room` dan `RoomLife` memakainya.
- Gambar ruangan adalah SVG desain yang disalin utuh (`design_svg_house.dart`) dan digambar `SvgTemplate`. Untuk itu `SvgTemplate` diperluas dengan gradien, clip, poligon, dan `class`.
- Layar kamar dipecah menjadi tiga bagian:
  - `RoomScene`: satu ruangan dengan semua lapisannya.
  - `HousePager`: geser dan transisi.
  - Bagian pintu: tombol, ikon perhatian, dan nyala pintu.

  `RoomView` tetap memegang keadaan.

**Tech Stack:** Flutter, Dart murni untuk model, `SvgTemplate` buatan proyek, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-21-rumah-dua-ruangan-design.md`

**Desain:**
- Kanvas: https://claude.ai/code/artifact/d110cbe8-34a2-4f87-85c5-2ec0b41829ba
- Salinan lokal ada di `docs/design/rumah-dua-ruangan/project/`. Folder ini tidak ikut repo; ambil ulang lewat Artifact `read` + `paths` + `out_dir`.
- Angka yang dikutip di bawah berasal dari catatan kanvas `kRuangTengah`, `kTeras`, `kSkala`, dan `n360` di `canvas.json`, serta dari `AdeganTengah`/`AdeganTeras.dc.html`.

## Global Constraints

- Semua koordinat desain memakai area rumah 390×652 (layar 390×844, panel bawah mulai y 652). Titik hilangnya (195, 230).
- Skala kedalaman: `s = 0,75 + 0,4 × (y_kaki − 392) / 260`. Contohnya: y 392 → 0,75, y 456 → 0,85, y 600 → 1,07, y 652 → 1,15. Barang dinding tetap 0,75.
- Urutan lapisan:
  1. Latar
  2. Cahaya (lantai)
  3. Bayangan
  4. Kucing yang sedang lewat pintu
  5. Kusen depan
  6. Barang dan kucing, urut y kaki
  7. Cahaya (udara)
  8. UI
- Transisi pindah ruangan: hanya area rumah yang bergeser, sejauh satu lebar layar, `easeInOut` 420 ms. Header dan panel bawah diam.
- Betah sesudah diajak: `lifeStaySeconds = 300` (5 menit, angka awal untuk dites di HP). Tidak disimpan.
- Mangkuk satu, selalu di ruang tengah. Hanya hammock dan lampu bulan yang boleh di teras di antara barang dinding.
- Ikon perhatian: satu ikon saja, prioritas lapar → sedih → hadiah koin.
- Semua teks baru (termasuk label pembaca layar) masuk ke keempat ARB, Indonesia ditulis dulu. Jalankan `flutter gen-l10n` dan `python tool/translations/make_review.py`.
- Tidak ada warna atau ukuran hardcode di widget. Warna baru dari desain masuk ke `KoColors`; ukuran tetap masuk ke `KoSize` atau konstanta geometri bernama.
- Kurangi gerak: pindah ruangan langsung tanpa geser, kucing yang diajak langsung pindah, dan animasi SVG diam (`time: null`).
- Pemain tidak pernah pindah ruangan lewat menu atau tab (anti-tujuan spec).

## Review Focus

1. **Simpanan lama.** Barang v1 yang posisinya jatuh di jalur pintu tidak boleh menutup pintu. `Room` menggeser spot itu ke tempat terdekat yang boleh (test di Task 2).
2. **Mode Hias.** Kucing yang sedang lewat pintu saat Hias dibuka atau kartu dibuka tidak boleh terjebak di balik kusen. `interrupt`/`paused` menyelesaikan pindahnya (test di Task 5).
3. **Tombol kembali sistem saat menghias.** Kalau Hias dibuka di teras, tombol kembali menutup Hias dan pemain tetap di teras. Tombol kembali biasa di teras tidak pindah ruangan, sama seperti v1 (test di Task 5 dan Task 10).
4. **Kucing di-*sync* ulang (beli kucing atau barang).** Kucing yang sedang di teras tidak boleh tiba-tiba kembali ke ruang tengah (test di Task 5).
5. **Layar kecil 360×640 dan teks 130%.** Chip "‹ Ruang tengah", status angkat, dan keterangan Gudang tidak boleh terpotong di keempat bahasa (`overflow_test`, Task 13).

---

# Langkah 33: gambar dua ruangan dan pindah ruangan

Branch `feat/rumah-dua-ruangan-gambar`. Di awal, ikuti alur git `CLAUDE.md`.

### Task 1: `SvgTemplate` bisa menggambar lapisan rumah

**Files:**
- Modify: `lib/game/render/svg_template.dart`, `lib/game/render/css_animation.dart`
- Test: `test/game/render/svg_template_test.dart`, `test/game/render/css_animation_test.dart`

**Interfaces:**
- Produces:
  - `SvgTemplate(String source, {Map<String, CssKeyframes> keyframes, Map<String, String> classes = const {}})`.
  - `classes` memetakan nama kelas ke deklarasi CSS (mis. `'rm-awan': 'animation: rmAwan 16s ease-in-out infinite alternate'`). Atribut `class` digabung ke depan `style`. Kelas yang tidak dikenal diabaikan; `rm-anim` hanya penanda kurangi gerak.

- [ ] **Step 1: Tulis test yang gagal**, satu per kemampuan, memakai pola warna piksel yang sudah ada:
  - `polygon`, `polyline`, dan `line`: piksel di dalam `<polygon points="0,0 10,0 10,10">` terisi, dan garis `line` dengan `stroke-width` tergambar.
  - `rgba(176,122,79,0.26)` di `fill` dan `stroke` menghasilkan alfa 0,26.
  - `<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">` dengan dua `stop` (`stop-color`, `stop-opacity`) lalu `fill="url(#g)"`: piksel atas ≈ warna stop pertama, piksel bawah ≈ warna stop kedua (`objectBoundingBox`).
  - `radialGradient` `cx`/`cy`/`r` diuji dengan cara yang sama.
  - `<clipPath id="c"><polygon …/></clipPath>` dan `<g clip-path="url(#c)">`: isi di luar poligon tidak tergambar.
  - `class="rm-awan"` dengan `classes:` bergerak seperti `style` yang sama pada `time` 4 dan 8.
  - `transform-box: fill-box; transform-origin: 50% 100%` berputar terhadap tengah-bawah kotak isi. Ini perlu di `css_animation_test`, karena sekarang `fill-box` hanya didukung bersama `center`.
  - `url(#tidak-ada)` dan elemen `<pattern>` tetap gagal dengan `FormatException`/`UnsupportedError`.
- [ ] **Step 2:** Jalankan `flutter test test/game/render/svg_template_test.dart test/game/render/css_animation_test.dart`. Hasil yang diharapkan: test baru FAIL.
- [ ] **Step 3: Implementasi**
  - `<defs>` dikumpulkan saat urai dan tidak digambar.
  - Gradien menjadi `ui.Gradient.linear`/`radial` yang dihitung dari kotak isi bentuknya.
  - `clip-path` di `g` menjadi `canvas.clipPath`.
  - `polygon`/`polyline` menjadi `Path` dari `points`; `polyline` tanpa `close`.
  - Perbarui dokumentasi subset di kepala `SvgTemplate`.
- [ ] **Step 4:** Jalankan `flutter test test/game/render/`. Semua PASS, termasuk `svg_binding_test` (cache varian tidak rusak).
- [ ] **Step 5: Commit** `feat(render): gradients, clip paths, polygons and classes in SvgTemplate`

### Task 2: Model rumah: lantai perspektif dan ruangan barang

**Files:**
- Create: `lib/game/model/house.dart`
- Modify: `lib/game/model/room.dart`, `lib/game/model/home_items.dart`
- Test: `test/game/model/house_test.dart`, `test/game/model/room_test.dart`

**Interfaces:**
- Produces, di `house.dart` (Dart murni, koordinat desain):
  - `enum HouseRoom { living, terrace }` dengan `HouseRoom get other`.
  - `const houseDepthBack = 392.0`, `houseDepthFront = 652.0`.
  - `double depthScale(double feetY)` (dijepit 0,75–1,15).
  - `const terraceHangers = {RoomItemId.hammock, RoomItemId.lampuBulan}`.
  - `bool canPlaceIn(RoomItemId id, HouseRoom room)`:
    - Lantai: boleh di mana saja, kecuali mangkuk yang hanya di `living`.
    - Dinding: hanya di `living`, kecuali `terraceHangers` yang juga boleh di `terrace`.
  - `class HouseFloor`, `const HouseFloor()`:
    - Zona kaki = poligon Hias `(84,398) (306,398) (386,508) (386,646) (4,646) (4,508)`.
    - `({double x, double y}) feetAt(Spot spot)`: `y = 398 + spot.y × 248`; `x` mengikuti tepi kiri–kanan zona di kedalaman itu.
    - `Spot spotAtFeet(double x, double y)` (dijepit).
    - `({double x, double y, double scale}) itemFeet(RoomItem item, Spot spot)`: tengah dijepit supaya lebar `item.width × scale` tetap di dalam 0–390.
    - `double distance(Spot a, Spot b)`: jarak px desain antar-kaki.
  - Ruangan:
    - `Spot threshold(HouseRoom room)`: ruang tengah (345, 456), teras (46, 456).
    - `List<({double x, double y})> doorPath(HouseRoom room)`: ruang tengah `(318,402) (384,491) (266,570) (212,508)`, teras `(72,401) (176,516) (124,578) (4,492)`.
    - `bool blocksDoor(RoomItem item, HouseRoom room, Spot spot)`: jejak barang = kotak selebar gambar, dari `feetY − 12 × scale` sampai `feetY`, dan kotak itu bersinggungan dengan poligon jalur. Barang `flat` (karpet) dan barang dinding tidak pernah menghalangi.
    - `Spot allowedSpot(RoomItem item, HouseRoom room, Spot spot)`: [spot] sendiri kalau tidak menghalangi. Kalau menghalangi, cari spot terdekat (jarak kaki) di kisi 41×41 yang tidak menghalangi.
  - Dinding ruang tengah: x 88–302, y 150–332, skala 0,75. Gantungan teras dibahas di Task 6.
- Produces, di `Room`:
  - `HouseRoom roomOf(RoomItemId id)` (default `living`).
  - `Map<RoomItemId, Spot> placedIn(HouseRoom room)`.
  - `Room place(RoomItemId id, Spot spot, {HouseRoom room = HouseRoom.living})`: tidak berubah kalau `!canPlaceIn`. Barang lantai disimpan dengan `allowedSpot`.
  - Factory `Room(...)` menerima `rooms: Map<RoomItemId, HouseRoom>` dan juga menjalankan `allowedSpot`.
  - JSON menambah `'terrace': [nama…]`. Tanpa field itu, semua barang ada di ruang tengah. Nama yang tidak boleh di teras dibuang ke ruang tengah.
  - `buy` menaruh barang di ruang tengah.
  - `store` menghapus ruangannya.

- [ ] **Step 1: Tulis test yang gagal** di `house_test.dart`:
  - `depthScale(392) == 0.75`, `depthScale(456) ≈ 0.8485`, `depthScale(652) == 1.15`.
  - `feetAt(Spot(0, 0)) == (x: 84, y: 398)`, `feetAt(Spot(1, 1)) == (x: 386, y: 646)`, lalu bolak-balik `spotAtFeet(feetAt(s)) == s` untuk beberapa spot.
  - `canPlaceIn`: lukisan di teras false, hammock di teras true, mangkuk di teras false, kasur di teras true.
  - `blocksDoor`: kasur dengan kaki di (300, 500) di ruang tengah true; kasur di (146, 432) false; karpet di jalur pintu false.
  - `allowedSpot`: spot yang menghalangi pindah ke spot yang tidak menghalangi dan jaraknya ≤ jarak semua spot sah lain di kisi.
- [ ] **Step 2: Tulis test yang gagal** di `room_test.dart`:
  - JSON tanpa `terrace` membuat semua barang di ruang tengah.
  - `place(kasur, …, room: terrace)` lalu JSON bolak-balik mempertahankan teras.
  - `place(lukisan, …, room: terrace)` tidak berubah.
  - Simpanan v1 dengan kasur di jalur pintu terbaca dengan spot yang tidak menghalangi (Review Focus 1).
  - `placedIn(terrace)` hanya berisi barang teras.
- [ ] **Step 3:** Jalankan `flutter test test/game/model/house_test.dart test/game/model/room_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 4:** Implementasikan `house.dart` dan perubahan `Room`. Konstanta dinding v1 (`wallLeft`…`floorBottom`) dan `spotAt`/`positionOf` di `home_items.dart` tetap dipakai untuk `defaultSpot`. Spot v1 dibaca langsung sebagai pecahan di zona baru, dan catat ini di komentar `Spot`.
- [ ] **Step 5:** Jalankan `flutter test test/game/model/`. Semua PASS. Perbaiki test lama yang spotnya bergeser karena `allowedSpot` dengan angka baru, bukan dengan melemahkan assert-nya.
- [ ] **Step 6: Commit** `feat(home): house rooms, perspective floor and door path`

### Task 3: Lapisan gambar ruangan dari desain

**Files:**
- Create: `lib/game/render/design_svg_house.dart`, `lib/game/render/house_art.dart`
- Modify: `lib/game/render/render.dart`, `test/game/render/design_sync_test.dart`
- Test: `test/game/render/house_art_test.dart`

**Interfaces:**
- Produces, di `design_svg_house.dart` (isi `<svg>` disalin utuh, jangan diketik ulang):
  - `houseLivingBackSvg` (`LatarTengah`), `houseLivingLightSvg` (`CahayaTengah`, dengan `<sc-if value="{{lantai}}">`/`{{udara}}`), `houseLivingFrameSvg` (`KusenTengah`).
  - Untuk teras: `houseTerraceBackSvg`, `houseTerraceLightSvg`, `houseTerraceFrameSvg`.
  - `houseKeyframes` (`rmAwan`, `rmDaun`, `rmDenyut`) dan `houseClasses` (`rm-awan`, `rm-daun`, `rm-denyut`).
- Produces, di `house_art.dart`:
  - `enum HouseLayer { back, floorLight, frame, airLight }`.
  - `void paintHouseLayer(Canvas canvas, HouseRoom room, HouseLayer layer, {required Size size, double? time})`: viewBox 390×652 diskalakan tidak seragam ke [size] (catatan `n360`: geometri sama, diperkecil).
  - Lapisan tanpa `style`/`class` di-cache diam.

- [ ] **Step 1: Tulis test yang gagal** di `house_art_test.dart`, berupa warna piksel di koordinat desain:
  - Ruang tengah `back`:
    - (195, 250) dinding belakang ≈ `#FCE6C8`.
    - (350, 240) langit lewat pintu: kebiruan, komponen B > R.
    - (195, 600) lantai ≈ gradien `#E3BC86`→`#EBC896`.
  - Ruang tengah `frame`: (386, 300) ≈ `#C99466`, sedangkan (200, 300) transparan.
  - Teras `back`: titik di bukaan pintu kiri (40, 300) memperlihatkan ruang tengah yang hangat, yaitu bukan biru langit.
  - `floorLight` ruang tengah di (300, 480) lebih kuning daripada `back` saja.
  - Semua lapisan teras dan ruang tengah bisa di-*render* pada `time` 0 dan 3 tanpa melempar.
- [ ] **Step 2: Tulis test yang gagal** di `design_sync_test.dart`, grup baru yang dilewati kalau `docs/design/rumah-dua-ruangan/project/` tidak ada: isi `<svg>` keenam berkas desain sama dengan konstanta Dart (normalisasi spasi seperti grup yang ada).
- [ ] **Step 3:** Jalankan `flutter test test/game/render/house_art_test.dart test/game/render/design_sync_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 4:** Salin keenam `<svg>`, lalu implementasikan `paintHouseLayer`. Kalau salah satu SVG memakai elemen yang belum didukung, perluas Task 1, jangan ubah SVG-nya.
- [ ] **Step 5:** Jalankan test yang sama. Hasil yang diharapkan: PASS.
- [ ] **Step 6: Commit** `feat(render): living room and terrace layers from design`

### Task 4: Geometri layar dan satu ruangan tergambar (`RoomScene`)

**Files:**
- Modify: `lib/screens/room/room_geometry.dart` (tulis ulang), `lib/screens/room/room_parts.dart` (`RoomBackground` diganti), `lib/screens/room/room_view.dart`
- Create: `lib/screens/room/room_scene.dart`
- Test: `test/screens/room_geometry_test.dart` (tulis ulang), `test/screens/room_screen_test.dart`

**Interfaces:**
- Consumes: `HouseFloor`, `depthScale`, `canPlaceIn` (Task 2), `paintHouseLayer` (Task 3).
- Produces:
  - `RoomGeometry(Size room, HouseRoom which)`:
    - `sx = width/390`, `sy = height/652`, `artScale = ((sx+sy)/2).clamp(0.6, 1.2)`.
    - `Offset toScreen(double x, double y)`.
    - `Rect boxOf(RoomItem item, Spot spot)`:
      - Lantai: kaki dari `itemFeet`, ukuran × `scale × artScale`.
      - Dinding ruang tengah: rentang x 88–302 / y 150–332, ukuran × 0,75 × `artScale`.
    - `Spot spotFor(RoomItem item, Offset topLeft)`.
    - `Rect catBoxOf(KittyId kitty, Spot spot)`: kaki = `feetAt(spot)`, sisi = (Oyen 116 / lainnya 96) × `depthScale` × `artScale`, kaki di 0,92 tinggi kotak.
    - `Spot catSpotAt(KittyId kitty, Rect box)`, `double feetOf(Rect catBox)`.
    - `Path door` (bukaan), `Rect doorTap`: ruang tengah (320,205) 64×172, teras (6,205) 64×172.
    - `Path doorPathArea`, `Rect wallZone`.
    - `Offset sadMarkAt`: ruang tengah (327,238), teras (15,238). `Offset coinBubbleAt`: ruang tengah (319,226), teras (7,226).
    - `Rect shadowOf(Rect box, {required bool cat, bool lifted = false})`:
      - Elips di kaki.
      - Lebar: kucing 0,68 × kotak, barang 0,8 × lebar, diangkat 0,4 × kotak.
      - Tinggi 0,2 × lebar (mengikuti kode `AdeganTengah`; catatan `kSkala` menulis 0,14).
    - `pathTo` dan `mirrorsInUse`/`userBoxOf` diport. Lantai dasar lompatan = garis kaki paling belakang (y 398). Konstanta `catHop*` dan `perchTops` tetap.
  - `roomSprites({items, cats, geo})`: dinding, lalu barang lantai dan kucing urut y kaki. Barang `flat` tetap paling bawah.
  - `RoomScene(geo:, room:, sprites:, passing:, time:, …)`: menumpuk lapisan sesuai urutan di Global Constraints. `passing` = kucing yang sedang lewat pintu (Task 6). Bayangan memakai token warna baru `KoColors.roomShadow` (`#3B2716`) dengan opasitas dan blur 1,5 sebagai konstanta.

- [ ] **Step 1: Tulis ulang test** di `room_geometry_test.dart`:
  - Pada 390×652, `catBoxOf(oyen, spotAtFeet(345,456))` punya kaki y 456 dan sisi 116 × 0,8485.
  - `boxOf(lukisan, …)` di ruang tengah ada di dalam `wallZone`.
  - Kucing di kaki y 600 lebih besar daripada di y 432.
  - `roomSprites` mengurutkan kucing di depan kasur kalau kakinya lebih bawah.
  - Pada 360×488 (n360), bukaan pintu ruang tengah ≈ (296,181) (352,174) (352,409) (296,340) dalam toleransi 6 px.
  - `pathTo` ke lampu bulan di dinding rendah memakai 1 lompatan, dan rak tinggi tanpa pijakan menghasilkan `null`.
- [ ] **Step 2:** Jalankan test. Hasil yang diharapkan: FAIL.
- [ ] **Step 3: Implementasi**
  - Tulis ulang `RoomGeometry`.
  - Pindahkan penggambaran ruangan dari `RoomView._room` ke `RoomScene`.
  - Untuk sekarang `RoomView` hanya menggambar `HouseRoom.living`.
  - Hapus `RoomBackground` lama. Hapus juga `paintRoomWindow`/`paintRoomFloorDecor` dan `roomWindowSvg`/`roomFloorDecorSvg` beserta test dan grup `design_sync`-nya, karena sudah termasuk di latar baru.
- [ ] **Step 4:** Jalankan `flutter test test/screens/` lalu perbaiki test kamar yang memakai posisi lama. `room_screen_test`, `decorate_test`, dan `room_life_test` menghitung posisi dari `RoomGeometry`, bukan angka mentah.
- [ ] **Step 5:** Ambil potret `19-kamar*` (`flutter test test/screenshots --dart-define=SCREENSHOTS=true`) dan bandingkan dengan `AdeganTengah` di kanvas.
- [ ] **Step 6: Commit** `feat(room): perspective living room scene`

### Task 5: Teras, pintu, dan pindah ruangan

**Files:**
- Create: `lib/screens/room/house_pager.dart`, `lib/screens/room/door_parts.dart`
- Modify: `lib/screens/room/room_view.dart`, `lib/screens/room/room_parts.dart` (`RoomHeader`), `lib/l10n/app_*.arb`, `lib/widgets/ko_icon.dart` (ikon `door` dan `chevronLeft` dari SVG desain)
- Test: `test/screens/house_pager_test.dart`

**Interfaces:**
- Produces:
  - `HousePager({required HouseRoom room, required ValueChanged<HouseRoom> onRoom, required bool enabled, required Widget Function(HouseRoom) builder})`:
    - Kedua ruangan dibangun hanya selama bergeser.
    - Geser horizontal dari area kosong: ruang tengah ke kiri, teras ke kanan.
    - Saat dilepas: geseran > 1/3 lebar atau fling > 700 px/detik pindah ruangan, selain itu kembali.
    - Animasi 420 ms `easeInOut`.
    - `animateTo(HouseRoom)` (ketuk pintu atau chip).
    - Kurangi gerak (`MediaQuery.disableAnimations`): langsung pindah.
    - `enabled: false` (Hias, kucing diangkat): tidak mengenali geser.
  - `DoorButton(geo:, onTap:, label:)`:
    - Kotak `doorTap`, tidak terlihat.
    - Semantik tombol `l.doorTo(room)` → "Pergi ke teras" / "Pergi ke ruang tengah".
  - `RoomChip`: "‹ Ruang tengah" di teras, di (16,106) setinggi 44. Ketuk = `animateTo(living)`. Tidak ada di ruang tengah (sesuai desain).
  - `RoomView` punya `HouseRoom _room` (awal `living`, tidak disimpan).
  - ARB baru: `roomName` (`select` living/terrace), `doorTo` (`select`).

- [ ] **Step 1: Tulis test yang gagal** di `house_pager_test.dart` (pakai `pumpApp` kamar diam):
  - Ketuk pintu → sesudah 420 ms tampil teras: chip "Ruang tengah" ada dan tombol semantik "Pergi ke ruang tengah" ada.
  - Pada 210 ms, `Transform`/offset area rumah = −195 × `sx`, sedangkan header dan panel bawah tidak bergeser.
  - Geser dari area kosong 60 px lalu lepas → tetap di ruang tengah. Geser 200 px → teras.
  - Geser yang dimulai di teras ke kiri tidak berbuat apa-apa.
  - `disableAnimations` → satu `pump` langsung di teras.
  - Mode Hias: geser dan pintu tidak berfungsi.
  - Tombol kembali sistem di teras membuka perilaku v1 (keluar dari Beranda), bukan pindah ruangan.
- [ ] **Step 2:** Jalankan `flutter test test/screens/house_pager_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan:
  - `HousePager` dengan `HorizontalDragGestureRecognizer` pada lapisan latar di bawah sprite, supaya ketukan kucing dan seret barang menang.
  - Bagian pintu, chip, dan ARB.
  - Lalu `flutter gen-l10n` dan `make_review.py`.
- [ ] **Step 4:** Jalankan `flutter test test/screens/` → PASS.
- [ ] **Step 5:** Pasang build debug di HP (`flutter run -d 75pvdew4da8dtgww`). Cek apakah teras langsung terlihat, apakah geser enak dipakai, dan apakah ketukan kucing tidak terganggu. Tulis hasilnya di badan PR.
- [ ] **Step 6:** Centang langkah 33 di `docs/ROADMAP.md`, isi `docs/DESIGN_NOTES.md` "Langkah 33", perbarui Struktur `CLAUDE.md` (model rumah, `house_art`, `RoomScene`, `HousePager`), lalu `/check`, review, dan PR.
- [ ] **Step 7: Commit** `feat(room): terrace, door and room transition`

---

# Langkah 34: kucing di dua ruangan

Branch `feat/rumah-dua-ruangan-kucing`.

### Task 6: `RoomLife` dua ruangan dan tempat nyaman

**Files:**
- Modify: `lib/game/model/room_life.dart`
- Test: `test/game/model/room_life_test.dart`

**Interfaces:**
- Consumes: `HouseRoom`, `HouseFloor`, `threshold`.
- Produces:
  - `RoomLife({required Random random, HouseFloor floor = const HouseFloor()})`, menggantikan `spanX`/`spanY`. Kecepatan jalan memakai `floor.distance`.
  - `LifePose` ditambah `sleep` dan `lounge`. `CatActivity` ditambah `leaving` dan `entering`, keduanya `onFloor == false`.
  - `class LifePlace { const LifePlace(this.x, this.y, {required LifePose pose, LifeHeading heading = LifeHeading.down, double seconds = lifeSleepSeconds, int weight = 3}) }`, dengan x/y kaki dalam px desain.
  - `const lifePlaces = {HouseRoom.living: [...], HouseRoom.terrace: [...]}`:
    - Ruang tengah: bawah jendela (146,432) lounge; tengah lantai (200,560) sleep; ambang pintu (345,456) idle.
    - Teras: petak matahari (182,600) lounge; dekat pagar (282,432) idle; dekat pot (296,556) idle; ambang pintu (46,456) idle.
  - `lifeCrowdRadius = 90`, `lifeCrowdFactor = 0.25`, dihitung hanya untuk kucing di ruangan yang sama.
  - `lifeTravelWeight = 1`, `lifeDoorSeconds = 0.6`, `lifeStaySeconds = 300`.
  - `CatLife`:
    - `HouseRoom room`, `int? place` (indeks di `lifePlaces[room]`), `double stayLeft`.
    - `bool traveling` (sedang menuju ambang untuk pindah).
    - `double get doorProgress` (0–1 selama `leaving`/`entering`).
  - `sync({required Map<KittyId, (HouseRoom, Spot)> homes, required targets, required uses, required Map<RoomItemId, HouseRoom> itemRooms, toys, hungry, sad})`:
    - Kucing yang sudah ada mempertahankan ruangannya (Review Focus 4).
    - Kucing baru memakai `homes`.
  - `LifeEvent` baru: `LeftRoom(kitty, from)` dan `EnteredRoom(kitty, to)`.
  - Perilaku:
    - Kucing hanya memilih barang dan tempat di ruangannya sendiri.
    - Pindah sendiri hanya kalau `stayLeft <= 0`.
    - Kucing lapar yang tidak seruangan dengan mangkuk berjalan pindah dulu.
    - Urutan pindah: jalan ke `threshold`, lalu `leaving` selama `lifeDoorSeconds`, lalu ganti ruangan dengan spot di `threshold` ruangan baru, lalu `entering` selama `lifeDoorSeconds`, lalu `_next`.
  - `interrupt()` dan `paused = true`: kucing yang `leaving`/`entering` langsung selesai di ruangan tujuan (Review Focus 2).

- [ ] **Step 1: Tulis test ber-seed yang gagal:**
  - Dengan dua tempat kosong di satu ruangan dan satu kucing lain di dekat salah satunya, dalam 200 undian ≥ 70% memilih tempat yang jauh, tapi ada yang memilih tempat yang dekat.
  - Kucing di teras tidak pernah memilih kasur ruang tengah.
  - Majukan 600 detik dengan seed: setiap kucing yang pindah ruangan melewati urutan walking→leaving→entering, ada `LeftRoom` lalu `EnteredRoom`, dan spot sesudah masuk = `threshold(to)`.
  - Kucing lapar di teras dengan mangkuk di ruang tengah: kegiatan pertamanya `traveling`, lalu `ReachedBowl`.
  - `interrupt()` saat `leaving` menghasilkan `room == to`, aktivitas idle, dan spot `threshold(to)`.
  - `sync` ulang dengan `homes` yang menaruh kucing di ruang tengah tidak memindahkan kucing yang sudah di teras.
  - Semua test lama tetap lulus setelah konstruktornya disesuaikan.
- [ ] **Step 2:** Jalankan `flutter test test/game/model/room_life_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan. Logika `LifePlace` dan undian berbobot `double` boleh diambil dari branch `spike/teras` (`git show origin/spike/teras:lib/game/model/room_life.dart`), lalu disesuaikan dengan ruangan.
- [ ] **Step 4:** Jalankan `flutter test test/game/model/` → PASS.
- [ ] **Step 5: Commit** `feat(home): cats roam two rooms and comfy spots`

### Task 7: Kucing hidup di layar: lewat pintu dan tempat awal

**Files:**
- Modify: `lib/screens/room/room_view.dart`, `lib/screens/room/room_scene.dart`, `lib/screens/room/room_geometry.dart`, `lib/l10n/app_*.arb`
- Test: `test/screens/room_life_test.dart`

**Interfaces:**
- Consumes: Task 6.
- Produces:
  - `Map<KittyId, (HouseRoom, Spot)> houseHomes(Iterable<KittyId> kitties, Random random)`, menggantikan `kittySpots`/`shuffledKittySlots`:
    - Oyen di ruang tengah, di `starterOyenSpot = spotAtFeet(205, 556)`.
    - Kucing lain dibagi bergantian ke kedua ruangan menurut urutan acak, di spot acak yang tidak berada di `doorPath`.
    - Kucing yang baru dibeli muncul di ruang tengah.
  - `RoomGeometry.passingBox(KittyId kitty, HouseRoom room, double progress, {required bool leaving})`:
    - Ruang tengah keluar: kaki dari (345,456) ke (400,470).
    - Teras masuk: dari (−10,470) ke (46,456).
    - Ukuran mengikuti `depthScale`.
  - Pemetaan pose: `LifePose.sleep` → `KittyPose.sleep`, `lounge` → `KittyPose.rebah`.
  - Pengumuman pembaca layar `l.kittyLeftTo(kitty, room)` hanya untuk kucing yang meninggalkan ruangan yang sedang dibuka.

- [ ] **Step 1: Tulis test yang gagal** (`pumpApp(roomLife: true)` + `settle`):
  - Kucing yang dipaksa pindah (seed tertentu, atau `invite` dari Task 8 kalau lebih mudah; catat pilihannya) terlihat di ruang tengah selama `leaving` dalam lapisan di bawah kusen. Sesudah selesai ia tidak digambar di ruang tengah, dan ada di teras sesudah pindah ruangan.
  - Kucing di ruangan lain tidak membangun `KittyView` (kinerja).
  - Ada pengumuman `kittyLeftTo` untuk kucing yang keluar dari ruangan yang sedang dibuka.
  - Kurangi gerak tidak menggerakkan kucing (perilaku v1).
- [ ] **Step 2:** Jalankan test. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan, lalu `gen-l10n` dan `make_review.py`.
- [ ] **Step 4:** Jalankan `flutter test test/screens/` → PASS.
- [ ] **Step 5: Commit** `feat(room): cats walk through the door`

### Task 8: Mengajak kucing: tombol kartu dan tahan-seret

**Files:**
- Modify: `lib/game/model/room_life.dart`, `lib/screens/room/kitty_card.dart`, `lib/screens/room/room_view.dart`, `lib/screens/room/door_parts.dart`, `lib/screens/room/room_parts.dart` (status header), `lib/l10n/app_*.arb`
- Test: `test/game/model/room_life_test.dart`, `test/screens/kitty_card_test.dart`, `test/screens/invite_test.dart`

**Interfaces:**
- Produces:
  - `RoomLife.invite(KittyId kitty, {bool atDoor = false, bool instant = false})`:
    - `stayLeft = lifeStaySeconds` dimulai saat kucing masuk ruangan tujuan.
    - `atDoor`: spot langsung di `threshold`, lalu `leaving`.
    - `instant`: langsung di `threshold` ruangan tujuan.
    - Undangan baru mengganti undangan lama, sehingga pemain bisa memanggil balik lebih awal.
  - `KittyCard(... room: HouseRoom, onInvite: VoidCallback)`:
    - Deskripsi ditambah `l.kittyInRoom(room)` ("Sedang di ruang tengah.").
    - Tombol hijau `KoButtonKind.success` dengan ikon pintu, berkunci `kitty-invite`, teks `l.inviteTo(room.other)` ("Ajak ke teras" / "Ajak ke ruang tengah"). Menekannya menutup kartu dan `invite`.
  - Tahan-seret di `RoomView`:
    - `LongPressGestureRecognizer` pada kucing. Kucing terangkat: `translateY −30`, skala 1,1 dengan titik (50%, 92%), bayangan diangkat.
    - `DoorGlow`: bukaan pintu diisi `rgba(255,200,61,0.3)`, garis 10 px opasitas 0,45 berdenyut `rmDenyut`, dan garis putus `#F59A33` 3,5 px `8 6`. Warna-warna ini masuk ke token.
    - Header berganti menjadi status `l.liftHint(room.other)` ("Bawa ke pintu untuk ajak ke teras") dengan `role=status`.
    - `HousePager` dimatikan selama kucing diangkat.
    - Dilepas di dalam `door` (dilebarkan 16 px) memanggil `invite(atDoor: true)`.
    - Dilepas di tempat lain: kucing pindah ke spot lantai di bawah jari (`catSpotAt`), lalu `rest`.
  - Aksi pembaca layar pada kucing: `CustomSemanticsAction(label: l.inviteTo(room.other))`.

- [ ] **Step 1: Tulis test model yang gagal:**
  - `invite` membuat kucing menuju ambang dan masuk teras.
  - Selama 300 detik di teras kucing itu tidak memilih pindah, tapi tetap berganti kegiatan (mis. ke petak matahari).
  - Sesudah 300 detik, pindah sendiri boleh lagi.
  - `invite` balik saat masih betah langsung berjalan.
  - `instant` langsung di ruangan tujuan.
- [ ] **Step 2: Tulis test layar yang gagal:**
  - Kartu menampilkan "Sedang di ruang tengah." dan "Ajak ke teras", dan ketukannya menutup kartu sehingga kucing berjalan ke pintu.
  - Kartu di teras menampilkan "Ajak ke ruang tengah".
  - Tahan 600 ms lalu seret ke pintu memanggil `invite`. Selama diangkat, status header tampil dan geser ruangan tidak terjadi.
  - Seret ke lantai kosong memindahkan spot kucing.
  - Ketuk biasa tetap membuka kartu.
  - Aksi semantik bekerja.
  - Kurangi gerak memakai `invite(instant: true)`.
  - Kartu 360×640 teks 130% tidak overflow.
- [ ] **Step 3:** Jalankan `flutter test test/game/model/room_life_test.dart test/screens/kitty_card_test.dart test/screens/invite_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 4:** Implementasikan, lalu `gen-l10n` dan `make_review.py`.
- [ ] **Step 5:** Jalankan test yang sama → PASS.
- [ ] **Step 6: Commit** `feat(room): invite cats to the other room`

### Task 9: Ikon perhatian di pintu dan "Lihat di kamar"

**Files:**
- Modify: `lib/game/model/house.dart`, `lib/screens/room/door_parts.dart`, `lib/screens/room/room_view.dart`, `lib/app/routes.dart`, `lib/screens/shop/buy_sheet.dart`, `lib/l10n/app_*.arb`
- Test: `test/game/model/house_test.dart`, `test/screens/door_attention_test.dart`, `test/screens/room_screen_test.dart`

**Interfaces:**
- Produces:
  - `enum DoorNeed { hungry, sad, reward }`.
  - `(KittyId, DoorNeed)? doorAttention(Iterable<KittyId> kitties, {required bool Function(KittyId) hungry, required bool Function(KittyId) sad, required bool Function(KittyId) reward})`: kebutuhan diurutkan lapar → sedih → hadiah, lalu urutan `KittyId`.
  - Di `RoomView`:
    - `hungry` = `needs.hunger <= sadThreshold` (aturan `SadMarkView(hungry:)` yang sudah ada).
    - `sad` = lesu dan bukan lapar.
    - `reward` = `canClaimKittyReward`.
  - `DoorAttention`: `SadMarkView` di `sadMarkAt` atau `CoinBubbleView` di `coinBubbleAt`, tanpa semantik sendiri. Label `DoorButton` menjadi `l.doorAttention(room, kitty, need)`, mis. "Ke teras. Mochi di teras lapar".
  - `AppRoutes.home` ditambah `AppRoutes.homeShowing(KittyId)` = `/?kucing=<nama>`. `RoomView(showKitty:)` pindah ke ruangan kucing itu tanpa animasi saat parameter berganti. `buy-room` memakainya.

- [ ] **Step 1: Tulis test yang gagal:**
  - `doorAttention`: lapar menang atas koin; sedih menang atas koin; tidak ada kebutuhan → null.
  - Layar:
    - Mochi lapar di teras membuat ikon lesu tampil di ruang tengah dekat pintu, dan label pintu menyebut lapar.
    - Kucing di ruang tengah yang punya hadiah membuat gelembung koin tampil di teras.
    - Kucing yang lapar di ruangan yang sedang dibuka tidak memunculkan ikon pintu.
  - Beli kucing → "Lihat di kamar" dari teras membuka ruangan kucing baru (ruang tengah).
- [ ] **Step 2:** Jalankan test. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan, lalu `gen-l10n` dan `make_review.py`.
- [ ] **Step 4:** Jalankan `flutter test` → PASS.
- [ ] **Step 5:** Cek di HP: apakah kucing melakukan hal menarik kalau didiamkan, dan apakah efek suara bertumpuk saat beberapa kucing aktif (catatan langkah 32). Tulis hasilnya di PR.
- [ ] **Step 6:** Centang langkah 34, isi DESIGN_NOTES "Langkah 34", perbarui Struktur `CLAUDE.md` (`RoomLife` dua ruangan, `invite`, `doorAttention`, `houseHomes`), lalu `/check`, review, dan PR.
- [ ] **Step 7: Commit** `feat(room): door attention icon and room-aware "see in room"`

---

# Langkah 35: Hias dua ruangan, pemain baru, dan cek akhir

Branch `feat/rumah-dua-ruangan-hias`.

### Task 10: Mode Hias per ruangan dan jalur pintu

**Files:**
- Modify: `lib/screens/room/decorate.dart`, `lib/screens/room/room_view.dart`, `lib/app/progress_controller.dart` (`placeItem(id, spot, {HouseRoom room})`), `lib/l10n/app_*.arb`
- Test: `test/screens/decorate_test.dart`, `test/app/progress_test.dart`

**Interfaces:**
- Produces:
  - `ProgressController.placeItem(RoomItemId id, Spot spot, {HouseRoom room = HouseRoom.living})`.
  - Seret hanya untuk barang di ruangan yang sedang dibuka.
  - Seret yang dilepas di jalur pintu bergeser ke `allowedSpot`.
  - Ketuk barang di Gudang menaruhnya di ruangan yang sedang dibuka, di posisi bawaannya (sesudah `allowedSpot`).
  - `ZoneGuides(geo:, room:)`:
    - Ruang tengah: kotak dinding (88,150) 214×182 rx 14 dan poligon lantai. Gaya garis biru `6 5` mengikuti `AdeganTengah`.
    - Jalur pintu: garis jingga `#C9650C` `7 5` 2,4 px dan arsir miring 45° (garis 4 px tiap 10 px).
    - Chip "Area dinding", "Area lantai", dan "⊘ Jalur pintu" `l.zoneDoorPath` di posisi desain.
  - Header Hias seperti desain: "Seret barang ke tempat baru" dan Selesai, sesuai `DecorateHint` v1.
  - Gaya garis disalin persis dari desain; warna masuk ke `KoColors`.

- [ ] **Step 1: Tulis test yang gagal:**
  - Kasur diseret ke tengah jalur pintu ruang tengah, lalu dilepas: spotnya tidak menghalangi dan tersimpan.
  - Hias di teras lalu taruh kasur dari Gudang: `roomOf(kasur) == terrace`.
  - Panduan "Jalur pintu" tampil di kedua ruangan.
  - Selesai di teras tetap di teras, dan tombol kembali sistem menutup Hias (Review Focus 3).
  - Kucing yang sedang lewat pintu saat Hias dibuka berakhir di ruangan tujuan.
- [ ] **Step 2:** Jalankan `flutter test test/screens/decorate_test.dart test/app/progress_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan, lalu `gen-l10n` dan `make_review.py`.
- [ ] **Step 4:** Jalankan test yang sama → PASS.
- [ ] **Step 5: Commit** `feat(room): decorate each room and keep the door path clear`

### Task 11: Gantungan teras dan Gudang yang diredupkan

**Files:**
- Modify: `lib/screens/room/room_geometry.dart`, `lib/screens/room/room_scene.dart`, `lib/screens/room/decorate.dart` (`StorageTray`), `lib/l10n/app_*.arb`
- Test: `test/screens/decorate_test.dart`, `test/screens/room_geometry_test.dart`

**Interfaces:**
- Produces:
  - `RoomGeometry.boxOf` di teras untuk gantungan:
    - Hammock: pojok kiri-atas (143,5, 350), skala 0,86 (103×60). Tali vertikal `#B07A4F` 2,2 px di x 150,4 dan 239,8 dari y 162 sampai 356. Urut gambar setara kaki y 464, dengan bayangan elips di (195,462) rx 42 opasitas 0,11.
    - Lampu bulan: tergantung di G3 (305,158). **Keputusan asisten** (desain tidak memberi kotaknya): skala 0,75, tengah-atas di (305, 200), tali dari 162 ke 200, dan urut di belakang barang lantai.
  - Spot gantungan di teras diabaikan. Seret gantungan di teras hanya bisa ke Gudang; dilepas di tempat lain, ia kembali ke titik gantungnya.
  - Mode Hias di teras menampilkan titik gantung: cincin r 12 di G1 (150,4,158), G2 (239,8,158), dan G3 (305,158, garis putus `4 3`), berdenyut `rmDenyut`. Di bawahnya ada garis putus G1–G2 di y 174 dan chip "Titik gantung · hammock" serta "Lampu bulan" di posisi desain.
  - `StorageTray(items:, dimmed: Set<RoomItemId>, onPlace:, onDimmed:)`:
    - Slot yang diredupkan: opasitas 0,42 dan grayscale 0,5.
    - Labelnya `l.storageLivingOnly(item)`.
    - Ketukannya memunculkan keterangan gelap di atas slot dengan panah: `l.livingOnlyNote` ("Bisa dipasang di ruang tengah").
    - Gantungan yang ditaruh di teras memunculkan `l.hangNote` ("Gantung di balok atap"), memakai gaya `ShopFlash`.
    - `dimmed` di teras = barang dinding yang bukan `terraceHangers`.
  - Hammock sudah dicek tidak memotong jalur pintu: kotak gantungan bukan barang lantai, dan jalur dari ambang ke tengah teras tetap kosong (test geometri).

- [ ] **Step 1: Tulis test yang gagal:**
  - Kotak hammock di teras pada 390×652 = (143,5, 350, 103,2, 60,2).
  - Taruh hammock dari Gudang di teras membuatnya tergambar dengan dua tali dan `roomOf == terrace`.
  - Jam di Gudang teras diredupkan, dan ketukannya menampilkan "Bisa dipasang di ruang tengah" tanpa menaruh jam.
  - Kotak hammock tidak bersinggungan dengan `doorPath(terrace)`.
  - Kucing bisa memakai hammock di teras (`pathTo` tidak null).
- [ ] **Step 2:** Jalankan test. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan, lalu `gen-l10n` dan `make_review.py`.
- [ ] **Step 4:** Jalankan test yang sama → PASS.
- [ ] **Step 5: Commit** `feat(room): terrace hang points and dimmed storage`

### Task 12: Rumah pemain baru (sisa langkah 33 lama)

**Files:**
- Modify: `lib/screens/room/room_parts.dart` (`EmptyRoomHints`), `lib/screens/room/room_scene.dart`
- Test: `test/screens/room_screen_test.dart`

**Interfaces:**
- Produces:
  - Ruang tengah baru (hanya mangkuk dan Oyen):
    - Bidang kosong dinding (212,176) 88×70 rx 12 dan bidang kosong lantai berbentuk elips (82,398) 126×56, dengan garis putus 2,5 px.
    - Gelembung ajakan di (20,570) maksimal 186 lebar, mengangguk `translateY` 0→−4 px dalam 1,8 detik.
    - Teks memakai kunci ARB v1 yang sudah ada.
    - Label mangkuk tetap `KeepInside` dan tidak menutupi Oyen.
  - Teras kosong menampilkan empat tempat nyaman: elips putus-putus `rx 40s ry 12s` dengan ikon tapak, tanpa semantik. Petunjuk Toko hanya ada di ruang tengah.
  - Sisa langkah 33 lama "kucing sedih kurang jelas butuh apa": sudah dijawab tanda lesu lapar/sedih v1, teks `needLowHunger`/`needLowJoy` di kartu, dan ikon pintu (Task 9). Tidak ada kode baru; cek di HP dan catat di DESIGN_NOTES.

- [ ] **Step 1: Tulis test yang gagal:**
  - Ruang tengah baru: kedua bidang kosong ada, lebar gelembung ≤ 186 × `sx`, dan kotak gelembung tidak bersinggungan dengan kotak Oyen. Hal yang sama dicek di 360×640.
  - Teras baru: tidak ada `EmptyRoomHints`, dan keempat tempat nyaman tergambar.
  - Kamar yang punya satu barang tidak menampilkan petunjuk.
- [ ] **Step 2:** Jalankan `flutter test test/screens/room_screen_test.dart`. Hasil yang diharapkan: FAIL.
- [ ] **Step 3:** Implementasikan.
- [ ] **Step 4:** Jalankan test yang sama → PASS.
- [ ] **Step 5: Commit** `feat(room): new-player rooms`

### Task 13: Layar kecil, overflow, potret, dan kinerja

**Files:**
- Modify: `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`, `tool/profile_room.dart`, `docs/performance-room-2026-11-08.md` (bagian baru), `test/screenshots/brand_test.dart` (potret toko `01-kamar`)
- Test: berkas-berkas di atas

**Interfaces:**
- Consumes: semua task sebelumnya.

- [ ] **Step 1:** Tambah ke `overflow_test` (360×640 sampai 412×915, teks 100%/130%, keempat bahasa):
  - Teras penuh dan teras Hias, termasuk keterangan Gudang yang diredupkan.
  - Status kucing diangkat.
  - Kartu kucing dengan tombol ajak.
  - Ruang tengah dengan ikon pintu.

  Jalankan, lalu perbaiki yang meluap.
- [ ] **Step 2:** Potret layar:
  - `19-kamar` ruang tengah dan `19-teras`.
  - Transisi pada 210 ms.
  - Hias kedua ruangan.
  - Pemain baru kedua ruangan, per bahasa.

  Bandingkan dengan artboard 1, 2, 5, 8, 9, dan 10 di kanvas.
- [ ] **Step 3:** Jalankan ulang `brand_test.dart --dart-define=BRAND=true` karena potret toko `01-kamar` berubah, lalu commit hasilnya.
- [ ] **Step 4:** Ukur `tool/profile_room.dart` di HP (9 kucing dibagi dua ruangan, semua barang): 15 detik pemanasan, 60 detik pengukuran, satu kali saat diam dan satu kali selama pindah ruangan bolak-balik. Batas acuannya langkah 32: bingkai > 16,67 ms ≲ 3%. Kalau angkanya jauh lebih buruk, cache lapisan latar diam sebagai `Picture` dan ukur ulang.
- [ ] **Step 5:** Centang langkah 35, isi DESIGN_NOTES "Langkah 35" (keputusan asisten: lampu bulan, bayangan 0,2, spot v1 dibaca ulang, kucing baru di ruang tengah), perbarui `CLAUDE.md`, lalu `/check`, review, dan PR.
- [ ] **Step 6: Commit** `test: two-room house overflow, screenshots and profile`

---

## Pekerjaan dokumen di awal langkah 33 (bagian dari Task 1, commit tersendiri)

- `docs/ROADMAP.md`: ganti isi langkah 33 dengan tiga langkah baru (33 gambar dan pindah ruangan, 34 kucing di dua ruangan, 35 Hias, pemain baru, dan cek akhir), masing-masing dengan "Baca dulu" (spec, rencana ini, kanvas) dan "Lalu" yang merujuk ke task di atas. Bahan brainstorming 8 Nov dipindah ke `DESIGN_NOTES` sebagai riwayat. Langkah 32 tetap terbuka.
- Spec: tambah link kanvas desain di bagian "Gambar yang dibutuhkan".
- `CLAUDE.md` "Sumber kebenaran": desain rumah dua ruangan ada di `docs/design/rumah-dua-ruangan/project/*.dc.html` (link kanvas di spec).
- Commit `docs: plan the two-room house`.
