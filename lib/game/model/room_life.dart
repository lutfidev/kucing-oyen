import 'dart:math' as math;

import 'home_items.dart';
import 'kitties.dart';

/// Kegiatan satu kucing di kamar.
enum CatActivity {
  /// Duduk atau menjilat di tempat.
  idle,

  /// Berjalan ke barang tujuannya.
  walking,

  /// Memakai barang (digambar oleh barangnya).
  using,

  /// Makan di mangkuk (memakai mangkuk).
  eating,

  /// Lesu: tidak berkeliling, hanya ke mangkuk kalau boleh makan.
  sad,

  /// Bereaksi karena dielus, diberi camilan, atau memakai aksesoris.
  reacting,
}

/// Pose kucing di luar barang. Barang yang dipakai menentukan pose kucing
/// di dalamnya sendiri.
enum LifePose { idle, lick, walk, sad, happy, petted, eat }

/// Arah hadap saat berjalan.
enum LifeHeading { down, left, right }

/// Peristiwa rutinitas yang diteruskan ke progres pemain.
sealed class LifeEvent {
  const LifeEvent(this.kitty);

  final KittyId kitty;
}

/// Kucing sampai di mangkuk: model kebutuhan memutuskan boleh makan atau
/// tidak (`ProgressController.eatFromBowl`).
class ReachedBowl extends LifeEvent {
  const ReachedBowl(super.kitty);

  @override
  bool operator ==(Object other) =>
      other is ReachedBowl && other.kitty == kitty;

  @override
  int get hashCode => kitty.hashCode;
}

/// Kucing mulai memakai mainan [item] (`ProgressController.play`).
class UsedToy extends LifeEvent {
  const UsedToy(super.kitty, this.item);

  final RoomItemId item;

  @override
  bool operator ==(Object other) =>
      other is UsedToy && other.kitty == kitty && other.item == item;

  @override
  int get hashCode => Object.hash(kitty, item);
}

/// Lama tiap kegiatan (detik, `AnimasiKucing.dc.html` dan rute
/// `Kamar.dc.html`; tidur diperpanjang supaya tidak gelisah).
const lifeIdleSeconds = 2.6;
const lifeUseSeconds = 3.0;
const lifeSleepSeconds = 6.0;
const lifeEatSeconds = 3.0;

/// Kecepatan jalan dalam px desain per detik (21c: ±70 px/detik).
const lifeWalkSpeed = 70.0;

/// Bobot undian tujuan: diam di tempat, dan barang menurut kegunaannya.
const lifeIdleWeight = 3;
const lifeUseWeights = <ItemUse, int>{
  ItemUse.sleep: 3,
  ItemUse.play: 3,
  ItemUse.lounge: 2,
  ItemUse.hide: 2,
  ItemUse.scratch: 2,
  ItemUse.watch: 2,
  ItemUse.sit: 2,
  ItemUse.eat: 0,
};

/// Keadaan satu kucing.
class CatLife {
  CatLife._(this.kitty, this.spot, this.remaining);

  final KittyId kitty;
  Spot spot;
  LifeHeading heading = LifeHeading.down;
  CatActivity activity = CatActivity.idle;
  LifePose pose = LifePose.idle;

  /// Barang yang dituju atau dipakai.
  RoomItemId? item;

  /// Detik sampai kegiatan diam/pakai/reaksi selesai.
  double remaining;

  /// Detik sejak kegiatan ini mulai (untuk bingkai jalan).
  double elapsed = 0;

  /// Memakai barang (termasuk makan): kucingnya digambar barang itu.
  bool get isInItem =>
      activity == CatActivity.using || activity == CatActivity.eating;

  @override
  String toString() =>
      'CatLife(${kitty.name}, ${activity.name}, ${item?.name}, $spot)';
}

/// Rutinitas kamar (desain 21c): tiap kucing diam, berjalan ke barang
/// lalu memakainya, makan di mangkuk kalau lapar, lesu, atau bereaksi.
/// Satu barang dipakai satu kucing. Dimajukan [advance] dari satu jam
/// kamar; tujuan diundi [random] (beri seed di test).
///
/// Posisi memakai [Spot] kotak kucing di lantai. [spanX] dan [spanY] =
/// px desain per satu satuan [Spot], untuk kecepatan jalan.
class RoomLife {
  RoomLife({required this.random, required this.spanX, required this.spanY});

  final math.Random random;
  final double spanX;
  final double spanY;

  /// Rutinitas berhenti (kartu terbuka, mode hias, atau ada reaksi).
  bool paused = false;

  final _cats = <KittyId, CatLife>{};
  Map<RoomItemId, Spot> _targets = const {};
  Map<RoomItemId, ItemUse> _uses = const {};
  Set<RoomItemId> _toys = const {};
  Set<KittyId> _hungry = const {};
  Set<KittyId> _sad = const {};

  Iterable<CatLife> get cats => _cats.values;

  CatLife of(KittyId kitty) => _cats[kitty]!;

  /// Barang yang sedang dituju atau dipakai, dan kucingnya.
  Map<RoomItemId, KittyId> get users => {
    for (final cat in _cats.values) ?cat.item: cat.kitty,
  };

  /// Kucing yang memakai [item] sekarang (bukan sekadar menuju).
  KittyId? userOf(RoomItemId item) {
    for (final cat in _cats.values) {
      if (cat.item == item && cat.isInItem) return cat.kitty;
    }
    return null;
  }

  /// Menyamakan isi kamar: kucing ([homes] = tempat awal kucing baru),
  /// tempat berdiri untuk memakai tiap barang ([targets]), kegunaannya,
  /// mainan, kucing yang boleh makan dari mangkuk, dan yang lesu. Tujuan
  /// yang hilang atau pindah membatalkan perjalanan dan pemakaiannya.
  void sync({
    required Map<KittyId, Spot> homes,
    required Map<RoomItemId, Spot> targets,
    required Map<RoomItemId, ItemUse> uses,
    Set<RoomItemId> toys = const {},
    Set<KittyId> hungry = const {},
    Set<KittyId> sad = const {},
  }) {
    _cats.removeWhere((kitty, _) => !homes.containsKey(kitty));
    for (final MapEntry(key: kitty, value: home) in homes.entries) {
      _cats.putIfAbsent(
        kitty,
        () => CatLife._(kitty, home, random.nextDouble() * lifeIdleSeconds),
      );
    }
    for (final cat in _cats.values) {
      final item = cat.item;
      if (item != null && _targets[item] != targets[item]) _rest(cat);
    }
    _targets = Map.of(targets);
    _uses = Map.of(uses);
    _toys = Set.of(toys);
    _hungry = Set.of(hungry);
    _sad = Set.of(sad);
    for (final cat in _cats.values) {
      if (cat.activity == CatActivity.idle && _sad.contains(cat.kitty)) {
        cat
          ..activity = CatActivity.sad
          ..pose = LifePose.sad;
      } else if (cat.activity == CatActivity.sad && !_sad.contains(cat.kitty)) {
        cat
          ..activity = CatActivity.idle
          ..pose = LifePose.idle;
      }
    }
  }

  /// Semua kucing berhenti di tempat dan melepas barangnya (mode hias).
  void interrupt() {
    for (final cat in _cats.values) {
      _rest(cat);
    }
  }

  /// Kucing [kitty] berhenti di tempat (reaksi selesai).
  void rest(KittyId kitty) {
    if (_cats[kitty] case final cat?) _rest(cat);
  }

  /// Kucing [kitty] bereaksi dengan [pose] selama [seconds], lalu lanjut
  /// dari langkah berikutnya. Barang yang dipakainya dilepas.
  void react(KittyId kitty, LifePose pose, double seconds) {
    final cat = _cats[kitty];
    if (cat == null) return;
    cat
      ..item = null
      ..activity = CatActivity.reacting
      ..pose = pose
      ..heading = LifeHeading.down
      ..remaining = seconds
      ..elapsed = 0;
  }

  /// Maju [seconds] detik; peristiwa yang terjadi selama itu.
  List<LifeEvent> advance(double seconds) {
    if (paused || seconds <= 0) return const [];
    final events = <LifeEvent>[];
    for (final cat in _cats.values) {
      cat.elapsed += seconds;
      if (cat.activity == CatActivity.walking) {
        _walk(cat, seconds, events);
        continue;
      }
      cat.remaining -= seconds;
      if (cat.remaining <= 0) _next(cat, events);
    }
    return events;
  }

  void _rest(CatLife cat) {
    final sad = _sad.contains(cat.kitty);
    cat
      ..item = null
      ..activity = sad ? CatActivity.sad : CatActivity.idle
      ..pose = sad ? LifePose.sad : LifePose.idle
      ..heading = LifeHeading.down
      ..remaining = lifeIdleSeconds
      ..elapsed = 0;
  }

  void _walk(CatLife cat, double seconds, List<LifeEvent> events) {
    final target = _targets[cat.item];
    if (target == null) return _rest(cat);
    final dx = (target.x - cat.spot.x) * spanX;
    final dy = (target.y - cat.spot.y) * spanY;
    final distance = math.sqrt(dx * dx + dy * dy);
    final step = lifeWalkSpeed * seconds;
    if (distance <= step) {
      cat.spot = target;
      _arrive(cat, events);
      return;
    }
    final f = step / distance;
    cat.spot = Spot(cat.spot.x + dx * f / spanX, cat.spot.y + dy * f / spanY);
  }

  void _arrive(CatLife cat, List<LifeEvent> events) {
    final item = cat.item!;
    final bowl = _uses[item] == ItemUse.eat;
    cat
      ..activity = bowl ? CatActivity.eating : CatActivity.using
      ..pose = LifePose.idle
      ..heading = LifeHeading.down
      ..elapsed = 0
      ..remaining = bowl
          ? lifeEatSeconds
          : _uses[item] == ItemUse.sleep
          ? lifeSleepSeconds
          : lifeUseSeconds;
    if (bowl) {
      events.add(ReachedBowl(cat.kitty));
    } else if (_toys.contains(item)) {
      events.add(UsedToy(cat.kitty, item));
    }
  }

  void _next(CatLife cat, List<LifeEvent> events) {
    final taken = users.keys.toSet();
    final bowl = _uses.entries
        .where((e) => e.value == ItemUse.eat && _targets.containsKey(e.key))
        .map((e) => e.key)
        .firstOrNull;
    final wasEating = cat.activity == CatActivity.eating;
    cat.item = null;
    if (bowl != null &&
        !wasEating &&
        _hungry.contains(cat.kitty) &&
        !taken.contains(bowl)) {
      return _go(cat, bowl, events);
    }
    if (_sad.contains(cat.kitty)) return _rest(cat);
    final options = <(RoomItemId?, int)>[
      (null, lifeIdleWeight),
      for (final MapEntry(key: item, value: use) in _uses.entries)
        if (!taken.contains(item) &&
            _targets.containsKey(item) &&
            (lifeUseWeights[use] ?? 0) > 0)
          (item, lifeUseWeights[use]!),
    ];
    final total = options.fold(0, (sum, o) => sum + o.$2);
    var roll = random.nextInt(total);
    for (final (item, weight) in options) {
      roll -= weight;
      if (roll >= 0) continue;
      if (item == null) {
        _rest(cat);
        cat.pose = random.nextBool() ? LifePose.idle : LifePose.lick;
        return;
      }
      return _go(cat, item, events);
    }
  }

  void _go(CatLife cat, RoomItemId item, List<LifeEvent> events) {
    final target = _targets[item]!;
    cat
      ..item = item
      ..activity = CatActivity.walking
      ..pose = LifePose.walk
      ..elapsed = 0
      ..heading = target.x < cat.spot.x
          ? LifeHeading.left
          : target.x > cat.spot.x
          ? LifeHeading.right
          : LifeHeading.down;
    if (target == cat.spot) _arrive(cat, events);
  }
}
