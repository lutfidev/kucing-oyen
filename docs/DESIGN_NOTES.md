# Keputusan desain aktif Ginger Logic

Dimulai ulang pada **8 November 2026** bersama roadmap baru. Catatan langkah lama tersedia di riwayat Git dan bukan spesifikasi visual aktif.

## Keputusan pemilik repo

- Seluruh visual diubah, termasuk bentuk kucing, mengikuti konsep A pada [preview Rumah Oyen](design-brief/rumah-oyen-area/preview-perbandingan.png), sisi kiri.
- Satu area per layar; kucing beraktivitas otomatis dan bisa diajak pemain.
- Desain, screenshot, brief dan rencana visual lama dibersihkan. Roadmap mulai langkah 1; release tetap menjadi tahap akhir setelah semuanya siap.
- Tahap sekarang adalah penyusunan ulang rencana, belum implementasi seluruh tampilan baru.

## Fondasi proyek saat reset

- Flutter + Flame, Android portrait, `com.gingerlogic.app`, versi saat reset `1.0.0+1`.
- Simulator/solver, 20 level, progres, transaksi koin, koleksi, penyimpanan, iklan dan suara sudah berjalan; desain baru dibangun di atas fondasi tersebut.
- Empat bahasa: Inggris utama, Indonesia, Portugis Brasil, Rusia. Teks baru masuk keempat ARB dan review terjemahan diperbarui bila perlu.
- Kucing koleksi berada di rumah. Aturan puzzle tetap mengacu GDD dan data level; perombakan visual tidak otomatis mengubah aturan.
- Simpanan lama harus dimigrasikan saat rumah menjadi beberapa area. Penomoran ulang roadmap tidak mereset progres pemain.
- Aset/kode runtime lama diganti bertahap ketika penggantinya siap. Gambar dokumentasi lama dibuang agar tidak menjadi acuan yang keliru.

## Persetujuan langkah 1 — 8 November 2026

Pemilik repo menyetujui arah visual dan usulan aturan setelah meninjau [paket desain v2](design-v2/README.md), branch `feat/design-v2-spec`, PR #40. Persetujuan eksplisit: “okee setuju sih sudah bagus hihi”; masukan selanjutnya akan disampaikan dan dicatat sebagai revisi. Disepakati: empat area gratis, kapasitas 3/2/2/2, antrean ajakan, elus+sikat tanpa mandi/kebutuhan kebersihan, hadiah gabungan dengan nominal v1. Langkah 1 selesai; runtime belum berubah.

Snapshot kode aplikasi lama telah dibuat dan di-push atas permintaan pemilik repo di branch [`archive/v1-desain-lama`](https://github.com/lutfidev/kucing-oyen/tree/archive/v1-desain-lama), commit `3c472b1`. Arsip tidak digunakan untuk pengembangan desain baru; dokumentasi snapshot sudah memuat arah redesign.

Rincian empat area, perpindahan/antrean, prioritas ajakan, pembatalan, hadiah, hias per area, pengenalan fitur dan migrasi mengikuti SPEC. Koreksi penyimpangan gambar dalam mockups/README.md tetap berlaku.

Target visual, aset/animasi dan seluruh keadaan layar dijabarkan dalam spesifikasi baru sebelum implementasi. Jangan menyalin ukuran dari HTML desain lama yang sudah dihapus.

## Paket aset langkah 2 — 8 November 2026

Sumber vector orisinal diproduksi di `assets/art/v2/` melalui generator deterministik `tool/art_v2/`. 209 bagian mencakup sembilan identitas, seluruh 16 aksesoris/21 barang katalog dan empat latar berlapis. Renderer rig bersama memiliki empat arah, jangkar mengikuti kepala, varian aksesori belakang dan delapan fase jalan; tersedia di `/galeri/aset-v2`. Bos tuxedo/blaze, Kembang tortoiseshell dan Telon tiga warna dipertahankan termasuk corak belakang.

Pilihan teknis vector mempertahankan proporsi/palet/outline A dengan permukaan rata tanpa grain raster. Sumber sekitar 258 KB, entry APK sekitar 79 KB terkompresi, tanpa atlas atau frame cache; laporan pengukuran host dan keterbatasan HP ada di [tinjauan aset](design-v2/assets/REVIEW.md). Penggunaan pada rumah/puzzle dan profil perangkat mengikuti langkah berikutnya; ikon/splash/materi toko belum diganti.

## Fondasi UI langkah 3 — 8 November 2026

Token dan komponen baru ada di `KoUi`/`lib/widgets/v2/`, galeri `/galeri/ui-v2`. Tema dipasang per layar selama migrasi, dengan label empat bahasa. Ink di atas oranye terang; oranye gelap hanya bayangan tombol karena tidak memenuhi kontras 4,5:1 untuk teks normal. Fredoka memakai fallback NunitoUi untuk Cyrillic, regular Nunito dibundel dengan SIL OFL. Navigasi ringkas mempertahankan kata utuh pada teks 130%; tombol puzzle terpisah dari aktivitas Bermain. [Render, verifikasi dan batas](design-v2/ui/REVIEW.md). Model/simpanan dan layar pemain yang dijadwalkan berikutnya masih mengikuti fondasi sebelumnya.

## Model rumah langkah 4 — 8 November 2026

Fondasi `HomeArea`/`HomeAreas`/`HomeRoutine`/`Household` memisahkan empat area, slot barang, perjalanan, ajakan dan kegiatan dari renderer. Penempatan v2 tidak mengikuti koordinat atau status penempatan kamar v1; kepemilikan tetap katalog yang sama. Bola/alas/sikat dasar adalah fasilitas struktural gratis. Jangkar slot diskret, ambang perjalanan 0,5 detik dan pendekatan 1 detik adalah keputusan implementasi, bukan perubahan durasi kegiatan atau kuota.

Progres gameplay produksi memakai satu snapshot JSON versi 2, dengan backup mentah v1 sebelum tulisan pertama; audio mempertahankan kuncinya. Aksi rumah pada store atomik baru terlihat setelah simpan sukses. Penempatan, ID kegiatan, kebutuhan dan hadiah dipulihkan bersama, waktu efektif mencakup timestamp serta hari hadiah tersimpan. Bila adopsi mengisi slot kosong terakhir yang sedang dipesan, perjalanan tunggal yang belum melewati ambang dibatalkan pada asal aman dan ajakannya tetap antre untuk dihitung ulang. Tidak memotong perjalanan berpasangan atau yang sudah commit. [Kontrak, hasil dan batas](design-v2/model/REVIEW.md).

Layar rumah v1 belum menjalankan scheduler v2. Integrasi layar, alasan pause/lifecycle/iklan, ringkasan migrasi dan preferensi sistem Kurangi gerak mengikuti langkah 5–9/12–13. Tidak ada angka ekonomi atau aturan simulator yang berubah.

## Baseline sebelum paket aset v2

- [Baseline performa kamar lama](performance-room-2026-11-08.md): 9 kucing, 21 barang termasuk mangkuk; sebelum/sesudah optimasi SVG, bingkai di atas 16,67 ms turun dari 14,3% menjadi 2,61%. Ini bukan kelulusan tampilan baru.
- Cache SVG animasi dibatasi 96 varian dan dijaga test kesamaan gambar. Pipeline aset baru perlu diukur lagi.
- HP uji Xiaomi 24117RN76O, Android 16/API 36. Manual debug/release sebelumnya dilaporkan baik; TalkBack dilewati atas permintaan pemilik repo. Desain baru perlu diuji ulang seluruhnya.
- Masih perlu disiapkan/dicek saat rilis: AdMob asli, keystore, kebijakan privasi, UMP, iklan petunjuk, ikon tema, perangkat/Android lain, terjemahan, formulir dan listing Play Console.
- Dokumen rilis dan kebijakan privasi dipertahankan. Jawaban kebijakan diverifikasi terhadap fitur serta ketentuan terbaru pada saat rilis.
