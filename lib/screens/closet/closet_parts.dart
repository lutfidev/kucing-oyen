import 'package:flutter/widgets.dart';

import '../../game/model/costumes.dart';
import '../../game/render/render.dart';
import '../../game/sim/sim.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Bar atas Lemari Kostum: tombol kembali, judul, dan saldo koin.
class ClosetBar extends StatelessWidget {
  const ClosetBar({super.key, required this.coins, required this.onBack});

  final int coins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final space = context.koSpace;
    return Row(
      children: [
        KoIconButton(
          icon: KoIcons.back,
          semanticLabel: 'Kembali ke Beranda',
          onPressed: onBack,
        ),
        SizedBox(width: space.s10),
        Expanded(
          child: Semantics(
            header: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Lemari Kostum',
                maxLines: 1,
                style: context.koType.headingLarge.copyWith(color: c.ink),
              ),
            ),
          ),
        ),
        SizedBox(width: space.s10),
        _CoinChip(coins: coins),
      ],
    );
  }
}

/// Saldo koin di kanan atas (desain 12): bergaris, tanpa bayangan.
class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$coins koin',
      excludeSemantics: true,
      child: Container(
        height: s.chip,
        padding: EdgeInsetsDirectional.only(start: space.s6, end: space.s14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(context.koRadius.pill),
          border: Border.all(color: c.line, width: s.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoinView(size: s.iconMedium),
            SizedBox(width: space.s6),
            Text(
              '$coins',
              maxLines: 1,
              style: context.koType.numberCoinLarge.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lemari kayu dengan Oyen senang memakai [costume], mengecil kalau
/// tempatnya kurang tinggi.
class ClosetPreview extends StatelessWidget {
  const ClosetPreview({super.key, required this.costume});

  final OyenCostume costume;

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    final size = ClosetArt.viewBox;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomCenter,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          children: [
            const ClosetView(),
            Positioned(
              left: (size.width - s.oyenCloset) / 2,
              bottom: context.koSpace.s14,
              child: OyenView(
                OyenLook(
                  pose: OyenPose.happy,
                  dir: Direction.down,
                  costume: costume,
                ),
                size: s.oyenCloset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu satu kostum: Oyen kecil berkostum, nama, dan label "Dipakai",
/// "Punyamu", atau harga. [selected] = sedang dipratinjau.
class CostumeCard extends StatelessWidget {
  const CostumeCard({
    super.key,
    required this.costume,
    required this.owned,
    required this.wearing,
    required this.selected,
    required this.onTap,
  });

  final Costume costume;
  final bool owned;
  final bool wearing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    final space = context.koSpace;
    final radius = context.koRadius;
    final (String tag, String status) = wearing
        ? ('Dipakai', 'dipakai')
        : owned
        ? ('Punyamu', 'punyamu')
        : ('${costume.price}', '${costume.price} koin');

    return KoPressable(
      onPressed: onTap,
      semanticLabel: '${costume.name}, $status',
      toggled: selected,
      color: c.surface,
      edgeColor: selected ? c.orangeDeep : c.lineDeep,
      depth: context.koShadow.pressSecondary,
      borderColor: selected ? c.orange : c.line,
      borderWidth: s.artBorder,
      radius: radius.card,
      height: s.costumeCard,
      padding: EdgeInsets.symmetric(horizontal: space.s12),
      child: Row(
        children: [
          Container(
            width: s.costumeArt,
            height: s.costumeArt,
            decoration: BoxDecoration(
              color: c.floor,
              borderRadius: BorderRadius.circular(radius.slot),
            ),
            alignment: Alignment.center,
            child: OyenView(
              OyenLook(dir: Direction.down, costume: costume.id),
              size: s.oyenCostume,
            ),
          ),
          SizedBox(width: space.s10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    costume.name,
                    maxLines: 1,
                    style: context.koType.cardLabel.copyWith(color: c.ink),
                  ),
                ),
                SizedBox(height: space.s6),
                _Tag(
                  text: tag,
                  coin: !owned,
                  color: wearing
                      ? c.success
                      : owned
                      ? c.locked
                      : c.priceTag,
                  textColor: wearing ? c.onSuccess : c.ink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label kecil di kartu kostum, dengan ikon koin untuk harga.
class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.coin,
    required this.color,
    required this.textColor,
  });

  final String text;
  final bool coin;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final s = context.koSize;
    final space = context.koSpace;
    return Container(
      height: s.badge,
      padding: EdgeInsets.symmetric(horizontal: space.s8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.koRadius.pill),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (coin) ...[
              CoinView(size: s.iconTiny, plain: true),
              SizedBox(width: space.s4),
            ],
            Text(
              text,
              maxLines: 1,
              style: context.koType.tag.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid dua kolom kartu kostum (desain 12).
class CostumeGrid extends StatelessWidget {
  const CostumeGrid({
    super.key,
    required this.wardrobe,
    required this.selected,
    required this.onSelect,
  });

  final Wardrobe wardrobe;
  final OyenCostume selected;
  final ValueChanged<OyenCostume> onSelect;

  static const columns = 2;

  @override
  Widget build(BuildContext context) {
    final gap = context.koSpace.s10;
    Widget card(Costume costume) => CostumeCard(
      key: ValueKey('costume-${costume.id.name}'),
      costume: costume,
      owned: wardrobe.owns(costume.id),
      wearing: wardrobe.wearing == costume.id,
      selected: selected == costume.id,
      onTap: () => onSelect(costume.id),
    );

    return Column(
      children: [
        for (var i = 0; i < costumes.length; i += columns) ...[
          if (i > 0) SizedBox(height: gap),
          Row(
            children: [
              for (var j = i; j < i + columns; j++) ...[
                if (j > i) SizedBox(width: gap),
                Expanded(
                  child: j < costumes.length
                      ? card(costumes[j])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Label tombol aksi untuk [action] pada [costume].
String closetActionLabel(CostumeAction action, Costume costume) =>
    switch (action) {
      CostumeAction.wearing => 'Sedang dipakai',
      CostumeAction.wear => 'Pakai',
      CostumeAction.buy => 'Beli · ${costume.price} koin',
      CostumeAction.notEnoughCoins => 'Koin kurang · ${costume.price}',
    };
