# Kucing Oren

Game puzzle mobile (Flutter + Flame). Pemain menaruh benda (ikan, ember air, kardus) di papan 7x9, lalu Oyen si kucing oren bergerak sendiri mengikuti aturan tetap. Semua teks di dalam game memakai Bahasa Indonesia santai.

## Sumber kebenaran

- `docs/GDD.md`: dokumen desain game (aturan Oyen, elemen peta, alur level, bintang, 20 level).
- `docs/reference/oyen_simulator.py`: simulator + solver acuan. Logika simulasi Dart HARUS identik dengan file ini.
- `assets/levels/chapter1-2.json`: data 20 level (peta, baki, bintang 3, solusi, jumlah langkah solusi).
- `docs/design/`: ekspor desain UI dari Claude Design (warna, tipografi, layar). Baca `docs/design/source/` (hasil bongkar: 18 halaman, komponen `*.dc.html`, token warna di `13-design-token-komponen-ui.html`), bukan `Kucing Oren.html` yang berupa paket terkompresi 16 MB.

## Aturan penting

- Logika simulasi ditulis sebagai Dart murni di `lib/game/sim/`, tanpa import Flame atau Flutter, supaya bisa diuji dengan unit test.
- Urutan aturan per langkah: sampai mangkuk → duduk di kardus → jatuhkan barang di meja sebelah → kejar ikan terdekat yang terlihat → cek petak depan (air: putar balik, tembok/meja: berputar searah jarum jam, kardus: masuk duduk 2 langkah, ikan: makan, lantai/mangkuk: maju).
- Seri jarak ikan: depan → searah jarum jam → berlawanan jarum jam → belakang.
- Gagal: keadaan berulang (mondar-mandir) atau lewat 80 langkah. Vas pecah tidak menggagalkan level, hanya menghapus bintang 2 dan 3.
- Huruf peta: `#` tembok, `.` lantai, `T` mangkuk, `M` meja, `G` meja+gelas, `V` meja+vas, `F` ikan bawaan, `A` genangan air, `K` kardus bawaan, `^ > v <` Oyen (huruf kecil `v` = menghadap bawah).
- Teks aturan memakai "berputar searah jarum jam", bukan "belok kanan". Teks cerita/caption memakai arah layar (atas, bawah, kiri, kanan).

## Wajib sebelum selesai

- `flutter test` lulus, termasuk test yang menjalankan solusi ke-20 level dari `chapter1-2.json`: setiap solusi harus menang, vas tidak pecah, dan jumlah langkahnya sama dengan `solutionSteps`.
