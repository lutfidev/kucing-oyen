# Rumah Oyen dua ruangan: ruang tengah + teras (gaya A, berperspektif)

Disepakati pemilik repo pada 21 Nov 2026. Menggantikan arah "satu area per layar" di langkah 33 roadmap dan seluruh rumah v2 (diarsipkan di `archive/v2-desain-kartun`). Brief untuk Claude Design ada di `docs/design-brief/rumah-dua-ruangan.md`.

## Maksud

Pemilik repo ingin rumah Oyen terasa seperti rumah sungguhan, bukan satu kamar datar dan bukan "ganti tombol" seperti v2. Saat pemain pindah ruangan, rasanya harus seperti berjalan lewat pintu ke tempat lain. Yang paling penting adalah kucing-kucingnya: mereka menyebar sendiri ke tempat nyaman, misalnya tidur di karpet, duduk di ambang pintu, atau berjemur di teras, sehingga rumah terasa hidup kalau didiamkan.

Arah ini dipilih dari tiga gambar konsep di kanvas https://claude.ai/artifact/FSsNaJV2xQDsmvZuw2CcGa: A ruang berperspektif, B rumah boneka, dan C isometrik. Prototipe datar sebelumnya (branch `spike/teras`) dinilai jelek dan tidak terasa nyata. Dari prototipe itu hanya logika tempat nyaman dan penyebaran yang dipakai lagi, gambarnya tidak.

## Tujuan

- Dua ruangan berperspektif, ruang tengah dan teras, yang terhubung lewat satu pintu terbuka.
- Pindah ruangan memperlihatkan arah perjalanan, dan kedua ruangan terasa nyambung.
- Kucing hidup sendiri: menyebar ke tempat nyaman yang kosong, sesekali berkumpul, dan berjalan sendiri antar-ruangan.
- Pemain bisa mengajak kucing pindah ruangan. Kucing betah di sana sebentar, lalu bebas lagi.
- Gestur di HP jelas dan tidak saling mengganggu.

## Bukan tujuan

- CCTV. Ditunda sampai ada ruangan ketiga; nanti bentuknya monitor dinding yang dibeli di Toko, bukan menu.
- Ruangan ketiga dan seterusnya, barang khusus teras, atau perubahan katalog Toko.
- Kebutuhan baru. Bar Lapar/Senang, mangkuk, hadiah koin, camilan, elus, dan aksesoris tetap seperti v1.
- Perubahan puzzle, peta, atau layar lain.

## Yang tidak boleh terjadi (anti-tujuan)

- Pindah ruangan lewat tombol menu atau tab. Itu kesalahan v2.
- Dinding, lantai, atau pintu yang digambar sendiri di kode tanpa desain. Itu kesalahan prototipe teras.
- Kucing berpindah ruangan secara tiba-tiba tanpa terlihat berjalan lewat pintu (kecuali saat kurangi gerak).
- Barang hiasan menutup jalur pintu sehingga kucing tidak bisa lewat.
- Gestur geser ruangan yang merebut seretan kucing atau seretan barang.

## Pendekatan yang dipertimbangkan

1. **A · Ruang berperspektif (dipilih).** Satu ruangan per layar dengan dinding samping miring dan lantai yang menyempit ke belakang. Pintu ada di dinding samping. Rasa masuk ruangan paling kuat, dan semua sprite kucing dan barang v1 yang dilihat dari depan tetap cocok.
2. **B · Rumah boneka.** Seluruh rumah dibelah depannya dan digeser seperti satu lembar panjang. Paling dekat dengan prototipe, tapi pindah ruangan terasa seperti menggeser kertas, bukan lewat pintu.
3. **C · Isometrik.** Paling "3D", tapi sprite v1 yang dilihat dari depan tampak janggal di lantai miring, jadi semua barang harus digambar ulang. Biayanya terlalu besar untuk manfaatnya.

## Yang sudah diputuskan pemilik repo

### Ruangan dan pintu

- Ruang tengah adalah ruangan awal saat aplikasi dibuka. Pintu ke teras ada di **dinding kanan**. Lewat pintu yang terbuka, pemain sudah melihat sedikit teras: langit, tanaman, lantai papan, dan cahaya.
- Di teras, pintu kembali ke ruang tengah ada di **dinding kiri** (dinding rumah). Lewat pintu itu terlihat sedikit isi ruang tengah yang hangat.
- Di atas layar ada penanda kecil nama ruangan sekarang (mis. "‹ Ruang tengah" di teras). Ini penanda, bukan menu.

### Pindah ruangan

- Ada dua cara: **ketuk pintu**, atau **geser layar dari area kosong** ke arah pintu. Di ruang tengah geser ke kiri menuju teras; di teras geser ke kanan menuju ruang tengah.
- Perpindahannya bergerak searah perjalanan. Ruang tengah bergeser keluar ke kiri, dan teras masuk dari kanan, seolah kamera berjalan lewat pintu. Kalau digeser, transisinya mengikuti jari, dan geseran pendek kembali ke ruangan semula.
- Kurangi gerak: pindah langsung tanpa animasi geser.

### Kucing di dua ruangan

- Setiap ruangan punya tempat nyaman tanpa barang. Ruang tengah: bawah jendela, tengah lantai, ambang pintu. Teras: petak matahari, dekat pagar, dekat pot, ambang pintu. Kucing juga tetap memakai barang seperti v1.
- Tempat yang dekat dengan kucing lain kurang menarik, jadi kucing menyebar. Kadang mereka tetap berkumpul (logika prototipe `LifePlace` dan `lifeCrowdFactor` dipakai lagi).
- Kucing bisa memilih sendiri untuk pindah ruangan. Ia berjalan ke ambang pintu, melewatinya, dan muncul di ambang pintu ruangan sebelah.
- **Pemain melihat kucing lewat ambang pintu.** Di ruangan asal, kucing berjalan masuk ke bukaan pintu dan menghilang di balik kusen. Kalau pemain menyusul, kucing itu ada di sisi pintu yang sesuai di ruangan tujuan: masuk dari dinding kiri teras, atau dari dinding kanan ruang tengah.

### Mengajak kucing pindah

- Ada dua cara: **tahan lalu seret kucing ke pintu**, atau tombol **"Ajak ke teras" / "Ajak ke ruang tengah"** di kartu kucing.
- Sesudah diajak, kucing berjalan lewat pintu ke ruangan tujuan.
- **Betah sebentar:** selama 5 menit (durasi awal untuk dites di HP) kucing tidak memilih pindah ruangan sendiri, tapi tetap bebas berjalan dan beraktivitas di ruangan tujuan, mis. ke petak matahari lalu rebahan. Sesudah itu kucing boleh memilih sendiri kapan lewat pintu lagi.
- Pemain boleh mengajaknya balik lebih awal kapan saja.
- Kalau aplikasi dibuka ulang, semua kucing langsung bebas: waktu betah tidak disimpan.

### Gestur

- **Ketuk kucing:** membuka kartu kucing (seperti v1).
- **Geser dari area kosong:** melihat ruangan sebelah.
- **Tahan lalu seret kucing:** mengajaknya pindah. Pintu menyala saat kucing diangkat; lepas di pintu = diajak, lepas di tempat lain = kucing kembali berjalan seperti biasa.
- **Mode Hias:** seret barang untuk mengatur posisinya di ruangan yang sedang dibuka. Seret barang selalu menang atas geser ruangan.
- **Jalur pintu harus tetap bisa dilewati.** Barang tidak bisa ditaruh di jalur pintu walaupun kedua ruangan dihias; saat menghias, jalurnya ditandai. Barang yang dilepas di sana bergeser ke tempat terdekat yang boleh.

### Hiasan dinding di teras (pilihan 1B)

- Teras punya **titik gantung di balok atap** untuk hammock dan lampu bulan.
- Jam, lukisan, rak, dan jendela burung hanya bisa dipasang di ruang tengah.
- Gudang yang dibuka dari teras meredupkan keempat barang itu. Kalau salah satunya diketuk, muncul keterangan "Bisa dipasang di ruang tengah".
- Hammock di teras tidak boleh mempersempit jalur Oyen ke pintu.

### Kucing di ruangan sebelah (pilihan 2A)

- Kalau ada kucing di ruangan sebelah yang perlu dicek, satu ikon kecil muncul di dekat pintu. Ini berlaku dari kedua arah: dari ruang tengah untuk kucing di teras, dan dari teras untuk kucing di ruang tengah.
- Hanya satu ikon yang tampil. Lapar didahulukan di atas hadiah koin. (Keputusan asisten: urutan lengkapnya lapar → sedih → hadiah koin.)
- Tombol "Lihat di kamar" sesudah membeli kucing langsung membuka ruangan tempat kucing baru itu berada.

### Tetap seperti v1

Kebutuhan kucing, mangkuk, hadiah koin, camilan, elus, aksesoris, Toko, header (koin, logo, bintang), dan panel bawah (Main, Toko, Aksesoris, Pengaturan).

## Keputusan asisten (boleh dikoreksi pemilik repo)

- **Hias** hanya bekerja di ruangan yang sedang dibuka. Semua barang lantai boleh ditaruh di ruangan mana pun; barang dinding mengikuti aturan di atas. Untuk memindahkan barang ke ruangan lain: simpan ke Gudang, pindah ruangan, lalu taruh dari Gudang. Barang tidak bisa diseret lewat pintu.
- **Mangkuk** tetap satu dan tetap di ruang tengah. Kucing lapar di teras berjalan ke ruang tengah untuk makan.
- **Barang yang sudah ditaruh** di kamar v1 menjadi barang ruang tengah. Simpanan lama tanpa keterangan ruangan dibaca sebagai ruang tengah.
- **Ruangan tempat tiap kucing berada** tidak disimpan. Saat aplikasi dibuka, Oyen ada di ruang tengah dan kucing lain dibagi ke kedua ruangan oleh rutinitas.
- **Kartu kucing** tetap bisa dibuka di ruangan mana pun. Tombol "Ajak ke …" ada di kartu itu, dengan teks baru di keempat bahasa.
- **Pembaca layar:** pintu adalah tombol "Pergi ke teras" / "Pergi ke ruang tengah", dan kucing punya aksi "Ajak ke teras" / "Ajak ke ruang tengah". Kucing yang pindah sendiri diumumkan singkat hanya kalau ia meninggalkan ruangan yang sedang dibuka.
- **Pemain baru** (hanya Oyen dan mangkuk): petunjuk kamar kosong v1 (`EmptyRoomHints`, gelembung ajakan ke Toko) hanya di ruang tengah; teras kosong cukup menampilkan tempat nyamannya. Oyen yang sendirian tetap boleh jalan sendiri ke teras, karena itu ajakan alami untuk menjelajah.
- **Sisa langkah 33** (gelembung ajakan Toko terlalu lebar, label mangkuk terlalu dekat dengan Oyen, kucing sedih kurang jelas butuh apa) digabung ke langkah rumah dua ruangan, karena tata letak ruangan memang digambar ulang.
- **Urutan kerja:** rencana dan kode baru dimulai sesudah link kanvas Claude Design diserahkan, termasuk model Dart murni, supaya model mengikuti angka desain (tempat nyaman, jalur pintu, zona dinding).
- **Kinerja:** hanya ruangan yang sedang dibuka yang menggambar kucing dan barang bergerak. Pemandangan lewat pintu adalah bagian gambar latar yang diam. Rutinitas tetap memajukan kucing di ruangan lain tanpa menggambarnya.

## Gambar yang dibutuhkan (lewat Claude Design)

Gambar dinding, lantai, pintu, cahaya, dan teras dibuat di Claude Design dengan gaya v1, lalu disalin persis, sama seperti kamar v1. Isi brief ada di `docs/design-brief/rumah-dua-ruangan.md`. Kode belum dimulai sebelum link kanvas desainnya diserahkan pemilik repo.

## Diserahkan ke pembuat rencana

- Model data ruangan di `lib/game/model/` (Dart murni): ruangan tiap barang, migrasi simpanan, dan rutinitas dua ruangan (`RoomLife` dengan tempat nyaman, ruangan per kucing, perjalanan lewat pintu, dan waktu betah).
- Geometri perspektif: posisi lantai (kiri–kanan, depan–belakang) ke layar, ukuran sprite menurut kedalaman, dan urutan gambar.
- Lapisan gambar: latar, kucing dan barang, kusen pintu di depan (supaya kucing hilang di balik kusen), dan cahaya.
- Pengenal gestur: geser ruangan, tahan-seret kucing, seret barang, dan prioritasnya.
- Test: model dan rutinitas (Dart murni, ber-seed), layar (gestur, transisi, kurangi gerak, pembaca layar), `overflow_test` dan potret layar di keempat bahasa, serta profil kinerja kamar di HP seperti langkah 32.
- Pembagian ke langkah roadmap baru sesudah langkah 32.
