import '../sim/sim.dart';
import 'progress.dart';

/// Satu babak: nomor dan level-levelnya, urut main. Level terakhir adalah
/// bos. Nama latarnya per bahasa (`chapterName`).
class Chapter {
  Chapter({required this.number, required this.levels})
    : assert(levels.isNotEmpty);

  /// Awalan nama level bos di data level ("BOS: Hari Lebaran").
  static const bossPrefix = 'BOS: ';

  final int number;
  final List<Level> levels;

  Level get boss => levels.last;

  Iterable<int> get ids => levels.map((level) => level.id);

  int get maxStars => levels.length * Progress.maxStars;

  /// Babak terbuka kalau level pertamanya terbuka.
  bool isUnlocked(Progress progress) => progress.isUnlocked(levels.first.id);

  /// Semua level sudah menang.
  bool isDone(Progress progress) => ids.every(progress.isWon);

  int stars(Progress progress) => progress.starsIn(ids);
}

/// Mengelompokkan [levels] per babak, urut nomor babak lalu urutan level.
List<Chapter> chaptersOf(List<Level> levels) {
  final grouped = <int, List<Level>>{};
  for (final level in levels) {
    grouped.putIfAbsent(level.chapter, () => []).add(level);
  }
  final numbers = grouped.keys.toList()..sort();
  return [
    for (final number in numbers)
      Chapter(number: number, levels: List.unmodifiable(grouped[number]!)),
  ];
}

/// Babak yang dibuka tombol Main: babak level yang dimainkan berikutnya,
/// atau babak terakhir kalau semua level sudah menang.
Chapter chapterToPlay(List<Chapter> chapters, Progress progress) {
  for (final chapter in chapters) {
    if (!chapter.isDone(progress)) return chapter;
  }
  return chapters.last;
}

Chapter? chapterNumbered(List<Chapter> chapters, int number) {
  for (final chapter in chapters) {
    if (chapter.number == number) return chapter;
  }
  return null;
}

Chapter? chapterOfLevel(List<Chapter> chapters, int levelId) {
  for (final chapter in chapters) {
    if (chapter.ids.contains(levelId)) return chapter;
  }
  return null;
}
