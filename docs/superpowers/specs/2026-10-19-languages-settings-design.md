# Desain langkah 15: Bahasa dan Pengaturan

## Context

Langkah 15 roadmap. Pasar utama sekarang AS/Kanada, jadi game butuh bahasa Inggris (utama), Indonesia, Portugis Brasil, dan Rusia. Tombol Pengaturan di Beranda juga harus mulai berfungsi. Keputusan pasar, bahasa, dan isi Pengaturan sudah ada di `docs/DESIGN_NOTES.md` bagian "Sebelum langkah 15". Hari ini pemilik repo menambah keputusan baru:

- **Nama game: "Ginger Logic"**, merek berbahasa Inggris yang **sama di semua bahasa** (tidak diterjemahkan). "Kucing Oren" sebelumnya hanya judul kerja. Yang diterjemahkan hanya teks di game, tagline, dan nanti listing Play Store (langkah 17).
- **Logo** memakai susunan yang sekarang: "Ginger" kecil (`logoSmall`, warna `ink`) di atas, "Logic" besar oranye (`logo`, `c.logo`, bayangan `logo`) di bawah, Oyen tidur di atasnya. Karena merek tetap berhuruf Latin, logo tetap memakai Fredoka di bahasa Rusia.
- **Oyen** tetap "Oyen". Di kalimat Rusia ditulis Sirilik "Ойен".
- **Ibu** diterjemahkan: EN "Mom" ("Mom's Vase"), PT "Mamãe" ("O Vaso da Mamãe"), RU "мама" ("Мамина ваза").

Keputusan saya (dicatat di DESIGN_NOTES, disebut di PR):

- Kode, nama paket `kucing_oren`, kelas `KucingGame`/`KucingOrenApp`, dan repo tidak ikut diganti nama. `android:label` diganti ke "Ginger Logic" sekarang karena namanya sudah final.
- Bahasa Portugis cukup satu berkas `app_pt.arb` berisi Portugis Brasil, jadi HP pt-PT juga mendapat versi Brasil.
- Galeri (`/galeri`, alat pengembang tanpa tombol) tetap berbahasa Indonesia dan tidak masuk ARB.
- Terjemahan EN/PT/RU saya tulis sendiri; di PR disarankan dicek penutur asli.

## Arsitektur

### l10n
- `pubspec.yaml`: `flutter_localizations` (sdk), `intl: any`, `package_info_plus` (versi di Tentang), `flutter: generate: true`. `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-dir: lib/l10n` (bukan paket sintetis), `nullable-getter: false`, `required-resource-attributes: true`.
- ARB `app_en.arb` (template, dengan `@kunci` deskripsi), `app_id.arb`, `app_pt.arb`, `app_ru.arb`. Jamak ICU `{n, plural, one{…} few{…} many{…} other{…}}` untuk semua angka yang menempel kata (langkah, benda, koin, bintang, kali); Rusia memakai one/few/many.
- **Teks Indonesia di `app_id.arb` harus sama persis dengan teks sekarang.** Test lama yang dijalankan dengan locale `id` jadi bukti regresi bahwa tidak ada kalimat yang berubah.
- `lib/l10n/l10n.dart`: `extension on BuildContext { AppLocalizations get l10n }` dan fungsi penerjemah data model (lapisan Flutter): `directionText(l, Direction)`, `itemName(l, Item)` (menggantikan `itemName` di tray), `levelName(l, id)` (switch id → getter `level1Name`…`level20Name`; nama bos tanpa awalan + pola `bossLevelName(name)` "BOS: {name}" / "BOSS: {name}"), `chapterName(l, n)`, `chapterTitle`, `costumeName(l, OyenCostume)`, `oyenLabel(l, OyenLook)`, `runCaptionText(l, caption)`, `replayCaptionText(l, caption)`, `hintTextFor(l, HintText)`, `hintEffectText(l, Item)`, `failText`, dll.

### Model Dart murni: data, bukan kalimat
Pindahkan semua kalimat keluar dari `lib/game/` tanpa mengimpor Flutter:
- `Direction.label` dihapus (simbol `^ > v <` tetap).
- `run_caption.dart`: `runCaption(...)` → `StepCaption` (kind enum + `dir`, `obstacle` meja/tembok, `water` genangan/ember, `steps`, `sameAs` langkah/awal). `replay.dart`: `replayCaptions` → `List<StepCaption>` dengan kind rekap (`loop`, `tooManySteps`, `vaseSafe`, `finished(steps)`, …). `TrailMark.label` tetap (hanya angka dan tanda).
- `hints.dart`: `hintText` → `HintText` (tier, item pertama, daftar `(Item, jumlah)` urut kemunculan, `hasVase`); `hintEffect`/`noItemsHintText` pindah ke ARB. Daftar "a, b, dan c" disusun di lapisan l10n per bahasa.
- `costumes.dart`: `Costume.name` dihapus. `chapter.dart`: `chapterNames`, `Chapter.name/title/bossName/bossPrefix` dihapus, nama dari l10n lewat nomor babak/id level (`Level.name` dari JSON tetap ada tapi tidak ditampilkan).
- `render/oyen.dart`: `OyenPose.label` dan `OyenLook.label` pindah ke `oyenLabel(l, look)`; `BoardMark.label` tetap.
- `lib/screens/level/tutorial.dart`: `tutorialFor(l, id)`.
- Test model (`run_caption_test`, `replay_test`, `hints_test`, `costumes_test`, `progress_test` babak) diubah membandingkan data. Teks Indonesia/Inggris dicek lewat `lookupAppLocalizations(Locale('id'))` di test l10n baru, termasuk caption level 13 yang persis desain 09.

### Bahasa terpilih
- `lib/app/language.dart`: `enum AppLanguage { system, en, id, pt, ru }` + `resolveLocale(AppLanguage, List<Locale> device)` murni: pilihan pemain → locale itu; `system` → bahasa HP pertama yang didukung (cocok `languageCode`), selain itu `en`.
- `ProgressStore.loadLanguage/saveLanguage` (kunci `settings.language`, nama enum; rusak → `system`), `MemoryProgressStore.language`. `ProgressController.language`, `setLanguage(l)` (notify, simpan).
- `KucingOrenApp`: `title: 'Ginger Logic'`, `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales`, `locale:` dari `resolveLocale(progress.language, PlatformDispatcher.locales)`; rebuild saat bahasa HP berubah (`didChangeLocales` lewat `AppLifecycleListener`/`WidgetsBindingObserver`) dan saat `language` berubah.

### Font
`_fredokaFallback = [Nunito]` sudah ada di `ko_type.dart`. Cek berkas TTF Nunito yang dibundel punya huruf Sirilik dan Fredoka punya ã/ç/õ (`pip install fonttools`, lalu cek cmap). Kalau Nunito ternyata subset Latin, ganti dengan berkas lengkap dari Google Fonts (OFL sama). Pastikan juga gaya Nunito sendiri (body) tidak jatuh ke font sistem. Test: teks Rusia di gaya Fredoka memakai fallback Nunito (cek `TextStyle.fontFamilyFallback`) dan potret layar RU dicek secara visual.

### Pengaturan (rute `/pengaturan`, `AppRoutes.settings`)
`lib/screens/settings/settings_screen.dart` + `settings_parts.dart`. Desainnya belum ada, jadi dibuat dengan gaya yang ada: bar seperti `ClosetBar` (kembali + judul), kartu `KoCard` per bagian, sheet konfirmasi lewat `showLevelSheet`/`LevelSheet`/`SheetButton` (`lib/screens/level/level_sheet.dart`).
- **Bahasa**: lima baris pilihan (lingkaran centang hijau seperti kartu yang terbuka). Nama bahasa ditulis dalam bahasanya sendiri ("English", "Bahasa Indonesia", "Português (Brasil)", "Русский"); "Ikuti bahasa HP" diterjemahkan ke bahasa yang aktif. Mengetuk langsung mengganti bahasa.
- **Lihat tutorial lagi**: `ProgressController.replayTutorials()` mengosongkan `tutorialsDone`, lalu muncul pesan singkat bahwa tutorial level 1, 3, dan 6 akan tampil lagi.
- **Reset progres**: sheet konfirmasi (judul, penjelasan apa yang dihapus, tombol batal dan hapus berwarna bata). `ProgressController.resetProgress()` menghapus bintang, koin (disimpan 0), petunjuk, kostum (`Wardrobe.initial`), dan tutorial; `rewards` dan `language` tetap. Ketukan ganda aman, semua perubahan terjadi sebelum menyimpan.
- **Tentang**: "Ginger Logic", versi dari `PackageInfo` (test: `PackageInfo.setMockInitialValues`), kredit font Fredoka dan Nunito (SIL OFL), tombol "Lisensi" → `showLicensePage` (lisensi font sudah didaftarkan di `main.dart`).
- Tidak ada tempat kosong untuk musik/efek atau Privasi.
- `HomeScreen`: tombol Pengaturan aktif menuju `/pengaturan`; logo jadi "Ginger"/"Logic" (`Semantics` label "Ginger Logic"); komentar `_MenuButton`/kelas yang masih bilang "belum berfungsi" dibereskan (butir review langkah 13).

