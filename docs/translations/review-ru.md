# Ginger Logic: Russian review

Ginger Logic is a casual puzzle game for phones: the player places fish, water buckets, and boxes on a 7x9 board, then Oyen the orange cat wakes up and walks on its own, following fixed rules. The game text was written in Indonesian first.

**How to review.** Read each line the way a player would see it in the game.
Write a better version in the *Feedback* column only where the text sounds
wrong, stiff, or unnatural; leave it empty when it is fine. The same goes
for the store listing at the end.

- **Tone:** casual, warm, and a little funny, like a friend telling the
  story of a stubborn cat. Short is better: most lines sit on small buttons
  and chips on a phone.
- **Rules of the game** say the cat *turns clockwise* at a wall or table
  (pt: "sentido horário", ru: "по часовой"), never "turns right".
- **Captions** (what the cat is doing step by step) use screen directions:
  up, down, left, right.
- **Do not translate:** the game name "Ginger Logic", the cat's name
  "Oyen", and the drawn words "PRANG!" and "Zzz".
- **Placeholders** in braces (`{n}`, `{dir}`, ...) stay as they are. Lines
  with `plural` or `select` are ICU messages: change only the words inside
  the inner braces, e.g. `{n, plural, one{{n} step} other{{n} steps}}`.
  Russian plurals have `one`, `few`, and `many` forms.

278 lines. Generated from `lib/l10n/` by `tool/translations/make_review.py`; do not edit by hand.

| Key | English | Russian | Notes | Feedback |
| --- | --- | --- | --- | --- |
| `backToHome` | Back to home | На главную | Back button to the home screen (screen reader). | |
| `backToMap` | Back to map | Назад к карте | Back button to the chapter map. | |
| `close` | Close | Закрыть | Close button of a sheet (screen reader). | |
| `cancel` | Cancel | Отмена | Cancel button. | |
| `starsOf` | {stars} of {total} stars | {stars} из {total, plural, one{{total} звезды} other{{total} звёзд}} | Screen reader: earned stars out of a total. Placeholders: `{stars}`, `{total}`. | |
| `coinsAmount` | {n, plural, one{{n} coin} other{{n} coins}} | {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}} | An amount of coins ("120 coins"). Placeholders: `{n}`. | |
| `coinsUnit` | {n, plural, one{coin} other{coins}} | {n, plural, one{монета} few{монеты} many{монет} other{монеты}} | Word after a big coin number on the result screen ("+30 coins"). Placeholders: `{n}`. | |
| `notEnoughCoins` | Not enough · {n} | Мало монет · {n} | Disabled pay button: not enough coins for the price. Placeholders: `{n}`. | |
| `watchAd` | Watch an ad | Смотреть рекламу | Button: watch a rewarded ad. | |
| `adFailed` | The ad couldn't play. Try again later, okay? | Реклама не загрузилась. Попробуй позже, ладно? | The rewarded ad failed to load or was closed early. | |
| `boardLabel` | Game board, 7 by 9 tiles | Игровое поле 7 на 9 клеток | Screen reader label of the 7×9 game board. | |
| `play` | Play | Играть | Big Play button on the home screen and the map node label. | |
| `closet` | Wardrobe | Гардероб | Costume closet button and screen title. | |
| `settings` | Settings | Настройки | Settings button and screen title. | |
| `tagline` | Oyen won't listen. You do the thinking. | Ойен не слушается. Думать тебе. | Tagline under the logo on the home screen. | |
| `splashTagline` | Let's play! | Играем! | Short line under the logo on the Android splash screen (rendered into an image, keep it very short). | |
| `starTotalUnit` | stars | звёзд | Word after the star total on the home screen ("31/60 stars"). | |
| `chapterNumber` | Chapter {n} | Глава {n} | Chapter number above the chapter name (shown in capitals). Placeholders: `{n}`. | |
| `chapter1Name` | Kitchen | Кухня | Name of chapter 1 (setting: kitchen). | |
| `chapter2Name` | Living Room | Гостиная | Name of chapter 2 (setting: living room). | |
| `chapterTitle` | Chapter {n} – {name} | Глава {n} – {name} | Chapter title on chapter cards. Placeholders: `{n}`, `{name}`. | |
| `chapterDone` | Done | Пройдено | Badge on a finished chapter card. | |
| `chapterLocked` | Locked | Закрыто | Badge on a locked chapter card. | |
| `statusDone` | done | пройдено | Screen reader status of a finished chapter (lowercase). | |
| `statusLocked` | locked | закрыто | Screen reader status of a locked level or chapter (lowercase). | |
| `statusPlayNow` | play now | играть сейчас | Screen reader status of the level to play now. | |
| `nodeStars` | {n, plural, one{{n} star} other{{n} stars}} | {n, plural, one{{n} звезда} few{{n} звезды} many{{n} звёзд} other{{n} звезды}} | Screen reader: stars earned on a level node. Placeholders: `{n}`. | |
| `levelNodeLabel` | Level {id}, {status} | Уровень {id}, {status} | Screen reader label of a level node on the map. Placeholders: `{id}`, `{status}`. | |
| `bossNodeLabel` | Level {id}, boss {name}, {status} | Уровень {id}, босс «{name}», {status} | Screen reader label of the boss level node. Placeholders: `{id}`, `{name}`, `{status}`. | |
| `bossTag` | Boss · {name} | Босс · {name} | Tag above the boss level on the map. Placeholders: `{name}`. | |
| `chapterMissing` | This chapter doesn't exist. | Такой главы нет. | Shown when the chapter in the link does not exist. | |
| `level1Name` | Wake Up Oyen | Разбуди Ойена | Name of level 1. | |
| `level2Name` | Round the Corner | За угол | Name of level 2. | |
| `level3Name` | First Fish | Первая рыбка | Name of level 3. | |
| `level4Name` | Nearest Fish | Ближайшая рыбка | Name of level 4. | |
| `level5Name` | Two Fish | Две рыбки | Name of level 5. | |
| `level6Name` | First Bucket | Первое ведро | Name of level 6. | |
| `level7Name` | Puddle | Лужа | Name of level 7. | |
| `level8Name` | Fish and Bucket | Рыбка и ведро | Name of level 8. | |
| `level9Name` | Tempting Fish | Рыбка-искушение | Name of level 9. | |
| `level10Name` | Salted Fish Feast | Пир солёной рыбки | Name of level 10. This is the boss level; the name is shown after the boss prefix. | |
| `level11Name` | Coffee Table | Журнальный столик | Name of level 11. | |
| `level12Name` | Falling Glass | Падающий стакан | Name of level 12. | |
| `level13Name` | Mom's Vase | Мамина ваза | Name of level 13. | |
| `level14Name` | Box in the Way | Коробка на пути | Name of level 14. | |
| `level15Name` | Squashed Box | Мятая коробка | Name of level 15. | |
| `level16Name` | The Long Way Round | Обходной путь | Name of level 16. | |
| `level17Name` | Two Vases | Две вазы | Name of level 17. | |
| `level18Name` | Tight Squeeze | Тесная комната | Name of level 18. | |
| `level19Name` | All Together | Всё вместе | Name of level 19. | |
| `level20Name` | Eid Day | Ураза-байрам | Name of level 20. This is the boss level; the name is shown after the boss prefix. | |
| `bossLevelName` | BOSS: {name} | БОСС: {name} | Full name of a boss level ("BOSS: Eid Day"). Placeholders: `{name}`. | |
| `levelTitle` | Level {id} · {name} | Уровень {id} · {name} | Level number and name in the top bar and result screens. Placeholders: `{id}`, `{name}`. | |
| `rules` | Rules | Правила | Rules button in the top bar. | |
| `hint` | Hint | Подсказка | Hint button (screen reader). | |
| `targetItems` | {n, plural, one{use {n} item} other{use {n} items}} | {n, plural, one{до {n} предмета} other{до {n} предметов}} | Three-star goal chip: the most items allowed. Placeholders: `{n}`. | |
| `targetLabel` | 3-star goal: {text} | Цель на 3 звезды: {text} | Screen reader label of the three-star goal chip. Placeholders: `{text}`. | |
| `levelMissing` | This level doesn't exist. | Такого уровня нет. | Shown when the level in the link does not exist. | |
| `backToArrange` | Back to setup | Назад к расстановке | Back button while Oyen walks: return to placing items. | |
| `wakeOyen` | Wake Oyen | Разбудить Ойена | Main button: start the run. | |
| `trayEmpty` | No items needed here yet. | Здесь пока не нужны предметы. | Tray text on levels without items. | |
| `trayLabel` | Items | Вещи | Vertical label of the item tray (shown in capitals). | |
| `clearBoard` | Clear the board | Очистить поле | Button: return all placed items to the tray. | |
| `trayHintTop` | Drop on a | Ставь на | Tray hint, first line: "Place on a / glowing tile". | |
| `trayHintBottom` | glowing tile | светлую клетку | Tray hint, second line. | |
| `itemFish` | Salted fish | Солёная рыбка | Item name: salted fish. | |
| `itemWater` | Water bucket | Ведро воды | Item name: water bucket. | |
| `itemBox` | Box | Коробка | Item name: cardboard box. | |
| `traySlotLabel` | {name}, {n} left | {name}, осталось: {n} | Screen reader label of a tray slot. Placeholders: `{name}`, `{n}`. | |
| `traySlotDragging` | {name}, dragging, {n} left | {name}, перетаскивается, осталось: {n} | Screen reader label of a tray slot while dragging. Placeholders: `{name}`, `{n}`. | |
| `traySlotSelectHint` | pick it up | взять эту вещь | Screen reader hint for a tray slot: what a double tap does ("Double tap to ..."). | |
| `traySlotUnselectHint` | cancel | отменить | Screen reader hint for a picked-up tray slot or board item: double tap cancels the pick (the item stays where it is). | |
| `tileLabel` | Row {row}, column {col}: {content} | Ряд {row}, столбец {col}: {content} | Screen reader label of one board tile: row and column (from 1, top left) and what is on it. Placeholders: `{row}`, `{col}`, `{content}`. | |
| `cellWall` | wall | стена | Board tile content for screen readers: wall. | |
| `cellFloor` | floor | пол | Board tile content for screen readers: empty floor. | |
| `cellBowl` | Oyen's bowl | миска Ойена | Board tile content for screen readers: Oyen's food bowl (the goal). | |
| `cellTable` | table | стол | Board tile content for screen readers: table. | |
| `cellTableGlass` | table with a glass | стол со стаканом | Board tile content for screen readers: table with a glass Oyen can knock off. | |
| `cellTableVase` | table with a vase | стол с вазой | Board tile content for screen readers: table with Mom's vase. | |
| `cellFish` | salted fish | солёная рыбка | Board tile content for screen readers: salted fish that is part of the level. | |
| `cellWater` | puddle | лужа | Board tile content for screen readers: water puddle that is part of the level. | |
| `cellBox` | box | коробка | Board tile content for screen readers: box that is part of the level. | |
| `tileOyen` | Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Ойен спит, смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}} | Board tile content for screen readers: sleeping Oyen and the screen direction he faces. Placeholders: `{dir}`. | |
| `tilePlayerItem` | {item}, placed by you | {item}, твоя вещь | Board tile content for screen readers: an item the player put there (item name first). Placeholders: `{item}`. | |
| `tileHintSpot` | {content}. Hint: something has to go here. | {content}. Подсказка: сюда что-то нужно поставить. | Board tile label suffix for screen readers: a tier 1 hint marks this tile (something must go here, type not revealed). Placeholders: `{content}`. | |
| `tileHintItem` | {content}. Hint: {item} goes here. | {content}. Подсказка: сюда — {item}. | Board tile label suffix for screen readers: a tier 2-3 hint shows which item goes on this tile. Placeholders: `{content}`, `{item}`. | |
| `tilePlaceHint` | put it here | поставить сюда | Screen reader hint for an empty tile while an item is picked up ("Double tap to ..."). | |
| `tilePickHint` | pick it up to move it | взять и переставить | Screen reader hint for a board item the player placed ("Double tap to ..."). | |
| `tileReturn` | Back to the tray | Вернуть к вещам | Screen reader custom action on a placed item: put it back in the tray. | |
| `itemPickedAnnounce` | {item} picked up. Choose an empty floor tile to put it on. | {item} в руке. Выбери пустую клетку пола. | Screen reader announcement after picking up an item without dragging. Placeholders: `{item}`. | |
| `itemPlacedAnnounce` | {item} placed at row {row}, column {col}. | Готово: {item} — ряд {row}, столбец {col}. | Screen reader announcement after an item is put on the board without dragging. Placeholders: `{item}`, `{row}`, `{col}`. | |
| `itemReturnedAnnounce` | {item} is back in the tray. | {item} снова среди вещей. | Screen reader announcement after a placed item goes back to the tray. Placeholders: `{item}`. | |
| `step` | Step | Шаг | Step counter label (also above the number chip). | |
| `stepNumber` | Step {n} | Шаг {n} | Step number ("Step 4"). Placeholders: `{n}`. | |
| `vaseBroken` | Vase broken | Ваза разбита | Status chip: the vase broke. | |
| `vaseSafe` | Vase safe | Ваза цела | Status chip: the vase is fine. | |
| `itemsUsed` | {n, plural, one{{n} item used} other{{n} items used}} | Предметов: {n} | Status chip: number of items used. Placeholders: `{n}`. | |
| `pause` | Pause | Пауза | Play/pause button while running. | |
| `resume` | Resume | Дальше | Play/pause button while paused. | |
| `stepForward` | One step forward | Шаг вперёд | Button: one step forward. | |
| `stepBack` | One step back | Шаг назад | Button: one step back (replay). | |
| `doubleSpeed` | Double speed | Ускорить вдвое | Toggle: play twice as fast. | |
| `seeResult` | See results | Результат | Button after the run: open the result screen. | |
| `runWake` | Oyen wakes up, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Ойен проснулся и смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Run caption, step 0. Placeholders: `{dir}`. | |
| `runAtBowl` | Made it to the bowl! Nom nom. | Дошёл до миски! Ням-ням. | Run caption: reached the bowl. | |
| `chaseFish` | Chasing the fish {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Бежит за рыбкой {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Run and replay caption: chasing a fish. Placeholders: `{dir}`. | |
| `runSmellFish` | Hey, salted fish {dir, select, up{up there} right{to the right} down{down there} left{to the left} other{to the right}}! | Ого, {dir, select, up{сверху} right{справа} down{снизу} left{слева} other{справа}} пахнет солёной рыбкой! | Run caption: a fish comes into sight. Placeholders: `{dir}`. | |
| `runWalk` | Strolling {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}, no rush. | Идёт {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}, не спеша. | Run caption: walking straight. Placeholders: `{dir}`. | |
| `runScared` | Water! Oyen jumps and turns back. | Вода! Ойен пугается и разворачивается. | Run caption: water ahead. | |
| `runTurn` | Hit {obstacle, select, table{a table} wall{a wall} other{a wall}}. Turned, now facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Упёрся в {obstacle, select, table{стол} wall{стену} other{стену}}. Повернулся, теперь смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Run caption: blocked by a table or wall, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `runEat` | Chomp! The salted fish is gone. | Ам! Рыбка съедена. | Run caption: eats a fish. | |
| `runEnterBox` | A box! Oyen climbs in and sits. | Коробка! Ойен залез и сел. | Run caption: gets into a box. | |
| `runSit` | Sitting pretty in the box. | Сидит в коробке. | Run caption: still sitting in the box. | |
| `runBoxGone` | The box gets squashed, then vanishes. | Коробка смялась и исчезла. | Run caption: the box is squashed and disappears. | |
| `runKnockGlass` | The glass gets pushed off. Lucky it's plastic! | Стакан полетел вниз. Хорошо, что пластиковый! | Run caption: pushes a glass off a table. | |
| `runKnockVase` | Uh-oh! Mom's vase falls and breaks. | Ой! Мамина ваза упала и разбилась. | Run caption: pushes the vase off and it breaks. | |
| `replayAsleep` | Start: Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Начало: Ойен спит и смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Replay caption, step 0. Placeholders: `{dir}`. | |
| `replayFinished` | Into the bowl. Done in {n, plural, one{{n} step} other{{n} steps}}. | В миске. Готово за {n, plural, one{{n} шаг} few{{n} шага} many{{n} шагов} other{{n} шага}}. | Replay caption: reached the bowl after n steps. Placeholders: `{n}`. | |
| `replayChaseVaseSafe` | Chasing the fish. Vase still safe. | За рыбкой. Ваза пока цела. | Replay caption: chasing a fish, vase still fine. | |
| `replaySeeFish` | Salted fish in sight, straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Солёная рыбка видна прямо {dir, select, up{сверху} right{справа} down{снизу} left{слева} other{справа}}. | Replay caption: a fish in a straight line. Placeholders: `{dir}`. | |
| `replayWalk` | Walks straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Идёт {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Replay caption: walking straight. Placeholders: `{dir}`. | |
| `replayScared` | Meets {water, select, puddle{a puddle} bucket{a water bucket} other{water}}, jumps, turns back. | Впереди {water, select, puddle{лужа} bucket{ведро воды} other{вода}}: испугался, развернулся. | Replay caption: water ahead (puddle or bucket), turned back. Placeholders: `{water}`. | |
| `replayTurn` | Hits {obstacle, select, table{a table} wall{a wall} other{a wall}}, turns to face {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Упёрся в {obstacle, select, table{стол} wall{стену} other{стену}}, повернулся и смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}}. | Replay caption: blocked, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `replayEat` | Chomp! Salted fish eaten. | Ам! Рыбка съедена. | Replay caption: eats a fish. | |
| `replayEnterBox` | Into the box, time to sit. | Залез в коробку, сидит. | Replay caption: gets into a box. | |
| `replaySit` | Still sitting in the box. | Всё ещё сидит в коробке. | Replay caption: still in the box. | |
| `replayBoxGone` | The box is squashed and gone. | Коробка смялась и исчезла. | Replay caption: the box is gone. | |
| `replayKnockGlass` | Glass pushed off. No harm, it's plastic. | Стакан сброшен. Не страшно, пластик. | Replay caption: glass pushed off. | |
| `replayKnockVase` | Mom's vase pushed off. Smash! | Мамина ваза сброшена. Вдребезги! | Replay caption: vase pushed off. | |
| `replayLoopStart` | Back to how it started. Oyen keeps circling and gets bored. | Снова как в начале. Ойен ходит по кругу, и ему скучно. | Replay caption, last step: same state as the start. | |
| `replayLoopStep` | Back to how step {n} looked. Oyen keeps circling and gets bored. | Снова как на шаге {n}. Ойен ходит по кругу, и ему скучно. | Replay caption, last step: same state as step n. Placeholders: `{n}`. | |
| `replayTooManySteps` | Step {n} and still no bowl. Oyen is bored. | Шаг {n}, а миски нет. Ойену скучно. | Replay caption, last step: hit the step limit. Placeholders: `{n}`. | |
| `closeRules` | Close rules | Закрыть правила | Screen reader: close the rules sheet. | |
| `rulesTitle` | Oyen's Rules | Правила Ойена | Rules sheet title. | |
| `rulesIntro` | Each step is checked from the top. The first rule that fits is what Oyen does. | Каждый шаг проверяется сверху вниз. Что подошло первым, то Ойен и делает. | Rules sheet intro. | |
| `ruleKnockTitle` | Knock over what's next door | Сбросить вещь рядом | Rule card: knock things off the table next to Oyen. | |
| `ruleKnockBody` | A glass or vase on the table next door? It gets bumped. Always. | Стакан или ваза на соседнем столе? Ойен столкнёт. Всегда. | Rule card body: knock. | |
| `ruleFishTitle` | Chase the nearest fish | Бежать к ближайшей рыбке | Rule card: chase the nearest fish. | |
| `ruleFishBody` | Only fish in a straight line. If tied: | Только те, что видны по прямой. Если поровну: | Rule card body: fish, before the tie order. | |
| `tieAhead` | ahead | прямо | Tie order word 1 (followed by an arrow). | |
| `tieClockwise` | clockwise | по часовой | Tie order word 2: clockwise (never "right"). | |
| `tieCounterClockwise` | counterclockwise | против часовой | Tie order word 3: counterclockwise (never "left"). | |
| `tieBehind` | behind | назад | Tie order word 4. | |
| `tieOrderLabel` | Tie order: ahead, clockwise, counterclockwise, behind. | Порядок при равенстве: прямо, по часовой, против часовой, назад. | Screen reader text of the tie order. | |
| `ruleWaterTitle` | Water? Turn back | Вода? Назад | Rule card: water, turn back. | |
| `ruleWaterBody` | Puddle or bucket ahead? Oyen gets spooked and turns around. | Лужа или ведро впереди? Ойен пугается и разворачивается. | Rule card body: water. | |
| `ruleWallTitle` | Blocked by a wall or table | Упёрся в стену или стол | Rule card: blocked by a wall or table. | |
| `ruleWallTurn` | Oyen turns clockwise | Ойен поворачивается по часовой | Rule card: turns clockwise (never "turns right"). | |
| `ruleWallBody` | A quarter turn, then off again. | Четверть оборота — и снова в путь. | Rule card body: wall. | |
| `ruleBoxTitle` | Box? Hop in, sit | Коробка? Залезть и сидеть | Rule card: box, get in and sit. | |
| `ruleBoxBody` | Sits 2 steps until the box gets squashed and vanishes. Fish behind a box stay hidden. | Сидит 2 шага, пока коробка не сомнётся и не исчезнет. Рыбку за коробкой не видно. | Rule card body: box. | |
| `ruleKnockLocked` | Things on tables | Вещи на столе | Locked rule card name: knock. | |
| `ruleFishLocked` | Fish | Рыбка | Locked rule card name: fish. | |
| `ruleWaterLocked` | Water | Вода | Locked rule card name: water. | |
| `ruleWallLocked` | Wall | Стена | Locked rule card name: wall. | |
| `ruleBoxLocked` | Box | Коробка | Locked rule card name: box. | |
| `ruleLockedTitle` | {name}: ??? | {name}: ??? | Locked rule card title. Placeholders: `{name}`. | |
| `ruleLockedBody` | Not learned yet. You'll meet it soon. | Ещё не изучено. Скоро познакомитесь. | Locked rule card body. | |
| `ruleLabel` | Rule {n} | Правило {n} | Screen reader label of rule card n. Placeholders: `{n}`. | |
| `ruleLockedLabel` | Rule {n}, locked, not learned yet | Правило {n}, закрыто, ещё не изучено | Screen reader label of a locked rule card. Placeholders: `{n}`. | |
| `closeHints` | Close hints | Закрыть подсказки | Screen reader: close the hint sheet. | |
| `hintsTitle` | Hints | Подсказки | Hint sheet title. | |
| `hintsIntro` | Go slow. Maybe all you need is a little nudge. | Не спеши. Может, хватит маленькой подсказки. | Hint sheet intro. | |
| `hintTier1Title` | Highlight the first tile | Показать первую клетку | Hint tier 1 title. | |
| `hintTier2Title` | Show the item type | Показать предмет | Hint tier 2 title. | |
| `hintTier3Title` | Show the full solution | Показать всё решение | Hint tier 3 title. | |
| `hintOpened` | Unlocked | Открыта | Hint tier status: already unlocked. | |
| `hintTier` | Tier {n} | Ступень {n} | Hint tier status: ready to unlock. Placeholders: `{n}`. | |
| `hintUnlockFirst` | Unlock tier {n} first | Сначала открой ступень {n} | Hint tier status: unlock the previous tier first. Placeholders: `{n}`. | |
| `noItemsHint` | No items needed here. Just wake Oyen up! | Здесь предметы не нужны. Просто разбуди Ойена! | Hint sheet card on levels without items. | |
| `hintTier1Text` | See the glowing tile? Something needs to go there. | Видишь светящуюся клетку? Туда нужно что-то поставить. | Unlocked hint tier 1. | |
| `hintPlaceFish` | Put a salted fish on the glowing tile. Oyen will chase it and eat it. | Положи солёную рыбку на светящуюся клетку. Ойен побежит за ней и съест. | Unlocked hint tier 2: salted fish. | |
| `hintPlaceWater` | Put a water bucket on the glowing tile. Oyen will get spooked and turn around. | Поставь ведро воды на светящуюся клетку. Ойен испугается и развернётся. | Unlocked hint tier 2: water bucket. | |
| `hintPlaceBox` | Put a box on the glowing tile. Oyen will climb in and sit there. | Поставь коробку на светящуюся клетку. Ойен залезет в неё и посидит. | Unlocked hint tier 2: box. | |
| `hintFishCount` | {count, select, one{a salted fish} two{two salted fish} three{three salted fish} other{{n} salted fish}} | {count, select, one{солёную рыбку} two{две солёные рыбки} three{три солёные рыбки} other{солёных рыбок: {n}}} | Hint tier 3 list part (count = one/two/three/other, n = number): n salted fish. Placeholders: `{count}`, `{n}`. | |
| `hintWaterCount` | {count, select, one{a water bucket} two{two water buckets} three{three water buckets} other{{n} water buckets}} | {count, select, one{ведро воды} two{два ведра воды} three{три ведра воды} other{вёдер воды: {n}}} | Hint tier 3 list part (count = one/two/three/other, n = number): n water buckets. Placeholders: `{count}`, `{n}`. | |
| `hintBoxCount` | {count, select, one{a box} two{two boxes} three{three boxes} other{{n} boxes}} | {count, select, one{коробку} two{две коробки} three{три коробки} other{коробок: {n}}} | Hint tier 3 list part (count = one/two/three/other, n = number): n boxes. Placeholders: `{count}`, `{n}`. | |
| `listPair` | {a} and {b} | {a} и {b} | Joins two list parts. Placeholders: `{a}`, `{b}`. | |
| `listLast` | {rest}, and {last} | {rest} и {last} | Joins the comma-separated start of a list with its last part. Placeholders: `{rest}`, `{last}`. | |
| `hintSolution` | {items} on the glowing {count, plural, one{tile} other{tiles}}. {tail} | Поставь {items} {count, plural, one{на светящуюся клетку} other{на светящиеся клетки}}. {tail} | Unlocked hint tier 3 (first letter is capitalized in code); count = number of items. Placeholders: `{items}`, `{count}`, `{tail}`. | |
| `hintSolutionVaseSafe` | Vase safe, 3 stars. | Ваза цела, 3 звезды. | Tier 3 ending on levels with a vase. | |
| `hintSolutionStars` | 3 stars! | 3 звезды! | Tier 3 ending on levels without a vase. | |
| `tutorial1Title` | You can't boss Oyen around. Just wake the cat up! | Ойену не прикажешь. Просто разбуди его! | Tutorial level 1, big text. | |
| `tutorial1Body` | Oyen walks to the bowl alone. You just watch. | Он сам дойдёт до миски. Тебе остаётся смотреть. | Tutorial level 1, small text. | |
| `tutorial3Title` | Oyen can't resist salted fish! | Ойен обожает солёную рыбку! | Tutorial level 3 (fish), big text. | |
| `tutorial3Body` | Drag a fish onto the floor. If Oyen sees it in a straight line, the chase is on. | Перетащи рыбку на пол. Если её видно по прямой, он сразу побежит за ней. | Tutorial level 3, small text. | |
| `tutorial6Title` | Oyen hates water. Like, really. | Ойен боится воды. Очень. | Tutorial level 6 (bucket), big text. | |
| `tutorial6Body` | Put the bucket in the way. Water ahead means a spooked cat and a U-turn. | Поставь ведро на пути. Увидит воду — испугается и повернёт назад. | Tutorial level 6, small text. | |
| `tutorialLabel` | Tutorial | Обучение | Screen reader label of the tutorial card. | |
| `skipTutorial` | Skip tutorial | Пропустить обучение | Screen reader label of the Skip button. | |
| `skip` | Skip | Пропустить | Skip button of the tutorial. | |
| `success` | Nailed it! | Получилось! | Success screen headline. | |
| `stepsUnit` | {n, plural, one{step} other{steps}} | {n, plural, one{шаг} few{шага} many{шагов} other{шага}} | Word under a step count ("6 steps"). Placeholders: `{n}`. | |
| `itemsUsedUnit` | {n, plural, one{item used} other{items used}} | {n, plural, one{предмет} few{предмета} many{предметов} other{предмета}} | Words under an item count ("2 items used"). Placeholders: `{n}`. | |
| `goalBowl` | Reached the bowl | Дошёл до миски | Star rule 1. | |
| `goalVase` | Mom's vase is safe | Мамина ваза цела | Star rule 2. | |
| `goalItems` | Fewest items | Меньше всего предметов | Star rule 3. | |
| `goalNotYet` | Not yet | Пока нет | Star rule status: not earned. | |
| `goalGot` | Got it | Есть | Star rule status: earned (vase screen). | |
| `goalAchieved` | done | выполнено | Screen reader: star rule earned (check mark). | |
| `restart` | Restart | Заново | Button: restart with an empty board. | |
| `next` | Next | Дальше | Button: next level. | |
| `watchReplay` | Watch the replay | Смотреть повтор | Link on the success screen. | |
| `vaseHeadlineTop` | Made it... | Дошёл, конечно... | Vase screen headline, line 1. | |
| `vaseHeadlineBottom` | but Mom's vase? | а мамина ваза? | Vase screen headline, line 2. | |
| `brokenAtStep` | Broke on step {n} | Разбита на шаге {n} | Vase screen: the step the vase broke. Placeholders: `{n}`. | |
| `tryAgain` | Try Again | Ещё раз | Vase screen button: arrange again. | |
| `nextAnyway` | Next Anyway | Всё равно дальше | Vase screen button: next level anyway. | |
| `vaseArtLabel` | The vase lies broken behind Oyen, and Mom pops in at the door, annoyed | За Ойеном разбитая ваза, в дверях появляется недовольная мама | Screen reader label of the vase screen picture. | |
| `loopTitle` | Oyen got bored going in circles. | Ойену надоело ходить по кругу. | Fail screen title: going in circles. | |
| `loopBadge` | Going in circles | По кругу | Fail screen chip: going in circles. | |
| `loopMessage` | Round and round, no bowl in sight. Oh well, back to sleep. | Кругами да кругами, а миски нет. Ну и ладно, спать. | Fail screen message: going in circles. | |
| `tooLongTitle` | Oyen got tired of walking. | Ойен устал ходить. | Fail screen title: walked too long. | |
| `tooLongBadge` | Over {n} steps | {n, plural, one{Больше {n} шага} other{Больше {n} шагов}} | Fail screen chip: over the step limit. Placeholders: `{n}`. | |
| `tooLongMessage` | {n} steps and still no bowl. Ugh, so tired. Back to sleep. | {n, plural, one{{n} шаг} few{{n} шага} other{{n} шагов}}, а миски всё нет. Устал. Спать. | Fail screen message: over the step limit. Placeholders: `{n}`. | |
| `failedKicker` | Level {id} · Failed | Уровень {id} · Неудача | Fail screen line above the title. Placeholders: `{id}`. | |
| `replay` | Replay | Повтор | Replay button and replay screen title. | |
| `arrangeAgain` | Rearrange | Переставить | Fail screen button: back to arranging. | |
| `replayStart` | Start | Начало | Replay: label of step 0. | |
| `replayPlay` | Autoplay | Автовоспроизведение | Replay: button that plays the steps by itself (screen reader label; the pause state uses "pause"). | |
| `backToResult` | Back to results | Назад к результату | Replay: back to the result screen. | |
| `recording` | Recording | Запись | Replay: chip next to the title. | |
| `replayStepCaption` | Step {n}. {text} | Шаг {n}. {text} | Replay: screen reader caption of step n. Placeholders: `{n}`, `{text}`. | |
| `timeline` | Time | Время | Replay: label of the time slider (shown in capitals). | |
| `oyenLabel` | Oyen {pose, select, idle{standing} walk{walking} sleep{asleep} shock{startled} box{sitting in a box} knock{knocking something over} eat{eating} happy{happy} other{standing}}, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Ойен {pose, select, idle{стоит} walk{идёт} sleep{спит} shock{испугался} box{сидит в коробке} knock{сбрасывает вещь} eat{ест} happy{доволен} other{стоит}}, смотрит {dir, select, up{вверх} right{вправо} down{вниз} left{влево} other{вправо}} | Screen reader label of Oyen: pose and facing (screen direction). Placeholders: `{pose}`, `{dir}`. | |
| `costumeNone` | Plain | Без костюма | Costume: none. | |
| `costumePeci` | Peci Cap | Пеци | Costume: peci (Indonesian cap). | |
| `costumeSarung` | Sarong | Саронг | Costume: sarong. | |
| `costumeKoki` | Chef Hat | Колпак | Costume: chef hat. | |
| `costumeKacamata` | Glasses | Очки | Costume: glasses. | |
| `costumeWearingTag` | Wearing | Надето | Costume card tag: being worn. | |
| `costumeWearingStatus` | wearing | надето | Screen reader status: being worn. | |
| `costumeOwnedTag` | Yours | Твоё | Costume card tag: owned. | |
| `costumeOwnedStatus` | yours | твоё | Screen reader status: owned. | |
| `costumeActionWearing` | Wearing now | Сейчас надето | Closet button: selected costume is worn. | |
| `costumeActionWear` | Wear | Надеть | Closet button: wear the owned costume. | |
| `costumeActionBuy` | {n, plural, one{Buy · {n} coin} other{Buy · {n} coins}} | {n, plural, one{Купить · {n} монета} few{Купить · {n} монеты} many{Купить · {n} монет} other{Купить · {n} монеты}} | Closet button: buy for n coins. Placeholders: `{n}`. | |
| `closeCoins` | Close coins | Закрыть монеты | Screen reader: close the coin sheet. | |
| `coinsTitle` | Get Coins | Монеты | Coin sheet title. | |
| `coinsIntro` | Coins buy hints and outfits for Oyen. Grab the daily bonus, or watch an ad. | Монеты нужны для подсказок и костюмов Ойена. Забирай бонус каждый день или смотри рекламу. | Coin sheet intro. | |
| `dailyBonus` | Daily bonus | Ежедневный бонус | Coin card title: daily bonus. | |
| `dailyBonusReady` | Once a day | Раз в день | Daily bonus status: can claim. | |
| `dailyBonusTaken` | Claimed today | Сегодня уже получено | Daily bonus status: already claimed. | |
| `claimCoins` | {n, plural, one{Claim {n} coin} other{Claim {n} coins}} | {n, plural, one{Забрать {n} монету} few{Забрать {n} монеты} many{Забрать {n} монет} other{Забрать {n} монеты}} | Daily bonus button. Placeholders: `{n}`. | |
| `claimTomorrow` | Back tomorrow | Завтра ещё | Daily bonus button after claiming. | |
| `adsLeftToday` | {n, plural, one{{n} left today} other{{n} left today}} | Сегодня осталось: {n} | Ad card status: ads left today. Placeholders: `{n}`. | |
| `adsUsedUp` | All used up today | На сегодня всё | Ad card status: no ads left today. | |
| `adRewardButton` | {n, plural, one{+{n} coin} other{+{n} coins}} | {n, plural, one{+{n} монета} few{+{n} монеты} many{+{n} монет} other{+{n} монеты}} | Ad card button: plus n coins. Placeholders: `{n}`. | |
| `adsTomorrow` | More tomorrow | Завтра ещё | Ad card button when used up. | |
| `coinChipAdd` | get coins | добавить монеты | Screen reader: the coin chip opens the coin sheet. | |
| `coinChipBonus` | daily bonus ready | ежедневный бонус готов | Screen reader: the daily bonus is ready. | |
| `soundSection` | Sound | Звук | Settings section: music and sound effects. | |
| `music` | Music | Музыка | Settings switch: background music. | |
| `soundEffects` | Sound effects | Звуковые эффекты | Settings switch: sound effects. | |
| `language` | Language | Язык | Settings section: language. | |
| `languageSystem` | Use phone language | Язык телефона | Language option: follow the phone language. | |
| `tutorialsSection` | Tutorials | Обучение | Settings section: tutorials. | |
| `replayTutorials` | Show tutorials again | Показать обучение снова | Settings button: show the tutorials again. | |
| `replayTutorialsInfo` | The tutorials on levels 1, 3, and 6 show up again next time you play them. | Обучение на уровнях 1, 3 и 6 появится снова, когда ты их откроешь. | Settings text under the tutorials button. | |
| `tutorialsBack` | Done! The tutorials are back. | Готово! Обучение вернулось. | Confirmation after pressing "show tutorials again". | |
| `progressSection` | Progress | Прогресс | Settings section: progress. | |
| `resetProgress` | Reset progress | Сбросить прогресс | Settings button: reset progress. | |
| `resetProgressInfo` | Erase stars, coins, outfits, hints, and tutorials, then start again from level 1. | Удалить звёзды, монеты, костюмы, подсказки и обучение и начать с уровня 1. | Settings text under the reset button. | |
| `resetConfirmTitle` | Erase all progress? | Удалить весь прогресс? | Reset confirmation title. | |
| `resetConfirmBody` | Stars, coins, outfits, hints, and tutorials will be erased. This can't be undone. Today's daily bonus and ads stay used. | Звёзды, монеты, костюмы, подсказки и обучение будут удалены. Отменить нельзя. Сегодняшний бонус и реклама останутся использованными. | Reset confirmation text. | |
| `resetConfirm` | Erase | Удалить | Reset confirmation button. | |
| `closeReset` | Close reset | Закрыть сброс | Screen reader: close the reset confirmation. | |
| `resetDone` | Progress erased. Fresh start! | Прогресс удалён. Начнём сначала! | Message after resetting. | |
| `privacySection` | Privacy | Конфиденциальность | Settings section: privacy (policy link and ad consent). | |
| `privacyInfo` | Your progress stays on your phone. Ads come from Google AdMob. | Прогресс хранится на твоём телефоне. Реклама — от Google AdMob. | Settings, Privacy card: short explanation above the buttons. | |
| `privacyPolicy` | Privacy policy | Политика конфиденциальности | Settings, Privacy: button that opens the privacy policy in the browser. | |
| `adConsent` | Ad consent settings | Согласие на рекламу | Settings, Privacy: button that reopens the ad consent form (only where the law requires it). | |
| `privacyLinkFailed` | Couldn't open the browser. Try again later, okay? | Браузер не открылся. Попробуй позже, ладно? | Settings, Privacy: small message when the browser could not be opened. | |
| `about` | About | Об игре | Settings section: about the game. | |
| `version` | Version {version} | Версия {version} | App version. Placeholders: `{version}`. | |
| `fontCredits` | Fonts: Fredoka and Nunito (SIL Open Font License). | Шрифты: Fredoka и Nunito (SIL Open Font License). | Font credits. | |
| `soundCredits` | Sound effects: Kenney and OpenGameArt (CC0). The music was made just for Ginger Logic. | Звуки: Kenney и OpenGameArt (CC0). Музыку написали специально для Ginger Logic. | About card: credits for sound effects (CC0 sources) and the original music. | |
| `licenses` | Licenses | Лицензии | Button: open the licenses page. | |

---

## Store listing: English (for reference)

### Store listing: English (en-US, default)

Paste into Play Console → Grow users → Store presence → Main store listing.

#### App name (≤ 30)

```
Ginger Logic: Cute Cat Puzzle
```

#### Short description (≤ 80)

```
A stubborn orange cat won't listen. Place fish & boxes to guide it to dinner!
```

#### Full description (≤ 4000)

```
Meet Oyen: a chubby orange cat with a sleepy face and zero interest in taking orders.

You can't move Oyen. You can only set up the room. Drop a salted fish here, a water bucket there, a cardboard box in the corner, then press "Wake Oyen" and watch. Oyen follows the same simple rules every time:

• Food bowl? Done, dinner time.
• Box? Hop in and sit for a bit.
• Something on the table next door? Knock it off. Obviously.
• A fish in plain sight? Chase the nearest one.
• Water ahead? Nope, turn back.
• Wall or table in the way? Turn clockwise and keep going.

Figure out the rules, plan the path, and get Oyen to the bowl. Just keep an eye on Mom's vase. Breaking it won't end the level, but it will cost you stars.

WHAT'S INSIDE
• 20 hand-made puzzles across two rooms: the Kitchen and the Living Room, each with a boss level
• Up to 3 stars per level: reach the bowl, keep the vase safe, and use as few items as possible
• Step-by-step replay so you can see exactly where Oyen went wrong (or right)
• Rule cards and short tutorials that teach as you go
• Stuck? Hints reveal one tile at a time, paid with coins or a short optional video ad
• Coins from new stars, a daily bonus, and optional ads
• A wardrobe for Oyen: peci cap, sarong, chef hat, and glasses
• Calm music and cute sound effects (each can be switched off)
• English, Indonesian, Brazilian Portuguese, and Russian

NO PRESSURE
No timers, no lives, no energy bars. Play offline, at your own pace. Your progress stays on your phone, no account needed.

Oyen won't listen. You do the thinking.
```

#### Notes

- Category: Game → Puzzle. Tags: Logic, Casual, Offline.
- Contact email: yoluvy.dev@gmail.com. Website: https://yoluvy.my.id/ (optional).
- Privacy policy URL: https://yoluvy.my.id/ginger-logic/privacy/

## Store listing: Russian

### Описание в магазине: русский (ru-RU)

Вставить в Play Console → Описание в магазине → Добавить перевод → Русский.

#### Название (≤ 30)

```
Ginger Logic: Котоголоволомка
```

#### Краткое описание (≤ 80)

```
Упрямый рыжий кот не слушается. Расставь рыбку и коробки и приведи его к миске!
```

#### Полное описание (≤ 4000)

```
Знакомься: Ойен. Пухлый рыжий кот с сонной мордой и полным нежеланием кого-либо слушаться.

Управлять Ойеном нельзя. Можно только обустроить комнату. Положи солёную рыбку сюда, ведро воды туда, коробку в угол, нажми «Разбудить Ойена» и смотри. Ойен всегда следует одним и тем же простым правилам:

• Дошёл до миски? Всё, пора обедать.
• Коробка? Залезть и посидеть.
• На соседнем столе что-то стоит? Сбросить. Разумеется.
• Видна рыбка по прямой? Бежать к ближайшей.
• Впереди вода? Ни за что, назад.
• Упёрся в стену или стол? Повернуть по часовой стрелке и идти дальше.

Разберись в правилах, продумай путь и доведи Ойена до миски. Только береги мамину вазу: если она разобьётся, уровень не закончится, но звёзды пропадут.

ЧТО ВНУТРИ
• 20 головоломок ручной работы в двух комнатах, Кухне и Гостиной, в каждой свой уровень-босс
• До 3 звёзд за уровень: дойти до миски, сберечь вазу и обойтись минимумом предметов
• Повтор по шагам: видно, где именно Ойен свернул не туда (или туда)
• Карточки правил и короткое обучение прямо по ходу игры
• Застрял? Подсказки открывают по одной клетке за монеты или за короткую рекламу по желанию
• Монеты за новые звёзды, ежедневный бонус и реклама по желанию
• Гардероб Ойена: пеци, саронг, поварской колпак и очки
• Спокойная музыка и милые звуки (каждое можно выключить)
• Английский, индонезийский, бразильский португальский и русский

БЕЗ СПЕШКИ
Ни таймеров, ни жизней, ни энергии. Играй без интернета, в своём темпе. Прогресс хранится на телефоне, аккаунт не нужен.

Ойен не слушается. Думать тебе.
```
