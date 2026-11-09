# Beranda v2 — langkah 5

Implementasi 9 November 2026, setelah PR model #43 masuk `main`.
**Status: siap untuk tinjauan visual pemilik repo; langkah 5 belum dicentang.**
Penerimaan screenshot merupakan syarat selesai pada ROADMAP.

## Tampilan dan alur

Rute `/` kini memakai `HomeView`: header saldo/bonus harian dan bintang menuju
peta, tab empat area dengan jumlah hadir/kapasitas, ruangan berlapis dari paket
vektor langkah 2, kucing milik pemain dari lokasi model, kartu pilihan, hadiah
gabungan, Main Puzzle serta navigasi Toko/Kucing/Pengaturan. Karpet Santai
adalah latar struktural gratis. Barang katalog hanya digambar dari penempatan
v2, bukan komposisi contoh galeri atau koordinat v1.

Tab terakhir disimpan secara atomik. Pilihan kucing dipertahankan selama sesi
controller, termasuk ketika kucing meninggalkan area dan pemain membuka
puzzle/Toko/Pengaturan. Temukan mengikuti tujuan perjalanan tanpa teleport.
Sheet koleksi, detail, ajakan/batal, hadiah, camilan dan aksesoris mengamati
controller secara langsung. Ringkasan migrasi dapat ditutup setelah tersimpan.
Gagal transaksi mempertahankan keadaan sebelumnya dan menyediakan retry.

`HouseholdDriver` menjadi satu-satunya penggerak rutinitas rumah pemain:
dt bingkai monotonik, commit berkala 250 ms, tidak menumpuk waktu ketika
tersembunyi, background, iklan, simpan sibuk atau gagal. Perubahan alasan
pause memiliki pendengar terpisah agar menutup iklan yang gagal pun dapat
melanjutkan clock. Preferensi dan pengaturan sistem Kurangi gerak mematikan
gerak gambar, bukan kegiatan atau hadiahnya. Sheet biasa tidak menjeda rumah.

## Bahan tinjauan

Screenshot berikut berasal dari widget runtime baru dengan aset asli, bukan
gambar AI. Fixture dikunci jamnya; animasi dihentikan untuk render stabil.

- [Santai baru, Oyen](santai-baru-id.png), 390×844.
- [Santai penuh dan barang lama](santai-penuh-id.png), 390×844.
- [Area kosong](area-kosong-id.png), 390×844.
- [Perjalanan ke Makan](perjalanan-makan-id.png), 390×844.
- Layar 360×640, teks 130%: [Indonesia](santai-id-360-130.png),
  [Inggris](santai-en-360-130.png), [Portugis](santai-pt-360-130.png),
  [Rusia](santai-ru-360-130.png).

Pada ukuran kecil/teks besar, bagian atas dapat digulir; Main Puzzle dan
navigasi tetap terjangkau. Tab dapat digulir horizontal dan tab aktif otomatis
ditampilkan. Pemeriksaan gambar memperbesar kucing dan menurunkan tinggi
ruangan agar chip hadiah tidak tertutup panel bawah di ukuran acuan.

Render ulang:
`flutter test test/screens/home_v2_test.dart --dart-define=HOME_REVIEW=true`.

## Verifikasi

Hasil akhir: `flutter analyze` tanpa issue; format 261 berkas bersih;
`flutter test --concurrency=2 --timeout=2m` **2.905 lulus, 135 skip historis**.
Ada 35 test rumah baru. Pemeriksaan terakhir rumah dan komponen UI berjumlah
64 test lulus, termasuk render ulang screenshot dan penyesuaian label panjang;
cek terpisah perpindahan sheet juga memastikan fokus tetap di modal aktif.
Generator 209 aset dan review terjemahan sesuai. `flutter build apk --debug`
berhasil. HP tidak terhubung (`flutter devices`: Chrome/Edge saja).

Test baru mencakup lokasi/kepemilikan/kapasitas, navigasi puzzle, persistensi
tab/pilihan, koleksi sampai kucing terakhir, ajakan/perjalanan/batal, klaim
gabungan gagal/retry/reload, migrasi sekali, aset gagal/retry, inventaris,
lifecycle, pause bertumpuk/iklan, gagal simpan serta kedua sumber Kurangi gerak.
Matriks rumah dan koleksi mencakup empat bahasa, tiga ukuran ponsel dan skala
teks 100%/130%, termasuk saldo 99999.

Regresi renderer/kartu/dekorasi v1 tetap dijalankan sebagai fixture komponen
terisolasi melalui `homeBuilder`; tidak menjadi bukti runtime rumah v2.
Pengujian navigasi dan sheet Koin memakai rumah baru. Tidak ada test perilaku
lama yang dihapus atau dijadikan skip. Peninjauan diff dilakukan dalam sesi
implementasi; belum ada review kode independen untuk branch ini.

## Batas berikutnya

Makan/Main/Rawat sudah dapat dibuka dan menampilkan lokasi serta kegiatan dari
model yang sama. Penyelesaian fasilitas, penempatan/animasi antrean khusus dan
status kuota per area tetap langkah 6–8. Tombol Hias dan editor Gudang/draf
ditambahkan pada langkah 9; layar baru tidak membuka editor koordinat v1.
Peta, puzzle, Toko dan Pengaturan masih memakai visual tahap sebelumnya.

Belum mengklaim pengujian Android fisik, TalkBack, durability perangkat atau
target frame rate. Frekuensi snapshot dan rendering perlu diprofilkan di HP
pada langkah performa. Sumber/lisensi aset tetap paket v2 langkah 2; tidak
ada bitmap AI atau dependensi baru yang ditambahkan.
