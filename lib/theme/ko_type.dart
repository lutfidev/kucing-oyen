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
  });

  static const standard = KoType(
    display: TextStyle(
      fontFamily: KoFonts.fredoka,
      fontFamilyFallback: _fredokaFallback,
      fontSize: 46,
      fontWeight: FontWeight.w700,
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
  );

  /// Fredoka 700/46: "Berhasil!".
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
    );
  }
}

/// Fredoka tidak punya semua glyph (panah, ↻); Nunito sebagai cadangan.
const _fredokaFallback = [KoFonts.nunito];
