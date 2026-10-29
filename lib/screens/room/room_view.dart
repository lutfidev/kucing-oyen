import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'decorate.dart';
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

  /// Geometri kamar terakhir (untuk seretan dan letak reaksi).
  RoomGeometry? _geo;

  /// Kucing yang kartunya terbuka.
  KittyId? _selected;

  /// Reaksi yang sedang melayang, kucingnya, dan nomor urutnya (reaksi
  /// baru memulai ulang animasi).
  (RoomReaction, KittyId, int)? _reaction;
  int _reactions = 0;

  bool _decorating = false;
  bool _finishing = false;

  /// Pujian sesudah menghias: dapat bonus Senang atau tidak, dan nomor
  /// urutnya.
  (bool, int)? _praise;
  int _praises = 0;

  /// Barang yang sedang diseret, letaknya sekarang, pojok kiri-atasnya
  /// saat mulai diseret, dan titik jari (layar) saat mulai dan sekarang.
  RoomItemId? _dragging;
  Spot? _dragSpot;
  Offset _dragOrigin = Offset.zero;
  Offset _dragDown = Offset.zero;
  Offset _dragPointer = Offset.zero;

  final _trayKey = GlobalKey();

  void _select(KittyId kitty) => setState(() => _selected = kitty);

  void _closeCard() => setState(() => _selected = null);

  void _react(KittyId kitty, RoomReaction reaction) =>
      setState(() => _reaction = (reaction, kitty, ++_reactions));

  void _openShop([ShopTab tab = ShopTab.items]) =>
      context.go(AppRoutes.shop(tab: tab));

  void _startDecorating() => setState(() {
    _decorating = true;
    _selected = null;
    _reaction = null;
  });

  /// Selesai menghias (juga tombol kembali sistem): kembali ke mode normal,
  /// lalu pujian, dengan bonus Senang kalau belum diberikan sejam ini.
  Future<void> _finish() async {
    if (_finishing || !_decorating) return;
    _finishing = true;
    setState(() {
      _decorating = false;
      _dragging = null;
      _dragSpot = null;
    });
    final bonus = await _progress.finishDecorating();
    if (!mounted) return;
    setState(() {
      _finishing = false;
      _praise = (bonus, ++_praises);
    });
  }

  void _dragStart(RoomItemId id, Rect box, Offset pointer) {
    _dragOrigin = box.topLeft;
    _dragDown = pointer;
    _dragPointer = pointer;
  }

  void _dragUpdate(RoomItemId id, Offset pointer) {
    final geo = _geo;
    if (geo == null) return;
    _dragPointer = pointer;
    setState(() {
      _dragging = id;
      _dragSpot = geo.spotFor(
        roomItemOf(id),
        _dragOrigin + (pointer - _dragDown),
      );
    });
  }

  /// Lepas di atas baki = masuk Gudang (kecuali mangkuk), selain itu
  /// ditaruh. Keduanya langsung disimpan.
  void _dragEnd(RoomItemId id) {
    final spot = _dragSpot;
    if (_dragging == id) {
      if (_overTray(_dragPointer) && !roomItemOf(id).builtIn) {
        _progress.storeItem(id);
      } else if (spot != null) {
        _progress.placeItem(id, spot);
      }
    }
    setState(() {
      _dragging = null;
      _dragSpot = null;
    });
  }

  bool _overTray(Offset pointer) {
    final box = _trayKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    return (box.localToGlobal(Offset.zero) & box.size).contains(pointer);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final compact = MediaQuery.sizeOf(context).height < s.roomCompactHeight;
    final home = _progress.home;
    final coins = _progress.coins;
    final selected = _selected;
    final reaction = _reaction;
    final praise = _praise;
    final geo = _geo;
    final padding = MediaQuery.paddingOf(context);
    final cardTop = padding.top + s.roomCardTop;
    final cardMax =
        MediaQuery.sizeOf(context).height -
        cardTop -
        padding.bottom -
        space.s16;
    // Panel bawah setinggi sama saat menghias, supaya kamar tidak berubah
    // ukuran.
    final panel = compact
        ? s.roomPlayCompact + space.s12 + s.roomMenuButtonCompact
        : s.roomPlay + space.s16 + s.roomMenuButton;
    return PopScope(
      canPop: selected == null && !_decorating,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_decorating) {
          _finish();
        } else {
          _closeCard();
        }
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
                RoomPanel(
                  compact: compact,
                  child: SizedBox(
                    height: panel,
                    child: _decorating
                        ? StorageTray(
                            key: _trayKey,
                            items: home.room.stored,
                            compact: compact,
                            onPlace: (id) => _progress.placeItem(
                              id,
                              roomItemOf(id).defaultSpot,
                            ),
                          )
                        : RoomMenu(
                            compact: compact,
                            shopDot: shopHasAffordable(home, coins),
                            accessoryDot: accessoriesHaveAffordable(
                              home,
                              coins,
                            ),
                            onPlay: () => context.go(
                              AppRoutes.chapter(
                                _progress.currentChapter.number,
                              ),
                            ),
                            onShop: _openShop,
                            onAccessories: () => _openShop(ShopTab.accessories),
                            onSettings: () => context.go(AppRoutes.settings),
                          ),
                  ),
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
                left: space.s16,
                right: space.s16,
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
            if (praise case (final bonus, final n))
              Positioned(
                left: s.roomPraiseInset,
                right: s.roomPraiseInset,
                top: padding.top + s.roomPraiseTop,
                child: PraiseToast(
                  key: ValueKey(n),
                  title: context.l10n.decoratePraise,
                  subtitle: bonus
                      ? context.l10n.decoratePraiseJoy(decorateJoy)
                      : null,
                  onDone: () => setState(() => _praise = null),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _room(RoomGeometry geo) {
    _geo = geo;
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final home = _progress.home;
    final now = _progress.clock();
    final bowlFull = !_progress.needs.bowl.isEmptyFor(home.kitties, now);
    final dragging = _dragging;
    final dragSpot = _dragSpot;
    final sprites = roomSprites(
      items: {
        ...home.room.placed,
        if (dragging != null && dragSpot != null) dragging: dragSpot,
      },
      cats: {for (final kitty in home.kitties) kitty: _slots[kitty.index]},
      geo: geo,
    );
    // Barang yang diangkat digambar paling depan.
    final ordered = [
      for (final sprite in sprites)
        if (sprite is! ItemSprite || sprite.id != dragging) sprite,
      for (final sprite in sprites)
        if (sprite is ItemSprite && sprite.id == dragging) sprite,
    ];
    final owned = home.room.owned;
    final empty = owned.every((id) => roomItemOf(id).builtIn);
    final top = MediaQuery.paddingOf(context).top + space.s6;
    return Stack(
      key: const ValueKey('room-area'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: RoomBackground(geo: geo)),
        if (_decorating) Positioned.fill(child: ZoneGuides(geo: geo)),
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
                    side: BorderSide(color: c.orange, width: s.artBorder),
                  ),
                ),
              ),
            ),
        for (final sprite in ordered)
          if (sprite case ItemSprite(:final id) when id == dragging) ...[
            Positioned(
              left: sprite.box.left + sprite.box.width * 0.1,
              top: sprite.box.bottom - s.roomLiftShadow * geo.artScale / 2,
              width: sprite.box.width * 0.8,
              height: s.roomLiftShadow * geo.artScale,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.roomDragShadow,
                  shape: const OvalBorder(),
                ),
              ),
            ),
            _itemSprite(sprite, geo, bowlFull, lifted: true),
          ] else
            switch (sprite) {
              ItemSprite() => _itemSprite(sprite, geo, bowlFull),
              KittySprite(:final kitty) => Positioned.fromRect(
                key: ValueKey(kitty),
                rect: sprite.box,
                child: IgnorePointer(
                  ignoring: _decorating,
                  child: _kitty(kitty, sprite.box),
                ),
              ),
            },
        if (!_decorating)
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
        if (empty && !_decorating)
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
        if (!empty || _decorating)
          Positioned(
            left: space.s16,
            right: space.s16,
            top: top + s.roomDecorateGap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_decorating)
                  const Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DecorateHint(),
                    ),
                  )
                else
                  const Spacer(),
                SizedBox(width: space.s8),
                DecorateButton(
                  done: _decorating,
                  onPressed: _decorating ? _finish : _startDecorating,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _itemSprite(
    ItemSprite sprite,
    RoomGeometry geo,
    bool bowlFull, {
    bool lifted = false,
  }) {
    final s = context.koSize;
    final id = sprite.id;
    Widget art = RoomItemView(
      id: id,
      box: sprite.box.size,
      full: id != RoomItemId.mangkuk || bowlFull,
    );
    if (_decorating) {
      final l = context.l10n;
      art = DecorOutline(
        child: Semantics(
          label: roomItemName(l, id),
          excludeSemantics: true,
          customSemanticsActions: roomItemOf(id).builtIn
              ? null
              : {
                  CustomSemanticsAction(label: l.storeItemAction): () =>
                      _progress.storeItem(id),
                },
          child: art,
        ),
      );
      art = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => _dragStart(id, sprite.box, d.globalPosition),
        onPanUpdate: (d) => _dragUpdate(id, d.globalPosition),
        onPanEnd: (_) => _dragEnd(id),
        onPanCancel: () => _dragEnd(id),
        child: art,
      );
    }
    if (lifted) {
      art = Transform.translate(
        offset: Offset(0, -s.roomLift * geo.artScale),
        child: Transform.scale(scale: s.roomLiftScale, child: art),
      );
    }
    return Positioned.fromRect(key: ValueKey(id), rect: sprite.box, child: art);
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
