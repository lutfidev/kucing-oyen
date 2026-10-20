# Kebijakan privasi: cara unggah

`index.html` adalah kebijakan privasi Ginger Logic dalam empat bahasa (bagian `#en`, `#id`, `#pt`, `#ru`), satu halaman statis tanpa skrip atau berkas luar.

1. Di repo GitHub Pages `yoluvy.my.id`, salin berkas ini ke `ginger-logic/privacy/index.html`.
2. Commit dan push, tunggu GitHub Pages selesai membangun.
3. Buka https://yoluvy.my.id/ginger-logic/privacy/ dan pastikan halamannya tampil (juga https://yoluvy.my.id/ginger-logic/privacy/#ru).
4. Tempel URL yang sama di Play Console → Kebijakan dan program → Konten aplikasi → Kebijakan privasi.

URL ini juga dibuka tombol "Kebijakan privasi" di Pengaturan game (`privacyPolicyUrl` di `lib/app/privacy.dart`). Kalau jalurnya diganti, ganti juga konstanta itu.

Kalau isi kebijakan berubah (mis. menambah SDK baru), perbarui tanggal berlaku di bagian atas dan di keempat bagian bahasa.
