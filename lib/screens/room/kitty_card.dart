import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/kitties.dart';
import '../../game/model/needs.dart';
import '../../game/model/snacks.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../shop/shop_tab.dart';
import 'room_reaction.dart';

enum _Panel { snacks, accessories }

/// Kartu kucing di kamar (`Kamar.dc.html`, keadaan `kartu`): nama,
/// keterangan Toko, bar Lapar dan Senang, lalu Camilan, Elus, dan
/// Aksesoris. Isinya bisa digulir di layar pendek.
class KittyCard extends StatefulWidget {
  const KittyCard({
    super.key,
    required this.progress,
    required this.kitty,
    required this.onReaction,
    required this.onClose,
  });

  final ProgressController progress;
  final KittyId kitty;
  final void Function(RoomReaction reaction) onReaction;
  final VoidCallback onClose;

  @override
  State<KittyCard> createState() => _KittyCardState();
}

class _KittyCardState extends State<KittyCard> {
  _Panel? _panel;

  /// Aksi yang sedang disimpan: ketukan lain diabaikan sampai selesai.
  bool _busy = false;

  /// Ketukan kedua dalam [kDoubleTapTimeout] diabaikan, supaya ketukan
  /// ganda tidak memberi dua camilan.
  Timer? _cooldown;

  @override
  void dispose() {
    _cooldown?.cancel();
    super.dispose();
  }

  ProgressController get _progress => widget.progress;
  KittyId get _kitty => widget.kitty;

  void _toggle(_Panel panel) =>
      setState(() => _panel = _panel == panel ? null : panel);

  Future<void> _run(
    Future<bool> Function() action,
    RoomReaction? Function(bool ok) reaction,
  ) async {
    if (_busy || (_cooldown?.isActive ?? false)) return;
    _cooldown = Timer(kDoubleTapTimeout, () {});
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (reaction(ok) case final r?) widget.onReaction(r);
  }

  void _pet() {
    final l = context.l10n;
    _run(
      () => _progress.pet(_kitty),
      (ok) => RoomReaction(text: ok ? l.reactionJoy(petJoy) : null),
    );
  }

  void _feed(SnackId id) {
    final l = context.l10n;
    final snack = snackOf(id);
    final hunger = snack.hunger;
    final joy = snack.joy;
    _run(
      () => _progress.feed(_kitty, id),
      (ok) => !ok
          ? null
          : RoomReaction(
              // Desain: Senang camilan baru disebut kalau ≥ 15.
              text: joy >= 15
                  ? l.reactionFedJoy(hunger, joy)
                  : l.reactionFed(hunger),
            ),
    );
  }

  void _wear(AccessoryId? id) {
    final l = context.l10n;
    _run(
      () => _progress.wearAccessory(_kitty, id),
      (ok) => !ok
          ? null
          : RoomReaction(
              text: id == null ? l.reactionRelieved : l.reactionNice,
            ),
    );
  }

  void _openShop() {
    widget.onClose();
    context.go(AppRoutes.shop(tab: ShopTab.accessories));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final l = context.l10n;
    final needs = _progress.catNeeds(_kitty);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l.kittyCardLabel(kittyName(l, _kitty)),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(context.koRadius.dialog),
            boxShadow: [
              ...KoShadow.solid(c.lineDeep, context.koShadow.pressSecondary),
              ...context.koShadow.dialog,
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              space.s16,
              space.s14,
              space.s16,
              space.s16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                SizedBox(height: space.s12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: space.s12,
                    vertical: space.s10,
                  ),
                  decoration: BoxDecoration(
                    color: c.cream,
                    borderRadius: BorderRadius.circular(
                      context.koRadius.control,
                    ),
                  ),
                  child: Column(
                    children: [
                      NeedBar(label: l.needHunger, value: needs.hunger),
                      SizedBox(height: space.s8),
                      NeedBar(label: l.needJoy, value: needs.joy, joy: true),
                    ],
                  ),
                ),
                SizedBox(height: space.s12),
                _buttons(),
                if (_panel == _Panel.snacks) ...[
                  SizedBox(height: space.s12),
                  _snacks(),
                ],
                if (_panel == _Panel.accessories) ...[
                  SizedBox(height: space.s12),
                  _accessories(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final avatar = MediaQuery.sizeOf(context).width >= s.roomCardAvatarMinWidth;
    return Row(
      children: [
        if (avatar) ...[
          Container(
            width: s.roomCardAvatar,
            height: s.roomCardAvatar,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: c.floor,
              borderRadius: BorderRadius.circular(context.koRadius.control),
            ),
            child: ExcludeSemantics(
              child: KittyView(
                look: KittyLook(
                  kitty: _kitty,
                  accessory: _progress.home.closet.wearingOf(_kitty),
                ),
                size: s.roomCardAvatarArt,
              ),
            ),
          ),
          SizedBox(width: space.s12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kittyName(l, _kitty),
                style: t.headingLarge.copyWith(color: c.ink),
              ),
              SizedBox(height: space.s2),
              Text(
                kittyDesc(l, _kitty),
                style: t.cardText.copyWith(color: c.inkSoft),
              ),
            ],
          ),
        ),
        SizedBox(width: space.s12),
        KoPressable(
          onPressed: widget.onClose,
          semanticLabel: l.kittyCardClose,
          color: c.cream,
          depth: 0,
          borderColor: c.line,
          borderWidth: s.border,
          radius: context.koRadius.icon,
          width: s.iconButton,
          height: s.iconButton,
          child: Center(
            child: KoIcon(KoIcons.close, size: s.iconCompact, color: c.ink),
          ),
        ),
      ],
    );
  }

  Widget _buttons() {
    final l = context.l10n;
    final space = context.koSpace;
    return Row(
      children: [
        Expanded(
          child: _CardButton(
            icon: KoIcons.snack,
            label: l.snackPanel,
            on: _panel == _Panel.snacks,
            onPressed: () => _toggle(_Panel.snacks),
          ),
        ),
        SizedBox(width: space.s8),
        Expanded(
          child: _CardButton(
            icon: KoIcons.heart,
            label: l.petAction,
            onPressed: _pet,
          ),
        ),
        SizedBox(width: space.s8),
        Expanded(
          child: _CardButton(
            icon: KoIcons.accessory,
            label: l.accessories,
            on: _panel == _Panel.accessories,
            onPressed: () => _toggle(_Panel.accessories),
          ),
        ),
      ],
    );
  }

  Widget _panelTitle(String text) => Text(
    text,
    style: context.koType.overline.copyWith(color: context.koColors.inkSoft),
  );

  Widget _snacks() {
    final s = context.koSize;
    final space = context.koSpace;
    final pantry = _progress.home.pantry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panelTitle(context.l10n.snackPick.toUpperCase()),
        SizedBox(height: space.s8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: space.s4),
          child: Row(
            children: [
              for (final (i, snack) in snacks.indexed) ...[
                if (i > 0) SizedBox(width: space.s8),
                SizedBox(
                  width: s.roomSnackCardWidth,
                  child: _SnackCard(
                    id: snack.id,
                    count: pantry.countOf(snack.id),
                    onPressed: () => _feed(snack.id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessories() {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final closet = _progress.home.closet;
    final wearing = closet.wearingOf(_kitty);
    final options = <AccessoryId?>[
      null,
      for (final a in accessories)
        if (closet.owns(a.id)) a.id,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _panelTitle(l.accessoryPanelTitle.toUpperCase())),
            SizedBox(width: space.s8),
            Semantics(
              link: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openShop,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: s.iconButton),
                  child: Center(
                    widthFactor: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.accessoryShopLink,
                          style: t.tag.copyWith(color: c.needHungerInk),
                        ),
                        SizedBox(width: space.s4),
                        KoIcon(
                          KoIcons.arrowRight,
                          size: s.iconTiny,
                          color: c.needHungerInk,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: space.s8),
        LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - space.s8 * 2) / 3;
            return Wrap(
              spacing: space.s8,
              runSpacing: space.s8,
              children: [
                for (final id in options)
                  SizedBox(
                    width: width,
                    child: _AccessoryOption(
                      id: id,
                      kitty: _kitty,
                      on: wearing == id,
                      onPressed: () => _wear(id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Bar Lapar atau Senang (`BarKebutuhan.dc.html`): ikon, label, bar, angka,
/// dan peringatan kalau ≤ [sadThreshold].
class NeedBar extends StatelessWidget {
  const NeedBar({
    super.key,
    required this.label,
    required this.value,
    this.joy = false,
  });

  final String label;
  final double value;
  final bool joy;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final n = value.round().clamp(0, maxNeed.round());
    final low = n <= sadThreshold;
    final (Color fill, Color tile, Color ink) = low
        ? (c.brick, c.needLowTile, c.brickDeep)
        : joy
        ? (c.success, c.needJoyTile, c.successDeep)
        : (c.orange, c.needHungerTile, c.needHungerInk);
    final gap = space.s10;
    return Semantics(
      label: low ? l.needValueLow(label, n) : l.needValueLabel(label, n),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.needTile,
                height: s.needTile,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tile,
                  borderRadius: BorderRadius.circular(context.koRadius.tag),
                ),
                child: KoIcon(
                  joy ? KoIcons.heart : KoIcons.snack,
                  size: s.iconCompact,
                  color: ink,
                ),
              ),
              SizedBox(width: gap),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: s.needLabel),
                child: Text(
                  label,
                  maxLines: 1,
                  style: t.chipLabel.copyWith(color: c.ink),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Container(
                  height: s.needBar,
                  clipBehavior: Clip.antiAlias,
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: c.floorAlt,
                    borderRadius: BorderRadius.circular(context.koRadius.pill),
                  ),
                  child: FractionallySizedBox(
                    // Desain: paling sedikit 3% supaya bar kosong tetap
                    // kelihatan.
                    widthFactor: n.clamp(3, 100) / 100,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(
                          context.koRadius.pill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: gap),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: s.needValue),
                child: Text(
                  '$n',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: t.numberCoin.copyWith(
                    color: low ? c.brickDeep : c.ink,
                  ),
                ),
              ),
            ],
          ),
          if (low)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: s.needTile + gap + s.needLabel + gap,
                top: space.s2,
              ),
              child: Text(
                joy ? l.needLowJoy : l.needLowHunger,
                style: t.tagSmall.copyWith(color: c.brickDeep),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tombol Camilan, Elus, atau Aksesoris; [on] = panelnya terbuka.
class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.on,
  });

  final KoIconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Null untuk tombol tanpa panel (Elus).
  final bool? on;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final active = on ?? false;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      toggled: on,
      color: active ? c.orange : c.surface,
      edgeColor: active ? c.orangeDeep : c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: active ? null : c.line,
      borderWidth: active ? 0 : s.border,
      radius: context.koRadius.control,
      height: s.roomCardButton,
      padding: EdgeInsets.symmetric(horizontal: space.s4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KoIcon(icon, size: s.iconSmall, color: c.ink),
              SizedBox(height: space.s2),
              Text(
                label,
                maxLines: 1,
                style: context.koType.buttonCard.copyWith(color: c.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu camilan di panel Camilan: gambar, nama, dan stok "×N".
class _SnackCard extends StatelessWidget {
  const _SnackCard({
    required this.id,
    required this.count,
    required this.onPressed,
  });

  final SnackId id;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final empty = count <= 0;
    final name = snackName(l, id);
    final card = KoPressable(
      onPressed: empty ? null : onPressed,
      semanticLabel: empty
          ? l.snackGiveEmpty(name, count)
          : l.snackGive(name, count),
      color: c.cream,
      edgeColor: c.lineDeep,
      depth: empty ? 0 : context.koShadow.pressIcon,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.slot,
      height: s.roomSnackCardHeight,
      padding: EdgeInsets.all(space.s4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: s.roomSnackArtBox,
                child: Center(
                  child: ExcludeSemantics(
                    child: SnackView(
                      id: id,
                      box: Size(s.roomSnackArtWidth, s.roomSnackArtHeight),
                    ),
                  ),
                ),
              ),
              SizedBox(height: space.s2),
              Text(name, maxLines: 1, style: t.tag.copyWith(color: c.ink)),
              SizedBox(height: space.s2),
              Container(
                height: s.roomStockBadge,
                padding: EdgeInsets.symmetric(horizontal: space.s8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: empty ? c.shortFill : c.ink,
                  borderRadius: BorderRadius.circular(context.koRadius.pill),
                ),
                child: Text(
                  '×$count',
                  style: t.numberTick.copyWith(
                    color: empty ? c.inkSoft : c.cream,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return empty ? Opacity(opacity: s.roomEmptyOpacity, child: card) : card;
  }
}

/// Satu pilihan di panel Aksesoris: "Lepas" ([id] null) atau aksesoris
/// yang dimiliki; [on] = sedang dipakai [kitty].
class _AccessoryOption extends StatelessWidget {
  const _AccessoryOption({
    required this.id,
    required this.kitty,
    required this.on,
    required this.onPressed,
  });

  final AccessoryId? id;
  final KittyId kitty;
  final bool on;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final s = context.koSize;
    final space = context.koSpace;
    final l = context.l10n;
    final id = this.id;
    final who = kittyName(l, kitty);
    final name = id == null ? l.accessoryRemove : accessoryName(l, id);
    final label = id == null
        ? l.accessoryRemoveLabel(who)
        : on
        ? l.accessoryWornLabel(name, who)
        : l.accessoryWearLabel(name, who);
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      toggled: on,
      color: on ? c.successSoft : c.cream,
      depth: 0,
      borderColor: on ? c.success : c.line,
      borderWidth: on ? s.artBorder : s.border,
      radius: context.koRadius.slot,
      padding: EdgeInsets.symmetric(horizontal: space.s4, vertical: space.s6),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: s.roomAccessoryCard - space.s6 * 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccessoryIconView(id: id, size: s.roomAccessoryArt),
            SizedBox(height: space.s2),
            Text(
              name,
              textAlign: TextAlign.center,
              style: t.tag.copyWith(color: c.ink),
            ),
            if (on && id != null) ...[
              SizedBox(height: space.s2),
              Container(
                height: s.roomWornTag,
                padding: EdgeInsets.symmetric(horizontal: space.s6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.success,
                  borderRadius: BorderRadius.circular(context.koRadius.pill),
                ),
                child: Text(
                  l.accessoryWornTag,
                  style: t.tagTiny.copyWith(color: c.onSuccess),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
