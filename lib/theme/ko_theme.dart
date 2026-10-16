import 'package:flutter/material.dart';

import 'ko_colors.dart';
import 'ko_radius.dart';
import 'ko_shadow.dart';
import 'ko_size.dart';
import 'ko_space.dart';
import 'ko_type.dart';

/// [ThemeData] aplikasi: semua token terpasang sebagai [ThemeExtension], satu
/// per grup seperti lembar token desain.
abstract final class KoTheme {
  static ThemeData light() {
    const c = KoColors.standard;
    const t = KoType.standard;
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: c.orange,
      onPrimary: c.ink,
      secondary: c.success,
      onSecondary: c.onSuccess,
      error: c.brick,
      onError: c.surface,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkSoft,
      outline: c.line,
      outlineVariant: c.lineDeep,
      shadow: c.ink,
    );
    final textTheme = TextTheme(
      displayLarge: t.display,
      displayMedium: t.number,
      headlineMedium: t.title,
      titleLarge: t.heading,
      bodyMedium: t.body,
      labelLarge: t.label,
      labelSmall: t.overline,
    ).apply(bodyColor: c.ink, displayColor: c.ink);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.cream,
      fontFamily: KoFonts.nunito,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      extensions: [
        c,
        t,
        KoSpace.standard,
        KoRadius.standard,
        KoShadow.standard,
        KoSize.standard,
      ],
    );
  }
}

/// Akses token dari widget: `context.koColors.orange`, `context.koSpace.s8`.
///
/// Tanpa tema Kucing Oren (mis. widget test polos), nilai standar dipakai.
extension KoThemeContext on BuildContext {
  KoColors get koColors =>
      Theme.of(this).extension<KoColors>() ?? KoColors.standard;
  KoType get koType => Theme.of(this).extension<KoType>() ?? KoType.standard;
  KoSpace get koSpace =>
      Theme.of(this).extension<KoSpace>() ?? KoSpace.standard;
  KoRadius get koRadius =>
      Theme.of(this).extension<KoRadius>() ?? KoRadius.standard;
  KoShadow get koShadow =>
      Theme.of(this).extension<KoShadow>() ?? KoShadow.standard;
  KoSize get koSize => Theme.of(this).extension<KoSize>() ?? KoSize.standard;
}
