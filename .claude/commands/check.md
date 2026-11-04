---
description: Format, analyze, dan test seluruh proyek
---
Jalankan berurutan dan perbaiki sampai bersih:
1. `dart format lib test`
2. `flutter analyze` (harus "No issues found!")
3. `python tool/translations/make_review.py --check` (`python3` atau `py -3` kalau `python` tidak ada) (berkas tinjauan terjemahan sesuai ARB; kalau basi, jalankan skripnya tanpa `--check` dan commit hasilnya)
4. `flutter test`
Laporkan ringkas hasilnya. Jangan men-skip atau menghapus test untuk membuatnya hijau.
