# Paket seni v2

Tambahan langkah 5: Santai pemain memakai latar ilustrasi raster versi tetap,
`scenes/santai-painted-v1.webp` (180.076 byte, decode 4 MiB), dibuat dengan
imagegen bawaan. Kucing dan barang dinamis tetap vektor. Sumber, prompt,
lisensi, batas cache serta fallback ada di
[catatan latar](../../../docs/design-v2/home/PAINTED_ASSET.md).
Uraian 209 SVG di bawah adalah inventaris vektor dan baseline langkah 2.

Sumber asli: [`tool/art_v2/generate.py`](../../../tool/art_v2/generate.py), Python standard library. Inventaris vektor tidak memakai aset unduhan, tracing raster, atlas, atau dependensi runtime baru. Referensi arah seni: konsep A dan `docs/design-v2/VISUAL.md`; bentuk vector digambar baru, bukan port bentuk v1. Ketentuan penggunaan di `LICENSE.txt`.

```sh
python tool/art_v2/generate.py
python tool/art_v2/generate.py --check
flutter run --route /galeri/aset-v2
flutter test test/game/render/v2_art_test.dart --dart-define=ART_REVIEW=true
flutter test test/game/render/v2_art_test.dart --plain-name "stress all" --dart-define=ART_MEASURE=true
python tool/art_v2/measure_apk.py build/app/outputs/flutter-apk/app-debug.apk
```

209 SVG transparan + manifest: 9 identitas (bagian badan/depan-belakang/ekor/telapak, 11 kepala arah×ekspresi), 16 aksesoris + 4 varian belakang, 21 barang×2 mask, 4 area×3 lapisan. ID/harga katalog dipertahankan. Bos tuxedo hitam-putih dengan blaze, Kembang tortoiseshell gelap; pola belakang Telon/Kembang tetap bercak, bukan tabby.

SVG menyimpan viewBox/dimensi/pivot; manifest menyimpan jangkar, titik interaksi barang, footY dan lapisan. Canvas kucing 128×128 termasuk margin topi; badan terlihat sekitar 72–104 unit. Pose tidur tetap dalam canvas, bukan crop. Potret memakai kepala utuh dengan telinga. Arah kanan mencerminkan bagian kiri beserta aksesoris; ekspresi depan/samping/belakang terpisah. Kacamata diproyeksikan ke mata samping; kalung, bandana, dasi dan kacamata memiliki seni belakang. Semua aksesoris mengikuti transformasi kepala/leher.

Rig `lib/game/render/v2/cat_rig.dart` dipakai bersama untuk integrasi rumah dan puzzle berikutnya: idle kedip/napas/ekor, jalan 8 fase/0,8 detik, duduk, tidur, makan, main, sikat, elus, senang, kaget, lesu; Oyen kardus/jatuhkan/kejar ikan/makan ikan/menang/bosan. Reaksi memakai empat fase. `time: null` menghasilkan gambar diam; pemanggil mengatur ticker/lifecycle. Jangan memberi cache berdasarkan waktu. Sprite tidak membawa teks UI.

Ruangan 390×390: wall (wallpaper+jendela/cahaya), floor, decor (furnitur latar noninteraktif). Furnitur dan kucing dinamis terpisah; `room_art.dart` hanya komposisi galeri, bukan penempatan/model rumah final. Urutan integrasi: wall → decor dinding → floor → karpet → item-back → kucing → item-front → efek. Pengurutan kaki Y dan aturan kapasitas diterapkan bersama model pada langkah 4–8. Hitbox/titik interaksi tidak menyatakan bahwa barang dekoratif otomatis memberikan hadiah.

Vector dipilih karena bagian bisa dibagi dan dianimasikan tanpa atlas/frame bitmap serta tetap tajam di petak puzzle. Hasil mempertahankan palet hangat, pipi bulat, kepala besar, kayu madu dan outline cokelat A; permukaan lebih rata dan tidak meniru grain cat air raster konsep. Review sheet adalah render kode sebenarnya, bukan konsep AI. Angka ukuran/memori dan batas pengujian tercatat di `docs/design-v2/assets/REVIEW.md`.

Satu `ArtPack` memiliki tepat 209 gambar statis; tidak membuat varian kombinasi/pose/waktu. Owner membuang pack saat scene tak diperlukan. Tidak ada preload semua layar aplikasi: langkah ini hanya memuat paket di galeri developer. Simpan pack bersama di lingkup scene saat integrasi, bukan satu pack per kucing. Anggaran sumber/kompresi ≤20 MB dan tekstur rumah ≤64 MiB; pada baseline vektor raster sumber 0 byte, tetapi Canvas, path, VM dan framebuffer tetap memakai memori. Profil HP/60fps bukan klaim langkah ini.

Ikon/splash/merek, glyph UI, papan puzzle, ilustrasi hasil dan tutorial mengikuti langkah 3 serta 10–14; belum mengganti materi produksi dengan aset konsep ini.
