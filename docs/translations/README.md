# Tinjauan terjemahan

Berkas untuk dikirim ke penutur asli (langkah 20 roadmap). Isinya setiap kunci ARB di `lib/l10n/` (teks Inggris, teks bahasa itu, deskripsi, placeholder, dan kolom *Feedback* kosong), lalu listing toko dari `docs/store/`. Pedoman nada dan aturan istilah ada di bagian atas tiap berkas, dalam bahasa Inggris supaya bisa dibaca peninjau.

- `review-en.md`: untuk penutur asli Inggris (kolom Indonesia sebagai teks asli).
- `review-pt.md`: Portugis Brasil.
- `review-ru.md`: Rusia.

Berkas ini dibuat skrip, jangan diedit tangan. Jalankan ulang setiap kali ARB atau listing berubah:

```
python tool/translations/make_review.py
```

`python tool/translations/make_review.py --check` hanya mengecek (tanpa menulis) dan gagal kalau ada berkas yang basi. Cek ini ikut `/check` dan `test/l10n/review_files_test.dart` (dilewati kalau Python 3 tidak ada).

**Untuk peninjau:** isi kolom *Feedback* di **salinan** berkasnya (unduh, atau salin ke dokumen sendiri), lalu kirim salinan itu kembali. Jangan mengisi berkas di repo ini: skrip menimpanya setiap kali ARB berubah, jadi masukan di sana bisa hilang.

Masukan yang kembali diterapkan ke `lib/l10n/app_<bahasa>.arb` dan `docs/store/listing-<bahasa>.md`, lalu `flutter gen-l10n` dan `flutter test test/screens/overflow_test.dart` (teks yang lebih panjang bisa tidak muat). Teks Indonesia tidak ditinjau di sini karena ditulis lebih dulu oleh pemilik repo.
