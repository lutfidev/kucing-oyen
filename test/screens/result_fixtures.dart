/// Contoh hasil untuk test layar hasil dan test overflow.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/level_session.dart';
import 'package:kucing_oren/game/sim/sim.dart';

/// Level dibaca langsung dari berkas, tanpa `rootBundle`.
final levels = parseLevels(File(chapter1to2Asset).readAsStringSync());

/// Peta 7×9 yang membuat Oyen lewat [maxSteps] langkah tanpa mengulang
/// keadaan. Tidak ada level asli yang bisa kelamaan (paling lama 58
/// langkah).
final longWalk = Level(
  id: 21,
  name: 'Lorong Panjang',
  chapter: 3,
  map: const [
    '#######',
    '#^..#.#',
    '#.....#',
    '#T...##',
    '#.#..##',
    '###.FA#',
    '##.F..#',
    '#.A#.F#',
    '#######',
  ],
  inventory: const {},
  starItems: 0,
  solution: const [],
  solutionSteps: 0,
);

/// Sesi level [level] yang sudah di layar hasil dengan benda [placed].
LevelSession resultOf(Level level, [List<Placement> placed = const []]) {
  final session = LevelSession(level);
  for (final p in placed) {
    expect(session.place(p.item, p.pos), isTrue, reason: '$p');
  }
  session
    ..wake()
    ..finish();
  return session;
}

/// Ikan saja di (2,4) level 13: vas pecah di langkah 2 (contoh desain 07).
const fishOnly = [Placement(Item.fish, Pos(2, 4))];

/// Level 15: solusi JSON ditambah ember yang tidak perlu (2 bintang).
const twoStars = [
  Placement(Item.fish, Pos(2, 3)),
  Placement(Item.water, Pos(1, 1)),
];

/// Sinar dan "PRANG!" bergerak terus, jadi `pumpAndSettle` tidak pernah
/// selesai di layar Berhasil dan vas pecah: majukan waktu per bingkai.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 16);
  for (var t = Duration.zero; t < duration; t += frame) {
    await tester.pump(frame);
  }
}
