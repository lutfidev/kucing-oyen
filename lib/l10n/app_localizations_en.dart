// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get backToHome => 'Back to home';

  @override
  String get backToMap => 'Back to map';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String starsOf(int stars, int total) {
    return '$stars of $total stars';
  }

  @override
  String coinsAmount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n coins',
      one: '$n coin',
    );
    return '$_temp0';
  }

  @override
  String coinsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'coins',
      one: 'coin',
    );
    return '$_temp0';
  }

  @override
  String notEnoughCoins(int n) {
    return 'Not enough · $n';
  }

  @override
  String get watchAd => 'Watch an ad';

  @override
  String get adFailed => 'The ad couldn\'t play. Try again later, okay?';

  @override
  String get boardLabel => 'Game board, 7 by 9 tiles';

  @override
  String get play => 'Play';

  @override
  String get closet => 'Wardrobe';

  @override
  String get settings => 'Settings';

  @override
  String get tagline => 'Oyen won\'t listen. You do the thinking.';

  @override
  String get splashTagline => 'Let\'s play!';

  @override
  String get starTotalUnit => 'stars';

  @override
  String chapterNumber(int n) {
    return 'Chapter $n';
  }

  @override
  String get chapter1Name => 'Kitchen';

  @override
  String get chapter2Name => 'Living Room';

  @override
  String chapterTitle(int n, String name) {
    return 'Chapter $n – $name';
  }

  @override
  String get chapterDone => 'Done';

  @override
  String get chapterLocked => 'Locked';

  @override
  String get statusDone => 'done';

  @override
  String get statusLocked => 'locked';

  @override
  String get statusPlayNow => 'play now';

  @override
  String nodeStars(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stars',
      one: '$n star',
    );
    return '$_temp0';
  }

  @override
  String levelNodeLabel(int id, String status) {
    return 'Level $id, $status';
  }

  @override
  String bossNodeLabel(int id, String name, String status) {
    return 'Level $id, boss $name, $status';
  }

  @override
  String bossTag(String name) {
    return 'Boss · $name';
  }

  @override
  String get chapterMissing => 'This chapter doesn\'t exist.';

  @override
  String get level1Name => 'Wake Up Oyen';

  @override
  String get level2Name => 'Round the Corner';

  @override
  String get level3Name => 'First Fish';

  @override
  String get level4Name => 'Nearest Fish';

  @override
  String get level5Name => 'Two Fish';

  @override
  String get level6Name => 'First Bucket';

  @override
  String get level7Name => 'Puddle';

  @override
  String get level8Name => 'Fish and Bucket';

  @override
  String get level9Name => 'Tempting Fish';

  @override
  String get level10Name => 'Salted Fish Feast';

  @override
  String get level11Name => 'Coffee Table';

  @override
  String get level12Name => 'Falling Glass';

  @override
  String get level13Name => 'Mom\'s Vase';

  @override
  String get level14Name => 'Box in the Way';

  @override
  String get level15Name => 'Squashed Box';

  @override
  String get level16Name => 'The Long Way Round';

  @override
  String get level17Name => 'Two Vases';

  @override
  String get level18Name => 'Tight Squeeze';

  @override
  String get level19Name => 'All Together';

  @override
  String get level20Name => 'Eid Day';

  @override
  String bossLevelName(String name) {
    return 'BOSS: $name';
  }

  @override
  String levelTitle(int id, String name) {
    return 'Level $id · $name';
  }

  @override
  String get rules => 'Rules';

  @override
  String get hint => 'Hint';

  @override
  String targetItems(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'use $n items',
      one: 'use $n item',
    );
    return '$_temp0';
  }

  @override
  String targetLabel(String text) {
    return '3-star goal: $text';
  }

  @override
  String get levelMissing => 'This level doesn\'t exist.';

  @override
  String get backToArrange => 'Back to setup';

  @override
  String get wakeOyen => 'Wake Oyen';

  @override
  String get trayEmpty => 'No items needed here yet.';

  @override
  String get trayLabel => 'Items';

  @override
  String get clearBoard => 'Clear the board';

  @override
  String get trayHintTop => 'Drop on a';

  @override
  String get trayHintBottom => 'glowing tile';

  @override
  String get itemFish => 'Salted fish';

  @override
  String get itemWater => 'Water bucket';

  @override
  String get itemBox => 'Box';

  @override
  String traySlotLabel(String name, int n) {
    return '$name, $n left';
  }

  @override
  String traySlotDragging(String name, int n) {
    return '$name, dragging, $n left';
  }

  @override
  String get traySlotSelectHint => 'pick it up';

  @override
  String get traySlotUnselectHint => 'cancel';

  @override
  String tileLabel(int row, int col, String content) {
    return 'Row $row, column $col: $content';
  }

  @override
  String get cellWall => 'wall';

  @override
  String get cellFloor => 'floor';

  @override
  String get cellBowl => 'Oyen\'s bowl';

  @override
  String get cellTable => 'table';

  @override
  String get cellTableGlass => 'table with a glass';

  @override
  String get cellTableVase => 'table with a vase';

  @override
  String get cellFish => 'salted fish';

  @override
  String get cellWater => 'puddle';

  @override
  String get cellBox => 'box';

  @override
  String tileOyen(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Oyen asleep, facing $_temp0';
  }

  @override
  String tilePlayerItem(String item) {
    return '$item, placed by you';
  }

  @override
  String tileHintSpot(String content) {
    return '$content. Hint: something has to go here.';
  }

  @override
  String tileHintItem(String content, String item) {
    return '$content. Hint: $item goes here.';
  }

  @override
  String get tilePlaceHint => 'put it here';

  @override
  String get tilePickHint => 'pick it up to move it';

  @override
  String get tileReturn => 'Back to the tray';

  @override
  String itemPickedAnnounce(String item) {
    return '$item picked up. Choose an empty floor tile to put it on.';
  }

  @override
  String itemPlacedAnnounce(String item, int row, int col) {
    return '$item placed at row $row, column $col.';
  }

  @override
  String itemReturnedAnnounce(String item) {
    return '$item is back in the tray.';
  }

  @override
  String get step => 'Step';

  @override
  String stepNumber(int n) {
    return 'Step $n';
  }

  @override
  String get vaseBroken => 'Vase broken';

  @override
  String get vaseSafe => 'Vase safe';

  @override
  String itemsUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items used',
      one: '$n item used',
    );
    return '$_temp0';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stepForward => 'One step forward';

  @override
  String get stepBack => 'One step back';

  @override
  String get doubleSpeed => 'Double speed';

  @override
  String get seeResult => 'See results';

  @override
  String runWake(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Oyen wakes up, facing $_temp0.';
  }

  @override
  String get runAtBowl => 'Made it to the bowl! Nom nom.';

  @override
  String chaseFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'to the right',
      'down': 'down',
      'left': 'to the left',
      'other': 'to the right',
    });
    return 'Chasing the fish $_temp0.';
  }

  @override
  String runSmellFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up there',
      'right': 'to the right',
      'down': 'down there',
      'left': 'to the left',
      'other': 'to the right',
    });
    return 'Hey, salted fish $_temp0!';
  }

  @override
  String runWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'to the right',
      'down': 'down',
      'left': 'to the left',
      'other': 'to the right',
    });
    return 'Strolling $_temp0, no rush.';
  }

  @override
  String get runScared => 'Water! Oyen jumps and turns back.';

  @override
  String runTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'a table',
      'wall': 'a wall',
      'other': 'a wall',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Hit $_temp0. Turned, now facing $_temp1.';
  }

  @override
  String get runEat => 'Chomp! The salted fish is gone.';

  @override
  String get runEnterBox => 'A box! Oyen climbs in and sits.';

  @override
  String get runSit => 'Sitting pretty in the box.';

  @override
  String get runBoxGone => 'The box gets squashed, then vanishes.';

  @override
  String get runKnockGlass => 'The glass gets pushed off. Lucky it\'s plastic!';

  @override
  String get runKnockVase => 'Uh-oh! Mom\'s vase falls and breaks.';

  @override
  String replayAsleep(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Start: Oyen asleep, facing $_temp0.';
  }

  @override
  String replayFinished(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n steps',
      one: '$n step',
    );
    return 'Into the bowl. Done in $_temp0.';
  }

  @override
  String get replayChaseVaseSafe => 'Chasing the fish. Vase still safe.';

  @override
  String replaySeeFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'to the right',
      'down': 'down',
      'left': 'to the left',
      'other': 'to the right',
    });
    return 'Salted fish in sight, straight $_temp0.';
  }

  @override
  String replayWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'to the right',
      'down': 'down',
      'left': 'to the left',
      'other': 'to the right',
    });
    return 'Walks straight $_temp0.';
  }

  @override
  String replayScared(String water) {
    String _temp0 = intl.Intl.selectLogic(water, {
      'puddle': 'a puddle',
      'bucket': 'a water bucket',
      'other': 'water',
    });
    return 'Meets $_temp0, jumps, turns back.';
  }

  @override
  String replayTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'a table',
      'wall': 'a wall',
      'other': 'a wall',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Hits $_temp0, turns to face $_temp1.';
  }

  @override
  String get replayEat => 'Chomp! Salted fish eaten.';

  @override
  String get replayEnterBox => 'Into the box, time to sit.';

  @override
  String get replaySit => 'Still sitting in the box.';

  @override
  String get replayBoxGone => 'The box is squashed and gone.';

  @override
  String get replayKnockGlass => 'Glass pushed off. No harm, it\'s plastic.';

  @override
  String get replayKnockVase => 'Mom\'s vase pushed off. Smash!';

  @override
  String get replayLoopStart =>
      'Back to how it started. Oyen keeps circling and gets bored.';

  @override
  String replayLoopStep(int n) {
    return 'Back to how step $n looked. Oyen keeps circling and gets bored.';
  }

  @override
  String replayTooManySteps(int n) {
    return 'Step $n and still no bowl. Oyen is bored.';
  }

  @override
  String get closeRules => 'Close rules';

  @override
  String get rulesTitle => 'Oyen\'s Rules';

  @override
  String get rulesIntro =>
      'Each step is checked from the top. The first rule that fits is what Oyen does.';

  @override
  String get ruleKnockTitle => 'Knock over what\'s next door';

  @override
  String get ruleKnockBody =>
      'A glass or vase on the table next door? It gets bumped. Always.';

  @override
  String get ruleFishTitle => 'Chase the nearest fish';

  @override
  String get ruleFishBody => 'Only fish in a straight line. If tied:';

  @override
  String get tieAhead => 'ahead';

  @override
  String get tieClockwise => 'clockwise';

  @override
  String get tieCounterClockwise => 'counterclockwise';

  @override
  String get tieBehind => 'behind';

  @override
  String get tieOrderLabel =>
      'Tie order: ahead, clockwise, counterclockwise, behind.';

  @override
  String get ruleWaterTitle => 'Water? Turn back';

  @override
  String get ruleWaterBody =>
      'Puddle or bucket ahead? Oyen gets spooked and turns around.';

  @override
  String get ruleWallTitle => 'Blocked by a wall or table';

  @override
  String get ruleWallTurn => 'Oyen turns clockwise';

  @override
  String get ruleWallBody => 'A quarter turn, then off again.';

  @override
  String get ruleBoxTitle => 'Box? Hop in, sit';

  @override
  String get ruleBoxBody =>
      'Sits 2 steps until the box gets squashed and vanishes. Fish behind a box stay hidden.';

  @override
  String get ruleKnockLocked => 'Things on tables';

  @override
  String get ruleFishLocked => 'Fish';

  @override
  String get ruleWaterLocked => 'Water';

  @override
  String get ruleWallLocked => 'Wall';

  @override
  String get ruleBoxLocked => 'Box';

  @override
  String ruleLockedTitle(String name) {
    return '$name: ???';
  }

  @override
  String get ruleLockedBody => 'Not learned yet. You\'ll meet it soon.';

  @override
  String ruleLabel(int n) {
    return 'Rule $n';
  }

  @override
  String ruleLockedLabel(int n) {
    return 'Rule $n, locked, not learned yet';
  }

  @override
  String get closeHints => 'Close hints';

  @override
  String get hintsTitle => 'Hints';

  @override
  String get hintsIntro => 'Go slow. Maybe all you need is a little nudge.';

  @override
  String get hintTier1Title => 'Highlight the first tile';

  @override
  String get hintTier2Title => 'Show the item type';

  @override
  String get hintTier3Title => 'Show the full solution';

  @override
  String get hintOpened => 'Unlocked';

  @override
  String hintTier(int n) {
    return 'Tier $n';
  }

  @override
  String hintUnlockFirst(int n) {
    return 'Unlock tier $n first';
  }

  @override
  String get noItemsHint => 'No items needed here. Just wake Oyen up!';

  @override
  String get hintTier1Text =>
      'See the glowing tile? Something needs to go there.';

  @override
  String get hintPlaceFish =>
      'Put a salted fish on the glowing tile. Oyen will chase it and eat it.';

  @override
  String get hintPlaceWater =>
      'Put a water bucket on the glowing tile. Oyen will get spooked and turn around.';

  @override
  String get hintPlaceBox =>
      'Put a box on the glowing tile. Oyen will climb in and sit there.';

  @override
  String hintFishCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'a salted fish',
      'two': 'two salted fish',
      'three': 'three salted fish',
      'other': '$n salted fish',
    });
    return '$_temp0';
  }

  @override
  String hintWaterCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'a water bucket',
      'two': 'two water buckets',
      'three': 'three water buckets',
      'other': '$n water buckets',
    });
    return '$_temp0';
  }

  @override
  String hintBoxCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'a box',
      'two': 'two boxes',
      'three': 'three boxes',
      'other': '$n boxes',
    });
    return '$_temp0';
  }

  @override
  String listPair(String a, String b) {
    return '$a and $b';
  }

  @override
  String listLast(String rest, String last) {
    return '$rest, and $last';
  }

  @override
  String hintSolution(String items, int count, String tail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tiles',
      one: 'tile',
    );
    return '$items on the glowing $_temp0. $tail';
  }

  @override
  String get hintSolutionVaseSafe => 'Vase safe, 3 stars.';

  @override
  String get hintSolutionStars => '3 stars!';

  @override
  String get tutorial1Title =>
      'You can\'t boss Oyen around. Just wake the cat up!';

  @override
  String get tutorial1Body => 'Oyen walks to the bowl alone. You just watch.';

  @override
  String get tutorial3Title => 'Oyen can\'t resist salted fish!';

  @override
  String get tutorial3Body =>
      'Drag a fish onto the floor. If Oyen sees it in a straight line, the chase is on.';

  @override
  String get tutorial6Title => 'Oyen hates water. Like, really.';

  @override
  String get tutorial6Body =>
      'Put the bucket in the way. Water ahead means a spooked cat and a U-turn.';

  @override
  String get tutorialLabel => 'Tutorial';

  @override
  String get skipTutorial => 'Skip tutorial';

  @override
  String get skip => 'Skip';

  @override
  String get success => 'Nailed it!';

  @override
  String stepsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'steps',
      one: 'step',
    );
    return '$_temp0';
  }

  @override
  String itemsUsedUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'items used',
      one: 'item used',
    );
    return '$_temp0';
  }

  @override
  String get goalBowl => 'Reached the bowl';

  @override
  String get goalVase => 'Mom\'s vase is safe';

  @override
  String get goalItems => 'Fewest items';

  @override
  String get goalNotYet => 'Not yet';

  @override
  String get goalGot => 'Got it';

  @override
  String get goalAchieved => 'done';

  @override
  String get restart => 'Restart';

  @override
  String get next => 'Next';

  @override
  String get watchReplay => 'Watch the replay';

  @override
  String get vaseHeadlineTop => 'Made it...';

  @override
  String get vaseHeadlineBottom => 'but Mom\'s vase?';

  @override
  String brokenAtStep(int n) {
    return 'Broke on step $n';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get nextAnyway => 'Next Anyway';

  @override
  String get vaseArtLabel =>
      'The vase lies broken behind Oyen, and Mom pops in at the door, annoyed';

  @override
  String get loopTitle => 'Oyen got bored going in circles.';

  @override
  String get loopBadge => 'Going in circles';

  @override
  String get loopMessage =>
      'Round and round, no bowl in sight. Oh well, back to sleep.';

  @override
  String get tooLongTitle => 'Oyen got tired of walking.';

  @override
  String tooLongBadge(int n) {
    return 'Over $n steps';
  }

  @override
  String tooLongMessage(int n) {
    return '$n steps and still no bowl. Ugh, so tired. Back to sleep.';
  }

  @override
  String failedKicker(int id) {
    return 'Level $id · Failed';
  }

  @override
  String get replay => 'Replay';

  @override
  String get arrangeAgain => 'Rearrange';

  @override
  String get replayStart => 'Start';

  @override
  String get backToResult => 'Back to results';

  @override
  String get recording => 'Recording';

  @override
  String replayStepCaption(int n, String text) {
    return 'Step $n. $text';
  }

  @override
  String get timeline => 'Time';

  @override
  String oyenLabel(String pose, String dir) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'standing',
      'walk': 'walking',
      'sleep': 'asleep',
      'shock': 'startled',
      'box': 'sitting in a box',
      'knock': 'knocking something over',
      'eat': 'eating',
      'happy': 'happy',
      'other': 'standing',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'up',
      'right': 'right',
      'down': 'down',
      'left': 'left',
      'other': 'right',
    });
    return 'Oyen $_temp0, facing $_temp1';
  }

  @override
  String get costumeNone => 'Plain';

  @override
  String get costumePeci => 'Peci Cap';

  @override
  String get costumeSarung => 'Sarong';

  @override
  String get costumeKoki => 'Chef Hat';

  @override
  String get costumeKacamata => 'Glasses';

  @override
  String get costumeWearingTag => 'Wearing';

  @override
  String get costumeWearingStatus => 'wearing';

  @override
  String get costumeOwnedTag => 'Yours';

  @override
  String get costumeOwnedStatus => 'yours';

  @override
  String get costumeActionWearing => 'Wearing now';

  @override
  String get costumeActionWear => 'Wear';

  @override
  String costumeActionBuy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Buy · $n coins',
      one: 'Buy · $n coin',
    );
    return '$_temp0';
  }

  @override
  String get closeCoins => 'Close coins';

  @override
  String get coinsTitle => 'Get Coins';

  @override
  String get coinsIntro =>
      'Coins buy hints and outfits for Oyen. Grab the daily bonus, or watch an ad.';

  @override
  String get dailyBonus => 'Daily bonus';

  @override
  String get dailyBonusReady => 'Once a day';

  @override
  String get dailyBonusTaken => 'Claimed today';

  @override
  String claimCoins(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Claim $n coins',
      one: 'Claim $n coin',
    );
    return '$_temp0';
  }

  @override
  String get claimTomorrow => 'Back tomorrow';

  @override
  String adsLeftToday(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n left today',
      one: '$n left today',
    );
    return '$_temp0';
  }

  @override
  String get adsUsedUp => 'All used up today';

  @override
  String adRewardButton(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n coins',
      one: '+$n coin',
    );
    return '$_temp0';
  }

  @override
  String get adsTomorrow => 'More tomorrow';

  @override
  String get coinChipAdd => 'get coins';

  @override
  String get coinChipBonus => 'daily bonus ready';

  @override
  String get soundSection => 'Sound';

  @override
  String get music => 'Music';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Use phone language';

  @override
  String get tutorialsSection => 'Tutorials';

  @override
  String get replayTutorials => 'Show tutorials again';

  @override
  String get replayTutorialsInfo =>
      'The tutorials on levels 1, 3, and 6 show up again next time you play them.';

  @override
  String get tutorialsBack => 'Done! The tutorials are back.';

  @override
  String get progressSection => 'Progress';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetProgressInfo =>
      'Erase stars, coins, outfits, hints, and tutorials, then start again from level 1.';

  @override
  String get resetConfirmTitle => 'Erase all progress?';

  @override
  String get resetConfirmBody =>
      'Stars, coins, outfits, hints, and tutorials will be erased. This can\'t be undone. Today\'s daily bonus and ads stay used.';

  @override
  String get resetConfirm => 'Erase';

  @override
  String get closeReset => 'Close reset';

  @override
  String get resetDone => 'Progress erased. Fresh start!';

  @override
  String get privacySection => 'Privacy';

  @override
  String get privacyInfo =>
      'Your progress stays on your phone. Ads come from Google AdMob.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get adConsent => 'Ad consent settings';

  @override
  String get privacyLinkFailed =>
      'Couldn\'t open the browser. Try again later, okay?';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get fontCredits =>
      'Fonts: Fredoka and Nunito (SIL Open Font License).';

  @override
  String get soundCredits =>
      'Sound effects: Kenney and OpenGameArt (CC0). The music was made just for Ginger Logic.';

  @override
  String get licenses => 'Licenses';
}
