import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Radius sudut (kartu "Jarak, radius, bayangan").
///
/// 8 petak · 14 ikon · 20 tombol · 24 tombol utama besar · 28 sheet · pill.
/// [slot], [card], dan [tray] berasal dari komponen di layar desain.
@immutable
class KoRadius extends ThemeExtension<KoRadius> {
  const KoRadius({
    required this.tile,
    required this.icon,
    required this.slot,
    required this.button,
    required this.card,
    required this.tray,
    required this.primary,
    required this.sheet,
    required this.pill,
    required this.control,
    required this.art,
    required this.stat,
    required this.statCompact,
    required this.avatar,
    required this.boss,
    required this.tag,
  });

  static const standard = KoRadius(
    tile: 8,
    icon: 14,
    slot: 16,
    button: 20,
    card: 20,
    tray: 22,
    primary: 24,
    sheet: 28,
    pill: 999,
    control: 18,
    art: 28,
    stat: 18,
    statCompact: 14,
    avatar: 16,
    boss: 30,
    tag: 10,
  );

  /// Petak papan.
  final double tile;

  /// Tombol ikon 44 px dan chip gelap.
  final double icon;

  /// Slot baki 64 px.
  final double slot;

  /// Tombol 64 px.
  final double button;

  /// Kartu (kartu aturan).
  final double card;

  /// Panel baki di bawah papan.
  final double tray;

  /// Tombol utama besar ("Main", "Bangunkan Oyen").
  final double primary;

  /// Bottom sheet.
  final double sheet;

  /// Chip, badge, tombol bulat.
  final double pill;

  /// Kotak caption dan tombol kontrol fase jalan.
  final double control;

  /// Kartu ilustrasi layar hasil.
  final double art;

  /// Kotak angka di layar Berhasil dan versi kecilnya di layar vas pecah.
  final double stat;
  final double statCompact;

  /// Kotak Oyen tidur di kartu pesan layar gagal.
  final double avatar;

  /// Kotak level bos.
  final double boss;

  /// Label nama bos.
  final double tag;

  @override
  KoRadius copyWith({
    double? tile,
    double? icon,
    double? slot,
    double? button,
    double? card,
    double? tray,
    double? primary,
    double? sheet,
    double? pill,
    double? control,
    double? art,
    double? stat,
    double? statCompact,
    double? avatar,
    double? boss,
    double? tag,
  }) {
    return KoRadius(
      tile: tile ?? this.tile,
      icon: icon ?? this.icon,
      slot: slot ?? this.slot,
      button: button ?? this.button,
      card: card ?? this.card,
      tray: tray ?? this.tray,
      primary: primary ?? this.primary,
      sheet: sheet ?? this.sheet,
      pill: pill ?? this.pill,
      control: control ?? this.control,
      art: art ?? this.art,
      stat: stat ?? this.stat,
      statCompact: statCompact ?? this.statCompact,
      avatar: avatar ?? this.avatar,
      boss: boss ?? this.boss,
      tag: tag ?? this.tag,
    );
  }

  @override
  KoRadius lerp(KoRadius? other, double t) {
    if (other == null) return this;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return KoRadius(
      tile: d(tile, other.tile),
      icon: d(icon, other.icon),
      slot: d(slot, other.slot),
      button: d(button, other.button),
      card: d(card, other.card),
      tray: d(tray, other.tray),
      primary: d(primary, other.primary),
      sheet: d(sheet, other.sheet),
      pill: d(pill, other.pill),
      control: d(control, other.control),
      art: d(art, other.art),
      stat: d(stat, other.stat),
      statCompact: d(statCompact, other.statCompact),
      avatar: d(avatar, other.avatar),
      boss: d(boss, other.boss),
      tag: d(tag, other.tag),
    );
  }
}
