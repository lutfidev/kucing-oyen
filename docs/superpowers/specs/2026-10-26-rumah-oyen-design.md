# Rumah Oyen: kamar, Toko, kucing koleksi, peta bergambar (langkah 21–26)

Dokumen ini hasil brainstorming dengan pemilik repo pada 26 Oktober 2026. Pekerjaannya dipecah menjadi langkah 21–26 di `docs/ROADMAP.md` dan baru dikerjakan **sesudah langkah 18–20**.

Gambar dan tata letak semua layar baru didesain pemilik repo di Claude Design memakai brief di `docs/design-brief/rumah-oyen.md`, lalu diekspor ke `docs/design/source/` sebagai halaman 19–24. Kalau halaman yang dibutuhkan suatu langkah belum ada di sana, langkah itu berhenti dan memberi tahu pemilik repo; jangan menebak desainnya. Begitu desain ada, tata letak, ukuran, warna, dan teks mengikuti desain. Angka di dokumen ini hanya aturan main dan usulan awal.

Tiap keputusan diberi penanda:

- **[pemilik]**: dipilih pemilik repo.
- **[saya]**: keputusan saya. Pemilik repo boleh mengubahnya, dan builder mengikutinya kalau tidak ada perubahan.

## Maksud

Pemilik repo merasa UI sekarang hambar. Ada tiga hal yang dikeluhkan:

- Masuk level dengan mengetuk bulatan angka di peta.
- Rasa bolak-balik antara peta dan level.
- Koin yang tidak punya banyak tujuan.

Arah yang dipilih adalah **Talking Tom / Neko Atsume** [pemilik]: kucingnya menjadi pusat perhatian, dan puzzle menjadi cara mendapat koin untuk merawat dan menghias rumahnya. Pemain membuka game, menyapa Oyen di kamarnya, memberi makan, mengambil hadiah, membeli barang atau kucing baru, lalu menekan Main untuk mencari koin lagi.

## Tujuan

1. **Kamar Oyen menggantikan Beranda** [pemilik]. Oyen dan kucing koleksi tinggal di sana, dan kamarnya bisa dihias dengan barang yang dibeli.
2. **Toko** (rute baru `/toko`) dengan tab Barang, Kucing, dan Makanan, **terpisah dari Lemari Kostum** [pemilik]. Lemari Kostum tidak berubah.
3. **Kucing koleksi dibeli langsung** di Toko [pemilik]. Mereka **hanya tinggal di kamar**, sedangkan yang berjalan di puzzle tetap Oyen [pemilik].
4. **Barang diseret bebas** di kamar, dan posisinya tersimpan [pemilik].
5. **Kamar hidup** [pemilik]:
   - kucing berjalan sendiri ke barang lalu memakainya
   - kucing punya kebutuhan
   - kucing bereaksi saat diketuk atau dielus
6. **Kebutuhan tanpa hukuman, dengan bonus** [pemilik]. Kucing yang dirawat memberi hadiah koin harian. Kucing yang diabaikan hanya lesu.
7. **Jatah iklan koin naik dari 5 jadi 10 per hari** [pemilik].
8. **Peta bergambar** [pemilik]. Tiap babak berupa ilustrasi ruangan dengan titik level bergambar. Sesudah menang, Oyen terlihat berjalan ke level berikutnya.

## Bukan tujuan

- Mengubah aturan Oyen, simulasi, solver, data level, bintang, petunjuk, atau kostum.
- Kucing koleksi di puzzle, kucing berkostum, atau kostum baru.
- Babak 3–5, pembelian dalam aplikasi (IAP), akun atau sinkron awan, dan notifikasi push.
- Kamar yang lebih lebar dari layar, lebih dari satu kamar, atau barang dobel.

## Jangan sampai

- **Ada hukuman.** Kucing kabur, sakit, mati, atau barang hilang karena diabaikan.
- **Ada iklan paksa, interstitial, atau sheet iklan yang terbuka sendiri.** Iklan tetap selalu pilihan pemain, seperti langkah 14.
- **Ada barang atau kucing yang membantu puzzle** (pay-to-win).
- **Koin terpotong dua kali, saldo negatif, atau stok camilan negatif.** Aturan `buyCostume` berlaku: kegagalan simpan harus menguntungkan pemain.
- **Kamar menghentikan `pumpAndSettle` selamanya tanpa jalan keluar di test.** Animasi kamar mengikuti pola peta: `settle`, `TickerMode`, dan `disableAnimations` mematikan gerak.
- **Gambar dari desain diketik ulang.** Isi `<svg>` disalin utuh seperti sekarang (lihat Format gambar).

## Rincian yang sudah diputuskan

### Kamar (Beranda baru, desain 19)

- **Isi layar** [saya]: kamar satu layar tanpa gulir, dengan bagian dinding di atas dan lantai di bawah.
  - Di atas kamar ada chip koin (membuka sheet Tambah Koin, bertitik selama bonus harian belum diambil, seperti sekarang) dan total bintang.
  - Di bawah ada tombol besar **Main** (ke `currentChapter` seperti sekarang) dan tombol **Toko**, **Lemari Kostum**, **Pengaturan**.
  - Logo "Ginger Logic" tetap ada di Beranda. Letak dan ukurannya mengikuti desain 19.
- **Ukuran layar**: harus muat di 360×640 sampai 412×915, teks 100% dan 130%, keempat bahasa (`overflow_test`). Area lantai dan dinding diukur dari ruang yang tersisa.
- **Mode hias** [saya]:
  - Tombol "Hias" membuat semua barang bisa diseret. Selama mode hias, kucing diam di tempat.
  - Barang lantai hanya bisa ditaruh di area lantai, barang dinding hanya di area dinding. Barang boleh bertumpuk; yang ditaruh terakhir digambar paling depan, dan di lantai urutannya ikut posisi y.
  - Barang yang sedang diangkat bisa dilepas ke "Gudang" (baki di bawah). Barang tetap dimiliki dan bisa ditaruh lagi dari Gudang.
  - Tombol "Selesai" menyimpan tata letak. Tidak ada tombol batal (keputusan saya: lebih sederhana).
  - Barang yang baru dibeli langsung muncul di posisi bawaan katalognya, atau di tengah area kalau tempat itu sudah terisi.
- **Posisi tersimpan** sebagai pecahan 0–1 dari area lantai atau dinding, jadi tetap pas di semua ukuran layar [saya].
- **Ketuk kucing** membuka kartu kecil kucing itu: nama, bar Lapar dan Senang, tombol "Beri camilan" yang memilih dari stok, dan "Elus". Mengusap kucing juga dihitung mengelus. Tanpa kartu terbuka, tidak ada bar permanen.
- **Tanda di atas kucing** [saya]:
  - gelembung koin kalau ada hadiah
  - tanda lesu kecil kalau Lapar atau Senang < 30
- **Mangkuk makanan kering** berupa barang bawaan yang selalu ada di lantai, tidak bisa dijual tapi bisa digeser di mode hias. Penuh = kering bisa dimakan; kosong = jam isi ulang.

### Kebutuhan dan hadiah [saya]

- **Dua bar per kucing, Lapar dan Senang**, 0–100. Tiap bar turun lurus mengikuti jam:
  - Lapar dari 100 ke 0 dalam 12 jam.
  - Senang dari 100 ke 0 dalam 16 jam.
  - Bar juga turun saat aplikasi ditutup, dihitung dari waktu terakhir disimpan, dan berhenti di 0.
  - Jam yang mundur tidak menaikkan bar dan tidak menggeser waktu terakhir ke belakang, mengikuti pola `DailyRewards`.
- **Kucing baru dan kucing sesudah reset** mulai dengan kedua bar 100.
- **Mangkuk dipakai bersama**, satu isi tiap 4 jam:
  - Mangkuk terisi lagi 4 jam sesudah isi sebelumnya dimulai. Hitungannya memakai jam, jadi tetap berjalan saat aplikasi ditutup, dan isi yang terlewat tidak menumpuk.
  - Dalam satu isi, tiap kucing boleh makan sekali (+40 Lapar), kalau Lapar-nya < 70.
  - Mangkuk tampil kosong begitu semua kucing yang dimiliki sudah makan dari isi itu.
  - Kucing yang lapar bergantian berjalan ke mangkuk. Hasilnya ditentukan model, bukan animasi, jadi saat aplikasi dibuka kucing yang lapar boleh langsung dihitung sudah makan kalau isi itu belum dipakainya.
- **Camilan** dibeli di tab Makanan dan masuk stok:

  | Camilan | Harga | Lapar | Senang |
  |---|---|---|---|
  | Ikan Asin | 10 | +30 | +0 |
  | Susu | 15 | +20 | +20 |
  | Tuna Kaleng | 30 | jadi 100 | +30 |

  Camilan diberikan lewat kartu kucing atau dengan menyeret camilan dari stok ke kucing. Satu camilan = satu stok.
- **Senang naik saat:**
  - dielus: +5, paling banyak +30 per jam per kucing supaya tidak bisa diketuk terus
  - kucing memakai mainan sendiri (bola, tikus, garukan, catnip, akuarium): +10 per pemakaian, paling banyak sekali per 30 menit per kucing
  - mainan diketuk pemain saat tidak dipakai, sehingga kucing terdekat datang bermain
- **Hadiah:**
  - Kucing yang Lapar dan Senang-nya ≥ 70 memunculkan gelembung **10 koin**, paling banyak sekali per hari kalender (`dayNumber`) per kucing.
  - Gelembung diketuk untuk diambil, dan koin ditambah lewat `ProgressController` yang sama dengan bonus harian.
  - Jam yang mundur menahan hadiah, seperti bonus harian.
- **Oyen penghuni penuh**: punya bar, bisa diberi makan, ikut hadiah, dan memakai kostumnya di kamar (`OyenLook.costume`).
- **Reset progres** menghapus barang, kucing koleksi, stok camilan, dan tata letak kamar. Bar Oyen kembali 100. Hari hadiah per kucing tidak ikut dihapus, supaya hadiah hari itu tidak bisa diambil ulang (sama dengan bonus harian).

### Kamar hidup [saya]

- Setiap kucing punya keadaan sederhana: diam (duduk/menjilat), berjalan ke tujuan, memakai barang (tidur, main, garuk, nonton, duduk), makan, lesu, dan bereaksi.
  - Tujuan dipilih acak berbobot dari barang yang ada dan sedang tidak dipakai kucing lain. Jalannya lurus di area lantai, tanpa pencarian jalur, dan boleh melewati barang. Barang dinding dipakai dari lantai di bawahnya (nonton jam/lukisan) atau tidak dipakai sama sekali.
  - Kucing yang lesu lebih sering rebahan dan berjalan lebih pelan.
- **Pemilihan perilaku memakai `Random` yang bisa diberi seed**, dan waktu kamar dimajukan oleh satu jam/ticker yang bisa diganti di test (seperti `RunClock`). Dengan begitu urutan perilaku bisa diuji tanpa menunggu.
- **Kurangi gerak** (`disableAnimations`): kucing tidak berjalan, hanya berganti pose di tempat. Kebutuhan dan hadiah tetap jalan.
- **Suara baru** lewat `GameSound`, berkas dibuat seperti langkah 16 dengan sumber CC0 dan dicatat lisensinya:
  - dengkur saat dielus
  - "meong" saat diketuk
  - makan
  - koin hadiah
  - beli di Toko

  Ukuran dan total berkas tetap dicek `audio_assets_test`. Batas total boleh dinaikkan seperlunya; catat alasannya.

### Toko (desain 20)

- Rute `/toko`, dibuka dari tombol Toko di kamar. Kembali = kamar. Chip koin di bar atas membuka sheet Tambah Koin.
- Tiga tab: **Barang**, **Kucing**, **Makanan**. Tiap kartu menampilkan gambar, nama, dan harga, dengan keadaan:
  - dimiliki ("Punyamu")
  - bisa dibeli
  - koin kurang

  Kartu Makanan menampilkan jumlah stok, dan bisa dibeli berulang.
- **Beli** dengan satu konfirmasi [saya]. Konfirmasinya berupa sheet kecil berisi gambar besar, nama, harga, dan tombol "Beli · N koin". Toko memakai konfirmasi karena harganya lebih besar dari kostum; Lemari Kostum tetap tanpa konfirmasi. Sesudah membeli barang atau kucing, ada tombol "Lihat di kamar".
- **Katalog** (harga usulan, nama Indonesia usulan, semua lewat ARB) [saya]:

  | Tab | Isi |
  |---|---|
  | Kucing | Arang (hitam) 300, Mendung (abu) 400, Telon (belang tiga) 600, Salju (putih) 800 |
  | Barang lantai | Kardus Nyaman 40 (duduk), Bola Benang 40 (main), Tikus Mainan 50 (main), Karpet Bulat 70 (rebahan), Kasur Bantal 80 (tidur), Pot Catnip 90 (main), Tiang Garukan 120 (garuk), Akuarium 200 (nonton), Rumah Kucing 250 (tidur) |
  | Barang dinding | Lukisan Ikan 60, Jam Kucing 100, Rak Dinding 150 (kucing bisa duduk di atasnya kalau desain 22 memungkinkan; kalau tidak, hiasan saja) |
  | Makanan | Ikan Asin 10, Susu 15, Tuna Kaleng 30 |

  Kucing dan barang hanya bisa dibeli satu kali. Stok camilan dibatasi 99 per jenis.

### Koin

- Sumber koin:
  - 10 koin per bintang baru
  - bonus harian 20
  - iklan +20 koin, **10 kali per hari** [pemilik] (`maxAdsPerDay` 10; teks "Sisa N kali hari ini" mengikuti)
  - hadiah kucing 10 per kucing per hari
- Barang dan kucing berjumlah ±3.900 koin, belum termasuk kostum dan camilan. Dengan 600 koin dari bintang dan sampai ±270 koin per hari dari bonus, iklan, dan hadiah lima kucing, semuanya bisa dibeli dalam sekitar 2–3 minggu bermain santai. Angka bisa diseimbangkan lagi sesudah dimainkan.

### Peta bergambar (desain 23)

- Tiap babak berupa ilustrasi ruangannya: **Babak 1 Dapur**, **Babak 2 Ruang Tamu**.
  - Titik level bergambar benda di ruangan itu menggantikan bulatan angka polos. Nomor level tetap terbaca, dengan keadaan selesai (bintang), saat ini, dan terkunci.
  - Bos tetap di ujung jalan.
  - **Token Oyen** (dengan kostumnya) berdiri di titik level saat ini.
- Peta tetap bisa digulir kalau lebih tinggi dari layar, dan dibuka dengan Oyen di tengah, seperti sekarang. Kartu babak lain tetap ada (desain 23 boleh mengubah bentuknya).
- **"Lanjut" sesudah menang** [saya]:
  1. Pemain kembali ke peta babak level berikutnya.
  2. Token Oyen berjalan dari titik level yang baru dimainkan ke titik level id+1, sekitar 1 detik. Dengan kurangi gerak, Oyen langsung pindah.
  3. Level berikutnya terbuka sendiri.
  4. Mengetuk layar selama Oyen berjalan membatalkan pembukaan otomatis; pemain tetap di peta.
  5. Tombol kembali di level yang terbuka sendiri tetap kembali ke peta.

  Ini juga berlaku untuk level lama yang diulang.
- **Kasus tepi** [saya]:
  - Sesudah bos level 10: pindah ke peta Babak 2 dengan Oyen di titik level 11, tanpa level yang terbuka sendiri. Ganti babak ditandai dengan judul baru.
  - Sesudah level 20: tetap di peta Babak 2, Oyen di titik bos, tanpa yang terbuka sendiri.
  - Test lama "Lanjut sesudah level 10 dan 20" diperbarui.
- **"Main" dari kamar** tetap membuka peta babak saat ini tanpa membuka level sendiri.

### Format gambar [saya]

- Semua gambar baru (kamar, barang, kucing koleksi, pose kamar Oyen, peta) disalin utuh dari `<svg>` ekspor desain ke `lib/game/render/` (`design_svg.dart` atau berkas pendamping) dan digambar lewat `SvgTemplate` dengan fungsi `Canvas`, seperti Oyen dan lemari. Tidak ada paket gambar baru.
- Kucing koleksi sebaiknya satu bentuk sprite dengan warna lewat placeholder, seperti kostum Oyen. Kalau desain 21 menggambar tiap kucing terpisah, salin terpisah.
- Gerak berjalan = pose diganti dan digeser, plus cermin kiri/kanan (`OyenLook.mirror`).
- `design_sync_test.dart` diperluas untuk halaman baru.

## Model data yang diusulkan (Dart murni, `lib/game/model/`)

Nama kelas dan berkas adalah usulan; ikuti kode kalau langkah sebelumnya memakai nama lain.

- **`home_items.dart`**:
  - `RoomItemId` (enum 12 barang)
  - `RoomItem` (`id`, `price`, `zone` lantai/dinding, `use` tidur/main/garuk/nonton/duduk/rebahan/hiasan, `toy` bool, `defaultSpot`)
  - `roomItems`, `roomItemOf`
- **`kitties.dart`**:
  - `KittyId` (`oyen`, `arang`, `mendung`, `telon`, `salju`)
  - `Kitty` (`id`, `price`; Oyen 0 dan selalu dimiliki), `kitties`
- **`snacks.dart`**:
  - `Snack` (`id`, `price`, `hunger`, `joy`), `snacks`
  - `Pantry` (stok per camilan; `add`, `use`, batas 99, `toJson`/`fromJson` membuang yang rusak)
- **`room.dart`**:
  - `Spot` (x, y pecahan, dijepit 0–1)
  - `Room` (`owned` barang, `placed` `Map<RoomItemId, Spot>`; yang dimiliki tapi tidak ditaruh = Gudang; `buy`, `place`, `store`)
  - `Room.initial`, JSON yang membuang entri rusak
- **`needs.dart`**:
  - `CatNeeds` (`hunger`, `joy`, `at` waktu terakhir; `decayed(now)` dengan laju di atas, jam mundur tidak menaikkan; `fed(snack)`, `petted(now)`, `played(now)`, batas elus per jam dan main per 30 menit)
  - `Bowl` (`filledAt`, kucing yang sudah makan dari isi itu; `refilled(now)`, `canEat(id, now)`, `eat(id)`, `looksEmpty(owned)`)
  - `CatRewards` (hari hadiah terakhir per kucing; `canClaim(id, today, needs)`, `claim`)
  - Konstanta: `hungerHours` 12, `joyHours` 16, `bowlRefillHours` 4, `bowlFood` 40, `rewardCoins` 10, `rewardThreshold` 70, `sadThreshold` 30
- **`rewards.dart`**: `maxAdsPerDay` = 10.
- **`ProgressStore`** baru:
  - `loadHome`/`saveHome`: satu JSON untuk barang, tata letak, kucing, dan stok, supaya pembelian tidak terbelah di dua kunci
  - `loadNeeds`/`saveNeeds`: kebutuhan, mangkuk, dan hari hadiah

  Kunci `home.state` dan `home.needs`. `MemoryProgressStore` ikut punya field-nya.
- **`ProgressController`** ditambah:
  - `home`, `needs` (sudah diturunkan ke `clock()`)
  - `buyItem`, `buyKitty`, `buySnack` (→ `Future<bool>`; gagal tanpa efek; barang disimpan sebelum koin)
  - `placeItem`, `storeItem`
  - `feed(kitty, snack)`, `pet(kitty)`, `play(kitty)`, `eatFromBowl(kitty)`
  - `claimKittyReward(kitty)` → `Future<bool>`
  - `resetProgress` menghapus sesuai aturan di atas

## Teks baru

Semua teks yang tampil ke pemain, juga label pembaca layar, masuk ke keempat ARB dengan nada santai dan jenaka. Teks Indonesia ditulis dulu, sesuai aturan di `CLAUDE.md`. Daftar kasarnya:

- nama 4 kucing, 12 barang, dan 3 camilan
- judul Toko dan nama tab
- keadaan kartu, konfirmasi beli, "Lihat di kamar"
- "Hias", "Selesai", "Gudang"
- isi kartu kucing (Lapar, Senang, Beri camilan, Elus, stok kosong)
- gelembung hadiah
- label pembaca layar kucing dan barang di kamar
- judul ganti babak di peta

Nama-nama tersebut memakai fungsi baru di `lib/l10n/names.dart`.

## Diserahkan ke builder

- Kurva gerak, kecepatan berjalan, bobot acak perilaku, dan lama tiap pose.
- Cara menyimpan berkala: misalnya simpan kebutuhan saat ada aksi pemain dan saat aplikasi ke latar belakang, tidak tiap bingkai.
- Bentuk persis kartu kucing dan sheet konfirmasi, kalau desain 19/20 tidak menggambarkannya. Gunakan gaya `KoSheet` dan `KoCard`, lalu catat di `docs/DESIGN_NOTES.md`.
- Cara galeri (`/galeri`) menampilkan sprite dan barang baru.
