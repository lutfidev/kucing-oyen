# Tinjauan paket aset langkah 2 — 8 November 2026

Paket implementasi tersedia untuk tinjauan pemilik repo melalui PR dan `/galeri/aset-v2`. Ini render vector runtime asli, bukan mockup AI atau screenshot rumah v2 yang sudah terintegrasi. Runtime pemain masih v1; integrasi bertahap mengikuti langkah 3–14.

Catatan 9 November 2026: proporsi pipi/badan karakter dan tiga lapisan Santai
dirapikan pada langkah 5 atas permintaan pemilik repo. Render di dokumen ini
adalah baseline langkah 2; [screenshot rumah terbaru](../home/REVIEW.md)
menunjukkan bentuk yang sekarang. Inventaris, ID, jangkar dan lisensi tetap.

## Bahan visual

- [Sembilan karakter: potret, duduk, belakang](characters.png).
- [17 pose × empat arah, Oyen dengan pita](motions.png).
- [16 aksesoris × sembilan karakter](accessories.png).
- [21 barang katalog](furniture.png).
- [Empat komposisi area berlapis](areas.png).

Galeri memilih seluruh kombinasi kucing, pose, arah dan aksesoris, memutar/jeda animasi dan menggeser fase. Gerak berhenti saat aplikasi di latar, `TickerMode` mati, atau kurangi gerak aktif. Semua potret menampilkan telinga utuh. Berkas SVG/manifest/pipeline/provenance berada di `assets/art/v2/README.md`.

## Keputusan dan pemeriksaan visual

Vector orisinal dipilih setelah render kode dibandingkan dengan konsep A: palet hangat, kepala dominan/pipi bulat, outline cokelat, jendela bertirai, kayu madu dan furnitur membulat dipertahankan. Permukaan sengaja lebih rata, tanpa tekstur grain/brush raster. Konsep A tetap arahan seni; bukan klaim duplikasi lukisan. Seluruh lima lembar di atas diperiksa langsung.

Bos mempertahankan tuxedo/blaze putih dan ujung ekor putih. Kembang tortoiseshell gelap dan Telon tiga warna memiliki bercak depan/belakang. Salju tidak diberi stripe tabby. Harga/ID katalog tidak berubah. Makan memiliki satu mangkuk dalam komposisi area; Rawat handuk/alas/sikat tanpa bak mandi.

Koreksi hasil pemeriksaan: badan tidur dan ujung syal sempat keluar canvas; karpet area sempat terpotong; mangkuk pose+scene sempat tergambar dua kali. Semuanya diperbaiki. Review independen menemukan slider pada fase 0,7995 detik dapat assert, kacamata tidak sejajar pada profil, ornament depan terlihat dari belakang, ekspresi samping kehilangan arah, pola belakang generik dan manifest parsial lolos loading. Perbaikan mencakup batas slider 0,8, proyeksi kacamata, empat varian aksesori belakang, kepala ekspresi×arah, corak belakang per identitas, dan validasi inventaris/jangkar di batas loading. Minor terakhir: ikan pengejaran dipindah ke depan hidung, mengikuti mirror kanan.

Tidak ada temuan Critical/Important tersisa pada review ulang. Pemeriksaan bentuk/kemiripan oleh pemilik repo tetap tersedia melalui PR; tidak mengklaim persetujuan pemilik repo atas lembar produksi sebelum ditinjau.

## Ukuran dan memori

209 bagian statis. Generator deterministik melaporkan **257.566 byte** sumber termasuk manifest, **100.195 byte** ZIP mandiri. Beda dengan kompresi APK karena setiap format archive memiliki aturan sendiri. Tidak ada atlas; SVG memiliki transparansi; tidak ada sumber bitmap yang perlu decode/preload ke texture. Ukuran native canvas: 128² kucing/barang, 100×80 aksesoris, 390² ruangan.

Build debug Android berhasil. Pengukuran entry APK (manifest + lisensi + 209 SVG): **258.085 byte** tanpa kompresi, **78.585 byte** terkompresi. APK debug universal keseluruhan sekitar 220 MB; angka ini mencakup engine/dependensi/debug multi-ABI dan bukan ukuran rilis. Ini kontribusi entry aset yang benar-benar dibundel, bukan perbandingan ukuran total APK terhadap v1. Jalankan `python tool/art_v2/measure_apk.py build/app/outputs/flutter-apk/app-debug.apk` untuk membaca hasil build lokal.

[`measurements.json`](measurements.json) berasal dari proses `flutter_test` Windows yang hanya menjalankan stress test (`--plain-name "stress all" --dart-define=ART_MEASURE=true`): RSS sebelum muat 138.723.328, sesudah muat 148.185.088, sesudah 9.792 komposisi 159.055.872 byte. Selisih muat sekitar 9,02 MiB, selisih total sekitar 19,39 MiB; RSS termasuk engine/VM/allocator dan alokasi temporer, bukan pengukuran eksklusif aset. Waktu recording rata-rata sekitar 41,8 µs/kucing, Picture rata-rata 2.238 byte. Tidak mencakup GPU/raster/komposisi frame perangkat. Map tetap 209 bagian dengan identitas objek sama setelah semua kombinasi; tidak ada cache varian/frame yang tumbuh bersama waktu.

Anggaran tambahan aset ≤20 MB terpenuhi. Bitmap sumber aktif 0 byte; ini tidak berarti Canvas/engine memakai 0 memori. Profil frame build/raster p95, cache transisi rumah sebenarnya dan target 60fps pada HP tetap langkah 13. HP Android tidak terhubung sesi ini (`flutter devices`: hanya Chrome/Edge); tidak mengklaim pengujian HP atau kelulusan performa runtime rumah baru.

## Verifikasi

Test baru memuat seluruh inventaris nyata, menolak manifest parsial/jangkar tidak sah, memeriksa arah semua pose, proyeksi kacamata dan mirror, delapan fase jalan, anchor ekstrem, tepi transparan seluruh sembilan kucing×16 aksesoris×empat arah pada tidur/jalan/kaget, dan 9.792 kombinasi tanpa memperbesar map. Test galeri mencakup loading/gagal/retry, fase mendekati batas siklus, pemilihan kucing, jeda, kurangi gerak, background/resume dan TickerMode. Galeri ditambah ke matriks overflow 360×640–412×915, teks 100%/130%.

Hasil akhir: format 238 berkas bersih; `flutter analyze` tanpa issue; review terjemahan sesuai; **2.812 test lulus, 135 dilewati** (ekspor screenshot/merek/lembar aset yang memang opt-in); generator `--check` sesuai; `flutter build apk --debug` berhasil. Setelah koreksi posisi ikan empat arah, 10 test aset/galeri dengan ekspor render juga lulus; stress terisolasi lulus. Tidak ada perubahan aturan simulator, solver, transaksi, progres atau simpanan.
