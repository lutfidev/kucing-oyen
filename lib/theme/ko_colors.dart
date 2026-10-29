import 'package:flutter/material.dart';

/// Palet Kucing Oren.
///
/// Sumber: `docs/design/source/13-design-token-komponen-ui.html` (kartu
/// "Warna"), ditambah warna pendukung yang dipakai komponen di layar desain.
/// Widget tidak menulis `Color(0x...)` sendiri; selalu ambil dari sini.
@immutable
class KoColors extends ThemeExtension<KoColors> {
  const KoColors({
    required this.cream,
    required this.surface,
    required this.line,
    required this.lineDeep,
    required this.ink,
    required this.inkSoft,
    required this.floor,
    required this.floorAlt,
    required this.orange,
    required this.orangeDeep,
    required this.orangeLine,
    required this.fur,
    required this.furStripe,
    required this.water,
    required this.waterDeep,
    required this.box,
    required this.boxEdge,
    required this.success,
    required this.successDeep,
    required this.onSuccess,
    required this.brick,
    required this.brickDeep,
    required this.wood,
    required this.woodDeep,
    required this.star,
    required this.starEdge,
    required this.starEmpty,
    required this.muted,
    required this.locked,
    required this.disabled,
    required this.onDisabled,
    required this.hint,
    required this.hintLine,
    required this.hintDeep,
    required this.boardRing,
    required this.shadowCard,
    required this.shadowBoard,
    required this.shadowGlow,
    required this.shadowGlowStrong,
    required this.shadowSprite,
    required this.shadowLift,
    required this.shadowTray,
    required this.inkDeep,
    required this.statIcon,
    required this.successText,
    required this.creamDim,
    required this.starShine,
    required this.logo,
    required this.mapFloor,
    required this.plank,
    required this.plankJoint,
    required this.shadowNode,
    required this.nodeLocked,
    required this.nodeLockedInk,
    required this.boss,
    required this.bossEdge,
    required this.brickEdge,
    required this.onBrick,
    required this.scrim,
    required this.shadowSheet,
    required this.scrimDeep,
    required this.shadowDialog,
    required this.sheetHandle,
    required this.onLockedSoft,
    required this.turnClockwise,
    required this.spotlightRing,
    required this.onScrimLine,
    required this.scrimLight,
    required this.successSoft,
    required this.disabledLine,
    required this.priceTag,
    required this.ownedChip,
    required this.rareChip,
    required this.onRareChip,
    required this.specialChip,
    required this.onSpecialChip,
    required this.tabTrack,
    required this.shortFill,
    required this.priceMuted,
    required this.roomWall,
    required this.roomWallStripe,
    required this.roomWallMark,
    required this.roomTrimLight,
    required this.roomFloorBoards,
    required this.roomFloorLine,
    required this.needHungerTile,
    required this.needHungerInk,
    required this.needJoyTile,
    required this.needLowTile,
    required this.heart,
    required this.roomHintWallLine,
    required this.roomHintWallInk,
    required this.roomHintFloorLine,
    required this.roomHintFloorInk,
    required this.roomScrim,
    required this.roomSelectFill,
    required this.roomZoneLine,
    required this.roomZoneFill,
    required this.roomItemDecorFill,
    required this.roomDragShadow,
    required this.onWaterDeep,
  });

  static const standard = KoColors(
    cream: Color(0xFFFFF4E2),
    surface: Color(0xFFFFFBF3),
    line: Color(0xFFEAD3AE),
    lineDeep: Color(0xFFE2C79C),
    ink: Color(0xFF3B2716),
    inkSoft: Color(0xFF6B4F3A),
    floor: Color(0xFFF7E8CE),
    floorAlt: Color(0xFFF1DDBA),
    orange: Color(0xFFF59A33),
    orangeDeep: Color(0xFFC9650C),
    orangeLine: Color(0xFFE07A10),
    fur: Color(0xFFF29A3A),
    furStripe: Color(0xFFC4651A),
    water: Color(0xFF8FD3F0),
    waterDeep: Color(0xFF2F86B8),
    box: Color(0xFFC8955A),
    boxEdge: Color(0xFF9E6C37),
    success: Color(0xFF2BB5A0),
    successDeep: Color(0xFF1C8676),
    onSuccess: Color(0xFF12352F),
    brick: Color(0xFFC2492F),
    brickDeep: Color(0xFF9A3520),
    wood: Color(0xFFB07A4F),
    woodDeep: Color(0xFF7E5233),
    star: Color(0xFFFFC83D),
    starEdge: Color(0xFFC98F00),
    starEmpty: Color(0xFFEADBC2),
    muted: Color(0xFFCDB48C),
    locked: Color(0xFFEFE3CF),
    disabled: Color(0xFFE6D6BC),
    onDisabled: Color(0xFF5E4A37),
    hint: Color(0xFFFFE6A8),
    hintLine: Color(0xFFF0C55A),
    hintDeep: Color(0xFFD9A92E),
    boardRing: Color(0xFF5E3B22),
    shadowCard: Color(0x24784614), // rgba(120,70,20,.14)
    shadowBoard: Color(0x475B3414), // rgba(91,52,20,.28)
    shadowGlow: Color(0x40A0500A), // rgba(160,80,10,.25)
    shadowGlowStrong: Color(0x47A0500A), // rgba(160,80,10,.28)
    shadowSprite: Color(0x297A4A1F), // #7A4A1F, opacity .16
    shadowLift: Color(0x595B3414), // rgba(91,52,20,.35)
    shadowTray: Color(0x1A784614), // rgba(120,70,20,.10)
    inkDeep: Color(0xFF1E140B),
    statIcon: Color(0xFFC99466),
    successText: Color(0xFF1C6F62),
    creamDim: Color(0xFFF3E6D2),
    starShine: Color(0xFFFFF1C2),
    logo: Color(0xFFD9700F),
    mapFloor: Color(0xFFF3E0C2),
    plank: Color(0x38B07A4F), // rgba(176,122,79,.22)
    plankJoint: Color(0x24B07A4F), // rgba(176,122,79,.14)
    shadowNode: Color(0x38965014), // rgba(150,80,20,.22)
    nodeLocked: Color(0xFFE8D6B8),
    nodeLockedInk: Color(0xFF8A7259),
    boss: Color(0xFFE3C9A6),
    bossEdge: Color(0xFFB28A64),
    brickEdge: Color(0xFF8E3220),
    onBrick: Color(0xFFFFFFFF),
    scrim: Color(0x9E2E1E10), // rgba(46,30,16,.62),
    shadowSheet: Color(0x4D2E1E10), // rgba(46,30,16,.3),
    scrimDeep: Color(0xBD1E140A), // rgba(30,20,10,.74),
    shadowDialog: Color(0x4D000000), // rgba(0,0,0,.3),
    sheetHandle: Color(0xFFD8BF97),
    onLockedSoft: Color(0xFF6B5A47),
    turnClockwise: Color(0xFF3E9BCB),
    spotlightRing: Color(0xB3F59A33), // rgba(245,154,51,.7),
    onScrimLine: Color(0xB3FFF4E2), // rgba(255,244,226,.7),
    scrimLight: Color(0x8C2E1E10), // rgba(46,30,16,.55),
    successSoft: Color(0xFFE3F5F1),
    disabledLine: Color(0xFFD8C3A2),
    priceTag: Color(0xFFFFF1C9),
    ownedChip: Color(0xFFD4F1EB),
    rareChip: Color(0xFFD6ECF7),
    onRareChip: Color(0xFF1F5E80),
    specialChip: Color(0xFFF6DDF0),
    onSpecialChip: Color(0xFF84336F),
    tabTrack: Color(0xFFF3E3C6),
    shortFill: Color(0xFFEADBC2),
    priceMuted: Color(0xFF8A7259),
    roomWall: Color(0xFFFCE6C8),
    roomWallStripe: Color(0x24E2AA6E), // rgba(226,170,110,.14)
    roomWallMark: Color(0x80D4A971), // #D4A971, opacity .5,
    roomTrimLight: Color(0xFFC99466),
    roomFloorBoards: Color(0xFFEBC896),
    roomFloorLine: Color(0x40B07A4F), // rgba(176,122,79,.25),
    needHungerTile: Color(0xFFFDE3C2),
    needHungerInk: Color(0xFFA9530A),
    needJoyTile: Color(0xFFCDEFE8),
    needLowTile: Color(0xFFF6D3CA),
    heart: Color(0xFFF07F9A),
    roomHintWallLine: Color(0xFFD9A066),
    roomHintWallInk: Color(0xFFA9530A),
    roomHintFloorLine: Color(0xFFC99466),
    roomHintFloorInk: Color(0xFF8E5A30),
    roomScrim: Color(0x383B2716), // rgba(59,39,22,.22),
    roomSelectFill: Color(0x2EF59A33), // rgba(245,154,51,.18),
    roomZoneLine: Color(0x8C2F86B8), // rgba(47,134,184,.55),
    roomZoneFill: Color(0x0D2F86B8), // rgba(47,134,184,.05),
    roomItemDecorFill: Color(0x122F86B8), // rgba(47,134,184,.07),
    roomDragShadow: Color(0x383B2716), // rgba(59,39,22,.22),
    onWaterDeep: Color(0xFFFFFFFF),
  );

  /// Latar semua layar.
  final Color cream;

  /// Kartu, tombol sekunder.
  final Color surface;

  /// Border kartu dan chip.
  final Color line;

  /// Bayangan tombol sekunder dan ikon, tepi slot baki.
  final Color lineDeep;

  /// Teks utama, ikon.
  final Color ink;

  /// Teks sekunder.
  final Color inkSoft;

  /// Petak lantai kotak-kotak.
  final Color floor;
  final Color floorAlt;

  /// Tombol utama, benda pemain.
  final Color orange;

  /// Bayangan tekan tombol utama, garis.
  final Color orangeDeep;

  /// Garis putus-putus slot baki yang sedang diseret.
  final Color orangeLine;

  /// Bulu Oyen dan belangnya.
  final Color fur;
  final Color furStripe;

  /// Genangan, isi ember.
  final Color water;

  /// Mangkuk dan ember.
  final Color waterDeep;

  /// Kardus dan tepinya.
  final Color box;
  final Color boxEdge;

  /// Berhasil, tercapai.
  final Color success;

  /// Judul berhasil, bayangan tombol sukses.
  final Color successDeep;

  /// Teks di atas [success].
  final Color onSuccess;

  /// Vas Ibu, peringatan.
  final Color brick;

  /// Teks peringatan.
  final Color brickDeep;

  /// Tembok dan perabot.
  final Color wood;
  final Color woodDeep;

  /// Bintang dan koin, beserta tepinya.
  final Color star;
  final Color starEdge;

  /// Bintang yang belum didapat (tepinya [muted]).
  final Color starEmpty;

  /// Angka baki yang habis, garis kartu terkunci, tepi bintang kosong.
  final Color muted;

  /// Latar kartu terkunci.
  final Color locked;

  /// Tombol nonaktif: isi dan teks (bayangannya [muted]).
  final Color disabled;
  final Color onDisabled;

  /// Tombol petunjuk: isi, garis, bayangan.
  final Color hint;
  final Color hintLine;
  final Color hintDeep;

  /// Bingkai papan.
  final Color boardRing;

  /// Bayangan lembut kartu, papan, sinar tombol utama besar (versi kuat untuk
  /// tombol Main di Beranda), dan elips di bawah sprite.
  final Color shadowCard;
  final Color shadowBoard;
  final Color shadowGlow;
  final Color shadowGlowStrong;
  final Color shadowSprite;

  /// Bayangan jatuh benda yang sedang diseret.
  final Color shadowLift;

  /// Bayangan lembut panel baki.
  final Color shadowTray;

  /// Bayangan padat tombol gelap (×2 yang menyala).
  final Color inkDeep;

  /// Ikon kotak angka di layar Berhasil (jejak kaki, kardus).
  final Color statIcon;

  /// Teks syarat bintang yang didapat ("Dapat").
  final Color successText;

  /// Latar layar gagal (Oyen bosan) dan kotak Oyen tidur di kartunya.
  final Color creamDim;

  /// Kilau bintang besar di layar Berhasil.
  final Color starShine;

  /// "Oren" di logo Beranda.
  final Color logo;

  /// Lantai kayu peta babak, garis antarpapan, dan sambungan papan.
  final Color mapFloor;

  final Color plank;

  final Color plankJoint;

  /// Bayangan lembut node level yang sudah selesai.
  final Color shadowNode;

  /// Node level terkunci (juga bintang kosong di peta) dan gemboknya.
  final Color nodeLocked;

  final Color nodeLockedInk;

  /// Kotak level bos dan bayangan padatnya.
  final Color boss;

  final Color bossEdge;

  /// Bayangan padat label bos dan teksnya.
  final Color brickEdge;

  final Color onBrick;

  /// Latar gelap di belakang sheet aturan.
  final Color scrim;

  /// Bayangan sheet aturan.
  final Color shadowSheet;

  /// Overlay gelap tutorial.
  final Color scrimDeep;

  /// Bayangan kartu tutorial.
  final Color shadowDialog;

  /// Pegangan sheet.
  final Color sheetHandle;

  /// Teks kecil kartu aturan terkunci.
  final Color onLockedSoft;

  /// Panah ↻ di kartu aturan ([brickDeep] untuk ↺).
  final Color turnClockwise;

  /// Cincin denyut di sekeliling sorotan tutorial.
  final Color spotlightRing;

  /// Garis tombol "Lewati" di atas overlay tutorial.
  final Color onScrimLine;

  /// Latar gelap di belakang sheet Petunjuk (desain 10).
  final Color scrimLight;

  /// Kotak teks petunjuk yang sudah dibuka.
  final Color successSoft;

  /// Garis tombol nonaktif di kartu petunjuk yang terkunci.
  final Color disabledLine;

  /// Stok camilan penuh di Toko.
  final Color priceTag;

  /// Latar badge "Punyamu" dan "Tinggal di kamar" di Toko (desain 20).
  final Color ownedChip;

  /// Latar badge aksesoris langka (desain 20).
  final Color rareChip;

  /// Tulisan di badge langka.
  final Color onRareChip;

  /// Latar badge aksesoris spesial (desain 20).
  final Color specialChip;

  /// Tulisan di badge spesial.
  final Color onSpecialChip;

  /// Latar baris tab Toko dan badge kelangkaan biasa (desain 20).
  final Color tabTrack;

  /// Tombol beli yang koinnya kurang (desain 20).
  final Color shortFill;

  /// Angka harga di kartu yang koinnya kurang (desain 20).
  final Color priceMuted;

  /// Dinding kamar (desain 19).
  final Color roomWall;

  /// Garis tegak dinding kamar.
  final Color roomWallStripe;

  /// Goresan lantai dan dinding kamar.
  final Color roomWallMark;

  /// Tepi terang trim kamar.
  final Color roomTrimLight;

  /// Lantai papan kamar.
  final Color roomFloorBoards;

  /// Sambungan papan lantai kamar.
  final Color roomFloorLine;

  /// Kotak ikon bar Lapar.
  final Color needHungerTile;

  /// Ikon dan angka bar Lapar.
  final Color needHungerInk;

  /// Kotak ikon bar Senang.
  final Color needJoyTile;

  /// Kotak ikon bar yang hampir habis.
  final Color needLowTile;

  /// Hati elusan.
  final Color heart;

  /// Garis bidang kosong dinding kamar baru.
  final Color roomHintWallLine;

  /// Teks bidang kosong dinding kamar baru.
  final Color roomHintWallInk;

  /// Garis bidang kosong lantai kamar baru.
  final Color roomHintFloorLine;

  /// Teks bidang kosong lantai kamar baru.
  final Color roomHintFloorInk;

  /// Latar gelap di belakang kartu kucing.
  final Color roomScrim;

  /// Isi cincin di bawah kucing yang kartunya terbuka.
  final Color roomSelectFill;

  /// Garis putus-putus area dinding/lantai saat menghias.
  final Color roomZoneLine;

  /// Isi area dinding/lantai saat menghias.
  final Color roomZoneFill;

  /// Isi kotak barang saat menghias.
  final Color roomItemDecorFill;

  /// Bayangan elips di bawah barang yang diangkat.
  final Color roomDragShadow;

  /// Teks dan ikon di atas `waterDeep` (label area, gagang).
  final Color onWaterDeep;

  @override
  KoColors copyWith({
    Color? cream,
    Color? surface,
    Color? line,
    Color? lineDeep,
    Color? ink,
    Color? inkSoft,
    Color? floor,
    Color? floorAlt,
    Color? orange,
    Color? orangeDeep,
    Color? orangeLine,
    Color? fur,
    Color? furStripe,
    Color? water,
    Color? waterDeep,
    Color? box,
    Color? boxEdge,
    Color? success,
    Color? successDeep,
    Color? onSuccess,
    Color? brick,
    Color? brickDeep,
    Color? wood,
    Color? woodDeep,
    Color? star,
    Color? starEdge,
    Color? starEmpty,
    Color? muted,
    Color? locked,
    Color? disabled,
    Color? onDisabled,
    Color? hint,
    Color? hintLine,
    Color? hintDeep,
    Color? boardRing,
    Color? shadowCard,
    Color? shadowBoard,
    Color? shadowGlow,
    Color? shadowGlowStrong,
    Color? shadowSprite,
    Color? shadowLift,
    Color? shadowTray,
    Color? inkDeep,
    Color? statIcon,
    Color? successText,
    Color? creamDim,
    Color? starShine,
    Color? logo,
    Color? mapFloor,
    Color? plank,
    Color? plankJoint,
    Color? shadowNode,
    Color? nodeLocked,
    Color? nodeLockedInk,
    Color? boss,
    Color? bossEdge,
    Color? brickEdge,
    Color? onBrick,
    Color? scrim,
    Color? shadowSheet,
    Color? scrimDeep,
    Color? shadowDialog,
    Color? sheetHandle,
    Color? onLockedSoft,
    Color? turnClockwise,
    Color? spotlightRing,
    Color? onScrimLine,
    Color? scrimLight,
    Color? successSoft,
    Color? disabledLine,
    Color? priceTag,
    Color? ownedChip,
    Color? rareChip,
    Color? onRareChip,
    Color? specialChip,
    Color? onSpecialChip,
    Color? tabTrack,
    Color? shortFill,
    Color? priceMuted,
    Color? roomWall,
    Color? roomWallStripe,
    Color? roomWallMark,
    Color? roomTrimLight,
    Color? roomFloorBoards,
    Color? roomFloorLine,
    Color? needHungerTile,
    Color? needHungerInk,
    Color? needJoyTile,
    Color? needLowTile,
    Color? heart,
    Color? roomHintWallLine,
    Color? roomHintWallInk,
    Color? roomHintFloorLine,
    Color? roomHintFloorInk,
    Color? roomScrim,
    Color? roomSelectFill,
    Color? roomZoneLine,
    Color? roomZoneFill,
    Color? roomItemDecorFill,
    Color? roomDragShadow,
    Color? onWaterDeep,
  }) {
    return KoColors(
      cream: cream ?? this.cream,
      surface: surface ?? this.surface,
      line: line ?? this.line,
      lineDeep: lineDeep ?? this.lineDeep,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      floor: floor ?? this.floor,
      floorAlt: floorAlt ?? this.floorAlt,
      orange: orange ?? this.orange,
      orangeDeep: orangeDeep ?? this.orangeDeep,
      orangeLine: orangeLine ?? this.orangeLine,
      fur: fur ?? this.fur,
      furStripe: furStripe ?? this.furStripe,
      water: water ?? this.water,
      waterDeep: waterDeep ?? this.waterDeep,
      box: box ?? this.box,
      boxEdge: boxEdge ?? this.boxEdge,
      success: success ?? this.success,
      successDeep: successDeep ?? this.successDeep,
      onSuccess: onSuccess ?? this.onSuccess,
      brick: brick ?? this.brick,
      brickDeep: brickDeep ?? this.brickDeep,
      wood: wood ?? this.wood,
      woodDeep: woodDeep ?? this.woodDeep,
      star: star ?? this.star,
      starEdge: starEdge ?? this.starEdge,
      starEmpty: starEmpty ?? this.starEmpty,
      muted: muted ?? this.muted,
      locked: locked ?? this.locked,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
      hint: hint ?? this.hint,
      hintLine: hintLine ?? this.hintLine,
      hintDeep: hintDeep ?? this.hintDeep,
      boardRing: boardRing ?? this.boardRing,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowBoard: shadowBoard ?? this.shadowBoard,
      shadowGlow: shadowGlow ?? this.shadowGlow,
      shadowGlowStrong: shadowGlowStrong ?? this.shadowGlowStrong,
      shadowSprite: shadowSprite ?? this.shadowSprite,
      shadowLift: shadowLift ?? this.shadowLift,
      shadowTray: shadowTray ?? this.shadowTray,
      inkDeep: inkDeep ?? this.inkDeep,
      statIcon: statIcon ?? this.statIcon,
      successText: successText ?? this.successText,
      creamDim: creamDim ?? this.creamDim,
      starShine: starShine ?? this.starShine,
      logo: logo ?? this.logo,
      mapFloor: mapFloor ?? this.mapFloor,
      plank: plank ?? this.plank,
      plankJoint: plankJoint ?? this.plankJoint,
      shadowNode: shadowNode ?? this.shadowNode,
      nodeLocked: nodeLocked ?? this.nodeLocked,
      nodeLockedInk: nodeLockedInk ?? this.nodeLockedInk,
      boss: boss ?? this.boss,
      bossEdge: bossEdge ?? this.bossEdge,
      brickEdge: brickEdge ?? this.brickEdge,
      onBrick: onBrick ?? this.onBrick,
      scrim: scrim ?? this.scrim,
      shadowSheet: shadowSheet ?? this.shadowSheet,
      scrimDeep: scrimDeep ?? this.scrimDeep,
      shadowDialog: shadowDialog ?? this.shadowDialog,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      onLockedSoft: onLockedSoft ?? this.onLockedSoft,
      turnClockwise: turnClockwise ?? this.turnClockwise,
      spotlightRing: spotlightRing ?? this.spotlightRing,
      onScrimLine: onScrimLine ?? this.onScrimLine,
      scrimLight: scrimLight ?? this.scrimLight,
      successSoft: successSoft ?? this.successSoft,
      disabledLine: disabledLine ?? this.disabledLine,
      priceTag: priceTag ?? this.priceTag,
      ownedChip: ownedChip ?? this.ownedChip,
      rareChip: rareChip ?? this.rareChip,
      onRareChip: onRareChip ?? this.onRareChip,
      specialChip: specialChip ?? this.specialChip,
      onSpecialChip: onSpecialChip ?? this.onSpecialChip,
      tabTrack: tabTrack ?? this.tabTrack,
      shortFill: shortFill ?? this.shortFill,
      priceMuted: priceMuted ?? this.priceMuted,
      roomWall: roomWall ?? this.roomWall,
      roomWallStripe: roomWallStripe ?? this.roomWallStripe,
      roomWallMark: roomWallMark ?? this.roomWallMark,
      roomTrimLight: roomTrimLight ?? this.roomTrimLight,
      roomFloorBoards: roomFloorBoards ?? this.roomFloorBoards,
      roomFloorLine: roomFloorLine ?? this.roomFloorLine,
      needHungerTile: needHungerTile ?? this.needHungerTile,
      needHungerInk: needHungerInk ?? this.needHungerInk,
      needJoyTile: needJoyTile ?? this.needJoyTile,
      needLowTile: needLowTile ?? this.needLowTile,
      heart: heart ?? this.heart,
      roomHintWallLine: roomHintWallLine ?? this.roomHintWallLine,
      roomHintWallInk: roomHintWallInk ?? this.roomHintWallInk,
      roomHintFloorLine: roomHintFloorLine ?? this.roomHintFloorLine,
      roomHintFloorInk: roomHintFloorInk ?? this.roomHintFloorInk,
      roomScrim: roomScrim ?? this.roomScrim,
      roomSelectFill: roomSelectFill ?? this.roomSelectFill,
      roomZoneLine: roomZoneLine ?? this.roomZoneLine,
      roomZoneFill: roomZoneFill ?? this.roomZoneFill,
      roomItemDecorFill: roomItemDecorFill ?? this.roomItemDecorFill,
      roomDragShadow: roomDragShadow ?? this.roomDragShadow,
      onWaterDeep: onWaterDeep ?? this.onWaterDeep,
    );
  }

  @override
  KoColors lerp(KoColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return KoColors(
      cream: c(cream, other.cream),
      surface: c(surface, other.surface),
      line: c(line, other.line),
      lineDeep: c(lineDeep, other.lineDeep),
      ink: c(ink, other.ink),
      inkSoft: c(inkSoft, other.inkSoft),
      floor: c(floor, other.floor),
      floorAlt: c(floorAlt, other.floorAlt),
      orange: c(orange, other.orange),
      orangeDeep: c(orangeDeep, other.orangeDeep),
      orangeLine: c(orangeLine, other.orangeLine),
      fur: c(fur, other.fur),
      furStripe: c(furStripe, other.furStripe),
      water: c(water, other.water),
      waterDeep: c(waterDeep, other.waterDeep),
      box: c(box, other.box),
      boxEdge: c(boxEdge, other.boxEdge),
      success: c(success, other.success),
      successDeep: c(successDeep, other.successDeep),
      onSuccess: c(onSuccess, other.onSuccess),
      brick: c(brick, other.brick),
      brickDeep: c(brickDeep, other.brickDeep),
      wood: c(wood, other.wood),
      woodDeep: c(woodDeep, other.woodDeep),
      star: c(star, other.star),
      starEdge: c(starEdge, other.starEdge),
      starEmpty: c(starEmpty, other.starEmpty),
      muted: c(muted, other.muted),
      locked: c(locked, other.locked),
      disabled: c(disabled, other.disabled),
      onDisabled: c(onDisabled, other.onDisabled),
      hint: c(hint, other.hint),
      hintLine: c(hintLine, other.hintLine),
      hintDeep: c(hintDeep, other.hintDeep),
      boardRing: c(boardRing, other.boardRing),
      shadowCard: c(shadowCard, other.shadowCard),
      shadowBoard: c(shadowBoard, other.shadowBoard),
      shadowGlow: c(shadowGlow, other.shadowGlow),
      shadowGlowStrong: c(shadowGlowStrong, other.shadowGlowStrong),
      shadowSprite: c(shadowSprite, other.shadowSprite),
      shadowLift: c(shadowLift, other.shadowLift),
      shadowTray: c(shadowTray, other.shadowTray),
      inkDeep: c(inkDeep, other.inkDeep),
      statIcon: c(statIcon, other.statIcon),
      successText: c(successText, other.successText),
      creamDim: c(creamDim, other.creamDim),
      starShine: c(starShine, other.starShine),
      logo: c(logo, other.logo),
      mapFloor: c(mapFloor, other.mapFloor),
      plank: c(plank, other.plank),
      plankJoint: c(plankJoint, other.plankJoint),
      shadowNode: c(shadowNode, other.shadowNode),
      nodeLocked: c(nodeLocked, other.nodeLocked),
      nodeLockedInk: c(nodeLockedInk, other.nodeLockedInk),
      boss: c(boss, other.boss),
      bossEdge: c(bossEdge, other.bossEdge),
      brickEdge: c(brickEdge, other.brickEdge),
      onBrick: c(onBrick, other.onBrick),
      scrim: c(scrim, other.scrim),
      shadowSheet: c(shadowSheet, other.shadowSheet),
      scrimDeep: c(scrimDeep, other.scrimDeep),
      shadowDialog: c(shadowDialog, other.shadowDialog),
      sheetHandle: c(sheetHandle, other.sheetHandle),
      onLockedSoft: c(onLockedSoft, other.onLockedSoft),
      turnClockwise: c(turnClockwise, other.turnClockwise),
      spotlightRing: c(spotlightRing, other.spotlightRing),
      onScrimLine: c(onScrimLine, other.onScrimLine),
      scrimLight: c(scrimLight, other.scrimLight),
      successSoft: c(successSoft, other.successSoft),
      disabledLine: c(disabledLine, other.disabledLine),
      priceTag: c(priceTag, other.priceTag),
      ownedChip: c(ownedChip, other.ownedChip),
      rareChip: c(rareChip, other.rareChip),
      onRareChip: c(onRareChip, other.onRareChip),
      specialChip: c(specialChip, other.specialChip),
      onSpecialChip: c(onSpecialChip, other.onSpecialChip),
      tabTrack: c(tabTrack, other.tabTrack),
      shortFill: c(shortFill, other.shortFill),
      priceMuted: c(priceMuted, other.priceMuted),
      roomWall: c(roomWall, other.roomWall),
      roomWallStripe: c(roomWallStripe, other.roomWallStripe),
      roomWallMark: c(roomWallMark, other.roomWallMark),
      roomTrimLight: c(roomTrimLight, other.roomTrimLight),
      roomFloorBoards: c(roomFloorBoards, other.roomFloorBoards),
      roomFloorLine: c(roomFloorLine, other.roomFloorLine),
      needHungerTile: c(needHungerTile, other.needHungerTile),
      needHungerInk: c(needHungerInk, other.needHungerInk),
      needJoyTile: c(needJoyTile, other.needJoyTile),
      needLowTile: c(needLowTile, other.needLowTile),
      heart: c(heart, other.heart),
      roomHintWallLine: c(roomHintWallLine, other.roomHintWallLine),
      roomHintWallInk: c(roomHintWallInk, other.roomHintWallInk),
      roomHintFloorLine: c(roomHintFloorLine, other.roomHintFloorLine),
      roomHintFloorInk: c(roomHintFloorInk, other.roomHintFloorInk),
      roomScrim: c(roomScrim, other.roomScrim),
      roomSelectFill: c(roomSelectFill, other.roomSelectFill),
      roomZoneLine: c(roomZoneLine, other.roomZoneLine),
      roomZoneFill: c(roomZoneFill, other.roomZoneFill),
      roomItemDecorFill: c(roomItemDecorFill, other.roomItemDecorFill),
      roomDragShadow: c(roomDragShadow, other.roomDragShadow),
      onWaterDeep: c(onWaterDeep, other.onWaterDeep),
    );
  }
}
