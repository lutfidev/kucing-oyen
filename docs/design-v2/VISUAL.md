# Token visual dan arahan aset — draf

Angka ini usulan untuk implementasi dan pengukuran berikutnya. Acuan gaya tetap sisi kiri konsep A. Jangan menyalin outline atau proporsi kucing renderer v1.

## Token

| Token | Nilai usulan | Pemakaian |
| --- | --- | --- |
| cream | #FFF4E2 | latar dan ruang kosong |
| paper | #FFFAF0 | permukaan kartu/sheet |
| peach | #FFD8AC | wallpaper/aksen |
| honey | #E9AE60 | kayu, lantai |
| orange | #FF8208 | tombol utama/dekorasi |
| orangePressed | #E36B00 | kedalaman tombol |
| ink | #573018 | semua teks utama/outline |
| mutedInk | #79543A | teks sekunder |
| success | #427443 | status berhasil, disertai ikon/teks |
| water | #81C6E6 | air puzzle, disertai bentuk riak |
| danger | #A63D32 | tindakan hapus/gagal, disertai teks |

Teks di atas tombol oranye memakai ink, bukan putih kecil, agar kontras teks normal memenuhi target 4,5:1. Putih di gambar konsep bukan token implementasi. Semua kombinasi teks diuji kontras saat langkah 3; warna outline tidak menggantikan kontras isi teks. Bentuk/glyph dan label menjelaskan status tanpa bergantung pada warna.

Fredoka untuk judul (20/26, 24/30, 30/36; semibold), Nunito untuk isi (16/22, 14/20; regular/bold). Angka saldo 16/22 bold. Teks kecil hanya sekunder ≥12/18. Fallback glyph Cyrillic wajib diverifikasi. Jangan meraster teks UI ke gambar.

Jarak 4/8/12/16/24; margin layar 16, gap kartu 12. Radius chip 16, tombol 18, kartu 22, sheet 28. Outline UI 1,5–2 dp cokelat, ilustrasi 2–3 dp pada skala desain. Bayangan tombol turun 3 dp dengan warna cokelat transparan; hindari blur berat/kontras hitam. Tekstur kertas hanya pada ilustrasi, tidak menutupi teks/grid.

## Kerangka ponsel

Ukuran acuan 390×844 dp; inset sistem di luar area konten. Lebar minimum 360 dp, pemeriksaan hingga 412×915, teks 100%/130%, en/id/pt/ru. Gambar konsep 2×2 bukan bukti layout bisa muat di 360×640.

Rumah pada 390×844: header 48, tab 52, judul area/aksi Hias 32, ruangan fleksibel (target sekitar 390), kartu kucing minimum 80, hadiah minimum 48, CTA puzzle 52, navigasi 56, gap/tepi sesuai sisa ruang. Jangan mengunci total tinggi berdasarkan penjumlahan thumbnail. Header boleh dua baris saat teks panjang. Area room memakai aspect-ratio adaptif dan skala kamera, bukan mengecilkan tombol.

Pada tinggi 640 atau teks 130%: kartu ringkas berubah dua baris, aksi tambahan pindah ke sheet; konten atas dapat scroll dengan navigasi dan Main Puzzle tetap terjangkau. Ruangan minimum 240 dp dan tidak boleh tertutup kartu. Tab horizontal dapat digulir dengan indikator tepi; tab aktif otomatis terlihat. Label lengkap tetap tersedia pada semantik, jangan memotong nama kucing atau harga penting.

Sheet maksimum 90% tinggi safe area, isi scroll, judul/tutup dan tombol konfirmasi tetap terjangkau; fokus awal ke judul dan pulih ke pemicu saat ditutup. Target sentuh minimum 48×48 dp, termasuk tutup, ikon saldo, replay, dan node peta. Petak puzzle boleh lebih kecil secara visual tetapi sediakan pilih-benda-lalu-ketuk, sorotan, dan navigasi semantik per petak; jangan memperlebar hitbox yang tumpang tindih.

Papan puzzle mempertahankan 7 kolom×9 baris termasuk batas; skala min(lebar tersedia/7, tinggi tersedia/9). Kontrol dan baki tidak menimpa papan. Bila tinggi terbatas, header/target diringkas dan panel aturan masuk sheet. Orientasi portrait; tidak meregangkan petak menjadi persegi panjang.

## Karakter dan aksesoris

Seluruh sembilan identitas katalog digambar ulang, mempertahankan nama/ID dan ciri yang dikenali: Oyen tabby oranye; Salju putih; Telon tiga warna; Arang gelap; Mendung abu; Kopi Susu krem-cokelat; Mochi pucat lembut; Bos dengan ciri wajah khas; Kembang bercorak. Pola final Bos/Kembang dan setiap lembar karakter ditinjau pada langkah 2, tidak diambil dari dugaan nama. Bandingkan identitas warna dengan katalog v1 tanpa mengadopsi bentuk lama.

Proporsi usulan: kepala ±55% tinggi duduk, pipi bulat, muzzle kecil krem, badan pendek lebar, kaki membulat; Oyen rumah dan puzzle memakai wajah/pola yang sama. Ukuran rumah target 72–104 dp; puzzle disederhanakan agar muat satu petak dan arah hidung/ekor jelas. Potret terpisah dari sprite badan, bukan crop yang memotong telinga.

Pose wajib per kucing: idle kedip, jalan kiri/kanan/depan/belakang, duduk, tidur, makan, main, sikat/elus, senang, kaget, lesu ringan. Oyen tambahan: duduk kardus, menjatuhkan barang, mengejar ikan, makan ikan, menang, bosan. Arah puzzle harus tetap jelas juga saat diam. Gerak jalan 6–8 frame; reaksi 3–5; idle hemat frame. Angka ini target produksi untuk dibandingkan kualitas/memori, bukan atlas yang sudah tersedia.

Seluruh 16 aksesoris katalog dipertahankan dan digambar ulang: pita, jepitBunga, bandana, dasiKupu, kalung, syal, beanie, topiKoki, baret, kacamata, headphone, tandukRusa, topiPesta, topiPenyihir, mahkota, mahkotaRaja. Buat jangkar headTop/headSideLeft/headSideRight/neck/face per pose dan arah, mirror eksplisit, tidak menempelkan aksesori pada koordinat absolut layar. Uji seluruh sembilan kucing dengan jangkar ekstrem; aksesoris tidak hilang/bergeser saat tidur/jalan.

## Ruangan dan lapisan

Lapisan: wallpaper → jendela/cahaya lembut → barang dinding → lantai → karpet/bayangan → barang/kucing urut kaki Y → efek kecil → UI. Jendela berbingkai kayu, tirai krem, lantai papan madu, outline membulat. Ruangan terasa tampak depan dengan sedikit lantai terlihat; bukan rumah empat kotak, bukan 3D isometrik. Sisakan jalur pintu dan ruang lantai agar kucing terbaca.

Santai: jendela pusat, rak buku, keranjang, karpet. Makan: lemari/pakan latar dan satu mangkuk interaktif. Main: tiang, bola dan lintasan aman; mainan dekoratif tidak otomatis menjadi penghalang puzzle. Rawat: handuk, alas dan sikat; tanpa bak mandi. Seluruh 21 barang termasuk mangkuk mengikuti tabel migrasi SPEC, bukan furnitur baru yang harus dibeli untuk mengakses fitur dasar.

Paket aset di langkah 2: background per area berlapis, furnitur dipisah mask depan/belakang dan titik interaksi, sprite karakter/aksesoris, art papan per babak, potret/hasil/tutorial, glyph UI, logo/ikon/splash baru. File runtime di `assets/art/v2/`, manifest mencatat dimensi, pivot, jangkar, sumber, lisensi, prompt, atlas, dan turunan. Pilihan raster/vector/gabungan ditetapkan dari uji kemiripan dan profil, bukan keputusan otomatis dari PNG konsep.

Anggaran awal untuk diuji: tambahan aset terkompresi ≤20 MB, tekstur decode aktif ≤64 MiB untuk rumah, cache varian bounded dan atlas maksimal 2048² per halaman. Ini usulan anggaran, belum pengukuran. Jangan preload semua layar/semua pose sembilan kucing tanpa batas. Target 60 fps, build/raster p95 masing-masing <16,67 ms pada HP uji; bingkai lambat dilaporkan terpisah dan cache diamati selama transisi berulang. Konfirmasi/ubah anggaran berdasarkan prototipe langkah 2.

## Gerak, suara, dan aksesibilitas

Transisi tab 180–240 ms, ketuk 100 ms, reaksi kucing singkat; jangan membuat kontrol menunggu animasi. Kurangi gerak menghilangkan kamera/partikel/lompatan dekoratif dan memakai pose akhir, tetapi urutan/hasil simulasi tidak berubah. Tidak ada kedipan cepat atau badge hadiah di atas semua kucing bersamaan.

Audio dipakai ulang bila cocok, suara aktivitas ditambah hanya setelah katalog baru ditetapkan. Jeda suara di latar/iklan; hormati pilihan audio. TalkBack: nama kucing + area/kegiatan, nilai kebutuhan, tindakan tersedia; perubahan antrean diumumkan tanpa spam per frame. Screen reader dapat memilih kucing dari daftar tanpa mengejar sprite. Bahasa panjang memakai wrap/scroll; label dan pesan baru masuk empat ARB saat implementasi. Teks konsep Indonesia di gambar bukan berkas terjemahan produksi.
