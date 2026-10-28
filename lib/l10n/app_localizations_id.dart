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

  @override
  String get roomItemTikus => 'Tikus Mainan';

  @override
  String get roomItemTikusDesc => 'Tidak pernah lari, tapi tetap dikejar.';

  @override
  String get roomItemAkuarium => 'Akuarium';

  @override
  String get roomItemAkuariumDesc => 'Tontonan seharian. Ikannya agak gugup.';

  @override
  String get roomItemRumah => 'Rumah Kucing';

  @override
  String get roomItemRumahDesc => 'Punya rumah sendiri, tetap tidur di kardus.';

  @override
  String get roomItemKasur => 'Kasur Bantal';

  @override
  String get roomItemKasurDesc =>
      'Empuk. Dipakai 60% waktunya, sisanya kardus.';

  @override
  String get roomItemCatnip => 'Pot Catnip';

  @override
  String get roomItemCatnipDesc => 'Satu hirup, langsung joget.';

  @override
  String get roomItemJam => 'Jam Kucing';

  @override
  String get roomItemJamDesc => 'Ekornya goyang tiap detik. Hipnotis.';

  @override
  String get roomItemKardus => 'Kardus Nyaman';

  @override
  String get roomItemKardusDesc => 'Yang dipilih kardusnya, bukan isinya.';

  @override
  String get roomItemBola => 'Bola Benang';

  @override
  String get roomItemBolaDesc => 'Kusut dalam 3 detik. Itu fiturnya.';

  @override
  String get roomItemKarpet => 'Karpet Bulat';

  @override
  String get roomItemKarpetDesc => 'Tempat resmi guling-guling.';

  @override
  String get roomItemTiang => 'Tiang Garukan';

  @override
  String get roomItemTiangDesc => 'Supaya sofa Ibu selamat. Semoga.';

  @override
  String get roomItemLukisan => 'Lukisan Ikan';

  @override
  String get roomItemLukisanDesc => 'Seni yang bikin lapar.';

  @override
  String get roomItemRak => 'Rak Dinding';

  @override
  String get roomItemRakDesc => 'Kursi VIP buat ngawasin semua orang.';

  @override
  String get roomItemPancingan => 'Pancingan Bulu';

  @override
  String get roomItemPancinganDesc =>
      'Bulunya dikejar, harga dirinya ketinggalan.';

  @override
  String get roomItemLampuBulan => 'Lampu Bulan';

  @override
  String get roomItemLampuBulanDesc =>
      'Bulan pribadi, nggak perlu nunggu malam.';

  @override
  String get roomItemBantalIkan => 'Bantal Ikan';

  @override
  String get roomItemBantalIkanDesc => 'Empuk, dan amis secara visual saja.';

  @override
  String get roomItemMonstera => 'Tanaman Monstera';

  @override
  String get roomItemMonsteraDesc =>
      'Daunnya bolong-bolong. Bukan ulah Oyen. Kali ini.';

  @override
  String get roomItemTerowongan => 'Terowongan Kucing';

  @override
  String get roomItemTerowonganDesc => 'Masuk satu kucing, keluar dengan gaya.';

  @override
  String get roomItemHammock => 'Hammock Jendela';

  @override
  String get roomItemHammockDesc => 'Tidur berayun. Bangun-bangun sudah sore.';

  @override
  String get roomItemSofaMini => 'Sofa Mini';

  @override
  String get roomItemSofaMiniDesc =>
      'Sofa sendiri, jadi sofa Ibu aman. Katanya.';

  @override
  String get roomItemJendelaBurung => 'Jendela Burung';

  @override
  String get roomItemJendelaBurungDesc =>
      'TV kucing 24 jam, siaran burung tanpa iklan.';

  @override
  String get roomItemMangkuk => 'Mangkuk makan';

  @override
  String get kittyOyen => 'Oyen';

  @override
  String get kittyOyenDesc => 'Kucing oren yang kamu bangunkan tiap level.';

  @override
  String get kittySalju => 'Salju';

  @override
  String get kittySaljuDesc =>
      'Putih bersih. Bertahan bersih sampai ketemu kardus.';

  @override
  String get kittyTelon => 'Telon';

  @override
  String get kittyTelonDesc => 'Tiga warna, tiga mood dalam semenit.';

  @override
  String get kittyArang => 'Arang';

  @override
  String get kittyArangDesc =>
      'Hitam pekat, mata kuning. Jago ngumpet di bayangan.';

  @override
  String get kittyMendung => 'Mendung';

  @override
  String get kittyMendungDesc => 'Kelihatan sedih, padahal cuma ngantuk.';

  @override
  String get kittyKopiSusu => 'Kopi Susu';

  @override
  String get kittyKopiSusuDesc => 'Manis, sedikit pahit kalau dibangunin.';

  @override
  String get kittyMochi => 'Mochi';

  @override
  String get kittyMochiDesc =>
      'Kalem, kenyal, mukanya kayak habis main lumpur.';

  @override
  String get kittyBos => 'Bos';

  @override
  String get kittyBosDesc => 'Selalu pakai jas. Rapat tiap jam makan.';

  @override
  String get kittyKembang => 'Kembang';

  @override
  String get kittyKembangDesc => 'Coraknya abstrak, kelakuannya juga.';

  @override
  String get accessoryPita => 'Pita';

  @override
  String get accessoryPitaDesc => 'Simpel, manis, gampang dipasang.';

  @override
  String get accessoryJepitBunga => 'Jepit Bunga';

  @override
  String get accessoryJepitBungaDesc => 'Mekar terus, nggak perlu disiram.';

  @override
  String get accessoryBandana => 'Bandana';

  @override
  String get accessoryBandanaDesc => 'Gaya koboi kompleks perumahan.';

  @override
  String get accessoryDasiKupu => 'Dasi Kupu-kupu';

  @override
  String get accessoryDasiKupuDesc => 'Siap kondangan, tanpa undangan.';

  @override
  String get accessoryKalung => 'Kalung Lonceng';

  @override
  String get accessoryKalungDesc =>
      'Kling-kling. Ketahuan tiap mau nyolong ikan.';

  @override
  String get accessorySyal => 'Syal Rajut';

  @override
  String get accessorySyalDesc => 'Hangat. Dirajut nenek imajiner.';

  @override
  String get accessoryBeanie => 'Beanie';

  @override
  String get accessoryBeanieDesc => 'Hangat. Padahal di luar panas.';

  @override
  String get accessoryTopiKoki => 'Topi Koki';

  @override
  String get accessoryTopiKokiDesc => 'Masak? Nggak. Cicip? Selalu.';

  @override
  String get accessoryBaret => 'Topi Baret';

  @override
  String get accessoryBaretDesc => 'Mendadak seniman. Karyanya: bantal sobek.';

  @override
  String get accessoryKacamata => 'Kacamata Bulat';

  @override
  String get accessoryKacamataDesc => 'Kelihatan pintar. Tetap jatuhin vas.';

  @override
  String get accessoryHeadphone => 'Headphone';

  @override
  String get accessoryHeadphoneDesc => 'Dengar lo-fi, pura-pura sibuk.';

  @override
  String get accessoryTandukRusa => 'Tanduk Rusa';

  @override
  String get accessoryTandukRusaDesc => 'Rusa jadi-jadian. Meongnya tetap.';

  @override
  String get accessoryTopiPesta => 'Topi Pesta';

  @override
  String get accessoryTopiPestaDesc =>
      'Tiap hari ulang tahun kalau kamu kucing.';

  @override
  String get accessoryTopiPenyihir => 'Topi Penyihir';

  @override
  String get accessoryTopiPenyihirDesc => 'Bisa bikin ikan muncul. Katanya.';

  @override
  String get accessoryMahkota => 'Mahkota Bunga';

  @override
  String get accessoryMahkotaDesc => 'Ratu kamar. Bunganya jangan dimakan.';

  @override
  String get accessoryMahkotaRaja => 'Mahkota Raja';

  @override
  String get accessoryMahkotaRajaDesc =>
      'Raja kamar. Pajaknya dibayar pakai elusan.';

  @override
  String get snackIkanAsin => 'Ikan Asin';

  @override
  String get snackIkanAsinDesc => 'Asin, gurih, baunya sampai tetangga.';

  @override
  String get snackSusu => 'Susu';

  @override
  String get snackSusuDesc => 'Sepiring kecil. Kumis jadi putih.';

  @override
  String get snackTuna => 'Tuna Kaleng';

  @override
  String get snackTunaDesc => 'Bunyi kalengnya bikin semua kucing datang.';

  @override
  String get snackBiskuit => 'Biskuit Kucing';

  @override
  String get snackBiskuitDesc => 'Kriuk dan murah. Kenyangnya sedikit.';

  @override
  String get snackPuding => 'Puding Ikan';

  @override
  String get snackPudingDesc => 'Mewah. Kenyang banget, senang banget.';

  @override
  String get rarityCommon => 'Biasa';

  @override
  String get rarityRare => 'Langka';

  @override
  String get raritySpecial => 'Spesial';

  @override
  String get shop => 'Toko';

  @override
  String get shopTabItems => 'Barang';

  @override
  String get shopTabKitties => 'Kucing';

  @override
  String get shopTabAccessories => 'Aksesoris';

  @override
  String get shopTabSnacks => 'Makanan';

  @override
  String get shopKittyIntro =>
      'Semua kucing tinggal sekamar dengan Oyen. Oyen setuju. Kayaknya.';

  @override
  String get shopSnackIntro =>
      'Camilan masuk stok. Kasih lewat kartu kucing di kamar.';

  @override
  String get shopOwnedTag => 'Punyamu';

  @override
  String get shopLivesHere => 'Tinggal di kamar';

  @override
  String get shopNotEnoughTag => 'Koin kurang';

  @override
  String shopShortBy(int n) {
    return 'Kurang $n koin';
  }

  @override
  String shopAdopt(int n) {
    return 'Adopsi · $n';
  }

  @override
  String shopBuyShort(int n) {
    return 'Beli · $n';
  }

  @override
  String shopStock(int n) {
    return 'Stok: $n';
  }

  @override
  String get shopTryOn => 'Coba di:';

  @override
  String shopPreviewOf(String name) {
    return 'Pratinjau · $name';
  }

  @override
  String get shopWearFree => 'Pakai · Gratis';

  @override
  String get shopRemoveFree => 'Lepas · Gratis';

  @override
  String get shopPlayFirst => 'Main puzzle dulu, koinnya nyusul.';

  @override
  String shopWornBy(String name) {
    return 'Dipakai $name';
  }

  @override
  String get shopFlashNice => 'Cakep!';

  @override
  String get shopFlashRemoved => 'Lepas, gratis';

  @override
  String shopFlashSpent(int n) {
    return '-$n koin';
  }

  @override
  String shopPreviewPickLabel(String name) {
    return 'Coba aksesoris di $name';
  }

  @override
  String shopCardBuyLabel(String name, int n) {
    return '$name, $n koin';
  }

  @override
  String shopCardShortLabel(String name, int n) {
    return '$name, $n koin, koin kurang';
  }

  @override
  String shopCardOwnedLabel(String name) {
    return '$name, sudah punyamu';
  }

  @override
  String shopCardLivesLabel(String name) {
    return '$name, sudah tinggal di kamar';
  }

  @override
  String shopAccessoryViewLabel(String name) {
    return 'Lihat $name';
  }

  @override
  String shopSnackBuyLabel(String name, int n) {
    return 'Beli $name seharga $n koin';
  }

  @override
  String shopSnackShortLabel(String name, int n) {
    return 'Beli $name seharga $n koin, koin kurang';
  }

  @override
  String buySheetLabel(String name) {
    return 'Beli $name';
  }

  @override
  String get buySuccessOverline => 'Berhasil!';

  @override
  String buySuccessItem(String name) {
    return '$name jadi punyamu!';
  }

  @override
  String get buySuccessItemBody => 'Sudah masuk Gudang. Taruh lewat mode Hias.';

  @override
  String buySuccessKitty(String name) {
    return '$name pindah ke kamar!';
  }

  @override
  String get buySuccessKittyBody =>
      'Sapa dia di kamar. Mungkin pura-pura cuek dulu.';

  @override
  String buySuccessAccessory(String name) {
    return '$name milikmu selamanya!';
  }

  @override
  String buySuccessAccessoryBody(String name) {
    return 'Pasang di $name sekarang, atau pindahkan ke kucing lain kapan saja.';
  }

  @override
  String get buyAccessoryInfo =>
      'Sekali beli, milikmu selamanya. Pasang-lepas gratis, buat semua kucing.';

  @override
  String buyPay(int n) {
    return 'Beli · $n koin';
  }

  @override
  String get buyLater => 'Nanti dulu';

  @override
  String get buyAgain => 'Belanja lagi';

  @override
  String get buySeeRoom => 'Lihat di kamar';

  @override
  String buyWearOn(String name) {
    return 'Pakai di $name';
  }

  @override
  String get buyNotEnoughHelp =>
      'Main puzzle atau tonton iklan berhadiah buat nambah koin.';

  @override
  String kittyPose(String pose) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'duduk diam',
      'lick': 'menjilat kaki',
      'walk1': 'jalan',
      'walk2': 'jalan',
      'sleep': 'tidur melingkar',
      'eat': 'makan dari mangkuk',
      'play': 'main menepuk mainan',
      'scratch': 'menggaruk tiang',
      'happy': 'senang',
      'lesu': 'lesu',
      'rebah': 'rebahan santai',
      'petted': 'dielus dan mendengkur',
      'other': 'duduk diam',
    });
    return '$_temp0';
  }

  @override
  String kittyLabel(String name, String pose) {
    return '$name $pose';
  }

  @override
  String kittyLabelAccessory(String name, String pose, String accessory) {
    return '$name $pose, memakai $accessory';
  }
}
