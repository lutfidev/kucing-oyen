# Langkah 26: Potret toko dan rapi-rapi rumah Oyen — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (sesi utama, sesuai CLAUDE.md). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Materi toko (potret, listing, kebijakan privasi, Data safety) dan GDD memperlihatkan rumah Oyen, dan saran kecil PR langkah 21–25 yang masih berlaku dibereskan.

**Architecture:** Potret toko tetap dibuat `test/screenshots/brand_test.dart` dengan `KucingOrenApp` sungguhan (kamar diam, `roomRandom` ber-seed). Saran kecil diperbaiki di model Dart murni dan layar kamar, masing-masing dengan test yang gagal dulu.

**Tech Stack:** Flutter, flutter_test, ARB + `flutter gen-l10n`.

**Spec:** prompt langkah 26 di `docs/ROADMAP.md` (tanpa dokumen desain baru; keputusan dicatat di `docs/DESIGN_NOTES.md` "Langkah 26").

## Global Constraints

- Teks pemain di keempat ARB (Indonesia dulu), nada santai jenaka; jalankan `flutter gen-l10n`, lalu `python tool/translations/make_review.py`.
- Tidak ada warna/ukuran hardcode di widget.
- Aturan main, level, dan bintang tidak berubah.
- Potret ponsel 1080×1920 (360×640 × 3), maksimum 8 per bahasa (batas Play), kamar tampil pertama.
- Tanpa atribusi Claude di commit/PR.

## Review Focus

- Kucing dengan Lapar dan Senang 100: tombol camilan mati (tidak membuang stok); dengan salah satu < 100 tetap hidup.
- Elus saat Senang 100: hanya hati, batas elus jam ini tidak terpakai.
- Mangkuk terisi < 60 menit lagi: "Terisi sebentar lagi", bukan "1 jam"; tepat 60 menit = "1 jam".
- Jam HP mundur saat kamar terbuka: kamar tidak crash, label mangkuk dan bar tidak negatif.
- Potret per bahasa memakai finder kunci/l10n, bukan teks Indonesia.

---

### Task 1: `owned` hasil `buy` tidak bisa diubah

**Files:** `lib/game/model/room.dart`, `lib/game/model/accessories.dart`; test di `test/game/model/room_test.dart`, `accessories_test.dart`.

- [ ] Test `buy menghasilkan owned yang tidak bisa diubah`: `expect(() => Room().buy(RoomItemId.bola).owned.add(RoomItemId.jam), throwsUnsupportedError)`; sama untuk `AccessoryCloset().buy(AccessoryId.pita).owned.add(...)`.
- [ ] Jalankan, gagal.
- [ ] Pindahkan `Set.unmodifiable` ke konstruktor privat `_` kedua kelas.
- [ ] Lulus, commit `fix(home): owned sets stay unmodifiable after buy`.

### Task 2: Camilan dan elus saat bar penuh

**Files:** `lib/game/model/needs.dart` (`CatNeeds.isFull` = Lapar dan Senang ≥ `maxNeed`; `petted` → null kalau Senang ≥ `maxNeed`, tanpa memakai jatah), `lib/screens/room/kitty_card.dart` (tombol camilan mati kalau `isFull`); test `needs_test.dart`, `kitty_card_test.dart`.

- [ ] Test model: `CatNeeds(hunger: 100, joy: 100).isFull` true, `(100, 99)` false; `petted` di Senang 100 null dan `petWindowJoy` tidak berubah.
- [ ] Test widget: Oyen penuh → tombol camilan di panel Camilan tidak bisa ditekan, stok tetap; Elus → hati tanpa angka.
- [ ] Gagal → implementasi → lulus. Commit `fix(room): no snacks or petting past full bars`.

### Task 3: "Terisi sebentar lagi"

**Files:** ARB empat bahasa kunci `bowlRefillSoon`; `room_view.dart` `_bowlRefill` → mengembalikan menit sisa atau `Duration`; `BowlRefillLabel` memilih teks; test `test/screens/room_life_test.dart`.

- [ ] Test: mangkuk kosong, isi lagi 30 menit → teks `bowlRefillSoon`; 60 menit → `bowlRefill(1)`; 61 menit → `bowlRefill(2)`.
- [ ] Gagal → implementasi → `flutter gen-l10n` → lulus. Commit `feat(room): bowl label says soon under an hour`.

### Task 4: Test jam mundur di kamar

**Files:** `test/screens/room_life_test.dart`.

- [ ] Test: kamar hidup terbuka, `clock` dipindah 3 jam mundur, `refreshDay`/penyegaran 30 detik berjalan → tidak ada exception, label mangkuk tidak tampil negatif, bar kartu kucing 0–100. Kalau gagal, perbaiki dengan systematic-debugging.
- [ ] Commit `test(room): clock going backwards`.

### Task 5: Potret toko

**Files:** `test/screenshots/brand_test.dart`, hapus `docs/store/screenshots/*/01-beranda.png` dan `12-lemari-kostum.png`.

Urutan baru per bahasa: `01-kamar` (kamar penuh: 12+ barang, 5 kucing, beberapa beraksesoris, saldo 480), `02-toko-aksesoris` (tab Aksesoris, satu aksesoris belum dimiliki diketuk → pratinjau pada Oyen), `03-peta-babak-2`, `04-fase-atur-level-13`, `05-fase-jalan-level-13`, `06-berhasil-level-13`.

- [ ] Ubah test, jalankan `flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true`, lihat PNG keempat bahasa.
- [ ] Feature graphic tetap (Oyen tidur tanpa kostum, bukan Beranda lama); hanya dibuat ulang oleh perintah yang sama.
- [ ] Commit `feat(store): screenshots show Oyen's room and shop`.

### Task 6: Dokumen

- [ ] Listing empat bahasa: ganti butir lemari kostum dengan kamar yang bisa dihias, kucing yang bisa diadopsi, aksesoris; daftar potret di `docs/store/README.md` (6 gambar baru).
- [ ] Kebijakan privasi empat bahasa: "kostum Oyen" → isi rumah Oyen (barang, kucing, aksesoris, camilan, kebutuhan kucing). Data safety di README: progres game disebut lengkap; cek ulang tidak ada SDK/izin baru (`android/app/src/main/AndroidManifest.xml`, `pubspec.yaml` sejak 20 Okt).
- [ ] GDD: tabel Monetisasi baris aksesoris; catatan di bagian Layar/prompt Claude Design bahwa Lemari Kostum sudah diganti.
- [ ] `python tool/translations/make_review.py`.
- [ ] `DESIGN_NOTES.md` "Langkah 26", centang ROADMAP, Struktur CLAUDE.md kalau API berubah. Commit `docs: step 26 store and GDD`.

### Task 7: Selesai

- [ ] Jalankan ulang potret `--dart-define=SCREENSHOTS=true`, cek kamar.
- [ ] `/check` (format, analyze, test), review subagent effort high, verifikasi, push, PR.

Tidak dikerjakan (dicatat di DESIGN_NOTES): tag "Baru!" (butuh simpanan "sudah dilihat"), gelembung hadiah untuk kucing di dalam barang, tempat berdiri Oyen 116, corak ikut tercermin, penolakan CSS `SvgTemplate`, uji HP murah.
