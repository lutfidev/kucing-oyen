import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'shop_tab.dart';

/// Bar atas Toko: tombol kembali, judul, dan saldo koin yang membuka sheet
/// Tambah Koin ([onCoins]). Titik merah di chip = bonus harian siap.
class ShopBar extends StatelessWidget {
  const ShopBar({
    super.key,
    required this.coins,
    required this.bonus,
    required this.onBack,
    required this.onCoins,
  });

  final int coins;
  final bool bonus;
  final VoidCallback onBack;
  final VoidCallback onCoins;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Row(
      children: [
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: context.l10n.backToHome,
          onPressed: onBack,
        ),
        SizedBox(width: space.s12),
        Expanded(
          child: Semantics(
            header: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.l10n.shop,
                maxLines: 1,
                style: context.koType.headlineSmall.copyWith(color: c.ink),
              ),
            ),
          ),
        ),
        SizedBox(width: space.s12),
        KoCoinChip(coins: coins, badge: bonus, onPressed: onCoins),
      ],
    );
  }
}

/// Empat tab Toko (`TabToko.dc.html`): ikon di atas label, tab aktif
/// berlatar terang dengan bayangan padat.
class ShopTabs extends StatelessWidget {
  const ShopTabs({super.key, required this.active, required this.onPick});

  final ShopTab active;
  final ValueChanged<ShopTab> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final radius = context.koRadius;
    final s = context.koSize;
    return Container(
      height: s.shopTabBar,
      padding: EdgeInsets.all(space.s4),
      decoration: BoxDecoration(
        color: c.tabTrack,
        borderRadius: BorderRadius.circular(radius.control),
      ),
      child: Row(
        children: [
          for (final tab in ShopTab.values) ...[
            if (tab != ShopTab.values.first) SizedBox(width: space.s4),
            Expanded(
              child: _Tab(
                tab: tab,
                label: _labelOf(context.l10n, tab),
                icon: _iconOf(tab),
                selected: tab == active,
                onPressed: () => onPick(tab),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _labelOf(AppLocalizations l, ShopTab tab) => switch (tab) {
  ShopTab.items => l.shopTabItems,
  ShopTab.kitties => l.shopTabKitties,
  ShopTab.accessories => l.shopTabAccessories,
  ShopTab.snacks => l.shopTabSnacks,
};

KoIconData _iconOf(ShopTab tab) => switch (tab) {
  ShopTab.items => KoIcons.shop,
  ShopTab.kitties => KoIcons.kitty,
  ShopTab.accessories => KoIcons.accessory,
  ShopTab.snacks => KoIcons.snack,
};

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final ShopTab tab;
  final String label;
  final KoIconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final ink = selected ? c.ink : c.inkSoft;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      toggled: selected,
      color: selected ? c.surface : const Color(0x00000000),
      edgeColor: selected ? c.lineDeep : null,
      depth: selected ? space.s2 + 1 : 0,
      radius: context.koRadius.statCompact,
      height: s.shopTab,
      padding: EdgeInsets.symmetric(horizontal: space.s4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KoIcon(icon, size: s.iconCompact, color: ink),
          SizedBox(height: space.s2 + 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.koType.tag.copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}
