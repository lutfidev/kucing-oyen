# Rencana langkah 15: Bahasa dan Pengaturan

Spec: `docs/superpowers/specs/2026-10-19-languages-settings-design.md`.

## Urutan kerja (commit kecil per butir)

1. **Awal langkah** (CLAUDE.md): `git fetch`, cek PR terbuka (sudah kosong, PR #16 sudah di-merge), `git checkout main && git pull --ff-only`, `git checkout -b feat/languages-settings`, hapus branch lokal yang sudah di-merge (`docs/roadmap-languages-audio`, dll.), `flutter pub get && flutter analyze && flutter test`.
2. Simpan spec ini ke `docs/superpowers/specs/2026-10-19-languages-settings-design.md` dan rencana ke `docs/superpowers/plans/2026-10-19-languages-settings.md`. `docs: ...`
3. Pasang l10n: pubspec, `l10n.yaml`, ARB awal, `lib/l10n/l10n.dart`, delegates di `KucingOrenApp`, helper test (`testProgressWith(language: AppLanguage.id)` default; `pumpThemed` dan helper baru `testMaterialApp(home:)` dengan delegates + `locale: Locale('id')`, dipakai di `screenshot_test`, `overflow_test`, `hint_sheet_test`, `level_view_test`, `result_view_test`, `replay_view_test`). Test `l10n_test.dart`: kunci keempat ARB sama, placeholder sama.
4. Bahasa terpilih: `AppLanguage`, `resolveLocale`, store, controller (TDD: test model dan `PrefsProgressStore` dulu).
5. Model ke data (TDD per berkas): `Direction.label`, captions, hints, costumes, chapter, `OyenLook.label`, tutorial. Setelah tiap berkas, test lama dengan locale `id` tetap hijau.
6. Pindahkan teks layar ke ARB per folder: home, chapter, level (bar, tray, run panel, sheet aturan, petunjuk, tutorial), result, replay, closet, coins, widgets (`KoCoinChip`, `TraySlot` semantics, dll.). Audit akhir: `grep` string literal huruf besar/kecil di `lib/screens`, `lib/widgets`, `lib/app` (di luar `lib/gallery`) sampai yang tersisa hanya kunci teknis.
7. Terjemahan EN, PT, RU lengkap: nada santai, "turns clockwise", caption memakai arah layar, jamak ICU.
8. Font: cek glyph, tambah test fallback.
9. Layar Pengaturan + rute + tombol Beranda + logo baru; `resetProgress`, `replayTutorials`.
10. Test (lihat Verifikasi) + overflow 4 bahasa + potret layar per bahasa.
11. Dokumen: `CLAUDE.md` (judul/pembuka: nama "Ginger Logic", bahasa; "Aturan penting": aturan teks per bahasa, ARB wajib lengkap; "Struktur": `lib/l10n/`, `lib/screens/settings/`, `language.dart`, API model baru, helper test locale), GDD (judul, baris Bahasa), `docs/DESIGN_NOTES.md` bagian "Langkah 15" (nama/logo, Ойен, Mom, pt = Brasil, galeri tetap ID, tata letak Pengaturan, cek font, `android:label`), README (nama), `docs/ROADMAP.md` (centang 15; prompt 17 menyebut nama "Ginger Logic"), `android:label`.
12. Review: `superpowers:requesting-code-review` (satu subagent, effort high) → `receiving-code-review` → perbaiki → `verification-before-completion` → push → `gh pr create --base main` dengan judul "feat: Bahasa dan Pengaturan" dan badan berbahasa Indonesia sesuai CLAUDE.md.

## Berkas utama
- Baru: `l10n.yaml`, `lib/l10n/app_{en,id,pt,ru}.arb`, `lib/l10n/l10n.dart`, `lib/app/language.dart`, `lib/screens/settings/*`, `test/l10n/l10n_test.dart`, `test/app/language_test.dart`, `test/screens/settings_screen_test.dart`.
- Diubah: `pubspec.yaml`, `lib/app/{app,progress_store,progress_scope,router,routes}.dart`, `lib/game/sim/direction.dart`, `lib/game/model/{run_caption,replay,hints,costumes,chapter}.dart`, `lib/game/render/oyen.dart`, semua layar di `lib/screens/`, `lib/widgets/*` yang punya teks, `test/test_helpers.dart`, `test/screens/overflow_test.dart`, `test/screenshots/screenshot_test.dart`, `android/app/src/main/AndroidManifest.xml`, dokumen.

## Verifikasi
- `flutter analyze` → `No issues found!`; `flutter test` semua hijau, termasuk 20 solusi level.
- Test baru:
  - bahasa awal mengikuti HP (`tester.platformDispatcher.localesTestValue` = pt-BR → Portugis, ru → Rusia, fr → Inggris);
  - pilihan bahasa tersimpan dan tetap ada saat aplikasi dibuka ulang;
  - "Ikuti bahasa HP" kembali ke HP;
  - reset menghapus bintang/koin/petunjuk/kostum/tutorial tapi tidak bonus harian, iklan, dan bahasa (store dan controller);
  - "Lihat tutorial lagi" memunculkan tutorial level 1;
  - jamak Rusia (1 шаг, 2 шага, 5 шагов, 21 шаг) dan Inggris;
  - keempat ARB punya kunci dan placeholder yang sama;
  - caption/petunjuk EN memakai "clockwise" dan arah layar;
  - `levelName` ada untuk ke-20 id;
  - teks `id` caption level 13 = desain 09.
- `overflow_test.dart`: loop terluar empat locale (en, id, pt, ru) untuk semua kasus yang ada + rute `/pengaturan` + sheet reset. Finder teks di kasus sheet memakai teks per locale atau finder kunci/semantics dari `lookupAppLocalizations`. Ukur waktu jalannya; kalau terlalu lama, ukuran 360×740 untuk locale selain id/ru boleh dipangkas (catat).
- Potret layar: `flutter test test/screenshots --dart-define=SCREENSHOTS=true` → `build/screenshots/390x844/<locale>/` untuk Beranda, fase atur level 13, dan Pengaturan di keempat bahasa (juga 360×640 untuk RU). Periksa gambarnya: logo, huruf Sirilik tidak jatuh ke font sistem, teks tidak terpotong.
- `/check` (format, analyze, test).
