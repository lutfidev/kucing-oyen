# Langkah 25: peta bergambar dan Oyen berjalan ke level berikutnya

Dokumen ini merinci langkah 25 `docs/ROADMAP.md`. Spesifikasi induknya adalah `docs/superpowers/specs/2026-10-26-rumah-oyen-design.md`, bagian "Peta bergambar". Pemilik repo menyerahkan semua keputusan yang belum diputuskan roadmap, spesifikasi, dan desain kepada saya ("bebas, ikut kamu, tapi yang bagus", 2 November 2026).

Penanda keputusan:

- **[roadmap]** diambil dari prompt langkah 25.
- **[spek]** diambil dari spesifikasi rumah Oyen.
- **[desain]** diambil dari desain.
- **[saya]** keputusan saya, berdasarkan wewenang dari pemilik repo.

## Maksud

Sekarang peta babak masih desain 02: bulatan angka di lantai kayu, dan "Lanjut" langsung melompat ke level berikutnya. Pemilik repo merasa bolak-balik antara peta dan level itu hambar. Peta yang baru berupa ruangan bergambar. Tiap level punya benda rumah sendiri, dan Oyen terlihat berdiri di level saat ini. Sesudah menang, pemain melihat Oyen berjalan ke level berikutnya sebelum level itu dibuka. Momen inilah intinya. Gerakannya harus terasa hidup: berjalan menyusuri jalur, bukan meluncur lurus.

## Sumber desain

Semua ada di `docs/design/rumah-oyen/project/`. Kalau folder itu tidak ada, unduh ulang lewat alat Artifact sesuai `CLAUDE.md`.

- `PetaBergambar.dc.html` adalah komponen peta, dengan prop `babak` (1/2) dan `mode` (normal/jalan/pindah). Isinya:
  - latar per babak dan dekor ruangan
  - area bos
  - jalur `roadD` (kurva halus lewat 10 titik `pts`)
  - jejak kaki
  - node
  - token
  - header dan kartu babak lain
  - kartu "Babak baru terbuka!"
- `PetaDapur` (Babak 1), `PetaJalan` (Oyen berjalan 12→13), dan `PetaPindah` (pindah babak) memakai komponen itu dengan prop berbeda.
- `TitikLevel.dc.html` adalah node bergambar. Ada 20 ikon benda (viewBox 48), keadaan selesai/sekarang/terkunci, chip nomor, gembok, bintang, label "Main", denyut `tlvPulse`, dan versi bos (kotak 100 px, label nama bos).
- `TokenOyenPeta.dc.html` adalah alas elips ditambah sprite `Kucing` Oyen 56 px. Prop-nya `pose` (idle/walk/walk1/walk2/happy), `dir` (down/left/right), dan `aksesoris`.
- `canvas.json` `n360` (bagian Peta) mengatur layar 360×640: titik level 64→54 px, jalur dirapatkan 12%, bos 100→84 px.

Isi `<svg>` disalin utuh ke `design_svg_home.dart` dan digambar lewat `SvgTemplate`, seperti langkah 21–24 [spek]. `design_sync_test` diperluas untuk keenam berkas ini.

## Tujuan

### Peta (`ChapterMap` dan `ChapterView`)

- **Latar dan dekor per babak** [desain]:
  - Babak 1 Dapur: ubin kotak-kotak `conic-gradient`, dekor jendela/kulkas, lemari kiri, dan keset.
  - Babak 2 Ruang Tamu: lantai papan dan karpet elips, sofa kanan, dan tanaman kiri.
  - Area bos dan jalur bergaris putus-putus ada di keduanya.
  - Lantai kayu `_Floor` lama diganti latar per babak.
- **Titik node** pakai `pts` desain 23 (lain dengan `MapArt.points` desain 02), sama untuk kedua babak [desain]. Jejak kaki mengikuti cara desain 23 (t 0,38/0,62, geser 5, jelas 0,95 sebelum level saat ini, samar 0,35 sesudahnya).
- **Node bergambar** (`TitikLevel`) [desain]:
  - Benda per level urut daftar `D1`/`D2` desain. Bos memakai `pestaIkanAsin` dan `ketupat`.
  - Keadaan memakai `NodeState` yang sudah ada.
  - Node saat ini berdenyut dan berlabel "Main". Node selesai menampilkan bintang. Node terkunci pudar, berbintik putus-putus, dan bergembok.
  - Node terbuka bisa diketuk untuk membuka level, seperti sekarang.
- **Label pembaca layar node** tetap memakai pola `LevelNode.labelOf`/`bossNodeLabel` yang ada: nomor, nama level dari data, keadaan, dan bintang [saya]. Nama benda di desain ("Kulkas", "Rak TV") tidak dibacakan dan tidak diterjemahkan. Gambar benda hanya hiasan, dan nama level lebih berguna bagi pemain. Akibatnya tidak perlu menambah 20 nama benda di empat ARB.
- **Token Oyen** (`TokenOyenPeta`) berdiri di atas kanan node sasaran, di `(x+18, y-92)` relatif kiri-atas token desain [desain]. Token memakai aksesoris yang sedang dipakai Oyen di rumah [saya]. Ini menyambung peta dengan kamar, dan karena aksesoris tidak menutup wajah, aman ditampilkan.
- **Sasaran token** [saya]:
  - Level saat ini (`progress.current`) kalau ada.
  - Kalau babak sudah selesai semua, token di bos.
  - Kalau babak terkunci, token tidak ada.
  - Kalau peta dibuka dari "Lanjut" (lihat bawah), sasarannya level tujuan jalan.
- **Header** sama dengan sekarang (kembali ke kamar, overline babak, judul, chip bintang /30, kartu babak lain). Bedanya, pudar header ikut warna latar babak [desain].
- **Gulir**: peta tetap selebar layar dengan skala lebar ÷ 390 dan bisa digulir. Peta dibuka dengan token Oyen di tengah tempat peta, bukan lagi node level saat ini [roadmap].
- **Ruang di atas peta** [saya]: pada desain, token di level 2 dan 12 (titik y 236, atas token y 144) setengah tertutup pudar header (y 140–184). Karena itu peta yang digulir diberi ruang kosong 56 px desain di atasnya. Saat gulir paling atas, token itu terlihat utuh di bawah header. Ruang ini berlaku juga untuk teks 130%, karena peta tetap mulai dari bawah header yang sebenarnya.
- **Ukuran node** 66 px dan bos 100 px [desain]. **Layar kecil** (tinggi di bawah `roomCompactHeight`, pola langkah 23) memakai ukuran `n360`: node 54, bos 84, dan jarak vertikal antartitik 88% [desain; ambang dari saya]. Pudar header berwarna krem `#FFF4E2` di kedua babak [desain].

### "Lanjut" sesudah menang [roadmap, spek]

- `LevelScreen._next` membuka **peta babak level berikutnya**, dengan keterangan dari level mana pemain datang. Caranya lewat parameter query, misalnya `AppRoutes.chapter(n, from: id)` → `/babak/n?dari=id` [saya]. Simpanan tidak berubah, dan kembali dari level tetap menuju peta.
- **Level biasa** (sesudahnya ada level di babak yang sama), berlaku juga untuk level lama yang diulang:
  1. Peta dibuka dengan token di node level `id`, dan gulir awal menuju token.
  2. Sesudah jeda singkat (≈0,3 detik, supaya pemain sempat melihat peta), Oyen **berjalan menyusuri jalur** (segmen kurva `roadD` antara dua titik) selama 1 detik. Bingkainya `walk1`/`walk2` (`KittyLook.walkPose`), arah kiri/kanan mengikuti gerak mendatar, dan kurvanya `easeInOut` [saya; desain memakai transisi lurus 1,5 detik, tapi roadmap meminta ≈1 detik, dan menyusuri jalur lebih hidup].
  3. Oyen sampai, pose diam sebentar (≈0,25 detik), lalu level `id+1` terbuka sendiri lewat rute level biasa.
  4. **Sentuhan di mana saja selama jalan dan jeda** membatalkan pembukaan otomatis, termasuk sentuhan di header dan awal gulir. Oyen tetap menyelesaikan jalannya. Sentuhan yang membatalkan tidak ikut menekan node atau tombol di bawahnya [saya], supaya pemain tidak tiba-tiba masuk level lain.
  5. Kembali sistem selama jalan juga membatalkan, lalu berlaku seperti biasa (ke kamar).
  6. **Sesudah level yang terbuka sendiri ditutup** (kembali atau kalah), peta dibuka lagi tanpa `?dari=`. Token kembali ke level saat ini (`progress.current`) [saya]. Untuk level lama yang diulang, artinya token pindah dari level yang baru dilewati ke level paling depan. Ini sengaja, karena posisi Oyen yang tetap selalu "level yang harus dimainkan berikutnya", dan rute tidak perlu menyimpan keadaan.
- **Pembaca layar aktif** (`MediaQuery.accessibleNavigation`): Oyen tetap berjalan (atau langsung pindah dengan kurangi gerak), tapi **tidak ada pembukaan otomatis** [saya]. Pengguna TalkBack tidak sempat mendengar pengumuman dan membatalkannya, dan ketuk ganda akan mengaktifkan elemen yang sedang difokus. Saat Oyen sampai, diumumkan "Oyen sampai di level 13", lalu pemain membuka level lewat node seperti biasa. Lapisan penangkap sentuhan tidak dipasang dalam mode ini.
- **Kurangi gerak** (`disableAnimations`): token langsung di node `id+1`. Level tetap terbuka sendiri sesudah jeda yang sama (≈0,6 detik), dan ketukan tetap bisa membatalkan [saya]. Alurnya sama dengan gerak penuh, hanya tanpa gerak.
- **Sesudah level 10** (bos Babak 1):
  - Yang dibuka peta Babak 2 dengan Oyen di level 11, tanpa jalan dan tanpa buka otomatis [roadmap].
  - Kalau level 10 baru pertama kali dimenangkan di kunjungan level itu, kartu **"Babak baru terbuka!"** (desain 23c) muncul di atas peta [saya]. Isinya judul babak baru, gambar pintu dengan Oyen berjalan, "N level baru · Bos: <nama bos>", dan tombol "Ayo masuk!" yang menutup kartu.
  - Kartu juga bisa ditutup dengan kembali sistem atau ketuk latar. Dengan kurangi gerak, kartu tampil tanpa animasi masuk.
  - Kalau level 10 diulang sesudah pernah menang, kartu tidak muncul. Penanda "pertama kali" ikut di rute (misalnya `?baru=1`), dihitung `LevelScreen` dari `isWon` saat level dibuka. Jadi tidak ada simpanan baru [saya].
- **Sesudah level 20**: peta Babak 2 dengan Oyen berdiri di bos, pose `happy`, tanpa jalan dan tanpa buka otomatis [roadmap; pose dari saya].
- **"Main" dari kamar** hanya membuka peta `currentChapter`, tanpa jalan [roadmap].

### Teks baru (keempat ARB) [roadmap]

Kalimat Indonesia mengikuti desain, dan bahasa lain dengan nada santai yang sama:

- "Babak baru terbuka!", "Ayo masuk!", "{count} level baru · Bos: {boss}" (jamak ICU).
- Label dialog kartu pindah babak.
- Pengumuman pembaca layar saat Oyen sampai: "Oyen sampai di level {number}." Hanya dipakai saat pembaca layar aktif, karena di mode itu tidak ada buka otomatis [saya].
- Label token Oyen untuk pembaca layar tidak perlu; node saat ini sudah membacakan "main sekarang".

## Bukan tujuan

- Kartu "Berhasil!" di peta prototipe 23 (`berhasilOn`). Itu peraga desain; layar hasil langkah 8 tetap dipakai [saya].
- Mengubah aturan main, progres, bintang, koin, atau simpanan.
- Peta babak 3+, atau peta yang memperlihatkan dua babak sekaligus.
- Suara baru. Jalan Oyen senyap seperti langkah jalan di fase jalan [saya].

## Jangan sampai

- Level terbuka sendiri padahal pemain sudah mengetuk, atau ketukan pembatal malah membuka level lain.
- Gambar desain diketik ulang (lihat Sumber desain).
- `pumpAndSettle` macet. Denyut node dan jalan Oyen mengikuti pola peta sekarang: `settle`, `TickerMode`, dan `disableAnimations`.
- Pewaktu buka otomatis yang tetap menyala sesudah layar ditutup (dispose), atau membuka level dua kali.
- Teks yang terpotong di 360×640 dengan teks 130% di keempat bahasa.

## Test [roadmap]

- Lanjut biasa: peta level berikutnya, token berjalan, level terbuka sendiri.
- Pembukaan dibatalkan dengan ketukan, tanpa node ikut tertekan.
- Level lama yang diulang.
- Sesudah level 10: Babak 2, Oyen di 11, kartu pindah hanya kali pertama, tanpa buka otomatis.
- Sesudah level 20: Oyen di bos, tanpa buka otomatis.
- Kurangi gerak.
- Pembaca layar aktif: tanpa buka otomatis, ada pengumuman sampai.
- Label pembaca layar node.
- Gulir awal menuju token.
- "Main" dari kamar tanpa jalan.
- Test lama `progress_flow_test` "Lanjut sesudah level 10 dan 20" diperbarui, dan `home_chapter_test` disesuaikan dengan titik dan node baru.
- Gambar: warna piksel node dan token di koordinat desain, posisi di jalur pada waktu tertentu.
- `overflow_test`: peta kedua babak, termasuk saat Oyen berjalan dan saat kartu pindah tampil.
- Potret layar peta per bahasa (Babak 1 dan Babak 2).

## Diserahkan ke builder

- Pembagian kelas dan berkas (misalnya `map_walk.dart` Dart murni untuk posisi di kurva per waktu, dan pemisahan `chapter_map.dart` yang sudah 560 baris).
- Cara menahan ketukan pembatal (lapisan penangkap di atas peta selama jalan).
- Nilai persis jeda, selama masih dalam kisaran di atas.
- Penamaan token warna baru di `KoColors` (latar dapur, karpet, dan lain-lain), mengikuti aturan tidak ada warna hardcode.

Catatan dicatat di `docs/DESIGN_NOTES.md` bagian "Langkah 25", dan bagian "Struktur" di `CLAUDE.md` diperbarui [roadmap].
