import 'dart:math' as math;

import 'home_items.dart';
import 'house.dart';
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

  /// Melompat dari tempat berdiri ke barang dinding lewat pijakannya.
  climbing,

  /// Melompat turun dari barang dinding ke tempat berdirinya.
  descending,

  /// Lesu: tidak berkeliling, hanya ke mangkuk kalau boleh makan.
  sad,

  /// Bereaksi karena dielus, diberi camilan, atau memakai aksesoris.
  reacting,

  /// Berjalan masuk ke bukaan pintu, menghilang di balik kusen.
  leaving,

  /// Muncul dari bukaan pintu di ruangan tujuan.
  entering,
}

extension CatActivityPlace on CatActivity {
  /// Kucing digambar sendiri di lantai (tidak di dalam barang, tidak
  /// sedang melompat, dan tidak sedang lewat pintu).
  bool get onFloor => switch (this) {
    CatActivity.using ||
    CatActivity.eating ||
    CatActivity.climbing ||
    CatActivity.descending ||
    CatActivity.leaving ||
    CatActivity.entering => false,
    _ => true,
  };
}

/// Pose kucing di luar barang. Barang yang dipakai menentukan pose kucing
/// di dalamnya sendiri. [sleep] dan [lounge] = tidur dan rebahan di tempat
/// nyaman.
enum LifePose { idle, lick, walk, sad, happy, petted, eat, sleep, lounge }

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

/// Kucing selesai keluar dari ruangan [from] lewat pintu.
class LeftRoom extends LifeEvent {
  const LeftRoom(super.kitty, this.from);

  final HouseRoom from;

  @override
  bool operator ==(Object other) =>
      other is LeftRoom && other.kitty == kitty && other.from == from;

  @override
  int get hashCode => Object.hash(kitty, from, 'left');
}

/// Kucing selesai masuk ke ruangan [to] dari pintu.
class EnteredRoom extends LifeEvent {
  const EnteredRoom(super.kitty, this.to);

  final HouseRoom to;

  @override
  bool operator ==(Object other) =>
      other is EnteredRoom && other.kitty == kitty && other.to == to;

  @override
  int get hashCode => Object.hash(kitty, to, 'entered');
}

/// Lama tiap kegiatan (detik, `AnimasiKucing.dc.html` dan rute
/// `Kamar.dc.html`; tidur diperpanjang supaya tidak gelisah).
const lifeIdleSeconds = 2.6;
const lifeUseSeconds = 3.0;
const lifeSleepSeconds = 6.0;
const lifeEatSeconds = 3.0;

/// Lama satu lompatan ke atau dari barang dinding (detik).
const lifeHopSeconds = 0.45;

/// Kecepatan jalan dalam px desain per detik (21c: ±70 px/detik).
const lifeWalkSpeed = 70.0;

/// Barang yang hanya hiasan, tidak pernah dipakai kucing kamar (lukisan
/// dan jam dinding tidak punya pijakan yang masuk akal).
const lifeDecorOnly = {RoomItemId.lukisan, RoomItemId.jam};

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

/// Tempat nyaman tanpa barang (spec "Kucing di dua ruangan"): kaki kucing
/// di ([x], [y]) px desain area rumah, [pose] dan [heading] selama di sana,
/// [seconds] lamanya (diacak 70–130%), [weight] bobot undian.
class LifePlace {
  const LifePlace(
    this.x,
    this.y, {
    required this.pose,
    this.heading = LifeHeading.down,
    this.seconds = lifeSleepSeconds,
    this.weight = 3,
  });

  final double x;
  final double y;
  final LifePose pose;
  final LifeHeading heading;
  final double seconds;
  final int weight;
}

/// Tempat nyaman tiap ruangan (desain `AdeganTengah`/`AdeganTeras`).
const lifePlaces = <HouseRoom, List<LifePlace>>{
  HouseRoom.living: [
    // Bawah jendela.
    LifePlace(146, 432, pose: LifePose.lounge),
    // Tengah lantai.
    LifePlace(200, 560, pose: LifePose.sleep),
    // Ambang pintu.
    LifePlace(345, 456, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
  ],
  HouseRoom.terrace: [
    // Petak matahari.
    LifePlace(182, 600, pose: LifePose.lounge),
    // Dekat pagar.
    LifePlace(282, 432, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
    // Dekat pot.
    LifePlace(296, 556, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
    // Ambang pintu.
    LifePlace(46, 456, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
  ],
};

/// Kucing lain (di ruangan yang sama) dalam [lifeCrowdRadius] px desain
/// dari tujuan membuat tujuan itu kurang menarik: bobotnya dikali
/// [lifeCrowdFactor] per kucing. Kucing menyebar, tapi sesekali tetap
/// berkumpul.
const lifeCrowdRadius = 90.0;
const lifeCrowdFactor = 0.25;

/// Bobot undian pindah ruangan sendiri, lama lewat pintu (keluar dan
/// masuk masing-masing), dan lama betah sesudah diajak (detik).
const lifeTravelWeight = 1;
const lifeDoorSeconds = 0.6;
const lifeStaySeconds = 300.0;

/// Cara satu kucing memakai satu barang: [stand] = tempat berdiri di lantai
/// sebelum memakai (kotak kucing seukuran kucing itu), [hops] = jumlah
/// lompatan dari situ ke barangnya (0 = barang lantai, langsung dipakai).
class LifeRoute {
  const LifeRoute(this.stand, {this.hops = 0});

  final Spot stand;
  final int hops;

  @override
  bool operator ==(Object other) =>
      other is LifeRoute && other.stand == stand && other.hops == hops;

  @override
  int get hashCode => Object.hash(stand, hops);

  @override
  String toString() => 'LifeRoute($stand, $hops)';
}

/// Keadaan satu kucing.
class CatLife {
  CatLife._(this.kitty, this.room, this.spot, this.remaining);

  final KittyId kitty;

  /// Ruangan tempat kucing berada (tidak disimpan).
  HouseRoom room;

  /// Titik kaki di lantai ruangan [room] (`HouseFloor`).
  Spot spot;
  LifeHeading heading = LifeHeading.down;
  CatActivity activity = CatActivity.idle;
  LifePose pose = LifePose.idle;

  /// Barang yang dituju atau dipakai.
  RoomItemId? item;

  /// Tempat nyaman yang dituju atau ditempati (indeks di
  /// `lifePlaces[room]`).
  int? place;

  /// Sedang berjalan ke ambang pintu untuk pindah ruangan.
  bool traveling = false;

  /// Detik sisa betah sesudah diajak: selama lebih dari 0, kucing tidak
  /// memilih pindah ruangan sendiri.
  double stayLeft = 0;

  /// Detik sampai kegiatan diam/pakai/reaksi/lewat pintu selesai.
  double remaining;

  /// Detik sejak kegiatan ini mulai (untuk bingkai jalan).
  double elapsed = 0;

  /// Jumlah lompatan ke barang yang dituju atau dipakai.
  int hops = 0;

  /// Kemajuan naik atau turun, 0–1 (lompatan ke-`floor(p * hops)`).
  double get hopProgress =>
      hops == 0 ? 0 : (elapsed / (hops * lifeHopSeconds)).clamp(0.0, 1.0);

  /// Kemajuan keluar atau masuk pintu, 0–1.
  double get doorProgress =>
      isPassing ? (elapsed / lifeDoorSeconds).clamp(0.0, 1.0) : 0;

  /// Melompat naik atau turun dari barang dinding.
  bool get isHopping =>
      activity == CatActivity.climbing || activity == CatActivity.descending;

  /// Sedang lewat pintu (keluar dari [room] atau masuk ke [room]).
  bool get isPassing =>
      activity == CatActivity.leaving || activity == CatActivity.entering;

  /// Memakai barang (termasuk makan): kucingnya digambar barang itu.
  bool get isInItem =>
      activity == CatActivity.using || activity == CatActivity.eating;

  @override
  String toString() =>
      'CatLife(${kitty.name}, ${room.name}, ${activity.name}, '
      '${item?.name}, $place, $spot)';
}

/// Tujuan undian "pindah ruangan".
const _travel = #travel;

/// Rutinitas rumah (desain 21c dan rumah dua ruangan): tiap kucing diam,
/// berjalan ke barang atau tempat nyaman di ruangannya, makan di mangkuk
/// kalau lapar (pindah ruangan dulu kalau mangkuknya di ruangan lain),
/// pindah ruangan lewat pintu, lesu, atau bereaksi. Satu barang dan satu
/// tempat nyaman dipakai satu kucing. Dimajukan [advance] dari satu jam
/// kamar; tujuan diundi [random] (beri seed di test).
///
/// Posisi memakai titik kaki [Spot] lantai [floor]; jarak jalan dalam px
/// desain lantai itu. [places] = tempat nyaman tiap ruangan,
/// [travelWeight] = bobot undian pindah ruangan sendiri (0 = tidak pernah).
class RoomLife {
  RoomLife({
    required this.random,
    this.floor = const HouseFloor(),
    this.places = lifePlaces,
    this.travelWeight = lifeTravelWeight,
  });

  final math.Random random;
  final HouseFloor floor;
  final Map<HouseRoom, List<LifePlace>> places;
  final int travelWeight;

  bool _paused = false;

  /// Rutinitas berhenti (kartu terbuka, mode hias, atau ada reaksi).
  /// Kucing yang sedang lewat pintu langsung selesai di ruangan tujuan,
  /// supaya tidak tertahan di balik kusen.
  bool get paused => _paused;
  set paused(bool value) {
    if (value && !_paused) {
      for (final cat in _cats.values) {
        if (cat.isPassing) _finishPassing(cat);
      }
    }
    _paused = value;
  }

  final _cats = <KittyId, CatLife>{};
  Map<RoomItemId, Map<KittyId, LifeRoute>> _targets = const {};
  Map<RoomItemId, ItemUse> _uses = const {};
  Map<RoomItemId, HouseRoom> _itemRooms = const {};
  Set<RoomItemId> _toys = const {};
  Set<KittyId> _hungry = const {};
  Set<KittyId> _sad = const {};

  Iterable<CatLife> get cats => _cats.values;

  CatLife of(KittyId kitty) => _cats[kitty]!;

  /// Barang yang sedang dituju atau dipakai, dan kucingnya.
  Map<RoomItemId, KittyId> get users => {
    for (final cat in _cats.values) ?cat.item: cat.kitty,
  };

  LifeRoute? _routeOf(RoomItemId? item, KittyId kitty) =>
      item == null ? null : _targets[item]?[kitty];

  /// Ruangan barang [item]; barang tanpa keterangan di ruang tengah.
  HouseRoom _roomOf(RoomItemId item) => _itemRooms[item] ?? HouseRoom.living;

  LifePlace? _placeOf(CatLife cat) {
    final i = cat.place;
    if (i == null) return null;
    final list = places[cat.room] ?? const [];
    return i < list.length ? list[i] : null;
  }

  Spot _placeSpot(LifePlace place) => floor.spotAtFeet(place.x, place.y);

  /// Kucing yang memakai [item] sekarang (bukan sekadar menuju).
  KittyId? userOf(RoomItemId item) {
    for (final cat in _cats.values) {
      if (cat.item == item && cat.isInItem) return cat.kitty;
    }
    return null;
  }

  /// Menyamakan isi rumah: kucing ([homes] = ruangan dan tempat awal
  /// kucing baru; kucing yang sudah ada tetap di ruangannya), rute tiap
  /// kucing ke tiap barang ([targets]; barang tanpa rute untuk seekor
  /// kucing tidak dituju kucing itu), kegunaannya, ruangan tiap barang
  /// ([itemRooms], tanpa keterangan = ruang tengah), mainan, kucing yang
  /// boleh makan dari mangkuk, dan yang lesu. Rute yang hilang atau
  /// berubah membatalkan perjalanan dan pemakaiannya.
  void sync({
    required Map<KittyId, (HouseRoom, Spot)> homes,
    required Map<RoomItemId, Map<KittyId, LifeRoute>> targets,
    required Map<RoomItemId, ItemUse> uses,
    Map<RoomItemId, HouseRoom> itemRooms = const {},
    Set<RoomItemId> toys = const {},
    Set<KittyId> hungry = const {},
    Set<KittyId> sad = const {},
  }) {
    _cats.removeWhere((kitty, _) => !homes.containsKey(kitty));
    for (final MapEntry(key: kitty, value: (room, spot)) in homes.entries) {
      _cats.putIfAbsent(
        kitty,
        () =>
            CatLife._(kitty, room, spot, random.nextDouble() * lifeIdleSeconds),
      );
    }
    for (final cat in _cats.values) {
      final item = cat.item;
      if (item != null &&
          (_routeOf(item, cat.kitty) != targets[item]?[cat.kitty] ||
              (itemRooms[item] ?? HouseRoom.living) != cat.room)) {
        _rest(cat);
      }
    }
    _targets = {
      for (final MapEntry(:key, :value) in targets.entries)
        if (!lifeDecorOnly.contains(key)) key: Map.of(value),
    };
    _uses = Map.of(uses);
    _itemRooms = Map.of(itemRooms);
    _toys = Set.of(toys);
    _hungry = Set.of(hungry);
    _sad = Set.of(sad);
    for (final cat in _cats.values) {
      if (cat.activity == CatActivity.idle && _sad.contains(cat.kitty)) {
        cat
          ..activity = CatActivity.sad
          ..pose = LifePose.sad
          ..place = null;
      } else if (cat.activity == CatActivity.sad && !_sad.contains(cat.kitty)) {
        cat
          ..activity = CatActivity.idle
          ..pose = LifePose.idle;
      }
    }
  }

  /// Semua kucing berhenti di tempat dan melepas barangnya (mode hias).
  /// Kucing yang sedang lewat pintu selesai di ruangan tujuan.
  void interrupt() {
    for (final cat in _cats.values) {
      if (cat.isPassing) {
        _finishPassing(cat);
      } else {
        _rest(cat);
      }
    }
  }

  /// Kucing [kitty] berhenti di tempat (reaksi selesai). Kucing yang
  /// sedang di atas (barang dinding atau lompatan ke sana) melanjutkan
  /// kegiatannya, supaya tidak pindah mendadak ke lantai.
  void rest(KittyId kitty) {
    final cat = _cats[kitty];
    if (cat == null || _isRaised(cat)) return;
    if (cat.isPassing) return _finishPassing(cat);
    _rest(cat);
  }

  /// Kucing di barang dinding atau sedang melompat ke atau darinya.
  static bool _isRaised(CatLife cat) =>
      cat.hops > 0 && (cat.isHopping || cat.activity == CatActivity.using);

  /// Kucing [kitty] bereaksi dengan [pose] selama [seconds], lalu lanjut
  /// dari langkah berikutnya. Barang yang dipakainya dilepas, kecuali
  /// kucing yang sedang di atas: ia tetap di barang dinding atau
  /// lompatannya (reaksinya hanya tampil di atasnya). Kucing yang sedang
  /// lewat pintu bereaksi di ambang ruangan tujuan.
  void react(KittyId kitty, LifePose pose, double seconds) {
    final cat = _cats[kitty];
    if (cat == null || _isRaised(cat)) return;
    if (cat.isPassing) _finishPassing(cat);
    cat
      ..item = null
      ..place = null
      ..traveling = false
      ..activity = CatActivity.reacting
      ..pose = pose
      ..heading = LifeHeading.down
      ..remaining = seconds
      ..elapsed = 0
      ..hops = 0;
  }

  /// Maju [seconds] detik; peristiwa yang terjadi selama itu.
  List<LifeEvent> advance(double seconds) {
    if (paused || seconds <= 0) return const [];
    final events = <LifeEvent>[];
    for (final cat in _cats.values) {
      cat.elapsed += seconds;
      if (cat.stayLeft > 0) {
        cat.stayLeft = math.max(0, cat.stayLeft - seconds);
      }
      if (cat.activity == CatActivity.walking) {
        _walk(cat, seconds, events);
        continue;
      }
      cat.remaining -= seconds;
      if (cat.remaining > 0) continue;
      switch (cat.activity) {
        case CatActivity.climbing:
          _arrive(cat, events);
        case CatActivity.using when cat.hops > 0:
          cat
            ..activity = CatActivity.descending
            ..pose = LifePose.walk
            ..elapsed = 0
            ..remaining = cat.hops * lifeHopSeconds;
        case CatActivity.leaving:
          _enter(cat, events);
        case CatActivity.entering:
          cat.traveling = false;
          events.add(EnteredRoom(cat.kitty, cat.room));
          _next(cat, events, justEntered: true);
        default:
          _next(cat, events);
      }
    }
    return events;
  }

  void _rest(CatLife cat) {
    final sad = _sad.contains(cat.kitty);
    cat
      ..item = null
      ..place = null
      ..traveling = false
      ..activity = sad ? CatActivity.sad : CatActivity.idle
      ..pose = sad ? LifePose.sad : LifePose.idle
      ..heading = LifeHeading.down
      ..remaining = lifeIdleSeconds
      ..elapsed = 0
      ..hops = 0;
  }

  /// Keluar pintu selesai: kucing pindah ke ambang ruangan sebelah dan
  /// mulai masuk.
  void _enter(CatLife cat, List<LifeEvent> events) {
    events.add(LeftRoom(cat.kitty, cat.room));
    final to = cat.room.other;
    cat
      ..room = to
      ..spot = floor.threshold(to)
      ..activity = CatActivity.entering
      ..pose = LifePose.walk
      ..heading = to == HouseRoom.terrace ? LifeHeading.right : LifeHeading.left
      ..elapsed = 0
      ..remaining = lifeDoorSeconds;
  }

  /// Lewat pintu langsung selesai: kucing diam di ambang ruangan tujuan.
  void _finishPassing(CatLife cat) {
    if (cat.activity == CatActivity.leaving) {
      final to = cat.room.other;
      cat
        ..room = to
        ..spot = floor.threshold(to);
    }
    _rest(cat);
  }

  void _walk(CatLife cat, double seconds, List<LifeEvent> events) {
    final target = cat.traveling
        ? floor.threshold(cat.room)
        : switch (_placeOf(cat)) {
            final place? => _placeSpot(place),
            null => _routeOf(cat.item, cat.kitty)?.stand,
          };
    if (target == null) return _rest(cat);
    final from = floor.feetAt(cat.spot);
    final to = floor.feetAt(target);
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    final step = lifeWalkSpeed * seconds;
    if (distance <= step) {
      cat.spot = target;
      _reach(cat, events);
      return;
    }
    final f = step / distance;
    cat.spot = floor.spotAtFeet(from.x + dx * f, from.y + dy * f);
  }

  /// Sampai di tempat berdiri: ambang dilewati, tempat nyaman ditempati,
  /// barang dinding dinaiki dulu.
  void _reach(CatLife cat, List<LifeEvent> events) {
    if (cat.traveling) {
      cat
        ..activity = CatActivity.leaving
        ..pose = LifePose.walk
        ..heading = cat.room == HouseRoom.living
            ? LifeHeading.right
            : LifeHeading.left
        ..elapsed = 0
        ..remaining = lifeDoorSeconds;
      return;
    }
    if (_placeOf(cat) case final place?) {
      cat
        ..activity = CatActivity.idle
        ..pose = place.pose
        ..heading = place.heading
        ..elapsed = 0
        ..remaining = place.seconds * (0.7 + random.nextDouble() * 0.6);
      return;
    }
    if (cat.hops == 0) return _arrive(cat, events);
    cat
      ..activity = CatActivity.climbing
      ..pose = LifePose.walk
      ..elapsed = 0
      ..remaining = cat.hops * lifeHopSeconds;
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

  /// Bobot tujuan di [at] untuk [cat]: dikali [lifeCrowdFactor] per kucing
  /// lain di ruangan yang sama yang berada (atau menuju) di dekatnya.
  double _crowd(CatLife cat, Spot at) {
    var w = 1.0;
    for (final other in _cats.values) {
      if (other.kitty == cat.kitty || other.room != cat.room) continue;
      final there = switch (_placeOf(other)) {
        final place? => _placeSpot(place),
        null => _routeOf(other.item, other.kitty)?.stand ?? other.spot,
      };
      if (floor.distance(there, at) < lifeCrowdRadius) w *= lifeCrowdFactor;
    }
    return w;
  }

  void _next(CatLife cat, List<LifeEvent> events, {bool justEntered = false}) {
    final taken = users.keys.toSet();
    final bowl = _uses.entries
        .where(
          (e) => e.value == ItemUse.eat && _routeOf(e.key, cat.kitty) != null,
        )
        .map((e) => e.key)
        .firstOrNull;
    final wasEating = cat.activity == CatActivity.eating;
    cat
      ..item = null
      ..place = null
      ..traveling = false
      ..hops = 0;
    if (bowl != null && !wasEating && _hungry.contains(cat.kitty)) {
      if (_roomOf(bowl) != cat.room) return _goTravel(cat, events);
      if (!taken.contains(bowl)) return _go(cat, bowl, events);
    }
    if (_sad.contains(cat.kitty)) return _rest(cat);
    final roomPlaces = places[cat.room] ?? const <LifePlace>[];
    final takenPlaces = {
      for (final c in _cats.values)
        if (c.room == cat.room && c.kitty != cat.kitty) ?c.place,
    };
    final options = <(Object?, double)>[
      (null, lifeIdleWeight.toDouble()),
      for (final MapEntry(key: item, value: use) in _uses.entries)
        if (!taken.contains(item) &&
            _roomOf(item) == cat.room &&
            _routeOf(item, cat.kitty) != null &&
            (lifeUseWeights[use] ?? 0) > 0)
          (
            item,
            lifeUseWeights[use]! *
                _crowd(cat, _routeOf(item, cat.kitty)!.stand),
          ),
      for (var i = 0; i < roomPlaces.length; i++)
        if (!takenPlaces.contains(i))
          (i, roomPlaces[i].weight * _crowd(cat, _placeSpot(roomPlaces[i]))),
      if (travelWeight > 0 && cat.stayLeft <= 0 && !justEntered)
        (_travel, travelWeight.toDouble()),
    ];
    final total = options.fold(0.0, (sum, o) => sum + o.$2);
    var roll = random.nextDouble() * total;
    for (final (target, weight) in options) {
      roll -= weight;
      if (roll >= 0) continue;
      switch (target) {
        case null:
          _rest(cat);
          cat.pose = random.nextBool() ? LifePose.idle : LifePose.lick;
        case final RoomItemId item:
          _go(cat, item, events);
        case final int place:
          _goPlace(cat, place, events);
        default:
          _goTravel(cat, events);
      }
      return;
    }
    _rest(cat);
  }

  LifeHeading _headingTo(CatLife cat, Spot target) => target.x < cat.spot.x
      ? LifeHeading.left
      : target.x > cat.spot.x
      ? LifeHeading.right
      : LifeHeading.down;

  void _startWalk(CatLife cat, Spot target, List<LifeEvent> events) {
    cat
      ..activity = CatActivity.walking
      ..pose = LifePose.walk
      ..elapsed = 0
      ..heading = _headingTo(cat, target);
    if (target == cat.spot) _reach(cat, events);
  }

  void _goTravel(CatLife cat, List<LifeEvent> events) {
    cat.traveling = true;
    _startWalk(cat, floor.threshold(cat.room), events);
  }

  void _goPlace(CatLife cat, int place, List<LifeEvent> events) {
    cat.place = place;
    _startWalk(cat, _placeSpot(places[cat.room]![place]), events);
  }

  void _go(CatLife cat, RoomItemId item, List<LifeEvent> events) {
    final route = _routeOf(item, cat.kitty)!;
    cat
      ..item = item
      ..hops = route.hops;
    _startWalk(cat, route.stand, events);
  }
}
