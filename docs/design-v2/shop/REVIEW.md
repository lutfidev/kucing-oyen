# Tinjauan Toko, koleksi, dan Hias v2 — langkah 9

10 November 2026, basis `104995e` sesudah PR #47 merged.
Rencana: `docs/superpowers/plans/2026-11-10-v2-shop.md`.

## Hasil implementasi

- Toko memakai UI v2 dan satu ArtPack terbatas per layar. Barang, sembilan
  karakter dan seluruh aksesoris memakai seni v2 yang juga dipakai rumah.
  Lima ilustrasi camilan baru digambar sebagai Canvas orisinal di
  `lib/widgets/v2/snack_art.dart`; tidak menambah aset unduhan/dependency.
- Empat tab dapat digulir horizontal, teks panjang tetap utuh. Kisi barang
  dan aksesoris menjadi satu kolom pada teks 130%. Daftar vertikal tetap
  dapat digulir ke item terakhir; tombol memiliki target minimal 48 dp.
- Kartu barang dan sheet beli menunjukkan area tujuan, atau Gudang saat
  area awal penuh. Saldo sesudah hanya ditampilkan bila koin mencukupi.
  Kepemilikan, stok penuh, koin kurang, proses/gagal/retry dan sukses
  mengikuti controller atomik; penutupan sheet tidak mengulang pembelian.
- Tujuan pembelian/adopsi dihitung lewat algoritma `HomeAreas.sync` dan
  `HomeRoutine.sync` yang sama dengan transaksi, termasuk reservasi saat
  kucing berjalan. Harga, ID, kapasitas, ekonomi dan skema simpanan tetap.
- Tab Kucing memisahkan koleksi dimiliki dari calon adopsi. Oyen termasuk
  koleksi; status area/kegiatan, Baru dan Temukan tersedia. Temukan memilih
  kucing dan membuka area model. Sheet koleksi rumah tetap menampilkan
  kebutuhan dan perjalanan; kartu aksesoris rumah mendapat pratinjau v2.
- Camilan menampilkan stok, harga dan efek Lapar/Senang. Aksesoris punya
  rarity, pratinjau tiap kucing, Pakai/Lepas, dan daftar pemakai. Satu
  aksesoris tetap dapat dipakai beberapa kucing tanpa pembayaran ulang.

## Hias dan Gudang

Tombol Hias ada pada judul area rumah. Editor mempunyai draf lokal,
pratinjau ruangan, pemilih area, slot dinding/lantai berlabel, daftar koleksi,
filter Gudang, dan tombol Simpan/Batal yang tetap terlihat.

Slot mengikuti kontrak 4 lantai/3 dinding dari langkah 4. Memilih barang
lalu mengetuk slot maupun menyeret ke kartu slot memakai validasi yang
sama. Sumber seret pilihan diulang dekat setiap zona agar sumber dan
tujuan dapat terlihat bersamaan di 360×640. Seret di luar, zona salah,
slot terisi dan area tidak diizinkan mempertahankan posisi terakhir sah
dengan pesan. Tidak ada penempatan bebas di jalur pintu/kegiatan.

Gudang menggunakan `household.areas`, bukan koordinat `Room` v1. Simpan
ke Gudang menjaga kepemilikan dan barang dapat ditaruh kembali gratis.
Mangkuk bawaan tidak dapat dipindah/disimpan. Pratinjau menyajikan draf
tanpa menerapkan perubahan ke rumah yang sudah tersimpan.

Back/Batal dengan perubahan menawarkan Simpan/Buang/Lanjut. Gagal simpan
tetap menahan draf dan keadaan model lama; Retry menerapkan snapshot
sekali. Buang sesudah gagal hanya membatalkan transaksi layout draf itu,
sehingga retry global tidak menghidupkannya kembali. Simpan tanpa perubahan
tidak memberi bonus. Bonus hias +5/60 menit tetap dari model lama.

Rutinitas dijeda selama editor dan seluruh transisi penutupannya; buka
ganda ditolak. Pemindahan fasilitas terikat, termasuk ke slot lain pada
area yang sama, memutus kegiatan dengan aman tanpa hadiah kegiatan parsial.

## Bukti visual

Render berasal dari widget aplikasi nyata dengan font aplikasi dimuat:

- `toko-{en,id,pt,ru}-360-{100,130}.png`: layar kecil empat bahasa.
- `hias-{en,id,pt,ru}-360-{100,130}.png`: editor dan tindakan tetap terlihat.
- `toko-{items,kitties,accessories,snacks}-id.png`: keempat tab.
- `hias-draf-id.png`, `gudang-id.png`, `hias-gagal-id.png`,
  `beli-sukses-id.png`: draf, Gudang, gagal simpan dan hasil transaksi.

Seluruh 24 gambar diperiksa melalui contact sheet dan gambar penuh.
Tidak ada teks terpotong atau overflow pada render yang diuji. Tab Toko
memang bergulir horizontal; bagian tab berikutnya dapat terlihat di tepi.
Editor bergulir untuk mencapai slot/koleksi, sedangkan footer selalu ada.
Tidak memakai ulang screenshot v1 atau membuat latar baru dari gambar AI.

Ekspor: `flutter test test/screens/shop_v2_test.dart --dart-define=SHOP_REVIEW=true`.

## Review dan verifikasi

Satu reviewer independen meninjau diff dan menemukan tiga masalah penting:
fasilitas pindah dalam area sama, buka editor ganda, dan pause berhenti
sebelum animasi penutupan selesai. Ketiganya diperbaiki, diberi regresi,
dan review ulang menyatakan tidak ada temuan Critical/Important tersisa
dalam lingkup tinjauan. Reviewer membaca kode/test; verifikasi dieksekusi
oleh sesi utama.

- Baseline sebelum perubahan: 2.968 test lulus / 135 skip, analyze bersih.
- Verifikasi akhir: **2.992 test lulus / 135 skip**, termasuk simulator,
  solver dan solusi seluruh 20 level; tidak ada kegagalan.
- **133 test terarah lulus** untuk transaksi/Toko/Hias serta regresi
  navigasi, Makan, Bermain dan Perawatan. Ekspor final 17 test lulus.
- `flutter analyze`: `No issues found!`; format 282 file tanpa perubahan;
  `make_review.py --check` sesuai ARB/listing. `git diff --check` bersih.
- APK debug berhasil dari entrypoint biasa:
  `build/app/outputs/flutter-apk/app-debug.apk`, 219.975.258 byte.
  SHA-256 `50502514a42a874971b52007abdd29bc1a73e6f6922833e68b3db0d1e08fc37f`.
- Pemeriksaan arsip APK: 215 entry seni v2 lengkap, 635.476 byte
  terkompresi. Ini kontribusi aset yang terkemas, bukan selisih ukuran APK
  terhadap v1 atau perkiraan ukuran rilis.

## Batas pemeriksaan

Belum diuji interaktif pada HP asli atau dengan TalkBack sungguhan dalam
langkah ini. Target sentuh/label/selected diuji melalui semantik Flutter;
ini tidak menggantikan uji pembaca layar di perangkat. Profil frame/memori
dan penerimaan visual pemilik repo mengikuti langkah 13/15 dan review PR.
Terjemahan empat bahasa lolos kontrak ARB/placeholder/generator; belum
mendapat tinjauan penutur asli baru. Galeri/komponen v1 tetap tersedia
untuk regresi historis; layar puzzle/peta/sheet lain mengikuti langkah 10–12.
