import 'package:flutter/widgets.dart';

import '../game/model/chapter.dart';
import '../game/model/costumes.dart';
import '../game/model/hints.dart';
import '../game/model/progress.dart';
import '../game/model/rewards.dart';
import '../game/render/oyen.dart';
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

/// Data level dan progres pemain untuk semua layar: bintang, tutorial,
/// koin, petunjuk, kostum Oyen, hadiah harian, dan bahasa. Dimuat sekali sebelum
/// aplikasi jalan (`main`), lalu dibagikan lewat [ProgressScope].
class ProgressController extends ChangeNotifier implements HintSource {
  ProgressController({
    required List<Level> levels,
    required this.store,
    this._progress = Progress.empty,
    Set<int> tutorialsDone = const {},
    this._coins = 0,
    Map<int, int> hints = const {},
    Wardrobe? wardrobe,
    this._rewards = DailyRewards.initial,
    this._language = AppLanguage.system,
    RewardedAds? ads,
    DateTime Function()? clock,
  }) : levels = List.unmodifiable(levels),
       _tutorialsDone = Set.unmodifiable(tutorialsDone),
       _hints = Map.unmodifiable(hints),
       _wardrobe = wardrobe ?? Wardrobe.initial,
       clock = clock ?? DateTime.now,
       _seenDay = dayNumber((clock ?? DateTime.now)()),
       ads = ads ?? FakeRewardedAds(),
       chapters = List.unmodifiable(chaptersOf(levels));

  /// Memuat progres, tutorial, koin, petunjuk, kostum, hadiah harian, dan
  /// bahasa dari [store]. Koin yang belum pernah disimpan (progres dari sebelum ada
  /// koin) dihitung dari total bintang.
  static Future<ProgressController> load({
    required List<Level> levels,
    required ProgressStore store,
    RewardedAds? ads,
    DateTime Function()? clock,
  }) async {
    final progress = await store.load();
    return ProgressController(
      levels: levels,
      store: store,
      progress: progress,
      tutorialsDone: await store.loadTutorials(),
      coins: await store.loadCoins() ?? progress.totalStars * coinsPerStar,
      hints: await store.loadHints(),
      wardrobe: await store.loadWardrobe(),
      rewards: await store.loadRewards(),
      language: await store.loadLanguage(),
      ads: ads,
      clock: clock,
    );
  }

  final List<Level> levels;
  final List<Chapter> chapters;
  final ProgressStore store;

  /// Iklan berhadiah untuk membuka petunjuk dan menambah koin.
  final RewardedAds ads;

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
    await Future.wait([
      store.save(next),
      if (earned > 0) store.saveCoins(_coins),
    ]);
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
          watched = await ads.show();
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
    await Future.wait([
      store.saveHints(_hints),
      if (pay == HintPay.coins) store.saveCoins(_coins),
    ]);
    return HintUnlock.opened;
  }

  Wardrobe _wardrobe;

  /// Kostum yang dimiliki dan yang sedang dipakai Oyen.
  Wardrobe get wardrobe => _wardrobe;

  /// Membeli kostum [id] dengan koin lalu langsung memakainya. Gagal tanpa
  /// efek kalau sudah dimiliki atau koin kurang. Semua perubahan terjadi
  /// sebelum menyimpan, jadi ketukan kedua melihat kostumnya sudah dimiliki.
  Future<bool> buyCostume(OyenCostume id) async {
    if (!_wardrobe.canBuy(id, _coins)) return false;
    _coins -= costumeOf(id).price;
    _wardrobe = _wardrobe.buy(id);
    notifyListeners();
    await Future.wait([store.saveWardrobe(_wardrobe), store.saveCoins(_coins)]);
    return true;
  }

  /// Memakai kostum [id]; gagal kalau belum dimiliki.
  Future<bool> wearCostume(OyenCostume id) async {
    if (!_wardrobe.owns(id)) return false;
    if (_wardrobe.wearing == id) return true;
    _wardrobe = _wardrobe.wear(id);
    notifyListeners();
    await store.saveWardrobe(_wardrobe);
    return true;
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
    await Future.wait([store.saveRewards(_rewards), store.saveCoins(_coins)]);
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
      watched = await ads.show();
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
    await Future.wait([store.saveRewards(_rewards), store.saveCoins(_coins)]);
    return AdReward.rewarded;
  }

  AppLanguage _language;

  /// Bahasa pilihan pemain ([AppLanguage.system] = ikuti HP).
  AppLanguage get language => _language;

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    await store.saveLanguage(language);
  }

  /// "Lihat tutorial lagi": tutorial level 1, 3, dan 6 muncul lagi.
  Future<void> replayTutorials() async {
    if (_tutorialsDone.isEmpty) return;
    _tutorialsDone = const {};
    notifyListeners();
    await store.saveTutorials(_tutorialsDone);
  }

  /// "Reset progres": menghapus bintang, koin, petunjuk, kostum, dan
  /// tutorial. Hadiah harian hari ini (supaya tidak bisa diklaim ulang) dan
  /// bahasa tetap. Koin disimpan 0, bukan dihitung ulang dari bintang.
  Future<void> resetProgress() async {
    _progress = Progress.empty;
    _coins = 0;
    _hints = const {};
    _wardrobe = Wardrobe.initial;
    _tutorialsDone = const {};
    notifyListeners();
    await Future.wait([
      store.save(_progress),
      store.saveCoins(_coins),
      store.saveHints(_hints),
      store.saveWardrobe(_wardrobe),
      store.saveTutorials(_tutorialsDone),
    ]);
  }

  /// Menandai tutorial level [id] selesai supaya tidak muncul lagi.
  Future<void> finishTutorial(int id) async {
    if (isTutorialDone(id)) return;
    _tutorialsDone = Set.unmodifiable({..._tutorialsDone, id});
    notifyListeners();
    await store.saveTutorials(_tutorialsDone);
  }
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
