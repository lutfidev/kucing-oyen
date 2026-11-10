# Langkah 14 — merek dan materi toko v2

Basis: PR #52 sudah merged ke main (`0f6b020`); branch `feat/design-v2-store-assets`.
Tidak mengubah simulator, ekonomi, SDK atau menyiapkan publikasi produksi.

- [x] Audit generator lama, sumber rig/palet, rute pemain dan listing empat bahasa.
- [x] Ganti sumber kepala merek dengan kepala rig Oyen v2; pertahankan lubang monokrom dan margin aman.
- [x] Buat launcher lima densitas, splash empat bahasa, ikon 512 dan grafis fitur 1024×500 empat bahasa.
- [x] Ganti skenario potret v1 dengan runtime v2, fixture snapshot terisolasi dan jam tetap.
- [x] Ekspor delapan screenshot toko per bahasa serta dokumentasi rumah/puzzle/rute tambahan.
- [x] Perbarui listing empat bahasa, review terjemahan, dan galeri README.
- [x] Tinjau seluruh render, perbaiki temuan dan catat batas pemeriksaan host/native.
- [x] Verifikasi format/analyze/test, generator aset/terjemahan, inventaris PNG dan APK debug.
- [x] Commit, push dan buka PR langkah 14; merge oleh pemilik repo.

Keputusan implementasi: potret toko 432×768 dp ×2,5 = 1080×1920,
sehingga bagian kartu rumah terlihat pada layar portrait 9:16. Empat area,
Toko aksesoris, peta babak 2, puzzle atur dan berhasil menjadi delapan potret.
Fase jalan disimpan untuk dokumentasi. Potret lain meliputi peta babak 1,
barang, koleksi, makanan dan Pengaturan dalam empat bahasa.

Gambar adalah render widget aplikasi dengan aset runtime asli, bukan tangkapan
OS Android. Native launcher/splash dan persetujuan visual pemilik repo tetap
bagian pemeriksaan HP langkah 15. Tidak memakai mockup AI baru atau mengembalikan
screenshot v1. Sumber/lisensi tetap mengikuti assets/art/v2/README.md.
