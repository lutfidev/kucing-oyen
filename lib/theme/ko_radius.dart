import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Radius sudut (kartu "Jarak, radius, bayangan").
///
/// 8 petak · 14 ikon · 20 tombol · 24 tombol utama besar · 28 sheet · pill.
/// [slot] dan [card] berasal dari komponen di layar desain.
@immutable
class KoRadius extends ThemeExtension<KoRadius> {
  const KoRadius({
    required this.tile,
    required this.icon,
    required this.slot,
    required this.button,
    required this.card,
    required this.primary,
    required this.sheet,
    required this.pill,
  });

  static const standard = KoRadius(
    tile: 8,
    icon: 14,
    slot: 16,
    button: 20,
    card: 20,
    primary: 24,
    sheet: 28,
    pill: 999,
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

  /// Tombol utama besar ("Main", "Bangunkan Oyen").
  final double primary;

  /// Bottom sheet.
  final double sheet;

  /// Chip, badge, tombol bulat.
  final double pill;

  @override
  KoRadius copyWith({
    double? tile,
    double? icon,
    double? slot,
    double? button,
    double? card,
    double? primary,
    double? sheet,
    double? pill,
  }) {
    return KoRadius(
      tile: tile ?? this.tile,
      icon: icon ?? this.icon,
      slot: slot ?? this.slot,
      button: button ?? this.button,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      sheet: sheet ?? this.sheet,
      pill: pill ?? this.pill,
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
      primary: d(primary, other.primary),
      sheet: d(sheet, other.sheet),
      pill: d(pill, other.pill),
    );
  }
}
