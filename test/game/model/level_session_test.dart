import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/game/sim/sim.dart';

void main() {
  final levels = parseLevels(
    File('assets/levels/chapter1-2.json').readAsStringSync(),
  );
  Level level(int id) => levels.firstWhere((l) => l.id == id);

  // Level 13 · Vas Ibu: Oyen di (4,3) menghadap kiri, vas di (2,3), gelas di
  // (1,4), mangkuk di (3,4), meja di (3,7). Baki: 1 ikan, 1 ember.
  group('fase atur', () {
    late LevelSession session;
    setUp(() => session = LevelSession(level(13)));

    test('mulai dengan papan kosong dan baki penuh', () {
      expect(session.phase, SessionPhase.arrange);
      expect(session.placed, isEmpty);
      expect(session.itemsUsed, 0);
      expect(session.remaining, {Item.fish: 1, Item.water: 1});
      expect(session.result, isNull);
      expect(session.stars, isNull);
    });

    test('place menaruh benda dan mengurangi baki', () {
      expect(session.place(Item.fish, const Pos(2, 4)), isTrue);
      expect(session.itemAt(const Pos(2, 4)), Item.fish);
      expect(session.placed, [const Placement(Item.fish, Pos(2, 4))]);
      expect(session.itemsUsed, 1);
      expect(session.remaining, {Item.fish: 0, Item.water: 1});
      expect(session.canPlaceAt(const Pos(2, 4)), isFalse);
    });

    test('place menolak petak yang bukan lantai kosong', () {
      const blocked = {
        'tembok': Pos(0, 0),
        'meja + vas': Pos(2, 3),
        'meja + gelas': Pos(1, 4),
        'mangkuk': Pos(3, 4),
        'meja': Pos(3, 7),
        'Oyen': Pos(4, 3),
        'luar kiri': Pos(-1, 3),
        'luar kanan': Pos(7, 3),
        'luar bawah': Pos(3, 9),
      };
      blocked.forEach((name, pos) {
        expect(session.canPlaceAt(pos), isFalse, reason: name);
        expect(session.place(Item.fish, pos), isFalse, reason: name);
      });
      expect(session.placed, isEmpty);
      expect(session.remaining, {Item.fish: 1, Item.water: 1});
    });

    test('place menolak petak yang sudah ada benda pemain', () {
      session.place(Item.fish, const Pos(2, 4));
      expect(session.place(Item.water, const Pos(2, 4)), isFalse);
      expect(session.itemAt(const Pos(2, 4)), Item.fish);
      expect(session.remaining, {Item.fish: 0, Item.water: 1});
    });

    test('place menolak benda yang sisa bakinya 0', () {
      session.place(Item.fish, const Pos(2, 4));
      expect(session.place(Item.fish, const Pos(1, 1)), isFalse);
      // Kardus tidak ada di baki level 13.
      expect(session.place(Item.box, const Pos(1, 1)), isFalse);
      expect(session.itemAt(const Pos(1, 1)), isNull);
      expect(session.itemsUsed, 1);
    });

    test('move memindah benda tanpa mengubah baki', () {
      session.place(Item.fish, const Pos(2, 4));
      expect(session.move(const Pos(2, 4), const Pos(5, 6)), isTrue);
      expect(session.itemAt(const Pos(2, 4)), isNull);
      expect(session.itemAt(const Pos(5, 6)), Item.fish);
      expect(session.placed, [const Placement(Item.fish, Pos(5, 6))]);
      expect(session.remaining, {Item.fish: 0, Item.water: 1});
      expect(session.canPlaceAt(const Pos(2, 4)), isTrue);
    });

    test('move menolak asal tanpa benda pemain dan tujuan yang tidak sah', () {
      session.place(Item.fish, const Pos(2, 4));
      session.place(Item.water, const Pos(3, 3));
      final before = session.placed;
      const rejected = {
        'asal kosong': (Pos(1, 1), Pos(2, 2)),
        'asal tembok': (Pos(0, 0), Pos(2, 2)),
        'tujuan terisi': (Pos(2, 4), Pos(3, 3)),
        'tujuan petak sendiri': (Pos(2, 4), Pos(2, 4)),
        'tujuan mangkuk': (Pos(2, 4), Pos(3, 4)),
        'tujuan Oyen': (Pos(2, 4), Pos(4, 3)),
        'tujuan luar peta': (Pos(2, 4), Pos(2, -1)),
      };
      rejected.forEach((name, move) {
        expect(session.move(move.$1, move.$2), isFalse, reason: name);
      });
      expect(session.placed, before);
    });

    test('remove mengembalikan benda ke baki', () {
      session.place(Item.fish, const Pos(2, 4));
      session.place(Item.water, const Pos(3, 3));
      expect(session.remove(const Pos(2, 4)), isTrue);
      expect(session.itemAt(const Pos(2, 4)), isNull);
      expect(session.placed, [const Placement(Item.water, Pos(3, 3))]);
      expect(session.remaining, {Item.fish: 1, Item.water: 0});
      expect(session.place(Item.fish, const Pos(1, 1)), isTrue);
    });

    test('remove menolak petak tanpa benda pemain', () {
      expect(session.remove(const Pos(2, 4)), isFalse);
      expect(session.remove(const Pos(2, 3)), isFalse);
      expect(session.remaining, {Item.fish: 1, Item.water: 1});
    });
  });

  // Level 15 · Kardus Penyok: ikan bawaan di (1,4), kardus bawaan di (2,4).
  group('benda bawaan peta', () {
    late LevelSession session;
    setUp(() => session = LevelSession(level(15)));

    test('tidak bisa ditimpa, dipindah, atau dikembalikan ke baki', () {
      for (final pos in const [Pos(1, 4), Pos(2, 4)]) {
        expect(session.canPlaceAt(pos), isFalse, reason: '$pos');
        expect(session.place(Item.water, pos), isFalse, reason: '$pos');
        expect(session.move(pos, const Pos(1, 1)), isFalse, reason: '$pos');
        expect(session.remove(pos), isFalse, reason: '$pos');
      }
      expect(session.placed, isEmpty);
      expect(session.remaining, {Item.fish: 1, Item.water: 1});
    });

    test('dibedakan dari benda pemain yang sejenis', () {
      session.place(Item.fish, const Pos(2, 3));
      expect(session.itemAt(const Pos(2, 3)), Item.fish);
      expect(session.board.cellAt(const Pos(2, 3)), Cell.floor);
      expect(session.itemAt(const Pos(1, 4)), isNull);
      expect(session.board.cellAt(const Pos(1, 4)), Cell.fish);
      expect(session.itemAt(const Pos(2, 4)), isNull);
      expect(session.board.cellAt(const Pos(2, 4)), Cell.box);
    });
  });

  group('pindah fase', () {
    late LevelSession session;
    setUp(() {
      session = LevelSession(level(13));
      session.place(Item.fish, const Pos(2, 4));
    });

    test('wake menjalankan simulasi dengan benda pemain', () {
      final result = session.wake();
      expect(session.phase, SessionPhase.running);
      expect(session.result, same(result));
      // Sama dengan simulate() langsung: ikan di (2,4), vas pecah langkah 2.
      expect(result.win, isTrue);
      expect(result.steps, 10);
      expect(result.vaseBrokenAtStep, 2);
    });

    test('finish masuk layar hasil', () {
      session.wake();
      session.finish();
      expect(session.phase, SessionPhase.result);
      expect(session.result, isNotNull);
    });

    test('aksi atur ditolak di fase jalan dan layar hasil', () {
      void expectLocked() {
        expect(session.canPlaceAt(const Pos(1, 1)), isFalse);
        expect(session.place(Item.water, const Pos(1, 1)), isFalse);
        expect(session.move(const Pos(2, 4), const Pos(1, 1)), isFalse);
        expect(session.remove(const Pos(2, 4)), isFalse);
        expect(session.placed, [const Placement(Item.fish, Pos(2, 4))]);
        expect(session.remaining, {Item.fish: 0, Item.water: 1});
      }

      session.wake();
      expectLocked();
      session.finish();
      expectLocked();
    });

    test('arrangeAgain kembali ke fase atur dengan susunan tetap', () {
      session.wake();
      session.finish();
      session.arrangeAgain();
      expect(session.phase, SessionPhase.arrange);
      expect(session.placed, [const Placement(Item.fish, Pos(2, 4))]);
      expect(session.remaining, {Item.fish: 0, Item.water: 1});
      expect(session.result, isNull);
      expect(session.stars, isNull);
      // Susunan bisa diubah lagi, lalu Oyen dibangunkan ulang.
      expect(session.place(Item.water, const Pos(3, 3)), isTrue);
      expect(session.wake().vaseBroken, isFalse);
    });

    test('arrangeAgain juga bisa dari fase jalan', () {
      session.wake();
      session.arrangeAgain();
      expect(session.phase, SessionPhase.arrange);
      expect(session.placed, [const Placement(Item.fish, Pos(2, 4))]);
      expect(session.result, isNull);
    });

    test('reset mengosongkan papan dari fase mana pun', () {
      session.reset();
      expect(session.placed, isEmpty);

      for (final toResult in [false, true]) {
        session.place(Item.fish, const Pos(2, 4));
        session.wake();
        if (toResult) session.finish();
        session.reset();
        expect(session.phase, SessionPhase.arrange);
        expect(session.placed, isEmpty);
        expect(session.remaining, {Item.fish: 1, Item.water: 1});
        expect(session.result, isNull);
        expect(session.stars, isNull);
      }
    });

    test('pindah fase yang tidak sah ditolak', () {
      expect(session.finish, throwsStateError);
      expect(session.arrangeAgain, throwsStateError);
      session.wake();
      expect(session.wake, throwsStateError);
      session.finish();
      expect(session.wake, throwsStateError);
      expect(session.finish, throwsStateError);
      expect(session.phase, SessionPhase.result);
    });
  });

  group('bintang', () {
    LevelSession play(Level level, List<Placement> placements) {
      final session = LevelSession(level);
      for (final p in placements) {
        expect(session.place(p.item, p.pos), isTrue, reason: '$p');
      }
      session.wake();
      expect(session.stars, isNotNull);
      session.finish();
      return session;
    }

    test('level 13, solusi JSON: menang, vas aman, 3 bintang', () {
      final session = play(level(13), level(13).solution);
      expect(session.result!.win, isTrue);
      expect(session.result!.vaseBroken, isFalse);
      expect(session.result!.steps, level(13).solutionSteps);
      expect(session.itemsUsed, level(13).starItems);
      expect(session.stars, 3);
    });

    test('level 13, ikan saja di (2,4): menang tapi vas pecah, 1 bintang', () {
      final session = play(level(13), const [Placement(Item.fish, Pos(2, 4))]);
      expect(session.result!.win, isTrue);
      expect(session.result!.vaseBroken, isTrue);
      expect(session.stars, 1);
    });

    test('level 13, tanpa benda: gagal, 0 bintang', () {
      final session = play(level(13), const []);
      expect(session.result!.win, isFalse);
      expect(session.result!.failReason, FailReason.loop);
      expect(session.stars, 0);
    });

    test('level 15, solusi JSON + ember di (1,1): boros benda, 2 bintang', () {
      final session = play(level(15), [
        ...level(15).solution,
        const Placement(Item.water, Pos(1, 1)),
      ]);
      expect(session.result!.win, isTrue);
      expect(session.result!.vaseBroken, isFalse);
      expect(session.itemsUsed, greaterThan(level(15).starItems));
      expect(session.stars, 2);
    });
  });
}
