// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get backToHome => 'На главную';

  @override
  String get backToMap => 'Назад к карте';

  @override
  String get close => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String starsOf(int stars, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total звёзд',
      one: '$total звезды',
    );
    return '$stars из $_temp0';
  }

  @override
  String coinsAmount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return '$_temp0';
  }

  @override
  String coinsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'монеты',
      many: 'монет',
      few: 'монеты',
      one: 'монета',
    );
    return '$_temp0';
  }

  @override
  String notEnoughCoins(int n) {
    return 'Мало монет · $n';
  }

  @override
  String get watchAd => 'Смотреть рекламу';

  @override
  String get adFailed => 'Реклама не загрузилась. Попробуй позже, ладно?';

  @override
  String get boardLabel => 'Игровое поле 7 на 9 клеток';

  @override
  String get play => 'Играть';

  @override
  String get closet => 'Гардероб';

  @override
  String get settings => 'Настройки';

  @override
  String get tagline => 'Ойен не слушается. Думать тебе.';

  @override
  String get splashTagline => 'Играем!';

  @override
  String get starTotalUnit => 'звёзд';

  @override
  String chapterNumber(int n) {
    return 'Глава $n';
  }

  @override
  String get chapter1Name => 'Кухня';

  @override
  String get chapter2Name => 'Гостиная';

  @override
  String chapterTitle(int n, String name) {
    return 'Глава $n – $name';
  }

  @override
  String get chapterDone => 'Пройдено';

  @override
  String get chapterLocked => 'Закрыто';

  @override
  String get statusDone => 'пройдено';

  @override
  String get statusLocked => 'закрыто';

  @override
  String get statusPlayNow => 'играть сейчас';

  @override
  String nodeStars(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n звезды',
      many: '$n звёзд',
      few: '$n звезды',
      one: '$n звезда',
    );
    return '$_temp0';
  }

  @override
  String levelNodeLabel(int id, String status) {
    return 'Уровень $id, $status';
  }

  @override
  String bossNodeLabel(int id, String name, String status) {
    return 'Уровень $id, босс «$name», $status';
  }

  @override
  String bossTag(String name) {
    return 'Босс · $name';
  }

  @override
  String get chapterMissing => 'Такой главы нет.';

  @override
  String get level1Name => 'Разбуди Ойена';

  @override
  String get level2Name => 'За угол';

  @override
  String get level3Name => 'Первая рыбка';

  @override
  String get level4Name => 'Ближайшая рыбка';

  @override
  String get level5Name => 'Две рыбки';

  @override
  String get level6Name => 'Первое ведро';

  @override
  String get level7Name => 'Лужа';

  @override
  String get level8Name => 'Рыбка и ведро';

  @override
  String get level9Name => 'Рыбка-искушение';

  @override
  String get level10Name => 'Пир солёной рыбки';

  @override
  String get level11Name => 'Журнальный столик';

  @override
  String get level12Name => 'Падающий стакан';

  @override
  String get level13Name => 'Мамина ваза';

  @override
  String get level14Name => 'Коробка на пути';

  @override
  String get level15Name => 'Мятая коробка';

  @override
  String get level16Name => 'Обходной путь';

  @override
  String get level17Name => 'Две вазы';

  @override
  String get level18Name => 'Тесная комната';

  @override
  String get level19Name => 'Всё вместе';

  @override
  String get level20Name => 'Ураза-байрам';

  @override
  String bossLevelName(String name) {
    return 'БОСС: $name';
  }

  @override
  String levelTitle(int id, String name) {
    return 'Уровень $id · $name';
  }

  @override
  String get rules => 'Правила';

  @override
  String get hint => 'Подсказка';

  @override
  String targetItems(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'до $n предметов',
      one: 'до $n предмета',
    );
    return '$_temp0';
  }

  @override
  String targetLabel(String text) {
    return 'Цель на 3 звезды: $text';
  }

  @override
  String get levelMissing => 'Такого уровня нет.';

  @override
  String get backToArrange => 'Назад к расстановке';

  @override
  String get wakeOyen => 'Разбудить Ойена';

  @override
  String get trayEmpty => 'Здесь пока не нужны предметы.';

  @override
  String get trayLabel => 'Вещи';

  @override
  String get clearBoard => 'Очистить поле';

  @override
  String get trayHintTop => 'Ставь на';

  @override
  String get trayHintBottom => 'светлую клетку';

  @override
  String get itemFish => 'Солёная рыбка';

  @override
  String get itemWater => 'Ведро воды';

  @override
  String get itemBox => 'Коробка';

  @override
  String traySlotLabel(String name, int n) {
    return '$name, осталось: $n';
  }

  @override
  String traySlotDragging(String name, int n) {
    return '$name, перетаскивается, осталось: $n';
  }

  @override
  String get traySlotSelectHint => 'взять эту вещь';

  @override
  String get traySlotUnselectHint => 'отменить';

  @override
  String tileLabel(int row, int col, String content) {
    return 'Ряд $row, столбец $col: $content';
  }

  @override
  String get cellWall => 'стена';

  @override
  String get cellFloor => 'пол';

  @override
  String get cellBowl => 'миска Ойена';

  @override
  String get cellTable => 'стол';

  @override
  String get cellTableGlass => 'стол со стаканом';

  @override
  String get cellTableVase => 'стол с вазой';

  @override
  String get cellFish => 'солёная рыбка';

  @override
  String get cellWater => 'лужа';

  @override
  String get cellBox => 'коробка';

  @override
  String tileOyen(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Ойен спит, смотрит $_temp0';
  }

  @override
  String tilePlayerItem(String item) {
    return '$item, твоя вещь';
  }

  @override
  String tileHintSpot(String content) {
    return '$content. Подсказка: сюда что-то нужно поставить.';
  }

  @override
  String tileHintItem(String content, String item) {
    return '$content. Подсказка: сюда — $item.';
  }

  @override
  String get tilePlaceHint => 'поставить сюда';

  @override
  String get tilePickHint => 'взять и переставить';

  @override
  String get tileReturn => 'Вернуть к вещам';

  @override
  String itemPickedAnnounce(String item) {
    return '$item в руке. Выбери пустую клетку пола.';
  }

  @override
  String itemPlacedAnnounce(String item, int row, int col) {
    return 'Готово: $item — ряд $row, столбец $col.';
  }

  @override
  String itemReturnedAnnounce(String item) {
    return '$item снова среди вещей.';
  }

  @override
  String get step => 'Шаг';

  @override
  String stepNumber(int n) {
    return 'Шаг $n';
  }

  @override
  String get vaseBroken => 'Ваза разбита';

  @override
  String get vaseSafe => 'Ваза цела';

  @override
  String itemsUsed(int n) {
    return 'Предметов: $n';
  }

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Дальше';

  @override
  String get stepForward => 'Шаг вперёд';

  @override
  String get stepBack => 'Шаг назад';

  @override
  String get doubleSpeed => 'Ускорить вдвое';

  @override
  String get seeResult => 'Результат';

  @override
  String runWake(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Ойен проснулся и смотрит $_temp0.';
  }

  @override
  String get runAtBowl => 'Дошёл до миски! Ням-ням.';

  @override
  String chaseFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Бежит за рыбкой $_temp0.';
  }

  @override
  String runSmellFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'сверху',
      'right': 'справа',
      'down': 'снизу',
      'left': 'слева',
      'other': 'справа',
    });
    return 'Ого, $_temp0 пахнет солёной рыбкой!';
  }

  @override
  String runWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Идёт $_temp0, не спеша.';
  }

  @override
  String get runScared => 'Вода! Ойен пугается и разворачивается.';

  @override
  String runTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'стол',
      'wall': 'стену',
      'other': 'стену',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Упёрся в $_temp0. Повернулся, теперь смотрит $_temp1.';
  }

  @override
  String get runEat => 'Ам! Рыбка съедена.';

  @override
  String get runEnterBox => 'Коробка! Ойен залез и сел.';

  @override
  String get runSit => 'Сидит в коробке.';

  @override
  String get runBoxGone => 'Коробка смялась и исчезла.';

  @override
  String get runKnockGlass => 'Стакан полетел вниз. Хорошо, что пластиковый!';

  @override
  String get runKnockVase => 'Ой! Мамина ваза упала и разбилась.';

  @override
  String replayAsleep(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Начало: Ойен спит и смотрит $_temp0.';
  }

  @override
  String replayFinished(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n шага',
      many: '$n шагов',
      few: '$n шага',
      one: '$n шаг',
    );
    return 'В миске. Готово за $_temp0.';
  }

  @override
  String get replayChaseVaseSafe => 'За рыбкой. Ваза пока цела.';

  @override
  String replaySeeFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'сверху',
      'right': 'справа',
      'down': 'снизу',
      'left': 'слева',
      'other': 'справа',
    });
    return 'Солёная рыбка видна прямо $_temp0.';
  }

  @override
  String replayWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Идёт $_temp0.';
  }

  @override
  String replayScared(String water) {
    String _temp0 = intl.Intl.selectLogic(water, {
      'puddle': 'лужа',
      'bucket': 'ведро воды',
      'other': 'вода',
    });
    return 'Впереди $_temp0: испугался, развернулся.';
  }

  @override
  String replayTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'стол',
      'wall': 'стену',
      'other': 'стену',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Упёрся в $_temp0, повернулся и смотрит $_temp1.';
  }

  @override
  String get replayEat => 'Ам! Рыбка съедена.';

  @override
  String get replayEnterBox => 'Залез в коробку, сидит.';

  @override
  String get replaySit => 'Всё ещё сидит в коробке.';

  @override
  String get replayBoxGone => 'Коробка смялась и исчезла.';

  @override
  String get replayKnockGlass => 'Стакан сброшен. Не страшно, пластик.';

  @override
  String get replayKnockVase => 'Мамина ваза сброшена. Вдребезги!';

  @override
  String get replayLoopStart =>
      'Снова как в начале. Ойен ходит по кругу, и ему скучно.';

  @override
  String replayLoopStep(int n) {
    return 'Снова как на шаге $n. Ойен ходит по кругу, и ему скучно.';
  }

  @override
  String replayTooManySteps(int n) {
    return 'Шаг $n, а миски нет. Ойену скучно.';
  }

  @override
  String get closeRules => 'Закрыть правила';

  @override
  String get rulesTitle => 'Правила Ойена';

  @override
  String get rulesIntro =>
      'Каждый шаг проверяется сверху вниз. Что подошло первым, то Ойен и делает.';

  @override
  String get ruleKnockTitle => 'Сбросить вещь рядом';

  @override
  String get ruleKnockBody =>
      'Стакан или ваза на соседнем столе? Ойен столкнёт. Всегда.';

  @override
  String get ruleFishTitle => 'Бежать к ближайшей рыбке';

  @override
  String get ruleFishBody => 'Только те, что видны по прямой. Если поровну:';

  @override
  String get tieAhead => 'прямо';

  @override
  String get tieClockwise => 'по часовой';

  @override
  String get tieCounterClockwise => 'против часовой';

  @override
  String get tieBehind => 'назад';

  @override
  String get tieOrderLabel =>
      'Порядок при равенстве: прямо, по часовой, против часовой, назад.';

  @override
  String get ruleWaterTitle => 'Вода? Назад';

  @override
  String get ruleWaterBody =>
      'Лужа или ведро впереди? Ойен пугается и разворачивается.';

  @override
  String get ruleWallTitle => 'Упёрся в стену или стол';

  @override
  String get ruleWallTurn => 'Ойен поворачивается по часовой';

  @override
  String get ruleWallBody => 'Четверть оборота — и снова в путь.';

  @override
  String get ruleBoxTitle => 'Коробка? Залезть и сидеть';

  @override
  String get ruleBoxBody =>
      'Сидит 2 шага, пока коробка не сомнётся и не исчезнет. Рыбку за коробкой не видно.';

  @override
  String get ruleKnockLocked => 'Вещи на столе';

  @override
  String get ruleFishLocked => 'Рыбка';

  @override
  String get ruleWaterLocked => 'Вода';

  @override
  String get ruleWallLocked => 'Стена';

  @override
  String get ruleBoxLocked => 'Коробка';

  @override
  String ruleLockedTitle(String name) {
    return '$name: ???';
  }

  @override
  String get ruleLockedBody => 'Ещё не изучено. Скоро познакомитесь.';

  @override
  String ruleLabel(int n) {
    return 'Правило $n';
  }

  @override
  String ruleLockedLabel(int n) {
    return 'Правило $n, закрыто, ещё не изучено';
  }

  @override
  String get closeHints => 'Закрыть подсказки';

  @override
  String get hintsTitle => 'Подсказки';

  @override
  String get hintsIntro => 'Не спеши. Может, хватит маленькой подсказки.';

  @override
  String get hintTier1Title => 'Показать первую клетку';

  @override
  String get hintTier2Title => 'Показать предмет';

  @override
  String get hintTier3Title => 'Показать всё решение';

  @override
  String get hintOpened => 'Открыта';

  @override
  String hintTier(int n) {
    return 'Ступень $n';
  }

  @override
  String hintUnlockFirst(int n) {
    return 'Сначала открой ступень $n';
  }

  @override
  String get noItemsHint => 'Здесь предметы не нужны. Просто разбуди Ойена!';

  @override
  String get hintTier1Text =>
      'Видишь светящуюся клетку? Туда нужно что-то поставить.';

  @override
  String get hintPlaceFish =>
      'Положи солёную рыбку на светящуюся клетку. Ойен побежит за ней и съест.';

  @override
  String get hintPlaceWater =>
      'Поставь ведро воды на светящуюся клетку. Ойен испугается и развернётся.';

  @override
  String get hintPlaceBox =>
      'Поставь коробку на светящуюся клетку. Ойен залезет в неё и посидит.';

  @override
  String hintFishCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'солёную рыбку',
      'two': 'две солёные рыбки',
      'three': 'три солёные рыбки',
      'other': 'солёных рыбок: $n',
    });
    return '$_temp0';
  }

  @override
  String hintWaterCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'ведро воды',
      'two': 'два ведра воды',
      'three': 'три ведра воды',
      'other': 'вёдер воды: $n',
    });
    return '$_temp0';
  }

  @override
  String hintBoxCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'коробку',
      'two': 'две коробки',
      'three': 'три коробки',
      'other': 'коробок: $n',
    });
    return '$_temp0';
  }

  @override
  String listPair(String a, String b) {
    return '$a и $b';
  }

  @override
  String listLast(String rest, String last) {
    return '$rest и $last';
  }

  @override
  String hintSolution(String items, int count, String tail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'на светящиеся клетки',
      one: 'на светящуюся клетку',
    );
    return 'Поставь $items $_temp0. $tail';
  }

  @override
  String get hintSolutionVaseSafe => 'Ваза цела, 3 звезды.';

  @override
  String get hintSolutionStars => '3 звезды!';

  @override
  String get tutorial1Title => 'Ойену не прикажешь. Просто разбуди его!';

  @override
  String get tutorial1Body => 'Он сам дойдёт до миски. Тебе остаётся смотреть.';

  @override
  String get tutorial3Title => 'Ойен обожает солёную рыбку!';

  @override
  String get tutorial3Body =>
      'Перетащи рыбку на пол. Если её видно по прямой, он сразу побежит за ней.';

  @override
  String get tutorial6Title => 'Ойен боится воды. Очень.';

  @override
  String get tutorial6Body =>
      'Поставь ведро на пути. Увидит воду — испугается и повернёт назад.';

  @override
  String get tutorialLabel => 'Обучение';

  @override
  String get skipTutorial => 'Пропустить обучение';

  @override
  String get skip => 'Пропустить';

  @override
  String get success => 'Получилось!';

  @override
  String stepsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'шага',
      many: 'шагов',
      few: 'шага',
      one: 'шаг',
    );
    return '$_temp0';
  }

  @override
  String itemsUsedUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'предмета',
      many: 'предметов',
      few: 'предмета',
      one: 'предмет',
    );
    return '$_temp0';
  }

  @override
  String get goalBowl => 'Дошёл до миски';

  @override
  String get goalVase => 'Мамина ваза цела';

  @override
  String get goalItems => 'Меньше всего предметов';

  @override
  String get goalNotYet => 'Пока нет';

  @override
  String get goalGot => 'Есть';

  @override
  String get goalAchieved => 'выполнено';

  @override
  String get restart => 'Заново';

  @override
  String get next => 'Дальше';

  @override
  String get watchReplay => 'Смотреть повтор';

  @override
  String get vaseHeadlineTop => 'Дошёл, конечно...';

  @override
  String get vaseHeadlineBottom => 'а мамина ваза?';

  @override
  String brokenAtStep(int n) {
    return 'Разбита на шаге $n';
  }

  @override
  String get tryAgain => 'Ещё раз';

  @override
  String get nextAnyway => 'Всё равно дальше';

  @override
  String get vaseArtLabel =>
      'За Ойеном разбитая ваза, в дверях появляется недовольная мама';

  @override
  String get loopTitle => 'Ойену надоело ходить по кругу.';

  @override
  String get loopBadge => 'По кругу';

  @override
  String get loopMessage =>
      'Кругами да кругами, а миски нет. Ну и ладно, спать.';

  @override
  String get tooLongTitle => 'Ойен устал ходить.';

  @override
  String tooLongBadge(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Больше $n шагов',
      one: 'Больше $n шага',
    );
    return '$_temp0';
  }

  @override
  String tooLongMessage(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n шагов',
      few: '$n шага',
      one: '$n шаг',
    );
    return '$_temp0, а миски всё нет. Устал. Спать.';
  }

  @override
  String failedKicker(int id) {
    return 'Уровень $id · Неудача';
  }

  @override
  String get replay => 'Повтор';

  @override
  String get arrangeAgain => 'Переставить';

  @override
  String get replayStart => 'Начало';

  @override
  String get replayPlay => 'Автовоспроизведение';

  @override
  String get backToResult => 'Назад к результату';

  @override
  String get recording => 'Запись';

  @override
  String replayStepCaption(int n, String text) {
    return 'Шаг $n. $text';
  }

  @override
  String get timeline => 'Время';

  @override
  String oyenLabel(String pose, String dir) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'стоит',
      'walk': 'идёт',
      'sleep': 'спит',
      'shock': 'испугался',
      'box': 'сидит в коробке',
      'knock': 'сбрасывает вещь',
      'eat': 'ест',
      'happy': 'доволен',
      'other': 'стоит',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'вверх',
      'right': 'вправо',
      'down': 'вниз',
      'left': 'влево',
      'other': 'вправо',
    });
    return 'Ойен $_temp0, смотрит $_temp1';
  }

  @override
  String get costumeNone => 'Без костюма';

  @override
  String get costumePeci => 'Пеци';

  @override
  String get costumeSarung => 'Саронг';

  @override
  String get costumeKoki => 'Колпак';

  @override
  String get costumeKacamata => 'Очки';

  @override
  String get costumeWearingTag => 'Надето';

  @override
  String get costumeWearingStatus => 'надето';

  @override
  String get costumeOwnedTag => 'Твоё';

  @override
  String get costumeOwnedStatus => 'твоё';

  @override
  String get costumeActionWearing => 'Сейчас надето';

  @override
  String get costumeActionWear => 'Надеть';

  @override
  String costumeActionBuy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Купить · $n монеты',
      many: 'Купить · $n монет',
      few: 'Купить · $n монеты',
      one: 'Купить · $n монета',
    );
    return '$_temp0';
  }

  @override
  String get closeCoins => 'Закрыть монеты';

  @override
  String get coinsTitle => 'Монеты';

  @override
  String get coinsIntro =>
      'Монеты нужны для подсказок и костюмов Ойена. Забирай бонус каждый день или смотри рекламу.';

  @override
  String get dailyBonus => 'Ежедневный бонус';

  @override
  String get dailyBonusReady => 'Раз в день';

  @override
  String get dailyBonusTaken => 'Сегодня уже получено';

  @override
  String claimCoins(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Забрать $n монеты',
      many: 'Забрать $n монет',
      few: 'Забрать $n монеты',
      one: 'Забрать $n монету',
    );
    return '$_temp0';
  }

  @override
  String get claimTomorrow => 'Завтра ещё';

  @override
  String adsLeftToday(int n) {
    return 'Сегодня осталось: $n';
  }

  @override
  String get adsUsedUp => 'На сегодня всё';

  @override
  String adRewardButton(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n монеты',
      many: '+$n монет',
      few: '+$n монеты',
      one: '+$n монета',
    );
    return '$_temp0';
  }

  @override
  String get adsTomorrow => 'Завтра ещё';

  @override
  String get coinChipAdd => 'добавить монеты';

  @override
  String get coinChipBonus => 'ежедневный бонус готов';

  @override
  String get soundSection => 'Звук';

  @override
  String get music => 'Музыка';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Язык телефона';

  @override
  String get tutorialsSection => 'Обучение';

  @override
  String get replayTutorials => 'Показать обучение снова';

  @override
  String get replayTutorialsInfo =>
      'Обучение на уровнях 1, 3 и 6 появится снова, когда ты их откроешь.';

  @override
  String get tutorialsBack => 'Готово! Обучение вернулось.';

  @override
  String get progressSection => 'Прогресс';

  @override
  String get resetProgress => 'Сбросить прогресс';

  @override
  String get resetProgressInfo =>
      'Удалить звёзды, монеты, костюмы, подсказки и обучение и начать с уровня 1.';

  @override
  String get resetConfirmTitle => 'Удалить весь прогресс?';

  @override
  String get resetConfirmBody =>
      'Звёзды, монеты, костюмы, подсказки и обучение будут удалены. Отменить нельзя. Сегодняшний бонус и реклама останутся использованными.';

  @override
  String get resetConfirm => 'Удалить';

  @override
  String get closeReset => 'Закрыть сброс';

  @override
  String get resetDone => 'Прогресс удалён. Начнём сначала!';

  @override
  String get privacySection => 'Конфиденциальность';

  @override
  String get privacyInfo =>
      'Прогресс хранится на твоём телефоне. Реклама — от Google AdMob.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get adConsent => 'Согласие на рекламу';

  @override
  String get privacyLinkFailed => 'Браузер не открылся. Попробуй позже, ладно?';

  @override
  String get about => 'Об игре';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get fontCredits => 'Шрифты: Fredoka и Nunito (SIL Open Font License).';

  @override
  String get soundCredits =>
      'Звуки: Kenney и OpenGameArt (CC0). Музыку написали специально для Ginger Logic.';

  @override
  String get licenses => 'Лицензии';
}
