# Pintu depan dan Gang Depan: rencana implementasi

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Proyek ini memakai `superpowers:executing-plans` di sesi utama (`CLAUDE.md`, "Skill dan effort").

**Goal:** Ruang tengah mendapat pintu depan di dinding kiri. Lewat pintu itu Oyen menyelinap ke Gang Depan saat Kumis berkunjung, dan pemain menyusul dengan satu gerakan kamera menembus pintu.

**Architecture:**
- **Model Dart murni.**
  - `lane.dart` berisi tetangga `Neighbor`, jadwal kunjungan per hari ber-seed `dayNumber`, keadaan kunjungan (gabung, perpanjang, paksa), dan geometri gang.
  - `lane_life.dart` berisi rutinitas dua kucing di gang: Oyen dan Kumis, termasuk naskah pertemuan pertama.
  - `RoomLife` hanya mendapat "keluar lewat pintu kucing" dan "pulang".
- **Gambar.** Semua lapisan gang, kusen depan, ekor, penanda, dan data daun pintu disalin skrip dari kanvas ke `design_svg_lane.dart`. Daun pintu diproyeksikan titik demi titik dengan rumus kamera desain, bukan homografi gambar.
- **Layar.** `RoomView` tetap memegang keadaan.
  - Gang digambar `LaneScene`.
  - Gerakan kamera ada di `LaneCamera`, dengan linimasa yang dihitung fungsi murni `laneCameraAt`.
  - `HousePager` tidak berubah. Gang berada di luar pager dan tidak bisa dicapai dengan geser.

**Tech Stack:** Flutter, Dart murni untuk model, `SvgTemplate` buatan proyek, `flutter_test`, Python 3 untuk skrip salin desain.

**Spec:** `docs/superpowers/specs/2026-11-22-gang-depan-design.md`

**Desain:**
- Kanvas: https://claude.ai/code/artifact/ea089b1c-2bf2-4906-932c-895e4bf207df
- Salinan lokal ada di `docs/design/gang-depan/project/` (tidak ikut repo; ambil ulang lewat Artifact `read` + `paths` + `out_dir`).
- Angka di bawah dikutip dari catatan kanvas `kPintuDepan`, `kProyeksi`, `kKamera`, `kGang`, `kTempat`, dan `n360` di `canvas.json`, serta dari `AdeganTengah`, `AdeganGang`, `PintuDepan`, dan `Kucing.dc.html`.

## Global Constraints

- Koordinat desain = area rumah 390×652, titik hilang (195, 230), trapesium lantai/tanah (78,392) (312,392) (390,500) (390,652) (0,652) (0,500). Skala kedalaman di trapesium sama dengan rumah (`depthScale`). Di belakang trapesium (hanya jalur Kumis): `s = 0,75 × (y − 230) / 162`.
- **Desain menang atas angka awal spec.** Jadi yang berlaku:
  - Kamera total 1,7 detik dengan pembagian `kKamera`.
  - Kurangi gerak = crossfade **240 ms**.
  - Daun pintu diproyeksikan per titik.
  - Semuanya dicatat di `docs/DESIGN_NOTES.md`.
- Urutan lapisan ruang tengah (`kPintuDepan`):
  1. LatarTengah
  2. Daun pintu depan (proyeksi DaunPintuDalam/Luar + pintu kucing)
  3. Ekor Kumis
  4. CahayaTengah lantai
  5. Bayangan
  6. Kucing yang lewat pintu (dipotong)
  7. KusenTengah + KusenDepan
  8. Barang dan kucing, urut y kaki
  9. CahayaTengah udara
  10. UI
- Urutan lapisan gang (`kGang`):
  1. LatarGang
  2. Daun pintu pulang
  3. CahayaGang lantai
  4. Bayangan
  5. Kucing lewat pintu
  6. KusenGang
  7. Bangku belakang
  8. Kucing di bangku
  9. Bangku depan
  10. Kucing lain urut y
  11. CahayaGang udara
- Kunjungan:
  - 3 per hari, mulai di 08.00–22.00 waktu lokal, jarak antar-mulai ≥ 2 jam, lama 8–12 menit.
  - Seed `dayNumber(hari)`; jadwal tidak disimpan.
  - Sesudah momen ekor, kunjungan berlangsung ≥ 5 menit lagi.
  - Kunjungan tidak berakhir selama pemain di gang.
  - Kunjungan paksa 20 detik sesudah ruang tengah tampil: hanya kalau level 1 menang dan `metNeighbor` false, sekali per sesi aplikasi.
- `lane.metNeighbor` hanya ditulis sesudah keduanya duduk bersama di bangku dan pemain ada di gang. Kunci `PrefsProgressStore` sendiri, ikut antrean simpan, dihapus `resetProgress`.
- Kumis bukan `KittyId`: tidak masuk Toko, `Home`, kebutuhan, aksesoris, `doorAttention`, atau galeri kucing milik pemain. Ia tetap ditampilkan di `/galeri/kucing` sebagai baris tetangga.
- Gang tidak punya Hias, Gudang, mangkuk, barang, geser, atau tahan-seret.
- Semua teks baru (termasuk label pembaca layar dan pengumuman) masuk ke keempat ARB, Indonesia ditulis dulu. Jalankan `flutter gen-l10n` dan `python tool/translations/make_review.py`.
- Tidak ada warna atau ukuran hardcode di widget. Konstanta geometri bernama ada di model atau `RoomGeometry`, warna di `KoColors`.
- SVG desain tidak diketik ulang. Semuanya lewat `tool/design/make_lane_svg.py` dan `make_house_svg.py`, lalu dijaga `design_sync_test`.

## Review Focus

1. **Oyen sedang di tengah pintu kucing saat kartu, Hias, atau reaksi dimulai.** Ia harus selesai di sisi tujuan, tidak tertahan di balik kusen. Test ada di Task 8.
2. **Aplikasi kembali dari latar belakang di tengah atau sesudah kunjungan, atau saat hari berganti.** Keadaan dihitung ulang dari jam: Oyen sudah di bangku (tanpa ekor), atau sudah pulang. Tidak boleh ada dua Kumis atau Oyen ganda. Test ada di Task 7 dan Task 12.
3. **Pemain meninggalkan gang di tengah pertemuan pertama** lewat tombol kembali sistem, chip, membuka Toko atau level, atau aplikasi ke latar belakang. `metNeighbor` tetap false, dan pertemuan diputar lagi di kunjungan berikutnya. Test ada di Task 12.
4. **Ketuk ganda pintu, atau ketuk selama gerakan kamera.** Tidak boleh ada dua transisi. Ketuk kedua melompat ke akhir. Test ada di Task 11.
5. **Simpanan lama dengan barang di jalur pintu depan yang baru** (tiang garukan di pojok kiri). Barang itu harus bergeser lewat `allowedSpot` saat dimuat. Test ada di Task 4.

---

# Langkah 36: gambar pintu depan, gang, dan Kumis

Branch `feat/gang-depan-gambar`. Di awal, ikuti alur git `CLAUDE.md`. Langkah 35 harus sudah di-merge dulu.

### Task 1: Salin desain gang ke Dart

**Files:**
- Create: `tool/design/make_lane_svg.py`, `lib/game/render/design_svg_lane.dart` (hasil skrip)
- Modify:
  - `tool/design/make_house_svg.py`: argumen kedua `<gang-depan>`, dari mana `LatarTengah`, `CahayaTengah`, dan `KusenTengah` dibaca.
  - `lib/game/render/design_svg_house.dart` (hasil skrip).
  - `lib/game/render/css_animation.dart`: `skewX`/`skewY` di `@keyframes`, untuk `ggKibar`.
- Test: `test/game/render/css_animation_test.dart`, `test/game/render/design_sync_test.dart`

**Interfaces:**
- Produces (`design_svg_lane.dart`). Semua SVG ber-viewBox 0 0 390 652 kecuali disebut lain:
  - `laneBackSvg` (LatarGang)
  - `laneFloorLightSvg` dan `laneAirLightSvg` (CahayaGang svg ke-0 dan ke-1; kupu-kupu ada di udara)
  - `laneFrameSvg` (KusenGang)
  - `livingFrontFrameSvg` (KusenDepan)
  - `benchBackSvg` dan `benchFrontSvg` (Bangku)
  - `laneMarkerSvg` (PenandaGang, viewBox 0 0 48 52)
  - `kumisTailSvg`: `<g>` ekor di `AdeganTengah`, termasuk kelas `ek-goyang`, origin (46.2, 426.2)
  - `laneKeyframesCss`: semua `@keyframes` CahayaGang, PenandaGang, `ekGoyang`, dan `atSeru`
  - `laneClassStyles`: `gg-awan2`, `gg-ayun`, `gg-kibar`, `gg-daun2`, `gg-kupu`, `gg-kupu2`, `gg-sayap`, `pg-bob`, `ek-goyang`, plus kelas `rm-*` lama
  - `doorLeafData`: objek `DATA` di `PintuDepan.dc.html` (`E` = poligon daun, `FL` = pintu kucing), ditulis sebagai literal Dart `List<Map>`
  - `seruSvg`: gelembung "!" di `AdeganTengah`, viewBox 0 0 24 30

- [ ] **Step 1:** Tulis test `css_animation_test` "skewX di keyframe" untuk `ggKibar`: pada t = 1,6 dari 3,2 detik, matriks memiliki `skewX(-2.2deg)`, dan di t = 0 identitas.
- [ ] **Step 2:** Jalankan `flutter test test/game/render/css_animation_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Tambah `skewX`/`skewY` ke `CssTransformFn` beserta matriksnya.
- [ ] **Step 4:** Tulis skrip, pola sama dengan `make_house_svg.py`:
  - Ambil `<svg>` ke-n per berkas.
  - Untuk `doorLeafData`, ambil teks sesudah `const DATA = ` sampai `;` lalu `json.loads`.
  - Header: "disalin utuh, jangan diketik ulang".
- [ ] **Step 5:** Jalankan dua perintah ini, lalu pastikan `git diff lib/game/render/design_svg_house.dart` hanya mengubah `houseLivingBackSvg`:
  - `python tool/design/make_house_svg.py docs/design/rumah-dua-ruangan/project docs/design/gang-depan/project lib/game/render/design_svg_house.dart`
  - `python tool/design/make_lane_svg.py docs/design/gang-depan/project lib/game/render/design_svg_lane.dart`
- [ ] **Step 6:** Perluas `design_sync_test` dengan grup `gang depan` (dilewati tanpa `docs/design/gang-depan/`). Setiap konstanta harus sama dengan isi berkas desainnya.
- [ ] **Step 7:** Jalankan `flutter test test/game/render`. Harapannya: PASS. Lalu commit `feat(render): copy front lane design layers`.

### Task 2: Kumis dan pose `endus`/`geser`

**Files:**
- Create: `lib/game/model/neighbor.dart`
- Modify:
  - `lib/game/render/kitty.dart`, `lib/game/render/kitty_painter.dart`
  - `lib/game/render/design_svg_home.dart`: `kittySvg` dan `kittyKeyframes` ditulis ulang dari `docs/design/gang-depan/project/Kucing.dc.html` dengan potongan skrip di `make_lane_svg.py` (opsi `--kitty <out>`), bukan diketik.
  - `lib/l10n/names.dart`, keempat ARB
  - `lib/gallery/` (galeri kucing: baris Kumis)
- Test: `test/game/render/kitty_test.dart`, `test/l10n/names_test.dart`

**Interfaces:**
- Produces:
  - `enum Neighbor { kumis }` di `neighbor.dart`.
  - `KittyLook({KittyId? kitty, Neighbor? neighbor, ..., bool bowl = true})`: tepat satu dari `kitty`/`neighbor` terisi (assert). `bowl` = mangkuk di pose `eat`, yaitu prop `mangkuk` desain. Kumis minum dari piring air memakai `bowl: false`.
  - `KittyLook.colors` memilih `neighborPalette[neighbor]`.
  - `KittyPose` tambah `endus`, `geser1`, `geser2`.
  - `KittyLook.shiftPose(double time)` = `geser1`/`geser2` bergantian tiap `walkFrameSeconds`, seperti `walkPose`.
  - `KittyColors` tambah `mask`, `brow`, `kumisOn`, `scarfOn`, `notch`, `shortTail`, `tailBand`, dan `noAcc`, dengan default seperti `Object.assign` desain.
  - `kittyLabel` dan `neighborName(l, Neighbor)`: "Kumis" di keempat bahasa.

- [ ] **Step 1:** Tulis test yang gagal:
  - Palet Kumis: warna `fur` `#F7F1E6`, `stripe` `#5E6E82`, `eye` `#C99A2E`.
  - Piksel syal merah `#D9574A` di sekitar (50, 74) pada pose `idle`.
  - Telinga sompek: piksel di (77, 13) tidak berwarna `earR` untuk Kumis, tapi berwarna `earR` untuk Oyen.
  - Ekor pendek: tidak ada piksel ekor di ujung ekor panjang Oyen pada (26, 88) di pose `sleep`.
  - `endus` mengubah `translate` kepala (bandingkan bounds dengan `idle`).
  - `geser1` dan `geser2` berbeda posisi kaki (`pawLX` 35/38).
  - `KittyLook(neighbor: Neighbor.kumis, accessory: AccessoryId.pita)` tetap tanpa pita (`noAcc`).
  - `bowl: false` di pose `eat` tidak menggambar mangkuk.
- [ ] **Step 2:** Jalankan `flutter test test/game/render/kitty_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Salin palet `kumis` dari `Kucing.dc.html` ke `neighborPalette` (termasuk `FurPatch` `pBody`, `pHead`, dst. dengan `G1` `#8494A7` dan `G2` `#5E6E82`). Port selisih `renderVals` desain ke `kittyVals`:
  - `leanT`, `earRD`, `sleepEarRD`, `sleepEarsD`, `sleepTailD`, `sleepTipD`
  - `pawLX`/`pawRX`, `showBowl`
  - `tailsPendek`
  - `kcSniff`
  - pose `endus`/`geser*` di `eyeOpen`, `eyeSleepy`, `mouthW`, `tailAnim`, `syalAnim`

  Daftar lengkapnya ada di diff `Kucing.dc.html` dua kanvas.
- [ ] **Step 4:** Regenerasi `kittySvg`/`kittyKeyframes` dengan skrip. `design_sync_test` untuk Kucing sekarang membaca kanvas gang-depan.
- [ ] **Step 5:** Tambah baris "Tetangga: Kumis" di galeri kucing (semua pose + `endus`, `geser1`, `geser2`).
- [ ] **Step 6:** Jalankan `flutter test test/game/render test/l10n test/gallery`. Harapannya: PASS. Lalu commit `feat(render): add Kumis and sniff/shift poses`.

### Task 3: Daun pintu terproyeksi

**Files:**
- Create: `lib/game/render/door_leaf.dart`
- Test: `test/game/render/door_leaf_test.dart`

**Interfaces:**
- Produces:
  - `enum DoorLeafSide { front, home }`: `front` = pintu depan ruang tengah (desain `kiri`), `home` = pintu pulang di gang (`kanan`, X dicerminkan).
  - `HousePoint doorLeafPoint(DoorLeafSide side, double angleDeg, double u, double v, {double n = 0})`, memakai rumus `kProyeksi` (F 270, Z1 2,16, DW 0,716149…, YT −0,144, DH 1,528615…).
  - `bool doorShowsOutside(DoorLeafSide side, double angleDeg)`: dari tanda luas poligon (logika `flip`/`muka` desain).
  - `void paintDoorLeaf(Canvas canvas, DoorLeafSide side, {required double angleDeg, double? flapDeg, bool leaf = true})`:
    - Poligon dari `doorLeafData`. `f == 'd'` = sisi dalam, `'l'` = sisi luar.
    - Pita tebal 0,045 di tepi bebas.
    - `flapDeg` null = tanpa pintu kucing (desain `flap: none`, saat kucing lewat).
    - Lubang `h` digambar dengan `PathFillType.evenOdd`.

- [ ] **Step 1:** Tulis test yang gagal (toleransi 0,6 px):
  - `front` di 0°: sudut (0,0)/(1,0)/(1,1)/(0,1) = (70,212)/(8,203)/(8,489)/(70,403).
  - `home` di 0° = (320,212)/(382,203)/(382,489)/(320,403).
  - `home` di 8°: tepi bebas x ≈ 363.
  - Pintu kucing `front` di flap 0: (61,344) (25,375) (25,455) (61,407).
  - `doorShowsOutside(front, 20)` false dan `doorShowsOutside(front, 40)` true; untuk `home` sebaliknya.
  - Piksel: `paintDoorLeaf(front, angleDeg: 0, flapDeg: 0)` mewarnai (40, 300) dengan kayu `#C99466` (toleransi seperti test rumah).
- [ ] **Step 2:** Jalankan `flutter test test/game/render/door_leaf_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan dengan port `P3`, `dPath`, `area`, dan `fnF` dari `PintuDepan.dc.html`.
- [ ] **Step 4:** Jalankan test yang sama. Harapannya: PASS. Lalu commit `feat(render): project front door leaf like the design`.

### Task 4: Model pintu depan dan geometri gang

**Files:**
- Create: `lib/game/model/lane.dart` (bagian geometri; jadwal menyusul di Task 6)
- Modify: `lib/game/model/house.dart`, `lib/game/model/home_items.dart` (posisi bawaan `tiang`), `lib/game/model/room.dart` (kalau perlu)
- Test: `test/game/model/house_test.dart`, `test/game/model/lane_test.dart`, `test/game/model/room_test.dart`

**Interfaces:**
- Produces di `house.dart`:
  - `HouseFloor.frontDoorPath` = (72,402) (6,491) (124,570) (178,508).
  - `doorPaths(HouseRoom room)`: ruang tengah → [pintu teras, pintu depan]; teras → [pintu teras].
  - `onDoorPath`, `blocksDoor`, dan `allowedSpot` memakai semua jalur di `doorPaths`.
  - `HouseFloor.frontThreshold` = `spotAtFeet(70, 436)`: tempat Oyen berdiri sebelum menyelinap (bayangan desain di (70, 436)).
  - `const flapClipX = 45.2` dan `const laneFlapClipX = 344.8`: garis potong kucing yang lewat pintu kucing.
- Produces di `lane.dart` (semua titik kaki desain):
  - `laneBenchLeft` (133.2, 396.5), `laneBenchRight` (198.3, 396.5), `laneBenchMiddle` (165.7, 396.5).
  - `laneBenchScaleY = 455`: skala kucing di bangku = `depthScale(455)`.
  - `laneHopFrom` (124.2, 487.8), `laneHopSeconds = 0.42`.
  - `laneThreshold` (300, 470).
  - `lanePlaces`, berisi `LifePlace`:
    - teduh (88,584) `lounge`, teduh (170,574) `lounge`
    - piring air (51,481) `eat`
    - tangga (85.7, 390.1), skala dari y 404
    - depan pintu (300,470) `idle`
  - `kumisArrivePath` (226,292) (205,394) (176,470) dan `kumisLeavePath` (190,470) (210,394) (232,330) (226,292).
  - `double laneScale(double feetY)`: `depthScale` di y ≥ 392, `0,75 × (y − 230)/162` di belakangnya.

- [ ] **Step 1:** Tulis test yang gagal:
  - `onDoorPath(living, spotAtFeet(60, 480))` true.
  - Tiang garukan di posisi bawaan baru (kaki (266,414) skala `depthScale(414)`, sama dengan `AdeganTengah` `barang('tiang', 266, 414)`) tidak `blocksDoor`.
  - `Room.fromJson` dengan tiang di pojok kiri lama memindahkannya keluar jalur (Review Focus 5).
  - `laneScale(292)` ≈ 0,287 dan `laneScale(455)` ≈ 0,847.
- [ ] **Step 2:** Jalankan `flutter test test/game/model`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan. Ubah `defaultX`/`defaultY` tiang agar kakinya di (266,414) (lewat `spotAtFeet`), lalu perbarui test katalog di `home_items_test` yang mengunci posisi lama.
- [ ] **Step 4:** Jalankan `flutter test test/game/model test/screens/room_geometry_test.dart test/screens/decorate_test.dart`. Harapannya: PASS. Lalu commit `feat(house): front door path and lane geometry`.

### Task 5: Ruang tengah dengan pintu depan, dan `LaneScene`

**Files:**
- Modify:
  - `lib/game/render/house_art.dart`: `HouseLayer.frame` ruang tengah menggambar KusenTengah lalu KusenDepan.
  - `lib/screens/room/room_scene.dart`: parameter `door` (widget di antara latar dan cahaya lantai) dan `aboveDoor` (ekor).
  - `lib/screens/room/room_view.dart`: `RoomScene(door:)` ruang tengah dengan `paintDoorLeaf(front, angleDeg: 0, flapDeg: 0)`.
- Create:
  - `lib/game/render/lane_art.dart`: `enum LaneLayer { back, floorLight, frame, benchBack, benchFront, airLight }`, `laneLayerAnimated`, `paintLaneLayer(canvas, layer, size:, time:)`, cache seperti `paintHouseLayer`.
  - `lib/screens/lane/lane_scene.dart`
  - `lib/widgets/game_art.dart`: tambah `DoorLeafView` dan `LaneMarkerView`.
- Test:
  - `test/game/render/lane_art_test.dart`
  - `test/screens/lane_scene_test.dart`
  - potret `test/screenshots/` `36-ruang-tengah-pintu-depan`, `36-gang-utama`, `36-gang-kosong`

**Interfaces:**
- Produces:
  - `LaneScene({required RoomGeometry geo, double? time, double homeDoorDeg = 8, double? flapDeg = 0, List<SceneShadow> shadows, List<Widget> passing, List<Widget> onBench, List<Widget> sprites})`. Urutannya mengikuti Global Constraints.
  - `geo` = `RoomGeometry(size, HouseRoom.living)`, karena bukaan pintu pulang sama dengan pintu teras ruang tengah. `geo.door`/`doorTap` dipakai apa adanya.

- [ ] **Step 1:** Tulis test warna piksel `lane_art_test`, dengan warna yang dibaca dari berkas desain di titik bersangkutan:
  - tenda warung merah di sekitar (60,140)
  - dudukan bangku `#D4A170` di (160,398)
  - kusen pintu pulang di (386,300)
  - layer diam tidak digambar ulang (`laneLayerAnimated(LaneLayer.frame)` false)
- [ ] **Step 2:** Tulis widget test `lane_scene_test`. Sprite di `onBench` digambar di atas `benchBack` dan di bawah `benchFront`, diperiksa lewat urutan anak `Stack` dengan kunci `lane-bench-back`, `lane-on-bench`, `lane-bench-front`.
- [ ] **Step 3:** Jalankan test-nya. Harapannya: FAIL.
- [ ] **Step 4:** Implementasikan. Potret layar ruang tengah harus memperlihatkan pintu depan tertutup, pintu kucing, dan keset seperti artboard 1b.
- [ ] **Step 5:** Jalankan `flutter test test/game/render test/screens`. Bandingkan potret dengan artboard 1a, 1b, 7, dan 9 (`flutter test test/screenshots --dart-define=SCREENSHOTS=true`). Lalu commit `feat(room): draw the front door and the lane scene`.
- [ ] **Step 6:** Akhir langkah 36:
  - Catat "Langkah 36" di `DESIGN_NOTES.md` (desain menang atas angka spec, proyeksi per titik, KusenDepan di lapisan frame).
  - Perbarui `CLAUDE.md` "Struktur" (`design_svg_lane.dart`, `door_leaf.dart`, `lane_art.dart`, `neighbor.dart`, `lane.dart`, `LaneScene`, skrip baru).
  - Centang langkah 36 di `ROADMAP.md`.
  - Review, `/check`, lalu PR.

---

# Langkah 37: kunjungan Kumis dan rutinitas gang

Branch `feat/gang-depan-kunjungan`.

### Task 6: Jadwal dan keadaan kunjungan

**Files:**
- Modify: `lib/game/model/lane.dart`
- Test: `test/game/model/lane_test.dart`

**Interfaces:**
- Produces:
  - Konstanta:
    - `laneVisitsPerDay = 3`
    - `laneWindowStartHour = 8`, `laneWindowEndHour = 22`
    - `laneMinGap = Duration(hours: 2)`
    - `laneMinVisit = Duration(minutes: 8)`, `laneMaxVisit = Duration(minutes: 12)`
    - `laneFollowTime = Duration(minutes: 5)`
    - `laneForcedDelay = Duration(seconds: 20)`
  - `class LaneVisit { final DateTime start; final DateTime end; bool contains(DateTime t); LaneVisit until(DateTime end); }`
  - `List<LaneVisit> laneVisitsOn(DateTime day)`: `Random(dayNumber(day))`, urut mulai. Kunjungan mulai di jendela; boleh berakhir sesudah 22.00.
  - `LaneVisit? laneVisitAt(DateTime now, {DateTime? heldUntil, LaneVisit? forced})`:
    - Gabungkan kunjungan hari ini dan kemarin (yang melewati tengah malam) dengan `forced`.
    - `heldUntil` memperpanjang kunjungan yang memuat `now` atau yang berakhir sesudah `heldUntil` dimulai.
    - Kunjungan yang mulai sebelum akhir kunjungan berjalan digabung.
    - Hasilnya kunjungan yang memuat `now`, atau null.

- [ ] **Step 1:** Tulis test yang gagal:
  - Seed tetap: hari yang sama selalu memberi jadwal yang sama, dan hari lain berbeda.
  - 200 hari acak: tiap hari 3 kunjungan, mulai di 08:00–22:00, jarak ≥ 2 jam, lama 8–12 menit.
  - `laneVisitAt` di luar kunjungan = null.
  - `heldUntil` 15 menit sesudah akhir: masih berjalan di akhir + 10 menit.
  - Perpanjangan yang menabrak kunjungan berikutnya digabung jadi satu `LaneVisit` dengan `end` yang lebih lambat (tidak pernah ada dua Kumis).
  - `forced` yang dimulai sekarang terlihat.
  - Kunjungan 21:55 + 12 menit tetap terlihat pukul 22:05.
- [ ] **Step 2:** Jalankan `flutter test test/game/model/lane_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan. Jadwal diundi dengan coba-ulang yang berbatas (mis. 50 kali) supaya jarak 2 jam terpenuhi. Kalau gagal, pakai tiga slot tetap 09:00/14:00/19:00 + acak menit, supaya fungsi selalu mengembalikan 3 kunjungan.
- [ ] **Step 4:** Jalankan test yang sama. Harapannya: PASS. Lalu commit `feat(lane): daily neighbor visit schedule`.

### Task 7: Kunjungan dan pertemuan pertama di `ProgressController`

**Files:**
- Modify: `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`
- Test: `test/app/progress_test.dart` (grup `gang depan`), `test/test_helpers.dart` (`testProgressWith(metNeighbor:)`)

**Interfaces:**
- Produces:
  - `ProgressStore.loadMetNeighbor() → Future<bool>` dan `saveMetNeighbor(bool)`.
  - `PrefsProgressStore.laneKey = 'lane.metNeighbor'`; nilai bukan bool dibaca false.
  - `MemoryProgressStore.metNeighbor`.
  - `_Part.lane`, ditaruh sesudah `home` dalam urutan tulis.
  - Di `ProgressController`:
    - `bool get metNeighbor` dan `Future<void> meetNeighbor()` (idempoten).
    - `bool get lanesOpen` = level 1 menang.
    - `LaneVisit? get laneVisit` = `laneVisitAt(clock(), heldUntil: _laneHeld, forced: _laneForced)`; null kalau `!lanesOpen`.
    - `bool get oyenInLane` = `laneVisit != null && !_oyenHomeFrom(laneVisit)`.
    - `void holdLane()`: dipanggil tiap penyegaran selama pemain di gang; `_laneHeld = clock() + 1 menit`.
    - `void followTail()`: `_laneHeld = max(_laneHeld, clock() + laneFollowTime)`.
    - `bool forceFirstVisit()`: sekali per sesi, hanya kalau `lanesOpen && !metNeighbor && laneVisit == null`; membuat `_laneForced` 10 menit mulai sekarang.
    - `void sendOyenHome()`: Oyen pulang lebih awal dari kunjungan ini karena lapar.
  - Semua keadaan memori ini tidak disimpan. `resetProgress` menulis `metNeighbor = false`.

- [ ] **Step 1:** Tulis test yang gagal:
  - `meetNeighbor` tersimpan, dan `ProgressController.load` ulang dengan store yang sama → `metNeighbor` true.
  - Tanpa `meetNeighbor`, muat ulang → false.
  - Data rusak (`'ya'` di kunci) → false.
  - `resetProgress` → false dan tersimpan.
  - Penyimpanan gagal → `hasUnsavedChanges` lalu `retrySaves` menulisnya (grup `simpanan gagal`, urutan `writes`).
  - `laneVisit` null sebelum level 1 menang.
  - `forceFirstVisit` true sekali lalu false; false sesudah `metNeighbor`.
  - `followTail` → kunjungan masih ada 4 menit 59 detik kemudian walau jadwalnya sudah lewat.
  - Jam maju melewati akhir tanpa `holdLane` → null (Review Focus 2).
- [ ] **Step 2:** Jalankan `flutter test test/app/progress_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan.
- [ ] **Step 4:** Jalankan `flutter test test/app`. Harapannya: PASS. Lalu commit `feat(progress): neighbor visits and remembered first meeting`.

### Task 8: Oyen keluar dan pulang lewat pintu kucing (`RoomLife`)

**Files:**
- Modify: `lib/game/model/room_life.dart`
- Test: `test/game/model/room_life_test.dart`

**Interfaces:**
- Produces:
  - Di `CatLife`:
    - `bool outside`
    - `bool viaFlap`: `leaving`/`entering` lewat pintu kucing, digambar dipotong di `flapClipX`.
  - `void goOut(KittyId kitty, {bool instant = false})`:
    - Kucing di ruang tengah berjalan ke `frontThreshold`, lalu `leaving` (`viaFlap`), lalu `outside = true` dengan event `WentOut(kitty)`.
    - Di teras, `instant`, atau sedang `paused`: langsung `outside`.
    - Kalau `stayLeft > 0` atau `invited`: ditunda sampai betah habis (ajakan menang).
  - `void comeHome(KittyId kitty, {bool instant = false})`: `entering` `viaFlap` di `frontThreshold`, lalu `EnteredRoom(kitty, living)`. `instant` = langsung di `frontThreshold` diam.
  - Kucing `outside` dilewati `advance`, `users`, dan undian keramaian. `sync` tidak memindahkannya.
  - `bool get wantsOut` per kucing: `goOut` sudah diminta tapi ditunda.

- [ ] **Step 1:** Tulis test yang gagal (seed tetap):
  - `goOut(oyen)` dari tengah lantai → berjalan, `leaving` `viaFlap`, lalu `WentOut` dan `outside`.
  - `paused = true` di tengah `leaving` → langsung `outside` (Review Focus 1).
  - `goOut` saat diajak ke teras (`stayLeft` 300) → baru keluar sesudah 300 detik.
  - Kucing lain tidak memilih tempat Oyen yang sudah di luar.
  - `comeHome` → `entering` lalu `EnteredRoom`, Oyen di ruang tengah.
  - `sync` dengan kucing baru tidak memasukkan kembali Oyen yang di luar.
- [ ] **Step 2:** Jalankan `flutter test test/game/model/room_life_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan dengan memakai `_startWalk`, `_finishPassing`, dan `lifeDoorSeconds`.
- [ ] **Step 4:** Jalankan test yang sama. Harapannya: PASS. Lalu commit `feat(life): Oyen goes out and home through the cat flap`.

### Task 9: `LaneLife`: rutinitas gang dan pertemuan pertama

**Files:**
- Create: `lib/game/model/lane_life.dart`
- Test: `test/game/model/lane_life_test.dart`

**Interfaces:**
- Consumes: `lane.dart` (Task 4, 6), `LifePlace`, `LifePose`, `LifeHeading`, `CatActivity`, `lifeWalkSpeed`, `lifeIdleSeconds`.
- Produces:
  - `enum LaneCat { oyen, kumis }`.
  - `class LaneActor`: `x`, `y`, `heading`, `activity`, `pose` (`LifePose` + `LanePose { sniff, shift }` lewat `LaneActor.lanePose`), `onBench`, `hopProgress`, `doorProgress`, `viaFlap`, `alpha` (Kumis memudar di ujung gang).
  - `LaneLife({required Random random})`. Metodenya:
    - `start({required bool firstMeeting, bool oyenComing = true, bool midVisit = false})`:
      - `midVisit` = keduanya sudah di bangku.
      - Selain itu Kumis datang lewat `kumisArrivePath` lalu duduk di `laneBenchMiddle`, dan Oyen keluar dari pintu kucing pulang (`viaFlap`) lalu duduk di `laneHopFrom` menghadap atas.
    - `playerHere(bool here)`
    - `List<LaneEvent> advance(double seconds)`
    - `leave()`: Kumis pergi lewat `kumisLeavePath`, lalu Oyen ke `laneThreshold` dan masuk pintu kucing.
    - `oyenGoesHome()`: lapar; Kumis tetap.
    - `react(LaneCat cat, LifePose pose, double seconds)`
    - `bool paused`: kartu Oyen terbuka.
    - `LaneActor? of(LaneCat)`
  - Event `LaneEvent`:
    - `SatTogether`: pertemuan pertama selesai saat keduanya duduk bersama dan `playerHere` true. Dari sini `meetNeighbor`.
    - `OyenEnteredHouse`: lanjut ke `RoomLife.comeHome(instant: true)`.
    - `KumisGone`.
- Naskah pertemuan pertama. Keduanya diam selama `playerHere` false. Sesudah pemain tiba:
  1. Kumis `geser` ke `laneBenchRight`, 0,8 detik.
  2. Oyen melompat dari `laneHopFrom` ke `laneBenchLeft` (`laneHopSeconds`).
  3. Keduanya `endus` menghadap satu sama lain (Oyen x 140, Kumis x 191.5), 1,6 detik, dengan puff.
  4. Duduk bersama (Oyen 136 kanan, Kumis 195 kiri) + hati (`temuE`), lalu `SatTogether`.
- Kunjungan biasa:
  - Bangku berpasangan berbobot 3. Kalau Oyen datang belakangan, Kumis `geser` dulu.
  - Tidur di bangku 2, teduh 2, piring air 1 (Oyen `eat` `bowl: false`, Kumis diam di (116,502)), tangga 1 (Kumis di tangga, Oyen di bangku), kupu-kupu 1 (Oyen `play` (212,542), Kumis (282,548)).
  - Lama per momen `lifeSleepSeconds`–20 detik. Pose dan posisi dari `AdeganGang`.

- [ ] **Step 1:** Tulis test yang gagal:
  - `start(firstMeeting: true)` dan `playerHere(false)` selama 60 detik: Kumis tetap di tengah dan Oyen tetap di `laneHopFrom` (menunggu pemain).
  - `playerHere(true)` → urutan `shift` → lompat → `sniff` → `SatTogether` tepat sekali.
  - `playerHere(false)` sebelum `SatTogether` → tidak ada `SatTogether`, lalu momen biasa.
  - `midVisit` → keduanya di bangku tanpa naskah.
  - `leave()` → Kumis pergi lebih dulu (`KumisGone`), lalu `OyenEnteredHouse`.
  - Momen biasa dengan seed tetap tidak pernah menaruh dua kucing di titik yang sama.
  - `oyenGoesHome` → `OyenEnteredHouse`, sementara Kumis tetap ada.
- [ ] **Step 2:** Jalankan `flutter test test/game/model/lane_life_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan.
- [ ] **Step 4:** Jalankan test yang sama. Harapannya: PASS. Lalu commit `feat(lane): lane routine and first meeting`.
- [ ] **Step 5:** Akhir langkah 37:
  - Catat "Langkah 37" di `DESIGN_NOTES.md`, termasuk keputusan `LaneLife` terpisah dari `RoomLife`. `RoomLife` berkunci `KittyId` dan barang; gang tidak punya barang, dan Kumis bukan `KittyId`. Tempat nyaman, jarak, dan kecepatan tetap dipakai bersama.
  - Perbarui `CLAUDE.md` "Struktur", centang langkah 37, review, `/check`, lalu PR.

---

# Langkah 38: layar gang, kamera, dan cek akhir

Branch `feat/gang-depan-layar`.

### Task 10: Momen ekor, Oyen menyelinap, dan penanda di ruang tengah

**Files:**
- Modify: `lib/screens/room/room_view.dart`, `lib/screens/room/door_parts.dart`, `lib/game/model/sounds.dart`, keempat ARB
- Create: `lib/screens/room/front_door.dart`
- Test: `test/screens/front_door_test.dart`

**Interfaces:**
- Consumes: `ProgressController.laneVisit`/`oyenInLane`/`forceFirstVisit`/`followTail` (Task 7), `RoomLife.goOut`/`comeHome`/`wantsOut` (Task 8), `paintDoorLeaf` (Task 3).
- Produces:
  - `FrontDoor({required RoomGeometry geo, required double flapDeg, required bool tail, double? time})`: daun pintu, pintu kucing, dan ekor Kumis.
  - `LaneMarker`: penanda kotak (15,238) 48×52, tanpa semantik.
  - `GameSound.flap` (`flap`), `GameSound.doorOpen` (`door_open`), `GameSound.doorClose` (`door_close`).
- Alur di `RoomView` (penyegaran `roomRefreshInterval` + `Ticker`):
  - Kunjungan baru mulai dan pemain di ruang tengah, Oyen di ruang tengah, dan bebas:
    1. Ekor (`ekorA`): flap 20°, goyang ±8° 0,55 detik, `meow`.
    2. Sesudah 1,2 detik Oyen menoleh kiri dengan "!" (`ekorB`).
    3. Sesudah 0,8 detik ekor hilang, flap 9° → 0 (`ekorC`).
    4. Lalu `followTail()` dan `goOut(oyen)`. Selama Oyen lewat, flap disembunyikan (`flapDeg` null), lalu berayun −14° → 0 dengan `GameSound.flap`.
  - Oyen tidak bebas (kartu, angkat, reaksi, Hias): tunggu.
  - Di teras atau di luar kamar: `goOut(instant: true)` tanpa ekor.
  - Dibuka di tengah kunjungan: Oyen langsung di luar.
  - Kunjungan berakhir atau `sendOyenHome`: `comeHome(oyen)`. Terlihat kalau pemain di ruang tengah.
  - `forceFirstVisit()` dipanggil 20 detik sesudah ruang tengah tampil (sekali).
  - Oyen di luar: `LaneMarker`. Kalau Oyen lapar atau lesu, `DoorAttention` biasa menggantikannya di letak yang sama.
- Teks ARB (Indonesia dulu): `laneName` "Gang Depan", `frontDoorTo` "Keluar ke Gang Depan", `frontDoorOyenOut` "Oyen ada di Gang Depan", `laneHomeDoor` "Pulang ke ruang tengah", `oyenWentOut` "Oyen menyelinap ke Gang Depan".

- [ ] **Step 1:** Tulis widget test yang gagal. Pakai `pumpApp(roomLife: true)`, jam lewat `clock`, dan `settle`:
  - Jam di tengah kunjungan + ruang tengah → ekor tampil (kunci `kumis-tail`), `meow` diputar, lalu Oyen `passing-oyen`, lalu tidak ada sprite Oyen dan `LaneMarker` tampil.
  - Kartu Oyen terbuka saat kunjungan mulai → tidak keluar sampai kartu ditutup.
  - Pengumuman `oyenWentOut` diterima.
  - Label pintu depan "Keluar ke Gang Depan, Oyen ada di Gang Depan".
  - Kunjungan habis → Oyen masuk lagi dan penanda hilang.
  - Kurangi gerak → tanpa goyang ekor, Oyen langsung keluar.
  - Progres baru tanpa level 1 → tidak ada ekor walau 20 detik berlalu. Sesudah level 1, ekor muncul 20 detik sesudah ruang tengah tampil.
- [ ] **Step 2:** Jalankan `flutter test test/screens/front_door_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan. Buat efek suara lewat `tool/audio/make_sfx.py` (sumber CC0; kalau tidak ada, sintesis seperti lonceng kamar), catat di `assets/audio/LICENSE-sfx.txt`, lalu daftarkan di `pubspec.yaml`.
- [ ] **Step 4:** Jalankan `flutter test test/screens test/app/audio_assets_test.dart`. Harapannya: PASS. Lalu commit `feat(room): tail at the cat flap and Oyen slipping out`.

### Task 11: Kamera menembus pintu

**Files:**
- Create: `lib/screens/room/lane_camera.dart`
- Modify: `lib/screens/room/room_view.dart`
- Test: `test/screens/lane_camera_test.dart`

**Interfaces:**
- Produces:
  - `LaneCameraFrame laneCameraAt(double ms, {required bool home})`, fungsi murni. `LaneCameraFrame` berisi:
    - `zoom`, `focus` (`HousePoint` desain), `doorDeg`
    - `laneScale`, `laneInOpening` (lapisan gang dipotong bukaan), `laneFull`
    - `chipOpacity`

    Linimasa `kKamera`:
    - 0–480 ms: zoom 1 → 1,6, `easeInOut`, pusat (39,346) → (195,330).
    - 480–860 ms: pintu 0° → 70°, `easeOut`. Gang mulai di bukaan pada 600 ms, skala 0,5.
    - 860–1400 ms: zoom 1,6 → 5,4, `easeIn`; pintu 70° → 88°; gang 0,5 → 0,92.
    - 1400–1700 ms: gang penuh 0,92 → 1, `easeOut`; chip memudar masuk selama 120 ms.

    `home: true` dicerminkan ke pintu pulang (pusat (351,346)), dan gang ↔ ruang tengah bertukar peran.
  - `const laneCameraMs = 1700`, `const laneFadeMs = 240`.
  - `LaneCamera({required bool home, required Widget from, required Widget to, required RoomGeometry geo, required VoidCallback onDone})`:
    - `from` ditransformasi `Matrix4` (zoom di sekitar `focus`).
    - Daun pintu digambar `paintDoorLeaf` di sudut `doorDeg`.
    - `to` dipotong `ClipPath` bukaan yang sudah ditransformasi kamera, dengan skala `laneScale`.
    - Ketuk selama berjalan = langsung ke akhir.
    - Kurangi gerak = crossfade `laneFadeMs`.
  - Di `RoomView`:
    - `_place` (living/terrace di pager, atau lane).
    - Ketuk `DoorButton` pintu depan (`doorTap` cermin: (6,205) 64×172) membuka `LaneCamera`. Ketukan kedua selama transisi diteruskan ke kamera, bukan memulai transisi baru.
    - Bunyi `doorOpen` di 480 ms dan `doorClose` di akhir.
    - Header dan panel diam. Chip "‹ Ruang tengah" di gang. Hias disembunyikan.
    - `PopScope` di gang = pulang.
    - `HousePager` dimatikan selama di gang.

- [ ] **Step 1:** Tulis test yang gagal:
  - `laneCameraAt(0)` zoom 1 dan pintu 0°.
  - `laneCameraAt(480)` zoom 1,6 dan fokus (195,330).
  - `laneCameraAt(860)` pintu 70°.
  - `laneCameraAt(1400)` zoom 5,4, pintu 88°, gang 0,92.
  - `laneCameraAt(1700)` `laneFull`, skala 1, chip 1.
  - Fokus `home` di 0 = (351,346).
  - Widget: ketuk pintu depan → sesudah 1700 ms `LaneScene` tampil dan ruang tengah tidak dibangun.
  - Ketuk dua kali cepat → satu transisi; ketukan kedua di 300 ms menyelesaikan transisi di bingkai berikutnya (Review Focus 4).
  - Header tidak bergerak (posisi `RoomHeader` sama di 0 dan 900 ms).
  - Tombol kembali sistem di gang → pulang (transisi `home`) ke ruang tengah.
  - Geser horizontal di gang tidak pindah ke teras.
  - Kurangi gerak → `FadeTransition` 240 ms tanpa `Transform`.
  - Pembaca layar: pintu di gang "Pulang ke ruang tengah".
- [ ] **Step 2:** Jalankan `flutter test test/screens/lane_camera_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan. Bandingkan bingkai 0/480/860/1400/1700 ms dengan artboard 6 dan 12 lewat potret sementara.
- [ ] **Step 4:** Jalankan `flutter test test/screens`. Harapannya: PASS. Lalu commit `feat(room): walk through the front door into the lane`.

### Task 12: Kehidupan di gang

**Files:**
- Modify: `lib/screens/room/room_view.dart`, `lib/screens/room/kitty_card.dart` (tanpa tombol ajak di gang), `lib/screens/room/room_reaction.dart`
- Create: `lib/screens/lane/lane_view.dart`: sprite `LaneLife` ke `LaneScene`, dengan kucing di bangku di lapisan `onBench`.
- Test: `test/screens/lane_view_test.dart`

**Interfaces:**
- Consumes: `LaneLife` (Task 9), `ProgressController.holdLane`/`meetNeighbor`/`oyenInLane`/`sendOyenHome`, `LaneCamera.onDone`.
- Produces:
  - `LaneView({required ProgressController progress, required LaneLife life, required double? time, required bool here})`.
  - Di gang:
    - Ketuk Oyen → `KittyCard(room: null)`, tanpa `kitty-invite`.
    - Ketuk Kumis (kunci `lane-kumis`) → `meow` + hati 1,6 detik (`ReaksiKumis`).
    - Label pembaca layar Kumis lewat `kittyLabel`.
- Alur:
  - `LaneLife.start` saat kunjungan mulai, saat aplikasi dibuka (`midVisit`), atau saat masuk gang.
  - `playerHere(true)` di `LaneCamera.onDone`, dan `false` saat transisi pulang mulai, rute lain dibuka, atau aplikasi ke latar belakang.
  - `holdLane()` tiap penyegaran selama di gang.
  - `SatTogether` → `meetNeighbor()`.
  - Kunjungan habis → `leave()`.
  - Lapar ≤ `sadThreshold` → `oyenGoesHome` + `sendOyenHome`.
  - `OyenEnteredHouse` → `comeHome(instant: true)`, dan Oyen terlihat masuk kalau pemain di ruang tengah.
  - Gang tanpa kunjungan = `LaneScene` tanpa kucing.

- [ ] **Step 1:** Tulis test yang gagal:
  - Ikuti ekor → ketuk pintu → di gang, Kumis masih ada dan pertemuan pertama berjalan → `metNeighbor` true dan tersimpan.
  - Pulang lewat chip di tengah naskah (sebelum duduk bersama) → `metNeighbor` false. Kunjungan berikutnya memutar pertemuan pertama lagi (Review Focus 3).
  - Sama untuk tombol kembali sistem dan membuka `/toko`.
  - Pemain di gang melewati akhir jadwal → Kumis tetap ada. Pulang → kunjungan berakhir dalam 1 menit (`holdLane`) → Kumis pergi dan Oyen masuk.
  - Gang saat tidak ada kunjungan → tidak ada sprite kucing.
  - Ketuk Kumis → `meow` dan hati, tanpa kartu.
  - Ketuk Oyen → kartu tanpa `kitty-invite`.
  - Aplikasi dibuka di tengah kunjungan → keduanya di bangku tanpa ekor (Review Focus 2).
  - Kurangi gerak → sprite diam.
- [ ] **Step 2:** Jalankan `flutter test test/screens/lane_view_test.dart`. Harapannya: FAIL.
- [ ] **Step 3:** Implementasikan.
- [ ] **Step 4:** Jalankan `flutter test test/screens`. Harapannya: PASS. Lalu commit `feat(lane): Oyen and Kumis in the lane`.

### Task 13: Layar kecil, bahasa, potret, kinerja, dan dokumen

**Files:**
- Modify:
  - `test/screens/overflow_test.dart`: ruang tengah dengan penanda, gang utama, gang kosong, kartu Oyen di gang, dan bingkai kamera 900 ms, di 360×640 sampai 412×915, teks 100%/130%, keempat bahasa.
  - `test/screenshots/` (`38-gang-*` per bahasa)
  - `tool/profile_room.dart`: opsi gang
  - `docs/performance-room-2026-11-08.md` (hasil gang)
  - `docs/DESIGN_NOTES.md`, `CLAUDE.md`, `docs/ROADMAP.md`
- Test: semua di atas

- [ ] **Step 1:** Tambah kasus overflow. Ikuti catatan `n360`: chip "‹ Ruang tengah" tetap 44 px, penanda tetap 48×52. Kalau ada yang terpotong, perbaiki di widget-nya. Teduh pohon dan baris sachet ikut geometri bersama karena gambar diskalakan seperti rumah.
- [ ] **Step 2:** Jalankan `flutter test test/screens/overflow_test.dart`. Harapannya: PASS.
- [ ] **Step 3:** Ambil potret layar keempat bahasa dan bandingkan dengan artboard 3 (ekor di ukuran HP), 7, 9, dan 13.
- [ ] **Step 4:** Profil gang di HP (`flutter run --profile -t tool/profile_room.dart --dart-define=PLACE=lane`). Catat p90/p99 build dan raster di dokumen kinerja. Hanya tempat yang dibuka yang menggambar.
- [ ] **Step 5:** Tulis "Langkah 38" di `DESIGN_NOTES.md`, perbarui `CLAUDE.md` "Struktur" (`LaneCamera`, `LaneView`, `FrontDoor`, `LaneMarker`, `lane.metNeighbor`, suara baru), lalu centang langkah 38.
- [ ] **Step 6:** Review (`superpowers:requesting-code-review`), `/check`, `superpowers:verification-before-completion`, lalu PR `feat: Gang Depan, layar dan kamera`.
