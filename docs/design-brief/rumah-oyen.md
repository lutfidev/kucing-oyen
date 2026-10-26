# Brief Claude Design: Rumah Oyen (halaman 19–24)

Brief ini dipakai untuk menambah layar baru ke proyek Claude Design "Kucing Oren" yang sudah ada, yaitu proyek yang menghasilkan halaman 01–18 di `docs/design/source/`. Isi aturannya ada di `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md`.

## Cara memakai

1. Buka proyek Claude Design yang sama, supaya token warna, tipografi, komponen tombol/kartu/chip, dan sprite Oyen ikut terpakai.
2. Salin seluruh blok di bawah, lalu tempel sebagai pesan baru.
3. Periksa hasilnya per halaman, terutama halaman 19 (Kamar) dan 21 (sprite kucing). Minta revisi di proyek yang sama kalau perlu.
4. Ekspor seperti dulu, lalu bongkar ke `docs/design/source/` supaya halaman 19–24 dan komponen `*.dc.html` barunya ada di samping yang lama. Jangan timpa halaman 01–18 kecuali memang ingin mengubahnya; kalau halaman lama ikut berubah, beri tahu di sesi langkah berikutnya.
5. Langkah 21–26 di `docs/ROADMAP.md` baru bisa dikerjakan sesudah ekspor ini ada.

```markdown
Tambahkan enam halaman baru (19–24) ke desain game "Ginger Logic" ini. Pakai design token, komponen, gaya vektor, dan sprite Oyen yang SUDAH ADA (halaman 13, 14, 16). Jangan mengubah halaman 01–18. Semua teks Bahasa Indonesia, santai dan jenaka. Layar mobile portrait 390x844, tapi tata letak harus tetap muat di 360x640 (tulis catatan apa yang mengecil).

## Konsep baru
Beranda berubah jadi KAMAR OYEN, seperti Talking Tom / Neko Atsume. Oyen dan kucing-kucing lain tinggal di sana, berjalan sendiri ke barang lalu memakainya (tidur di kasur, main bola benang, menggaruk tiang). Pemain bisa mengetuk/mengelus kucing, memberi makan, mengambil hadiah koin, dan menghias kamar dengan barang yang dibeli pakai koin dari puzzle dan iklan berhadiah. Puzzle tetap sama; tombol "Main" di kamar membawa ke peta babak. Nada santai: tidak ada hukuman, kucing yang lama tidak dirawat cuma lesu.

## Aturan gambar (penting untuk implementasi)
- Semua sprite, barang, dan ilustrasi berupa <svg> vektor terpisah dengan viewBox tetap (seperti sprite Oyen di halaman 14), bukan bitmap, bukan satu gambar besar yang menyatu.
- Kucing baru memakai BENTUK yang sama dengan Oyen (siluet, proporsi, pose), hanya warna bulu dan corak yang beda. Kalau bisa, buat warna sebagai variabel/prop komponen (seperti prop costume di Oyen.dc.html).
- Kamar dilihat dari depan agak atas (bukan top-down seperti papan puzzle): dinding di atas, lantai di bawah, supaya barang dinding dan barang lantai jelas bedanya.
- Pakai palet yang ada; tambah token baru hanya kalau perlu dan tampilkan di halaman 24.

## Halaman 19 – Kamar Oyen (Beranda baru)
Tunjukkan dalam beberapa keadaan, berdampingan:
a. Normal: kamar berisi Oyen (berkostum Peci, contoh) dan dua kucing koleksi, plus 5–6 barang yang sudah dibeli. Di atas: chip koin (dengan "+" dan titik merah bonus seperti Beranda lama) dan total bintang. Logo "Ginger Logic" kecil. Di bawah: tombol besar "Main", lalu tiga tombol "Toko", "Lemari Kostum", "Pengaturan". Mangkuk makan kering di lantai (penuh).
b. Kartu kucing terbuka (kucing diketuk): kartu kecil berisi nama kucing, bar "Lapar" dan "Senang" (0–100), tombol "Beri camilan" (pilih dari stok: Ikan Asin ×3, Susu ×1, Tuna Kaleng ×0 nonaktif) dan "Elus". Tutup dengan X.
c. Hadiah: gelembung koin "+10" di atas kucing yang senang, dan tanda lesu kecil di atas kucing lain yang lapar (pose lesu). Mangkuk kosong dengan label kecil "Terisi lagi 2 jam".
d. Mode hias: tombol "Hias" ditekan; barang punya garis putus-putus/tanda bisa diseret, satu barang sedang diangkat jari dengan bayangan, area lantai dan area dinding terlihat batasnya, baki "Gudang" di bawah berisi barang yang dimiliki tapi belum ditaruh, tombol "Selesai". Kucing diam.
e. Kamar baru (pemain baru): hanya Oyen tidur dan mangkuk, kamar kosong yang tetap hangat dan menarik, dengan ajakan kecil ke Toko.

## Halaman 20 – Toko
Bar atas: kembali, judul "Toko", chip koin (dengan "+"). Tab: "Barang", "Kucing", "Makanan".
- Tab Barang: grid kartu barang (gambar, nama, harga koin). Keadaan kartu: bisa dibeli, "Punyamu", koin kurang (harga redup).
- Tab Kucing: kartu besar per kucing dengan sprite duduk, nama, harga. Keadaan: bisa dibeli, "Tinggal di kamar" (sudah dimiliki), koin kurang.
- Tab Makanan: kartu camilan dengan "Stok: 3" dan tombol beli berulang.
- Sheet konfirmasi beli: gambar besar, nama, deskripsi lucu satu baris, tombol "Beli · 300 koin" dan "Nanti dulu". Sesudah beli: keadaan sukses dengan tombol "Lihat di kamar".
- Satu contoh "Koin kurang · 120" di tombol konfirmasi.

## Halaman 21 – Sprite kucing koleksi + pose kamar Oyen
Empat kucing baru (nama boleh diusulkan ulang):
- Arang: hitam polos, mata kuning
- Mendung: abu-abu dengan belang lebih gelap
- Telon: belang tiga (putih, oranye, hitam)
- Salju: putih bersih, ujung telinga merah muda
Pose untuk setiap kucing (dan pose kamar yang BELUM ADA untuk Oyen): duduk diam, menjilat kaki, jalan ke samping (2 bingkai), tidur melingkar, makan dari mangkuk, main (menepuk bola), menggaruk tiang, senang (mata ^^), lesu (rebahan, telinga turun), dielus (mata terpejam, "purr"). Tampilkan dalam grid: baris = kucing, kolom = pose. Oyen memakai pose yang sudah ada kalau cocok (idle, sleep, happy, eat).

## Halaman 22 – Barang kamar dan makanan
Setiap barang dalam dua keadaan: diam, dan sedang dipakai kucing (contoh: Oyen tidur di kasur).
Barang lantai: Kardus Nyaman, Bola Benang, Tikus Mainan, Karpet Bulat, Kasur Bantal, Pot Catnip, Tiang Garukan, Akuarium (ikan bergerak kecil), Rumah Kucing.
Barang dinding: Lukisan Ikan, Jam Kucing, Rak Dinding (kucing bisa duduk di atasnya).
Mangkuk makan kering: penuh dan kosong.
Camilan: Ikan Asin, Susu (mangkuk kecil), Tuna Kaleng (kaleng tanpa merek).
Tunjukkan juga ukuran relatif semua barang terhadap Oyen.

## Halaman 23 – Peta bergambar
Ganti peta "bulatan angka" di halaman 02 dengan peta bergambar, untuk dua babak:
- Babak 1 – Dapur (level 1–10, bos "Pesta Ikan Asin").
- Babak 2 – Ruang Tamu (level 11–20, bos "Hari Lebaran").
Peta berupa ilustrasi ruangan (lantai, perabot, karpet) yang dilihat agak dari atas, dengan jalan/jejak kaki berkelok. Setiap level adalah titik bergambar benda di ruangan itu (misalnya kulkas, kompor, rak piring, tudung saji untuk dapur; sofa, meja tamu, rak TV, pot bunga untuk ruang tamu), nomor level tetap terbaca. Keadaan: selesai (0–3 bintang), saat ini (berdenyut, label "Main"), terkunci (pudar + gembok). Bos tetap paling besar di ujung.
Token Oyen (sprite kecil, ikut kostum) berdiri di level saat ini. Tunjukkan juga satu bingkai "Oyen sedang berjalan" di jalan antara level 12 dan 13 (sesudah menekan "Lanjut"), dan satu bingkai pindah babak (judul "Babak 2 – Ruang Tamu" muncul). Bar atas tetap: kembali, "BABAK 2", nama babak, chip bintang, kartu babak lain.

## Halaman 24 – Komponen dan token baru
Komponen terpisah (*.dc.html) untuk: bar kebutuhan (Lapar/Senang, termasuk hampir habis), gelembung koin hadiah, tanda lesu, kartu toko (semua keadaan), tab toko, sheet konfirmasi, tombol "Hias"/"Selesai", baki Gudang, token Oyen peta, titik level bergambar. Tampilkan token warna/ukuran baru kalau ada.

## Alur prototipe
Kamar → Toko → beli kucing → "Lihat di kamar" → kucing baru di kamar.
Kamar → ketuk kucing → kartu kucing → beri camilan.
Kamar → Hias → seret barang → Selesai.
Kamar → Main → Peta Babak 2 → level 13 → (Berhasil) Lanjut → Oyen berjalan ke 14.
```
