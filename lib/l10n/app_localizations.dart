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

  /// Costume closet button and screen title.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get closet;

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

  /// Word after the star total on the home screen ("31/60 stars").
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get starTotalUnit;

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

  /// Costume: none.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get costumeNone;

  /// Costume: peci (Indonesian cap).
  ///
  /// In en, this message translates to:
  /// **'Peci Cap'**
  String get costumePeci;

  /// Costume: sarong.
  ///
  /// In en, this message translates to:
  /// **'Sarong'**
  String get costumeSarung;

  /// Costume: chef hat.
  ///
  /// In en, this message translates to:
  /// **'Chef Hat'**
  String get costumeKoki;

  /// Costume: glasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get costumeKacamata;

  /// Costume card tag: being worn.
  ///
  /// In en, this message translates to:
  /// **'Wearing'**
  String get costumeWearingTag;

  /// Screen reader status: being worn.
  ///
  /// In en, this message translates to:
  /// **'wearing'**
  String get costumeWearingStatus;

  /// Costume card tag: owned.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get costumeOwnedTag;

  /// Screen reader status: owned.
  ///
  /// In en, this message translates to:
  /// **'yours'**
  String get costumeOwnedStatus;

  /// Closet button: selected costume is worn.
  ///
  /// In en, this message translates to:
  /// **'Wearing now'**
  String get costumeActionWearing;

  /// Closet button: wear the owned costume.
  ///
  /// In en, this message translates to:
  /// **'Wear'**
  String get costumeActionWear;

  /// Closet button: buy for n coins.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Buy · {n} coin} other{Buy · {n} coins}}'**
  String costumeActionBuy(int n);

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
  /// **'Coins buy hints and outfits for Oyen. Grab the daily bonus, or watch an ad.'**
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
  /// **'Erase stars, coins, outfits, hints, and tutorials, then start again from level 1.'**
  String get resetProgressInfo;

  /// Reset confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Erase all progress?'**
  String get resetConfirmTitle;

  /// Reset confirmation text.
  ///
  /// In en, this message translates to:
  /// **'Stars, coins, outfits, hints, and tutorials will be erased. This can\'t be undone. Today\'s daily bonus and ads stay used.'**
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
