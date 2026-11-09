import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'progress_scope.dart';
import 'routes.dart';

/// A single clock for the whole house, including areas that are not painted.
/// Calendar/offline time never becomes animation time. Sheets keep it running.
class HouseholdDriver extends StatefulWidget {
  const HouseholdDriver({
    super.key,
    required this.progress,
    required this.router,
    required this.enabled,
    required this.child,
  });
  final ProgressController progress;
  final GoRouter router;
  final bool enabled;
  final Widget child;

  @override
  State<HouseholdDriver> createState() => _HouseholdDriverState();
}

class _HouseholdDriverState extends State<HouseholdDriver>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;
  double _pending = 0;
  ProgressController get c => widget.progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_route);
    c.addListener(_sync);
    c.householdPauseChanges.addListener(_sync);
    _route();
    didChangeAppLifecycleState(
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
    );
  }

  void _route() {
    final home =
        widget.router.routerDelegate.currentConfiguration.uri.path ==
        AppRoutes.home;
    if (home) {
      c.resumeHousehold(HouseholdPause.hidden);
    } else {
      c.pauseHousehold(HouseholdPause.hidden);
    }
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      c.resumeHousehold(HouseholdPause.background);
    } else {
      c.pauseHousehold(HouseholdPause.background);
    }
    _sync();
  }

  void _sync() {
    final run = widget.enabled && !c.householdPaused && !c.householdSaveFailed;
    if (run && !_ticker.isActive) {
      _last = null;
      _pending = 0;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _last = null;
      _pending = 0;
    }
  }

  void _tick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    // Even when an ad starts between frames, none of its time is accumulated.
    if (last == null ||
        c.householdPaused ||
        c.householdSaveFailed ||
        c.householdBusy) {
      _pending = 0;
      return;
    }
    _pending += ((elapsed - last).inMicroseconds / 1e6).clamp(0, .25);
    if (_pending < .25) return;
    final seconds = _pending;
    _pending = 0;
    unawaited(c.advanceHousehold(seconds));
  }

  @override
  void dispose() {
    c.removeListener(_sync);
    c.householdPauseChanges.removeListener(_sync);
    widget.router.routerDelegate.removeListener(_route);
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    c.pauseHousehold(HouseholdPause.hidden);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
