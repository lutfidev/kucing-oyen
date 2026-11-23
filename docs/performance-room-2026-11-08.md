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

## Gang Depan (langkah 38, 23 Nov 2026 16.46 WIB)

HP sama, layar terbuka, pengaturan tetap menyala saat USB tersambung diubah sementara ke 2 lalu dikembalikan ke 0. `tool/profile_room.dart --dart-define=PLACE=lane`: data memori kamar penuh yang sama, level 1 menang, sudah bertemu Kumis, jam di tengah kunjungan; pintu depan diketuk sesudah 5 detik, jadi pemanasan memuat kamera ke gang, lalu 60 detik pengukuran di gang (Oyen dan Kumis di bangku, lalu bermain). Kamera sendiri tidak ikut diukur.

| Metrik | Rumah (sesudah optimasi) | Gang |
| --- | --- | --- |
| Bingkai tercatat selama 60 detik | 3.792 | 3.680 |
| Build rata-rata (ms) | 8,207 | 8,404 |
| Build P50 / P90 / P99 (ms) | 7,537 / 9,733 / 18,517 | 7,735 / 9,731 / 19,743 |
| Build maksimum (ms) | 28,876 | 36,411 |
| Raster rata-rata (ms) | 10,571 | 11,401 |
| Raster P50 / P90 / P99 (ms) | 10,041 / 13,176 / 17,017 | 11,185 / 13,582 / 15,675 |
| Raster maksimum (ms) | 19,656 | 22,852 |
| Build atau raster >16,67 ms | 99 (2,61%) | 128 (3,48%) |

Gang setara dengan rumah penuh pada HP ini; satu pengukuran, suhu dan aktivitas sistem tidak dikontrol. Potret beruntun lewat adb selama kamera pergi dan pulang menemukan penanda "Oyen di gang" yang ikut diperbesar kamera berangkat (diperbaiki, lihat `docs/DESIGN_NOTES.md` "Langkah 38").

```json
{"place":"lane","frames":3680,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.40434157608697,"p50_ms":7.735,"p90_ms":9.731,"p99_ms":19.743,"max_ms":36.411},"raster":{"mean_ms":11.40143722826086,"p50_ms":11.185,"p90_ms":13.582,"p99_ms":15.675,"max_ms":22.852},"over_16_67ms":128,"over_8_33ms":3670}
```

## Rumah dua ruangan (langkah 32, 23 Nov 2026 18.20–19.00 WIB)

HP sama (Xiaomi 24117RN76O, Android 16), layar terbuka, dicas, status termal 0, suhu baterai 33 °C. `tool/profile_room.dart` dengan data memori yang sama (9 kucing beraksesoris, 20 barang toko + mangkuk, semuanya di ruang tengah). APK profil dipasang dengan `adb install -r`, bukan `flutter run`. Satu run "diam" pertama sesudah perbaikan tidak sah karena layar HP mati sendiri (359 bingkai); pengaturan tetap menyala saat USB diubah sementara 0 → `usb` → 0.

| Metrik | Sebelum, diam | Sebelum, pindah ruangan | Sesudah, diam | Sesudah, pindah ruangan |
| --- | --- | --- | --- | --- |
| Bingkai dalam 60 detik | 3.353 | 3.495 | 3.448 | 3.502 |
| Build rata-rata (ms) | 10,604 | 10,273 | 10,095 | 9,856 |
| Build P50 / P90 / P99 (ms) | 9,370 / 15,205 / 28,906 | 9,206 / 14,680 / 28,076 | 9,185 / 11,532 / 22,571 | 8,877 / 14,000 / 26,416 |
| Raster rata-rata (ms) | 12,028 | 11,419 | 12,951 | 12,347 |
| Raster P50 / P90 / P99 (ms) | 11,468 / 14,201 / 22,794 | 11,353 / 14,346 / 15,721 | 12,761 / 14,158 / 16,911 | 12,453 / 14,734 / 17,602 |
| Build atau raster >16,67 ms | 303 (9,0%) | 222 (6,4%) | 237 (6,9%) | 265 (7,6%) |

Pembanding tanpa `RepaintBoundary` barang diam (hanya perbaikan bentuk SVG): 261 (7,6%) diam, 395 (11,7%) pindah ruangan, build rata-rata 10,84 / 10,51 ms. Variasi antar-run besar; satu run per baris.

**Rincian biaya (probe stopwatch sementara di HP, rata-rata 600 bingkai, sebelum perbaikan):** `paintRoomItemArt` 3,7 ms (21 barang per bingkai), `paintHouseLayer` 3,2 ms (3 lapisan bergerak), `paintKitty` 2,9 ms (±7,5 kucing), logika `RoomView` (tick, `_syncKitties`, `build`, `_room`) ±0,5 ms. Sesudah `RepaintBoundary`: ±11 barang per bingkai (yang beranimasi atau sedang dipakai kucing). Sesudah perbaikan bentuk: lapisan rumah 2,2 ms. Benchmark desktop lapisan latar ruang tengah: `render` 916 → 331 µs, `paint` ±290 µs, total per bingkai 1,43 → 0,79 ms.

**Batas:** masih di atas ≲3%. Sisa biayanya SVG beranimasi yang direkam ulang tiap bingkai (lapisan latar, kucing, barang yang dipakai) dan raster ±12–13 ms. Dilanjutkan di langkah 39 (keputusan pemilik repo).

Gang sesudah perbaikan, satu run: 4.058 bingkai, build 7,149 ms (P90 8,152), raster 12,953 ms, 147 (3,6%) di atas 16,67 ms; sebelumnya 3,48%.

```json
{"switch_rooms":false,"place":"house","frames":3353,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":10.604313748881593,"p50_ms":9.37,"p90_ms":15.205,"p99_ms":28.906,"max_ms":44.88},"raster":{"mean_ms":12.028198628094266,"p50_ms":11.468,"p90_ms":14.201,"p99_ms":22.794,"max_ms":57.203},"over_16_67ms":303,"over_8_33ms":3353}
{"switch_rooms":true,"place":"house","frames":3495,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":10.273481545064381,"p50_ms":9.206,"p90_ms":14.68,"p99_ms":28.076,"max_ms":44.534},"raster":{"mean_ms":11.419389985693863,"p50_ms":11.353,"p90_ms":14.346,"p99_ms":15.721,"max_ms":22.175},"over_16_67ms":222,"over_8_33ms":3338}
{"switch_rooms":false,"place":"house","frames":3448,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":10.095315255220427,"p50_ms":9.185,"p90_ms":11.532,"p99_ms":22.571,"max_ms":42.186},"raster":{"mean_ms":12.951233468677472,"p50_ms":12.761,"p90_ms":14.158,"p99_ms":16.911,"max_ms":24.876},"over_16_67ms":237,"over_8_33ms":3448}
{"switch_rooms":true,"place":"house","frames":3502,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":9.855773843517978,"p50_ms":8.877,"p90_ms":14.0,"p99_ms":26.416,"max_ms":45.112},"raster":{"mean_ms":12.347453455168493,"p50_ms":12.453,"p90_ms":14.734,"p99_ms":17.602,"max_ms":21.984},"over_16_67ms":265,"over_8_33ms":3430}
{"switch_rooms":false,"place":"lane","frames":4058,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.149174963035977,"p50_ms":6.407,"p90_ms":8.152,"p99_ms":19.786,"max_ms":38.107},"raster":{"mean_ms":12.95331665845247,"p50_ms":13.459,"p90_ms":14.374,"p99_ms":15.763,"max_ms":18.986},"over_16_67ms":147,"over_8_33ms":4058}
```

## Pemulihan dan pengujian manual

Versi release biasa dengan optimasi dipasang kembali setelah tes ulang. Potret layar sesudah pemulihan menunjukkan progres asli tetap ada: 80 koin, 9/60 bintang, kamar awal Oyen dan mangkuk. Data kamar penuh tidak ditulis ke penyimpanan pemain. Pengaturan layar tetap menyala saat USB tersambung sudah dikembalikan ke nilai awal 0; proses aplikasi release berjalan dan buffer crash kosong saat diperiksa.

Pemilik repo melaporkan pengujian manual debug dan release berjalan baik untuk gameplay, suara, iklan Tambah Koin dan hadiahnya; ikon dan splash juga dinilai baik. Ini laporan manual, bukan pengukuran latensi audio. TalkBack dilewati atas permintaan pemilik repo. Formulir UMP, iklan petunjuk, ikon tema, dan splash Android versi lama belum diverifikasi secara terpisah.
