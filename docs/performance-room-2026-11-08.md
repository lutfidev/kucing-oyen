# Pengukuran kamar penuh — 8 Nov 2026

Status: pengukuran awal selesai; optimasi pembentukan SVG sudah dibuat dan lolos test lokal. Pengukuran ulang di HP masih menunggu layar dibuka kuncinya. Langkah 32 belum selesai.

## Kondisi

- Xiaomi 24117RN76O, Android 16 / API 36, tersambung USB.
- Flutter mode profile; entrypoint lokal `.dart_tool/room_profile.dart` memakai model dan layar aplikasi yang sama, `MemoryProgressStore`, pengacak `Random(1)`, dan audio asli. Tidak menjalankan SDK iklan.
- Sembilan kucing, semuanya beraksesoris; seluruh 20 barang toko ditaruh pada posisi bawaan, ditambah mangkuk (21 barang). Posisi bawaan bisa saling menumpuk; ini kondisi padat untuk pengujian, bukan usulan tata letak pemain.
- Pemanasan 15 detik, lalu pengumpulan `FrameTiming` selama 60 detik dengan kamar di depan. Tidak menguji navigasi atau interaksi selama pengukuran.
- Layar mendukung 60/90/120 Hz. Perbandingan berikut memakai anggaran 60 fps (16,67 ms), bukan klaim aplikasi mencapai 120 fps.

## Hasil

3.235 bingkai tercatat; sekitar 53,9 bingkai per detik selama jendela pengukuran. Ini laju bingkai yang dilaporkan Flutter, bukan pengukuran presentasi fisik layar.

| Durasi (ms) | Rata-rata | P50 | P90 | P99 | Maksimum |
| --- | --- | --- | --- | --- | --- |
| Build / UI | 13,471 | 12,375 | 17,235 | 22,289 | 28,498 |
| Raster | 12,263 | 11,963 | 13,694 | 18,299 | 27,047 |

- 463 dari 3.235 bingkai (14,3%) memiliki durasi build atau raster di atas 16,67 ms.
- Seluruh bingkai memiliki setidaknya salah satu durasi di atas 8,33 ms.
- Durasi build dan raster dibandingkan secara terpisah; tidak dijumlahkan karena pipeline dapat berjalan bersamaan.
- Tidak ada crash yang tercatat saat pengecekan.

Kamar penuh sebelum optimasi belum stabil pada target 60 fps di perangkat ini. Belum ada pengujian di perangkat lain atau HP dengan spesifikasi lebih rendah.

## Optimasi dan validasi lokal

`kittyDrawing` sebelumnya membentuk ulang nilai dan perintah SVG setiap bingkai animasi. Varian sekarang disiapkan sekali dengan `SvgTemplate.bind`, disimpan pada cache LRU maksimal 96 varian, lalu dievaluasi pada waktu asli. Waktu tidak dibulatkan dan bingkai tidak disimpan sepanjang permainan.

Diagnostik desktop (300 bingkai × 9 kucing idle beraksesoris, membentuk `kittyDrawing` lalu menggambar ke `PictureRecorder`): pembentukan SVG rata-rata 6,981 → 0,868 ms per bingkai sembilan kucing; perekaman gambar 1,074 → 0,400 ms. Ini pengukuran mikro di laptop, bukan klaim FPS atau perbaikan durasi raster HP.

Test membandingkan piksel dan bounds secara persis dengan renderer acuan pada 9 kucing × 12 pose × 3 waktu (termasuk waktu null), ditambah pergantian waktu/varian setelah lebih dari 96 varian digunakan. Perbandingan juga mencakup snapshot nilai, opasitas grup, dan penolakan kombinasi CSS yang tidak didukung. Review kode tidak menemukan masalah yang menghalangi; dua saran kecil tentang kontrak validasi dan cakupan cache sudah ditangani.

Pengukuran ulang pertama tidak valid: HP terkunci, viewport awal nol menyebabkan kesalahan geometri dan hasil `no_frames`. Tidak ada angka tersebut yang dipakai untuk membuktikan peningkatan performa. Ulangi saat HP terbuka dan kamar tetap di depan selama seluruh tes.

Untuk mengulang dengan data memori yang sama:

```sh
flutter run --profile -t tool/profile_room.dart -d <device>
```

Tunggu 15 detik pemanasan dan 60 detik pengukuran, lalu baca baris `ROOM_PROFILE_RESULT` di log Flutter. Kembalikan build biasa dari `lib/main.dart` setelah tes; jangan membuat rilis produksi dari entrypoint profil.

## Pemulihan dan pengujian manual

Versi release biasa dipasang kembali setelah tes. Potret layar sesudah pemulihan menunjukkan progres asli tetap ada: 80 koin, 9/60 bintang, kamar awal Oyen dan mangkuk. Data kamar penuh tidak ditulis ke penyimpanan pemain.

Pemilik repo melaporkan pengujian manual debug dan release berjalan baik untuk gameplay, suara, iklan Tambah Koin dan hadiahnya; ikon dan splash juga dinilai baik. Ini laporan manual, bukan pengukuran latensi audio. TalkBack dilewati atas permintaan pemilik repo. Formulir UMP, iklan petunjuk, ikon tema, dan splash Android versi lama belum diverifikasi secara terpisah.
