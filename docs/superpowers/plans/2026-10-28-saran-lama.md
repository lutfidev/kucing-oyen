# Langkah 19: Saran Lama Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (CLAUDE.md: rencana dijalankan di sesi utama). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Membereskan saran "di luar lingkup" PR #5–#18 yang masih berlaku: aksesibilitas tanpa seret, tampilan judul level, kembali sistem, simpanan yang gagal, kinerja papan, dan suara.

**Architecture:** Perubahan kecil per area. Aturan main tetap di `LevelSession`; aksesibilitas papan berupa lapisan `Semantics` 7×9 di atas `GameWidget` yang dibangun `LevelView`. Simpanan `ProgressController` lewat satu antrean tulis berurutan yang menelan error, mencatat bagian yang belum tersimpan, dan mencobanya lagi.

**Tech Stack:** Flutter 3.47, Flame, `audioplayers` 6.8.1, `flutter_test` (`takeAnnouncements`, `SemanticsTester` via `tester.getSemantics`).

**Spec:** prompt langkah 19 di `docs/ROADMAP.md`. Pemilik repo meminta "langsung kerjakan, pakai pilihanmu", jadi semua pilihan di bawah adalah keputusan Claude dan dicatat di `docs/DESIGN_NOTES.md` bagian "Langkah 19".

## Global Constraints

- Teks pemain baru ada di keempat ARB (`app_en.arb` dengan deskripsi, lalu `id`, `pt`, `ru`), nada santai; `flutter gen-l10n` sesudahnya.
- Tidak ada warna/ukuran hardcode di widget; pakai token `context.ko*`.
- Model Dart murni tidak mengimpor Flutter.
- `flutter analyze` bersih, `flutter test` hijau (termasuk `overflow_test`).

## Review Focus

- Benda dipilih lewat pembaca layar lalu pemain menyeret benda lain dengan jari: pilihan harus batal, tidak menaruh dua benda. (Task 7, test `seret membatalkan pilihan`.)
- Simpanan gagal lalu berhasil lagi: bagian yang tertunda ikut tertulis dengan nilai terbaru, bukan nilai lama. (Task 5, test `menulis ulang yang tertunda`.)
- Kembali sistem saat putar ulang terbuka tetap menutup putar ulang saja, bukan ke fase atur. (Task 4.)
- Sakelar efek dimatikan lalu dinyalakan cepat: tidak ada bunyi saat mati. (Task 6.)
- Pilihan benda terakhir di baki (sisa 1) lalu ditaruh: slot jadi 0 dan tidak bisa dipilih lagi. (Task 7.)

---

### Task 1: Judul level rata kiri

**Files:** Modify `lib/screens/level/level_bar.dart`; Test `test/screens/level_view_test.dart`.

- [ ] Test `judul level rata kiri`: kiri `Text` judul = kanan tombol kembali + `space.s10` (±0,5) di 390×844, level 13.
- [ ] Jalankan, gagal (judul di tengah).
- [ ] `FittedBox(alignment: AlignmentDirectional.centerStart)`.
- [ ] Jalankan, lulus; commit `fix(level): left-align the level title like designs 03 and 04`.

### Task 2: Chip Langkah tidak diumumkan tiap langkah

**Files:** Modify `lib/screens/level/run_panel.dart` (`StepCounter({required int step, bool announce = true})` → `liveRegion: announce`), `lib/screens/level/level_view.dart` (`announce: !run.clock.playing`); Test `test/screens/level_view_test.dart` grup `fase jalan`.

- [ ] Test: saat berputar node `Langkah N` tidak punya flag `isLiveRegion`; sesudah Jeda punya; sesudah selesai punya.
- [ ] Gagal, implementasi, lulus, commit `fix(a11y): announce the step chip only when paused or done`.

### Task 3: Tag bahasa di baris pilihan bahasa

**Files:** Modify `lib/screens/settings/settings_parts.dart` (`_LanguageRow` dapat `Locale? locale`; label lewat `attributedLabel: AttributedString(name, attributes: [LocaleStringAttribute(range: TextRange(start: 0, end: name.length), locale: locale)])`); locale = `Locale(language.name)` untuk bahasa selain `system`. Test `test/screens/settings_screen_test.dart`.

- [ ] Test: node `language-ru` punya `attributedLabel` dengan `LocaleStringAttribute` locale `ru`; `language-system` tanpa atribut.
- [ ] Gagal, implementasi, lulus, commit `fix(a11y): tag language names with their locale for screen readers`.

### Task 4: Kembali sistem di fase jalan dan layar hasil

Keputusan: kembali sistem di fase jalan **dan** layar hasil = kembali ke fase atur dengan susunan tetap (sama dengan tombol kembali fase jalan dan "Atur Lagi"); putar ulang terbuka = tutup putar ulang saja (tetap). Dari fase atur, kembali sistem keluar ke peta.

**Files:** Modify `lib/screens/level/level_view.dart` (`PopScope(canPop: phase == arrange && !_replaying)`, `onPopInvokedWithResult`: replaying → `_closeReplay`, selain itu `_arrangeAgain`). Test `test/screens/level_view_test.dart` grup baru `kembali sistem` (pakai `tester.binding.handlePopRoute()` lewat `pumpApp` di rute level).

- [ ] Test: fase jalan → kembali sistem → tombol "Bangunkan Oyen" tampil dan benda tetap di papan; layar hasil (Berhasil dan Oyen bosan) → kembali sistem → fase atur; fase atur → kembali sistem → peta babak; putar ulang → kembali sistem → layar hasil.
- [ ] Gagal, implementasi, lulus, commit `fix(level): system back returns to arranging from the run and result screens`.

### Task 5: Simpanan yang gagal dan urutan tulis

Keputusan: tanpa pesan ke pemain (tidak ada desainnya). Keadaan di memori tetap; bagian yang gagal ditandai belum tersimpan dan ditulis ulang di simpan berikutnya dan saat aplikasi ke latar belakang. Tulisan berurutan; urutan memihak pemain: koin dulu baru progres (`record`), petunjuk dulu baru koin (`unlockHint`), koin dulu baru hadiah harian (bonus dan iklan), kostum dulu baru koin (tetap). Kegagalan menghentikan sisa urutan (sisanya ikut ditandai), supaya tidak ada tulisan "merugikan" yang lolos sendirian.

**Files:** Modify `lib/app/progress_scope.dart`, `lib/app/game_audio.dart` (`_setSettings` menelan error simpan), `lib/app/app.dart` (`AppLifecycleListener.onPause`/`onHide` → `progress.retrySaves()`). Test `test/app/progress_test.dart` grup baru `simpanan gagal`, dengan `FailingProgressStore extends MemoryProgressStore` (field `failing` = set nama kunci yang melempar, `writes` = urutan kunci yang ditulis) di `test/test_helpers.dart`.

**Interfaces (Produces):**
- `enum _Part { progress, tutorials, coins, hints, wardrobe, rewards, language }` (privat).
- `Future<void> _save(List<_Part> parts)`: antre di belakang tulisan sebelumnya; tulis bagian tertunda + `parts` (urut `parts` dulu), tiap bagian membaca nilai terbaru saat ditulis; tidak pernah melempar.
- `bool get hasUnsavedChanges`, `Future<void> retrySaves()`.

- [ ] Test `urutan tulis memihak pemain`: `record` menulis `coins` sebelum `progress`; `unlockHint` koin menulis `hints` sebelum `coins`; `claimDailyBonus` dan `watchAdForCoins` menulis `coins` sebelum `rewards`.
- [ ] Test `simpan gagal tidak melempar`: `failing = {'coins'}`; `record` selesai tanpa error, bintang dan koin di memori baru, `hasUnsavedChanges` true, `progress` tidak ditulis.
- [ ] Test `menulis ulang yang tertunda`: lanjut dari atas, `failing = {}`, `setLanguage(ru)` → store berisi koin dan progres terbaru, `hasUnsavedChanges` false.
- [ ] Test `retrySaves`: gagal lalu `retrySaves()` menulis semuanya.
- [ ] Test `GameAudio` di `test/app/game_audio_test.dart`: `saveSound` melempar → `setEffectsOn(false)` selesai tanpa error dan `effectsOn` false.
- [ ] Test `app` di `test/app/app_audio_test.dart` (atau `progress_test`): `AppLifecycleState.paused` memanggil `retrySaves` (store gagal dulu, lalu pulih, lalu lifecycle paused → tersimpan).
- [ ] Gagal, implementasi, lulus, commit `fix(progress): survive failed saves and write in a player-friendly order`.

### Task 6: Suara

**Files:** Modify `lib/screens/settings/settings_parts.dart` (`_SwitchRow`: aksi dulu, lalu `GameSound.tap`), `lib/widgets/ko_pressable.dart` (`bool silent = false`: tanpa `tapSound`), `lib/widgets/ko_button.dart`, `lib/widgets/ko_icon_button.dart`, `lib/widgets/ko_sheet.dart` (`SheetButton`) meneruskan `silent`; `silent: true` di tombol Bangunkan Oyen, Kosongkan papan (`tray.dart`), bonus harian (`coin_sheet.dart`). `lib/app/sound_player.dart`: `Future<void> preload()` di `SoundPlayer` (Fake: catat `preloaded = true`; asli: buat semua pool `GameSound.values`); `GameAudio.load` memanggil `unawaited(player.preload())`. Tests: `settings_screen_test` grup suara, `level_view_test` grup suara, `coin_sheet_test`, `sound_player_test`/`game_audio_test`.

- [ ] Test sakelar: efek dimatikan → tidak ada `tap`; dinyalakan → satu `tap`.
- [ ] Test tumpuk: Bangunkan Oyen → `played` berisi `wake` tanpa `tap`; Kosongkan → `back` tanpa `tap`; bonus → `coin` tanpa `tap`. Tombol biasa (Aturan) tetap `tap`.
- [ ] Test preload: `GameAudio.load` → `FakeSoundPlayer.preloaded` true.
- [ ] Gagal, implementasi, lulus, commit `fix(audio): flip the effects switch sound, drop stacked taps, warm up pools`.

### Task 7: Menaruh benda tanpa seret (pembaca layar)

Keputusan desain:
- Slot baki: aksi ketuk semantik = pilih benda itu (ketuk lagi = batal). Label `traySlotSelected` saat dipilih, `selected: true`. Slot sisa 0 tanpa aksi.
- Papan di fase atur: lapisan semantik 63 petak (urut baris), tiap petak berlabel "Baris R, kolom C: <isi>". Isi: benda pemain (`itemName`), sel bawaan (nama sel), Oyen ("Oyen tidur, menghadap <arah layar>"). Fase jalan dan hasil: tetap satu gambar `boardLabel`.
- Ada benda dipilih dan petak `canPlaceAt`: ketuk = taruh/pindah (`onTapHint` "taruh <benda> di sini"). Petak berisi benda pemain: ketuk = pilih untuk dipindah; aksi kustom "Kembalikan ke baki" = `remove`.
- Selama ada pilihan, semua petak `canPlaceAt` menyala (bantuan penglihatan sebagian). Pilihan batal saat seret dimulai, Bangunkan, Kosongkan, atau sesudah taruh/pindah/ambil.
- Pengumuman (`SemanticsService.sendAnnouncement`): dipilih ("Ikan dipilih. Pilih petak kosong untuk menaruhnya."), ditaruh/dipindah ("Ikan ditaruh di baris R, kolom C."), dikembalikan ("Ikan kembali ke baki.").
- Suara sama dengan seret: pilih = `pickUp`, taruh = `place`, kembali = `back`. Tutorial benda selesai saat benda yang disorot dipilih.

**Files:** Create `lib/screens/level/board_semantics.dart` (`BoardTileSemantics` data: `label`, `VoidCallback? onTap`, `String? onTapHint`, `VoidCallback? onRemove`, `bool selected`; widget `BoardSemantics(tiles: List<BoardTileSemantics>)` grid 7×9 tanpa hit test). Modify `level_board.dart` (`LevelBoard({game, List<BoardTileSemantics>? tiles})`: null = satu gambar), `tray.dart` (`TrayPanel.selected`, `onSelect(Item)`; `TraySlot` dapat `onTap`/`selected` semantik), `lib/widgets/tray_slot.dart`, `level_view.dart` (`_selected` = `({Item item, Pos? from})?`), `lib/l10n/names.dart` (`cellName(l, cell)`), ARB ×4. Tests `test/screens/level_view_test.dart` grup `tanpa seret`, `test/l10n/names_test.dart`.

ARB (id): `traySlotSelected` "{name} dipilih, sisa {n}", `traySlotSelectHint` "memilih benda", `traySlotUnselectHint` "batal memilih", `tileLabel` "Baris {row}, kolom {col}: {content}", `cellWall` "tembok", `cellFloor` "lantai", `cellBowl` "mangkuk Oyen", `cellTable` "meja", `cellTableGlass` "meja dengan gelas", `cellTableVase` "meja dengan vas", `cellFish` "ikan", `cellWater` "genangan air", `cellBox` "kardus", `tileOyen` "Oyen tidur, menghadap {dir, select, …}", `tilePlaceHint` "taruh {item} di sini", `tilePickHint` "memindah {item}", `tileRemove` "Kembalikan ke baki", `itemSelectedAnnounce` "{item} dipilih. Pilih petak kosong untuk menaruhnya.", `itemPlacedAnnounce` "{item} ditaruh di baris {row}, kolom {col}.", `itemReturnedAnnounce` "{item} kembali ke baki.".

- [ ] Test `label petak`: level 13 fase atur, node "Baris 1, kolom 1: tembok" ada; node Oyen sesuai arah awal; 63 node petak.
- [ ] Test `pilih lalu taruh`: aksi tap semantik di slot ikan → slot `selected`, pengumuman dipilih; aksi tap di petak kosong yang boleh → `session.itemAt` (lewat label petak "ikan") dan sisa slot berkurang, pengumuman ditaruh, suara `pickUp` lalu `place`.
- [ ] Test `pindah dan kembalikan`: tap petak berisi ikan → dipilih; tap petak lain → pindah; aksi kustom "Kembalikan ke baki" → kembali, sisa bertambah.
- [ ] Test `seret membatalkan pilihan`: pilih lewat semantik, seret ember ke petak → hanya ember yang tertaruh.
- [ ] Test `sisa 0`: slot dengan sisa 0 tidak punya aksi tap.
- [ ] Test `fase jalan`: papan kembali satu node `boardLabel`.
- [ ] Test `names_test`: `cellName` keempat bahasa tidak kosong untuk semua `Cell`.
- [ ] Gagal, implementasi + ARB + `flutter gen-l10n`, lulus; `overflow_test` tetap hijau; commit `feat(a11y): place, move, and return items without dragging`.

### Task 8: Kinerja papan, catatan, dan penutup

Keputusan: tidak ada cache `Picture`. Diukur 28 Okt 2026 (`flutter test`, desktop, JIT): merekam papan level 13 + Oyen ≈ 0,24 ms per bingkai dengan 3 petak menyala (0,39 ms kalau 63 petak menyala). Mesin Flame hanya jalan selama ada kedip atau Oyen bergeser. Saran: profil di HP murah sebelum mengoptimasi.

- [ ] `docs/DESIGN_NOTES.md` bagian "Langkah 19": semua keputusan Task 2–8.
- [ ] `docs/ROADMAP.md`: centang 19, tambah ringkasan "Selesai".
- [ ] `CLAUDE.md` Struktur: `board_semantics.dart`, `LevelBoard.tiles`, `TrayPanel.selected/onSelect`, `KoPressable.silent`, `SoundPlayer.preload`, `ProgressController.hasUnsavedChanges/retrySaves`, `FailingProgressStore`, `StepCounter.announce`.
- [ ] `/check`, commit `docs: step 19 notes, roadmap, and structure`.
