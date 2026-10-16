import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Skala jarak (kartu "Jarak, radius, bayangan").
///
/// Token inti s4 · s8 · s12 · s16 · s24 · s32. Nilai pendukung (s2, s6, s10,
/// s14) dipakai komponen di layar desain untuk celah kecil.
@immutable
class KoSpace extends ThemeExtension<KoSpace> {
  const KoSpace({
    required this.s2,
    required this.s4,
    required this.s6,
    required this.s8,
    required this.s10,
    required this.s12,
    required this.s14,
    required this.s16,
    required this.s24,
    required this.s32,
  });

  static const standard = KoSpace(
    s2: 2,
    s4: 4,
    s6: 6,
    s8: 8,
    s10: 10,
    s12: 12,
    s14: 14,
    s16: 16,
    s24: 24,
    s32: 32,
  );

  final double s2;
  final double s4;
  final double s6;
  final double s8;
  final double s10;
  final double s12;
  final double s14;
  final double s16;
  final double s24;
  final double s32;

  /// Jarak kiri-kanan layar.
  double get gutter => s16;

  @override
  KoSpace copyWith({
    double? s2,
    double? s4,
    double? s6,
    double? s8,
    double? s10,
    double? s12,
    double? s14,
    double? s16,
    double? s24,
    double? s32,
  }) {
    return KoSpace(
      s2: s2 ?? this.s2,
      s4: s4 ?? this.s4,
      s6: s6 ?? this.s6,
      s8: s8 ?? this.s8,
      s10: s10 ?? this.s10,
      s12: s12 ?? this.s12,
      s14: s14 ?? this.s14,
      s16: s16 ?? this.s16,
      s24: s24 ?? this.s24,
      s32: s32 ?? this.s32,
    );
  }

  @override
  KoSpace lerp(KoSpace? other, double t) {
    if (other == null) return this;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return KoSpace(
      s2: d(s2, other.s2),
      s4: d(s4, other.s4),
      s6: d(s6, other.s6),
      s8: d(s8, other.s8),
      s10: d(s10, other.s10),
      s12: d(s12, other.s12),
      s14: d(s14, other.s14),
      s16: d(s16, other.s16),
      s24: d(s24, other.s24),
      s32: d(s32, other.s32),
    );
  }
}
