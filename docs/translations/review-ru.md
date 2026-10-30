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

476 lines. Generated from `lib/l10n/` by `tool/translations/make_review.py`; do not edit by hand.

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
| `settings` | Settings | Настройки | Settings button and screen title. | |
| `tagline` | Oyen won't listen. You do the thinking. | Ойен не слушается. Думать тебе. | Tagline under the logo on the home screen. | |
| `splashTagline` | Let's play! | Играем! | Short line under the logo on the Android splash screen (rendered into an image, keep it very short). | |
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
| `closeCoins` | Close coins | Закрыть монеты | Screen reader: close the coin sheet. | |
| `coinsTitle` | Get Coins | Монеты | Coin sheet title. | |
| `coinsIntro` | Coins buy hints and stuff for Oyen's room. Grab the daily bonus, or watch an ad. | Монеты нужны для подсказок и вещей в комнату Ойена. Забирай бонус каждый день или смотри рекламу. | Coin sheet intro. | |
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
| `resetProgressInfo` | Erase stars, coins, room stuff, hints, and tutorials, then start again from level 1. | Удалить звёзды, монеты, вещи в комнате, подсказки и обучение и начать с уровня 1. | Settings text under the reset button. | |
| `resetConfirmTitle` | Erase all progress? | Удалить весь прогресс? | Reset confirmation title. | |
| `resetConfirmBody` | Stars, coins, room stuff, hints, and tutorials will be erased. This can't be undone. Today's daily bonus and ads stay used. | Звёзды, монеты, вещи в комнате, подсказки и обучение будут удалены. Отменить нельзя. Сегодняшний бонус и реклама останутся использованными. | Reset confirmation text. | |
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
| `roomItemTikus` | Toy Mouse | Игрушечная мышка | Name of the room item "Toy Mouse". | |
| `roomItemTikusDesc` | Never runs away, still gets chased. | Никуда не убегает, но за ней всё равно охотятся. | Shop description of the room item "Toy Mouse". | |
| `roomItemAkuarium` | Aquarium | Аквариум | Name of the room item "Aquarium". | |
| `roomItemAkuariumDesc` | All-day entertainment. The fish are a bit nervous. | Развлечение на весь день. Рыбки слегка нервничают. | Shop description of the room item "Aquarium". | |
| `roomItemRumah` | Cat House | Домик для кота | Name of the room item "Cat House". | |
| `roomItemRumahDesc` | Has its own house, still sleeps in the box. | Свой дом есть, а спит всё равно в коробке. | Shop description of the room item "Cat House". | |
| `roomItemKasur` | Cushion Bed | Матрасик-подушка | Name of the room item "Cushion Bed". | |
| `roomItemKasurDesc` | Soft. Used 60% of the time, the rest is box. | Мягкий. Используется 60% времени, остальное — коробка. | Shop description of the room item "Cushion Bed". | |
| `roomItemCatnip` | Catnip Pot | Горшок с котовником | Name of the room item "Catnip Pot". | |
| `roomItemCatnipDesc` | One sniff and the dancing starts. | Один вдох — и сразу танцы. | Shop description of the room item "Catnip Pot". | |
| `roomItemJam` | Cat Clock | Часы-кот | Name of the room item "Cat Clock". | |
| `roomItemJamDesc` | The tail swings every second. Hypnotic. | Хвост качается каждую секунду. Гипноз. | Shop description of the room item "Cat Clock". | |
| `roomItemKardus` | Cozy Box | Уютная коробка | Name of the room item "Cozy Box". | |
| `roomItemKardusDesc` | It's the box that gets picked, not what came in it. | Выбирают коробку, а не то, что в ней было. | Shop description of the room item "Cozy Box". | |
| `roomItemBola` | Yarn Ball | Клубок пряжи | Name of the room item "Yarn Ball". | |
| `roomItemBolaDesc` | Tangled in 3 seconds. That's the feature. | Запутается за 3 секунды. Это фича. | Shop description of the room item "Yarn Ball". | |
| `roomItemKarpet` | Round Rug | Круглый коврик | Name of the room item "Round Rug". | |
| `roomItemKarpetDesc` | The official rolling-around spot. | Официальное место для валяния. | Shop description of the room item "Round Rug". | |
| `roomItemTiang` | Scratching Post | Когтеточка | Name of the room item "Scratching Post". | |
| `roomItemTiangDesc` | So Mom's sofa survives. Hopefully. | Чтобы мамин диван выжил. Надеемся. | Shop description of the room item "Scratching Post". | |
| `roomItemLukisan` | Fish Painting | Картина с рыбой | Name of the room item "Fish Painting". | |
| `roomItemLukisanDesc` | Art that makes you hungry. | Искусство, от которого хочется есть. | Shop description of the room item "Fish Painting". | |
| `roomItemRak` | Wall Shelf | Полка на стене | Name of the room item "Wall Shelf". | |
| `roomItemRakDesc` | VIP seat for watching everyone. | VIP-место, чтобы следить за всеми. | Shop description of the room item "Wall Shelf". | |
| `roomItemPancingan` | Feather Wand | Удочка с перьями | Name of the room item "Feather Wand". | |
| `roomItemPancinganDesc` | Chases the feather, leaves its dignity behind. | За перышком бежит, достоинство остаётся позади. | Shop description of the room item "Feather Wand". | |
| `roomItemLampuBulan` | Moon Lamp | Лампа-луна | Name of the room item "Moon Lamp". | |
| `roomItemLampuBulanDesc` | A private moon, no need to wait for night. | Личная луна — ночи ждать не надо. | Shop description of the room item "Moon Lamp". | |
| `roomItemBantalIkan` | Fish Pillow | Подушка-рыба | Name of the room item "Fish Pillow". | |
| `roomItemBantalIkanDesc` | Soft, and fishy only to look at. | Мягкая, и рыбой пахнет только на вид. | Shop description of the room item "Fish Pillow". | |
| `roomItemMonstera` | Monstera Plant | Монстера | Name of the room item "Monstera Plant". | |
| `roomItemMonsteraDesc` | The leaves have holes. Not Oyen's doing. This time. | Листья в дырках. Ойен не виноват. На этот раз. | Shop description of the room item "Monstera Plant". | |
| `roomItemTerowongan` | Cat Tunnel | Кошачий туннель | Name of the room item "Cat Tunnel". | |
| `roomItemTerowonganDesc` | One cat goes in, style comes out. | Заходит кот — выходит со стилем. | Shop description of the room item "Cat Tunnel". | |
| `roomItemHammock` | Window Hammock | Гамак на окно | Name of the room item "Window Hammock". | |
| `roomItemHammockDesc` | Naps with a swing. Wake up and it's evening. | Сон с покачиванием. Проснулся — уже вечер. | Shop description of the room item "Window Hammock". | |
| `roomItemSofaMini` | Mini Sofa | Мини-диван | Name of the room item "Mini Sofa". | |
| `roomItemSofaMiniDesc` | Its own sofa, so Mom's is safe. Allegedly. | Свой диван — мамин в безопасности. Якобы. | Shop description of the room item "Mini Sofa". | |
| `roomItemJendelaBurung` | Bird Window | Окно с птицами | Name of the room item "Bird Window". | |
| `roomItemJendelaBurungDesc` | 24-hour cat TV, all birds, no ads. | Кошачье ТВ 24 часа: птицы без рекламы. | Shop description of the room item "Bird Window". | |
| `roomItemMangkuk` | Food bowl | Миска с едой | Name of the room item "Food bowl". | |
| `kittyOyen` | Oyen | Ойен | Name of the collection cat "Oyen". | |
| `kittyOyenDesc` | The ginger cat you wake up every level. | Рыжий кот, которого ты будишь на каждом уровне. | Shop description of the collection cat "Oyen". | |
| `kittySalju` | Snowy | Снежок | Name of the collection cat "Snowy". | |
| `kittySaljuDesc` | Spotless white. Stays that way until it finds a box. | Белоснежный. Пока не найдёт коробку. | Shop description of the collection cat "Snowy". | |
| `kittyTelon` | Patches | Тришка | Name of the collection cat "Patches". | |
| `kittyTelonDesc` | Three colors, three moods a minute. | Три цвета, три настроения в минуту. | Shop description of the collection cat "Patches". | |
| `kittyArang` | Charcoal | Уголёк | Name of the collection cat "Charcoal". | |
| `kittyArangDesc` | Deep black, yellow eyes. Expert shadow hider. | Чёрный как уголь, глаза жёлтые. Мастер прятаться в тенях. | Shop description of the collection cat "Charcoal". | |
| `kittyMendung` | Cloudy | Тучка | Name of the collection cat "Cloudy". | |
| `kittyMendungDesc` | Looks sad, is just sleepy. | Выглядит грустным, а просто хочет спать. | Shop description of the collection cat "Cloudy". | |
| `kittyKopiSusu` | Latte | Латте | Name of the collection cat "Latte". | |
| `kittyKopiSusuDesc` | Sweet, a little bitter when woken up. | Сладкий, но горчит, если разбудить. | Shop description of the collection cat "Latte". | |
| `kittyMochi` | Mochi | Моти | Name of the collection cat "Mochi". | |
| `kittyMochiDesc` | Calm, squishy, face like it played in mud. | Спокойный, мягкий, морда как после игры в грязи. | Shop description of the collection cat "Mochi". | |
| `kittyBos` | Boss | Босс | Name of the collection cat "Boss". | |
| `kittyBosDesc` | Always in a suit. Meetings at every mealtime. | Всегда в костюме. Совещания в каждый приём пищи. | Shop description of the collection cat "Boss". | |
| `kittyKembang` | Blossom | Цветик | Name of the collection cat "Blossom". | |
| `kittyKembangDesc` | Abstract markings, abstract behavior. | Окрас абстрактный, поведение тоже. | Shop description of the collection cat "Blossom". | |
| `accessoryPita` | Ribbon | Лента | Name of the accessory "Ribbon". | |
| `accessoryPitaDesc` | Simple, sweet, easy to put on. | Просто, мило, надевается легко. | Shop description of the accessory "Ribbon". | |
| `accessoryJepitBunga` | Flower Clip | Заколка-цветок | Name of the accessory "Flower Clip". | |
| `accessoryJepitBungaDesc` | Always in bloom, never needs water. | Цветёт всегда, поливать не нужно. | Shop description of the accessory "Flower Clip". | |
| `accessoryBandana` | Bandana | Бандана | Name of the accessory "Bandana". | |
| `accessoryBandanaDesc` | Cowboy style, suburban edition. | Ковбойский стиль, спальный район. | Shop description of the accessory "Bandana". | |
| `accessoryDasiKupu` | Bow Tie | Галстук-бабочка | Name of the accessory "Bow Tie". | |
| `accessoryDasiKupuDesc` | Ready for the party, no invitation. | Готов к торжеству, приглашения нет. | Shop description of the accessory "Bow Tie". | |
| `accessoryKalung` | Bell Collar | Ошейник с бубенчиком | Name of the accessory "Bell Collar". | |
| `accessoryKalungDesc` | Jingle jingle. Busted on every fish heist. | Звяк-звяк. Попался на каждой краже рыбы. | Shop description of the accessory "Bell Collar". | |
| `accessorySyal` | Knit Scarf | Вязаный шарф | Name of the accessory "Knit Scarf". | |
| `accessorySyalDesc` | Warm. Knitted by an imaginary grandma. | Тёплый. Связан воображаемой бабушкой. | Shop description of the accessory "Knit Scarf". | |
| `accessoryBeanie` | Beanie | Шапка-бини | Name of the accessory "Beanie". | |
| `accessoryBeanieDesc` | Warm. Even though it's hot outside. | Тепло. Хотя на улице жара. | Shop description of the accessory "Beanie". | |
| `accessoryTopiKoki` | Chef Hat | Колпак шефа | Name of the accessory "Chef Hat". | |
| `accessoryTopiKokiDesc` | Cooking? No. Tasting? Always. | Готовить? Нет. Пробовать? Всегда. | Shop description of the accessory "Chef Hat". | |
| `accessoryBaret` | Beret | Берет | Name of the accessory "Beret". | |
| `accessoryBaretDesc` | Instant artist. Masterpiece: a torn pillow. | Внезапно художник. Шедевр — порванная подушка. | Shop description of the accessory "Beret". | |
| `accessoryKacamata` | Round Glasses | Круглые очки | Name of the accessory "Round Glasses". | |
| `accessoryKacamataDesc` | Looks smart. Still knocks the vase over. | Вид умный. Вазу всё равно уронит. | Shop description of the accessory "Round Glasses". | |
| `accessoryHeadphone` | Headphones | Наушники | Name of the accessory "Headphones". | |
| `accessoryHeadphoneDesc` | Lo-fi on, pretending to be busy. | Слушает лоу-фай, делает вид, что занят. | Shop description of the accessory "Headphones". | |
| `accessoryTandukRusa` | Reindeer Antlers | Рога оленя | Name of the accessory "Reindeer Antlers". | |
| `accessoryTandukRusaDesc` | A pretend reindeer. Still meows. | Олень ненастоящий. Мяукает по-прежнему. | Shop description of the accessory "Reindeer Antlers". | |
| `accessoryTopiPesta` | Party Hat | Праздничный колпак | Name of the accessory "Party Hat". | |
| `accessoryTopiPestaDesc` | Every day is a birthday when you're a cat. | Если ты кот, каждый день — день рождения. | Shop description of the accessory "Party Hat". | |
| `accessoryTopiPenyihir` | Wizard Hat | Шляпа волшебника | Name of the accessory "Wizard Hat". | |
| `accessoryTopiPenyihirDesc` | Can make fish appear. Allegedly. | Умеет доставать рыбу. Говорят. | Shop description of the accessory "Wizard Hat". | |
| `accessoryMahkota` | Flower Crown | Венок из цветов | Name of the accessory "Flower Crown". | |
| `accessoryMahkotaDesc` | Queen of the room. Don't eat the flowers. | Королева комнаты. Цветы не есть. | Shop description of the accessory "Flower Crown". | |
| `accessoryMahkotaRaja` | King's Crown | Королевская корона | Name of the accessory "King's Crown". | |
| `accessoryMahkotaRajaDesc` | King of the room. Taxes paid in head scratches. | Король комнаты. Налоги платят поглаживаниями. | Shop description of the accessory "King's Crown". | |
| `snackIkanAsin` | Salted Fish | Солёная рыба | Name of the snack "Salted Fish". | |
| `snackIkanAsinDesc` | Salty, savory, the neighbors can smell it. | Солёная, вкусная, запах слышен соседям. | Shop description of the snack "Salted Fish". | |
| `snackSusu` | Milk | Молоко | Name of the snack "Milk". | |
| `snackSusuDesc` | A small saucer. White whiskers guaranteed. | Маленькое блюдце. Усы становятся белыми. | Shop description of the snack "Milk". | |
| `snackTuna` | Canned Tuna | Тунец в банке | Name of the snack "Canned Tuna". | |
| `snackTunaDesc` | The can opening summons every cat. | Звук банки собирает всех кошек. | Shop description of the snack "Canned Tuna". | |
| `snackBiskuit` | Cat Biscuits | Кошачье печенье | Name of the snack "Cat Biscuits". | |
| `snackBiskuitDesc` | Crunchy and cheap. Not very filling. | Хрустит и дешёвое. Сытости мало. | Shop description of the snack "Cat Biscuits". | |
| `snackPuding` | Fish Pudding | Рыбный пудинг | Name of the snack "Fish Pudding". | |
| `snackPudingDesc` | Fancy. Very filling, very happy. | Шикарно. Очень сытно и очень радостно. | Shop description of the snack "Fish Pudding". | |
| `rarityCommon` | Common | Обычный | Accessory rarity badge in the shop: common. | |
| `rarityRare` | Rare | Редкий | Accessory rarity badge in the shop: rare. | |
| `raritySpecial` | Special | Особый | Accessory rarity badge in the shop: special. | |
| `shop` | Shop | Магазин | Shop screen title, and the menu button that opens it. | |
| `shopTabItems` | Items | Вещи | Shop tab: room items. | |
| `shopTabKitties` | Cats | Коты | Shop tab: collection cats. | |
| `shopTabAccessories` | Accessories | Аксессуары | Shop tab: accessories. | |
| `shopTabSnacks` | Food | Еда | Shop tab: snacks. | |
| `shopKittyIntro` | Every cat shares the room with Oyen. Oyen agrees. Probably. | Все коты живут в комнате Ойена. Ойен согласен. Вроде бы. | Line above the cat cards in the shop. | |
| `shopSnackIntro` | Snacks go into your stock. Hand them out from the cat card in the room. | Лакомства идут в запас. Угощай из карточки кота в комнате. | Line above the snack cards in the shop. | |
| `shopOwnedTag` | Yours | Твоё | Shop card badge: already owned. | |
| `shopLivesHere` | Lives in the room | Живёт в комнате | Shop card badge: this cat already lives in the room. | |
| `shopNotEnoughTag` | Not enough coins | Мало монет | Shop card badge: the player cannot afford this yet. | |
| `shopShortBy` | {n, plural, one{{n} coin short} other{{n} coins short}} | {n, plural, one{Не хватает {n} монеты} few{Не хватает {n} монет} many{Не хватает {n} монет} other{Не хватает {n} монеты}} | How many coins are still missing for this cat. Placeholders: `{n}`. | |
| `shopAdopt` | Adopt · {n} | Взять · {n} | Shop cat card button: adopt for this many coins. Placeholders: `{n}`. | |
| `shopBuyShort` | Buy · {n} | Купить · {n} | Shop snack card button: buy for this many coins. Placeholders: `{n}`. | |
| `shopStock` | Stock: {n} | Запас: {n} | Shop snack card: how many are in stock. Placeholders: `{n}`. | |
| `shopTryOn` | Try on: | Примерить на: | Label before the row of cats used for the accessory preview. | |
| `shopPreviewOf` | Preview · {name} | Примерка · {name} | Accessory preview panel overline, with the cat name. Placeholders: `{name}`. | |
| `shopWearFree` | Wear · Free | Надеть · Бесплатно | Button: put the owned accessory on the previewed cat, for free. | |
| `shopRemoveFree` | Take off · Free | Снять · Бесплатно | Button: take the accessory off the previewed cat, for free. | |
| `shopPlayFirst` | Play a puzzle first, the coins will follow. | Сначала головоломка — монеты придут. | Hint under the accessory button when coins are missing. | |
| `shopWornBy` | Worn by {name} | Носит {name} | Accessory card note: which cats wear it (comma separated names). Placeholders: `{name}`. | |
| `shopFlashNice` | Looking good! | Красота! | Cheer shown after putting an accessory on a cat. | |
| `shopFlashRemoved` | Off, free of charge | Снято, бесплатно | Note shown after taking an accessory off. | |
| `shopFlashSpent` | {n, plural, one{-{n} coin} other{-{n} coins}} | {n, plural, one{-{n} монета} few{-{n} монеты} many{-{n} монет} other{-{n} монеты}} | Floating note after buying a snack: coins spent. Placeholders: `{n}`. | |
| `shopPreviewPickLabel` | Try the accessory on {name} | Примерить аксессуар на {name} | Screen reader label of a cat button in the preview row. Placeholders: `{name}`. | |
| `shopCardBuyLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}} | {name}, {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}} | Screen reader label of a shop card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopCardShortLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | {name}, {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}}, не хватает монет | Screen reader label of a shop card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopCardOwnedLabel` | {name}, already yours | {name}, уже твоё | Screen reader label of a shop card for something already owned. Placeholders: `{name}`. | |
| `shopCardLivesLabel` | {name}, already lives in the room | {name}, уже живёт в комнате | Screen reader label of a cat card for a cat already adopted. Placeholders: `{name}`. | |
| `shopSnackBuyLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}} | Купить {name} за {n, plural, one{{n} монету} few{{n} монеты} many{{n} монет} other{{n} монеты}} | Screen reader label of the snack buy button. Placeholders: `{name}`, `{n}`. | |
| `shopSnackShortLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Купить {name} за {n, plural, one{{n} монету} few{{n} монеты} many{{n} монет} other{{n} монеты}}, не хватает монет | Screen reader label of the snack buy button when coins are missing. Placeholders: `{name}`, `{n}`. | |
| `buySheetLabel` | Buy {name} | Купить {name} | Screen reader label of the buy confirmation sheet. Placeholders: `{name}`. | |
| `buySuccessOverline` | Success! | Готово! | Overline above the title after a successful purchase. | |
| `buySuccessItem` | {name} is yours! | {name} теперь твой! | Buy sheet title after buying a room item. Placeholders: `{name}`. | |
| `buySuccessItemBody` | It's in the room already. Move it around in decorate mode. | Уже стоит в комнате. Переставить можно в режиме «Украшать». | Buy sheet body after buying a room item. | |
| `buySuccessKitty` | {name} moved into the room! | {name} переехал в комнату! | Buy sheet title after adopting a cat. Placeholders: `{name}`. | |
| `buySuccessKittyBody` | Say hi in the room. Expect some fake indifference first. | Поздоровайся в комнате. Сначала сделает вид, что ему всё равно. | Buy sheet body after adopting a cat. | |
| `buySuccessAccessory` | {name} is yours forever! | {name} теперь твой навсегда! | Buy sheet title after buying an accessory. Placeholders: `{name}`. | |
| `buySuccessAccessoryBody` | Put it on {name} now, or move it to another cat any time. | Надень на {name} сейчас или переставь другому коту когда захочешь. | Buy sheet body after buying an accessory, with the previewed cat name. Placeholders: `{name}`. | |
| `buyAccessoryInfo` | Buy once, keep forever. Free to put on and take off, for every cat. | Покупаешь раз — остаётся навсегда. Надевать и снимать бесплатно, на любого кота. | Note in the accessory buy sheet before paying. | |
| `buyPay` | Buy · {n, plural, one{{n} coin} other{{n} coins}} | Купить · {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}} | Buy sheet button: pay this many coins. Placeholders: `{n}`. | |
| `buyLater` | Maybe later | Потом | Buy sheet button: close without buying. | |
| `buyAgain` | Keep shopping | Купить ещё | Buy sheet button after a purchase: back to the shop. | |
| `buySeeRoom` | See it in the room | Посмотреть в комнате | Buy sheet button after a purchase: open the room. | |
| `buyWearOn` | Wear on {name} | Надеть на {name} | Buy sheet button after buying an accessory: put it on this cat. Placeholders: `{name}`. | |
| `buyNotEnoughHelp` | Play a puzzle or watch a rewarded ad to get more coins. | Пройди головоломку или посмотри рекламу за награду, чтобы получить монеты. | Buy sheet hint when the player cannot afford the item. | |
| `kittyPose` | {pose, select, idle{sitting still} lick{licking a paw} walk1{walking} walk2{walking} sleep{curled up asleep} eat{eating from the bowl} play{batting a toy} scratch{scratching the post} happy{happy} lesu{listless} rebah{lounging} petted{being petted, purring} other{sitting still}} | {pose, select, idle{сидит спокойно} lick{облизывает лапку} walk1{идёт} walk2{идёт} sleep{спит свернувшись} eat{ест из миски} play{играет с игрушкой} scratch{точит когти о когтеточку} happy{радуется} lesu{вялый} rebah{лежит и отдыхает} petted{мурчит от поглаживаний} other{сидит спокойно}} | What a room cat is doing, for its screen reader label. Placeholders: `{pose}`. | |
| `kittyLabel` | {name} {pose} | {name} {pose} | Screen reader label of a room cat: name and what it is doing. Placeholders: `{name}`, `{pose}`. | |
| `kittyLabelAccessory` | {name} {pose}, wearing a {accessory} | {name} {pose}, в {accessory} | Screen reader label of a room cat wearing an accessory. Placeholders: `{name}`, `{pose}`, `{accessory}`. | |
| `shopSnackFullLabel` | Buy {name}, stock full | Купить {name}, запас полон | Screen reader label of the snack buy button when the stock is full. Placeholders: `{name}`. | |
| `shopStockFull` | Stock full | Запас полон | Snack card chip when the stock is at the maximum. | |
| `shopAccessoryBuyLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}} | Посмотреть {name}, {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}} | Screen reader label of an accessory card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryShortLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Посмотреть {name}, {n, plural, one{{n} монета} few{{n} монеты} many{{n} монет} other{{n} монеты}}, не хватает монет | Screen reader label of an accessory card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryOwnedLabel` | View {name}, yours | Посмотреть {name}, твоё | Screen reader label of an owned accessory card nobody wears. Placeholders: `{name}`. | |
| `shopAccessoryWornLabel` | View {name}, yours, worn by {who} | Посмотреть {name}, твоё, носит {who} | Screen reader label of an owned accessory card with the cats wearing it. Placeholders: `{name}`, `{who}`. | |
| `sadMarkHungry` | Droopy: hungry | Скис: голодный | Screen reader label of the thought bubble above a hungry room cat. | |
| `sadMarkSad` | Droopy: wants attention | Скис: мало внимания | Screen reader label of the thought bubble above a room cat that needs attention. | |
| `roomEmptyBubble` | Pretty empty in here. To the Shop! | Пустовато тут. Айда в магазин! | Speech bubble in an empty starter room, pointing the player to the shop. | |
| `roomEmptyWall` | Wall decor? | Что-то на стену? | Short label inside the empty dashed spot on the wall of a starter room. | |
| `roomEmptyWallHint` | Empty. Find wall decor in the Shop | Пусто. Найди украшение для стены в магазине | Screen reader label of the empty wall spot; tapping opens the shop. | |
| `roomEmptyFloor` | A bed, maybe? | Может, лежанку? | Short label inside the empty dashed spot on the floor of a starter room. | |
| `roomEmptyFloorHint` | Empty. Find a bed or a toy in the Shop | Пусто. Найди лежанку или игрушку в магазине | Screen reader label of the empty floor spot; tapping opens the shop. | |
| `accessories` | Accessories | Аксессуары | Room menu button that opens the accessories tab of the shop. | |
| `shopHasNew` | something new you can afford | есть что-то новое по карману | Added to a room menu button's screen reader label when something there is affordable and not owned yet. | |
| `menuButtonNew` | {label}, {note} | {label}, {note} | Screen reader label of a room menu button with a red dot. {label} is the button name, {note} is shopHasNew. Placeholders: `{label}`, `{note}`. | |
| `kittyTapHint` | {name}. Tap to see their card | {name}. Нажми, чтобы открыть карточку | Screen reader label of a cat in the room. Placeholders: `{name}`. | |
| `kittyTapHintHungry` | {name}, hungry. Tap to see their card | {name} хочет есть. Нажми, чтобы открыть карточку | Screen reader label of a hungry cat in the room. Placeholders: `{name}`. | |
| `needHunger` | Full | Сытость | Hunger bar label on a cat card (higher = fuller). | |
| `needJoy` | Happy | Радость | Happiness bar label on a cat card. | |
| `needValueLabel` | {label} {value} out of 100 | {label}: {value} из 100 | Screen reader label of a need bar. Placeholders: `{label}`, `{value}`. | |
| `needValueLow` | {label} {value} out of 100, almost empty | {label}: {value} из 100, почти на нуле | Screen reader label of a need bar that is almost empty. Placeholders: `{label}`, `{value}`. | |
| `needLowHunger` | Almost empty! That tummy is rumbling. | Почти на нуле! Живот уже урчит. | Warning under an almost empty hunger bar. | |
| `needLowJoy` | Almost empty! Pet them already. | Почти на нуле! Погладь уже. | Warning under an almost empty happiness bar. | |
| `kittyCardLabel` | {name}'s card | Карточка: {name} | Screen reader label of the cat card dialog. Placeholders: `{name}`. | |
| `kittyCardClose` | Close card | Закрыть карточку | Screen reader label of the close button on a cat card. | |
| `petAction` | Pet | Погладить | Cat card button that pets the cat. | |
| `snackPanel` | Snacks | Вкусняшки | Cat card button that opens the snack list. | |
| `snackPick` | Pick from your stock | Выбери из запасов | Heading above the snack list on a cat card. | |
| `snackGive` | Give {name}, {count} in stock | Дать: {name}, в запасе {count} | Screen reader label of a snack on a cat card. Placeholders: `{name}`, `{count}`. | |
| `snackGiveEmpty` | Give {name}, {count} in stock, all gone | Дать: {name}, в запасе {count}, закончилось | Screen reader label of a snack that ran out. Placeholders: `{name}`, `{count}`. | |
| `accessoryPanelTitle` | Yours · swap for free | Твои · меняй бесплатно | Heading above the owned accessories on a cat card. | |
| `accessoryShopLink` | Accessory shop | Магазин аксессуаров | Link on a cat card to the accessories shop (an arrow icon follows it). | |
| `accessoryRemove` | Take off | Снять | Card in the accessory list that takes the accessory off. | |
| `accessoryWornTag` | Wearing | Надето | Tag on the accessory the cat is wearing. | |
| `accessoryWearLabel` | Put {accessory} on {name} | Надеть {accessory}: {name} | Screen reader label of an accessory on a cat card. Placeholders: `{accessory}`, `{name}`. | |
| `accessoryWornLabel` | Put {accessory} on {name}, wearing it now | Надеть {accessory}: {name}, уже надето | Screen reader label of the accessory the cat is wearing. Placeholders: `{accessory}`, `{name}`. | |
| `accessoryRemoveLabel` | Take {name}'s accessory off | Снять аксессуар: {name} | Screen reader label of the take-off card. Placeholders: `{name}`. | |
| `reactionFed` | +{hunger} full | +{hunger} сытости | Floating text over a cat after a snack. Placeholders: `{hunger}`. | |
| `reactionFedJoy` | +{hunger} full, +{joy} happy | +{hunger} сытости, +{joy} радости | Floating text over a cat after a snack that also makes it happy. Placeholders: `{hunger}`, `{joy}`. | |
| `reactionJoy` | +{joy} happy | +{joy} радости | Floating text over a cat after petting. Placeholders: `{joy}`. | |
| `reactionNice` | Looking sharp! | Красота! | Floating text over a cat after putting an accessory on. | |
| `reactionRelieved` | Ahh, free! | Свобода! | Floating text over a cat after taking its accessory off. | |
| `decorate` | Decorate | Обустроить | Room button that starts decorate mode. | |
| `decorateDone` | Done | Готово | Button that ends decorate mode. | |
| `decorateHint` | Drag things to a new spot | Перетащи вещи на новое место | Chip shown while decorating. | |
| `zoneWall` | Wall area | Стена | Label of the wall area while decorating. | |
| `zoneFloor` | Floor area | Пол | Label of the floor area while decorating. | |
| `storage` | Storage | Кладовка | Title of the storage tray with owned items that are not in the room. | |
| `storageCount` | {count, plural, =1{1 item} other{{count} items}} | {count, plural, one{{count} вещь} few{{count} вещи} many{{count} вещей} other{{count} вещи}} | Number of items in storage. Placeholders: `{count}`. | |
| `storageTapHint` | Tap to place | Нажми, чтобы поставить | Hint on the storage tray. | |
| `storageEmpty` | Storage is empty. Everything's on display, Oyen is proud. | Кладовка пуста. Всё расставлено, Ойен гордится. | Storage tray when every item is in the room. | |
| `storagePlaceLabel` | Put {item} in the room | Поставить в комнату: {item} | Screen reader label of an item in storage. Placeholders: `{item}`. | |
| `storageLabel` | Item storage | Кладовка с вещами | Screen reader label of the storage tray. | |
| `storeItemAction` | Move to storage | Убрать в кладовку | Screen reader action on a room item while decorating. | |
| `decoratePraise` | Room's looking great! | Комната всё краше! | Praise shown after decorating. | |
| `decoratePraiseJoy` | +{joy} Happy for every cat | +{joy} радости всем котикам | Bonus line under the decorating praise. Placeholders: `{joy}`. | |
| `bowlRefill` | {hours, plural, one{Refills in {hours} hour} other{Refills in {hours} hours}} | {hours, plural, one{Наполнится через {hours} час} few{Наполнится через {hours} часа} many{Наполнится через {hours} часов} other{Наполнится через {hours} часа}} | Label over the empty shared food bowl in the cat room: hours until it refills. Placeholders: `{hours}`. | |
| `kittyRewardLabel` | {coins, plural, one{Collect {coins} coin from {name}} other{Collect {coins} coins from {name}}} | {coins, plural, one{{name}: забрать {coins} монету} few{{name}: забрать {coins} монеты} many{{name}: забрать {coins} монет} other{{name}: забрать {coins} монеты}} | Screen reader label of the coin bubble over a well cared-for cat; tapping collects the daily reward. Placeholders: `{coins}`, `{name}`. | |
| `reactionCoins` | {coins, plural, one{+{coins} coin} other{+{coins} coins}} | {coins, plural, one{+{coins} монета} few{+{coins} монеты} many{+{coins} монет} other{+{coins} монеты}} | Floating text over a cat after collecting its coin reward. Placeholders: `{coins}`. | |

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
