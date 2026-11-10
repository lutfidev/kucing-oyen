// flutter run --profile -t tool/profile_room.dart -d <Android-device>
// Automatic v2 scenarios. No preferences or production ad SDK.
// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/level_loader.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/render/svg_template.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/screens/room/home_view.dart';

import 'profile_fixture.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final c = await profileProgress(await loadLevels());
  final audio = await GameAudio.load(
    store: c.store,
    player: AudioplayersSoundPlayer(),
  );
  runApp(
    KucingOrenApp(
      progress: c,
      audio: audio,
      homeBuilder: (_) => _ProfileHome(progress: c),
    ),
  );
}

class _ProfileHome extends StatefulWidget {
  const _ProfileHome({required this.progress});
  final ProgressController progress;
  @override
  State<_ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<_ProfileHome>
    with WidgetsBindingObserver {
  final _samples = <FrameTiming>[];
  final _pack = ArtPack.load();
  bool _measuring = false, _valid = true;
  int _dropped = 0;
  ProgressController get c => widget.progress;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addTimingsCallback(_timings);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_run()));
  }

  void _timings(List<FrameTiming> batch) {
    if (!_measuring) return;
    for (final frame in batch) {
      if (_samples.length < 12000) {
        _samples.add(frame);
      } else {
        _dropped++;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_measuring && state != AppLifecycleState.resumed) _valid = false;
  }

  Map<String, Object> _stats(List<double> values) {
    values.sort();
    if (values.isEmpty) return {'samples': 0};
    double at(double p) => values[((values.length - 1) * p).round()];
    return {
      'mean_ms': values.reduce((a, b) => a + b) / values.length,
      'p50_ms': at(.5),
      'p90_ms': at(.9),
      'p95_ms': at(.95),
      'p99_ms': at(.99),
      'max_ms': values.last,
    };
  }

  Future<void> _measure(String name, {Future<void> Function()? actions}) async {
    await Future<void>.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _samples.clear();
    _dropped = 0;
    _valid =
        (WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed) ==
        AppLifecycleState.resumed;
    final rss = ProcessInfo.currentRss;
    final watch = Stopwatch()..start();
    _measuring = true;
    print('V2_PROFILE_START $name');
    if (actions == null) {
      await Future<void>.delayed(const Duration(seconds: 20));
    } else {
      await actions();
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _measuring = false;
    watch.stop();
    final cache = PaintingBinding.instance.imageCache;
    print(
      'V2_PROFILE_RESULT ${jsonEncode({
        'scenario': name,
        'mode': kProfileMode ? 'profile' : 'non_profile',
        'valid': _valid && _dropped == 0 && _samples.isNotEmpty,
        'elapsed_ms': watch.elapsedMilliseconds,
        'frames': _samples.length,
        'dropped_samples': _dropped,
        'cats': c.home.kitties.length,
        'placed': c.household.areas.placed.length,
        'stored': c.home.room.owned.length - c.household.areas.placed.length,
        'area_counts': {for (final a in HomeArea.values) a.name: c.household.routine.present(a).length},
        'build': _stats([for (final f in _samples) f.buildDuration.inMicroseconds / 1000]),
        'raster': _stats([for (final f in _samples) f.rasterDuration.inMicroseconds / 1000]),
        'over_16_67ms': _samples.where((f) => f.buildDuration.inMicroseconds > 16667 || f.rasterDuration.inMicroseconds > 16667).length,
        'rss_before_bytes': rss,
        'rss_after_bytes': ProcessInfo.currentRss,
        'max_rss_bytes': ProcessInfo.maxRss,
        'image_cache_entries': cache.currentSize,
        'image_cache_bytes': cache.currentSizeBytes,
        'live_images': cache.liveImageCount,
        'svg_paths': SvgTemplate.cachedPaths,
      })}',
    );
  }

  Future<void> _run() async {
    await _pack;
    if (!mounted) return;
    final router = GoRouter.of(context);
    for (final area in HomeArea.values) {
      await c.setHomeArea(area);
      await _measure('area_${area.name}');
      if (!mounted) return;
    }
    await _measure(
      'area_transitions',
      actions: () async {
        for (var i = 0; i < 20 && mounted; i++) {
          await c.setHomeArea(HomeArea.values[i % 4]);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      },
    );
    if (!mounted) return;
    router.go(AppRoutes.level(13, chapter: 2));
    await _measure('puzzle_arrange_13');
    if (!mounted) return;
    router.go(AppRoutes.home);
    await c.setReducedMotion(true);
    await _measure('home_reduced_motion');
    print('V2_PROFILE_DONE restore lib/main.dart for normal gameplay');
  }

  @override
  void dispose() {
    _measuring = false;
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.removeTimingsCallback(_timings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      HomeView(progress: c, loadArt: () => _pack);
}
