import 'package:flutter/material.dart';

import 'ko_colors.dart';
import 'ko_radius.dart';
import 'ko_size.dart';
import 'ko_type.dart';
import 'ko_ui.dart';

/// Compatibility tokens for the existing accessible puzzle controls.
ThemeData puzzleTheme() => KoUi.theme().copyWith(
  extensions: [
    ...KoUi.theme().extensions.values.where(
      (e) => e is! KoColors && e is! KoType && e is! KoRadius && e is! KoSize,
    ),
    KoColors.standard.copyWith(
      cream: KoUi.cream,
      creamDim: KoUi.cream,
      mapKitchen: KoUi.cream,
      mapFloor: KoUi.honey,
      nodeLocked: KoUi.peach,
      nodeLockedInk: KoUi.mutedInk,
      nodeLockedEdge: KoUi.homeLine,
      brickDeep: KoUi.danger,
      brickEdge: KoUi.danger,
      successText: KoUi.success,
      introScrim: KoUi.scrim,
      scrimLight: KoUi.scrim,
      scrimDeep: KoUi.scrim,
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
      display: KoUi.display,
      title: KoUi.title,
      headline: KoUi.display,
      headlineSmall: KoUi.title,
      headingLarge: KoUi.title,
      overlineLarge: KoUi.caption,
      overline: KoUi.caption,
      body: KoUi.body,
      bodySmall: KoUi.small,
      label: KoUi.label,
      paragraph: KoUi.body,
      paragraphSmall: KoUi.small,
      caption: KoUi.caption,
      heading: KoUi.heading,
      button: KoUi.title,
      controlLabel: KoUi.label,
      cardTitle: KoUi.heading,
      cardBody: KoUi.small,
      cardBodyStrong: KoUi.label,
      cardLabel: KoUi.label,
      dialogTitle: KoUi.title,
      hintReveal: KoUi.label,
      numberTier: KoUi.heading,
      chipLabel: KoUi.small,
    ),
    KoRadius.standard.copyWith(
      primary: KoUi.buttonRadius,
      slot: KoUi.chipRadius,
      card: KoUi.cardRadius,
      sheet: KoUi.sheetRadius,
      dialog: KoUi.cardRadius,
    ),
    KoSize.standard.copyWith(iconButton: KoUi.target),
  ],
);
