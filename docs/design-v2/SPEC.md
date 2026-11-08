# Spesifikasi v2 — usulan untuk ditinjau

8 November 2026 · langkah 1 · **DRAF, belum persetujuan implementasi**.

## Batas dan hasil yang dituju

Seluruh tampilan mengikuti konsep A: satu area per layar, kucing besar dan bulat, ruangan hangat berlapis, kontrol ringkas. Fondasi Flutter + Flame, 20 level, simulator, solver, ekonomi puzzle, empat bahasa, suara, dan iklan dipertahankan. Dokumen ini mengusulkan perilaku rumah yang sebelumnya belum diputuskan. Hanya pilihan konsep A, perubahan seluruh visual, serta aktivitas otomatis dan ajakan yang sudah disepakati pemilik repo.

Implementasi berjalan bertahap sesuai roadmap 2–16 setelah spesifikasi diterima. Tidak ada perubahan runtime pada langkah 1. Seluruh angka baru di bawah adalah usulan konkret untuk ditinjau, bukan hasil pengujian pemain.

## Struktur rumah dan navigasi

- Empat area gratis dan terbuka sejak awal: Santai, Makan, Bermain, Perawatan. Tidak menambah pembukaan area melalui bintang atau pembelian.
- Tab pendek: Santai / Makan / Main / Rawat; label aksesibilitas dan judul lengkap memakai nama area. Ikon Rawat adalah sikat, bukan bak mandi. Nama Main selalu berada dalam grup tab area.
- Beranda membuka area terakhir yang tersimpan, default Santai; kembali dari puzzle/Toko/Pengaturan mempertahankan area dan pilihan kucing sesi itu. Setelah restart, pulihkan area, pilih Oyen jika ada di area tersebut, selain itu kucing pertama menurut urutan katalog.
- Header: saldo membuka Tambah Koin; judul Ginger Logic; bintang membuka peta. Tombol utama bawah berlabel **Main Puzzle**, menuju level berikut melalui peta sesuai alur yang ada. Navigasi bawah Toko / Kucing / Pengaturan. Hias adalah tombol kecil di judul area, bukan tab kelima.
- Kucing membuka koleksi milik pemain sebagai sheet dengan nama, potret, area, kegiatan, kebutuhan, dan tombol Temukan. Kucing belum diadopsi dipisahkan di Toko. Sheet ini bukan rute baru yang memutus tumpukan navigasi.
- Ketuk kucing di ruangan memilihnya; kartu ringkas menampilkan nama, kegiatan, dan dua tindakan sesuai area. Ketuk nama/potret membuka kartu lengkap: kebutuhan, ajakan Makan/Main/Rawat, Camilan, Aksesoris, Temukan, dan Batalkan jika ada ajakan.
- Temukan menutup sheet dan membuka area kucing. Bila sedang berpindah, ikuti tujuan dan tampilkan status perjalanan. Tidak memindahkan kucing secara paksa.
- Kembali Android menutup sheet terlebih dahulu, kemudian mode Hias, lalu kembali sesuai router. Pergantian tab area tidak menambah entri tumpukan. Dari beranda, perilaku keluar mengikuti Android.

## Kapasitas dan penempatan

| Area | Maksimum kucing hadir | Tempat kegiatan serentak | Isi bawaan gratis |
| --- | ---: | --- | --- |
| Santai | 3 | 3 posisi istirahat | karpet latar, jendela, tempat duduk lantai |
| Makan | 2 | 1 makan + 1 posisi tunggu | satu mangkuk interaktif, lemari latar |
| Bermain | 2 | 1 bermain + 1 posisi tunggu | satu bola dasar tanpa nilai jual |
| Perawatan | 2 | 1 sikat/elus + 1 posisi tunggu | alas rawat dan sikat dasar |

Total kapasitas 9 sesuai seluruh koleksi; batas ini tetap sama pada layar kecil, ukuran gambar menyesuaikan. Sembilan kucing tidak dipaksa masuk Santai. Semua kucing punya tepat satu area atau satu perjalanan dengan asal dan tujuan. Hitungan tab mencakup kucing hadir; kucing berjalan ditandai terpisah di koleksi, bukan dihitung di dua area.

Slot tujuan dipesan sebelum berjalan; pemesanan dihitung untuk kapasitas. Kucing masih memiliki area asal sampai melewati ambang pintu. Pada ambang, satu transaksi mengubah area ke tujuan, mengubah reservasi tujuan menjadi slot hadir, dan melepas slot asal. Sesudah ambang, sisa animasi berjalan terjadi di tujuan. Tidak ada fase tanpa pemilik slot atau kucing digambar di dua area.

Kapan pun tujuan penuh (meskipun area lain masih kosong), tukar satu kucing diam di tujuan dengan pemohon melalui perpindahan berpasangan. Prioritaskan kandidat tanpa ajakan tertunda, lalu urutan katalog. Jika semua punya ajakan, kandidat dengan ajakan tertunda tetap boleh ditukar: pertahankan ajakannya, hitung ulang rute dari lokasi baru, dan jika tujuan ajakannya sama dengan asal pemohon, tandai perjalanan kedua ajakan terpenuhi bersama. Diam/tidur boleh ditukar; kegiatan aktif atau perjalanan/reservasi yang sudah terkunci untuk transaksi lain tidak boleh. Jika belum ada kandidat, tunggu sampai kegiatan/perjalanan selesai dan evaluasi lagi sebelum rutinitas otomatis baru dimulai. Scheduler memproses satu keputusan pemesanan pada satu waktu, sehingga dua swap tidak mengunci kucing yang sama. Swap memesan pasangan slot yang sudah ditempati, tidak menambah kapasitas; kedua identitas area berpindah dalam satu transaksi pada ambang. Ajakan tertunda tidak dihitung sebagai kunci slot, sehingga sembilan kucing dengan sembilan ajakan tidak saling memblokir hanya karena semua punya tujuan.

Migrasi awal membagi kucing urut katalog: tiga Santai, dua Makan, dua Bermain, dua Perawatan. Dengan satu kucing, Oyen mulai di Santai. Adopsi baru mencari slot kosong Santai lalu area lain dalam urutan di atas. Tidak ada kucing hilang/tersembunyi di Gudang.

## Aktivitas otomatis dan ajakan

| Aktivitas | Pemicu otomatis | Ajakan | Durasi usulan setelah tiba | Efek selesai |
| --- | --- | --- | ---: | --- |
| Santai/tidur | tidak ada prioritas lain | kembali Santai | diam 4–8 dtk, tidur 12–20 dtk | kosmetik |
| Makan | Lapar <70, jatah mangkuk tersedia | Ajak makan | 4 dtk | Lapar +40, maksimal 100 |
| Bermain | Senang <70, cooldown main selesai | Ajak main | 8 dtk | Senang +10, sekali per 30 menit |
| Sikat | pilihan santai sesekali | Rawat → Sikat | 6 dtk | memakai jatah elus, +10 Senang |
| Elus | tidak otomatis oleh pemain bayangan | Rawat → Elus | 2 dtk | +10 Senang, total sikat+elus maksimal 30/jam |

Bar Lapar bernilai tinggi berarti sudah makan; kartu menjelaskan "Makanan 80/100" agar arti bar jelas. Model tetap memakai hunger. Senang dan Lapar turun seperti v1: 100→0 dalam 16 dan 12 jam, berhenti pada 0. Tidak menambah kebersihan, mandi, kematian, sakit, kehilangan kucing, pengurangan koin, atau kewajiban membuka aplikasi. Kebutuhan rendah hanya ekspresi/status; semua puzzle tetap bisa dimainkan.

Urutan otomatis: selesaikan kegiatan aktif → ajakan tertunda → makan jika memenuhi syarat → bermain jika memenuhi syarat → pilihan santai/sikat. Putaran keputusan ketika diam setiap 4–8 detik dengan RNG ber-seed dalam test. Sikat otomatis paling sering sekali per 30 menit per kucing, tetap memakai batas elus gabungan; jika batas habis, hanya animasi santai. Jangan kirim kegiatan berulang ketika semua kebutuhan penuh.

Ajakan dari kartu lengkap menyebut kucing dan tujuan. Bila bisa langsung diterima, kartu ringkas berubah "Menuju Makan…" dan menawarkan Lihat area. Layar tidak berpindah tanpa pilihan pemain. Saat sudah di area itu, animasi perjalanan pendek menuju fasilitas tetap terlihat. Ketuk tab tidak mengajak kucing dan tidak membatalkan kegiatan.

### Prioritas, antrean, dan batal

1. Setiap kucing memiliki paling banyak satu ajakan tertunda. Ketuk ajakan identik bersifat idempoten. Ajakan baru mengganti tujuan tertunda dan melepaskan reservasi lama.
2. Ajakan menggantikan diam/tidur atau perjalanan otomatis pada titik aman. Jika sedang makan/main/rawat, tunggu sampai selesai; tampilkan "Sesudah kegiatan ini". Tidak memberi efek lebih awal.
3. Antrean per fasilitas: ajakan pemain dahulu, kemudian otomatis; FIFO dalam masing-masing kelompok. Kegiatan yang sudah mulai tidak dipotong. Setelah dua ajakan berturut-turut dilayani, layani satu antrean otomatis jika ada untuk mencegah kelaparan antrean.
4. Antrean logis bisa menampung sisa kucing koleksi (maksimum 8); hanya satu kucing tunggu digambar pada masing-masing area kegiatan. Sisanya menunggu di area asal. Kartu menunjukkan urutan dan Batalkan.
5. Jika fasilitas/area penuh, pesanan tetap tertunda di asal sampai tempat tersedia. Periksa kelayakan lagi sebelum berangkat dan sebelum mulai. Jika sudah kenyang/jatah habis, hapus pesanan dengan penjelasan; tidak mengantre selamanya untuk cooldown berjam-jam.
6. Batalkan sebelum transaksi ambang menghapus pesanan dan reservasi tujuan, lalu kucing tetap di asal. Setelah transaksi ambang, kucing menyelesaikan langkah pendek ke titik aman tujuan tanpa memakai fasilitas; slot tujuan tetap dimiliki dan tidak dilepas sebagai reservasi. Untuk swap, batal sebelum ambang membatalkan kedua perjalanan/reservasi, sedangkan batal setelah commit menyelesaikan kedua perpindahan. Bila kegiatan sudah mulai, tombol menjadi "Batal setelah ini"; efek kegiatan berjalan tetap satu kali saat selesai. Tidak mengembalikan camilan yang sudah berhasil dikonsumsi.
7. Bila fasilitas disimpan saat Hias, hentikan rencana yang belum mulai; kucing aktif keluar ke posisi aman tanpa efek yang belum diberikan. Fasilitas bawaan tidak dapat disimpan, sehingga kegiatan dasar selalu tersedia.
8. Area tidak dikunci pada v2. Area ditutup sementara hanya ketika diedit dalam Hias: hentikan mesin rumah, tampilkan "Sedang dihias", jangan terima ajakan baru sampai keluar Hias. Ini jeda global singkat yang jelas, bukan kucing lain diam tanpa status.

## Waktu, latar belakang, dan transaksi

- Mesin rumah berjalan saat salah satu area rumah tampil. Area yang tidak terlihat tetap memperbarui model; render hanya area aktif. UI sheet koleksi/kartu tetap membiarkan rutinitas berjalan, kecuali Hias dan dialog reset.
- Masuk puzzle, Toko, Pengaturan, iklan, atau aplikasi ke latar belakang menjeda rutinitas dan durasi animasi. Simpan lokasi aman, kegiatan, sisa durasi, antrean, dan reservasi yang konsisten. Kebutuhan tetap meluruh berdasarkan waktu kalender seperti v1.
- Membuka kembali melanjutkan sisa durasi tanpa menghitung kegiatan rumah selama offline. Tidak membuat hadiah atau makanan otomatis selama tutup. Validasi kelayakan sebelum aktivitas dilanjutkan; kegiatan yang sudah mulai menyelesaikan efeknya sekali, dengan pembatas kebutuhan dan kuota yang dicek ulang saat commit.
- Waktu efektif untuk kebutuhan dan batas hadiah tidak boleh mundur dari waktu terakhir tersimpan. Selisih kalender tidak digunakan untuk memutar animasi. Durasi aktif menggunakan waktu monotonik, bukan jam sistem.
- Mulai kegiatan disimpan dengan ID kegiatan unik. Saat selesai, kebutuhan, stok/jatah, hadiah, dan tanda ID telah selesai di-commit dalam satu transaksi progres. Ketuk ganda, callback ganda, berpindah layar, atau restart tidak menggandakan efek. Bila simpan gagal, pertahankan keadaan sebelum transaksi, tahan retry dengan ID sama, dan tampilkan Coba lagi; jangan memperlihatkan koin sudah diterima.
- Kerusakan sebagian data baru dipulihkan per bagian; ID tidak dikenal diabaikan. Kepemilikan, koin, bintang, petunjuk, bahasa, suara, camilan, aksesoris, cooldown serta hari hadiah lama dipertahankan. Backup snapshot lama disimpan sebelum migrasi; bila commit gagal jangan menimpa snapshot valid. Rincian skema/versioning dan fixture diuji pada langkah 4.

## Makanan, kebutuhan, dan hadiah

Mangkuk tetap sistem v1: satu siklus 4 jam dimulai ketika kucing pertama makan; setiap kucing hanya sekali per siklus, Lapar harus <70. Makanan siap kembali otomatis sesudah siklus; tidak perlu bayar, beli stok pakan, atau menonton iklan. Tombol yang benar adalah "Ajak makan" atau status "Makanan berikutnya 02:15"; **bukan Isi mangkuk** seperti di konsep gambar. Mangkuk tidak habis hanya karena satu kucing sudah makan. Status dibedakan per kucing dan untuk seluruh koleksi. Tidak menambah mangkuk kedua sebagai sumber jatah terpisah.

Camilan tetap inventaris/harga/efek v1; kartu kucing membuka panel stok dan jalan ke Toko saat habis. Mainan yang dibeli mengubah animasi/posisi kegiatan, bukan kuota main baru per barang. Bonus menghias +5 Senang per 60 menit tetap berlaku satu kali setelah penyimpanan tata letak yang benar-benar berubah, bukan keluar/masuk Hias. Semua kebutuhan dijepit 0–100.

Hadiah rumah tetap **10 koin/kucing/hari** ketika Lapar dan Senang ≥70, hari kalender sesuai v1. Usulan baru hanya penyajian gabungan: satu chip "Hadiah tersedia · 30" untuk tiga kucing yang memenuhi syarat; ketuk membuka rincian nama dan total, tombol "Ambil semua". Klaim mengecek ulang syarat/hari dan commit koin serta tanda klaim seluruh kucing yang sah secara atomik. Tidak mengunci nominal dari gambar, tidak menagih biaya, tidak memberi hadiah per animasi. Saat tidak ada, chip menjadi status tenang tanpa badge merah. Maksimum rumah 90 koin/hari untuk 9 kucing.

Bonus harian 20, iklan koin 20 maksimal 10/hari, petunjuk dan hadiah peningkatan bintang tetap aturan v1. Iklan tetap pilihan pemain pada sheet Koin/Petunjuk, bukan interupsi aktivitas rumah. Semua status siap/memuat/gagal/habis/dibatalkan wajib tersedia.

## Dekorasi, toko, dan migrasi barang

Barang dimiliki sekali dan ditempatkan di paling banyak satu area; boleh pindah antararea yang diizinkan, atau Gudang. Tidak menjual ulang barang otomatis. Gudang bukan pembelian ulang. Harga dan ID tetap v1; area tujuan ditampilkan sebelum membeli. Pembelian ketika posisi penuh masuk Gudang dengan pesan yang jelas. Mangkuk bawaan selalu di Makan.

| Kelompok barang v1 | Area awal migrasi | Area yang diizinkan |
| --- | --- | --- |
| tikus, catnip, bola, tiang, pancingan, terowongan | Bermain | Bermain |
| akuarium, jendelaBurung | Santai | Santai, Bermain |
| rumah, kasur, kardus, karpet, lampuBulan, bantalIkan, hammock, sofaMini | Santai | Santai, Perawatan |
| jam, lukisan, rak, monstera | Santai | semua area dengan zona dinding/lantai yang sesuai |
| mangkuk | Makan | Makan, tidak dapat disimpan |

Pindahkan semua barang dimiliki tanpa menghilangkan kepemilikan. Isi slot visual dengan urutan katalog: maksimal 4 barang lantai dan 3 dinding per area, termasuk fasilitas interaktif bawaan yang merupakan barang katalog; sisanya ke Gudang. Latar struktural bukan barang katalog. Koordinat lama tidak disalin ke kanvas baru; gunakan slot aman yang didokumentasikan pada langkah 2–4. Tampilkan ringkasan migrasi sekali: "Rumah lebih luas! Barang lainnya aman di Gudang." Pemain bisa menata ulang gratis.

Hias memakai pratinjau draf: pilih barang, slot/seret, Pindah area, Simpan ke Gudang, Simpan tata letak, Batal. Slot jalan/pintu/tempat kegiatan tidak boleh tertutup. Sorot invalid dan kembalikan ke posisi terakhir sah saat lepas. Menekan kembali dengan perubahan membuka Simpan/Buang/Lanjut menghias. Perubahan hanya berlaku setelah simpan sukses. Aksesoris tetap satu per kucing, bisa dipakai beberapa kucing sekaligus setelah dimiliki; ID dan harga tidak berubah.

## Seluruh layar di luar rumah

[SCREENS.md](SCREENS.md) mencatat cakupan lengkap. Peta menggambar ulang Dapur dan Ruang Tamu, masing-masing 10 level; perolehan bintang, gerbang babak, dan pengenalan aturan mengikuti kode/data saat ini. Puzzle memakai grid asli 7×9; arah hadap, petak target, benda bawaan/pemain dan hitbox harus terbaca. Renderer tidak menambah objek penghalang yang tidak ada dalam data. Memindahkan benda melalui seret atau pilih-lalu-ketuk tetap didukung.

Hasil punya varian menang 1/2/3 bintang, sampai mangkuk dengan vas pecah, dan bosan karena loop/batas langkah. Vas pecah bukan kegagalan mencapai mangkuk. Putar ulang memiliki langkah 0, akhir, jeda, kecepatan, maju/mundur, jejak dan peristiwa; semua dari hasil simulasi, bukan jalur ilustrasi mockup. Tutorial hanya mengenalkan fitur yang relevan, bisa dilewati; pengenalan area tidak menghalangi Main Puzzle. Pengaturan mempertahankan bahasa, audio, privasi, tentang, reset; opsi Kurangi gerak ditambahkan dan menghormati preferensi sistem.

## Syarat penerimaan sebelum langkah 2

- Pemilik repo menyetujui arah visual, kapasitas 3/2/2/2, empat area gratis, antrean/ajakan, perawatan elus+sikat tanpa mandi, dan hadiah gabungan dengan nominal lama.
- Setiap baris inventaris memiliki rencana keadaan dan kontrol; mockup konsep serta koreksinya ditinjau, ukuran ponsel ditetapkan di VISUAL.md.
- Catat perubahan usulan hasil tinjauan di DESIGN_NOTES.md; jangan mengubah label draf menjadi final hanya karena dokumen sudah ditulis.
- Setelah disetujui, perbarui status roadmap dan buat rencana implementasi langkah 2. Tes visual/performa runtime baru dilakukan bersama implementasi, bukan dianggap lulus dari gambar konsep.
