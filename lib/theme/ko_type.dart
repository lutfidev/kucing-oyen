import 'package:flutter/material.dart';

/// Nama keluarga font yang dibundel di `assets/fonts/` (lihat `pubspec.yaml`).
abstract final class KoFonts {
  /// Judul, angka, tombol (500–700).
  static const fredoka = 'Fredoka';

  /// Teks dan label (600–800).
  static const nunito = 'Nunito';
}

/// Skala tipografi (kartu "Tipografi" di lembar token).
///
/// Gaya tidak membawa warna; warna diwarisi dari [DefaultTextStyle] atau
/// ditambahkan lewat `copyWith(color: ...)`. Teks overline ditulis kapital
/// oleh pemanggil, karena Flutter tidak punya `text-transform`.
@immutable
class KoType extends ThemeExtension<KoType> {
  const KoType({
    required this.display,
    required this.title,
    required this.heading,
    required this.number,
    required this.body,
    required this.label,
    required this.overline,
    required this.buttonHero,
    required this.button,
    required this.chip,
    required this.numberSmall,
    required this.badge,
    required this.labelSmall,
    required this.chipLabel,
    required this.bodySmall,
    required this.caption,
    required this.numberMedium,
    required this.numberBadge,
    required this.paragraph,
    required this.controlLabel,
    required this.overlineLarge,
    required this.headline,
    required this.headlineSmall,
    required this.numberCompact,
    required this.logoSmall,
    required this.logo,
    required this.bodyLarge,
    required this.numberChip,
    required this.numberChipSmall,
    required this.tag,
    required this.tagSmall,
    required this.headingLarge,
    required this.paragraphSmall,
    required this.numberTick,
    required this.cardTitle,
    required this.cardBody,
    required this.cardBodyStrong,
    required this.numberRule,
    required this.dialogTitle,
    required this.numberCoin,
    required this.numberTier,
    required this.hintReveal,
    required this.numberCoinLarge,
    required this.cardLabel,
  });

  static const standard = KoType(
    display: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 46,
      fontWeight: FontWeight.w700,
      height: 1.05,
    ),
    title: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 26,
      fontWeight: FontWeight.w700,
    ),
    heading: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    number: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 30,
      fontWeight: FontWeight.w700,
    ),
    body: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    label: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
    overline: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
    ),
    buttonHero: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 34,
      fontWeight: FontWeight.w700,
    ),
    button: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    chip: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    numberSmall: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    badge: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 13,
      fontWeight: FontWeight.w800,
    ),
    chipLabel: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
    bodySmall: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    caption: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    numberMedium: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    numberBadge: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    paragraph: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    controlLabel: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    overlineLarge: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
    ),
    headline: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.1,
    ),
    headlineSmall: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.1,
    ),
    numberCompact: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    logoSmall: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 54,
      fontWeight: FontWeight.w700,
      height: 0.88,
      letterSpacing: -0.5,
    ),
    logo: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 82,
      fontWeight: FontWeight.w700,
      height: 0.88,
      letterSpacing: -0.5,
    ),
    bodyLarge: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    numberChip: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    numberChipSmall: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    tag: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
    ),
    tagSmall: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
    headingLarge: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.1,
    ),
    paragraphSmall: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    numberTick: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    cardTitle: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    cardBody: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    cardBodyStrong: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 13.5,
      fontWeight: FontWeight.w800,
      height: 1.4,
    ),
    numberRule: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    dialogTitle: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    numberCoin: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    numberTier: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    hintReveal: TextStyle(
      fontFamily: KoFonts.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      height: 1.35,
    ),
    numberCoinLarge: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    cardLabel: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Fredoka 700/46, tinggi baris 1,05: "Berhasil!" (layar 06; lembar
  /// token menulis 1).
  final TextStyle display;

  /// Fredoka 700/26: judul sheet ("Aturan Oyen"), tombol utama besar.
  final TextStyle title;

  /// Fredoka 600/20: judul level di bar atas, tombol sekunder.
  final TextStyle heading;

  /// Fredoka 700/30: angka besar.
  final TextStyle number;

  /// Nunito 700/15: teks biasa.
  final TextStyle body;

  /// Nunito 800/15: label tombol kecil ("Lemari Kostum", "Aturan").
  final TextStyle label;

  /// Nunito 800/12, jarak huruf 1.2: "BABAK 1".
  final TextStyle overline;

  /// Fredoka 700/34: tombol "Main" di Beranda.
  final TextStyle buttonHero;

  /// Fredoka 700/22: tombol utama dan sukses ukuran biasa.
  final TextStyle button;

  /// Fredoka 600/18: angka di chip ("14/60").
  final TextStyle chip;

  /// Fredoka 700/20: angka di chip gelap ("Langkah 1").
  final TextStyle numberSmall;

  /// Fredoka 600/14: angka sisa di slot baki.
  final TextStyle badge;

  /// Nunito 800/13: label chip gelap ("Langkah"), petunjuk baki ("Taruh di
  /// petak").
  final TextStyle labelSmall;

  /// Nunito 800/14: chip target bintang ("pakai 2 benda").
  final TextStyle chipLabel;

  /// Nunito 700/14: teks kecil ("Level ini belum butuh benda.").
  final TextStyle bodySmall;

  /// Nunito 700/12: keterangan kecil ("yang menyala").
  final TextStyle caption;

  /// Fredoka 700/24: angka "Langkah" di bar atas fase jalan.
  final TextStyle numberMedium;

  /// Fredoka 700/15: nomor langkah di lingkaran caption.
  final TextStyle numberBadge;

  /// Nunito 700/15, tinggi baris 1,3: caption langkah fase jalan.
  final TextStyle paragraph;

  /// Nunito 700/13: keterangan tombol putar ("Jeda", "Lanjutkan").
  final TextStyle controlLabel;

  /// Nunito 800/13, jarak huruf 1.2: "LEVEL 13 · VAS IBU" di layar hasil.
  final TextStyle overlineLarge;

  /// Fredoka 700/32, tinggi baris 1,1: "Sampai sih... tapi vas Ibu?".
  final TextStyle headline;

  /// Fredoka 700/28, tinggi baris 1,1: "Oyen bosan mondar-mandir.".
  final TextStyle headlineSmall;

  /// Fredoka 700/22: angka kotak kecil di layar vas pecah ("10 langkah").
  final TextStyle numberCompact;

  /// Fredoka 700/54 dan 700/82, tinggi baris 0,88: logo "Kucing" dan "Oren"
  /// di Beranda.
  final TextStyle logoSmall;

  final TextStyle logo;

  /// Nunito 700/16: tagline Beranda.
  final TextStyle bodyLarge;

  /// Fredoka 600/22: total bintang di Beranda ("31/60").
  final TextStyle numberChip;

  /// Fredoka 600/15: bintang babak di kartu babak ("26/30").
  final TextStyle numberChipSmall;

  /// Nunito 800/12,5: badge "Selesai" di kartu babak.
  final TextStyle tag;

  /// Nunito 800/12: label "Main" di atas node level saat ini.
  final TextStyle tagSmall;

  /// Fredoka 700/24, tinggi baris 1,1: judul "Putar Ulang" (desain 09).
  final TextStyle headingLarge;

  /// Nunito 700/14, tinggi baris 1,3: caption putar ulang.
  final TextStyle paragraphSmall;

  /// Fredoka 600/13: angka di bawah slider waktu putar ulang.
  final TextStyle numberTick;

  /// Fredoka 600/17, tinggi baris 1,2: judul kartu aturan.
  final TextStyle cardTitle;

  /// Nunito 700/13,5, tinggi baris 1,35: isi kartu aturan.
  final TextStyle cardBody;

  /// Nunito 800/13,5, tinggi baris 1,4: baris tebal kartu aturan
  /// ("depan → searah jarum jam ↻ → ...").
  final TextStyle cardBodyStrong;

  /// Fredoka 700/14: nomor kartu aturan.
  final TextStyle numberRule;

  /// Fredoka 600/22, tinggi baris 1,25: teks besar kartu tutorial.
  final TextStyle dialogTitle;

  /// Fredoka 600/16: saldo koin di sheet Petunjuk.
  final TextStyle numberCoin;

  /// Fredoka 700/16: nomor tingkat petunjuk.
  final TextStyle numberTier;

  /// Nunito 800/14, tinggi baris 1,35: teks petunjuk yang dibuka.
  final TextStyle hintReveal;

  /// Fredoka 600/17: chip koin Lemari Kostum.
  final TextStyle numberCoinLarge;

  /// Fredoka 600/16: nama kostum di kartu Lemari Kostum.
  final TextStyle cardLabel;

  @override
  KoType copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? number,
    TextStyle? body,
    TextStyle? label,
    TextStyle? overline,
    TextStyle? buttonHero,
    TextStyle? button,
    TextStyle? chip,
    TextStyle? numberSmall,
    TextStyle? badge,
    TextStyle? labelSmall,
    TextStyle? chipLabel,
    TextStyle? bodySmall,
    TextStyle? caption,
    TextStyle? numberMedium,
    TextStyle? numberBadge,
    TextStyle? paragraph,
    TextStyle? controlLabel,
    TextStyle? overlineLarge,
    TextStyle? headline,
    TextStyle? headlineSmall,
    TextStyle? numberCompact,
    TextStyle? logoSmall,
    TextStyle? logo,
    TextStyle? bodyLarge,
    TextStyle? numberChip,
    TextStyle? numberChipSmall,
    TextStyle? tag,
    TextStyle? tagSmall,
    TextStyle? headingLarge,
    TextStyle? paragraphSmall,
    TextStyle? numberTick,
    TextStyle? cardTitle,
    TextStyle? cardBody,
    TextStyle? cardBodyStrong,
    TextStyle? numberRule,
    TextStyle? dialogTitle,
    TextStyle? numberCoin,
    TextStyle? numberTier,
    TextStyle? hintReveal,
    TextStyle? numberCoinLarge,
    TextStyle? cardLabel,
  }) {
    return KoType(
      display: display ?? this.display,
      title: title ?? this.title,
      heading: heading ?? this.heading,
      number: number ?? this.number,
      body: body ?? this.body,
      label: label ?? this.label,
      overline: overline ?? this.overline,
      buttonHero: buttonHero ?? this.buttonHero,
      button: button ?? this.button,
      chip: chip ?? this.chip,
      numberSmall: numberSmall ?? this.numberSmall,
      badge: badge ?? this.badge,
      labelSmall: labelSmall ?? this.labelSmall,
      chipLabel: chipLabel ?? this.chipLabel,
      bodySmall: bodySmall ?? this.bodySmall,
      caption: caption ?? this.caption,
      numberMedium: numberMedium ?? this.numberMedium,
      numberBadge: numberBadge ?? this.numberBadge,
      paragraph: paragraph ?? this.paragraph,
      controlLabel: controlLabel ?? this.controlLabel,
      overlineLarge: overlineLarge ?? this.overlineLarge,
      headline: headline ?? this.headline,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      numberCompact: numberCompact ?? this.numberCompact,
      logoSmall: logoSmall ?? this.logoSmall,
      logo: logo ?? this.logo,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      numberChip: numberChip ?? this.numberChip,
      numberChipSmall: numberChipSmall ?? this.numberChipSmall,
      tag: tag ?? this.tag,
      tagSmall: tagSmall ?? this.tagSmall,
      headingLarge: headingLarge ?? this.headingLarge,
      paragraphSmall: paragraphSmall ?? this.paragraphSmall,
      numberTick: numberTick ?? this.numberTick,
      cardTitle: cardTitle ?? this.cardTitle,
      cardBody: cardBody ?? this.cardBody,
      cardBodyStrong: cardBodyStrong ?? this.cardBodyStrong,
      numberRule: numberRule ?? this.numberRule,
      dialogTitle: dialogTitle ?? this.dialogTitle,
      numberCoin: numberCoin ?? this.numberCoin,
      numberTier: numberTier ?? this.numberTier,
      hintReveal: hintReveal ?? this.hintReveal,
      numberCoinLarge: numberCoinLarge ?? this.numberCoinLarge,
      cardLabel: cardLabel ?? this.cardLabel,
    );
  }

  @override
  KoType lerp(KoType? other, double t) {
    if (other == null) return this;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return KoType(
      display: s(display, other.display),
      title: s(title, other.title),
      heading: s(heading, other.heading),
      number: s(number, other.number),
      body: s(body, other.body),
      label: s(label, other.label),
      overline: s(overline, other.overline),
      buttonHero: s(buttonHero, other.buttonHero),
      button: s(button, other.button),
      chip: s(chip, other.chip),
      numberSmall: s(numberSmall, other.numberSmall),
      badge: s(badge, other.badge),
      labelSmall: s(labelSmall, other.labelSmall),
      chipLabel: s(chipLabel, other.chipLabel),
      bodySmall: s(bodySmall, other.bodySmall),
      caption: s(caption, other.caption),
      numberMedium: s(numberMedium, other.numberMedium),
      numberBadge: s(numberBadge, other.numberBadge),
      paragraph: s(paragraph, other.paragraph),
      controlLabel: s(controlLabel, other.controlLabel),
      overlineLarge: s(overlineLarge, other.overlineLarge),
      headline: s(headline, other.headline),
      headlineSmall: s(headlineSmall, other.headlineSmall),
      numberCompact: s(numberCompact, other.numberCompact),
      logoSmall: s(logoSmall, other.logoSmall),
      logo: s(logo, other.logo),
      bodyLarge: s(bodyLarge, other.bodyLarge),
      numberChip: s(numberChip, other.numberChip),
      numberChipSmall: s(numberChipSmall, other.numberChipSmall),
      tag: s(tag, other.tag),
      tagSmall: s(tagSmall, other.tagSmall),
      headingLarge: s(headingLarge, other.headingLarge),
      paragraphSmall: s(paragraphSmall, other.paragraphSmall),
      numberTick: s(numberTick, other.numberTick),
      cardTitle: s(cardTitle, other.cardTitle),
      cardBody: s(cardBody, other.cardBody),
      cardBodyStrong: s(cardBodyStrong, other.cardBodyStrong),
      numberRule: s(numberRule, other.numberRule),
      dialogTitle: s(dialogTitle, other.dialogTitle),
      numberCoin: s(numberCoin, other.numberCoin),
      numberTier: s(numberTier, other.numberTier),
      hintReveal: s(hintReveal, other.hintReveal),
      numberCoinLarge: s(numberCoinLarge, other.numberCoinLarge),
      cardLabel: s(cardLabel, other.cardLabel),
    );
  }
}

/// Fredoka tidak punya semua glyph (panah, ↻); Nunito sebagai cadangan.
const _fredokaFallback = [KoFonts.nunito];
