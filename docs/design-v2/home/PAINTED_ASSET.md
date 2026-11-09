# Latar Santai berilustrasi

9 November 2026. Permintaan pemilik repo: warna dan kekayaan ilustrasi
mendekati papan mockup, bukan pergeseran palet krem saja.

## Berkas dan asal

- Metode: **imagegen bawaan**, penyuntingan berdasarkan referensi proyek.
- Acuan seni: [mockup empat area](../mockups/01-empat-area.png), panel Santai kiri atas.
- Acuan posisi: [runtime sebelum ilustrasi](santai-sebelum-ilustrasi-id.png).
- [Keluaran sumber PNG](source/santai-painted-v1.png): 1254×1254, 2.323.309 byte.
- [Aset runtime WebP](../../../assets/art/v2/scenes/santai-painted-v1.webp):
  1024×1024, 180.076 byte. Turunan memakai Pillow Lanczos dan WebP quality 90,
  method 6; tidak ada perubahan isi gambar setelah generasi.
- Hak keluaran mengikuti ketentuan layanan alat. Kredit ada di
  `assets/art/v2/LICENSE.txt`; tidak menyatakan lisensi stok/clip-art pihak ketiga.

Gambar sumber dipindahkan ke workspace dari keluaran imagegen. Runtime hanya
membundel WebP; PNG sumber di dokumentasi tidak dimasukkan ke APK.
WebP diperlakukan sebagai binary di `.gitattributes` agar normalisasi LF
untuk SVG tidak merusak bitstream pada checkout Windows. SHA-256 runtime:
`e55847d1d17421ba75d02e7e2bd272b3c0634bce86f4ab1445a8f678dabcb109`.

## Kontrak integrasi

Latar hanya memuat arsitektur, tanaman/buku dekoratif dan karpet struktural.
Hasil diperiksa: tidak ada kucing, teks UI, mangkuk makanan, bola, tempat tidur,
atau barang interaktif yang dipanggang ke gambar. Kucing, barang katalog,
aksesoris, pilihan, kontrol dan pergerakan tetap mengikuti model secara live.
Karpet latar bersifat struktural gratis seperti implementasi sebelumnya.

`PaintedScenery.lounge` menggunakan satu provider versi tetap dengan decode
1024×1024: 4.194.304 byte RGBA (4 MiB), dibagi melalui cache gambar Flutter
yang bounded. Ukuran decode tidak bertambah menurut waktu/pose/rasio piksel.
Latar berada di RepaintBoundary. Tidak membuat atlas atau frame cache baru.
Ini ukuran bitmap yang didekode, bukan klaim seluruh proses hanya memakai 4 MiB.

Sambil memuat atau saat gambar gagal, latar vektor tetap tampil. Barang dan
kucing tidak digandakan ketika fallback digantikan gambar. Area Makan/Main/
Rawat masih menggunakan lapisan vektor sampai penyelesaian area masing-masing.

Pembaruan langkah 6: Makan kini memakai [latar ilustrasi tersendiri](../dining/PAINTED_ASSET.md).
Main/Rawat tetap vektor sampai tahap masing-masing.

Test memeriksa gambar benar-benar terdecode, dimensi/memori terikat, cache
digunakan kembali setelah pindah area, dan kucing tetap dapat diketuk ketika
gambar gagal. Pemeriksaan APK memastikan WebP benar-benar dibundel. Profil
frame/memori total pada HP tetap diperlukan pada langkah performa.

## Prompt final

Input 1: `docs/design-v2/mockups/01-empat-area.png` (target/acuan gaya).
Input 2: runtime yang disimpan sebagai `santai-sebelum-ilustrasi-id.png`
(acuan geometri). `transparent_background=false`.

```text
Use case: precise-object-edit / production game background.
Image 1 is the owner-approved art reference; extract and repaint ONLY the architecture of the TOP LEFT 'Santai' room as one standalone richly illustrated game background. Image 2 is a geometry reference for the already functional game; preserve its broad placement and keep the lower foreground open for separately rendered cats. This is NOT a UI mockup.
Output one SQUARE 1024x1024 edge-to-edge room illustration, no border, no panels, NO TEXT OR UI. Match Image 1's expressive hand-painted storybook game-art finish, warm dimensional rounded brown outlines, luminous soft shading, lively varied colors, subtle paper/gouache texture. It must feel substantially richer and more colorful than Image 2's simple flat vector art. Colors: golden orange honey wood, creamy ivory curtains, vivid clear sky blue, fresh leafy green plants, coral/teal/ochre/green book spines. Keep distinct colors and bright ivory highlights; do NOT apply a uniform yellow, beige, sepia, or brown filter.
Composition in percentages of square canvas: front-facing cozy wall occupies upper 63%; central wooden window around x32-69%, y12-52%, blue sky/clouds and green outdoor bushes, cream curtains tied with warm coral-orange bands. Small book shelf and a trailing leafy plant along the upper left x3-27%, y26-43%. Low built-in open book cabinet x3-28%, y49-66%, colorful books and woven drawer. A small framed paw illustration near x79-94%, y19-32%. An arched open doorway at x79-100%, y41-65%, soft depth into an empty adjoining room with NO FOOD BOWL or furniture. Warm orange wood plank floor from y63% to bottom, perspective and soft directional window light with gentle brown contact shadows. A fluffy cream scalloped oval structural rug centered at x50%, y83%, width83%, height25%, empty and textured for cats to stand on. A small cluster of green leaves may enter at the very bottom left edge without covering the central floor.
Remove ALL cats, animals, food bowls, balls, loose toys, beds, scratch posts, interactive furniture, UI, buttons, letters, numbers, headings, tab bars, labels, outer frame, watermarks. The wall paw picture is decorative. No baked character shadows. All actual cats, purchased furniture and controls will be drawn live by code over this image. Keep safe usable blank foreground across the rug; do not add extra props there.
```
