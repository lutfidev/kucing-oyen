import 'package:flutter/widgets.dart';

import '../../game/model/accessories.dart';
import '../../game/model/home_items.dart';
import '../../game/render/render.dart';
import '../../game/model/kitties.dart';
import '../../game/model/snacks.dart';
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
      height: context.koSize.shopOwnedChip,
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
    final size = context.koSize.shopOwnedMark;
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
      borderWidth: s.border,
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

/// Kartu satu kucing koleksi (`KartuToko.dc.html`, jenis kucing): sprite
/// di kotak, nama, deskripsi, lalu "Adopsi · N", badge "Tinggal di kamar",
/// atau harga pudar beserta selisih koinnya.
class KittyCard extends StatelessWidget {
  const KittyCard({
    super.key,
    required this.id,
    required this.state,
    required this.coins,
    required this.onPressed,
  });

  final KittyId id;
  final ShopCardState state;

  /// Saldo pemain, untuk menghitung selisih harga.
  final int coins;

  /// Null = kartu tidak bisa ditekan (sudah tinggal di kamar).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final kitty = kittyOf(id);
    final name = kittyName(l, id);
    final short = state == ShopCardState.short;
    final home = state == ShopCardState.livesHere;
    return KoPressable(
      key: ValueKey('shop-kitty-${id.name}'),
      onPressed: onPressed,
      semanticLabel: home
          ? l.shopCardLivesLabel(name)
          : short
          ? l.shopCardShortLabel(name, kitty.price)
          : l.shopCardBuyLabel(name, kitty.price),
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.tray,
      padding: EdgeInsets.all(space.s12),
      child: Row(
        children: [
          Container(
            width: s.shopKittyWell,
            height: s.shopKittyWell,
            decoration: BoxDecoration(
              color: c.floor,
              borderRadius: BorderRadius.circular(context.koRadius.control),
            ),
            alignment: Alignment.center,
            child: KittyView(
              look: KittyLook(kitty: id),
              size: s.shopKittyArt,
            ),
          ),
          SizedBox(width: space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.koType.button.copyWith(color: c.ink),
                ),
                SizedBox(height: space.s6),
                Text(
                  kittyDesc(l, id),
                  style: context.koType.cardText.copyWith(color: c.inkSoft),
                ),
                SizedBox(height: space.s6),
                if (home)
                  ShopOwnedTag(text: l.shopLivesHere, icon: KoIcons.house)
                else if (short)
                  Wrap(
                    spacing: space.s8,
                    runSpacing: space.s4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _PriceChip(price: kitty.price),
                      Text(
                        l.shopShortBy(kitty.price - coins),
                        style: context.koType.tag.copyWith(color: c.brickDeep),
                      ),
                    ],
                  )
                else
                  _AdoptChip(price: kitty.price),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip harga oranye "Adopsi · N" di kartu kucing yang bisa dibeli.
class _AdoptChip extends StatelessWidget {
  const _AdoptChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Container(
      height: s.shopPriceChip,
      padding: EdgeInsetsDirectional.only(start: space.s8, end: space.s12),
      decoration: BoxDecoration(
        color: c.orange,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
        boxShadow: context.koShadow.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinView(size: s.iconSmall),
          SizedBox(width: space.s6),
          Text(
            context.l10n.shopAdopt(price),
            style: context.koType.cardLabel.copyWith(color: c.ink),
          ),
        ],
      ),
    );
  }
}

/// Chip harga pudar di kartu kucing yang koinnya kurang.
class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return Container(
      height: s.shopPriceChip,
      padding: EdgeInsetsDirectional.only(start: space.s8, end: space.s12),
      decoration: BoxDecoration(
        color: c.shortFill,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: s.lockedOpacity,
            child: CoinView(kind: CoinKind.plain, size: s.iconSmall),
          ),
          SizedBox(width: space.s6),
          Text(
            '$price',
            style: context.koType.cardLabel.copyWith(color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu camilan (`KartuToko.dc.html`, jenis makanan): gambar, nama,
/// deskripsi, stok, dan tombol beli yang langsung menambah stok.
class SnackCard extends StatelessWidget {
  const SnackCard({
    super.key,
    required this.id,
    required this.stock,
    required this.short,
    required this.full,
    required this.onBuy,
  });

  final SnackId id;
  final int stock;

  /// Koin tidak cukup: tombol beli mati.
  final bool short;

  /// Stok sudah penuh (99): tombol beli mati juga.
  final bool full;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final snack = snackOf(id);
    final name = snackName(l, id);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        space.s10,
        space.s10,
        space.s12,
        space.s10,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line, width: s.border),
        borderRadius: BorderRadius.circular(context.koRadius.card),
        boxShadow: context.koShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: s.shopSnackWell,
            height: s.shopSnackWell,
            decoration: BoxDecoration(
              color: c.floor,
              borderRadius: BorderRadius.circular(context.koRadius.slot),
            ),
            alignment: Alignment.center,
            child: SnackView(
              id: id,
              box: Size(s.shopSnackArtWidth, s.shopSnackArtHeight),
            ),
          ),
          SizedBox(width: space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.koType.chip.copyWith(color: c.ink),
                ),
                SizedBox(height: space.s4),
                Text(
                  snackDesc(l, id),
                  style: context.koType.cardTextSmall.copyWith(
                    color: c.inkSoft,
                  ),
                ),
                SizedBox(height: space.s6),
                _StockChip(stock: stock, full: full),
              ],
            ),
          ),
          SizedBox(width: space.s8),
          KoPressable(
            key: ValueKey('shop-snack-${id.name}'),
            onPressed: short || full ? null : onBuy,
            semanticLabel: full
                ? l.shopSnackFullLabel(name)
                : short
                ? l.shopSnackShortLabel(name, snack.price)
                : l.shopSnackBuyLabel(name, snack.price),
            color: short || full ? c.shortFill : c.orange,
            edgeColor: short || full ? null : c.orangeDeep,
            depth: short || full ? 0 : context.koShadow.pressSecondary,
            radius: context.koRadius.slot,
            height: s.shopSnackButton,
            padding: EdgeInsetsDirectional.only(
              start: space.s10,
              end: space.s12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (short || full)
                  Opacity(
                    opacity: s.lockedOpacity,
                    child: CoinView(kind: CoinKind.plain, size: s.iconSmall),
                  )
                else
                  CoinView(kind: CoinKind.plain, size: s.iconSmall),
                SizedBox(width: space.s6),
                Text(
                  l.shopBuyShort(snack.price),
                  style: context.koType.cardLabel.copyWith(
                    color: short || full ? c.inkSoft : c.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip stok camilan: krem kalau ada, merah muda kalau habis, dan menyebut
/// "Stok penuh" kalau sudah 99.
class _StockChip extends StatelessWidget {
  const _StockChip({required this.stock, required this.full});

  final int stock;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final empty = stock == 0;
    return Container(
      height: context.koSize.shopStockChip,
      padding: EdgeInsets.symmetric(horizontal: context.koSpace.s8),
      decoration: BoxDecoration(
        color: empty ? c.priceTag : c.tabTrack,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          full ? context.l10n.shopStockFull : context.l10n.shopStock(stock),
          style: context.koType.tagSmall.copyWith(
            color: empty ? c.brickDeep : c.ink,
          ),
        ),
      ),
    );
  }
}

/// Pesan mengapung sesudah membeli camilan atau memasang aksesoris
/// ("-15 koin", "Cakep!"). Hilang sendiri; diumumkan pembaca layar.
class ShopFlash extends StatelessWidget {
  const ShopFlash(this.text, {super.key});

  final String text;

  /// Lama pesan tampil (desain: animasi 1,3 detik).
  static const duration = Duration(milliseconds: 1300);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.koType.cardLabel.copyWith(
          color: context.koColors.orangeDeep,
        ),
      ),
    );
  }
}

/// Badge kelangkaan aksesoris: biasa, langka, atau spesial.
class RarityChip extends StatelessWidget {
  const RarityChip({super.key, required this.rarity, this.height});

  final Rarity rarity;

  /// Tinggi badge; default badge kartu (desain 20).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final (Color fill, Color ink) = switch (rarity) {
      Rarity.common => (c.surface, c.inkSoft),
      Rarity.rare => (c.rareChip, c.onRareChip),
      Rarity.special => (c.specialChip, c.onSpecialChip),
    };
    return Container(
      height: height ?? context.koSize.shopRarityChip,
      padding: EdgeInsets.symmetric(horizontal: context.koSpace.s8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          rarityName(context.l10n, rarity),
          style: context.koType.tagTiny.copyWith(color: ink),
        ),
      ),
    );
  }
}

/// Panggung pratinjau aksesoris: kucing terpilih memakai aksesoris yang
/// sedang dilihat, di depan dinding dan lantai (desain 20g).
class AccessoryStage extends StatelessWidget {
  const AccessoryStage({
    super.key,
    required this.kitty,
    required this.accessory,
    required this.scale,
  });

  final KittyId kitty;
  final AccessoryId accessory;

  /// Skala panggung (1 = ukuran desain; mengecil di layar 360 px).
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return SizedBox(
      width: s.shopPreviewWidth * scale,
      height: s.shopPreviewHeight * scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.koRadius.control),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.floor)),
            Positioned(
              top: s.shopPreviewFloor * scale,
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(color: c.floorAlt),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: context.koSpace.s6 * scale),
                child: KittyView(
                  look: KittyLook(kitty: kitty, accessory: accessory),
                  size: s.shopPreviewArt * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aksi di panel pratinjau aksesoris.
enum AccessoryAction {
  /// Belum dimiliki dan koinnya cukup.
  buy,

  /// Belum dimiliki dan koinnya kurang.
  short,

  /// Dimiliki dan belum dipakai kucing ini.
  wear,

  /// Dipakai kucing ini.
  remove,
}

/// Panel pratinjau aksesoris: panggung kucing, nama, kelangkaan,
/// deskripsi, dan tombol beli, pakai, atau lepas (desain 20g).
class AccessoryPreview extends StatelessWidget {
  const AccessoryPreview({
    super.key,
    required this.kitty,
    required this.accessory,
    required this.action,
    required this.coins,
    required this.onBuy,
    required this.onWear,
    required this.onRemove,
  });

  final KittyId kitty;
  final AccessoryId accessory;
  final AccessoryAction action;
  final int coins;
  final VoidCallback onBuy;
  final VoidCallback onWear;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final item = accessoryOf(accessory);
    final name = accessoryName(l, accessory);
    final owned =
        action == AccessoryAction.wear || action == AccessoryAction.remove;
    // Panggung mengecil di layar sempit (catatan n360 di desain).
    final scale = MediaQuery.sizeOf(context).width < 380
        ? s.shopPreviewMinScale
        : 1.0;
    return Container(
      padding: EdgeInsets.all(space.s12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line, width: s.border),
        borderRadius: BorderRadius.circular(context.koRadius.art),
        boxShadow: context.koShadow.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessoryStage(kitty: kitty, accessory: accessory, scale: scale),
          SizedBox(width: space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.shopPreviewOf(kittyName(l, kitty)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.koType.overline.copyWith(color: c.inkSoft),
                ),
                SizedBox(height: space.s6),
                Row(
                  children: [
                    AccessoryIconView(id: accessory, size: s.iconCompact),
                    SizedBox(width: space.s6),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.koType.headingStrong.copyWith(
                          color: c.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: space.s6),
                Wrap(
                  spacing: space.s6,
                  runSpacing: space.s4,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RarityChip(rarity: item.rarity, height: s.shopPreviewChip),
                    if (owned) ShopOwnedTag(text: l.shopOwnedTag),
                  ],
                ),
                SizedBox(height: space.s6),
                Text(
                  accessoryDesc(l, accessory),
                  style: context.koType.cardTextSmall.copyWith(
                    color: c.inkSoft,
                  ),
                ),
                SizedBox(height: space.s10),
                switch (action) {
                  AccessoryAction.buy => _PreviewButton(
                    key: const ValueKey('shop-preview-buy'),
                    label: l.shopBuyShort(item.price),
                    color: c.orange,
                    edge: c.orangeDeep,
                    ink: c.ink,
                    icon: CoinView(kind: CoinKind.plain, size: s.iconCompact),
                    onPressed: onBuy,
                  ),
                  AccessoryAction.short => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PreviewButton(
                        key: const ValueKey('shop-preview-short'),
                        label: l.notEnoughCoins(item.price - coins),
                        color: c.shortFill,
                        edge: null,
                        ink: c.inkSoft,
                        icon: KoIcon(
                          KoIcons.lock,
                          size: s.iconCompact,
                          color: c.inkSoft,
                        ),
                        onPressed: null,
                      ),
                      SizedBox(height: space.s4),
                      Text(
                        l.shopPlayFirst,
                        style: context.koType.tag.copyWith(color: c.brickDeep),
                      ),
                    ],
                  ),
                  AccessoryAction.wear => _PreviewButton(
                    key: const ValueKey('shop-preview-wear'),
                    label: l.shopWearFree,
                    color: c.success,
                    edge: c.successDeep,
                    ink: c.onSuccess,
                    onPressed: onWear,
                  ),
                  AccessoryAction.remove => _PreviewButton(
                    key: const ValueKey('shop-preview-remove'),
                    label: l.shopRemoveFree,
                    color: c.surface,
                    edge: c.lineDeep,
                    ink: c.ink,
                    border: true,
                    onPressed: onRemove,
                  ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({
    super.key,
    required this.label,
    required this.color,
    required this.edge,
    required this.ink,
    required this.onPressed,
    this.icon,
    this.border = false,
  });

  final String label;
  final Color color;
  final Color? edge;
  final Color ink;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    return KoPressable(
      onPressed: onPressed,
      semanticLabel: label,
      color: color,
      edgeColor: edge,
      depth: edge == null ? 0 : context.koShadow.pressSecondary,
      borderColor: border ? c.line : null,
      borderWidth: border ? s.border : 0,
      radius: context.koRadius.slot,
      height: s.shopPreviewButton,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: space.s6)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.koType.cardLabel.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris "Coba di:": kucing yang dimiliki, yang terpilih berbingkai
/// oranye (desain 20g).
class KittyPicker extends StatelessWidget {
  const KittyPicker({
    super.key,
    required this.kitties,
    required this.active,
    required this.wearing,
    required this.onPick,
  });

  final List<KittyId> kitties;
  final KittyId active;

  /// Aksesoris yang sedang dipakai tiap kucing.
  final Map<KittyId, AccessoryId> wearing;
  final ValueChanged<KittyId> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    return Row(
      children: [
        Text(
          l.shopTryOn,
          style: context.koType.labelSmall.copyWith(color: c.inkSoft),
        ),
        SizedBox(width: space.s8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final kitty in kitties) ...[
                  if (kitty != kitties.first) SizedBox(width: space.s8),
                  KoPressable(
                    key: ValueKey('shop-preview-${kitty.name}'),
                    onPressed: () => onPick(kitty),
                    semanticLabel: l.shopPreviewPickLabel(kittyName(l, kitty)),
                    toggled: kitty == active,
                    color: c.surface,
                    depth: 0,
                    circle: true,
                    borderColor: kitty == active ? c.orange : c.line,
                    borderWidth: kitty == active ? s.artBorder : s.border,
                    width: s.shopPick,
                    height: s.shopPick,
                    child: Center(
                      child: KittyView(
                        look: KittyLook(
                          kitty: kitty,
                          accessory: wearing[kitty],
                        ),
                        size: s.shopPickArt,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu satu aksesoris: kucing pratinjau memakainya, badge kelangkaan,
/// ikon dan nama, lalu harga atau "Punyamu" beserta pemakainya.
class AccessoryCard extends StatelessWidget {
  const AccessoryCard({
    super.key,
    required this.id,
    required this.preview,
    required this.state,
    required this.selected,
    required this.wornBy,
    required this.onPressed,
  });

  final AccessoryId id;

  /// Kucing yang dipakai untuk menggambar kartunya.
  final KittyId preview;
  final ShopCardState state;
  final bool selected;

  /// Nama kucing yang memakainya, dipisah koma; kosong = tidak dipakai.
  final String wornBy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final l = context.l10n;
    final item = accessoryOf(id);
    final name = accessoryName(l, id);
    final short = state == ShopCardState.short;
    final owned = state == ShopCardState.owned;
    return KoPressable(
      key: ValueKey('shop-accessory-${id.name}'),
      onPressed: onPressed,
      semanticLabel: owned
          ? (wornBy.isEmpty
                ? l.shopAccessoryOwnedLabel(name)
                : l.shopAccessoryWornLabel(name, wornBy))
          : short
          ? l.shopAccessoryShortLabel(name, item.price)
          : l.shopAccessoryBuyLabel(name, item.price),
      toggled: selected,
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: selected ? c.orange : c.line,
      borderWidth: selected ? s.artBorder : s.border,
      radius: context.koRadius.card,
      padding: EdgeInsets.all(space.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShopWell(
            height: s.shopAccessoryWell,
            owned: owned,
            alignBottom: true,
            badge: RarityChip(rarity: item.rarity),
            child: Opacity(
              opacity: short ? s.lockedOpacity : 1,
              child: KittyView(
                look: KittyLook(kitty: preview, accessory: id),
                size: s.shopAccessoryArt,
              ),
            ),
          ),
          SizedBox(height: space.s8),
          Row(
            children: [
              AccessoryIconView(id: id, size: s.iconSmall),
              SizedBox(width: space.s6),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.koType.cardName.copyWith(color: c.ink),
                ),
              ),
            ],
          ),
          SizedBox(height: space.s8),
          if (owned)
            Wrap(
              spacing: space.s6,
              runSpacing: space.s4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ShopOwnedTag(text: l.shopOwnedTag),
                if (wornBy.isNotEmpty)
                  Text(
                    l.shopWornBy(wornBy),
                    style: context.koType.tag.copyWith(color: c.successDeep),
                  ),
              ],
            )
          else
            ShopPrice(price: item.price, short: short),
        ],
      ),
    );
  }
}
