# Langkah 5: Beranda Santai dan perpindahan area

Acuan: ROADMAP langkah 5, SPEC, SCREENS H01/H05/H06/H10/H11 dan VISUAL.

- Gunakan aset/komponen v2 untuk rumah pemain; renderer v1 tetap tersedia
  untuk layar yang belum dimigrasikan dan regresi komponen lama.
- Header saldo/bintang, tab empat area beserta jumlah hadir, ruangan berlapis
  dengan kucing dari lokasi model, pilihan ringkas, hadiah gabungan, CTA puzzle
  dan navigasi Toko/Kucing/Pengaturan.
- Pilihan kucing disimpan selama sesi controller; tab terakhir melalui snapshot.
  Temukan mengikuti tujuan perjalanan, tanpa memindahkan kucing.
- Sheet koleksi, detail/ajakan/batal, hadiah dan ringkasan migrasi memakai data
  hidup. Camilan/aksesoris mempertahankan akses ke inventaris yang ada.
- Penggerak waktu aktif monotonik, jeda route/lifecycle/iklan dan gagal simpan;
  kurangi gerak hanya mengubah gambar. Tidak menjalankan mesin v1 bersamaan.
- Uji perilaku navigasi, kapasitas, ajakan, penyimpanan gagal, lifecycle,
  reduced motion serta ukuran/bahasa/skala teks. Render screenshot Santai baru,
  penuh, kosong dan perjalanan untuk tinjauan pemilik repo.
- Area Makan/Main/Rawat menggunakan kerangka dan data model yang sama;
  penyelesaian kontrol/animasi khusus tetap langkah 6–8. Hias/Gudang langkah 9.

Penerimaan visual akhir tetap memerlukan tinjauan screenshot pemilik repo;
jangan mencentang langkah 5 hanya berdasarkan test otomatis.
