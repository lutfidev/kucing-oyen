# Langkah 12: Petunjuk dan koin

Dokumen desain hasil brainstorming dengan pemilik repo (17 Oktober 2026). Sumber lain tetap berlaku: `docs/ROADMAP.md` langkah 12, GDD bagian "Petunjuk", dan desain `docs/design/source/10-petunjuk.html` (harga, teks, dan gaya diambil persis dari sana).

## Maksud

Pemain yang buntu bisa membuka petunjuk sedikit demi sedikit, tanpa langsung dikasih jawaban. Tiap tingkat dibuka dengan menonton iklan (gratis) atau membayar koin; pemain yang memilih. Koin adalah mata uang game: sekarang untuk petunjuk, di langkah 13 untuk kostum Oyen (Kacamata 45, Peci 60, Sarung 90, Topi Koki 150). Koin didapat dengan bermain baik, supaya pemain terdorong mengejar 3 bintang.

## Tujuan

1. **Koin dari bintang baru.** Setiap bintang yang *pertama kali* didapat di sebuah level memberi **10 koin**. Menang 2 bintang pertama kali = +20; kemudian 3 bintang di level yang sama = +10; mengulang level yang sudah 3 bintang = +0. Total 60 bintang = 600 koin. Saldo awal 0. Koin diberikan saat bintang dicatat (layar hasil dibuka, lewat `ProgressController.record`).
2. **Tiga tingkat petunjuk per level**, dibuka berurutan (tingkat 2 terkunci sampai tingkat 1 terbuka, dst.), harga persis desain 10: **20, 40, 80 koin**, atau "Tonton iklan".
   - Tingkat 1: sorot petak benda pertama.
   - Tingkat 2: sebut jenis benda untuk petak itu.
   - Tingkat 3: tampilkan solusi bintang 3 lengkap.
   - "Benda pertama" = `level.solution[0]`; "solusi lengkap" = seluruh `level.solution` (sudah terbukti solusi minimum di langkah 2). Untuk level 13 hasilnya sama dengan contoh desain: ember di (3,3), lalu ikan di (2,4).
3. **Petunjuk tetap di papan.** Setelah sheet ditutup, petunjuk yang terbuka tetap tampil selama fase atur: petak petunjuk menyala, dan mulai tingkat 2 benda petunjuknya digambar samar (`paintItemArt(..., ghost: true)`) di petak itu. Petunjuk tidak menaruh benda; pemain tetap menaruh sendiri.
4. **Memakai petunjuk tidak mengurangi bintang maupun koin** (keputusan pemilik repo).
5. **Tersimpan.** Saldo koin dan tingkat petunjuk tertinggi yang terbuka per level disimpan di perangkat, lewat `ProgressStore` seperti progres dan tutorial. Membuka level lagi tidak perlu membayar lagi.
6. **Iklan palsu.** Antarmuka `RewardedAds` dengan implementasi palsu yang selalu berhasil. SDK asli dipasang di langkah iklan asli (lihat bagian Roadmap).
7. **Saldo terlihat** di chip koin Beranda (kiri atas, desain 01, yang di langkah 9 ditunda) dan chip koin sheet Petunjuk (desain 10). Layar hasil yang memberi koin (Berhasil, Vas pecah) menampilkan "+N koin"; kalau N = 0 tidak ditampilkan.

## Bukan tujuan langkah ini

- Tonton iklan untuk menambah koin, dan bonus harian. Pemain menyetujui keduanya untuk langkah berikutnya: dicatat di `docs/ROADMAP.md` (lihat bagian Roadmap), tidak dikerjakan sekarang.
- SDK iklan asli (`google_mobile_ads`).
- Lemari kostum (langkah 13). Chip koin Beranda belum bisa ditekan.

## Jangan sampai

- Koin bisa "digiling" dengan mengulang level yang sama.
- Petunjuk menaruh benda sendiri, atau benda petunjuk tampak sama dengan benda pemain sehingga pemain mengira sudah terpasang.
- Teks petunjuk yang hanya cocok untuk satu level (contoh desain "ikan asin tepat di kiri mangkuk" hanya benar di level 13).
- Pemain membayar koin dua kali untuk tingkat yang sama.

## Rincian yang sudah diputuskan

### Sheet Petunjuk

- Dibuka dari tombol bohlam bulat di bar atas fase atur, sesuai desain 03 (`aria-label="Petunjuk"`, di samping chip target). Tidak tampil di fase jalan. Ikuti pola `RulesButton`/`showRulesSheet` langkah 11 (cara menutup: tombol tutup, latar, kembali, tarik).
- Isi dan gaya persis desain 10: judul "Petunjuk", ikon bohlam, chip saldo, tombol tutup, kalimat "Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil.", tiga kartu dengan nomor, judul ("Sorot petak pertama", "Tunjukkan jenis benda", "Tampilkan solusi lengkap"), subjudul ("Tingkat N", "Terbuka", "Buka tingkat N dulu"), tombol "Tonton iklan" dan "N koin", kartu terbuka menampilkan teks petunjuk di kotak hijau muda.
- **Koin tidak cukup** (keputusan saya): tombol koin berlabel "Koin kurang · N" seperti tombol beli di desain 12, dan tidak melakukan apa-apa saat ditekan. "Tonton iklan" tetap bisa.
- **Level tanpa benda** (level 1 dan 2, `solution` kosong; keputusan saya): sheet tetap terbuka dari tombol yang sama, tetapi tanpa tiga tingkat. Isinya satu kartu gratis bergaya kartu terbuka: "Level ini nggak butuh benda. Langsung bangunkan Oyen!"

### Teks petunjuk

- Tingkat 1: persis desain, "Lihat petak yang menyala. Ada benda yang harus ditaruh di situ."
- Tingkat 2: "Taruh {nama benda} di petak yang menyala. {akibat}". Nama benda dalam huruf kecil dari `itemName` ("ikan asin", "ember air", "kardus"). Akibat per jenis:
  - ember air: persis desain, "Oyen bakal kaget dan balik badan."
  - ikan asin: kalimat santai senada, misalnya "Oyen bakal ngejar dan makan ikannya."
  - kardus: kalimat santai senada, misalnya "Oyen bakal masuk dan duduk di situ."
- Tingkat 3: kalimat umum yang benar untuk semua level, menyebut benda yang dipakai dan bahwa semuanya di petak yang menyala, lalu 3 bintang. "Vas aman" hanya disebut kalau peta level punya vas. Contoh level 13: "Ember air dan ikan asin di petak yang menyala. Vas aman, 3 bintang." Contoh level 5: "Dua ikan asin di petak yang menyala. 3 bintang!" Kalimat persisnya diserahkan ke pembangun, asal santai, Bahasa Indonesia, dan tidak menyebut arah tetap yang salah.

### Papan

- Tingkat 1: petak `solution[0]` menyala.
- Tingkat 2: ditambah gambar samar benda `solution[0]` di petak itu.
- Tingkat 3: semua petak `solution` menyala dengan gambar samar bendanya.
- Petak petunjuk yang sudah diisi pemain berhenti menyala dan gambar samarnya tertutup benda asli. Pengecualian (keputusan saya): kalau jenis benda petak itu sudah dibuka (tingkat 2 untuk petak pertama, tingkat 3 untuk semua) dan pemain menaruh benda lain, petak tetap menyala supaya pemain tahu ada yang salah. Di tingkat 1 benda apa pun memadamkan nyala, supaya jenis benda tidak bisa ditebak gratis dengan coba-coba.
- Saat menyeret, yang menyala hanya petak tujuan di bawah jari (keputusan langkah 6), jadi petak petunjuk tetap mudah dibedakan.
- Gaya menyala sama dengan petak menyala saat menyeret. Petak menyala desain berkedip (`koGlow`). Mesin `KucingGame` hanya berjalan selama ada yang berkedip, jadi selama petunjuk tampil mesin terus berjalan: test layar level dengan petunjuk terbuka tidak boleh `pumpAndSettle` (catat di `CLAUDE.md` seperti catatan denyut peta).

### Koin di layar hasil (keputusan saya)

Layar Berhasil dan Vas pecah menampilkan koin yang baru didapat sebagai satu `ResultStat` tambahan (ikon koin, "+N", label "koin") di samping langkah dan benda, hanya kalau N > 0. Desain 06 dan 07 tidak punya ini; buat dengan gaya yang sama dan catat di `docs/DESIGN_NOTES.md`.

### Data dan penyimpanan

- Koin: saldo disimpan sebagai angka. Penambahan dihitung di `record`: (bintang baru − bintang terbaik lama) × 10, hanya kalau positif. Pengeluaran lewat aksi yang menolak kalau saldo kurang.
- **Pemain lama** (keputusan saya): kalau kunci koin belum pernah tersimpan tetapi progres sudah ada (perangkat pemilik repo), saldo awal = total bintang × 10, supaya bintang yang didapat sebelum langkah ini tetap dihitung.
- Petunjuk: tingkat tertinggi yang terbuka per id level (0–3). Data rusak dibuang seperti `Progress.fromJson`.
- Membuka tingkat dengan iklan: panggil `RewardedAds` (asinkron, supaya iklan asli nanti tinggal dipasang). Iklan palsu langsung berhasil tanpa layar iklan tiruan. Selama menunggu, kedua tombol tingkat itu tidak bisa ditekan. Kalau hasilnya tidak berhasil, tingkat tidak terbuka dan kartunya menampilkan kalimat singkat "Iklannya belum bisa diputar. Coba lagi nanti, ya." (keputusan saya). Membuka dengan koin: kurangi saldo dan buka tingkat bersamaan, lalu simpan.
- Logika petunjuk (petak dan benda per tingkat, teks) ditulis sebagai Dart murni di `lib/game/model/`, supaya bisa diuji tanpa layar.

### Test (dari roadmap, ditambah keputusan di atas)

- Urutan buka tingkat (tingkat 2 dan 3 tidak bisa dibuka lebih dulu), koin berkurang sesuai harga, koin kurang ditolak, iklan membuka tanpa koin.
- Koin dari bintang baru: pertama kali, naik bintang, ulang tanpa tambahan, gagal tanpa tambahan, pemain lama.
- Simpan dan muat koin serta petunjuk lewat `PrefsProgressStore` dan `MemoryProgressStore`.
- Petunjuk tampil di papan per tingkat (`BoardScene`/glow/benda samar) dan tetap ada setelah sheet ditutup.
- Teks tingkat 2 dan 3 untuk setiap level 3–20 tidak kosong dan menyebut benda yang benar; level 1–2 menampilkan pesan tanpa benda.
- Sheet Petunjuk dan Beranda dengan chip koin masuk `test/screens/overflow_test.dart` (360×640 sampai 412×915, teks 100% dan 130%).
- Potret layar sheet Petunjuk di `test/screenshots/`.

## Roadmap

Sesuai permintaan pemilik repo, tambahkan ke `docs/ROADMAP.md` langkah baru **"14. Koin tambahan: tonton iklan dan bonus harian"** (tonton iklan berhadiah untuk menambah koin, dan bonus koin harian), lalu geser "Polish dan rilis Android" menjadi langkah 15. Langkah 15 tetap memasang SDK iklan asli yang menggantikan `RewardedAds` palsu. Penomoran baru dan penempatan ini keputusan saya. Prompt langkah 14 menyebut bahwa desainnya belum ada dan harus dibuat dengan gaya yang sama, dan bahwa angka hadiah ditanyakan ke pemilik repo di awal sesi.

## Diserahkan ke pembangun

- Nama kelas, file, dan kunci penyimpanan, asal mengikuti pola yang sudah ada (`ProgressStore`, `ProgressController`, `rules_sheet.dart`).
- Cara `RewardedAds` disuntikkan ke layar, asal test bisa memakai versi palsu dan versi gagal.
- Apakah petak petunjuk berkedip atau menyala diam, asal tampilannya sama dengan gaya menyala desain dan catatan test di atas ditulis.
- Kalimat persis teks tingkat 2 (ikan, kardus) dan tingkat 3.
