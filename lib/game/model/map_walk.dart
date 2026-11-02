/// Linimasa Oyen berjalan di peta sesudah "Lanjut" (langkah 25): jeda
/// sebentar, jalan menyusuri jalur, diam sebentar, lalu level berikutnya
/// dibuka sendiri, kecuali dibatalkan atau [autoOpen] mati. Dart murni;
/// layar memajukannya lewat [tick].
class MapWalk {
  MapWalk({required this.autoOpen, required this.still});

  /// Jeda sebelum jalan supaya pemain sempat melihat peta (detik).
  static const double delay = 0.3;

  /// Lama jalan dari node ke node berikutnya.
  static const double walkTime = 1.0;

  /// Diam di node tujuan sebelum level dibuka.
  static const double rest = 0.25;

  /// Kurangi gerak: Oyen langsung di tujuan, level dibuka sesudah ini.
  static const double stillWait = 0.6;

  /// Level tujuan dibuka sendiri (mati saat pembaca layar aktif).
  final bool autoOpen;

  /// Kurangi gerak: tanpa jalan.
  final bool still;

  double _time = 0;
  bool _cancelled = false;
  bool _opened = false;

  double get _arriveAt => still ? 0 : delay + walkTime;
  double get _openAt => still ? stillWait : delay + walkTime + rest;

  /// Majukan waktu [seconds].
  void tick(double seconds) => _time += seconds;

  /// Letak di segmen 0–1 sesudah kurva `easeInOut`.
  double get t {
    if (still) return 1;
    final x = ((_time - delay) / walkTime).clamp(0.0, 1.0);
    return _easeInOut(x);
  }

  /// Sedang melangkah (pose jalan).
  bool get walking => !still && _time > delay && _time < _arriveAt;

  /// Sudah di node tujuan.
  bool get arrived => _time >= _arriveAt;

  /// Pembukaan otomatis dibatalkan (ketukan atau kembali).
  bool get cancelled => _cancelled;

  void cancel() => _cancelled = true;

  /// True tepat sekali, saat level tujuan harus dibuka.
  bool takeOpen() {
    if (_opened || _cancelled || !autoOpen || _time < _openAt) return false;
    _opened = true;
    return true;
  }

  /// Tidak ada lagi yang berubah: layar boleh berhenti memajukan waktu.
  bool get done =>
      arrived && (_opened || _cancelled || !autoOpen || _time >= _openAt);

  /// `Curves.easeInOut` = `Cubic(0.42, 0, 0.58, 1)`, disalin supaya model
  /// tetap tanpa Flutter.
  static double _easeInOut(double x) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    const a = 0.42, b = 0.0, c = 0.58, d = 1.0;
    double curve(double p, double q, double m) =>
        3 * p * (1 - m) * (1 - m) * m + 3 * q * (1 - m) * m * m + m * m * m;
    var start = 0.0, end = 1.0;
    while (true) {
      final mid = (start + end) / 2;
      final estimate = curve(a, c, mid);
      if ((x - estimate).abs() < 0.0001) return curve(b, d, mid);
      if (estimate < x) {
        start = mid;
      } else {
        end = mid;
      }
    }
  }
}
