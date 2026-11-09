# Desain v2 — bahan tinjauan langkah 1

Status: **DISETUJUI pemilik repo pada 8 November 2026** setelah tinjauan mockup dan usulan aturan. Langkah 1 selesai; paket aset langkah 2 tersedia untuk tinjauan. Rumah pemain memakai desain v2 sejak implementasi langkah 5; layar lainnya masih memakai visual sebelumnya; integrasi dan penyelesaian mengikuti langkah 3–16. Masukan selanjutnya dicatat sebagai revisi spesifikasi.

- [Spesifikasi](SPEC.md): aturan usulan dan batas implementasi.
- [Inventaris layar dan keadaan](SCREENS.md): cakupan rute, sheet, dan keadaan gagal.
- [Token dan arahan aset](VISUAL.md): ukuran, karakter, furnitur, animasi, aksesibilitas.
- [Mockup](mockups/README.md): gambar konsep baru, sumber, prompt, dan koreksi yang wajib diikuti.
- [Aset produksi langkah 2](assets/REVIEW.md): render sembilan karakter, aksesoris, barang, empat area, ukuran dan hasil pemeriksaan. Galeri `/galeri/aset-v2`.
- [Fondasi UI langkah 3](ui/REVIEW.md): komponen, render empat bahasa dan pemeriksaan responsif. Galeri `/galeri/ui-v2`.
- [Model rumah langkah 4](model/REVIEW.md): area, rutinitas, ajakan, migrasi snapshot dan kontrak integrasi layar berikutnya.
- [Beranda langkah 5](home/REVIEW.md): runtime rumah v2, koleksi/ajakan/hadiah; visual akhir diterima pemilik repo pada 9 November 2026 dan langkah 5 selesai. PR #44 sudah di-merge.
- [Area Makan langkah 6](dining/REVIEW.md): fasilitas makan, ajakan/otomatis, antrean, status jatah dan render empat bahasa.
- [Rencana penyelesaian langkah 1](PLAN.md): hasil yang tersedia dan syarat persetujuan.

Konsep A pada [referensi terpilih](../design-brief/rumah-oyen-area/preview-perbandingan.png) menjadi acuan gaya. Gambar AI menunjukkan arah seni; angka, aturan, dan cakupan mengikuti dokumen tertulis. Gambar bukan screenshot aplikasi atau aset runtime.

Versi aplikasi lama tersimpan di branch [`archive/v1-desain-lama`](https://github.com/lutfidev/kucing-oyen/tree/archive/v1-desain-lama). Branch ini adalah snapshot kode v1; dokumentasinya sudah memuat arah redesign. Jalankan `git checkout archive/v1-desain-lama` untuk membuka kode lama (pastikan perubahan lokal disimpan dahulu).
