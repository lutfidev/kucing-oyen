# Latar Area Bermain

10 November 2026. Dibuat dengan imagegen bawaan, referensi gaya latar Makan
`../dining/source/makan-painted-v1.png`. Tidak ada kucing, mainan, mangkuk,
barang interaktif atau UI di latar. Rak selimut, tanaman, jendela dan pintu
adalah arsitektur gratis; semua fasilitas permainan digambar live.

- Sumber: [main-painted-v1.png](source/main-painted-v1.png), 1254×1254.
- Runtime: `assets/art/v2/scenes/main-painted-v1.webp`, 1024×1024, 127,572 byte.
- Turunan: Pillow LANCZOS resize, RGB, WebP quality 88, method 6.
- SHA-256: `33b73c43ff19a337436e1c8f532feebda9ddc8f328639a9e00793e6ae58ecf40`.
- Hak keluaran mengikuti ketentuan layanan alat, dicatat pada lisensi paket.

Decode tetap 1024×1024 (4 MiB RGBA), cache bersama Flutter dan RepaintBoundary;
ketiga latar raster rumah memakai 12 MiB jika semuanya ada di cache. Ini bukan
pengukuran total memori aplikasi. PNG sumber hanya dokumentasi, tidak dibundel.
Fallback vektor tetap tersedia saat memuat/gagal. Inventaris vektor tetap 209.

## Prompt

Referensi: `docs/design-v2/dining/source/makan-painted-v1.png`.
`transparent_background=false`.

```text
Create a new square mobile game playroom BACKGROUND illustration matching the provided reference image's cozy hand-painted storybook art EXACTLY: rich honey caramel wood, cream ivory walls, rounded thick warm outlines, detailed painted highlights and folds, leafy green plants, blue sky through a window. This is the adjacent cat PLAYROOM of the same house. No cats, people, text, UI, balls, toys, bowls, scratching posts, tunnels, mats or interactive furniture: those are rendered dynamically by the game. Change the dining cabinet into a compact rounded wooden wall shelf with neatly stacked folded colorful blankets and a trailing plant in the upper LEFT, keep a lovely curtained window centered in the UPPER HALF, an open arched doorway on the RIGHT. Wall/floor junction at about 60 percent height. Lower 40 percent must be completely empty golden wooden floor, spacious for two dynamic cats and one toy; no objects blocking this floor. Very clean frontal game room composition, square 1024x1024, full bleed, no border. Retain cheerful blue and green accents, tactile illustrated wood grain and sunny contact shadows, no global yellow tint. This is finished raster background art, not a mockup.
```
