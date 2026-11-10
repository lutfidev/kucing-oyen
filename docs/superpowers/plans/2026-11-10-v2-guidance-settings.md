# Langkah 12 — Tutorial, Petunjuk, Koin, Pengaturan

> Eksekusi di sesi utama dengan superpowers:executing-plans; desain mengikuti SPEC/SCREENS/VISUAL langkah 1 yang telah disetujui.

**Goal:** Seluruh permukaan bantuan dan pengaturan pemain memakai v2, dapat digulir dalam empat bahasa, dan menampilkan hasil simpan yang benar.
**Architecture:** Pertahankan simulator, ID simpanan, harga serta nominal. Gunakan panel/tombol/token v2, shell sheet dengan back/drag/fokus, seni aturan dari PuzzleArt dan CatRig. Reset produksi menulis snapshot sebelum menerbitkan keadaan; simpan gagal dapat dicoba ulang. Pengenalan rumah berupa bantuan opsional yang dapat dibuka ulang, tanpa modal otomatis yang menghalangi puzzle; pemberitahuan migrasi tetap satu kali.
**Tech Stack:** Flutter, Dart, ARB, flutter_test, renderer Canvas v2.

- [x] 1. Baseline `flutter pub get`, `flutter analyze`, `flutter test`; main terbaru dan branch terpisah.
- [x] 2. Buat panel/header/status v2; migrasikan Koin/Petunjuk beserta saldo, loading, gagal, habis dan retry simpan. Uji iklan/bonus berulang dan petunjuk berurutan.
- [x] 3. Migrasikan Aturan dan Tutorial ke seni kucing/benda v2; pertahankan sorotan/input/skip dan urutan aturan. Uji teks besar dan semua level tutorial.
- [x] 4. Migrasikan Pengaturan, bahasa/audio/gerak/privasi/tentang/lisensi/reset; lengkapi bantuan rumah opsional. Uji simpan gagal, reset/batal, area serta reload dan callback iklan lama.
- [x] 5. Audit SCREENS semua rute termasuk not-found/loading/sheet; tambah matriks 3 ukuran × 4 bahasa × 2 skala, screenshot dan pemeriksaan visual.
- [x] 6. Review independen, perbaiki temuan, format/analyze/test/terjemahan/generator/APK. Catat bukti dan batas di guidance/REVIEW.md, perbarui roadmap/README/CLAUDE, commit dan buka PR; merge oleh pemilik.
