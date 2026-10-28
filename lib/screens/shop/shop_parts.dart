import 'package:flutter/widgets.dart';

import '../../game/model/home_items.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
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

/// Keadaan kartu Toko (`KartuToko.dc.html`).
enum ShopCardState {
  /// Bisa dibeli: harga terbaca dan kartunya bisa ditekan.
  buy,

  /// Koin kurang: harga pudar dan ada catatan "Koin kurang".
  short,

  /// Sudah dimiliki (barang, aksesoris).
  owned,

  /// Kucing yang sudah tinggal di kamar.
  livesHere,
}

/// Paragraf pembuka di atas daftar kartu (tab Kucing dan Makanan).
class ShopIntro extends StatelessWidget {
  const ShopIntro(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: context.koSpace.s2),
      child: Text(
        text,
        style: context.koType.cardBody.copyWith(
          color: context.koColors.inkSoft,
        ),
      ),
    );
  }
}

/// Harga di kartu: koin lalu angkanya, pudar kalau koinnya kurang.
class ShopPrice extends StatelessWidget {
  const ShopPrice({super.key, required this.price, required this.short});

  final int price;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Row(
      children: [
        if (short)
          Opacity(
            opacity: s.lockedOpacity,
            child: CoinView(kind: CoinKind.plain, size: s.iconSmall),
          )
        else
          CoinView(size: s.iconSmall),
        SizedBox(width: space.s6),
        Text(
          '$price',
          style: context.koType.chip.copyWith(
            color: short ? c.priceMuted : c.ink,
          ),
        ),
        if (short) ...[
          SizedBox(width: space.s6),
          Expanded(
            child: Text(
              context.l10n.shopNotEnoughTag,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.koType.tag.copyWith(color: c.brickDeep),
            ),
          ),
        ],
      ],
    );
  }
}

/// Badge hijau di kartu: "Punyamu" atau "Tinggal di kamar".
class ShopOwnedTag extends StatelessWidget {
  const ShopOwnedTag({super.key, required this.text, this.icon});

  final String text;
  final KoIconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Container(
      height: context.koSize.chipMedium,
      padding: EdgeInsets.symmetric(horizontal: space.s10),
      decoration: BoxDecoration(
        color: c.ownedChip,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            KoIcon(icon!, size: context.koSize.iconMicro, color: c.onSuccess),
            SizedBox(width: space.s6),
          ],
          Text(
            text,
            style: context.koType.labelSmall.copyWith(color: c.onSuccess),
          ),
        ],
      ),
    );
  }
}

/// Centang hijau di pojok kanan atas kotak gambar (barang dan aksesoris
/// yang sudah dimiliki).
class ShopOwnedMark extends StatelessWidget {
  const ShopOwnedMark({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final size = context.koSize.chipMedium - context.koSpace.s2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.success, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: KoIcon(
        KoIcons.check,
        size: context.koSize.iconMicro,
        color: c.onSuccess,
      ),
    );
  }
}

/// Kotak gambar di kartu: latar lantai, sudut melengkung, dan centang
/// hijau kalau sudah dimiliki.
class ShopWell extends StatelessWidget {
  const ShopWell({
    super.key,
    required this.height,
    required this.owned,
    required this.child,
    this.alignBottom = false,
    this.badge,
  });

  final double height;
  final bool owned;
  final Widget child;

  /// Gambar rata bawah (kartu aksesoris: kucing berdiri di dasar kotak).
  final bool alignBottom;

  /// Badge kelangkaan di pojok kiri atas (kartu aksesoris).
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.floor,
                borderRadius: BorderRadius.circular(
                  context.koRadius.statCompact,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  context.koRadius.statCompact,
                ),
                child: Align(
                  alignment: alignBottom
                      ? Alignment.bottomCenter
                      : Alignment.center,
                  child: child,
                ),
              ),
            ),
          ),
          if (badge != null)
            PositionedDirectional(
              top: space.s8,
              start: space.s8,
              child: badge!,
            ),
          if (owned)
            PositionedDirectional(
              top: space.s8,
              end: space.s8,
              child: const ShopOwnedMark(),
            ),
        ],
      ),
    );
  }
}

/// Kartu satu barang kamar di tab Barang (`KartuToko.dc.html`, jenis
/// barang): gambar di kotak, nama, lalu harga atau badge "Punyamu".
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.id,
    required this.state,
    required this.onPressed,
  });

  final RoomItemId id;
  final ShopCardState state;

  /// Null = kartu tidak bisa ditekan (sudah dimiliki).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final item = roomItemOf(id);
    final name = roomItemName(l, id);
    final short = state == ShopCardState.short;
    final owned = state == ShopCardState.owned;
    return KoPressable(
      key: ValueKey('shop-item-${id.name}'),
      onPressed: onPressed,
      semanticLabel: owned
          ? l.shopCardOwnedLabel(name)
          : short
          ? l.shopCardShortLabel(name, item.price)
          : l.shopCardBuyLabel(name, item.price),
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: c.line,
      borderWidth: s.artBorder,
      radius: context.koRadius.card,
      padding: EdgeInsets.all(space.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShopWell(
            height: s.shopItemWell,
            owned: owned,
            child: Opacity(
              opacity: short ? s.lockedOpacity : 1,
              child: RoomItemView(
                id: id,
                box: Size(s.shopItemArtWidth, s.shopItemArtHeight),
              ),
            ),
          ),
          SizedBox(height: space.s8),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.koType.cardName.copyWith(color: c.ink),
          ),
          SizedBox(height: space.s8),
          if (owned)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShopOwnedTag(text: l.shopOwnedTag),
            )
          else
            ShopPrice(price: item.price, short: short),
        ],
      ),
    );
  }
}

/// Kisi dua kolom kartu Toko (desain 20). Kartu sebaris sama tinggi,
/// setinggi kartu tertinggi, jadi tinggi teks 130% tetap muat.
class ShopGrid extends StatelessWidget {
  const ShopGrid({super.key, required this.children});

  final List<Widget> children;

  static const columns = 2;

  @override
  Widget build(BuildContext context) {
    final gap = context.koSpace.s12;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i += columns) ...[
          if (i > 0) SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + columns; j++) ...[
                  if (j > i) SizedBox(width: gap),
                  Expanded(
                    child: j < children.length
                        ? children[j]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
