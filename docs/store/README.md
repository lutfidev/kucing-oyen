# Rilis Play Store: Ginger Logic

Semua yang dibutuhkan untuk mengunggah Ginger Logic (`com.gingerlogic.app`, versi `1.0.0+1`) ke Play Console.

## ⚠️ Wajib sebelum rilis produksi

Build release tetap bisa dibuat tanpa langkah ini (untuk uji internal), tapi **jangan unggah ke jalur produksi sebelum semuanya beres**:

1. **ID aplikasi AdMob asli** di `android/app/build.gradle.kts`, baris `val admobAppId = ...` (bertanda `TEMPEL ID ASLI DI SINI`). Sekarang masih ID aplikasi uji Google `ca-app-pub-3940256099942544~3347511713`.
2. **ID unit iklan berhadiah asli** di `lib/app/ad_ids.dart`: `hintRewardedUnit` (petunjuk) dan `coinRewardedUnit` (koin tambahan). Kalau hanya satu unit dibuat di AdMob, tempel ID yang sama di keduanya. Sekarang masih ID unit uji `ca-app-pub-3940256099942544/5224354917`, jadi build release menampilkan iklan uji dan tidak menghasilkan uang.
3. **Keystore upload** dan `android/key.properties` (lihat "Signing" di bawah). Tanpa itu (dan tanpa wizard "Generate Signed Bundle" Android Studio), `flutter build appbundle` gagal dengan pesan "Ginger Logic: android/key.properties tidak ada ..."; APK release (`flutter build apk --release`, `flutter run --release`) tetap bisa dibuat dengan debug key untuk dicoba di HP.
4. **Kebijakan privasi** diunggah ke https://yoluvy.my.id/ginger-logic/privacy/ (lihat `privacy/README.md`).
5. Di AdMob, tautkan aplikasi ke listing Play Store setelah terbit, dan atur pesan persetujuan GDPR (Privasi & pesan → Eropa) supaya formulir UMP muncul di EEA, Inggris, dan Swiss.

Gradle mencetak peringatan "Ginger Logic: ..." saat build release kalau ID aplikasi AdMob masih ID uji, atau kalau APK release dibuat tanpa `key.properties` (Flutter hanya menampilkan peringatan dengan `-v`, mis. `flutter build apk --release -v`); aplikasi juga mencetak peringatan di log kalau ID unit masih ID uji.

## Isi folder

| Berkas | Kolom Play Console |
|---|---|
| `listing-en.md` | Listing toko utama (Inggris, AS): nama aplikasi, deskripsi singkat, deskripsi lengkap |
| `listing-id.md`, `listing-pt.md`, `listing-ru.md` | Listing toko → Kelola terjemahan → Indonesia, Portugis (Brasil), Rusia |
| `icon-512.png` | Ikon aplikasi (512×512) |
| `feature-graphic.png` | Grafis fitur (1024×500) |
| `screenshots/<bahasa>/*.png` | Screenshot ponsel per bahasa (1080×1920, 6 gambar) |
| `privacy/index.html` | Kebijakan privasi (diunggah ke situs, lalu URL-nya ditempel) |

Gambar dibuat ulang dengan:

```
flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true
```

Perintah itu juga menulis ikon launcher, splash, dan `values/colors.xml` di `android/app/src/main/res/`.

## Signing

Kunci yang dibuat di sini adalah **upload key**; Play App Signing menyimpan kunci penandatanganan aplikasi yang sebenarnya.

1. Buat keystore **di luar repo** (ganti `<folder>` dengan folder aman, mis. `C:\Users\<nama>\keys`):

   ```
   keytool -genkey -v -keystore <folder>/ginger-logic-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Buat `android/key.properties` (sudah diabaikan git):

   ```
   storeFile=C:/Users/<nama>/keys/ginger-logic-upload.jks
   storePassword=<sandi keystore>
   keyAlias=upload
   keyPassword=<sandi kunci>
   ```

3. **Backup** berkas `.jks` dan kedua sandinya di tempat aman (mis. pengelola sandi + salinan offline). Kalau hilang, upload key harus direset lewat dukungan Play Console.

## Build

```
flutter build appbundle
```

Hasilnya `build/app/outputs/bundle/release/app-release.aab`. Unggah ke Play Console → Uji dan rilis → (Pengujian internal dulu, lalu Produksi). Saat pertama mengunggah, pilih Play App Signing (default).

## Konten aplikasi (Play Console → Kebijakan dan program → Konten aplikasi)

Jawaban di bawah dicek terhadap panduan Google pada 20 Okt 2026. Pengembang tetap bertanggung jawab atas jawabannya; cek ulang kalau SDK atau fitur berubah.

### Kebijakan privasi

`https://yoluvy.my.id/ginger-logic/privacy/`

### Iklan

**Ya**, aplikasi berisi iklan (iklan video berhadiah AdMob, selalu pilihan pemain).

### Akses aplikasi

Semua fungsi tersedia tanpa akses khusus (tanpa login).

### Target audiens dan konten

- Kelompok usia target: **13–15, 16–17, 18+** (keputusan "Sebelum langkah 15" di `docs/DESIGN_NOTES.md`; iklan tidak ditandai untuk anak).
- "Apakah aplikasi bisa menarik minat anak secara tidak sengaja?": jawab jujur. Gambar imut bisa membuat Google meminta kepatuhan program Keluarga; kalau itu terjadi, ubah permintaan iklan ke mode anak (`ageRestrictedTreatment: AgeRestrictedTreatment.child` di `startAdMob`, `lib/app/admob_sdk.dart`) dan perbarui jawaban di sini.
- Listing toko tidak memakai kata-kata yang menyasar anak.

### Keamanan data (Data safety)

Sumber: [Google Mobile Ads SDK: data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure) dan [Play Console: Data safety](https://support.google.com/googleplay/android-developer/answer/10787469).

- Mengumpulkan atau membagikan data pengguna: **Ya** (oleh SDK iklan).
- Semua data dienkripsi saat transit: **Ya** (TLS).
- Cara meminta penghapusan data: tidak ada akun; data iklan dikelola Google. Jawab "Tidak" untuk permintaan penghapusan akun (tidak ada akun).
- Jenis data (semua: **dikumpulkan dan dibagikan**, tidak diproses sementara, wajib kecuali ID iklan):

  | Kategori Play Console | Jenis | Tujuan |
  |---|---|---|
  | Lokasi | Perkiraan lokasi (dari alamat IP) | Iklan atau pemasaran, Analitik, Pencegahan penipuan |
  | Aktivitas aplikasi | Interaksi aplikasi (ketukan dan tontonan iklan) | Iklan atau pemasaran, Analitik, Pencegahan penipuan |
  | Info dan performa aplikasi | Diagnostik | Iklan atau pemasaran, Analitik, Pencegahan penipuan |
  | ID perangkat atau lainnya | ID iklan, ID set aplikasi | Iklan atau pemasaran, Analitik, Pencegahan penipuan |

- Progres game (bintang, koin, kostum, pengaturan) **tidak dideklarasikan**: hanya disimpan di perangkat dan tidak pernah dikirim ke pengembang. Auto Backup Android (cadangan ke akun Google pemain, aktif di manifest) dikelola Google, terenkripsi ujung ke ujung di Android 9+ dengan kunci layar, dan tidak bisa dibaca pengembang; panduan Data safety tidak menyebutnya, jadi tidak dideklarasikan sebagai pengumpulan oleh aplikasi. Kebijakan privasi tetap menyebutnya.

### Rating konten (kuesioner IARC)

- Kategori: **Game** → Teka-teki / Puzzle.
- Kekerasan, darah, ketakutan, seks, bahasa kasar, narkoba, judi: **Tidak**. (Vas pecah dan gelas jatuh adalah komedi benda, tanpa makhluk terluka.)
- Interaksi antar pengguna, berbagi lokasi, pembelian digital: **Tidak** (koin hanya didapat di dalam game, tidak dijual).
- Iklan: **Ya**. Rating konten iklan dibatasi **G** lewat `maxAdContentRating` (`lib/app/admob_sdk.dart`).
- Perkiraan hasil: semua umur (ESRB Everyone, PEGI 3).

### Lain-lain

- Aplikasi berita / aplikasi pemerintah / aplikasi keuangan / kesehatan: **Tidak**.
- ID iklan: **Ya**, dipakai untuk iklan (izin `AD_ID` ditambahkan SDK).

## Kategori dan kontak

- Kategori: Game → Puzzle. Tag: Logika, Kasual, Offline.
- Email kontak: `yoluvy.dev@gmail.com`. Nama pengembang: **Yoluvy**. Situs (opsional): https://yoluvy.my.id/
