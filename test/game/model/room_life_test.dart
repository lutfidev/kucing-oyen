import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room_life.dart';

/// Satu bingkai jam kamar.
const _frame = 1 / 30;

/// Rutinitas satu ruangan seperti v1: tanpa tempat nyaman dan tanpa pindah
/// ruangan, supaya test barang tetap memeriksa hal yang sama.
RoomLife _life(int seed) =>
    RoomLife(random: Random(seed), places: const {}, travelWeight: 0);

const _floor = HouseFloor();

final _bed = Spot(0.9, 0.2);
final _ball = Spot(0.1, 0.8);
final _bowl = Spot(0.5, 1);

const _uses = {
  RoomItemId.kasur: ItemUse.sleep,
  RoomItemId.bola: ItemUse.play,
  RoomItemId.mangkuk: ItemUse.eat,
  RoomItemId.rak: ItemUse.sit,
  RoomItemId.jendelaBurung: ItemUse.watch,
};

void _sync(
  RoomLife life, {
  Set<KittyId> kitties = const {KittyId.oyen},
  Map<RoomItemId, Spot>? targets,
  Map<RoomItemId, Map<KittyId, LifeRoute>> routes = const {},
  Set<KittyId> hungry = const {},
  Set<KittyId> sad = const {},
}) => life.sync(
  homes: {for (final k in kitties) k: (HouseRoom.living, Spot(0.5, 0.5))},
  targets: {
    for (final MapEntry(key: item, value: spot)
        in (targets ??
                {
                  RoomItemId.kasur: _bed,
                  RoomItemId.bola: _ball,
                  RoomItemId.mangkuk: _bowl,
                })
            .entries)
      item: {for (final k in kitties) k: LifeRoute(spot)},
    ...routes,
  },
  uses: _uses,
  toys: const {RoomItemId.bola, RoomItemId.jendelaBurung},
  hungry: hungry,
  sad: sad,
);

/// Maju [seconds] per bingkai; semua peristiwa.
List<LifeEvent> _run(RoomLife life, double seconds, [void Function()? each]) {
  final events = <LifeEvent>[];
  for (var t = 0.0; t < seconds; t += _frame) {
    events.addAll(life.advance(_frame));
    each?.call();
  }
  return events;
}

void main() {
  test('kucing mencapai barang tujuannya lalu memakainya', () {
    final life = _life(3);
    _sync(life);
    final reached = <RoomItemId>{};
    _run(life, 60, () {
      final cat = life.of(KittyId.oyen);
      if (cat.isInItem) {
        reached.add(cat.item!);
        expect(cat.spot, switch (cat.item!) {
          RoomItemId.kasur => _bed,
          RoomItemId.bola => _ball,
          _ => _bowl,
        });
        expect(life.userOf(cat.item!), KittyId.oyen);
      }
    });
    expect(reached, containsAll([RoomItemId.kasur, RoomItemId.bola]));
    // Kucing yang tidak lapar tidak menuju mangkuk.
    expect(reached, isNot(contains(RoomItemId.mangkuk)));
  });

  test('jalan 70 px desain per detik ke arah tujuan', () {
    final life = _life(1);
    _sync(life);
    _run(life, 30, () {
      final cat = life.of(KittyId.oyen);
      if (cat.activity == CatActivity.walking && cat.elapsed < 0.5) {
        expect(cat.pose, LifePose.walk);
        expect(cat.heading, isNot(LifeHeading.down));
      }
    });
  });

  test('satu barang tidak dipakai dua kucing sekaligus', () {
    for (var seed = 0; seed <= 20; seed++) {
      final life = _life(seed);
      _sync(
        life,
        kitties: {KittyId.oyen, KittyId.arang, KittyId.salju},
        targets: {RoomItemId.kasur: _bed},
      );
      _run(life, 40, () {
        final going = [
          for (final cat in life.cats)
            if (cat.item == RoomItemId.kasur) cat.kitty,
        ];
        expect(going.length, lessThanOrEqualTo(1), reason: 'seed $seed');
      });
    }
  });

  test('kucing lapar menuju mangkuk dan sampai sekali per kedatangan', () {
    final life = _life(5);
    _sync(life, hungry: {KittyId.oyen});
    final events = <LifeEvent>[];
    for (var t = 0.0; t < 20 && events.isEmpty; t += _frame) {
      events.addAll(life.advance(_frame));
    }
    expect(events, [const ReachedBowl(KittyId.oyen)]);
    expect(life.of(KittyId.oyen).activity, CatActivity.eating);
    // Sudah makan: tidak lapar lagi.
    _sync(life);
    expect(_run(life, 30).whereType<ReachedBowl>(), isEmpty);
  });

  test('dua kucing lapar: mangkuk dipakai bergantian', () {
    final life = _life(7);
    _sync(
      life,
      kitties: {KittyId.oyen, KittyId.arang},
      hungry: {KittyId.oyen, KittyId.arang},
    );
    final events = _run(life, 30, () {
      final eating = life.cats.where((c) => c.activity == CatActivity.eating);
      expect(eating.length, lessThanOrEqualTo(1));
    });
    expect(events.whereType<ReachedBowl>().map((e) => e.kitty).toSet(), {
      KittyId.oyen,
      KittyId.arang,
    });
  });

  test('mainan memancarkan UsedToy saat mulai dipakai', () {
    final life = _life(3);
    _sync(life, targets: {RoomItemId.bola: _ball});
    final events = _run(life, 40);
    expect(events, contains(const UsedToy(KittyId.oyen, RoomItemId.bola)));
  });

  test('dijeda: maju tidak mengubah apa pun', () {
    final life = _life(2);
    _sync(life);
    _run(life, 5);
    final cat = life.of(KittyId.oyen);
    final before = (cat.spot, cat.activity, cat.remaining);
    life.paused = true;
    expect(_run(life, 30), isEmpty);
    expect((cat.spot, cat.activity, cat.remaining), before);
  });

  test('barang tujuan hilang: perjalanan batal tanpa crash', () {
    final life = _life(3);
    _sync(life, targets: {RoomItemId.kasur: _bed});
    while (life.of(KittyId.oyen).activity != CatActivity.walking) {
      life.advance(_frame);
    }
    _sync(life, targets: const {});
    final cat = life.of(KittyId.oyen);
    expect(cat.activity, CatActivity.idle);
    expect(cat.item, isNull);
    _run(life, 10);
    expect(life.users, isEmpty);
  });

  test('barang dipindah saat dipakai: kucing dilepas', () {
    final life = _life(3);
    _sync(life, targets: {RoomItemId.kasur: _bed});
    while (!life.of(KittyId.oyen).isInItem) {
      life.advance(_frame);
    }
    _sync(life, targets: {RoomItemId.kasur: Spot(0.2, 0.2)});
    expect(life.userOf(RoomItemId.kasur), isNull);
    expect(life.of(KittyId.oyen).spot, _bed);
  });

  test('interrupt: semua kucing berhenti dan melepas barang', () {
    final life = _life(3);
    _sync(life, kitties: {KittyId.oyen, KittyId.arang});
    _run(life, 8);
    life.interrupt();
    expect(life.users, isEmpty);
    expect(life.cats.every((c) => c.activity == CatActivity.idle), isTrue);
  });

  test('reaksi selama durasinya lalu lanjut', () {
    final life = _life(3);
    _sync(life);
    life.react(KittyId.oyen, LifePose.petted, 1.6);
    final cat = life.of(KittyId.oyen);
    expect((cat.activity, cat.pose), (CatActivity.reacting, LifePose.petted));
    _run(life, 1.5);
    expect(cat.activity, CatActivity.reacting);
    _run(life, 0.2);
    expect(cat.activity, isNot(CatActivity.reacting));
  });

  test('kucing lesu tidak berkeliling, kecuali ke mangkuk', () {
    final life = _life(4);
    _sync(life, sad: {KittyId.oyen});
    _run(life, 30, () {
      final cat = life.of(KittyId.oyen);
      expect(cat.activity, CatActivity.sad);
      expect(cat.spot, Spot(0.5, 0.5));
    });
    _sync(life, sad: {KittyId.oyen}, hungry: {KittyId.oyen});
    expect(_run(life, 30), contains(const ReachedBowl(KittyId.oyen)));
  });

  test('kucing baru muncul di tempatnya tanpa memindahkan yang lain', () {
    final life = _life(3);
    _sync(life);
    _run(life, 4);
    final oyen = life.of(KittyId.oyen).spot;
    life.sync(
      homes: {
        KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5)),
        KittyId.mochi: (HouseRoom.living, Spot(0.1, 0.1)),
      },
      targets: {
        RoomItemId.kasur: {
          KittyId.oyen: LifeRoute(_bed),
          KittyId.mochi: LifeRoute(_bed),
        },
      },
      uses: _uses,
    );
    expect(life.of(KittyId.oyen).spot, oyen);
    expect(life.of(KittyId.mochi).spot, Spot(0.1, 0.1));
  });

  test('seed yang sama = rutinitas yang sama', () {
    List<String> trace(int seed) {
      final life = _life(seed);
      _sync(life, kitties: {KittyId.oyen, KittyId.salju});
      final out = <String>[];
      _run(life, 20, () => out.add('${life.cats.toList()}'));
      return out;
    }

    expect(trace(9), trace(9));
  });

  test('tempat berdiri per kucing: tiap kucing ke tempatnya sendiri', () {
    final oyenSpot = Spot(0.9, 0.2);
    final saljuSpot = Spot(0.85, 0.25);
    for (final (kitty, spot) in [
      (KittyId.oyen, oyenSpot),
      (KittyId.salju, saljuSpot),
    ]) {
      final life = _life(3);
      _sync(
        life,
        kitties: {kitty},
        targets: const {},
        routes: {
          RoomItemId.kasur: {
            KittyId.oyen: LifeRoute(oyenSpot),
            KittyId.salju: LifeRoute(saljuSpot),
          },
        },
      );
      while (!life.of(kitty).isInItem) {
        life.advance(_frame);
      }
      expect(life.of(kitty).spot, spot);
    }
  });

  test('barang tanpa rute untuk kucing itu tidak pernah dituju', () {
    final life = _life(3);
    _sync(
      life,
      kitties: {KittyId.oyen, KittyId.salju},
      targets: const {},
      routes: {
        RoomItemId.kasur: {KittyId.salju: LifeRoute(_bed)},
      },
    );
    _run(life, 60, () {
      expect(life.of(KittyId.oyen).item, isNull);
    });
    expect(life.of(KittyId.salju).item, anyOf(isNull, RoomItemId.kasur));
  });

  test('barang dinding: naik, pakai, lalu turun lewat pijakannya', () {
    final life = _life(3);
    final stand = Spot(0.3, 0);
    _sync(
      life,
      targets: const {},
      routes: {
        RoomItemId.jendelaBurung: {KittyId.oyen: LifeRoute(stand, hops: 2)},
      },
    );
    final cat = life.of(KittyId.oyen);
    final seen = <CatActivity>[];
    final events = _run(life, 40, () {
      if (seen.lastOrNull != cat.activity) seen.add(cat.activity);
      if (cat.activity case CatActivity.climbing || CatActivity.descending) {
        expect(cat.isInItem, isFalse);
        expect(cat.spot, stand);
        expect(life.users[RoomItemId.jendelaBurung], KittyId.oyen);
        expect(life.userOf(RoomItemId.jendelaBurung), isNull);
        expect(cat.hops, 2);
        expect(cat.hopProgress, inInclusiveRange(0, 1));
      }
    });
    final climb = seen.indexOf(CatActivity.climbing);
    expect(climb, greaterThan(0));
    expect(seen.sublist(climb - 1, climb + 3), [
      CatActivity.walking,
      CatActivity.climbing,
      CatActivity.using,
      CatActivity.descending,
    ]);
    expect(
      events,
      contains(const UsedToy(KittyId.oyen, RoomItemId.jendelaBurung)),
    );
  });

  test('naik dan turun masing-masing lifeHopSeconds per lompatan', () {
    final life = _life(3);
    _sync(
      life,
      targets: const {},
      routes: {
        RoomItemId.rak: {KittyId.oyen: LifeRoute(Spot(0.5, 0.5), hops: 2)},
      },
    );
    final cat = life.of(KittyId.oyen);
    while (cat.activity != CatActivity.climbing) {
      life.advance(_frame);
    }
    expect(cat.hopProgress, 0);
    life.advance(lifeHopSeconds);
    expect(cat.activity, CatActivity.climbing);
    expect(cat.hopProgress, closeTo(0.5, 1e-9));
    life.advance(lifeHopSeconds + 0.01);
    expect(cat.activity, CatActivity.using);
    while (cat.activity == CatActivity.using) {
      life.advance(_frame);
    }
    expect(cat.activity, CatActivity.descending);
    expect(cat.hopProgress, 0);
    life.advance(lifeHopSeconds * 2 + 0.01);
    expect(cat.activity, isNot(CatActivity.descending));
  });

  test('dijeda di tengah lompatan: kucing turun di tempat berdirinya', () {
    final life = _life(3);
    final stand = Spot(0.3, 0);
    _sync(
      life,
      targets: const {},
      routes: {
        RoomItemId.rak: {KittyId.oyen: LifeRoute(stand, hops: 1)},
      },
    );
    final cat = life.of(KittyId.oyen);
    while (cat.activity != CatActivity.climbing) {
      life.advance(_frame);
    }
    life.interrupt();
    expect(cat.activity, CatActivity.idle);
    expect(cat.spot, stand);
    expect(life.users, isEmpty);
  });

  test('reaksi di barang dinding: kucing tetap di barangnya, tidak turun', () {
    final life = _life(3);
    _sync(
      life,
      targets: const {},
      routes: {
        RoomItemId.rak: {KittyId.oyen: LifeRoute(Spot(0.3, 0), hops: 1)},
      },
    );
    final cat = life.of(KittyId.oyen);
    while (cat.activity != CatActivity.using) {
      life.advance(_frame);
    }
    for (final pose in [LifePose.petted, LifePose.happy]) {
      life.react(KittyId.oyen, pose, 1.6);
      life.rest(KittyId.oyen);
      expect(cat.activity, CatActivity.using);
      expect(cat.item, RoomItemId.rak);
      expect(life.userOf(RoomItemId.rak), KittyId.oyen);
    }
    // Lalu turun lewat rutenya seperti biasa.
    while (cat.activity == CatActivity.using) {
      life.advance(_frame);
    }
    expect(cat.activity, CatActivity.descending);
  });

  test('reaksi di tengah lompatan: lompatannya tidak putus', () {
    final life = _life(3);
    _sync(
      life,
      targets: const {},
      routes: {
        RoomItemId.rak: {KittyId.oyen: LifeRoute(Spot(0.3, 0), hops: 2)},
      },
    );
    final cat = life.of(KittyId.oyen);
    while (cat.activity != CatActivity.climbing) {
      life.advance(_frame);
    }
    life.advance(lifeHopSeconds);
    final progress = cat.hopProgress;
    life.react(KittyId.oyen, LifePose.petted, 1.6);
    life.rest(KittyId.oyen);
    expect(cat.activity, CatActivity.climbing);
    expect(cat.hopProgress, progress);
  });

  test('lukisan dan jam tidak dituju walau diberi rute', () {
    final life = _life(3);
    life.sync(
      homes: {KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5))},
      targets: {
        RoomItemId.lukisan: {KittyId.oyen: LifeRoute(Spot(0.2, 0))},
        RoomItemId.jam: {KittyId.oyen: LifeRoute(Spot(0.8, 0))},
      },
      uses: const {
        RoomItemId.lukisan: ItemUse.watch,
        RoomItemId.jam: ItemUse.play,
      },
    );
    _run(life, 60, () => expect(life.of(KittyId.oyen).item, isNull));
  });

  group('dua ruangan', () {
    final bedSpot = _floor.spotAtFeet(120, 560);
    final bowlSpot = _floor.spotAtFeet(300, 600);

    void syncHouse(
      RoomLife life,
      Map<KittyId, (HouseRoom, Spot)> homes, {
      Set<KittyId> hungry = const {},
      Set<KittyId> sad = const {},
    }) => life.sync(
      homes: homes,
      targets: {
        RoomItemId.kasur: {for (final k in homes.keys) k: LifeRoute(bedSpot)},
        RoomItemId.mangkuk: {
          for (final k in homes.keys) k: LifeRoute(bowlSpot),
        },
      },
      uses: _uses,
      itemRooms: const {
        RoomItemId.kasur: HouseRoom.living,
        RoomItemId.mangkuk: HouseRoom.living,
      },
      hungry: hungry,
      sad: sad,
    );

    test('lapar, mangkuk sedang dipakai: menunggu, tidak pindah ruangan', () {
      for (var seed = 0; seed < 10; seed++) {
        final life = RoomLife(
          random: Random(seed),
          places: const {},
          travelWeight: 50,
        );
        syncHouse(
          life,
          {
            KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5)),
            KittyId.mochi: (HouseRoom.living, Spot(0.3, 0.5)),
          },
          hungry: const {KittyId.oyen, KittyId.mochi},
        );
        final events = _run(life, 60);
        expect(events.whereType<LeftRoom>(), isEmpty, reason: 'seed $seed');
      }
    });

    test('tempat nyaman dekat kucing lain kurang menarik', () {
      const near = LifePlace(120, 560, pose: LifePose.sleep);
      const far = LifePlace(300, 450, pose: LifePose.lounge);
      var nearCount = 0;
      var farCount = 0;
      for (var seed = 0; seed < 200; seed++) {
        final life = RoomLife(
          random: Random(seed),
          places: const {
            HouseRoom.living: [near, far],
          },
          travelWeight: 0,
        );
        life.sync(
          homes: {
            KittyId.oyen: (HouseRoom.living, _floor.spotAtFeet(200, 500)),
            // Mochi lesu: diam dekat tempat yang dekat (di luar jarak
            // minimum lifeCatSpacing, masih di lifeCrowdRadius).
            KittyId.mochi: (HouseRoom.living, _floor.spotAtFeet(170, 590)),
          },
          targets: const {},
          uses: const {},
          sad: const {KittyId.mochi},
        );
        final oyen = life.of(KittyId.oyen);
        for (var t = 0.0; t < 10 && oyen.place == null; t += _frame) {
          life.advance(_frame);
        }
        switch (oyen.place) {
          case 0:
            nearCount++;
          case 1:
            farCount++;
        }
      }
      expect(farCount / (farCount + nearCount), greaterThanOrEqualTo(0.7));
      expect(nearCount, greaterThan(0));
    });

    test('kucing di teras tidak memakai barang ruang tengah', () {
      for (var seed = 0; seed < 10; seed++) {
        final life = RoomLife(random: Random(seed));
        syncHouse(life, {KittyId.oyen: (HouseRoom.terrace, Spot(0.5, 0.5))});
        final oyen = life.of(KittyId.oyen);
        _run(life, 120, () {
          if (oyen.room == HouseRoom.terrace) {
            expect(oyen.item, isNull, reason: 'seed $seed');
          }
        });
      }
    });

    test('pindah ruangan: ke ambang, keluar, lalu masuk di ambang sebelah', () {
      final life = RoomLife(random: Random(4));
      syncHouse(life, {
        KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5)),
        KittyId.mochi: (HouseRoom.terrace, Spot(0.5, 0.5)),
        KittyId.arang: (HouseRoom.living, Spot(0.3, 0.8)),
      });
      final seen = {for (final c in life.cats) c.kitty: <CatActivity>[]};
      final rooms = {for (final c in life.cats) c.kitty: c.room};
      var moves = 0;
      final events = _run(life, 600, () {
        for (final cat in life.cats) {
          final list = seen[cat.kitty]!;
          if (list.lastOrNull != cat.activity) list.add(cat.activity);
          if (cat.activity case CatActivity.leaving || CatActivity.entering) {
            expect(cat.activity.onFloor, isFalse);
            expect(cat.doorProgress, inInclusiveRange(0, 1));
          }
          if (cat.room != rooms[cat.kitty]) {
            moves++;
            expect(cat.activity, CatActivity.entering);
            expect(cat.spot, _floor.threshold(cat.room));
            final n = list.length;
            expect(list.sublist(n - 2), [
              CatActivity.leaving,
              CatActivity.entering,
            ]);
            // Berjalan ke ambang, kecuali sudah duduk di ambang pintu.
            expect(list[n - 3], anyOf(CatActivity.walking, CatActivity.idle));
            rooms[cat.kitty] = cat.room;
          }
        }
      });
      expect(moves, greaterThan(0));
      for (final kitty in seen.keys) {
        final rooms = [
          for (final e in events)
            switch (e) {
              LeftRoom(kitty: final k, :final from) when k == kitty =>
                'left ${from.name}',
              EnteredRoom(kitty: final k, :final to) when k == kitty =>
                'entered ${to.name}',
              _ => null,
            },
        ].nonNulls.toList();
        for (var i = 0; i < rooms.length; i++) {
          expect(rooms[i], startsWith(i.isEven ? 'left' : 'entered'));
        }
      }
    });

    test('kucing lapar di teras berjalan ke ruang tengah untuk makan', () {
      final life = RoomLife(random: Random(2));
      syncHouse(
        life,
        {KittyId.mochi: (HouseRoom.terrace, Spot(0.5, 0.5))},
        hungry: {KittyId.mochi},
      );
      final mochi = life.of(KittyId.mochi);
      while (mochi.activity == CatActivity.idle) {
        life.advance(_frame);
      }
      expect(mochi.traveling, isTrue);
      expect(mochi.activity, CatActivity.walking);
      final events = <LifeEvent>[];
      for (var t = 0.0; t < 60 && events.whereType<ReachedBowl>().isEmpty;) {
        events.addAll(life.advance(_frame));
        t += _frame;
      }
      expect(events, contains(const ReachedBowl(KittyId.mochi)));
      expect(mochi.room, HouseRoom.living);
    });

    for (final pausing in [false, true]) {
      test('${pausing ? 'paused' : 'interrupt'} saat keluar pintu: '
          'langsung di ruangan tujuan', () {
        final life = RoomLife(random: Random(2));
        syncHouse(
          life,
          {KittyId.mochi: (HouseRoom.terrace, Spot(0.5, 0.5))},
          hungry: {KittyId.mochi},
        );
        final mochi = life.of(KittyId.mochi);
        while (mochi.activity != CatActivity.leaving) {
          life.advance(_frame);
        }
        if (pausing) {
          life.paused = true;
        } else {
          life.interrupt();
        }
        expect(mochi.room, HouseRoom.living);
        expect(mochi.activity, CatActivity.idle);
        expect(mochi.spot, _floor.threshold(HouseRoom.living));
        expect(mochi.traveling, isFalse);
      });
    }

    test('sync ulang tidak memindahkan kucing yang sudah di teras', () {
      final life = RoomLife(random: Random(2));
      syncHouse(life, {KittyId.oyen: (HouseRoom.terrace, Spot(0.4, 0.6))});
      _run(life, 3);
      final oyen = life.of(KittyId.oyen);
      final spot = oyen.spot;
      syncHouse(life, {KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5))});
      expect(oyen.room, HouseRoom.terrace);
      expect(oyen.spot, spot);
    });

    test('tempat nyaman desain: tiga di ruang tengah, empat di teras', () {
      expect(lifePlaces[HouseRoom.living]!.map((p) => (p.x, p.y, p.pose)), [
        (146.0, 432.0, LifePose.lounge),
        (200.0, 560.0, LifePose.sleep),
        (345.0, 456.0, LifePose.idle),
      ]);
      expect(lifePlaces[HouseRoom.terrace]!.map((p) => (p.x, p.y, p.pose)), [
        (182.0, 600.0, LifePose.lounge),
        (282.0, 432.0, LifePose.idle),
        (296.0, 556.0, LifePose.idle),
        (46.0, 456.0, LifePose.idle),
      ]);
    });
  });

  group('mengajak', () {
    RoomLife alone(int seed, {HouseRoom room = HouseRoom.living}) {
      final life = RoomLife(random: Random(seed));
      life.sync(
        homes: {KittyId.oyen: (room, Spot(0.3, 0.6))},
        targets: const {},
        uses: const {},
      );
      return life;
    }

    /// Maju sampai kucing selesai masuk ruangan lain (paling lama 60 detik).
    List<LifeEvent> untilEntered(RoomLife life) {
      final events = <LifeEvent>[];
      for (var t = 0.0; t < 60; t += _frame) {
        events.addAll(life.advance(_frame));
        if (events.whereType<EnteredRoom>().isNotEmpty) break;
      }
      return events;
    }

    test('invite: berjalan ke ambang lalu masuk teras, betah 5 menit', () {
      final life = alone(1);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen);
      expect(oyen.traveling, isTrue);
      expect(oyen.activity, CatActivity.walking);
      final events = untilEntered(life);
      expect(events, contains(const LeftRoom(KittyId.oyen, HouseRoom.living)));
      expect(
        events,
        contains(const EnteredRoom(KittyId.oyen, HouseRoom.terrace)),
      );
      expect(oyen.room, HouseRoom.terrace);
      expect(oyen.stayLeft, closeTo(lifeStaySeconds, 0.1));
    });

    test('betah: 300 detik tidak pindah sendiri, tapi tetap beraktivitas', () {
      for (var seed = 0; seed < 5; seed++) {
        final life = alone(seed);
        final oyen = life.of(KittyId.oyen);
        life.invite(KittyId.oyen);
        untilEntered(life);
        final poses = <LifePose>{};
        final events = _run(life, lifeStaySeconds - 1, () {
          poses.add(oyen.pose);
        });
        expect(events.whereType<LeftRoom>(), isEmpty, reason: 'seed $seed');
        expect(oyen.room, HouseRoom.terrace);
        expect(poses.length, greaterThan(1), reason: 'seed $seed');
      }
    });

    test('sesudah betah: boleh pindah sendiri lagi', () {
      final life = alone(3);
      life.invite(KittyId.oyen);
      untilEntered(life);
      _run(life, lifeStaySeconds);
      expect(life.of(KittyId.oyen).stayLeft, 0);
      final events = _run(life, 900);
      expect(events, contains(const LeftRoom(KittyId.oyen, HouseRoom.terrace)));
    });

    test('diajak balik saat masih betah: langsung berjalan ke pintu', () {
      final life = alone(2);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen);
      untilEntered(life);
      _run(life, 10);
      life.invite(KittyId.oyen);
      expect(oyen.traveling, isTrue);
      expect(oyen.activity, anyOf(CatActivity.walking, CatActivity.leaving));
      final events = untilEntered(life);
      expect(
        events,
        contains(const EnteredRoom(KittyId.oyen, HouseRoom.living)),
      );
    });

    test('atDoor: langsung keluar dari ambang', () {
      final life = alone(2);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen, atDoor: true);
      expect(oyen.activity, CatActivity.leaving);
      expect(oyen.spot, _floor.threshold(HouseRoom.living));
      untilEntered(life);
      expect(oyen.room, HouseRoom.terrace);
      expect(oyen.stayLeft, closeTo(lifeStaySeconds, 0.1));
    });

    test('instant: langsung di ambang ruangan tujuan', () {
      final life = alone(2, room: HouseRoom.terrace);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen, instant: true);
      expect(oyen.room, HouseRoom.living);
      expect(oyen.spot, _floor.threshold(HouseRoom.living));
      expect(oyen.activity, CatActivity.idle);
      expect(oyen.stayLeft, lifeStaySeconds);
    });

    test('dijeda saat keluar sesudah diajak: tetap betah di tujuan', () {
      final life = alone(2);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen, atDoor: true);
      life.paused = true;
      expect(oyen.room, HouseRoom.terrace);
      expect(oyen.stayLeft, lifeStaySeconds);
    });

    test('dielus saat berjalan ke pintu: ajakan batal tanpa sisa', () {
      final life = alone(2);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen);
      life.react(KittyId.oyen, LifePose.petted, 1);
      expect(oyen.traveling, isFalse);
      expect(oyen.invited, isFalse);
    });

    test('moveTo: diletakkan di lantai lalu diam', () {
      final life = alone(2);
      final oyen = life.of(KittyId.oyen);
      _run(life, 5);
      life.moveTo(KittyId.oyen, Spot(0.7, 0.4));
      expect(oyen.spot, Spot(0.7, 0.4));
      expect(oyen.activity, CatActivity.idle);
      expect(oyen.item, isNull);
    });
  });

  group('keluar ke gang', () {
    RoomLife house(
      int seed, {
      Map<KittyId, (HouseRoom, Spot)>? homes,
      Map<HouseRoom, List<LifePlace>> places = const {},
    }) {
      final life = RoomLife(
        random: Random(seed),
        places: places,
        travelWeight: 0,
      );
      life.sync(
        homes: homes ?? {KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5))},
        targets: const {},
        uses: const {},
      );
      return life;
    }

    /// Maju sampai [done] (paling lama [limit] detik); semua peristiwa.
    List<LifeEvent> until(
      RoomLife life,
      bool Function() done, {
      double limit = 60,
    }) {
      final events = <LifeEvent>[];
      for (var t = 0.0; t < limit && !done(); t += _frame) {
        events.addAll(life.advance(_frame));
      }
      return events;
    }

    test(
      'goOut: berjalan ke pintu depan, lewat pintu kucing, lalu di luar',
      () {
        final life = house(1);
        final oyen = life.of(KittyId.oyen);
        life.goOut(KittyId.oyen);
        expect(oyen.activity, CatActivity.walking);
        expect(oyen.outside, isFalse);
        final walked = until(life, () => oyen.activity == CatActivity.leaving);
        expect(walked.whereType<WentOut>(), isEmpty);
        expect(oyen.spot, _floor.frontThreshold);
        expect(oyen.viaFlap, isTrue);
        expect(oyen.heading, LifeHeading.left);
        final events = until(life, () => oyen.outside);
        expect(events, contains(const WentOut(KittyId.oyen, viaFlap: true)));
        expect(oyen.outside, isTrue);
        expect(oyen.viaFlap, isFalse);
        expect(life.advance(10), isEmpty);
        expect(oyen.outside, isTrue);
      },
    );

    test('dijeda di tengah pintu kucing: langsung di luar', () {
      final life = house(2);
      final oyen = life.of(KittyId.oyen);
      life.goOut(KittyId.oyen);
      until(life, () => oyen.activity == CatActivity.leaving);
      life.advance(lifeDoorSeconds / 2);
      expect(oyen.isPassing, isTrue);
      life.paused = true;
      expect(oyen.outside, isTrue);
      expect(oyen.isPassing, isFalse);
      life.paused = false;
      // Tetap dilaporkan sebagai lewat pintu kucing: pintunya berayun dan
      // pembaca layar mengumumkan Oyen menyelinap.
      expect(
        life.advance(_frame),
        contains(const WentOut(KittyId.oyen, viaFlap: true)),
      );
    });

    test('goOutNow di tengah pintu kucing: bukan lewat pintu kucing', () {
      final life = house(2);
      final oyen = life.of(KittyId.oyen);
      life.goOut(KittyId.oyen);
      until(life, () => oyen.activity == CatActivity.leaving);
      life.advance(lifeDoorSeconds / 2);
      life.goOutNow(KittyId.oyen);
      expect(oyen.outside, isTrue);
      expect(life.advance(_frame), [const WentOut(KittyId.oyen)]);
    });

    test('goOut selama dijeda menunggu sampai rutinitas jalan lagi', () {
      final life = house(2);
      final oyen = life.of(KittyId.oyen);
      life.paused = true;
      life.goOut(KittyId.oyen);
      expect(life.wantsOut(KittyId.oyen), isTrue);
      expect(oyen.activity, isNot(CatActivity.walking));
      life.paused = false;
      until(life, () => oyen.outside);
      expect(oyen.outside, isTrue);
      expect(life.wantsOut(KittyId.oyen), isFalse);
    });

    test('goOutNow: pemain menyusul ke gang, Oyen langsung di luar', () {
      // Sedang berjalan ke pintu.
      final walking = house(5);
      walking.goOut(KittyId.oyen);
      walking.advance(0.5);
      walking.goOutNow(KittyId.oyen);
      expect(walking.of(KittyId.oyen).outside, isTrue);
      expect(walking.wantsOut(KittyId.oyen), isFalse);
      // Diajak ke teras (betah): menyusul tetap membawanya keluar.
      final invited = house(5);
      invited.invite(KittyId.oyen, instant: true);
      invited.goOut(KittyId.oyen);
      invited.goOutNow(KittyId.oyen);
      final oyen = invited.of(KittyId.oyen);
      expect(oyen.outside, isTrue);
      expect(oyen.stayLeft, 0);
      expect(invited.advance(_frame), contains(const WentOut(KittyId.oyen)));
      // Dijeda (kartu terbuka) tidak menahan.
      final paused = house(5)..paused = true;
      paused.goOutNow(KittyId.oyen);
      expect(paused.of(KittyId.oyen).outside, isTrue);
    });

    test('di teras atau instant: langsung di luar', () {
      final terrace = house(
        3,
        homes: {KittyId.oyen: (HouseRoom.terrace, Spot(0.5, 0.5))},
      );
      terrace.goOut(KittyId.oyen);
      expect(terrace.of(KittyId.oyen).outside, isTrue);
      expect(terrace.advance(_frame), contains(const WentOut(KittyId.oyen)));

      final instant = house(3);
      instant.goOut(KittyId.oyen, instant: true);
      expect(instant.of(KittyId.oyen).outside, isTrue);
    });

    test('diajak ke teras: baru keluar sesudah betahnya habis', () {
      final life = house(4);
      final oyen = life.of(KittyId.oyen);
      life.invite(KittyId.oyen, instant: true);
      expect(oyen.stayLeft, lifeStaySeconds);
      life.goOut(KittyId.oyen);
      expect(life.wantsOut(KittyId.oyen), isTrue);
      expect(oyen.outside, isFalse);
      _run(life, lifeStaySeconds - 1);
      expect(oyen.outside, isFalse);
      expect(oyen.room, HouseRoom.terrace);
      _run(life, 2);
      expect(oyen.outside, isTrue);
    });

    test('Oyen yang di luar melepas tempatnya untuk kucing lain', () {
      const places = {
        HouseRoom.living: [
          LifePlace(200, 520, pose: LifePose.lounge, weight: 1000),
        ],
      };
      final life = house(5, places: places);
      final oyen = life.of(KittyId.oyen);
      until(life, () => oyen.place == 0);
      expect(oyen.place, 0);
      life.sync(
        homes: {
          KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5)),
          KittyId.salju: (HouseRoom.living, Spot(0.2, 0.9)),
        },
        targets: const {},
        uses: const {},
      );
      final salju = life.of(KittyId.salju);
      _run(life, 20);
      expect(salju.place, isNull);
      life.goOut(KittyId.oyen, instant: true);
      expect(oyen.place, isNull);
      until(life, () => salju.place == 0, limit: 120);
      expect(salju.place, 0);
    });

    test('comeHome: masuk lewat pintu kucing ke ruang tengah', () {
      final life = house(6);
      final oyen = life.of(KittyId.oyen);
      life.goOut(KittyId.oyen, instant: true);
      life.comeHome(KittyId.oyen);
      expect(oyen.outside, isFalse);
      expect(oyen.room, HouseRoom.living);
      expect(oyen.spot, _floor.frontThreshold);
      expect(oyen.activity, CatActivity.entering);
      expect(oyen.viaFlap, isTrue);
      final events = until(life, () => oyen.activity != CatActivity.entering);
      expect(
        events,
        contains(const EnteredRoom(KittyId.oyen, HouseRoom.living)),
      );
      expect(oyen.viaFlap, isFalse);

      final instant = house(6);
      instant.goOut(KittyId.oyen, instant: true);
      instant.comeHome(KittyId.oyen, instant: true);
      final back = instant.of(KittyId.oyen);
      expect(back.outside, isFalse);
      expect(back.spot, _floor.frontThreshold);
      expect(back.activity, CatActivity.idle);
    });

    test('comeHome di tengah pintu kucing: tanpa WentOut palsu', () {
      final life = house(9);
      final oyen = life.of(KittyId.oyen);
      life.goOut(KittyId.oyen);
      until(life, () => oyen.activity == CatActivity.leaving);
      life.comeHome(KittyId.oyen, instant: true);
      expect(oyen.outside, isFalse);
      expect(life.advance(_frame).whereType<WentOut>(), isEmpty);

      final paused = house(9);
      final cat = paused.of(KittyId.oyen);
      paused.goOut(KittyId.oyen);
      until(paused, () => cat.activity == CatActivity.leaving);
      paused.paused = true;
      paused.comeHome(KittyId.oyen, instant: true);
      paused.paused = false;
      expect(paused.advance(_frame).whereType<WentOut>(), isEmpty);
      expect(cat.outside, isFalse);
    });

    test('sync dengan kucing baru tidak memasukkan Oyen yang di luar', () {
      final life = house(7);
      life.goOut(KittyId.oyen, instant: true);
      life.sync(
        homes: {
          KittyId.oyen: (HouseRoom.living, Spot(0.5, 0.5)),
          KittyId.salju: (HouseRoom.living, Spot(0.2, 0.9)),
        },
        targets: const {},
        uses: const {},
        sad: const {KittyId.oyen},
      );
      final oyen = life.of(KittyId.oyen);
      expect(oyen.outside, isTrue);
      expect(oyen.activity, isNot(CatActivity.sad));
      _run(life, 20);
      expect(oyen.outside, isTrue);
    });

    test('Hias di tengah jalan ke pintu: keluar sesudah Hias selesai', () {
      final life = house(8);
      final oyen = life.of(KittyId.oyen);
      life.goOut(KittyId.oyen);
      life.advance(0.5);
      life.interrupt();
      expect(oyen.activity, CatActivity.idle);
      expect(life.wantsOut(KittyId.oyen), isTrue);
      until(life, () => oyen.outside);
      expect(oyen.outside, isTrue);
    });
  });

  group('tenang (langkah 40)', () {
    const all = KittyId.values;
    // Rumah penuh di ruang tengah: kucing tersebar, barang di kisi.
    final items = <RoomItemId, Spot>{
      RoomItemId.kasur: Spot(0.15, 0.3),
      RoomItemId.bola: Spot(0.85, 0.3),
      RoomItemId.mangkuk: _bowl,
      RoomItemId.rak: Spot(0.5, 0.05),
      RoomItemId.jendelaBurung: Spot(0.2, 0.05),
    };
    RoomLife full(int seed) {
      final life = RoomLife(random: Random(seed), travelWeight: 0);
      life.sync(
        homes: {
          for (final k in all)
            k: (
              HouseRoom.living,
              Spot(0.1 + 0.1 * (k.index % 9), 0.4 + 0.15 * (k.index % 3)),
            ),
        },
        targets: {
          for (final MapEntry(key: item, value: spot) in items.entries)
            item: {for (final k in all) k: LifeRoute(spot)},
        },
        uses: _uses,
        toys: const {RoomItemId.bola, RoomItemId.jendelaBurung},
      );
      return life;
    }

    bool onFoot(CatLife c) => const {
      CatActivity.walking,
      CatActivity.climbing,
      CatActivity.descending,
    }.contains(c.activity);

    test('paling banyak 2 kucing berjalan per ruangan', () {
      for (final seed in [1, 2, 3]) {
        final life = full(seed)..watching = HouseRoom.living;
        _run(life, 300, () {
          for (final room in HouseRoom.values) {
            final walking = life.cats
                .where((c) => c.room == room && !c.outside && onFoot(c))
                .length;
            expect(walking, lessThanOrEqualTo(lifeMaxWalkers));
          }
        });
      }
    });

    test('ruangan yang ditonton bergerak dalam 3 detik', () {
      for (final seed in [1, 2, 3, 4]) {
        final life = full(seed)..watching = HouseRoom.living;
        var moved = false;
        _run(life, 3, () {
          if (life.cats.any(onFoot)) moved = true;
        });
        expect(moved, isTrue, reason: 'seed $seed');
      }
    });

    test('tidak pernah 8,5 detik diam di ruangan yang ditonton', () {
      for (final seed in [1, 2]) {
        final life = full(seed)..watching = HouseRoom.living;
        var still = 0.0;
        _run(life, 300, () {
          final lively = life.cats.any(
            (c) =>
                onFoot(c) ||
                (c.isInItem && c.item == RoomItemId.bola) ||
                (c.isInItem && c.item == RoomItemId.jendelaBurung),
          );
          still = lively ? 0 : still + _frame;
          expect(still, lessThan(8.5), reason: 'seed $seed');
        });
      }
    });

    test('dorongan tidak membangunkan kucing yang tidur di tempat nyaman', () {
      for (var seed = 0; seed < 20; seed++) {
        final life = RoomLife(
          random: Random(seed),
          places: const {
            HouseRoom.living: [
              LifePlace(120, 600, pose: LifePose.sleep),
              LifePlace(300, 450, pose: LifePose.lounge),
            ],
          },
          travelWeight: 0,
        );
        life.sync(
          homes: {
            KittyId.oyen: (HouseRoom.living, _floor.spotAtFeet(120, 600)),
            KittyId.salju: (HouseRoom.living, _floor.spotAtFeet(220, 470)),
          },
          targets: {
            RoomItemId.bola: {
              KittyId.oyen: LifeRoute(_ball),
              KittyId.salju: LifeRoute(_ball),
            },
          },
          uses: _uses,
          toys: const {RoomItemId.bola},
        );
        life.of(KittyId.oyen)
          ..place = 0
          ..pose = LifePose.sleep
          ..remaining = 100;
        life.of(KittyId.salju).remaining = 100;
        life.watching = HouseRoom.living;
        _run(life, 3);
        expect(life.of(KittyId.oyen).place, 0, reason: 'seed $seed');
        expect(
          life.of(KittyId.salju).activity,
          isNot(CatActivity.idle),
          reason: 'seed $seed',
        );
      }
    });

    test('selesai turun dari barang: dirinya tidak dihitung berjalan', () {
      // Mochi sedang berjalan (1 slot), Oyen baru selesai turun: masih ada
      // slot untuk Oyen, jadi di beberapa seed Oyen langsung berjalan.
      var walked = 0;
      for (var seed = 1; seed <= 20; seed++) {
        final life = _life(seed);
        _sync(life, kitties: {KittyId.oyen, KittyId.mochi});
        life.of(KittyId.mochi)
          ..traveling = true
          ..activity = CatActivity.walking
          ..spot = Spot(0.1, 1);
        life.of(KittyId.oyen)
          ..activity = CatActivity.descending
          ..hops = 1
          ..remaining = _frame / 2;
        life.advance(_frame);
        final oyen = life.of(KittyId.oyen);
        expect(oyen.activity, isNot(CatActivity.descending));
        if (oyen.activity == CatActivity.walking) walked++;
      }
      expect(walked, greaterThan(0));
    });

    test('tidak memilih diam di ambang pintu dekat kucing lain', () {
      final door = _floor.threshold(HouseRoom.living);
      expect(_floor.onDoorPath(HouseRoom.living, door), isTrue);
      for (var seed = 1; seed <= 20; seed++) {
        final life = _life(seed);
        _sync(life, kitties: {KittyId.oyen, KittyId.mochi});
        life.of(KittyId.mochi)
          ..spot = door
          ..remaining = 100;
        life.of(KittyId.oyen)
          ..spot = door
          ..remaining = _frame / 2;
        life.advance(_frame);
        expect(
          life.of(KittyId.oyen).activity,
          CatActivity.walking,
          reason: 'seed $seed',
        );
      }
    });

    test('tanpa ruangan ditonton tidak ada dorongan', () {
      final life = _life(1);
      _sync(life, targets: const {});
      final cat = life.of(KittyId.oyen)..remaining = 100;
      _run(life, 10);
      expect(cat.activity, CatActivity.idle);
    });

    test('diam 8–20 detik, memakai barang 8–14, tidur 20–40', () {
      final life = _life(5);
      _sync(life);
      var last = life.of(KittyId.oyen).activity;
      var idles = 0;
      var uses = 0;
      _run(life, 600, () {
        final cat = life.of(KittyId.oyen);
        if (cat.activity != last) {
          final left = cat.remaining + _frame;
          if (cat.activity == CatActivity.idle) {
            idles++;
            expect(left, inInclusiveRange(lifeIdleMin, lifeIdleMax + _frame));
          } else if (cat.activity == CatActivity.using) {
            uses++;
            final (lo, hi) = cat.item == RoomItemId.kasur
                ? (lifeSleepMin, lifeSleepMax)
                : (lifeUseMin, lifeUseMax);
            expect(
              left,
              inInclusiveRange(lo, hi + _frame),
              reason: '${cat.item}',
            );
          }
          last = cat.activity;
        }
      });
      expect(idles, greaterThan(3));
      expect(uses, greaterThan(3));
    });

    test('tujuan tidak dalam 40 px dari kucing lain (selain mangkuk)', () {
      final life = full(7)..watching = HouseRoom.living;
      Spot? stop(CatLife c) => c.isInItem && c.item != RoomItemId.mangkuk
          ? c.spot
          : c.place != null && !onFoot(c)
          ? c.spot
          : null;
      _run(life, 300, () {
        final stops = [
          for (final c in life.cats)
            if (stop(c) case final s?) (c.kitty, s),
        ];
        for (var i = 0; i < stops.length; i++) {
          for (var j = i + 1; j < stops.length; j++) {
            expect(
              _floor.distance(stops[i].$2, stops[j].$2),
              greaterThanOrEqualTo(lifeCatSpacing - 0.01),
              reason: '${stops[i].$1} × ${stops[j].$1}',
            );
          }
        }
      });
    });

    test('kucing lapar tetap ke mangkuk walau slot jalan penuh', () {
      final life = _life(1);
      _sync(
        life,
        kitties: {KittyId.oyen, KittyId.salju, KittyId.telon},
        hungry: {KittyId.oyen},
      );
      // Dua kucing sedang berjalan ke kasur dan bola.
      for (final (k, item) in [
        (KittyId.salju, RoomItemId.kasur),
        (KittyId.telon, RoomItemId.bola),
      ]) {
        life.of(k)
          ..item = item
          ..activity = CatActivity.walking
          ..pose = LifePose.walk;
      }
      life.of(KittyId.oyen).remaining = 0;
      life.advance(_frame);
      expect(life.of(KittyId.oyen).activity, CatActivity.walking);
      expect(life.of(KittyId.oyen).item, RoomItemId.mangkuk);
    });

    test('slot penuh: kucing lain menunggu sebentar', () {
      final life = _life(1);
      _sync(
        life,
        kitties: {KittyId.oyen, KittyId.salju, KittyId.telon},
        // Rak bebas: Oyen sebenarnya punya tujuan.
        targets: {
          RoomItemId.kasur: _bed,
          RoomItemId.bola: _ball,
          RoomItemId.mangkuk: _bowl,
          RoomItemId.rak: Spot(0.5, 0.05),
        },
      );
      for (final (k, item) in [
        (KittyId.salju, RoomItemId.kasur),
        (KittyId.telon, RoomItemId.bola),
      ]) {
        life.of(k)
          ..item = item
          ..activity = CatActivity.walking
          ..pose = LifePose.walk;
      }
      final oyen = life.of(KittyId.oyen)..remaining = 0;
      var waits = 0;
      for (var i = 0; i < 20; i++) {
        oyen.remaining = 0;
        life.advance(_frame);
        // Tidak pernah berangkat; kadang memilih diam biasa, kadang menunggu.
        expect(oyen.activity, CatActivity.idle);
        if (oyen.remaining == lifeWaitSeconds) waits++;
      }
      expect(waits, greaterThan(0));
    });
  });
}
