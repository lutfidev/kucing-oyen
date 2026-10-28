import '../game/model/chapter.dart';
import '../game/render/oyen.dart';
import '../game/sim/sim.dart';
import 'app_localizations.dart';

/// Nama level tanpa awalan bos, dari id level; null kalau belum ada
/// terjemahannya.
String? _baseName(AppLocalizations l, int id) => switch (id) {
  1 => l.level1Name,
  2 => l.level2Name,
  3 => l.level3Name,
  4 => l.level4Name,
  5 => l.level5Name,
  6 => l.level6Name,
  7 => l.level7Name,
  8 => l.level8Name,
  9 => l.level9Name,
  10 => l.level10Name,
  11 => l.level11Name,
  12 => l.level12Name,
  13 => l.level13Name,
  14 => l.level14Name,
  15 => l.level15Name,
  16 => l.level16Name,
  17 => l.level17Name,
  18 => l.level18Name,
  19 => l.level19Name,
  20 => l.level20Name,
  _ => null,
};

/// Level bos ditandai awalan "BOS: " di data level.
bool _isBoss(Level level) => level.name.startsWith(Chapter.bossPrefix);

/// Nama level dalam bahasa [l] ("Vas Ibu", "BOS: Hari Lebaran"). Level yang
/// belum diterjemahkan memakai nama di data level.
String levelName(AppLocalizations l, Level level) {
  final base = _baseName(l, level.id);
  if (base == null) return level.name;
  return _isBoss(level) ? l.bossLevelName(base) : base;
}

/// "Level 13 · Vas Ibu".
String levelTitle(AppLocalizations l, Level level) =>
    l.levelTitle(level.id, levelName(l, level));

/// Nama bos babak tanpa awalan: "Hari Lebaran".
String bossName(AppLocalizations l, Chapter chapter) {
  final boss = chapter.boss;
  return _baseName(l, boss.id) ??
      (_isBoss(boss)
          ? boss.name.substring(Chapter.bossPrefix.length)
          : boss.name);
}

/// Nama latar babak ("Dapur"); babak tanpa nama memakai "Babak N".
String chapterName(AppLocalizations l, Chapter chapter) =>
    switch (chapter.number) {
      1 => l.chapter1Name,
      2 => l.chapter2Name,
      final n => l.chapterNumber(n),
    };

/// "Babak 1 – Dapur".
String chapterTitle(AppLocalizations l, Chapter chapter) =>
    l.chapterTitle(chapter.number, chapterName(l, chapter));

/// Nama benda di baki ("Ikan asin").
String itemName(AppLocalizations l, Item item) => switch (item) {
  Item.fish => l.itemFish,
  Item.water => l.itemWater,
  Item.box => l.itemBox,
};

/// Isi petak peta untuk pembaca layar ("meja dengan vas").
String cellName(AppLocalizations l, Cell cell) => switch (cell) {
  Cell.wall => l.cellWall,
  Cell.floor => l.cellFloor,
  Cell.bowl => l.cellBowl,
  Cell.table => l.cellTable,
  Cell.tableGlass => l.cellTableGlass,
  Cell.tableVase => l.cellTableVase,
  Cell.fish => l.cellFish,
  Cell.water => l.cellWater,
  Cell.box => l.cellBox,
};

/// Nama kostum di Lemari Kostum.
String costumeName(AppLocalizations l, OyenCostume costume) =>
    switch (costume) {
      OyenCostume.none => l.costumeNone,
      OyenCostume.peci => l.costumePeci,
      OyenCostume.sarung => l.costumeSarung,
      OyenCostume.koki => l.costumeKoki,
      OyenCostume.kacamata => l.costumeKacamata,
    };

/// Label pembaca layar Oyen ("Oyen tidur, menghadap kiri"), sama dengan
/// `aria-label` di desain.
String oyenLabel(AppLocalizations l, OyenLook look) =>
    l.oyenLabel(look.pose.name, look.dir.name);
