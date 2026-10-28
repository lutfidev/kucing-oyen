# Ginger Logic: Brazilian Portuguese review

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

436 lines. Generated from `lib/l10n/` by `tool/translations/make_review.py`; do not edit by hand.

| Key | English | Brazilian Portuguese | Notes | Feedback |
| --- | --- | --- | --- | --- |
| `backToHome` | Back to home | Voltar ao início | Back button to the home screen (screen reader). | |
| `backToMap` | Back to map | Voltar ao mapa | Back button to the chapter map. | |
| `close` | Close | Fechar | Close button of a sheet (screen reader). | |
| `cancel` | Cancel | Cancelar | Cancel button. | |
| `starsOf` | {stars} of {total} stars | {stars} de {total} estrelas | Screen reader: earned stars out of a total. Placeholders: `{stars}`, `{total}`. | |
| `coinsAmount` | {n, plural, one{{n} coin} other{{n} coins}} | {n, plural, one{{n} moeda} other{{n} moedas}} | An amount of coins ("120 coins"). Placeholders: `{n}`. | |
| `coinsUnit` | {n, plural, one{coin} other{coins}} | {n, plural, one{moeda} other{moedas}} | Word after a big coin number on the result screen ("+30 coins"). Placeholders: `{n}`. | |
| `notEnoughCoins` | Not enough · {n} | Moedas insuficientes · {n} | Disabled pay button: not enough coins for the price. Placeholders: `{n}`. | |
| `watchAd` | Watch an ad | Ver anúncio | Button: watch a rewarded ad. | |
| `adFailed` | The ad couldn't play. Try again later, okay? | O anúncio não rolou. Tenta de novo mais tarde, tá? | The rewarded ad failed to load or was closed early. | |
| `boardLabel` | Game board, 7 by 9 tiles | Tabuleiro de 7 por 9 quadrados | Screen reader label of the 7×9 game board. | |
| `play` | Play | Jogar | Big Play button on the home screen and the map node label. | |
| `closet` | Wardrobe | Guarda-roupa | Costume closet button and screen title. | |
| `settings` | Settings | Configurações | Settings button and screen title. | |
| `tagline` | Oyen won't listen. You do the thinking. | Oyen não obedece. Quem pensa é você. | Tagline under the logo on the home screen. | |
| `splashTagline` | Let's play! | Bora jogar! | Short line under the logo on the Android splash screen (rendered into an image, keep it very short). | |
| `starTotalUnit` | stars | estrelas | Word after the star total on the home screen ("31/60 stars"). | |
| `chapterNumber` | Chapter {n} | Capítulo {n} | Chapter number above the chapter name (shown in capitals). Placeholders: `{n}`. | |
| `chapter1Name` | Kitchen | Cozinha | Name of chapter 1 (setting: kitchen). | |
| `chapter2Name` | Living Room | Sala de Estar | Name of chapter 2 (setting: living room). | |
| `chapterTitle` | Chapter {n} – {name} | Capítulo {n} – {name} | Chapter title on chapter cards. Placeholders: `{n}`, `{name}`. | |
| `chapterDone` | Done | Concluído | Badge on a finished chapter card. | |
| `chapterLocked` | Locked | Bloqueado | Badge on a locked chapter card. | |
| `statusDone` | done | concluído | Screen reader status of a finished chapter (lowercase). | |
| `statusLocked` | locked | bloqueado | Screen reader status of a locked level or chapter (lowercase). | |
| `statusPlayNow` | play now | jogar agora | Screen reader status of the level to play now. | |
| `nodeStars` | {n, plural, one{{n} star} other{{n} stars}} | {n, plural, one{{n} estrela} other{{n} estrelas}} | Screen reader: stars earned on a level node. Placeholders: `{n}`. | |
| `levelNodeLabel` | Level {id}, {status} | Fase {id}, {status} | Screen reader label of a level node on the map. Placeholders: `{id}`, `{status}`. | |
| `bossNodeLabel` | Level {id}, boss {name}, {status} | Fase {id}, chefão {name}, {status} | Screen reader label of the boss level node. Placeholders: `{id}`, `{name}`, `{status}`. | |
| `bossTag` | Boss · {name} | Chefão · {name} | Tag above the boss level on the map. Placeholders: `{name}`. | |
| `chapterMissing` | This chapter doesn't exist. | Esse capítulo não existe. | Shown when the chapter in the link does not exist. | |
| `level1Name` | Wake Up Oyen | Acorda, Oyen | Name of level 1. | |
| `level2Name` | Round the Corner | Virando a Esquina | Name of level 2. | |
| `level3Name` | First Fish | Primeiro Peixe | Name of level 3. | |
| `level4Name` | Nearest Fish | Peixe Mais Perto | Name of level 4. | |
| `level5Name` | Two Fish | Dois Peixes | Name of level 5. | |
| `level6Name` | First Bucket | Primeiro Balde | Name of level 6. | |
| `level7Name` | Puddle | Poça | Name of level 7. | |
| `level8Name` | Fish and Bucket | Peixe e Balde | Name of level 8. | |
| `level9Name` | Tempting Fish | Peixe Tentador | Name of level 9. | |
| `level10Name` | Salted Fish Feast | Festa do Peixe Salgado | Name of level 10. This is the boss level; the name is shown after the boss prefix. | |
| `level11Name` | Coffee Table | Mesa de Centro | Name of level 11. | |
| `level12Name` | Falling Glass | Copo no Chão | Name of level 12. | |
| `level13Name` | Mom's Vase | O Vaso da Mamãe | Name of level 13. | |
| `level14Name` | Box in the Way | Caixa no Caminho | Name of level 14. | |
| `level15Name` | Squashed Box | Caixa Amassada | Name of level 15. | |
| `level16Name` | The Long Way Round | Volta Longa | Name of level 16. | |
| `level17Name` | Two Vases | Dois Vasos | Name of level 17. | |
| `level18Name` | Tight Squeeze | Aperto | Name of level 18. | |
| `level19Name` | All Together | Todos Juntos | Name of level 19. | |
| `level20Name` | Eid Day | Dia do Eid | Name of level 20. This is the boss level; the name is shown after the boss prefix. | |
| `bossLevelName` | BOSS: {name} | CHEFÃO: {name} | Full name of a boss level ("BOSS: Eid Day"). Placeholders: `{name}`. | |
| `levelTitle` | Level {id} · {name} | Fase {id} · {name} | Level number and name in the top bar and result screens. Placeholders: `{id}`, `{name}`. | |
| `rules` | Rules | Regras | Rules button in the top bar. | |
| `hint` | Hint | Dica | Hint button (screen reader). | |
| `targetItems` | {n, plural, one{use {n} item} other{use {n} items}} | {n, plural, one{use {n} item} other{use {n} itens}} | Three-star goal chip: the most items allowed. Placeholders: `{n}`. | |
| `targetLabel` | 3-star goal: {text} | Meta de 3 estrelas: {text} | Screen reader label of the three-star goal chip. Placeholders: `{text}`. | |
| `levelMissing` | This level doesn't exist. | Essa fase não existe. | Shown when the level in the link does not exist. | |
| `backToArrange` | Back to setup | Voltar à montagem | Back button while Oyen walks: return to placing items. | |
| `wakeOyen` | Wake Oyen | Acordar Oyen | Main button: start the run. | |
| `trayEmpty` | No items needed here yet. | Essa fase ainda não precisa de itens. | Tray text on levels without items. | |
| `trayLabel` | Items | Itens | Vertical label of the item tray (shown in capitals). | |
| `clearBoard` | Clear the board | Limpar o tabuleiro | Button: return all placed items to the tray. | |
| `trayHintTop` | Drop on a | Solte num | Tray hint, first line: "Place on a / glowing tile". | |
| `trayHintBottom` | glowing tile | quadrado aceso | Tray hint, second line. | |
| `itemFish` | Salted fish | Peixe salgado | Item name: salted fish. | |
| `itemWater` | Water bucket | Balde de água | Item name: water bucket. | |
| `itemBox` | Box | Caixa | Item name: cardboard box. | |
| `traySlotLabel` | {name}, {n} left | {name}, {n, plural, one{resta {n}} other{restam {n}}} | Screen reader label of a tray slot. Placeholders: `{name}`, `{n}`. | |
| `traySlotDragging` | {name}, dragging, {n} left | {name}, arrastando, {n, plural, one{resta {n}} other{restam {n}}} | Screen reader label of a tray slot while dragging. Placeholders: `{name}`, `{n}`. | |
| `traySlotSelectHint` | pick it up | pegar este item | Screen reader hint for a tray slot: what a double tap does ("Double tap to ..."). | |
| `traySlotUnselectHint` | cancel | cancelar | Screen reader hint for a picked-up tray slot or board item: double tap cancels the pick (the item stays where it is). | |
| `tileLabel` | Row {row}, column {col}: {content} | Linha {row}, coluna {col}: {content} | Screen reader label of one board tile: row and column (from 1, top left) and what is on it. Placeholders: `{row}`, `{col}`, `{content}`. | |
| `cellWall` | wall | parede | Board tile content for screen readers: wall. | |
| `cellFloor` | floor | chão | Board tile content for screen readers: empty floor. | |
| `cellBowl` | Oyen's bowl | tigela do Oyen | Board tile content for screen readers: Oyen's food bowl (the goal). | |
| `cellTable` | table | mesa | Board tile content for screen readers: table. | |
| `cellTableGlass` | table with a glass | mesa com um copo | Board tile content for screen readers: table with a glass Oyen can knock off. | |
| `cellTableVase` | table with a vase | mesa com um vaso | Board tile content for screen readers: table with Mom's vase. | |
| `cellFish` | salted fish | peixe salgado | Board tile content for screen readers: salted fish that is part of the level. | |
| `cellWater` | puddle | poça d'água | Board tile content for screen readers: water puddle that is part of the level. | |
| `cellBox` | box | caixa | Board tile content for screen readers: box that is part of the level. | |
| `tileOyen` | Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Oyen dormindo, virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}} | Board tile content for screen readers: sleeping Oyen and the screen direction he faces. Placeholders: `{dir}`. | |
| `tilePlayerItem` | {item}, placed by you | {item}, foi você que colocou | Board tile content for screen readers: an item the player put there (item name first). Placeholders: `{item}`. | |
| `tileHintSpot` | {content}. Hint: something has to go here. | {content}. Dica: algo tem que ir aqui. | Board tile label suffix for screen readers: a tier 1 hint marks this tile (something must go here, type not revealed). Placeholders: `{content}`. | |
| `tileHintItem` | {content}. Hint: {item} goes here. | {content}. Dica: {item} vai aqui. | Board tile label suffix for screen readers: a tier 2-3 hint shows which item goes on this tile. Placeholders: `{content}`, `{item}`. | |
| `tilePlaceHint` | put it here | colocar aqui | Screen reader hint for an empty tile while an item is picked up ("Double tap to ..."). | |
| `tilePickHint` | pick it up to move it | pegar para mudar de lugar | Screen reader hint for a board item the player placed ("Double tap to ..."). | |
| `tileReturn` | Back to the tray | Devolver aos itens | Screen reader custom action on a placed item: put it back in the tray. | |
| `itemPickedAnnounce` | {item} picked up. Choose an empty floor tile to put it on. | {item} na mão. Escolha um quadrado de chão vazio pra colocar. | Screen reader announcement after picking up an item without dragging. Placeholders: `{item}`. | |
| `itemPlacedAnnounce` | {item} placed at row {row}, column {col}. | Pronto: {item} na linha {row}, coluna {col}. | Screen reader announcement after an item is put on the board without dragging. Placeholders: `{item}`, `{row}`, `{col}`. | |
| `itemReturnedAnnounce` | {item} is back in the tray. | {item} voltou para os itens. | Screen reader announcement after a placed item goes back to the tray. Placeholders: `{item}`. | |
| `step` | Step | Passo | Step counter label (also above the number chip). | |
| `stepNumber` | Step {n} | Passo {n} | Step number ("Step 4"). Placeholders: `{n}`. | |
| `vaseBroken` | Vase broken | Vaso quebrado | Status chip: the vase broke. | |
| `vaseSafe` | Vase safe | Vaso inteiro | Status chip: the vase is fine. | |
| `itemsUsed` | {n, plural, one{{n} item used} other{{n} items used}} | {n, plural, one{{n} item usado} other{{n} itens usados}} | Status chip: number of items used. Placeholders: `{n}`. | |
| `pause` | Pause | Pausar | Play/pause button while running. | |
| `resume` | Resume | Continuar | Play/pause button while paused. | |
| `stepForward` | One step forward | Avançar um passo | Button: one step forward. | |
| `stepBack` | One step back | Voltar um passo | Button: one step back (replay). | |
| `doubleSpeed` | Double speed | Velocidade dupla | Toggle: play twice as fast. | |
| `seeResult` | See results | Ver resultado | Button after the run: open the result screen. | |
| `runWake` | Oyen wakes up, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Oyen acorda, virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Run caption, step 0. Placeholders: `{dir}`. | |
| `runAtBowl` | Made it to the bowl! Nom nom. | Chegou na tigela! Nham nham. | Run caption: reached the bowl. | |
| `chaseFish` | Chasing the fish {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Correndo atrás do peixe para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Run and replay caption: chasing a fish. Placeholders: `{dir}`. | |
| `runSmellFish` | Hey, salted fish {dir, select, up{up there} right{to the right} down{down there} left{to the left} other{to the right}}! | Opa, cheiro de peixe salgado {dir, select, up{lá em cima} right{à direita} down{lá embaixo} left{à esquerda} other{à direita}}! | Run caption: a fish comes into sight. Placeholders: `{dir}`. | |
| `runWalk` | Strolling {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}, no rush. | Andando reto para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}, de boa. | Run caption: walking straight. Placeholders: `{dir}`. | |
| `runScared` | Water! Oyen jumps and turns back. | Água! Oyen se assusta e dá meia-volta. | Run caption: water ahead. | |
| `runTurn` | Hit {obstacle, select, table{a table} wall{a wall} other{a wall}}. Turned, now facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Bateu {obstacle, select, table{na mesa} wall{na parede} other{na parede}}. Girou, agora virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Run caption: blocked by a table or wall, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `runEat` | Chomp! The salted fish is gone. | Nhac! Lá se foi o peixe salgado. | Run caption: eats a fish. | |
| `runEnterBox` | A box! Oyen climbs in and sits. | Uma caixa! Oyen entra e senta. | Run caption: gets into a box. | |
| `runSit` | Sitting pretty in the box. | Sentadinho dentro da caixa. | Run caption: still sitting in the box. | |
| `runBoxGone` | The box gets squashed, then vanishes. | A caixa amassa e some. | Run caption: the box is squashed and disappears. | |
| `runKnockGlass` | The glass gets pushed off. Lucky it's plastic! | Empurrou o copo. Ainda bem que é de plástico! | Run caption: pushes a glass off a table. | |
| `runKnockVase` | Uh-oh! Mom's vase falls and breaks. | Ih! O vaso da Mamãe caiu e quebrou. | Run caption: pushes the vase off and it breaks. | |
| `replayAsleep` | Start: Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Início: Oyen dormindo, virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Replay caption, step 0. Placeholders: `{dir}`. | |
| `replayFinished` | Into the bowl. Done in {n, plural, one{{n} step} other{{n} steps}}. | Na tigela. Pronto em {n, plural, one{{n} passo} other{{n} passos}}. | Replay caption: reached the bowl after n steps. Placeholders: `{n}`. | |
| `replayChaseVaseSafe` | Chasing the fish. Vase still safe. | Atrás do peixe. Vaso ainda inteiro. | Replay caption: chasing a fish, vase still fine. | |
| `replaySeeFish` | Salted fish in sight, straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Peixe salgado à vista, reto {dir, select, up{para cima} right{à direita} down{para baixo} left{à esquerda} other{à direita}}. | Replay caption: a fish in a straight line. Placeholders: `{dir}`. | |
| `replayWalk` | Walks straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Anda reto para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Replay caption: walking straight. Placeholders: `{dir}`. | |
| `replayScared` | Meets {water, select, puddle{a puddle} bucket{a water bucket} other{water}}, jumps, turns back. | Encontra {water, select, puddle{uma poça} bucket{um balde de água} other{água}}, se assusta, meia-volta. | Replay caption: water ahead (puddle or bucket), turned back. Placeholders: `{water}`. | |
| `replayTurn` | Hits {obstacle, select, table{a table} wall{a wall} other{a wall}}, turns to face {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Bate {obstacle, select, table{na mesa} wall{na parede} other{na parede}}, gira e fica virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}}. | Replay caption: blocked, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `replayEat` | Chomp! Salted fish eaten. | Nhac! Peixe salgado comido. | Replay caption: eats a fish. | |
| `replayEnterBox` | Into the box, time to sit. | Entra na caixa e senta. | Replay caption: gets into a box. | |
| `replaySit` | Still sitting in the box. | Ainda sentado na caixa. | Replay caption: still in the box. | |
| `replayBoxGone` | The box is squashed and gone. | A caixa amassou e sumiu. | Replay caption: the box is gone. | |
| `replayKnockGlass` | Glass pushed off. No harm, it's plastic. | Copo derrubado. Tranquilo, é de plástico. | Replay caption: glass pushed off. | |
| `replayKnockVase` | Mom's vase pushed off. Smash! | Vaso da Mamãe derrubado. Quebrou! | Replay caption: vase pushed off. | |
| `replayLoopStart` | Back to how it started. Oyen keeps circling and gets bored. | De volta ao começo. Oyen fica rodando e se cansa. | Replay caption, last step: same state as the start. | |
| `replayLoopStep` | Back to how step {n} looked. Oyen keeps circling and gets bored. | Igual ao passo {n}. Oyen fica rodando e se cansa. | Replay caption, last step: same state as step n. Placeholders: `{n}`. | |
| `replayTooManySteps` | Step {n} and still no bowl. Oyen is bored. | Passo {n} e nada da tigela. Oyen cansou. | Replay caption, last step: hit the step limit. Placeholders: `{n}`. | |
| `closeRules` | Close rules | Fechar regras | Screen reader: close the rules sheet. | |
| `rulesTitle` | Oyen's Rules | Regras do Oyen | Rules sheet title. | |
| `rulesIntro` | Each step is checked from the top. The first rule that fits is what Oyen does. | Cada passo é checado de cima para baixo. A primeira regra que servir é o que o Oyen faz. | Rules sheet intro. | |
| `ruleKnockTitle` | Knock over what's next door | Derruba o que estiver do lado | Rule card: knock things off the table next to Oyen. | |
| `ruleKnockBody` | A glass or vase on the table next door? It gets bumped. Always. | Copo ou vaso na mesa do lado? Vai pro chão. Sempre. | Rule card body: knock. | |
| `ruleFishTitle` | Chase the nearest fish | Persegue o peixe mais perto | Rule card: chase the nearest fish. | |
| `ruleFishBody` | Only fish in a straight line. If tied: | Só os que estão em linha reta. Se empatar: | Rule card body: fish, before the tie order. | |
| `tieAhead` | ahead | frente | Tie order word 1 (followed by an arrow). | |
| `tieClockwise` | clockwise | sentido horário | Tie order word 2: clockwise (never "right"). | |
| `tieCounterClockwise` | counterclockwise | anti-horário | Tie order word 3: counterclockwise (never "left"). | |
| `tieBehind` | behind | trás | Tie order word 4. | |
| `tieOrderLabel` | Tie order: ahead, clockwise, counterclockwise, behind. | Ordem de desempate: frente, sentido horário, anti-horário, trás. | Screen reader text of the tie order. | |
| `ruleWaterTitle` | Water? Turn back | Água? Meia-volta | Rule card: water, turn back. | |
| `ruleWaterBody` | Puddle or bucket ahead? Oyen gets spooked and turns around. | Deu de cara com poça ou balde? Oyen leva um susto e dá meia-volta. | Rule card body: water. | |
| `ruleWallTitle` | Blocked by a wall or table | Bateu na parede ou na mesa | Rule card: blocked by a wall or table. | |
| `ruleWallTurn` | Oyen turns clockwise | Oyen gira no sentido horário | Rule card: turns clockwise (never "turns right"). | |
| `ruleWallBody` | A quarter turn, then off again. | Um quarto de volta e segue em frente. | Rule card body: wall. | |
| `ruleBoxTitle` | Box? Hop in, sit | Caixa? Entra e senta | Rule card: box, get in and sit. | |
| `ruleBoxBody` | Sits 2 steps until the box gets squashed and vanishes. Fish behind a box stay hidden. | Fica 2 passos sentado até a caixa amassar e sumir. Peixe atrás de caixa não aparece. | Rule card body: box. | |
| `ruleKnockLocked` | Things on tables | Coisas na mesa | Locked rule card name: knock. | |
| `ruleFishLocked` | Fish | Peixe | Locked rule card name: fish. | |
| `ruleWaterLocked` | Water | Água | Locked rule card name: water. | |
| `ruleWallLocked` | Wall | Parede | Locked rule card name: wall. | |
| `ruleBoxLocked` | Box | Caixa | Locked rule card name: box. | |
| `ruleLockedTitle` | {name}: ??? | {name}: ??? | Locked rule card title. Placeholders: `{name}`. | |
| `ruleLockedBody` | Not learned yet. You'll meet it soon. | Ainda não aprendida. Logo vocês se conhecem. | Locked rule card body. | |
| `ruleLabel` | Rule {n} | Regra {n} | Screen reader label of rule card n. Placeholders: `{n}`. | |
| `ruleLockedLabel` | Rule {n}, locked, not learned yet | Regra {n}, bloqueada, ainda não aprendida | Screen reader label of a locked rule card. Placeholders: `{n}`. | |
| `closeHints` | Close hints | Fechar dicas | Screen reader: close the hint sheet. | |
| `hintsTitle` | Hints | Dicas | Hint sheet title. | |
| `hintsIntro` | Go slow. Maybe all you need is a little nudge. | Vai com calma. Talvez você só precise de um empurrãozinho. | Hint sheet intro. | |
| `hintTier1Title` | Highlight the first tile | Destacar o primeiro quadrado | Hint tier 1 title. | |
| `hintTier2Title` | Show the item type | Mostrar o tipo de item | Hint tier 2 title. | |
| `hintTier3Title` | Show the full solution | Mostrar a solução completa | Hint tier 3 title. | |
| `hintOpened` | Unlocked | Liberada | Hint tier status: already unlocked. | |
| `hintTier` | Tier {n} | Nível {n} | Hint tier status: ready to unlock. Placeholders: `{n}`. | |
| `hintUnlockFirst` | Unlock tier {n} first | Libere o nível {n} antes | Hint tier status: unlock the previous tier first. Placeholders: `{n}`. | |
| `noItemsHint` | No items needed here. Just wake Oyen up! | Essa fase não precisa de itens. É só acordar o Oyen! | Hint sheet card on levels without items. | |
| `hintTier1Text` | See the glowing tile? Something needs to go there. | Viu o quadrado aceso? Tem um item que precisa ir ali. | Unlocked hint tier 1. | |
| `hintPlaceFish` | Put a salted fish on the glowing tile. Oyen will chase it and eat it. | Coloque um peixe salgado no quadrado aceso. Oyen vai correr atrás e comer. | Unlocked hint tier 2: salted fish. | |
| `hintPlaceWater` | Put a water bucket on the glowing tile. Oyen will get spooked and turn around. | Coloque um balde de água no quadrado aceso. Oyen vai se assustar e dar meia-volta. | Unlocked hint tier 2: water bucket. | |
| `hintPlaceBox` | Put a box on the glowing tile. Oyen will climb in and sit there. | Coloque uma caixa no quadrado aceso. Oyen vai entrar e sentar lá. | Unlocked hint tier 2: box. | |
| `hintFishCount` | {count, select, one{a salted fish} two{two salted fish} three{three salted fish} other{{n} salted fish}} | {count, select, one{um peixe salgado} two{dois peixes salgados} three{três peixes salgados} other{{n} peixes salgados}} | Hint tier 3 list part (count = one/two/three/other, n = number): n salted fish. Placeholders: `{count}`, `{n}`. | |
| `hintWaterCount` | {count, select, one{a water bucket} two{two water buckets} three{three water buckets} other{{n} water buckets}} | {count, select, one{um balde de água} two{dois baldes de água} three{três baldes de água} other{{n} baldes de água}} | Hint tier 3 list part (count = one/two/three/other, n = number): n water buckets. Placeholders: `{count}`, `{n}`. | |
| `hintBoxCount` | {count, select, one{a box} two{two boxes} three{three boxes} other{{n} boxes}} | {count, select, one{uma caixa} two{duas caixas} three{três caixas} other{{n} caixas}} | Hint tier 3 list part (count = one/two/three/other, n = number): n boxes. Placeholders: `{count}`, `{n}`. | |
| `listPair` | {a} and {b} | {a} e {b} | Joins two list parts. Placeholders: `{a}`, `{b}`. | |
| `listLast` | {rest}, and {last} | {rest} e {last} | Joins the comma-separated start of a list with its last part. Placeholders: `{rest}`, `{last}`. | |
| `hintSolution` | {items} on the glowing {count, plural, one{tile} other{tiles}}. {tail} | {items} {count, plural, one{no quadrado aceso} other{nos quadrados acesos}}. {tail} | Unlocked hint tier 3 (first letter is capitalized in code); count = number of items. Placeholders: `{items}`, `{count}`, `{tail}`. | |
| `hintSolutionVaseSafe` | Vase safe, 3 stars. | Vaso inteiro, 3 estrelas. | Tier 3 ending on levels with a vase. | |
| `hintSolutionStars` | 3 stars! | 3 estrelas! | Tier 3 ending on levels without a vase. | |
| `tutorial1Title` | You can't boss Oyen around. Just wake the cat up! | Ninguém manda no Oyen. É só acordar o gato! | Tutorial level 1, big text. | |
| `tutorial1Body` | Oyen walks to the bowl alone. You just watch. | Ele vai sozinho até a tigela. Você só assiste. | Tutorial level 1, small text. | |
| `tutorial3Title` | Oyen can't resist salted fish! | Oyen não resiste a peixe salgado! | Tutorial level 3 (fish), big text. | |
| `tutorial3Body` | Drag a fish onto the floor. If Oyen sees it in a straight line, the chase is on. | Arraste o peixe para o chão. Se estiver em linha reta, ele sai correndo atrás. | Tutorial level 3, small text. | |
| `tutorial6Title` | Oyen hates water. Like, really. | Oyen morre de medo de água. | Tutorial level 6 (bucket), big text. | |
| `tutorial6Body` | Put the bucket in the way. Water ahead means a spooked cat and a U-turn. | Coloque o balde no caminho. Deu de cara com água, ele se assusta e dá meia-volta. | Tutorial level 6, small text. | |
| `tutorialLabel` | Tutorial | Tutorial | Screen reader label of the tutorial card. | |
| `skipTutorial` | Skip tutorial | Pular tutorial | Screen reader label of the Skip button. | |
| `skip` | Skip | Pular | Skip button of the tutorial. | |
| `success` | Nailed it! | Conseguiu! | Success screen headline. | |
| `stepsUnit` | {n, plural, one{step} other{steps}} | {n, plural, one{passo} other{passos}} | Word under a step count ("6 steps"). Placeholders: `{n}`. | |
| `itemsUsedUnit` | {n, plural, one{item used} other{items used}} | {n, plural, one{item usado} other{itens usados}} | Words under an item count ("2 items used"). Placeholders: `{n}`. | |
| `goalBowl` | Reached the bowl | Chegou à tigela | Star rule 1. | |
| `goalVase` | Mom's vase is safe | Vaso da Mamãe inteiro | Star rule 2. | |
| `goalItems` | Fewest items | Menos itens | Star rule 3. | |
| `goalNotYet` | Not yet | Ainda não | Star rule status: not earned. | |
| `goalGot` | Got it | Feito | Star rule status: earned (vase screen). | |
| `goalAchieved` | done | conseguido | Screen reader: star rule earned (check mark). | |
| `restart` | Restart | Recomeçar | Button: restart with an empty board. | |
| `next` | Next | Próxima | Button: next level. | |
| `watchReplay` | Watch the replay | Ver o replay | Link on the success screen. | |
| `vaseHeadlineTop` | Made it... | Chegou... | Vase screen headline, line 1. | |
| `vaseHeadlineBottom` | but Mom's vase? | mas e o vaso da Mamãe? | Vase screen headline, line 2. | |
| `brokenAtStep` | Broke on step {n} | Quebrou no passo {n} | Vase screen: the step the vase broke. Placeholders: `{n}`. | |
| `tryAgain` | Try Again | Tentar de Novo | Vase screen button: arrange again. | |
| `nextAnyway` | Next Anyway | Seguir Assim | Vase screen button: next level anyway. | |
| `vaseArtLabel` | The vase lies broken behind Oyen, and Mom pops in at the door, annoyed | O vaso quebrado atrás do Oyen, e a Mamãe aparece na porta, brava | Screen reader label of the vase screen picture. | |
| `loopTitle` | Oyen got bored going in circles. | Oyen cansou de andar em círculos. | Fail screen title: going in circles. | |
| `loopBadge` | Going in circles | Em círculos | Fail screen chip: going in circles. | |
| `loopMessage` | Round and round, no bowl in sight. Oh well, back to sleep. | Dá voltas e voltas e nada da tigela. Ah, bora dormir de novo. | Fail screen message: going in circles. | |
| `tooLongTitle` | Oyen got tired of walking. | Oyen cansou de tanto andar. | Fail screen title: walked too long. | |
| `tooLongBadge` | Over {n} steps | Mais de {n} passos | Fail screen chip: over the step limit. Placeholders: `{n}`. | |
| `tooLongMessage` | {n} steps and still no bowl. Ugh, so tired. Back to sleep. | {n} passos e nada da tigela. Cansei. Bora dormir. | Fail screen message: over the step limit. Placeholders: `{n}`. | |
| `failedKicker` | Level {id} · Failed | Fase {id} · Falhou | Fail screen line above the title. Placeholders: `{id}`. | |
| `replay` | Replay | Replay | Replay button and replay screen title. | |
| `arrangeAgain` | Rearrange | Reorganizar | Fail screen button: back to arranging. | |
| `replayStart` | Start | Início | Replay: label of step 0. | |
| `replayPlay` | Autoplay | Reprodução automática | Replay: button that plays the steps by itself (screen reader label; the pause state uses "pause"). | |
| `backToResult` | Back to results | Voltar ao resultado | Replay: back to the result screen. | |
| `recording` | Recording | Gravação | Replay: chip next to the title. | |
| `replayStepCaption` | Step {n}. {text} | Passo {n}. {text} | Replay: screen reader caption of step n. Placeholders: `{n}`, `{text}`. | |
| `timeline` | Time | Tempo | Replay: label of the time slider (shown in capitals). | |
| `oyenLabel` | Oyen {pose, select, idle{standing} walk{walking} sleep{asleep} shock{startled} box{sitting in a box} knock{knocking something over} eat{eating} happy{happy} other{standing}}, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Oyen {pose, select, idle{parado} walk{andando} sleep{dormindo} shock{assustado} box{sentado na caixa} knock{derrubando algo} eat{comendo} happy{feliz} other{parado}}, virado para {dir, select, up{cima} right{a direita} down{baixo} left{a esquerda} other{a direita}} | Screen reader label of Oyen: pose and facing (screen direction). Placeholders: `{pose}`, `{dir}`. | |
| `costumeNone` | Plain | Básico | Costume: none. | |
| `costumePeci` | Peci Cap | Peci | Costume: peci (Indonesian cap). | |
| `costumeSarung` | Sarong | Sarongue | Costume: sarong. | |
| `costumeKoki` | Chef Hat | Chapéu de Chef | Costume: chef hat. | |
| `costumeKacamata` | Glasses | Óculos | Costume: glasses. | |
| `costumeWearingTag` | Wearing | Usando | Costume card tag: being worn. | |
| `costumeWearingStatus` | wearing | usando | Screen reader status: being worn. | |
| `costumeOwnedTag` | Yours | Seu | Costume card tag: owned. | |
| `costumeOwnedStatus` | yours | seu | Screen reader status: owned. | |
| `costumeActionWearing` | Wearing now | Usando agora | Closet button: selected costume is worn. | |
| `costumeActionWear` | Wear | Usar | Closet button: wear the owned costume. | |
| `costumeActionBuy` | {n, plural, one{Buy · {n} coin} other{Buy · {n} coins}} | {n, plural, one{Comprar · {n} moeda} other{Comprar · {n} moedas}} | Closet button: buy for n coins. Placeholders: `{n}`. | |
| `closeCoins` | Close coins | Fechar moedas | Screen reader: close the coin sheet. | |
| `coinsTitle` | Get Coins | Mais Moedas | Coin sheet title. | |
| `coinsIntro` | Coins buy hints and outfits for Oyen. Grab the daily bonus, or watch an ad. | Moedas servem para dicas e roupas do Oyen. Pegue o bônus diário ou veja um anúncio. | Coin sheet intro. | |
| `dailyBonus` | Daily bonus | Bônus diário | Coin card title: daily bonus. | |
| `dailyBonusReady` | Once a day | Uma vez por dia | Daily bonus status: can claim. | |
| `dailyBonusTaken` | Claimed today | Já pegou hoje | Daily bonus status: already claimed. | |
| `claimCoins` | {n, plural, one{Claim {n} coin} other{Claim {n} coins}} | {n, plural, one{Pegar {n} moeda} other{Pegar {n} moedas}} | Daily bonus button. Placeholders: `{n}`. | |
| `claimTomorrow` | Back tomorrow | Volta amanhã | Daily bonus button after claiming. | |
| `adsLeftToday` | {n, plural, one{{n} left today} other{{n} left today}} | {n, plural, one{Resta {n} hoje} other{Restam {n} hoje}} | Ad card status: ads left today. Placeholders: `{n}`. | |
| `adsUsedUp` | All used up today | Acabou por hoje | Ad card status: no ads left today. | |
| `adRewardButton` | {n, plural, one{+{n} coin} other{+{n} coins}} | {n, plural, one{+{n} moeda} other{+{n} moedas}} | Ad card button: plus n coins. Placeholders: `{n}`. | |
| `adsTomorrow` | More tomorrow | Amanhã tem mais | Ad card button when used up. | |
| `coinChipAdd` | get coins | mais moedas | Screen reader: the coin chip opens the coin sheet. | |
| `coinChipBonus` | daily bonus ready | bônus diário pronto | Screen reader: the daily bonus is ready. | |
| `soundSection` | Sound | Som | Settings section: music and sound effects. | |
| `music` | Music | Música | Settings switch: background music. | |
| `soundEffects` | Sound effects | Efeitos sonoros | Settings switch: sound effects. | |
| `language` | Language | Idioma | Settings section: language. | |
| `languageSystem` | Use phone language | Idioma do celular | Language option: follow the phone language. | |
| `tutorialsSection` | Tutorials | Tutoriais | Settings section: tutorials. | |
| `replayTutorials` | Show tutorials again | Ver tutoriais de novo | Settings button: show the tutorials again. | |
| `replayTutorialsInfo` | The tutorials on levels 1, 3, and 6 show up again next time you play them. | Os tutoriais das fases 1, 3 e 6 aparecem de novo na próxima vez que você jogar. | Settings text under the tutorials button. | |
| `tutorialsBack` | Done! The tutorials are back. | Pronto! Os tutoriais voltaram. | Confirmation after pressing "show tutorials again". | |
| `progressSection` | Progress | Progresso | Settings section: progress. | |
| `resetProgress` | Reset progress | Apagar progresso | Settings button: reset progress. | |
| `resetProgressInfo` | Erase stars, coins, outfits, hints, and tutorials, then start again from level 1. | Apaga estrelas, moedas, roupas, dicas e tutoriais e recomeça na fase 1. | Settings text under the reset button. | |
| `resetConfirmTitle` | Erase all progress? | Apagar todo o progresso? | Reset confirmation title. | |
| `resetConfirmBody` | Stars, coins, outfits, hints, and tutorials will be erased. This can't be undone. Today's daily bonus and ads stay used. | Estrelas, moedas, roupas, dicas e tutoriais serão apagados. Não dá para desfazer. O bônus e os anúncios de hoje continuam contados. | Reset confirmation text. | |
| `resetConfirm` | Erase | Apagar | Reset confirmation button. | |
| `closeReset` | Close reset | Fechar apagar progresso | Screen reader: close the reset confirmation. | |
| `resetDone` | Progress erased. Fresh start! | Progresso apagado. Bora recomeçar! | Message after resetting. | |
| `privacySection` | Privacy | Privacidade | Settings section: privacy (policy link and ad consent). | |
| `privacyInfo` | Your progress stays on your phone. Ads come from Google AdMob. | Seu progresso fica no seu celular. Os anúncios vêm do Google AdMob. | Settings, Privacy card: short explanation above the buttons. | |
| `privacyPolicy` | Privacy policy | Política de privacidade | Settings, Privacy: button that opens the privacy policy in the browser. | |
| `adConsent` | Ad consent settings | Consentimento de anúncios | Settings, Privacy: button that reopens the ad consent form (only where the law requires it). | |
| `privacyLinkFailed` | Couldn't open the browser. Try again later, okay? | O navegador não abriu. Tenta de novo mais tarde, tá? | Settings, Privacy: small message when the browser could not be opened. | |
| `about` | About | Sobre | Settings section: about the game. | |
| `version` | Version {version} | Versão {version} | App version. Placeholders: `{version}`. | |
| `fontCredits` | Fonts: Fredoka and Nunito (SIL Open Font License). | Fontes: Fredoka e Nunito (SIL Open Font License). | Font credits. | |
| `soundCredits` | Sound effects: Kenney and OpenGameArt (CC0). The music was made just for Ginger Logic. | Efeitos sonoros: Kenney e OpenGameArt (CC0). A música foi feita especialmente para o Ginger Logic. | About card: credits for sound effects (CC0 sources) and the original music. | |
| `licenses` | Licenses | Licenças | Button: open the licenses page. | |
| `roomItemTikus` | Toy Mouse | Ratinho de Brinquedo | Name of the room item "Toy Mouse". | |
| `roomItemTikusDesc` | Never runs away, still gets chased. | Nunca foge, mas é sempre caçado. | Shop description of the room item "Toy Mouse". | |
| `roomItemAkuarium` | Aquarium | Aquário | Name of the room item "Aquarium". | |
| `roomItemAkuariumDesc` | All-day entertainment. The fish are a bit nervous. | Diversão o dia inteiro. Os peixes ficam meio nervosos. | Shop description of the room item "Aquarium". | |
| `roomItemRumah` | Cat House | Casinha de Gato | Name of the room item "Cat House". | |
| `roomItemRumahDesc` | Has its own house, still sleeps in the box. | Tem a própria casa e dorme na caixa. | Shop description of the room item "Cat House". | |
| `roomItemKasur` | Cushion Bed | Caminha Almofadada | Name of the room item "Cushion Bed". | |
| `roomItemKasurDesc` | Soft. Used 60% of the time, the rest is box. | Fofa. Usada 60% do tempo, o resto é caixa. | Shop description of the room item "Cushion Bed". | |
| `roomItemCatnip` | Catnip Pot | Vaso de Catnip | Name of the room item "Catnip Pot". | |
| `roomItemCatnipDesc` | One sniff and the dancing starts. | Uma cheirada e já vem a dancinha. | Shop description of the room item "Catnip Pot". | |
| `roomItemJam` | Cat Clock | Relógio de Gato | Name of the room item "Cat Clock". | |
| `roomItemJamDesc` | The tail swings every second. Hypnotic. | A cauda balança a cada segundo. Hipnótico. | Shop description of the room item "Cat Clock". | |
| `roomItemKardus` | Cozy Box | Caixa Confortável | Name of the room item "Cozy Box". | |
| `roomItemKardusDesc` | It's the box that gets picked, not what came in it. | O escolhido é a caixa, não o que vinha dentro. | Shop description of the room item "Cozy Box". | |
| `roomItemBola` | Yarn Ball | Bola de Lã | Name of the room item "Yarn Ball". | |
| `roomItemBolaDesc` | Tangled in 3 seconds. That's the feature. | Embaraçada em 3 segundos. É recurso, não defeito. | Shop description of the room item "Yarn Ball". | |
| `roomItemKarpet` | Round Rug | Tapete Redondo | Name of the room item "Round Rug". | |
| `roomItemKarpetDesc` | The official rolling-around spot. | O lugar oficial para rolar. | Shop description of the room item "Round Rug". | |
| `roomItemTiang` | Scratching Post | Arranhador | Name of the room item "Scratching Post". | |
| `roomItemTiangDesc` | So Mom's sofa survives. Hopefully. | Para o sofá da mãe sobreviver. Tomara. | Shop description of the room item "Scratching Post". | |
| `roomItemLukisan` | Fish Painting | Quadro de Peixe | Name of the room item "Fish Painting". | |
| `roomItemLukisanDesc` | Art that makes you hungry. | Arte que dá fome. | Shop description of the room item "Fish Painting". | |
| `roomItemRak` | Wall Shelf | Prateleira | Name of the room item "Wall Shelf". | |
| `roomItemRakDesc` | VIP seat for watching everyone. | Assento VIP para vigiar todo mundo. | Shop description of the room item "Wall Shelf". | |
| `roomItemPancingan` | Feather Wand | Varinha de Penas | Name of the room item "Feather Wand". | |
| `roomItemPancinganDesc` | Chases the feather, leaves its dignity behind. | Corre atrás da pena e deixa a dignidade para trás. | Shop description of the room item "Feather Wand". | |
| `roomItemLampuBulan` | Moon Lamp | Lâmpada Lua | Name of the room item "Moon Lamp". | |
| `roomItemLampuBulanDesc` | A private moon, no need to wait for night. | Uma lua particular, sem esperar a noite. | Shop description of the room item "Moon Lamp". | |
| `roomItemBantalIkan` | Fish Pillow | Almofada de Peixe | Name of the room item "Fish Pillow". | |
| `roomItemBantalIkanDesc` | Soft, and fishy only to look at. | Fofa, e com cara de peixe só na aparência. | Shop description of the room item "Fish Pillow". | |
| `roomItemMonstera` | Monstera Plant | Costela-de-Adão | Name of the room item "Monstera Plant". | |
| `roomItemMonsteraDesc` | The leaves have holes. Not Oyen's doing. This time. | As folhas têm buracos. Não foi o Oyen. Dessa vez. | Shop description of the room item "Monstera Plant". | |
| `roomItemTerowongan` | Cat Tunnel | Túnel de Gato | Name of the room item "Cat Tunnel". | |
| `roomItemTerowonganDesc` | One cat goes in, style comes out. | Entra um gato, sai com estilo. | Shop description of the room item "Cat Tunnel". | |
| `roomItemHammock` | Window Hammock | Rede de Janela | Name of the room item "Window Hammock". | |
| `roomItemHammockDesc` | Naps with a swing. Wake up and it's evening. | Soneca balançando. Acorda e já é tarde. | Shop description of the room item "Window Hammock". | |
| `roomItemSofaMini` | Mini Sofa | Sofá Mini | Name of the room item "Mini Sofa". | |
| `roomItemSofaMiniDesc` | Its own sofa, so Mom's is safe. Allegedly. | Sofá próprio, então o da mãe está seguro. Dizem. | Shop description of the room item "Mini Sofa". | |
| `roomItemJendelaBurung` | Bird Window | Janela dos Pássaros | Name of the room item "Bird Window". | |
| `roomItemJendelaBurungDesc` | 24-hour cat TV, all birds, no ads. | TV de gato 24 horas, só pássaros, sem anúncios. | Shop description of the room item "Bird Window". | |
| `roomItemMangkuk` | Food bowl | Comedouro | Name of the room item "Food bowl". | |
| `kittyOyen` | Oyen | Oyen | Name of the collection cat "Oyen". | |
| `kittyOyenDesc` | The ginger cat you wake up every level. | O gato laranja que você acorda em cada nível. | Shop description of the collection cat "Oyen". | |
| `kittySalju` | Snowy | Neve | Name of the collection cat "Snowy". | |
| `kittySaljuDesc` | Spotless white. Stays that way until it finds a box. | Branquinho. Continua assim até achar uma caixa. | Shop description of the collection cat "Snowy". | |
| `kittyTelon` | Patches | Tricolor | Name of the collection cat "Patches". | |
| `kittyTelonDesc` | Three colors, three moods a minute. | Três cores, três humores por minuto. | Shop description of the collection cat "Patches". | |
| `kittyArang` | Charcoal | Carvão | Name of the collection cat "Charcoal". | |
| `kittyArangDesc` | Deep black, yellow eyes. Expert shadow hider. | Preto profundo, olhos amarelos. Mestre em se esconder nas sombras. | Shop description of the collection cat "Charcoal". | |
| `kittyMendung` | Cloudy | Nublado | Name of the collection cat "Cloudy". | |
| `kittyMendungDesc` | Looks sad, is just sleepy. | Parece triste, só está com sono. | Shop description of the collection cat "Cloudy". | |
| `kittyKopiSusu` | Latte | Latte | Name of the collection cat "Latte". | |
| `kittyKopiSusuDesc` | Sweet, a little bitter when woken up. | Doce, meio amargo quando acordado. | Shop description of the collection cat "Latte". | |
| `kittyMochi` | Mochi | Mochi | Name of the collection cat "Mochi". | |
| `kittyMochiDesc` | Calm, squishy, face like it played in mud. | Calmo, fofinho, cara de quem brincou na lama. | Shop description of the collection cat "Mochi". | |
| `kittyBos` | Boss | Chefe | Name of the collection cat "Boss". | |
| `kittyBosDesc` | Always in a suit. Meetings at every mealtime. | Sempre de terno. Reunião em toda hora de comer. | Shop description of the collection cat "Boss". | |
| `kittyKembang` | Blossom | Florzinha | Name of the collection cat "Blossom". | |
| `kittyKembangDesc` | Abstract markings, abstract behavior. | Manchas abstratas, comportamento também. | Shop description of the collection cat "Blossom". | |
| `accessoryPita` | Ribbon | Fitinha | Name of the accessory "Ribbon". | |
| `accessoryPitaDesc` | Simple, sweet, easy to put on. | Simples, fofa, fácil de colocar. | Shop description of the accessory "Ribbon". | |
| `accessoryJepitBunga` | Flower Clip | Presilha de Flor | Name of the accessory "Flower Clip". | |
| `accessoryJepitBungaDesc` | Always in bloom, never needs water. | Sempre florida, nunca precisa de água. | Shop description of the accessory "Flower Clip". | |
| `accessoryBandana` | Bandana | Bandana | Name of the accessory "Bandana". | |
| `accessoryBandanaDesc` | Cowboy style, suburban edition. | Estilo caubói de condomínio. | Shop description of the accessory "Bandana". | |
| `accessoryDasiKupu` | Bow Tie | Gravata-Borboleta | Name of the accessory "Bow Tie". | |
| `accessoryDasiKupuDesc` | Ready for the party, no invitation. | Pronto para a festa, sem convite. | Shop description of the accessory "Bow Tie". | |
| `accessoryKalung` | Bell Collar | Coleira com Sininho | Name of the accessory "Bell Collar". | |
| `accessoryKalungDesc` | Jingle jingle. Busted on every fish heist. | Tlim-tlim. Flagrado em todo roubo de peixe. | Shop description of the accessory "Bell Collar". | |
| `accessorySyal` | Knit Scarf | Cachecol de Tricô | Name of the accessory "Knit Scarf". | |
| `accessorySyalDesc` | Warm. Knitted by an imaginary grandma. | Quentinho. Tricotado por uma vovó imaginária. | Shop description of the accessory "Knit Scarf". | |
| `accessoryBeanie` | Beanie | Gorro | Name of the accessory "Beanie". | |
| `accessoryBeanieDesc` | Warm. Even though it's hot outside. | Quentinho. Mesmo com calor lá fora. | Shop description of the accessory "Beanie". | |
| `accessoryTopiKoki` | Chef Hat | Chapéu de Chef | Name of the accessory "Chef Hat". | |
| `accessoryTopiKokiDesc` | Cooking? No. Tasting? Always. | Cozinhar? Não. Provar? Sempre. | Shop description of the accessory "Chef Hat". | |
| `accessoryBaret` | Beret | Boina | Name of the accessory "Beret". | |
| `accessoryBaretDesc` | Instant artist. Masterpiece: a torn pillow. | Artista instantâneo. Obra-prima: almofada rasgada. | Shop description of the accessory "Beret". | |
| `accessoryKacamata` | Round Glasses | Óculos Redondos | Name of the accessory "Round Glasses". | |
| `accessoryKacamataDesc` | Looks smart. Still knocks the vase over. | Parece inteligente. Ainda derruba o vaso. | Shop description of the accessory "Round Glasses". | |
| `accessoryHeadphone` | Headphones | Fones de Ouvido | Name of the accessory "Headphones". | |
| `accessoryHeadphoneDesc` | Lo-fi on, pretending to be busy. | Lo-fi ligado, fingindo estar ocupado. | Shop description of the accessory "Headphones". | |
| `accessoryTandukRusa` | Reindeer Antlers | Chifres de Rena | Name of the accessory "Reindeer Antlers". | |
| `accessoryTandukRusaDesc` | A pretend reindeer. Still meows. | Rena de mentirinha. Mia do mesmo jeito. | Shop description of the accessory "Reindeer Antlers". | |
| `accessoryTopiPesta` | Party Hat | Chapéu de Festa | Name of the accessory "Party Hat". | |
| `accessoryTopiPestaDesc` | Every day is a birthday when you're a cat. | Todo dia é aniversário quando você é gato. | Shop description of the accessory "Party Hat". | |
| `accessoryTopiPenyihir` | Wizard Hat | Chapéu de Mago | Name of the accessory "Wizard Hat". | |
| `accessoryTopiPenyihirDesc` | Can make fish appear. Allegedly. | Faz peixe aparecer. Dizem. | Shop description of the accessory "Wizard Hat". | |
| `accessoryMahkota` | Flower Crown | Coroa de Flores | Name of the accessory "Flower Crown". | |
| `accessoryMahkotaDesc` | Queen of the room. Don't eat the flowers. | Rainha do quarto. Não coma as flores. | Shop description of the accessory "Flower Crown". | |
| `accessoryMahkotaRaja` | King's Crown | Coroa de Rei | Name of the accessory "King's Crown". | |
| `accessoryMahkotaRajaDesc` | King of the room. Taxes paid in head scratches. | Rei do quarto. Impostos pagos em carinho. | Shop description of the accessory "King's Crown". | |
| `snackIkanAsin` | Salted Fish | Peixe Salgado | Name of the snack "Salted Fish". | |
| `snackIkanAsinDesc` | Salty, savory, the neighbors can smell it. | Salgado, saboroso, o vizinho sente o cheiro. | Shop description of the snack "Salted Fish". | |
| `snackSusu` | Milk | Leite | Name of the snack "Milk". | |
| `snackSusuDesc` | A small saucer. White whiskers guaranteed. | Um pratinho. O bigode fica branco. | Shop description of the snack "Milk". | |
| `snackTuna` | Canned Tuna | Atum em Lata | Name of the snack "Canned Tuna". | |
| `snackTunaDesc` | The can opening summons every cat. | O som da lata chama todos os gatos. | Shop description of the snack "Canned Tuna". | |
| `snackBiskuit` | Cat Biscuits | Biscoitos de Gato | Name of the snack "Cat Biscuits". | |
| `snackBiskuitDesc` | Crunchy and cheap. Not very filling. | Crocante e barato. Enche pouco. | Shop description of the snack "Cat Biscuits". | |
| `snackPuding` | Fish Pudding | Pudim de Peixe | Name of the snack "Fish Pudding". | |
| `snackPudingDesc` | Fancy. Very filling, very happy. | Chique. Enche muito, alegra muito. | Shop description of the snack "Fish Pudding". | |
| `rarityCommon` | Common | Comum | Accessory rarity badge in the shop: common. | |
| `rarityRare` | Rare | Raro | Accessory rarity badge in the shop: rare. | |
| `raritySpecial` | Special | Especial | Accessory rarity badge in the shop: special. | |
| `shop` | Shop | Loja | Shop screen title, and the menu button that opens it. | |
| `shopTabItems` | Items | Objetos | Shop tab: room items. | |
| `shopTabKitties` | Cats | Gatos | Shop tab: collection cats. | |
| `shopTabAccessories` | Accessories | Acessórios | Shop tab: accessories. | |
| `shopTabSnacks` | Food | Comida | Shop tab: snacks. | |
| `shopKittyIntro` | Every cat shares the room with Oyen. Oyen agrees. Probably. | Todos os gatos moram no quarto do Oyen. O Oyen concorda. Acho. | Line above the cat cards in the shop. | |
| `shopSnackIntro` | Snacks go into your stock. Hand them out from the cat card in the room. | Os petiscos vão para o estoque. Entregue pela ficha do gato no quarto. | Line above the snack cards in the shop. | |
| `shopOwnedTag` | Yours | Seu | Shop card badge: already owned. | |
| `shopLivesHere` | Lives in the room | Mora no quarto | Shop card badge: this cat already lives in the room. | |
| `shopNotEnoughTag` | Not enough coins | Moedas de menos | Shop card badge: the player cannot afford this yet. | |
| `shopShortBy` | {n, plural, one{{n} coin short} other{{n} coins short}} | {n, plural, one{Falta {n} moeda} other{Faltam {n} moedas}} | How many coins are still missing for this cat. Placeholders: `{n}`. | |
| `shopAdopt` | Adopt · {n} | Adotar · {n} | Shop cat card button: adopt for this many coins. Placeholders: `{n}`. | |
| `shopBuyShort` | Buy · {n} | Comprar · {n} | Shop snack card button: buy for this many coins. Placeholders: `{n}`. | |
| `shopStock` | Stock: {n} | Estoque: {n} | Shop snack card: how many are in stock. Placeholders: `{n}`. | |
| `shopTryOn` | Try on: | Testar em: | Label before the row of cats used for the accessory preview. | |
| `shopPreviewOf` | Preview · {name} | Prévia · {name} | Accessory preview panel overline, with the cat name. Placeholders: `{name}`. | |
| `shopWearFree` | Wear · Free | Usar · Grátis | Button: put the owned accessory on the previewed cat, for free. | |
| `shopRemoveFree` | Take off · Free | Tirar · Grátis | Button: take the accessory off the previewed cat, for free. | |
| `shopPlayFirst` | Play a puzzle first, the coins will follow. | Jogue um quebra-cabeça, as moedas vêm depois. | Hint under the accessory button when coins are missing. | |
| `shopWornBy` | Worn by {name} | Usado por {name} | Accessory card note: which cats wear it (comma separated names). Placeholders: `{name}`. | |
| `shopFlashNice` | Looking good! | Ficou lindo! | Cheer shown after putting an accessory on a cat. | |
| `shopFlashRemoved` | Off, free of charge | Tirado, de graça | Note shown after taking an accessory off. | |
| `shopFlashSpent` | {n, plural, one{-{n} coin} other{-{n} coins}} | {n, plural, one{-{n} moeda} other{-{n} moedas}} | Floating note after buying a snack: coins spent. Placeholders: `{n}`. | |
| `shopPreviewPickLabel` | Try the accessory on {name} | Testar o acessório em {name} | Screen reader label of a cat button in the preview row. Placeholders: `{name}`. | |
| `shopCardBuyLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}} | {name}, {n, plural, one{{n} moeda} other{{n} moedas}} | Screen reader label of a shop card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopCardShortLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | {name}, {n, plural, one{{n} moeda} other{{n} moedas}}, moedas de menos | Screen reader label of a shop card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopCardOwnedLabel` | {name}, already yours | {name}, já é seu | Screen reader label of a shop card for something already owned. Placeholders: `{name}`. | |
| `shopCardLivesLabel` | {name}, already lives in the room | {name}, já mora no quarto | Screen reader label of a cat card for a cat already adopted. Placeholders: `{name}`. | |
| `shopSnackBuyLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}} | Comprar {name} por {n, plural, one{{n} moeda} other{{n} moedas}} | Screen reader label of the snack buy button. Placeholders: `{name}`, `{n}`. | |
| `shopSnackShortLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Comprar {name} por {n, plural, one{{n} moeda} other{{n} moedas}}, moedas de menos | Screen reader label of the snack buy button when coins are missing. Placeholders: `{name}`, `{n}`. | |
| `buySheetLabel` | Buy {name} | Comprar {name} | Screen reader label of the buy confirmation sheet. Placeholders: `{name}`. | |
| `buySuccessOverline` | Success! | Sucesso! | Overline above the title after a successful purchase. | |
| `buySuccessItem` | {name} is yours! | {name} agora é seu! | Buy sheet title after buying a room item. Placeholders: `{name}`. | |
| `buySuccessItemBody` | It's in the room already. Move it around in decorate mode. | Já está no quarto. Mude de lugar no modo Decorar. | Buy sheet body after buying a room item. | |
| `buySuccessKitty` | {name} moved into the room! | {name} se mudou para o quarto! | Buy sheet title after adopting a cat. Placeholders: `{name}`. | |
| `buySuccessKittyBody` | Say hi in the room. Expect some fake indifference first. | Diga oi no quarto. Talvez finja não ligar no começo. | Buy sheet body after adopting a cat. | |
| `buySuccessAccessory` | {name} is yours forever! | {name} é seu para sempre! | Buy sheet title after buying an accessory. Placeholders: `{name}`. | |
| `buySuccessAccessoryBody` | Put it on {name} now, or move it to another cat any time. | Coloque no {name} agora, ou passe para outro gato quando quiser. | Buy sheet body after buying an accessory, with the previewed cat name. Placeholders: `{name}`. | |
| `buyAccessoryInfo` | Buy once, keep forever. Free to put on and take off, for every cat. | Compre uma vez, é seu para sempre. Colocar e tirar é grátis, para todos os gatos. | Note in the accessory buy sheet before paying. | |
| `buyPay` | Buy · {n, plural, one{{n} coin} other{{n} coins}} | Comprar · {n, plural, one{{n} moeda} other{{n} moedas}} | Buy sheet button: pay this many coins. Placeholders: `{n}`. | |
| `buyLater` | Maybe later | Fica para depois | Buy sheet button: close without buying. | |
| `buyAgain` | Keep shopping | Continuar comprando | Buy sheet button after a purchase: back to the shop. | |
| `buySeeRoom` | See it in the room | Ver no quarto | Buy sheet button after a purchase: open the room. | |
| `buyWearOn` | Wear on {name} | Usar no {name} | Buy sheet button after buying an accessory: put it on this cat. Placeholders: `{name}`. | |
| `buyNotEnoughHelp` | Play a puzzle or watch a rewarded ad to get more coins. | Jogue um quebra-cabeça ou veja um anúncio premiado para ganhar moedas. | Buy sheet hint when the player cannot afford the item. | |
| `kittyPose` | {pose, select, idle{sitting still} lick{licking a paw} walk1{walking} walk2{walking} sleep{curled up asleep} eat{eating from the bowl} play{batting a toy} scratch{scratching the post} happy{happy} lesu{listless} rebah{lounging} petted{being petted, purring} other{sitting still}} | {pose, select, idle{sentado quietinho} lick{lambendo a patinha} walk1{andando} walk2{andando} sleep{dormindo enroladinho} eat{comendo da tigela} play{brincando com o brinquedo} scratch{arranhando o poste} happy{feliz} lesu{sem ânimo} rebah{deitado de boa} petted{recebendo carinho, ronronando} other{sentado quietinho}} | What a room cat is doing, for its screen reader label. Placeholders: `{pose}`. | |
| `kittyLabel` | {name} {pose} | {name} {pose} | Screen reader label of a room cat: name and what it is doing. Placeholders: `{name}`, `{pose}`. | |
| `kittyLabelAccessory` | {name} {pose}, wearing a {accessory} | {name} {pose}, usando {accessory} | Screen reader label of a room cat wearing an accessory. Placeholders: `{name}`, `{pose}`, `{accessory}`. | |
| `shopSnackFullLabel` | Buy {name}, stock full | Comprar {name}, estoque cheio | Screen reader label of the snack buy button when the stock is full. Placeholders: `{name}`. | |
| `shopStockFull` | Stock full | Estoque cheio | Snack card chip when the stock is at the maximum. | |
| `shopAccessoryBuyLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}} | Ver {name}, {n, plural, one{{n} moeda} other{{n} moedas}} | Screen reader label of an accessory card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryShortLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Ver {name}, {n, plural, one{{n} moeda} other{{n} moedas}}, moedas de menos | Screen reader label of an accessory card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryOwnedLabel` | View {name}, yours | Ver {name}, seu | Screen reader label of an owned accessory card nobody wears. Placeholders: `{name}`. | |
| `shopAccessoryWornLabel` | View {name}, yours, worn by {who} | Ver {name}, seu, usado por {who} | Screen reader label of an owned accessory card with the cats wearing it. Placeholders: `{name}`, `{who}`. | |

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

## Store listing: Brazilian Portuguese

### Ficha da loja: Português (pt-BR)

Cole no Play Console → Ficha da loja → Adicionar tradução → Português (Brasil).

#### Nome do app (≤ 30)

```
Ginger Logic: Gato Teimoso
```

#### Descrição curta (≤ 80)

```
Um gato laranja teimoso não obedece. Use peixes e caixas pra levá-lo à tigela!
```

#### Descrição completa (≤ 4000)

```
Conheça o Oyen: um gato laranja gordinho, com cara de sono e zero vontade de obedecer.

Você não controla o Oyen. Você só arruma a casa. Coloca um peixe salgado aqui, um balde de água ali, uma caixa no canto, aperta "Acordar Oyen" e assiste. O Oyen segue sempre as mesmas regrinhas:

• Chegou na tigela? Pronto, hora do rango.
• Caixa? Entra e senta um pouquinho.
• Tem algo na mesa do lado? Derruba. Claro.
• Viu um peixe em linha reta? Corre atrás do mais perto.
• Água na frente? Nem pensar, meia-volta.
• Parede ou mesa no caminho? Gira no sentido horário e segue.

Descubra as regras, planeje o caminho e leve o Oyen até a tigela. Só cuidado com o vaso da Mamãe: se quebrar, a fase não acaba, mas lá se vão as estrelas.

O QUE TEM
• 20 quebra-cabeças feitos à mão em dois cômodos: Cozinha e Sala de Estar, cada um com uma fase chefe
• Até 3 estrelas por fase: chegar na tigela, salvar o vaso e usar o mínimo de itens
• Replay passo a passo pra ver exatamente onde o Oyen errou (ou acertou)
• Cartas de regras e tutoriais curtinhos que ensinam enquanto você joga
• Travou? Dicas revelam um quadrado por vez, pagas com moedas ou um anúncio curto opcional
• Moedas por estrelas novas, bônus diário e anúncios opcionais
• Guarda-roupa do Oyen: peci, sarongue, chapéu de chef e óculos
• Música tranquila e efeitos fofos (dá pra desligar cada um)
• Inglês, indonésio, português do Brasil e russo

SEM PRESSÃO
Sem cronômetro, sem vidas, sem energia. Jogue offline, no seu ritmo. Seu progresso fica no celular, sem precisar de conta.

O Oyen não obedece. Quem pensa é você.
```
