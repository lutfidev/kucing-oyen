import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ko_ui.dart';
import '../tap_sound.dart';

enum UiButtonKind { primary, secondary, danger }

/// Wraps long labels, grows with text scaling and supports keyboard activation.
class UiButton extends StatefulWidget {
  const UiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.icon,
    this.leading,
    this.silent = false,
    this.kind = UiButtonKind.primary,
    this.loading = false,
    this.selected,
    this.autofocus = false,
    this.compact = false,
    this.homeStyle = false,
  });
  final String label;
  final String? semanticLabel;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool silent;
  final UiButtonKind kind;
  final bool loading, autofocus, compact;
  final bool homeStyle;
  final bool? selected;
  @override
  State<UiButton> createState() => _UiButtonState();
}

class _UiButtonState extends State<UiButton> {
  bool pressed = false, focused = false;
  @override
  void didUpdateWidget(UiButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading || widget.onPressed == null) pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final fill = !enabled
        ? KoUi.cream
        : switch (widget.kind) {
            UiButtonKind.primary => KoUi.orange,
            UiButtonKind.secondary =>
              widget.selected == true ? KoUi.peach : KoUi.paper,
            UiButtonKind.danger => KoUi.danger,
          };
    final foreground = enabled && widget.kind == UiButtonKind.danger
        ? KoUi.paper
        : KoUi.ink;
    final action = enabled
        ? (widget.silent
              ? widget.onPressed
              : tapSound(context, widget.onPressed))
        : null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel ?? widget.label,
      liveRegion: widget.loading,
      onTap: action,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (v) => setState(() => focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              action?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action,
          onTapDown: enabled ? (_) => setState(() => pressed = true) : null,
          onTapUp: (_) => setState(() => pressed = false),
          onTapCancel: () => setState(() => pressed = false),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : KoUi.pressTime,
            transform: Matrix4.translationValues(
              0,
              pressed && enabled ? KoUi.depth : 0,
              0,
            ),
            constraints: const BoxConstraints(
              minHeight: KoUi.target,
              minWidth: KoUi.target,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 0 : KoUi.s16,
              vertical: KoUi.s12,
            ),
            decoration:
                (widget.homeStyle
                        ? KoUi.homeCard(radius: KoUi.buttonRadius)
                        : KoUi.card(radius: KoUi.buttonRadius, color: fill))
                    .copyWith(
                      color: fill,
                      gradient: widget.homeStyle
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors:
                                  widget.kind == UiButtonKind.primary && enabled
                                  ? [KoUi.homeGold, KoUi.orange]
                                  : [KoUi.homePaper, KoUi.homeCream],
                            )
                          : null,
                      border: Border.all(
                        color: widget.homeStyle && !focused
                            ? KoUi.homeLine
                            : KoUi.ink,
                        width: focused ? 3 : KoUi.outline,
                      ),
                      boxShadow: pressed || !enabled
                          ? []
                          : widget.homeStyle
                          ? [
                              const BoxShadow(
                                color: KoUi.homeShade,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: widget.kind == UiButtonKind.primary
                                    ? KoUi.orangePressed
                                    : KoUi.shadow,
                                offset: Offset(0, KoUi.depth),
                              ),
                            ],
                    ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading) ...[
                  SizedBox(
                    width: KoUi.s16,
                    height: KoUi.s16,
                    child: MediaQuery.disableAnimationsOf(context)
                        ? Icon(
                            Icons.hourglass_top,
                            size: KoUi.s16,
                            color: foreground,
                          )
                        : CircularProgressIndicator(
                            strokeWidth: 2,
                            color: foreground,
                          ),
                  ),
                  const SizedBox(width: KoUi.s8),
                ] else if (widget.leading != null) ...[
                  ExcludeSemantics(child: widget.leading!),
                  const SizedBox(width: KoUi.s8),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, color: foreground),
                  const SizedBox(width: KoUi.s8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style:
                        (widget.compact
                                ? KoUi.small.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )
                                : KoUi.label)
                            .copyWith(color: foreground),
                  ),
                ),
                if (!enabled && !widget.loading) ...[
                  const SizedBox(width: KoUi.s8),
                  Icon(Icons.block, size: KoUi.s16, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
