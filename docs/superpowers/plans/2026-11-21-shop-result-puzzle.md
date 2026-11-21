# Langkah 14b Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans (CLAUDE.md: sesi utama). Steps use checkbox (`- [ ]`) syntax.

**Goal:** Rapikan Toko, layar hasil, dan papan puzzle sesuai roadmap 14b.

**Architecture:** Perubahan render di renderer v2 (`puzzle_art.dart`, `board_painter.dart`, `journey_art.dart`), tata letak di `shop_screen.dart` dan `result_parts.dart`. Model, aturan, hitbox tidak disentuh.

**Tech Stack:** Flutter, Flame, flutter_test (piksel lewat `toImage`).

**Spec:** `docs/superpowers/specs/2026-11-21-shop-result-puzzle-design.md`

## Global Constraints
- Tidak ada warna/ukuran hardcode di widget; tambah konstanta di `KoUi`/`PuzzleArt` bila perlu.
- Teks baru (bila ada) di keempat ARB + `flutter gen-l10n`.
- `overflow_test` 4 bahasa 360×640–412×915 teks 100%/130% tetap lulus.

## Review Focus
- Toko di 360×640 teks 130% Rusia: header terpusat tidak menimpa tombol kembali/chip koin (overflow_test).
- Pembaca layar: label semantik harga tetap memuat harga & aksi (test lama shop).
- Benda pemain vs benda bawaan (ikan `F`, kardus `K`) tetap bisa dibedakan setelah stiker dihapus.
- Panah arah tetap terlihat untuk keempat arah dan tidak keluar papan di petak tepi.
- Layar hasil yang digulir (teks 130%) tidak menampilkan tepi sinar lurus.

---

### Task 1: Puzzle — benda tanpa stiker, baki tanpa bingkai ganda, kontras tembok
**Files:** Modify `lib/game/render/v2/puzzle_art.dart`, `lib/widgets/game_art.dart:80,149`; Test `test/screens/puzzle_v2_test.dart` (atau berkas render yang sudah menguji puzzle art)
- [ ] Test: render `paintPuzzleTile` untuk `TileItem.fishP` → piksel pojok (6,7) = warna lantai (bukan `KoUi.paper`); ada piksel oranye-tembus di bawah benda (penanda lantai). `ItemArtView` (baki) → tidak ada piksel `KoUi.orange` stroke di tepi kotak 4..46. Tembok: kontras luminans `PuzzleArt.wall` vs `PuzzleArt.floor` ≥ 1.6.
- [ ] Implement: `paintPuzzleItem(..., player)` menggambar elips penanda `PuzzleArt.playerMark` (oranye α≈.35) di lantai bawah benda, bukan kotak; baki & lifted memanggil `player: false`. Tembok pakai `PuzzleArt.wall` lebih gelap (mis. `0xFFE2A876`) + garis `wood` lebih tegas.
- [ ] Perbaiki test lama yang mengunci stiker; jalankan `flutter test test/screens/puzzle_v2_test.dart test/game/render` → PASS. Commit `fix(puzzle): items blend into tiles, single tray frame, stronger walls`.

### Task 2: Puzzle — panah arah tidak menutupi wajah
**Files:** Modify `lib/game/render/board_painter.dart:215-245`; Test sama dengan Task 1
- [ ] Test: untuk tiap `Direction`, pusat lencana berada di luar kotak kepala Oyen (kotak kepala = bagian atas 55% sprite `BoardArt.oyenSize` di posisi `oyenOffset`) dan di dalam papan 350×450 untuk petak tepi.
- [ ] Implement: lencana di sisi hadap setinggi kaki (kiri/kanan y≈38, x di luar siluet; atas: pojok kanan-atas di luar kepala; bawah: di bawah kaki).
- [ ] PASS, commit `fix(puzzle): move facing badge off Oyen's face`.

### Task 3: Layar hasil — sinar penuh, mangkuk di samping
**Files:** Modify `lib/screens/result/result_parts.dart` (`ResultPage`: padding pindah ke dalam `SingleChildScrollView` agar klip selebar layar), `lib/game/render/v2/journey_art.dart` (`rays`: panjang ≥ 700 dengan gradasi radial memudar ke 0; `result`: mangkuk di `center + 78`, pecahan vas pindah kiri); Test `test/screens/journey_v2_test.dart`
- [ ] Test: render `JourneyArt.rays` → alfa pada radius 600 ≈ 0 (pudar), pada radius 100 > 0. `JourneyArt.result` → piksel di tengah bawah kucing (center, h-29) bukan warna mangkuk.
- [ ] Implement & PASS, commit `fix(result): full-bleed fading rays, bowl beside Oyen`.

### Task 4: Toko — judul tengah, harga berkoin, pratinjau ringkas, "Coba di:" satu baris
**Files:** Modify `lib/screens/shop/shop_screen.dart`; Test `test/screens/shop_v2_test.dart`
- [ ] Test: pusat X teks judul `l.shop` == pusat layar (±1); tombol `shop-kitty-salju`, `shop-accessory-*`, `shop-snack-*`, `shop-preview-buy` memuat `CoinView`; "Coba di:" = satu `SingleChildScrollView` horizontal (semua `shop-preview-<kucing>` punya dy sama); kelangkaan dirender sebagai `UiChip`; tinggi kartu pratinjau ≤ 260 di 390×844.
- [ ] Implement: header `NavigationToolbar(centerMiddle: true)`; harga = `leading: CoinView` + angka (status kurang/penuh tetap teks); pratinjau `Row` (CatalogArt size 130 | info); chip pilihan dalam `UiEdgeFade` horizontal.
- [ ] PASS, commit `fix(shop): centered title, coin prices, compact preview`.

### Task 5: Verifikasi, dokumentasi, PR
- [ ] `/check` (format, analyze, review terjemahan, test) hijau.
- [ ] Screenshot `SCREENSHOTS=true SCREENSHOT_DIR=docs/screenshots` + `BRAND=true` + `python tool/store_assets.py` lalu `--check`; periksa gambar.
- [ ] Centang 14b di `docs/ROADMAP.md` + catatan selesai; review subagent; push; PR.
