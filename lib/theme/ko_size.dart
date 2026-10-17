import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Ukuran komponen yang berulang di layar desain (tinggi tombol, ikon, chip,
/// slot baki). Grup ini tidak ada di lembar token; ditambahkan supaya widget
/// tidak menulis angka sendiri.
@immutable
class KoSize extends ThemeExtension<KoSize> {
  const KoSize({
    required this.buttonHero,
    required this.buttonLarge,
    required this.button,
    required this.iconButton,
    required this.iconHero,
    required this.iconLarge,
    required this.icon,
    required this.iconSmall,
    required this.chip,
    required this.tray,
    required this.trayHint,
    required this.slot,
    required this.slotItem,
    required this.slotGhost,
    required this.badge,
    required this.badgeInset,
    required this.star,
    required this.starSmall,
    required this.border,
    required this.dash,
    required this.dashGap,
    required this.ghostOpacity,
    required this.chipSmall,
    required this.dot,
    required this.captionBox,
    required this.stepBadge,
    required this.control,
    required this.play,
    required this.iconMedium,
    required this.iconPlay,
    required this.resultStar,
    required this.resultStarMid,
    required this.partialStar,
    required this.partialStarMid,
    required this.statBox,
    required this.statBoxCompact,
    required this.ruleRow,
    required this.checkBadge,
    required this.iconTiny,
    required this.chipCompact,
    required this.iconChip,
    required this.avatar,
    required this.artBorder,
    required this.divider,
    required this.dimSaturation,
    required this.artMinScale,
    required this.oyenHome,
    required this.oyenHomeOverlap,
    required this.menuButton,
    required this.starHome,
    required this.node,
    required this.nodeRing,
    required this.nodeDash,
    required this.mapStar,
    required this.boss,
    required this.bossArt,
    required this.bossBadge,
    required this.chapterCard,
    required this.chapterIcon,
    required this.iconMicro,
    required this.chipMedium,
    required this.dotSmall,
    required this.captionBoxSmall,
    required this.slider,
    required this.sliderTrack,
    required this.sliderThumb,
    required this.sheetHandle,
    required this.sheetHandleThickness,
    required this.ruleArt,
    required this.ruleBadge,
    required this.oyenTutorial,
    required this.oyenTutorialOverlap,
  });

  static const standard = KoSize(
    buttonHero: 76,
    buttonLarge: 72,
    button: 64,
    iconButton: 44,
    iconHero: 30,
    iconLarge: 28,
    icon: 22,
    iconSmall: 20,
    chip: 40,
    tray: 88,
    trayHint: 72,
    slot: 64,
    slotItem: 50,
    slotGhost: 40,
    badge: 24,
    badgeInset: 8,
    star: 36,
    starSmall: 18,
    border: 2,
    dash: 6,
    dashGap: 4,
    ghostOpacity: 0.28,
    chipSmall: 32,
    dot: 10,
    captionBox: 56,
    stepBadge: 30,
    control: 56,
    play: 80,
    iconMedium: 24,
    iconPlay: 32,
    resultStar: 66,
    resultStarMid: 86,
    partialStar: 56,
    partialStarMid: 68,
    statBox: 68,
    statBoxCompact: 44,
    ruleRow: 44,
    checkBadge: 26,
    iconTiny: 14,
    chipCompact: 30,
    iconChip: 16,
    avatar: 56,
    artBorder: 3,
    divider: 1.5,
    dimSaturation: 0.7,
    artMinScale: 0.3,
    oyenHome: 190,
    oyenHomeOverlap: 34,
    menuButton: 56,
    starHome: 26,
    node: 64,
    nodeRing: 4,
    nodeDash: 3,
    mapStar: 17,
    boss: 96,
    bossArt: 64,
    bossBadge: 32,
    chapterCard: 52,
    chapterIcon: 36,
    iconMicro: 12,
    chipMedium: 36,
    dotSmall: 8,
    captionBoxSmall: 52,
    slider: 28,
    sliderTrack: 6,
    sliderThumb: 20,
    sheetHandle: 44,
    sheetHandleThickness: 5,
    ruleArt: 76,
    ruleBadge: 26,
    oyenTutorial: 96,
    oyenTutorialOverlap: 26,
  );

  /// Tombol "Main" di Beranda.
  final double buttonHero;

  /// Tombol "Bangunkan Oyen".
  final double buttonLarge;

  /// Tombol utama, sukses, dan sekunder biasa.
  final double button;

  /// Tombol ikon (kembali, petunjuk, Aturan).
  final double iconButton;

  /// Ikon di tombol "Main", "Bangunkan Oyen", tombol ikon, dan ikon kecil
  /// (Aturan, tutup, kosongkan papan).
  final double iconHero;
  final double iconLarge;
  final double icon;
  final double iconSmall;

  /// Tinggi chip.
  final double chip;

  /// Tinggi panel baki di bawah papan.
  final double tray;

  /// Lebar paling sempit petunjuk "Taruh di petak yang menyala" di baki
  /// (dikali skala teks). Kalau tempatnya kurang, petunjuk disembunyikan.
  final double trayHint;

  /// Slot baki, gambar benda di dalamnya, dan bayangan benda yang sedang
  /// diseret.
  final double slot;
  final double slotItem;
  final double slotGhost;

  /// Badge angka sisa di slot baki dan jarak keluarnya dari sudut slot.
  final double badge;
  final double badgeInset;

  /// Bintang di layar hasil dan bintang kecil di chip target.
  final double star;
  final double starSmall;

  /// Tebal garis kartu, chip, dan tombol.
  final double border;

  /// Garis putus-putus (slot kosong, kartu terkunci): panjang garis dan
  /// celah. CSS tidak menetapkan polanya; nilai ini mendekati Chrome.
  final double dash;
  final double dashGap;

  /// Bayangan benda di slot baki yang sedang diseret.
  final double ghostOpacity;

  /// Chip status fase jalan ("Vas aman", "2 benda dipakai").
  final double chipSmall;

  /// Titik warna di chip status vas.
  final double dot;

  /// Tinggi paling kecil kotak caption langkah.
  final double captionBox;

  /// Lingkaran nomor langkah di kotak caption.
  final double stepBadge;

  /// Tombol kontrol fase jalan ("Maju satu langkah", ×2).
  final double control;

  /// Tombol bulat Jeda/Lanjutkan.
  final double play;

  /// Ikon tombol kontrol fase jalan.
  final double iconMedium;

  /// Ikon di tombol Jeda/Lanjutkan.
  final double iconPlay;

  /// Bintang di layar Berhasil: kiri-kanan dan tengah.
  final double resultStar;
  final double resultStarMid;

  /// Bintang di layar vas pecah: kiri-kanan dan tengah.
  final double partialStar;
  final double partialStarMid;

  /// Kotak angka ("6 langkah") di layar Berhasil dan versi kecilnya di
  /// layar vas pecah.
  final double statBox;
  final double statBoxCompact;

  /// Tinggi paling kecil baris syarat bintang di layar hasil.
  final double ruleRow;

  /// Lingkaran centang syarat bintang yang didapat dan centangnya.
  final double checkBadge;
  final double iconTiny;

  /// Chip gelap di atas papan layar gagal ("Muter terus") dan ikonnya.
  final double chipCompact;
  final double iconChip;

  /// Kotak Oyen tidur di kartu pesan layar gagal.
  final double avatar;

  /// Garis dalam kartu ilustrasi layar hasil.
  final double artBorder;

  /// Garis putus-putus antarbaris syarat bintang.
  final double divider;

  /// Saturasi papan di layar gagal (`saturate(0.7)`).
  final double dimSaturation;

  /// Skala paling kecil kartu ilustrasi layar hasil; kalau tempatnya kurang,
  /// ilustrasinya disembunyikan.
  final double artMinScale;

  /// Oyen tidur di Beranda dan seberapa jauh logo menutupinya.
  final double oyenHome;

  final double oyenHomeOverlap;

  /// Tombol Lemari Kostum dan Pengaturan di Beranda.
  final double menuButton;

  /// Bintang di total bintang Beranda.
  final double starHome;

  /// Node level di peta babak, tebal cincin node saat ini (juga garis kotak
  /// bos), dan tebal garis putus-putus node terkunci.
  final double node;

  final double nodeRing;

  final double nodeDash;

  /// Bintang di bawah node level.
  final double mapStar;

  /// Kotak level bos, gambar di dalamnya, dan badge gemboknya.
  final double boss;

  final double bossArt;

  final double bossBadge;

  /// Kartu babak lain di bawah judul peta dan ikonnya.
  final double chapterCard;

  final double chapterIcon;

  /// Ikon di badge "Selesai".
  final double iconMicro;

  /// Chip "Rekaman" di bar atas putar ulang.
  final double chipMedium;

  /// Titik di chip "Rekaman".
  final double dotSmall;

  /// Tinggi paling kecil kotak caption putar ulang.
  final double captionBoxSmall;

  /// Tinggi slider waktu putar ulang (`input type=range`).
  final double slider;

  /// Tebal jalur slider.
  final double sliderTrack;

  /// Garis tengah pegangan slider.
  final double sliderThumb;

  /// Lebar pegangan sheet.
  final double sheetHandle;

  /// Tebal pegangan sheet.
  final double sheetHandleThickness;

  /// Gambar kartu aturan.
  final double ruleArt;

  /// Lingkaran nomor kartu aturan.
  final double ruleBadge;

  /// Oyen di kartu tutorial.
  final double oyenTutorial;

  /// Seberapa jauh Oyen menimpa kartu tutorial.
  final double oyenTutorialOverlap;

  @override
  KoSize copyWith({
    double? buttonHero,
    double? buttonLarge,
    double? button,
    double? iconButton,
    double? iconHero,
    double? iconLarge,
    double? icon,
    double? iconSmall,
    double? chip,
    double? tray,
    double? trayHint,
    double? slot,
    double? slotItem,
    double? slotGhost,
    double? badge,
    double? badgeInset,
    double? star,
    double? starSmall,
    double? border,
    double? dash,
    double? dashGap,
    double? ghostOpacity,
    double? chipSmall,
    double? dot,
    double? captionBox,
    double? stepBadge,
    double? control,
    double? play,
    double? iconMedium,
    double? iconPlay,
    double? resultStar,
    double? resultStarMid,
    double? partialStar,
    double? partialStarMid,
    double? statBox,
    double? statBoxCompact,
    double? ruleRow,
    double? checkBadge,
    double? iconTiny,
    double? chipCompact,
    double? iconChip,
    double? avatar,
    double? artBorder,
    double? divider,
    double? dimSaturation,
    double? artMinScale,
    double? oyenHome,
    double? oyenHomeOverlap,
    double? menuButton,
    double? starHome,
    double? node,
    double? nodeRing,
    double? nodeDash,
    double? mapStar,
    double? boss,
    double? bossArt,
    double? bossBadge,
    double? chapterCard,
    double? chapterIcon,
    double? iconMicro,
    double? chipMedium,
    double? dotSmall,
    double? captionBoxSmall,
    double? slider,
    double? sliderTrack,
    double? sliderThumb,
    double? sheetHandle,
    double? sheetHandleThickness,
    double? ruleArt,
    double? ruleBadge,
    double? oyenTutorial,
    double? oyenTutorialOverlap,
  }) {
    return KoSize(
      buttonHero: buttonHero ?? this.buttonHero,
      buttonLarge: buttonLarge ?? this.buttonLarge,
      button: button ?? this.button,
      iconButton: iconButton ?? this.iconButton,
      iconHero: iconHero ?? this.iconHero,
      iconLarge: iconLarge ?? this.iconLarge,
      icon: icon ?? this.icon,
      iconSmall: iconSmall ?? this.iconSmall,
      chip: chip ?? this.chip,
      tray: tray ?? this.tray,
      trayHint: trayHint ?? this.trayHint,
      slot: slot ?? this.slot,
      slotItem: slotItem ?? this.slotItem,
      slotGhost: slotGhost ?? this.slotGhost,
      badge: badge ?? this.badge,
      badgeInset: badgeInset ?? this.badgeInset,
      star: star ?? this.star,
      starSmall: starSmall ?? this.starSmall,
      border: border ?? this.border,
      dash: dash ?? this.dash,
      dashGap: dashGap ?? this.dashGap,
      ghostOpacity: ghostOpacity ?? this.ghostOpacity,
      chipSmall: chipSmall ?? this.chipSmall,
      dot: dot ?? this.dot,
      captionBox: captionBox ?? this.captionBox,
      stepBadge: stepBadge ?? this.stepBadge,
      control: control ?? this.control,
      play: play ?? this.play,
      iconMedium: iconMedium ?? this.iconMedium,
      iconPlay: iconPlay ?? this.iconPlay,
      resultStar: resultStar ?? this.resultStar,
      resultStarMid: resultStarMid ?? this.resultStarMid,
      partialStar: partialStar ?? this.partialStar,
      partialStarMid: partialStarMid ?? this.partialStarMid,
      statBox: statBox ?? this.statBox,
      statBoxCompact: statBoxCompact ?? this.statBoxCompact,
      ruleRow: ruleRow ?? this.ruleRow,
      checkBadge: checkBadge ?? this.checkBadge,
      iconTiny: iconTiny ?? this.iconTiny,
      chipCompact: chipCompact ?? this.chipCompact,
      iconChip: iconChip ?? this.iconChip,
      avatar: avatar ?? this.avatar,
      artBorder: artBorder ?? this.artBorder,
      divider: divider ?? this.divider,
      dimSaturation: dimSaturation ?? this.dimSaturation,
      artMinScale: artMinScale ?? this.artMinScale,
      oyenHome: oyenHome ?? this.oyenHome,
      oyenHomeOverlap: oyenHomeOverlap ?? this.oyenHomeOverlap,
      menuButton: menuButton ?? this.menuButton,
      starHome: starHome ?? this.starHome,
      node: node ?? this.node,
      nodeRing: nodeRing ?? this.nodeRing,
      nodeDash: nodeDash ?? this.nodeDash,
      mapStar: mapStar ?? this.mapStar,
      boss: boss ?? this.boss,
      bossArt: bossArt ?? this.bossArt,
      bossBadge: bossBadge ?? this.bossBadge,
      chapterCard: chapterCard ?? this.chapterCard,
      chapterIcon: chapterIcon ?? this.chapterIcon,
      iconMicro: iconMicro ?? this.iconMicro,
      chipMedium: chipMedium ?? this.chipMedium,
      dotSmall: dotSmall ?? this.dotSmall,
      captionBoxSmall: captionBoxSmall ?? this.captionBoxSmall,
      slider: slider ?? this.slider,
      sliderTrack: sliderTrack ?? this.sliderTrack,
      sliderThumb: sliderThumb ?? this.sliderThumb,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      sheetHandleThickness: sheetHandleThickness ?? this.sheetHandleThickness,
      ruleArt: ruleArt ?? this.ruleArt,
      ruleBadge: ruleBadge ?? this.ruleBadge,
      oyenTutorial: oyenTutorial ?? this.oyenTutorial,
      oyenTutorialOverlap: oyenTutorialOverlap ?? this.oyenTutorialOverlap,
    );
  }

  @override
  KoSize lerp(KoSize? other, double t) {
    if (other == null) return this;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return KoSize(
      buttonHero: d(buttonHero, other.buttonHero),
      buttonLarge: d(buttonLarge, other.buttonLarge),
      button: d(button, other.button),
      iconButton: d(iconButton, other.iconButton),
      iconHero: d(iconHero, other.iconHero),
      iconLarge: d(iconLarge, other.iconLarge),
      icon: d(icon, other.icon),
      iconSmall: d(iconSmall, other.iconSmall),
      chip: d(chip, other.chip),
      tray: d(tray, other.tray),
      trayHint: d(trayHint, other.trayHint),
      slot: d(slot, other.slot),
      slotItem: d(slotItem, other.slotItem),
      slotGhost: d(slotGhost, other.slotGhost),
      badge: d(badge, other.badge),
      badgeInset: d(badgeInset, other.badgeInset),
      star: d(star, other.star),
      starSmall: d(starSmall, other.starSmall),
      border: d(border, other.border),
      dash: d(dash, other.dash),
      dashGap: d(dashGap, other.dashGap),
      ghostOpacity: d(ghostOpacity, other.ghostOpacity),
      chipSmall: d(chipSmall, other.chipSmall),
      dot: d(dot, other.dot),
      captionBox: d(captionBox, other.captionBox),
      stepBadge: d(stepBadge, other.stepBadge),
      control: d(control, other.control),
      play: d(play, other.play),
      iconMedium: d(iconMedium, other.iconMedium),
      iconPlay: d(iconPlay, other.iconPlay),
      resultStar: d(resultStar, other.resultStar),
      resultStarMid: d(resultStarMid, other.resultStarMid),
      partialStar: d(partialStar, other.partialStar),
      partialStarMid: d(partialStarMid, other.partialStarMid),
      statBox: d(statBox, other.statBox),
      statBoxCompact: d(statBoxCompact, other.statBoxCompact),
      ruleRow: d(ruleRow, other.ruleRow),
      checkBadge: d(checkBadge, other.checkBadge),
      iconTiny: d(iconTiny, other.iconTiny),
      chipCompact: d(chipCompact, other.chipCompact),
      iconChip: d(iconChip, other.iconChip),
      avatar: d(avatar, other.avatar),
      artBorder: d(artBorder, other.artBorder),
      divider: d(divider, other.divider),
      dimSaturation: d(dimSaturation, other.dimSaturation),
      artMinScale: d(artMinScale, other.artMinScale),
      oyenHome: d(oyenHome, other.oyenHome),
      oyenHomeOverlap: d(oyenHomeOverlap, other.oyenHomeOverlap),
      menuButton: d(menuButton, other.menuButton),
      starHome: d(starHome, other.starHome),
      node: d(node, other.node),
      nodeRing: d(nodeRing, other.nodeRing),
      nodeDash: d(nodeDash, other.nodeDash),
      mapStar: d(mapStar, other.mapStar),
      boss: d(boss, other.boss),
      bossArt: d(bossArt, other.bossArt),
      bossBadge: d(bossBadge, other.bossBadge),
      chapterCard: d(chapterCard, other.chapterCard),
      chapterIcon: d(chapterIcon, other.chapterIcon),
      iconMicro: d(iconMicro, other.iconMicro),
      chipMedium: d(chipMedium, other.chipMedium),
      dotSmall: d(dotSmall, other.dotSmall),
      captionBoxSmall: d(captionBoxSmall, other.captionBoxSmall),
      slider: d(slider, other.slider),
      sliderTrack: d(sliderTrack, other.sliderTrack),
      sliderThumb: d(sliderThumb, other.sliderThumb),
      sheetHandle: d(sheetHandle, other.sheetHandle),
      sheetHandleThickness: d(sheetHandleThickness, other.sheetHandleThickness),
      ruleArt: d(ruleArt, other.ruleArt),
      ruleBadge: d(ruleBadge, other.ruleBadge),
      oyenTutorial: d(oyenTutorial, other.oyenTutorial),
      oyenTutorialOverlap: d(oyenTutorialOverlap, other.oyenTutorialOverlap),
    );
  }
}
