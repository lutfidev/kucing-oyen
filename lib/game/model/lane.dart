import 'dart:math';

import 'house.dart';
import 'rewards.dart';
import 'room_life.dart';

/// Geometri Gang Depan (catatan kanvas `kGang` dan `kTempat`). Gang memakai
/// titik hilang dan trapesium tanah yang sama dengan rumah, jadi titik di
/// bawah ini titik kaki desain 390×652 dan skalanya [laneScale].

/// Skala kucing di gang menurut y kaki: sama dengan rumah ([depthScale])
/// di trapesium tanah, dan mengecil ke titik hilang di belakangnya
/// (jalur Kumis ke ujung gang): `0,75 × (y − 230) / 162`.
double laneScale(double feetY) => feetY >= houseDepthBack
    ? depthScale(feetY)
    : (0.75 * (feetY - 230) / (houseDepthBack - 230)).clamp(0.0, 0.75);

/// Tempat duduk di bangku: kiri, kanan, dan tengah (pertemuan pertama).
/// Kucing di bangku diskalakan seperti kaki di y [laneBenchScaleY].
const laneBenchLeft = (x: 133.2, y: 396.5);
const laneBenchRight = (x: 198.3, y: 396.5);
const laneBenchMiddle = (x: 165.7, y: 396.5);
const laneBenchScaleY = 455.0;

/// Titik lompat dari tanah ke bangku, dan lama lengkungnya (detik).
const laneHopFrom = (x: 124.2, y: 487.8);
const laneHopSeconds = 0.42;

/// Depan pintu pulang: Oyen berdiri di sini sebelum masuk pintu kucing.
const laneThreshold = (x: 300.0, y: 470.0);

/// Tempat nyaman gang selain bangku: dua teduh pohon, piring air (minum
/// dengan pose makan tanpa mangkuk), tangga warung (skala dari y 404), dan
/// depan pintu pulang.
const lanePlaces = <LifePlace>[
  LifePlace(88, 584, pose: LifePose.lounge, heading: LifeHeading.right),
  LifePlace(170, 574, pose: LifePose.lounge, heading: LifeHeading.left),
  LifePlace(51, 481, pose: LifePose.eat, seconds: lifeEatSeconds * 2),
  LifePlace(85.7, 390.1, pose: LifePose.idle, heading: LifeHeading.right),
  LifePlace(300, 470, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
];

/// Kaki di tangga warung diskalakan seperti y ini (`kGang`).
const laneStepScaleY = 404.0;

/// Jalur Kumis datang dari ujung gang ke depan bangku, dan pergi kembali.
const kumisArrivePath = [
  (x: 226.0, y: 292.0),
  (x: 205.0, y: 394.0),
  (x: 176.0, y: 470.0),
];
const kumisLeavePath = [
  (x: 190.0, y: 470.0),
  (x: 210.0, y: 394.0),
  (x: 232.0, y: 330.0),
  (x: 226.0, y: 292.0),
];

/// Kunjungan Kumis per hari: tiga, mulai di jendela 08.00–22.00 waktu
/// lokal dengan jarak antar-mulai paling sedikit [laneMinGap], masing-masing
/// [laneMinVisit]–[laneMaxVisit]. Jadwal diundi dari [dayNumber], jadi tidak
/// disimpan.
const laneVisitsPerDay = 3;
const laneWindowStartHour = 8;
const laneWindowEndHour = 22;
const laneMinGap = Duration(hours: 2);
const laneMinVisit = Duration(minutes: 8);
const laneMaxVisit = Duration(minutes: 12);

/// Sesudah momen ekor, kunjungan berlangsung paling sedikit selama ini.
const laneFollowTime = Duration(minutes: 5);

/// Kunjungan paksa pertama datang selama ini sesudah ruang tengah tampil.
const laneForcedDelay = Duration(seconds: 20);

/// Undian jadwal yang gagal memenuhi [laneMinGap] dicoba ulang sebanyak ini,
/// lalu jatuh ke tiga slot tetap.
const _laneScheduleTries = 50;
const _laneFallbackHours = [9, 14, 19];

/// Satu kunjungan: [start] sampai sebelum [end].
class LaneVisit {
  const LaneVisit({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  LaneVisit until(DateTime end) => LaneVisit(start: start, end: end);

  @override
  bool operator ==(Object other) =>
      other is LaneVisit && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'LaneVisit($start – $end)';
}

/// Jadwal kunjungan hari kalender [day] (jamnya diabaikan), urut mulai.
/// Kunjungan mulai di jendela, tetapi boleh berakhir sesudah 22.00.
List<LaneVisit> laneVisitsOn(DateTime day) {
  final random = Random(dayNumber(day));
  final open = DateTime(day.year, day.month, day.day, laneWindowStartHour);
  final windowSeconds = (laneWindowEndHour - laneWindowStartHour) * 3600;
  List<DateTime>? starts;
  for (var i = 0; i < _laneScheduleTries && starts == null; i++) {
    final tried = [
      for (var j = 0; j < laneVisitsPerDay; j++)
        open.add(Duration(seconds: random.nextInt(windowSeconds + 1))),
    ]..sort();
    var ok = true;
    for (var j = 1; j < tried.length; j++) {
      if (tried[j].difference(tried[j - 1]) < laneMinGap) ok = false;
    }
    if (ok) starts = tried;
  }
  starts ??= [
    for (final hour in _laneFallbackHours)
      DateTime(day.year, day.month, day.day, hour, random.nextInt(60)),
  ];
  final spread = (laneMaxVisit - laneMinVisit).inSeconds;
  return [
    for (final start in starts)
      LaneVisit(
        start: start,
        end: start.add(
          laneMinVisit + Duration(seconds: random.nextInt(spread + 1)),
        ),
      ),
  ];
}

/// Kunjungan yang sedang berjalan pada [now], atau null.
///
/// Kunjungan kemarin (yang diperpanjang melewati tengah malam), hari ini,
/// dan [forced] dipertimbangkan bersama. [heldUntil] memperpanjang
/// kunjungan terakhir yang dimulai sebelum [heldUntil], yaitu kunjungan
/// saat pemain di gang atau saat momen ekor. Kunjungan yang dimulai sebelum
/// kunjungan lain berakhir digabung, jadi tidak pernah ada dua Kumis.
LaneVisit? laneVisitAt(DateTime now, {DateTime? heldUntil, LaneVisit? forced}) {
  final visits = [
    ...laneVisitsOn(now.subtract(const Duration(days: 1))),
    ...laneVisitsOn(now),
    ?forced,
  ]..sort((a, b) => a.start.compareTo(b.start));
  if (heldUntil != null) {
    final i = visits.lastIndexWhere((v) => v.start.isBefore(heldUntil));
    if (i >= 0 && visits[i].end.isBefore(heldUntil)) {
      visits[i] = visits[i].until(heldUntil);
    }
  }
  LaneVisit? current;
  for (final v in visits) {
    if (current != null && v.start.isBefore(current.end)) {
      if (v.end.isAfter(current.end)) current = current.until(v.end);
      continue;
    }
    if (current != null && current.contains(now)) return current;
    current = v;
  }
  return current != null && current.contains(now) ? current : null;
}
