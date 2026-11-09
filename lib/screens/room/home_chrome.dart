import 'package:flutter/material.dart';

import '../../theme/ko_ui.dart';
import '../../widgets/v2/ui_button.dart';
import '../../widgets/tap_sound.dart';

/// Four visible destinations at normal text size; enlarged text can scroll.
/// Counts stay in the label and full names remain available to screen readers.
class HomeAreaStrip extends StatefulWidget {
  const HomeAreaStrip({
    super.key,
    required this.labels,
    required this.semantics,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels, semantics;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  State<HomeAreaStrip> createState() => _HomeAreaStripState();
}

class _HomeAreaStripState extends State<HomeAreaStrip> {
  final _keys = List.generate(4, (_) => GlobalKey());
  final _scroll = ScrollController();
  List<String> get labels => widget.labels;
  List<String> get semantics => widget.semantics;
  int get selected => widget.selected;
  ValueChanged<int> get onChanged => widget.onChanged;

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reveal();
  }

  @override
  void didUpdateWidget(HomeAreaStrip old) {
    super.didUpdateWidget(old);
    if (old.selected != selected) _reveal();
  }

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || !_scroll.hasClients) return;
    final target = _keys[selected].currentContext;
    if (target == null) return;
    Scrollable.of(target, axis: Axis.horizontal).position.ensureVisible(
      target.findRenderObject()!,
      alignment: .5,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : KoUi.tabTime,
    );
  });
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static const icons = [
    Icons.weekend_outlined,
    Icons.restaurant_rounded,
    Icons.sports_esports_outlined,
    Icons.brush_outlined,
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(KoUi.s4),
    decoration: KoUi.homeCard(radius: KoUi.cardRadius),
    child: LayoutBuilder(
      builder: (context, box) {
        final large = MediaQuery.textScalerOf(context).scale(13) > 15;
        final width = large
            ? box.maxWidth.clamp(360, 440) / 3
            : box.maxWidth / 4;
        final tabs = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 4; i++)
              SizedBox(
                width: width,
                key: _keys[i],
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  label: semantics[i],
                  excludeSemantics: true,
                  onTap: tapSound(context, () => onChanged(i)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(KoUi.buttonRadius),
                      onTap: tapSound(context, () => onChanged(i)),
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : KoUi.tabTime,
                        constraints: const BoxConstraints(
                          minHeight: KoUi.target,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: KoUi.s4,
                          vertical: KoUi.s8,
                        ),
                        decoration: BoxDecoration(
                          gradient: i == selected
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [KoUi.homeGold, KoUi.orange],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(
                            KoUi.buttonRadius,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[i], size: 21, color: KoUi.ink),
                            const SizedBox(height: KoUi.s4),
                            Text(
                              labels[i],
                              textAlign: TextAlign.center,
                              style: KoUi.small.copyWith(
                                fontSize: 13,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        return large
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scroll,
                child: tabs,
              )
            : tabs;
      },
    ),
  );
}

class HomeNavigation extends StatelessWidget {
  const HomeNavigation({
    super.key,
    required this.puzzleLabel,
    required this.labels,
    required this.onPuzzle,
    required this.onChanged,
  });
  final String puzzleLabel;
  final List<String> labels;
  final VoidCallback onPuzzle;
  final ValueChanged<int> onChanged;
  static const icons = [
    Icons.storefront_outlined,
    Icons.pets_rounded,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [KoUi.cream, KoUi.peach],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(KoUi.s16, KoUi.s8, KoUi.s16, KoUi.s8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: UiButton(
            label: puzzleLabel,
            homeStyle: true,
            icon: Icons.play_arrow_rounded,
            onPressed: onPuzzle,
          ),
        ),
        const SizedBox(height: KoUi.s4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                flex: labels[i].runes.length > 10 ? 3 : 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(KoUi.buttonRadius),
                    onTap: tapSound(context, () => onChanged(i)),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: KoUi.s4),
                        child: Column(
                          children: [
                            Icon(icons[i], size: 22, color: KoUi.ink),
                            const SizedBox(height: KoUi.s4),
                            Text(
                              labels[i],
                              textAlign: TextAlign.center,
                              style: KoUi.small.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
