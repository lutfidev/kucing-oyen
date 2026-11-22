import 'dart:math' as math;

import 'lane.dart';
import 'room_life.dart';

/// Kucing di Gang Depan. Kumis bukan `KittyId`, jadi gang punya kuncinya
/// sendiri.
enum LaneCat { oyen, kumis }

/// Pose gang di luar [LifePose]: mengendus, bergeser di bangku, dan main
/// dengan kupu-kupu.
enum LanePose { sniff, shift, play }

/// Momen gang yang sedang berjalan (`AdeganGang`).
enum LaneMoment {
  /// Datang: Kumis dari ujung gang, Oyen dari pintu kucing.
  arriving,

  /// Naskah pertemuan pertama (menunggu pemain, geser, lompat, endus,
  /// duduk bersama).
  meeting,

  /// Duduk berdampingan di bangku.
  pair,

  /// Tidur berdampingan di bangku.
  sleep,

  /// Berbaring di teduh pohon.
  shade,

  /// Oyen minum dari piring air, Kumis menunggu.
  water,

  /// Kumis di tangga warung, Oyen di bangku.
  step,

  /// Oyen main dengan kupu-kupu, Kumis menonton.
  butterflies,

  /// Kumis sendirian (Oyen sudah pulang).
  alone,

  /// Kunjungan selesai: Kumis pergi, lalu Oyen pulang.
  leaving,
}

/// Titik kaki di gang (px desain 390×652).
typedef LanePoint = ({double x, double y});

/// Lama bagian pertemuan pertama (detik): Kumis bergeser, saling
/// mengendus, dan hati di atas mereka.
const laneShiftSeconds = 0.8;
const laneSniffSeconds = 1.6;
const laneHeartSeconds = 1.6;

/// Pindah tempat duduk di bangku tanpa turun (detik).
const laneSeatSlideSeconds = 0.25;

/// Lama satu momen biasa: [lifeSleepSeconds] sampai ini (detik).
const laneMomentMaxSeconds = 20.0;

/// Bobot undian momen biasa (spec "Kunjungan berikutnya").
const laneMomentWeights = {
  LaneMoment.pair: 3,
  LaneMoment.sleep: 2,
  LaneMoment.shade: 2,
  LaneMoment.water: 1,
  LaneMoment.step: 1,
  LaneMoment.butterflies: 1,
};

/// Peristiwa gang yang diteruskan ke layar dan progres.
sealed class LaneEvent {
  const LaneEvent();
}

/// Pertemuan pertama selesai di depan pemain: `ProgressController.meetNeighbor`.
class SatTogether extends LaneEvent {
  const SatTogether();

  @override
  bool operator ==(Object other) => other is SatTogether;

  @override
  int get hashCode => (SatTogether).hashCode;
}

/// Oyen masuk lewat pintu kucing pulang: `RoomLife.comeHome(instant: true)`.
class OyenEnteredHouse extends LaneEvent {
  const OyenEnteredHouse();

  @override
  bool operator ==(Object other) => other is OyenEnteredHouse;

  @override
  int get hashCode => (OyenEnteredHouse).hashCode;
}

/// Kumis hilang di ujung gang.
class KumisGone extends LaneEvent {
  const KumisGone();

  @override
  bool operator ==(Object other) => other is KumisGone;

  @override
  int get hashCode => (KumisGone).hashCode;
}

/// Keadaan satu kucing di gang. Posisi = titik kaki desain; kucing di
/// bangku diskalakan dari [laneBenchScaleY] dan di tangga dari
/// [laneStepScaleY] ([scaleY]).
class LaneActor {
  LaneActor._(this.cat, this.x, this.y);

  final LaneCat cat;
  double x;
  double y;
  LifeHeading heading = LifeHeading.down;
  CatActivity activity = CatActivity.idle;
  LifePose pose = LifePose.idle;

  /// Pose gang yang menggantikan [pose] (null = [pose] biasa).
  LanePose? lanePose;

  /// Duduk di bangku.
  bool onBench = false;

  /// Duduk di tangga warung.
  bool onStep = false;

  /// Kumis memudar di ujung gang.
  double alpha = 1;

  /// Keluar atau masuk lewat pintu kucing pintu pulang (dipotong di
  /// `laneFlapClipX`).
  bool viaFlap = false;

  /// Detik sejak kegiatan ini mulai (bingkai jalan dan geser).
  double elapsed = 0;

  double _progress = 0;

  /// Lompatan naik atau turun bangku: dari [hopFrom] ke [hopTo].
  LanePoint? hopFrom;
  LanePoint? hopTo;

  /// Kemajuan lompatan, 0–1.
  double get hopProgress => isHopping ? _progress : 0;

  /// Kemajuan lewat pintu kucing, 0–1.
  double get doorProgress => isPassing ? _progress : 0;

  bool get isHopping =>
      activity == CatActivity.climbing || activity == CatActivity.descending;

  bool get isPassing =>
      activity == CatActivity.leaving || activity == CatActivity.entering;

  /// Y lantai yang menentukan skala sprite.
  double get scaleY => onBench
      ? laneBenchScaleY
      : onStep
      ? laneStepScaleY
      : y;

  @override
  String toString() =>
      'LaneActor(${cat.name}, ${activity.name}, ${pose.name}, '
      '${lanePose?.name}, $x, $y)';
}

// ── Langkah naskah ──────────────────────────────────────────────────────

sealed class _Step {
  /// [LaneLife._begin] sudah dipanggil.
  bool begun = false;
}

/// Berjalan menyusuri [points]; [fadeIn]/[fadeOut] = alpha di ruas
/// pertama/terakhir.
class _Walk extends _Step {
  _Walk(this.points, {this.fadeIn = false, this.fadeOut = false, this.step});

  final List<LanePoint> points;
  final bool fadeIn;
  final bool fadeOut;

  /// Sampai di tangga warung.
  final bool? step;
  int next = 0;

  /// Titik awal ruas pertama (tempat kucing saat mulai berjalan).
  LanePoint? from;
}

/// Lompat naik ([up]) ke tempat duduk [to], atau turun ke tanah.
class _Hop extends _Step {
  _Hop(this.to, {required this.up, this.heading});

  final LanePoint to;
  final bool up;
  final LifeHeading? heading;
  double t = 0;
}

/// Bergeser di bangku ke [x].
class _Slide extends _Step {
  _Slide(this.x, this.seconds, {this.lanePose, this.heading});

  final double x;
  final double seconds;
  final LanePose? lanePose;
  final LifeHeading? heading;
  double? fromX;
  double t = 0;
}

/// Diam dengan pose selama [seconds].
class _Hold extends _Step {
  _Hold(this.seconds, {this.pose = LifePose.idle, this.lanePose, this.heading});

  final double seconds;
  final LifePose pose;
  final LanePose? lanePose;
  final LifeHeading? heading;
  double t = 0;
}

/// Lewat pintu kucing pintu pulang.
class _Door extends _Step {
  _Door({required this.leaving});

  final bool leaving;
  double t = 0;
}

/// Menunggu semua kucing di gang sampai di [_Sync] bertanda sama.
class _Sync extends _Step {
  _Sync(this.tag);

  final Object tag;
}

/// Menunggu [until].
class _Wait extends _Step {
  _Wait(this.until);

  final bool Function() until;
}

/// Langkah seketika: [run], lalu lanjut.
class _Call extends _Step {
  _Call(this.run);

  final void Function() run;
}

/// Tujuan satu kucing di satu momen.
class _Target {
  const _Target(
    this.at, {
    this.bench = false,
    this.step = false,
    this.pose = LifePose.idle,
    this.lanePose,
    this.heading = LifeHeading.down,
  });

  final LanePoint at;
  final bool bench;
  final bool step;
  final LifePose pose;
  final LanePose? lanePose;
  final LifeHeading heading;
}

LanePoint _seat(double x) => (x: x, y: laneBenchLeft.y);

/// Tempat tiap kucing per momen (`AdeganGang`).
final Map<LaneMoment, Map<LaneCat, _Target>> _moments = {
  LaneMoment.pair: {
    LaneCat.oyen: _Target(laneBenchLeft, bench: true),
    LaneCat.kumis: _Target(
      laneBenchRight,
      bench: true,
      heading: LifeHeading.left,
    ),
  },
  LaneMoment.sleep: {
    LaneCat.oyen: _Target(_seat(138), bench: true, pose: LifePose.sleep),
    LaneCat.kumis: _Target(
      _seat(197),
      bench: true,
      pose: LifePose.sleep,
      heading: LifeHeading.right,
    ),
  },
  LaneMoment.shade: {
    LaneCat.oyen: const _Target(
      (x: 88, y: 584),
      pose: LifePose.lounge,
      heading: LifeHeading.right,
    ),
    LaneCat.kumis: const _Target(
      (x: 170, y: 574),
      pose: LifePose.lounge,
      heading: LifeHeading.left,
    ),
  },
  LaneMoment.water: {
    LaneCat.oyen: const _Target((x: 51, y: 481), pose: LifePose.eat),
    LaneCat.kumis: const _Target((x: 116, y: 502), heading: LifeHeading.left),
  },
  LaneMoment.step: {
    LaneCat.oyen: _Target(_seat(150), bench: true, heading: LifeHeading.left),
    LaneCat.kumis: const _Target(
      (x: 85.7, y: 390.1),
      step: true,
      heading: LifeHeading.right,
    ),
  },
  LaneMoment.butterflies: {
    LaneCat.oyen: const _Target(
      (x: 212, y: 542),
      lanePose: LanePose.play,
      heading: LifeHeading.right,
    ),
    LaneCat.kumis: const _Target((x: 282, y: 548), heading: LifeHeading.left),
  },
};

/// Kumis sendirian sesudah Oyen pulang: bangku tengah atau teduh.
final _aloneTargets = [
  _Target(laneBenchMiddle, bench: true),
  const _Target((x: 170, y: 574), pose: LifePose.lounge),
];

/// Rutinitas Gang Depan: Oyen dan Kumis datang, pertemuan pertama yang
/// menunggu pemain, momen biasa berbobot, lalu pulang. Terpisah dari
/// [RoomLife], yang berkunci `KittyId` dan barang; tempat, kecepatan
/// jalan, dan pose memakai nilai rumah. Dimajukan [advance]; momen diundi
/// [random] (beri seed di test).
class LaneLife {
  LaneLife({required this.random});

  final math.Random random;

  /// Kartu Oyen atau Kumis terbuka: rutinitas berhenti.
  bool paused = false;

  final _actors = <LaneCat, LaneActor>{};
  final _queues = <LaneCat, List<_Step>>{};
  final _events = <LaneEvent>[];

  bool _playerHere = false;
  bool _meeting = false;
  bool _meetingStarted = false;
  bool _leaving = false;
  bool _puff = false;
  bool _heart = false;
  LaneMoment _moment = LaneMoment.arriving;

  /// Momen yang sedang berjalan.
  LaneMoment get moment => _moment;

  /// Kepulan kecil di antara hidung saat mengendus.
  bool get puff => _puff;

  /// Hati kecil di antara mereka saat duduk bersama (`temuE`).
  bool get heart => _heart;

  /// Kupu-kupu berputar di sekitar Oyen.
  bool get butterflies => _moment == LaneMoment.butterflies;

  LaneActor? of(LaneCat cat) => _actors[cat];

  Iterable<LaneActor> get actors => _actors.values;

  /// Kunjungan mulai (atau gang dibuka di tengah kunjungan, [midVisit]:
  /// keduanya sudah duduk di bangku). Selain itu Kumis datang dari ujung
  /// gang dan duduk di tengah bangku, dan Oyen ([oyenComing]) masuk lewat
  /// pintu kucing pintu pulang lalu duduk di depan bangku. [firstMeeting] =
  /// naskah pertemuan pertama yang menunggu pemain.
  void start({
    required bool firstMeeting,
    bool oyenComing = true,
    bool midVisit = false,
  }) {
    _actors.clear();
    _queues.clear();
    _events.clear();
    _leaving = false;
    _puff = false;
    _heart = false;
    _meetingStarted = false;
    _meeting = firstMeeting && oyenComing && !midVisit;
    if (midVisit) {
      final kumis = _add(LaneCat.kumis, laneBenchRight)
        ..onBench = true
        ..heading = LifeHeading.left;
      assert(kumis.onBench);
      if (oyenComing) _add(LaneCat.oyen, laneBenchLeft).onBench = true;
      _moment = oyenComing ? LaneMoment.pair : LaneMoment.alone;
      _queueHoldAll();
      _kickAll();
      return;
    }
    _moment = _meeting ? LaneMoment.meeting : LaneMoment.arriving;
    _add(LaneCat.kumis, kumisArrivePath.first).alpha = 0;
    _queue(LaneCat.kumis)
      ..add(_Walk(kumisArrivePath.sublist(1), fadeIn: true))
      ..add(_Hop(laneBenchMiddle, up: true));
    if (!oyenComing) {
      _moment = LaneMoment.alone;
      _kickAll();
      return;
    }
    _add(LaneCat.oyen, laneFlapFeet);
    _queue(LaneCat.oyen)
      ..add(_Door(leaving: false))
      ..add(_Walk([laneHopFrom]))
      ..add(_Call(() => _actors[LaneCat.oyen]?.heading = LifeHeading.down));
    if (_meeting) {
      _queueMeeting();
    } else {
      _queueJoin(_holdSeconds());
    }
    _kickAll();
  }

  /// Pemain ada di gang. Naskah pertemuan pertama menunggu ini; pemain
  /// yang pergi sebelum mereka duduk bersama membatalkannya untuk
  /// kunjungan ini (momen biasa berlanjut).
  void playerHere(bool here) {
    _playerHere = here;
    if (!here && _meeting && _meetingStarted) _abortMeeting();
  }

  /// Kunjungan selesai: Kumis pergi ke ujung gang ([KumisGone]), lalu Oyen
  /// pulang lewat pintu kucing ([OyenEnteredHouse]).
  void leave() {
    if (_leaving) return;
    _abortMeeting();
    _leaving = true;
    _moment = LaneMoment.leaving;
    for (final cat in _actors.keys) {
      _trimQueue(cat);
    }
    final kumis = _actors[LaneCat.kumis];
    if (kumis != null) {
      final q = _queue(LaneCat.kumis);
      if (kumis.onBench || _endsOnBench(LaneCat.kumis)) {
        q.add(_Hop(kumisLeavePath.first, up: false));
      } else {
        q.add(_Walk([kumisLeavePath.first]));
      }
      q
        ..add(_Walk(kumisLeavePath.sublist(1), fadeOut: true))
        ..add(_Call(() => _remove(LaneCat.kumis, const KumisGone())));
    }
    if (_actors.containsKey(LaneCat.oyen)) {
      _queue(LaneCat.oyen)
          .add(_Wait(() => !_actors.containsKey(LaneCat.kumis)));
      _queueOyenHome();
    }
    _kickAll();
  }

  /// Oyen lapar pulang lebih dulu; Kumis tetap di gang sendirian.
  void oyenGoesHome() {
    if (!_actors.containsKey(LaneCat.oyen)) return;
    _abortMeeting();
    for (final cat in _actors.keys) {
      _trimQueue(cat);
    }
    _queueOyenHome();
    if (!_leaving) _moment = LaneMoment.alone;
    _kickAll();
  }

  /// [cat] bereaksi dengan [pose] selama [seconds] (diketuk pemain), lalu
  /// lanjut. Kucing yang sedang melompat, bergeser, atau lewat pintu tidak
  /// berhenti.
  void react(LaneCat cat, LifePose pose, double seconds) {
    final actor = _actors[cat];
    if (actor == null) return;
    final q = _queue(cat);
    final head = q.firstOrNull;
    if (head is _Hop || head is _Slide || head is _Door) return;
    q.insert(0, _Hold(seconds, pose: pose, heading: actor.heading));
    _begin(actor, q.first);
    final resumed = q.length > 1 ? q[1] : null;
    // Jalan yang tertunda reaksi mulai lagi dari tempat kucing berhenti.
    if (resumed is _Walk) resumed.begun = false;
  }

  /// Maju [seconds] detik; peristiwa yang terjadi selama itu.
  List<LaneEvent> advance(double seconds) {
    if (paused || seconds <= 0) return const [];
    for (final cat in LaneCat.values) {
      final actor = _actors[cat];
      if (actor == null) continue;
      actor.elapsed += seconds;
      _step(actor, seconds);
    }
    _releaseSyncs();
    if (!_leaving &&
        _actors.isNotEmpty &&
        _actors.keys.every((cat) => _queue(cat).isEmpty)) {
      _planMoment();
      _kickAll();
    }
    final events = List.of(_events);
    _events.clear();
    return events;
  }

  // ── Naskah ────────────────────────────────────────────────────────────

  List<_Step> _queue(LaneCat cat) => _queues.putIfAbsent(cat, () => []);

  LaneActor _add(LaneCat cat, LanePoint at) =>
      _actors[cat] = LaneActor._(cat, at.x, at.y);

  void _remove(LaneCat cat, LaneEvent event) {
    _actors.remove(cat);
    _queues.remove(cat);
    _events.add(event);
  }

  double _holdSeconds() =>
      lifeSleepSeconds +
      random.nextDouble() * (laneMomentMaxSeconds - lifeSleepSeconds);

  void _queueHoldAll() {
    final seconds = _holdSeconds();
    for (final actor in _actors.values) {
      _queue(actor.cat).add(_Hold(seconds, heading: actor.heading));
    }
  }

  /// Kumis menunggu di tengah bangku sampai Oyen di depan bangku, bergeser
  /// ke kanan, lalu Oyen melompat naik ke kiri. Keduanya lalu duduk
  /// [seconds] detik.
  void _queueJoin(double seconds) {
    _queue(LaneCat.kumis)
      ..add(_Sync(#ready))
      ..add(
        _Slide(
          laneBenchRight.x,
          laneShiftSeconds,
          lanePose: LanePose.shift,
          heading: LifeHeading.right,
        ),
      )
      ..add(_Sync(#hop))
      ..add(_Hold(seconds, heading: LifeHeading.left));
    _queue(LaneCat.oyen)
      ..add(_Sync(#ready))
      ..add(_Sync(#hop))
      ..add(_Hop(laneBenchLeft, up: true, heading: LifeHeading.right))
      ..add(_Hold(seconds));
  }

  void _queueMeeting() {
    _queue(LaneCat.kumis)
      ..add(_Sync(#ready))
      ..add(_Wait(() => _playerHere))
      ..add(_Call(() => _meetingStarted = true))
      ..add(
        _Slide(
          laneBenchRight.x,
          laneShiftSeconds,
          lanePose: LanePose.shift,
          heading: LifeHeading.right,
        ),
      )
      ..add(_Call(() => _actors[LaneCat.kumis]?.heading = LifeHeading.left))
      ..add(_Sync(#hop))
      ..add(_Sync(#sniff))
      ..add(_Slide(191.5, laneSeatSlideSeconds, heading: LifeHeading.left))
      ..add(
        _Hold(
          laneSniffSeconds,
          lanePose: LanePose.sniff,
          heading: LifeHeading.left,
        ),
      )
      ..add(_Sync(#together))
      ..add(_Slide(195, laneSeatSlideSeconds, heading: LifeHeading.left))
      ..add(_Sync(#heart))
      ..add(_Hold(laneHeartSeconds, heading: LifeHeading.left))
      ..add(_Sync(#done));
    _queue(LaneCat.oyen)
      ..add(_Sync(#ready))
      ..add(_Sync(#hop))
      ..add(_Hop(laneBenchLeft, up: true, heading: LifeHeading.right))
      ..add(_Sync(#sniff))
      ..add(_Slide(140, laneSeatSlideSeconds, heading: LifeHeading.right))
      ..add(_Call(() => _puff = true))
      ..add(
        _Hold(
          laneSniffSeconds,
          lanePose: LanePose.sniff,
          heading: LifeHeading.right,
        ),
      )
      ..add(_Call(() => _puff = false))
      ..add(_Sync(#together))
      ..add(_Slide(136, laneSeatSlideSeconds, heading: LifeHeading.right))
      ..add(_Sync(#heart))
      ..add(_Call(() => _heart = true))
      ..add(_Hold(laneHeartSeconds, heading: LifeHeading.right))
      ..add(
        _Call(() {
          _heart = false;
          _meeting = false;
          _events.add(const SatTogether());
        }),
      )
      ..add(_Sync(#done));
  }

  /// Pertemuan pertama batal: gerak yang sedang berjalan diselesaikan,
  /// sisanya dibuang, lalu momen biasa.
  void _abortMeeting() {
    if (!_meeting) return;
    _meeting = false;
    _meetingStarted = false;
    _puff = false;
    _heart = false;
    for (final cat in _actors.keys) {
      _trimQueue(cat);
    }
    if (_moment == LaneMoment.meeting) _moment = LaneMoment.pair;
  }

  /// Menyisakan hanya gerak yang sedang berjalan (jalan, lompat, geser,
  /// lewat pintu), supaya kucing tidak pindah mendadak.
  void _trimQueue(LaneCat cat) {
    final q = _queue(cat);
    final head = q.firstOrNull;
    q.clear();
    if (head is _Walk || head is _Hop || head is _Slide || head is _Door) {
      q.add(head!);
    } else {
      final actor = _actors[cat];
      if (actor != null) _idle(actor);
    }
  }

  bool _endsOnBench(LaneCat cat) {
    final head = _queue(cat).firstOrNull;
    return head is _Hop && head.up;
  }

  void _queueOyenHome() {
    final oyen = _actors[LaneCat.oyen]!;
    final q = _queue(LaneCat.oyen);
    if (oyen.onBench || _endsOnBench(LaneCat.oyen)) {
      q.add(_Hop(laneHopFrom, up: false));
    }
    q
      ..add(_Walk([laneThreshold, laneFlapFeet]))
      ..add(_Door(leaving: true))
      ..add(_Call(() => _remove(LaneCat.oyen, const OyenEnteredHouse())));
  }

  void _planMoment() {
    final hold = _holdSeconds();
    if (!_actors.containsKey(LaneCat.oyen)) {
      _moment = LaneMoment.alone;
      final target = _aloneTargets[random.nextInt(_aloneTargets.length)];
      _goTo(_actors[LaneCat.kumis]!, target, hold);
      return;
    }
    if (!_actors.containsKey(LaneCat.kumis)) {
      _goTo(_actors[LaneCat.oyen]!, _Target(laneBenchLeft, bench: true), hold);
      return;
    }
    final total = laneMomentWeights.values.fold(0, (a, b) => a + b);
    var roll = random.nextInt(total);
    var moment = LaneMoment.pair;
    for (final MapEntry(:key, :value) in laneMomentWeights.entries) {
      roll -= value;
      if (roll < 0) {
        moment = key;
        break;
      }
    }
    _moment = moment;
    final oyen = _actors[LaneCat.oyen]!;
    final kumis = _actors[LaneCat.kumis]!;
    if (moment == LaneMoment.pair && !oyen.onBench) {
      // Oyen datang belakangan: Kumis menunggu di tengah lalu bergeser.
      _goTo(kumis, _Target(laneBenchMiddle, bench: true), null);
      _goTo(oyen, const _Target(laneHopFrom), null);
      _queueJoin(hold);
      return;
    }
    final targets = _moments[moment]!;
    _goTo(oyen, targets[LaneCat.oyen]!, hold);
    _goTo(kumis, targets[LaneCat.kumis]!, hold);
  }

  /// Menambah langkah dari tempat [actor] sekarang ke [target], lalu diam
  /// [hold] detik (null = tanpa diam).
  void _goTo(LaneActor actor, _Target target, double? hold) {
    final q = _queue(actor.cat);
    final hop = actor.cat == LaneCat.oyen ? laneHopFrom : kumisArrivePath.last;
    if (actor.onBench && target.bench) {
      q.add(_Slide(target.at.x, laneSeatSlideSeconds, heading: target.heading));
    } else if (actor.onBench) {
      q
        ..add(_Hop(hop, up: false))
        ..add(_Walk([target.at], step: target.step));
    } else if (target.bench) {
      q
        ..add(_Walk([hop]))
        ..add(_Hop(target.at, up: true, heading: target.heading));
    } else {
      q.add(_Walk([target.at], step: target.step));
    }
    if (hold != null) {
      q.add(
        _Hold(
          hold,
          pose: target.pose,
          lanePose: target.lanePose,
          heading: target.heading,
        ),
      );
    }
  }

  // ── Menjalankan langkah ───────────────────────────────────────────────

  void _idle(LaneActor actor) {
    actor
      ..activity = CatActivity.idle
      ..pose = LifePose.idle
      ..lanePose = null
      ..hopFrom = null
      ..hopTo = null
      ..viaFlap = false
      .._progress = 0;
  }

  /// Memulai langkah pertama tiap antrean yang belum mulai, supaya keadaan
  /// kucing sudah benar sebelum [advance] pertama.
  void _kickAll() {
    for (final actor in _actors.values) {
      final head = _queue(actor.cat).firstOrNull;
      if (head != null && !head.begun) _begin(actor, head);
    }
  }

  /// Kegiatan [actor] saat langkah [step] dimulai.
  void _begin(LaneActor actor, _Step step) {
    step.begun = true;
    actor.elapsed = 0;
    switch (step) {
      case _Walk():
        step.from = (x: actor.x, y: actor.y);
        actor
          ..activity = CatActivity.walking
          ..pose = LifePose.walk
          ..lanePose = null
          ..onStep = false;
      case _Hop(:final to, :final up, :final heading):
        actor
          ..activity = up ? CatActivity.climbing : CatActivity.descending
          ..pose = LifePose.walk
          ..lanePose = null
          ..onStep = false
          ..hopFrom = (x: actor.x, y: actor.y)
          ..hopTo = to
          .._progress = 0;
        if (heading != null) actor.heading = heading;
      case _Slide(:final lanePose, :final heading):
        step.fromX ??= actor.x;
        actor
          ..activity = CatActivity.idle
          ..pose = LifePose.idle
          ..lanePose = lanePose;
        if (heading != null) actor.heading = heading;
      case _Hold(:final pose, :final lanePose, :final heading):
        actor
          ..activity = CatActivity.idle
          ..pose = pose
          ..lanePose = lanePose;
        if (heading != null) actor.heading = heading;
      case _Door(:final leaving):
        actor
          ..activity = leaving ? CatActivity.leaving : CatActivity.entering
          ..pose = LifePose.walk
          ..lanePose = null
          ..viaFlap = true
          ..heading = leaving ? LifeHeading.right : LifeHeading.left
          .._progress = 0;
      case _Sync() || _Wait() || _Call():
        if (actor.activity != CatActivity.idle) _idle(actor);
        actor.lanePose = null;
    }
  }

  void _step(LaneActor actor, double seconds) {
    var dt = seconds;
    var guard = 0;
    while (guard++ < 64) {
      final q = _queues[actor.cat];
      if (q == null || q.isEmpty) return;
      final step = q.first;
      if (!step.begun) _begin(actor, step);
      final left = _run(actor, step, dt);
      if (left == null) return;
      if (!identical(_queues[actor.cat], q) || q.isEmpty) return;
      q.removeAt(0);
      dt = left;
      if (q.isNotEmpty) {
        _begin(actor, q.first);
      } else {
        _idle(actor);
      }
    }
  }

  /// Menjalankan [step] selama [dt]; sisa waktu kalau langkahnya selesai,
  /// null kalau belum (atau sedang menunggu).
  double? _run(LaneActor actor, _Step step, double dt) {
    switch (step) {
      case _Walk():
        return _walk(actor, step, dt);
      case _Hop(:final to):
        step.t += dt;
        final duration = laneHopSeconds;
        actor._progress = (step.t / duration).clamp(0.0, 1.0);
        if (step.t < duration) return null;
        actor
          ..x = to.x
          ..y = to.y
          ..onBench = step.up
          ..hopFrom = null
          ..hopTo = null;
        return step.t - duration;
      case _Slide(:final x, :final seconds):
        step.t += dt;
        final from = step.fromX ?? actor.x;
        final f = (step.t / seconds).clamp(0.0, 1.0);
        actor.x = from + (x - from) * f;
        if (step.t < seconds) return null;
        actor.x = x;
        return step.t - seconds;
      case _Hold(:final seconds):
        step.t += dt;
        return step.t < seconds ? null : step.t - seconds;
      case _Door():
        step.t += dt;
        actor._progress = (step.t / lifeDoorSeconds).clamp(0.0, 1.0);
        if (step.t < lifeDoorSeconds) return null;
        actor.viaFlap = false;
        return step.t - lifeDoorSeconds;
      case _Sync():
        return null;
      case _Wait(:final until):
        return until() ? dt : null;
      case _Call(:final run):
        run();
        return dt;
    }
  }

  double? _walk(LaneActor actor, _Walk step, double dt) {
    var budget = lifeWalkSpeed * dt;
    final points = step.points;
    while (step.next < points.length) {
      final to = points[step.next];
      final dx = to.x - actor.x;
      final dy = to.y - actor.y;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (dx.abs() > 0.5) {
        actor.heading = dx < 0 ? LifeHeading.left : LifeHeading.right;
      }
      if (distance <= budget) {
        actor
          ..x = to.x
          ..y = to.y;
        budget -= distance;
        _fade(actor, step, 1);
        step.next++;
        continue;
      }
      final f = budget / distance;
      actor
        ..x += dx * f
        ..y += dy * f;
      final from = step.next == 0 ? step.from! : points[step.next - 1];
      final length = math.sqrt(
        math.pow(to.x - from.x, 2) + math.pow(to.y - from.y, 2),
      );
      final left = distance - budget;
      _fade(actor, step, length == 0 ? 1 : 1 - left / length);
      return null;
    }
    if (step.step != null) actor.onStep = step.step!;
    return budget / lifeWalkSpeed;
  }

  /// Alpha di ruas pertama ([_Walk.fadeIn], muncul) atau terakhir
  /// ([_Walk.fadeOut], hilang); [f] = kemajuan ruas yang sedang dijalani,
  /// 0–1.
  void _fade(LaneActor actor, _Walk step, double f) {
    final f01 = f.clamp(0.0, 1.0);
    if (step.fadeIn && step.next == 0) actor.alpha = f01;
    if (step.fadeOut && step.next == step.points.length - 1) {
      actor.alpha = 1 - f01;
    }
  }

  /// [_Sync] bertanda sama di kepala semua antrean: semuanya lanjut.
  void _releaseSyncs() {
    for (var i = 0; i < 8; i++) {
      final heads = [for (final cat in _actors.keys) _queue(cat).firstOrNull];
      if (heads.isEmpty || heads.any((h) => h is! _Sync)) return;
      final tag = (heads.first! as _Sync).tag;
      if (heads.any((h) => (h! as _Sync).tag != tag)) return;
      for (final actor in _actors.values) {
        final q = _queue(actor.cat)..removeAt(0);
        if (q.isNotEmpty) {
          _begin(actor, q.first);
          _step(actor, 0);
        } else {
          _idle(actor);
        }
      }
    }
  }
}
