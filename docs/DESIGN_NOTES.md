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
