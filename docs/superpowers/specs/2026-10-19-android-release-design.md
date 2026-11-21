# Desain langkah 17: Polish dan rilis Android

## Konteks

Langkah 17 roadmap, langkah terakhir. Hasilnya app bundle release yang siap diunggah ke Play Console. Langkah 16 (PR #18) sudah di-merge dan tidak ada PR terbuka. Keputusan iklan dan audiens ada di `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 15": iklan **tidak** ditandai untuk anak, target audiens Play Console 13+, dan formulir persetujuan (UMP) dipakai di wilayah yang mewajibkan.

Jawaban pemilik repo (19 Okt 2026):
- **`applicationId`:** `com.gingerlogic.app`.
- **ID AdMob:** belum ada. Dipasang sebagai template di satu tempat yang jelas, isinya ID uji Google, dan nanti tinggal ditempel ID asli.
- **Kebijakan privasi:** dihosting di `yoluvy.my.id`, situs GitHub Pages pemilik repo (statis, juga berisi info dan proyek lain). Kontak di kebijakan dan listing: `yoluvy.dev@gmail.com` (akun dibuat pemilik repo).
- **Keystore:** dibuat sendiri oleh pemilik repo.
- **Backup Android (Auto Backup) tetap aktif:** progres ikut pindah saat pemain ganti HP atau memasang ulang, tanpa login di dalam game. Manifest tidak mematikan backup.
- **Ikon launcher:** wajah Oyen bermata ngantuk (pose depan desain, `eyeSleepy`) di latar krem `cream` `#FFF4E2`. Dipilih dari 4 mockup (A).
- **Splash:** wajah yang sama di tengah, latar krem, dan di bawahnya logo "Ginger" kecil di atas "Logic" besar oranye seperti Beranda, lalu tagline kecil "Let's play!" (pilihan T3).
- **Judul Play Store:** EN "Ginger Logic: Cute Cat Puzzle", ID "Ginger Logic: Teka-teki Kucing", PT "Ginger Logic: Gato Teimoso", RU "Ginger Logic: Котоголоволомка". Semuanya ≤ 30 karakter.

## Tujuan

- Build release bisa diunggah: `applicationId` final, ditandatangani keystore di luar repo, `flutter build appbundle` berhasil.
- Petunjuk dan iklan koin memutar iklan berhadiah asli lewat `google_mobile_ads`. Persetujuan UMP diminta sebelum iklan pertama.
- Game punya identitas sendiri: ikon launcher dan splash Oyen.
- Semua teks toko dan kebijakan privasi siap ditempel ke Play Console dan diunggah ke situs.
- Temuan kecil review langkah 13 dan 14 dibereskan.

**Bukan tujuan:** iOS, analytics, crash reporting, akun atau sinkronisasi awan, rating dalam aplikasi, iklan banner atau interstisial, dan mengunggah ke Play Console (itu dikerjakan pemilik repo).

**Anti-tujuan:** iklan yang membuat game macet atau crash saat gagal dimuat; ID uji yang diam-diam terkirim ke produksi tanpa diketahui pemilik repo; teks pembaca layar atau teks pemain yang tidak ada di keempat ARB.

## Desain

### Identitas aplikasi
- `applicationId` dan `namespace` menjadi `com.gingerlogic.app`. `MainActivity` pindah ke paket Kotlin/Java yang sesuai. Nama paket Dart `kucing_oren` tetap.
- Versi `pubspec.yaml`: `1.0.0+1` (keputusan saya).
- `android:label` sudah "Ginger Logic".

### Ikon dan splash (gambar dirender dari kode desain)
- Gambar tidak diketik ulang. Sebuah generator berbasis `flutter test` (pola `test/screenshots/`, aktif lewat `--dart-define`) menggambar wajah Oyen dengan path di `design_svg.dart` (`paintOyen` pose depan, mata ngantuk, tanpa bayangan dan badan; cukup kepala), lalu menulis PNG ke `android/app/src/main/res/` dan `docs/store/`. PNG ikut di-commit. Perintah generatornya dicatat di CLAUDE.md dan DESIGN_NOTES.
- **Adaptive icon** (`mipmap-anydpi-v26`): lapisan depan = kepala Oyen di zona aman 66/108 dp, lapisan belakang = warna `cream`. Lapisan monokrom (ikon tema Android 13+): siluet kepala dengan mata, hidung, dan garis belang dilubangi (keputusan saya). Ikon lama (`mipmap-*dpi/ic_launcher.png`) untuk Android < 8: kepala di lingkaran krem.
- **Ikon Play Store** 512×512 PNG di `docs/store/`: kotak krem penuh tanpa potongan.
- **Splash** lewat tema Android, bukan layar Flutter:
  - Android 12+: `windowSplashScreenBackground` = krem, `windowSplashScreenAnimatableIcon` = kepala Oyen (ukuran ikon 288 dp dengan isi di lingkaran 192 dp), `windowSplashScreenBrandingImage` = gambar logo + tagline (200×80 dp).
  - Android < 12: `launch_background.xml` krem dengan kepala di tengah dan gambar logo di bawah.
  - Tagline ikut bahasa HP lewat folder resource berbahasa (`drawable-in`, `drawable-pt`, `drawable-ru`, default Inggris). Teksnya kunci ARB `splashTagline`: EN "Let's play!", ID "Ayo main!", PT "Bora jogar!", RU "Играем!". Generator membacanya lewat `lookupAppLocalizations`. Logo "Ginger Logic" tetap Fredoka; tagline Rusia memakai cadangan Nunito seperti aturan font yang sudah ada.
  - Warna latar Flutter sesudah splash (`NormalTheme`) juga krem, supaya tidak ada kedipan putih.
- Hasilnya dicek lewat PNG dan potret layar, lalu dicatat di DESIGN_NOTES.

### Iklan berhadiah asli
- Paket `google_mobile_ads` (versi stabil terbaru; baca API-nya dari pub cache sebelum dipakai). UMP ikut di paket ini.
- **Tempat menempel ID** (satu-satunya tempat, diberi komentar "TEMPEL ID ASLI DI SINI"):
  - ID aplikasi AdMob: properti Gradle di `android/app/build.gradle.kts` → `manifestPlaceholders`, lalu `<meta-data com.google.android.gms.ads.APPLICATION_ID>` di manifest. Default = ID aplikasi uji Google.
  - ID unit iklan berhadiah: `lib/app/ad_ids.dart`, **dua unit** (petunjuk dan koin) supaya laporan AdMob terpisah (keputusan saya); kalau hanya satu unit dibuat, ID yang sama ditempel di keduanya. Debug dan profile selalu memakai ID unit uji Google; release memakai konstanta yang ditempel, dan selama konstanta itu masih ID uji, build release memakai ID uji.
  - Selama ID asli belum ditempel, PR dan `docs/store/README.md` menulisnya dengan jelas sebagai hal yang wajib diganti sebelum unggah produksi. Build release tidak digagalkan, supaya app bundle tetap bisa dibuat untuk uji internal.
- `AdMobRewardedAds implements RewardedAds`, satu instans per unit (petunjuk dan koin), masing-masing dibungkus `pauseDuringAds`. `ProgressController` mendapat iklan petunjuk dan iklan koin terpisah (sekarang satu `ads`).
  - Memuat satu iklan lebih dulu, setelah persetujuan memungkinkan.
  - `show()` memuat iklan kalau belum ada, dengan batas waktu. Hasilnya true hanya kalau `onUserEarnedReward` terjadi; false kalau gagal dimuat, ditutup lebih dulu, waktu habis, persetujuan belum memungkinkan, atau ada error. Tidak pernah melempar.
  - Sesudah iklan ditutup, iklan berikutnya dimuat.
  - Pemanggilan SDK diletakkan di balik celah kecil yang bisa dipalsukan (pola `MusicDeck`), supaya alur muat, tampil, hadiah, gagal, dan waktu habis bisa diuji tanpa SDK.
- Konfigurasi permintaan iklan: tidak ditandai untuk anak dan tidak ditandai "under age of consent". Rating konten maksimum `G` (keputusan saya; cocok dengan gambar imut dan pemain keluarga).
- `FakeRewardedAds` tetap dipakai semua test.

### Persetujuan iklan (UMP)
- Antarmuka `AdConsent` (palsu di test, asli lewat UMP):
  - `gather()` saat aplikasi mulai: perbarui info persetujuan, lalu tampilkan formulir kalau wajib. Tidak memblokir layar pertama, dan error ditelan.
  - `canRequestAds`.
  - `privacyOptionsRequired`.
  - `showPrivacyOptions()`.
- `MobileAds.instance.initialize()` dan pemuatan iklan pertama baru berjalan setelah `canRequestAds` true.
- Kalau `show()` dipanggil sebelum persetujuan bisa meminta iklan, hasilnya false. Layar petunjuk dan koin sudah punya pesan "iklan gagal".

### Bagian Privasi di Pengaturan
- Bagian baru "Privasi" di antara Progres dan Tentang, dalam `KoCard` seperti bagian lain:
  - Tombol "Kebijakan privasi" membuka URL kebijakan di browser (`url_launcher`). Kalau gagal dibuka, muncul pesan kecil.
  - Tombol "Atur persetujuan iklan" hanya tampil kalau `privacyOptionsRequired`, dan membuka formulir UMP.
- Semua teksnya di keempat ARB. Konsentnya lewat scope atau parameter supaya bisa dipalsukan di test. Overflow test Pengaturan mencakup kedua keadaan (tombol persetujuan ada dan tidak ada).
- URL kebijakan: konstanta `privacyPolicyUrl` = `https://yoluvy.my.id/ginger-logic/privacy/` (keputusan saya untuk jalurnya; pemilik repo menyebut domain saja). Di repo GitHub Pages cukup berkas `ginger-logic/privacy/index.html`.

### Dokumen toko: `docs/store/`
- `README.md`: daftar isi folder, apa yang ditempel ke kolom Play Console mana, jawaban formulir Data safety dan rating konten (dicek ulang terhadap panduan Google saat ditulis, termasuk soal Auto Backup), ID AdMob yang wajib diganti, cara build release, dan lokasi keystore (bukan isinya).
- `listing-en.md`, `listing-id.md`, `listing-pt.md`, `listing-ru.md`: judul (pilihan di atas), deskripsi singkat ≤ 80 karakter, dan deskripsi panjang ≤ 4000 karakter, dengan nada santai dan jenaka game. Inggris ditulis lebih dulu. Contoh deskripsi singkat EN: "A stubborn orange cat won't listen. Place fish & boxes to guide it home!"
- `privacy/index.html`: kebijakan privasi siap unggah, satu halaman dengan keempat bahasa (bagian beranchor). Isinya: tidak ada akun dan tidak ada server sendiri; progres disimpan di HP dan ikut dicadangkan Android ke akun Google pemain (bisa dimatikan di pengaturan HP), tidak pernah dikirim ke pengembang; iklan AdMob mengumpulkan ID iklan, perkiraan lokasi dari IP, dan info perangkat (dipersonalisasi hanya dengan persetujuan); cara menarik persetujuan lewat Pengaturan; anak di bawah 13; kontak `yoluvy.dev@gmail.com` dengan nama pengembang "Yoluvy" (keputusan saya, dari alamat email dan domainnya); tanggal berlaku. Juga `privacy/README.md` berisi cara mengunggahnya ke jalur di atas.
- Aset gambar toko: ikon 512, feature graphic 1024×500 (wajib di Play Console; latar krem dengan Oyen tidur dan logo, keputusan saya), dan potret layar ponsel per bahasa dengan rasio ≤ 2:1 (potret layar sekarang 390×844 lebih dari 2:1; dibuat ulang di 1080×1920 = 360×640 × 3). Semuanya dari generator yang sama.

### Signing release
- `android/key.properties` (diabaikan git) berisi `storeFile`, `storePassword`, `keyAlias`, dan `keyPassword`. Keystore di luar repo.
- `build.gradle.kts` memakai config release kalau `key.properties` ada. Kalau tidak ada, build release jatuh ke debug key dengan peringatan, supaya `flutter run --release` tetap jalan.
- Kunci ini dipakai sebagai upload key dengan Play App Signing.
- Keystore dibuat pemilik repo. `docs/store/README.md` memuat perintah `keytool` siap jalan (lokasi di luar repo, alias `upload`), isi contoh `key.properties`, dan pengingat backup. Di langkah ini build release dicek dengan cadangan debug key; bundle bertanda tangan asli dibuat pemilik repo sesudah keystore ada.

### Polish: temuan review langkah 13 dan 14
- `buyCostume`: simpan kostum dulu, baru koin (gagal di tengah menguntungkan pemain).
- `unawaited(...)` untuk `buyCostume`/`wearCostume` di `ClosetScreen`, dan untuk `claimDailyBonus` di `coin_sheet.dart`.
- Tinggi pratinjau Lemari Kostum (`rest`) tidak lagi mengulang jarak Column dan faktor 1,25.
- Koin di label harga kartu kostum memakai garis 2,4 seperti desain 12 (sekarang `coinPlainSvg` 2).
- Komentar dokumentasi yang lewat 80 kolom di `progress_scope.dart`, `test_helpers.dart`, dan `level_sheet.dart`.
- Chip koin Lemari Kostum (`KoCoinChipStyle.outlined`) bergerak saat ditekan.
- Chip koin yang bisa ditekan tetap `liveRegion`, jadi saldo baru diumumkan.
- `showLevelSheet`/`LevelSheet`/`SheetButton` dipindah dari `lib/screens/level/` ke tempat bersama (`lib/widgets/` atau `lib/screens/common/`), dan impornya diperbarui.
- Jumlah iklan rusak di `rewards.daily` dianggap jatah habis, bukan 0.

### Penutup
- Centang daftar "Isi versi pertama" di GDD, dan centang langkah 17 di ROADMAP.
- Perbarui bagian "Struktur" di CLAUDE.md: iklan, persetujuan, Privasi, generator ikon/splash/aset toko, `docs/store/`, dan signing.
- Catat di DESIGN_NOTES: ikon, splash, tagline, judul toko, rating konten `G`, jalur URL privasi, perilaku ID uji di release, dan feature graphic.

## Batasan
- `flutter analyze` bersih dan `flutter test` hijau (sekarang 1830 lulus). Test yang ada tidak boleh dibuat bergantung pada SDK iklan.
- Tidak ada warna atau ukuran hardcode di widget. Warna di generator gambar diambil dari `KoColors` atau path desain.
- Teks baru di keempat ARB, lalu `flutter gen-l10n`.
- Semua rute di overflow test tetap lolos di keempat bahasa.

## Diserahkan ke pembuat
- Versi persis `google_mobile_ads` dan `url_launcher`, serta pengaturan Gradle atau minSdk yang dibutuhkannya.
- Batas waktu muat iklan, dan apakah iklan dimuat ulang setelah gagal.
- Tempat bersama untuk komponen sheet.
- Rincian tata letak gambar branding splash dan feature graphic, dalam batas desain di atas.
