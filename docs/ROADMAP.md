# Roadmap baru Ginger Logic

Penomoran dimulai ulang pada **8 November 2026**, atas permintaan pemilik repo. Dokumen ini menggantikan seluruh urutan langkah lama. Release tetap menjadi tahap akhir setelah desain dan fitur baru siap.

## Tujuan dan acuan

Perombakan visual seluruh game: kucing, ruangan, barang, aksesoris, UI, puzzle, peta, hasil, tutorial, ikon, splash, dan materi toko mengikuti **konsep A — satu area per layar**.

Acuan: [preview Rumah Oyen](design-brief/rumah-oyen-area/preview-perbandingan.png), **sisi kiri**, dan [brief baru](design-brief/rumah-oyen-area/ARAH_DESAIN.md). Sisi kanan bukan desain terpilih. Preview adalah konsep raster, belum aset runtime atau spesifikasi seluruh layar.

Pilihan pemilik repo: kucing beraktivitas sendiri **dan** bisa diajak pemain. Santai, Makan, Bermain, dan Perawatan serta kapasitas, perpindahan, aktivitas, kebutuhan, dan hadiah telah disepakati pada langkah 1 di [spesifikasi v2](design-v2/SPEC.md).

Fondasi: Flutter + Flame, Android portrait, simulator/solver dan 20 level, progres/koin/koleksi, empat bahasa (en/id/pt/ru), suara dan iklan yang sudah berjalan. Rumah baru memakai migrasi simpanan yang aman. Penomoran ulang roadmap bukan reset progres pemain.

## Cara bekerja

- Langkah berikutnya adalah kotak pertama yang belum dicentang. Satu langkah menghasilkan pekerjaan yang bisa ditinjau dan diuji mandiri, biasanya satu PR; alur Git mengikuti `CLAUDE.md`.
- Selesaikan spesifikasi langkah 1 dahulu. Angka tata letak, bentuk sprite, dan aturan interaksi mengikuti desain baru yang disepakati, bukan menebak dari thumbnail.
- Desain, screenshot, dan rencana visual lama dibersihkan. Riwayat Git bukan acuan visual aktif. Jangan membuat ulang gambar lama untuk memenuhi dokumen baru.
- Aset dan kode runtime diganti bertahap ketika penggantinya siap, sehingga aplikasi tetap dapat dijalankan. Test simulasi, solver, transaksi, dan penyimpanan tetap berlaku.
- Test visual/piksel diperbarui bersama desain yang berubah. Jangan menghapus test perilaku untuk menyembunyikan kegagalan.
- Teks baru masuk keempat ARB. Perbarui GDD, catatan keputusan, daftar layar, dan dokumentasi struktur sesuai hasil setiap langkah.
- Akhiri langkah dengan format, analyze, test yang sesuai, serta pemeriksaan visual bila tampilan berubah. Catat hasil dan batas pengujian.
- Ini urutan proyek, bukan instruksi membangun semuanya sekaligus. Buat rencana implementasi rinci per langkah setelah keputusan desain tersedia.

## Status

- [x] 1. Spesifikasi lengkap desain baru dan alur rumah
- [x] 2. Aset kucing, furnitur, ruangan, dan animasi baru
- [ ] 3. Fondasi UI dan komponen sesuai desain baru
- [ ] 4. Model banyak area, rutinitas, dan migrasi progres
- [ ] 5. Beranda Santai dan perpindahan area
- [ ] 6. Area Makan: otomatis dan ajakan pemain
- [ ] 7. Area Bermain: otomatis dan ajakan pemain
- [ ] 8. Area Perawatan dan interaksi kucing
- [ ] 9. Toko, koleksi, aksesoris, dan hias per area
- [ ] 10. Visual puzzle: papan, benda, dan Oyen
- [ ] 11. Peta babak, hasil level, dan putar ulang
- [ ] 12. Tutorial, petunjuk, koin, dan Pengaturan
- [ ] 13. Animasi, suara, aksesibilitas, dan performa
- [ ] 14. Screenshot, ikon, splash, dan materi Play Store baru
- [ ] 15. Pengujian menyeluruh di HP dan kandidat rilis
- [ ] 16. Persiapan produksi dan release Play Store

## 1. Spesifikasi lengkap desain baru dan alur rumah

**Selesai, disetujui pemilik repo pada 8 November 2026:** [desain v2](design-v2/README.md) berisi spesifikasi, inventaris, token, mockup dan wireframe. Masukan berikutnya dicatat sebagai revisi. PR #40 sudah merged; paket aset langkah 2 tersedia, integrasi runtime mengikuti langkah 3–14.

**Baca:** brief dan preview A; `lib/app/routes.dart`, `router.dart`, `lib/screens/`; model `home.dart`, `needs.dart`, `room_life.dart`; GDD bagian aturan dan level.

**Kerjakan:**

- Buat `docs/design-v2/SPEC.md`, inventaris layar/keadaan, token visual, dan mockup resolusi ponsel. Liputi seluruh rute dan sheet.
- Rancang empat area, perpindahan, kapasitas yang nyaman, posisi kucing antararea, serta cara menemukan kucing yang tidak sedang terlihat.
- Tetapkan prioritas otomatis/ajakan, antrean, pembatalan, area tertutup, aktivitas selesai, dan perilaku saat pemain masuk puzzle atau menutup aplikasi.
- Putuskan hubungan aktivitas dengan Lapar/Senang dan hadiah. Hasil disepakati: tanpa mandi/kebersihan baru, hadiah gabungan bernominal v1, kapasitas 3/2/2/2; lihat SPEC.
- Desain seluruh kucing baru, barang, aksesoris, header/navigasi, puzzle, peta, hasil, Toko, tutorial, dan Pengaturan. Sertakan kosong/penuh, kebutuhan rendah, teks panjang, dan layar kecil.
- Tetapkan kemiripan dengan A: komposisi, proporsi kucing, palet, outline, tekstur, furnitur dan tombol. Tunjukkan hasil ke pemilik repo untuk disepakati.

**Selesai jika:** seluruh layar tercakup dan keputusan yang memengaruhi pemain sudah ditetapkan dalam desain yang disetujui. Langkah ini menghasilkan desain, belum perubahan runtime.

## 2. Aset kucing, furnitur, ruangan, dan animasi baru

**Selesai implementasi pada 8 November 2026:** [paket dan tinjauan aset](design-v2/assets/REVIEW.md), galeri `/galeri/aset-v2`. 209 bagian vector orisinal untuk sembilan kucing, seluruh aksesoris/barang katalog dan empat latar berlapis; rig arah/pose bersama dan jangkar tervalidasi. Kontribusi entry APK sekitar 79 KB terkompresi, pengukuran RSS/recording host tercatat dengan batasnya. Review independen dan pemeriksaan visual render selesai; 2.812 test lulus, analyze bersih, APK debug berhasil. Paket siap ditinjau pemilik repo melalui PR; belum mengganti layar runtime pemain. Berikutnya langkah 3 setelah PR langkah ini di-merge.

**Baca/ubah:** spesifikasi langkah 1; renderer `kitty.dart`, `kitty_painter.dart`, `room_item_art.dart`; katalog `kitties.dart`, `accessories.dart`, `home_items.dart`; `pubspec.yaml`.

- Desain ulang seluruh sembilan kucing dan barang/aksesoris yang dipertahankan katalog. Kucing di puzzle dan rumah harus terlihat sebagai karakter yang sama.
- Buat latar tiap area berlapis, pisahkan dekorasi dan objek interaktif. Siapkan pose diam/jalan/tidur/makan/bermain/perawatan/reaksi serta jangkar aksesoris dan arah hadap.
- Tetapkan pipeline pada `assets/art/v2/` dan renderer baru bila diperlukan. Pilih raster/vector atau gabungannya berdasarkan kemiripan dan hasil ukur, bukan menganggap gambar konsep siap dipakai.
- Catat sumber/lisensi, resolusi, transparansi, atlas/kompresi, prosedur pembuatan ulang, serta anggaran memori dan ukuran build.

**Selesai jika:** galeri aset sesuai desain, animasi/aksesoris tidak bergeser, aset berada di repo, dan biaya memori/ukuran terukur.

## 3. Fondasi UI dan komponen sesuai desain baru

**Baca/ubah:** `lib/theme/`, `lib/widgets/`, galeri, test tema/widget.

- Terapkan token warna, font/tinggi baris, jarak, radius, outline dan bayangan; buat tombol, tab area, chip, kartu kucing, sheet dan indikator kebutuhan.
- Header/navigasi konsisten; tombol menuju puzzle jelas dan tidak tertukar dengan aktivitas Bermain.
- Periksa 360×640 sampai ukuran HP uji, teks 100%/130%, empat bahasa, sentuhan dan semantik.

**Selesai jika:** galeri sesuai mockup, semua keadaan tekan/nonaktif/loading jelas, teks muat dan test komponen lulus.

## 4. Model banyak area, rutinitas, dan migrasi progres

**Baca/ubah:** `lib/game/model/home.dart`, `room.dart`, `room_life.dart`, `needs.dart`; `lib/app/progress_scope.dart`, `progress_store.dart`; test model/progres.

- Tambah identitas area, penempatan barang/kucing, rutinitas otomatis, ajakan, antrean, pembatalan, pause/resume dan kurangi gerak berdasarkan spesifikasi.
- Satu kucing tidak muncul ganda atau menerima dua aktivitas bersamaan. Logika dipisahkan dari gambar.
- Migrasikan bintang, koin, kucing, barang, aksesoris, petunjuk, pengaturan, kebutuhan dan hadiah dari simpanan lama. Tetapkan area awal barang/kucing lama.
- Test data lama/rusak, jam mundur, simpan gagal, ketukan ganda, tutup/buka ulang dan hadiah sekali saja.

**Selesai jika:** fixture progres lama termigrasi tanpa kehilangan pembelian, rutinitas dapat diuji deterministik dan transaksi aman saat gagal simpan.

## 5. Beranda Santai dan perpindahan area

**Baca/ubah:** `lib/screens/room/`, router/rute, komponen/aset/model langkah 2–4; test kamar/navigasi.

- Bangun Santai berlapis, header, tab area, kucing, kartu pilihan, hadiah dan panel bawah sesuai A.
- Hubungkan pemilihan kucing/ajakan dan perpindahan area tanpa duplikasi atau reset keadaan.
- Periksa kosong/penuh, kebutuhan rendah, kucing berpindah, kembali dari puzzle, teks panjang dan batas sentuh/overlap.

**Selesai jika:** screenshot terhadap mockup diterima dan alur utama berfungsi, bukan hanya gambar statis.

## 6. Area Makan: otomatis dan ajakan pemain

- Terapkan desain Makan, titik makan, perjalanan/antrean, animasi, stok/isi ulang sesuai spesifikasi dan model kebutuhan langkah 4.
- Kucing dapat datang sendiri dan diajak; kebutuhan/hadiah berubah tepat sekali termasuk saat pindah layar atau aplikasi dijeda.
- Test kenyang, persediaan habis, mangkuk dipakai, jam mundur, ketukan berulang dan simpan gagal.

**Selesai jika:** alur otomatis/ajakan dari Santai ke Makan lalu kembali ke rutinitas berfungsi dan semua keadaan terlihat jelas.

## 7. Area Bermain: otomatis dan ajakan pemain

- Terapkan latar/mainan yang disepakati, pilihan otomatis dan ajakan, animasi mulai/main/selesai serta kapasitas/lintasan agar kucing tidak bertumpuk.
- Hubungkan Senang dan hadiah sesuai spesifikasi; test batas hadiah, mainan dipakai, gangguan aktivitas dan kembali dari puzzle.

**Selesai jika:** tindakan mudah dipahami dan perilaku/hadiah mengikuti keputusan langkah 1, tanpa kewajiban perawatan tambahan yang belum disepakati.

## 8. Area Perawatan dan interaksi kucing

- Terapkan ruang/perlengkapan/kontrol/animasi perawatan yang disetujui: elus/sikat dan mandi bila dipilih. Jangan otomatis menambah kebutuhan baru.
- Hubungkan otomatis/ajakan sesuai aktivitas, pembatalan aman dan reaksi yang singkat; tombol tidak terasa mengabaikan pemain.
- Test kebutuhan penuh, batas interaksi, ketukan ganda, pause/resume, pembaca layar dan kurangi gerak.

**Selesai jika:** interaksi utuh dan sesuai spesifikasi; hukuman karena pemain lama tidak membuka aplikasi tidak ditambahkan tanpa keputusan desain.

## 9. Toko, koleksi, aksesoris, dan hias per area

**Baca/ubah:** `lib/screens/shop/`, `room/decorate.dart`, `kitty_card.dart`, model katalog/rumah/progres; test toko/kartu/dekorasi.

- Desain ulang Toko/daftar kucing, pratinjau, adopsi, kepemilikan, aksesoris dan akses ke lokasi kucing.
- Hubungkan furnitur dengan area, Gudang, pindah/simpan, jangkar interaksi serta transaksi koin.
- Test koin pas/kurang, barang dimiliki, stok penuh, seret keluar batas, pembelian ganda, persistensi dan label empat bahasa.

**Selesai jika:** koleksi mudah dicari tanpa memenuhi Beranda, pembelian dan tata letak per area tersimpan.

## 10. Visual puzzle: papan, benda, dan Oyen

**Baca/ubah:** `lib/screens/level/`, `lib/game/components/`, renderer papan/Oyen/benda, baki dan test terkait.

- Ganti seni papan, lantai, tembok, meja, gelas/vas, ikan, air, kardus, mangkuk, Oyen, efek, baki dan kontrol mengikuti gaya baru.
- Jaga keterbacaan grid, petak tujuan, arah hadap dan seretan/pilih-lalu-ketuk. Animasi mengikuti hasil simulasi yang sudah ada.
- Jalankan solver/solusi seluruh 20 level: menang, vas aman, minimum benda dan langkah sesuai data.

**Selesai jika:** puzzle sejalan dengan rumah baru dan tetap dapat dimainkan dengan aturan teruji.

## 11. Peta babak, hasil level, dan putar ulang

**Baca/ubah:** layar peta babak, hasil, replay, renderer/rute terkait; test navigasi/hasil/replay.

- Gambar ulang dua peta, node terkunci/terbuka, bos, transisi, ilustrasi menang/gagal/vas pecah, bintang dan hadiah.
- Perbarui jejak replay, nomor langkah, jeda/kecepatan, langkah awal/akhir dan semantik.
- Test lanjut antarlevel/babak, ketukan saat transisi, kembali, hasil berulang dan hadiah hanya untuk peningkatan bintang.

**Selesai jika:** semua hasil/transisi jelas dan pergantian tampilan tidak merusak progres.

## 12. Tutorial, petunjuk, koin, dan Pengaturan

**Baca/ubah:** tutorial/aturan, sheet petunjuk/koin, layar Pengaturan, `lib/l10n/`, routing dan test terkait.

- Terapkan gaya baru pada tutorial, kartu aturan, petunjuk, bonus harian, iklan koin, bahasa, suara, privasi, tentang dan reset.
- Rancang pengenalan rumah/area/ajakan bila diperlukan tanpa menghalangi puzzle. Lengkapi siap/loading/gagal/habis/nonaktif dan semua teks/semantik empat bahasa.
- Reset mencakup area baru; pembatalan reset tidak mengubah data. Audit seluruh inventaris layar langkah 1.

**Selesai jika:** tidak ada rute/sheet pemain yang tertinggal gaya lama, terjemahan dan navigasi lulus.

## 13. Animasi, suara, aksesibilitas, dan performa

- Selaraskan pose/reaksi/efek suara; hentikan animasi layar tertutup dan jeda suara selama iklan/latar belakang.
- Ukur profil 9 kucing dan seluruh barang sesuai aturan area, transisi area, puzzle dan memori; gunakan cache/preload yang terbatas dan terukur.
- Targetkan kelancaran 60 fps pada HP uji; laporkan build/raster, bingkai lambat, memori dan keterbatasan perangkat. Hasil desain lama bukan kelulusan baru.
- Periksa viewport awal nol, layar terkunci, pause/resume, teks besar, kontras, target sentuh, TalkBack dan kurangi gerak. Yang dilewati dicatat belum diuji.

**Selesai jika:** masalah bermakna ditangani/dicatat dengan alasan, tidak ada pertumbuhan cache tanpa batas, memori/ukuran sesuai anggaran.

## 14. Screenshot, ikon, splash, dan materi Play Store baru

**Baca/ubah:** `test/screenshots/`, generator merek, ikon/splash Android, `docs/store/`, README.

- Perbarui generator/scenario untuk desain baru. Jangan sekadar menjalankan generator lama lalu menganggap perombakan selesai.
- Buat ikon launcher/adaptif/monokrom, splash, ikon toko 512×512, feature graphic 1024×500 dan screenshot empat bahasa.
- Buat ulang `docs/screenshots/` dan `docs/store/screenshots/` dari game baru, periksa seluruh gambar, lalu isi galeri README.
- Tinjau listing sesuai fitur final dan buat ulang berkas review terjemahan bila teks berubah.

**Selesai jika:** gambar sesuai aplikasi nyata, tidak tercampur screenshot lama, ikon/splash benar dan listing tidak menjanjikan fitur yang belum ada.

## 15. Pengujian menyeluruh di HP dan kandidat rilis

- Jalankan format, `flutter analyze`, pemeriksaan terjemahan, seluruh `flutter test`, solver 20 level dan pengujian visual/overflow baru.
- Coba update dari progres lama, buka ulang, antararea, otomatis/ajakan, transaksi/dekorasi, puzzle/replay, pengaturan, offline dan kembali setelah iklan.
- Di HP asli: ikon/ikon tema, splash, bunyi pertama, TalkBack, UMP sesuai kondisi uji, iklan uji petunjuk/koin dan hadiah. Uji Android lama/HP spek rendah jika tersedia, catat jika tidak tersedia.
- Ukur ulang kamar penuh/transisi dan cek log Flutter/crash/ANR. Proses hidup saja tidak membuktikan layar bekerja. Fixture uji tidak menimpa data pemain.
- Tutup temuan penghalang dan tetapkan kandidat yang diterima pemilik repo secara visual maupun fungsional.

**Selesai jika:** laporan per butir tersedia beserta keterbatasan, dan kandidat rilis berfungsi.

## 16. Persiapan produksi dan release Play Store

**Baca:** `docs/store/README.md`, `docs/store/privacy/README.md`, spesifikasi/rencana Android release yang dipertahankan di `docs/superpowers/`, konfigurasi Android/AdMob.

- Verifikasi ketentuan Play Console/AdMob terbaru melalui sumber resmi saat rilis. Jawaban formulir lama ditinjau terhadap fitur final.
- Siapkan App ID/unit AdMob produksi, persetujuan, keystore upload dan `android/key.properties` di luar Git serta backup kunci. Sandi tidak masuk chat/repo.
- Tinjau/unggah kebijakan privasi, listing, target audiens, Data safety, rating konten, deklarasi iklan dan izin sesuai aplikasi final.
- Pastikan versi/kode versi, ID `com.gingerlogic.app`, signing, aturan R8, aset toko dan iklan benar. Buat `flutter build appbundle` dari entrypoint biasa, bukan helper profil.
- Unggah kandidat ke jalur pengujian yang berlaku untuk akun; lakukan pemeriksaan yang diminta Play Console, tangani laporannya, lalu siapkan produksi dan pemantauan crash.
- Publikasi/rollout dilakukan setelah pemilik repo menyetujui kandidat final. Penyusunan roadmap ini belum merupakan tindakan publish.

**Selesai jika:** bundle bertanda tangan, materi/formulir valid, pengujian memadai dan rilis yang disetujui berhasil dipublikasikan; bukan hanya APK berhasil dibangun.
