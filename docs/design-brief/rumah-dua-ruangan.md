# Brief Claude Design: Rumah Oyen dua ruangan (ruang tengah + teras)

Untuk ditempel ke Claude Design. Keputusan lengkap ada di `docs/superpowers/specs/2026-11-21-rumah-dua-ruangan-design.md`.

## Konteks

Ginger Logic adalah game puzzle mobile. Beranda game adalah rumah Oyen, kucing oren, tempat kucing-kucing milik pemain hidup sendiri. Rumah yang sekarang (v1) hanya satu kamar datar yang dilihat lurus dari depan. Kita ingin dua ruangan yang terasa nyata dan nyambung: **ruang tengah** dan **teras**, dihubungkan satu pintu terbuka.

Acuan:
- **Gaya dan palet:** kanvas desain kamar v1 "Ginger Logic – Rumah Oyen (19–24)", https://claude.ai/code/artifact/d25a6575-3d34-4887-9de4-18435367bf86. Pakai warna, font (Fredoka, Nunito), header, panel bawah, dan sprite kucing/barang dari kanvas itu.
- **Arah sudut pandang (sketsa kasar, bukan gambar final):** kanvas konsep https://claude.ai/artifact/FSsNaJV2xQDsmvZuw2CcGa, artboard "A · Ruang berperspektif" (ruang tengah dan teras). Ambil sudut pandangnya, jangan gambarnya: dinding, lantai, dan cahaya di sana masih kasar.

## Sudut pandang

Satu ruangan per layar, **berperspektif satu titik hilang**: dinding belakang di tengah, dinding kiri dan kanan miring ke dalam, langit-langit di atas, lantai papan yang garisnya menyempit ke belakang. Ruangan harus terasa punya kedalaman tanpa menjadi isometrik. Kucing dan barang tetap sprite v1 yang dilihat dari depan, dan ukurannya mengecil di belakang (sekitar 0,75×) serta membesar di depan (sekitar 1,15×). Ada bayangan lembut di bawah kucing dan barang.

## Yang wajib sama dengan v1

- Ukuran layar 390×844. Area rumah dari tepi atas sampai y 652; di bawahnya panel bawah v1 (tombol Main, lalu Toko, Aksesoris, Pengaturan) tanpa perubahan.
- Header v1 di atas: chip koin, logo "Ginger Logic", chip bintang, tombol Hias.
- Sprite kucing dan barang v1 tidak digambar ulang. Gaya ruangan harus cocok dengan sprite itu: rata, hangat, garis lembut, tidak terlalu kartun.
- Tidak ada tulisan di dalam gambar ruangan.

## Artboard yang diminta

1. **Ruang tengah (390×844).** Pintu ke teras ada di **dinding kanan** dan terbuka. Lewat pintu, pemain melihat sedikit teras: langit, tanaman, lantai papan teras, dan cahaya matahari. Cahaya dari pintu jatuh miring ke lantai ruang tengah. Isi contoh: jendela dan lukisan di dinding belakang, kasur, karpet, tiang garukan, mangkuk; lima kucing menyebar (satu di ambang pintu, satu tidur di kasur, satu di cahaya pintu, satu di karpet, satu di depan).
2. **Teras (390×844).** Pintu kembali ke ruang tengah ada di **dinding kiri** (dinding rumah). Lewat pintu itu terlihat sedikit ruang tengah yang hangat. Atap teras kayu di atas, kebun dan pagar di belakang, pagar samping di kanan, petak matahari di lantai, pot tanaman. Isi contoh: satu kucing berjemur di petak matahari, satu di ambang pintu, satu dekat tanaman, dan **hammock yang tergantung di balok atap** (sprite hammock v1) dengan tali ke balok. Ukuran dan posisinya harus jelas, dan jalur dari ambang pintu ke tengah teras tetap lega. Tandai **titik gantung** di balok atap; hanya hammock dan lampu bulan yang boleh digantung di sana. Di atas, penanda kecil "‹ Ruang tengah".
3. **Pasangan pintu dari dua sisi (780×844, dua layar berdampingan).** Ruang tengah di kiri dan teras di kanan, dengan panah yang menunjukkan Oyen keluar lewat pintu kanan ruang tengah lalu masuk lewat pintu kiri teras. Tunjukkan bahwa ambang pintu di kedua layar adalah pintu yang sama dan posisinya cocok, termasuk tinggi lantai dan arah cahaya.
4. **Oyen melewati ambang (tiga bingkai kecil).** (a) Oyen berjalan ke ambang pintu di ruang tengah, (b) setengah badan tertutup kusen, (c) muncul di ambang pintu teras dan berjalan masuk. Kusen pintu harus digambar sebagai **lapisan depan terpisah** supaya kucing bisa hilang di baliknya.
5. **Transisi pindah ruangan (tiga bingkai kecil).** Ruang tengah bergeser keluar ke kiri, teras masuk dari kanan, seolah kamera berjalan lewat pintu. Header dan panel bawah tetap diam.
6. **Mengajak kucing.** (a) Kucing ditahan lalu diangkat (sedikit membesar, bayangan menjauh) dan pintu menyala sebagai tujuan. (b) Kartu kucing v1 dengan tombol baru "Ajak ke teras".
7. **Ikon perhatian di dekat pintu.** Satu ikon kecil di dekat pintu kalau ada kucing di ruangan sebelah yang perlu dicek: lapar, sedih, atau hadiah koin (hanya satu ikon; lapar paling didahulukan). Tunjukkan di kedua ruangan: di ruang tengah untuk kucing di teras, dan di teras untuk kucing di ruang tengah. Gunakan gaya tanda lesu dan gelembung koin v1.
8. **Mode Hias di ruang tengah.** Panduan zona v1 ditambah **jalur pintu** yang ditandai sebagai area yang tidak boleh ditempati barang, dari ambang pintu ke tengah lantai.
9. **Mode Hias di teras.** Jalur pintu ditandai, titik gantung di balok atap ditandai, dan baki Gudang v1 dengan jam, lukisan, rak, dan jendela burung yang diredupkan, ditambah keterangan "Bisa dipasang di ruang tengah" saat salah satunya diketuk.
10. **Rumah pemain baru.** Ruang tengah hanya berisi Oyen dan mangkuk, dengan petunjuk kamar kosong v1 (bidang kosong bergaris putus-putus dan gelembung ajakan ke Toko) yang ukurannya diperbaiki: gelembung tidak terlalu lebar dan tidak menutupi Oyen. Teras kosong hanya menampilkan tempat nyamannya.
11. **Catatan layar kecil 360×640:** apa yang mengecil, seperti catatan `n360` di kanvas v1.

## Agar bisa disalin ke game

- Gambar ruangan sebagai SVG di dalam `.dc.html`, dengan lapisan terpisah: **latar** (dinding, lantai, pemandangan lewat pintu), **kusen pintu depan**, dan **cahaya/bayangan**.
- Tuliskan koordinat penting di catatan artboard: sudut lantai (trapesium), titik hilang, bukaan pintu dan ambangnya, jalur pintu, dinding untuk barang dinding, dan **tempat nyaman** kucing (ruang tengah: bawah jendela, tengah lantai, ambang pintu; teras: petak matahari, dekat pagar, dekat pot, ambang pintu).
- Ukuran sprite menurut kedalaman: tuliskan skala di garis paling belakang dan paling depan lantai.
- Animasi kecil boleh (awan bergerak, daun bergoyang, cahaya berdenyut pelan) dalam CSS `@keyframes` seperti kamar v1.
