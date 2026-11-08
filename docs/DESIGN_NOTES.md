# Keputusan desain aktif Ginger Logic

Dimulai ulang pada **8 November 2026** bersama roadmap baru. Catatan langkah lama tersedia di riwayat Git dan bukan spesifikasi visual aktif.

## Keputusan pemilik repo

- Seluruh visual diubah, termasuk bentuk kucing, mengikuti konsep A pada [preview Rumah Oyen](design-brief/rumah-oyen-area/preview-perbandingan.png), sisi kiri.
- Satu area per layar; kucing beraktivitas otomatis dan bisa diajak pemain.
- Desain, screenshot, brief dan rencana visual lama dibersihkan. Roadmap mulai langkah 1; release tetap menjadi tahap akhir setelah semuanya siap.
- Tahap sekarang adalah penyusunan ulang rencana, belum implementasi seluruh tampilan baru.

## Fondasi proyek saat reset

- Flutter + Flame, Android portrait, `com.gingerlogic.app`, versi saat reset `1.0.0+1`.
- Simulator/solver, 20 level, progres, transaksi koin, koleksi, penyimpanan, iklan dan suara sudah berjalan; desain baru dibangun di atas fondasi tersebut.
- Empat bahasa: Inggris utama, Indonesia, Portugis Brasil, Rusia. Teks baru masuk keempat ARB dan review terjemahan diperbarui bila perlu.
- Kucing koleksi berada di rumah. Aturan puzzle tetap mengacu GDD dan data level; perombakan visual tidak otomatis mengubah aturan.
- Simpanan lama harus dimigrasikan saat rumah menjadi beberapa area. Penomoran ulang roadmap tidak mereset progres pemain.
- Aset/kode runtime lama diganti bertahap ketika penggantinya siap. Gambar dokumentasi lama dibuang agar tidak menjadi acuan yang keliru.

## Keputusan terbuka untuk langkah 1

Rincian empat area, kapasitas kucing, perpindahan/antrean, prioritas ajakan, pembatalan, hadiah, hias per area, dan pengenalan fitur. Mandi, kebutuhan kebersihan, hadiah gabungan serta batas 3–4 kucing per layar belum merupakan aturan final.

Target visual, aset/animasi dan seluruh keadaan layar dijabarkan dalam spesifikasi baru sebelum implementasi. Jangan menyalin ukuran dari HTML desain lama yang sudah dihapus.

## Data teknis dan release yang dipertahankan

- [Baseline performa kamar lama](performance-room-2026-11-08.md): 9 kucing, 21 barang termasuk mangkuk; sebelum/sesudah optimasi SVG, bingkai di atas 16,67 ms turun dari 14,3% menjadi 2,61%. Ini bukan kelulusan tampilan baru.
- Cache SVG animasi dibatasi 96 varian dan dijaga test kesamaan gambar. Pipeline aset baru perlu diukur lagi.
- HP uji Xiaomi 24117RN76O, Android 16/API 36. Manual debug/release sebelumnya dilaporkan baik; TalkBack dilewati atas permintaan pemilik repo. Desain baru perlu diuji ulang seluruhnya.
- Masih perlu disiapkan/dicek saat rilis: AdMob asli, keystore, kebijakan privasi, UMP, iklan petunjuk, ikon tema, perangkat/Android lain, terjemahan, formulir dan listing Play Console.
- Dokumen rilis dan kebijakan privasi dipertahankan. Jawaban kebijakan diverifikasi terhadap fitur serta ketentuan terbaru pada saat rilis.
