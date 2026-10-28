# Rumah Oyen: kamar, Toko, kucing koleksi, aksesoris, peta bergambar (langkah 21–26)

Dokumen ini dimulai dari brainstorming dengan pemilik repo pada 26 Oktober 2026, lalu diperbarui 28 Oktober 2026 sesudah desainnya jadi dan sesudah isi tambahan masuk ke desain (lihat "Isi tambahan 28 Oktober"). Pekerjaannya dipecah menjadi langkah 21–26 di `docs/ROADMAP.md` dan baru dikerjakan **sesudah langkah 18–20** [pemilik].

## Sumber desain

Pemilik repo membuat desainnya di Claude Design dengan brief `docs/design-brief/rumah-oyen.md` ditambah permintaan perubahan sendiri (lihat "Perubahan 28 Oktober").

- **Hasil desain**: kanvas "Ginger Logic – Rumah Oyen (19–24)", https://claude.ai/code/artifact/d25a6575-3d34-4887-9de4-18435367bf86.
- **Salinan di komputer pemilik repo**: `docs/design/rumah-oyen/project/`. Folder `docs/design/` tidak ikut repo (`.gitignore`).
- **Kalau folder itu tidak ada**: unduh ulang file `project/*` dari link kanvas memakai alat Artifact (aksi `read` dengan `paths` dan `out_dir` `docs/design/rumah-oyen`). Kalau link tidak bisa dibuka, beri tahu pemilik repo dan jangan menebak isi desainnya.

Setiap artboard adalah satu berkas `.dc.html` lengkap. `project/canvas.json` berisi daftar dan judulnya.

| Halaman | Berkas |
|---|---|
| 19 Kamar | `Kamar.dc.html` dengan prop `keadaan`, dipakai `KamarKartu`, `KamarHadiah`, `KamarHias`, `KamarBaru`, `KamarSalju`, `KamarAksesoris` |
| 20 Toko | `Toko.dc.html` dengan prop `tab`/`lembar`/`tahap`, dipakai `TokoKucing`, `TokoMakanan`, `TokoBeli`, `TokoKurang`, `TokoSukses`, `TokoAksesoris*` |
| 21 Sprite | `Kucing.dc.html` (komponen sprite: `kucing`, `pose`, `dir`, `aksesoris`, `animasi`, warna), `SpriteKucing.dc.html`, `AksesorisPreview.dc.html` (21b), `AnimasiKucing.dc.html` (21c, angka animasi), `IkonAksesoris.dc.html` |
| 22 Barang | `Barang.dc.html` (komponen barang: `item`, `dipakai`, `kucing`, `aksesoris`, `skala`), `BarangKamar.dc.html` |
| 23 Peta | `PetaBergambar.dc.html` (Babak 2), `PetaDapur.dc.html` (Babak 1), `PetaJalan.dc.html`, `PetaPindah.dc.html`, `TitikLevel.dc.html`, `TokenOyenPeta.dc.html` |
| 24 Komponen | `KomponenBaru.dc.html`, `BarKebutuhan`, `GelembungKoin`, `TandaLesu`, `ChipKoin`, `TabToko`, `KartuToko`, `SheetBeli`, `TombolHias`, `BakiGudang` |

Aturan pemakaian desain:

- Tata letak, ukuran, warna, teks, dan harga mengikuti desain. Untuk layar 360×640, catatan `n360` di `canvas.json` menyebut apa saja yang mengecil.
- Aturan yang tidak tampak di desain mengikuti dokumen ini: kebutuhan turun mengikuti jam, mangkuk, batas, dan simpanan.
- Interaksi di prototipe desain hanya peraga, misalnya "+50 koin iklan" di chip koin Kamar. Iklan tetap +20 koin sesuai langkah 14.
- Kalau desain dan dokumen ini bertentangan dalam aturan main, ikuti dokumen ini dan catat di `docs/DESIGN_NOTES.md`.

Penanda keputusan:

- **[pemilik]**: dipilih pemilik repo.
- **[desain]**: diambil dari desain.
- **[saya]**: keputusan saya. Pemilik repo boleh mengubahnya; builder mengikutinya kalau tidak ada perubahan.

## Maksud

Pemilik repo merasa UI sekarang hambar. Ada tiga keluhan:

- Masuk level dengan mengetuk bulatan angka.
- Rasa bolak-balik antara peta dan level.
- Koin yang tidak punya banyak tujuan.

Arah yang dipilih adalah **Talking Tom / Neko Atsume** [pemilik]. Kucingnya menjadi pusat perhatian, dan puzzle menjadi cara mendapat koin untuk merawat, mendandani, dan menghias rumahnya.

## Perubahan 28 Oktober (sesudah desain) [pemilik]

- **Peci, sarung, dan atribut religius dihapus** dari semua karakter dan sprite, supaya game inklusif. Oyen tampil default sebagai kucing oranye belang tanpa pakaian.
- **Lemari Kostum dihapus.** Di kamar, tombolnya diganti **Aksesoris**, yang membuka tab Aksesoris di Toko. Aksesoris juga bisa diganti dari kartu kucing.
- **Kostum lama dihapus tanpa migrasi** karena belum ada pemain asli. Simpanan `costume.owned` dan `costume.wearing` diabaikan, lalu dihapus saat dibaca. Koin yang dulu dipakai membeli kostum tidak dikembalikan.
  - **Kacamata** lama diganti **Kacamata Bulat** dari desain.
  - **Topi Koki** tetap ada sebagai aksesoris, dengan gambar baru yang lebih bagus (sudah ada di desain).
- **Animasi natural**: berkedip, ekor bergerak, jalan, tidur, makan, main, menggaruk, dielus, plus barang yang bergerak (akuarium, bola benang, catnip, jam).
- **Respons yang menyenangkan** saat memberi camilan, mengelus, membeli atau memasang aksesoris, dan selesai menghias.

## Isi tambahan 28 Oktober [pemilik]

Pemilik repo meminta isi yang lebih banyak, dan semuanya sudah masuk ke desain lewat prompt tambahan:

- **4 kucing baru**: Kopi Susu, Mochi, Bos, Kembang. Bentuknya sama dengan Oyen; hanya warna dan coraknya beda. Mochi punya topeng wajah, dan Bos punya garis putih di wajah. Jumlah kucing jadi 9 termasuk Oyen.
- **9 aksesoris baru**: Topi Koki, Jepit Bunga, Dasi Kupu-kupu, Syal Rajut, Topi Baret, Headphone, Tanduk Rusa, Topi Penyihir, Mahkota Raja. Totalnya jadi 16.
- **8 barang baru**: Pancingan Bulu, Bantal Ikan, Tanaman Monstera, Terowongan Kucing, Sofa Mini, Lampu Bulan, Hammock Jendela, Jendela Burung. Totalnya jadi 20.
- **2 camilan baru**: Biskuit Kucing dan Puding Ikan. Totalnya jadi 5.
- **Pose baru "rebahan"** (`rebah`, dipakai di Sofa Mini dan Karpet), plus animasi untuk barang baru (lihat Kamar hidup).

## Tujuan

1. **Kamar Oyen menggantikan Beranda** [pemilik]. Oyen dan kucing koleksi tinggal di sana, dan kamarnya bisa dihias.
2. **Toko** di rute baru `/toko`, dengan tab **Barang, Kucing, Aksesoris, Makanan** [desain].
3. **Kucing koleksi dibeli langsung** di Toko dan **hanya tinggal di kamar**. Yang berjalan di puzzle tetap Oyen [pemilik].
4. **Aksesoris dibeli sekali dan dimiliki selamanya.** Semua kucing bisa memakainya; memasang, melepas, dan mengganti gratis [pemilik].
5. **Barang diseret bebas** di kamar, dan posisinya tersimpan [pemilik].
6. **Kamar hidup**: kucing berjalan sendiri ke barang lalu memakainya, punya kebutuhan, dan bereaksi saat diketuk atau dielus [pemilik].
7. **Kebutuhan tanpa hukuman, dengan bonus**. Kucing yang dirawat memberi hadiah koin harian; kucing yang diabaikan hanya lesu [pemilik].
8. **Jatah iklan koin naik dari 5 jadi 10 per hari** [pemilik].
9. **Peta bergambar**, dan Oyen terlihat berjalan ke level berikutnya sesudah menang [pemilik].

## Bukan tujuan

- Mengubah aturan Oyen, simulasi, solver, data level, bintang, atau petunjuk.
- Kucing koleksi di puzzle.
- Babak 3–5, pembelian dalam aplikasi, akun atau sinkron awan, dan notifikasi push.
- Kamar yang lebih lebar dari layar, lebih dari satu kamar, barang dobel, atau dua aksesoris sekaligus di satu kucing.

## Jangan sampai

- **Hukuman**: kucing kabur, sakit, mati, atau barang hilang karena diabaikan.
- **Iklan paksa**, interstitial, atau sheet iklan yang terbuka sendiri.
- **Pay-to-win**: barang, kucing, atau aksesoris yang membantu puzzle.
- **Kesalahan saldo**: koin terpotong dua kali, saldo negatif, atau stok camilan negatif. Kegagalan simpan harus menguntungkan pemain: barang disimpan sebelum koin, seperti `buyCostume` dulu.
- **Aksesoris yang menutup wajah atau ekspresi kucing**.
- **`pumpAndSettle` yang tidak pernah selesai di test tanpa jalan keluar**. Animasi kamar mengikuti pola peta: `settle`, `TickerMode`, dan `disableAnimations` mematikan gerak.
- **Gambar dari desain yang diketik ulang**. Isi `<svg>` disalin utuh (lihat Format gambar).

## Rincian

### Kamar (Beranda baru, `Kamar.dc.html`)

- **Satu layar tanpa gulir** [saya, sesuai desain], dengan dinding di atas dan lantai di bawah.
  - Logo kecil dan chip koin ada di atas. Chip koin membuka sheet Tambah Koin dan bertitik selama bonus harian belum diambil.
  - Panel bawah berisi tombol besar **Main** (ke `currentChapter`) dan tiga tombol: **Toko** (bertitik saat ada yang baru terjangkau), **Aksesoris** (ke tab Aksesoris), dan **Pengaturan** [desain].
  - Kalau desain menampilkan total bintang, ikuti desainnya. Kalau tidak, total bintang cukup tampil di peta babak.
- **Ukuran layar**: muat di 360×640 sampai 412×915, teks 100% dan 130%, keempat bahasa (`overflow_test`). Cara mengecil mengikuti catatan `n360`.
- **Pemain baru** (`KamarBaru`): hanya Oyen, mangkuk, kamar kosong, dan ajakan "Kamar masih sepi. Ke Toko, yuk!" [desain].
- **Mode hias** (`KamarHias`, `TombolHias`, `BakiGudang`):
  - Tombol "Hias" membuat barang bisa diseret dan menghentikan rutinitas kucing.
  - Barang lantai hanya di area lantai, barang dinding hanya di area dinding. Di lantai, urutan gambar mengikuti posisi y.
  - Barang yang dilepas ke Gudang tetap dimiliki. Mengetuk barang di Gudang menaruhnya kembali di kamar.
  - Tombol "Selesai" menyimpan tata letak dan menampilkan pujian [desain]. Selesai juga memberi +5 Senang ke semua kucing, paling banyak sekali per jam [saya; angka dari desain].
  - Barang yang baru dibeli muncul di posisi bawaannya.
- **Posisi tersimpan** sebagai pecahan 0–1 dari area lantai atau dinding [saya].
- **Ketuk kucing** membuka kartu kucing (`KamarKartu`, `KamarAksesoris`) berisi nama, keterangan, bar Lapar dan Senang (`BarKebutuhan`), tombol Elus, dan dua panel [desain]:
  - **Camilan**: stok tiap camilan; yang habis nonaktif.
  - **Aksesoris**: "Lepas" dan aksesoris yang dimiliki; yang sedang dipakai ditandai; ada tautan "Toko aksesoris →".
- **Reaksi** [desain]: angka melayang ("+25 kenyang", "+10 senang", "Cakep!", "+10 koin"), hati, dan pose singkat (makan, dielus, senang).
- **Tanda di atas kucing**: gelembung koin (`GelembungKoin`) kalau ada hadiah, dan tanda lesu (`TandaLesu`) kalau Lapar atau Senang ≤ 20 [desain].
- **Mangkuk makanan kering** adalah barang bawaan yang selalu ada dan bisa digeser saat menghias. Saat kosong tampil label "Terisi lagi N jam" [desain].

### Kebutuhan dan hadiah

- **Dua bar per kucing, Lapar dan Senang**, 0–100. Keduanya turun lurus mengikuti jam [saya]:
  - Lapar habis dalam 12 jam, Senang dalam 16 jam.
  - Bar tetap turun saat aplikasi ditutup dan berhenti di 0.
  - Jam yang mundur tidak menaikkan bar, mengikuti pola `DailyRewards`.
- **Kucing baru dan kucing sesudah reset** mulai dengan kedua bar 100 [saya].
- **Mangkuk dipakai bersama**, satu isi tiap 4 jam [saya]:
  - Isi baru datang 4 jam sesudah isi sebelumnya dimulai. Isi yang terlewat tidak menumpuk.
  - Dalam satu isi, tiap kucing boleh makan sekali (+40 Lapar) kalau Lapar-nya < 70.
  - Mangkuk tampil kosong begitu semua kucing sudah makan dari isi itu.
  - Hasilnya ditentukan model, bukan animasi.
- **Camilan** dibeli di tab Makanan lalu masuk stok. Stok paling banyak 99 per jenis [saya].

  | Camilan | Harga | Lapar | Senang |
  |---|---|---|---|
  | Biskuit Kucing | 10 | +10 | +2 |
  | Susu | 15 | +15 | +5 |
  | Ikan Asin | 20 | +25 | +5 |
  | Tuna Kaleng | 40 | +40 | +5 |
  | Puding Ikan | 90 | +60 | +15 |

  Semua angka dari desain (harga di `Toko.dc.html`, efek di `Kamar.dc.html`). Camilan diberikan lewat kartu kucing.
- **Senang naik karena:**
  - **dielus**: +10 [desain], paling banyak +30 per jam per kucing [saya]
  - **memakai mainan sendiri**: bola, tikus, garukan, catnip, akuarium, pancingan, terowongan, jendela burung; +10 per pemakaian, paling banyak sekali per 30 menit per kucing [saya]
  - **selesai menghias** (lihat Mode hias)
- **Hadiah**:
  - Kucing yang Lapar dan Senang-nya ≥ 70 memunculkan gelembung **10 koin**, paling banyak sekali per hari kalender (`dayNumber`) per kucing [saya; 10 dari desain].
  - Gelembung diketuk untuk mengambil koinnya. Jam yang mundur menahan hadiah.
- **Oyen penghuni penuh kamar**: punya bar, bisa diberi makan, ikut hadiah, dan bisa memakai aksesoris.

### Aksesoris (Toko tab Aksesoris, `AksesorisPreview`, `IkonAksesoris`)

| Aksesoris | Harga | Kelangkaan | Jangkar |
|---|---|---|---|
| Pita | 50 | Biasa | kepala-samping (kanan) |
| Jepit Bunga | 60 | Biasa | kepala-samping (kiri) |
| Bandana | 80 | Biasa | leher |
| Dasi Kupu-kupu | 90 | Biasa | leher |
| Kalung Lonceng | 120 | Biasa | leher |
| Syal Rajut | 140 | Biasa | leher |
| Beanie | 180 | Langka | kepala-atas |
| Topi Koki | 200 | Langka | kepala-atas |
| Topi Baret | 220 | Langka | kepala-atas |
| Kacamata Bulat | 250 | Langka | wajah |
| Headphone | 280 | Langka | kepala-atas |
| Tanduk Rusa | 320 | Langka | kepala-atas |
| Topi Pesta | 350 | Langka | kepala-atas |
| Topi Penyihir | 520 | Spesial | kepala-atas |
| Mahkota Bunga | 600 | Spesial | kepala-atas |
| Mahkota Raja | 800 | Spesial | kepala-atas |

Semua baris dari desain (`Toko.dc.html`, `AksesorisPreview.dc.html`).

- **Aturan memakai** [pemilik + desain]:
  - Sekali beli, aksesoris jadi milik pemain dan bisa dipakai semua kucing.
  - Satu kucing memakai paling banyak satu aksesoris.
  - Aksesoris yang sama boleh dipakai beberapa kucing sekaligus [saya; desain menyebut "membuka gaya untuk semua kucing sekaligus"].
  - Memasang, melepas, dan mengganti gratis.
- **Pratinjau langsung** di tab Aksesoris (`TokoAksesoris`): pemain memilih kucing dan aksesoris, lalu melihat kucing itu memakainya.
  - Konfirmasi beli: `TokoAksesorisBeli`.
  - Koin kurang: `TokoAksesorisKurang`.
  - Sukses: `TokoAksesorisSukses`, "Milikmu selamanya", lalu bisa langsung dipakai.
- **Posisi** mengikuti jangkar di desain 21b: aksesoris digambar di grup kepala sprite, jadi ikut setiap pose dan animasi.
  - Pose tidur memakai varian kecil; aksesoris baru diskala 0,72 ke kepala yang melingkar.
  - Lonceng dan ujung bandana disembunyikan saat lesu. Ujung syal disembunyikan saat rebahan dan tidur, dan berayun 0,44 detik saat jalan.
  - Headphone hanya bando dan bantalan kecil di antara telinga; telinga kucing tetap terlihat.
  - Kacamata berlensa bening, dengan bingkai berwarna garis wajah kucing.
- **Di puzzle** [saya]: Oyen di papan, putar ulang, layar hasil, dan tutorial tampil tanpa aksesoris. Aksesoris hanya digambar untuk sprite kamar (`Kucing.dc.html`). Sprite papan (desain 14) punya bentuk dan arah lain, dan desain tidak menggambarkan aksesoris di sana.
  - Akibatnya `OyenCostume`, prop `costume` di `OyenLook`/`BoardScene.dressed`, dan kostum di papan dihapus bersama Lemari Kostum.
  - Token Oyen di peta (`TokenOyenPeta`) memakai aksesoris Oyen kalau desainnya mendukung.

### Kamar hidup (`AnimasiKucing.dc.html`, `Kamar.dc.html`)

- **Rutinitas per kucing**: diam (duduk/menjilat), jalan, memakai barang (main bola atau pancingan, makan, sembunyi di kardus atau terowongan, garuk tiang, tidur di kasur, bantal ikan, atau hammock, rebahan di sofa mini atau karpet, duduk di rak, nonton jendela burung atau akuarium), lesu, dan bereaksi.
  - Contoh rutinitas Oyen ada di desain 21c.
  - Tujuan dipilih acak berbobot dari barang yang ada dan sedang tidak dipakai kucing lain [saya].
  - Kucing berjalan lurus di lantai dan boleh melewati barang.
  - Bola dan mangkuk disembunyikan dari lantai saat dipakai, lalu digambar oleh sprite. Kardus, kasur, dan rak berganti ke keadaan "dipakai" lewat komponen Barang [desain].
- **Angka animasi** [desain 21c]:
  - kedip: mata skala-Y 1→0,12 selama 140 ms, tiap 4,6 detik, dengan jeda awal acak
  - ekor: ±8° per 2,6 detik; kibas cepat 0,9 detik saat senang atau main
  - jalan: 2 bingkai tiap 220 ms, ±70 px/detik
  - tidur: napas skala 1→1,04 per 3,2 detik, "Z" naik 2,4 detik
  - makan: angguk 2,6 px per 0,45 detik
  - main: tepukan 5 px per 0,5 detik
  - garuk: 5 px per 0,35 detik
  - dielus: ±4° per 0,9 detik
  - senang: kilau 1,2 detik
  - barang: ikan akuarium 4–5 detik, bola ±10° per 2,8 detik, catnip 3,2 detik, pendulum jam 1,4 detik
  - barang baru: bulu pancingan ±14° per 1,3 detik, burung jendela lompat 2,6 detik, lampu bulan berpendar 0,9→1,06 per 3 detik, hammock ±2,5° per 3,2 detik, daun monstera ±3° per 4,2 detik, puding goyang 2,2 detik
  - rebahan: ekor ayun 3,4 detik; headphone: not musik melayang 2,2 detik
- **Jeda**: rutinitas berhenti selama kartu kucing terbuka, mode hias aktif, atau ada reaksi, lalu lanjut dari langkah berikutnya [desain].
- **Hemat**: kucing di luar layar tidak dianimasikan.
- **Kurangi gerak** (`disableAnimations`): semua loop berhenti dan kucing tetap di pose diam. Kebutuhan dan hadiah tetap berjalan [desain].
- **Bisa diuji**: perilaku memakai `Random` yang bisa diberi seed, dan satu jam kamar yang bisa dimajukan di test seperti `RunClock` [saya].
- **Suara baru** lewat `GameSound`, dengan sumber CC0 yang dicatat lisensinya [saya]: dengkur saat dielus, meong saat diketuk, makan, koin hadiah, beli, dan pasang aksesoris. Ukurannya dicek `audio_assets_test`; batasnya boleh dinaikkan seperlunya, dengan alasan yang dicatat.

### Toko (`Toko.dc.html`)

- **Rute dan bar atas**: rute `/toko`, dibuka dari tombol Toko (tab Barang) atau Aksesoris (tab Aksesoris) di kamar. Kembali = kamar. Chip koin membuka sheet Tambah Koin.
- **Tab dan kartu** (`TabToko`, `KartuToko`): keadaan kartu adalah bisa dibeli, dimiliki ("Punyamu", atau untuk kucing "Tinggal di kamar"), dan koin kurang. Kartu Makanan menampilkan stok dan bisa dibeli berulang.
- **Konfirmasi beli** (`SheetBeli`) berisi gambar besar, nama, deskripsi jenaka, dan tombol "Beli · N koin" / "Nanti dulu". Kalau koin kurang, tombolnya "Koin kurang · N". Sesudah berhasil, tombolnya "Lihat di kamar" [desain].
- **Katalog** [desain]. Kucing dan barang hanya bisa dibeli satu kali.

  | Tab | Isi |
  |---|---|
  | Kucing | Salju 300, Kopi Susu 300, Mendung 350, Arang 400, Mochi 450, Telon 550, Bos 600, Kembang 700 |
  | Barang lantai | Kardus Nyaman 50, Pancingan Bulu 60, Bola Benang 80, Tikus Mainan 120, Karpet Bulat 150, Bantal Ikan 160, Pot Catnip 180, Kasur Bantal 200, Tanaman Monstera 200, Tiang Garukan 220, Terowongan Kucing 260, Sofa Mini 450, Akuarium 600, Rumah Kucing 900 |
  | Barang dinding | Lampu Bulan 120, Lukisan Ikan 140, Rak Dinding 160, Jam Kucing 240, Hammock Jendela 380, Jendela Burung 700 |
  | Aksesoris | lihat tabel Aksesoris |
  | Makanan | Biskuit Kucing 10, Susu 15, Ikan Asin 20, Tuna Kaleng 40, Puding Ikan 90 |

  Deskripsi jenaka tiap barang ada di `Toko.dc.html`. Zona barang baru (lantai/dinding) adalah keputusan saya dari gambarnya; ikuti `Barang.dc.html` kalau berbeda.

### Koin

- **Sumber koin**:
  - 10 koin per bintang baru
  - bonus harian 20
  - iklan +20 koin, **10 kali per hari** [pemilik]
  - hadiah kucing 10 per kucing per hari (paling banyak 90 dengan 9 kucing)
- **Total belanja**: barang 5.370, kucing 3.650, aksesoris 4.260, jadi ±13.280 koin, belum termasuk camilan.
  - Sumber per hari paling banyak ±310 koin, ditambah 600 koin dari bintang.
  - Pemain yang mengambil semua jatah tiap hari butuh sekitar 6 minggu untuk membeli semuanya; pemain santai butuh 2–3 bulan. Ini sengaja jadi tujuan jangka panjang.
  - Angka bisa diseimbangkan lagi sesudah dimainkan.

### Peta bergambar (`PetaBergambar`, `PetaDapur`, `PetaJalan`, `PetaPindah`)

- **Ilustrasi per babak**: Babak 1 Dapur, Babak 2 Ruang Tamu.
  - Titik level bergambar (`TitikLevel`) punya keadaan selesai, saat ini, dan terkunci.
  - Bos ada di ujung.
  - Token Oyen (`TokenOyenPeta`) berdiri di level saat ini.
- **Gulir**: peta tetap bisa digulir, dan dibuka dengan Oyen di tengah.
- **"Lanjut" sesudah menang** [saya; gambar dari desain `PetaJalan`]:
  1. Kembali ke peta babak level id+1.
  2. Oyen berjalan dari titik level yang baru dimainkan, sekitar 1 detik (langsung pindah kalau gerak dikurangi).
  3. Level id+1 terbuka sendiri.
  4. Ketukan selama Oyen berjalan membatalkan pembukaan otomatis.

  Berlaku juga untuk level lama yang diulang. Tombol kembali di level tetap ke peta.
- **Kasus tepi** [saya]:
  - Sesudah bos level 10: peta Babak 2 dengan Oyen di level 11 (`PetaPindah`), tanpa buka otomatis.
  - Sesudah level 20: peta Babak 2 dengan Oyen di bos, tanpa buka otomatis.
  - Test lama "Lanjut sesudah level 10 dan 20" diperbarui.
- **"Main" dari kamar** hanya membuka peta.

### Format gambar [saya]

- **Salin dari desain**: semua gambar baru (kucing dan pose, aksesoris, barang, kamar, peta) disalin dari `<svg>` desain ke `lib/game/render/` dan digambar lewat `SvgTemplate` dengan fungsi `Canvas`. Tidak ada paket gambar baru.
  - `Kucing.dc.html` menyusun sprite dari bagian-bagian (kepala, ekor, mata) dengan warna lewat prop. Pertahankan pembagian itu, karena animasi memutar, menggeser, dan menskala bagian.
- **Kurangi gerak dan test**: animasi dibuat sebagai fungsi waktu (pose, sudut ekor, skala mata) supaya bisa dimatikan dan diuji per waktu.
- **`design_sync_test.dart`** diperluas untuk berkas desain baru, dan dilewati kalau folder desain tidak ada.

## Model data yang diusulkan (Dart murni, `lib/game/model/`)

Nama kelas dan berkas adalah usulan. Kalau langkah sebelumnya memakai nama lain, ikuti kode.

- **`home_items.dart`**:
  - `RoomItemId` (20 barang)
  - `RoomItem`: `id`, `price`, `zone` lantai/dinding, `use` tidur/main/garuk/nonton/duduk/sembunyi/rebahan/hiasan, `toy`, `defaultSpot`
  - `roomItems`, `roomItemOf`
- **`kitties.dart`**:
  - `KittyId`: `oyen`, `salju`, `mendung`, `arang`, `telon`, `kopiSusu`, `mochi`, `bos`, `kembang`
  - `Kitty`: `id`, `price`; Oyen berharga 0 dan selalu dimiliki
  - `kitties`
- **`accessories.dart`**:
  - `AccessoryId` (16 aksesoris)
  - `Accessory`: `id`, `price`, `rarity`, `anchor`
  - `accessories`
  - `AccessoryCloset`: `owned`, `wearing` (`Map<KittyId, AccessoryId>`), `buy`, `wear(kitty, id?)`; JSON membuang entri rusak, termasuk aksesoris yang belum dimiliki
  - **Menggantikan `costumes.dart`/`Wardrobe`**
- **`snacks.dart`**:
  - `Snack`: `id`, `price`, `hunger`, `joy`
  - `snacks`
  - `Pantry`: batas 99
- **`room.dart`**:
  - `Spot`: pecahan, dijepit ke 0–1
  - `Room`: `owned`, `placed`, dan Gudang
- **`needs.dart`**:
  - `CatNeeds`: `hunger`, `joy`, `at`, `decayed(now)`, `fed`, `petted`, `played`, `decorated`, plus batas per jam
  - `Bowl`: `filledAt`, kucing yang sudah makan dari isi itu
  - `CatRewards`
  - konstanta: `hungerHours` 12, `joyHours` 16, `bowlRefillHours` 4, `bowlFood` 40, `rewardCoins` 10, `rewardThreshold` 70, `sadThreshold` 20, `petJoy` 10, `petJoyPerHour` 30, `decorateJoy` 5
- **`rewards.dart`**: `maxAdsPerDay` = 10.
- **`ProgressStore`**:
  - `loadHome`/`saveHome`, kunci `home.state`: satu JSON berisi barang, tata letak, kucing, aksesoris, dan stok, supaya satu pembelian tidak terbelah di dua kunci
  - `loadNeeds`/`saveNeeds`, kunci `home.needs`: kebutuhan, mangkuk, dan hari hadiah
  - `loadWardrobe`/`saveWardrobe` dan kunci `costume.*` dihapus
- **`ProgressController`**:
  - `home`, `needs`
  - `buyItem`, `buyKitty`, `buySnack`, `buyAccessory`, masing-masing → `Future<bool>`
  - `wearAccessory(kitty, id?)`, `placeItem`, `storeItem`, `feed`, `pet`, `play`, `finishDecorating`, `eatFromBowl`, `claimKittyReward`
  - `resetProgress` menghapus barang, kucing, aksesoris, stok, dan tata letak. Bar Oyen kembali ke 100, dan hari hadiah tidak berubah.
  - `wardrobe`, `buyCostume`, dan `wearCostume` dihapus.

## Teks baru

Semua teks pemain dan label pembaca layar masuk ke keempat ARB. Teks Indonesia diambil dari desain dan ditulis dulu. Nama-nama lewat `lib/l10n/names.dart`. Yang perlu ditambah:

- nama dan deskripsi kucing, barang, aksesoris, dan camilan
- kelangkaan aksesoris
- tab Toko
- keadaan kartu
- konfirmasi beli dan "Milikmu selamanya"
- Hias, Selesai, Gudang, dan pujian sesudah menghias
- kartu kucing: Lapar, Senang, "Hampir habis!", Elus, Camilan, Aksesoris, Lepas
- reaksi
- gelembung hadiah
- "Kamar masih sepi"
- label pembaca layar
- judul pindah babak

Teks Lemari Kostum dan kostum lama dihapus dari keempat ARB.

## Diserahkan ke builder

- Bobot acak rutinitas, urutan gambar saat kucing bertumpuk, dan cara menyimpan berkala. Usulan untuk penyimpanan: simpan saat ada aksi pemain dan saat aplikasi masuk ke latar belakang.
- Bentuk persis bagian yang tidak digambar desain. Pakai gaya `KoSheet` dan `KoCard`, lalu catat di `docs/DESIGN_NOTES.md`.
- Cara galeri (`/galeri`) menampilkan sprite, aksesoris, dan barang baru.
