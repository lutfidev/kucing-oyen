# Rumah Oyen: pintu depan dan Gang Depan

Disepakati pemilik repo pada 22 Nov 2026. Memperluas rumah dua ruangan (`docs/superpowers/specs/2026-11-21-rumah-dua-ruangan-design.md`) dengan tempat ketiga di luar rumah. Brief untuk Claude Design ada di `docs/design-brief/gang-depan.md`. Pratinjau konsep (sketsa kasar di atas potret layar game, bukan gambar final): https://claude.ai/artifact/59AgVWDnrnRnLjgJHmX2jM.

## Maksud

Sesudah teras ada di kanan, dinding kiri ruang tengah terasa kosong. Pemilik repo ingin dinding itu punya **pintu depan** yang benar-benar bisa dipakai Oyen dan pemain untuk keluar rumah, ke **satu gang kecil yang nyaman**. Teras tetap tempat Oyen bersantai yang sudah akrab, sedangkan gang menjadi tempat Oyen menjelajah dan bertemu teman.

Inti pengalamannya: seekor kucing tetangga lewat, ujung ekornya terlihat sebentar di pintu kucing, Oyen menyadarinya lalu menyelinap keluar. Kamera tetap di ruang tengah sampai pemain mengetuk pintu depan untuk menyusul. Saat itu kamera mendekat ke pintu, pintu terayun terbuka, gang terlihat lewat celahnya, dan kamera melangkah melewati ambang dalam satu gerakan utuh. Rasanya harus seperti pemain baru saja melangkah keluar untuk melihat ke mana Oyen pergi.

## Tujuan

- Pintu depan di dinding kiri ruang tengah, pasangan dari pintu teras di dinding kanan.
- Gang satu layar dengan warung kecil dan bangku kayu, digambar dengan sudut pandang dan gaya yang sama dengan rumah.
- Satu kucing tetangga baru dengan desainnya sendiri, yang datang beberapa kali sehari.
- Oyen keluar sendiri lewat pintu kucing saat tetangga datang, lalu pulang sendiri.
- Pemain bisa ke gang kapan saja dengan mengetuk pintu depan, juga saat Oyen masih di dalam, dan pulang dengan mengetuk pintu rumah dari gang.
- Pertemuan pertama yang dirancang (tetangga bergeser memberi tempat di bangku), lalu momen yang bervariasi di kunjungan berikutnya.

## Bukan tujuan (v1)

- Kucing lain selain Oyen keluar rumah. Kucing lain tetap di ruang tengah dan teras.
- Mengajak kucing ke gang: pintu depan tidak menerima tahan-seret, dan kartu kucing tidak punya tombol "Ajak ke gang".
- Hadiah dari kunjungan: tidak ada koin, barang, atau persahabatan yang dihitung. Momen kecilnya sudah cukup jadi hadiah.
- Hias, Gudang, mangkuk, atau barang di gang. Gang bukan ruangan yang bisa ditata.
- Kartu, kebutuhan, atau aksesoris untuk kucing tetangga.
- Gang kedua, tetangga lain, warung yang membuka Toko, atau siang-malam. Semuanya dicatat sebagai ide nanti.
- Kebutuhan baru, perubahan ekonomi koin, puzzle, atau peta.

## Yang tidak boleh terjadi (anti-tujuan)

- Ke gang lewat geser layar, tombol menu, atau tab. Gang hanya lewat pintu depan.
- Kamera ikut pindah sendiri saat Oyen keluar. Kamera hanya bergerak kalau pemain mengetuk pintu.
- Pindah ke gang terasa seperti potongan atau crossfade (kecuali saat kurangi gerak). Harus satu gerakan kamera yang utuh.
- Pemain menyusul Oyen sesudah melihat ekor di pintu kucing, lalu tetangganya sudah pergi.
- Dinding, pintu, gang, atau kucing tetangga digambar sendiri di kode tanpa desain.
- Barang hiasan menutup jalur pintu depan.
- Ruang tengah terasa rusak saat Oyen tidak ada di dalam.

## Pendekatan yang dipertimbangkan

1. **A · Kamera berjalan menembus pintu (dipilih).** Ketuk pintu depan: kamera mendekat ke pintu sambil memutar pintu ke tengah layar, pintu terayun ke dalam, gang terlihat lewat celah sebagai lapisan sendiri yang sudah sejajar dengan posisi akhirnya, lalu ambang membesar sampai melewati tepi layar dan gang menetap. Berbeda jelas dari geser ke teras: geser = melihat ruangan sebelah, jalan menembus pintu = keluar rumah. Gang memakai titik hilang dan pita lantai yang sama dengan rumah, jadi skala kedalaman, rutinitas jalan, dan lewat pintu tetap berlaku.
2. **B · Gang di kiri dalam satu jalur geser** (gang | ruang tengah | teras). Paling murah karena memakai `HousePager`, tapi keluar rumah terasa sama dengan pindah ke teras, dan geser bisa membawa pemain keluar tanpa sengaja. Bertentangan dengan keinginan pemilik repo.
3. **C · Potong atau crossfade ke gang.** Murah, tapi tidak ada rasa melangkah keluar. Hanya dipakai saat kurangi gerak.

## Yang sudah diputuskan pemilik repo

### Pintu depan dan ruang tengah

- Pintu depan ada di **dinding kiri ruang tengah**, cermin dari pintu teras di dinding kanan (tinggi, kusen kayu, dan letaknya sama). Pintunya tertutup, berbeda dari pintu teras yang terbuka.
- Dari dalam terlihat: jendela kecil di daun pintu (sepotong langit dan tenda bergaris warung), **pintu kucing** di bawah, dan keset di lantai.
- Saat Oyen di luar, ada penanda kecil di dekat pintu supaya ruang tengah tanpa Oyen tidak terasa rusak.

### Siapa yang keluar

- **Hanya Oyen** di v1. Ia keluar sendiri lewat pintu kucing dan pulang sendiri.
- Kucing lain tetap di ruang tengah dan teras.
- **Pemain** bisa mengetuk pintu depan dan ke gang **kapan saja**, juga saat Oyen masih di dalam.

### Kunjungan tetangga

- Tetangga datang **beberapa kali sehari pada waktu yang berbeda-beda**.
- **Pertemuan pertama dijamin:** kalau pemain melihat ekor di pintu kucing, melihat Oyen menyelinap keluar, lalu mengetuk pintu untuk menyusul, tetangganya **masih ada** saat pemain tiba.
- Pertemuan pertama memperlihatkan tetangga **bergeser di bangku memberi tempat untuk Oyen**. Oyen naik, mereka saling mengendus, lalu duduk bersama.
- Sesudah itu momen pertemuannya bervariasi.
- Tidak ada hadiah di v1; momen kecil itu sudah cukup.

### Kamera dan gestur

- **Ketuk** pintu depan untuk ke gang. **Geser** tetap hanya untuk ruang tengah ↔ teras.
- Saat Oyen keluar sendiri, kamera **tetap bersama pemain** di ruangan yang sedang dibuka.
- Saat pemain mengetuk pintu: kamera mendekat pelan ke pintu, pintu terayun terbuka, dan gerakannya membawa pemain melewati ambang dalam **satu gerakan utuh**.
- Dari gang, pemain mengetuk pintu masuk rumah untuk pulang.

## Keputusan asisten (boleh dikoreksi pemilik repo)

### Nama dan letak

- Nama tempatnya **Gang Depan** (disetujui pemilik repo 22 Nov 2026). Di dokumen ini disingkat "gang". Terjemahannya ditulis di ARB seperti nama ruangan lain (usulan: Inggris "Front Lane", Portugis "Viela da Frente", Rusia "Переулок у дома"). Gang Depan bukan `HouseRoom` yang bisa dihias; di model ia tempat terpisah yang memakai lantai dan rutinitas yang sama.
- Kucing tetangga diusulkan bernama **Kumis** (nama sama di semua bahasa): kucing warung, putih dengan belang abu dan "kumis" abu di bawah hidung, ekor pendek bengkok, syal kain bergaris merah-krem seperti tenda warung. Desain lengkapnya di brief. Ekor bengkoknya sengaja dibuat mudah dikenali karena ekor itulah yang terlihat di pintu kucing.
- Letak di gang: warung dan bangku di sisi kiri, depan rumah Oyen di sisi kanan. **Pintu pulang berada tepat di posisi pintu teras di ruang tengah** (bukaan (320,212)–(382,203)–(382,489)–(320,403)), dengan kusen, panel, jendela, dan pintu kucing yang sama dengan sisi dalam. Pintunya sedikit terbuka dengan cahaya hangat di baliknya. Seperti teras, pintu kembali selalu di dinding samping yang menghadap rumah.
- Header di gang: chip koin, logo, chip bintang, dan chip "‹ Ruang tengah" (pulang, sama seperti chip di teras). Tidak ada tombol Hias. Panel bawah tetap.

### Pintu depan di ruang tengah

- Bukaan pintu depan = cermin bukaan pintu teras: (70,212)–(8,203)–(8,489)–(70,403); kusen dicerminkan dari `LatarTengah`/`KusenTengah`.
- **Jalur pintu depan** ikut `HouseFloor.doorPath`/`blocksDoor`, sama seperti pintu teras. Posisi bawaan tiang garukan (sekarang di pojok kiri) pindah keluar dari jalur itu. Barang simpanan lama yang jatuh di jalur bergeser lewat `allowedSpot`.
- Penanda "Oyen di gang": gelembung kecil bergambar tapak di dekat pintu depan, dengan gaya dan aturan `DoorAttention` (tanpa semantik sendiri; label pintu yang menyebutnya). Kalau Oyen lapar atau lesu di gang, ikon perhatian yang biasa (lapar → lesu → hadiah) menggantikannya.
- Pembaca layar: pintu depan "Keluar ke Gang Depan" (ditambah "Oyen ada di Gang Depan" kalau ia di luar); pintu di gang "Pulang ke ruang tengah". Saat Oyen keluar sendiri dari ruangan yang sedang dibuka, diumumkan singkat seperti `kittyLeftTo`.

### Kamera ke gang dan pulang

- Durasi awal (dites di HP): mendekat 0,45 detik (`easeInOut`, skala 1 → 1,6 di sekitar tengah pintu, pintu bergeser ke tengah layar), pintu terayun 0,6 detik (`easeOut`, engsel di tepi belakang, ke arah kamera), melewati ambang 0,65 detik (`easeIn`, skala ruangan sampai bukaan melewati tepi layar), menetap 0,55 detik (gang 108% → 100%). Total sekitar 1,7 detik; tahap-tahapnya saling tumpang seperti di pratinjau.
- Gang dirender sebagai lapisan sendiri yang dipotong bentuk bukaan pintu (setelah transformasi kamera), jadi tidak ada crossfade.
- Daun pintu digambar datar oleh desain lalu diproyeksikan ke sudut bukaan di setiap sudut ayun (homografi `Matrix4`), supaya cukup satu gambar daun pintu per sisi.
- Ketuk lagi selama gerakan = langsung ke akhir. Kurangi gerak = crossfade pendek (200 ms).
- **Pulang** dari gang memakai gerakan yang sama ke pintu rumah: pintu terbuka ke ruang tengah yang hangat lalu kamera masuk dan berakhir di ruang tengah.
- Tombol kembali sistem di gang = pulang ke ruang tengah. Di dalam rumah tetap seperti sekarang.
- Header dan panel bawah diam selama gerakan, seperti transisi teras.

### Gestur di gang

- Ketuk Oyen di gang membuka kartu kucing biasa (tanpa tombol ajak). Camilan dan elus tetap bisa.
- Ketuk Kumis memberi reaksi kecil (suara `meow`, hati), tanpa kartu.
- Tidak ada tahan-seret dan tidak ada geser ruangan di gang.
- Geser di ruang tengah ke arah pintu depan tidak melakukan apa-apa (tetap seperti sekarang).

### Jadwal kunjungan

- Jadwal per hari kalender, dihitung dari nomor hari (`dayNumber`) sebagai seed, jadi tidak perlu disimpan: **3 kunjungan** di jendela 08.00–22.00 waktu lokal, mulai acak dengan jarak minimal 2 jam, masing-masing **8–12 menit**.
- Kunjungan hanya terlihat sebagai kejadian saat aplikasi terbuka. Kalau aplikasi dibuka di tengah kunjungan, Oyen sudah di bangku bersama Kumis (tanpa momen ekor).
- Saat kunjungan dimulai, momen ekor hanya diputar kalau pemain sedang di ruang tengah. Di teras, gang, atau layar lain, Oyen langsung lewat pintu kucing (di layar lain tidak terlihat).
- Oyen tidak keluar selama kartunya terbuka, sedang diangkat, sedang bereaksi, atau mode Hias aktif. Ia keluar begitu bebas, selama kunjungan masih berjalan.
- **Jaminan menyusul:** kunjungan tidak berakhir selama pemain berada di gang. Sesudah Oyen keluar karena momen ekor, kunjungan berlangsung paling sedikit 5 menit lagi.
- Akhir kunjungan: Kumis berjalan pergi ke ujung gang, lalu Oyen pulang lewat pintu kucing. Kalau pemain di ruang tengah, ia melihat Oyen masuk.
- Lapar: kalau Lapar Oyen ≤ `sadThreshold` di gang, ia pulang lebih awal ke mangkuk, seperti kucing lapar di ruangan tanpa mangkuk. Kunjungan yang tersisa berlanjut tanpa Oyen.
- Kunjungan yang dijadwalkan mulai saat kunjungan lain masih berjalan (karena diperpanjang) digabung: kunjungan yang sedang berjalan berlanjut sampai akhir yang lebih lambat. Tidak pernah ada dua Kumis.
- Keadaan kunjungan dihitung dari jam dan jadwal, bukan disimpan: "Oyen di gang" = ada kunjungan berjalan dan Oyen belum pulang karena lapar. Perpanjangan (pemain di gang, 5 menit sesudah momen ekor) dan kunjungan paksa disimpan di memori `ProgressController`, jadi bertahan saat pemain membuka Toko atau level, tetapi hilang kalau aplikasi ditutup. Sesudah dibuka ulang, jadwal biasa berlaku lagi.
- Kalau Oyen sedang betah di teras karena diajak pemain saat kunjungan mulai, ajakan menang: Oyen keluar sesudah waktu betahnya habis, selama kunjungan masih berjalan.
- Tidak ada kunjungan yang dimulai sebelum pemain menyelesaikan level 1. Kunjungan pertama selama aplikasi terbuka dan pemain di ruang tengah dipaksa datang 20 detik sesudah ruang tengah tampil, kalau pertemuan pertama belum pernah terjadi, supaya pemain baru tidak harus menunggu jadwal. Kunjungan paksa ini tambahan di luar jadwal, berlaku sekali per sesi aplikasi, dan berhenti setelah pertemuan pertama terjadi.
- Kumis bukan `KittyId`. Ia tipe kucing terpisah (tetangga) supaya Toko, `Home.kitties`, kebutuhan, aksesoris, dan `doorAttention` tidak perlu menyaringnya. `KittyLook`, palet, dan `RoomLife` diperluas agar bisa menggambar dan menggerakkan kucing bukan milik pemain.

### Pertemuan pertama dan sesudahnya

- **Pertemuan pertama diingat permanen (keputusan pemilik repo).** Game mencatat `lane.metNeighbor` di `ProgressStore` (kunci `PrefsProgressStore` sendiri, ikut antrean simpan yang tidak pernah melempar dan `retrySaves`) **hanya sesudah pemain melihat seluruh pertemuan pertama di gang**: Kumis bergeser, Oyen melompat naik, mengendus, sampai duduk bersama. Catatan ini bertahan sesudah aplikasi ditutup dan dibuka ulang, jadi pertemuan pertama tidak pernah diputar dua kali dan kunjungan paksa tidak muncul lagi.
- Kalau pemain meninggalkan gang (pulang, kembali, membuka layar lain, atau aplikasi ditutup) sebelum mereka duduk bersama, pertemuan pertama belum dianggap terlihat: kunjungan itu berlanjut sebagai kunjungan biasa, dan pertemuan pertama diputar lagi di kunjungan berikutnya. Data rusak dibaca sebagai belum bertemu. `resetProgress` menghapusnya seperti isi rumah lain: progres baru berarti pertemuan pertama diputar lagi. Test: tersimpan sesudah urutan lengkap, tidak tersimpan kalau terputus, tetap ada sesudah `ProgressController.load` ulang.
- Urutan pertemuan pertama: Kumis sudah duduk di tengah bangku. Oyen datang dan duduk di depan bangku sambil menengadah. **Oyen menunggu pemain:** selama pemain belum di gang, keduanya tetap di pose itu. Begitu pemain tiba (gerakan kamera selesai), Kumis bergeser ke ujung kanan bangku, Oyen melompat naik ke kiri, keduanya mengendus, lalu duduk bersama. Sesudah itu rutinitas biasa.
- Kalau kunjungan pertama berakhir tanpa pemain datang, pertemuan pertama belum dianggap terjadi dan diulang di kunjungan berikutnya.
- Kunjungan berikutnya: Oyen dan Kumis memilih momen dari **tempat nyaman gang** dengan bobot, memakai `RoomLife` (`LifePlace`, jarak kaki `HouseFloor.distance`, pose kucing biasa). Daftar awal: duduk bersama di bangku (Kumis bergeser lagi kalau Oyen datang belakangan), tidur berdampingan di bangku, berbaring di teduh pohon, minum dari piring air di dekat warung, duduk di tangga warung, melihat kupu-kupu bersama.
- Kumis memakai tempat nyaman yang sama dan pose dari templat `Kucing.dc.html`. Pose baru `endus` (mengendus ke samping) dan `geser` (bergeser sambil duduk) dibuat untuk templat itu, jadi berlaku untuk semua kucing.

### Gang tanpa Oyen dan tanpa tetangga

- Gang tetap hidup walau kosong: daun pohon bergoyang, awan, kupu-kupu, sachet warung berayun. Ini bagian gambar latar, bukan kucing.
- Saat Oyen di dalam dan tidak ada kunjungan, gang kosong dari kucing.

### Hal lain

- Suara: `meow` saat Oyen menyadari ekor, bunyi kayu pintu kucing berayun, dan bunyi pintu depan terbuka/tertutup. Efek baru dibuat lewat `tool/audio/make_sfx.py` dari sumber CC0, ikut batas ukuran di `audio_assets_test`. Kalau sumber CC0 yang cocok tidak ada, efeknya disintesis seperti lonceng dan gigitan kamar.
- Kinerja: hanya tempat yang sedang dibuka yang menggambar kucing dan barang bergerak; rutinitas gang tetap maju tanpa menggambar, seperti dua ruangan.
- Teks baru (nama gang, Kumis, label pembaca layar, pengumuman) di keempat ARB.

## Gambar yang dibutuhkan (lewat Claude Design)

Isi lengkap ada di `docs/design-brief/gang-depan.md`. Ringkasnya: ruang tengah dengan pintu depan (pemain baru dan berisi), lapisan kusen depan dan pintu kucing, daun pintu datar dua sisi, gang dengan lapisan latar/cahaya/depan, bangku dua lapis, ekor di pintu kucing, Oyen lewat pintu kucing, papan cerita kamera ke gang dan pulang, pertemuan pertama, momen sesudahnya, desain dan pose lengkap Kumis, pose baru `endus` dan `geser`, penanda "Oyen di gang", dan catatan 360×640.

## Perubahan pada spec rumah dua ruangan

- "Bukan tujuan: ruangan ketiga" diganti: tempat ketiga adalah gang ini, dengan batas di atas.
- CCTV tetap ditunda. Gang bukan ruangan yang dimiliki pemain, jadi belum alasan untuk CCTV.
- Pintu ruang tengah sekarang ada dua; ikon perhatian dan jalur pintu berlaku untuk keduanya.

## Diserahkan ke pembuat rencana

- Model Dart murni: tempat gang di samping `HouseRoom` (atau tipe tempat yang lebih umum), jadwal kunjungan per hari, keadaan kunjungan (mulai, menunggu pemain, selesai), pertemuan pertama, dan perluasan `RoomLife` untuk Kumis, pintu kucing, dan gang.
- Geometri: bukaan pintu depan dan jalurnya, tempat nyaman gang, bangku sebagai tempat duduk dua kucing (tempat berdiri dan lompat seperti barang dinding).
- Gerakan kamera ke gang dan pulang, potongan bukaan, homografi daun pintu, ketuk untuk melompati, kurangi gerak.
- Simpanan `lane.metNeighbor` (kapan tepatnya dianggap "duduk bersama" di rutinitas) dan migrasinya.
- Test: jadwal ber-seed, jaminan menyusul, pertemuan pertama yang menunggu pemain, layar (ketuk pintu, transisi, kembali, kurangi gerak, pembaca layar), `overflow_test` dan potret layar keempat bahasa, profil kinerja kamar seperti langkah 32.
- Pembagian ke langkah roadmap sesudah langkah 35. Rencana dimulai sesudah link kanvas Claude Design diserahkan.
