# Langkah 14c — Header dan panel rumah ringkas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans (CLAUDE.md: sesi utama). Steps use checkbox (`- [ ]`) syntax.

**Goal:** Rumah v2 seperti konsep A: tab chip satu baris, Hias/bantuan ikon di kamar, panel kucing satu baris, detail area di sheet, kamar lebih tinggi.

**Architecture:** Hanya lapisan layar (`lib/screens/room/`) dan ARB. Model, kuota, simpanan tidak berubah. Panel area (`DiningPanel`/`PlayPanel`/`CarePanel`) diganti chip status; isinya pindah ke `HomeSheets.dining/playing/caring`.

**Tech Stack:** Flutter, flutter_test, gen-l10n.

**Spec:** `docs/superpowers/specs/2026-11-21-home-header-design.md`

## Global Constraints
- Semua teks baru di keempat ARB (`id` dulu, `en` dengan deskripsi, `pt`, `ru`), lalu `flutter gen-l10n`.
- Target sentuh ≥ 48 dp (`KoUi.target`); warna/ukuran dari `KoUi`.
- Overflow 360×640–412×915, teks 100%/130%, empat bahasa tetap lulus.
- Kunci yang dipakai test tetap ada: `home-decorate`, `home-rewards`, `home-selection`, `dining-choose`, `play-choose`, `care-choose`, `<area>-cancel-<kucing>` (pindah ke sheet).

## Review Focus
- Teks 130% di 360×640 bahasa Rusia: chip tab dan aksi kucing tidak terpotong/overflow → `overflow_test`, `home_v2_test` matriks bahasa.
- Kucing terpilih berada di area lain: panel tetap menawarkan "Lihat area" → test 14c.
- Hias saat pack belum dimuat/sibuk: tombol ikon nonaktif → test 14c.
- Pembaca layar: tab tetap menyebut hitungan `homeAreaCount`; tombol ikon punya label → test 14c.
- Antrean hanya bisa dibatalkan dari sheet → test dining/play/care diperbarui.

---

### Task 1: Teks baru
**Files:** `lib/l10n/app_{id,en,pt,ru}.arb`, generated.
- [ ] Tambah `homeStatusBowl` ({left}/{total}), `homeStatusBowlEmpty`, `homeStatusToy`, `homeStatusCare`, `homeStatusQueue` ({count}), `homeRewardLater`; `flutter gen-l10n`; `flutter test test/l10n` lulus; commit `feat(l10n): compact home status texts`.

### Task 2: Tab chip satu baris
**Files:** `lib/screens/room/home_chrome.dart` (`HomeAreaStrip`), `home_view.dart`.
- [ ] `HomeAreaStrip.labels` = nama pendek tanpa hitungan; `semantics` tetap `homeAreaCount`. Chip: `Row(icon 18, label)`, tinggi min 44 dalam wadah; teks normal = 4 `Expanded` + `FittedBox(scaleDown)`, teks besar = gulir horizontal (perilaku lama).
- [ ] Test (Task 5) menegaskan keempat chip berada di satu garis `top` yang sama dan tinggi strip ≤ 60 pada 390×844.

### Task 3: Tata letak HomeView
**Files:** `home_view.dart`, `home_chrome.dart` (`HomeIconButton`, `HomeStatusChip` bila perlu).
- [ ] Hapus baris judul area. Tombol ikon bulat (`home-help`, `home-decorate`) `Positioned` kanan atas di atas `HomeScene`.
- [ ] Panel kucing satu baris: avatar 48, nama + status `maxLines: 1`, dua `UiButton` berikon (`Flexible`); kolom untuk teks besar/kucing di area lain.
- [ ] Ganti panel area dengan `Wrap` chip: status area (`dining-choose`/`play-choose`/`care-choose`) + hadiah (`home-rewards`, `homeRewardLater` saat 0).
- [ ] Tinggi kamar = sisa tinggi − perkiraan chrome, dijepit 240…lebar×1,16.

### Task 4: Sheet area membawa detail
**Files:** `home_sheets.dart`; hapus `dining_panel.dart`/`play_panel.dart`/`care_panel.dart` kecuali fungsi label ketersediaan (pindah ke `home_labels.dart` atau dipertahankan di file kecil).
- [ ] Ringkasan di atas sheet: Makan (`diningStock`, `diningRefill`/`diningFresh`, `diningEmpty`/`diningFree`/`diningUsing`), Main (`playRules`, `playToy`, `playFree`/`playUsing`), Rawat (`careRules`, `careFree`/`careUsing`). Tombol batal ber-kunci `<area>-cancel-<kucing>`.
- [ ] Perbarui `dining_v2_test`, `play_v2_test`, `care_v2_test`, `home_v2_test` (hitungan tab lewat semantik) agar membuka sheet.

### Task 5: Test tata letak 14c + verifikasi
**Files:** `test/screens/home_layout_14c_test.dart`.
- [ ] Test: kamar ≥ 400 dp tinggi di 390×844 (lama ±338); judul area tidak tampil sebagai teks besar; `home-help`/`home-decorate` ≥ 48 dp dan di dalam kotak kamar; panel kucing satu baris (tinggi ≤ 80) dengan dua tombol berikon; chip hadiah dan status area membuka sheet.
- [ ] `/check`; screenshot `SCREENSHOTS=true` + `BRAND=true` + `tool/store_assets.py`; centang roadmap; CLAUDE.md; commit; review; PR.
