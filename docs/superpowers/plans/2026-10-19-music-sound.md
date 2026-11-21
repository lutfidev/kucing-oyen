# Rencana langkah 16: Musik dan efek suara

Spec: `docs/superpowers/specs/2026-10-19-music-sound-design.md` (nama, kunci, dan pemicu suara ada di sana).

## Urutan kerja (commit kecil per butir, TDD)

1. **Awal langkah**: `main` terbaru, branch `feat/music-sound`, baseline analyze bersih dan 1766 test lulus. Simpan spec dan rencana ini. `docs: ...`
2. **Model** `lib/game/model/sounds.dart`: `GameSound`, `MusicTrack`, `asset`, `stepSound`. Test `test/game/model/sounds_test.dart` ditulis lebih dulu.
3. **Simpanan**: `SoundSettings`, `loadSound`/`saveSound` di `ProgressStore`, `MemoryProgressStore.sound`, `PrefsProgressStore` (`settings.music`, `settings.sfx`, nilai rusak = menyala). Grup `suara` di `test/app/progress_test.dart`.
4. **Pengendali**: `lib/app/sound_player.dart` (`SoundPlayer`, `FakeSoundPlayer`) dan `lib/app/game_audio.dart` (`GameAudio`, `AudioHold`, `pauseDuringAds`, `AudioScope`). Test `test/app/game_audio_test.dart`.
5. **Aset**:
   - Unduh paket Kenney ke `<scratchpad>/kenney/` dan cari bunyi kucing CC0 di OpenGameArt.
   - Skrip pilih/potong/normalisasi `tool/audio/make_sfx.py` (ikut di-commit, sumbernya di luar repo; mencatat berkas asal per suara).
   - `tool/audio/make_music.py` membuat dua lagu.
   - Hasilnya di `assets/audio/{sfx,music}/` plus `assets/audio/License-Kenney.txt` dan entri pubspec.
   - Test `test/app/audio_assets_test.dart`.
6. **Pemutar asli**: `flutter pub add audioplayers`, baca API dari pub cache, lalu tulis `AudioplayersSoundPlayer`.
   - Pasang di `main.dart`: `LicenseRegistry` Kenney, `GameAudio.load`, dan iklan yang dibungkus `pauseDuringAds`.
   - `KucingOrenApp(audio:)`: `AudioScope`, lifecycle hold, listener rute yang memanggil `musicFor`.
   - `pumpApp(audio:)`.
   - Test `test/app/app_audio_test.dart`.
7. **Pemicu**:
   - `KoPressable` dan tombol `GestureDetector` lain → `tap`.
   - `LevelView`: angkat, taruh, kembali, kosongkan, bangun, langkah jalan.
   - `ResultStars` → `star`; `BoredResult` → `bored`; koin di layar hasil dan sheet Tambah Koin → `coin`.
   - Grup `suara` di `level_view_test`, `result_view_test`, `coin_sheet_test`, dan test `KoPressable`.
8. **Pengaturan**:
   - Kunci ARB `soundSection`, `music`, `soundEffects`, dan kredit Kenney di keempat bahasa, lalu `flutter gen-l10n`.
   - `SoundCard` di urutan pertama, kredit di `AboutCard`.
   - Test di `settings_screen_test`.
9. **Galeri suara** `/galeri/suara`, ditambahkan ke `overflow_test`. **Titik cek pemilik repo:** kirim path berkas audio untuk didengar, lalu sesuaikan.
10. **Dokumen**: DESIGN_NOTES "Langkah 16", CLAUDE.md "Struktur", centang ROADMAP.
11. **Verifikasi dan PR**:
    - `/check`, potret layar Pengaturan, `flutter build apk --debug`.
    - Review satu subagent effort high, lalu receiving-code-review, lalu verification.
    - Push dan `gh pr create`.
