# Desain langkah 16: Musik dan efek suara

## Konteks

Langkah 16 roadmap: game punya musik latar dan efek suara, keduanya bisa dimatikan terpisah di Pengaturan. Belum ada satu pun berkas audio atau paket audio di repo. PR langkah 15 (#17) sudah di-merge, dan tidak ada PR terbuka.

Jawaban pemilik repo atas pertanyaan prompt roadmap:
- **Efek suara:** paket Kenney CC0, dipilih, dikompres ke OGG, lisensinya dicatat per berkas, dan Kenney dikredit di Tentang.
- **Musik:** dibuat sendiri dengan skrip Python (milik kita, tanpa lisensi pihak ketiga).
- **Suasana:** dua lagu. Beranda, peta, Lemari Kostum, dan Pengaturan memakai lagu santai-ceria; layar level (fase atur, jalan, hasil, putar ulang) memakai lagu yang lebih tenang dan ringan. Pergantian lagu memakai crossfade pendek.

Alat yang tersedia: Python 3.12, tanpa ffmpeg. Encode OGG lewat `pip install numpy soundfile` (libsndfile di wheel bisa menulis OGG Vorbis).

## Desain

### Model Dart murni: `lib/game/model/sounds.dart`
- `enum GameSound` (13 suara): `tap` (tombol), `pickUp` (angkat benda), `place` (taruh), `back` (benda kembali ke baki), `wake` (Oyen bangun), `eat`, `scared` (kaget air), `box` (masuk kardus), `glass` (gelas jatuh), `vase` ("PRANG!"), `star`, `bored` (Oyen bosan), `coin`. Tiap suara punya getter `asset` → `audio/sfx/<name>.ogg`.
- `enum MusicTrack { home, level }` dengan getter `asset` → `audio/music/<name>.ogg`.
- `GameSound? stepSound(RunFrame frame)`: `eat`→eat, `scared`→scared, `enterBox`→box, `knockGlass`→glass, `knockVase`→vase. `walk`/`turn`/`sit`/langkah 0 tidak bersuara, karena 4 langkah per detik akan bising.

### Pemutar di balik antarmuka: `lib/app/sound_player.dart` (pola `RewardedAds`)
- `abstract interface class SoundPlayer`: `play(GameSound)`, `playMusic(MusicTrack)` (crossfade dari lagu yang sedang jalan), `stopMusic()`, `pauseMusic()`, `resumeMusic()`.
- `FakeSoundPlayer`: mencatat `played` (List<GameSound>), `music` (lagu sekarang atau null), dan `musicPaused`. Tidak memutar apa pun. Dipakai di semua test dan sebagai default.
- `AudioplayersSoundPlayer` (asli, paket `audioplayers`; baca dulu API-nya dari pub cache sebelum dipakai):
  - SFX lewat `AudioPool` per suara, dibuat malas.
  - Musik lewat satu `AudioPlayer` berulang (`ReleaseMode.loop`), volume ±0,5, crossfade ±400 ms dengan Timer.
  - Konteks audio global diatur supaya SFX tidak merebut fokus audio dan memotong musik (mix with others).
  - Semua error platform ditelan, supaya game tetap jalan tanpa suara.

### Pengendali: `lib/app/game_audio.dart`
- `GameAudio extends ChangeNotifier`, dengan `GameAudio.load(store:, player:)`.
- Sakelar: `musicOn`, `effectsOn`, `setMusicOn(bool)`, `setEffectsOn(bool)`, disimpan lewat `ProgressStore`.
- `play(GameSound)`: tidak melakukan apa-apa kalau efek mati atau musik sedang ditahan.
- `track` (lagu yang diminta layar) dan `setTrack(MusicTrack)`.
- `hold(AudioHold)` / `release(AudioHold)` dengan `enum AudioHold { background, ad }`. Musik diputar hanya kalau `musicOn`, ada `track`, dan tidak ada yang menahan.
- `RewardedAds pauseDuringAds(RewardedAds ads)` membungkus iklan supaya musik ditahan selama `show()`, termasuk saat gagal atau error (pakai `finally`).
- `AudioScope` (`InheritedNotifier<GameAudio>`): `of` untuk Pengaturan, dan `maybeRead` untuk tombol dan layar. `maybeRead` null tanpa scope, jadi test widget lama tetap senyap.
- Sakelar terpisah dari `ProgressController`, jadi `resetProgress()` tidak menyentuhnya (sesuai DESIGN_NOTES: "pilihan bahasa dan suara juga tetap").

### Simpanan: `lib/app/progress_store.dart`
- `SoundSettings(music, effects)`, default keduanya menyala.
- `loadSound()`/`saveSound()` dengan kunci `settings.music` dan `settings.sfx` (bool). Nilai rusak dibaca sebagai menyala.
- `MemoryProgressStore` mendapat field `sound`.

### Pemasangan
- `main.dart`: `audio = await GameAudio.load(store, AudioplayersSoundPlayer())`, lalu `ProgressController.load(..., ads: audio.pauseDuringAds(FakeRewardedAds()))`, lalu `KucingOrenApp(progress:, audio:)`.
- `KucingOrenApp`:
  - Parameter `audio` (default `GameAudio` dengan `FakeSoundPlayer`, seperti `ads`), dibungkus `AudioScope`.
  - `AppLifecycleListener`: `onHide` → `hold(background)`; `onShow` → `release(background)`. `onResume` tetap menjalankan `refreshDay`.
  - Listener `routerDelegate` memanggil `audio.setTrack(musicFor(location))`. `musicFor` (di `routes.dart`) mengembalikan `level` untuk `/babak/:n/level/:id`, selain itu `home`.
- `test_helpers.pumpApp` mendapat parameter `audio:` (default fake) dan mengembalikan akses ke fake-nya.

### Titik pemicu suara
- `KoPressable.onTap` → `tap`. Juga diberi `tap`: baris bahasa dan baris sakelar Pengaturan, kartu kostum, kartu babak, `LevelNode`, dan "Lewati" tutorial.
- `LevelView`:
  - `_start` → `pickUp`.
  - `_drop` ke petak menyala → `place`.
  - Dilepas di luar papan atau batal, sehingga benda kembali → `back`. "Kosongkan baki" → `back`.
  - `_wake` → `wake`.
  - Saat langkah tampil maju tepat satu (dari tick maupun "maju satu langkah") → `stepSound(frame)`. Lompatan beberapa langkah (`skipToEnd`, kurangi gerak) senyap.
- `ResultStars`: satu `star` per bintang, di saat `popDelays` masing-masing, hanya kalau animasinya jalan. Dengan `disableAnimations` tidak ada suara bintang.
- `BoredResult` dibuka → `bored`. `SuccessResult`/`VaseResult` dengan `coins > 0` → `coin` sesudah bintang terakhir. `VaseResult` tidak menambah suara lain, karena PRANG sudah berbunyi di fase jalan.
- Sheet Tambah Koin: bonus diambil atau iklan berhasil → `coin`.
- Putar ulang: tidak ada suara langkah (slider bisa digeser cepat); hanya `tap` tombol.

### Pengaturan
- Bagian baru "Suara" di urutan pertama, sesuai urutan DESIGN_NOTES "Isi Pengaturan".
- `SoundCard` di `settings_parts.dart`: dua baris (Musik, Efek suara) bergaya baris bahasa, dengan sakelar pil yang digambar sendiri dari token yang ada (hijau saat menyala). Semantik `toggled`, kunci `sound-music` dan `sound-effects`. Tambah token hanya kalau perlu.
- Tentang: baris kredit "Efek suara: Kenney (CC0)" di samping kredit font. Lisensi CC0 Kenney didaftarkan di `LicenseRegistry` dari `assets/audio/License-Kenney.txt`.
- ARB: tambah kunci `soundSection`, `music`, `soundEffects`, dan kredit Kenney di keempat bahasa (Indonesia ditulis lebih dulu, nada santai), lalu `flutter gen-l10n`.

### Galeri suara (untuk audisi)
- Rute `/galeri/suara`, berbahasa Indonesia seperti galeri lain: satu tombol per `GameSound` dan per lagu, memakai `AudioScope`.
- Pemilik repo bisa mendengar semuanya di HP (`flutter run --route /galeri/suara`).
- Rute ini ditambahkan ke daftar `routes` di `overflow_test`.

## Aset audio

- **SFX:** unduh paket Kenney (Interface Sounds, Impact Sounds, RPG Audio, Casino Audio, Digital Audio; CC0) ke folder baru di scratchpad, terpisah dari skrip.
  - Pilih per `GameSound` berdasarkan nama dan analisis durasi/puncak. Bunyi kucing (`wake`, `scared`, `bored`) dicari dulu di OpenGameArt dengan lisensi CC0. Kalau tidak ada, pakai bunyi kartun Kenney (mis. nada naik untuk bangun, cipratan untuk kaget, nada turun untuk bosan).
  - Potong hening, normalisasi, simpan ke `assets/audio/sfx/*.ogg` (mono 44,1 kHz). Target setiap berkas ≤ 40 KB.
- **Musik:** `tool/audio/make_music.py` (numpy + soundfile, deterministik dengan seed tetap, ikut di-commit supaya bisa dibuat ulang). Hasilnya `assets/audio/music/home.ogg` dan `level.ogg`.
  - `home`: ±108 BPM, mayor, pluck + bass + perkusi lembut, ceria.
  - `level`: ±84 BPM, lebih jarang, nada marimba/kalimba FM, tenang.
  - Keduanya loop mulus ±30–40 detik (ekor gema dibungkus ke awal), mono 32 kHz OGG. Target ≤ 400 KB per lagu.
- `pubspec.yaml`: `audioplayers` (versi stabil terbaru lewat `flutter pub add`), aset `assets/audio/sfx/`, `assets/audio/music/`, dan `assets/audio/License-Kenney.txt`.
- **Titik cek dengan pemilik repo (satu kali):** sesudah SFX dipilih dan musik dibuat, kirim path berkasnya (dan galeri suara) supaya pemilik repo bisa mendengar, lalu sesuaikan sebelum di-commit. Saya tidak bisa mendengar audio, jadi pilihan nada butuh telinga pemilik repo.

## Test

- `test/game/model/sounds_test.dart`: `stepSound` untuk setiap `StepKind` dan langkah 0. Setiap `GameSound`/`MusicTrack` punya `asset`.
- `test/app/game_audio_test.dart`:
  - Efek mati berarti `play` tidak sampai ke pemain. Musik mati berarti `stopMusic`; dinyalakan lagi berarti lagu yang diminta diputar.
  - Kedua sakelar tersimpan.
  - Hold `background` dan `ad` (dua alasan bertumpuk) menjeda musik lalu melanjutkannya.
  - `pauseDuringAds` menahan musik selama iklan, juga saat iklan gagal atau error.
- `test/app/progress_test.dart`, grup `suara`: `PrefsProgressStore` membaca dan menulis `settings.music`/`settings.sfx`, nilai rusak dibaca menyala, dan `resetProgress` tidak mengubahnya.
- `test/app/app_audio_test.dart`:
  - Beranda memutar `home`. Masuk level memutar `level`, kembali ke peta memutar `home`.
  - Lifecycle `paused` menjeda musik dan `resumed` melanjutkannya.
  - Iklan koin dari Beranda menjeda musik selama iklan, dengan iklan yang menunggu `Completer`.
- `level_view_test.dart`, grup `suara`:
  - Angkat, taruh, kembali ke baki, dan Kosongkan.
  - `wake`.
  - Fase jalan level 13 dan 15: urutan suara yang terdengar sama dengan `stepSound` dari frame solusinya.
  - Efek mati berarti tidak ada suara.
- `result_view_test.dart`: Berhasil 3 bintang berbunyi `star` ×3 lalu `coin`, Oyen bosan berbunyi `bored`, dan `disableAnimations` tidak berbunyi bintang.
- `coin_sheet_test.dart`: bonus dan iklan berhasil berbunyi `coin`, iklan gagal tidak.
- `settings_screen_test.dart`: sakelar Musik dan Efek suara mengubah `GameAudio` dan tersimpan, plus label pembaca layar.
- `test/widgets/ko_pressable_test.dart` (atau test yang sudah ada): tombol berbunyi `tap`; tombol nonaktif tidak.
- `test/app/audio_assets_test.dart` (`dart:io`): setiap `asset` ada di `assets/` dan terdaftar di pubspec; SFX ≤ 40 KB, musik ≤ 400 KB, total ≤ 1,2 MB.
- `overflow_test` sudah mencakup Pengaturan (bagian Suara baru) di keempat bahasa; ditambah `/galeri/suara`. Potret layar Pengaturan per bahasa dibuat ulang dan dicek.

## Dokumen

- `docs/DESIGN_NOTES.md` bagian "Langkah 16":
  - Sumber dan lisensi setiap berkas (nama paket Kenney + nama berkas asli, CC0; musik buatan sendiri lewat `tool/audio/make_music.py`).
  - Daftar momen suara dan yang sengaja senyap (jalan/putar/duduk, putar ulang, kurangi gerak).
  - Dua lagu dan pembagian rutenya.
  - Gaya sakelar Pengaturan.
- `CLAUDE.md` "Struktur": `sounds.dart`, `SoundPlayer`/`FakeSoundPlayer`, `GameAudio`/`AudioScope`, `SoundSettings`, kunci simpanan, `musicFor`, galeri suara, test baru, dan `tool/audio/`.
- `docs/ROADMAP.md`: centang 16 dan tulis ringkasan "Selesai".

## Verifikasi

- `/check` (format, `flutter analyze` = `No issues found!`, `flutter test` lulus, termasuk 20 solusi level).
- `flutter test test/screenshots --dart-define=SCREENSHOTS=true`, lalu lihat Pengaturan di keempat bahasa.
- Cek ukuran aset (test di atas) dan ukuran build: `flutter build apk --debug` berhasil.
- Kalau ada perangkat atau emulator, `flutter run --route /galeri/suara` dan Beranda → level untuk dengar musik, crossfade, dan jeda di latar belakang. Kalau tidak ada, catat di PR bahwa audisi di perangkat dilakukan pemilik repo.
- Review: `superpowers:requesting-code-review` (satu subagent, effort high), lalu `superpowers:receiving-code-review`, lalu `superpowers:verification-before-completion`.
- Akhir: centang roadmap, `git push -u origin feat/music-sound`, `gh pr create --base main` dengan judul "feat: Musik dan efek suara", badan berbahasa Indonesia tanpa atribusi Claude.
