import '../sim/sim.dart';

/// Fase satu level.
enum SessionPhase {
  /// Oyen tidur; pemain menaruh, memindah, dan mengembalikan benda.
  arrange,

  /// Oyen bangun dan berjalan mengikuti [LevelSession.result].
  running,

  /// Layar hasil: berhasil, vas pecah, atau Oyen bosan.
  result,
}

/// Keadaan satu level yang sedang dimainkan, tanpa tampilan.
///
/// Benda pemain disimpan terpisah dari benda bawaan peta ([Board.cellAt]),
/// karena keduanya digambar berbeda.
class LevelSession {
  LevelSession(this.level);

  final Level level;

  Board get board => level.board;

  SessionPhase _phase = SessionPhase.arrange;
  final _placed = <Pos, Item>{};
  SimResult? _result;

  SessionPhase get phase => _phase;

  /// Benda yang ditaruh pemain, urut saat ditaruh atau dipindah.
  List<Placement> get placed => List.unmodifiable([
    for (final e in _placed.entries) Placement(e.value, e.key),
  ]);

  /// Benda pemain di [pos], atau null. Benda bawaan peta tidak termasuk.
  Item? itemAt(Pos pos) => _placed[pos];

  /// Jumlah benda pemain di papan.
  int get itemsUsed => _placed.length;

  /// Sisa baki: isi baki level dikurangi benda di papan. Benda yang sudah
  /// habis tetap ada dengan angka 0.
  Map<Item, int> get remaining => Map.unmodifiable({
    for (final e in level.inventory.entries)
      e.key: e.value - _placed.values.where((item) => item == e.key).length,
  });

  /// Petak yang boleh diisi benda sekarang: fase atur, lantai kosong (bukan
  /// petak Oyen atau benda bawaan), dan belum ada benda pemain.
  bool canPlaceAt(Pos pos) =>
      _phase == SessionPhase.arrange &&
      board.canPlace(pos) &&
      !_placed.containsKey(pos);

  /// Menaruh [item] dari baki di [pos]. False kalau ditolak: petak tidak
  /// boleh diisi ([canPlaceAt]) atau sisa [item] di baki sudah 0.
  bool place(Item item, Pos pos) {
    if (!canPlaceAt(pos) || (remaining[item] ?? 0) == 0) return false;
    _placed[pos] = item;
    return true;
  }

  /// Memindah benda pemain dari [from] ke [to]. False kalau ditolak: tidak
  /// ada benda pemain di [from] atau [to] tidak boleh diisi ([canPlaceAt]).
  bool move(Pos from, Pos to) {
    final item = _placed[from];
    if (item == null || !canPlaceAt(to)) return false;
    _placed.remove(from);
    _placed[to] = item;
    return true;
  }

  /// Mengembalikan benda pemain di [pos] ke baki. False kalau ditolak: di
  /// luar fase atur atau tidak ada benda pemain di [pos].
  bool remove(Pos pos) =>
      _phase == SessionPhase.arrange && _placed.remove(pos) != null;

  /// Hasil simulasi sejak [wake]; null di fase atur.
  SimResult? get result => _result;

  /// Bintang dari [result]: 0 gagal, 1 menang, 2 menang dan vas aman, 3 kalau
  /// juga [itemsUsed] paling banyak `level.starItems`. Null di fase atur.
  int? get stars {
    final result = _result;
    if (result == null) return null;
    if (!result.win) return 0;
    if (result.vaseBroken) return 1;
    return itemsUsed <= level.starItems ? 3 : 2;
  }

  /// "Bangunkan Oyen": menjalankan simulasi dengan benda pemain, lalu masuk
  /// fase jalan. Hanya dari fase atur.
  SimResult wake() {
    _expectPhase(const {SessionPhase.arrange}, 'wake');
    final result = simulate(board, placed);
    _result = result;
    _phase = SessionPhase.running;
    return result;
  }

  /// Fase jalan selesai: masuk layar hasil.
  void finish() {
    _expectPhase(const {SessionPhase.running}, 'finish');
    _phase = SessionPhase.result;
  }

  /// "Atur Lagi" atau "Coba Lagi": kembali ke fase atur dengan susunan benda
  /// tetap.
  void arrangeAgain() {
    _expectPhase(const {
      SessionPhase.running,
      SessionPhase.result,
    }, 'arrangeAgain');
    _result = null;
    _phase = SessionPhase.arrange;
  }

  /// "Ulangi": kembali ke fase atur dengan papan kosong, dari fase mana pun.
  void reset() {
    _placed.clear();
    _result = null;
    _phase = SessionPhase.arrange;
  }

  void _expectPhase(Set<SessionPhase> allowed, String action) {
    if (!allowed.contains(_phase)) {
      throw StateError('$action() tidak bisa di fase ${_phase.name}');
    }
  }
}
