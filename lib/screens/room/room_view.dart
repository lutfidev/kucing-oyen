import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../app/game_audio.dart';
import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/needs.dart';
import '../../game/model/room_life.dart';
import '../../game/model/sounds.dart';
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

/// Oyen di kamar baru (hanya mangkuk): di tengah lantai seperti desain
/// (`Kamar.dc.html` keadaan `baru`, kiri 128 atas 470), jauh dari gelembung
/// ajakan di kiri bawah.
final starterOyenSpot = Spot(0.47, 0.71);

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
  const RoomView({
    super.key,
    required this.progress,
    this.random,
    this.life = true,
  });

  final ProgressController progress;

  /// Pengacak posisi kucing dan rutinitasnya; null = acak sungguhan.
  final Random? random;

  /// Kamar hidup (desain 21c): kucing berkedip, berjalan ke barang, dan
  /// memakainya; barang bergerak. False = kamar diam (test layar lain).
  final bool life;

  @override
  State<RoomView> createState() => _RoomViewState();
}

/// Rentang tempat kucing di lantai kamar desain, untuk kecepatan jalan.
final _designFloor = RoomGeometry(const Size(designRoomWidth, designRoomHeight))
    .rangeOf(RoomZone.floor, const Size.square(kittyRoomSize));

/// Selang penyegaran bar kebutuhan, gelembung hadiah, dan label mangkuk.
const roomRefreshInterval = Duration(seconds: 30);

class _RoomViewState extends State<RoomView>
    with SingleTickerProviderStateMixin {
  late final Random _random = widget.random ?? Random();
  late final List<Spot> _slots = shuffledKittySlots(_random);
  late final RoomLife _life = RoomLife(
    random: _random,
    spanX: _designFloor.width,
    spanY: _designFloor.height,
  );

  /// Jam kamar: memajukan rutinitas dan waktu animasi. Hanya jalan kalau
  /// kamar hidup dan gerak tidak dikurangi; `TickerMode` mematikannya saat
  /// layar lain menutupi kamar.
  late final Ticker _ticker = createTicker(_tick);
  Duration _lastTick = Duration.zero;
  double _time = 0;
  Timer? _refresh;

  /// Gerak dikurangi (`disableAnimations`): semua loop berhenti.
  bool _still = false;

  /// Animasi kucing dan barang sedang jalan.
  bool get _animating => widget.life && !_still;

  ProgressController get _progress => widget.progress;

  /// Geometri kamar terakhir (untuk seretan dan letak reaksi).
  RoomGeometry? _geo;

  /// Rute tiap kucing ke tiap barang (lompatan ke barang dinding).
  Map<(RoomItemId, KittyId), ItemPath> _paths = const {};

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

  /// Kamar baru: belum punya barang selain mangkuk.
  bool get _empty =>
      _progress.home.room.owned.every((id) => roomItemOf(id).builtIn);

  Spot _spotOf(KittyId kitty) =>
      _empty && kitty == KittyId.oyen ? starterOyenSpot : _slots[kitty.index];

  /// Tempat kucing sekarang: dari rutinitas kalau kamar hidup.
  Spot _catSpot(KittyId kitty) =>
      widget.life ? _life.of(kitty).spot : _spotOf(kitty);

  @override
  void initState() {
    super.initState();
    if (widget.life) {
      _syncKitties();
      _refresh = Timer.periodic(roomRefreshInterval, (_) => _refreshNeeds());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_animating && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!_animating && _ticker.isActive) {
      _ticker.stop();
    }
    if (widget.life && _still) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _eatWithoutWalking());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _refresh?.cancel();
    super.dispose();
  }

  void _sound(GameSound sound) => AudioScope.maybeRead(context)?.play(sound);

  void _tick(Duration elapsed) {
    // Bingkai yang tertunda lama (aplikasi dijeda) tidak melompatkan kucing.
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = elapsed;
    _time += dt;
    _life.paused = _selected != null || _decorating || _reaction != null;
    for (final event in _life.advance(dt)) {
      switch (event) {
        case ReachedBowl(:final kitty):
          _eatFromBowl(kitty);
        case UsedToy(:final kitty, :final item):
          _progress.play(kitty, item);
      }
    }
    setState(() {});
  }

  Future<void> _eatFromBowl(KittyId kitty) async {
    if (await _progress.eatFromBowl(kitty) && mounted) {
      _sound(GameSound.munch);
    }
  }

  /// Kurangi gerak: kucing tidak berjalan, jadi yang lapar langsung makan
  /// dari mangkuk (kebutuhan tetap berjalan).
  void _eatWithoutWalking() {
    if (!mounted || !_still) return;
    for (final kitty in _progress.home.kitties) {
      if (_progress.canEatFromBowl(kitty)) _eatFromBowl(kitty);
    }
  }

  void _refreshNeeds() {
    if (!mounted) return;
    setState(() {});
    _eatWithoutWalking();
  }

  /// Kucing yang dimiliki, kebutuhannya, dan tempat memakai tiap barang
  /// ke rutinitas.
  void _syncKitties([RoomGeometry? geo]) {
    final home = _progress.home;
    final placed = home.room.placed;
    _paths = geo == null || _decorating
        ? const {}
        : {
            for (final id in placed.keys)
              for (final kitty in home.kitties)
                (id, kitty): ?geo.pathTo(kitty, id, placed),
          };
    _life.sync(
      homes: {for (final kitty in home.kitties) kitty: _spotOf(kitty)},
      targets: {
        for (final id in placed.keys)
          id: {
            for (final kitty in home.kitties)
              if (_paths[(id, kitty)] case final path?)
                kitty: LifeRoute(path.stand, hops: path.hops),
          },
      },
      uses: {for (final id in placed.keys) id: roomItemOf(id).use},
      toys: {
        for (final id in placed.keys)
          if (roomItemOf(id).toy) id,
      },
      hungry: {
        for (final kitty in home.kitties)
          if (_progress.canEatFromBowl(kitty)) kitty,
      },
      sad: {
        for (final kitty in home.kitties)
          if (_progress.catNeeds(kitty).isSad) kitty,
      },
    );
  }

  void _select(KittyId kitty) {
    _sound(GameSound.meow);
    setState(() => _selected = kitty);
    _progress.seeKitty(kitty);
  }

  void _closeCard() => setState(() => _selected = null);

  void _react(KittyId kitty, RoomReaction reaction) {
    if (reaction.sound case final sound?) _sound(sound);
    if (widget.life) {
      _life.react(
        kitty,
        reaction.pose,
        ReactionOverlay.duration.inMilliseconds / 1000,
      );
    }
    setState(() => _reaction = (reaction, kitty, ++_reactions));
  }

  void _reactionDone() {
    final kitty = _reaction?.$2;
    if (widget.life && kitty != null) _life.rest(kitty);
    setState(() => _reaction = null);
  }

  /// Ambil hadiah koin kucing yang dirawat (gelembung).
  Future<void> _claim(KittyId kitty) async {
    final l = context.l10n;
    if (!await _progress.claimKittyReward(kitty) || !mounted) return;
    _react(
      kitty,
      RoomReaction(
        text: l.reactionCoins(kittyRewardCoins),
        hearts: false,
        sound: GameSound.reward,
      ),
    );
  }

  void _openShop([ShopTab tab = ShopTab.items]) =>
      context.go(AppRoutes.shop(tab: tab));

  void _startDecorating() => setState(() {
    _decorating = true;
    _selected = null;
    _reaction = null;
    _life.interrupt();
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
                anchor: geo.catBoxOf(kitty, _catSpot(kitty)),
                onDone: _reactionDone,
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
    if (widget.life) _syncKitties(geo);
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
      cats: {
        for (final kitty in home.kitties)
          if (!widget.life || _life.of(kitty).activity.onFloor)
            kitty: _catSpot(kitty),
      },
      geo: geo,
    );
    // Barang yang diangkat digambar paling depan.
    final ordered = [
      for (final sprite in sprites)
        if (sprite is! ItemSprite || sprite.id != dragging) sprite,
      for (final sprite in sprites)
        if (sprite is ItemSprite && sprite.id == dragging) sprite,
    ];
    final hopping = {
      for (final kitty in home.kitties) kitty: ?_hopBox(kitty, geo),
    };
    final catBoxes = {..._catBoxes(sprites, geo), ...hopping};
    final empty = _empty;
    final top = MediaQuery.paddingOf(context).top + space.s6;
    // Tag dan gelembung tidak naik ke bawah header dan tombol Hias, yang
    // digambar di atasnya dan menelan ketukan.
    final overlayTop =
        top + s.roomDecorateGap + s.roomDecorateButton + space.s8;
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
        // Kucing yang melompat ke atau dari barang dinding, paling depan.
        for (final MapEntry(key: kitty, value: box) in hopping.entries)
          Positioned.fromRect(
            key: ValueKey(kitty),
            rect: box,
            child: _kitty(kitty, box, facing: _hopFacing(kitty, geo)),
          ),
        if (!_decorating)
          for (final MapEntry(key: kitty, value: box) in catBoxes.entries)
            if (_progress.catNeeds(kitty) case final needs when needs.isSad)
              Positioned(
                left: box.left + box.width * 0.19,
                top: box.top - box.width * 0.19,
                child: SadMarkView(
                  hungry: needs.hunger <= sadThreshold,
                  size: RoomArt.sadMarkViewBox.width * geo.artScale,
                  time: _animating ? _time : null,
                ),
              )
            else if (home.isFresh(kitty))
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: tag di tengah kotak kucing (kiri − 26 untuk
                  // "Baru!" selebar ±52), atas − 14.
                  delegate: KeepInside(
                    Offset(box.center.dx, box.top - 14 * geo.artScale),
                    margin: space.s8,
                    top: overlayTop,
                    centered: true,
                  ),
                  child: const NewKittyTag(),
                ),
              )
            else if (widget.life && _progress.canClaimKittyReward(kitty))
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: gelembung di (163, 362) untuk Oyen 116 di
                  // (137, 430); dijepit supaya tidak keluar tepi kamar.
                  delegate: KeepInside(
                    Offset(
                      box.left + box.width * 26 / oyenRoomSize,
                      box.top - box.width * 68 / oyenRoomSize,
                    ),
                    margin: space.s8,
                    top: overlayTop,
                  ),
                  child: CoinBubbleView(
                    key: ValueKey('reward-${kitty.name}'),
                    coins: kittyRewardCoins,
                    label: context.l10n.kittyRewardLabel(
                      kittyRewardCoins,
                      kittyName(context.l10n, kitty),
                    ),
                    size: RoomArt.coinBubbleViewBox.width * geo.artScale,
                    time: _animating ? _time : null,
                    onTap: () => _claim(kitty),
                  ),
                ),
              ),
        if (!_decorating && widget.life)
          if ((_bowlRefill(now), home.room.placed[RoomItemId.mangkuk]) case (
            final left?,
            final spot?,
          ))
            if (geo.boxOf(roomItemOf(RoomItemId.mangkuk), spot) case final bowl)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  // Desain: label di (282, 566) untuk mangkuk di (298, 596),
                  // dijepit supaya tidak keluar tepi kamar.
                  delegate: KeepInside(
                    Offset(
                      bowl.left - 16 * geo.artScale,
                      bowl.top - 30 * geo.artScale,
                    ),
                    margin: context.koSpace.s8,
                  ),
                  child: BowlRefillLabel(left: left),
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

  /// Kotak tiap kucing di kamar: sprite-nya sendiri, atau kotak kucing di
  /// barang yang sedang dipakainya.
  Map<KittyId, Rect> _catBoxes(List<RoomSprite> sprites, RoomGeometry geo) {
    final boxes = <KittyId, Rect>{};
    for (final sprite in sprites) {
      switch (sprite) {
        case KittySprite(:final kitty):
          boxes[kitty] = sprite.box;
        case ItemSprite(:final id):
          final user = widget.life && !_decorating ? _life.userOf(id) : null;
          if (user == null) continue;
          boxes[user] = geo.userBoxOf(id, sprite.box);
      }
    }
    return boxes;
  }

  /// Rute lompatan kucing [kitty] yang sedang naik atau turun, urut dari
  /// tempatnya sekarang; null kalau tidak sedang melompat.
  List<Rect>? _hopBoxes(KittyId kitty) {
    if (!widget.life || _decorating) return null;
    final cat = _life.of(kitty);
    final item = cat.item;
    if (!cat.isHopping || item == null) return null;
    final boxes = _paths[(item, kitty)]?.boxes;
    if (boxes == null) return null;
    return cat.activity == CatActivity.descending
        ? boxes.reversed.toList()
        : boxes;
  }

  Rect? _hopBox(KittyId kitty, RoomGeometry geo) {
    final boxes = _hopBoxes(kitty);
    if (boxes == null) return null;
    return hopBox(
      boxes,
      _life.of(kitty).hopProgress,
      arc: catHopArc * geo.artScale,
    );
  }

  /// Arah hadap selama melompat: ke lompatan yang sedang dijalani.
  KittyFacing _hopFacing(KittyId kitty, RoomGeometry geo) {
    final boxes = _hopBoxes(kitty)!;
    final hops = boxes.length - 1;
    final i = min((_life.of(kitty).hopProgress * hops).floor(), hops - 1);
    final dx = boxes[i + 1].center.dx - boxes[i].center.dx;
    if (dx.abs() < geo.artScale) return KittyFacing.down;
    return dx < 0 ? KittyFacing.left : KittyFacing.right;
  }

  /// Sisa waktu sampai mangkuk terisi lagi, atau null kalau mangkuknya
  /// tidak kosong.
  Duration? _bowlRefill(DateTime now) {
    final bowl = _progress.needs.bowl;
    if (!bowl.isEmptyFor(_progress.home.kitties, now)) return null;
    return bowl.refillIn(now);
  }

  Widget _itemSprite(
    ItemSprite sprite,
    RoomGeometry geo,
    bool bowlFull, {
    bool lifted = false,
  }) {
    final s = context.koSize;
    final id = sprite.id;
    final user = widget.life && !_decorating ? _life.userOf(id) : null;
    final time = _animating ? _time : null;
    if (user != null) {
      final mirror = geo.mirrorsInUse(id, sprite.box);
      final box = RoomItemArt.inUseBox(id, sprite.box, mirror: mirror);
      return Positioned.fromRect(
        key: ValueKey(id),
        rect: box,
        child: _kittyButton(
          user,
          RoomItemView(
            id: id,
            box: box.size,
            full: id != RoomItemId.mangkuk || bowlFull,
            time: time,
            mirror: mirror,
            user: KittyLook(
              kitty: user,
              accessory: _progress.home.closet.wearingOf(user),
              time: time,
            ),
          ),
        ),
      );
    }
    Widget art = RoomItemView(
      id: id,
      box: sprite.box.size,
      full: id != RoomItemId.mangkuk || bowlFull,
      // Barang diam tidak digambar ulang tiap bingkai.
      time: RoomItemArt.isAnimated(id) ? time : null,
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
      if (lifted) {
        art = Transform.translate(
          offset: Offset(0, -s.roomLift * geo.artScale),
          child: Transform.scale(scale: s.roomLiftScale, child: art),
        );
      }
      // Gerakan tetap paling luar: kalau jenis widget di atasnya berganti
      // saat barang terangkat, pengenal seretnya ikut dibuang di tengah
      // seretan.
      art = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => _dragStart(id, sprite.box, d.globalPosition),
        onPanUpdate: (d) => _dragUpdate(id, d.globalPosition),
        onPanEnd: (_) => _dragEnd(id),
        onPanCancel: () => _dragEnd(id),
        child: art,
      );
    }
    return Positioned.fromRect(key: ValueKey(id), rect: sprite.box, child: art);
  }

  /// Kucing yang bisa diketuk untuk membuka kartunya.
  Widget _kittyButton(KittyId kitty, Widget child) {
    final l = context.l10n;
    final hungry = _progress.catNeeds(kitty).hunger <= sadThreshold;
    final fresh = _progress.home.isFresh(kitty);
    final name = kittyName(l, kitty);
    return Semantics(
      button: true,
      label: switch ((fresh, hungry)) {
        (true, true) => l.kittyTapHintNewHungry(name),
        (true, false) => l.kittyTapHintNew(name),
        (false, true) => l.kittyTapHintHungry(name),
        (false, false) => l.kittyTapHint(name),
      },
      excludeSemantics: true,
      onTap: () => _select(kitty),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(kitty),
        child: child,
      ),
    );
  }

  Widget _kitty(KittyId kitty, Rect box, {KittyFacing? facing}) {
    final needs = _progress.catNeeds(kitty);
    var pose = needs.isSad ? KittyPose.lesu : KittyPose.idle;
    final hopFacing = facing;
    facing = KittyFacing.down;
    if (widget.life && !_decorating) {
      final cat = _life.of(kitty);
      pose = switch (cat.pose) {
        LifePose.idle => KittyPose.idle,
        LifePose.lick => KittyPose.lick,
        LifePose.walk => KittyLook.walkPose(cat.elapsed),
        LifePose.sad => KittyPose.lesu,
        LifePose.happy => KittyPose.happy,
        LifePose.petted => KittyPose.petted,
        LifePose.eat => KittyPose.eat,
      };
      facing = switch (cat.heading) {
        LifeHeading.down => KittyFacing.down,
        LifeHeading.left => KittyFacing.left,
        LifeHeading.right => KittyFacing.right,
      };
    }
    facing = hopFacing ?? facing;
    return _kittyButton(
      kitty,
      KittyView(
        look: KittyLook(
          kitty: kitty,
          pose: pose,
          facing: facing,
          accessory: _progress.home.closet.wearingOf(kitty),
          // Desain: kucing tidak dianimasikan selama mode hias.
          time: _animating && !_decorating ? _time : null,
        ),
        size: box.width,
      ),
    );
  }
}
