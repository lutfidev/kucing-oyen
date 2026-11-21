// Jalankan: flutter run --profile -t tool/profile_room.dart -d <device>
// Data uji hanya di memori; tidak membaca atau menulis progres pemain.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  var room = Room();
  for (final item in shopItems) {
    room = room.buy(item.id);
  }
  final store = MemoryProgressStore()
    ..coins = 99999
    ..home = Home(
      room: room,
      kitties: KittyId.values,
      closet: AccessoryCloset(
        owned: AccessoryId.values,
        wearing: {
          for (final kitty in KittyId.values)
            kitty: AccessoryId.values[kitty.index % AccessoryId.values.length],
        },
      ),
    );
  final progress = await ProgressController.load(
    levels: await loadLevels(),
    store: store,
  );
  final audio = await GameAudio.load(
    store: store,
    player: AudioplayersSoundPlayer(),
  );
  final frames = <FrameTiming>[];
  var measuring = false;
  WidgetsBinding.instance.addTimingsCallback((batch) {
    if (measuring) frames.addAll(batch);
  });
  runApp(
    KucingOrenApp(
      progress: progress,
      audio: audio,
      roomRandom: () => Random(1),
    ),
  );
  Timer(const Duration(seconds: 15), () {
    measuring = true;
    print(
      'ROOM_PROFILE_START cats=${store.home.kitties.length} items=${room.placed.length}',
    );
  });
  Timer(const Duration(seconds: 75), () {
    measuring = false;
    Map<String, Object> stats(List<double> values) {
      values.sort();
      double percentile(double p) => values[((values.length - 1) * p).round()];
      return {
        'mean_ms': values.reduce((a, b) => a + b) / values.length,
        'p50_ms': percentile(.5),
        'p90_ms': percentile(.9),
        'p99_ms': percentile(.99),
        'max_ms': values.last,
      };
    }

    if (frames.isEmpty) {
      print('ROOM_PROFILE_RESULT no_frames');
      return;
    }
    print(
      'ROOM_PROFILE_RESULT ${jsonEncode({
        'frames': frames.length,
        'seconds': 60,
        'cats': store.home.kitties.length,
        'items_including_bowl': room.placed.length,
        'build': stats([for (final f in frames) f.buildDuration.inMicroseconds / 1000]),
        'raster': stats([for (final f in frames) f.rasterDuration.inMicroseconds / 1000]),
        'over_16_67ms': frames.where((f) => f.buildDuration.inMicroseconds > 16667 || f.rasterDuration.inMicroseconds > 16667).length,
        'over_8_33ms': frames.where((f) => f.buildDuration.inMicroseconds > 8333 || f.rasterDuration.inMicroseconds > 8333).length,
      })}',
    );
  });
}
