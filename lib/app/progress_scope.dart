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
    Set<int> tutorialsDone = const {},
  }) : levels = List.unmodifiable(levels),
       _tutorialsDone = Set.unmodifiable(tutorialsDone),
       chapters = List.unmodifiable(chaptersOf(levels));

  /// Memuat progres dan tutorial yang sudah selesai dari [store].
  static Future<ProgressController> load({
    required List<Level> levels,
    required ProgressStore store,
  }) async => ProgressController(
    levels: levels,
    store: store,
    progress: await store.load(),
    tutorialsDone: await store.loadTutorials(),
  );

  final List<Level> levels;
  final List<Chapter> chapters;
  final ProgressStore store;

  Progress _progress;
  Progress get progress => _progress;

  Set<int> _tutorialsDone;

  /// Id level yang tutorialnya sudah selesai (dikerjakan atau dilewati).
  Set<int> get tutorialsDone => _tutorialsDone;

  bool isTutorialDone(int id) => _tutorialsDone.contains(id);

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

  /// Menandai tutorial level [id] selesai supaya tidak muncul lagi.
  Future<void> finishTutorial(int id) async {
    if (isTutorialDone(id)) return;
    _tutorialsDone = Set.unmodifiable({..._tutorialsDone, id});
    notifyListeners();
    await store.saveTutorials(_tutorialsDone);
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
