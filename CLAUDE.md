# Kucing Oren

Game puzzle mobile (Flutter + Flame). Pemain menaruh benda (ikan, ember air, kardus) di papan 7x9, lalu Oyen si kucing oren bergerak sendiri mengikuti aturan tetap. Semua teks di dalam game memakai Bahasa Indonesia santai.

## Sumber kebenaran

- `docs/GDD.md`: dokumen desain game (aturan Oyen, elemen peta, alur level, bintang, 20 level).
- `docs/reference/oyen_simulator.py`: simulator + solver acuan. Logika simulasi Dart HARUS identik dengan file ini.
- `assets/levels/chapter1-2.json`: data 20 level (peta, baki, bintang 3, solusi, jumlah langkah solusi).
- `docs/design/`: ekspor desain UI dari Claude Design (warna, tipografi, layar). Baca `docs/design/source/` (hasil bongkar: 18 halaman, komponen `*.dc.html`, token warna di `13-design-token-komponen-ui.html`), bukan `Kucing Oren.html` yang berupa paket terkompresi 16 MB. Folder ini tidak ikut repo (`.gitignore`), hanya ada di komputer pemilik repo. Kalau tidak ada, beri tahu pemilik repo; jangan menebak isi desain.
- `docs/DESIGN_NOTES.md`: keputusan saat desain, GDD, dan data level tidak cocok (dibuat saat pertama dibutuhkan).

## Struktur

- `lib/game/sim/`: simulasi Dart murni. `simulate(board, placed)` → `SimResult` (`win`, `vaseBroken`, `steps`, `failReason`, `trace` berisi `SimStep` per langkah, `vaseBrokenAtStep`). `solve(board, inventory, {needSafe})` → `SolveResult` (`minItems`, `solutions`: semua susunan minimum tanpa duplikat) atau null. `Board.parse`, `Level`/`parseLevels`, `Cell`, `Direction`, `Item`/`Placement`, `Pos`. Impor lewat `sim/sim.dart`.
- `lib/game/model/level_session.dart`: `LevelSession(level)`, Dart murni. Fase `SessionPhase` (`arrange` → `running` → `result`). Aksi fase atur `place`/`move`/`remove` mengembalikan `false` kalau ditolak; `canPlaceAt(pos)` untuk petak menyala. `itemAt(pos)` hanya benda pemain (benda bawaan lewat `board.cellAt`), `placed`, `remaining` (sisa baki), `itemsUsed`. Pindah fase: `wake()` → `SimResult`, `finish()` ke layar hasil, `arrangeAgain()` (Atur Lagi/Coba Lagi, susunan tetap), `reset()` (Ulangi, papan kosong); pindah fase yang tidak sah melempar `StateError`. `stars` 0–3, null di fase atur.
- `lib/game/level_loader.dart`: `loadLevels()` membaca aset level lewat `rootBundle`.
- `lib/game/render/`: gambar petak, Oyen, dan papan sebagai fungsi `Canvas` (untuk `CustomPainter` maupun Flame), impor lewat `render/render.dart`. Data Dart murni: `Tile` (`TileKind`, `TileItem`, `alt`, `glow`; `Tile.size` 50), `OyenLook` (`OyenPose`, `Direction`, `OyenCostume`, `OyenBubble`, `label`), `BoardScene.fromMap(map, items, glow, broken, oyen, showOyen, facing)` (port `Board.dc.html`, 63 petak + `BoardOyen` berkolom/baris pecahan; `designMap`). Penggambar: `paintTile(canvas, tile, glowOpacity)`, `paintOyen(canvas, look, size)`, `paintBoardFrame`, `paintBoard(canvas, scene, glowOpacity)`, `tileGlowOpacity(detik)`, `BoardArt` (ukuran Oyen 62, geser (-6, -12)). Isi `<svg>` desain disalin utuh di `design_svg.dart` dan diurai `SvgTemplate`; jangan diketik ulang.
- `lib/theme/`: token desain sebagai `ThemeExtension` per grup: `KoColors`, `KoType` (display, title, heading, number, body, label, overline, plus gaya tombol/chip/badge), `KoSpace`, `KoRadius`, `KoShadow`, `KoSize`. `KoTheme.light()` memasang semuanya; widget membaca lewat `context.koColors`, `context.koType`, `context.koSpace`, `context.koRadius`, `context.koShadow`, `context.koSize`. Tidak ada warna atau ukuran hardcode di widget; tambah token kalau butuh nilai baru. Font Fredoka/Nunito dibundel di `assets/fonts/` (`KoFonts`).
- `lib/widgets/`: komponen dasar, impor lewat `widgets/widgets.dart`. `TileView`, `OyenView`, `BoardView` (`game_art.dart`, membungkus `lib/game/render/`), `KoButton` (`KoButtonKind` primary/success/secondary, `KoButtonSize` hero/large/medium), `KoIconButton` (`KoIconButtonTone`, opsional `label`), `KoPressable` (bayangan padat yang hilang saat ditekan), `KoChip` / `KoChip.dark`, `TraySlot` (slot baki + badge sisa), `KoCard` (`locked`, `elevated`), `KoStar`/`KoStars`, `KoIcon` + `KoIcons` (path SVG dari desain), `KoDashedBorder`.
- `lib/app/`: `KucingOrenApp` (`MaterialApp.router`), `createRouter()`, `AppRoutes` (`/` Beranda sementara, `/galeri`, `/galeri/papan`, `/galeri/oyen`). `lib/screens/<layar>/` untuk layar, `lib/gallery/` untuk galeri: token dan komponen (`gallery_screen.dart`), petak dan papan, sprite Oyen; kerangka bersama `GalleryPage`, `GallerySection`, `GalleryGrid`.
- `test/game/`: test simulasi, solver, loader, sesi level, dan gambar (`render/`: pemetaan peta, `SvgTemplate`, warna piksel di koordinat desain, dan `design_sync_test.dart` yang hanya jalan kalau `docs/design/` ada). `test/widgets/`, `test/theme/`: test komponen dan token.
- `test/screens/overflow_test.dart`: semua rute di 360×640 sampai 412×915, teks 100% dan 130%. Rute baru wajib ditambahkan ke daftar `routes`.
- `test/screenshots/`: potret layar, `flutter test test/screenshots --dart-define=SCREENSHOTS=true` → `build/screenshots/390x844/*.png` (dilewati di test biasa). `test/flutter_test_config.dart` memuat font asli untuk semua test. Helper test di `test/test_helpers.dart` (`pumpApp`, `pumpThemed`, `setScreenSize`, `setTextScale`). `rootBundle.loadString` menyimpan Future-nya di cache: kalau satu widget test mulai memuat aset (mis. `loadLevels()`) lalu selesai sebelum Future-nya beres, test berikutnya di file yang sama mendapat Future yang tidak pernah selesai, bahkan dengan `runAsync`. Tunggu sampai aset termuat di test itu, atau berikan data level langsung ke widget.

Setiap langkah roadmap memperbarui bagian ini kalau menambah folder atau API penting.

## Aturan penting

- Logika simulasi ditulis sebagai Dart murni di `lib/game/sim/`, tanpa import Flame atau Flutter, supaya bisa diuji dengan unit test.
- Urutan aturan per langkah: sampai mangkuk → duduk di kardus → jatuhkan barang di meja sebelah → kejar ikan terdekat yang terlihat → cek petak depan (air: putar balik, tembok/meja: berputar searah jarum jam, kardus: masuk duduk 2 langkah, ikan: makan, lantai/mangkuk: maju).
- Seri jarak ikan: depan → searah jarum jam → berlawanan jarum jam → belakang.
- Gagal: keadaan berulang (mondar-mandir) atau lewat 80 langkah. Vas pecah tidak menggagalkan level, hanya menghapus bintang 2 dan 3.
- Huruf peta: `#` tembok, `.` lantai, `T` mangkuk, `M` meja, `G` meja+gelas, `V` meja+vas, `F` ikan bawaan, `A` genangan air, `K` kardus bawaan, `^ > v <` Oyen (huruf kecil `v` = menghadap bawah).
- Teks aturan memakai "berputar searah jarum jam", bukan "belok kanan". Teks cerita/caption memakai arah layar (atas, bawah, kiri, kanan).

## Wajib sebelum selesai

- `flutter analyze` bersih (`No issues found!`).
- `flutter test` lulus, termasuk test yang menjalankan solusi ke-20 level dari `chapter1-2.json`: setiap solusi harus menang, vas tidak pecah, dan jumlah langkahnya sama dengan `solutionSteps`.
- Perintah `/check` (`.claude/commands/check.md`) menjalankan format, analyze, dan test sekaligus.

## Alur git per langkah roadmap

Pemilik repo biasanya `/clear` setelah tiap sesi, jadi aturan ini yang berlaku, bukan ingatan percakapan. Kerjakan sendiri tanpa bertanya dan tanpa menyuruh pemilik repo menjalankan perintah:

- **Awal langkah:** `git fetch`, pastikan tidak ada PR terbuka (`gh pr list --state open` kosong) dan PR langkah sebelumnya sudah di-merge ke `origin/main`, lalu `git checkout main && git pull --ff-only`, buat `feat/<nama-langkah>`, hapus branch lokal yang sudah di-merge, `flutter pub get && flutter analyze && flutter test`. Kalau masih ada PR yang belum di-merge, jangan bercabang dari `main` lama; beri tahu pemilik repo. (Langkah 1 masuk langsung ke `main` tanpa PR.)
- **Selama langkah:** commit kecil, pesan bahasa Inggris singkat (`feat(sim): ...`, `fix: ...`, `test: ...`, `docs: ...`).
- **Akhir langkah** (analyze bersih, test hijau, temuan review sudah diperbaiki, langkah sudah dicentang di `docs/ROADMAP.md`): `git push -u origin <branch>` lalu `gh pr create --base main` langsung, tanpa menu pilihan. Kirim link PR-nya. Judul PR `feat: <nama langkah>`. Badan PR berbahasa Indonesia: kalimat pembuka "Langkah N roadmap: ...", daftar perubahan, asumsi baru (kalau ada, juga dicatat di `docs/DESIGN_NOTES.md`), lalu baris "Verifikasi:" berisi hasil `flutter analyze`, jumlah test `flutter test` yang lulus, dan cek lain yang dijalankan.
- **Merge PR** dilakukan pemilik repo di GitHub; jangan merge sendiri kecuali diminta.
- **Atribusi:** commit dan PR atas nama akun git pemilik repo. Jangan tambahkan `Co-Authored-By: Claude`, "Generated with Claude Code", atau atribusi Claude lain di pesan commit maupun badan PR.
- Kesepakatan baru soal alur kerja langsung dicatat di file ini, jangan hanya diucapkan di chat.

## Lanjut ke mana

Lihat `docs/ROADMAP.md`: status tiap langkah dan prompt siap tempel. Langkah berikutnya = langkah pertama yang belum dicentang.
