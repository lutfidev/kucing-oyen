# Pengukuran kamar penuh — 8 Nov 2026

Status: pengukuran awal dan pengukuran ulang sesudah optimasi selesai. Beban berkurang, tetapi masih ada bingkai di atas anggaran 60 fps. Langkah 32 belum selesai karena masih ada pemeriksaan dan persiapan produksi lain.

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

## Pengukuran ulang sesudah optimasi (09.39–09.41 WIB)

HP dibuka kuncinya, kamar penuh diverifikasi lewat potret layar, dan pengaturan tetap menyala saat USB tersambung diaktifkan sementara (nilai awal 0, nilai tes 2, dikembalikan ke 0 setelah tes). Kondisi data, pemanasan, dan lama pengukuran sama dengan tes awal. Tidak ada kesalahan Flutter yang tercatat pada log proses tes ini.

| Metrik | Sebelum | Sesudah |
| --- | --- | --- |
| Bingkai tercatat selama 60 detik | 3.235 | 3.792 |
| Build rata-rata (ms) | 13,471 | 8,207 |
| Build P50 / P90 / P99 (ms) | 12,375 / 17,235 / 22,289 | 7,537 / 9,733 / 18,517 |
| Build maksimum (ms) | 28,498 | 28,876 |
| Raster rata-rata (ms) | 12,263 | 10,571 |
| Raster P50 / P90 / P99 (ms) | 11,963 / 13,694 / 18,299 | 10,041 / 13,176 / 17,017 |
| Raster maksimum (ms) | 27,047 | 19,656 |
| Build atau raster >16,67 ms | 463 (14,3%) | 99 (2,61%) |
| Build atau raster >8,33 ms | 3.235 | 3.736 |

Build rata-rata turun sekitar 39%; porsi bingkai di atas 16,67 ms turun sekitar 82% relatif terhadap tes awal. Ini satu pengukuran sebelum dan sesudah pada satu HP: suhu dan aktivitas sistem tidak dikontrol, serta jalur rutinitas kucing dapat berbeda karena waktu antarbingkai. Angka ini menunjukkan perbaikan pada kondisi tes, bukan jaminan FPS stabil di semua perangkat. Jangan menyebut hasil ini bebas stutter atau stabil 120 fps. Bingkai lambat yang tersisa dan pengujian HP spek lebih rendah tetap menjadi batas hasil.

Hasil log sesudah optimasi:

```json
{"frames":3792,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.207055643459917,"p50_ms":7.537,"p90_ms":9.733,"p99_ms":18.517,"max_ms":28.876},"raster":{"mean_ms":10.571090981012631,"p50_ms":10.041,"p90_ms":13.176,"p99_ms":17.017,"max_ms":19.656},"over_16_67ms":99,"over_8_33ms":3736}
```

## Pemulihan dan pengujian manual

Versi release biasa dengan optimasi dipasang kembali setelah tes ulang. Potret layar sesudah pemulihan menunjukkan progres asli tetap ada: 80 koin, 9/60 bintang, kamar awal Oyen dan mangkuk. Data kamar penuh tidak ditulis ke penyimpanan pemain. Pengaturan layar tetap menyala saat USB tersambung sudah dikembalikan ke nilai awal 0; proses aplikasi release berjalan dan buffer crash kosong saat diperiksa.

Pemilik repo melaporkan pengujian manual debug dan release berjalan baik untuk gameplay, suara, iklan Tambah Koin dan hadiahnya; ikon dan splash juga dinilai baik. Ini laporan manual, bukan pengukuran latensi audio. TalkBack dilewati atas permintaan pemilik repo. Formulir UMP, iklan petunjuk, ikon tema, dan splash Android versi lama belum diverifikasi secara terpisah.
