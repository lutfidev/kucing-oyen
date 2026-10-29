# Ginger Logic: English review

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

| Key | English | Indonesian (original) | Notes | Feedback |
| --- | --- | --- | --- | --- |
| `backToHome` | Back to home | Kembali ke Beranda | Back button to the home screen (screen reader). | |
| `backToMap` | Back to map | Kembali ke peta | Back button to the chapter map. | |
| `close` | Close | Tutup | Close button of a sheet (screen reader). | |
| `cancel` | Cancel | Batal | Cancel button. | |
| `starsOf` | {stars} of {total} stars | {stars} dari {total} bintang | Screen reader: earned stars out of a total. Placeholders: `{stars}`, `{total}`. | |
| `coinsAmount` | {n, plural, one{{n} coin} other{{n} coins}} | {n} koin | An amount of coins ("120 coins"). Placeholders: `{n}`. | |
| `coinsUnit` | {n, plural, one{coin} other{coins}} | koin | Word after a big coin number on the result screen ("+30 coins"). Placeholders: `{n}`. | |
| `notEnoughCoins` | Not enough · {n} | Koin kurang · {n} | Disabled pay button: not enough coins for the price. Placeholders: `{n}`. | |
| `watchAd` | Watch an ad | Tonton iklan | Button: watch a rewarded ad. | |
| `adFailed` | The ad couldn't play. Try again later, okay? | Iklannya belum bisa diputar. Coba lagi nanti, ya. | The rewarded ad failed to load or was closed early. | |
| `boardLabel` | Game board, 7 by 9 tiles | Papan permainan 7 kali 9 petak | Screen reader label of the 7×9 game board. | |
| `play` | Play | Main | Big Play button on the home screen and the map node label. | |
| `settings` | Settings | Pengaturan | Settings button and screen title. | |
| `tagline` | Oyen won't listen. You do the thinking. | Oyen nggak bisa disuruh. Kamu yang mikir. | Tagline under the logo on the home screen. | |
| `splashTagline` | Let's play! | Ayo main! | Short line under the logo on the Android splash screen (rendered into an image, keep it very short). | |
| `chapterNumber` | Chapter {n} | Babak {n} | Chapter number above the chapter name (shown in capitals). Placeholders: `{n}`. | |
| `chapter1Name` | Kitchen | Dapur | Name of chapter 1 (setting: kitchen). | |
| `chapter2Name` | Living Room | Ruang Tamu | Name of chapter 2 (setting: living room). | |
| `chapterTitle` | Chapter {n} – {name} | Babak {n} – {name} | Chapter title on chapter cards. Placeholders: `{n}`, `{name}`. | |
| `chapterDone` | Done | Selesai | Badge on a finished chapter card. | |
| `chapterLocked` | Locked | Terkunci | Badge on a locked chapter card. | |
| `statusDone` | done | selesai | Screen reader status of a finished chapter (lowercase). | |
| `statusLocked` | locked | terkunci | Screen reader status of a locked level or chapter (lowercase). | |
| `statusPlayNow` | play now | main sekarang | Screen reader status of the level to play now. | |
| `nodeStars` | {n, plural, one{{n} star} other{{n} stars}} | {n} bintang | Screen reader: stars earned on a level node. Placeholders: `{n}`. | |
| `levelNodeLabel` | Level {id}, {status} | Level {id}, {status} | Screen reader label of a level node on the map. Placeholders: `{id}`, `{status}`. | |
| `bossNodeLabel` | Level {id}, boss {name}, {status} | Level {id}, bos {name}, {status} | Screen reader label of the boss level node. Placeholders: `{id}`, `{name}`, `{status}`. | |
| `bossTag` | Boss · {name} | Bos · {name} | Tag above the boss level on the map. Placeholders: `{name}`. | |
| `chapterMissing` | This chapter doesn't exist. | Babak ini nggak ada. | Shown when the chapter in the link does not exist. | |
| `level1Name` | Wake Up Oyen | Bangunkan Oyen | Name of level 1. | |
| `level2Name` | Round the Corner | Belok Kanan | Name of level 2. | |
| `level3Name` | First Fish | Ikan Pertama | Name of level 3. | |
| `level4Name` | Nearest Fish | Ikan Terdekat | Name of level 4. | |
| `level5Name` | Two Fish | Dua Ikan | Name of level 5. | |
| `level6Name` | First Bucket | Ember Pertama | Name of level 6. | |
| `level7Name` | Puddle | Genangan | Name of level 7. | |
| `level8Name` | Fish and Bucket | Ikan dan Ember | Name of level 8. | |
| `level9Name` | Tempting Fish | Ikan Godaan | Name of level 9. | |
| `level10Name` | Salted Fish Feast | Pesta Ikan Asin | Name of level 10. This is the boss level; the name is shown after the boss prefix. | |
| `level11Name` | Coffee Table | Meja Tamu | Name of level 11. | |
| `level12Name` | Falling Glass | Gelas Jatuh | Name of level 12. | |
| `level13Name` | Mom's Vase | Vas Ibu | Name of level 13. | |
| `level14Name` | Box in the Way | Kardus Penghalang | Name of level 14. | |
| `level15Name` | Squashed Box | Kardus Penyok | Name of level 15. | |
| `level16Name` | The Long Way Round | Jalan Memutar | Name of level 16. | |
| `level17Name` | Two Vases | Dua Vas | Name of level 17. | |
| `level18Name` | Tight Squeeze | Ruang Sempit | Name of level 18. | |
| `level19Name` | All Together | Semua Bersama | Name of level 19. | |
| `level20Name` | Eid Day | Hari Lebaran | Name of level 20. This is the boss level; the name is shown after the boss prefix. | |
| `bossLevelName` | BOSS: {name} | BOS: {name} | Full name of a boss level ("BOSS: Eid Day"). Placeholders: `{name}`. | |
| `levelTitle` | Level {id} · {name} | Level {id} · {name} | Level number and name in the top bar and result screens. Placeholders: `{id}`, `{name}`. | |
| `rules` | Rules | Aturan | Rules button in the top bar. | |
| `hint` | Hint | Petunjuk | Hint button (screen reader). | |
| `targetItems` | {n, plural, one{use {n} item} other{use {n} items}} | pakai {n} benda | Three-star goal chip: the most items allowed. Placeholders: `{n}`. | |
| `targetLabel` | 3-star goal: {text} | Target 3 bintang: {text} | Screen reader label of the three-star goal chip. Placeholders: `{text}`. | |
| `levelMissing` | This level doesn't exist. | Level ini nggak ada. | Shown when the level in the link does not exist. | |
| `backToArrange` | Back to setup | Kembali ke fase atur | Back button while Oyen walks: return to placing items. | |
| `wakeOyen` | Wake Oyen | Bangunkan Oyen | Main button: start the run. | |
| `trayEmpty` | No items needed here yet. | Level ini belum butuh benda. | Tray text on levels without items. | |
| `trayLabel` | Items | Benda | Vertical label of the item tray (shown in capitals). | |
| `clearBoard` | Clear the board | Kosongkan papan | Button: return all placed items to the tray. | |
| `trayHintTop` | Drop on a | Taruh di petak | Tray hint, first line: "Place on a / glowing tile". | |
| `trayHintBottom` | glowing tile | yang menyala | Tray hint, second line. | |
| `itemFish` | Salted fish | Ikan asin | Item name: salted fish. | |
| `itemWater` | Water bucket | Ember air | Item name: water bucket. | |
| `itemBox` | Box | Kardus | Item name: cardboard box. | |
| `traySlotLabel` | {name}, {n} left | {name}, sisa {n} | Screen reader label of a tray slot. Placeholders: `{name}`, `{n}`. | |
| `traySlotDragging` | {name}, dragging, {n} left | {name}, sedang diseret, sisa {n} | Screen reader label of a tray slot while dragging. Placeholders: `{name}`, `{n}`. | |
| `traySlotSelectHint` | pick it up | mengambil benda ini | Screen reader hint for a tray slot: what a double tap does ("Double tap to ..."). | |
| `traySlotUnselectHint` | cancel | batal mengambil | Screen reader hint for a picked-up tray slot or board item: double tap cancels the pick (the item stays where it is). | |
| `tileLabel` | Row {row}, column {col}: {content} | Baris {row}, kolom {col}: {content} | Screen reader label of one board tile: row and column (from 1, top left) and what is on it. Placeholders: `{row}`, `{col}`, `{content}`. | |
| `cellWall` | wall | tembok | Board tile content for screen readers: wall. | |
| `cellFloor` | floor | lantai | Board tile content for screen readers: empty floor. | |
| `cellBowl` | Oyen's bowl | mangkuk Oyen | Board tile content for screen readers: Oyen's food bowl (the goal). | |
| `cellTable` | table | meja | Board tile content for screen readers: table. | |
| `cellTableGlass` | table with a glass | meja dengan gelas | Board tile content for screen readers: table with a glass Oyen can knock off. | |
| `cellTableVase` | table with a vase | meja dengan vas | Board tile content for screen readers: table with Mom's vase. | |
| `cellFish` | salted fish | ikan asin | Board tile content for screen readers: salted fish that is part of the level. | |
| `cellWater` | puddle | genangan air | Board tile content for screen readers: water puddle that is part of the level. | |
| `cellBox` | box | kardus | Board tile content for screen readers: box that is part of the level. | |
| `tileOyen` | Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Oyen tidur, menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}} | Board tile content for screen readers: sleeping Oyen and the screen direction he faces. Placeholders: `{dir}`. | |
| `tilePlayerItem` | {item}, placed by you | {item}, kamu yang taruh | Board tile content for screen readers: an item the player put there (item name first). Placeholders: `{item}`. | |
| `tileHintSpot` | {content}. Hint: something has to go here. | {content}. Petunjuk: ada benda yang harus ditaruh di sini. | Board tile label suffix for screen readers: a tier 1 hint marks this tile (something must go here, type not revealed). Placeholders: `{content}`. | |
| `tileHintItem` | {content}. Hint: {item} goes here. | {content}. Petunjuk: {item} di sini. | Board tile label suffix for screen readers: a tier 2-3 hint shows which item goes on this tile. Placeholders: `{content}`, `{item}`. | |
| `tilePlaceHint` | put it here | menaruh di sini | Screen reader hint for an empty tile while an item is picked up ("Double tap to ..."). | |
| `tilePickHint` | pick it up to move it | mengambil untuk dipindah | Screen reader hint for a board item the player placed ("Double tap to ..."). | |
| `tileReturn` | Back to the tray | Kembalikan ke baki | Screen reader custom action on a placed item: put it back in the tray. | |
| `itemPickedAnnounce` | {item} picked up. Choose an empty floor tile to put it on. | {item} diambil. Pilih petak lantai yang kosong untuk menaruhnya. | Screen reader announcement after picking up an item without dragging. Placeholders: `{item}`. | |
| `itemPlacedAnnounce` | {item} placed at row {row}, column {col}. | {item} ditaruh di baris {row}, kolom {col}. | Screen reader announcement after an item is put on the board without dragging. Placeholders: `{item}`, `{row}`, `{col}`. | |
| `itemReturnedAnnounce` | {item} is back in the tray. | {item} kembali ke baki. | Screen reader announcement after a placed item goes back to the tray. Placeholders: `{item}`. | |
| `step` | Step | Langkah | Step counter label (also above the number chip). | |
| `stepNumber` | Step {n} | Langkah {n} | Step number ("Step 4"). Placeholders: `{n}`. | |
| `vaseBroken` | Vase broken | Vas pecah | Status chip: the vase broke. | |
| `vaseSafe` | Vase safe | Vas aman | Status chip: the vase is fine. | |
| `itemsUsed` | {n, plural, one{{n} item used} other{{n} items used}} | {n} benda dipakai | Status chip: number of items used. Placeholders: `{n}`. | |
| `pause` | Pause | Jeda | Play/pause button while running. | |
| `resume` | Resume | Lanjutkan | Play/pause button while paused. | |
| `stepForward` | One step forward | Maju satu langkah | Button: one step forward. | |
| `stepBack` | One step back | Mundur satu langkah | Button: one step back (replay). | |
| `doubleSpeed` | Double speed | Percepat dua kali | Toggle: play twice as fast. | |
| `seeResult` | See results | Lihat hasil | Button after the run: open the result screen. | |
| `runWake` | Oyen wakes up, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Oyen bangun, menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Run caption, step 0. Placeholders: `{dir}`. | |
| `runAtBowl` | Made it to the bowl! Nom nom. | Sampai di mangkuk! Nyam nyam. | Run caption: reached the bowl. | |
| `chaseFish` | Chasing the fish {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Kejar ikan ke {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Run and replay caption: chasing a fish. Placeholders: `{dir}`. | |
| `runSmellFish` | Hey, salted fish {dir, select, up{up there} right{to the right} down{down there} left{to the left} other{to the right}}! | Eh, ada bau ikan asin di {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}! | Run caption: a fish comes into sight. Placeholders: `{dir}`. | |
| `runWalk` | Strolling {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}, no rush. | Jalan lurus ke {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}, santai. | Run caption: walking straight. Placeholders: `{dir}`. | |
| `runScared` | Water! Oyen jumps and turns back. | Ada air! Oyen kaget, lalu putar balik. | Run caption: water ahead. | |
| `runTurn` | Hit {obstacle, select, table{a table} wall{a wall} other{a wall}}. Turned, now facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Mentok {obstacle, select, table{meja} wall{tembok} other{tembok}}. Berputar, sekarang menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Run caption: blocked by a table or wall, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `runEat` | Chomp! The salted fish is gone. | Hap! Ikan asinnya dimakan. | Run caption: eats a fish. | |
| `runEnterBox` | A box! Oyen climbs in and sits. | Ada kardus! Oyen masuk lalu duduk. | Run caption: gets into a box. | |
| `runSit` | Sitting pretty in the box. | Duduk manis di dalam kardus. | Run caption: still sitting in the box. | |
| `runBoxGone` | The box gets squashed, then vanishes. | Kardusnya penyok, lalu hilang. | Run caption: the box is squashed and disappears. | |
| `runKnockGlass` | The glass gets pushed off. Lucky it's plastic! | Gelas didorong jatuh. Untung plastik! | Run caption: pushes a glass off a table. | |
| `runKnockVase` | Uh-oh! Mom's vase falls and breaks. | Waduh! Vas Ibu jatuh dan pecah. | Run caption: pushes the vase off and it breaks. | |
| `replayAsleep` | Start: Oyen asleep, facing {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Awal: Oyen tidur menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Replay caption, step 0. Placeholders: `{dir}`. | |
| `replayFinished` | Into the bowl. Done in {n, plural, one{{n} step} other{{n} steps}}. | Masuk mangkuk. Selesai dalam {n} langkah. | Replay caption: reached the bowl after n steps. Placeholders: `{n}`. | |
| `replayChaseVaseSafe` | Chasing the fish. Vase still safe. | Kejar ikan. Vas tetap aman. | Replay caption: chasing a fish, vase still fine. | |
| `replaySeeFish` | Salted fish in sight, straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Ikan asin kelihatan lurus di {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Replay caption: a fish in a straight line. Placeholders: `{dir}`. | |
| `replayWalk` | Walks straight {dir, select, up{up} right{to the right} down{down} left{to the left} other{to the right}}. | Jalan lurus ke {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Replay caption: walking straight. Placeholders: `{dir}`. | |
| `replayScared` | Meets {water, select, puddle{a puddle} bucket{a water bucket} other{water}}, jumps, turns back. | Ketemu {water, select, puddle{genangan air} bucket{ember air} other{air}}, kaget, putar balik. | Replay caption: water ahead (puddle or bucket), turned back. Placeholders: `{water}`. | |
| `replayTurn` | Hits {obstacle, select, table{a table} wall{a wall} other{a wall}}, turns to face {dir, select, up{up} right{right} down{down} left{left} other{right}}. | Mentok {obstacle, select, table{meja} wall{tembok} other{tembok}}, berputar menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}}. | Replay caption: blocked, turned clockwise. Placeholders: `{obstacle}`, `{dir}`. | |
| `replayEat` | Chomp! Salted fish eaten. | Hap! Ikan asin dimakan. | Replay caption: eats a fish. | |
| `replayEnterBox` | Into the box, time to sit. | Masuk kardus, duduk dulu. | Replay caption: gets into a box. | |
| `replaySit` | Still sitting in the box. | Masih duduk di kardus. | Replay caption: still in the box. | |
| `replayBoxGone` | The box is squashed and gone. | Kardusnya penyok dan hilang. | Replay caption: the box is gone. | |
| `replayKnockGlass` | Glass pushed off. No harm, it's plastic. | Gelas didorong jatuh. Aman, plastik. | Replay caption: glass pushed off. | |
| `replayKnockVase` | Mom's vase pushed off. Smash! | Vas Ibu didorong jatuh. Pecah! | Replay caption: vase pushed off. | |
| `replayLoopStart` | Back to how it started. Oyen keeps circling and gets bored. | Balik lagi seperti awal. Oyen muter terus, jadi bosan. | Replay caption, last step: same state as the start. | |
| `replayLoopStep` | Back to how step {n} looked. Oyen keeps circling and gets bored. | Balik lagi seperti langkah {n}. Oyen muter terus, jadi bosan. | Replay caption, last step: same state as step n. Placeholders: `{n}`. | |
| `replayTooManySteps` | Step {n} and still no bowl. Oyen is bored. | Langkah ke-{n}, mangkuknya belum ketemu. Oyen bosan. | Replay caption, last step: hit the step limit. Placeholders: `{n}`. | |
| `closeRules` | Close rules | Tutup aturan | Screen reader: close the rules sheet. | |
| `rulesTitle` | Oyen's Rules | Aturan Oyen | Rules sheet title. | |
| `rulesIntro` | Each step is checked from the top. The first rule that fits is what Oyen does. | Tiap langkah dicek urut dari atas. Yang pertama cocok, itu yang dia lakukan. | Rules sheet intro. | |
| `ruleKnockTitle` | Knock over what's next door | Jatuhkan barang di sebelahnya | Rule card: knock things off the table next to Oyen. | |
| `ruleKnockBody` | A glass or vase on the table next door? It gets bumped. Always. | Ada gelas atau vas di meja sebelah? Disenggol. Pasti. | Rule card body: knock. | |
| `ruleFishTitle` | Chase the nearest fish | Kejar ikan terdekat | Rule card: chase the nearest fish. | |
| `ruleFishBody` | Only fish in a straight line. If tied: | Yang kelihatan lurus saja. Kalau seri: | Rule card body: fish, before the tie order. | |
| `tieAhead` | ahead | depan | Tie order word 1 (followed by an arrow). | |
| `tieClockwise` | clockwise | searah jarum jam | Tie order word 2: clockwise (never "right"). | |
| `tieCounterClockwise` | counterclockwise | berlawanan jarum jam | Tie order word 3: counterclockwise (never "left"). | |
| `tieBehind` | behind | belakang | Tie order word 4. | |
| `tieOrderLabel` | Tie order: ahead, clockwise, counterclockwise, behind. | Urutan seri: depan, searah jarum jam, berlawanan jarum jam, belakang. | Screen reader text of the tie order. | |
| `ruleWaterTitle` | Water? Turn back | Air? Putar balik | Rule card: water, turn back. | |
| `ruleWaterBody` | Puddle or bucket ahead? Oyen gets spooked and turns around. | Ketemu genangan atau ember, Oyen kaget lalu balik badan. | Rule card body: water. | |
| `ruleWallTitle` | Blocked by a wall or table | Mentok tembok atau meja | Rule card: blocked by a wall or table. | |
| `ruleWallTurn` | Oyen turns clockwise | Oyen berputar searah jarum jam | Rule card: turns clockwise (never "turns right"). | |
| `ruleWallBody` | A quarter turn, then off again. | Seperempat putaran, lalu jalan lagi. | Rule card body: wall. | |
| `ruleBoxTitle` | Box? Hop in, sit | Kardus? Masuk, duduk | Rule card: box, get in and sit. | |
| `ruleBoxBody` | Sits 2 steps until the box gets squashed and vanishes. Fish behind a box stay hidden. | Duduk 2 langkah sampai kardusnya penyok dan hilang. Ikan di balik kardus nggak kelihatan. | Rule card body: box. | |
| `ruleKnockLocked` | Things on tables | Barang di meja | Locked rule card name: knock. | |
| `ruleFishLocked` | Fish | Ikan | Locked rule card name: fish. | |
| `ruleWaterLocked` | Water | Air | Locked rule card name: water. | |
| `ruleWallLocked` | Wall | Tembok | Locked rule card name: wall. | |
| `ruleBoxLocked` | Box | Kardus | Locked rule card name: box. | |
| `ruleLockedTitle` | {name}: ??? | {name}: ??? | Locked rule card title. Placeholders: `{name}`. | |
| `ruleLockedBody` | Not learned yet. You'll meet it soon. | Belum dipelajari. Nanti juga kenalan sendiri. | Locked rule card body. | |
| `ruleLabel` | Rule {n} | Aturan {n} | Screen reader label of rule card n. Placeholders: `{n}`. | |
| `ruleLockedLabel` | Rule {n}, locked, not learned yet | Aturan {n}, terkunci, belum dipelajari | Screen reader label of a locked rule card. Placeholders: `{n}`. | |
| `closeHints` | Close hints | Tutup petunjuk | Screen reader: close the hint sheet. | |
| `hintsTitle` | Hints | Petunjuk | Hint sheet title. | |
| `hintsIntro` | Go slow. Maybe all you need is a little nudge. | Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil. | Hint sheet intro. | |
| `hintTier1Title` | Highlight the first tile | Sorot petak pertama | Hint tier 1 title. | |
| `hintTier2Title` | Show the item type | Tunjukkan jenis benda | Hint tier 2 title. | |
| `hintTier3Title` | Show the full solution | Tampilkan solusi lengkap | Hint tier 3 title. | |
| `hintOpened` | Unlocked | Terbuka | Hint tier status: already unlocked. | |
| `hintTier` | Tier {n} | Tingkat {n} | Hint tier status: ready to unlock. Placeholders: `{n}`. | |
| `hintUnlockFirst` | Unlock tier {n} first | Buka tingkat {n} dulu | Hint tier status: unlock the previous tier first. Placeholders: `{n}`. | |
| `noItemsHint` | No items needed here. Just wake Oyen up! | Level ini nggak butuh benda. Langsung bangunkan Oyen! | Hint sheet card on levels without items. | |
| `hintTier1Text` | See the glowing tile? Something needs to go there. | Lihat petak yang menyala. Ada benda yang harus ditaruh di situ. | Unlocked hint tier 1. | |
| `hintPlaceFish` | Put a salted fish on the glowing tile. Oyen will chase it and eat it. | Taruh ikan asin di petak yang menyala. Oyen bakal ngejar dan makan ikannya. | Unlocked hint tier 2: salted fish. | |
| `hintPlaceWater` | Put a water bucket on the glowing tile. Oyen will get spooked and turn around. | Taruh ember air di petak yang menyala. Oyen bakal kaget dan balik badan. | Unlocked hint tier 2: water bucket. | |
| `hintPlaceBox` | Put a box on the glowing tile. Oyen will climb in and sit there. | Taruh kardus di petak yang menyala. Oyen bakal masuk dan duduk di situ. | Unlocked hint tier 2: box. | |
| `hintFishCount` | {count, select, one{a salted fish} two{two salted fish} three{three salted fish} other{{n} salted fish}} | {count, select, one{ikan asin} two{dua ikan asin} three{tiga ikan asin} other{{n} ikan asin}} | Hint tier 3 list part (count = one/two/three/other, n = number): n salted fish. Placeholders: `{count}`, `{n}`. | |
| `hintWaterCount` | {count, select, one{a water bucket} two{two water buckets} three{three water buckets} other{{n} water buckets}} | {count, select, one{ember air} two{dua ember air} three{tiga ember air} other{{n} ember air}} | Hint tier 3 list part (count = one/two/three/other, n = number): n water buckets. Placeholders: `{count}`, `{n}`. | |
| `hintBoxCount` | {count, select, one{a box} two{two boxes} three{three boxes} other{{n} boxes}} | {count, select, one{kardus} two{dua kardus} three{tiga kardus} other{{n} kardus}} | Hint tier 3 list part (count = one/two/three/other, n = number): n boxes. Placeholders: `{count}`, `{n}`. | |
| `listPair` | {a} and {b} | {a} dan {b} | Joins two list parts. Placeholders: `{a}`, `{b}`. | |
| `listLast` | {rest}, and {last} | {rest}, dan {last} | Joins the comma-separated start of a list with its last part. Placeholders: `{rest}`, `{last}`. | |
| `hintSolution` | {items} on the glowing {count, plural, one{tile} other{tiles}}. {tail} | {items} di petak yang menyala. {tail} | Unlocked hint tier 3 (first letter is capitalized in code); count = number of items. Placeholders: `{items}`, `{count}`, `{tail}`. | |
| `hintSolutionVaseSafe` | Vase safe, 3 stars. | Vas aman, 3 bintang. | Tier 3 ending on levels with a vase. | |
| `hintSolutionStars` | 3 stars! | 3 bintang! | Tier 3 ending on levels without a vase. | |
| `tutorial1Title` | You can't boss Oyen around. Just wake the cat up! | Oyen nggak bisa disuruh. Bangunkan saja dia! | Tutorial level 1, big text. | |
| `tutorial1Body` | Oyen walks to the bowl alone. You just watch. | Dia jalan sendiri ke mangkuknya. Kamu tinggal nonton. | Tutorial level 1, small text. | |
| `tutorial3Title` | Oyen can't resist salted fish! | Oyen nggak tahan bau ikan asin! | Tutorial level 3 (fish), big text. | |
| `tutorial3Body` | Drag a fish onto the floor. If Oyen sees it in a straight line, the chase is on. | Seret ikan ke lantai. Kalau kelihatan lurus, dia langsung mengejarnya. | Tutorial level 3, small text. | |
| `tutorial6Title` | Oyen hates water. Like, really. | Oyen takut air. Banget. | Tutorial level 6 (bucket), big text. | |
| `tutorial6Body` | Put the bucket in the way. Water ahead means a spooked cat and a U-turn. | Taruh ember di jalannya. Ketemu air, dia kaget lalu putar balik. | Tutorial level 6, small text. | |
| `tutorialLabel` | Tutorial | Tutorial | Screen reader label of the tutorial card. | |
| `skipTutorial` | Skip tutorial | Lewati tutorial | Screen reader label of the Skip button. | |
| `skip` | Skip | Lewati | Skip button of the tutorial. | |
| `success` | Nailed it! | Berhasil! | Success screen headline. | |
| `stepsUnit` | {n, plural, one{step} other{steps}} | langkah | Word under a step count ("6 steps"). Placeholders: `{n}`. | |
| `itemsUsedUnit` | {n, plural, one{item used} other{items used}} | benda dipakai | Words under an item count ("2 items used"). Placeholders: `{n}`. | |
| `goalBowl` | Reached the bowl | Sampai mangkuk | Star rule 1. | |
| `goalVase` | Mom's vase is safe | Vas Ibu aman | Star rule 2. | |
| `goalItems` | Fewest items | Benda paling sedikit | Star rule 3. | |
| `goalNotYet` | Not yet | Belum | Star rule status: not earned. | |
| `goalGot` | Got it | Dapat | Star rule status: earned (vase screen). | |
| `goalAchieved` | done | tercapai | Screen reader: star rule earned (check mark). | |
| `restart` | Restart | Ulangi | Button: restart with an empty board. | |
| `next` | Next | Lanjut | Button: next level. | |
| `watchReplay` | Watch the replay | Tonton putar ulang | Link on the success screen. | |
| `vaseHeadlineTop` | Made it... | Sampai sih... | Vase screen headline, line 1. | |
| `vaseHeadlineBottom` | but Mom's vase? | tapi vas Ibu? | Vase screen headline, line 2. | |
| `brokenAtStep` | Broke on step {n} | Pecah di langkah {n} | Vase screen: the step the vase broke. Placeholders: `{n}`. | |
| `tryAgain` | Try Again | Coba Lagi | Vase screen button: arrange again. | |
| `nextAnyway` | Next Anyway | Lanjut Saja | Vase screen button: next level anyway. | |
| `vaseArtLabel` | The vase lies broken behind Oyen, and Mom pops in at the door, annoyed | Vas pecah di belakang Oyen, Ibu muncul dari pintu dengan wajah kesal | Screen reader label of the vase screen picture. | |
| `loopTitle` | Oyen got bored going in circles. | Oyen bosan mondar-mandir. | Fail screen title: going in circles. | |
| `loopBadge` | Going in circles | Muter terus | Fail screen chip: going in circles. | |
| `loopMessage` | Round and round, no bowl in sight. Oh well, back to sleep. | Jalannya muter-muter terus, nggak ketemu mangkuk. Ya sudah, tidur lagi. | Fail screen message: going in circles. | |
| `tooLongTitle` | Oyen got tired of walking. | Oyen bosan jalan terus. | Fail screen title: walked too long. | |
| `tooLongBadge` | Over {n} steps | Lewat {n} langkah | Fail screen chip: over the step limit. Placeholders: `{n}`. | |
| `tooLongMessage` | {n} steps and still no bowl. Ugh, so tired. Back to sleep. | Sudah {n} langkah, mangkuknya belum ketemu juga. Capek, ah. Tidur lagi. | Fail screen message: over the step limit. Placeholders: `{n}`. | |
| `failedKicker` | Level {id} · Failed | Level {id} · Gagal | Fail screen line above the title. Placeholders: `{id}`. | |
| `replay` | Replay | Putar Ulang | Replay button and replay screen title. | |
| `arrangeAgain` | Rearrange | Atur Lagi | Fail screen button: back to arranging. | |
| `replayStart` | Start | Awal | Replay: label of step 0. | |
| `replayPlay` | Autoplay | Putar otomatis | Replay: button that plays the steps by itself (screen reader label; the pause state uses "pause"). | |
| `backToResult` | Back to results | Kembali ke hasil | Replay: back to the result screen. | |
| `recording` | Recording | Rekaman | Replay: chip next to the title. | |
| `replayStepCaption` | Step {n}. {text} | Langkah {n}. {text} | Replay: screen reader caption of step n. Placeholders: `{n}`, `{text}`. | |
| `timeline` | Time | Waktu | Replay: label of the time slider (shown in capitals). | |
| `oyenLabel` | Oyen {pose, select, idle{standing} walk{walking} sleep{asleep} shock{startled} box{sitting in a box} knock{knocking something over} eat{eating} happy{happy} other{standing}}, facing {dir, select, up{up} right{right} down{down} left{left} other{right}} | Oyen {pose, select, idle{diam} walk{jalan} sleep{tidur} shock{kaget} box{duduk dalam kardus} knock{menjatuhkan barang} eat{makan} happy{senang} other{diam}}, menghadap {dir, select, up{atas} right{kanan} down{bawah} left{kiri} other{kanan}} | Screen reader label of Oyen: pose and facing (screen direction). Placeholders: `{pose}`, `{dir}`. | |
| `closeCoins` | Close coins | Tutup tambah koin | Screen reader: close the coin sheet. | |
| `coinsTitle` | Get Coins | Tambah Koin | Coin sheet title. | |
| `coinsIntro` | Coins buy hints and stuff for Oyen's room. Grab the daily bonus, or watch an ad. | Koin buat petunjuk dan isi kamar Oyen. Ambil bonus tiap hari, atau tonton iklan. | Coin sheet intro. | |
| `dailyBonus` | Daily bonus | Bonus harian | Coin card title: daily bonus. | |
| `dailyBonusReady` | Once a day | Sekali sehari | Daily bonus status: can claim. | |
| `dailyBonusTaken` | Claimed today | Sudah diambil hari ini | Daily bonus status: already claimed. | |
| `claimCoins` | {n, plural, one{Claim {n} coin} other{Claim {n} coins}} | Ambil {n} koin | Daily bonus button. Placeholders: `{n}`. | |
| `claimTomorrow` | Back tomorrow | Ambil lagi besok | Daily bonus button after claiming. | |
| `adsLeftToday` | {n, plural, one{{n} left today} other{{n} left today}} | Sisa {n} kali hari ini | Ad card status: ads left today. Placeholders: `{n}`. | |
| `adsUsedUp` | All used up today | Jatah hari ini habis | Ad card status: no ads left today. | |
| `adRewardButton` | {n, plural, one{+{n} coin} other{+{n} coins}} | +{n} koin | Ad card button: plus n coins. Placeholders: `{n}`. | |
| `adsTomorrow` | More tomorrow | Besok ada lagi | Ad card button when used up. | |
| `coinChipAdd` | get coins | tambah koin | Screen reader: the coin chip opens the coin sheet. | |
| `coinChipBonus` | daily bonus ready | bonus harian siap | Screen reader: the daily bonus is ready. | |
| `soundSection` | Sound | Suara | Settings section: music and sound effects. | |
| `music` | Music | Musik | Settings switch: background music. | |
| `soundEffects` | Sound effects | Efek suara | Settings switch: sound effects. | |
| `language` | Language | Bahasa | Settings section: language. | |
| `languageSystem` | Use phone language | Ikuti bahasa HP | Language option: follow the phone language. | |
| `tutorialsSection` | Tutorials | Tutorial | Settings section: tutorials. | |
| `replayTutorials` | Show tutorials again | Lihat tutorial lagi | Settings button: show the tutorials again. | |
| `replayTutorialsInfo` | The tutorials on levels 1, 3, and 6 show up again next time you play them. | Tutorial di level 1, 3, dan 6 muncul lagi saat levelnya dimainkan. | Settings text under the tutorials button. | |
| `tutorialsBack` | Done! The tutorials are back. | Siap! Tutorialnya muncul lagi. | Confirmation after pressing "show tutorials again". | |
| `progressSection` | Progress | Progres | Settings section: progress. | |
| `resetProgress` | Reset progress | Reset progres | Settings button: reset progress. | |
| `resetProgressInfo` | Erase stars, coins, room stuff, hints, and tutorials, then start again from level 1. | Hapus bintang, koin, isi kamar, petunjuk, dan tutorial, lalu mulai lagi dari level 1. | Settings text under the reset button. | |
| `resetConfirmTitle` | Erase all progress? | Hapus semua progres? | Reset confirmation title. | |
| `resetConfirmBody` | Stars, coins, room stuff, hints, and tutorials will be erased. This can't be undone. Today's daily bonus and ads stay used. | Bintang, koin, isi kamar, petunjuk, dan tutorial dihapus. Ini nggak bisa dibatalkan. Bonus harian dan iklan hari ini tetap terhitung. | Reset confirmation text. | |
| `resetConfirm` | Erase | Hapus | Reset confirmation button. | |
| `closeReset` | Close reset | Tutup reset progres | Screen reader: close the reset confirmation. | |
| `resetDone` | Progress erased. Fresh start! | Progres dihapus. Mulai lagi, yuk! | Message after resetting. | |
| `privacySection` | Privacy | Privasi | Settings section: privacy (policy link and ad consent). | |
| `privacyInfo` | Your progress stays on your phone. Ads come from Google AdMob. | Progresmu tersimpan di HP sendiri. Iklannya dari Google AdMob. | Settings, Privacy card: short explanation above the buttons. | |
| `privacyPolicy` | Privacy policy | Kebijakan privasi | Settings, Privacy: button that opens the privacy policy in the browser. | |
| `adConsent` | Ad consent settings | Atur persetujuan iklan | Settings, Privacy: button that reopens the ad consent form (only where the law requires it). | |
| `privacyLinkFailed` | Couldn't open the browser. Try again later, okay? | Browser-nya belum mau kebuka. Coba lagi nanti, ya. | Settings, Privacy: small message when the browser could not be opened. | |
| `about` | About | Tentang | Settings section: about the game. | |
| `version` | Version {version} | Versi {version} | App version. Placeholders: `{version}`. | |
| `fontCredits` | Fonts: Fredoka and Nunito (SIL Open Font License). | Font: Fredoka dan Nunito (SIL Open Font License). | Font credits. | |
| `soundCredits` | Sound effects: Kenney and OpenGameArt (CC0). The music was made just for Ginger Logic. | Efek suara: Kenney dan OpenGameArt (CC0). Musiknya dibuat khusus untuk Ginger Logic. | About card: credits for sound effects (CC0 sources) and the original music. | |
| `licenses` | Licenses | Lisensi | Button: open the licenses page. | |
| `roomItemTikus` | Toy Mouse | Tikus Mainan | Name of the room item "Toy Mouse". | |
| `roomItemTikusDesc` | Never runs away, still gets chased. | Tidak pernah lari, tapi tetap dikejar. | Shop description of the room item "Toy Mouse". | |
| `roomItemAkuarium` | Aquarium | Akuarium | Name of the room item "Aquarium". | |
| `roomItemAkuariumDesc` | All-day entertainment. The fish are a bit nervous. | Tontonan seharian. Ikannya agak gugup. | Shop description of the room item "Aquarium". | |
| `roomItemRumah` | Cat House | Rumah Kucing | Name of the room item "Cat House". | |
| `roomItemRumahDesc` | Has its own house, still sleeps in the box. | Punya rumah sendiri, tetap tidur di kardus. | Shop description of the room item "Cat House". | |
| `roomItemKasur` | Cushion Bed | Kasur Bantal | Name of the room item "Cushion Bed". | |
| `roomItemKasurDesc` | Soft. Used 60% of the time, the rest is box. | Empuk. Dipakai 60% waktunya, sisanya kardus. | Shop description of the room item "Cushion Bed". | |
| `roomItemCatnip` | Catnip Pot | Pot Catnip | Name of the room item "Catnip Pot". | |
| `roomItemCatnipDesc` | One sniff and the dancing starts. | Satu hirup, langsung joget. | Shop description of the room item "Catnip Pot". | |
| `roomItemJam` | Cat Clock | Jam Kucing | Name of the room item "Cat Clock". | |
| `roomItemJamDesc` | The tail swings every second. Hypnotic. | Ekornya goyang tiap detik. Hipnotis. | Shop description of the room item "Cat Clock". | |
| `roomItemKardus` | Cozy Box | Kardus Nyaman | Name of the room item "Cozy Box". | |
| `roomItemKardusDesc` | It's the box that gets picked, not what came in it. | Yang dipilih kardusnya, bukan isinya. | Shop description of the room item "Cozy Box". | |
| `roomItemBola` | Yarn Ball | Bola Benang | Name of the room item "Yarn Ball". | |
| `roomItemBolaDesc` | Tangled in 3 seconds. That's the feature. | Kusut dalam 3 detik. Itu fiturnya. | Shop description of the room item "Yarn Ball". | |
| `roomItemKarpet` | Round Rug | Karpet Bulat | Name of the room item "Round Rug". | |
| `roomItemKarpetDesc` | The official rolling-around spot. | Tempat resmi guling-guling. | Shop description of the room item "Round Rug". | |
| `roomItemTiang` | Scratching Post | Tiang Garukan | Name of the room item "Scratching Post". | |
| `roomItemTiangDesc` | So Mom's sofa survives. Hopefully. | Supaya sofa Ibu selamat. Semoga. | Shop description of the room item "Scratching Post". | |
| `roomItemLukisan` | Fish Painting | Lukisan Ikan | Name of the room item "Fish Painting". | |
| `roomItemLukisanDesc` | Art that makes you hungry. | Seni yang bikin lapar. | Shop description of the room item "Fish Painting". | |
| `roomItemRak` | Wall Shelf | Rak Dinding | Name of the room item "Wall Shelf". | |
| `roomItemRakDesc` | VIP seat for watching everyone. | Kursi VIP buat ngawasin semua orang. | Shop description of the room item "Wall Shelf". | |
| `roomItemPancingan` | Feather Wand | Pancingan Bulu | Name of the room item "Feather Wand". | |
| `roomItemPancinganDesc` | Chases the feather, leaves its dignity behind. | Bulunya dikejar, harga dirinya ketinggalan. | Shop description of the room item "Feather Wand". | |
| `roomItemLampuBulan` | Moon Lamp | Lampu Bulan | Name of the room item "Moon Lamp". | |
| `roomItemLampuBulanDesc` | A private moon, no need to wait for night. | Bulan pribadi, nggak perlu nunggu malam. | Shop description of the room item "Moon Lamp". | |
| `roomItemBantalIkan` | Fish Pillow | Bantal Ikan | Name of the room item "Fish Pillow". | |
| `roomItemBantalIkanDesc` | Soft, and fishy only to look at. | Empuk, dan amis secara visual saja. | Shop description of the room item "Fish Pillow". | |
| `roomItemMonstera` | Monstera Plant | Tanaman Monstera | Name of the room item "Monstera Plant". | |
| `roomItemMonsteraDesc` | The leaves have holes. Not Oyen's doing. This time. | Daunnya bolong-bolong. Bukan ulah Oyen. Kali ini. | Shop description of the room item "Monstera Plant". | |
| `roomItemTerowongan` | Cat Tunnel | Terowongan Kucing | Name of the room item "Cat Tunnel". | |
| `roomItemTerowonganDesc` | One cat goes in, style comes out. | Masuk satu kucing, keluar dengan gaya. | Shop description of the room item "Cat Tunnel". | |
| `roomItemHammock` | Window Hammock | Hammock Jendela | Name of the room item "Window Hammock". | |
| `roomItemHammockDesc` | Naps with a swing. Wake up and it's evening. | Tidur berayun. Bangun-bangun sudah sore. | Shop description of the room item "Window Hammock". | |
| `roomItemSofaMini` | Mini Sofa | Sofa Mini | Name of the room item "Mini Sofa". | |
| `roomItemSofaMiniDesc` | Its own sofa, so Mom's is safe. Allegedly. | Sofa sendiri, jadi sofa Ibu aman. Katanya. | Shop description of the room item "Mini Sofa". | |
| `roomItemJendelaBurung` | Bird Window | Jendela Burung | Name of the room item "Bird Window". | |
| `roomItemJendelaBurungDesc` | 24-hour cat TV, all birds, no ads. | TV kucing 24 jam, siaran burung tanpa iklan. | Shop description of the room item "Bird Window". | |
| `roomItemMangkuk` | Food bowl | Mangkuk makan | Name of the room item "Food bowl". | |
| `kittyOyen` | Oyen | Oyen | Name of the collection cat "Oyen". | |
| `kittyOyenDesc` | The ginger cat you wake up every level. | Kucing oren yang kamu bangunkan tiap level. | Shop description of the collection cat "Oyen". | |
| `kittySalju` | Snowy | Salju | Name of the collection cat "Snowy". | |
| `kittySaljuDesc` | Spotless white. Stays that way until it finds a box. | Putih bersih. Bertahan bersih sampai ketemu kardus. | Shop description of the collection cat "Snowy". | |
| `kittyTelon` | Patches | Telon | Name of the collection cat "Patches". | |
| `kittyTelonDesc` | Three colors, three moods a minute. | Tiga warna, tiga mood dalam semenit. | Shop description of the collection cat "Patches". | |
| `kittyArang` | Charcoal | Arang | Name of the collection cat "Charcoal". | |
| `kittyArangDesc` | Deep black, yellow eyes. Expert shadow hider. | Hitam pekat, mata kuning. Jago ngumpet di bayangan. | Shop description of the collection cat "Charcoal". | |
| `kittyMendung` | Cloudy | Mendung | Name of the collection cat "Cloudy". | |
| `kittyMendungDesc` | Looks sad, is just sleepy. | Kelihatan sedih, padahal cuma ngantuk. | Shop description of the collection cat "Cloudy". | |
| `kittyKopiSusu` | Latte | Kopi Susu | Name of the collection cat "Latte". | |
| `kittyKopiSusuDesc` | Sweet, a little bitter when woken up. | Manis, sedikit pahit kalau dibangunin. | Shop description of the collection cat "Latte". | |
| `kittyMochi` | Mochi | Mochi | Name of the collection cat "Mochi". | |
| `kittyMochiDesc` | Calm, squishy, face like it played in mud. | Kalem, kenyal, mukanya kayak habis main lumpur. | Shop description of the collection cat "Mochi". | |
| `kittyBos` | Boss | Bos | Name of the collection cat "Boss". | |
| `kittyBosDesc` | Always in a suit. Meetings at every mealtime. | Selalu pakai jas. Rapat tiap jam makan. | Shop description of the collection cat "Boss". | |
| `kittyKembang` | Blossom | Kembang | Name of the collection cat "Blossom". | |
| `kittyKembangDesc` | Abstract markings, abstract behavior. | Coraknya abstrak, kelakuannya juga. | Shop description of the collection cat "Blossom". | |
| `accessoryPita` | Ribbon | Pita | Name of the accessory "Ribbon". | |
| `accessoryPitaDesc` | Simple, sweet, easy to put on. | Simpel, manis, gampang dipasang. | Shop description of the accessory "Ribbon". | |
| `accessoryJepitBunga` | Flower Clip | Jepit Bunga | Name of the accessory "Flower Clip". | |
| `accessoryJepitBungaDesc` | Always in bloom, never needs water. | Mekar terus, nggak perlu disiram. | Shop description of the accessory "Flower Clip". | |
| `accessoryBandana` | Bandana | Bandana | Name of the accessory "Bandana". | |
| `accessoryBandanaDesc` | Cowboy style, suburban edition. | Gaya koboi kompleks perumahan. | Shop description of the accessory "Bandana". | |
| `accessoryDasiKupu` | Bow Tie | Dasi Kupu-kupu | Name of the accessory "Bow Tie". | |
| `accessoryDasiKupuDesc` | Ready for the party, no invitation. | Siap kondangan, tanpa undangan. | Shop description of the accessory "Bow Tie". | |
| `accessoryKalung` | Bell Collar | Kalung Lonceng | Name of the accessory "Bell Collar". | |
| `accessoryKalungDesc` | Jingle jingle. Busted on every fish heist. | Kling-kling. Ketahuan tiap mau nyolong ikan. | Shop description of the accessory "Bell Collar". | |
| `accessorySyal` | Knit Scarf | Syal Rajut | Name of the accessory "Knit Scarf". | |
| `accessorySyalDesc` | Warm. Knitted by an imaginary grandma. | Hangat. Dirajut nenek imajiner. | Shop description of the accessory "Knit Scarf". | |
| `accessoryBeanie` | Beanie | Beanie | Name of the accessory "Beanie". | |
| `accessoryBeanieDesc` | Warm. Even though it's hot outside. | Hangat. Padahal di luar panas. | Shop description of the accessory "Beanie". | |
| `accessoryTopiKoki` | Chef Hat | Topi Koki | Name of the accessory "Chef Hat". | |
| `accessoryTopiKokiDesc` | Cooking? No. Tasting? Always. | Masak? Nggak. Cicip? Selalu. | Shop description of the accessory "Chef Hat". | |
| `accessoryBaret` | Beret | Topi Baret | Name of the accessory "Beret". | |
| `accessoryBaretDesc` | Instant artist. Masterpiece: a torn pillow. | Mendadak seniman. Karyanya: bantal sobek. | Shop description of the accessory "Beret". | |
| `accessoryKacamata` | Round Glasses | Kacamata Bulat | Name of the accessory "Round Glasses". | |
| `accessoryKacamataDesc` | Looks smart. Still knocks the vase over. | Kelihatan pintar. Tetap jatuhin vas. | Shop description of the accessory "Round Glasses". | |
| `accessoryHeadphone` | Headphones | Headphone | Name of the accessory "Headphones". | |
| `accessoryHeadphoneDesc` | Lo-fi on, pretending to be busy. | Dengar lo-fi, pura-pura sibuk. | Shop description of the accessory "Headphones". | |
| `accessoryTandukRusa` | Reindeer Antlers | Tanduk Rusa | Name of the accessory "Reindeer Antlers". | |
| `accessoryTandukRusaDesc` | A pretend reindeer. Still meows. | Rusa jadi-jadian. Meongnya tetap. | Shop description of the accessory "Reindeer Antlers". | |
| `accessoryTopiPesta` | Party Hat | Topi Pesta | Name of the accessory "Party Hat". | |
| `accessoryTopiPestaDesc` | Every day is a birthday when you're a cat. | Tiap hari ulang tahun kalau kamu kucing. | Shop description of the accessory "Party Hat". | |
| `accessoryTopiPenyihir` | Wizard Hat | Topi Penyihir | Name of the accessory "Wizard Hat". | |
| `accessoryTopiPenyihirDesc` | Can make fish appear. Allegedly. | Bisa bikin ikan muncul. Katanya. | Shop description of the accessory "Wizard Hat". | |
| `accessoryMahkota` | Flower Crown | Mahkota Bunga | Name of the accessory "Flower Crown". | |
| `accessoryMahkotaDesc` | Queen of the room. Don't eat the flowers. | Ratu kamar. Bunganya jangan dimakan. | Shop description of the accessory "Flower Crown". | |
| `accessoryMahkotaRaja` | King's Crown | Mahkota Raja | Name of the accessory "King's Crown". | |
| `accessoryMahkotaRajaDesc` | King of the room. Taxes paid in head scratches. | Raja kamar. Pajaknya dibayar pakai elusan. | Shop description of the accessory "King's Crown". | |
| `snackIkanAsin` | Salted Fish | Ikan Asin | Name of the snack "Salted Fish". | |
| `snackIkanAsinDesc` | Salty, savory, the neighbors can smell it. | Asin, gurih, baunya sampai tetangga. | Shop description of the snack "Salted Fish". | |
| `snackSusu` | Milk | Susu | Name of the snack "Milk". | |
| `snackSusuDesc` | A small saucer. White whiskers guaranteed. | Sepiring kecil. Kumis jadi putih. | Shop description of the snack "Milk". | |
| `snackTuna` | Canned Tuna | Tuna Kaleng | Name of the snack "Canned Tuna". | |
| `snackTunaDesc` | The can opening summons every cat. | Bunyi kalengnya bikin semua kucing datang. | Shop description of the snack "Canned Tuna". | |
| `snackBiskuit` | Cat Biscuits | Biskuit Kucing | Name of the snack "Cat Biscuits". | |
| `snackBiskuitDesc` | Crunchy and cheap. Not very filling. | Kriuk dan murah. Kenyangnya sedikit. | Shop description of the snack "Cat Biscuits". | |
| `snackPuding` | Fish Pudding | Puding Ikan | Name of the snack "Fish Pudding". | |
| `snackPudingDesc` | Fancy. Very filling, very happy. | Mewah. Kenyang banget, senang banget. | Shop description of the snack "Fish Pudding". | |
| `rarityCommon` | Common | Biasa | Accessory rarity badge in the shop: common. | |
| `rarityRare` | Rare | Langka | Accessory rarity badge in the shop: rare. | |
| `raritySpecial` | Special | Spesial | Accessory rarity badge in the shop: special. | |
| `shop` | Shop | Toko | Shop screen title, and the menu button that opens it. | |
| `shopTabItems` | Items | Barang | Shop tab: room items. | |
| `shopTabKitties` | Cats | Kucing | Shop tab: collection cats. | |
| `shopTabAccessories` | Accessories | Aksesoris | Shop tab: accessories. | |
| `shopTabSnacks` | Food | Makanan | Shop tab: snacks. | |
| `shopKittyIntro` | Every cat shares the room with Oyen. Oyen agrees. Probably. | Semua kucing tinggal sekamar dengan Oyen. Oyen setuju. Kayaknya. | Line above the cat cards in the shop. | |
| `shopSnackIntro` | Snacks go into your stock. Hand them out from the cat card in the room. | Camilan masuk stok. Kasih lewat kartu kucing di kamar. | Line above the snack cards in the shop. | |
| `shopOwnedTag` | Yours | Punyamu | Shop card badge: already owned. | |
| `shopLivesHere` | Lives in the room | Tinggal di kamar | Shop card badge: this cat already lives in the room. | |
| `shopNotEnoughTag` | Not enough coins | Koin kurang | Shop card badge: the player cannot afford this yet. | |
| `shopShortBy` | {n, plural, one{{n} coin short} other{{n} coins short}} | Kurang {n} koin | How many coins are still missing for this cat. Placeholders: `{n}`. | |
| `shopAdopt` | Adopt · {n} | Adopsi · {n} | Shop cat card button: adopt for this many coins. Placeholders: `{n}`. | |
| `shopBuyShort` | Buy · {n} | Beli · {n} | Shop snack card button: buy for this many coins. Placeholders: `{n}`. | |
| `shopStock` | Stock: {n} | Stok: {n} | Shop snack card: how many are in stock. Placeholders: `{n}`. | |
| `shopTryOn` | Try on: | Coba di: | Label before the row of cats used for the accessory preview. | |
| `shopPreviewOf` | Preview · {name} | Pratinjau · {name} | Accessory preview panel overline, with the cat name. Placeholders: `{name}`. | |
| `shopWearFree` | Wear · Free | Pakai · Gratis | Button: put the owned accessory on the previewed cat, for free. | |
| `shopRemoveFree` | Take off · Free | Lepas · Gratis | Button: take the accessory off the previewed cat, for free. | |
| `shopPlayFirst` | Play a puzzle first, the coins will follow. | Main puzzle dulu, koinnya nyusul. | Hint under the accessory button when coins are missing. | |
| `shopWornBy` | Worn by {name} | Dipakai {name} | Accessory card note: which cats wear it (comma separated names). Placeholders: `{name}`. | |
| `shopFlashNice` | Looking good! | Cakep! | Cheer shown after putting an accessory on a cat. | |
| `shopFlashRemoved` | Off, free of charge | Lepas, gratis | Note shown after taking an accessory off. | |
| `shopFlashSpent` | {n, plural, one{-{n} coin} other{-{n} coins}} | -{n} koin | Floating note after buying a snack: coins spent. Placeholders: `{n}`. | |
| `shopPreviewPickLabel` | Try the accessory on {name} | Coba aksesoris di {name} | Screen reader label of a cat button in the preview row. Placeholders: `{name}`. | |
| `shopCardBuyLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}} | {name}, {n} koin | Screen reader label of a shop card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopCardShortLabel` | {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | {name}, {n} koin, koin kurang | Screen reader label of a shop card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopCardOwnedLabel` | {name}, already yours | {name}, sudah punyamu | Screen reader label of a shop card for something already owned. Placeholders: `{name}`. | |
| `shopCardLivesLabel` | {name}, already lives in the room | {name}, sudah tinggal di kamar | Screen reader label of a cat card for a cat already adopted. Placeholders: `{name}`. | |
| `shopSnackBuyLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}} | Beli {name} seharga {n} koin | Screen reader label of the snack buy button. Placeholders: `{name}`, `{n}`. | |
| `shopSnackShortLabel` | Buy {name} for {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Beli {name} seharga {n} koin, koin kurang | Screen reader label of the snack buy button when coins are missing. Placeholders: `{name}`, `{n}`. | |
| `buySheetLabel` | Buy {name} | Beli {name} | Screen reader label of the buy confirmation sheet. Placeholders: `{name}`. | |
| `buySuccessOverline` | Success! | Berhasil! | Overline above the title after a successful purchase. | |
| `buySuccessItem` | {name} is yours! | {name} jadi punyamu! | Buy sheet title after buying a room item. Placeholders: `{name}`. | |
| `buySuccessItemBody` | It's in the room already. Move it around in decorate mode. | Sudah nongkrong di kamar. Geser lewat mode Hias kalau mau pindah. | Buy sheet body after buying a room item. | |
| `buySuccessKitty` | {name} moved into the room! | {name} pindah ke kamar! | Buy sheet title after adopting a cat. Placeholders: `{name}`. | |
| `buySuccessKittyBody` | Say hi in the room. Expect some fake indifference first. | Sapa dia di kamar. Mungkin pura-pura cuek dulu. | Buy sheet body after adopting a cat. | |
| `buySuccessAccessory` | {name} is yours forever! | {name} milikmu selamanya! | Buy sheet title after buying an accessory. Placeholders: `{name}`. | |
| `buySuccessAccessoryBody` | Put it on {name} now, or move it to another cat any time. | Pasang di {name} sekarang, atau pindahkan ke kucing lain kapan saja. | Buy sheet body after buying an accessory, with the previewed cat name. Placeholders: `{name}`. | |
| `buyAccessoryInfo` | Buy once, keep forever. Free to put on and take off, for every cat. | Sekali beli, milikmu selamanya. Pasang-lepas gratis, buat semua kucing. | Note in the accessory buy sheet before paying. | |
| `buyPay` | Buy · {n, plural, one{{n} coin} other{{n} coins}} | Beli · {n} koin | Buy sheet button: pay this many coins. Placeholders: `{n}`. | |
| `buyLater` | Maybe later | Nanti dulu | Buy sheet button: close without buying. | |
| `buyAgain` | Keep shopping | Belanja lagi | Buy sheet button after a purchase: back to the shop. | |
| `buySeeRoom` | See it in the room | Lihat di kamar | Buy sheet button after a purchase: open the room. | |
| `buyWearOn` | Wear on {name} | Pakai di {name} | Buy sheet button after buying an accessory: put it on this cat. Placeholders: `{name}`. | |
| `buyNotEnoughHelp` | Play a puzzle or watch a rewarded ad to get more coins. | Main puzzle atau tonton iklan berhadiah buat nambah koin. | Buy sheet hint when the player cannot afford the item. | |
| `kittyPose` | {pose, select, idle{sitting still} lick{licking a paw} walk1{walking} walk2{walking} sleep{curled up asleep} eat{eating from the bowl} play{batting a toy} scratch{scratching the post} happy{happy} lesu{listless} rebah{lounging} petted{being petted, purring} other{sitting still}} | {pose, select, idle{duduk diam} lick{menjilat kaki} walk1{jalan} walk2{jalan} sleep{tidur melingkar} eat{makan dari mangkuk} play{main menepuk mainan} scratch{menggaruk tiang} happy{senang} lesu{lesu} rebah{rebahan santai} petted{dielus dan mendengkur} other{duduk diam}} | What a room cat is doing, for its screen reader label. Placeholders: `{pose}`. | |
| `kittyLabel` | {name} {pose} | {name} {pose} | Screen reader label of a room cat: name and what it is doing. Placeholders: `{name}`, `{pose}`. | |
| `kittyLabelAccessory` | {name} {pose}, wearing a {accessory} | {name} {pose}, memakai {accessory} | Screen reader label of a room cat wearing an accessory. Placeholders: `{name}`, `{pose}`, `{accessory}`. | |
| `shopSnackFullLabel` | Buy {name}, stock full | Beli {name}, stok penuh | Screen reader label of the snack buy button when the stock is full. Placeholders: `{name}`. | |
| `shopStockFull` | Stock full | Stok penuh | Snack card chip when the stock is at the maximum. | |
| `shopAccessoryBuyLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}} | Lihat {name}, {n} koin | Screen reader label of an accessory card the player can afford. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryShortLabel` | View {name}, {n, plural, one{{n} coin} other{{n} coins}}, not enough coins | Lihat {name}, {n} koin, koin kurang | Screen reader label of an accessory card that costs more than the balance. Placeholders: `{name}`, `{n}`. | |
| `shopAccessoryOwnedLabel` | View {name}, yours | Lihat {name}, punyamu | Screen reader label of an owned accessory card nobody wears. Placeholders: `{name}`. | |
| `shopAccessoryWornLabel` | View {name}, yours, worn by {who} | Lihat {name}, punyamu, dipakai {who} | Screen reader label of an owned accessory card with the cats wearing it. Placeholders: `{name}`, `{who}`. | |
| `sadMarkHungry` | Droopy: hungry | Lesu: lapar | Screen reader label of the thought bubble above a hungry room cat. | |
| `sadMarkSad` | Droopy: wants attention | Lesu: kurang perhatian | Screen reader label of the thought bubble above a room cat that needs attention. | |
| `roomEmptyBubble` | Pretty empty in here. To the Shop! | Kamar masih sepi. Ke Toko, yuk! | Speech bubble in an empty starter room, pointing the player to the shop. | |
| `roomEmptyWall` | Wall decor? | Hiasan dinding? | Short label inside the empty dashed spot on the wall of a starter room. | |
| `roomEmptyWallHint` | Empty. Find wall decor in the Shop | Kosong. Cari hiasan dinding di Toko | Screen reader label of the empty wall spot; tapping opens the shop. | |
| `roomEmptyFloor` | A bed, maybe? | Kasur, mungkin? | Short label inside the empty dashed spot on the floor of a starter room. | |
| `roomEmptyFloorHint` | Empty. Find a bed or a toy in the Shop | Kosong. Cari kasur atau mainan di Toko | Screen reader label of the empty floor spot; tapping opens the shop. | |
| `accessories` | Accessories | Aksesoris | Room menu button that opens the accessories tab of the shop. | |
| `shopHasNew` | something new you can afford | ada yang baru terjangkau | Added to a room menu button's screen reader label when something there is affordable and not owned yet. | |
| `menuButtonNew` | {label}, {note} | {label}, {note} | Screen reader label of a room menu button with a red dot. {label} is the button name, {note} is shopHasNew. Placeholders: `{label}`, `{note}`. | |
| `kittyTapHint` | {name}. Tap to see their card | {name}. Ketuk untuk lihat kartunya | Screen reader label of a cat in the room. Placeholders: `{name}`. | |
| `kittyTapHintHungry` | {name}, hungry. Tap to see their card | {name}, lapar. Ketuk untuk lihat kartunya | Screen reader label of a hungry cat in the room. Placeholders: `{name}`. | |
| `needHunger` | Full | Lapar | Hunger bar label on a cat card (higher = fuller). | |
| `needJoy` | Happy | Senang | Happiness bar label on a cat card. | |
| `needValueLabel` | {label} {value} out of 100 | {label} {value} dari 100 | Screen reader label of a need bar. Placeholders: `{label}`, `{value}`. | |
| `needValueLow` | {label} {value} out of 100, almost empty | {label} {value} dari 100, hampir habis | Screen reader label of a need bar that is almost empty. Placeholders: `{label}`, `{value}`. | |
| `needLowHunger` | Almost empty! That tummy is rumbling. | Hampir habis! Perutnya keroncongan. | Warning under an almost empty hunger bar. | |
| `needLowJoy` | Almost empty! Pet them already. | Hampir habis! Elus dulu, dong. | Warning under an almost empty happiness bar. | |
| `kittyCardLabel` | {name}'s card | Kartu {name} | Screen reader label of the cat card dialog. Placeholders: `{name}`. | |
| `kittyCardClose` | Close card | Tutup kartu | Screen reader label of the close button on a cat card. | |
| `petAction` | Pet | Elus | Cat card button that pets the cat. | |
| `snackPanel` | Snacks | Camilan | Cat card button that opens the snack list. | |
| `snackPick` | Pick from your stock | Pilih dari stok | Heading above the snack list on a cat card. | |
| `snackGive` | Give {name}, {count} in stock | Beri {name}, stok {count} | Screen reader label of a snack on a cat card. Placeholders: `{name}`, `{count}`. | |
| `snackGiveEmpty` | Give {name}, {count} in stock, all gone | Beri {name}, stok {count}, habis | Screen reader label of a snack that ran out. Placeholders: `{name}`, `{count}`. | |
| `accessoryPanelTitle` | Yours · swap for free | Punyamu · ganti gratis | Heading above the owned accessories on a cat card. | |
| `accessoryShopLink` | Accessory shop | Toko aksesoris | Link on a cat card to the accessories shop (an arrow icon follows it). | |
| `accessoryRemove` | Take off | Lepas | Card in the accessory list that takes the accessory off. | |
| `accessoryWornTag` | Wearing | Dipakai | Tag on the accessory the cat is wearing. | |
| `accessoryWearLabel` | Put {accessory} on {name} | Pasang {accessory} di {name} | Screen reader label of an accessory on a cat card. Placeholders: `{accessory}`, `{name}`. | |
| `accessoryWornLabel` | Put {accessory} on {name}, wearing it now | Pasang {accessory} di {name}, sedang dipakai | Screen reader label of the accessory the cat is wearing. Placeholders: `{accessory}`, `{name}`. | |
| `accessoryRemoveLabel` | Take {name}'s accessory off | Lepas aksesoris {name} | Screen reader label of the take-off card. Placeholders: `{name}`. | |
| `reactionFed` | +{hunger} full | +{hunger} kenyang | Floating text over a cat after a snack. Placeholders: `{hunger}`. | |
| `reactionFedJoy` | +{hunger} full, +{joy} happy | +{hunger} kenyang, +{joy} senang | Floating text over a cat after a snack that also makes it happy. Placeholders: `{hunger}`, `{joy}`. | |
| `reactionJoy` | +{joy} happy | +{joy} senang | Floating text over a cat after petting. Placeholders: `{joy}`. | |
| `reactionNice` | Looking sharp! | Cakep! | Floating text over a cat after putting an accessory on. | |
| `reactionRelieved` | Ahh, free! | Lega! | Floating text over a cat after taking its accessory off. | |
| `decorate` | Decorate | Hias | Room button that starts decorate mode. | |
| `decorateDone` | Done | Selesai | Button that ends decorate mode. | |
| `decorateHint` | Drag things to a new spot | Seret barang ke tempat baru | Chip shown while decorating. | |
| `zoneWall` | Wall area | Area dinding | Label of the wall area while decorating. | |
| `zoneFloor` | Floor area | Area lantai | Label of the floor area while decorating. | |
| `storage` | Storage | Gudang | Title of the storage tray with owned items that are not in the room. | |
| `storageCount` | {count, plural, =1{1 item} other{{count} items}} | {count, plural, other{{count} barang}} | Number of items in storage. Placeholders: `{count}`. | |
| `storageTapHint` | Tap to place | Ketuk untuk menaruh | Hint on the storage tray. | |
| `storageEmpty` | Storage is empty. Everything's on display, Oyen is proud. | Gudangnya kosong. Semua barang sudah dipajang, Oyen bangga. | Storage tray when every item is in the room. | |
| `storagePlaceLabel` | Put {item} in the room | Taruh {item} di kamar | Screen reader label of an item in storage. Placeholders: `{item}`. | |
| `storageLabel` | Item storage | Gudang barang | Screen reader label of the storage tray. | |
| `storeItemAction` | Move to storage | Simpan ke Gudang | Screen reader action on a room item while decorating. | |
| `decoratePraise` | Room's looking great! | Kamar makin cakep! | Praise shown after decorating. | |
| `decoratePraiseJoy` | +{joy} Happy for every cat | +{joy} Senang untuk semua kucing | Bonus line under the decorating praise. Placeholders: `{joy}`. | |
| `bowlRefill` | {hours, plural, one{Refills in {hours} hour} other{Refills in {hours} hours}} | {hours, plural, other{Terisi lagi {hours} jam}} | Label over the empty shared food bowl in the cat room: hours until it refills. Placeholders: `{hours}`. | |
| `kittyRewardLabel` | {coins, plural, one{Collect {coins} coin from {name}} other{Collect {coins} coins from {name}}} | Ambil {coins} koin dari {name} | Screen reader label of the coin bubble over a well cared-for cat; tapping collects the daily reward. Placeholders: `{coins}`, `{name}`. | |
| `reactionCoins` | {coins, plural, one{+{coins} coin} other{+{coins} coins}} | +{coins} koin | Floating text over a cat after collecting its coin reward. Placeholders: `{coins}`. | |

---

## Store listing: English

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
