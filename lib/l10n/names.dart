import '../game/model/accessories.dart';
import '../game/model/chapter.dart';
import '../game/model/home_items.dart';
import '../game/model/kitties.dart';
import '../game/model/snacks.dart';
import '../game/render/kitty.dart';
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

/// Nama barang kamar di Toko dan kamar.
String roomItemName(AppLocalizations l, RoomItemId id) => switch (id) {
  RoomItemId.tikus => l.roomItemTikus,
  RoomItemId.akuarium => l.roomItemAkuarium,
  RoomItemId.rumah => l.roomItemRumah,
  RoomItemId.kasur => l.roomItemKasur,
  RoomItemId.catnip => l.roomItemCatnip,
  RoomItemId.jam => l.roomItemJam,
  RoomItemId.kardus => l.roomItemKardus,
  RoomItemId.bola => l.roomItemBola,
  RoomItemId.karpet => l.roomItemKarpet,
  RoomItemId.tiang => l.roomItemTiang,
  RoomItemId.lukisan => l.roomItemLukisan,
  RoomItemId.rak => l.roomItemRak,
  RoomItemId.pancingan => l.roomItemPancingan,
  RoomItemId.lampuBulan => l.roomItemLampuBulan,
  RoomItemId.bantalIkan => l.roomItemBantalIkan,
  RoomItemId.monstera => l.roomItemMonstera,
  RoomItemId.terowongan => l.roomItemTerowongan,
  RoomItemId.hammock => l.roomItemHammock,
  RoomItemId.sofaMini => l.roomItemSofaMini,
  RoomItemId.jendelaBurung => l.roomItemJendelaBurung,
  RoomItemId.mangkuk => l.roomItemMangkuk,
};

/// Deskripsi jenaka barang di kartu dan sheet Toko. Mangkuk bawaan tidak
/// dijual, jadi memakai deskripsi kardus? Tidak: mangkuk tidak punya
/// deskripsi di desain dan tidak pernah tampil di Toko.
String roomItemDesc(AppLocalizations l, RoomItemId id) => switch (id) {
  RoomItemId.tikus => l.roomItemTikusDesc,
  RoomItemId.akuarium => l.roomItemAkuariumDesc,
  RoomItemId.rumah => l.roomItemRumahDesc,
  RoomItemId.kasur => l.roomItemKasurDesc,
  RoomItemId.catnip => l.roomItemCatnipDesc,
  RoomItemId.jam => l.roomItemJamDesc,
  RoomItemId.kardus => l.roomItemKardusDesc,
  RoomItemId.bola => l.roomItemBolaDesc,
  RoomItemId.karpet => l.roomItemKarpetDesc,
  RoomItemId.tiang => l.roomItemTiangDesc,
  RoomItemId.lukisan => l.roomItemLukisanDesc,
  RoomItemId.rak => l.roomItemRakDesc,
  RoomItemId.pancingan => l.roomItemPancinganDesc,
  RoomItemId.lampuBulan => l.roomItemLampuBulanDesc,
  RoomItemId.bantalIkan => l.roomItemBantalIkanDesc,
  RoomItemId.monstera => l.roomItemMonsteraDesc,
  RoomItemId.terowongan => l.roomItemTerowonganDesc,
  RoomItemId.hammock => l.roomItemHammockDesc,
  RoomItemId.sofaMini => l.roomItemSofaMiniDesc,
  RoomItemId.jendelaBurung => l.roomItemJendelaBurungDesc,
  RoomItemId.mangkuk => '',
};

/// Nama kucing kamar.
String kittyName(AppLocalizations l, KittyId id) => switch (id) {
  KittyId.oyen => l.kittyOyen,
  KittyId.salju => l.kittySalju,
  KittyId.telon => l.kittyTelon,
  KittyId.arang => l.kittyArang,
  KittyId.mendung => l.kittyMendung,
  KittyId.kopiSusu => l.kittyKopiSusu,
  KittyId.mochi => l.kittyMochi,
  KittyId.bos => l.kittyBos,
  KittyId.kembang => l.kittyKembang,
};

/// Deskripsi kucing di kartu Toko.
String kittyDesc(AppLocalizations l, KittyId id) => switch (id) {
  KittyId.oyen => l.kittyOyenDesc,
  KittyId.salju => l.kittySaljuDesc,
  KittyId.telon => l.kittyTelonDesc,
  KittyId.arang => l.kittyArangDesc,
  KittyId.mendung => l.kittyMendungDesc,
  KittyId.kopiSusu => l.kittyKopiSusuDesc,
  KittyId.mochi => l.kittyMochiDesc,
  KittyId.bos => l.kittyBosDesc,
  KittyId.kembang => l.kittyKembangDesc,
};

/// Nama aksesoris.
String accessoryName(AppLocalizations l, AccessoryId id) => switch (id) {
  AccessoryId.pita => l.accessoryPita,
  AccessoryId.jepitBunga => l.accessoryJepitBunga,
  AccessoryId.bandana => l.accessoryBandana,
  AccessoryId.dasiKupu => l.accessoryDasiKupu,
  AccessoryId.kalung => l.accessoryKalung,
  AccessoryId.syal => l.accessorySyal,
  AccessoryId.beanie => l.accessoryBeanie,
  AccessoryId.topiKoki => l.accessoryTopiKoki,
  AccessoryId.baret => l.accessoryBaret,
  AccessoryId.kacamata => l.accessoryKacamata,
  AccessoryId.headphone => l.accessoryHeadphone,
  AccessoryId.tandukRusa => l.accessoryTandukRusa,
  AccessoryId.topiPesta => l.accessoryTopiPesta,
  AccessoryId.topiPenyihir => l.accessoryTopiPenyihir,
  AccessoryId.mahkota => l.accessoryMahkota,
  AccessoryId.mahkotaRaja => l.accessoryMahkotaRaja,
};

/// Deskripsi aksesoris di panel pratinjau dan sheet beli.
String accessoryDesc(AppLocalizations l, AccessoryId id) => switch (id) {
  AccessoryId.pita => l.accessoryPitaDesc,
  AccessoryId.jepitBunga => l.accessoryJepitBungaDesc,
  AccessoryId.bandana => l.accessoryBandanaDesc,
  AccessoryId.dasiKupu => l.accessoryDasiKupuDesc,
  AccessoryId.kalung => l.accessoryKalungDesc,
  AccessoryId.syal => l.accessorySyalDesc,
  AccessoryId.beanie => l.accessoryBeanieDesc,
  AccessoryId.topiKoki => l.accessoryTopiKokiDesc,
  AccessoryId.baret => l.accessoryBaretDesc,
  AccessoryId.kacamata => l.accessoryKacamataDesc,
  AccessoryId.headphone => l.accessoryHeadphoneDesc,
  AccessoryId.tandukRusa => l.accessoryTandukRusaDesc,
  AccessoryId.topiPesta => l.accessoryTopiPestaDesc,
  AccessoryId.topiPenyihir => l.accessoryTopiPenyihirDesc,
  AccessoryId.mahkota => l.accessoryMahkotaDesc,
  AccessoryId.mahkotaRaja => l.accessoryMahkotaRajaDesc,
};

/// Nama camilan.
String snackName(AppLocalizations l, SnackId id) => switch (id) {
  SnackId.ikanAsin => l.snackIkanAsin,
  SnackId.susu => l.snackSusu,
  SnackId.tuna => l.snackTuna,
  SnackId.biskuit => l.snackBiskuit,
  SnackId.puding => l.snackPuding,
};

/// Deskripsi camilan di kartu Toko.
String snackDesc(AppLocalizations l, SnackId id) => switch (id) {
  SnackId.ikanAsin => l.snackIkanAsinDesc,
  SnackId.susu => l.snackSusuDesc,
  SnackId.tuna => l.snackTunaDesc,
  SnackId.biskuit => l.snackBiskuitDesc,
  SnackId.puding => l.snackPudingDesc,
};

/// Kelangkaan aksesoris di kartu Toko.
String rarityName(AppLocalizations l, Rarity rarity) => switch (rarity) {
  Rarity.common => l.rarityCommon,
  Rarity.rare => l.rarityRare,
  Rarity.special => l.raritySpecial,
};

/// Label pembaca layar kucing kamar ("Oyen duduk diam, memakai Pita"),
/// sama dengan `aria-label` di `Kucing.dc.html`.
String kittyLabel(AppLocalizations l, KittyLook look) {
  final name = kittyName(l, look.kitty);
  final pose = l.kittyPose(look.pose.name);
  final accessory = look.accessory;
  return accessory == null
      ? l.kittyLabel(name, pose)
      : l.kittyLabelAccessory(name, pose, accessoryName(l, accessory));
}

/// Label pembaca layar tanda lesu (`aria-label` di `TandaLesu.dc.html`).
String sadMarkLabel(AppLocalizations l, {required bool hungry}) =>
    hungry ? l.sadMarkHungry : l.sadMarkSad;
