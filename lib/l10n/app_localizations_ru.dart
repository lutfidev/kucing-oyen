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
  String get settings => 'Настройки';

  @override
  String get tagline => 'Ойен не слушается. Думать тебе.';

  @override
  String get splashTagline => 'Играем!';

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
  String get closeCoins => 'Закрыть монеты';

  @override
  String get coinsTitle => 'Монеты';

  @override
  String get coinsIntro =>
      'Монеты нужны для подсказок и вещей в комнату Ойена. Забирай бонус каждый день или смотри рекламу.';

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
      'Удалить звёзды, монеты, вещи в комнате, подсказки и обучение и начать с уровня 1.';

  @override
  String get resetConfirmTitle => 'Удалить весь прогресс?';

  @override
  String get resetConfirmBody =>
      'Звёзды, монеты, вещи в комнате, подсказки и обучение будут удалены. Отменить нельзя. Сегодняшний бонус и реклама останутся использованными.';

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

  @override
  String get roomItemTikus => 'Игрушечная мышка';

  @override
  String get roomItemTikusDesc =>
      'Никуда не убегает, но за ней всё равно охотятся.';

  @override
  String get roomItemAkuarium => 'Аквариум';

  @override
  String get roomItemAkuariumDesc =>
      'Развлечение на весь день. Рыбки слегка нервничают.';

  @override
  String get roomItemRumah => 'Домик для кота';

  @override
  String get roomItemRumahDesc => 'Свой дом есть, а спит всё равно в коробке.';

  @override
  String get roomItemKasur => 'Матрасик-подушка';

  @override
  String get roomItemKasurDesc =>
      'Мягкий. Используется 60% времени, остальное — коробка.';

  @override
  String get roomItemCatnip => 'Горшок с котовником';

  @override
  String get roomItemCatnipDesc => 'Один вдох — и сразу танцы.';

  @override
  String get roomItemJam => 'Часы-кот';

  @override
  String get roomItemJamDesc => 'Хвост качается каждую секунду. Гипноз.';

  @override
  String get roomItemKardus => 'Уютная коробка';

  @override
  String get roomItemKardusDesc => 'Выбирают коробку, а не то, что в ней было.';

  @override
  String get roomItemBola => 'Клубок пряжи';

  @override
  String get roomItemBolaDesc => 'Запутается за 3 секунды. Это фича.';

  @override
  String get roomItemKarpet => 'Круглый коврик';

  @override
  String get roomItemKarpetDesc => 'Официальное место для валяния.';

  @override
  String get roomItemTiang => 'Когтеточка';

  @override
  String get roomItemTiangDesc => 'Чтобы мамин диван выжил. Надеемся.';

  @override
  String get roomItemLukisan => 'Картина с рыбой';

  @override
  String get roomItemLukisanDesc => 'Искусство, от которого хочется есть.';

  @override
  String get roomItemRak => 'Полка на стене';

  @override
  String get roomItemRakDesc => 'VIP-место, чтобы следить за всеми.';

  @override
  String get roomItemPancingan => 'Удочка с перьями';

  @override
  String get roomItemPancinganDesc =>
      'За перышком бежит, достоинство остаётся позади.';

  @override
  String get roomItemLampuBulan => 'Лампа-луна';

  @override
  String get roomItemLampuBulanDesc => 'Личная луна — ночи ждать не надо.';

  @override
  String get roomItemBantalIkan => 'Подушка-рыба';

  @override
  String get roomItemBantalIkanDesc => 'Мягкая, и рыбой пахнет только на вид.';

  @override
  String get roomItemMonstera => 'Монстера';

  @override
  String get roomItemMonsteraDesc =>
      'Листья в дырках. Ойен не виноват. На этот раз.';

  @override
  String get roomItemTerowongan => 'Кошачий туннель';

  @override
  String get roomItemTerowonganDesc => 'Заходит кот — выходит со стилем.';

  @override
  String get roomItemHammock => 'Гамак на окно';

  @override
  String get roomItemHammockDesc =>
      'Сон с покачиванием. Проснулся — уже вечер.';

  @override
  String get roomItemSofaMini => 'Мини-диван';

  @override
  String get roomItemSofaMiniDesc =>
      'Свой диван — мамин в безопасности. Якобы.';

  @override
  String get roomItemJendelaBurung => 'Окно с птицами';

  @override
  String get roomItemJendelaBurungDesc =>
      'Кошачье ТВ 24 часа: птицы без рекламы.';

  @override
  String get roomItemMangkuk => 'Миска с едой';

  @override
  String get kittyOyen => 'Ойен';

  @override
  String get kittyOyenDesc => 'Рыжий кот, которого ты будишь на каждом уровне.';

  @override
  String get kittySalju => 'Снежок';

  @override
  String get kittySaljuDesc => 'Белоснежный. Пока не найдёт коробку.';

  @override
  String get kittyTelon => 'Тришка';

  @override
  String get kittyTelonDesc => 'Три цвета, три настроения в минуту.';

  @override
  String get kittyArang => 'Уголёк';

  @override
  String get kittyArangDesc =>
      'Чёрный как уголь, глаза жёлтые. Мастер прятаться в тенях.';

  @override
  String get kittyMendung => 'Тучка';

  @override
  String get kittyMendungDesc => 'Выглядит грустным, а просто хочет спать.';

  @override
  String get kittyKopiSusu => 'Латте';

  @override
  String get kittyKopiSusuDesc => 'Сладкий, но горчит, если разбудить.';

  @override
  String get kittyMochi => 'Моти';

  @override
  String get kittyMochiDesc =>
      'Спокойный, мягкий, морда как после игры в грязи.';

  @override
  String get kittyBos => 'Босс';

  @override
  String get kittyBosDesc => 'Всегда в костюме. Совещания в каждый приём пищи.';

  @override
  String get kittyKembang => 'Цветик';

  @override
  String get kittyKembangDesc => 'Окрас абстрактный, поведение тоже.';

  @override
  String get accessoryPita => 'Лента';

  @override
  String get accessoryPitaDesc => 'Просто, мило, надевается легко.';

  @override
  String get accessoryJepitBunga => 'Заколка-цветок';

  @override
  String get accessoryJepitBungaDesc => 'Цветёт всегда, поливать не нужно.';

  @override
  String get accessoryBandana => 'Бандана';

  @override
  String get accessoryBandanaDesc => 'Ковбойский стиль, спальный район.';

  @override
  String get accessoryDasiKupu => 'Галстук-бабочка';

  @override
  String get accessoryDasiKupuDesc => 'Готов к торжеству, приглашения нет.';

  @override
  String get accessoryKalung => 'Ошейник с бубенчиком';

  @override
  String get accessoryKalungDesc => 'Звяк-звяк. Попался на каждой краже рыбы.';

  @override
  String get accessorySyal => 'Вязаный шарф';

  @override
  String get accessorySyalDesc => 'Тёплый. Связан воображаемой бабушкой.';

  @override
  String get accessoryBeanie => 'Шапка-бини';

  @override
  String get accessoryBeanieDesc => 'Тепло. Хотя на улице жара.';

  @override
  String get accessoryTopiKoki => 'Колпак шефа';

  @override
  String get accessoryTopiKokiDesc => 'Готовить? Нет. Пробовать? Всегда.';

  @override
  String get accessoryBaret => 'Берет';

  @override
  String get accessoryBaretDesc =>
      'Внезапно художник. Шедевр — порванная подушка.';

  @override
  String get accessoryKacamata => 'Круглые очки';

  @override
  String get accessoryKacamataDesc => 'Вид умный. Вазу всё равно уронит.';

  @override
  String get accessoryHeadphone => 'Наушники';

  @override
  String get accessoryHeadphoneDesc =>
      'Слушает лоу-фай, делает вид, что занят.';

  @override
  String get accessoryTandukRusa => 'Рога оленя';

  @override
  String get accessoryTandukRusaDesc =>
      'Олень ненастоящий. Мяукает по-прежнему.';

  @override
  String get accessoryTopiPesta => 'Праздничный колпак';

  @override
  String get accessoryTopiPestaDesc =>
      'Если ты кот, каждый день — день рождения.';

  @override
  String get accessoryTopiPenyihir => 'Шляпа волшебника';

  @override
  String get accessoryTopiPenyihirDesc => 'Умеет доставать рыбу. Говорят.';

  @override
  String get accessoryMahkota => 'Венок из цветов';

  @override
  String get accessoryMahkotaDesc => 'Королева комнаты. Цветы не есть.';

  @override
  String get accessoryMahkotaRaja => 'Королевская корона';

  @override
  String get accessoryMahkotaRajaDesc =>
      'Король комнаты. Налоги платят поглаживаниями.';

  @override
  String get snackIkanAsin => 'Солёная рыба';

  @override
  String get snackIkanAsinDesc => 'Солёная, вкусная, запах слышен соседям.';

  @override
  String get snackSusu => 'Молоко';

  @override
  String get snackSusuDesc => 'Маленькое блюдце. Усы становятся белыми.';

  @override
  String get snackTuna => 'Тунец в банке';

  @override
  String get snackTunaDesc => 'Звук банки собирает всех кошек.';

  @override
  String get snackBiskuit => 'Кошачье печенье';

  @override
  String get snackBiskuitDesc => 'Хрустит и дешёвое. Сытости мало.';

  @override
  String get snackPuding => 'Рыбный пудинг';

  @override
  String get snackPudingDesc => 'Шикарно. Очень сытно и очень радостно.';

  @override
  String get rarityCommon => 'Обычный';

  @override
  String get rarityRare => 'Редкий';

  @override
  String get raritySpecial => 'Особый';

  @override
  String get shop => 'Магазин';

  @override
  String get shopTabItems => 'Вещи';

  @override
  String get shopTabKitties => 'Коты';

  @override
  String get shopTabAccessories => 'Аксессуары';

  @override
  String get shopTabSnacks => 'Еда';

  @override
  String get shopKittyIntro =>
      'Все коты живут в комнате Ойена. Ойен согласен. Вроде бы.';

  @override
  String get shopSnackIntro =>
      'Лакомства идут в запас. Угощай из карточки кота в комнате.';

  @override
  String get shopOwnedTag => 'Твоё';

  @override
  String get shopLivesHere => 'Живёт в комнате';

  @override
  String get shopNotEnoughTag => 'Мало монет';

  @override
  String shopShortBy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Не хватает $n монеты',
      many: 'Не хватает $n монет',
      few: 'Не хватает $n монет',
      one: 'Не хватает $n монеты',
    );
    return '$_temp0';
  }

  @override
  String shopAdopt(int n) {
    return 'Взять · $n';
  }

  @override
  String shopBuyShort(int n) {
    return 'Купить · $n';
  }

  @override
  String shopStock(int n) {
    return 'Запас: $n';
  }

  @override
  String get shopTryOn => 'Примерить на:';

  @override
  String shopPreviewOf(String name) {
    return 'Примерка · $name';
  }

  @override
  String get shopWearFree => 'Надеть · Бесплатно';

  @override
  String get shopRemoveFree => 'Снять · Бесплатно';

  @override
  String get shopPlayFirst => 'Сначала головоломка — монеты придут.';

  @override
  String shopWornBy(String name) {
    return 'Носит $name';
  }

  @override
  String get shopFlashNice => 'Красота!';

  @override
  String get shopFlashRemoved => 'Снято, бесплатно';

  @override
  String shopFlashSpent(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '-$n монеты',
      many: '-$n монет',
      few: '-$n монеты',
      one: '-$n монета',
    );
    return '$_temp0';
  }

  @override
  String shopPreviewPickLabel(String name) {
    return 'Примерить аксессуар на $name';
  }

  @override
  String shopCardBuyLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return '$name, $_temp0';
  }

  @override
  String shopCardShortLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return '$name, $_temp0, не хватает монет';
  }

  @override
  String shopCardOwnedLabel(String name) {
    return '$name, уже твоё';
  }

  @override
  String shopCardLivesLabel(String name) {
    return '$name, уже живёт в комнате';
  }

  @override
  String shopSnackBuyLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монету',
    );
    return 'Купить $name за $_temp0';
  }

  @override
  String shopSnackShortLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монету',
    );
    return 'Купить $name за $_temp0, не хватает монет';
  }

  @override
  String buySheetLabel(String name) {
    return 'Купить $name';
  }

  @override
  String get buySuccessOverline => 'Готово!';

  @override
  String buySuccessItem(String name) {
    return '$name теперь твой!';
  }

  @override
  String get buySuccessItemBody =>
      'Уже стоит в комнате. Переставить можно в режиме «Украшать».';

  @override
  String buySuccessKitty(String name) {
    return '$name переехал в комнату!';
  }

  @override
  String get buySuccessKittyBody =>
      'Поздоровайся в комнате. Сначала сделает вид, что ему всё равно.';

  @override
  String buySuccessAccessory(String name) {
    return '$name теперь твой навсегда!';
  }

  @override
  String buySuccessAccessoryBody(String name) {
    return 'Надень на $name сейчас или переставь другому коту когда захочешь.';
  }

  @override
  String get buyAccessoryInfo =>
      'Покупаешь раз — остаётся навсегда. Надевать и снимать бесплатно, на любого кота.';

  @override
  String buyPay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return 'Купить · $_temp0';
  }

  @override
  String get buyLater => 'Потом';

  @override
  String get buyAgain => 'Купить ещё';

  @override
  String get buySeeRoom => 'Посмотреть в комнате';

  @override
  String buyWearOn(String name) {
    return 'Надеть на $name';
  }

  @override
  String get buyNotEnoughHelp =>
      'Пройди головоломку или посмотри рекламу за награду, чтобы получить монеты.';

  @override
  String kittyPose(String pose) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'сидит спокойно',
      'lick': 'облизывает лапку',
      'walk1': 'идёт',
      'walk2': 'идёт',
      'sleep': 'спит свернувшись',
      'eat': 'ест из миски',
      'play': 'играет с игрушкой',
      'scratch': 'точит когти о когтеточку',
      'happy': 'радуется',
      'lesu': 'вялый',
      'rebah': 'лежит и отдыхает',
      'petted': 'мурчит от поглаживаний',
      'other': 'сидит спокойно',
    });
    return '$_temp0';
  }

  @override
  String kittyLabel(String name, String pose) {
    return '$name $pose';
  }

  @override
  String kittyLabelAccessory(String name, String pose, String accessory) {
    return '$name $pose, в $accessory';
  }

  @override
  String shopSnackFullLabel(String name) {
    return 'Купить $name, запас полон';
  }

  @override
  String get shopStockFull => 'Запас полон';

  @override
  String shopAccessoryBuyLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return 'Посмотреть $name, $_temp0';
  }

  @override
  String shopAccessoryShortLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n монеты',
      many: '$n монет',
      few: '$n монеты',
      one: '$n монета',
    );
    return 'Посмотреть $name, $_temp0, не хватает монет';
  }

  @override
  String shopAccessoryOwnedLabel(String name) {
    return 'Посмотреть $name, твоё';
  }

  @override
  String shopAccessoryWornLabel(String name, String who) {
    return 'Посмотреть $name, твоё, носит $who';
  }

  @override
  String get sadMarkHungry => 'Скис: голодный';

  @override
  String get sadMarkSad => 'Скис: мало внимания';

  @override
  String get roomEmptyBubble => 'Пустовато тут. Айда в магазин!';

  @override
  String get roomEmptyWall => 'Что-то на стену?';

  @override
  String get roomEmptyWallHint => 'Пусто. Найди украшение для стены в магазине';

  @override
  String get roomEmptyFloor => 'Может, лежанку?';

  @override
  String get roomEmptyFloorHint =>
      'Пусто. Найди лежанку или игрушку в магазине';

  @override
  String get accessories => 'Аксессуары';

  @override
  String get shopHasNew => 'есть что-то новое по карману';

  @override
  String menuButtonNew(String label, String note) {
    return '$label, $note';
  }

  @override
  String kittyTapHint(String name) {
    return '$name. Нажми, чтобы открыть карточку';
  }

  @override
  String kittyTapHintHungry(String name) {
    return '$name хочет есть. Нажми, чтобы открыть карточку';
  }

  @override
  String get needHunger => 'Сытость';

  @override
  String get needJoy => 'Радость';

  @override
  String needValueLabel(String label, int value) {
    return '$label: $value из 100';
  }

  @override
  String needValueLow(String label, int value) {
    return '$label: $value из 100, почти на нуле';
  }

  @override
  String get needLowHunger => 'Почти на нуле! Живот уже урчит.';

  @override
  String get needLowJoy => 'Почти на нуле! Погладь уже.';

  @override
  String kittyCardLabel(String name) {
    return 'Карточка: $name';
  }

  @override
  String get kittyCardClose => 'Закрыть карточку';

  @override
  String get petAction => 'Погладить';

  @override
  String get snackPanel => 'Вкусняшки';

  @override
  String get snackPick => 'Выбери из запасов';

  @override
  String snackGive(String name, int count) {
    return 'Дать: $name, в запасе $count';
  }

  @override
  String snackGiveEmpty(String name, int count) {
    return 'Дать: $name, в запасе $count, закончилось';
  }

  @override
  String get accessoryPanelTitle => 'Твои · меняй бесплатно';

  @override
  String get accessoryShopLink => 'Магазин аксессуаров';

  @override
  String get accessoryRemove => 'Снять';

  @override
  String get accessoryWornTag => 'Надето';

  @override
  String accessoryWearLabel(String accessory, String name) {
    return 'Надеть $accessory: $name';
  }

  @override
  String accessoryWornLabel(String accessory, String name) {
    return 'Надеть $accessory: $name, уже надето';
  }

  @override
  String accessoryRemoveLabel(String name) {
    return 'Снять аксессуар: $name';
  }

  @override
  String reactionFed(int hunger) {
    return '+$hunger сытости';
  }

  @override
  String reactionFedJoy(int hunger, int joy) {
    return '+$hunger сытости, +$joy радости';
  }

  @override
  String reactionJoy(int joy) {
    return '+$joy радости';
  }

  @override
  String get reactionNice => 'Красота!';

  @override
  String get reactionRelieved => 'Свобода!';

  @override
  String get decorate => 'Обустроить';

  @override
  String get decorateDone => 'Готово';

  @override
  String get decorateHint => 'Перетащи вещи на новое место';

  @override
  String get zoneWall => 'Стена';

  @override
  String get zoneFloor => 'Пол';

  @override
  String get storage => 'Кладовка';

  @override
  String storageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вещи',
      many: '$count вещей',
      few: '$count вещи',
      one: '$count вещь',
    );
    return '$_temp0';
  }

  @override
  String get storageTapHint => 'Нажми, чтобы поставить';

  @override
  String get storageEmpty => 'Кладовка пуста. Всё расставлено, Ойен гордится.';

  @override
  String storagePlaceLabel(String item) {
    return 'Поставить в комнату: $item';
  }

  @override
  String get storageLabel => 'Кладовка с вещами';

  @override
  String get storeItemAction => 'Убрать в кладовку';

  @override
  String get decoratePraise => 'Комната всё краше!';

  @override
  String decoratePraiseJoy(int joy) {
    return '+$joy радости всем котикам';
  }

  @override
  String bowlRefill(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Наполнится через $hours часа',
      many: 'Наполнится через $hours часов',
      few: 'Наполнится через $hours часа',
      one: 'Наполнится через $hours час',
    );
    return '$_temp0';
  }

  @override
  String kittyRewardLabel(int coins, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$name: забрать $coins монеты',
      many: '$name: забрать $coins монет',
      few: '$name: забрать $coins монеты',
      one: '$name: забрать $coins монету',
    );
    return '$_temp0';
  }

  @override
  String reactionCoins(int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '+$coins монеты',
      many: '+$coins монет',
      few: '+$coins монеты',
      one: '+$coins монета',
    );
    return '$_temp0';
  }
}
