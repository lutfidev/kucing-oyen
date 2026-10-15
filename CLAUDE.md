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
- `test/game/`: test simulasi, solver, loader, dan sesi level.

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
