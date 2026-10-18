import 'package:flutter/widgets.dart';

import '../game/model/chapter.dart';
import '../game/model/costumes.dart';
import '../game/model/hints.dart';
import '../game/model/progress.dart';
import '../game/render/oyen.dart';
import '../game/sim/sim.dart';
import 'hint_source.dart';
import 'progress_store.dart';
import 'rewarded_ads.dart';

/// Data level dan progres pemain untuk semua layar: bintang, tutorial,
/// koin, petunjuk, dan kostum Oyen. Dimuat sekali sebelum aplikasi jalan (`main`), lalu
/// dibagikan lewat [ProgressScope].
class ProgressController extends ChangeNotifier implements HintSource {
  ProgressController({
    required List<Level> levels,
    required this.store,
    this._progress = Progress.empty,
    Set<int> tutorialsDone = const {},
    this._coins = 0,
    Map<int, int> hints = const {},
    Wardrobe? wardrobe,
    RewardedAds? ads,
  }) : levels = List.unmodifiable(levels),
       _tutorialsDone = Set.unmodifiable(tutorialsDone),
       _hints = Map.unmodifiable(hints),
       _wardrobe = wardrobe ?? Wardrobe.initial,
       ads = ads ?? FakeRewardedAds(),
       chapters = List.unmodifiable(chaptersOf(levels));

  /// Memuat progres, tutorial, koin, petunjuk, dan kostum dari [store]. Koin yang
  /// belum pernah disimpan (progres dari sebelum ada koin) dihitung dari
  /// total bintang.
  static Future<ProgressController> load({
    required List<Level> levels,
    required ProgressStore store,
    RewardedAds? ads,
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
      ads: ads,
    );
  }

  final List<Level> levels;
  final List<Chapter> chapters;
  final ProgressStore store;

  /// Iklan berhadiah untuk membuka petunjuk.
  final RewardedAds ads;

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
