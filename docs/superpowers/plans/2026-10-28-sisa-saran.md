# Sisa Saran (Langkah 20) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Putar otomatis di putar ulang, berkas tinjauan terjemahan, `Tile.copyWith` yang bisa menghapus `ghost`, dan jarak huruf Material yang tidak bocor ke teks.

**Architecture:** Putar otomatis hidup di `_ReplayViewState` (Ticker + akumulator waktu, satu langkah per `ReplayView.autoStepTime`); tombolnya `ReplayPlayButton` di `replay_parts.dart`, di kiri slider. Berkas tinjauan dibuat skrip Python dari ARB dan listing toko. Jarak huruf diperbaiki di `KoTheme.light()` dengan mengisi `letterSpacing` setiap gaya `TextTheme`.

**Tech Stack:** Flutter, flutter_test, Python 3 (skrip alat).

**Spec:** prompt langkah 20 di `docs/ROADMAP.md`. Pemilik repo meminta langsung dikerjakan dengan pilihan saya sendiri (28 Okt 2026), jadi semua keputusan di bawah adalah keputusan saya.

## Global Constraints

- Tidak ada warna/ukuran hardcode di widget; pakai token (`KoSize.control` 56, `KoSize.iconMedium`, `c.orange`, `c.orangeDeep`, `koShadow.press`).
- Semua teks baru di keempat ARB (Indonesia ditulis dulu), lalu `flutter gen-l10n`.
- `flutter analyze` bersih, `flutter test` hijau, `overflow_test` tetap hijau.
- Pesan commit bahasa Inggris singkat, tanpa atribusi Claude.

## Keputusan putar otomatis

- Tombol bulat oranye 56 px (gaya tombol main desain 04, ukuran tombol kontrol) di kiri slider, ikon `KoIcons.resume`/`KoIcons.pause`; label pembaca layar `replayPlay` "Putar otomatis" / `pause` "Jeda". Tanpa teks di bawah tombol.
- Kecepatan `ReplayView.autoStepTime` = 0,7 detik per langkah (lebih lambat dari fase jalan 0,25 detik supaya caption terbaca; Oyen digeser 0,35 detik).
- Putar di langkah terakhir = mulai lagi dari langkah 0. Sampai langkah terakhir = berhenti sendiri, tombol kembali ke ikon putar.
- Slider (ketuk, geser, aksi pembaca layar) dan tombol mundur/maju menghentikan putar otomatis.
- Kurangi gerak (`MediaQuery.disableAnimations`): tombol tidak ditampilkan dan putar otomatis dihentikan kalau sedang jalan (sama dengan fase jalan yang langsung lompat ke akhir); slider kembali selebar desain 09.
- Caption `liveRegion` hanya saat tidak berputar sendiri (seperti chip Langkah langkah 19), supaya pembaca layar tidak dibanjiri.

## Review Focus

- Putar otomatis yang berjalan saat `ReplayView` ditutup (kembali ke hasil): Ticker harus di-dispose tanpa error.
- Level yang langsung selesai (`max` kecil) atau langkah 0 = terakhir: tombol tidak boleh macet berputar.
- Tik yang terlambat (bingkai panjang) tidak boleh melompati lebih dari satu langkah per tik.
- Kurangi gerak dinyalakan saat sedang berputar: berhenti.
- Teks tombol pause/putar di keempat bahasa: tidak ada teks tampil, hanya label semantik; overflow tetap dicek.

---

### Task 1: Putar otomatis di putar ulang

**Files:**
- Modify: `lib/screens/replay/replay_view.dart`, `lib/screens/replay/replay_parts.dart` (`ReplayPlayButton`, `ReplayCaption.announce`)
- Modify: `lib/l10n/app_{en,id,pt,ru}.arb` (kunci `replayPlay`)
- Test: `test/screens/replay_view_test.dart` grup `putar otomatis`

**Interfaces:**
- Produces: `ReplayView.autoStepTime` (`Duration(milliseconds: 700)`), `ReplayPlayButton({required bool playing, required VoidCallback onPressed})`, `ReplayCaption(announce: bool)` (default true).

- [ ] **Step 1: test gagal** — di grup `putar otomatis` (level 13 solusi, `_pumpReplay`):
  - `maju sendiri per langkah lalu berhenti di akhir`: tap tombol `Putar otomatis`; `pump(autoStepTime)` → `_sliderValue == 1`; terus sampai 6; pump lagi → tetap 6 dan tombol berlabel `Putar otomatis` lagi.
  - `jeda`: putar, pump 2 langkah, tap `Jeda` → nilai tetap sesudah `pump(autoStepTime * 3)`.
  - `slider dan tombol langkah menghentikan`: putar, ketuk slider di awal → nilai 0 dan tetap 0 sesudah pump; putar lagi, tap `Satu langkah mundur`... (cukup satu: tap `Satu langkah maju` → berhenti).
  - `di akhir mulai lagi dari awal`: slider ke akhir, tap putar → nilai 0 lalu 1 sesudah satu langkah.
  - `kurangi gerak: tanpa tombol putar`.
  - `pembaca layar`: tombol bersemantik `Putar otomatis`/`Jeda`; `ReplayCaption.announce` false saat berputar, true saat dijeda.
  - `ditutup saat berputar` : putar, pumpWidget ganti layar kosong, tidak ada exception.
- [ ] **Step 2:** `flutter test test/screens/replay_view_test.dart` → gagal (tombol tidak ada).
- [ ] **Step 3:** ARB `replayPlay` (id "Putar otomatis", en "Autoplay", pt "Reprodução automática", ru "Автовоспроизведение"), `flutter gen-l10n`. `_ReplayViewState` dengan `SingleTickerProviderStateMixin`: `_playing`, akumulator `_elapsed`; tik maju paling banyak satu langkah, berhenti di `_last`; `_go` dari slider/tombol menghentikan; `didChangeDependencies` menghentikan saat kurangi gerak. Tata letak: `Row(crossAxisAlignment: center)` [tombol, `s12`, `Expanded(slider)`], tombol disembunyikan saat kurangi gerak.
- [ ] **Step 4:** test file hijau, plus `overflow_test` putar ulang.
- [ ] **Step 5:** commit `feat(replay): autoplay button`.

### Task 2: Potret layar putar ulang

- [ ] `flutter test test/screenshots --dart-define=SCREENSHOTS=true` lalu buka `build/screenshots/390x844/09-putar-ulang-*.png`; cek tombol di kiri slider rapi dengan desain 09. Tidak ada commit kecuali potret perlu adegan baru.

### Task 3: `Tile.copyWith(clearGhost:)`

**Files:** `lib/game/render/tile.dart`, test `test/game/render/board_scene_test.dart`.
- [ ] Test: `const Tile(ghost: Item.box).copyWith(clearGhost: true).ghost` null; `copyWith(glow: true)` menjaga ghost; `clearGhost` + `ghost:` → assert gagal (pakai `throwsAssertionError`).
- [ ] Tambah `bool clearGhost = false` dengan `assert(!(clearGhost && ghost != null))`. Commit `feat(render): let Tile.copyWith clear the ghost`.

### Task 4: Jarak huruf Material

**Files:** `lib/theme/ko_theme.dart`, test `test/theme/theme_test.dart`.
- [ ] Test `teks tanpa jarak huruf eksplisit tidak mendapat jarak huruf Material`: pump `testApp` dengan `Scaffold` + `Text('x')`; `DefaultTextStyle` letterSpacing == 0; semua 15 gaya `Theme.of(context).textTheme` punya letterSpacing == gaya `KoType` asalnya atau 0 (displayLarge = `t.display.letterSpacing ?? 0`, dst.). Gagal sekarang (0,25).
- [ ] Isi `TextTheme` lengkap 15 gaya: gaya `KoType` yang dipetakan memakai `letterSpacing ?? 0`, sisanya `TextStyle(letterSpacing: 0)`.
- [ ] Jalankan seluruh `flutter test` (teks sedikit lebih sempit, cek overflow dan piksel), dan `brand_test` (`--dart-define=BRAND=true`) kalau gambar merek memakai teks; commit PNG yang berubah. Commit `fix(theme): keep Material letter spacing out of text`.

### Task 5: Berkas tinjauan terjemahan

**Files:** Create `tool/translations/make_review.py`, `docs/translations/README.md`, `docs/translations/review-{en,pt,ru}.md`.
- [ ] Skrip membaca `lib/l10n/app_{en,id,pt,ru}.arb` dan `docs/store/listing-*.md`. `review-en.md`: tabel kunci | Indonesia (sumber) | Inggris | deskripsi; `review-pt.md`/`review-ru.md`: kunci | Inggris | bahasa itu | deskripsi. Di atas tabel: pedoman nada (santai, jenaka), aturan "turns clockwise"/"sentido horário"/"по часовой", caption pakai arah layar, jangan menerjemahkan "Ginger Logic", "PRANG!", "Zzz", placeholder `{n}` dan bentuk jamak ICU. Di bawah: listing toko Inggris dan bahasa itu utuh. `|` di-escape, baris baru jadi `<br>`.
- [ ] Jalankan `python tool/translations/make_review.py`; cek jumlah baris tabel = jumlah kunci ARB. Commit `docs: translation review sheets`.

### Task 6: Catatan dan penutup

- [ ] `docs/DESIGN_NOTES.md` bagian "Langkah 20" (semua keputusan di atas, temuan jarak huruf yang ternyata masih terjadi, terjemahan belum ada masukan).
- [ ] `docs/ROADMAP.md` centang 20 + ringkasan hasil; `CLAUDE.md` Struktur (putar otomatis, `docs/translations/`, `tool/translations/`).
- [ ] Review subagent effort high, perbaiki temuan, verifikasi, push, PR.
