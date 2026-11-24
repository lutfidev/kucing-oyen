// Jalankan: flutter run --profile -t tool/profile_room.dart -d <device>
// Tambah --dart-define=SWITCH_ROOMS=true untuk mengukur sambil pindah
// ruangan bolak-balik (pintu diketuk tiap 2,5 detik).
// Tambah --dart-define=PLACE=lane untuk mengukur di Gang Depan: jam di
// tengah kunjungan Kumis (Oyen dan Kumis di bangku), pintu depan diketuk
// sesudah 5 detik, lalu pengukuran di gang.
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
import 'package:kucing_oren/game/model/lane.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/room/door_parts.dart';
import 'package:kucing_oren/screens/room/front_door.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  var room = Room();
  for (final item in shopItems) {
    room = room.buy(item.id);
  }
  // Gang: level 1 menang (gang terbuka), sudah bertemu Kumis (tanpa
  // kunjungan paksa), jam berjalan dari 1 menit sesudah kunjungan pertama
  // hari ini dimulai.
  final store =
      MemoryProgressStore(_lane ? Progress(const {1: 3}) : Progress.empty)
        ..metNeighbor = _lane
        ..coins = 99999
        ..home = Home(
          room: room,
          kitties: KittyId.values,
          closet: AccessoryCloset(
            owned: AccessoryId.values,
            wearing: {
              for (final kitty in KittyId.values)
                kitty:
                    AccessoryId.values[kitty.index % AccessoryId.values.length],
            },
          ),
        );
  final started = DateTime.now();
  final visit = laneVisitsOn(started).first.start
      .add(const Duration(minutes: 1));
  final progress = await ProgressController.load(
    levels: await loadLevels(),
    store: store,
    clock: _lane ? () => visit.add(DateTime.now().difference(started)) : null,
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
  Timer? switching;
  if (_lane) Timer(const Duration(seconds: 5), _tapFrontDoor);
  Timer(const Duration(seconds: 15), () {
    measuring = true;
    print(
      'ROOM_PROFILE_START cats=${store.home.kitties.length} items=${room.placed.length} switch=$_switchRooms place=${_lane ? 'lane' : 'house'}',
    );
    if (_switchRooms) {
      switching = Timer.periodic(
        const Duration(milliseconds: 2500),
        (_) => _tapDoor(),
      );
    }
  });
  Timer(const Duration(seconds: 75), () {
    measuring = false;
    switching?.cancel();
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
        'switch_rooms': _switchRooms,
        'place': _lane ? 'lane' : 'house',
        'frames': frames.length,
        'seconds': 60,
        'cats': store.home.kitties.length,
        'items_including_bowl': room.placed.length,
        'build': stats([for (final f in frames) f.buildDuration.inMicroseconds / 1000]),
        'raster': stats([for (final f in frames) f.rasterDuration.inMicroseconds / 1000]),
        'over_16_67ms': frames.where((f) => f.buildDuration.inMicroseconds > 16667 || f.rasterDuration.inMicroseconds > 16667).length,
        'build_over_16_67ms': frames.where((f) => f.buildDuration.inMicroseconds > 16667).length,
        'raster_over_16_67ms': frames.where((f) => f.rasterDuration.inMicroseconds > 16667).length,
        'over_8_33ms': frames.where((f) => f.buildDuration.inMicroseconds > 8333 || f.rasterDuration.inMicroseconds > 8333).length,
      })}',
    );
  });
}

const _switchRooms = bool.fromEnvironment('SWITCH_ROOMS');
const _lane = String.fromEnvironment('PLACE') == 'lane';

/// Ketuk pintu depan (ke Gang Depan) lewat `onTap`-nya langsung.
void _tapFrontDoor() {
  void visit(Element element) {
    final widget = element.widget;
    if (widget is FrontDoorButton) return widget.onTap();
    element.visitChildElements(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildElements(visit);
}

/// Membuka pintu ruangan yang sedang tampil: cari [DoorButton] di pohon
/// widget lalu panggil `onTap`-nya langsung (sentuhan sungguhan bisa
/// mengenai kucing di depan pintu dan membuka kartunya). Selama transisi
/// kedua ruangan dibangun; ketukan dilewati sampai tinggal satu.
void _tapDoor() {
  final doors = <DoorButton>[];
  void visit(Element element) {
    final widget = element.widget;
    if (widget is DoorButton) {
      doors.add(widget);
      return;
    }
    element.visitChildElements(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildElements(visit);
  if (doors.length == 1) doors.single.onTap();
}
