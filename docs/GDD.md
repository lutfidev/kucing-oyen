# Kucing Oren — Dokumen Desain Game

Oct 15, 2026 · @Lutfi

## Ringkasan

Kucing Oren adalah game puzzle mobile untuk semua umur: pemain tidak mengendalikan Oyen, tapi meletakkan benda supaya Oyen sampai ke mangkuk makannya sendiri. Oyen bergerak dengan aturan tetap, jadi tantangannya adalah memprediksi tingkahnya. Semua 20 level di dokumen ini sudah dicek dengan solver: pasti bisa diselesaikan, dan jumlah benda minimum untuk bintang 3 sudah dihitung.

| Aspek | Keputusan |
| --- | --- |
| Judul kerja | Kucing Oren (karakter: Oyen) |
| Genre | Puzzle kendali tidak langsung, berbasis giliran |
| Target | Semua umur, sesi 1–3 menit per level |
| Platform | Android dulu, Flutter + Flame |
| Orientasi | Portrait, grid 7 × 9 petak (area main 5 × 7) |
| Bahasa | Inggris (utama), Indonesia, Portugis Brasil, Rusia; santai dan jenaka (lihat `docs/DESIGN_NOTES.md`, "Sebelum langkah 15") |
| Versi pertama | Babak 1 Dapur + Babak 2 Ruang Tamu, 20 level |

## Aturan Oyen

Setiap langkah, Oyen mengecek aturan dari atas ke bawah dan menjalankan aturan pertama yang cocok. Satu langkah = satu aksi. Urutan ini final dan dipakai solver; "jatuhkan barang" sengaja ditaruh sebelum "lihat ikan" supaya Oyen tetap iseng meski sedang mengejar ikan.

1. **Sudah di mangkuk** → level menang.
2. **Sedang di dalam kardus** → diam. Setelah 2 langkah, kardus penyok dan hilang, lalu Oyen lanjut ke arah yang sama.
3. **Ada barang di meja tepat di sebelahnya** (depan, kanan, kiri, atau belakang) yang belum jatuh → jatuhkan satu barang, menatap pemain. Gelas plastik aman; vas Ibu pecah.
4. **Melihat ikan** dalam garis lurus ke 4 arah → menghadap ke ikan terdekat. Pandangan terhalang tembok, perabot, meja, dan kardus, tapi tidak terhalang air. Kalau jaraknya sama, urutannya: depan, kanan, kiri, belakang.
5. **Petak di depannya**:
   - Air → kaget dan putar balik di tempat.
   - Tembok, perabot, atau meja → belok kanan di tempat.
   - Kardus → masuk dan duduk.
   - Ikan → maju dan memakannya (ikan hilang).
   - Lantai atau mangkuk → maju.

**Mangkuk tidak menarik perhatian Oyen** (ia belum tahu sudah diisi), jadi pemain harus menggiring Oyen sampai lewat di atasnya.

**Gagal** kalau Oyen kembali ke keadaan yang persis sama (mondar-mandir tanpa akhir) atau lewat 80 langkah. Vas pecah tidak menggagalkan level, tapi menghapus bintang 2 dan 3.

## Elemen peta dan benda

Peta level ditulis sebagai teks 9 baris × 7 kolom; setiap karakter satu petak. Format ini bisa langsung disimpan sebagai data level di Flutter. Koordinat ditulis (kolom, baris), dihitung dari 0 di pojok kiri atas.

| Simbol | Elemen | Tampilan | Sifat |
| --- | --- | --- | --- |
| `#` | Tembok / perabot | Dinding, kulkas, lemari, kompor | Menghalangi jalan dan pandangan |
| `.` | Lantai | Ubin dapur / lantai kayu | Bisa dilewati, tempat menaruh benda |
| `^ > v <` | Oyen | Kucing oren tidur, arah hadap sesuai panah | Posisi dan arah awal |
| `T` | Mangkuk makan | Mangkuk biru berisi pakan | Tujuan; tidak menarik Oyen |
| `M` | Meja kosong | Meja kayu | Menghalangi jalan dan pandangan |
| `G` | Meja + gelas plastik | Gelas warna-warni | Dijatuhkan Oyen, aman |
| `V` | Meja + vas Ibu | Vas keramik bermotif | Kalau jatuh: pecah, bintang 2–3 hilang |
| `F` | Ikan asin bawaan | Ikan di piring / tempat sampah | Godaan yang sudah ada di peta |
| `A` | Genangan air | Genangan biru | Oyen putar balik |
| `K` | Kardus bawaan | Kardus cokelat | Menghalangi pandangan; Oyen masuk, duduk 2 langkah, kardus hilang |

**Benda pemain** (jumlah terbatas per level, ditaruh di petak lantai kosong):

| Benda | Kode | Fungsi | Muncul pertama |
| --- | --- | --- | --- |
| Ikan asin | f | Menarik Oyen dari jauh, dimakan saat dilewati | Level 3 |
| Ember air | a | Membuat Oyen putar balik | Level 6 |
| Kardus | k | Menutupi pandangan ke ikan; jadi "gerbang" yang hilang setelah diduduki | Level 14 |

## Alur satu level

1. **Fase atur (Oyen tidur).** Pemain menyeret benda dari baki di bawah layar ke petak lantai kosong. Benda bisa dipindah atau dikembalikan ke baki. Tombol "Lihat aturan" membuka kartu aturan Oyen yang sudah dipelajari.
2. **Bangunkan Oyen.** Simulasi berjalan otomatis, kira-kira 4 langkah per detik. Gelembung pikiran di atas Oyen menunjukkan incarannya (ikon ikan, tanda seru saat kaget air). Tombol percepat ×2 tersedia.
3. **Hasil.**
   - Sampai mangkuk: layar hasil dengan bintang.
   - Mondar-mandir atau kelamaan: Oyen tertidur lagi dengan teks "Oyen bosan...", lalu kembali ke fase atur dengan susunan benda tetap tersimpan.
4. **Putar ulang.** Setelah gagal, pemain bisa memutar ulang langkah demi langkah (maju/mundur) untuk melihat di mana prediksinya meleset.

### Bintang

| Bintang | Syarat |
| --- | --- |
| 1 | Oyen sampai di mangkuk |
| 2 | Sampai, dan tidak ada vas yang pecah |
| 3 | Syarat bintang 2, dan memakai benda paling sedikit (angka "Minimum" di tabel level) |

Di fase atur, layar menampilkan target bintang 3, misalnya "⭐⭐⭐ pakai 2 benda". Baki sengaja berisi lebih banyak benda dari minimum di beberapa level, supaya ada ruang untuk solusi yang boros.

### Petunjuk

Tiga tingkat, dibuka dengan iklan berhadiah atau koin: (1) sorot petak tempat benda pertama, (2) tunjukkan jenis benda untuk petak itu, (3) tampilkan solusi bintang 3 lengkap.

## Babak 1 — Dapur (Level 1–10)

Babak 1 mengajarkan tiga aturan dasar satu per satu: jalan lurus dan belok kanan, ikan, lalu air. Setiap level memperkenalkan paling banyak satu hal baru, dan level 10 menggabungkan semuanya. Di peta, panah ↑ → ↓ ← adalah Oyen beserta arah hadapnya; huruf kecil f, a, k di kolom SOLUSI adalah benda yang ditaruh pemain.

| Level | Nama | Hal baru | Baki | Bintang 3 |
| --- | --- | --- | --- | --- |
| 1 | Bangunkan Oyen | Fase jalan | kosong | tanpa benda |
| 2 | Belok Kanan | Tembok = belok kanan | kosong | tanpa benda |
| 3 | Ikan Pertama | Ikan menarik Oyen | 1 ikan | 1 benda |
| 4 | Ikan Terdekat | Ikan terdekat menang | 1 ikan | 1 benda |
| 5 | Dua Ikan | Ikan berantai | 2 ikan | 2 benda |
| 6 | Ember Pertama | Air = putar balik | 1 ember | 1 benda |
| 7 | Genangan | Genangan bawaan | 1 ikan, 1 ember | 1 benda |
| 8 | Ikan dan Ember | Menggabungkan keduanya | 1 ikan, 1 ember | 2 benda |
| 9 | Ikan Godaan | Menjauhkan Oyen dari ikan bawaan | 1 ikan, 1 ember | 2 benda |
| 10 | BOS: Pesta Ikan Asin | Rantai ikan + ember | 2 ikan, 1 ember | 3 benda |

### Level 1 — Bangunkan Oyen

**Baru:** Tombol "Bangunkan Oyen". **Baki:** kosong. **Bintang 3:** tanpa benda. **Langkah:** 6.

```
AWAL       SOLUSI
#######    #######
#..T..#    #..T..#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#..↑..#    #..↑..#
#######    #######
```

**Solusi bintang 3:** tanpa benda. Oyen berjalan lurus ke atas dan langsung sampai di mangkuk. Tujuannya hanya mengenalkan fase jalan.

### Level 2 — Belok Kanan

**Baru:** Tembok = belok kanan. **Baki:** kosong. **Bintang 3:** tanpa benda. **Langkah:** 10.

```
AWAL       SOLUSI
#######    #######
#...T.#    #...T.#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#↑....#    #↑....#
#######    #######
```

**Solusi bintang 3:** tanpa benda. Oyen naik sampai mentok tembok, belok kanan, lalu menyusuri baris atas ke mangkuk.

### Level 3 — Ikan Pertama

**Baru:** Ikan menarik Oyen. **Baki:** 1 ikan. **Bintang 3:** 1 benda. **Langkah:** 6. (3 solusi minimum)

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#.....#    #.....#
#..T..#    #.fT..#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#↑....#    #↑....#
#######    #######
```

**Solusi bintang 3:** ikan di (2,3). Mangkuk ada di tengah ruangan, jadi tanpa benda Oyen hanya berkeliling menyusuri tembok selamanya. Ikan yang sebaris dengan mangkuk membuat Oyen berbelok dan lewat di atas mangkuk.

### Level 4 — Ikan Terdekat

**Baru:** Oyen memilih ikan terdekat. **Baki:** 1 ikan. **Bintang 3:** 1 benda. **Langkah:** 4.

```
AWAL       SOLUSI
#######    #######
#..F..#    #..F..#
#.....#    #.....#
#.....#    #.....#
#.T...#    #fT...#
#.....#    #.....#
#.....#    #.....#
#..↑..#    #..↑..#
#######    #######
```

**Solusi bintang 3:** ikan di (1,4). Ikan bawaan di atas menarik Oyen lurus naik. Ikan pemain di (1,4) lebih dekat saat Oyen tiba di (3,4) (jarak 2 lawan 3), jadi Oyen belok kiri dan melewati mangkuk.

### Level 5 — Dua Ikan

**Baru:** Dua ikan berantai. **Baki:** 2 ikan. **Bintang 3:** 2 benda. **Langkah:** 3. (3 solusi minimum)

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#.→...#    #.→...#
#..####    #.f####
##.T.##    ##.Tf##
##....#    ##....#
#######    #######
```

**Solusi bintang 3:** ikan di (2,5), ikan di (4,6). Mangkuk tersembunyi di ruang bawah. Ikan pertama menarik Oyen turun ke ruang itu, ikan kedua menariknya ke kanan melewati mangkuk.

### Level 6 — Ember Pertama

**Baru:** Air = putar balik. **Baki:** 1 ember. **Bintang 3:** 1 benda. **Langkah:** 6.

```
AWAL       SOLUSI
#######    #######
#.....#    #..a..#
#..↑..#    #..↑..#
#....##    #....##
##...##    ##...##
##...##    ##...##
##...##    ##...##
#..T..#    #..T..#
#######    #######
```

**Solusi bintang 3:** ember di (3,1). Ember tepat di depan Oyen membuatnya kaget, putar balik, lalu berjalan lurus ke mangkuk di bawah.

### Level 7 — Genangan

**Baru:** Genangan bawaan. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 1 benda. **Langkah:** 11.

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#T....#    #T....#
#...#.#    #f..#.#
##...A#    ##...A#
#.....#    #.....#
####↑.#    ####↑.#
#.....#    #.....#
#######    #######
```

**Solusi bintang 3:** ikan di (1,3). Oyen naik, mentok, belok kanan, lalu kaget oleh genangan dan putar balik ke kiri. Di ujung kiri ia naik, dan ikan di (1,3) menariknya ke pojok tepat di bawah mangkuk. Ember di baki sengaja tidak diperlukan.

### Level 8 — Ikan dan Ember

**Baru:** Ember dan ikan bersama. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 2 benda. **Langkah:** 6.

```
AWAL       SOLUSI
#######    #######
#.....#    #..a..#
#..↑.##    #..↑.##
###...#    ###...#
##....#    ##....#
#.....#    #.....#
#.T...#    #fT...#
#.....#    #.....#
#######    #######
```

**Solusi bintang 3:** ember di (3,1), ikan di (1,6). Ember di depan Oyen membuatnya berbalik turun. Di baris 6, ikan di (1,6) menariknya ke kiri melewati mangkuk.

### Level 9 — Ikan Godaan

**Baru:** Menghindari godaan. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 2 benda. **Langkah:** 5. (2 solusi minimum)

```
AWAL       SOLUSI
#######    #######
#...F.#    #...F.#
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#....F#    #a...F#
#←###.#    #←###.#
#..T.##    #.fT.##
#######    #######
```

**Solusi bintang 3:** ember di (1,5), ikan di (2,7). Ruang atas penuh ikan godaan. Ember di (1,5) mencegah Oyen naik ke sana; Oyen berbalik turun, lalu ikan di (2,7) menariknya ke kanan melewati mangkuk.

### Level 10 — BOS: Pesta Ikan Asin

**Baru:** Bos: rantai ikan. **Baki:** 2 ikan, 1 ember. **Bintang 3:** 3 benda. **Langkah:** 13. (2 solusi minimum)

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#...###    #...###
#↑##T.#    #↑##T.#
#..F..#    #..F..#
#.F...#    #fF...#
#.#...#    #.#.f.#
#.#...#    #.#.a.#
#######    #######
```

**Solusi bintang 3:** ember di (4,7), ikan di (1,5), ikan di (4,6). Oyen memakan ikan satu per satu, termasuk dua ikan godaan, dan setiap ikan mengubah arahnya. Ember di (4,7) membuat Oyen berbalik naik di kolom 4 tepat ke mangkuk.

## Babak 2 — Ruang Tamu (Level 11–20)

Babak 2 menambahkan meja, gelas, vas Ibu, dan kardus. Mulai level 13, menyelesaikan level itu mudah tapi bintang 2–3 menuntut Oyen tidak lewat di sebelah vas. Di peta, `V` = vas (di level 20: opor, toples kue, dan vas), `G` = gelas, `M` = meja kosong, `K` = kardus bawaan.

| Level | Nama | Hal baru | Baki | Bintang 3 |
| --- | --- | --- | --- | --- |
| 11 | Meja Tamu | Meja = tembok | 2 ikan | 1 benda |
| 12 | Gelas Jatuh | Barang jatuh, gelas aman | 1 ikan | 1 benda |
| 13 | Vas Ibu | Vas tidak boleh jatuh | 1 ikan, 1 ember | 2 benda |
| 14 | Kardus Penghalang | Kardus menutupi pandangan | 1 ikan, 1 kardus | 2 benda |
| 15 | Kardus Penyok | Kardus sebagai gerbang | 1 ikan, 1 ember | 1 benda |
| 16 | Jalan Memutar | Bintang 1 vs bintang 3 | 1 ikan, 1 ember | 2 benda |
| 17 | Dua Vas | Vas di dua sisi | 2 ikan, 1 ember | 2 benda |
| 18 | Ruang Sempit | Lorong panjang, 32 langkah | 1 ikan, 1 kardus | 2 benda |
| 19 | Semua Bersama | Ikan, ember, kardus sekaligus | 1 ikan, 1 ember, 1 kardus | 3 benda |
| 20 | BOS: Hari Lebaran | Tiga barang berharga | 2 ikan, 1 ember | 3 benda |

### Level 11 — Meja Tamu

**Baru:** Meja = tembok. **Baki:** 2 ikan. **Bintang 3:** 1 benda. **Langkah:** 9.

```
AWAL       SOLUSI
#######    #######
#....##    #....##
#....T#    #...fT#
#...M.#    #...M.#
#..←..#    #..←..#
#.M...#    #.M...#
#M....#    #M....#
#....M#    #....M#
#######    #######
```

**Solusi bintang 3:** ikan di (4,2). Meja menghalangi jalan dan pandangan seperti tembok. Oyen ke kiri, mentok, naik, lalu ikan di (4,2) menariknya ke kanan ke mangkuk. Baki berisi 2 ikan, tapi bintang 3 cukup 1.

### Level 12 — Gelas Jatuh

**Baru:** Gelas jatuh itu aman. **Baki:** 1 ikan. **Bintang 3:** 1 benda. **Langkah:** 19.

```
AWAL       SOLUSI
#######    #######
#GT...#    #GTf..#
#...GM#    #...GM#
#.....#    #.....#
#.....#    #.....#
#..M..#    #..M..#
#.....#    #.....#
#↑...##    #↑...##
#######    #######
```

**Solusi bintang 3:** ikan di (3,1). Oyen menjatuhkan dua gelas plastik di perjalanan; setiap gelas memakan 1 langkah tapi tidak merugikan. Setelah memakan ikan, Oyen berputar di pojok kanan atas lalu menyusuri baris atas ke mangkuk.

### Level 13 — Vas Ibu

**Baru:** Vas Ibu tidak boleh jatuh. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 2 benda. **Langkah:** 6. (tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#..#..#    #..#..#
#..#..#    #..#..#
#.V.←.#    #.Va←.#
#G.T..#    #GfT..#
#.....#    #.....#
#.....#    #.....#
#..M..#    #..M..#
#######    #######
```

**Solusi bintang 3:** ember di (3,3), ikan di (2,4). Tanpa rencana, Oyen lewat di sebelah vas dan menjatuhkannya. Ember membuat Oyen berbalik ke kanan menjauhi vas, lalu ikan menariknya kembali ke kiri lewat baris 4 ke mangkuk.

### Level 14 — Kardus Penghalang

**Baru:** Kardus menutupi pandangan. **Baki:** 1 ikan, 1 kardus. **Bintang 3:** 2 benda. **Langkah:** 5.

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#.....#    #.....#
#.....#    #.....#
#MM↓..#    #MM↓..#
#F....#    #Fk...#
#....##    #....##
#....T#    #...fT#
#######    #######
```

**Solusi bintang 3:** ikan di (4,7), kardus di (2,5). Ikan godaan di (1,5) akan menarik Oyen ke kiri. Kardus menutupi ikan itu, sehingga Oyen terus turun dan ikan di (4,7) menariknya ke mangkuk.

### Level 15 — Kardus Penyok

**Baru:** Kardus jadi gerbang. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 1 benda. **Langkah:** 12.

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#.....#    #.....#
#..MM.#    #.fMM.#
#FK...#    #FK...#
#....##    #....##
#.←..##    #.←..##
#.T#..#    #.T#..#
#######    #######
```

**Solusi bintang 3:** ikan di (2,3). Di awal, kardus bawaan menutupi ikan pemain dari pandangan Oyen. Oyen memakan ikan godaan di (1,4), naik satu petak, lalu ikan di (2,3) menariknya ke kanan. Meja membuatnya belok turun, masuk kardus, duduk 2 langkah, kardus penyok, lalu Oyen lanjut turun ke mangkuk.

### Level 16 — Jalan Memutar

**Baru:** Bintang 1 itu mudah, bintang 3 butuh rencana. **Baki:** 1 ikan, 1 ember. **Bintang 3:** 2 benda. **Langkah:** 4. (tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#...#.#    #...#.#
#.....#    #.....#
##....#    ##....#
##V...#    ##V...#
#....T#    #...fT#
#..↓.M#    #..↓.M#
#...M.#    #..aM.#
#######    #######
```

**Solusi bintang 3:** ember di (3,7), ikan di (4,5). Tanpa benda Oyen sampai ke mangkuk, tapi lewat dekat vas dan memecahkannya. Ember membuat Oyen berbalik naik, dan ikan menariknya ke kanan ke mangkuk tanpa mendekati vas.

### Level 17 — Dua Vas

**Baru:** Dua vas di dua sisi. **Baki:** 2 ikan, 1 ember. **Bintang 3:** 2 benda. **Langkah:** 9. (2 solusi minimum; tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#↓..#.#    #↓f.#.#
#.....#    #.....#
#...M.#    #...M.#
#V...V#    #V...V#
#....T#    #...fT#
#.....#    #.....#
#######    #######
```

**Solusi bintang 3:** ikan di (2,2), ikan di (4,6). Ikan pertama menarik Oyen ke kanan sebelum ia turun ke dekat vas kiri. Oyen lalu turun di kolom 3, dan ikan kedua menariknya ke mangkuk tanpa menyentuh vas kanan. Ember di baki tidak diperlukan.

### Level 18 — Ruang Sempit

**Baru:** Lorong panjang. **Baki:** 1 ikan, 1 kardus. **Bintang 3:** 2 benda. **Langkah:** 32. (2 solusi minimum; tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#....##    #....##
#TV..↑#    #TV..↑#
#...#.#    #...#.#
#.F##.#    #.F##.#
#..#..#    #.k#..#
#..#..#    #..#..#
#....##    #...f##
#######    #######
```

**Solusi bintang 3:** ikan di (4,7), kardus di (2,5). Ikan memancing Oyen keluar dari lorong kanan. Tanpa kardus, Oyen melihat ikan godaan di (2,4) dari bawah, naik di kolom 2, lalu menjatuhkan vas. Kardus menutup pandangan itu, sehingga Oyen naik lewat kolom 1. Setelah memakan ikan godaan, ia masuk kardus, turun, lalu naik lagi ke mangkuk.

### Level 19 — Semua Bersama

**Baru:** Ketiga benda, satu tujuan. **Baki:** 1 ikan, 1 ember, 1 kardus. **Bintang 3:** 3 benda. **Langkah:** 17. (3 solusi minimum; tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#.....#    #.....#
#..#..#    #..#..#
#.....#    #.....#
#...G.#    #...G.#
#↓...F#    #↓k..F#
#.V.T.#    #aVfT.#
#.#.M.#    #.#.M.#
#######    #######
```

**Solusi bintang 3:** ember di (1,6), ikan di (3,6), kardus di (2,5). Ember membuat Oyen berbalik naik menjauhi vas. Kardus menutupi ikan godaan di ujung kanan, supaya Oyen tidak berjalan di baris 5 yang bersebelahan dengan vas. Oyen berkeliling, menjatuhkan gelas, memakan ikan godaan, lalu ikan di (3,6) menariknya ke mangkuk. Kardus juga boleh di (3,5) atau (4,5).

### Level 20 — BOS: Hari Lebaran

**Baru:** Meja Lebaran. **Baki:** 2 ikan, 1 ember. **Bintang 3:** 3 benda. **Langkah:** 22. (3 solusi minimum; tanpa rencana vas pecah)

```
AWAL       SOLUSI
#######    #######
#.T.#.#    #fT.#.#
#VG.#V#    #VG.#V#
#...#.#    #.f.#.#
#...V.#    #..aV.#
#.....#    #.....#
#↓..M.#    #↓..M.#
#..F..#    #..F..#
#######    #######
```

**Solusi bintang 3:** ember di (3,4), ikan di (1,1), ikan di (2,3). Tiga barang berharga: semangkuk opor di (1,2), toples kue di (5,2), dan vas di (4,4), plus satu gelas. Oyen menyusuri baris bawah, memakan ikan bawaan, naik di kolom 2 menuju ikan (2,3), dan menjatuhkan gelas. Ember menghentikannya sebelum menyentuh vas, lalu ikan di (1,1) menariknya ke mangkuk.

## Babak 3–5 (setelah versi pertama)

Babak berikutnya baru dirancang detail setelah 20 level pertama diuji pemain. Setiap babak menambah satu atau dua aturan baru, dengan generator dan solver yang sama.

| Babak | Latar | Aturan atau elemen baru | Level bos |
| --- | --- | --- | --- |
| 3 | Halaman | Bola benang (Oyen mengejar, bola menggelinding); anjing tetangga yang bergerak dan membuat Oyen kabur; pohon (Oyen naik, diam 3 langkah). Di sini "duduk di kardus" mulai penting untuk mengatur waktu. | Jadwal Mandi: Oyen digiring ke kamar mandi padahal takut air |
| 4 | Pasar Ikan | Banyak ikan godaan; pedagang yang mengusir Oyen ke arah tertentu | Lapak Ikan Tongkol: ikan di mana-mana, hanya satu jalan aman |
| 5 | Rumah Nenek | Kucing kedua, Belang, yang bergerak tiap 2 langkah. Kalau Oyen dan Belang mengincar ikan yang sama, keduanya berkelahi dan level gagal | Ke Dokter Hewan: dua kucing harus masuk kandang bawaan |

## Panduan teknis Flutter + Flame

Pisahkan logika dari tampilan: simulasi Oyen ditulis sebagai Dart murni tanpa Flame, sehingga bisa diuji dengan unit test dan dipakai ulang untuk putar ulang, petunjuk, dan pengecekan level. Flame hanya membaca hasil tiap langkah lalu menganimasikannya.

### Data level

```json
{
  "id": 13,
  "name": "Vas Ibu",
  "chapter": 2,
  "map": ["#######", "#..#..#", "#..#..#", "#.V.<.#", "#G.T..#", "#.....#", "#.....#", "#..M..#", "#######"],
  "inventory": {"fish": 1, "water": 1},
  "starItems": 2
}
```

Panah Oyen di data memakai `^ > v <` (huruf kecil `v` = menghadap bawah, berbeda dengan `V` vas). Simpan 20 level ini sebagai satu file `assets/levels/chapter1-2.json`.

### Satu langkah simulasi

```dart
StepEvent step(GameState s) {
  if (s.cellAt(s.cat) == Cell.bowl) return StepEvent.win;
  if (s.sitTurns > 0) {                       // di dalam kardus
    if (--s.sitTurns == 0) s.clear(s.cat);    // kardus penyok
    return StepEvent.sit;
  }
  for (final d in s.dir.lookOrder) {          // depan, kanan, kiri, belakang
    final p = s.cat + d;
    if (s.hasUnknockedItem(p)) return s.knock(p); // gelas aman, vas = pecah
  }
  final fish = s.nearestVisibleFish();        // seri: depan > kanan > kiri > belakang
  if (fish != null) s.dir = fish.direction;
  final next = s.cat + s.dir;
  switch (s.cellAt(next)) {
    case Cell.water: s.dir = s.dir.back; return StepEvent.scared;
    case Cell.wall || Cell.table: s.dir = s.dir.right; return StepEvent.turn;
    case Cell.box: s.cat = next; s.sitTurns = 2; return StepEvent.enterBox;
    case Cell.fish: s.cat = next; s.clear(next); return StepEvent.eat;
    default: s.cat = next; return StepEvent.walk;
  }
}
```

Deteksi mondar-mandir: simpan keadaan `(x, y, arah, sisaDuduk, jumlahBendaHilang, jumlahBarangJatuh)` di sebuah `Set`. Karena benda hanya bisa berkurang, angka jumlah sudah cukup mewakili isi peta. Kalau keadaan berulang, atau lewat 80 langkah, level gagal.

### Pembagian komponen Flame

| Komponen | Tugas |
| --- | --- |
| `BoardComponent` | Menggambar petak lantai, tembok, meja, dan barang |
| `CatComponent` | Sprite Oyen; tween 0,25 detik antarpetak; animasi jalan, kaget, duduk, menjatuhkan |
| `TrayComponent` | Baki benda di bawah layar; seret dan lepas ke petak, *snap* ke grid |
| `ThoughtBubble` | Ikon incaran Oyen di atas kepalanya |
| `ReplayController` | Menyimpan daftar `GameState` per langkah untuk maju/mundur |

### Solver dan generator

Solver mencoba semua penempatan benda dari baki dan menjalankan simulasi untuk masing-masing. Dengan grid 5 × 7 dan paling banyak 3 benda, satu level selesai dicek dalam hitungan detik. Pakai solver untuk: menghitung angka bintang 3, membuka petunjuk (solusi pertama), dan mengecek level baru. Generator level cukup mengacak dinding, meja, dan benda bawaan, lalu menyimpan peta yang lolos syarat: tanpa benda gagal, semua benda di baki terpakai di solusi minimum, dan jumlah solusi minimum paling banyak 3–4.

## Monetisasi dan versi pertama

Versi pertama berisi 20 level di dokumen ini, gratis, dengan iklan berhadiah sebagai sumber pemasukan awal. Tidak ada iklan paksa di tengah permainan.

| Sumber | Bentuk |
| --- | --- |
| Iklan berhadiah | Membuka petunjuk tingkat 1–3 |
| Kostum Oyen | Peci, sarung, topi koki, kacamata; kosmetik saja |
| Paket babak | Babak 3–5 dibeli per babak atau sekaligus |
| Hapus iklan | Pembelian sekali bayar |

**Isi versi pertama:**

- [ ] Simulasi Dart + unit test untuk 20 level (setiap solusi di dokumen ini harus menang tanpa vas pecah)
- [ ] Layar Beranda, Peta Babak, Gameplay (fase atur dan fase jalan), Hasil, Gagal, Tutorial level 1, 3, dan 6
- [ ] Animasi Oyen: jalan 4 arah, kaget, duduk di kardus, menjatuhkan barang, makan, senang di mangkuk
- [ ] Putar ulang langkah demi langkah
- [ ] Simpan progres bintang secara lokal
- [ ] Iklan berhadiah untuk petunjuk

## Prompt Claude Design

Salin seluruh blok di bawah ke Claude Design. Layar gameplay sengaja memakai peta Level 13 yang sudah dicek, supaya mockup cocok dengan data level yang nanti dibangun di Flutter.

```markdown
Desain UI untuk game puzzle mobile berjudul "Kucing Oren". Semua teks di dalam game memakai Bahasa Indonesia yang santai dan jenaka.

## Konsep
Pemain menuntun Oyen, kucing oren gempal yang bandel, ke mangkuk makannya. Pemain TIDAK mengendalikan Oyen. Pemain hanya menaruh benda (ikan asin, ember air, kardus) di petak lantai, lalu menekan "Bangunkan Oyen". Oyen bergerak langkah demi langkah dengan aturan tetap: mendekati ikan terdekat yang terlihat lurus, putar balik kalau ketemu air, belok kanan kalau mentok tembok, masuk dan duduk di kardus, dan menjatuhkan barang di meja sebelahnya. Vas Ibu tidak boleh sampai jatuh.

Game dibangun dengan Flutter + Flame. Buat komponen yang konsisten dan design token yang jelas (warna, tipografi, jarak, radius, bayangan).

## Format
- Mobile portrait 390x844.
- Prototipe yang bisa diklik sesuai alur di bagian bawah.

## Gaya visual
- Kartun flat yang hangat, dilihat dari atas (top-down), dengan bayangan lembut.
- Papan permainan berupa grid 7 kolom x 9 baris petak persegi (sekitar 50px per petak), diletakkan di tengah layar. Baris dan kolom terluar adalah tembok/perabot.
- Oyen adalah karakter ORISINAL: kucing oren belang (tabby) yang bulat, pipi tembam, mata besar setengah mengantuk, ekor tebal, ekspresi "tanpa dosa". Jangan menyerupai kucing kartun terkenal mana pun.
- Warna: krem hangat untuk lantai, oranye untuk Oyen dan tombol utama, biru muda untuk air dan mangkuk, cokelat kardus, hijau toska untuk status berhasil, merah bata untuk vas dan peringatan.
- Tipografi sans-serif membulat yang ramah, angka mudah dibaca.
- Jangan memakai logo, merek, atau kemasan produk nyata apa pun.

## Elemen papan (pakai ikon/ilustrasi yang konsisten)
- Tembok dan perabot dapur/ruang tamu (kulkas, lemari, rak)
- Lantai
- Mangkuk makan (tujuan)
- Meja kosong, meja dengan gelas plastik, meja dengan vas Ibu
- Ikan asin bawaan, genangan air bawaan, kardus bawaan
- Benda pemain: ikan asin, ember air, kardus (sedikit berbeda dari versi bawaan, misalnya dengan garis tepi oranye)
- Oyen dalam 4 arah hadap, ditambah pose: tidur, jalan, kaget, duduk dalam kardus, menjatuhkan barang, makan, senang

## Layar

1. **Beranda**
   Logo teks "Kucing Oren" dengan Oyen tidur melingkar di atasnya. Tombol besar "Main", total bintang (contoh: 24/60), tombol Lemari Kostum dan Pengaturan.

2. **Peta Babak 1 – Dapur**
   10 level berupa jejak kaki kucing yang berkelok di atas ilustrasi lantai dapur. Setiap level menunjukkan 0–3 bintang; level terkunci tampil pudar dengan gembok. Level 10 adalah bos "Pesta Ikan Asin", tampil lebih besar. Di bawah ada pratinjau Babak 2 – Ruang Tamu (terkunci).

3. **Gameplay – Fase Atur (Level 13 "Vas Ibu")**
   - Bar atas: tombol kembali, "Level 13 · Vas Ibu", target bintang 3 ("⭐⭐⭐ pakai 2 benda"), tombol "Aturan".
   - Papan memakai peta ini (# tembok, . lantai, T mangkuk, M meja, G meja+gelas, V meja+vas, < Oyen menghadap kiri):
     #######
     #..#..#
     #..#..#
     #.V.<.#
     #G.T..#
     #.....#
     #.....#
     #..M..#
     #######
   - Oyen tidur dengan "Zzz".
   - Baki bawah berisi 1 ikan dan 1 ember, dengan angka sisa. Tunjukkan satu ember sedang diseret jari, dengan petak tujuan yang menyala.
   - Tombol utama besar "Bangunkan Oyen".

4. **Gameplay – Fase Jalan (Level 13)**
   - Ember sudah di kolom 3 baris 3, ikan di kolom 2 baris 4 (dihitung dari 0 di pojok kiri atas).
   - Oyen sedang kaget di depan ember, dengan tanda seru di gelembung pikiran.
   - Penghitung langkah ("Langkah 1"), tombol jeda, dan tombol percepat x2.

5. **Kartu Aturan Oyen** (bottom sheet)
   Lima kartu bergambar sesuai urutan: jatuhkan barang di sebelahnya → kejar ikan terdekat (seri: depan, kanan, kiri, belakang) → air: putar balik → tembok/meja: belok kanan → kardus: masuk dan duduk 2 langkah. Aturan yang belum dipelajari tampil terkunci.

6. **Hasil – Berhasil**
   Oyen makan dengan bahagia di mangkuk. Animasi 3 bintang, jumlah langkah, jumlah benda dipakai. Penjelasan bintang: ⭐ sampai mangkuk · ⭐⭐ vas aman · ⭐⭐⭐ benda paling sedikit. Tombol "Ulangi" dan "Lanjut".

7. **Hasil – Vas Pecah**
   Oyen sampai di mangkuk tapi vas pecah di belakangnya, Ibu muncul dari pintu dengan wajah kesal. Hanya 1 bintang. Teks: "Sampai sih... tapi vas Ibu?" Tombol "Coba Lagi" dan "Lanjut Saja".

8. **Gagal – Oyen Bosan**
   Oyen tertidur lagi di tengah jalan. Teks: "Oyen bosan mondar-mandir." Tombol "Putar Ulang" dan "Atur Lagi".

9. **Putar Ulang**
   Papan dengan jejak langkah Oyen bernomor, slider waktu, dan tombol mundur/maju satu langkah.

10. **Petunjuk** (bottom sheet)
    Tiga tingkat: sorot petak pertama, tunjukkan jenis benda, tampilkan solusi lengkap. Setiap tingkat dibuka dengan tombol "Tonton iklan" atau koin.

11. **Tutorial Level 1**
    Overlay gelap dengan tangan penunjuk ke tombol "Bangunkan Oyen" dan teks pendek: "Oyen nggak bisa disuruh. Bangunkan saja dia!"

12. **Lemari Kostum**
    Grid kostum Oyen (peci, sarung, topi koki, kacamata), dengan pratinjau Oyen di atas dan harga dalam koin.

## Alur prototipe
Beranda → Peta Babak 1 → Fase Atur → Fase Jalan → Berhasil / Vas Pecah / Oyen Bosan → (Putar Ulang) → Peta Babak 1.
Dari Fase Atur: tombol "Aturan" membuka Kartu Aturan; ikon bohlam membuka Petunjuk. Dari Beranda: Lemari Kostum.
```

Setelah hasil pertama keluar, poles dulu layar Fase Atur dan Fase Jalan: di situlah pemain menghabiskan hampir seluruh waktunya.
