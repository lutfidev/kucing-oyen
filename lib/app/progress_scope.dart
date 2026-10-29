import 'package:flutter/widgets.dart';

import '../game/model/accessories.dart';
import '../game/model/chapter.dart';
import '../game/model/hints.dart';
import '../game/model/home.dart';
import '../game/model/home_items.dart';
import '../game/model/kitties.dart';
import '../game/model/needs.dart';
import '../game/model/progress.dart';
import '../game/model/rewards.dart';
import '../game/model/snacks.dart';
import '../game/sim/sim.dart';
import 'hint_source.dart';
import 'language.dart';
import 'progress_store.dart';
import 'rewarded_ads.dart';

/// Hasil [ProgressController.watchAdForCoins].
enum AdReward {
  /// Iklan selesai, koin ditambah.
  rewarded,

  /// Iklan gagal dimuat atau ditutup lebih dulu; tidak ada yang berubah.
  failed,

  /// Jatah iklan hari ini habis; iklan tidak diputar.
  limitReached,

  /// Iklan koin lain sedang diputar.
  busy,
}

/// Bagian progres yang disimpan terpisah, urut tulisnya. Urutan ini memihak
/// pemain kalau aplikasi mati di tengah: petunjuk dan isi rumah
/// sebelum koin yang membayarnya, koin sebelum bintang, hadiah harian, dan
/// hari hadiah kucing yang memberikannya (jadi paling buruk koin didapat
/// lagi, tidak hilang). Akibatnya stok camilan ditulis sebelum bar yang
/// dinaikkannya.
enum _Part { hints, home, coins, needs, progress, rewards, tutorials, language }

/// Data level dan progres pemain untuk semua layar: bintang, tutorial,
/// koin, petunjuk, rumah Oyen dan kebutuhan kucingnya, hadiah harian, dan
/// bahasa. Dimuat sekali sebelum aplikasi jalan (`main`), lalu dibagikan lewat [ProgressScope].
class ProgressController extends ChangeNotifier implements HintSource {
  ProgressController({
    required List<Level> levels,
    required this.store,
    this._progress = Progress.empty,
    Set<int> tutorialsDone = const {},
    this._coins = 0,
    Map<int, int> hints = const {},
    Home? home,
    HomeNeeds? needs,
    this._rewards = DailyRewards.initial,
    this._language = AppLanguage.system,
    RewardedAds? hintAds,
    RewardedAds? coinAds,
    DateTime Function()? clock,
  }) : levels = List.unmodifiable(levels),
       _tutorialsDone = Set.unmodifiable(tutorialsDone),
       _hints = Map.unmodifiable(hints),
       _home = home ?? Home.initial,
       _needs = (needs ?? HomeNeeds.empty).withKitties(
         (home ?? Home.initial).kitties,
         (clock ?? DateTime.now)(),
       ),
       clock = clock ?? DateTime.now,
       _seenDay = dayNumber((clock ?? DateTime.now)()),
       hintAds = hintAds ?? FakeRewardedAds(),
       coinAds = coinAds ?? FakeRewardedAds(),
       chapters = List.unmodifiable(chaptersOf(levels));

  /// Memuat progres, tutorial, koin, petunjuk, rumah, kebutuhan
  /// kucing, hadiah harian, dan bahasa dari [store]. Koin yang belum pernah
  /// disimpan (progres dari sebelum ada koin) dihitung dari total bintang.
  /// Kucing yang kebutuhannya belum tercatat (pemain baru) mulai penuh pada
  /// jam muat dan langsung disimpan, supaya bar tetap turun walau aplikasi
  /// ditutup sebelum ada aksi.
  static Future<ProgressController> load({
    required List<Level> levels,
    required ProgressStore store,
    RewardedAds? hintAds,
    RewardedAds? coinAds,
    DateTime Function()? clock,
  }) async {
    final progress = await store.load();
    final needs = await store.loadNeeds();
    final controller = ProgressController(
      levels: levels,
      store: store,
      progress: progress,
      tutorialsDone: await store.loadTutorials(),
      coins: await store.loadCoins() ?? progress.totalStars * coinsPerStar,
      hints: await store.loadHints(),
      home: await store.loadHome(),
      needs: needs,
      rewards: await store.loadRewards(),
      language: await store.loadLanguage(),
      hintAds: hintAds,
      coinAds: coinAds,
      clock: clock,
    );
    if (!identical(controller._needs, needs)) {
      await controller._save({_Part.needs});
    }
    return controller;
  }

  final List<Level> levels;
  final List<Chapter> chapters;
  final ProgressStore store;

  /// Iklan berhadiah untuk membuka petunjuk.
  final RewardedAds hintAds;

  /// Iklan berhadiah untuk koin tambahan (unit AdMob sendiri, supaya
  /// laporannya terpisah).
  final RewardedAds coinAds;

  /// Jam untuk bonus harian dan jatah iklan; diganti di test.
  final DateTime Function() clock;

  Progress _progress;
  Progress get progress => _progress;

  Set<int> _tutorialsDone;

  /// Id level yang tutorialnya sudah selesai (dikerjakan atau dilewati).
  Set<int> get tutorialsDone => _tutorialsDone;

  bool isTutorialDone(int id) => _tutorialsDone.contains(id);

  Level? levelById(int id) {
    for (final level in levels) {
      if (level.id == id) return level;
    }
    return null;
  }

  Chapter? chapter(int number) => chapterNumbered(chapters, number);

  /// Babak yang dibuka tombol Main.
  Chapter get currentChapter => chapterToPlay(chapters, _progress);

  /// Bintang paling banyak semua level ("31/60").
  int get maxStars => levels.length * Progress.maxStars;

  /// Koin yang didapat kalau level [id] selesai dengan [stars] bintang
  /// sekarang: hanya bintang yang baru.
  int coinsFor(int id, int stars) =>
      coinsForStars(_progress.starsOf(id), stars);

  /// Mencatat hasil level [id] lalu menyimpannya kalau lebih baik, dan
  /// menambah koin untuk bintang yang baru. Gagal (0 bintang) tidak
  /// dicatat.
  Future<void> record(int id, int stars) async {
    final earned = coinsFor(id, stars);
    final next = _progress.record(id, stars);
    if (identical(next, _progress)) return;
    _progress = next;
    _coins += earned;
    notifyListeners();
    await _save({_Part.progress, if (earned > 0) _Part.coins});
  }

  int _coins;
  Map<int, int> _hints;

  /// Level yang tingkat petunjuknya sedang dibuka (menunggu iklan), supaya
  /// ketukan kedua tidak membuka atau membayar dua kali.
  final _unlocking = <int>{};

  @override
  int get coins => _coins;

  @override
  int hintTier(int levelId) => _hints[levelId] ?? 0;

  @override
  Future<HintUnlock> unlockHint(int levelId, int tier, HintPay pay) async {
    bool ready() =>
        tier >= 1 &&
        tier <= maxHintTier &&
        tier == hintTier(levelId) + 1 &&
        !_unlocking.contains(levelId);
    if (!ready()) return HintUnlock.notReady;
    switch (pay) {
      case HintPay.coins:
        final cost = hintCost(tier);
        if (_coins < cost) return HintUnlock.notEnoughCoins;
        _coins -= cost;
      case HintPay.ad:
        _unlocking.add(levelId);
        bool watched;
        try {
          watched = await hintAds.show();
        } on Object {
          // SDK iklan yang gagal dimuat dengan error dianggap iklan gagal.
          watched = false;
        } finally {
          _unlocking.remove(levelId);
        }
        if (!watched) return HintUnlock.adFailed;
        if (!ready()) return HintUnlock.notReady;
    }
    _hints = Map.unmodifiable({..._hints, levelId: tier});
    notifyListeners();
    await _save({_Part.hints, if (pay == HintPay.coins) _Part.coins});
    return HintUnlock.opened;
  }

  // ── Rumah Oyen ──────────────────────────────────────────────────────

  Home _home;

  /// Barang dan tata letak kamar, kucing, aksesoris, dan stok camilan.
  Home get home => _home;

  HomeNeeds _needs;

  /// Kebutuhan kucing, mangkuk, dan hari hadiah kucing. Bar dibaca lewat
  /// [catNeeds] supaya sudah diturunkan ke jam sekarang.
  HomeNeeds get needs => _needs;

  /// Lapar dan Senang [kitty] sekarang.
  CatNeeds catNeeds(KittyId kitty) => _needs.of(kitty, clock());

  /// [kitty] tinggal di kamar, belum makan dari isi mangkuk sekarang, dan
  /// Lapar-nya di bawah [bowlHungerLimit].
  bool canEatFromBowl(KittyId kitty) =>
      _home.ownsKitty(kitty) && _needs.canEatFromBowl(kitty, clock());

  /// Gelembung koin [kitty] boleh diambil.
  bool canClaimKittyReward(KittyId kitty) =>
      _home.ownsKitty(kitty) && _needs.canClaim(kitty, clock());

  /// Menerapkan aksi rumah yang sudah lolos syaratnya. Keadaan berubah
  /// sebelum `await` pertama, jadi ketukan kedua melihat hasil ketukan
  /// pertama dan tidak membayar dua kali. [coins] negatif = membayar.
  Future<bool> _changeHome(
    Set<_Part> parts, {
    Home? home,
    HomeNeeds? needs,
    int coins = 0,
  }) async {
    if (home != null) _home = home;
    if (needs != null) _needs = needs;
    _coins += coins;
    notifyListeners();
    await _save({...parts, if (coins != 0) _Part.coins});
    return true;
  }

  /// Membeli barang [id]; langsung ditaruh di posisi bawaannya. Gagal tanpa
  /// efek kalau sudah dimiliki atau koin kurang, begitu juga pembelian lain.
  Future<bool> buyItem(RoomItemId id) async {
    if (!_home.room.canBuy(id, _coins)) return false;
    return _changeHome(
      {_Part.home},
      home: _home.copyWith(room: _home.room.buy(id)),
      coins: -roomItemOf(id).price,
    );
  }

  /// Membeli kucing [id]; bar-nya mulai penuh sekarang.
  Future<bool> buyKitty(KittyId id) async {
    if (!_home.canBuyKitty(id, _coins)) return false;
    return _changeHome(
      {_Part.home, _Part.needs},
      home: _home.copyWith(kitties: {..._home.kitties, id}),
      needs: _needs.adopted(id, clock()),
      coins: -kittyOf(id).price,
    );
  }

  /// Membeli aksesoris [id] untuk semua kucing; belum dipakai.
  Future<bool> buyAccessory(AccessoryId id) async {
    if (!_home.closet.canBuy(id, _coins)) return false;
    return _changeHome(
      {_Part.home},
      home: _home.copyWith(closet: _home.closet.buy(id)),
      coins: -accessoryOf(id).price,
    );
  }

  /// Membeli satu camilan [id]; gagal kalau koin kurang atau stok penuh.
  Future<bool> buySnack(SnackId id) async {
    final price = snackOf(id).price;
    if (_coins < price || !_home.pantry.canAdd(id)) return false;
    return _changeHome(
      {_Part.home},
      home: _home.copyWith(pantry: _home.pantry.add(id)),
      coins: -price,
    );
  }

  /// [kitty] memakai aksesoris [id], atau melepasnya kalau [id] null.
  /// Gagal kalau kucing atau aksesorisnya tidak dimiliki.
  Future<bool> wearAccessory(KittyId kitty, AccessoryId? id) async {
    if (!_home.ownsKitty(kitty)) return false;
    if (id != null && !_home.closet.owns(id)) return false;
    if (_home.closet.wearingOf(kitty) == id) return true;
    return _changeHome({
      _Part.home,
    }, home: _home.copyWith(closet: _home.closet.wear(kitty, id)));
  }

  /// Menaruh barang [id] di [spot], juga dari Gudang.
  Future<bool> placeItem(RoomItemId id, Spot spot) async {
    if (!_home.room.owns(id)) return false;
    if (_home.room.spotOf(id) == spot) return true;
    return _changeHome({
      _Part.home,
    }, home: _home.copyWith(room: _home.room.place(id, spot)));
  }

  /// Memindahkan barang [id] ke Gudang; mangkuk tidak bisa.
  Future<bool> storeItem(RoomItemId id) async {
    final room = _home.room.store(id);
    if (identical(room, _home.room)) return false;
    return _changeHome({_Part.home}, home: _home.copyWith(room: room));
  }

  /// Memberi [kitty] satu camilan [snack] dari stok.
  Future<bool> feed(KittyId kitty, SnackId snack) async {
    final pantry = _home.pantry.take(snack);
    if (!_home.ownsKitty(kitty) || pantry == null) return false;
    return _changeHome(
      {_Part.home, _Part.needs},
      home: _home.copyWith(pantry: pantry),
      needs: _needs.feed(kitty, snackOf(snack), clock()),
    );
  }

  /// Mengelus [kitty]; gagal kalau batas elus jam ini habis.
  Future<bool> pet(KittyId kitty) async {
    final needs = _home.ownsKitty(kitty) ? _needs.pet(kitty, clock()) : null;
    if (needs == null) return false;
    return _changeHome({_Part.needs}, needs: needs);
  }

  /// [kitty] memakai mainan [item] yang ditaruh di kamar; gagal kalau
  /// [item] bukan mainan, tidak ditaruh, atau [kitty] baru saja bermain.
  Future<bool> play(KittyId kitty, RoomItemId item) async {
    final usable =
        _home.ownsKitty(kitty) &&
        roomItemOf(item).toy &&
        _home.room.isPlaced(item);
    final needs = usable ? _needs.play(kitty, clock()) : null;
    if (needs == null) return false;
    return _changeHome({_Part.needs}, needs: needs);
  }

  /// Selesai menghias: Senang semua kucing naik, paling banyak sekali per
  /// jam. Tata letaknya sudah tersimpan lewat [placeItem] dan [storeItem].
  Future<bool> finishDecorating() async {
    final needs = _needs.finishDecorating(_home.kitties, clock());
    if (needs == null) return false;
    return _changeHome({_Part.needs}, needs: needs);
  }

  /// [kitty] makan dari mangkuk.
  Future<bool> eatFromBowl(KittyId kitty) async {
    final needs = _home.ownsKitty(kitty)
        ? _needs.eatFromBowl(kitty, clock())
        : null;
    if (needs == null) return false;
    return _changeHome({_Part.needs}, needs: needs);
  }

  /// Mengambil gelembung koin [kitty] (+[kittyRewardCoins]).
  Future<bool> claimKittyReward(KittyId kitty) async {
    final needs = _home.ownsKitty(kitty) ? _needs.claim(kitty, clock()) : null;
    if (needs == null) return false;
    return _changeHome({_Part.needs}, needs: needs, coins: kittyRewardCoins);
  }

  DailyRewards _rewards;

  /// Iklan koin sedang diputar, supaya ketukan kedua tidak memutar dua iklan.
  bool _watchingAd = false;

  int get _today => dayNumber(clock());

  /// Hari saat pendengar terakhir diberi tahu soal hadiah harian (awalnya
  /// hari controller dibuat).
  int _seenDay;

  /// Memberi tahu pendengar kalau hari sudah berganti (bonus dan jatah
  /// iklan baru), mis. saat aplikasi kembali dari latar belakang esok hari.
  void refreshDay() {
    final today = _today;
    if (today == _seenDay) return;
    _seenDay = today;
    notifyListeners();
  }

  /// Bonus harian hari ini belum diambil.
  bool get canClaimBonus => _rewards.canClaimBonus(_today);

  /// Sisa iklan koin hari ini.
  int get adsLeft => _rewards.adsLeft(_today);

  /// Mengambil bonus harian ([dailyBonusCoins]); false tanpa efek kalau
  /// hari ini sudah diambil.
  Future<bool> claimDailyBonus() async {
    final today = _today;
    if (!_rewards.canClaimBonus(today)) return false;
    _rewards = _rewards.claimBonus(today);
    _coins += dailyBonusCoins;
    notifyListeners();
    await _save({_Part.rewards, _Part.coins});
    return true;
  }

  /// Memutar satu iklan berhadiah; kalau selesai, menambah [adRewardCoins]
  /// dan menghitungnya di jatah hari itu. Iklan yang selesai tetap diberi
  /// hadiah walau hari berganti selama iklan.
  Future<AdReward> watchAdForCoins() async {
    if (_watchingAd) return AdReward.busy;
    if (adsLeft == 0) return AdReward.limitReached;
    _watchingAd = true;
    bool watched;
    try {
      watched = await coinAds.show();
    } on Object {
      // SDK iklan yang gagal dimuat dengan error dianggap iklan gagal.
      watched = false;
    } finally {
      _watchingAd = false;
    }
    if (!watched) return AdReward.failed;
    _rewards = _rewards.watchedAd(_today);
    _coins += adRewardCoins;
    notifyListeners();
    await _save({_Part.rewards, _Part.coins});
    return AdReward.rewarded;
  }

  AppLanguage _language;

  /// Bahasa pilihan pemain ([AppLanguage.system] = ikuti HP).
  AppLanguage get language => _language;

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    await _save({_Part.language});
  }

  /// "Lihat tutorial lagi": tutorial level 1, 3, dan 6 muncul lagi.
  Future<void> replayTutorials() async {
    if (_tutorialsDone.isEmpty) return;
    _tutorialsDone = const {};
    notifyListeners();
    await _save({_Part.tutorials});
  }

  /// "Reset progres": menghapus bintang, koin, petunjuk, tutorial,
  /// dan isi rumah (barang, tata letak, kucing, aksesoris, stok); bar Oyen
  /// kembali penuh. Hadiah harian dan hadiah kucing hari ini (supaya tidak
  /// bisa diklaim ulang) dan bahasa tetap. Koin disimpan 0, bukan dihitung
  /// ulang dari bintang.
  Future<void> resetProgress() async {
    _progress = Progress.empty;
    _coins = 0;
    _hints = const {};
    _home = Home.initial;
    _needs = _needs.reset(clock());
    _tutorialsDone = const {};
    notifyListeners();
    await _save({
      _Part.progress,
      _Part.coins,
      _Part.hints,
      _Part.home,
      _Part.needs,
      _Part.tutorials,
    });
  }

  /// Menandai tutorial level [id] selesai supaya tidak muncul lagi.
  Future<void> finishTutorial(int id) async {
    if (isTutorialDone(id)) return;
    _tutorialsDone = Set.unmodifiable({..._tutorialsDone, id});
    notifyListeners();
    await _save({_Part.tutorials});
  }

  // ── Simpanan ────────────────────────────────────────────────────────

  /// Bagian yang berubah tapi belum tersimpan (menunggu giliran atau gagal
  /// ditulis; bagian yang sedang ditulis tidak termasuk).
  final _unsaved = <_Part>{};

  /// Tulisan berjalan satu per satu, supaya tulisan lama yang lambat tidak
  /// menimpa yang baru.
  Future<void> _saving = Future.value();

  /// Ada perubahan yang menunggu atau gagal disimpan, mis. penyimpanan
  /// perangkat gagal. Tulisan yang sedang berjalan tidak dihitung.
  bool get hasUnsavedChanges => _unsaved.isNotEmpty;

  /// Mencoba lagi menulis bagian yang gagal disimpan (mis. saat aplikasi
  /// ke latar belakang). Tidak pernah melempar.
  Future<void> retrySaves() => _save(const {});

  /// Menyimpan [parts] beserta bagian yang tertunda, urut [_Part], dengan
  /// nilai terbaru saat ditulis. Kegagalan tidak dilempar: keadaan di
  /// memori tetap, bagian yang gagal dan sesudahnya dicoba lagi di simpan
  /// berikutnya.
  Future<void> _save(Set<_Part> parts) {
    _unsaved.addAll(parts);
    return _saving = _saving.then((_) => _writeUnsaved());
  }

  Future<void> _writeUnsaved() async {
    while (true) {
      // Selalu bagian paling awal yang belum tersimpan, juga yang ditandai
      // lagi selama tulisan sebelumnya berjalan, supaya urutan [_Part] tetap.
      final part = _Part.values.where(_unsaved.contains).firstOrNull;
      if (part == null) return;
      // Dihapus sebelum ditulis: perubahan selama menulis menandainya lagi.
      _unsaved.remove(part);
      try {
        await _write(part);
      } on Object catch (error) {
        _unsaved.add(part);
        debugPrint('Progres gagal disimpan ($part): $error');
        return;
      }
    }
  }

  Future<void> _write(_Part part) => switch (part) {
    _Part.progress => store.save(_progress),
    _Part.tutorials => store.saveTutorials(_tutorialsDone),
    _Part.coins => store.saveCoins(_coins),
    _Part.hints => store.saveHints(_hints),
    _Part.home => store.saveHome(_home),
    _Part.needs => store.saveNeeds(_needs),
    _Part.rewards => store.saveRewards(_rewards),
    _Part.language => store.saveLanguage(_language),
  };
}

/// Membagikan [ProgressController] ke bawah; widget yang membacanya lewat
/// [of] dibangun ulang saat progres berubah.
class ProgressScope extends InheritedNotifier<ProgressController> {
  const ProgressScope({
    super.key,
    required ProgressController progress,
    required super.child,
  }) : super(notifier: progress);

  static ProgressController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope tidak ada di atas $context');
    return scope!.notifier!;
  }

  /// Seperti [of], tanpa dibangun ulang saat progres berubah (untuk aksi
  /// dan data level yang tetap).
  static ProgressController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope tidak ada di atas $context');
    return scope!.notifier!;
  }
}
