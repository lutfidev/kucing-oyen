import 'package:flutter/material.dart';

import '../../theme/ko_ui.dart';
import 'ui_button.dart';

/// Header and confirmation stay visible; only the body scrolls.
Future<T?> showUiSheet<T>(
  BuildContext context, {
  required String title,
  required String closeLabel,
  required Widget body,
  required Widget footer,
}) {
  final trigger = FocusManager.instance.primaryFocus;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: KoUi.paper,
    barrierColor: KoUi.scrim,
    barrierLabel: closeLabel,
    requestFocus: true,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(duration: KoUi.tabTime),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(KoUi.sheetRadius),
      ),
      side: BorderSide(color: KoUi.ink, width: KoUi.outline),
    ),
    builder: (context) => UiSheet(
      title: title,
      closeLabel: closeLabel,
      body: body,
      footer: footer,
    ),
  ).whenComplete(() {
    if (trigger?.context != null) trigger!.requestFocus();
  });
}

class UiSheet extends StatefulWidget {
  const UiSheet({
    super.key,
    required this.title,
    required this.closeLabel,
    required this.body,
    required this.footer,
  });
  final String title, closeLabel;
  final Widget body, footer;
  @override
  State<UiSheet> createState() => _UiSheetState();
}

class _UiSheetState extends State<UiSheet> {
  final titleFocus = FocusNode();
  @override
  void dispose() {
    titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            (MediaQuery.sizeOf(context).height -
                MediaQuery.paddingOf(context).vertical) *
            .9,
      ),
      child: Padding(
        padding: const EdgeInsets.all(KoUi.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Focus(
                    focusNode: titleFocus,
                    autofocus: true,
                    child: Semantics(
                      header: true,
                      namesRoute: true,
                      child: Text(widget.title, style: KoUi.title),
                    ),
                  ),
                ),
                const SizedBox(width: KoUi.s8),
                UiButton(
                  label: widget.closeLabel,
                  kind: UiButtonKind.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: KoUi.s12),
            Flexible(child: SingleChildScrollView(child: widget.body)),
            const SizedBox(height: KoUi.s16),
            widget.footer,
          ],
        ),
      ),
    ),
  );
}
