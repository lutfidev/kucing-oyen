# Brief Claude Design: pintu depan, gang, dan Kumis si kucing tetangga

Untuk ditempel ke Claude Design. Keputusan lengkap ada di `docs/superpowers/specs/2026-11-22-gang-depan-design.md`.

## Konteks

Ginger Logic adalah game puzzle mobile. Beranda game adalah rumah Oyen, kucing oren, tempat kucing-kucing milik pemain hidup sendiri. Rumahnya sekarang dua ruangan berperspektif: **ruang tengah** dengan pintu terbuka ke **teras** di dinding kanan. Dinding kiri ruang tengah masih kosong.

Kita menambah **pintu depan** di dinding kiri ruang tengah. Pintu itu membawa Oyen dan pemain ke **satu gang kecil yang nyaman** dengan warung dan bangku kayu. Tempat itu bernama **Gang Depan**. Di sana Oyen bertemu **Kumis**, kucing tetangga baru. Teras tetap tempat bersantai yang akrab; gang adalah tempat menjelajah dan bertemu teman.

Ceritanya: Kumis lewat, ujung ekornya terlihat sebentar di pintu kucing, Oyen menyadarinya lalu menyelinap keluar. Kamera tetap di ruang tengah. Kalau pemain mengetuk pintu depan, kamera mendekat pelan ke pintu, pintu terayun terbuka, gang terlihat lewat celahnya, lalu kamera melangkah melewati ambang dalam satu gerakan utuh. Di gang, Kumis bergeser di bangku memberi tempat untuk Oyen, Oyen naik, mereka saling mengendus, lalu duduk bersama.

Acuan:
- **Rumah dua ruangan (wajib cocok):** kanvas https://claude.ai/code/artifact/d110cbe8-34a2-4f87-85c5-2ec0b41829ba. Pakai sudut pandang, palet, kusen pintu, cahaya, dan susunan lapisan dari `LatarTengah`, `KusenTengah`, `CahayaTengah`, `LatarTeras`, dan `Kucing.dc.html` di sana.
- **Kamar v1 (gaya, sprite, header, panel):** kanvas "Ginger Logic – Rumah Oyen (19–24)", https://claude.ai/code/artifact/d25a6575-3d34-4887-9de4-18435367bf86.
- **Pratinjau konsep (sketsa kasar, bukan gambar final):** https://claude.ai/artifact/59AgVWDnrnRnLjgJHmX2jM. Ambil letak, alur, dan gerakan kameranya, jangan gambarnya. Pintu, gang, dan bangku di sana sketsa; kucing tetangga di sana memakai sprite Telon sebagai pengganti sementara.

## Sudut pandang dan skala

- Gang digambar **seperti ruangan rumah**: satu layar, perspektif satu titik hilang di **(195, 230)**, dan pita tanah dari y 392 (belakang) sampai y 652 (depan) dengan trapesium yang sama dengan lantai ruang tengah: (78,392)–(312,392)–(390,500)–(390,652)–(0,652)–(0,500). Dengan begitu kucing berukuran sama per kedalaman (sekitar 0,75× di belakang, 1,15× di depan), dan Oyen di gang sama besarnya dengan di rumah.
- Sisi kiri gang (bidang x 0–78, seperti dinding kiri ruangan) adalah **depan warung**. Sisi kanan (bidang x 312–390) adalah **depan rumah Oyen**. Di tengah, gang menyempit ke belakang menuju rumah-rumah lain, pohon, dan langit.
- **Pintu pulang** di depan rumah Oyen berada tepat di posisi pintu teras di ruang tengah: bukaan (320,212)–(382,203)–(382,489)–(320,403), dengan kusen yang sama. Pemain harus langsung mengenalinya sebagai pintu yang tadi ia lewati, dari sisi luar.

## Yang wajib sama dengan rumah sekarang

- Layar 390×844. Area rumah/gang dari tepi atas sampai y 652; di bawahnya panel bawah v1 (Main, lalu Toko, Aksesoris, Pengaturan) tanpa perubahan.
- Header: chip koin, logo "Ginger Logic", chip bintang. Di gang ada chip "‹ Ruang tengah" seperti di teras, dan **tidak ada tombol Hias**.
- Gaya: rata, hangat, garis lembut, tidak terlalu kartun, cocok dengan sprite kucing dan barang v1. Palet dari rumah dua ruangan (kayu `#C99466`/`#B07A4F`/`#D9A066`, krem `#FCE6C8`, langit `#A9DDF5`→`#E4F5EC`, hijau `#7FBF6E`/`#67A85B`, terakota atap `#D9785A`).
- **Tidak ada tulisan di gambar**: papan warung memakai ikon (cangkir, bungkus camilan), bukan kata "WARUNG". Nomor rumah diganti plakat bergambar tapak.
- Sprite kucing v1 tidak digambar ulang. Gang tidak punya barang Toko.

## Kumis, kucing tetangga (desain baru)

Kumis adalah kucing warung yang suka nongkrong di gang. Ia bukan kucing milik pemain: tidak dijual di Toko, tidak punya kartu atau kebutuhan, dan tidak memakai aksesoris Toko.

- **Badan:** templat yang sama dengan kucing v1 di `Kucing.dc.html` (kotak 100×100, ukuran dasar seperti kucing lain, 96 di skala kedalaman 1), supaya semua pose dan animasi berlaku.
- **Warna:** putih krem dengan **belang abu kebiruan** di punggung dan "topi" abu di kepala. Satu telinga sedikit **sompek** di ujungnya (tanda kucing jalanan yang sudah berpengalaman, tetap manis).
- **Ciri utama:** bercak abu di bawah hidung yang berbentuk **kumis** tebal, dari sinilah namanya. Ekspresinya santai dan percaya diri, sedikit lebih tua dari Oyen.
- **Ekor pendek bengkok** di ujungnya, abu bergaris. Ini harus mudah dikenali karena hanya ekor inilah yang terlihat di pintu kucing.
- **Syal kain kecil** bergaris merah-krem, sama dengan tenda warung, supaya jelas ia kucing warung. Syal adalah bagian badan Kumis, bukan aksesoris Toko.
- Palet harus berbeda jelas dari sembilan kucing pemain (Oyen oren, Salju putih, Telon tiga warna, Arang hitam, Mendung abu, Kopi Susu cokelat-krem, Mochi, Bos jas, Kembang belang abstrak). Belang abu + kumis + syal tidak boleh tertukar dengan Mendung atau Bos.
- **Pose:** semua pose templat (`idle`, `lick`, `walk1`, `walk2`, `sleep`, `eat`, `play`, `scratch`, `happy`, `lesu`, `rebah`, `petted`) beserta tiga arah hadap, ditambah dua pose baru di bawah.

### Pose baru untuk templat (semua kucing)

- **`endus`**: mengendus ke samping, kepala maju sedikit, mata setengah tertutup. Dipakai saat Oyen dan Kumis saling mengendus di bangku.
- **`geser`**: bergeser sambil tetap duduk, badan condong ke samping, kaki depan menapak bergantian (dua bingkai `geser1`/`geser2`). Dipakai saat Kumis memberi tempat di bangku.

Kedua pose ditulis di templat `Kucing.dc.html` dengan animasi CSS seperti pose lain, supaya kucing pemain juga bisa memakainya nanti.

## Artboard yang diminta

1. **Ruang tengah dengan pintu depan (390×844, dua versi).** (a) Pemain baru: hanya Oyen dan mangkuk, dengan petunjuk kamar kosong. (b) Ruang tengah berisi: tiga kucing dan barang seperti potret `19-kamar`, dengan tiang garukan dipindah keluar dari jalur pintu depan. Pintu depan ada di **dinding kiri**, cermin dari pintu teras (bukaan (70,212)–(8,203)–(8,489)–(70,403)), **tertutup**: kayu dengan panel, **jendela kecil** (sepotong langit dan ujung tenda bergaris warung), **pintu kucing** di bawah yang cukup lebar untuk Oyen menyelinap (sekitar 60% lebar daun pintu dan 30% tingginya), gagang, dan **keset** di lantai. Tunjukkan bahwa ruangan terasa seimbang: pintu teras yang terang dan terbuka di kanan, pintu depan yang tertutup di kiri.
2. **Lapisan pintu depan (dipisah).** (a) **Kusen depan** sebagai lapisan depan terpisah (seperti `KusenTengah`), supaya kucing bisa hilang di baliknya. (b) **Daun pintu datar**, dilihat lurus dari depan, untuk **sisi dalam dan sisi luar**, termasuk jendela dan pintu kucing. Game memproyeksikan gambar datar ini ke setiap sudut ayun. (c) **Daun pintu kucing** sendiri (bisa berayun). (d) Catatan: titik engsel (tepi belakang), arah ayun (ke dalam rumah, ke arah kamera), dan koordinat bukaan.
3. **Ekor Kumis di pintu kucing, satu layar penuh (390×844).** Ruang tengah lengkap dengan header dan panel bawah, Oyen di tengah lantai menoleh ke pintu depan, dan **ujung ekor bengkok Kumis menyembul dari pintu kucing** dalam ukuran sebenarnya di layar HP. Artboard ini untuk mengecek apakah bentuk ekornya (pendek, bengkok di ujung, abu bergaris) tetap mudah dikenali di ukuran HP tanpa memperbesar. Sertakan di sampingnya potongan yang diperbesar 3× sebagai pembanding.
4. **Ekor di pintu kucing (tiga bingkai kecil).** Ruang tengah dengan Oyen di tengah lantai. (a) Ujung ekor bengkok Kumis menyembul dari pintu kucing dan bergoyang. (b) Oyen menoleh, tanda "!" kecil di atas kepalanya. (c) Ekor menghilang, pintu kucing masih bergoyang sedikit.
5. **Oyen menyelinap keluar (tiga bingkai kecil).** (a) Oyen berjalan ke pintu depan dengan ukuran sesuai kedalaman. (b) Setengah badan masuk ke pintu kucing, bagian yang sudah lewat tertutup daun pintu. (c) Oyen sudah di luar, pintu kucing berayun, dan **penanda "Oyen di gang"** muncul di dekat pintu: gelembung kecil bergambar tapak, gaya `TandaLesu`/`GelembungKoin`, letaknya cermin dari ikon perhatian pintu teras (sekitar (63,238)). Ruang tengah tanpa Oyen harus tetap terasa utuh.
6. **Kamera ke gang (papan cerita, lima bingkai).** Hanya area rumah yang bergerak; header dan panel bawah diam. (a) Jari mengetuk pintu depan. (b) Kamera mendekat: ruangan membesar sekitar 1,6× di sekitar pintu dan pintu bergeser ke tengah layar. (c) Pintu terayun ke dalam (ke arah kamera, engsel di tepi belakang), dan gang terlihat lewat celah. (d) Melewati ambang: bukaan membesar sampai melewati tepi layar, daun pintu terbuka lewat di sisi kanan. (e) Gang menetap. Total gerakan sekitar 1,7 detik; tuliskan pembagian waktunya di catatan kalau ada saran.
7. **Gang (390×844), keadaan utama.** Warung di kiri: dinding kayu, bukaan konter dengan toples kerupuk dan sachet camilan berwarna yang tergantung, **tenda bergaris merah-krem** yang menjorok ke gang, dan sepetak tangga kecil. **Bangku kayu panjang** di depan warung, cukup untuk dua kucing duduk berdampingan. **Pohon mangga** di belakang warung dengan teduh berbintik di tanah. **Piring air** kecil di dekat warung (ditaruh pemilik warung untuk kucing). Depan rumah Oyen di kanan: dinding plester krem, ujung atap genteng, lampu dinding kecil, plakat tapak, pot tanaman, keset, dan **pintu pulang** yang sedikit terbuka dengan cahaya hangat di baliknya dan cahaya hangat yang jatuh ke tanah. Di belakang: gang menyempit, rumah-rumah tetangga kecil, kabel listrik, bukit hijau, dan langit dengan awan. Tidak ada mobil (gang khusus pejalan kaki). Isi contoh: Oyen dan Kumis duduk berdampingan di bangku.
8. **Lapisan gang (dipisah, seperti rumah).** **Latar** (langit, rumah belakang, tanah, warung, depan rumah, pemandangan hangat di balik pintu), **cahaya tanah** (teduh pohon, cahaya dari pintu), **kusen pintu pulang** sebagai lapisan depan, **cahaya udara**, dan **bangku dua lapis** (belakang: dudukan; depan: tepi dudukan dan kaki depan) supaya kucing bisa duduk di atasnya atau lewat di belakang kakinya.
9. **Gang kosong.** Pemain datang saat Oyen masih di dalam dan tidak ada kunjungan. Gang tetap terasa hidup: daun bergoyang, awan bergerak, kupu-kupu, sachet warung berayun pelan. Tidak ada kucing.
10. **Pertemuan pertama (papan cerita, lima bingkai).** (a) Kumis duduk di tengah bangku; Oyen duduk di tanah di depan bangku, menengadah. (b) Kumis bergeser ke ujung kanan bangku dengan pose `geser`. (c) Oyen melompat naik ke sisi kiri (lengkung lompat). (d) Keduanya mengendus dengan pose `endus`, hidung berdekatan, puff kecil. (e) Duduk bersama, satu hati kecil muncul di antara mereka.
11. **Momen sesudahnya (enam bingkai kecil).** Tidur berdampingan di bangku; berbaring di teduh pohon; minum dari piring air; duduk di tangga warung; melihat kupu-kupu bersama; Kumis pergi ke ujung gang sementara Oyen berjalan pulang dan masuk lewat pintu kucing di pintu pulang.
12. **Pulang ke rumah (papan cerita, empat bingkai).** Dari gang: ketuk pintu pulang, kamera mendekat, pintu terbuka ke ruang tengah yang hangat, kamera masuk dan berakhir di ruang tengah. Tunjukkan juga Oyen yang pulang sendiri, muncul dari pintu kucing di ruang tengah.
13. **Reaksi saat Kumis diketuk.** Satu bingkai: Kumis dengan hati kecil, seperti reaksi kamar v1.
14. **Kumis, lembar sprite.** Semua pose templat dan dua pose baru, tiga arah hadap, di samping Oyen sebagai pembanding ukuran, plus satu baris pose `endus` dan `geser` untuk Oyen.
15. **Catatan layar kecil 360×640:** apa yang mengecil di gang dan di pintu depan, seperti catatan `n360` di rumah dua ruangan.

## Agar bisa disalin ke game

- Semua gambar sebagai SVG di dalam `.dc.html`, satu berkas per lapisan atau artboard seperti kanvas rumah dua ruangan (`LatarTengah`, `KusenTengah`, `CahayaTengah`). Untuk gang: `LatarGang`, `KusenGang`, `CahayaGang`, `Bangku` (dua lapis), dan pintu depan `LatarTengah` yang diperbarui plus `KusenDepan`, `DaunPintuDalam`, `DaunPintuLuar`, `PintuKucing`. Kumis masuk ke `Kucing.dc.html` sebagai palet baru, bukan berkas terpisah.
- Tuliskan koordinat di catatan artboard: titik hilang, trapesium tanah, bukaan pintu depan dan pintu pulang beserta ambang dan jalur pintunya, posisi pintu kucing, letak penanda "Oyen di gang", dudukan bangku (dua titik duduk dan titik lompat dari tanah), dan **tempat nyaman gang**: bangku kiri, bangku kanan, teduh pohon, piring air, tangga warung, depan pintu pulang. Tulis juga jalur Kumis datang dan pergi (dari dan ke ujung gang).
- Animasi kecil dalam CSS `@keyframes` seperti rumah: awan, daun, kupu-kupu, sachet berayun, tenda sedikit berkibar, cahaya pintu berdenyut pelan. Hormati `prefers-reduced-motion`.
- Gerakan kamera, ayun pintu, dan lompatan dibuat di kode; papan cerita cukup memperlihatkan bingkai kuncinya.
