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
    required this.checker,
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
    checker: Color(0x33E2C08C), // rgba(226,192,140,.20)
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

  /// Kotak-kotak latar Beranda.
  final Color checker;

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
    Color? checker,
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
      checker: checker ?? this.checker,
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
      checker: c(checker, other.checker),
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
    );
  }
}
