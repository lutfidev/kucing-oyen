import 'package:flutter/material.dart';

import 'ko_theme.dart';
import 'ko_type.dart';

/// Approved v2 tokens. Apply [theme] at a screen boundary during migration.
abstract final class KoUi {
  static const cream = Color(0xFFFFF4E2);
  static const paper = Color(0xFFFFFAF0);
  static const peach = Color(0xFFFFD8AC);
  static const honey = Color(0xFFE9AE60);
  static const orange = Color(0xFFFF8208);
  static const orangePressed = Color(0xFFE36B00);
  static const ink = Color(0xFF573018);
  static const mutedInk = Color(0xFF79543A);
  static const success = Color(0xFF427443);
  static const water = Color(0xFF81C6E6);
  static const danger = Color(0xFFA63D32);
  static const shadow = Color(0x33573018);
  static const scrim = Color(0x99573018);
  static const homeBackground = Color(0xFFF9DEB4);
  static const homePaper = Color(0xFFFFF0D4);
  static const homeCream = Color(0xFFFFE5B8);
  static const homePeach = Color(0xFFF4C88F);
  static const homeLine = Color(0xFFC18B52);
  static const homeShade = Color(0x2BA2673E);
  static const homeGold = Color(0xFFFFBD58);
  static const homeFloor = Color(0xFFE5B16E);
  static const homeLeaf = Color(0xFF869D60);
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s24 = 24.0;
  static const chipRadius = 16.0, buttonRadius = 18.0;
  static const cardRadius = 22.0, sheetRadius = 28.0;
  static const outline = 1.5, target = 48.0, depth = 3.0;
  static const pressTime = Duration(milliseconds: 100);
  static const tabTime = Duration(milliseconds: 200);
  static const body = TextStyle(
    fontFamily: 'NunitoUi',
    fontFamilyFallback: ['NunitoUi'],
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
    color: ink,
  );
  static final label = body.copyWith(fontWeight: FontWeight.w700);
  static final small = body.copyWith(fontSize: 14, height: 20 / 14);
  static final caption = body.copyWith(fontSize: 12, height: 18 / 12);
  static final heading = body.copyWith(
    fontFamily: KoFonts.fredoka,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
  );
  static final title = heading.copyWith(fontSize: 24, height: 30 / 24);
  static final display = heading.copyWith(fontSize: 30, height: 36 / 30);
  static ThemeData theme() => KoTheme.light().copyWith(
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(seedColor: orange).copyWith(
      primary: orange,
      onPrimary: ink,
      surface: paper,
      onSurface: ink,
      error: danger,
      onError: paper,
      outline: ink,
    ),
    textTheme: TextTheme(
      bodyMedium: body,
      bodySmall: small,
      labelLarge: label,
      titleLarge: title,
      titleMedium: heading,
      headlineLarge: display,
    ),
  );
  static BoxDecoration card({
    double radius = cardRadius,
    Color color = paper,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: ink, width: outline),
    boxShadow: const [BoxShadow(color: shadow, offset: Offset(0, depth))],
  );

  static BoxDecoration homeCard({double radius = cardRadius}) => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [homePaper, homeCream],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: homeLine, width: outline),
    boxShadow: const [
      BoxShadow(color: homeShade, blurRadius: 8, offset: Offset(0, 3)),
    ],
  );
}
