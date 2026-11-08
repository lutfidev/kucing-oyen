# Model rumah banyak area — Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans in the main session. Review the whole branch with one independent reviewer before PR.

**Goal:** Fondasi langkah 4: empat area, rutinitas deterministik, migrasi aman dan transaksi atomik; layar baru mengikuti langkah 5–9.

**Architecture:** Model Dart murni `home_areas.dart` mengatur slot barang; `home_routine.dart` mengatur lokasi, perjalanan berpasangan, antrean dan aktivitas. `Household` menggabungkannya dengan waktu efektif. `ProgressSnapshot` menyimpan seluruh progres gameplay dalam satu JSON versi 2; preferensi audio tetap memakai kunci aslinya. Controller mengekspos API baru yang baru menerbitkan hasil setelah simpan sukses, sementara penyimpanan per bagian tetap tersedia untuk adapter/test lama.

**Tech Stack:** Dart, Flutter test, SharedPreferencesAsync; tanpa paket tambahan.

**Spec:** `docs/design-v2/SPEC.md`, roadmap langkah 4.

## Global Constraints

- Empat area gratis Santai/Makan/Main/Rawat, kapasitas 3/2/2/2; barang lantai 4/dinding 3.
- Durasi makan/main/sikat/elus 4/8/6/2 detik; kuota dan ekonomi v1 dipertahankan.
- Ajakan pemain FIFO, setelah dua pemain layani satu otomatis. Satu ajakan/kucing, satu aktivitas/fasilitas.
- Tidak memutar waktu offline; jam kebutuhan tidak mundur; efek hanya setelah commit.
- Model mengembalikan status data; semua teks pemain tetap lewat ARB pada integrasi layar.

## Review Focus

- Sembilan ajakan pada rumah penuh: swap tidak mengunci kucing dua kali atau menyebabkan deadlock.
- Pembatalan sebelum/sesudah ambang: pasangan kembali konsisten dan tidak memberi efek.
- Simpan gagal/restart/callback ganda: kebutuhan, stok, koin dan ID aktivitas tetap koheren.
- Data rusak sebagian: kepemilikan valid dipertahankan dan lokasi/slot dipulihkan.
- Perubahan progres lain selama simpan: snapshot berikutnya memakai keadaan terbaru.

## Task 1: Area dan migrasi penempatan

Files: `lib/game/model/home_areas.dart`, `test/game/model/home_areas_test.dart`.
Interfaces: `HomeArea`, `AreaSlot`, `HomeAreas.migrate(Home)`, `sync(Home)`, `place`, `store`, `toJson/fromJson`.

- [x] Tulis test distribusi barang katalog, barang Gudang, pembatas zona/slot, id asing dan kepemilikan; jalankan untuk melihat gagal.
- [x] Implementasikan aturan SPEC, slot aman indeks diskret 0..3/0..2 per zona, mangkuk di Makan.
- [x] Jalankan test area/model lama dan commit.

## Task 2: Mesin rutinitas tersimpan

Files: `lib/game/model/home_routine.dart`, `lib/game/model/household.dart`, `test/game/model/home_routine_v2_test.dart`.
Interfaces: `HomeRoutine.initial(kitties)`, `invite`, `cancel`, `advance`, `sync`; `Household.migrate(home, now)`, serialisasi/normalisasi.

- [x] Tulis test kapasitas 9 kucing, FIFO/fairness, ambang swap, batal, kelayakan sebelum mulai, efek tepat sekali, pause/restart/kurangi gerak dan data rusak; jalankan untuk melihat gagal.
- [x] Implementasikan state immutable, ID monotonik aktivitas, pemesanan tunggal per keputusan dan jam aktif deterministik. Transisi mulai dan selesai dipisahkan agar mulai tersimpan sebelum selesai.
- [x] Test seed tetap dan stress sembilan ajakan; commit.

## Task 3: Snapshot dan API controller

Files: `lib/app/progress_snapshot.dart`, `lib/app/progress_store.dart`, `lib/app/progress_scope.dart`, `lib/app/household_controller.dart`, `test/app/household_progress_test.dart`.
Interfaces: `SnapshotStore.readSnapshot/writeSnapshot`, `ProgressSnapshot`; API controller `inviteKitty`, `cancelInvitation`, `advanceHousehold`, `claimAllKittyRewards`, `setHomeArea`, `setReducedMotion`, `pauseHousehold/resumeHousehold`.

- [x] Tulis fixture v1 lengkap dan test simpan gagal, backup, reload, jam mundur, klaim bersamaan, reset/adopsi dan mutasi selama simpan; jalankan untuk melihat gagal.
- [x] Tambah snapshot satu kunci dengan backup raw legacy sebelum commit pertama. Kunci v1 dan audio tetap tersedia. Snapshot rusak dipulihkan per bagian dengan legacy sebagai fallback.
- [x] Hubungkan controller dan sinkronisasi aksi rumah lama; serialisasikan transaksi baru dengan antrean tulis yang sama, hasil tidak dipublikasikan sebelum sukses.
- [x] Jalankan test progres/model dan commit.

## Task 4: Review dan penutupan

- [x] Review independen seluruh branch terhadap SPEC; perbaiki temuan penting dengan test regresi.
- [x] Format, analyze, cek terjemahan/generator, seluruh test (termasuk solver 20 level).
- [x] Catat hasil/batas di `docs/design-v2/model/REVIEW.md`, perbarui GDD/CLAUDE/keputusan/roadmap, push dan buat PR. Merge tetap pemilik repo.

## Ledger

Pre-flight: SPEC sudah disetujui; tidak ada keputusan produk baru. Alur Git repo mengizinkan eksekusi langsung dan PR, tanpa konfirmasi rencana tambahan. Branch terpisah dari main; skill script Unix digantikan perintah PowerShell dan ledger ini untuk lingkungan Windows. Audio menggunakan kunci lama agar tidak ditimpa snapshot gameplay yang kedaluwarsa.

Task 1: complete (d396e30; area + model lama 25/25). Test awal gagal karena model belum ada, lalu lulus.
Task 2: complete (5386442; scheduler/kapasitas/FIFO/stres/reload lulus dalam suite model baru). FIFO dan pendekatan lokal direproduksi gagal lalu diperbaiki.
Task 3: complete (2d7aff8; fixture/transaksi/migrasi dan kompatibilitas model/progres lama 290/290 sebelum review). Test baru seluruh model/progres 20/20 sebelum review.
Final review: fresh independent reviewer, enam temuan penting / tujuh reproduksi gagal. Perbaikan: reservasi adopsi, dana pembelian, high-water clock/hari hadiah, sinkronisasi slot, fallback subbagian dan fasilitas restore. Tujuh regresi RED→GREEN; dua batas tambahan (retry dana dan ID fasilitas asing) juga lulus. Total suite baru 29/29. Tidak ada minor ditunda. Cakupan UI/lifecycle/performa/HP tetap langkah 5–9/13/15 sesuai roadmap.

Task 4: complete. Final format 255 file bersih; analyze tanpa issue; terjemahan dan generator konsisten; flutter test --concurrency=2 --timeout=2m → 2870 pass / 135 skip historis, exit 0. Putaran default sebelumnya 2 kegagalan berbasis waktu (iklan + timeout renderer); ulangan lengkap lulus tanpa mengubah test lama. Tidak ada ruling produk baru atau minor ditunda; keputusan teknis adopsi/reservasi dicatat dalam DESIGN_NOTES.
