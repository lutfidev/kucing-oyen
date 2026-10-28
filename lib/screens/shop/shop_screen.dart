import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/home_items.dart';
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
            SizedBox(height: space.s12),
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
                  _ => const SizedBox.shrink(),
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
