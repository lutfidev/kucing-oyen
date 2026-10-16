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
    );
  }
}
