import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room_life.dart';

/// Satu bingkai jam kamar.
const _frame = 1 / 30;

RoomLife _life(int seed) =>
    RoomLife(random: Random(seed), spanX: 280, spanY: 130);

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
  homes: {for (final k in kitties) k: Spot(0.5, 0.5)},
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
      homes: {KittyId.oyen: Spot(0.5, 0.5), KittyId.mochi: Spot(0.1, 0.1)},
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
}
