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
    required this.hintButton,
    required this.iconCompact,
    required this.lockedOpacity,
    required this.costumeCard,
    required this.costumeArt,
    required this.oyenCostume,
    required this.oyenCloset,
    required this.closetMinScale,
    required this.shopTab,
    required this.shopTabBar,
    required this.shopItemWell,
    required this.shopItemArtWidth,
    required this.shopItemArtHeight,
    required this.shopKittyWell,
    required this.shopKittyArt,
    required this.shopAccessoryWell,
    required this.shopAccessoryArt,
    required this.shopSnackWell,
    required this.shopSnackArtWidth,
    required this.shopSnackArtHeight,
    required this.shopPreviewWidth,
    required this.shopPreviewHeight,
    required this.shopPreviewArt,
    required this.shopPreviewFloor,
    required this.shopPick,
    required this.shopPickArt,
    required this.shopPreviewMinScale,
    required this.buyWell,
    required this.buyKittyArt,
    required this.buyAccessoryArt,
    required this.buyItemArtWidth,
    required this.buyItemArtHeight,
    required this.buyButton,
    required this.buyClose,
    required this.shopOwnedChip,
    required this.shopHomeChip,
    required this.shopOwnedMark,
    required this.shopPriceChip,
    required this.shopSnackButton,
    required this.shopStockChip,
    required this.shopRarityChip,
    required this.shopPreviewChip,
    required this.shopPreviewButton,
    required this.roomPlay,
    required this.roomPlayCompact,
    required this.roomMenuButton,
    required this.roomMenuButtonCompact,
    required this.roomCompactHeight,
    required this.roomDecorateGap,
    required this.roomHintBorder,
    required this.roomBubbleTail,
    required this.roomPraiseTop,
    required this.roomPraiseInset,
    required this.roomDecorateButton,
    required this.roomZoneChip,
    required this.roomGrip,
    required this.roomItemOutline,
    required this.roomLift,
    required this.roomLiftScale,
    required this.roomLiftShadow,
    required this.roomTraySlotWidth,
    required this.roomTraySlotHeight,
    required this.roomTraySlotWidthCompact,
    required this.roomTraySlotHeightCompact,
    required this.roomTrayArtWidth,
    required this.roomTrayArtHeight,
    required this.roomCardTop,
    required this.roomCardAvatar,
    required this.roomCardAvatarArt,
    required this.roomCardAvatarMinWidth,
    required this.roomCardButton,
    required this.roomSnackCardWidth,
    required this.roomSnackCardHeight,
    required this.roomSnackArtWidth,
    required this.roomSnackArtHeight,
    required this.roomSnackArtBox,
    required this.roomStockBadge,
    required this.roomEmptyOpacity,
    required this.roomAccessoryArt,
    required this.roomAccessoryCard,
    required this.roomWornTag,
    required this.needTile,
    required this.needLabel,
    required this.needBar,
    required this.needValue,
    required this.roomReactionWidth,
    required this.roomReactionHeight,
    required this.roomReactionRise,
    required this.roomHeaderLogoMinWidth,
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
    hintButton: 46,
    iconCompact: 18,
    lockedOpacity: 0.75,
    costumeCard: 104,
    costumeArt: 64,
    oyenCostume: 56,
    oyenCloset: 168,
    closetMinScale: 0.5,
    shopTab: 48,
    shopTabBar: 56,
    shopItemWell: 100,
    shopItemArtWidth: 128,
    shopItemArtHeight: 80,
    shopKittyWell: 108,
    shopKittyArt: 94,
    shopAccessoryWell: 104,
    shopAccessoryArt: 84,
    shopSnackWell: 68,
    shopSnackArtWidth: 52,
    shopSnackArtHeight: 40,
    shopPreviewWidth: 146,
    shopPreviewHeight: 176,
    shopPreviewArt: 126,
    shopPreviewFloor: 104,
    shopPick: 52,
    shopPickArt: 40,
    shopPreviewMinScale: 0.82,
    buyWell: 168,
    buyKittyArt: 140,
    buyAccessoryArt: 136,
    buyItemArtWidth: 220,
    buyItemArtHeight: 130,
    buyButton: 64,
    buyClose: 52,
    shopOwnedChip: 26,
    shopHomeChip: 30,
    shopOwnedMark: 24,
    shopPriceChip: 34,
    shopSnackButton: 44,
    shopStockChip: 22,
    shopRarityChip: 20,
    shopPreviewChip: 22,
    shopPreviewButton: 46,
    roomPlay: 70,
    roomPlayCompact: 60,
    roomMenuButton: 58,
    roomMenuButtonCompact: 52,
    roomCompactHeight: 700,
    roomDecorateGap: 56,
    roomHintBorder: 2.5,
    roomBubbleTail: 14,
    roomPraiseTop: 120,
    roomPraiseInset: 40,
    roomDecorateButton: 44,
    roomZoneChip: 22,
    roomGrip: 24,
    roomItemOutline: 4,
    roomLift: 16,
    roomLiftScale: 1.06,
    roomLiftShadow: 18,
    roomTraySlotWidth: 76,
    roomTraySlotHeight: 64,
    roomTraySlotWidthCompact: 64,
    roomTraySlotHeightCompact: 54,
    roomTrayArtWidth: 56,
    roomTrayArtHeight: 46,
    roomCardTop: 52,
    roomCardAvatar: 60,
    roomCardAvatarArt: 54,
    roomCardAvatarMinWidth: 380,
    roomCardButton: 54,
    roomSnackCardWidth: 94,
    roomSnackCardHeight: 86,
    roomSnackArtWidth: 44,
    roomSnackArtHeight: 28,
    roomSnackArtBox: 30,
    roomStockBadge: 20,
    roomEmptyOpacity: 0.45,
    roomAccessoryArt: 30,
    roomAccessoryCard: 86,
    roomWornTag: 18,
    needTile: 28,
    needLabel: 54,
    needBar: 14,
    needValue: 30,
    roomReactionWidth: 120,
    roomReactionHeight: 60,
    roomReactionRise: 26,
    roomHeaderLogoMinWidth: 360,
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

  /// Tombol "Tonton iklan" dan bayar koin di kartu petunjuk.
  final double hintButton;

  /// Ikon iklan dan koin di tombol kartu petunjuk.
  final double iconCompact;

  /// Opasitas kartu petunjuk yang belum bisa dibuka.
  final double lockedOpacity;

  /// Kartu kostum di Lemari Kostum.
  final double costumeCard;

  /// Kotak Oyen kecil di kartu kostum.
  final double costumeArt;

  /// Oyen di kartu kostum.
  final double oyenCostume;

  /// Oyen pratinjau di Lemari Kostum.
  final double oyenCloset;

  /// Skala terkecil pratinjau lemari di layar pendek (selebihnya digulir).
  final double closetMinScale;

  /// Tinggi satu tab Toko (desain 20).
  final double shopTab;

  /// Tinggi baris tab Toko beserta bantalannya.
  final double shopTabBar;

  /// Kotak gambar di kartu barang (desain 20).
  final double shopItemWell;

  /// Lebar muat gambar barang di kartunya.
  final double shopItemArtWidth;

  /// Tinggi muat gambar barang di kartunya.
  final double shopItemArtHeight;

  /// Kotak gambar di kartu kucing (desain 20).
  final double shopKittyWell;

  /// Sprite kucing di kartu kucing.
  final double shopKittyArt;

  /// Kotak gambar di kartu aksesoris (desain 20).
  final double shopAccessoryWell;

  /// Sprite kucing di kartu aksesoris.
  final double shopAccessoryArt;

  /// Kotak gambar di kartu camilan (desain 20).
  final double shopSnackWell;

  /// Lebar muat gambar camilan di kartunya.
  final double shopSnackArtWidth;

  /// Tinggi muat gambar camilan di kartunya.
  final double shopSnackArtHeight;

  /// Lebar panggung pratinjau aksesoris.
  final double shopPreviewWidth;

  /// Tinggi panggung pratinjau aksesoris.
  final double shopPreviewHeight;

  /// Sprite kucing di panggung pratinjau.
  final double shopPreviewArt;

  /// Garis lantai di panggung pratinjau, dari atas.
  final double shopPreviewFloor;

  /// Tombol pilih kucing di baris "Coba di:".
  final double shopPick;

  /// Sprite kucing di tombol pilih.
  final double shopPickArt;

  /// Skala terkecil panggung pratinjau di layar 360 px (catatan n360).
  final double shopPreviewMinScale;

  /// Kotak ilustrasi di sheet beli (desain 20).
  final double buyWell;

  /// Sprite kucing di sheet beli.
  final double buyKittyArt;

  /// Sprite kucing beraksesoris di sheet beli.
  final double buyAccessoryArt;

  /// Lebar muat gambar barang di sheet beli.
  final double buyItemArtWidth;

  /// Tinggi muat gambar barang di sheet beli.
  final double buyItemArtHeight;

  /// Tombol beli di sheet (desain 20).
  final double buyButton;

  /// Tombol tutup di sheet beli.
  final double buyClose;

  /// Badge "Punyamu" di kartu Toko (desain 20).
  final double shopOwnedChip;

  /// Badge "Tinggal di kamar" di kartu kucing (desain 20).
  final double shopHomeChip;

  /// Centang hijau di kotak gambar kartu yang dimiliki (desain 20).
  final double shopOwnedMark;

  /// Chip "Adopsi - N" dan harga pudar di kartu kucing (desain 20).
  final double shopPriceChip;

  /// Tombol beli di kartu camilan (desain 20).
  final double shopSnackButton;

  /// Chip stok di kartu camilan (desain 20).
  final double shopStockChip;

  /// Badge kelangkaan di kartu aksesoris (desain 20).
  final double shopRarityChip;

  /// Badge di panel pratinjau aksesoris (desain 20).
  final double shopPreviewChip;

  /// Tombol beli, pakai, dan lepas di panel pratinjau (desain 20).
  final double shopPreviewButton;

  /// Tombol Main di panel bawah kamar (desain 19).
  final double roomPlay;

  /// Tombol Main di layar pendek (catatan `n360`).
  final double roomPlayCompact;

  /// Tombol Toko, Aksesoris, dan Pengaturan di panel bawah kamar.
  final double roomMenuButton;

  /// Tombol menu kamar di layar pendek (catatan `n360`).
  final double roomMenuButtonCompact;

  /// Layar di bawah tinggi ini memakai panel kamar ringkas.
  final double roomCompactHeight;

  /// Jarak dari atas header kamar ke tombol Hias (desain: 50 → 106).
  final double roomDecorateGap;

  /// Garis putus-putus bidang kosong kamar baru.
  final double roomHintBorder;

  /// Ekor gelembung ajakan kamar baru.
  final double roomBubbleTail;

  /// Jarak pujian menghias dari bawah status bar (desain: top 164 − 44).
  final double roomPraiseTop;

  /// Jarak kiri-kanan pujian menghias.
  final double roomPraiseInset;

  /// Tombol Hias, Selesai, dan chip petunjuk menghias (`TombolHias.dc.html`).
  final double roomDecorateButton;

  /// Label "Area dinding" dan "Area lantai" saat menghias.
  final double roomZoneChip;

  /// Gagang titik-titik di pojok barang saat menghias.
  final double roomGrip;

  /// Jarak garis putus-putus dari barang saat menghias.
  final double roomItemOutline;

  /// Barang yang diangkat naik sejauh ini (dikali skala gambar).
  final double roomLift;

  /// Barang yang diangkat sedikit membesar.
  final double roomLiftScale;

  /// Tinggi bayangan elips di bawah barang yang diangkat.
  final double roomLiftShadow;

  /// Kotak barang di baki Gudang (`BakiGudang.dc.html`).
  final double roomTraySlotWidth;

  final double roomTraySlotHeight;

  /// Kotak barang Gudang di layar pendek (catatan `n360`).
  final double roomTraySlotWidthCompact;

  final double roomTraySlotHeightCompact;

  /// Gambar barang di kotak Gudang.
  final double roomTrayArtWidth;

  final double roomTrayArtHeight;

  /// Jarak kartu kucing dari bawah status bar (desain: top 96 − status bar 44).
  final double roomCardTop;

  /// Kotak avatar di kartu kucing.
  final double roomCardAvatar;

  /// Sprite kucing di avatar kartu.
  final double roomCardAvatarArt;

  /// Avatar kartu disembunyikan di layar lebih sempit dari ini (catatan `n360`).
  final double roomCardAvatarMinWidth;

  /// Tombol Camilan, Elus, dan Aksesoris di kartu kucing.
  final double roomCardButton;

  /// Kartu camilan di kartu kucing.
  final double roomSnackCardWidth;

  final double roomSnackCardHeight;

  /// Gambar camilan di kartu camilan.
  final double roomSnackArtWidth;

  final double roomSnackArtHeight;

  /// Tinggi tempat gambar camilan.
  final double roomSnackArtBox;

  /// Badge stok "×N" camilan.
  final double roomStockBadge;

  /// Kartu camilan yang stoknya habis.
  final double roomEmptyOpacity;

  /// Ikon aksesoris di kartu kucing.
  final double roomAccessoryArt;

  /// Tinggi minimum kartu aksesoris di kartu kucing.
  final double roomAccessoryCard;

  /// Tag "Dipakai" di kartu aksesoris.
  final double roomWornTag;

  /// Kotak ikon bar kebutuhan (`BarKebutuhan.dc.html`).
  final double needTile;

  /// Lebar label bar kebutuhan.
  final double needLabel;

  /// Tinggi bar kebutuhan.
  final double needBar;

  /// Lebar angka bar kebutuhan.
  final double needValue;

  /// Kotak angka dan hati yang melayang di atas kucing.
  final double roomReactionWidth;

  final double roomReactionHeight;

  /// Seberapa jauh angka reaksi naik sebelum hilang.
  final double roomReactionRise;

  /// Logo header kamar disembunyikan di layar lebih sempit dari ini.
  final double roomHeaderLogoMinWidth;

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
    double? hintButton,
    double? iconCompact,
    double? lockedOpacity,
    double? costumeCard,
    double? costumeArt,
    double? oyenCostume,
    double? oyenCloset,
    double? closetMinScale,
    double? shopTab,
    double? shopTabBar,
    double? shopItemWell,
    double? shopItemArtWidth,
    double? shopItemArtHeight,
    double? shopKittyWell,
    double? shopKittyArt,
    double? shopAccessoryWell,
    double? shopAccessoryArt,
    double? shopSnackWell,
    double? shopSnackArtWidth,
    double? shopSnackArtHeight,
    double? shopPreviewWidth,
    double? shopPreviewHeight,
    double? shopPreviewArt,
    double? shopPreviewFloor,
    double? shopPick,
    double? shopPickArt,
    double? shopPreviewMinScale,
    double? buyWell,
    double? buyKittyArt,
    double? buyAccessoryArt,
    double? buyItemArtWidth,
    double? buyItemArtHeight,
    double? buyButton,
    double? buyClose,
    double? shopOwnedChip,
    double? shopHomeChip,
    double? shopOwnedMark,
    double? shopPriceChip,
    double? shopSnackButton,
    double? shopStockChip,
    double? shopRarityChip,
    double? shopPreviewChip,
    double? shopPreviewButton,
    double? roomPlay,
    double? roomPlayCompact,
    double? roomMenuButton,
    double? roomMenuButtonCompact,
    double? roomCompactHeight,
    double? roomDecorateGap,
    double? roomHintBorder,
    double? roomBubbleTail,
    double? roomPraiseTop,
    double? roomPraiseInset,
    double? roomDecorateButton,
    double? roomZoneChip,
    double? roomGrip,
    double? roomItemOutline,
    double? roomLift,
    double? roomLiftScale,
    double? roomLiftShadow,
    double? roomTraySlotWidth,
    double? roomTraySlotHeight,
    double? roomTraySlotWidthCompact,
    double? roomTraySlotHeightCompact,
    double? roomTrayArtWidth,
    double? roomTrayArtHeight,
    double? roomCardTop,
    double? roomCardAvatar,
    double? roomCardAvatarArt,
    double? roomCardAvatarMinWidth,
    double? roomCardButton,
    double? roomSnackCardWidth,
    double? roomSnackCardHeight,
    double? roomSnackArtWidth,
    double? roomSnackArtHeight,
    double? roomSnackArtBox,
    double? roomStockBadge,
    double? roomEmptyOpacity,
    double? roomAccessoryArt,
    double? roomAccessoryCard,
    double? roomWornTag,
    double? needTile,
    double? needLabel,
    double? needBar,
    double? needValue,
    double? roomReactionWidth,
    double? roomReactionHeight,
    double? roomReactionRise,
    double? roomHeaderLogoMinWidth,
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
      hintButton: hintButton ?? this.hintButton,
      iconCompact: iconCompact ?? this.iconCompact,
      lockedOpacity: lockedOpacity ?? this.lockedOpacity,
      costumeCard: costumeCard ?? this.costumeCard,
      costumeArt: costumeArt ?? this.costumeArt,
      oyenCostume: oyenCostume ?? this.oyenCostume,
      oyenCloset: oyenCloset ?? this.oyenCloset,
      closetMinScale: closetMinScale ?? this.closetMinScale,
      shopTab: shopTab ?? this.shopTab,
      shopTabBar: shopTabBar ?? this.shopTabBar,
      shopItemWell: shopItemWell ?? this.shopItemWell,
      shopItemArtWidth: shopItemArtWidth ?? this.shopItemArtWidth,
      shopItemArtHeight: shopItemArtHeight ?? this.shopItemArtHeight,
      shopKittyWell: shopKittyWell ?? this.shopKittyWell,
      shopKittyArt: shopKittyArt ?? this.shopKittyArt,
      shopAccessoryWell: shopAccessoryWell ?? this.shopAccessoryWell,
      shopAccessoryArt: shopAccessoryArt ?? this.shopAccessoryArt,
      shopSnackWell: shopSnackWell ?? this.shopSnackWell,
      shopSnackArtWidth: shopSnackArtWidth ?? this.shopSnackArtWidth,
      shopSnackArtHeight: shopSnackArtHeight ?? this.shopSnackArtHeight,
      shopPreviewWidth: shopPreviewWidth ?? this.shopPreviewWidth,
      shopPreviewHeight: shopPreviewHeight ?? this.shopPreviewHeight,
      shopPreviewArt: shopPreviewArt ?? this.shopPreviewArt,
      shopPreviewFloor: shopPreviewFloor ?? this.shopPreviewFloor,
      shopPick: shopPick ?? this.shopPick,
      shopPickArt: shopPickArt ?? this.shopPickArt,
      shopPreviewMinScale: shopPreviewMinScale ?? this.shopPreviewMinScale,
      buyWell: buyWell ?? this.buyWell,
      buyKittyArt: buyKittyArt ?? this.buyKittyArt,
      buyAccessoryArt: buyAccessoryArt ?? this.buyAccessoryArt,
      buyItemArtWidth: buyItemArtWidth ?? this.buyItemArtWidth,
      buyItemArtHeight: buyItemArtHeight ?? this.buyItemArtHeight,
      buyButton: buyButton ?? this.buyButton,
      buyClose: buyClose ?? this.buyClose,
      shopOwnedChip: shopOwnedChip ?? this.shopOwnedChip,
      shopHomeChip: shopHomeChip ?? this.shopHomeChip,
      shopOwnedMark: shopOwnedMark ?? this.shopOwnedMark,
      shopPriceChip: shopPriceChip ?? this.shopPriceChip,
      shopSnackButton: shopSnackButton ?? this.shopSnackButton,
      shopStockChip: shopStockChip ?? this.shopStockChip,
      shopRarityChip: shopRarityChip ?? this.shopRarityChip,
      shopPreviewChip: shopPreviewChip ?? this.shopPreviewChip,
      shopPreviewButton: shopPreviewButton ?? this.shopPreviewButton,
      roomPlay: roomPlay ?? this.roomPlay,
      roomPlayCompact: roomPlayCompact ?? this.roomPlayCompact,
      roomMenuButton: roomMenuButton ?? this.roomMenuButton,
      roomMenuButtonCompact:
          roomMenuButtonCompact ?? this.roomMenuButtonCompact,
      roomCompactHeight: roomCompactHeight ?? this.roomCompactHeight,
      roomDecorateGap: roomDecorateGap ?? this.roomDecorateGap,
      roomHintBorder: roomHintBorder ?? this.roomHintBorder,
      roomBubbleTail: roomBubbleTail ?? this.roomBubbleTail,
      roomPraiseTop: roomPraiseTop ?? this.roomPraiseTop,
      roomPraiseInset: roomPraiseInset ?? this.roomPraiseInset,
      roomDecorateButton: roomDecorateButton ?? this.roomDecorateButton,
      roomZoneChip: roomZoneChip ?? this.roomZoneChip,
      roomGrip: roomGrip ?? this.roomGrip,
      roomItemOutline: roomItemOutline ?? this.roomItemOutline,
      roomLift: roomLift ?? this.roomLift,
      roomLiftScale: roomLiftScale ?? this.roomLiftScale,
      roomLiftShadow: roomLiftShadow ?? this.roomLiftShadow,
      roomTraySlotWidth: roomTraySlotWidth ?? this.roomTraySlotWidth,
      roomTraySlotHeight: roomTraySlotHeight ?? this.roomTraySlotHeight,
      roomTraySlotWidthCompact:
          roomTraySlotWidthCompact ?? this.roomTraySlotWidthCompact,
      roomTraySlotHeightCompact:
          roomTraySlotHeightCompact ?? this.roomTraySlotHeightCompact,
      roomTrayArtWidth: roomTrayArtWidth ?? this.roomTrayArtWidth,
      roomTrayArtHeight: roomTrayArtHeight ?? this.roomTrayArtHeight,
      roomCardTop: roomCardTop ?? this.roomCardTop,
      roomCardAvatar: roomCardAvatar ?? this.roomCardAvatar,
      roomCardAvatarArt: roomCardAvatarArt ?? this.roomCardAvatarArt,
      roomCardAvatarMinWidth:
          roomCardAvatarMinWidth ?? this.roomCardAvatarMinWidth,
      roomCardButton: roomCardButton ?? this.roomCardButton,
      roomSnackCardWidth: roomSnackCardWidth ?? this.roomSnackCardWidth,
      roomSnackCardHeight: roomSnackCardHeight ?? this.roomSnackCardHeight,
      roomSnackArtWidth: roomSnackArtWidth ?? this.roomSnackArtWidth,
      roomSnackArtHeight: roomSnackArtHeight ?? this.roomSnackArtHeight,
      roomSnackArtBox: roomSnackArtBox ?? this.roomSnackArtBox,
      roomStockBadge: roomStockBadge ?? this.roomStockBadge,
      roomEmptyOpacity: roomEmptyOpacity ?? this.roomEmptyOpacity,
      roomAccessoryArt: roomAccessoryArt ?? this.roomAccessoryArt,
      roomAccessoryCard: roomAccessoryCard ?? this.roomAccessoryCard,
      roomWornTag: roomWornTag ?? this.roomWornTag,
      needTile: needTile ?? this.needTile,
      needLabel: needLabel ?? this.needLabel,
      needBar: needBar ?? this.needBar,
      needValue: needValue ?? this.needValue,
      roomReactionWidth: roomReactionWidth ?? this.roomReactionWidth,
      roomReactionHeight: roomReactionHeight ?? this.roomReactionHeight,
      roomReactionRise: roomReactionRise ?? this.roomReactionRise,
      roomHeaderLogoMinWidth:
          roomHeaderLogoMinWidth ?? this.roomHeaderLogoMinWidth,
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
      hintButton: d(hintButton, other.hintButton),
      iconCompact: d(iconCompact, other.iconCompact),
      lockedOpacity: d(lockedOpacity, other.lockedOpacity),
      costumeCard: d(costumeCard, other.costumeCard),
      costumeArt: d(costumeArt, other.costumeArt),
      oyenCostume: d(oyenCostume, other.oyenCostume),
      oyenCloset: d(oyenCloset, other.oyenCloset),
      closetMinScale: d(closetMinScale, other.closetMinScale),
      shopTab: d(shopTab, other.shopTab),
      shopTabBar: d(shopTabBar, other.shopTabBar),
      shopItemWell: d(shopItemWell, other.shopItemWell),
      shopItemArtWidth: d(shopItemArtWidth, other.shopItemArtWidth),
      shopItemArtHeight: d(shopItemArtHeight, other.shopItemArtHeight),
      shopKittyWell: d(shopKittyWell, other.shopKittyWell),
      shopKittyArt: d(shopKittyArt, other.shopKittyArt),
      shopAccessoryWell: d(shopAccessoryWell, other.shopAccessoryWell),
      shopAccessoryArt: d(shopAccessoryArt, other.shopAccessoryArt),
      shopSnackWell: d(shopSnackWell, other.shopSnackWell),
      shopSnackArtWidth: d(shopSnackArtWidth, other.shopSnackArtWidth),
      shopSnackArtHeight: d(shopSnackArtHeight, other.shopSnackArtHeight),
      shopPreviewWidth: d(shopPreviewWidth, other.shopPreviewWidth),
      shopPreviewHeight: d(shopPreviewHeight, other.shopPreviewHeight),
      shopPreviewArt: d(shopPreviewArt, other.shopPreviewArt),
      shopPreviewFloor: d(shopPreviewFloor, other.shopPreviewFloor),
      shopPick: d(shopPick, other.shopPick),
      shopPickArt: d(shopPickArt, other.shopPickArt),
      shopPreviewMinScale: d(shopPreviewMinScale, other.shopPreviewMinScale),
      buyWell: d(buyWell, other.buyWell),
      buyKittyArt: d(buyKittyArt, other.buyKittyArt),
      buyAccessoryArt: d(buyAccessoryArt, other.buyAccessoryArt),
      buyItemArtWidth: d(buyItemArtWidth, other.buyItemArtWidth),
      buyItemArtHeight: d(buyItemArtHeight, other.buyItemArtHeight),
      buyButton: d(buyButton, other.buyButton),
      buyClose: d(buyClose, other.buyClose),
      shopOwnedChip: d(shopOwnedChip, other.shopOwnedChip),
      shopHomeChip: d(shopHomeChip, other.shopHomeChip),
      shopOwnedMark: d(shopOwnedMark, other.shopOwnedMark),
      shopPriceChip: d(shopPriceChip, other.shopPriceChip),
      shopSnackButton: d(shopSnackButton, other.shopSnackButton),
      shopStockChip: d(shopStockChip, other.shopStockChip),
      shopRarityChip: d(shopRarityChip, other.shopRarityChip),
      shopPreviewChip: d(shopPreviewChip, other.shopPreviewChip),
      shopPreviewButton: d(shopPreviewButton, other.shopPreviewButton),
      roomPlay: d(roomPlay, other.roomPlay),
      roomPlayCompact: d(roomPlayCompact, other.roomPlayCompact),
      roomMenuButton: d(roomMenuButton, other.roomMenuButton),
      roomMenuButtonCompact: d(
        roomMenuButtonCompact,
        other.roomMenuButtonCompact,
      ),
      roomCompactHeight: d(roomCompactHeight, other.roomCompactHeight),
      roomDecorateGap: d(roomDecorateGap, other.roomDecorateGap),
      roomHintBorder: d(roomHintBorder, other.roomHintBorder),
      roomBubbleTail: d(roomBubbleTail, other.roomBubbleTail),
      roomPraiseTop: d(roomPraiseTop, other.roomPraiseTop),
      roomPraiseInset: d(roomPraiseInset, other.roomPraiseInset),
      roomDecorateButton: d(roomDecorateButton, other.roomDecorateButton),
      roomZoneChip: d(roomZoneChip, other.roomZoneChip),
      roomGrip: d(roomGrip, other.roomGrip),
      roomItemOutline: d(roomItemOutline, other.roomItemOutline),
      roomLift: d(roomLift, other.roomLift),
      roomLiftScale: d(roomLiftScale, other.roomLiftScale),
      roomLiftShadow: d(roomLiftShadow, other.roomLiftShadow),
      roomTraySlotWidth: d(roomTraySlotWidth, other.roomTraySlotWidth),
      roomTraySlotHeight: d(roomTraySlotHeight, other.roomTraySlotHeight),
      roomTraySlotWidthCompact: d(
        roomTraySlotWidthCompact,
        other.roomTraySlotWidthCompact,
      ),
      roomTraySlotHeightCompact: d(
        roomTraySlotHeightCompact,
        other.roomTraySlotHeightCompact,
      ),
      roomTrayArtWidth: d(roomTrayArtWidth, other.roomTrayArtWidth),
      roomTrayArtHeight: d(roomTrayArtHeight, other.roomTrayArtHeight),
      roomCardTop: d(roomCardTop, other.roomCardTop),
      roomCardAvatar: d(roomCardAvatar, other.roomCardAvatar),
      roomCardAvatarArt: d(roomCardAvatarArt, other.roomCardAvatarArt),
      roomCardAvatarMinWidth: d(
        roomCardAvatarMinWidth,
        other.roomCardAvatarMinWidth,
      ),
      roomCardButton: d(roomCardButton, other.roomCardButton),
      roomSnackCardWidth: d(roomSnackCardWidth, other.roomSnackCardWidth),
      roomSnackCardHeight: d(roomSnackCardHeight, other.roomSnackCardHeight),
      roomSnackArtWidth: d(roomSnackArtWidth, other.roomSnackArtWidth),
      roomSnackArtHeight: d(roomSnackArtHeight, other.roomSnackArtHeight),
      roomSnackArtBox: d(roomSnackArtBox, other.roomSnackArtBox),
      roomStockBadge: d(roomStockBadge, other.roomStockBadge),
      roomEmptyOpacity: d(roomEmptyOpacity, other.roomEmptyOpacity),
      roomAccessoryArt: d(roomAccessoryArt, other.roomAccessoryArt),
      roomAccessoryCard: d(roomAccessoryCard, other.roomAccessoryCard),
      roomWornTag: d(roomWornTag, other.roomWornTag),
      needTile: d(needTile, other.needTile),
      needLabel: d(needLabel, other.needLabel),
      needBar: d(needBar, other.needBar),
      needValue: d(needValue, other.needValue),
      roomReactionWidth: d(roomReactionWidth, other.roomReactionWidth),
      roomReactionHeight: d(roomReactionHeight, other.roomReactionHeight),
      roomReactionRise: d(roomReactionRise, other.roomReactionRise),
      roomHeaderLogoMinWidth: d(
        roomHeaderLogoMinWidth,
        other.roomHeaderLogoMinWidth,
      ),
    );
  }
}
