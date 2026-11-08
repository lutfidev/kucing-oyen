"""Generate offline, low-fidelity design documentation. No runtime game assets."""
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# title, content blocks, actions, diagram kind
SCREENS = [
    ('Makan', ['Oyen · jatah tersedia', 'Satu mangkuk · satu posisi tunggu', 'Salju menunggu · urutan 1'], ['Ajak makan', 'Lihat antrean'], 'room'),
    ('Makan · cooldown', ['Oyen sudah makan dari isi ini', 'Makanan berikutnya 02:15', 'Kucing lain masih bisa makan jika punya jatah'], ['Kembali', 'Camilan'], 'room'),
    ('Koleksi', ['Oyen · Santai · Tidur | Temukan', 'Salju · Perawatan · Disikat | Temukan', 'Mendung · Menuju Bermain | Temukan'], ['Tutup', 'Adopsi di Toko'], 'list'),
    ('Kartu Oyen', ['Santai · Duduk', 'Makanan 80/100', 'Senang 70/100', 'Ajakan akan dijalankan setelah kegiatan aktif selesai'], ['Ajak makan', 'Ajak main', 'Rawat', 'Camilan', 'Aksesoris'], 'portrait'),
    ('Ajakan tertunda', ['Oyen · Santai', 'Menunggu Makan · urutan 2', 'Tempat sedang dipakai. Oyen menunggu di area asal.'], ['Lihat area', 'Batalkan ajakan'], 'room'),
    ('Camilan', ['Oyen · Makanan 80/100', 'Stok camilan milik pemain', 'Efek dan jumlah memakai katalog v1', 'Stok habis: Beri nonaktif'], ['Beri', 'Ke Toko', 'Tutup'], 'portrait'),
    ('Aksesoris', ['Oyen · pratinjau', 'Dasi kupu · sedang dipakai', 'Pita · dimiliki', 'Satu aksesoris per kucing'], ['Pakai', 'Lepas', 'Ke Toko'], 'portrait'),
    ('Hias', ['Area Santai · rutinitas dijeda', 'Barang lantai 4/4 · dinding 2/3', 'Sofa mini dipilih · slot valid', 'Jalur pintu tidak boleh tertutup'], ['Simpan tata letak', 'Gudang', 'Pindah area', 'Batal'], 'room'),
    ('Gudang', ['Barang aman, tidak perlu dibeli lagi', 'Kasur · Santai / Perawatan', 'Kardus · Santai / Perawatan', 'Area penuh: pilih slot atau simpan kembali'], ['Letakkan', 'Kembali menghias'], 'list'),
    ('Buang perubahan?', ['Tata letak belum disimpan', 'Simpan sebelum keluar atau buang draf', 'Kepemilikan barang tidak berubah'], ['Simpan', 'Buang', 'Lanjut menghias'], 'sheet'),
    ('Hadiah rumah', ['Oyen +10', 'Salju +10', 'Mendung +10', 'Total 30 koin · cek ulang saat klaim'], ['Ambil semua', 'Tutup'], 'sheet'),
    ('Hadiah · kosong', ['Belum ada hadiah', 'Kucing dengan Makanan dan Senang minimal 70 bisa memberi hadiah sekali sehari', 'Tidak perlu mengambil tindakan sekarang'], ['Tutup'], 'sheet'),
    ('Pengenalan rumah', ['Empat area untuk teman-temanmu', 'Kucing bisa bergerak sendiri atau kamu ajak', 'Barang lama yang belum muat aman di Gudang', 'Puzzle bisa langsung dimainkan'], ['Lihat rumah', 'Lewati'], 'room'),
    ('Adopsi', ['Salju · 300 koin', 'Akan tinggal di area yang punya tempat', 'Kucing dimiliki: tampilkan Milikmu', 'Saldo kurang: tombol beli nonaktif'], ['Adopsi', 'Batal'], 'portrait'),
    ('Beli', ['Kasur · 200 koin', 'Saldo 800 → 600', 'Tujuan Santai penuh · masuk Gudang', 'Pratinjau dan harga harus terlihat sebelum konfirmasi'], ['Beli 200', 'Batal'], 'sheet'),
    ('Babak2', ['Ruang Tamu · 0/30 bintang', 'Level 11–20 · node sesuai progres', 'Terkunci: jelaskan syarat dari progres v1'], ['Pilih level', 'Dapur'], 'map'),
    ('Babak baru', ['Ruang Tamu terbuka!', 'Ilustrasi babak baru', 'Ketuk ganda tidak membuka level dua kali'], ['Lanjut'], 'sheet'),
    ('Jalan', ['Level 13 · Langkah 4', 'Pose, peristiwa, arah mengikuti simulator', 'Kardus / vas / ikan ditampilkan pada petak data'], ['Jeda', 'Kecepatan ×2', 'Kembali mengatur'], 'board'),
    ('Tutorial', ['Sorot baki atau petak yang relevan', 'Satu pesan pendek setiap tahap', 'Letakkan ikan untuk mengarahkan Oyen'], ['Berikutnya', 'Lewati'], 'board'),
    ('Aturan', ['Sampai mangkuk → menang', 'Kardus → duduk 2 langkah', 'Barang meja → jatuhkan', 'Ikan terlihat → kejar', 'Air → putar balik; tembok → searah jarum jam', 'Hanya tampilkan aturan yang sudah dikenalkan'], ['Tutup'], 'sheet'),
    ('Petunjuk', ['Tingkat 1 · petak pertama · terbuka', 'Tingkat 2 · jenis benda · biaya dari model', 'Tingkat 3 · solusi · buka tingkat sebelumnya dulu', 'Iklan memuat / gagal / habis punya status sendiri'], ['Pakai koin', 'Tonton iklan', 'Tutup'], 'sheet'),
    ('Hasil', ['Oyen kenyang!', 'Varian 1 / 2 / 3 bintang', 'Langkah, benda, dan hadiah dihitung dari sesi', 'Hadiah hanya untuk peningkatan bintang'], ['Lanjut', 'Coba lagi', 'Putar ulang'], 'portrait'),
    ('Vas', ['Sampai mangkuk · 1 bintang', 'Vas Ibu pecah', 'Kamu tetap bisa lanjut; coba lagi untuk vas aman'], ['Lanjut', 'Coba lagi', 'Putar ulang'], 'portrait'),
    ('Bosan', ['Oyen bosan…', 'Alasan: keadaan berulang / batas langkah', 'Susunan benda tetap tersimpan'], ['Coba lagi', 'Putar ulang'], 'portrait'),
    ('Privasi', ['Kebijakan privasi', 'Pengaturan persetujuan bila tersedia', 'Jika link gagal: tampilkan pesan dan coba lagi'], ['Buka kebijakan', 'Kembali'], 'sheet'),
    ('Tentang', ['Ginger Logic', 'Versi dari build aplikasi', 'Kredit font, suara, aset dan lisensi', 'Konten panjang dapat digulir'], ['Lisensi', 'Kembali'], 'sheet'),
    ('Reset', ['Reset progres?', 'Bintang, koin, kucing, barang dan simpanan rumah akan kembali ke awal', 'Pembatalan tidak mengubah data'], ['Batal', 'Reset progres'], 'sheet'),
    ('Koin', ['Saldo 80', 'Bonus harian +20 · Ambil / sudah diambil', 'Iklan pilihan +20 · sisa kuota dari model', 'Tidak ada pembelian uang asli'], ['Ambil bonus', 'Tonton iklan', 'Tutup'], 'sheet'),
    ('Koin · gagal', ['Iklan belum tersedia', 'Koin tidak berubah', 'Bisa coba lagi nanti atau tutup sheet'], ['Coba lagi', 'Tutup'], 'sheet'),
    ('Galeri', ['Token, tombol, chip, kartu dan sheet', 'Papan / Oyen / Kucing / Gerak / Suara', 'Normal · tekan · nonaktif · loading · error', 'Semua pose / arah / jangkar aksesoris'], ['Buka contoh', 'Kembali'], 'list'),
    ('Memuat', ['Menyiapkan rumah…', 'Latar cream dan indikator tenang', 'Kontrol transaksi belum tersedia'], [], 'loading'),
    ('Gagal', ['Belum tersimpan', 'Saldo dan kepemilikan sebelumnya tetap berlaku', 'Coba ulang transaksi yang sama, jangan gandakan efek'], ['Coba lagi', 'Batal'], 'sheet'),
    ('Tidak ditemukan', ['Babak atau level tidak ditemukan', 'ID cocok pola rute, tetapi data tidak tersedia', 'Gunakan tombol kembali sesuai konteks; jangan mengubah progres'], ['Kembali ke peta', 'Ke rumah'], 'sheet'),
]

CSS = '''
*{box-sizing:border-box}body{margin:24px;background:#fff4e2;color:#573018;font:16px/1.4 system-ui,sans-serif}h1{font-size:28px}p{max-width:900px}.grid{display:grid;grid-template-columns:repeat(auto-fit,390px);gap:24px;align-items:start}article{width:390px;height:844px;border:2px solid #79543a;border-radius:24px;background:#fffaf0;display:flex;flex-direction:column;overflow:hidden}header{padding:16px;border-bottom:2px solid #ffd8ac;min-height:64px;font-size:20px;font-weight:700}main{padding:16px;overflow:auto;flex:1}.block{padding:12px;margin:0 0 12px;border:1px solid #c7aa82;border-radius:16px;background:#fff4e2;overflow-wrap:anywhere}.diagram{height:200px;background:#ffe6c8;border:2px dashed #b28c62;border-radius:16px;margin:0 0 16px;display:flex;align-items:center;justify-content:center;text-align:center;padding:16px;color:#79543a}.board{height:330px;display:grid;grid-template-columns:repeat(7,1fr);grid-template-rows:repeat(9,1fr);padding:0;gap:1px;background:#b28c62}.tile{background:#fff4e2;display:flex;align-items:center;justify-content:center;font-size:12px}.wall{background:#e9ae60}footer{padding:12px 16px;border-top:2px solid #ffd8ac;display:flex;gap:8px;flex-wrap:wrap}.action{background:#ffd8ac;color:#573018;border:1px solid #79543a;border-radius:16px;min-height:48px;padding:12px;flex:1 1 42%;text-align:center;font-weight:700}.action:first-child{background:#ff8208}.meta{font-size:12px;color:#79543a;padding:4px 16px}nav{display:flex;flex-wrap:wrap;gap:12px;margin:24px 0}a{color:#573018}@media print{article{break-inside:avoid}nav{display:none}}
'''


def diagram(kind):
    if kind == 'board':
        cells = []
        for row in range(9):
            for col in range(7):
                wall = row in (0, 8) or col in (0, 6)
                label = {(2, 2): 'Oyen →', (3, 4): 'Vas', (6, 4): 'Mangkuk'}.get((row, col), '')
                cells.append(f'<div class="tile {"wall" if wall else ""}">{label}</div>')
        return '<div class="diagram board" aria-label="Diagram 7 kolom 9 baris, bukan data level">' + ''.join(cells) + '</div>'
    labels = {'room': 'RUANGAN · LANTAI LEGA<br>slot kucing / fasilitas / pintu', 'portrait': 'POTRET / ILUSTRASI<br>karakter baru mengikuti A', 'map': 'PETA ILUSTRASI<br>11 — 12 — … — 20', 'loading': '● ● ●'}
    return f'<div class="diagram">{labels[kind]}</div>' if kind in labels else ''


def generate():
    out = ROOT / 'wireframes'
    out.mkdir(exist_ok=True)
    cards = []
    nav = []
    for index, (title, blocks, actions, kind) in enumerate(SCREENS, 1):
        nav.append(f'<a href="#wf{index}">{escape(title)}</a>')
        content = ''.join(f'<div class="block">{escape(block)}</div>' for block in blocks)
        controls = ''.join(f'<div class="action">{escape(action)}</div>' for action in actions)
        cards.append(f'<article id="wf{index}"><header>← {escape(title)}</header><div class="meta">WF {index:02} · DRAF · 390 × 844</div><main>{diagram(kind)}{content}</main><footer>{controls}</footer></article>')
    html = '<!doctype html><html lang="id"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Wireframe v2 — draf</title><style>' + CSS + '</style><h1>Ginger Logic · wireframe v2</h1><p>Diagram struktur, bukan aplikasi interaktif atau seni final. Kotak tindakan sengaja statis. Baca SPEC untuk aturan. Masing-masing bingkai berukuran 390×844 dp logis. Varian kecil dan terjemahan diuji saat implementasi.</p><nav>' + ''.join(nav) + '</nav><div class="grid">' + ''.join(cards) + '</div></html>'
    (out / 'index.html').write_text(html, encoding='utf-8')
    print(f'Generated {len(cards)} wireframes: {out / "index.html"}')


if __name__ == '__main__':
    generate()
