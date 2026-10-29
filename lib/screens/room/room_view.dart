import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/needs.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../coins/coin_sheet.dart';
import '../shop/shop_tab.dart';
import 'room_geometry.dart';
import 'kitty_card.dart';
import 'room_parts.dart';
import 'room_reaction.dart';

// Tempat kucing di lantai: 4 kolom × 3 baris, diacak tiap kamar dibuka.
const _slotColumns = [0.08, 0.36, 0.64, 0.92];
const _slotRows = [0.08, 0.5, 0.92];

/// Dua belas tempat kucing urut acak [random].
List<Spot> shuffledKittySlots(Random random) => [
  for (final y in _slotRows)
    for (final x in _slotColumns) Spot(x, y),
]..shuffle(random);

/// Tempat tiap kucing di [kitties]: kucing yang sama selalu memakai urutan
/// [KittyId]-nya, jadi kucing yang baru diadopsi tidak memindahkan yang
/// lain.
Map<KittyId, Spot> kittySpots(Iterable<KittyId> kitties, Random random) {
  final slots = shuffledKittySlots(random);
  return {for (final kitty in kitties) kitty: slots[kitty.index]};
}

/// Titik merah Toko: ada barang atau kucing yang belum dimiliki dan
/// terjangkau [coins]. Camilan tidak dihitung.
bool shopHasAffordable(Home home, int coins) =>
    shopItems.any((item) => home.room.canBuy(item.id, coins)) ||
    kitties.any((kitty) => home.canBuyKitty(kitty.id, coins));

/// Titik merah Aksesoris: ada aksesoris yang belum dimiliki dan terjangkau.
bool accessoriesHaveAffordable(Home home, int coins) =>
    accessories.any((a) => home.closet.canBuy(a.id, coins));

/// Kamar Oyen (desain 19): barang yang ditaruh, kucing yang tinggal di
/// kamar, header (koin, logo, bintang), dan panel bawah (Main, Toko,
/// Aksesoris, Pengaturan). Kamar digambar dari tepi atas layar sampai
/// panel bawah; header di bawah status bar.
class RoomView extends StatefulWidget {
  const RoomView({super.key, required this.progress, this.random});

  final ProgressController progress;

  /// Pengacak posisi kucing; null = acak sungguhan.
  final Random? random;

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  late final List<Spot> _slots = shuffledKittySlots(widget.random ?? Random());

  ProgressController get _progress => widget.progress;

  /// Geometri kamar terakhir (untuk letak reaksi di atas kucing).
  RoomGeometry? _geo;

  /// Kucing yang kartunya terbuka.
  KittyId? _selected;

  /// Reaksi yang sedang melayang, kucingnya, dan nomor urutnya (reaksi
  /// baru memulai ulang animasi).
  (RoomReaction, KittyId, int)? _reaction;
  int _reactions = 0;

  void _select(KittyId kitty) => setState(() => _selected = kitty);

  void _closeCard() => setState(() => _selected = null);

  void _react(KittyId kitty, RoomReaction reaction) =>
      setState(() => _reaction = (reaction, kitty, ++_reactions));

  void _openShop([ShopTab tab = ShopTab.items]) =>
      context.go(AppRoutes.shop(tab: tab));

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final compact = MediaQuery.sizeOf(context).height < s.roomCompactHeight;
    final home = _progress.home;
    final coins = _progress.coins;
    final selected = _selected;
    final reaction = _reaction;
    final geo = _geo;
    final padding = MediaQuery.paddingOf(context);
    final cardTop = padding.top + s.roomCardTop;
    final cardMax =
        MediaQuery.sizeOf(context).height -
        cardTop -
        padding.bottom -
        context.koSpace.s16;
    return PopScope(
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeCard();
      },
      child: Scaffold(
        backgroundColor: c.roomFloorBoards,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => _room(RoomGeometry(box.biggest)),
                  ),
                ),
                RoomMenu(
                  compact: compact,
                  shopDot: shopHasAffordable(home, coins),
                  accessoryDot: accessoriesHaveAffordable(home, coins),
                  onPlay: () => context.go(
                    AppRoutes.chapter(_progress.currentChapter.number),
                  ),
                  onShop: _openShop,
                  onAccessories: () => _openShop(ShopTab.accessories),
                  onSettings: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
            if (selected != null) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeCard,
                  child: ColoredBox(color: c.roomScrim),
                ),
              ),
              Positioned(
                left: context.koSpace.s16,
                right: context.koSpace.s16,
                top: cardTop,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: max(0, cardMax)),
                  child: KittyCard(
                    key: ValueKey(selected),
                    progress: _progress,
                    kitty: selected,
                    onReaction: (r) => _react(selected, r),
                    onClose: _closeCard,
                  ),
                ),
              ),
            ],
            if ((reaction, geo)
                case ((final r, final kitty, final n), final geo?)
                when _progress.home.ownsKitty(kitty))
              ReactionOverlay(
                key: ValueKey(n),
                reaction: r,
                anchor: geo.catBoxOf(kitty, _slots[kitty.index]),
                onDone: () => setState(() => _reaction = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _room(RoomGeometry geo) {
    _geo = geo;
    final c = context.koColors;
    final space = context.koSpace;
    final home = _progress.home;
    final now = _progress.clock();
    final bowlFull = !_progress.needs.bowl.isEmptyFor(home.kitties, now);
    final sprites = roomSprites(
      items: home.room.placed,
      cats: {for (final kitty in home.kitties) kitty: _slots[kitty.index]},
      geo: geo,
    );
    final empty = home.room.placed.keys.every((id) => roomItemOf(id).builtIn);
    final top = MediaQuery.paddingOf(context).top + space.s6;
    return Stack(
      key: const ValueKey('room-area'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: RoomBackground(geo: geo)),
        for (final sprite in sprites.whereType<KittySprite>())
          if (sprite.kitty == _selected)
            Positioned(
              left: sprite.box.left + sprite.box.width * 0.12,
              top: sprite.box.top + sprite.box.height * 0.84,
              width: sprite.box.width * 0.76,
              height: space.s16 + space.s4,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.roomSelectFill,
                  shape: OvalBorder(
                    side: BorderSide(
                      color: c.orange,
                      width: context.koSize.artBorder,
                    ),
                  ),
                ),
              ),
            ),
        for (final sprite in sprites)
          Positioned.fromRect(
            rect: sprite.box,
            child: switch (sprite) {
              ItemSprite(:final id) => RoomItemView(
                id: id,
                box: sprite.box.size,
                full: id != RoomItemId.mangkuk || bowlFull,
              ),
              KittySprite(:final kitty) => _kitty(kitty, sprite.box),
            },
          ),
        for (final sprite in sprites.whereType<KittySprite>())
          if (_progress.catNeeds(sprite.kitty) case final needs
              when needs.isSad)
            Positioned(
              left: sprite.box.left + sprite.box.width * 0.19,
              top: sprite.box.top - sprite.box.width * 0.19,
              child: SadMarkView(
                hungry: needs.hunger <= sadThreshold,
                size: RoomArt.sadMarkViewBox.width * geo.artScale,
              ),
            ),
        if (empty)
          Positioned.fill(
            child: EmptyRoomHints(geo: geo, onShop: _openShop),
          ),
        Positioned(
          left: space.s16,
          right: space.s16,
          top: top,
          child: RoomHeader(
            coins: _progress.coins,
            bonus: _progress.canClaimBonus,
            stars: _progress.progress.totalStars,
            maxStars: _progress.maxStars,
            onCoins: () => showCoinSheet(context, _progress),
          ),
        ),
      ],
    );
  }

  Widget _kitty(KittyId kitty, Rect box) {
    final l = context.l10n;
    final needs = _progress.catNeeds(kitty);
    final hungry = needs.hunger <= sadThreshold;
    final name = kittyName(l, kitty);
    return Semantics(
      button: true,
      label: hungry ? l.kittyTapHintHungry(name) : l.kittyTapHint(name),
      excludeSemantics: true,
      onTap: () => _select(kitty),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(kitty),
        child: KittyView(
          look: KittyLook(
            kitty: kitty,
            pose: needs.isSad ? KittyPose.lesu : KittyPose.idle,
            accessory: _progress.home.closet.wearingOf(kitty),
          ),
          size: box.width,
        ),
      ),
    );
  }
}
