# Beranda v2 — langkah 5

Implementasi 9 November 2026, setelah PR model #43 masuk `main`.
**Status: visual akhir DISETUJUI pemilik repo pada 9 November 2026; langkah 5 selesai.**
Persetujuan eksplisit setelah tinjauan latar ilustrasi pada runtime: “boleh lah”.
Syarat penerimaan screenshot pada ROADMAP terpenuhi. PR #44 difinalisasi untuk
review/merge oleh pemilik repo; langkah 6 dimulai setelah merge.

## Perapian visual setelah tinjauan pemilik repo

Pemilik repo meminta visual dirapikan sebelum melanjutkan langkah 6.
Rumah Santai kini memakai latar ilustrasi dengan jendela berlapis, tirai
berlipat, tanaman menjuntai, pintu melengkung dan lantai berperspektif. Vektor
dan Canvas dipertahankan untuk barang dinamis serta fallback. Bentuk pipi/badan
sembilan kucing dibulatkan, dengan blush halus; kucing pilihan yang sedang
santai memakai ekspresi senang, sedangkan tidur/kebutuhan rendah tetap mengikuti
model. Oyen tampil lebih besar saat sendiri; komposisi tiga kucing memiliki
kedalaman dan target sentuh terpisah, tanpa label nama mengambang.

Empat tab terlihat bersama pada skala teks normal. Teks besar dapat menggulir
tab dan pilihan aktif otomatis ditampilkan. Kartu pilihan ringkas, navigasi
berikon, serta garis/bayangan yang lembut menggantikan permukaan bergaris gelap.
Hit area tetap minimal 48 dp. Posisi gambar barang memakai pemetaan slot yang
lebih aman agar barang dinding tidak menutup jendela; ID slot dan simpanan
tidak berubah. Fungsi ajakan, hadiah, navigasi dan suara ketukan dipertahankan.

Perbandingan runtime 390×844: [sebelum](santai-sebelum-polish-id.png) dan
[sesudah](santai-baru-id.png). Seluruh screenshot lainnya di bawah sudah
diperbarui. Ini tetap bahan tinjauan, bukan persetujuan visual otomatis.

Sumber ilustrasi tambahan: `tool/art_v2/lounge.py`, dipanggil generator utama.
Inventaris tetap 209 aset vektor, 300.571 byte sumber, 108.833 byte ZIP menurut
generator. Tambahan latar raster dan ketentuan keluarannya dijelaskan berikut.

### Latar ilustrasi sesuai mockup

Setelah tinjauan langsung terhadap `mockups/01-empat-area.png`, pemilik repo
meminta kekayaan warna/ilustrasi yang lebih terlihat. Santai sekarang memakai
satu latar bertekstur dari imagegen bawaan. UI, kucing, barang katalog dan
pergerakan tetap interaktif, bukan bagian dari gambar latar. Gambar tidak
memuat kucing, makanan, mainan atau teks UI. Karpet dan tanaman struktural
gratis menjadi bagian latar seperti aturan sebelumnya.

[Preview terbaru](santai-baru-id.png), [sebelum latar ilustrasi](santai-sebelum-ilustrasi-id.png),
serta [sumber, prompt final dan lisensi](PAINTED_ASSET.md) tersedia untuk tinjauan.
WebP runtime 180.076 byte, decode 1024×1024 (4 MiB). PNG sumber hanya berada
di dokumentasi. Cache digunakan kembali antararea; gagal memuat memakai latar
vektor dan mempertahankan semua target sentuh. Tambahan ini tidak mengubah
model, saldo, inventaris atau identitas karakter.

APK debug memuat seluruh 209 SVG dan latar WebP. Seluruh entry seni memakai
481.792 byte sumber / 269.557 byte terkompresi menurut pengukuran APK, bukan
ukuran seluruh aplikasi atau prediksi rilis.

### Percobaan cahaya dan variasi warna pada fallback vektor

Acuan tetap konsep A, yang ditunjukkan kembali pemilik repo pada screenshot
referensi. Langit biru dan tanaman hijau dipulihkan agar kayu jingga serta
krem mempunyai pembanding warna. Tirai memakai lipatan gelap dan highlight
ivory; kabinet dan bingkai mempunyai sisi terang serta sisi bayangan.

Lapisan kuning seluruh ruangan dihapus. `lounge_lighting.dart` menggambar
cahaya jendela terarah, bayangan kisi, bayangan kontak dan grain dinding/kayu.
Pencahayaan digambar sebelum dekor dan aktor; kaca biru, daun, dan bulu tidak
terkena tint global. Tekstur berada di lapisan latar statis yang sudah memakai
RepaintBoundary. Warna bulu tetap agar sembilan identitas mudah dikenali.

Latar UI kini `#FCE8C6`, kartu ivory `#FFF7E8` → `#FFE8C7`, dan panel peach
`#F6D6AB`. Perbandingan: [versi kuning sebelumnya](santai-sebelum-cahaya-id.png)
dan [ilustrasi terbaru](santai-baru-id.png). Percobaan palet lebih awal tetap
tersedia pada [pembanding awal](santai-sebelum-warna-hangat-id.png).

Kontras teks cokelat `#573018` terhadap permukaan krem/peach baru 8,21–10,71:1;
ujung oranye tombol utama tetap 4,59:1. Pemeriksaan dilakukan dari luminans
warna, bukan klaim audit aksesibilitas perangkat. Perubahan palet diverifikasi
dengan 64 test rumah/komponen UI, pengecekan aset dan build debug; hasil suite
lengkap di bawah merupakan baseline perapian sebelumnya.

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

Screenshot berikut berasal dari widget runtime: latar ilustrasi raster,
kucing/barang vektor dan kontrol hidup. Ini bukan mockup yang dipasang utuh.
Fixture dikunci jamnya; animasi dihentikan untuk render stabil.

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

Hasil akhir: `flutter analyze` tanpa issue; format 264 berkas bersih;
`flutter test --concurrency=2 --timeout=2m` **2.907 lulus, 135 skip historis**.
Ada 37 test rumah baru, termasuk render ulang screenshot, empat tab terlihat,
target sentuh kucing tidak tumpang tindih, tab aktif terlihat pada teks besar,
decode/cache gambar bounded dan fallback yang mempertahankan target sentuh.
Pemeriksaan aset/galeri setelah perapian juga lulus 9 test (1 ekspor opt-in
dilewati). Cek perpindahan sheet memastikan fokus tetap di modal aktif.
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
pada langkah performa. Tambahan latar AI, sumber PNG, prompt dan ketentuan
keluarannya ada di PAINTED_ASSET.md. Tidak ada dependensi runtime baru.
