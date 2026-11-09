# Inventaris layar, sheet, dan keadaan

Audit sumber: `lib/app/routes.dart`, `router.dart`, seluruh `lib/screens/`, dan galeri pada 8 November 2026. **Disetujui** sebagai cakupan desain langkah 1; kolom gambar menunjukkan templat visual, bukan bukti implementasi. Varian rinci memakai kerangka di [wireframes](mockups/wireframes/index.html). Seluruh wireframe berukuran logis 390×844; adaptasi layar kecil mengikuti VISUAL.md.

## Rute pemain

| ID | Rute/keadaan | Susunan dan tindakan | Keadaan wajib | Acuan |
| --- | --- | --- | --- | --- |
| H01 | `/`, Santai | header, tab, Hias, ruangan, kartu kucing, hadiah, Main Puzzle, nav | Oyen saja; 3 kucing; tanpa pilihan; kebutuhan rendah; perjalanan masuk/keluar | 01 empat area |
| H02 | `/`, Makan | kerangka rumah, satu mangkuk, satu titik tunggu; panel jatah dan sheet pilih kucing | siap; makan; jatah kucing habis; semua sudah makan; siklus selesai; antrean/batal; simpan gagal/retry | [runtime langkah 6](dining/REVIEW.md) |
| H03 | `/`, Main | satu posisi bermain, satu menunggu, kartu kegiatan | mainan dasar; mainan dibeli; cooldown; ajakan tertunda; tanpa kucing | 01 |
| H04 | `/`, Rawat | alas/sikat, elus/sikat, kartu kegiatan | idle; rawat; batas elus habis; batal setelah ini; tanpa kucing | 01 |
| H05 | Kucing (sheet baru di `/`) | daftar vertikal potret, lokasi/kegiatan, Temukan | 1/9 kucing; kucing berjalan; panjang nama; indikator Baru | 03 + WF Koleksi |
| H06 | kartu kucing | potret, kebutuhan bernilai, ajakan, Camilan, Aksesoris, Temukan | penuh/rendah; antrean urutan; ditolak karena jatah; nonaktif saat simpan | 03 + WF Kartu |
| H07 | Camilan dalam kartu | stok, efek, Beri, link Toko | stok 0; kenyang; simpan gagal; berhasil; ketuk ganda | WF Camilan |
| H08 | Aksesoris dalam kartu | pratinjau, daftar dimiliki, Pakai/Lepas, Toko | kosong; satu aktif; dipakai banyak kucing; panjang nama | WF Aksesoris |
| H09 | Hias/Gudang | judul area, room slot, daftar barang, Simpan/Batal | awal; invalid/overlap; pindah area; Gudang; penuh; simpan gagal; dialog buang perubahan | WF Hias |
| H10 | hadiah rumah baru | rincian kucing sah, total, Ambil semua | 0/1/9; syarat berubah; sudah klaim; simpan gagal; berhasil | 03 + WF Hadiah |
| H11 | pengenalan rumah/migrasi | satu kartu penjelasan, Lihat rumah, Tutup | pemain baru; progres v1 dengan barang Gudang; tidak tampil dua kali | WF Pengenalan |
| S01 | `/toko?tab=items` | header kembali/saldo, empat tab, grid barang dan tujuan area | belum/dimiliki; koin kurang/pas; tujuan penuh; gulir ke kartu terakhir | 03 |
| S02 | `/toko?tab=kitties` | kartu sembilan kucing dan harga, adopsi | dimiliki; Baru; kurang/pas; slot awal tujuan ditampilkan | WF Adopsi |
| S03 | `/toko?tab=accessories` | pratinjau dan rarity, beli atau Pakai | biasa/langka/spesial; dimiliki; belum ada kucing dipilih | WF Beli |
| S04 | `/toko?tab=snacks` | stok/harga/efek, beli | 0/banyak stok; koin kurang; simpan gagal | WF Beli |
| S05 | konfirmasi pembelian | ilustrasi, nama, harga, saldo sesudah, tujuan, Beli/Batal | sudah dimiliki; kurang; ke Gudang; memproses; gagal; berhasil | WF Beli |
| C01 | `/babak/1` | Dapur, 10 node, bintang, navigasi babak | terkunci/terbuka/1–3 bintang/bos; baru buka; jalan dari hasil | 02 peta |
| C02 | `/babak/2` | Ruang Tamu, 10 node level 11–20 | babak terkunci; terbuka; semua selesai; ulang level | 02 templat + WF Babak2 |
| C03 | kartu babak baru `?baru=1` | ilustrasi babak, pesan singkat, Lanjut | animasi/kurangi gerak; kembali; ketuk dua kali | WF Babak baru |
| L01 | `/babak/:chapter/level/:id`, atur | header/target, papan, baki, Bangunkan, aturan/petunjuk | baki kosong; benda terpilih; invalid; semua dipasang; sorot petunjuk; level tak valid | 02 puzzle |
| L02 | fase jalan | papan sama, langkah, pikiran, jeda, ×1/×2, kembali atur | jalan; berhenti kardus; jatuhkan gelas/vas; makan; loop; langkah 80 | WF Jalan |
| L03 | tutorial overlay | sorot elemen, kartu satu pesan, Berikutnya/Lewati | level 1/3/6 dan aturan yang baru; teks panjang; selesai sekali | WF Tutorial |
| L04 | sheet aturan | judul, kartu aturan yang sudah dipelajari | level awal hanya aturan tersedia; gulir kartu terakhir level 20 | WF Aturan |
| L05 | sheet petunjuk | tiga tingkat, status buka, koin/iklan, tutup | gratis sudah buka; terkunci berurutan; koin kurang; iklan muat/gagal/habis; simpan gagal | WF Petunjuk |
| R01 | hasil menang 1/2/3 bintang | ilustrasi, bintang, aturan tercapai, statistik, Lanjut/Ulang/Replay | tiga varian; hadiah peningkatan saja; hadiah 0; level 10/20 | 02 hasil + WF Hasil |
| R02 | sampai mangkuk, vas pecah | Oyen dan pecahan, 1 bintang, penjelasan kehilangan bintang | bisa lanjut; coba lagi; replay peristiwa; bukan gagal menang | WF Vas |
| R03 | bosan loop/batas | Oyen mengantuk, alasan, Coba lagi/Replay | loop; >80; susunan benda dipertahankan | WF Bosan |
| P01 | putar ulang, di dalam rute level | papan, jejak, langkah/slider, kontrol, kembali atur | 0/akhir; panjang 6/40/80; jeda/putar; vas pecah; tombol batas nonaktif | 02 replay |
| G01 | `/pengaturan` | kartu suara, bahasa, gerak, privasi, tentang, reset | sistem/en/id/pt/ru; audio off; teks130%; simpan gagal | 03 |
| G02 | privasi | link kebijakan dan tindakan persetujuan yang tersedia | launcher gagal; persetujuan tak tersedia; kembali | WF Privasi |
| G03 | Tentang | judul, versi, kredit, lisensi/link | teks panjang; gulir; tautan gagal | WF Tentang |
| G04 | reset | judul eksplisit, daftar data dihapus, Batal, Reset progres | batal tanpa perubahan; simpan gagal; sukses kembali rumah awal | WF Reset |
| K01 | Tambah Koin (dari saldo/hasil/petunjuk) | saldo, bonus harian, iklan pilihan | bonus tersedia/sudah; iklan siap/loading/gagal/habis/ditutup tanpa reward; simpan gagal | 03 + WF Koin |

## Rute pengembangan dan keadaan global

`/galeri`: token, tombol, tab, kartu, chip, sheet dan seluruh state tekan/nonaktif/loading. `/galeri/papan`: grid/benda dan hitbox; `/galeri/oyen`: pose puzzle; `/galeri/kucing`: sembilan karakter, 16 aksesoris, 21 barang, camilan; `/galeri/gerak`: transisi/kurangi gerak; `/galeri/suara`: pemutar audio dan status. Masing-masing tetap rute pengembangan tanpa tombol di menu pemain, memakai shell galeri baru yang sama (WF Galeri).

Rute tak dikenal kembali ke rumah melalui onException router. ID babak/level yang cocok pola rute tetapi datanya tidak ada menampilkan layar Tidak ditemukan, seperti `_NotFound` pada ChapterScreen/LevelScreen; sediakan Kembali ke peta atau Ke rumah sesuai konteks (WF Tidak ditemukan). Loading progres/aset memakai latar cream, indikator kecil, tanpa tombol transaksi sebelum siap (WF Memuat). Gagal simpan memakai pesan dekat tindakan, Coba lagi/Batal, tidak mengubah saldo sebelum commit (WF Gagal). Offline tetap bisa puzzle/rumah; hanya tindakan iklan menampilkan ketersediaannya, tanpa banner internet yang menghalangi game. Status fokus, nonaktif, tertekan, loading, berhasil, error menggunakan token yang sama di seluruh komponen.

## Pemeriksaan lintas layar saat implementasi

Semua baris diuji di 360×640, 390×844, 412×915; skala teks 100%/130%; empat bahasa; saldo besar 99999; seluruh kucing/barang dimiliki. Rumah baru, area kosong/penuh, antrean dan migrasi harus mendapat fixture terpisah. Setiap sheet diuji gulir sampai tombol/kartu terakhir dan Kembali Android. Animasi terus berjalan memakai helper settle yang sesuai, bukan menunggu semua animasi diam. Pengujian runtime v1 tidak membuktikan mockup v2 telah lulus overflow, semantik, atau TalkBack.
