# Rumah yang rapi: hadiah bergiliran, kucing lebih tenang, barang tidak menumpuk, rak buku (langkah 40)

Desain rak buku dan pose baca: kanvas Claude Design "Ginger Logic – Gang Depan",
https://claude.ai/code/artifact/ea089b1c-2bf2-4906-932c-895e4bf207df (artboard
15 `RakBukuTengah`, 16 `LembarBaca`; komponen `Barang.dc.html` item `rakBuku`,
`Kucing.dc.html` pose `baca`). Salinan lokal di `docs/design/gang-depan/project/`
(diambil 25 Nov 2026).

## Kenapa

Pemilik repo melihat rumah di HP (ruang tengah penuh, 9 kucing) dan merasa
"terlalu rame dan kacau, penempatan gak rapi". Sumbernya:

1. Setiap kucing yang siap memberi hadiah memunculkan gelembung "+10" sendiri.
   Dengan 6 kucing ada 6 gelembung yang saling tumpuk dan menutupi muka.
2. Barang yang baru dibeli langsung ditaruh di posisi bawaannya di ruang tengah
   (`Room.buy`) tanpa cek tumpang tindih, jadi barang saling tumpuk.
3. Kucing berdiri di atas barang dan di atas kucing lain.
4. Mangkuk di tepi kanan membuat Oyen yang makan terpotong tepi layar, dan
   label "Terisi lagi…" serta gelembung pikiran menimpa Oyen.
5. Diam hanya 2,6 detik, memakai barang 3 detik, tidur 6 detik. Dengan banyak
   kucing, hampir selalu ada beberapa yang berjalan bersamaan, sehingga rumah
   terasa ribut.
6. Kotak putus-putus "Hiasan dinding?" / "Kasur, mungkin?" di rumah kosong
   dianggap berlebihan.

Pemilik repo juga minta barang baru: rak buku tempat kucing membaca sambil
berkacamata ("jadi lucuk").

**Berhasil kalau:**
- Rumah penuh terlihat tenang. Paling banyak satu gelembung hadiah dan paling
  banyak dua kucing berjalan bersamaan.
- Rumah tetap hidup: tidak pernah semua kucing diam lama.
- Barang tidak saling tumpuk.
- Ada kucing yang membaca di rak buku.

## Tujuan

- **G1. Kotak petunjuk rumah kosong dihapus.** `EmptyRoomHints` (dua bidang
  putus-putus beserta labelnya) dihapus. Gelembung "Kamar masih sepi. Ke Toko,
  yuk!" tetap ada. Kunci ARB `roomEmptyWall`, `roomEmptyWallHint`,
  `roomEmptyFloor`, `roomEmptyFloorHint` dihapus dari keempat ARB kalau tidak
  dipakai di tempat lain. Kalau gelembung ajakan sekarang ada di dalam
  `EmptyRoomHints`, gelembungnya dipertahankan sebagai widget sendiri.
- **G2. Hadiah koin bergiliran** (keputusan pemilik repo: pilihan C).
  - Di ruangan yang dibuka, hanya satu kucing yang menampilkan gelembung hadiah.
    Yang dipilih adalah kucing pertama dalam urutan `KittyId` yang
    `canClaimKittyReward`, tidak sedang lesu, dan tag "Baru!"-nya sudah hilang.
  - Kalau masih ada kucing lain di ruangan itu yang siap memberi hadiah,
    gelembung diberi tanda kecil "+N lagi". Kunci ARB baru dengan jamak ICU.
  - Setelah gelembung diketuk (`claimKittyReward`), gelembung pindah ke kucing
    berikutnya.
  - Aturan hadiahnya tidak berubah: 10 koin, sekali sehari per kucing, Lapar
    dan Senang ≥ 70.
  - Ikon hadiah di pintu untuk kucing di ruangan sebelah (`doorAttention`) tetap
    seperti sekarang.
- **G3. Kucing berjalan lebih tenang** (keputusan pemilik repo: minimal satu
  kucing bergerak).
  - Diam di tempat diacak 8–20 detik (sekarang 2,6). Memakai barang sekitar
    8–14 detik. Tidur di kasur, hammock, sofa, dan barang lain berjenis
    `sleep`/`lounge` sekitar 20–40 detik.
  - Paling banyak 2 kucing yang sedang berjalan atau melompat di satu ruangan
    pada saat yang sama. Kucing yang mau pergi saat slot penuh menunggu sedikit
    lebih lama dulu.
  - Ruangan yang dibuka (atau baru masuk lewat pintu) tidak pernah terlihat
    beku:
    - Dalam 2–3 detik setelah ruangan dibuka, satu kucing mulai bergerak.
    - Kalau tidak ada yang bergerak selama sekitar 8 detik, satu kucing
      didorong mulai.
    - "Bergerak" = berjalan, melompat, memakai mainan, atau membaca. Tidur dan
      diam tidak dihitung.
  - Lesu, lapar menuju mangkuk, diajak, dan Gang Depan tetap seperti sekarang.
    Kucing lapar tidak ikut dibatasi slot jalan.
- **G4. Kucing tidak berdiri bertumpuk.** Tempat diam dan tempat berdiri di
  depan barang tidak dipilih kalau terlalu dekat dengan kaki kucing lain di
  ruangan yang sama. Kalau tidak ada pilihan lain, kucing tetap diam di
  tempatnya. Kucing yang sedang berjalan boleh lewat saling melintas.
- **G5. Barang baru tidak menumpuk.** Barang yang baru dibeli ditaruh di tempat
  pertama yang muat, dengan urutan:
  1. Spot bawaannya di ruang tengah, atau tempat kosong terdekat
     (`HouseFloor.freeSpot`).
  2. Teras, kalau barang itu boleh di teras.
  3. Gudang.

  Barang dinding: posisi bawaan di dinding ruang tengah, atau posisi lain di
  dinding yang tidak menimpa barang dinding lain, lalu Gudang. Setelah membeli,
  sheet beli tetap menawarkan "Lihat di kamar". Kalau barang masuk Gudang,
  sheet memberi tahu lewat teks baru di keempat ARB.
- **G6. Rumah lama dirapikan** (keputusan pemilik repo: A+B).
  - **A. Otomatis sekali.** Saat simpanan rumah dari versi sebelumnya dimuat,
    kedua ruangan dirapikan satu kali. JSON rumah mendapat tanda bahwa
    perapian sudah dijalankan, jadi tidak diulang. Pemain tidak melihat
    animasi.
  - **B. Tombol "Rapikan" di mode Hias.** Letaknya di kiri, berseberangan
    dengan "Selesai". Hanya ruangan yang dibuka yang dirapikan.
    - Barang yang menumpuk meluncur ke tempat kosong terdekat di ruangan itu.
    - Barang yang tidak kebagian tempat masuk Gudang, tidak ke ruangan lain.
    - Barang yang tidak menumpuk tidak disentuh.
    - Lalu muncul pesan "Sudah rapi! · Batalkan". "Batalkan" mengembalikan
      susunan sebelumnya. Pesannya hilang dengan sendirinya seperti
      `PraiseToast`.
    - Kalau tidak ada yang menumpuk, tombolnya tetap ada dan pesannya
      "Sudah rapi!" saja, tanpa Batalkan.
  - **Arti "menumpuk"** (keputusan pemilik repo: pilihan C).
    - Diukur dari kotak gambar barang di layar (`RoomGeometry.boxOf`, atau
      padanannya di koordinat desain 390×652), bukan alas tipis
      `HouseFloor.footprint`.
    - Dua barang dianggap menumpuk kalau bagian barang belakang yang tertutup
      barang depan lebih dari sekitar seperempat (25 %) luas gambar barang
      belakang. Barang belakang = yang kakinya lebih jauh. Barang depan boleh
      menutupi bagian bawah barang belakang sampai batas itu.
    - Aturan yang sama dipakai untuk barang dinding (saling timpa > 25 % =
      menumpuk), untuk `buy` (G5), untuk perapian A dan B, dan untuk
      pemindahan barang penutup jalur pintu di `Room.fromJson`, supaya
      semuanya konsisten.
    - Untuk itu dibuat tes tumpang tindih baru berbasis kotak gambar
      (Dart murni). `freeSpot` menerima tes itu atau diganti versinya;
      `footprint` lama tetap untuk jalur pintu.
    - Akibatnya rumah yang sangat penuh bisa mengirim beberapa barang ke
      Gudang. Itu diterima.
  - Aturan rapi (dipakai A dan B):
    - Barang lantai yang tidak rata diproses urut katalog. Barang yang tidak
      menimpa barang yang sudah diproses tetap di tempatnya. Barang yang
      menimpa dipindah ke `freeSpot`; kalau tidak ada tempat, ke Gudang.
    - Karpet (barang rata) tidak dihitung menumpuk.
    - Mangkuk tidak pernah ke Gudang; ia selalu dapat `allowedSpot`. Mangkuk
      diproses pertama, jadi barang lain yang menimpanya yang dipindah.
    - Barang dinding yang saling timpa juga dipisah.
    - Gantungan teras tidak berubah karena posisinya tetap.
- **G7. Mangkuk dan label di tepi.**
  - Oyen yang makan tidak boleh terpotong tepi layar. Mangkuk di dekat tepi
    digeser ke dalam (lewat `allowedSpot` atau batas spot mangkuk), atau
    tempat berdiri kucing di mangkuk dijepit ke dalam ruangan.
  - `BowlRefillLabel` dan gelembung pikiran tidak menimpa kucing yang sedang
    makan atau berdiri di mangkuk.
  - Dicek dengan potret `19-kamar*`.
- **G8. Rak Buku** (barang ke-21; `RoomItemId.rakBuku`).
  - Barang lantai, harga 220 koin, jenis pakai baru `ItemUse.read`, bukan
    mainan, hanya di ruang tengah.
  - Gambar belakang dan depan, serta tabel dipakai, disalin dari
    `Barang.dc.html`:
    - Ukuran `[112, 140, 150, 152]`, offset seni `[38, 8]`.
    - Kucing `[0, 52, 100, 'baca']`, menghadap kanan (`catDir`).
  - Nama dan deskripsi di keempat ARB, dengan nada santai.
  - Kartu Toko di tab Barang, ikut urutan kartu desain Toko kalau ada; kalau
    tidak, di sebelah Rak Dinding.
- **G9. Pose baca.**
  - `KittyPose.baca`, bersama `kittySvg` dan `kittyKeyframes` baru
    (`kcPage`, `kcRead`), dibuat ulang dengan
    `python tool/design/make_lane_svg.py … --kitty …`. Tidak diketik tangan.
  - Kacamata baca otomatis muncul kecuali kucing memakai aksesoris
    `kacamata`; logika `kacaBaca` ikut desain.
  - Label pembaca layar "membaca buku", "berkacamata baca" di keempat ARB.
  - Rutinitas: `ItemUse.read` punya bobot undian seperti `sit`/`watch`, dan
    lamanya seperti "memakai barang" di G3. `LifePose` baru bila perlu.
  - Muncul di galeri `/galeri/kucing` dan `/galeri/gerak`.

## Bukan tujuan

- Mengubah aturan, jumlah, atau jadwal hadiah koin.
- Mengubah gambar ruangan, panel bawah, atau header.
- Ruangan ketiga atau barang lain selain rak buku.
- Membuat kucing membaca di luar rak buku. Artboard 15 menampilkan Oyen
  membaca di lantai depan rak; itu dianggap contoh susunan ruangan saja.
  Game memakai tabel "dipakai".

## Anti-tujuan

- Rumah terasa mati. Kalau pemain membuka rumah dan tidak ada yang bergerak
  beberapa detik, langkah ini gagal.
- Barang pemain hilang atau pindah ruangan tanpa jejak. Barang yang terkena
  perapian hanya bergeser di ruangannya atau masuk Gudang, dan B bisa
  dibatalkan.
- Ketukan ganda di "Rapikan" atau di gelembung hadiah memberi efek dua kali.

## Batasan

- Logika rutinitas, perapian, dan penempatan barang ditulis sebagai Dart murni
  di `lib/game/model/` dan diuji unit test ber-seed.
- Gambar disalin dari desain lewat alat (`make_lane_svg.py --kitty`).
  `roomItemBackSvgs`/`roomItemFrontSvgs` disalin utuh, dan
  `design_sync_test` diperbarui supaya mengenal sumber Gang Depan untuk rak
  buku.
- Semua teks baru ada di keempat ARB. `make_review.py` dijalankan ulang.
- Kinerja: rak buku diam dibungkus `RepaintBoundary` seperti barang lain.
  Halaman yang dibalik memakai varian `bind`. `tool/profile_room.dart` ikut
  memasang rak buku, jadi isinya 21 barang.
- Overflow test: kamar penuh sekarang berisi 21 barang. Mode hias dengan
  tombol Rapikan dicek di 360×640, teks 130%, keempat bahasa.

## Pendekatan yang ditimbang

Pemilik repo menyerahkan cara membangunnya ("mengikuti semua arahanmu").
Pilihan di bawah adalah keputusanku.

**Rutinitas tenang (G3):**
1. *Hanya memperpanjang lama diam/pakai.* Paling sederhana, tapi rumah bisa
   beku lama dan tetap bisa banyak kucing jalan bersamaan saat kebetulan.
   Ditolak.
2. **Dipilih: "pengatur giliran" di `RoomLife`.** Lama diam diperpanjang,
   ditambah batas 2 kucing berjalan per ruangan dan dorongan kalau ruangan
   yang ditonton diam.
   - `RoomLife` tahu ruangan mana yang ditonton lewat field baru (mis.
     `watching`) yang diisi `RoomView` saat pindah ruangan.
   - Dorongan hanya untuk ruangan yang ditonton. Ruangan lain cukup memakai
     batas dan lama diam.
   - Semua ber-seed, jadi bisa diuji.
3. *Jadwal tetap (kucing bergiliran menurut urutan).* Terlalu mekanis dan
   mudah terlihat polanya. Ditolak.

**Hadiah bergiliran (G2):** dipilih di lapisan layar (`RoomView`), karena
aturan hadiah di model tetap. Pilihan kucing dibuat fungsi murni kecil supaya
bisa diuji.

**Perapian (G5, G6):** satu fungsi `Room.tidy(room, floor)` (nama bebas) yang
dipakai muat-sekali, tombol, dan `buy`, di atas `HouseFloor.freeSpot` yang
sudah ada. Alternatif "susun ulang seluruh ruangan ke kisi" ditolak karena
menggeser barang yang sudah rapi.

## Yang diputuskan pemilik repo

- Hapus kotak "Hiasan dinding?" dan "Kasur, mungkin?".
- Hadiah koin: pilihan C, bergiliran dengan "+N lagi".
- Minimal satu kucing bergerak.
- Rumah lama: A+B.
- "Menumpuk" = kotak gambar tertutup lebih dari ±25 %; barang depan boleh
  menutupi sedikit bagian bawah barang belakang (pilihan C, usulanku).
- Desain rak buku dan pose baca dari Claude Design, sudah dicek dan disetujui.
- Harga 220 koin, dan posisi baca mengikuti tabel "dipakai" (usulanku,
  disetujui).

## Diserahkan ke pembangun

- Angka pasti dalam rentang G3 (diam 8–20, pakai 8–14, tidur 20–40 detik;
  dorongan ±8 detik; mulai 2–3 detik), selama terasa tenang tapi hidup di HP.
- Letak tanda "+N lagi" terhadap gelembung (contoh kasar di visual companion:
  chip kecil gelap).
- Jarak minimum antar kaki kucing di G4 (usul ± 40 px desain).
- Animasi geser barang saat "Rapikan" (usul 300 ms `easeOut`; langsung saat
  kurangi gerak).
- Cara pasti memperbaiki mangkuk di tepi (G7).
- Bobot undian rak buku.
- Angka pasti batas tertutup (sekitar 25 %), asal hasilnya di potret
  `19-kamar*` terlihat tidak bertumpuk.
