// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get backToMap => 'Kembali ke peta';

  @override
  String get close => 'Tutup';

  @override
  String get cancel => 'Batal';

  @override
  String starsOf(int stars, int total) {
    return '$stars dari $total bintang';
  }

  @override
  String coinsAmount(int n) {
    return '$n koin';
  }

  @override
  String coinsUnit(int n) {
    return 'koin';
  }

  @override
  String notEnoughCoins(int n) {
    return 'Koin kurang · $n';
  }

  @override
  String get watchAd => 'Tonton iklan';

  @override
  String get adFailed => 'Iklannya belum bisa diputar. Coba lagi nanti, ya.';

  @override
  String get boardLabel => 'Papan permainan 7 kali 9 petak';

  @override
  String get play => 'Main';

  @override
  String get closet => 'Lemari Kostum';

  @override
  String get settings => 'Pengaturan';

  @override
  String get tagline => 'Oyen nggak bisa disuruh. Kamu yang mikir.';

  @override
  String get splashTagline => 'Ayo main!';

  @override
  String get starTotalUnit => 'bintang';

  @override
  String chapterNumber(int n) {
    return 'Babak $n';
  }

  @override
  String get chapter1Name => 'Dapur';

  @override
  String get chapter2Name => 'Ruang Tamu';

  @override
  String chapterTitle(int n, String name) {
    return 'Babak $n – $name';
  }

  @override
  String get chapterDone => 'Selesai';

  @override
  String get chapterLocked => 'Terkunci';

  @override
  String get statusDone => 'selesai';

  @override
  String get statusLocked => 'terkunci';

  @override
  String get statusPlayNow => 'main sekarang';

  @override
  String nodeStars(int n) {
    return '$n bintang';
  }

  @override
  String levelNodeLabel(int id, String status) {
    return 'Level $id, $status';
  }

  @override
  String bossNodeLabel(int id, String name, String status) {
    return 'Level $id, bos $name, $status';
  }

  @override
  String bossTag(String name) {
    return 'Bos · $name';
  }

  @override
  String get chapterMissing => 'Babak ini nggak ada.';

  @override
  String get level1Name => 'Bangunkan Oyen';

  @override
  String get level2Name => 'Belok Kanan';

  @override
  String get level3Name => 'Ikan Pertama';

  @override
  String get level4Name => 'Ikan Terdekat';

  @override
  String get level5Name => 'Dua Ikan';

  @override
  String get level6Name => 'Ember Pertama';

  @override
  String get level7Name => 'Genangan';

  @override
  String get level8Name => 'Ikan dan Ember';

  @override
  String get level9Name => 'Ikan Godaan';

  @override
  String get level10Name => 'Pesta Ikan Asin';

  @override
  String get level11Name => 'Meja Tamu';

  @override
  String get level12Name => 'Gelas Jatuh';

  @override
  String get level13Name => 'Vas Ibu';

  @override
  String get level14Name => 'Kardus Penghalang';

  @override
  String get level15Name => 'Kardus Penyok';

  @override
  String get level16Name => 'Jalan Memutar';

  @override
  String get level17Name => 'Dua Vas';

  @override
  String get level18Name => 'Ruang Sempit';

  @override
  String get level19Name => 'Semua Bersama';

  @override
  String get level20Name => 'Hari Lebaran';

  @override
  String bossLevelName(String name) {
    return 'BOS: $name';
  }

  @override
  String levelTitle(int id, String name) {
    return 'Level $id · $name';
  }

  @override
  String get rules => 'Aturan';

  @override
  String get hint => 'Petunjuk';

  @override
  String targetItems(int n) {
    return 'pakai $n benda';
  }

  @override
  String targetLabel(String text) {
    return 'Target 3 bintang: $text';
  }

  @override
  String get levelMissing => 'Level ini nggak ada.';

  @override
  String get backToArrange => 'Kembali ke fase atur';

  @override
  String get wakeOyen => 'Bangunkan Oyen';

  @override
  String get trayEmpty => 'Level ini belum butuh benda.';

  @override
  String get trayLabel => 'Benda';

  @override
  String get clearBoard => 'Kosongkan papan';

  @override
  String get trayHintTop => 'Taruh di petak';

  @override
  String get trayHintBottom => 'yang menyala';

  @override
  String get itemFish => 'Ikan asin';

  @override
  String get itemWater => 'Ember air';

  @override
  String get itemBox => 'Kardus';

  @override
  String traySlotLabel(String name, int n) {
    return '$name, sisa $n';
  }

  @override
  String traySlotDragging(String name, int n) {
    return '$name, sedang diseret, sisa $n';
  }

  @override
  String get traySlotSelectHint => 'mengambil benda ini';

  @override
  String get traySlotUnselectHint => 'batal mengambil';

  @override
  String tileLabel(int row, int col, String content) {
    return 'Baris $row, kolom $col: $content';
  }

  @override
  String get cellWall => 'tembok';

  @override
  String get cellFloor => 'lantai';

  @override
  String get cellBowl => 'mangkuk Oyen';

  @override
  String get cellTable => 'meja';

  @override
  String get cellTableGlass => 'meja dengan gelas';

  @override
  String get cellTableVase => 'meja dengan vas';

  @override
  String get cellFish => 'ikan asin';

  @override
  String get cellWater => 'genangan air';

  @override
  String get cellBox => 'kardus';

  @override
  String tileOyen(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Oyen tidur, menghadap $_temp0';
  }

  @override
  String tilePlayerItem(String item) {
    return '$item, kamu yang taruh';
  }

  @override
  String tileHintSpot(String content) {
    return '$content. Petunjuk: ada benda yang harus ditaruh di sini.';
  }

  @override
  String tileHintItem(String content, String item) {
    return '$content. Petunjuk: $item di sini.';
  }

  @override
  String get tilePlaceHint => 'menaruh di sini';

  @override
  String get tilePickHint => 'mengambil untuk dipindah';

  @override
  String get tileReturn => 'Kembalikan ke baki';

  @override
  String itemPickedAnnounce(String item) {
    return '$item diambil. Pilih petak lantai yang kosong untuk menaruhnya.';
  }

  @override
  String itemPlacedAnnounce(String item, int row, int col) {
    return '$item ditaruh di baris $row, kolom $col.';
  }

  @override
  String itemReturnedAnnounce(String item) {
    return '$item kembali ke baki.';
  }

  @override
  String get step => 'Langkah';

  @override
  String stepNumber(int n) {
    return 'Langkah $n';
  }

  @override
  String get vaseBroken => 'Vas pecah';

  @override
  String get vaseSafe => 'Vas aman';

  @override
  String itemsUsed(int n) {
    return '$n benda dipakai';
  }

  @override
  String get pause => 'Jeda';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get stepForward => 'Maju satu langkah';

  @override
  String get stepBack => 'Mundur satu langkah';

  @override
  String get doubleSpeed => 'Percepat dua kali';

  @override
  String get seeResult => 'Lihat hasil';

  @override
  String runWake(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Oyen bangun, menghadap $_temp0.';
  }

  @override
  String get runAtBowl => 'Sampai di mangkuk! Nyam nyam.';

  @override
  String chaseFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Kejar ikan ke $_temp0.';
  }

  @override
  String runSmellFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Eh, ada bau ikan asin di $_temp0!';
  }

  @override
  String runWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Jalan lurus ke $_temp0, santai.';
  }

  @override
  String get runScared => 'Ada air! Oyen kaget, lalu putar balik.';

  @override
  String runTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'meja',
      'wall': 'tembok',
      'other': 'tembok',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Mentok $_temp0. Berputar, sekarang menghadap $_temp1.';
  }

  @override
  String get runEat => 'Hap! Ikan asinnya dimakan.';

  @override
  String get runEnterBox => 'Ada kardus! Oyen masuk lalu duduk.';

  @override
  String get runSit => 'Duduk manis di dalam kardus.';

  @override
  String get runBoxGone => 'Kardusnya penyok, lalu hilang.';

  @override
  String get runKnockGlass => 'Gelas didorong jatuh. Untung plastik!';

  @override
  String get runKnockVase => 'Waduh! Vas Ibu jatuh dan pecah.';

  @override
  String replayAsleep(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Awal: Oyen tidur menghadap $_temp0.';
  }

  @override
  String replayFinished(int n) {
    return 'Masuk mangkuk. Selesai dalam $n langkah.';
  }

  @override
  String get replayChaseVaseSafe => 'Kejar ikan. Vas tetap aman.';

  @override
  String replaySeeFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Ikan asin kelihatan lurus di $_temp0.';
  }

  @override
  String replayWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Jalan lurus ke $_temp0.';
  }

  @override
  String replayScared(String water) {
    String _temp0 = intl.Intl.selectLogic(water, {
      'puddle': 'genangan air',
      'bucket': 'ember air',
      'other': 'air',
    });
    return 'Ketemu $_temp0, kaget, putar balik.';
  }

  @override
  String replayTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'meja',
      'wall': 'tembok',
      'other': 'tembok',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Mentok $_temp0, berputar menghadap $_temp1.';
  }

  @override
  String get replayEat => 'Hap! Ikan asin dimakan.';

  @override
  String get replayEnterBox => 'Masuk kardus, duduk dulu.';

  @override
  String get replaySit => 'Masih duduk di kardus.';

  @override
  String get replayBoxGone => 'Kardusnya penyok dan hilang.';

  @override
  String get replayKnockGlass => 'Gelas didorong jatuh. Aman, plastik.';

  @override
  String get replayKnockVase => 'Vas Ibu didorong jatuh. Pecah!';

  @override
  String get replayLoopStart =>
      'Balik lagi seperti awal. Oyen muter terus, jadi bosan.';

  @override
  String replayLoopStep(int n) {
    return 'Balik lagi seperti langkah $n. Oyen muter terus, jadi bosan.';
  }

  @override
  String replayTooManySteps(int n) {
    return 'Langkah ke-$n, mangkuknya belum ketemu. Oyen bosan.';
  }

  @override
  String get closeRules => 'Tutup aturan';

  @override
  String get rulesTitle => 'Aturan Oyen';

  @override
  String get rulesIntro =>
      'Tiap langkah dicek urut dari atas. Yang pertama cocok, itu yang dia lakukan.';

  @override
  String get ruleKnockTitle => 'Jatuhkan barang di sebelahnya';

  @override
  String get ruleKnockBody =>
      'Ada gelas atau vas di meja sebelah? Disenggol. Pasti.';

  @override
  String get ruleFishTitle => 'Kejar ikan terdekat';

  @override
  String get ruleFishBody => 'Yang kelihatan lurus saja. Kalau seri:';

  @override
  String get tieAhead => 'depan';

  @override
  String get tieClockwise => 'searah jarum jam';

  @override
  String get tieCounterClockwise => 'berlawanan jarum jam';

  @override
  String get tieBehind => 'belakang';

  @override
  String get tieOrderLabel =>
      'Urutan seri: depan, searah jarum jam, berlawanan jarum jam, belakang.';

  @override
  String get ruleWaterTitle => 'Air? Putar balik';

  @override
  String get ruleWaterBody =>
      'Ketemu genangan atau ember, Oyen kaget lalu balik badan.';

  @override
  String get ruleWallTitle => 'Mentok tembok atau meja';

  @override
  String get ruleWallTurn => 'Oyen berputar searah jarum jam';

  @override
  String get ruleWallBody => 'Seperempat putaran, lalu jalan lagi.';

  @override
  String get ruleBoxTitle => 'Kardus? Masuk, duduk';

  @override
  String get ruleBoxBody =>
      'Duduk 2 langkah sampai kardusnya penyok dan hilang. Ikan di balik kardus nggak kelihatan.';

  @override
  String get ruleKnockLocked => 'Barang di meja';

  @override
  String get ruleFishLocked => 'Ikan';

  @override
  String get ruleWaterLocked => 'Air';

  @override
  String get ruleWallLocked => 'Tembok';

  @override
  String get ruleBoxLocked => 'Kardus';

  @override
  String ruleLockedTitle(String name) {
    return '$name: ???';
  }

  @override
  String get ruleLockedBody => 'Belum dipelajari. Nanti juga kenalan sendiri.';

  @override
  String ruleLabel(int n) {
    return 'Aturan $n';
  }

  @override
  String ruleLockedLabel(int n) {
    return 'Aturan $n, terkunci, belum dipelajari';
  }

  @override
  String get closeHints => 'Tutup petunjuk';

  @override
  String get hintsTitle => 'Petunjuk';

  @override
  String get hintsIntro =>
      'Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil.';

  @override
  String get hintTier1Title => 'Sorot petak pertama';

  @override
  String get hintTier2Title => 'Tunjukkan jenis benda';

  @override
  String get hintTier3Title => 'Tampilkan solusi lengkap';

  @override
  String get hintOpened => 'Terbuka';

  @override
  String hintTier(int n) {
    return 'Tingkat $n';
  }

  @override
  String hintUnlockFirst(int n) {
    return 'Buka tingkat $n dulu';
  }

  @override
  String get noItemsHint =>
      'Level ini nggak butuh benda. Langsung bangunkan Oyen!';

  @override
  String get hintTier1Text =>
      'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.';

  @override
  String get hintPlaceFish =>
      'Taruh ikan asin di petak yang menyala. Oyen bakal ngejar dan makan ikannya.';

  @override
  String get hintPlaceWater =>
      'Taruh ember air di petak yang menyala. Oyen bakal kaget dan balik badan.';

  @override
  String get hintPlaceBox =>
      'Taruh kardus di petak yang menyala. Oyen bakal masuk dan duduk di situ.';

  @override
  String hintFishCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'ikan asin',
      'two': 'dua ikan asin',
      'three': 'tiga ikan asin',
      'other': '$n ikan asin',
    });
    return '$_temp0';
  }

  @override
  String hintWaterCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'ember air',
      'two': 'dua ember air',
      'three': 'tiga ember air',
      'other': '$n ember air',
    });
    return '$_temp0';
  }

  @override
  String hintBoxCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'kardus',
      'two': 'dua kardus',
      'three': 'tiga kardus',
      'other': '$n kardus',
    });
    return '$_temp0';
  }

  @override
  String listPair(String a, String b) {
    return '$a dan $b';
  }

  @override
  String listLast(String rest, String last) {
    return '$rest, dan $last';
  }

  @override
  String hintSolution(String items, int count, String tail) {
    return '$items di petak yang menyala. $tail';
  }

  @override
  String get hintSolutionVaseSafe => 'Vas aman, 3 bintang.';

  @override
  String get hintSolutionStars => '3 bintang!';

  @override
  String get tutorial1Title => 'Oyen nggak bisa disuruh. Bangunkan saja dia!';

  @override
  String get tutorial1Body =>
      'Dia jalan sendiri ke mangkuknya. Kamu tinggal nonton.';

  @override
  String get tutorial3Title => 'Oyen nggak tahan bau ikan asin!';

  @override
  String get tutorial3Body =>
      'Seret ikan ke lantai. Kalau kelihatan lurus, dia langsung mengejarnya.';

  @override
  String get tutorial6Title => 'Oyen takut air. Banget.';

  @override
  String get tutorial6Body =>
      'Taruh ember di jalannya. Ketemu air, dia kaget lalu putar balik.';

  @override
  String get tutorialLabel => 'Tutorial';

  @override
  String get skipTutorial => 'Lewati tutorial';

  @override
  String get skip => 'Lewati';

  @override
  String get success => 'Berhasil!';

  @override
  String stepsUnit(int n) {
    return 'langkah';
  }

  @override
  String itemsUsedUnit(int n) {
    return 'benda dipakai';
  }

  @override
  String get goalBowl => 'Sampai mangkuk';

  @override
  String get goalVase => 'Vas Ibu aman';

  @override
  String get goalItems => 'Benda paling sedikit';

  @override
  String get goalNotYet => 'Belum';

  @override
  String get goalGot => 'Dapat';

  @override
  String get goalAchieved => 'tercapai';

  @override
  String get restart => 'Ulangi';

  @override
  String get next => 'Lanjut';

  @override
  String get watchReplay => 'Tonton putar ulang';

  @override
  String get vaseHeadlineTop => 'Sampai sih...';

  @override
  String get vaseHeadlineBottom => 'tapi vas Ibu?';

  @override
  String brokenAtStep(int n) {
    return 'Pecah di langkah $n';
  }

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get nextAnyway => 'Lanjut Saja';

  @override
  String get vaseArtLabel =>
      'Vas pecah di belakang Oyen, Ibu muncul dari pintu dengan wajah kesal';

  @override
  String get loopTitle => 'Oyen bosan mondar-mandir.';

  @override
  String get loopBadge => 'Muter terus';

  @override
  String get loopMessage =>
      'Jalannya muter-muter terus, nggak ketemu mangkuk. Ya sudah, tidur lagi.';

  @override
  String get tooLongTitle => 'Oyen bosan jalan terus.';

  @override
  String tooLongBadge(int n) {
    return 'Lewat $n langkah';
  }

  @override
  String tooLongMessage(int n) {
    return 'Sudah $n langkah, mangkuknya belum ketemu juga. Capek, ah. Tidur lagi.';
  }

  @override
  String failedKicker(int id) {
    return 'Level $id · Gagal';
  }

  @override
  String get replay => 'Putar Ulang';

  @override
  String get arrangeAgain => 'Atur Lagi';

  @override
  String get replayStart => 'Awal';

  @override
  String get replayPlay => 'Putar otomatis';

  @override
  String get backToResult => 'Kembali ke hasil';

  @override
  String get recording => 'Rekaman';

  @override
  String replayStepCaption(int n, String text) {
    return 'Langkah $n. $text';
  }

  @override
  String get timeline => 'Waktu';

  @override
  String oyenLabel(String pose, String dir) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'diam',
      'walk': 'jalan',
      'sleep': 'tidur',
      'shock': 'kaget',
      'box': 'duduk dalam kardus',
      'knock': 'menjatuhkan barang',
      'eat': 'makan',
      'happy': 'senang',
      'other': 'diam',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'atas',
      'right': 'kanan',
      'down': 'bawah',
      'left': 'kiri',
      'other': 'kanan',
    });
    return 'Oyen $_temp0, menghadap $_temp1';
  }

  @override
  String get costumeNone => 'Polos';

  @override
  String get costumePeci => 'Peci';

  @override
  String get costumeSarung => 'Sarung';

  @override
  String get costumeKoki => 'Topi Koki';

  @override
  String get costumeKacamata => 'Kacamata';

  @override
  String get costumeWearingTag => 'Dipakai';

  @override
  String get costumeWearingStatus => 'dipakai';

  @override
  String get costumeOwnedTag => 'Punyamu';

  @override
  String get costumeOwnedStatus => 'punyamu';

  @override
  String get costumeActionWearing => 'Sedang dipakai';

  @override
  String get costumeActionWear => 'Pakai';

  @override
  String costumeActionBuy(int n) {
    return 'Beli · $n koin';
  }

  @override
  String get closeCoins => 'Tutup tambah koin';

  @override
  String get coinsTitle => 'Tambah Koin';

  @override
  String get coinsIntro =>
      'Koin buat petunjuk dan kostum Oyen. Ambil bonus tiap hari, atau tonton iklan.';

  @override
  String get dailyBonus => 'Bonus harian';

  @override
  String get dailyBonusReady => 'Sekali sehari';

  @override
  String get dailyBonusTaken => 'Sudah diambil hari ini';

  @override
  String claimCoins(int n) {
    return 'Ambil $n koin';
  }

  @override
  String get claimTomorrow => 'Ambil lagi besok';

  @override
  String adsLeftToday(int n) {
    return 'Sisa $n kali hari ini';
  }

  @override
  String get adsUsedUp => 'Jatah hari ini habis';

  @override
  String adRewardButton(int n) {
    return '+$n koin';
  }

  @override
  String get adsTomorrow => 'Besok ada lagi';

  @override
  String get coinChipAdd => 'tambah koin';

  @override
  String get coinChipBonus => 'bonus harian siap';

  @override
  String get soundSection => 'Suara';

  @override
  String get music => 'Musik';

  @override
  String get soundEffects => 'Efek suara';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Ikuti bahasa HP';

  @override
  String get tutorialsSection => 'Tutorial';

  @override
  String get replayTutorials => 'Lihat tutorial lagi';

  @override
  String get replayTutorialsInfo =>
      'Tutorial di level 1, 3, dan 6 muncul lagi saat levelnya dimainkan.';

  @override
  String get tutorialsBack => 'Siap! Tutorialnya muncul lagi.';

  @override
  String get progressSection => 'Progres';

  @override
  String get resetProgress => 'Reset progres';

  @override
  String get resetProgressInfo =>
      'Hapus bintang, koin, kostum, petunjuk, dan tutorial, lalu mulai lagi dari level 1.';

  @override
  String get resetConfirmTitle => 'Hapus semua progres?';

  @override
  String get resetConfirmBody =>
      'Bintang, koin, kostum, petunjuk, dan tutorial dihapus. Ini nggak bisa dibatalkan. Bonus harian dan iklan hari ini tetap terhitung.';

  @override
  String get resetConfirm => 'Hapus';

  @override
  String get closeReset => 'Tutup reset progres';

  @override
  String get resetDone => 'Progres dihapus. Mulai lagi, yuk!';

  @override
  String get privacySection => 'Privasi';

  @override
  String get privacyInfo =>
      'Progresmu tersimpan di HP sendiri. Iklannya dari Google AdMob.';

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String get adConsent => 'Atur persetujuan iklan';

  @override
  String get privacyLinkFailed =>
      'Browser-nya belum mau kebuka. Coba lagi nanti, ya.';

  @override
  String get about => 'Tentang';

  @override
  String version(String version) {
    return 'Versi $version';
  }

  @override
  String get fontCredits => 'Font: Fredoka dan Nunito (SIL Open Font License).';

  @override
  String get soundCredits =>
      'Efek suara: Kenney dan OpenGameArt (CC0). Musiknya dibuat khusus untuk Ginger Logic.';

  @override
  String get licenses => 'Lisensi';
}
