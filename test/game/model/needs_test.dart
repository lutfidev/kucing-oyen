import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/snacks.dart';

void main() {
  final t0 = DateTime(2026, 10, 28, 8);
  DateTime at(Duration d) => t0.add(d);
  const hour = Duration(hours: 1);
  const minute = Duration(minutes: 1);

  test('angka kebutuhan', () {
    expect(hungerHours, 12);
    expect(joyHours, 16);
    expect(bowlRefillHours, 4);
    expect(bowlFood, 40);
    expect(bowlHungerLimit, 70);
    expect(kittyRewardCoins, 10);
    expect(rewardThreshold, 70);
    expect(sadThreshold, 20);
    expect(petJoy, 10);
    expect(petJoyPerHour, 30);
    expect(playJoy, 10);
    expect(playMinutes, 30);
    expect(decorateJoy, 5);
    expect(decorateMinutes, 60);
  });

  group('CatNeeds', () {
    final full = CatNeeds.full(t0);

    test('penuh: kedua bar 100', () {
      expect(full.hunger, 100);
      expect(full.joy, 100);
      expect(full.at, t0);
    });

    test('turun lurus: Lapar habis 12 jam, Senang 16 jam', () {
      final six = full.decayed(at(hour * 6));
      expect(six.hunger, closeTo(50, 1e-9));
      expect(six.joy, closeTo(62.5, 1e-9));
      expect(full.decayed(at(hour * 12)).hunger, closeTo(0, 1e-9));
    });

    test('berhenti di 0', () {
      final late = full.decayed(at(hour * 20));
      expect(late.hunger, 0);
      expect(late.joy, 0);
    });

    test('turun bertahap = turun sekaligus', () {
      final stepwise = full.decayed(at(hour * 3)).decayed(at(hour * 9));
      final once = full.decayed(at(hour * 9));
      expect(stepwise.hunger, closeTo(once.hunger, 1e-9));
      expect(stepwise.joy, closeTo(once.joy, 1e-9));
    });

    test('jam mundur tidak menaikkan bar', () {
      final six = full.decayed(at(hour * 6));
      final back = six.decayed(at(hour * 3));
      expect(back, six);
      // Maju lagi: dihitung dari waktu lama, tidak dua kali.
      expect(back.decayed(at(hour * 8)).hunger, closeTo(100 / 3, 1e-9));
    });

    test('camilan menambah Lapar dan Senang, dijepit 100', () {
      final hungry = full.decayed(at(hour * 6));
      final fed = hungry.fed(snackOf(SnackId.ikanAsin), at(hour * 6));
      expect(fed.hunger, closeTo(75, 1e-9));
      expect(fed.joy, closeTo(67.5, 1e-9));
      expect(full.fed(snackOf(SnackId.puding), t0).hunger, 100);
    });

    test('elus: +10, paling banyak +30 per jam', () {
      var cat = full.decayed(at(hour * 8)); // Senang 50
      for (var i = 0; i < 3; i++) {
        cat = cat.petted(at(hour * 8))!;
      }
      expect(cat.joy, closeTo(80, 1e-9));
      expect(cat.petted(at(hour * 8 + minute * 59)), isNull);
      final again = cat.petted(at(hour * 9));
      expect(again, isNotNull);
      expect(again!.joy, closeTo(90 - 100 / 16, 1e-9));
    });

    test('elus: jam mundur tetap tertahan', () {
      var cat = full;
      for (var i = 0; i < 3; i++) {
        cat = cat.petted(t0)!;
      }
      expect(cat.petted(t0.subtract(hour * 2)), isNull);
    });

    test('main: +10, sekali per 30 menit', () {
      final bored = full.decayed(at(hour * 8));
      final played = bored.played(at(hour * 8))!;
      expect(played.joy, closeTo(60, 1e-9));
      expect(played.played(at(hour * 8 + minute * 29)), isNull);
      expect(played.played(at(hour * 8 + minute * 30)), isNotNull);
      expect(played.played(at(hour * 7)), isNull);
    });

    test('lesu kalau Lapar atau Senang ≤ 20', () {
      expect(full.isSad, isFalse);
      expect(CatNeeds(hunger: 20, joy: 90, at: t0).isSad, isTrue);
      expect(CatNeeds(hunger: 90, joy: 20, at: t0).isSad, isTrue);
      expect(CatNeeds(hunger: 21, joy: 21, at: t0).isSad, isFalse);
    });

    test('nilai dijepit 0–100', () {
      final odd = CatNeeds(hunger: 140, joy: -5, at: t0);
      expect(odd.hunger, 100);
      expect(odd.joy, 0);
    });

    test('JSON pulang-pergi; rusak = null', () {
      final cat = full
          .decayed(at(hour * 3))
          .petted(at(hour * 3))!
          .played(at(hour * 3))!;
      expect(CatNeeds.fromJson(cat.toJson()), cat);
      expect(CatNeeds.fromJson(full.toJson()), full);
      for (final bad in <Object?>[
        null,
        'x',
        {'hunger': 'a', 'joy': 1, 'at': 0},
        {'hunger': double.nan, 'joy': 1, 'at': 0},
        {'hunger': 1, 'joy': 1, 'at': 'pagi'},
        {'hunger': 1, 'joy': 1},
      ]) {
        expect(CatNeeds.fromJson(bad), isNull, reason: '$bad');
      }
    });

    test('JSON waktu di luar jangkauan dibuang tanpa melempar', () {
      for (final ms in [9000000000000000, 8639999999999999, -1]) {
        final json = {...full.toJson(), 'at': ms};
        expect(CatNeeds.fromJson(json), isNull, reason: '$ms');
        final odd = CatNeeds.fromJson({
          ...full.toJson(),
          'petAt': ms,
          'playedAt': ms,
        })!;
        expect(odd.petWindowStart, isNull, reason: '$ms');
        expect(odd.playedAt, isNull, reason: '$ms');
        expect(odd.played(t0), isNotNull, reason: '$ms');
      }
    });

    test('JSON batas rusak = batasnya habis', () {
      final json = {
        ...full.toJson(),
        'petAt': t0.millisecondsSinceEpoch,
        'petJoy': 'x',
        'playedAt': 'x',
      };
      final cat = CatNeeds.fromJson(json)!;
      expect(cat.petted(t0), isNull);
      expect(cat.played(t0), isNotNull);
    });
  });

  group('Bowl', () {
    test('awal penuh, makan sekali per isi per kucing', () {
      final bowl = Bowl.full;
      expect(bowl.hasEaten(KittyId.oyen, t0), isFalse);
      final ate = bowl.eat(KittyId.oyen, t0);
      expect(ate.hasEaten(KittyId.oyen, at(hour)), isTrue);
      expect(ate.hasEaten(KittyId.arang, at(hour)), isFalse);
      expect(ate.refillAt(at(hour)), at(hour * 4));
    });

    test('kosong kalau semua kucing sudah makan dari isi itu', () {
      final kitties = [KittyId.oyen, KittyId.arang];
      var bowl = Bowl.full.eat(KittyId.oyen, t0);
      expect(bowl.isEmptyFor(kitties, t0), isFalse);
      bowl = bowl.eat(KittyId.arang, at(hour));
      expect(bowl.isEmptyFor(kitties, at(hour)), isTrue);
      expect(bowl.isEmptyFor(kitties, at(hour * 4)), isFalse);
      expect(Bowl.full.isEmptyFor(kitties, t0), isFalse);
    });

    test(
      'isi baru 4 jam sesudah makan pertama; yang terlewat tidak menumpuk',
      () {
        final bowl = Bowl.full
            .eat(KittyId.oyen, t0)
            .eat(KittyId.arang, at(hour * 3));
        expect(bowl.refillAt(at(hour * 3)), at(hour * 4));
        final next = bowl.eat(KittyId.oyen, at(hour * 30));
        expect(next.filledAt, at(hour * 30));
        expect(next.eaten, {KittyId.oyen});
        expect(next.hasEaten(KittyId.oyen, at(hour * 31)), isTrue);
      },
    );

    test('jam mundur sebelum isi dimulai: tetap isi lama', () {
      final bowl = Bowl.full.eat(KittyId.oyen, t0);
      expect(bowl.hasEaten(KittyId.oyen, t0.subtract(hour * 5)), isTrue);
    });

    test('JSON pulang-pergi; rusak dibuang', () {
      final bowl = Bowl.full.eat(KittyId.oyen, t0).eat(KittyId.bos, t0);
      expect(Bowl.fromJson(bowl.toJson()), bowl);
      expect(Bowl.fromJson(Bowl.full.toJson()), Bowl.full);
      expect(
        Bowl.fromJson({
          'at': 'x',
          'eaten': ['oyen'],
        }),
        Bowl.full,
      );
      expect(
        Bowl.fromJson({
          'at': t0.millisecondsSinceEpoch,
          'eaten': ['oyen', 'harimau', 3],
        }),
        Bowl(filledAt: t0, eaten: {KittyId.oyen}),
      );
    });
  });

  group('HomeNeeds', () {
    final home = HomeNeeds.empty.withKitties([KittyId.oyen, KittyId.arang], t0);

    test('withKitties: kucing baru penuh, yang lama tetap', () {
      expect(home.of(KittyId.oyen, t0), CatNeeds.full(t0));
      final later = home.withKitties([KittyId.oyen, KittyId.salju], at(hour));
      expect(later.of(KittyId.oyen, at(hour)).hunger, lessThan(100));
      expect(later.of(KittyId.salju, at(hour)).hunger, 100);
      expect(home.withKitties([KittyId.oyen], at(hour)), same(home));
    });

    test(
      'adopted: kucing yang baru dibeli penuh, juga kalau ada entri lama',
      () {
        final stale = home.withKitties([KittyId.salju], t0);
        final later = at(hour * 10);
        final adopted = stale.adopted(KittyId.salju, later);
        expect(adopted.of(KittyId.salju, later), CatNeeds.full(later));
        expect(adopted.of(KittyId.oyen, later), home.of(KittyId.oyen, later));
      },
    );

    test('of: tanpa entri = penuh sekarang', () {
      expect(HomeNeeds.empty.of(KittyId.bos, t0), CatNeeds.full(t0));
    });

    test('feed, pet, play memakai aturan CatNeeds', () {
      final fed = home.feed(KittyId.oyen, snackOf(SnackId.susu), t0);
      expect(fed.of(KittyId.oyen, t0).hunger, 100);
      var petted = home;
      for (var i = 0; i < 3; i++) {
        petted = petted.pet(KittyId.oyen, t0)!;
      }
      expect(petted.pet(KittyId.oyen, t0), isNull);
      expect(petted.pet(KittyId.arang, t0), isNotNull);
      final played = home.play(KittyId.arang, t0)!;
      expect(played.play(KittyId.arang, at(minute * 10)), isNull);
    });

    test('mangkuk: +40 kalau Lapar < 70, sekali per isi', () {
      final hungry = at(hour * 6); // Lapar 50
      expect(home.canEatFromBowl(KittyId.oyen, t0), isFalse);
      expect(home.eatFromBowl(KittyId.oyen, t0), isNull);
      expect(home.canEatFromBowl(KittyId.oyen, hungry), isTrue);
      final ate = home.eatFromBowl(KittyId.oyen, hungry)!;
      expect(ate.of(KittyId.oyen, hungry).hunger, closeTo(90, 1e-9));
      expect(ate.bowl.hasEaten(KittyId.oyen, hungry), isTrue);

      // Lapar lagi di isi yang sama: tetap tidak boleh.
      final later = at(hour * 9);
      expect(ate.of(KittyId.oyen, later).hunger, lessThan(70));
      expect(ate.canEatFromBowl(KittyId.oyen, later), isFalse);
      expect(ate.canEatFromBowl(KittyId.arang, later), isTrue);
      expect(ate.canEatFromBowl(KittyId.oyen, at(hour * 10)), isTrue);
    });

    test('hadiah: kedua bar ≥ 70, sekali per hari kalender', () {
      expect(home.canClaim(KittyId.oyen, t0), isTrue);
      final claimed = home.claim(KittyId.oyen, t0)!;
      expect(claimed.canClaim(KittyId.oyen, at(hour * 2)), isFalse);
      expect(claimed.claim(KittyId.oyen, at(hour * 2)), isNull);
      expect(claimed.canClaim(KittyId.arang, at(hour * 2)), isTrue);

      final tomorrow = DateTime(2026, 10, 29, 7);
      final fresh = claimed.feed(
        KittyId.oyen,
        snackOf(SnackId.puding),
        tomorrow,
      );
      expect(fresh.canClaim(KittyId.oyen, tomorrow), isFalse);
      final cared = fresh
          .feed(KittyId.oyen, snackOf(SnackId.puding), tomorrow)
          .feed(KittyId.oyen, snackOf(SnackId.puding), tomorrow)
          .pet(KittyId.oyen, tomorrow)!
          .pet(KittyId.oyen, tomorrow)!
          .pet(KittyId.oyen, tomorrow)!;
      expect(cared.of(KittyId.oyen, tomorrow).joy, greaterThanOrEqualTo(70));
      expect(cared.canClaim(KittyId.oyen, tomorrow), isTrue);
    });

    test('hadiah: bar < 70 tidak boleh', () {
      expect(home.canClaim(KittyId.oyen, at(hour * 4)), isFalse);
    });

    test('hadiah: jam mundur ke hari sebelumnya tertahan', () {
      final claimed = home.claim(KittyId.oyen, t0)!;
      final yesterday = DateTime(2026, 10, 27, 20);
      expect(claimed.canClaim(KittyId.oyen, yesterday), isFalse);
    });

    test('menghias: +5 Senang semua kucing, sekali per jam', () {
      final now = at(hour * 8); // Senang 50
      final done = home.finishDecorating([KittyId.oyen, KittyId.arang], now)!;
      expect(done.of(KittyId.oyen, now).joy, closeTo(55, 1e-9));
      expect(done.of(KittyId.arang, now).joy, closeTo(55, 1e-9));
      expect(
        done.finishDecorating([KittyId.oyen], now.add(minute * 59)),
        isNull,
      );
      expect(
        done.finishDecorating([KittyId.oyen], now.add(minute * 60)),
        isNotNull,
      );
      expect(done.finishDecorating([KittyId.oyen], now.subtract(hour)), isNull);
    });

    test('reset: hanya Oyen, penuh; mangkuk dan hari hadiah tetap', () {
      final used = home
          .claim(KittyId.oyen, t0)!
          .eatFromBowl(KittyId.arang, at(hour * 6))!
          .finishDecorating([KittyId.oyen], at(hour * 6))!;
      final reset = used.reset(at(hour * 7));
      expect(reset.cats.keys, [KittyId.oyen]);
      expect(reset.of(KittyId.oyen, at(hour * 7)), CatNeeds.full(at(hour * 7)));
      expect(reset.bowl, used.bowl);
      expect(reset.rewardDays, used.rewardDays);
      expect(reset.decoratedAt, used.decoratedAt);
      expect(reset.canClaim(KittyId.oyen, at(hour * 7)), isFalse);
    });

    test('JSON pulang-pergi', () {
      final used = home
          .claim(KittyId.oyen, t0)!
          .eatFromBowl(KittyId.arang, at(hour * 6))!
          .finishDecorating([KittyId.oyen], at(hour * 6))!;
      expect(HomeNeeds.fromJson(used.toJson()), used);
      expect(HomeNeeds.fromJson(HomeNeeds.empty.toJson()), HomeNeeds.empty);
    });

    test('JSON waktu di luar jangkauan dibuang tanpa melempar', () {
      const huge = 8639999999999999;
      final read = HomeNeeds.fromJson({
        'cats': {
          'oyen': {...CatNeeds.full(t0).toJson(), 'at': huge},
        },
        'bowl': {
          'at': huge,
          'eaten': ['oyen'],
        },
        'decoratedAt': huge,
      });
      expect(read, HomeNeeds.empty);
      expect(read.canEatFromBowl(KittyId.oyen, t0), isFalse);
      expect(read.finishDecorating([KittyId.oyen], t0), isNotNull);
    });

    test('JSON rusak dibuang per bagian tanpa melempar', () {
      final read = HomeNeeds.fromJson({
        'cats': {
          'oyen': CatNeeds.full(t0).toJson(),
          'harimau': CatNeeds.full(t0).toJson(),
          'arang': {'hunger': 'x'},
        },
        'bowl': 'x',
        'rewardDays': {'oyen': 5, 'arang': 'x', 'bos': -1},
        'decoratedAt': 'x',
      });
      expect(read.cats, {KittyId.oyen: CatNeeds.full(t0)});
      expect(read.bowl, Bowl.full);
      expect(read.rewardDays, {KittyId.oyen: 5});
      expect(read.decoratedAt, isNull);
      expect(
        HomeNeeds.fromJson({'cats': [], 'rewardDays': 3}),
        HomeNeeds.empty,
      );
    });
  });
}
