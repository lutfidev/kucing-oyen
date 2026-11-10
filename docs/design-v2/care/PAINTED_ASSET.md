# Latar Area Perawatan

10 November 2026. Dibuat dengan imagegen bawaan memakai latar Bermain
sebagai referensi gaya. Handuk/rak, tanaman, jendela, panel dinding hijau
dan pintu adalah arsitektur gratis. Tidak ada kucing, alas, sikat atau UI
tertanam di gambar; perlengkapan interaktif digambar oleh runtime.

- Sumber: [rawat-painted-v1.png](source/rawat-painted-v1.png), 1254×1254.
- Runtime: `assets/art/v2/scenes/rawat-painted-v1.webp`, 1024×1024,
  127.354 byte.
- SHA-256: `3a121ccc649b5217c4b521f8aaf3930a1cd235045e10bff5b2f87714e2076129`.
- Turunan: Pillow, RGB, LANCZOS resize, WebP quality 88, method 6.
- Hak keluaran mengikuti ketentuan layanan alat; lihat lisensi paket aset.
- Decode tetap 1024×1024 (4 MiB RGBA), memakai cache bersama Flutter.
  Empat latar rumah membutuhkan 16 MiB jika seluruhnya berada dalam cache;
  ini anggaran decode, bukan pengukuran total memori aplikasi.
- PNG sumber hanya dokumentasi dan tidak dibundel dalam APK.

## Prompt lengkap

Referensi gaya: `docs/design-v2/play/source/main-painted-v1.png`.
`transparent_background=false`, built-in tool, tanpa CLI/API key.

```text
Use case: illustration-story. Create a NEW square mobile game cat grooming room BACKGROUND using the reference image only for the exact cozy hand-painted storybook style: honey caramel wood, ivory walls, rounded warm outlines, detailed painted highlights, sunny blue and green accents. An adjacent room in the same house. Upper left a compact wall cabinet with neatly folded pale blue towels and a leafy plant, upper center a rounded small window with cream curtains, right an open arched doorway. Distinguish the composition from the playroom with a pale sage green wall wainscot and a towel rail on the upper left. Wall-floor junction at 60% height. Lower 40% completely EMPTY warm wooden floor for two dynamically rendered cats and a grooming mat. No cats, people, hands, brushes, grooming tools, mats, baths, sinks, bowls, toys, text, UI, logos or borders. All interactive objects will be drawn live by the game. Frontal full bleed square 1024x1024 finished raster background art, no global yellow tint.
```
