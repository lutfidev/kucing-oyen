import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/rewards.dart';

void main() {
  test('skala gang: sama dengan rumah di tanah, mengecil di belakangnya', () {
    expect(laneScale(392), closeTo(0.75, 1e-9));
    expect(laneScale(455), closeTo(depthScale(455), 1e-9));
    expect(laneScale(455), closeTo(0.847, 0.001));
    expect(laneScale(292), closeTo(0.287, 0.001));
    expect(laneScale(230), closeTo(0, 1e-9));
  });

  test('tempat di gang (kGang, kTempat)', () {
    expect(laneBenchLeft, (x: 133.2, y: 396.5));
    expect(laneBenchRight, (x: 198.3, y: 396.5));
    expect(laneBenchMiddle, (x: 165.7, y: 396.5));
    expect(laneBenchScaleY, 455);
    expect(laneHopFrom, (x: 124.2, y: 487.8));
    expect(laneHopSeconds, 0.42);
    expect(laneThreshold, (x: 300.0, y: 470.0));
    expect(lanePlaces, hasLength(5));
    expect(kumisArrivePath.first, (x: 226.0, y: 292.0));
    expect(kumisArrivePath.last, (x: 176.0, y: 470.0));
    expect(kumisLeavePath.last, (x: 226.0, y: 292.0));
  });

  group('jadwal kunjungan', () {
    final day = DateTime(2026, 11, 22);

    test('seed hari: hari yang sama sama, hari lain berbeda', () {
      final a = laneVisitsOn(DateTime(2026, 11, 22, 3));
      final b = laneVisitsOn(DateTime(2026, 11, 22, 23, 59));
      expect([for (final v in a) v.start], [for (final v in b) v.start]);
      expect([for (final v in a) v.end], [for (final v in b) v.end]);
      final c = laneVisitsOn(DateTime(2026, 11, 23));
      expect([
        for (final v in c) v.start.hour * 60 + v.start.minute,
      ], isNot([for (final v in a) v.start.hour * 60 + v.start.minute]));
    });

    test('200 hari: 3 kunjungan, 08–22, jarak ≥ 2 jam, 8–12 menit', () {
      for (var i = 0; i < 200; i++) {
        final d = DateTime(2026, 1, 1 + i * 7);
        final visits = laneVisitsOn(d);
        expect(visits, hasLength(laneVisitsPerDay), reason: '$d');
        for (var j = 0; j < visits.length; j++) {
          final v = visits[j];
          final open = DateTime(d.year, d.month, d.day, laneWindowStartHour);
          final close = DateTime(d.year, d.month, d.day, laneWindowEndHour);
          expect(v.start.isBefore(open), isFalse, reason: '$d $j');
          expect(v.start.isAfter(close), isFalse, reason: '$d $j');
          final long = v.end.difference(v.start);
          expect(long >= laneMinVisit && long <= laneMaxVisit, isTrue);
          if (j > 0) {
            expect(
              v.start.difference(visits[j - 1].start) >= laneMinGap,
              isTrue,
              reason: '$d $j',
            );
          }
          expect(laneVisitAt(v.start)?.start, v.start);
          expect(
            laneVisitAt(v.end.subtract(const Duration(seconds: 1)))?.end,
            v.end,
          );
          expect(laneVisitAt(v.end), isNull);
        }
      }
    });

    test('di luar kunjungan = null', () {
      final first = laneVisitsOn(day).first;
      expect(
        laneVisitAt(first.start.subtract(const Duration(minutes: 1))),
        isNull,
      );
      expect(laneVisitAt(DateTime(2026, 11, 22, 3)), isNull);
    });

    test('heldUntil memperpanjang kunjungan yang berjalan', () {
      final v = laneVisitsOn(day).first;
      final held = v.until(v.end.add(const Duration(minutes: 15)));
      final at = laneVisitAt(
        v.end.add(const Duration(minutes: 10)),
        held: held,
      );
      expect(at?.start, v.start);
      expect(at?.end, held.end);
      expect(laneVisitAt(held.end, held: held), isNull);
    });

    test('heldUntil tidak menghidupkan kunjungan pagi yang sudah lewat', () {
      final visits = laneVisitsOn(day);
      final last = visits.last;
      final held = last.until(last.end.add(const Duration(minutes: 1)));
      final between = visits.first.end.add(const Duration(minutes: 30));
      expect(laneVisitAt(between, held: held), isNull);
    });

    test('perpanjangan yang menabrak kunjungan berikutnya digabung', () {
      final visits = laneVisitsOn(day);
      final next = visits[1];
      final forced = LaneVisit(
        start: next.start.subtract(const Duration(minutes: 3)),
        end: next.start.add(const Duration(minutes: 2)),
      );
      final merged = laneVisitAt(
        next.start.add(const Duration(minutes: 1)),
        forced: forced,
      );
      expect(merged?.start, forced.start);
      expect(merged?.end, next.end);
      final held = laneVisitAt(
        next.start.subtract(const Duration(minutes: 1)),
        forced: forced,
        held: next.until(next.end.add(const Duration(minutes: 4))),
      );
      expect(held?.start, forced.start);
      expect(held?.end, next.end.add(const Duration(minutes: 4)));
    });

    test('perpanjangan yang menyentuh kunjungan berikutnya tanpa celah', () {
      final start = DateTime(2026, 11, 22, 3);
      final forced = LaneVisit(
        start: start,
        end: start.add(const Duration(minutes: 10)),
      );
      final held = forced.until(forced.end.add(const Duration(minutes: 1)));
      expect(
        laneVisitAt(
          forced.end.add(const Duration(seconds: 30)),
          forced: forced,
          held: held,
        ),
        isNotNull,
      );
    });

    test('kunjungan paksa yang dimulai sekarang terlihat', () {
      final now = DateTime(2026, 11, 22, 3, 10);
      final forced = LaneVisit(
        start: now,
        end: now.add(const Duration(minutes: 10)),
      );
      expect(laneVisitAt(now, forced: forced)?.start, now);
      expect(
        laneVisitAt(now.add(const Duration(minutes: 9)), forced: forced),
        isNotNull,
      );
    });

    test('kunjungan 21:55 + 12 menit masih terlihat pukul 22:05', () {
      final start = DateTime(2026, 11, 22, 21, 55);
      final forced = LaneVisit(start: start, end: start.add(laneMaxVisit));
      expect(
        laneVisitAt(DateTime(2026, 11, 22, 22, 5), forced: forced),
        isNotNull,
      );
    });

    test('kunjungan kemarin yang diperpanjang lewat tengah malam', () {
      final yesterday = laneVisitsOn(DateTime(2026, 11, 21)).last;
      final held = yesterday.until(DateTime(2026, 11, 22, 0, 5));
      final at = laneVisitAt(DateTime(2026, 11, 22, 0, 1), held: held);
      expect(at?.start, yesterday.start);
      expect(at?.end, held.end);
    });

    test('LaneVisit.contains dan until', () {
      final v = LaneVisit(
        start: DateTime(2026, 1, 1, 9),
        end: DateTime(2026, 1, 1, 9, 10),
      );
      expect(v.contains(DateTime(2026, 1, 1, 9)), isTrue);
      expect(v.contains(DateTime(2026, 1, 1, 9, 10)), isFalse);
      expect(
        v.until(DateTime(2026, 1, 1, 9, 20)).end,
        DateTime(2026, 1, 1, 9, 20),
      );
      expect(laneForcedDelay, const Duration(seconds: 20));
      expect(laneFollowTime, const Duration(minutes: 5));
      expect(dayNumber(v.start), dayNumber(DateTime(2026, 1, 1)));
    });
  });
}
