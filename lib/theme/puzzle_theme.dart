import 'package:flutter/material.dart';

import 'ko_colors.dart';
import 'ko_radius.dart';
import 'ko_type.dart';
import 'ko_ui.dart';

/// Compatibility tokens for the existing accessible puzzle controls.
ThemeData puzzleTheme() => KoUi.theme().copyWith(
  extensions: [
    ...KoUi.theme().extensions.values.where(
      (e) => e is! KoColors && e is! KoType && e is! KoRadius,
    ),
    KoColors.standard.copyWith(
      cream: KoUi.cream,
      surface: KoUi.paper,
      ink: KoUi.ink,
      inkSoft: KoUi.mutedInk,
      floor: KoUi.peach,
      floorAlt: KoUi.honey,
      line: KoUi.homeLine,
      lineDeep: KoUi.ink,
      orange: KoUi.orange,
      orangeDeep: KoUi.orangePressed,
      orangeLine: KoUi.orangePressed,
      success: KoUi.success,
      successDeep: KoUi.ink,
      onSuccess: KoUi.paper,
      brick: KoUi.danger,
      water: KoUi.water,
    ),
    KoType.standard.copyWith(
      body: KoUi.body,
      bodySmall: KoUi.small,
      label: KoUi.label,
      paragraph: KoUi.body,
      paragraphSmall: KoUi.small,
      caption: KoUi.caption,
      heading: KoUi.heading,
      button: KoUi.title,
      controlLabel: KoUi.label,
      chipLabel: KoUi.small,
    ),
    KoRadius.standard.copyWith(
      primary: KoUi.buttonRadius,
      slot: KoUi.chipRadius,
    ),
  ],
);
