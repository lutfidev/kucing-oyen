import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'ko_colors.dart';

/// Bayangan (kartu "Jarak, radius, bayangan").
///
/// Tombol memakai bayangan padat tanpa blur ("press": 0 6 0 orangeDeep) yang
/// hilang saat ditekan; tingginya disimpan sebagai angka di sini, warnanya
/// ikut varian tombol. Kartu dan papan memakai bayangan lembut.
@immutable
class KoShadow extends ThemeExtension<KoShadow> {
  const KoShadow({
    required this.pressHero,
    required this.press,
    required this.pressSecondary,
    required this.pressIcon,
    required this.pressNode,
    required this.card,
    required this.tray,
    required this.board,
    required this.glow,
    required this.glowStrong,
    required this.badgeRing,
    required this.glowPlay,
    required this.node,
    required this.logo,
    required this.sheet,
    required this.dialog,
    required this.coinChip,
  });

  factory KoShadow.from(KoColors c) => KoShadow(
    pressHero: 7,
    press: 6,
    pressSecondary: 4,
    pressIcon: 3,
    pressNode: 5,
    card: [
      BoxShadow(
        color: c.shadowCard,
        offset: const Offset(0, 6),
        blurRadius: 16,
      ),
    ],
    tray: [
      BoxShadow(
        color: c.shadowTray,
        offset: const Offset(0, 6),
        blurRadius: 16,
      ),
    ],
    board: [
      BoxShadow(color: c.boardRing, spreadRadius: 4),
      BoxShadow(
        color: c.shadowBoard,
        offset: const Offset(0, 14),
        blurRadius: 28,
      ),
    ],
    glow: [
      BoxShadow(
        color: c.shadowGlow,
        offset: const Offset(0, 16),
        blurRadius: 28,
      ),
    ],
    glowStrong: [
      BoxShadow(
        color: c.shadowGlowStrong,
        offset: const Offset(0, 16),
        blurRadius: 28,
      ),
    ],
    badgeRing: [BoxShadow(color: c.surface, spreadRadius: 2)],
    glowPlay: [
      BoxShadow(
        color: c.shadowGlow,
        offset: const Offset(0, 14),
        blurRadius: 24,
      ),
    ],
    node: [
      BoxShadow(
        color: c.shadowNode,
        offset: const Offset(0, 10),
        blurRadius: 16,
      ),
    ],
    logo: [Shadow(color: c.ink, offset: const Offset(0, 4))],
    sheet: [
      BoxShadow(
        color: c.shadowSheet,
        offset: const Offset(0, -10),
        blurRadius: 30,
      ),
    ],
    dialog: [
      BoxShadow(
        color: c.shadowDialog,
        offset: const Offset(0, 16),
        blurRadius: 30,
      ),
    ],
    coinChip: [
      BoxShadow(color: c.line, offset: const Offset(0, 2)),
      BoxShadow(
        color: c.shadowTray,
        offset: const Offset(0, 6),
        blurRadius: 14,
      ),
    ],
  );

  static final standard = KoShadow.from(KoColors.standard);

  /// Tinggi bayangan padat tombol utama besar (0 7 0).
  final double pressHero;

  /// Tinggi bayangan padat tombol utama dan sukses (0 6 0).
  final double press;

  /// Tinggi bayangan padat tombol sekunder (0 4 0).
  final double pressSecondary;

  /// Tinggi bayangan padat tombol ikon dan slot baki (0 3 0).
  final double pressIcon;

  /// Tinggi bayangan padat node level di peta (0 5 0).
  final double pressNode;

  /// Kartu: 0 6 16, 14%.
  final List<BoxShadow> card;

  /// Panel baki: 0 6 16, 10%.
  final List<BoxShadow> tray;

  /// Papan: cincin 4 px + 0 14 28.
  final List<BoxShadow> board;

  /// Sinar di bawah tombol utama besar: 0 16 28, 25% ("Bangunkan Oyen")
  /// atau 28% ("Main").
  final List<BoxShadow> glow;
  final List<BoxShadow> glowStrong;

  /// Cincin 2 px warna permukaan di sekeliling badge angka.
  final List<BoxShadow> badgeRing;

  /// Sinar di bawah tombol bulat Jeda/Lanjutkan: 0 14 24, 25%.
  final List<BoxShadow> glowPlay;

  /// Bayangan lembut node level yang sudah selesai: 0 10 16, 22%.
  final List<BoxShadow> node;

  /// Bayangan padat teks "Oren" di logo Beranda (0 4 0 tinta).
  final List<Shadow> logo;

  /// Sheet aturan: 0 -10 30, 30%.
  final List<BoxShadow> sheet;

  /// Kartu tutorial: 0 16 30, hitam 30%.
  final List<BoxShadow> dialog;

  /// Chip saldo koin di Beranda: garis padat 2 px dan bayangan lembut.
  final List<BoxShadow> coinChip;

  /// Bayangan padat setinggi [depth] (tanpa blur).
  static List<BoxShadow> solid(Color color, double depth) => [
    BoxShadow(color: color, offset: Offset(0, depth)),
  ];

  @override
  KoShadow copyWith({
    double? pressHero,
    double? press,
    double? pressSecondary,
    double? pressIcon,
    double? pressNode,
    List<BoxShadow>? card,
    List<BoxShadow>? tray,
    List<BoxShadow>? board,
    List<BoxShadow>? glow,
    List<BoxShadow>? glowStrong,
    List<BoxShadow>? badgeRing,
    List<BoxShadow>? glowPlay,
    List<BoxShadow>? node,
    List<Shadow>? logo,
    List<BoxShadow>? sheet,
    List<BoxShadow>? dialog,
    List<BoxShadow>? coinChip,
  }) {
    return KoShadow(
      pressHero: pressHero ?? this.pressHero,
      press: press ?? this.press,
      pressSecondary: pressSecondary ?? this.pressSecondary,
      pressIcon: pressIcon ?? this.pressIcon,
      pressNode: pressNode ?? this.pressNode,
      card: card ?? this.card,
      tray: tray ?? this.tray,
      board: board ?? this.board,
      glow: glow ?? this.glow,
      glowStrong: glowStrong ?? this.glowStrong,
      badgeRing: badgeRing ?? this.badgeRing,
      glowPlay: glowPlay ?? this.glowPlay,
      node: node ?? this.node,
      logo: logo ?? this.logo,
      sheet: sheet ?? this.sheet,
      dialog: dialog ?? this.dialog,
      coinChip: coinChip ?? this.coinChip,
    );
  }

  @override
  KoShadow lerp(KoShadow? other, double t) {
    if (other == null) return this;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    List<BoxShadow> l(List<BoxShadow> a, List<BoxShadow> b) =>
        BoxShadow.lerpList(a, b, t)!;
    return KoShadow(
      pressHero: d(pressHero, other.pressHero),
      press: d(press, other.press),
      pressSecondary: d(pressSecondary, other.pressSecondary),
      pressIcon: d(pressIcon, other.pressIcon),
      pressNode: d(pressNode, other.pressNode),
      card: l(card, other.card),
      tray: l(tray, other.tray),
      board: l(board, other.board),
      glow: l(glow, other.glow),
      glowStrong: l(glowStrong, other.glowStrong),
      badgeRing: l(badgeRing, other.badgeRing),
      glowPlay: l(glowPlay, other.glowPlay),
      node: l(node, other.node),
      logo: Shadow.lerpList(logo, other.logo, t)!,
      sheet: l(sheet, other.sheet),
      dialog: l(dialog, other.dialog),
      coinChip: l(coinChip, other.coinChip),
    );
  }
}
