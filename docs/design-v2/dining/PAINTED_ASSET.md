# Latar Area Makan

9 November 2026. Imagegen bawaan, referensi gambar Santai yang sudah disetujui:
`../home/source/santai-painted-v1.png`. Hasil adalah ilustrasi baru area Makan.
Tidak ada kucing, mangkuk, pakan atau barang interaktif di latar.
Lemari, jendela, toples dekoratif dan tanaman adalah arsitektur gratis.

- Sumber: [makan-painted-v1.png](source/makan-painted-v1.png), 1254×1254.
- Runtime: `assets/art/v2/scenes/makan-painted-v1.webp`, 1024×1024, 110.624 byte.
- Turunan: Pillow resize 1024×1024 (BICUBIC default), WebP quality 85, method 6.
- SHA-256: `0b0016c4277bfbfd9512ad7e8589a2d6e21d1292fdaf6cb18a85955d72595f4b`.
- Hak keluaran mengikuti ketentuan layanan alat; kredit di `assets/art/v2/LICENSE.txt`.

`PaintedScenery.dining` memakai decode 1024×1024 tetap (4 MiB RGBA), cache
Flutter bersama dan RepaintBoundary. Dua latar rumah berarti 8 MiB bitmap latar
jika keduanya berada di cache, bukan ukuran total proses. Kegagalan/muat awal
tetap menampilkan latar vektor. PNG sumber tidak dibundel. Mangkuk, keadaan
penuh/kosong, kucing, aksesoris, barang dan hitbox digambar live.

## Prompt

Input gambar: `docs/design-v2/home/source/santai-painted-v1.png`.
`transparent_background=false`.

```text
Create a square game room background for the DINING AREA adjacent to the provided approved lounge image. Match exactly its cozy hand-painted children's game art, warm honey/caramel wood, ivory peach walls, rounded detailed furniture, rich blue and green accents, textured paper, soft directional sunlight. Front-facing room with floor taking bottom 42 percent, wall top 58 percent. A small honey wood kitchen cabinet at far left upper/middle, shelves with colorful ceramic jars and small potted herb; central small blue-sky window with ivory short curtains, a tiny fish-shaped wall ornament. Rounded arch doorway at right matching reference around x=340/390 y=210/390. Very important: entire bottom 42 percent of image is EMPTY warm wooden floor, absolutely no rug, no food bowls, no food, no cats, no characters, no text, no UI. The interactive bowl and cats will be drawn by game code on this clear floor. Keep cabinets off the foreground, not blocking the empty floor. Deliver an original standalone room illustration only, no border.
```
