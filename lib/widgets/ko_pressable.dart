import 'package:flutter/widgets.dart';

import '../app/game_audio.dart';

/// Permukaan tombol dengan bayangan padat di bawahnya ("press" di lembar
/// token). Saat jari menempel, permukaan turun setinggi [depth] dan bayangan
/// padatnya hilang; saat dilepas, kembali. Ketukan berbunyi
/// "tap" lewat [tapSound].
///
/// Bayangan tidak memakan tempat di tata letak (sama seperti `box-shadow`
/// CSS), jadi ukuran widget = [width] × [height].
class KoPressable extends StatefulWidget {
  const KoPressable({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.color,
    required this.depth,
    required this.child,
    this.edgeColor,
    this.borderColor,
    this.borderWidth = 0,
    this.radius = 0,
    this.circle = false,
    this.glow = const [],
    this.width,
    this.height,
    this.padding,
    this.toggled,
  });

  /// Null = nonaktif: tidak bisa ditekan dan tidak turun.
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color color;

  /// Tinggi dan warna bayangan padat. Tanpa [edgeColor], tidak ada bayangan
  /// dan tombol tidak turun saat ditekan.
  final double depth;
  final Color? edgeColor;

  final Color? borderColor;
  final double borderWidth;
  final double radius;

  /// Bulat penuh (tombol petunjuk); [radius] diabaikan.
  final bool circle;

  /// Bayangan lembut tambahan di bawah bayangan padat.
  final List<BoxShadow> glow;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  /// Tombol nyala/mati untuk pembaca layar (mis. ×2); null = tombol biasa.
  final bool? toggled;

  @override
  State<KoPressable> createState() => _KoPressableState();
}

class _KoPressableState extends State<KoPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(KoPressable old) {
    super.didUpdateWidget(old);
    if (widget.onPressed == null) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final onTap = tapSound(context, widget.onPressed);
    final edge = widget.edgeColor;
    final depth = edge == null ? 0.0 : widget.depth;
    final shift = _pressed ? depth : 0.0;
    final border = widget.borderColor;

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      toggled: widget.toggled,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, shift),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color,
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.circle
                  ? null
                  : BorderRadius.circular(widget.radius),
              border: border == null
                  ? null
                  : Border.all(color: border, width: widget.borderWidth),
              boxShadow: [
                if (edge != null && depth > shift)
                  BoxShadow(color: edge, offset: Offset(0, depth - shift)),
                ...widget.glow,
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
