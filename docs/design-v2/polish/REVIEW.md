# Langkah 13 — animasi, suara, aksesibilitas dan performa

10 November 2026. Implementasi dan audit lokal desain v2. Tidak mengubah
aturan, ekonomi, migrasi progres, aset atau terjemahan. **Target 60 fps HP
belum dinyatakan lulus:** hanya Chrome/Edge terdeteksi pada sesi ini.

## Perubahan dan regresi

- Musik serta efek berhenti sejak lifecycle `inactive`, tetap berhenti selama
  alasan iklan/latar belakang bertumpuk, lalu musik kembali saat `resumed`.
  Awal aplikasi yang belum aktif juga ditahan.
- Efek yang sudah berjalan dihentikan dan pemuatan yang tertunda dibatalkan.
  `EffectPool` memiliki maksimal tiga voice per jenis (19 jenis = maksimal
  57 pemutar efek); satu voice dipreload per jenis. Voice selesai dipakai ulang
  berdasarkan state pemutar. Antrean per jenis dan revisi pembatalan menangani
  stop saat pool/voice dimuat, dihentikan atau sedang menjalankan perintah native.
- Puzzle menghentikan jam simulasi saat kehilangan fokus atau TickerMode
  tertutup, melanjutkan tanpa waktu tersembunyi, dan mempertahankan jeda pemain.
  Loop Flame juga menonaktifkan gerak selama keadaan itu. Replay berhenti saat
  tertutup dan menunggu tombol Putar lagi, sama seperti jeda lifecycle.
- Fase rig rumah dilanjutkan dari waktu aktif terakhir, bukan dimulai ulang
  sesudah pause. Ukuran viewport nol/tak berbatas tidak membentuk geometri
  negatif. Makan memicu munch, main meow, elus/sikat purr sekali saat ID kegiatan
  yang terlihat dipublikasikan setelah simpan. Membuka area atau mount ulang
  tidak memainkan kembali kegiatan lama. Kurangi gerak tetap mengizinkan suara.
- Cache parsing path SVG dibatasi LRU 512, termasuk jika pemanggil memberi
  path dinamis. Eviksi tidak mengubah drawing yang sudah terikat. Cache tidak
  menggunakan waktu atau bingkai sebagai kunci.

Uji merah sebelum perbaikan membuktikan musik masih aktif saat `inactive`
dan puzzle maju dari langkah 1 ke 2 selama jeda. Regresi kini menguji resume,
jeda pemain, rute tertutup, replay, fase rumah, viewport nol, ID bunyi dan cache.
Review independen menemukan callback stop AudioPool lama bisa memotong bunyi
baru setelah player dipakai ulang; implementasi diganti dengan voice pool
sendiri. Review berikutnya menemukan pembatalan saat ekspansi voice dimuat;
revisi pool dan uji gated load menutupnya. Review ulang: tidak ada blocker kode.

## Aksesibilitas dan render

Fixture memiliki sembilan kucing beraksesoris dan 21 barang dimiliki; 19
ditaruh pada anchor legal berbeda, dua mainan di Gudang karena kapasitas.
Jumlah kucing per area tetap 3/2/2/2. Ini data uji dalam memori, bukan simpanan
pemain. Tidak memaksa 21 barang atau sembilan kucing tampil di satu area.

Delapan render runtime ditinjau langsung: empat area, Indonesia 390×844/100%
dan Rusia 360×640/130%. Lulus pemeriksaan exception/overflow, label target
interaksi, dan `androidTapTargetGuideline` (48 dp). Tab Rusia menggulir agar
tab terpilih terlihat; konten rumah dapat digulir di atas navigasi tetap.
Tidak ada kucing keluar scene atau tombol tertutup navigasi. Pemeriksaan
kontras numerik token teks aktif/status terhadap paper/cream/homePaper dan
ink/orange lulus rasio 4,5:1; ini bukan audit kontras setiap piksel aplikasi.
Matriks empat bahasa dan layar lain tetap dicakup suite visual langkah 3–12.

| Area | Indonesia | Rusia, teks 130% |
| --- | --- | --- |
| Santai | [render](santai-id.png) | [render](santai-ru.png) |
| Makan | [render](makan-id.png) | [render](makan-ru.png) |
| Bermain | [render](main-id.png) | [render](main-ru.png) |
| Perawatan | [render](rawat-id.png) | [render](rawat-ru.png) |

## Pengukuran host dan batas cache

[Data mentah host](host-profile.json) berasal dari Flutter test debug Windows,
bukan Android. Tiap skenario merekam PictureRecorder: 30 pemanasan + 300 sampel;
gambar dilepas setiap sampel. Tidak mengukur raster GPU, layout widget penuh,
presentasi layar, audio native atau FPS HP. Sembilan rig dalam mikrobenchmark
adalah beban diagnostik, bukan kapasitas satu area runtime.

| Perekaman CPU | Rata-rata ms | P90 ms | P99 ms |
| --- | ---: | ---: | ---: |
| 9 kucing idle | 0,345 | 0,457 | 0,992 |
| 9 kucing berjalan | 0,286 | 0,362 | 0,576 |
| 9 kucing makan | 0,466 | 0,673 | 1,147 |
| 9 kucing bermain | 0,368 | 0,530 | 0,766 |
| 9 kucing sikat | 0,410 | 0,574 | 0,800 |
| Puzzle 13, seluruh frame solusi | 0,636 | 0,936 | 1,669 |

RSS proses test host 351.600.640 → 358.834.176 byte selama diagnostik. Angka
ini mencakup VM/harness, alokasi dan GC; bukan ukuran heap retained game atau
bukti tidak bocor. Pack tetap 209 bagian / 300.571 byte sumber. Cache path
tercatat 263 entri pada diagnostik; uji 1.200 path unik tetap maksimal 512.
Pack penuh dimiliki layar, subset puzzle/navigasi terbatas; paragraf nomor
papan dibatasi 256. Tidak ada cache kombinasi per waktu. Empat latar memakai
decode tetap 1024×1024, total anggaran decode 16 MiB, berada dalam ImageCache
Flutter yang terbatas. Ukuran entry APK dicatat di [apk-size.json](apk-size.json),
bukan delta ukuran APK terhadap v1 atau prakiraan ukuran rilis.

Anggaran sumber terkompresi v2 di APK debug 635.869 byte, di bawah batas
awal 20 MB. Decode empat latar 16 MiB berada di bawah anggaran rumah 64 MiB.
Ini perhitungan aset/tekstur; penggunaan total memori proses Android belum
diukur dan tidak disamakan dengan anggaran decode.

## Mengulang di perangkat

```sh
flutter run --profile -t tool/profile_room.dart -d <Android-device>
```

Helper memakai runtime v2, SnapshotStore dalam memori dan audio asli, tanpa
PrefsProgressStore/SDK iklan. Otomatis mengukur empat area, 20 perpindahan
area, puzzle 13 fase atur, dan rumah dengan Kurangi gerak. Setiap skenario
pemanasan 5 detik lalu sekitar 20 detik ukur; maksimal 12.000 timing per
skenario. Log `V2_PROFILE_RESULT` memuat build/raster mean/P50/P90/P95/P99/max,
jumlah bingkai >16,67 ms, RSS, cache gambar, cache SVG dan jumlah penghuni.
Lifecycle tidak aktif membatalkan validitas sampel; `no_frames`/sampel kosong
tidak menjadi bukti FPS. Rumah diam dengan Kurangi gerak dapat menghasilkan
sedikit/tanpa frame secara wajar. Durasi aktual ikut dilaporkan; build dan
raster dibandingkan terpisah, tidak dijumlahkan sebagai waktu frame.

Pastikan HP terbuka dan amati layar selama pengukuran. Setelah tes jalankan
entrypoint biasa `lib/main.dart`; jangan merilis helper profil. Helper hanya
mengukur fase atur puzzle pada HP; fase jalan dicakup diagnostik renderer
host dan regresi perilaku, belum profil build/raster perangkat.

Ekspor lokal:

```sh
flutter test test/screens/polish_v2_visual_test.dart --dart-define=POLISH_PROFILE=true --dart-define=POLISH_REVIEW=true
python tool/art_v2/measure_apk.py build/app/outputs/flutter-apk/app-debug.apk
```

## Batas yang diteruskan ke pengujian HP

Belum diuji: FPS/build/raster/RSS Android v2, pertumbuhan memori pada sesi
panjang di HP, layar terkunci lalu buka, TalkBack nyata/fokus urut, latensi
audio pertama dan penghentian native saat iklan SDK, HP spek rendah, serta
kontras seluruh layar. Tidak ada hasil desain lama yang dipakai sebagai
kelulusan desain v2. Profil helper siap diulang saat perangkat tersedia;
butir perangkat ini tetap terbuka pada langkah 15 dan tidak digantikan APK
yang berhasil dibangun. Tidak ada klaim 60 fps/perangkat lulus.

## Verifikasi

- `flutter pub get`: berhasil. Baseline analyze bersih; dua regresi jeda
  yang ditambahkan selama audit terbukti gagal sebelum perbaikan.
- `dart format --output=none --set-exit-if-changed lib test tool/profile_room.dart tool/profile_fixture.dart`:
  299 file, 0 berubah.
- `flutter analyze`: **No issues found!**
- `flutter test`: **3.105 test lulus / 136 skip** (135 historis, satu
  diagnostik host opt-in), tanpa kegagalan; termasuk solver/solusi 20 level.
- Ekspor `POLISH_REVIEW=true` dan diagnostik `POLISH_PROFILE=true`: tiga
  test lulus, delapan render ditinjau dan data host ditulis.
- Regresi akhir pool/polish: 17 test terarah lulus sesudah dua temuan review
  ditangani. Uji audio lengkap sebelumnya: 32 test lulus.
- `python tool/translations/make_review.py --check`: sesuai ARB/listing.
- Generator 209 bagian dan subset puzzle `--check`: sesuai sumber.
- `flutter build apk --debug`: berhasil dari entrypoint biasa.
- `flutter build apk --profile -t tool/profile_room.dart`: berhasil; hanya
  bukti helper dapat dibangun, belum dijalankan pada HP. Build profile
  mengeluarkan pesan font CupertinoIcons tidak tersedia saat tree-shaking;
  tidak menggagalkan build, ikon perangkat tetap bagian uji langkah 15.
- Link lokal laporan serta `git diff --check`: bersih.
