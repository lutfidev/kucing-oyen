import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// Back button to the home screen (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// Back button to the chapter map.
  ///
  /// In en, this message translates to:
  /// **'Back to map'**
  String get backToMap;

  /// Close button of a sheet (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Screen reader: earned stars out of a total.
  ///
  /// In en, this message translates to:
  /// **'{stars} of {total} stars'**
  String starsOf(int stars, int total);

  /// An amount of coins ("120 coins").
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{{n} coin} other{{n} coins}}'**
  String coinsAmount(int n);

  /// Word after a big coin number on the result screen ("+30 coins").
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{coin} other{coins}}'**
  String coinsUnit(int n);

  /// Disabled pay button: not enough coins for the price.
  ///
  /// In en, this message translates to:
  /// **'Not enough · {n}'**
  String notEnoughCoins(int n);

  /// Button: watch a rewarded ad.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad'**
  String get watchAd;

  /// The rewarded ad failed to load or was closed early.
  ///
  /// In en, this message translates to:
  /// **'The ad couldn\'t play. Try again later, okay?'**
  String get adFailed;

  /// Screen reader label of the 7×9 game board.
  ///
  /// In en, this message translates to:
  /// **'Game board, 7 by 9 tiles'**
  String get boardLabel;

  /// Big Play button on the home screen and the map node label.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Settings button and screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Tagline under the logo on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Oyen won\'t listen. You do the thinking.'**
  String get tagline;

  /// Short line under the logo on the Android splash screen (rendered into an image, keep it very short).
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get splashTagline;

  /// Chapter number above the chapter name (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Chapter {n}'**
  String chapterNumber(int n);

  /// Name of chapter 1 (setting: kitchen).
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get chapter1Name;

  /// Name of chapter 2 (setting: living room).
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get chapter2Name;

  /// Chapter title on chapter cards.
  ///
  /// In en, this message translates to:
  /// **'Chapter {n} – {name}'**
  String chapterTitle(int n, String name);

  /// Badge on a finished chapter card.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get chapterDone;

  /// Badge on a locked chapter card.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get chapterLocked;

  /// Screen reader status of a finished chapter (lowercase).
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get statusDone;

  /// Screen reader status of a locked level or chapter (lowercase).
  ///
  /// In en, this message translates to:
  /// **'locked'**
  String get statusLocked;

  /// Screen reader status of the level to play now.
  ///
  /// In en, this message translates to:
  /// **'play now'**
  String get statusPlayNow;

  /// Screen reader: stars earned on a level node.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{{n} star} other{{n} stars}}'**
  String nodeStars(int n);

  /// Screen reader label of a level node on the map.
  ///
  /// In en, this message translates to:
  /// **'Level {id}, {status}'**
  String levelNodeLabel(int id, String status);

  /// Screen reader label of the boss level node.
  ///
  /// In en, this message translates to:
  /// **'Level {id}, boss {name}, {status}'**
  String bossNodeLabel(int id, String name, String status);

  /// Tag above the boss level on the map.
  ///
  /// In en, this message translates to:
  /// **'Boss · {name}'**
  String bossTag(String name);

  /// Shown when the chapter in the link does not exist.
  ///
  /// In en, this message translates to:
  /// **'This chapter doesn\'t exist.'**
  String get chapterMissing;

  /// Name of level 1.
  ///
  /// In en, this message translates to:
  /// **'Wake Up Oyen'**
  String get level1Name;

  /// Name of level 2.
  ///
  /// In en, this message translates to:
  /// **'Round the Corner'**
  String get level2Name;

  /// Name of level 3.
  ///
  /// In en, this message translates to:
  /// **'First Fish'**
  String get level3Name;

  /// Name of level 4.
  ///
  /// In en, this message translates to:
  /// **'Nearest Fish'**
  String get level4Name;

  /// Name of level 5.
  ///
  /// In en, this message translates to:
  /// **'Two Fish'**
  String get level5Name;

  /// Name of level 6.
  ///
  /// In en, this message translates to:
  /// **'First Bucket'**
  String get level6Name;

  /// Name of level 7.
  ///
  /// In en, this message translates to:
  /// **'Puddle'**
  String get level7Name;

  /// Name of level 8.
  ///
  /// In en, this message translates to:
  /// **'Fish and Bucket'**
  String get level8Name;

  /// Name of level 9.
  ///
  /// In en, this message translates to:
  /// **'Tempting Fish'**
  String get level9Name;

  /// Name of level 10. This is the boss level; the name is shown after the boss prefix.
  ///
  /// In en, this message translates to:
  /// **'Salted Fish Feast'**
  String get level10Name;

  /// Name of level 11.
  ///
  /// In en, this message translates to:
  /// **'Coffee Table'**
  String get level11Name;

  /// Name of level 12.
  ///
  /// In en, this message translates to:
  /// **'Falling Glass'**
  String get level12Name;

  /// Name of level 13.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s Vase'**
  String get level13Name;

  /// Name of level 14.
  ///
  /// In en, this message translates to:
  /// **'Box in the Way'**
  String get level14Name;

  /// Name of level 15.
  ///
  /// In en, this message translates to:
  /// **'Squashed Box'**
  String get level15Name;

  /// Name of level 16.
  ///
  /// In en, this message translates to:
  /// **'The Long Way Round'**
  String get level16Name;

  /// Name of level 17.
  ///
  /// In en, this message translates to:
  /// **'Two Vases'**
  String get level17Name;

  /// Name of level 18.
  ///
  /// In en, this message translates to:
  /// **'Tight Squeeze'**
  String get level18Name;

  /// Name of level 19.
  ///
  /// In en, this message translates to:
  /// **'All Together'**
  String get level19Name;

  /// Name of level 20. This is the boss level; the name is shown after the boss prefix.
  ///
  /// In en, this message translates to:
  /// **'Eid Day'**
  String get level20Name;

  /// Full name of a boss level ("BOSS: Eid Day").
  ///
  /// In en, this message translates to:
  /// **'BOSS: {name}'**
  String bossLevelName(String name);

  /// Level number and name in the top bar and result screens.
  ///
  /// In en, this message translates to:
  /// **'Level {id} · {name}'**
  String levelTitle(int id, String name);

  /// Rules button in the top bar.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// Hint button (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Three-star goal chip: the most items allowed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{use {n} item} other{use {n} items}}'**
  String targetItems(int n);

  /// Screen reader label of the three-star goal chip.
  ///
  /// In en, this message translates to:
  /// **'3-star goal: {text}'**
  String targetLabel(String text);

  /// Shown when the level in the link does not exist.
  ///
  /// In en, this message translates to:
  /// **'This level doesn\'t exist.'**
  String get levelMissing;

  /// Back button while Oyen walks: return to placing items.
  ///
  /// In en, this message translates to:
  /// **'Back to setup'**
  String get backToArrange;

  /// Main button: start the run.
  ///
  /// In en, this message translates to:
  /// **'Wake Oyen'**
  String get wakeOyen;

  /// Tray text on levels without items.
  ///
  /// In en, this message translates to:
  /// **'No items needed here yet.'**
  String get trayEmpty;

  /// Vertical label of the item tray (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get trayLabel;

  /// Button: return all placed items to the tray.
  ///
  /// In en, this message translates to:
  /// **'Clear the board'**
  String get clearBoard;

  /// Tray hint, first line: "Place on a / glowing tile".
  ///
  /// In en, this message translates to:
  /// **'Drop on a'**
  String get trayHintTop;

  /// Tray hint, second line.
  ///
  /// In en, this message translates to:
  /// **'glowing tile'**
  String get trayHintBottom;

  /// Item name: salted fish.
  ///
  /// In en, this message translates to:
  /// **'Salted fish'**
  String get itemFish;

  /// Item name: water bucket.
  ///
  /// In en, this message translates to:
  /// **'Water bucket'**
  String get itemWater;

  /// Item name: cardboard box.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get itemBox;

  /// Screen reader label of a tray slot.
  ///
  /// In en, this message translates to:
  /// **'{name}, {n} left'**
  String traySlotLabel(String name, int n);

  /// Screen reader label of a tray slot while dragging.
  ///
  /// In en, this message translates to:
  /// **'{name}, dragging, {n} left'**
  String traySlotDragging(String name, int n);

  /// Screen reader hint for a tray slot: what a double tap does ("Double tap to ...").
  ///
  /// In en, this message translates to:
  /// **'pick it up'**
  String get traySlotSelectHint;

  /// Screen reader hint for a picked-up tray slot or board item: double tap cancels the pick (the item stays where it is).
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get traySlotUnselectHint;

  /// Screen reader label of one board tile: row and column (from 1, top left) and what is on it.
  ///
  /// In en, this message translates to:
  /// **'Row {row}, column {col}: {content}'**
  String tileLabel(int row, int col, String content);

  /// Board tile content for screen readers: wall.
  ///
  /// In en, this message translates to:
  /// **'wall'**
  String get cellWall;

  /// Board tile content for screen readers: empty floor.
  ///
  /// In en, this message translates to:
  /// **'floor'**
  String get cellFloor;

  /// Board tile content for screen readers: Oyen's food bowl (the goal).
  ///
  /// In en, this message translates to:
  /// **'Oyen\'s bowl'**
  String get cellBowl;

  /// Board tile content for screen readers: table.
  ///
  /// In en, this message translates to:
  /// **'table'**
  String get cellTable;

  /// Board tile content for screen readers: table with a glass Oyen can knock off.
  ///
  /// In en, this message translates to:
  /// **'table with a glass'**
  String get cellTableGlass;

  /// Board tile content for screen readers: table with Mom's vase.
  ///
  /// In en, this message translates to:
  /// **'table with a vase'**
  String get cellTableVase;

  /// Board tile content for screen readers: salted fish that is part of the level.
  ///
  /// In en, this message translates to:
  /// **'salted fish'**
  String get cellFish;

  /// Board tile content for screen readers: water puddle that is part of the level.
  ///
  /// In en, this message translates to:
  /// **'puddle'**
  String get cellWater;

  /// Board tile content for screen readers: box that is part of the level.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get cellBox;

  /// Board tile content for screen readers: sleeping Oyen and the screen direction he faces.
  ///
  /// In en, this message translates to:
  /// **'Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}'**
  String tileOyen(String dir);

  /// Board tile content for screen readers: an item the player put there (item name first).
  ///
  /// In en, this message translates to:
  /// **'{item}, placed by you'**
  String tilePlayerItem(String item);

  /// Board tile label suffix for screen readers: a tier 1 hint marks this tile (something must go here, type not revealed).
  ///
  /// In en, this message translates to:
  /// **'{content}. Hint: something has to go here.'**
  String tileHintSpot(String content);

  /// Board tile label suffix for screen readers: a tier 2-3 hint shows which item goes on this tile.
  ///
  /// In en, this message translates to:
  /// **'{content}. Hint: {item} goes here.'**
  String tileHintItem(String content, String item);

  /// Screen reader hint for an empty tile while an item is picked up ("Double tap to ...").
  ///
  /// In en, this message translates to:
  /// **'put it here'**
  String get tilePlaceHint;

  /// Screen reader hint for a board item the player placed ("Double tap to ...").
  ///
  /// In en, this message translates to:
  /// **'pick it up to move it'**
  String get tilePickHint;

  /// Screen reader custom action on a placed item: put it back in the tray.
  ///
  /// In en, this message translates to:
  /// **'Back to the tray'**
  String get tileReturn;

  /// Screen reader announcement after picking up an item without dragging.
  ///
  /// In en, this message translates to:
  /// **'{item} picked up. Choose an empty floor tile to put it on.'**
  String itemPickedAnnounce(String item);

  /// Screen reader announcement after an item is put on the board without dragging.
  ///
  /// In en, this message translates to:
  /// **'{item} placed at row {row}, column {col}.'**
  String itemPlacedAnnounce(String item, int row, int col);

  /// Screen reader announcement after a placed item goes back to the tray.
  ///
  /// In en, this message translates to:
  /// **'{item} is back in the tray.'**
  String itemReturnedAnnounce(String item);

  /// Step counter label (also above the number chip).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// Step number ("Step 4").
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String stepNumber(int n);

  /// Status chip: the vase broke.
  ///
  /// In en, this message translates to:
  /// **'Vase broken'**
  String get vaseBroken;

  /// Status chip: the vase is fine.
  ///
  /// In en, this message translates to:
  /// **'Vase safe'**
  String get vaseSafe;

  /// Status chip: number of items used.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{{n} item used} other{{n} items used}}'**
  String itemsUsed(int n);

  /// Play/pause button while running.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Play/pause button while paused.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Button: one step forward.
  ///
  /// In en, this message translates to:
  /// **'One step forward'**
  String get stepForward;

  /// Button: one step back (replay).
  ///
  /// In en, this message translates to:
  /// **'One step back'**
  String get stepBack;

  /// Toggle: play twice as fast.
  ///
  /// In en, this message translates to:
  /// **'Double speed'**
  String get doubleSpeed;

  /// Button after the run: open the result screen.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get seeResult;

  /// Run caption, step 0.
  ///
  /// In en, this message translates to:
  /// **'Oyen wakes up, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}.'**
  String runWake(String dir);

  /// Run caption: reached the bowl.
  ///
  /// In en, this message translates to:
  /// **'Made it to the bowl! Nom nom.'**
  String get runAtBowl;

  /// Run and replay caption: chasing a fish.
  ///
  /// In en, this message translates to:
  /// **'Chasing the fish {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}.'**
  String chaseFish(String dir);

  /// Run caption: a fish comes into sight.
  ///
  /// In en, this message translates to:
  /// **'Hey, salted fish {dir, select, up{up there} right{to the right} down{down there} left{to the left} other{to the right}}!'**
  String runSmellFish(String dir);

  /// Run caption: walking straight.
  ///
  /// In en, this message translates to:
  /// **'Strolling {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}, no rush.'**
  String runWalk(String dir);

  /// Run caption: water ahead.
  ///
  /// In en, this message translates to:
  /// **'Water! Oyen jumps and turns back.'**
  String get runScared;

  /// Run caption: blocked by a table or wall, turned clockwise.
  ///
  /// In en, this message translates to:
  /// **'Hit {obstacle, select, table{a table} wall{a wall} other{a wall}}. Turned, now facing {dir, select, up{up} right{right} down{down} left{left} other{right}}.'**
  String runTurn(String obstacle, String dir);

  /// Run caption: eats a fish.
  ///
  /// In en, this message translates to:
  /// **'Chomp! The salted fish is gone.'**
  String get runEat;

  /// Run caption: gets into a box.
  ///
  /// In en, this message translates to:
  /// **'A box! Oyen climbs in and sits.'**
  String get runEnterBox;

  /// Run caption: still sitting in the box.
  ///
  /// In en, this message translates to:
  /// **'Sitting pretty in the box.'**
  String get runSit;

  /// Run caption: the box is squashed and disappears.
  ///
  /// In en, this message translates to:
  /// **'The box gets squashed, then vanishes.'**
  String get runBoxGone;

  /// Run caption: pushes a glass off a table.
  ///
  /// In en, this message translates to:
  /// **'The glass gets pushed off. Lucky it\'s plastic!'**
  String get runKnockGlass;

  /// Run caption: pushes the vase off and it breaks.
  ///
  /// In en, this message translates to:
  /// **'Uh-oh! Mom\'s vase falls and breaks.'**
  String get runKnockVase;

  /// Replay caption, step 0.
  ///
  /// In en, this message translates to:
  /// **'Start: Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}.'**
  String replayAsleep(String dir);

  /// Replay caption: reached the bowl after n steps.
  ///
  /// In en, this message translates to:
  /// **'Into the bowl. Done in {n, plural, one{{n} step} other{{n} steps}}.'**
  String replayFinished(int n);

  /// Replay caption: chasing a fish, vase still fine.
  ///
  /// In en, this message translates to:
  /// **'Chasing the fish. Vase still safe.'**
  String get replayChaseVaseSafe;

  /// Replay caption: a fish in a straight line.
  ///
  /// In en, this message translates to:
  /// **'Salted fish in sight, straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}.'**
  String replaySeeFish(String dir);

  /// Replay caption: walking straight.
  ///
  /// In en, this message translates to:
  /// **'Walks straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}.'**
  String replayWalk(String dir);

  /// Replay caption: water ahead (puddle or bucket), turned back.
  ///
  /// In en, this message translates to:
  /// **'Meets {water, select, puddle{a puddle} bucket{a water bucket} other{water}}, jumps, turns back.'**
  String replayScared(String water);

  /// Replay caption: blocked, turned clockwise.
  ///
  /// In en, this message translates to:
  /// **'Hits {obstacle, select, table{a table} wall{a wall} other{a wall}}, turns to face {dir, select, up{up} right{right} down{down} left{left} other{right}}.'**
  String replayTurn(String obstacle, String dir);

  /// Replay caption: eats a fish.
  ///
  /// In en, this message translates to:
  /// **'Chomp! Salted fish eaten.'**
  String get replayEat;

  /// Replay caption: gets into a box.
  ///
  /// In en, this message translates to:
  /// **'Into the box, time to sit.'**
  String get replayEnterBox;

  /// Replay caption: still in the box.
  ///
  /// In en, this message translates to:
  /// **'Still sitting in the box.'**
  String get replaySit;

  /// Replay caption: the box is gone.
  ///
  /// In en, this message translates to:
  /// **'The box is squashed and gone.'**
  String get replayBoxGone;

  /// Replay caption: glass pushed off.
  ///
  /// In en, this message translates to:
  /// **'Glass pushed off. No harm, it\'s plastic.'**
  String get replayKnockGlass;

  /// Replay caption: vase pushed off.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s vase pushed off. Smash!'**
  String get replayKnockVase;

  /// Replay caption, last step: same state as the start.
  ///
  /// In en, this message translates to:
  /// **'Back to how it started. Oyen keeps circling and gets bored.'**
  String get replayLoopStart;

  /// Replay caption, last step: same state as step n.
  ///
  /// In en, this message translates to:
  /// **'Back to how step {n} looked. Oyen keeps circling and gets bored.'**
  String replayLoopStep(int n);

  /// Replay caption, last step: hit the step limit.
  ///
  /// In en, this message translates to:
  /// **'Step {n} and still no bowl. Oyen is bored.'**
  String replayTooManySteps(int n);

  /// Screen reader: close the rules sheet.
  ///
  /// In en, this message translates to:
  /// **'Close rules'**
  String get closeRules;

  /// Rules sheet title.
  ///
  /// In en, this message translates to:
  /// **'Oyen\'s Rules'**
  String get rulesTitle;

  /// Rules sheet intro.
  ///
  /// In en, this message translates to:
  /// **'Each step is checked from the top. The first rule that fits is what Oyen does.'**
  String get rulesIntro;

  /// Rule card: knock things off the table next to Oyen.
  ///
  /// In en, this message translates to:
  /// **'Knock over what\'s next door'**
  String get ruleKnockTitle;

  /// Rule card body: knock.
  ///
  /// In en, this message translates to:
  /// **'A glass or vase on the table next door? It gets bumped. Always.'**
  String get ruleKnockBody;

  /// Rule card: chase the nearest fish.
  ///
  /// In en, this message translates to:
  /// **'Chase the nearest fish'**
  String get ruleFishTitle;

  /// Rule card body: fish, before the tie order.
  ///
  /// In en, this message translates to:
  /// **'Only fish in a straight line. If tied:'**
  String get ruleFishBody;

  /// Tie order word 1 (followed by an arrow).
  ///
  /// In en, this message translates to:
  /// **'ahead'**
  String get tieAhead;

  /// Tie order word 2: clockwise (never "right").
  ///
  /// In en, this message translates to:
  /// **'clockwise'**
  String get tieClockwise;

  /// Tie order word 3: counterclockwise (never "left").
  ///
  /// In en, this message translates to:
  /// **'counterclockwise'**
  String get tieCounterClockwise;

  /// Tie order word 4.
  ///
  /// In en, this message translates to:
  /// **'behind'**
  String get tieBehind;

  /// Screen reader text of the tie order.
  ///
  /// In en, this message translates to:
  /// **'Tie order: ahead, clockwise, counterclockwise, behind.'**
  String get tieOrderLabel;

  /// Rule card: water, turn back.
  ///
  /// In en, this message translates to:
  /// **'Water? Turn back'**
  String get ruleWaterTitle;

  /// Rule card body: water.
  ///
  /// In en, this message translates to:
  /// **'Puddle or bucket ahead? Oyen gets spooked and turns around.'**
  String get ruleWaterBody;

  /// Rule card: blocked by a wall or table.
  ///
  /// In en, this message translates to:
  /// **'Blocked by a wall or table'**
  String get ruleWallTitle;

  /// Rule card: turns clockwise (never "turns right").
  ///
  /// In en, this message translates to:
  /// **'Oyen turns clockwise'**
  String get ruleWallTurn;

  /// Rule card body: wall.
  ///
  /// In en, this message translates to:
  /// **'A quarter turn, then off again.'**
  String get ruleWallBody;

  /// Rule card: box, get in and sit.
  ///
  /// In en, this message translates to:
  /// **'Box? Hop in, sit'**
  String get ruleBoxTitle;

  /// Rule card body: box.
  ///
  /// In en, this message translates to:
  /// **'Sits 2 steps until the box gets squashed and vanishes. Fish behind a box stay hidden.'**
  String get ruleBoxBody;

  /// Locked rule card name: knock.
  ///
  /// In en, this message translates to:
  /// **'Things on tables'**
  String get ruleKnockLocked;

  /// Locked rule card name: fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get ruleFishLocked;

  /// Locked rule card name: water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get ruleWaterLocked;

  /// Locked rule card name: wall.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get ruleWallLocked;

  /// Locked rule card name: box.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get ruleBoxLocked;

  /// Locked rule card title.
  ///
  /// In en, this message translates to:
  /// **'{name}: ???'**
  String ruleLockedTitle(String name);

  /// Locked rule card body.
  ///
  /// In en, this message translates to:
  /// **'Not learned yet. You\'ll meet it soon.'**
  String get ruleLockedBody;

  /// Screen reader label of rule card n.
  ///
  /// In en, this message translates to:
  /// **'Rule {n}'**
  String ruleLabel(int n);

  /// Screen reader label of a locked rule card.
  ///
  /// In en, this message translates to:
  /// **'Rule {n}, locked, not learned yet'**
  String ruleLockedLabel(int n);

  /// Screen reader: close the hint sheet.
  ///
  /// In en, this message translates to:
  /// **'Close hints'**
  String get closeHints;

  /// Hint sheet title.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintsTitle;

  /// Hint sheet intro.
  ///
  /// In en, this message translates to:
  /// **'Go slow. Maybe all you need is a little nudge.'**
  String get hintsIntro;

  /// Hint tier 1 title.
  ///
  /// In en, this message translates to:
  /// **'Highlight the first tile'**
  String get hintTier1Title;

  /// Hint tier 2 title.
  ///
  /// In en, this message translates to:
  /// **'Show the item type'**
  String get hintTier2Title;

  /// Hint tier 3 title.
  ///
  /// In en, this message translates to:
  /// **'Show the full solution'**
  String get hintTier3Title;

  /// Hint tier status: already unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get hintOpened;

  /// Hint tier status: ready to unlock.
  ///
  /// In en, this message translates to:
  /// **'Tier {n}'**
  String hintTier(int n);

  /// Hint tier status: unlock the previous tier first.
  ///
  /// In en, this message translates to:
  /// **'Unlock tier {n} first'**
  String hintUnlockFirst(int n);

  /// Hint sheet card on levels without items.
  ///
  /// In en, this message translates to:
  /// **'No items needed here. Just wake Oyen up!'**
  String get noItemsHint;

  /// Unlocked hint tier 1.
  ///
  /// In en, this message translates to:
  /// **'See the glowing tile? Something needs to go there.'**
  String get hintTier1Text;

  /// Unlocked hint tier 2: salted fish.
  ///
  /// In en, this message translates to:
  /// **'Put a salted fish on the glowing tile. Oyen will chase it and eat it.'**
  String get hintPlaceFish;

  /// Unlocked hint tier 2: water bucket.
  ///
  /// In en, this message translates to:
  /// **'Put a water bucket on the glowing tile. Oyen will get spooked and turn around.'**
  String get hintPlaceWater;

  /// Unlocked hint tier 2: box.
  ///
  /// In en, this message translates to:
  /// **'Put a box on the glowing tile. Oyen will climb in and sit there.'**
  String get hintPlaceBox;

  /// Hint tier 3 list part (count = one/two/three/other, n = number): n salted fish.
  ///
  /// In en, this message translates to:
  /// **'{count, select, one{a salted fish} two{two salted fish} three{three salted fish} other{{n} salted fish}}'**
  String hintFishCount(String count, int n);

  /// Hint tier 3 list part (count = one/two/three/other, n = number): n water buckets.
  ///
  /// In en, this message translates to:
  /// **'{count, select, one{a water bucket} two{two water buckets} three{three water buckets} other{{n} water buckets}}'**
  String hintWaterCount(String count, int n);

  /// Hint tier 3 list part (count = one/two/three/other, n = number): n boxes.
  ///
  /// In en, this message translates to:
  /// **'{count, select, one{a box} two{two boxes} three{three boxes} other{{n} boxes}}'**
  String hintBoxCount(String count, int n);

  /// Joins two list parts.
  ///
  /// In en, this message translates to:
  /// **'{a} and {b}'**
  String listPair(String a, String b);

  /// Joins the comma-separated start of a list with its last part.
  ///
  /// In en, this message translates to:
  /// **'{rest}, and {last}'**
  String listLast(String rest, String last);

  /// Unlocked hint tier 3 (first letter is capitalized in code); count = number of items.
  ///
  /// In en, this message translates to:
  /// **'{items} on the glowing {count, plural, one{tile} other{tiles}}. {tail}'**
  String hintSolution(String items, int count, String tail);

  /// Tier 3 ending on levels with a vase.
  ///
  /// In en, this message translates to:
  /// **'Vase safe, 3 stars.'**
  String get hintSolutionVaseSafe;

  /// Tier 3 ending on levels without a vase.
  ///
  /// In en, this message translates to:
  /// **'3 stars!'**
  String get hintSolutionStars;

  /// Tutorial level 1, big text.
  ///
  /// In en, this message translates to:
  /// **'You can\'t boss Oyen around. Just wake the cat up!'**
  String get tutorial1Title;

  /// Tutorial level 1, small text.
  ///
  /// In en, this message translates to:
  /// **'Oyen walks to the bowl alone. You just watch.'**
  String get tutorial1Body;

  /// Tutorial level 3 (fish), big text.
  ///
  /// In en, this message translates to:
  /// **'Oyen can\'t resist salted fish!'**
  String get tutorial3Title;

  /// Tutorial level 3, small text.
  ///
  /// In en, this message translates to:
  /// **'Drag a fish onto the floor. If Oyen sees it in a straight line, the chase is on.'**
  String get tutorial3Body;

  /// Tutorial level 6 (bucket), big text.
  ///
  /// In en, this message translates to:
  /// **'Oyen hates water. Like, really.'**
  String get tutorial6Title;

  /// Tutorial level 6, small text.
  ///
  /// In en, this message translates to:
  /// **'Put the bucket in the way. Water ahead means a spooked cat and a U-turn.'**
  String get tutorial6Body;

  /// Screen reader label of the tutorial card.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorialLabel;

  /// Screen reader label of the Skip button.
  ///
  /// In en, this message translates to:
  /// **'Skip tutorial'**
  String get skipTutorial;

  /// Skip button of the tutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Success screen headline.
  ///
  /// In en, this message translates to:
  /// **'Nailed it!'**
  String get success;

  /// Word under a step count ("6 steps").
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{step} other{steps}}'**
  String stepsUnit(int n);

  /// Words under an item count ("2 items used").
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{item used} other{items used}}'**
  String itemsUsedUnit(int n);

  /// Star rule 1.
  ///
  /// In en, this message translates to:
  /// **'Reached the bowl'**
  String get goalBowl;

  /// Star rule 2.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s vase is safe'**
  String get goalVase;

  /// Star rule 3.
  ///
  /// In en, this message translates to:
  /// **'Fewest items'**
  String get goalItems;

  /// Star rule status: not earned.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get goalNotYet;

  /// Star rule status: earned (vase screen).
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get goalGot;

  /// Screen reader: star rule earned (check mark).
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get goalAchieved;

  /// Button: restart with an empty board.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Button: next level.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Link on the success screen.
  ///
  /// In en, this message translates to:
  /// **'Watch the replay'**
  String get watchReplay;

  /// Vase screen headline, line 1.
  ///
  /// In en, this message translates to:
  /// **'Made it...'**
  String get vaseHeadlineTop;

  /// Vase screen headline, line 2.
  ///
  /// In en, this message translates to:
  /// **'but Mom\'s vase?'**
  String get vaseHeadlineBottom;

  /// Vase screen: the step the vase broke.
  ///
  /// In en, this message translates to:
  /// **'Broke on step {n}'**
  String brokenAtStep(int n);

  /// Vase screen button: arrange again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Vase screen button: next level anyway.
  ///
  /// In en, this message translates to:
  /// **'Next Anyway'**
  String get nextAnyway;

  /// Screen reader label of the vase screen picture.
  ///
  /// In en, this message translates to:
  /// **'The vase lies broken behind Oyen, and Mom pops in at the door, annoyed'**
  String get vaseArtLabel;

  /// Fail screen title: going in circles.
  ///
  /// In en, this message translates to:
  /// **'Oyen got bored going in circles.'**
  String get loopTitle;

  /// Fail screen chip: going in circles.
  ///
  /// In en, this message translates to:
  /// **'Going in circles'**
  String get loopBadge;

  /// Fail screen message: going in circles.
  ///
  /// In en, this message translates to:
  /// **'Round and round, no bowl in sight. Oh well, back to sleep.'**
  String get loopMessage;

  /// Fail screen title: walked too long.
  ///
  /// In en, this message translates to:
  /// **'Oyen got tired of walking.'**
  String get tooLongTitle;

  /// Fail screen chip: over the step limit.
  ///
  /// In en, this message translates to:
  /// **'Over {n} steps'**
  String tooLongBadge(int n);

  /// Fail screen message: over the step limit.
  ///
  /// In en, this message translates to:
  /// **'{n} steps and still no bowl. Ugh, so tired. Back to sleep.'**
  String tooLongMessage(int n);

  /// Fail screen line above the title.
  ///
  /// In en, this message translates to:
  /// **'Level {id} · Failed'**
  String failedKicker(int id);

  /// Replay button and replay screen title.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// Fail screen button: back to arranging.
  ///
  /// In en, this message translates to:
  /// **'Rearrange'**
  String get arrangeAgain;

  /// Replay: label of step 0.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get replayStart;

  /// Replay: button that plays the steps by itself (screen reader label; the pause state uses "pause").
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get replayPlay;

  /// Replay: back to the result screen.
  ///
  /// In en, this message translates to:
  /// **'Back to results'**
  String get backToResult;

  /// Replay: chip next to the title.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// Replay: screen reader caption of step n.
  ///
  /// In en, this message translates to:
  /// **'Step {n}. {text}'**
  String replayStepCaption(int n, String text);

  /// Replay: label of the time slider (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeline;

  /// Screen reader label of Oyen: pose and facing (screen direction).
  ///
  /// In en, this message translates to:
  /// **'Oyen {pose, select, idle{standing} walk{walking} sleep{asleep} shock{startled} box{sitting in a box} knock{knocking something over} eat{eating} happy{happy} other{standing}}, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}'**
  String oyenLabel(String pose, String dir);

  /// Screen reader: close the coin sheet.
  ///
  /// In en, this message translates to:
  /// **'Close coins'**
  String get closeCoins;

  /// Coin sheet title.
  ///
  /// In en, this message translates to:
  /// **'Get Coins'**
  String get coinsTitle;

  /// Coin sheet intro.
  ///
  /// In en, this message translates to:
  /// **'Coins buy hints and stuff for Oyen\'s room. Grab the daily bonus, or watch an ad.'**
  String get coinsIntro;

  /// Coin card title: daily bonus.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus'**
  String get dailyBonus;

  /// Daily bonus status: can claim.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get dailyBonusReady;

  /// Daily bonus status: already claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed today'**
  String get dailyBonusTaken;

  /// Daily bonus button.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Claim {n} coin} other{Claim {n} coins}}'**
  String claimCoins(int n);

  /// Daily bonus button after claiming.
  ///
  /// In en, this message translates to:
  /// **'Back tomorrow'**
  String get claimTomorrow;

  /// Ad card status: ads left today.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{{n} left today} other{{n} left today}}'**
  String adsLeftToday(int n);

  /// Ad card status: no ads left today.
  ///
  /// In en, this message translates to:
  /// **'All used up today'**
  String get adsUsedUp;

  /// Ad card button: plus n coins.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{+{n} coin} other{+{n} coins}}'**
  String adRewardButton(int n);

  /// Ad card button when used up.
  ///
  /// In en, this message translates to:
  /// **'More tomorrow'**
  String get adsTomorrow;

  /// Screen reader: the coin chip opens the coin sheet.
  ///
  /// In en, this message translates to:
  /// **'get coins'**
  String get coinChipAdd;

  /// Screen reader: the daily bonus is ready.
  ///
  /// In en, this message translates to:
  /// **'daily bonus ready'**
  String get coinChipBonus;

  /// Settings section: music and sound effects.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSection;

  /// Settings switch: background music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// Settings switch: sound effects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// Settings section: language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language option: follow the phone language.
  ///
  /// In en, this message translates to:
  /// **'Use phone language'**
  String get languageSystem;

  /// Settings section: tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsSection;

  /// Settings button: show the tutorials again.
  ///
  /// In en, this message translates to:
  /// **'Show tutorials again'**
  String get replayTutorials;

  /// Settings text under the tutorials button.
  ///
  /// In en, this message translates to:
  /// **'The tutorials on levels 1, 3, and 6 show up again next time you play them.'**
  String get replayTutorialsInfo;

  /// Confirmation after pressing "show tutorials again".
  ///
  /// In en, this message translates to:
  /// **'Done! The tutorials are back.'**
  String get tutorialsBack;

  /// Settings section: progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressSection;

  /// Settings button: reset progress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// Settings text under the reset button.
  ///
  /// In en, this message translates to:
  /// **'Erase stars, coins, room stuff, hints, and tutorials, then start again from level 1.'**
  String get resetProgressInfo;

  /// Reset confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Erase all progress?'**
  String get resetConfirmTitle;

  /// Reset confirmation text.
  ///
  /// In en, this message translates to:
  /// **'Stars, coins, room stuff, hints, and tutorials will be erased. This can\'t be undone. Today\'s daily bonus and ads stay used.'**
  String get resetConfirmBody;

  /// Reset confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get resetConfirm;

  /// Screen reader: close the reset confirmation.
  ///
  /// In en, this message translates to:
  /// **'Close reset'**
  String get closeReset;

  /// Message after resetting.
  ///
  /// In en, this message translates to:
  /// **'Progress erased. Fresh start!'**
  String get resetDone;

  /// Settings section: privacy (policy link and ad consent).
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySection;

  /// Settings, Privacy card: short explanation above the buttons.
  ///
  /// In en, this message translates to:
  /// **'Your progress stays on your phone. Ads come from Google AdMob.'**
  String get privacyInfo;

  /// Settings, Privacy: button that opens the privacy policy in the browser.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Settings, Privacy: button that reopens the ad consent form (only where the law requires it).
  ///
  /// In en, this message translates to:
  /// **'Ad consent settings'**
  String get adConsent;

  /// Settings, Privacy: small message when the browser could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the browser. Try again later, okay?'**
  String get privacyLinkFailed;

  /// Settings section: about the game.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Font credits.
  ///
  /// In en, this message translates to:
  /// **'Fonts: Fredoka and Nunito (SIL Open Font License).'**
  String get fontCredits;

  /// About card: credits for sound effects (CC0 sources) and the original music.
  ///
  /// In en, this message translates to:
  /// **'Sound effects: Kenney and OpenGameArt (CC0). The music was made just for Ginger Logic.'**
  String get soundCredits;

  /// Button: open the licenses page.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Name of the room item "Toy Mouse".
  ///
  /// In en, this message translates to:
  /// **'Toy Mouse'**
  String get roomItemTikus;

  /// Shop description of the room item "Toy Mouse".
  ///
  /// In en, this message translates to:
  /// **'Never runs away, still gets chased.'**
  String get roomItemTikusDesc;

  /// Name of the room item "Aquarium".
  ///
  /// In en, this message translates to:
  /// **'Aquarium'**
  String get roomItemAkuarium;

  /// Shop description of the room item "Aquarium".
  ///
  /// In en, this message translates to:
  /// **'All-day entertainment. The fish are a bit nervous.'**
  String get roomItemAkuariumDesc;

  /// Name of the room item "Cat House".
  ///
  /// In en, this message translates to:
  /// **'Cat House'**
  String get roomItemRumah;

  /// Shop description of the room item "Cat House".
  ///
  /// In en, this message translates to:
  /// **'Has its own house, still sleeps in the box.'**
  String get roomItemRumahDesc;

  /// Name of the room item "Cushion Bed".
  ///
  /// In en, this message translates to:
  /// **'Cushion Bed'**
  String get roomItemKasur;

  /// Shop description of the room item "Cushion Bed".
  ///
  /// In en, this message translates to:
  /// **'Soft. Used 60% of the time, the rest is box.'**
  String get roomItemKasurDesc;

  /// Name of the room item "Catnip Pot".
  ///
  /// In en, this message translates to:
  /// **'Catnip Pot'**
  String get roomItemCatnip;

  /// Shop description of the room item "Catnip Pot".
  ///
  /// In en, this message translates to:
  /// **'One sniff and the dancing starts.'**
  String get roomItemCatnipDesc;

  /// Name of the room item "Cat Clock".
  ///
  /// In en, this message translates to:
  /// **'Cat Clock'**
  String get roomItemJam;

  /// Shop description of the room item "Cat Clock".
  ///
  /// In en, this message translates to:
  /// **'The tail swings every second. Hypnotic.'**
  String get roomItemJamDesc;

  /// Name of the room item "Cozy Box".
  ///
  /// In en, this message translates to:
  /// **'Cozy Box'**
  String get roomItemKardus;

  /// Shop description of the room item "Cozy Box".
  ///
  /// In en, this message translates to:
  /// **'It\'s the box that gets picked, not what came in it.'**
  String get roomItemKardusDesc;

  /// Name of the room item "Yarn Ball".
  ///
  /// In en, this message translates to:
  /// **'Yarn Ball'**
  String get roomItemBola;

  /// Shop description of the room item "Yarn Ball".
  ///
  /// In en, this message translates to:
  /// **'Tangled in 3 seconds. That\'s the feature.'**
  String get roomItemBolaDesc;

  /// Name of the room item "Round Rug".
  ///
  /// In en, this message translates to:
  /// **'Round Rug'**
  String get roomItemKarpet;

  /// Shop description of the room item "Round Rug".
  ///
  /// In en, this message translates to:
  /// **'The official rolling-around spot.'**
  String get roomItemKarpetDesc;

  /// Name of the room item "Scratching Post".
  ///
  /// In en, this message translates to:
  /// **'Scratching Post'**
  String get roomItemTiang;

  /// Shop description of the room item "Scratching Post".
  ///
  /// In en, this message translates to:
  /// **'So Mom\'s sofa survives. Hopefully.'**
  String get roomItemTiangDesc;

  /// Name of the room item "Fish Painting".
  ///
  /// In en, this message translates to:
  /// **'Fish Painting'**
  String get roomItemLukisan;

  /// Shop description of the room item "Fish Painting".
  ///
  /// In en, this message translates to:
  /// **'Art that makes you hungry.'**
  String get roomItemLukisanDesc;

  /// Name of the room item "Wall Shelf".
  ///
  /// In en, this message translates to:
  /// **'Wall Shelf'**
  String get roomItemRak;

  /// Shop description of the room item "Wall Shelf".
  ///
  /// In en, this message translates to:
  /// **'VIP seat for watching everyone.'**
  String get roomItemRakDesc;

  /// Name of the room item "Feather Wand".
  ///
  /// In en, this message translates to:
  /// **'Feather Wand'**
  String get roomItemPancingan;

  /// Shop description of the room item "Feather Wand".
  ///
  /// In en, this message translates to:
  /// **'Chases the feather, leaves its dignity behind.'**
  String get roomItemPancinganDesc;

  /// Name of the room item "Moon Lamp".
  ///
  /// In en, this message translates to:
  /// **'Moon Lamp'**
  String get roomItemLampuBulan;

  /// Shop description of the room item "Moon Lamp".
  ///
  /// In en, this message translates to:
  /// **'A private moon, no need to wait for night.'**
  String get roomItemLampuBulanDesc;

  /// Name of the room item "Fish Pillow".
  ///
  /// In en, this message translates to:
  /// **'Fish Pillow'**
  String get roomItemBantalIkan;

  /// Shop description of the room item "Fish Pillow".
  ///
  /// In en, this message translates to:
  /// **'Soft, and fishy only to look at.'**
  String get roomItemBantalIkanDesc;

  /// Name of the room item "Monstera Plant".
  ///
  /// In en, this message translates to:
  /// **'Monstera Plant'**
  String get roomItemMonstera;

  /// Shop description of the room item "Monstera Plant".
  ///
  /// In en, this message translates to:
  /// **'The leaves have holes. Not Oyen\'s doing. This time.'**
  String get roomItemMonsteraDesc;

  /// Name of the room item "Cat Tunnel".
  ///
  /// In en, this message translates to:
  /// **'Cat Tunnel'**
  String get roomItemTerowongan;

  /// Shop description of the room item "Cat Tunnel".
  ///
  /// In en, this message translates to:
  /// **'One cat goes in, style comes out.'**
  String get roomItemTerowonganDesc;

  /// Name of the room item "Window Hammock".
  ///
  /// In en, this message translates to:
  /// **'Window Hammock'**
  String get roomItemHammock;

  /// Shop description of the room item "Window Hammock".
  ///
  /// In en, this message translates to:
  /// **'Naps with a swing. Wake up and it\'s evening.'**
  String get roomItemHammockDesc;

  /// Name of the room item "Mini Sofa".
  ///
  /// In en, this message translates to:
  /// **'Mini Sofa'**
  String get roomItemSofaMini;

  /// Shop description of the room item "Mini Sofa".
  ///
  /// In en, this message translates to:
  /// **'Its own sofa, so Mom\'s is safe. Allegedly.'**
  String get roomItemSofaMiniDesc;

  /// Name of the room item "Bird Window".
  ///
  /// In en, this message translates to:
  /// **'Bird Window'**
  String get roomItemJendelaBurung;

  /// Shop description of the room item "Bird Window".
  ///
  /// In en, this message translates to:
  /// **'24-hour cat TV, all birds, no ads.'**
  String get roomItemJendelaBurungDesc;

  /// Name of the room item "Food bowl".
  ///
  /// In en, this message translates to:
  /// **'Food bowl'**
  String get roomItemMangkuk;

  /// Name of the collection cat "Oyen".
  ///
  /// In en, this message translates to:
  /// **'Oyen'**
  String get kittyOyen;

  /// Shop description of the collection cat "Oyen".
  ///
  /// In en, this message translates to:
  /// **'The ginger cat you wake up every level.'**
  String get kittyOyenDesc;

  /// Name of the collection cat "Snowy".
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get kittySalju;

  /// Shop description of the collection cat "Snowy".
  ///
  /// In en, this message translates to:
  /// **'Spotless white. Stays that way until it finds a box.'**
  String get kittySaljuDesc;

  /// Name of the collection cat "Patches".
  ///
  /// In en, this message translates to:
  /// **'Patches'**
  String get kittyTelon;

  /// Shop description of the collection cat "Patches".
  ///
  /// In en, this message translates to:
  /// **'Three colors, three moods a minute.'**
  String get kittyTelonDesc;

  /// Name of the collection cat "Charcoal".
  ///
  /// In en, this message translates to:
  /// **'Charcoal'**
  String get kittyArang;

  /// Shop description of the collection cat "Charcoal".
  ///
  /// In en, this message translates to:
  /// **'Deep black, yellow eyes. Expert shadow hider.'**
  String get kittyArangDesc;

  /// Name of the collection cat "Cloudy".
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get kittyMendung;

  /// Shop description of the collection cat "Cloudy".
  ///
  /// In en, this message translates to:
  /// **'Looks sad, is just sleepy.'**
  String get kittyMendungDesc;

  /// Name of the collection cat "Latte".
  ///
  /// In en, this message translates to:
  /// **'Latte'**
  String get kittyKopiSusu;

  /// Shop description of the collection cat "Latte".
  ///
  /// In en, this message translates to:
  /// **'Sweet, a little bitter when woken up.'**
  String get kittyKopiSusuDesc;

  /// Name of the collection cat "Mochi".
  ///
  /// In en, this message translates to:
  /// **'Mochi'**
  String get kittyMochi;

  /// Shop description of the collection cat "Mochi".
  ///
  /// In en, this message translates to:
  /// **'Calm, squishy, face like it played in mud.'**
  String get kittyMochiDesc;

  /// Name of the collection cat "Boss".
  ///
  /// In en, this message translates to:
  /// **'Boss'**
  String get kittyBos;

  /// Shop description of the collection cat "Boss".
  ///
  /// In en, this message translates to:
  /// **'Always in a suit. Meetings at every mealtime.'**
  String get kittyBosDesc;

  /// Name of the collection cat "Blossom".
  ///
  /// In en, this message translates to:
  /// **'Blossom'**
  String get kittyKembang;

  /// Shop description of the collection cat "Blossom".
  ///
  /// In en, this message translates to:
  /// **'Abstract markings, abstract behavior.'**
  String get kittyKembangDesc;

  /// Name of the accessory "Ribbon".
  ///
  /// In en, this message translates to:
  /// **'Ribbon'**
  String get accessoryPita;

  /// Shop description of the accessory "Ribbon".
  ///
  /// In en, this message translates to:
  /// **'Simple, sweet, easy to put on.'**
  String get accessoryPitaDesc;

  /// Name of the accessory "Flower Clip".
  ///
  /// In en, this message translates to:
  /// **'Flower Clip'**
  String get accessoryJepitBunga;

  /// Shop description of the accessory "Flower Clip".
  ///
  /// In en, this message translates to:
  /// **'Always in bloom, never needs water.'**
  String get accessoryJepitBungaDesc;

  /// Name of the accessory "Bandana".
  ///
  /// In en, this message translates to:
  /// **'Bandana'**
  String get accessoryBandana;

  /// Shop description of the accessory "Bandana".
  ///
  /// In en, this message translates to:
  /// **'Cowboy style, suburban edition.'**
  String get accessoryBandanaDesc;

  /// Name of the accessory "Bow Tie".
  ///
  /// In en, this message translates to:
  /// **'Bow Tie'**
  String get accessoryDasiKupu;

  /// Shop description of the accessory "Bow Tie".
  ///
  /// In en, this message translates to:
  /// **'Ready for the party, no invitation.'**
  String get accessoryDasiKupuDesc;

  /// Name of the accessory "Bell Collar".
  ///
  /// In en, this message translates to:
  /// **'Bell Collar'**
  String get accessoryKalung;

  /// Shop description of the accessory "Bell Collar".
  ///
  /// In en, this message translates to:
  /// **'Jingle jingle. Busted on every fish heist.'**
  String get accessoryKalungDesc;

  /// Name of the accessory "Knit Scarf".
  ///
  /// In en, this message translates to:
  /// **'Knit Scarf'**
  String get accessorySyal;

  /// Shop description of the accessory "Knit Scarf".
  ///
  /// In en, this message translates to:
  /// **'Warm. Knitted by an imaginary grandma.'**
  String get accessorySyalDesc;

  /// Name of the accessory "Beanie".
  ///
  /// In en, this message translates to:
  /// **'Beanie'**
  String get accessoryBeanie;

  /// Shop description of the accessory "Beanie".
  ///
  /// In en, this message translates to:
  /// **'Warm. Even though it\'s hot outside.'**
  String get accessoryBeanieDesc;

  /// Name of the accessory "Chef Hat".
  ///
  /// In en, this message translates to:
  /// **'Chef Hat'**
  String get accessoryTopiKoki;

  /// Shop description of the accessory "Chef Hat".
  ///
  /// In en, this message translates to:
  /// **'Cooking? No. Tasting? Always.'**
  String get accessoryTopiKokiDesc;

  /// Name of the accessory "Beret".
  ///
  /// In en, this message translates to:
  /// **'Beret'**
  String get accessoryBaret;

  /// Shop description of the accessory "Beret".
  ///
  /// In en, this message translates to:
  /// **'Instant artist. Masterpiece: a torn pillow.'**
  String get accessoryBaretDesc;

  /// Name of the accessory "Round Glasses".
  ///
  /// In en, this message translates to:
  /// **'Round Glasses'**
  String get accessoryKacamata;

  /// Shop description of the accessory "Round Glasses".
  ///
  /// In en, this message translates to:
  /// **'Looks smart. Still knocks the vase over.'**
  String get accessoryKacamataDesc;

  /// Name of the accessory "Headphones".
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get accessoryHeadphone;

  /// Shop description of the accessory "Headphones".
  ///
  /// In en, this message translates to:
  /// **'Lo-fi on, pretending to be busy.'**
  String get accessoryHeadphoneDesc;

  /// Name of the accessory "Reindeer Antlers".
  ///
  /// In en, this message translates to:
  /// **'Reindeer Antlers'**
  String get accessoryTandukRusa;

  /// Shop description of the accessory "Reindeer Antlers".
  ///
  /// In en, this message translates to:
  /// **'A pretend reindeer. Still meows.'**
  String get accessoryTandukRusaDesc;

  /// Name of the accessory "Party Hat".
  ///
  /// In en, this message translates to:
  /// **'Party Hat'**
  String get accessoryTopiPesta;

  /// Shop description of the accessory "Party Hat".
  ///
  /// In en, this message translates to:
  /// **'Every day is a birthday when you\'re a cat.'**
  String get accessoryTopiPestaDesc;

  /// Name of the accessory "Wizard Hat".
  ///
  /// In en, this message translates to:
  /// **'Wizard Hat'**
  String get accessoryTopiPenyihir;

  /// Shop description of the accessory "Wizard Hat".
  ///
  /// In en, this message translates to:
  /// **'Can make fish appear. Allegedly.'**
  String get accessoryTopiPenyihirDesc;

  /// Name of the accessory "Flower Crown".
  ///
  /// In en, this message translates to:
  /// **'Flower Crown'**
  String get accessoryMahkota;

  /// Shop description of the accessory "Flower Crown".
  ///
  /// In en, this message translates to:
  /// **'Queen of the room. Don\'t eat the flowers.'**
  String get accessoryMahkotaDesc;

  /// Name of the accessory "King's Crown".
  ///
  /// In en, this message translates to:
  /// **'King\'s Crown'**
  String get accessoryMahkotaRaja;

  /// Shop description of the accessory "King's Crown".
  ///
  /// In en, this message translates to:
  /// **'King of the room. Taxes paid in head scratches.'**
  String get accessoryMahkotaRajaDesc;

  /// Name of the snack "Salted Fish".
  ///
  /// In en, this message translates to:
  /// **'Salted Fish'**
  String get snackIkanAsin;

  /// Shop description of the snack "Salted Fish".
  ///
  /// In en, this message translates to:
  /// **'Salty, savory, the neighbors can smell it.'**
  String get snackIkanAsinDesc;

  /// Name of the snack "Milk".
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get snackSusu;

  /// Shop description of the snack "Milk".
  ///
  /// In en, this message translates to:
  /// **'A small saucer. White whiskers guaranteed.'**
  String get snackSusuDesc;

  /// Name of the snack "Canned Tuna".
  ///
  /// In en, this message translates to:
  /// **'Canned Tuna'**
  String get snackTuna;

  /// Shop description of the snack "Canned Tuna".
  ///
  /// In en, this message translates to:
  /// **'The can opening summons every cat.'**
  String get snackTunaDesc;

  /// Name of the snack "Cat Biscuits".
  ///
  /// In en, this message translates to:
  /// **'Cat Biscuits'**
  String get snackBiskuit;

  /// Shop description of the snack "Cat Biscuits".
  ///
  /// In en, this message translates to:
  /// **'Crunchy and cheap. Not very filling.'**
  String get snackBiskuitDesc;

  /// Name of the snack "Fish Pudding".
  ///
  /// In en, this message translates to:
  /// **'Fish Pudding'**
  String get snackPuding;

  /// Shop description of the snack "Fish Pudding".
  ///
  /// In en, this message translates to:
  /// **'Fancy. Very filling, very happy.'**
  String get snackPudingDesc;

  /// Accessory rarity badge in the shop: common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// Accessory rarity badge in the shop: rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// Accessory rarity badge in the shop: special.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get raritySpecial;

  /// Shop screen title, and the menu button that opens it.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// Shop tab: room items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get shopTabItems;

  /// Shop tab: collection cats.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get shopTabKitties;

  /// Shop tab: accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get shopTabAccessories;

  /// Shop tab: snacks.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get shopTabSnacks;

  /// Line above the cat cards in the shop.
  ///
  /// In en, this message translates to:
  /// **'Every cat shares the room with Oyen. Oyen agrees. Probably.'**
  String get shopKittyIntro;

  /// Line above the snack cards in the shop.
  ///
  /// In en, this message translates to:
  /// **'Snacks go into your stock. Hand them out from the cat card in the room.'**
  String get shopSnackIntro;

  /// Shop card badge: already owned.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get shopOwnedTag;

  /// Shop card badge: this cat already lives in the room.
  ///
  /// In en, this message translates to:
  /// **'Lives in the room'**
  String get shopLivesHere;

  /// Shop card badge: the player cannot afford this yet.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get shopNotEnoughTag;

  /// How many coins are still missing for this cat.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{{n} coin short} other{{n} coins short}}'**
  String shopShortBy(int n);

  /// Shop cat card button: adopt for this many coins.
  ///
  /// In en, this message translates to:
  /// **'Adopt · {n}'**
  String shopAdopt(int n);

  /// Shop snack card button: buy for this many coins.
  ///
  /// In en, this message translates to:
  /// **'Buy · {n}'**
  String shopBuyShort(int n);

  /// Shop snack card: how many are in stock.
  ///
  /// In en, this message translates to:
  /// **'Stock: {n}'**
  String shopStock(int n);

  /// Label before the row of cats used for the accessory preview.
  ///
  /// In en, this message translates to:
  /// **'Try on:'**
  String get shopTryOn;

  /// Accessory preview panel overline, with the cat name.
  ///
  /// In en, this message translates to:
  /// **'Preview · {name}'**
  String shopPreviewOf(String name);

  /// Button: put the owned accessory on the previewed cat, for free.
  ///
  /// In en, this message translates to:
  /// **'Wear · Free'**
  String get shopWearFree;

  /// Button: take the accessory off the previewed cat, for free.
  ///
  /// In en, this message translates to:
  /// **'Take off · Free'**
  String get shopRemoveFree;

  /// Hint under the accessory button when coins are missing.
  ///
  /// In en, this message translates to:
  /// **'Play a puzzle first, the coins will follow.'**
  String get shopPlayFirst;

  /// Accessory card note: which cats wear it (comma separated names).
  ///
  /// In en, this message translates to:
  /// **'Worn by {name}'**
  String shopWornBy(String name);

  /// Cheer shown after putting an accessory on a cat.
  ///
  /// In en, this message translates to:
  /// **'Looking good!'**
  String get shopFlashNice;

  /// Note shown after taking an accessory off.
  ///
  /// In en, this message translates to:
  /// **'Off, free of charge'**
  String get shopFlashRemoved;

  /// Floating note after buying a snack: coins spent.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{-{n} coin} other{-{n} coins}}'**
  String shopFlashSpent(int n);

  /// Screen reader label of a cat button in the preview row.
  ///
  /// In en, this message translates to:
  /// **'Try the accessory on {name}'**
  String shopPreviewPickLabel(String name);

  /// Screen reader label of a shop card the player can afford.
  ///
  /// In en, this message translates to:
  /// **'{name}, {n, plural, one{{n} coin} other{{n} coins}}'**
  String shopCardBuyLabel(String name, int n);

  /// Screen reader label of a shop card that costs more than the balance.
  ///
  /// In en, this message translates to:
  /// **'{name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins'**
  String shopCardShortLabel(String name, int n);

  /// Screen reader label of a shop card for something already owned.
  ///
  /// In en, this message translates to:
  /// **'{name}, already yours'**
  String shopCardOwnedLabel(String name);

  /// Screen reader label of a cat card for a cat already adopted.
  ///
  /// In en, this message translates to:
  /// **'{name}, already lives in the room'**
  String shopCardLivesLabel(String name);

  /// Screen reader label of the snack buy button.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} for {n, plural, one{{n} coin} other{{n} coins}}'**
  String shopSnackBuyLabel(String name, int n);

  /// Screen reader label of the snack buy button when coins are missing.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} for {n, plural, one{{n} coin} other{{n} coins}}, not enough coins'**
  String shopSnackShortLabel(String name, int n);

  /// Screen reader label of the buy confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}'**
  String buySheetLabel(String name);

  /// Overline above the title after a successful purchase.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get buySuccessOverline;

  /// Buy sheet title after buying a room item.
  ///
  /// In en, this message translates to:
  /// **'{name} is yours!'**
  String buySuccessItem(String name);

  /// Buy sheet body after buying a room item.
  ///
  /// In en, this message translates to:
  /// **'It\'s in the room already. Move it around in decorate mode.'**
  String get buySuccessItemBody;

  /// Buy sheet title after adopting a cat.
  ///
  /// In en, this message translates to:
  /// **'{name} moved into the room!'**
  String buySuccessKitty(String name);

  /// Buy sheet body after adopting a cat.
  ///
  /// In en, this message translates to:
  /// **'Say hi in the room. Expect some fake indifference first.'**
  String get buySuccessKittyBody;

  /// Buy sheet title after buying an accessory.
  ///
  /// In en, this message translates to:
  /// **'{name} is yours forever!'**
  String buySuccessAccessory(String name);

  /// Buy sheet body after buying an accessory, with the previewed cat name.
  ///
  /// In en, this message translates to:
  /// **'Put it on {name} now, or move it to another cat any time.'**
  String buySuccessAccessoryBody(String name);

  /// Note in the accessory buy sheet before paying.
  ///
  /// In en, this message translates to:
  /// **'Buy once, keep forever. Free to put on and take off, for every cat.'**
  String get buyAccessoryInfo;

  /// Buy sheet button: pay this many coins.
  ///
  /// In en, this message translates to:
  /// **'Buy · {n, plural, one{{n} coin} other{{n} coins}}'**
  String buyPay(int n);

  /// Buy sheet button: close without buying.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get buyLater;

  /// Buy sheet button after a purchase: back to the shop.
  ///
  /// In en, this message translates to:
  /// **'Keep shopping'**
  String get buyAgain;

  /// Buy sheet button after a purchase: open the room.
  ///
  /// In en, this message translates to:
  /// **'See it in the room'**
  String get buySeeRoom;

  /// Buy sheet button after buying an accessory: put it on this cat.
  ///
  /// In en, this message translates to:
  /// **'Wear on {name}'**
  String buyWearOn(String name);

  /// Buy sheet hint when the player cannot afford the item.
  ///
  /// In en, this message translates to:
  /// **'Play a puzzle or watch a rewarded ad to get more coins.'**
  String get buyNotEnoughHelp;

  /// What a room cat is doing, for its screen reader label.
  ///
  /// In en, this message translates to:
  /// **'{pose, select, idle{sitting still} lick{licking a paw} walk1{walking} walk2{walking} sleep{curled up asleep} eat{eating from the bowl} play{batting a toy} scratch{scratching the post} happy{happy} lesu{listless} rebah{lounging} petted{being petted, purring} other{sitting still}}'**
  String kittyPose(String pose);

  /// Screen reader label of a room cat: name and what it is doing.
  ///
  /// In en, this message translates to:
  /// **'{name} {pose}'**
  String kittyLabel(String name, String pose);

  /// Screen reader label of a room cat wearing an accessory.
  ///
  /// In en, this message translates to:
  /// **'{name} {pose}, wearing a {accessory}'**
  String kittyLabelAccessory(String name, String pose, String accessory);

  /// Screen reader label of the snack buy button when the stock is full.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}, stock full'**
  String shopSnackFullLabel(String name);

  /// Snack card chip when the stock is at the maximum.
  ///
  /// In en, this message translates to:
  /// **'Stock full'**
  String get shopStockFull;

  /// Screen reader label of an accessory card the player can afford.
  ///
  /// In en, this message translates to:
  /// **'View {name}, {n, plural, one{{n} coin} other{{n} coins}}'**
  String shopAccessoryBuyLabel(String name, int n);

  /// Screen reader label of an accessory card that costs more than the balance.
  ///
  /// In en, this message translates to:
  /// **'View {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins'**
  String shopAccessoryShortLabel(String name, int n);

  /// Screen reader label of an owned accessory card nobody wears.
  ///
  /// In en, this message translates to:
  /// **'View {name}, yours'**
  String shopAccessoryOwnedLabel(String name);

  /// Screen reader label of an owned accessory card with the cats wearing it.
  ///
  /// In en, this message translates to:
  /// **'View {name}, yours, worn by {who}'**
  String shopAccessoryWornLabel(String name, String who);

  /// Screen reader label of the thought bubble above a hungry room cat.
  ///
  /// In en, this message translates to:
  /// **'Droopy: hungry'**
  String get sadMarkHungry;

  /// Screen reader label of the thought bubble above a room cat that needs attention.
  ///
  /// In en, this message translates to:
  /// **'Droopy: wants attention'**
  String get sadMarkSad;

  /// Speech bubble in an empty starter room, pointing the player to the shop.
  ///
  /// In en, this message translates to:
  /// **'Pretty empty in here. To the Shop!'**
  String get roomEmptyBubble;

  /// Short label inside the empty dashed spot on the wall of a starter room.
  ///
  /// In en, this message translates to:
  /// **'Wall decor?'**
  String get roomEmptyWall;

  /// Screen reader label of the empty wall spot; tapping opens the shop.
  ///
  /// In en, this message translates to:
  /// **'Empty. Find wall decor in the Shop'**
  String get roomEmptyWallHint;

  /// Short label inside the empty dashed spot on the floor of a starter room.
  ///
  /// In en, this message translates to:
  /// **'A bed, maybe?'**
  String get roomEmptyFloor;

  /// Screen reader label of the empty floor spot; tapping opens the shop.
  ///
  /// In en, this message translates to:
  /// **'Empty. Find a bed or a toy in the Shop'**
  String get roomEmptyFloorHint;

  /// Room menu button that opens the accessories tab of the shop.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// Added to a room menu button's screen reader label when something there is affordable and not owned yet.
  ///
  /// In en, this message translates to:
  /// **'something new you can afford'**
  String get shopHasNew;

  /// Screen reader label of a room menu button with a red dot. {label} is the button name, {note} is shopHasNew.
  ///
  /// In en, this message translates to:
  /// **'{label}, {note}'**
  String menuButtonNew(String label, String note);

  /// Screen reader label of a cat in the room.
  ///
  /// In en, this message translates to:
  /// **'{name}. Tap to see their card'**
  String kittyTapHint(String name);

  /// Screen reader label of a hungry cat in the room.
  ///
  /// In en, this message translates to:
  /// **'{name}, hungry. Tap to see their card'**
  String kittyTapHintHungry(String name);

  /// Hunger bar label on a cat card (higher = fuller).
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get needHunger;

  /// Happiness bar label on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get needJoy;

  /// Screen reader label of a need bar.
  ///
  /// In en, this message translates to:
  /// **'{label} {value} out of 100'**
  String needValueLabel(String label, int value);

  /// Screen reader label of a need bar that is almost empty.
  ///
  /// In en, this message translates to:
  /// **'{label} {value} out of 100, almost empty'**
  String needValueLow(String label, int value);

  /// Warning under an almost empty hunger bar.
  ///
  /// In en, this message translates to:
  /// **'Almost empty! That tummy is rumbling.'**
  String get needLowHunger;

  /// Warning under an almost empty happiness bar.
  ///
  /// In en, this message translates to:
  /// **'Almost empty! Pet them already.'**
  String get needLowJoy;

  /// Screen reader label of the cat card dialog.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s card'**
  String kittyCardLabel(String name);

  /// Screen reader label of the close button on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Close card'**
  String get kittyCardClose;

  /// Cat card button that pets the cat.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get petAction;

  /// Cat card button that opens the snack list.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snackPanel;

  /// Heading above the snack list on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Pick from your stock'**
  String get snackPick;

  /// Screen reader label of a snack on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Give {name}, {count} in stock'**
  String snackGive(String name, int count);

  /// Screen reader label of a snack that ran out.
  ///
  /// In en, this message translates to:
  /// **'Give {name}, {count} in stock, all gone'**
  String snackGiveEmpty(String name, int count);

  /// Heading above the owned accessories on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Yours · swap for free'**
  String get accessoryPanelTitle;

  /// Link on a cat card to the accessories shop (an arrow icon follows it).
  ///
  /// In en, this message translates to:
  /// **'Accessory shop'**
  String get accessoryShopLink;

  /// Card in the accessory list that takes the accessory off.
  ///
  /// In en, this message translates to:
  /// **'Take off'**
  String get accessoryRemove;

  /// Tag on the accessory the cat is wearing.
  ///
  /// In en, this message translates to:
  /// **'Wearing'**
  String get accessoryWornTag;

  /// Screen reader label of an accessory on a cat card.
  ///
  /// In en, this message translates to:
  /// **'Put {accessory} on {name}'**
  String accessoryWearLabel(String accessory, String name);

  /// Screen reader label of the accessory the cat is wearing.
  ///
  /// In en, this message translates to:
  /// **'Put {accessory} on {name}, wearing it now'**
  String accessoryWornLabel(String accessory, String name);

  /// Screen reader label of the take-off card.
  ///
  /// In en, this message translates to:
  /// **'Take {name}\'s accessory off'**
  String accessoryRemoveLabel(String name);

  /// Floating text over a cat after a snack.
  ///
  /// In en, this message translates to:
  /// **'+{hunger} full'**
  String reactionFed(int hunger);

  /// Floating text over a cat after a snack that also makes it happy.
  ///
  /// In en, this message translates to:
  /// **'+{hunger} full, +{joy} happy'**
  String reactionFedJoy(int hunger, int joy);

  /// Floating text over a cat after petting.
  ///
  /// In en, this message translates to:
  /// **'+{joy} happy'**
  String reactionJoy(int joy);

  /// Floating text over a cat after putting an accessory on.
  ///
  /// In en, this message translates to:
  /// **'Looking sharp!'**
  String get reactionNice;

  /// Floating text over a cat after taking its accessory off.
  ///
  /// In en, this message translates to:
  /// **'Ahh, free!'**
  String get reactionRelieved;

  /// Room button that starts decorate mode.
  ///
  /// In en, this message translates to:
  /// **'Decorate'**
  String get decorate;

  /// Button that ends decorate mode.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get decorateDone;

  /// Chip shown while decorating.
  ///
  /// In en, this message translates to:
  /// **'Drag things to a new spot'**
  String get decorateHint;

  /// Label of the wall area while decorating.
  ///
  /// In en, this message translates to:
  /// **'Wall area'**
  String get zoneWall;

  /// Label of the floor area while decorating.
  ///
  /// In en, this message translates to:
  /// **'Floor area'**
  String get zoneFloor;

  /// Title of the storage tray with owned items that are not in the room.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Number of items in storage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String storageCount(int count);

  /// Hint on the storage tray.
  ///
  /// In en, this message translates to:
  /// **'Tap to place'**
  String get storageTapHint;

  /// Storage tray when every item is in the room.
  ///
  /// In en, this message translates to:
  /// **'Storage is empty. Everything\'s on display, Oyen is proud.'**
  String get storageEmpty;

  /// Screen reader label of an item in storage.
  ///
  /// In en, this message translates to:
  /// **'Put {item} in the room'**
  String storagePlaceLabel(String item);

  /// Screen reader label of the storage tray.
  ///
  /// In en, this message translates to:
  /// **'Item storage'**
  String get storageLabel;

  /// Screen reader action on a room item while decorating.
  ///
  /// In en, this message translates to:
  /// **'Move to storage'**
  String get storeItemAction;

  /// Praise shown after decorating.
  ///
  /// In en, this message translates to:
  /// **'Room\'s looking great!'**
  String get decoratePraise;

  /// Bonus line under the decorating praise.
  ///
  /// In en, this message translates to:
  /// **'+{joy} Happy for every cat'**
  String decoratePraiseJoy(int joy);

  /// Label over the empty shared food bowl in the cat room: hours until it refills.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one{Refills in {hours} hour} other{Refills in {hours} hours}}'**
  String bowlRefill(int hours);

  /// Screen reader label of the coin bubble over a well cared-for cat; tapping collects the daily reward.
  ///
  /// In en, this message translates to:
  /// **'{coins, plural, one{Collect {coins} coin from {name}} other{Collect {coins} coins from {name}}}'**
  String kittyRewardLabel(int coins, String name);

  /// Floating text over a cat after collecting its coin reward.
  ///
  /// In en, this message translates to:
  /// **'{coins, plural, one{+{coins} coin} other{+{coins} coins}}'**
  String reactionCoins(int coins);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'pt', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
