import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/lane_life.dart';
import 'package:kucing_oren/game/model/room_life.dart';

/// Satu bingkai jam gang.
const _frame = 1 / 30;

/// Maju [seconds] per bingkai; semua peristiwa. [each] dipanggil tiap
/// bingkai.
List<LaneEvent> _run(
  LaneLife life,
  double seconds, [
  void Function(List<LaneEvent> events)? each,
]) {
  final events = <LaneEvent>[];
  for (var t = 0.0; t < seconds; t += _frame) {
    final step = life.advance(_frame);
    events.addAll(step);
    each?.call(step);
  }
  return events;
}

bool _near(LaneActor a, ({double x, double y}) p) =>
    (a.x - p.x).abs() < 0.01 && (a.y - p.y).abs() < 0.01;

void main() {
  test('pertemuan pertama menunggu pemain', () {
    final life = LaneLife(random: Random(1))..start(firstMeeting: true);
    final events = _run(life, 60);
    expect(events, isEmpty);
    final kumis = life.of(LaneCat.kumis)!;
    final oyen = life.of(LaneCat.oyen)!;
    expect(_near(kumis, laneBenchMiddle), isTrue, reason: '${kumis.x}');
    expect(kumis.onBench, isTrue);
    expect(kumis.lanePose, isNull);
    expect(_near(oyen, laneHopFrom), isTrue, reason: '${oyen.x},${oyen.y}');
    expect(oyen.onBench, isFalse);
    expect(oyen.activity, CatActivity.idle);
    expect(oyen.heading, LifeHeading.down);
  });

  test('Kumis datang dari ujung gang, Oyen keluar pintu kucing pulang', () {
    final life = LaneLife(random: Random(2))..start(firstMeeting: true);
    final kumis = life.of(LaneCat.kumis)!;
    final oyen = life.of(LaneCat.oyen)!;
    expect(_near(kumis, kumisArrivePath.first), isTrue);
    expect(kumis.alpha, lessThan(1));
    expect(oyen.activity, CatActivity.entering);
    expect(oyen.viaFlap, isTrue);
    expect(_near(oyen, laneFlapFeet), isTrue);
    _run(life, 1);
    expect(oyen.viaFlap, isFalse);
    expect(oyen.activity, CatActivity.walking);
  });

  test('pemain tiba: geser, lompat, endus, lalu SatTogether sekali', () {
    final life = LaneLife(random: Random(3))..start(firstMeeting: true);
    _run(life, 20);
    life.playerHere(true);
    final order = <String>[];
    void note(String what) {
      if (order.isEmpty || order.last != what) order.add(what);
    }

    var puff = false;
    var heart = false;
    final events = _run(life, 30, (step) {
      final kumis = life.of(LaneCat.kumis)!;
      final oyen = life.of(LaneCat.oyen)!;
      if (kumis.lanePose == LanePose.shift) note('geser');
      if (oyen.activity == CatActivity.climbing) note('lompat');
      if (oyen.lanePose == LanePose.sniff && kumis.lanePose == LanePose.sniff) {
        note('endus');
        expect(oyen.x, 140);
        expect(kumis.x, 191.5);
        expect(oyen.heading, LifeHeading.right);
        expect(kumis.heading, LifeHeading.left);
      }
      puff |= life.puff;
      if (life.heart) {
        heart = true;
        expect(oyen.x, 136);
        expect(kumis.x, 195);
      }
      if (step.contains(const SatTogether())) note('duduk');
    });
    expect(order.take(4), ['geser', 'lompat', 'endus', 'duduk']);
    expect(events.whereType<SatTogether>(), hasLength(1));
    expect(puff, isTrue);
    expect(heart, isTrue);
  });

  test('pemain pergi sebelum duduk bersama: tanpa SatTogether', () {
    final life = LaneLife(random: Random(4))..start(firstMeeting: true);
    _run(life, 20);
    life.playerHere(true);
    var hopped = false;
    final before = <LaneEvent>[];
    for (var t = 0.0; t < 10 && !hopped; t += _frame) {
      before.addAll(life.advance(_frame));
      hopped = life.of(LaneCat.oyen)!.onBench;
    }
    expect(hopped, isTrue);
    life.playerHere(false);
    expect(life.puff, isFalse);
    final events = _run(life, 60);
    expect([...before, ...events].whereType<SatTogether>(), isEmpty);
    // Momen biasa: keduanya pindah dari letak pertemuan.
    expect(life.heart, isFalse);
    expect(life.moment, isNot(LaneMoment.meeting));
  });

  test('di tengah kunjungan: keduanya sudah di bangku tanpa naskah', () {
    final life = LaneLife(random: Random(5))
      ..start(firstMeeting: true, midVisit: true)
      ..playerHere(true);
    final oyen = life.of(LaneCat.oyen)!;
    final kumis = life.of(LaneCat.kumis)!;
    expect(oyen.onBench && kumis.onBench, isTrue);
    expect(_near(oyen, laneBenchLeft), isTrue);
    expect(_near(kumis, laneBenchRight), isTrue);
    expect(kumis.heading, LifeHeading.left);
    final events = _run(life, 60);
    expect(events.whereType<SatTogether>(), isEmpty);
  });

  test('leave: Kumis pergi dulu, lalu Oyen masuk rumah', () {
    final life = LaneLife(random: Random(6))
      ..start(firstMeeting: false, midVisit: true);
    _run(life, 10);
    life.leave();
    var faded = false;
    final events = _run(life, 40, (_) {
      final kumis = life.of(LaneCat.kumis);
      if (kumis != null && kumis.alpha < 0.5) faded = true;
      final oyen = life.of(LaneCat.oyen);
      if (life.of(LaneCat.kumis) != null && oyen != null) {
        expect(oyen.activity, isNot(CatActivity.leaving));
      }
    });
    expect(faded, isTrue);
    expect(events, [const KumisGone(), const OyenEnteredHouse()]);
    expect(life.of(LaneCat.kumis), isNull);
    expect(life.of(LaneCat.oyen), isNull);
  });

  test('Oyen pulang lewat pintu kucing, dipotong di pintu', () {
    final life = LaneLife(random: Random(7))
      ..start(firstMeeting: false, midVisit: true);
    life.oyenGoesHome();
    var flap = false;
    final events = _run(life, 30, (_) {
      final oyen = life.of(LaneCat.oyen);
      if (oyen != null && oyen.activity == CatActivity.leaving) {
        flap = oyen.viaFlap;
        expect(_near(oyen, laneFlapFeet), isTrue);
      }
    });
    expect(flap, isTrue);
    expect(events, [const OyenEnteredHouse()]);
    expect(life.of(LaneCat.oyen), isNull);
    expect(life.of(LaneCat.kumis), isNotNull);
    // Kumis tetap di gang sendirian.
    expect(_run(life, 60), isEmpty);
    expect(life.of(LaneCat.kumis), isNotNull);
  });

  test('momen biasa tidak pernah menaruh dua kucing di titik yang sama', () {
    for (var seed = 0; seed < 8; seed++) {
      final life = LaneLife(random: Random(seed))
        ..start(firstMeeting: false)
        ..playerHere(true);
      final moments = <LaneMoment>{};
      _run(life, 300, (_) {
        moments.add(life.moment);
        final oyen = life.of(LaneCat.oyen)!;
        final kumis = life.of(LaneCat.kumis)!;
        final still =
            oyen.activity == CatActivity.idle &&
            kumis.activity == CatActivity.idle;
        if (still) {
          final d = sqrt(pow(oyen.x - kumis.x, 2) + pow(oyen.y - kumis.y, 2));
          expect(d, greaterThan(30), reason: 'seed $seed ${life.moment}');
        }
      });
      expect(moments.length, greaterThan(2), reason: 'seed $seed');
    }
  });

  test('kunjungan biasa: Kumis geser dulu kalau Oyen datang belakangan', () {
    final life = LaneLife(random: Random(8))..start(firstMeeting: false);
    var shifted = false;
    var hoppedAfterShift = false;
    _run(life, 15, (_) {
      final kumis = life.of(LaneCat.kumis)!;
      final oyen = life.of(LaneCat.oyen)!;
      if (kumis.lanePose == LanePose.shift) shifted = true;
      if (shifted && oyen.activity == CatActivity.climbing) {
        hoppedAfterShift = true;
      }
    });
    expect(shifted, isTrue);
    expect(hoppedAfterShift, isTrue);
  });

  test('tanpa Oyen: Kumis sendirian, tanpa peristiwa', () {
    final life = LaneLife(random: Random(9))
      ..start(firstMeeting: false, oyenComing: false);
    expect(life.of(LaneCat.oyen), isNull);
    expect(_run(life, 120), isEmpty);
    expect(life.of(LaneCat.kumis), isNotNull);
  });

  test('oyenGoesHome sesudah leave: Kumis tetap pergi, Oyen sekali lewat', () {
    final life = LaneLife(random: Random(12))
      ..start(firstMeeting: false, midVisit: true);
    life
      ..leave()
      ..oyenGoesHome();
    final events = _run(life, 60);
    expect(events, [const KumisGone(), const OyenEnteredHouse()]);
  });

  test('leave sesudah oyenGoesHome, atau oyenGoesHome dua kali: '
      'Oyen sekali lewat pintu', () {
    for (final second in [true, false]) {
      final life = LaneLife(random: Random(13))
        ..start(firstMeeting: false, midVisit: true);
      life.oyenGoesHome();
      var t = 0.0;
      while (life.of(LaneCat.oyen)!.activity != CatActivity.leaving && t < 30) {
        life.advance(_frame);
        t += _frame;
      }
      if (second) {
        life.leave();
      } else {
        life.oyenGoesHome();
      }
      var doors = 1;
      var wasLeaving = true;
      final events = _run(life, 60, (_) {
        final leaving = life.of(LaneCat.oyen)?.activity == CatActivity.leaving;
        if (leaving && !wasLeaving) doors++;
        wasLeaving = leaving;
      });
      expect(doors, 1, reason: 'leave=$second');
      expect(events.whereType<OyenEnteredHouse>(), hasLength(1));
      if (second) expect(events, contains(const KumisGone()));
    }
  });

  test('dijeda di tengah pintu kucing: langsung selesai', () {
    final life = LaneLife(random: Random(14))..start(firstMeeting: false);
    _run(life, 0.3);
    expect(life.of(LaneCat.oyen)!.isPassing, isTrue);
    life.paused = true;
    expect(life.of(LaneCat.oyen)!.isPassing, isFalse);

    final home = LaneLife(random: Random(14))
      ..start(firstMeeting: false, midVisit: true)
      ..oyenGoesHome();
    var t = 0.0;
    while (home.of(LaneCat.oyen)?.activity != CatActivity.leaving && t < 30) {
      home.advance(_frame);
      t += _frame;
    }
    home.paused = true;
    expect(home.of(LaneCat.oyen), isNull);
    home.paused = false;
    expect(home.advance(_frame), [const OyenEnteredHouse()]);
  });

  test('dijeda: tidak bergerak', () {
    final life = LaneLife(random: Random(10))..start(firstMeeting: false);
    _run(life, 1);
    final kumis = life.of(LaneCat.kumis)!;
    final at = (kumis.x, kumis.y);
    life.paused = true;
    expect(_run(life, 5), isEmpty);
    expect((kumis.x, kumis.y), at);
  });

  test('react: pose sebentar, lalu lanjut', () {
    final life = LaneLife(random: Random(11))
      ..start(firstMeeting: false, midVisit: true);
    life.react(LaneCat.kumis, LifePose.petted, 1.6);
    expect(life.of(LaneCat.kumis)!.pose, LifePose.petted);
    _run(life, 1.7);
    expect(life.of(LaneCat.kumis)!.pose, isNot(LifePose.petted));
  });
}
