import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../theme/theme.dart';
import '../coins/coin_sheet.dart';
import 'shop_parts.dart';
import 'shop_tab.dart';

export 'shop_tab.dart';

/// Toko (desain 20, rute `/toko`): empat tab untuk membeli barang, kucing,
/// aksesoris, dan camilan dengan koin.
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
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
