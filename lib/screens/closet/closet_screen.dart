import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/costumes.dart';
import '../../game/render/render.dart';
import '../../l10n/l10n.dart';
import '../../l10n/names.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../coins/coin_sheet.dart';
import 'closet_parts.dart';

/// Lemari Kostum (desain 12, rute `/kostum`): pratinjau Oyen di lemari,
/// grid kostum, dan tombol beli/pakai. Menekan kartu hanya memilih
/// pratinjau; kostum yang dipakai berubah lewat tombol aksi.
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  /// Kostum yang dipratinjau; awalnya kostum yang sedang dipakai.
  OyenCostume? _selected;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final wardrobe = progress.wardrobe;
    final coins = progress.coins;
    final selected = _selected ??= wardrobe.wearing;
    final costume = costumeOf(selected);
    final action = wardrobe.actionFor(selected, coins);

    final c = context.koColors;
    final space = context.koSpace;
    final s = context.koSize;
    final t = context.koType;

    void act() => switch (action) {
      CostumeAction.buy => unawaited(progress.buyCostume(selected)),
      CostumeAction.wear => unawaited(progress.wearCostume(selected)),
      CostumeAction.wearing || CostumeAction.notEnoughCoins => null,
    };
    final enabled = action == CostumeAction.buy || action == CostumeAction.wear;

    return Scaffold(
      backgroundColor: c.cream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: space.s8),
              ClosetBar(
                coins: coins,
                onBack: () => context.go(AppRoutes.home),
                onCoins: () => showCoinSheet(context, progress),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    // Pratinjau mengisi sisa tempat (paling besar seukuran
                    // desain); di layar pendek berhenti di skala terkecil
                    // dan grid digulir, tombol aksi tetap terlihat.
                    final name = costumeName(context.l10n, costume.id);
                    final nameStyle = t.heading.copyWith(color: c.ink);
                    final namePainter = TextPainter(
                      // Gaya gabungan seperti `Text` (tinggi baris ikut
                      // DefaultTextStyle).
                      text: TextSpan(
                        text: name,
                        style: DefaultTextStyle.of(context).style
                            .merge(nameStyle),
                      ),
                      textScaler: MediaQuery.textScalerOf(context),
                      textDirection: Directionality.of(context),
                      maxLines: 1,
                    )..layout();
                    final nameHeight = namePainter.height;
                    namePainter.dispose();
                    // Jarak yang sama dipakai Column di bawah.
                    final (top, afterArt, afterName, bottom) = (
                      space.s8,
                      space.s6,
                      space.s16,
                      space.s24 + space.s4,
                    );
                    final rest =
                        top +
                        afterArt +
                        nameHeight +
                        afterName +
                        CostumeGrid.heightOf(context) +
                        bottom;
                    final art = ClosetArt.viewBox.height;
                    final preview = (box.maxHeight - rest).clamp(
                      art * s.closetMinScale,
                      art,
                    );
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: top),
                          SizedBox(
                            height: preview,
                            child: ClosetPreview(costume: selected),
                          ),
                          SizedBox(height: afterArt),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: nameStyle,
                            ),
                          ),
                          SizedBox(height: afterName),
                          CostumeGrid(
                            wardrobe: wardrobe,
                            selected: selected,
                            onSelect: (id) => setState(() => _selected = id),
                          ),
                          SizedBox(height: bottom),
                        ],
                      ),
                    );
                  },
                ),
              ),
              KoButton(
                label: closetActionLabel(context.l10n, action, costume),
                onPressed: enabled ? act : null,
              ),
              SizedBox(height: space.s32),
            ],
          ),
        ),
      ),
    );
  }
}
