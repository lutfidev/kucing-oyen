# Kamar Hidup (langkah 24) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans (sesi utama, sesuai `CLAUDE.md`). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Kucing di kamar bergerak (kedip, ekor, napas, jalan, memakai barang), barang ikut bergerak, kebutuhan mengikuti jam, dan kucing yang dirawat memberi hadiah koin.

**Architecture:** Animasi desain ditulis sebagai CSS `@keyframes` di atribut `style`. `SvgTemplate` belajar mengevaluasi `style` (transform-origin, transform-box, animation, animation-delay) pada waktu `t`, dengan `@keyframes` yang disalin utuh dari desain, jadi isi `<svg>` tetap tidak diketik ulang. Rutinitas kucing adalah model Dart murni `RoomLife` yang dimajukan `advance(dt)` dari satu `Ticker` di `RoomView`; peristiwa (sampai di mangkuk, memakai mainan) diteruskan ke `ProgressController`.

**Tech Stack:** Flutter, Dart murni untuk model, `SvgTemplate` sendiri, `audioplayers` (sudah ada), Python numpy+soundfile untuk efek suara.

**Spec:** `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md` (Kamar hidup, Kebutuhan dan hadiah), `docs/ROADMAP.md` langkah 24, desain `docs/design/rumah-oyen/project/{AnimasiKucing,Kucing,Barang,Kamar,GelembungKoin,TandaLesu}.dc.html`.

## Global Constraints

- Model di `lib/game/model/` tanpa import Flutter/Flame.
- Isi `<svg>` dan `@keyframes` disalin utuh dari desain; tidak ada warna atau ukuran hardcode di widget (token di `lib/theme/`).
- Semua teks pemain di keempat ARB, Indonesia dulu, `flutter gen-l10n`.
- Kurangi gerak (`MediaQuery.disableAnimations`): semua loop berhenti, kucing diam; kebutuhan dan hadiah tetap berjalan.
- Test kamar memakai `settle`, bukan `pumpAndSettle`.
- `flutter analyze` bersih, `flutter test` hijau.

## Keputusan builder (spesifikasi "Diserahkan ke builder")

- **Bobot tujuan acak:** diam (duduk/menjilat) 3; per barang menurut `ItemUse`: sleep 3, play 3, lounge 2, hide 2, scratch 2, watch 2, sit 2; mangkuk hanya kalau `canEatFromBowl` dan menjadi tujuan wajib (prioritas). Barang yang sedang dipakai/dituju kucing lain tidak ikut diundi.
- **Lama:** diam 2,6 s, memakai barang 3,0 s, tidur (sleep) 6,0 s, makan 3,0 s (angka 21c/`Kamar.dc.html`; tidur diperpanjang supaya tidak gelisah). Jalan 70 px desain/detik.
- **Kucing lesu** tidak berkeliling; hanya berjalan ke mangkuk kalau boleh makan.
- **Urutan gambar** kucing yang bertumpuk tetap menurut kaki (sudah ada di `roomSprites`); kucing yang memakai barang digambar oleh barangnya.
- **Simpan:** setiap aksi sudah menyimpan; bar diturunkan dari jam, jadi masuk latar belakang cukup `retrySaves()` yang sudah ada. Dicatat di DESIGN_NOTES.

## Review Focus

- Kucing memakai barang lalu barang itu dipindah ke Gudang/diseret saat mode hias → kucing dilepas dari barang, tidak menggantung di posisi lama (test di Task 4 `interrupt` dan Task 6).
- Barang dibeli/disimpan saat kucing sedang berjalan ke barang itu → tujuan batal, kucing memilih tujuan lain tanpa crash (test Task 4 `items berubah`).
- Kucing baru diadopsi di tengah rutinitas → muncul di tempatnya tanpa memindahkan kucing lain (test Task 4 `withKitties`).
- Dua kucing lapar sekaligus → hanya satu di mangkuk, yang lain menunggu/diundi ulang; masing-masing makan sekali per isi (test Task 4 + progress).
- Jam mundur (jam HP diubah) → bar tidak naik, hadiah tertahan (sudah dijaga model; test Task 6 lewat `clock`).

---

### Task 1: `SvgTemplate` mengevaluasi animasi CSS

**Files:**
- Create: `lib/game/render/css_animation.dart`
- Modify: `lib/game/render/svg_template.dart`, `lib/game/render/design_svg_home.dart` (tambah `kittyKeyframes`, `roomItemKeyframes`, `roomBadgeKeyframes` disalin utuh dari `<style>` desain)
- Test: `test/game/render/css_animation_test.dart`, `test/game/render/svg_template_test.dart`

**Interfaces:**
- Produces: `CssKeyframes.parse(String css)` → `Map<String, CssKeyframes>`; `CssKeyframes.at(double progress)` → `CssFrame(transform: List<CssTransformFn>, opacity: double?)`; `cssEase(String name, double t)`; `SvgTemplate(source, {Map<String, CssKeyframes> keyframes = const {}})`; `SvgTemplate.render(vals, {double? time})` — `time == null` = diam (gaya animasi diabaikan).
- Didukung di `style`: `transform-origin: Xpx Ypx | center`, `transform-box: fill-box`, `animation: <nama> <dur>s [easing] infinite [alternate]`, `animation-delay: <n>s`. Fungsi transform: `rotate(deg)`, `translate(px,px)`, `translateX/Y`, `scale(x[,y])`, `scaleX/Y`. Properti tidak dikenal → `FormatException`.
- Interpolasi per segmen keyframe dengan easing animasi (CSS: easing berlaku per segmen); `alternate` membalik iterasi ganjil; delay negatif menggeser fase; offset yang tidak menulis `transform` dianggap identitas (fungsi sejenis).

- [ ] Test: `kcBlink` di 0,96 × 4,6 s → scaleY 0,12; di 0 → 1. `kcTail` 2,6 s di 1,3 s → rotate −8°. `kcNom` alternate 0,45 s di 0,45 s → 2,6 px, di 0,9 s → 0. `brgHop` di 0,2 × 2,6 s → translate(−8, 0). `cssEase('ease-in-out', .5) == .5`.
- [ ] Test template: `<g style="transform-origin: 10px 10px; animation: kcTail 2.6s ease-in-out infinite"><rect …/></g>` → `bounds` diputar di `time: 1.3`, sama dengan diam di `time: null`; `transform-box: fill-box; transform-origin: center` memakai pusat kotak isi; elemen dengan `transform` dan `style` animasi sekaligus → `FormatException`.
- [ ] Implement, jalankan test, commit `feat(render): evaluate design CSS animations in SvgTemplate`.

### Task 2: Kucing beranimasi

**Files:**
- Modify: `lib/game/render/kitty.dart` (`KittyLook.time` jadi `double?`, null = diam; `KittyLook.walkFrame(time)` → `walk1`/`walk2` tiap 220 ms; `kittyDelay(KittyId)` = `delay` palet desain), `lib/game/render/kitty_painter.dart` (gaya `A()` desain; cache hanya untuk `time == null`), `lib/widgets/game_art.dart` (`KittyView` tetap)
- Test: `test/game/render/kitty_test.dart`

**Interfaces:**
- Produces: `kittyVals(KittyLook)` mengisi `tailStyle`, `headAnim`, `sleepAnim`, `accAnim`, `syalAnim`, `noteOn`, `noteAnim`, `crownTw`, `blinkStyle`, `zzzAnim`, `tapAnim`, `ballAnim`, `scratchA/B`, `lickAnim`, `tw1–3`, `heartAnim/2` persis string desain saat `time != null`, kosong saat null. `paintKitty(canvas, look, size:)` me-render dengan `time: look.time`.

- [ ] Test: Oyen `idle` di `time = 4.6*0.96` (delay Oyen 0) → kotak mata lebih pendek dari diam (ambil `SvgTemplate` bounds lewat helper uji `kittyDrawing(look)`); Arang `idle` di `time` setengah periode ekor (delay −1,3 → `1.3 + 1.3`) → kotak ekor berbeda dari diam; `time: null` → identik dengan sebelum langkah ini; `walkFrame(0.1) == walk1`, `walkFrame(0.3) == walk2`.
- [ ] Implement, test, commit `feat(render): animate room kitties as a function of time`.

### Task 3: Barang beranimasi dan keadaan "dipakai"

**Files:**
- Modify: `lib/game/render/room_item_art.dart`
- Test: `test/game/render/room_item_art_test.dart`

**Interfaces:**
- Produces: `RoomItemArt.inUse(RoomItemId)` → `ItemInUse?` (`size` = kotak dipakai `D[2..3]`, `artOffset` = `offs`, `cat` = (`offset` cp, `size`, `KittyPose`), `hidesSelf` bola/tikus/mangkuk) dari tabel `Barang.dc.html`; `RoomItemArt.inUseBox(id, Rect box)` → kotak layar saat dipakai (`box.topLeft - artOffset*k`, ukuran `size*k`, `k = box.width/sizeOf(id).width`); `paintRoomItemArt(canvas, id, {box, full, double? time, KittyLook? user})` — dengan `user`: lapisan belakang, kucing (pose tabel, `toy` bola/tikus, `post` false untuk tiang/akuarium/jam), lapisan depan; hammock berayun `brgHam` 3,2 s di sekitar (W·s/2, 0); lukisan miring −9° di (36, 2).
- [ ] Test: `inUseBox(kardus, Rect(0,42,122,82))` → `Rect(0,0,122,124)`; bola dipakai tidak menggambar bola sendiri (jumlah perintah gambar lapisan bola = 0) tapi kucing `play`; catnip di `time` setengah periode berbeda dari diam.
- [ ] Implement, test, commit `feat(render): in-use item variants and item animations`.

### Task 4: Rutinitas kamar `RoomLife`

**Files:**
- Create: `lib/game/model/room_life.dart`
- Test: `test/game/model/room_life_test.dart`

**Interfaces:**
- Produces:
  - `enum CatActivity { idle, walking, using, eating, sad, reacting }`
  - `class CatLife { KittyId kitty; Spot spot; KittyFacing-like `bool facingRight`/`CatHeading { down, left, right }`; CatActivity activity; RoomItemId? item; KittyPoseHint pose; double time }` (pose sebagai enum model `LifePose { idle, lick, walk, sleep, eat, play, scratch, happy, petted, sad, rebah }`, dipetakan ke `KittyPose` di layar)
  - `sealed class LifeEvent` → `ReachedBowl(kitty)`, `UsedToy(kitty, item)`
  - `RoomLife({required Map<KittyId, Spot> homes, required Random random, required double spanX, required double spanY})`
  - `void sync({required Map<RoomItemId, Spot> targets, required Map<RoomItemId, ItemUse> uses, required Set<KittyId> hungry, required Set<KittyId> sad, required Set<KittyId> kitties})` — tujuan berubah/hilang membatalkan perjalanan; kucing baru ditambah di `homes`.
  - `List<LifeEvent> advance(double seconds)` — tidak berjalan saat `paused`.
  - `bool paused`; `void interrupt()` (semua kucing berhenti di tempat, lepas barang); `void react(KittyId, LifePose, double seconds)`; `Map<RoomItemId, KittyId> get users`; `CatLife of(KittyId)`.
- Bobot dan lama dari "Keputusan builder". Kecepatan: `70 / spanX` spot per detik pada sumbu x (sama untuk y dengan `spanY`).
- [ ] Test (seed `Random(3)`): dalam ≤ 60 s simulasi per 1/30 s Oyen pernah `using` barang tujuannya dan `spot` sama dengan target; dua kucing dengan satu barang + `Random` apa pun (seed 0–20) tidak pernah sama-sama `users` barang itu; kucing di `hungry` menuju mangkuk dan memancarkan `ReachedBowl` sekali per kedatangan; `paused` → `advance` tidak mengubah apa pun; `sync` tanpa barang tujuan → perjalanan batal; `interrupt` → `users` kosong; `react` → `reacting` selama durasinya lalu `idle`; kucing `sad` tidak berjalan kecuali ke mangkuk; mainan (`toy`) → `UsedToy`.
- [ ] Implement, test, commit `feat(home): seeded room routine model`.

### Task 5: Efek suara kamar

**Files:**
- Modify: `tool/audio/make_sfx.py` (argumen nama suara opsional; lapisan `synth:chime:<nada,...>` untuk lonceng sintetis), `lib/game/model/sounds.dart`, `assets/audio/LICENSE-sfx.txt`, `pubspec.yaml` (kalau aset didaftarkan per berkas), `test/app/audio_assets_test.dart`, `lib/gallery/` galeri suara otomatis dari enum
- Create: `assets/audio/sfx/{purr,meow,munch,reward,buy,wear}.ogg`
- **Interfaces:** `GameSound.purr`, `meow`, `munch`, `reward`, `buy`, `wear`.
- Sumber: OpenGameArt CC0 "Cat Purr & Meow" (Kerzoven): `cat_purractive_loop.wav` (dengkur), `cat_mewpurr.wav` (meong), `cat_mewfood.wav` (makan); lonceng koin/beli/pasang disintesis sendiri (seperti musik).
- [ ] Test `audio_assets_test`: berkas baru ada; batas total dinaikkan ke 1,4 MB kalau perlu (alasan dicatat). Commit `feat(audio): room sounds`.

### Task 6: Kamar hidup di layar

**Files:**
- Create: `lib/screens/room/room_life_view.dart` (Ticker + `TickerMode`, pemetaan `LifePose` → `KittyPose`), `lib/widgets/coin_bubble.dart` (`CoinBubbleView`, SVG `GelembungKoin` di `design_svg_home.dart`, `gkBob` 1,6 s)
- Modify: `room_view.dart` (kucing dari `RoomLife`, barang dipakai, mangkuk/bola disembunyikan lewat varian dipakai, gelembung hadiah → `claimKittyReward` + reaksi "+10 koin" + `GameSound.reward`, tanda lesu bergoyang `tlBob` 2,4 s, label "Terisi lagi N jam" di dekat mangkuk kosong, penyegaran tiap 30 detik, peristiwa → `eatFromBowl`/`play` + `munch`, jeda saat kartu/hias/reaksi, kurangi gerak = tanpa Ticker dan kucing lapar makan langsung), `kitty_card.dart` (`RoomReaction.pose`, suara `meow` saat kucing diketuk, `purr` saat dielus, `munch` camilan, `wear` aksesoris), `room_reaction.dart` (`pose`), Toko `buy_sheet.dart`/`SnackCard` (`GameSound.buy`), token baru di `lib/theme/`
- Test: `test/screens/room_life_test.dart` + perbarui `room_screen_test`, `kitty_card_test`, `decorate_test`, `shop_screen_test`, `progress_test` (kebutuhan turun saat dibuka lagi dengan `clock` maju; makan dari mangkuk sekali per isi; camilan mengurangi stok; hadiah sekali sehari)
- [ ] Test widget: sesudah `tester.pump` beberapa detik dengan `roomRandom` ber-seed, Oyen memakai barang (KittyView Oyen hilang, barang dipakai tergambar); kartu terbuka → posisi kucing tidak berubah; kurangi gerak → posisi tetap dan tidak ada Ticker aktif; gelembung tampil kalau `canClaimKittyReward`, ketuk → koin +10, suara `reward`, gelembung hilang; label mangkuk kosong; efek suara mati → tidak ada suara; layar lain menutupi kamar → `TickerMode` mati.
- [ ] Implement, test, commit kecil per bagian.

### Task 7: Teks, galeri, overflow, potret, dokumen

- ARB: `kittyRewardLabel` ("Ambil {coins} koin dari {name}"), `kittyRewardReaction` ("+{coins} koin"), `bowlRefillIn` (jamak: "Terisi lagi {hours} jam"; < 1 jam "Terisi sebentar lagi"), `bowlRefillSoon`.
- Galeri `/galeri/kucing`: bagian "Animasi" (pose bergerak per kucing contoh 21c, barang bergerak, barang dipakai).
- `overflow_test`: kamar dengan gelembung hadiah dan label mangkuk; potret `room-reward`.
- `CLAUDE.md` Struktur + catatan `settle`/`TickerMode`, `DESIGN_NOTES.md` "Langkah 24", centang ROADMAP.
- [ ] `flutter analyze`, `flutter test`, commit `docs: step 24 notes`.
