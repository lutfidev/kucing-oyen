/// Jam fase jalan: langkah yang sedang tampil, jeda, dan ×2. Dart murni;
/// waktu dimajukan pemanggil lewat [tick].
///
/// Langkah 1 langsung tampil saat Oyen dibangunkan, lalu satu langkah tiap
/// [interval] sampai langkah terakhir ([done]).
class RunClock {
  RunClock(this.steps) : _step = steps < 1 ? steps : 1;

  /// 4 langkah per detik (GDD "Alur satu level").
  static const stepTime = Duration(milliseconds: 250);

  /// Jumlah langkah yang diputar.
  final int steps;

  int _step;
  bool _paused = false;
  bool _fast = false;
  Duration _elapsed = Duration.zero;

  /// Langkah yang sedang tampil.
  int get step => _step;

  /// Langkah terakhir sudah tampil.
  bool get done => _step >= steps;

  /// Tidak dijeda dan belum selesai.
  bool get playing => !_paused && !done;

  /// Percepat ×2.
  bool get fast => _fast;

  /// Lama satu langkah: [stepTime], atau setengahnya saat [fast].
  Duration get interval => _fast ? stepTime ~/ 2 : stepTime;

  /// Memajukan waktu sebanyak [elapsed]. True kalau langkahnya berganti.
  bool tick(Duration elapsed) {
    if (!playing) return false;
    final before = _step;
    _elapsed += elapsed;
    while (_elapsed >= interval && !done) {
      _elapsed -= interval;
      _step++;
    }
    if (done) _elapsed = Duration.zero;
    return _step != before;
  }

  /// Jeda atau Lanjutkan.
  void togglePause() => _paused = !_paused;

  /// ×2 nyala/mati. Bagian langkah yang sudah lewat tetap sama.
  void toggleFast() {
    _fast = !_fast;
    _elapsed = _fast ? _elapsed ~/ 2 : _elapsed * 2;
  }

  /// "Maju satu langkah": jeda, lalu tampilkan langkah berikutnya.
  void stepOnce() {
    _paused = true;
    if (done) return;
    _step++;
    _elapsed = Duration.zero;
  }

  /// Langsung ke langkah terakhir (tanpa animasi).
  void skipToEnd() {
    _step = steps;
    _elapsed = Duration.zero;
  }
}
