# Langkah 13 — animasi, suara, aksesibilitas, performa

Cakupan mengikuti ROADMAP dan SPEC v2 yang sudah disetujui. Tidak menambah
aturan permainan atau mengubah seni. Eksekusi di sesi utama.

1. Baseline dari main setelah PR #51 merged: pub get, analyze, seluruh test.
2. Reproduksi jeda audio/puzzle/replay dan penghormatan TickerMode melalui
   regresi widget. Perbaiki sumber jam dan lifecycle tanpa menambah waktu
   selama layar tertutup. Pertahankan preferensi jeda pemain.
3. Audit scene rumah: kesinambungan fase animasi, target sentuh/semantik,
   batas ukuran nol, pose dan suara kegiatan yang terlihat. Uji kurangi
   gerak serta pause bertumpuk iklan/latar belakang.
4. Ganti helper profil lama dengan fixture v2 sembilan kucing, seluruh barang
   dimiliki dan penempatan aman sesuai kapasitas. Ukur setiap area, transisi,
   puzzle, build/raster, cache dan memori dengan sampel terbatas. Data hanya
   di memori. Tambahkan diagnostik host bila HP tidak tersedia; angka host
   tidak membuktikan 60 fps HP.
5. Verifikasi semantik/target sentuh/kontras dan teks besar pada v2, renderer
   dan cache terbatas. Catat seluruh batas TalkBack/perangkat yang belum diuji.
6. Format, analyze, terjemahan/generator, seluruh test dan APK debug. Review
   kode, perbaiki temuan, tulis laporan desain v2/polish dan perbarui roadmap.
   Commit kecil lalu push dan buka PR; merge oleh pemilik repo.

Kriteria selesai: regresi lifecycle lulus; tak ada cache per waktu tanpa
batas; helper profil dapat diulang dan tidak menulis data pemain; bukti serta
keterbatasan pengukuran jelas. Target 60 fps tetap perlu pengukuran HP.
