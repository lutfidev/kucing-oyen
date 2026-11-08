# Model rumah v2 — langkah 4

Implementasi 8 November 2026. Acuan perilaku: [SPEC](../SPEC.md). Model dan penyimpanan tersedia; layar rumah baru dan penggerak lifecycle rutinitas dipasang pada langkah 5–9. Layar v1 tetap dapat dimainkan selama migrasi bertahap.

## Kontrak untuk integrasi layar

- `HomeArea`: Santai/Makan/Main/Rawat, kapasitas 3/2/2/2. `household.routine.locations` adalah pemilik slot tunggal; `journeys` menunjukkan perjalanan dan reservasi. `findArea` mengikuti tujuan, `present` menghitung slot yang sedang dimiliki. Jangan menggambar kucing di dua area.
- `HomeAreas` memisahkan kepemilikan katalog `Home.room` dari penempatan v2. Tidak ada pembelian hilang ketika slot penuh: barang tanpa slot berada di Gudang v2. Barang Gudang v1 tetap Gudang. Koordinat v1 tidak digunakan.
- Slot lantai 0–3 berjangkar (0,18/0,82; 0,62/0,88), slot dinding 0–2 (0,16/0,50/0,84; 0,25), relatif ke kanvas area. Jalur tengah disisakan. Mangkuk adalah slot Makan/lantai/0; bola/alas/sikat dasar adalah fasilitas struktural gratis, bukan pembelian katalog.
- `inviteKitty`/`cancelInvitation`: satu ajakan per kucing, identik idempoten, FIFO pemain, setelah dua pemain dilayani satu otomatis bila ada. Tujuan yang penuh memakai swap dengan kucing diam (tanpa ajakan lebih dulu, lalu katalog); transaksi ambang terjadi pada 0,5 detik, perjalanan selesai pada 1 detik. Pendekatan di area yang sama juga 1 detik.
- `advanceHousehold(activeSeconds)` menerima dt aktif monotonik, bukan selisih kalender atau waktu offline. Langkah yang memulai aktivitas hanya menyimpan ID dan durasi 4/8/6/2 detik; aktivitas baru mengonsumsi dt pada panggilan berikutnya. Lanjutkan ID/sisa durasi saat membuka kembali. Renderer mengikuti model; kurangi gerak tidak mempercepat hadiah.
- `pauseHousehold`/`resumeHousehold` memakai alasan bertumpuk `hidden/background/ad/decorating/reset`. Penggerak layar berikutnya wajib meneruskan lifecycle, rute, iklan dan Hias; jangan hanya mematikan ticker gambar. Sheet biasa tetap menjalankan rutinitas. Hias menolak ajakan baru.
- `claimableKitties`/`householdRewardCoins` untuk rincian hadiah; `claimAllKittyRewards` mengecek ulang kebutuhan/hari dan menyimpan total bersama tanda klaim. Kegagalan tidak menerbitkan saldo baru. `householdSaveFailed` memberi keadaan Coba lagi; `retrySaves()` memakai transaksi tertunda dan ID aktivitas yang sama. Klaim/efek diperiksa ulang pada retry.
- `setHomeArea`, `setReducedMotion`, `acknowledgeHomeMigration`: preferensi tersimpan. Pilihan kucing hanya sesi; `initialSelection` memilih Oyen jika hadir di area terakhir, kemudian urutan katalog. Integrasi preferensi sistem Kurangi gerak ada pada layar berikutnya.
- `saveAreaLayout` menerima draf immutable, tidak memberi bonus bila tata letak sama. Penyimpanan gagal mempertahankan tata letak/kebutuhan lama; barang opsional yang sedang dipakai dan disimpan menghentikan aktivitas tanpa efek yang belum diberikan.

## Penyimpanan dan migrasi

`PrefsProgressStore` menambahkan kemampuan `SnapshotStore`. Satu JSON `progress.snapshot.v2` versi 2 mencakup bintang, tutorial, saldo, petunjuk, koleksi/aksesoris/camilan, kebutuhan/cooldown/hari hadiah, bahasa dan keadaan rumah. Sebelum tulisan pertama, nilai mentah kunci v1 disalin ke `progress.backup.v1`. Kunci v1 tetap tersedia; backup tidak ditimpa oleh commit selanjutnya. Audio tetap memakai `settings.music`/`settings.sfx`, sehingga perubahan audio tidak ditimpa snapshot gameplay lama.

Controller membaca snapshot v2 setelah fallback v1. Bagian yang tidak dapat dibaca dipulihkan per bagian; lokasi tidak sah disebarkan ke slot bebas, perjalanan rusak dibuang tanpa efek. Versi snapshot lebih baru ditolak supaya tidak ditimpa. Kerusakan total v2 hanya dapat mengembalikan progres sebelum migrasi yang masih ada pada kunci v1; tidak ada klaim dapat merekonstruksi pembelian yang seluruh datanya telah hilang.

Transaksi rumah produksi masuk antrean tulis yang sama dengan hasil puzzle/iklan/pengaturan, lalu baru menerbitkan perubahan setelah satu tulisan berhasil. Pembelian/aksi rumah lama pada store atomik juga menggunakan jalur ini. Saldo baru dari puzzle selama penyimpanan rumah dipertahankan dan masuk snapshot berikutnya. Adapter per-bagian `MemoryProgressStore`/test lama tetap mempertahankan kontrak v1; untuk API v2 gunakan adapter yang menyediakan `SnapshotStore`.

## Verifikasi

Hasil akhir: `dart format --output=none --set-exit-if-changed lib test` bersih (255 file), `flutter analyze` tanpa issue, cek terjemahan dan generator 209 aset konsisten. Seluruh `flutter test --concurrency=2 --timeout=2m` lulus: **2.870 test**, **135 skip historis**. Termasuk solver/solusi seluruh 20 level, kompatibilitas layar v1 dan 29 test baru/regresi.

Putaran suite dengan paralelisme default sebelumnya menghasilkan satu kegagalan test jeda iklan wall-clock dan satu timeout 30 detik pada test pembandingan SVG. Tidak ada kode iklan/renderer atau test lama yang diubah. Ulangan lengkap dengan dua worker dan batas 2 menit per test selesai 3 menit 10 detik tanpa kegagalan. Angka ini adalah hasil verifikasi host sesi ini, bukan ukuran performa perangkat.

Test baru mencakup migrasi koleksi lengkap, kapasitas, Gudang, FIFO/fairness, swap, pembatalan, jeda/reload, pendekatan lokal, kuota, jam mundur, kegagalan simpan/retry, transaksi bersamaan, reset dan draf tata letak. Stres ber-seed menjalankan 1.200 langkah campuran untuk tiap seed, dengan pemeriksaan invariansi dan reload berulang.

## Batas

Belum mengganti layar pemain, menampilkan ringkasan migrasi, atau menjalankan mesin v2 di layar rumah v1. Perilaku visual/perpindahan area dan lifecycle pada UI, TalkBack, serta performa/penyimpanan pada HP diuji saat integrasi berikutnya. Tidak ada screenshot baru untuk langkah model ini.

## Tinjauan kode independen

Satu reviewer terpisah memeriksa seluruh implementasi terhadap SPEC dan rencana. Enam temuan penting direproduksi sebagai tujuh test gagal sebelum perbaikan: adopsi saat slot akhir dipesan, pembayaran pembelian/petunjuk bersamaan, waktu efektif mundur (termasuk hari hadiah migrasi), penempatan Gudang v2 hilang saat aksi v1, subbagian rumah rusak tanpa fallback, dan fasilitas kegiatan tersimpan yang tidak tersedia. Semuanya sudah diperbaiki. Dua test tambahan memeriksa retry pembelian setelah saldo berkurang dan ID fasilitas tidak dikenal. Total 29 test baru/regresi lulus.

Review tidak menilai integrasi layar/lifecycle langkah 5–9, rendering/performa, atau durability fisik penyimpanan perangkat; cakupan itu tetap pada langkah roadmap masing-masing. Tidak ada temuan minor yang ditunda. Perbaikan diuji lewat RED→GREEN dan seluruh suite, tanpa mengubah/menghapus test perilaku lama.
