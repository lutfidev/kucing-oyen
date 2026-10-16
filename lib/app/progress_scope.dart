import 'package:flutter/widgets.dart';

import '../game/model/chapter.dart';
import '../game/model/progress.dart';
import '../game/sim/sim.dart';
import 'progress_store.dart';

/// Data level dan progres pemain untuk semua layar. Dimuat sekali sebelum
/// aplikasi jalan (`main`), lalu dibagikan lewat [ProgressScope].
class ProgressController extends ChangeNotifier {
  ProgressController({
    required List<Level> levels,
    required this.store,
    this._progress = Progress.empty,
  }) : levels = List.unmodifiable(levels),
       chapters = List.unmodifiable(chaptersOf(levels));

  /// Memuat progres dari [store].
  static Future<ProgressController> load({
    required List<Level> levels,
    required ProgressStore store,
  }) async => ProgressController(
    levels: levels,
    store: store,
    progress: await store.load(),
  );

  final List<Level> levels;
  final List<Chapter> chapters;
  final ProgressStore store;

  Progress _progress;
  Progress get progress => _progress;

  Level? levelById(int id) {
    for (final level in levels) {
      if (level.id == id) return level;
    }
    return null;
  }

  Chapter? chapter(int number) => chapterNumbered(chapters, number);

  /// Babak yang dibuka tombol Main.
  Chapter get currentChapter => chapterToPlay(chapters, _progress);

  /// Bintang paling banyak semua level ("31/60").
  int get maxStars => levels.length * Progress.maxStars;

  /// Mencatat hasil level [id] lalu menyimpannya kalau lebih baik. Gagal
  /// (0 bintang) tidak dicatat.
  Future<void> record(int id, int stars) async {
    final next = _progress.record(id, stars);
    if (identical(next, _progress)) return;
    _progress = next;
    notifyListeners();
    await store.save(next);
  }
}

/// Membagikan [ProgressController] ke bawah; widget yang membacanya lewat
/// [of] dibangun ulang saat progres berubah.
class ProgressScope extends InheritedNotifier<ProgressController> {
  const ProgressScope({
    super.key,
    required ProgressController progress,
    required super.child,
  }) : super(notifier: progress);

  static ProgressController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope tidak ada di atas $context');
    return scope!.notifier!;
  }

  /// Seperti [of], tanpa dibangun ulang saat progres berubah (untuk aksi
  /// dan data level yang tetap).
  static ProgressController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope tidak ada di atas $context');
    return scope!.notifier!;
  }
}
