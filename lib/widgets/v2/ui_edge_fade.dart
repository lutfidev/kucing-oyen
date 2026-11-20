import 'package:flutter/material.dart';

import '../../theme/ko_ui.dart';

/// Fades the edges of a scrollable child where more content is hidden, so a
/// clipped list reads as "scroll for more" instead of as cut-off content.
class UiEdgeFade extends StatefulWidget {
  const UiEdgeFade({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.extent = KoUi.s24,
  });
  final Widget child;
  final Axis axis;
  final double extent;

  @override
  State<UiEdgeFade> createState() => _UiEdgeFadeState();
}

class _UiEdgeFadeState extends State<UiEdgeFade> {
  bool _before = false, _after = false;

  /// (faded before, faded after), for tests.
  @visibleForTesting
  (bool, bool) get debugEdges => (_before, _after);

  bool _update(ScrollMetrics m) {
    if (m.axis != widget.axis) return false;
    final before = m.extentBefore > 0.5;
    final after = m.extentAfter > 0.5;
    if (before != _before || after != _after) {
      setState(() {
        _before = before;
        _after = after;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final listened = NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => n.depth == 0 && _update(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => n.depth == 0 && _update(n.metrics),
        child: widget.child,
      ),
    );
    // Always wrapped, so toggling the fade keeps the scrollable's state.
    final vertical = widget.axis == Axis.vertical;
    return ShaderMask(
      key: const ValueKey('edge-fade'),
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final length = vertical ? bounds.height : bounds.width;
        final stop = length <= 0 ? 0.0 : (widget.extent / length).clamp(0, .5);
        return LinearGradient(
          begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
          end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [
            _before ? Colors.transparent : Colors.black,
            Colors.black,
            Colors.black,
            _after ? Colors.transparent : Colors.black,
          ],
          stops: [0, stop.toDouble(), 1 - stop.toDouble(), 1],
        ).createShader(bounds);
      },
      child: listened,
    );
  }
}
