# Fondasi UI v2 — langkah 3

8 November 2026. Acuan: [VISUAL](../VISUAL.md), mockup keluarga komponen langkah 1 dan aset langkah 2. Galeri: `flutter run --route /galeri/ui-v2`, juga ditautkan dari `/galeri`. Semua angka/kegiatan di galeri adalah fixture, tidak menyimpan progres atau menjalankan rutinitas.

## Hasil

`lib/theme/ko_ui.dart` memuat warna, tipografi/tinggi baris, jarak, radius, outline 1,5 dp, bayangan 3 dp dan waktu transisi. `KoUi.theme()` dipasang di batas layar selama migrasi. Komponen `lib/widgets/v2/`: tombol primary/secondary/danger, chip, tab area, indikator kebutuhan, kartu kucing, header, navigasi dan sheet. Pemanggil memasok string terlokalisasi, callback dan nilai model. Layar pemain dimigrasikan pada langkah 5–12; komponen v1 masih diperlukan oleh layar tersebut.

Tombol tumbuh dengan teks, target minimal 48 dp, label penuh, keyboard Enter/Space, fokus, semantik aktif/nonaktif/terpilih/loading dan bunyi tap yang sudah ada. Tekan turun 3 dp; loading menahan callback. Kurangi gerak menonaktifkan transisi dan mengganti spinner dengan glyph jam pasir. Tab menggulir pilihan aktif pada sumbu horizontal tanpa menggeser halaman induk. Sheet maksimal 90% safe area, judul mendapat fokus, isi bergulir sementara tutup/konfirmasi tetap terlihat, dan fokus kembali ke pemicu. Navigasi memakai label 14/20 dengan padding ringkas agar kata panjang tetap utuh; CTA puzzle berikon potongan puzzle, terpisah dari tab aktivitas Bermain.

## Render yang diperiksa

Render berasal dari widget Flutter dan font/aset bundel, bukan mockup HTML atau gambar AI. Matriks otomatis: en/id/pt/ru × 360×640, 390×844, 412×915 × teks 100%/130% (24 kombinasi). Ekspor ini menampilkan ukuran terkecil dengan teks 130%.

| Render | Cakupan |
| --- | --- |
| [Indonesia](id-small.png), [Inggris](en-small.png), [Portugis](pt-small.png), [Rusia](ru-small.png) | header, saldo 99999, tab bergulir, CTA puzzle dan navigasi tetap |
| [Kartu ID](id-card.png), [EN](en-card.png), [PT](pt-card.png), [RU](ru-card.png) | potret v2, nama/status, kebutuhan rendah dan aksi |
| [Sheet Rusia](ru-sheet.png) | judul panjang, Cyrillic, scroll dan konfirmasi |
| [Tombol/status](id-states.png) | aktif, nonaktif, loading, bahaya, chip dan kebutuhan |
| [Token dan fallback](id-tokens.png) | palet dan sampel Fredoka/Nunito/Cyrillic |

Perbaikan dari pemeriksaan: judul Cyrillic Fredoka semula kotak; fallback eksplisit ke NunitoUi memperbaikinya. Label navigasi panjang semula terpotong di tengah kata; padding ringkas diperiksa kembali dengan metrik baris. Oranye pressed dipakai untuk bayangan, bukan isi, karena ink di atasnya hanya 3,46:1. Ink/orange 4,59:1; mutedInk/paper 6,42:1; paper/danger 6,05:1; paper/success 5,30:1. Semua pasangan isi/teks komponen diuji ≥4,5:1; status rendah juga memakai ikon dan teks.

## Font dan reproduksi

Fredoka tidak mencakup Cyrillic; judul memakai fallback NunitoUi. NunitoUi regular memakai font variabel Nunito dari [Google Fonts](https://github.com/google/fonts/tree/main/ofl/nunito), diunduh 8 November 2026 dari `Nunito[wght].ttf`, disimpan utuh sebagai `assets/fonts/Nunito-Variable.ttf` (276.932 byte, SHA-256 `bb55a5ca5c2042335b3991af27c4d0705d0ef41cac6164ac737fd8f2a1e85207`). SIL OFL yang sama dengan `OFL-Nunito.txt` telah dibandingkan identik. Semibold/bold memakai berkas Nunito yang sudah dibundel. Family baru menjaga pemilihan font layar v1 selama migrasi; tidak ada unduhan font saat runtime.

```sh
flutter test test/widgets/ui_v2_test.dart --dart-define=UI_REVIEW=true
```

Flag ekspor hanya menulis PNG saat diminta. Tanpa flag, test tidak memperbarui artefak tinjauan.

## Verifikasi dan batas

29 test fondasi meliputi kontras, tekan/batal/keyboard, callback loading/nonaktif, nilai/ikon kebutuhan, matriks layout, tab terpilih, batas tinggi/gulir/konfirmasi sheet, navigasi, kurangi gerak, pemulihan fokus dan ekspor. Font aplikasi dimuat oleh konfigurasi test proyek. Verifikasi akhir: `flutter analyze` bersih; `flutter test` 2.841 lulus, 135 skip historis; format 244 file bersih; pemeriksaan berkas tinjauan terjemahan dan generator 209 aset lulus. Solusi seluruh 20 level tetap lulus.

Pemeriksaan gambar dan kode dilakukan di sesi utama. Reviewer independen tidak dijalankan: sesi ini membatasi delegasi dan skill superpowers tidak tersedia. TalkBack di HP, penampilan font sistem, animasi/fps perangkat dan penilaian visual pemilik repo belum diuji; mengikuti langkah 13/15. Render galeri membuktikan komponen, bukan kelulusan tata letak Beranda baru atau model banyak area.
