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

## Kinerja rumah penuh (langkah 39, 24 Nov 2026)

HP sama (Xiaomi 24117RN76O, Android 16), data `tool/profile_room.dart` yang sama (9 kucing beraksesoris, 20 barang toko + mangkuk). APK profil dipasang dengan `adb install -r`; "tetap menyala saat USB" sementara 0 → `usb` → 0. `tool/profile_room.dart` sekarang juga menghitung bingkai lambat karena build (`build_over_16_67ms`) dan karena raster (`raster_over_16_67ms`) secara terpisah.

**Probe sementara** (sakelar `--dart-define=PROBE=…` di penggambar, tidak di-commit), satu run per baris, bingkai di atas 16,67 ms per 60 detik:

| Varian | Bingkai | Build rata-rata (ms) | Raster rata-rata (ms) | Lambat (build / raster) |
| --- | --- | --- | --- | --- |
| Normal (2 run) | 3.479 / 3.484 | 9,48 / 9,45 | 11,78 / 11,75 | 168 (152 / 19) · 164 (159 / 9) |
| Tanpa lapisan rumah | 3.938 | 7,98 | 10,45 | 99 (68 / 32) |
| Tanpa bayangan | 3.472 | 9,80 | 11,57 | 178 (168 / 13) |
| Tanpa kucing | 3.804 | 8,25 | 11,61 | 97 (88 / 15) |
| Tanpa barang | 4.131 | 7,57 | 11,64 | 122 (105 / 19) |
| Lapisan rumah dan kucing diam | 3.831 | 8,07 | 13,08 | 86 (50 / 37) |
| Normal, pindah ruangan | 3.705 | 8,85 | 12,63 | 185 (176 / 13) |

Kesimpulan: bingkai lambat hampir semuanya karena build (sisi Dart), bukan raster. Penyumbang terbesar lapisan rumah yang bergerak: seluruh latar disusun ulang tiap bingkai, padahal yang bergerak hanya awan, daun, dan cahaya berdenyut. Barang beranimasi juga masih memakai `SvgTemplate.render` (urai template) tiap bingkai. Bayangan blur tidak berpengaruh.

**Perbaikan:**

- `SvgTemplate.bind(vals, record: true)`: rangkaian elemen yang tidak beranimasi (dirinya, induknya, dan anaknya) direkam sekali sebagai `Picture` di koordinat akhirnya; hanya bagian yang bergerak disusun tiap bingkai. Dipakai lapisan rumah dan gang. Di dalam `<g opacity>` atau `clip-path`, dan di bawah induk yang bergerak, bentuk tetap digambar langsung (rekaman di sana menggeser warna 1 tingkat dari render acuan). Sprite kucing tidak memakainya: rekaman kucing yang sudah pernah digambar bisa beda 1 tingkat warna dari render acuan (test piksel).
- Barang beranimasi memakai varian `bind` per isi mangkuk, seperti kucing.

**Sesudah** (kode akhir tanpa probe):

| Run | Bingkai | Build rata-rata / P90 (ms) | Raster rata-rata / P90 (ms) | Lambat (build / raster) |
| --- | --- | --- | --- | --- |
| Diam 1 | 3.716 | 8,04 / 9,38 | 12,94 / 14,48 | 97 = 2,6% (71 / 27) |
| Diam 2 | 3.472 | 9,38 / 11,09 | 15,20 / 16,71 | 471 = 13,6% (131 / 367), HP panas sesudah ±45 menit diukur sambil dicas |
| Diam 3 (sesudah didinginkan 6 menit, baterai 33,6 °C) | 3.814 | 7,74 / 8,99 | 12,86 / 14,49 | 81 = 2,1% (61 / 24) |
| Pindah ruangan 1 | 3.834 | 7,20 / 9,72 | 13,32 / 14,72 | 108 = 2,8% (63 / 51) |
| Pindah ruangan 2 | 3.830 | 7,22 / 9,83 | 13,33 / 14,74 | 100 = 2,6% (64 / 42) |
| Gang | 4.281 | 5,42 / 6,42 | 13,59 / 14,37 | 45 = 1,1% (23 / 23) |

Run lebih awal dengan perbaikan yang sama tetapi sakelar ukur masih terpasang (tidak aktif), bingkai lambat: diam 92 (2,4%) dan 167 (4,5%, raster 93), pindah ruangan 87 (2,2%) dan 91 (2,4%).

**Batas:** di bawah ≲3% saat diam dan pindah ruangan, kecuali run yang HP-nya panas. Raster rata-rata naik ±1,3 ms dibanding sebelum perbaikan; kenaikan yang sama muncul di probe "diam" tanpa rekaman, jadi kemungkinan karena bingkai dibuat lebih cepat, bukan karena `drawPicture`. Sisanya raster ±13 ms per bingkai (seluruh layar digambar ulang tiap bingkai; Impeller tidak punya cache raster) dan lonjakan build P99 ±18 ms.

```json
{"probe":"","switch_rooms":false,"place":"house","frames":3479,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":9.477787007760842,"p50_ms":8.813,"p90_ms":10.665,"p99_ms":21.568,"max_ms":37.688},"raster":{"mean_ms":11.78224978442084,"p50_ms":11.571,"p90_ms":13.604,"p99_ms":16.17,"max_ms":30.369},"over_16_67ms":168,"build_over_16_67ms":152,"raster_over_16_67ms":19,"over_8_33ms":3479}
{"probe":"nohouse","switch_rooms":false,"place":"house","frames":3938,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.983416962925326,"p50_ms":7.352,"p90_ms":9.576,"p99_ms":20.529,"max_ms":31.398},"raster":{"mean_ms":10.450573895378387,"p50_ms":10.013,"p90_ms":12.786,"p99_ms":16.531,"max_ms":26.833},"over_16_67ms":99,"build_over_16_67ms":68,"raster_over_16_67ms":32,"over_8_33ms":3758}
{"probe":"noshadow","switch_rooms":false,"place":"house","frames":3472,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":9.801340725806444,"p50_ms":9.097,"p90_ms":10.952,"p99_ms":21.652,"max_ms":37.022},"raster":{"mean_ms":11.574465437788025,"p50_ms":11.391,"p90_ms":13.185,"p99_ms":15.578,"max_ms":24.325},"over_16_67ms":178,"build_over_16_67ms":168,"raster_over_16_67ms":13,"over_8_33ms":3472}
{"probe":"nokitty","switch_rooms":false,"place":"house","frames":3804,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.245946372239755,"p50_ms":7.573,"p90_ms":9.487,"p99_ms":19.664,"max_ms":36.867},"raster":{"mean_ms":11.612433491062076,"p50_ms":11.457,"p90_ms":13.834,"p99_ms":15.288,"max_ms":22.55},"over_16_67ms":97,"build_over_16_67ms":88,"raster_over_16_67ms":15,"over_8_33ms":3774}
{"probe":"noitem","switch_rooms":false,"place":"house","frames":4131,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.572454611474224,"p50_ms":6.951,"p90_ms":8.774,"p99_ms":19.737,"max_ms":44.459},"raster":{"mean_ms":11.644395545872694,"p50_ms":12.529,"p90_ms":13.493,"p99_ms":14.943,"max_ms":25.573},"over_16_67ms":122,"build_over_16_67ms":105,"raster_over_16_67ms":19,"over_8_33ms":3894}
{"probe":"stillhouse,stillkitty","switch_rooms":false,"place":"house","frames":3831,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.070439832941807,"p50_ms":7.499,"p90_ms":9.866,"p99_ms":18.031,"max_ms":27.16},"raster":{"mean_ms":13.076827460193108,"p50_ms":13.365,"p90_ms":14.723,"p99_ms":16.501,"max_ms":30.481},"over_16_67ms":86,"build_over_16_67ms":50,"raster_over_16_67ms":37,"over_8_33ms":3831}
{"probe":"","switch_rooms":false,"place":"house","frames":3484,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":9.452847014925378,"p50_ms":8.789,"p90_ms":10.541,"p99_ms":21.944,"max_ms":36.361},"raster":{"mean_ms":11.750208955223869,"p50_ms":11.559,"p90_ms":13.518,"p99_ms":15.623,"max_ms":20.213},"over_16_67ms":164,"build_over_16_67ms":159,"raster_over_16_67ms":9,"over_8_33ms":3484}
{"probe":"","switch_rooms":true,"place":"house","frames":3705,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.85213603238867,"p50_ms":8.061,"p90_ms":11.991,"p99_ms":23.441,"max_ms":43.531},"raster":{"mean_ms":12.6315120107962,"p50_ms":12.978,"p90_ms":14.621,"p99_ms":15.938,"max_ms":26.06},"over_16_67ms":185,"build_over_16_67ms":176,"raster_over_16_67ms":13,"over_8_33ms":3674}
{"switch_rooms":false,"place":"house","frames":3716,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":8.041252691065656,"p50_ms":7.458,"p90_ms":9.382,"p99_ms":19.101,"max_ms":41.453},"raster":{"mean_ms":12.936931377825621,"p50_ms":12.851,"p90_ms":14.477,"p99_ms":16.34,"max_ms":23.902},"over_16_67ms":97,"build_over_16_67ms":71,"raster_over_16_67ms":27,"over_8_33ms":3716}
{"switch_rooms":true,"place":"house","frames":3834,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.195794470526875,"p50_ms":6.937,"p90_ms":9.724,"p99_ms":18.426,"max_ms":33.714},"raster":{"mean_ms":13.323632759520072,"p50_ms":13.813,"p90_ms":14.716,"p99_ms":16.882,"max_ms":24.567},"over_16_67ms":108,"build_over_16_67ms":63,"raster_over_16_67ms":51,"over_8_33ms":3834}
{"switch_rooms":false,"place":"house","frames":3472,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":9.378721774193576,"p50_ms":8.706,"p90_ms":11.094,"p99_ms":20.665,"max_ms":39.207},"raster":{"mean_ms":15.202633640552992,"p50_ms":15.128,"p90_ms":16.71,"p99_ms":19.447,"max_ms":29.545},"over_16_67ms":471,"build_over_16_67ms":131,"raster_over_16_67ms":367,"over_8_33ms":3472}
{"switch_rooms":true,"place":"house","frames":3830,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.217926370757184,"p50_ms":6.919,"p90_ms":9.829,"p99_ms":18.592,"max_ms":36.015},"raster":{"mean_ms":13.333026892950409,"p50_ms":13.767,"p90_ms":14.741,"p99_ms":16.787,"max_ms":28.499},"over_16_67ms":100,"build_over_16_67ms":64,"raster_over_16_67ms":42,"over_8_33ms":3830}
{"switch_rooms":false,"place":"lane","frames":4281,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":5.420305769679979,"p50_ms":4.801,"p90_ms":6.424,"p99_ms":14.656,"max_ms":32.695},"raster":{"mean_ms":13.594898855407623,"p50_ms":13.61,"p90_ms":14.373,"p99_ms":16.025,"max_ms":21.971},"over_16_67ms":45,"build_over_16_67ms":23,"raster_over_16_67ms":23,"over_8_33ms":4281}
{"switch_rooms":false,"place":"house","frames":3814,"seconds":60,"cats":9,"items_including_bowl":21,"build":{"mean_ms":7.73908730991086,"p50_ms":7.104,"p90_ms":8.989,"p99_ms":18.283,"max_ms":33.308},"raster":{"mean_ms":12.856357105401118,"p50_ms":12.862,"p90_ms":14.487,"p99_ms":16.112,"max_ms":23.358},"over_16_67ms":81,"build_over_16_67ms":61,"raster_over_16_67ms":24,"over_8_33ms":3814}
```
