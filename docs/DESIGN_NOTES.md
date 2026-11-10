# Keputusan desain aktif Ginger Logic

Dimulai ulang pada **8 November 2026** bersama roadmap baru. Catatan langkah lama tersedia di riwayat Git dan bukan spesifikasi visual aktif.

## Area Bermain v2 — 10 November 2026

Langkah 7 memakai satu fasilitas mainan dengan satu titik tunggu, panel status
Senang/cooldown, sheet pilih kucing dan antrean/batal. Bola dasar gratis tetap
tersedia tanpa kepemilikan katalog. Mainan opsional pertama menurut urutan
katalog menjadi fasilitas; kegiatan aktif mempertahankan fasilitasnya sampai
selesai atau diinterupsi karena barang disimpan. Kuota bermain tetap per kucing,
bukan per mainan. Model dan renderer memakai pilihan fasilitas yang sama.

Latar raster mengikuti ilustrasi Makan/Santai melalui imagegen bawaan; sumber,
prompt, lisensi dan ukuran ada di [PAINTED_ASSET](design-v2/play/PAINTED_ASSET.md).
Mainan dirender terpisah tanpa bola duplikat dari rig. Dua posisi dan lintasan
serah giliran mengikuti Makan; target mainan terpisah dari target kucing,
minimal 48 dp. Kurangi gerak mempertahankan pose diam dan tidak mengubah kuota.
Tidak mengubah ekonomi, skema snapshot, atau aturan puzzle. Editor tetap langkah 9.
Hasil render dan batas pengujian: [review Bermain](design-v2/play/REVIEW.md).

## Area Makan v2 — 9 November 2026

Langkah 6 melengkapi fasilitas makan dengan satu mangkuk dan titik tunggu,
panel jatah koleksi serta status individu, sheet pilih kucing dan batal antrean.
Aturan makan tetap SPEC/v1: Makanan <70, +40 saat selesai 4 detik, tiap kucing
sekali dalam siklus 4 jam sejak makan pertama, isi ulang otomatis tanpa biaya.
Waktu UI memakai high-water mark yang sama dengan transaksi.

Antrean UI memakai urutan scheduler (prioritas pemain/FIFO/fairness), bukan
sekadar nomor pesanan. Latar raster Makan dibuat imagegen bawaan memakai
Santai yang disetujui sebagai acuan; kucing dan mangkuk tetap dinamis.
Sumber/prompt dan batas pengujian: [review Makan](design-v2/dining/REVIEW.md).
Pergantian giliran memakai transisi posisi singkat; Kurangi gerak mematikannya.

## Integrasi beranda v2 — 9 November 2026

Visual akhir rumah berilustrasi diterima pemilik repo dengan “boleh lah” setelah
tinjauan screenshot runtime. Langkah 5 selesai dan dicentang; PR #44 berubah
dari draft menjadi siap review. Merge tetap dilakukan pemilik repo. Langkah 6
(Makan) dimulai setelah merge, dengan arah ilustrasi ini sebagai acuan.

Keputusan ilustrasi berikutnya: permintaan warna/kekayaan visual seperti mockup
diterapkan dengan latar Santai baru dari imagegen bawaan, terpisah dari UI,
kucing dan barang katalog. Aset WebP 180.076 byte, decode tetap 4 MiB; vektor
menjadi fallback jika belum siap/gagal. Inventaris vektor tetap 209. Sumber PNG,
prompt, hak keluaran dan kontrak integrasi tercatat di
[PAINTED_ASSET](design-v2/home/PAINTED_ASSET.md). Ini revisi pilihan teknis
vektor murni untuk latar, tanpa mengubah aturan model. PR #44 tetap draft.

Revisi ilustrasi berdasarkan perbandingan langsung konsep A: pulihkan biru
jendela dan hijau daun, gunakan highlight/lipatan pada bahan, serta cahaya
terarah dan bayangan kontak. Hapus tint kuning global. Tekstur dinding/lantai
berada pada latar statis; warna karakter dan aturan model dipertahankan.
[Pembanding ilustrasi](design-v2/home/REVIEW.md) diperbarui di PR #44.

Revisi warna berikutnya atas permintaan pemilik repo: krem madu dan ivory
hangat untuk rumah/kartu, kayu karamel serta cahaya sore untuk Santai. Token
khusus rumah menjaga identitas warna kucing dan palet dasar layar lain.
[Perbandingan palet](design-v2/home/REVIEW.md) tersedia; penerimaan akhir tetap
melalui tinjauan visual pemilik repo.

Tinjauan berikutnya: pemilik repo meminta tampilan dirapikan terlebih dahulu,
sebelum langkah 6. Perapian meliputi arsitektur Santai, karakter lebih bulat,
komposisi berlapis, empat tab terlihat pada teks normal dan kontrol yang lebih
ringkas. Aturan model tetap; [perbandingan sebelum/sesudah](design-v2/home/REVIEW.md)
masih menunggu penerimaan pemilik repo. PR #44 tetap draft.

Langkah 5 memasang rumah v2 sebagai rute pemain, memakai lokasi model langkah
4 dan aset/komponen langkah 2–3. Pilihan kucing bersifat sesi dan tidak ikut
hilang ketika kucing meninggalkan area. Tab disimpan; sheet tetap menjalankan
rutinitas; rute lain, lifecycle, iklan dan gagal simpan menjeda clock aktif.
Preferensi/sistem Kurangi gerak hanya mengubah rendering. Lihat
[screenshot dan batas tinjauan](design-v2/home/REVIEW.md). Penerimaan visual
pemilik repo masih diperlukan sebelum langkah 5 dicentang. Penyelesaian area
khusus tetap langkah 6–8; editor Hias/Gudang langkah 9, tanpa membuka editor
koordinat v1 di rumah baru. Tidak mengubah ekonomi, solver atau aturan puzzle.


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
