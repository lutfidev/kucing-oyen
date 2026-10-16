# Catatan desain

Keputusan saat desain (`docs/design/source/`), GDD, data level, dan roadmap tidak cocok atau tidak mengatur sesuatu. Urut menurut langkah roadmap.

## Langkah 4: fondasi UI

- **ThemeExtension per grup.** Prompt roadmap meminta "semua token dalam satu ThemeExtension", tapi lembar token (`13-design-token-komponen-ui.html`) menulis "satu `ThemeExtension` per grup (KoColors, KoType, KoSpace, KoRadius, KoShadow)". Ikut desain: lima grup itu ada di `lib/theme/`, ditambah `KoSize` untuk ukuran komponen (tinggi tombol, ikon, chip, slot baki) yang tidak punya grup di lembar token. Semua dipasang di `KoTheme.light()` dan dibaca lewat `context.koColors`, `context.koType`, dan seterusnya.
- **Tombol 64 px: radius 20.** Contoh tombol utama dan sukses di lembar token memakai radius 22, padahal skala radius di lembar yang sama hanya 8, 14, 20, 24, 28, pill, dan layar hasil (06–09) memakai 20. Dipakai 20. Tombol utama besar ("Main" 76 px, "Bangunkan Oyen" 72 px) memakai 24.
- **Tombol sekunder: tinggi 64.** Contoh di lembar token 60 px; layar hasil memakai 62–64. Satu ukuran 64 untuk semua tombol biasa.
- **Sinar tombol utama besar.** "Main" memakai 0 16 28 dengan 28%, "Bangunkan Oyen" 25%. Keduanya jadi token (`glowStrong`, `glow`).
- **Token pendukung.** Lembar token hanya memuat 18 warna, skala jarak 4–32, dan enam radius. Nilai lain yang dipakai komponen di layar desain ikut jadi token: warna `lineDeep` (`#E2C79C`), `orangeLine`, `onSuccess`, `starEmpty`, `muted`, `locked`, `hint`/`hintLine`/`hintDeep`, `boardRing`, dan warna bayangan; jarak `s2`, `s6`, `s10`, `s14`; radius `slot` 16 dan `card` 20; tinggi bayangan padat 7/6/4/3 px; serta gaya teks `buttonHero`, `button`, `chip`, `numberSmall`, `badge`, `labelSmall`.
- **`woodDeep`.** Lembar token menulis "wood / woodDeep #B07A4F" tanpa hex kedua. Dipakai `#7E5233`, warna dasar tembok di `Tile.dc.html`.
- **Tombol nonaktif.** Lembar token tidak punya. Warna dari tombol aksi nonaktif di `12-lemari-kostum.html`: isi `#E6D6BC`, teks `#5E4A37`, bayangan `#CDB48C`. Tinggi bayangannya mengikuti ukuran tombol (desain 5 px, tombol aktif 6 px).
- **Efek tekan.** Desain hanya memberi nama "press" (0 6 0 orangeDeep) tanpa gaya `:active`. Saat ditekan, permukaan tombol turun setinggi bayangan padatnya dan bayangan itu hilang, tanpa animasi. Bayangan tidak memakan tempat di tata letak, sama seperti `box-shadow` CSS.
- **Slot baki sisa 0.** Desain hanya menunjukkan slot "sedang diseret, sisa 0" (garis putus-putus oranye, gambar pudar). Gaya itu dipakai untuk semua slot yang sisanya 0.
- **Garis putus-putus.** CSS `dashed` tidak menetapkan pola garis; dipakai garis 6 px, celah 4 px.
- **Font.** Fredoka (500, 600, 700) dan Nunito (600, 700, 800) dibundel di `assets/fonts/` beserta lisensi OFL-nya, dan dimuat oleh `test/flutter_test_config.dart` untuk semua test supaya ukuran teks di test sama dengan di perangkat.
- **Beranda sementara.** Rute `/` berisi judul, tagline dari desain Beranda, dan tombol ke galeri sampai Beranda asli dibuat di langkah 9.
- **Belum dibuat.** Node level (lembar token) menunggu peta babak di langkah 9. Gambar benda di slot baki galeri masih kotak pengganti sampai gambar petak dibuat di langkah 5.

## Langkah 5: gambar petak, papan, dan Oyen

- **SVG desain disalin utuh, bukan diketik ulang.** Isi `<svg>` `Tile.dc.html` dan `Oyen.dc.html` (termasuk blok `sc-if` dan `{{nama}}`) serta panah arah hadap di `Board.dc.html` ada di `lib/game/render/design_svg.dart`. `SvgTemplate` mengurai subset SVG yang dipakai (g, rect, circle, ellipse, path, text; fill, stroke, opacity, dasharray, transform) dan string `d` lewat `parseSvgPathData`. `renderVals()` di-port apa adanya ke `tileVals` dan `oyenVals`. `test/game/render/design_sync_test.dart` membandingkan salinan dengan file desain kalau `docs/design/` ada.
- **Warna gambar tetap hex dari SVG.** Warna petak dan Oyen adalah data gambar, sama seperti string path, jadi tidak dipindah ke `KoColors`. Bingkai papan (`KoShadow.board`) dan lingkaran panah arah hadap (`orange`, cincin `surface`) memakai token karena ditulis sebagai CSS, bukan SVG.
- **Gelas yang sudah jatuh** tidak punya gambar di desain: digambar sebagai `table` kosong. Simulasi tidak mengubah huruf peta saat barang jatuh (ia mencatat petak `knocked`), jadi langkah 7 yang mengganti gelas jatuh jadi `table` dan vas jatuh jadi `tableBroken`.
- **Pose menjatuhkan** dari desain selalu mengulurkan tangan ke kanan sprite (ke kiri kalau Oyen menghadap kanan, karena dicerminkan). Simulasi tidak memutar Oyen ke arah meja, jadi saat Oyen menghadap kiri ke vas tangannya menjauhi meja. Gambar mengikuti desain; arah pose `knock` diputuskan di langkah 7.
- **Kedip petak menyala.** Animasi `koGlow` (opasitas 1 → 0,45 → 1 tiap detik, `ease-in-out`) ada di `tileGlowOpacity`, dipakai mulai langkah 6. Galeri menggambarnya diam supaya `pumpAndSettle` selesai.
- **Belum di-port:** `path` dan `trail` di `Board.dc.html` (jejak putar ulang, langkah 10) dan transisi posisi Oyen 0,35 detik (langkah 7). `BoardOyen` sudah memakai kolom/baris pecahan untuk animasi itu.
- **Galeri.** Rute `/galeri/papan` (desain 15 dan 18) dan `/galeri/oyen` (desain 14). Kartu memakai `KoCard` (sudut 20, desain 18) dan kisi menyesuaikan lebar ponsel, bukan 4–7 kolom seperti halaman desain 960 px. Ukuran pratinjau (petak 160%, Oyen 104/88/92 px, kartu 150/132 px) ditulis sebagai konstanta halaman galeri, bukan token, karena bukan UI game. Contoh papan memakai peta bawaan `Board.dc.html` (= level 13) dengan isi seperti layar 03, 04, dan vas pecah, jadi galeri tidak perlu memuat aset level. Pemetaan level 18 diuji di unit test.
- **Gambar benda di slot baki** galeri masih kotak pengganti. Slot baki di `03-gameplay-fase-atur.html` memakai SVG sendiri (tanpa bayangan, ember tanpa cincin oranye), jadi dibuat bersama baki di langkah 6.
