import '../sim/sim.dart';
import 'progress.dart';

/// Nama latar tiap babak (GDD). Data level hanya menyimpan nomor babak.
const chapterNames = {1: 'Dapur', 2: 'Ruang Tamu'};

/// Satu babak: latar dan level-levelnya, urut main. Level terakhir adalah
/// bos.
class Chapter {
  Chapter({required this.number, required this.name, required this.levels})
    : assert(levels.isNotEmpty);

  /// Awalan nama level bos di data level ("BOS: Hari Lebaran").
  static const bossPrefix = 'BOS: ';

  final int number;
  final String name;
  final List<Level> levels;

  /// "Babak 1 – Dapur".
  String get title => 'Babak $number – $name';

  Level get boss => levels.last;

  /// Nama bos tanpa awalan: "Hari Lebaran".
  String get bossName => boss.name.startsWith(bossPrefix)
      ? boss.name.substring(bossPrefix.length)
      : boss.name;

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
      Chapter(
        number: number,
        name: chapterNames[number] ?? 'Babak $number',
        levels: List.unmodifiable(grouped[number]!),
      ),
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
