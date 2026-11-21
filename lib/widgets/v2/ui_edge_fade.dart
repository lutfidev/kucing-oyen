import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/ko_ui.dart';

/// Fades the edges of a scrollable child where more content is hidden, so a
/// clipped list reads as "scroll for more" instead of as cut-off content.
///
/// Paints a gradient toward [color] (the page background) over the edges
/// instead of masking the child, so animated content underneath needs no
/// offscreen layer.
class UiEdgeFade extends StatefulWidget {
  const UiEdgeFade({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.extent = KoUi.s24,
    this.color = KoUi.homeBackground,
  });
  final Widget child;
  final Axis axis;
  final double extent;
  final Color color;

  @override
  State<UiEdgeFade> createState() => _UiEdgeFadeState();
}

class _UiEdgeFadeState extends State<UiEdgeFade> {
  // Hidden content toward the top/left and toward the bottom/right.
  bool _start = false, _end = false;

  /// (faded top/left, faded bottom/right), for tests.
  @visibleForTesting
  (bool, bool) get debugEdges => (_start, _end);

  bool _update(ScrollMetrics m) {
    if (m.axis != widget.axis) return false;
    final before = m.extentBefore > 0.5;
    final after = m.extentAfter > 0.5;
    final reversed = axisDirectionIsReversed(m.axisDirection);
    final start = reversed ? after : before;
    final end = reversed ? before : after;
    if (start == _start && end == _end) return false;
    void apply() {
      if (!mounted) return;
      setState(() {
        _start = start;
        _end = end;
      });
    }

    // Notifications can arrive during layout; rebuild after the frame then.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
    return false;
  }

  Widget _edge({required bool start}) {
    final vertical = widget.axis == Axis.vertical;
    final clear = widget.color.withValues(alpha: 0);
    return Positioned(
      left: vertical || start ? 0 : null,
      right: vertical || !start ? 0 : null,
      top: !vertical || start ? 0 : null,
      bottom: !vertical || !start ? 0 : null,
      width: vertical ? null : widget.extent,
      height: vertical ? widget.extent : null,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: vertical
                  ? (start ? Alignment.topCenter : Alignment.bottomCenter)
                  : (start ? Alignment.centerLeft : Alignment.centerRight),
              end: vertical
                  ? (start ? Alignment.bottomCenter : Alignment.topCenter)
                  : (start ? Alignment.centerRight : Alignment.centerLeft),
              colors: [widget.color, clear],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    // The scrollable stays the first child, so it keeps its state.
    children: [
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (n) => n.depth == 0 && _update(n.metrics),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) => n.depth == 0 && _update(n.metrics),
          child: widget.child,
        ),
      ),
      if (_start) _edge(start: true),
      if (_end) _edge(start: false),
    ],
  );
}
