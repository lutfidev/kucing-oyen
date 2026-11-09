# Area Makan — langkah 6

Implementasi 9 November 2026, basis main setelah PR #44 di-merge.

## Perilaku

Area Makan menggunakan ilustrasi selaras Santai, satu mangkuk interaktif dan
dua tempat terpisah: makan dan tunggu. Mangkuk berada di depan kucing; prop
mangkuk rig tidak ikut digambar. Perjalanan dari area lain melalui pintu;
perjalanan dalam Makan mendekati fasilitas dari titik tunggu. Pergantian pemakai
memakai transisi 350 ms. Kurangi gerak memakai pose dan posisi statis tanpa
mematikan model kegiatan.

Panel menampilkan jatah seluruh koleksi, pemakai mangkuk, antrean berurutan
dan Batalkan. Ketuk mangkuk/Pilih kucing membuka sheet semua kucing milik pemain,
dengan kebutuhan, status, alasan tidak bisa makan dan Ajak makan. Sheet tetap
mengamati model saat rumah berjalan; tidak memindahkan tab secara paksa.
Kartu lengkap juga menjelaskan jatah/kenyang dan menonaktifkan ajakan yang
belum layak. Camilan tetap panel/inventaris terpisah.

`DiningState` adalah proyeksi read-only kebutuhan dan scheduler; bukan stok
baru. Pembacaan memakai waktu efektif controller. Makan 4 detik memberi
+40 Makanan maksimal 100, hanya bila Makanan <70 dan jatah tersedia. Satu siklus
4 jam dimulai pada penyelesaian makan pertama; tiap kucing sekali, pulih otomatis
dan gratis. Jatah kucing yang habis tidak membuat mangkuk seluruh koleksi kosong.
Timer H:MM dibulatkan ke atas dan diperbarui melalui clock rumah.

Scheduler dan UI memakai `queueFor` yang sama: pemain dahulu/FIFO, satu otomatis
setelah dua pemain jika tersedia. Efek dan jatah tetap transaksi snapshot yang
sama; gagal simpan mempertahankan kegiatan sebelum selesai hingga retry sukses.
Hadiah diklaim eksplisit melalui chip gabungan, bukan setiap animasi makan.

## Bahan tinjauan runtime

- [Makan dan antrean](makan-antrean-id.png), 390×844.
- [Jatah seluruh koleksi habis](makan-jatah-habis-id.png), 390×844.
- [Tengah perpindahan giliran](makan-pergantian-giliran-id.png), 360×640;
  lintasan depan/belakang dan target sentuh dipisahkan sepanjang transisi.
- Layar kecil 360×640 teks 130%: [Indonesia](makan-id-360-130.png),
  [Inggris](makan-en-360-130.png), [Portugis](makan-pt-360-130.png),
  [Rusia](makan-ru-360-130.png). Versi 100% disertakan pula.
- [Asal dan prompt gambar](PAINTED_ASSET.md).

Screenshot berasal dari widget pemain dan model dengan fixture waktu tetap.
Pada layar kecil panel/antrean/kartu dapat digulir; Main Puzzle dan navigasi
tetap terlihat. Ini pemeriksaan implementasi, belum persetujuan visual pemilik
repo untuk langkah 6.

Render ulang: `flutter test test/screens/dining_v2_test.dart --dart-define=DINING_REVIEW=true`.

## Verifikasi dan batas

Baseline main: analyze bersih, 2.907 test lulus, 135 skip historis.
Tambahan lima test controller/proyeksi dan 14 test widget mencakup makan otomatis, antrean,
ajakan identik, batal, kenyang/jatah habis, isi ulang, hadiah sekali, pause,
gagal simpan/retry, reload, jam mundur, satu mangkuk dan hitbox kucing terpisah.

Review independen menemukan status mangkuk habis yang masih menyebut siap,
pergantian giliran tanpa transisi posisi, lalu lintasan pertukaran yang saling
menutupi. Semuanya diperbaiki dengan regresi; review ulang tidak menemukan bug
konkret tambahan. Target sentuh diperiksa pada sepuluh fase transisi 350 ms,
minimal 48 dp dan tidak bertumpuk pada ruangan kecil. Test lama penghitung
kucing tetap berlaku; key transisi memakai namespace terpisah dari hitbox.
Verifikasi final: `flutter analyze` tanpa issue; format 268 berkas bersih;
`flutter test --concurrency=4 --timeout=2m` **2.926 lulus, 135 skip historis**.
Regresi terarah rumah/Makan 56 test lulus; render opt-in 14 test lulus.
Tidak ada test perilaku lama yang dihapus/dilewati untuk meluluskan perubahan.
Build APK debug berhasil; pengukuran paket seni: 213 entry, 592.759 byte sumber
dan 380.288 byte terkompresi. Latar Makan 110.624 byte; dua bitmap latar dibatasi
8 MiB RGBA jika keduanya di-cache. Ini kontribusi aset, bukan ukuran rilis
atau hasil profil memori seluruh aplikasi. Generator 209 SVG dan review
terjemahan cocok dengan sumber. `flutter devices` hanya menemukan Chrome/Edge.
Belum mengklaim pengujian Android fisik/TalkBack atau profil frame/memori HP.
Penyelesaian Bermain/Perawatan/Hias tetap langkah 7–9.
