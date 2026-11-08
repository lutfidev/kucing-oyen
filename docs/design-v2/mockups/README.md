# Mockup konsep v2

**Draf untuk tinjauan, bukan screenshot atau aset runtime.** Dibuat 8 November 2026 dengan alat imagegen bawaan, skill imagegen, menggunakan sisi kiri konsep A sebagai referensi. Prompt lengkap disimpan di [PROMPTS.md](PROMPTS.md). Referensi proyek dibuat dengan imagegen pada sesi sebelumnya; tidak menambahkan sumber seni pihak ketiga. Hak atas keluaran mengikuti ketentuan layanan alat; jangan mencantumkan lisensi open-source pihak ketiga yang tidak ada.

| Berkas | Isi | Resolusi dan batas |
| --- | --- | --- |
| [01-empat-area.png](01-empat-area.png) | Santai, Makan, Bermain, Perawatan | 1024×1536; satu papan 2×2, bukan empat screenshot resolusi native |
| [02-puzzle.png](02-puzzle.png) | peta, atur, hasil, replay | 1024×1536; ilustrasi papan bukan solusi level |
| [03-pendukung.png](03-pendukung.png) | Toko, koleksi/kartu, Pengaturan, hadiah/koin | 1024×1536; panel gabungan untuk menunjukkan keluarga komponen |
| [wireframes/index.html](wireframes/index.html) | layar dan sheet tambahan, termasuk keadaan gagal | diagram UI logis 390×844, dibuat dari kode; bisa dibuka lokal tanpa server |

## Hasil inspeksi dan koreksi yang mengikat draf

- Papan 01 mengikuti proporsi kucing, tekstur, outline, ruangan dan komposisi A. Santai masih punya mangkuk di pintu: hapus pada runtime; makan hanya di area Makan.
- Papan 01 menggambar dua mangkuk dan tombol Isi mangkuk: implementasi hanya satu mangkuk/jatah bersama mengikuti SPEC; ganti kontrol dengan Ajak makan/status siklus otomatis. Tidak mengusulkan stok pakan berbayar.
- Ikon tab Rawat di papan 01 masih bak mandi. Ganti sikat seperti kartu Rawat; mandi belum termasuk usulan v2.
- Papan 02: grid/penghalang, baki, angka target, 24 langkah dan +30 adalah ilustrasi komposisi. Gunakan data JSON dan hasil simulator untuk semua angka, benda, posisi, arah dan hadiah; grid implementasi selalu 7×9. Level 13 tidak boleh diberi stok kardus karena contoh gambar ini. Peta babak 2 memiliki level 11–20, bukan angka 1–10 gambar Dapur.
- Papan 03 menaruh daftar kucing tiga kolom dengan uraian panjang dan kartu detail bersama. Implementasi adalah daftar vertikal dalam sheet dan kartu detail terpisah agar muat teks130%; lihat wireframe. Tidak perlu saldo dalam header koleksi.
- Papan 03 memuat teks Salju "Perlu dirawat agar tetap sehat dan ceria": ganti status kegiatan faktual seperti "Sedang disikat". Tidak ada mekanisme kesehatan atau kewajiban rawat.
- Papan 03 memakai tanda centang pada barang yang tombolnya Beli: hapus centang dari kartu belum dimiliki; kartu dimiliki menampilkan Milikmu/Letakkan, bukan Beli. Rincian hadiah dan Tambah Koin adalah dua sheet terpisah, bukan layar bertumpuk.
- Teks putih pada oranye, ukuran kecil, dan hitbox pada gambar bukan spesifikasi aksesibilitas. Ikuti VISUAL.md (ink pada oranye, target48, wrap/scroll), empat ARB saat implementasi. Panel gambar tidak membuktikan layout responsif.

PNG disimpan utuh tanpa perubahan piksel. Wireframe terpisah memperjelas struktur; seni final untuk seluruh katalog tetap dikerjakan di langkah 2. Tidak ada gambar ini yang didaftarkan ke pubspec atau dipakai sebagai latar aplikasi.
