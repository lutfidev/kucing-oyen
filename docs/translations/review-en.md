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

278 lines. Generated from `lib/l10n/` by `tool/translations/make_review.py`; do not edit by hand.

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
| `closet` | Wardrobe | Lemari Kostum | Costume closet button and screen title. | |
| `settings` | Settings | Pengaturan | Settings button and screen title. | |
| `tagline` | Oyen won't listen. You do the thinking. | Oyen nggak bisa disuruh. Kamu yang mikir. | Tagline under the logo on the home screen. | |
| `splashTagline` | Let's play! | Ayo main! | Short line under the logo on the Android splash screen (rendered into an image, keep it very short). | |
| `starTotalUnit` | stars | bintang | Word after the star total on the home screen ("31/60 stars"). | |
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
| `costumeNone` | Plain | Polos | Costume: none. | |
| `costumePeci` | Peci Cap | Peci | Costume: peci (Indonesian cap). | |
| `costumeSarung` | Sarong | Sarung | Costume: sarong. | |
| `costumeKoki` | Chef Hat | Topi Koki | Costume: chef hat. | |
| `costumeKacamata` | Glasses | Kacamata | Costume: glasses. | |
| `costumeWearingTag` | Wearing | Dipakai | Costume card tag: being worn. | |
| `costumeWearingStatus` | wearing | dipakai | Screen reader status: being worn. | |
| `costumeOwnedTag` | Yours | Punyamu | Costume card tag: owned. | |
| `costumeOwnedStatus` | yours | punyamu | Screen reader status: owned. | |
| `costumeActionWearing` | Wearing now | Sedang dipakai | Closet button: selected costume is worn. | |
| `costumeActionWear` | Wear | Pakai | Closet button: wear the owned costume. | |
| `costumeActionBuy` | {n, plural, one{Buy · {n} coin} other{Buy · {n} coins}} | Beli · {n} koin | Closet button: buy for n coins. Placeholders: `{n}`. | |
| `closeCoins` | Close coins | Tutup tambah koin | Screen reader: close the coin sheet. | |
| `coinsTitle` | Get Coins | Tambah Koin | Coin sheet title. | |
| `coinsIntro` | Coins buy hints and outfits for Oyen. Grab the daily bonus, or watch an ad. | Koin buat petunjuk dan kostum Oyen. Ambil bonus tiap hari, atau tonton iklan. | Coin sheet intro. | |
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
| `resetProgressInfo` | Erase stars, coins, outfits, hints, and tutorials, then start again from level 1. | Hapus bintang, koin, kostum, petunjuk, dan tutorial, lalu mulai lagi dari level 1. | Settings text under the reset button. | |
| `resetConfirmTitle` | Erase all progress? | Hapus semua progres? | Reset confirmation title. | |
| `resetConfirmBody` | Stars, coins, outfits, hints, and tutorials will be erased. This can't be undone. Today's daily bonus and ads stay used. | Bintang, koin, kostum, petunjuk, dan tutorial dihapus. Ini nggak bisa dibatalkan. Bonus harian dan iklan hari ini tetap terhitung. | Reset confirmation text. | |
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
