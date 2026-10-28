import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/accessories.dart';
import '../../game/model/home_items.dart';
import '../../game/model/kitties.dart';
import '../../game/model/snacks.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../coins/coin_sheet.dart';
import 'buy_sheet.dart';
import 'shop_parts.dart';
import 'shop_tab.dart';

export 'shop_tab.dart';

/// Toko (desain 20, rute `/toko`): empat tab untuk membeli barang, kucing,
/// aksesoris, dan camilan dengan koin. Barang, kucing, dan aksesoris lewat
/// sheet konfirmasi; camilan langsung dari kartunya.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.initialTab = ShopTab.items});

  /// Tab yang terbuka pertama (`/toko?tab=aksesoris`).
  final ShopTab initialTab;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late ShopTab _tab = widget.initialTab;

  /// Pesan mengapung terakhir ("-15 koin", "Cakep!"), null = tidak ada.
  String? _flash;
  Timer? _flashTimer;

  /// Kucing dan aksesoris yang sedang dipratinjau di tab Aksesoris.
  KittyId _preview = KittyId.oyen;
  AccessoryId _selected = accessories.first.id;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  /// Menampilkan [text] sebentar di bawah bar atas.
  void _showFlash(String text) {
    _flashTimer?.cancel();
    setState(() => _flash = text);
    _flashTimer = Timer(ShopFlash.duration, () {
      if (mounted) setState(() => _flash = null);
    });
  }

  /// Memasang aksesoris terpilih di kucing pratinjau, atau melepasnya.
  Future<void> _wear(ProgressController progress, {required bool on}) async {
    final ok = await progress.wearAccessory(_preview, on ? _selected : null);
    if (ok && mounted) {
      _showFlash(
        on ? context.l10n.shopFlashNice : context.l10n.shopFlashRemoved,
      );
    }
  }

  Future<void> _buySnack(ProgressController progress, SnackId id) async {
    final price = snackOf(id).price;
    if (await progress.buySnack(id) && mounted) {
      _showFlash(context.l10n.shopFlashSpent(price));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final c = context.koColors;
    final space = context.koSpace;

    return Scaffold(
      backgroundColor: c.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: space.s8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: space.gutter),
              child: ShopBar(
                coins: progress.coins,
                bonus: progress.canClaimBonus,
                onBack: () => context.go(AppRoutes.home),
                onCoins: () => showCoinSheet(context, progress),
              ),
            ),
            SizedBox(height: space.s12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: space.gutter),
              child: ShopTabs(
                active: _tab,
                onPick: (tab) => setState(() => _tab = tab),
              ),
            ),
            SizedBox(height: space.s8),
            SizedBox(
              height: context.koSize.chipSmall,
              child: Center(
                child: _flash == null
                    ? const SizedBox.shrink()
                    : ShopFlash(_flash!),
              ),
            ),
            SizedBox(height: space.s4),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  space.gutter,
                  0,
                  space.gutter,
                  space.s32,
                ),
                child: switch (_tab) {
                  ShopTab.items => _Items(progress: progress),
                  ShopTab.kitties => _Kitties(progress: progress),
                  ShopTab.snacks => _Snacks(
                    progress: progress,
                    onBuy: (id) => _buySnack(progress, id),
                  ),
                  ShopTab.accessories => _Accessories(
                    progress: progress,
                    preview: progress.home.ownsKitty(_preview)
                        ? _preview
                        : KittyId.oyen,
                    selected: _selected,
                    onPreview: (kitty) => setState(() => _preview = kitty),
                    onSelect: (id) => setState(() => _selected = id),
                    onBuy: () => showBuySheet(
                      context,
                      target: BuyAccessory(_selected),
                      progress: progress,
                      previewKitty: _preview,
                      onWear: (id) {
                        setState(() => _selected = id);
                        _wear(progress, on: true);
                      },
                    ),
                    onWear: () => _wear(progress, on: true),
                    onRemove: () => _wear(progress, on: false),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab Barang: kisi dua kolom berisi 20 barang yang dijual.
class _Items extends StatelessWidget {
  const _Items({required this.progress});

  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final room = progress.home.room;
    final coins = progress.coins;
    return ShopGrid(
      children: [
        for (final item in shopItems)
          ItemCard(
            id: item.id,
            state: room.owns(item.id)
                ? ShopCardState.owned
                : coins >= item.price
                ? ShopCardState.buy
                : ShopCardState.short,
            onPressed: room.owns(item.id)
                ? null
                : () => showBuySheet(
                    context,
                    target: BuyItem(item.id),
                    progress: progress,
                  ),
          ),
      ],
    );
  }
}

/// Tab Kucing: paragraf pembuka lalu kartu kesembilan kucing (Oyen sudah
/// tinggal di kamar, jadi tidak dijual).
class _Kitties extends StatelessWidget {
  const _Kitties({required this.progress});

  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final home = progress.home;
    final coins = progress.coins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShopIntro(context.l10n.shopKittyIntro),
        for (final kitty in kitties.skip(1)) ...[
          SizedBox(height: space.s12),
          KittyCard(
            id: kitty.id,
            coins: coins,
            state: home.ownsKitty(kitty.id)
                ? ShopCardState.livesHere
                : coins >= kitty.price
                ? ShopCardState.buy
                : ShopCardState.short,
            onPressed: home.ownsKitty(kitty.id)
                ? null
                : () => showBuySheet(
                    context,
                    target: BuyKitty(kitty.id),
                    progress: progress,
                  ),
          ),
        ],
      ],
    );
  }
}

/// Tab Makanan: paragraf pembuka lalu kartu camilan yang bisa dibeli
/// berulang. Camilan masuk stok langsung, tanpa sheet konfirmasi (desain).
class _Snacks extends StatelessWidget {
  const _Snacks({required this.progress, required this.onBuy});

  final ProgressController progress;
  final void Function(SnackId id) onBuy;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final pantry = progress.home.pantry;
    final coins = progress.coins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShopIntro(context.l10n.shopSnackIntro),
        for (final snack in snacks) ...[
          SizedBox(height: space.s12),
          SnackCard(
            id: snack.id,
            stock: pantry.countOf(snack.id),
            short: coins < snack.price,
            onBuy: () => onBuy(snack.id),
          ),
        ],
      ],
    );
  }
}

/// Tab Aksesoris: panel pratinjau, baris "Coba di:", lalu kisi kartu.
/// Mengetuk kartu hanya mengganti pratinjau; membeli lewat panel.
class _Accessories extends StatelessWidget {
  const _Accessories({
    required this.progress,
    required this.preview,
    required this.selected,
    required this.onPreview,
    required this.onSelect,
    required this.onBuy,
    required this.onWear,
    required this.onRemove,
  });

  final ProgressController progress;
  final KittyId preview;
  final AccessoryId selected;
  final ValueChanged<KittyId> onPreview;
  final ValueChanged<AccessoryId> onSelect;
  final VoidCallback onBuy;
  final VoidCallback onWear;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    final l = context.l10n;
    final home = progress.home;
    final closet = home.closet;
    final coins = progress.coins;
    final owned = closet.owns(selected);
    final worn = closet.wearingOf(preview) == selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessoryPreview(
          kitty: preview,
          accessory: selected,
          coins: coins,
          action: owned
              ? (worn ? AccessoryAction.remove : AccessoryAction.wear)
              : coins >= accessoryOf(selected).price
              ? AccessoryAction.buy
              : AccessoryAction.short,
          onBuy: onBuy,
          onWear: onWear,
          onRemove: onRemove,
        ),
        SizedBox(height: space.s12),
        KittyPicker(
          kitties: [
            for (final kitty in kitties)
              if (home.ownsKitty(kitty.id)) kitty.id,
          ],
          active: preview,
          wearing: closet.wearing,
          onPick: onPreview,
        ),
        SizedBox(height: space.s12),
        ShopGrid(
          children: [
            for (final accessory in accessories)
              AccessoryCard(
                id: accessory.id,
                preview: preview,
                selected: accessory.id == selected,
                state: closet.owns(accessory.id)
                    ? ShopCardState.owned
                    : coins >= accessory.price
                    ? ShopCardState.buy
                    : ShopCardState.short,
                wornBy: [
                  for (final kitty in kitties)
                    if (closet.wearingOf(kitty.id) == accessory.id)
                      kittyName(l, kitty.id),
                ].join(', '),
                onPressed: () => onSelect(accessory.id),
              ),
          ],
        ),
      ],
    );
  }
}
