import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/costumes.dart';
import '../../game/render/render.dart';
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
      CostumeAction.buy => progress.buyCostume(selected),
      CostumeAction.wear => progress.wearCostume(selected),
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
                    final scaler = MediaQuery.textScalerOf(context);
                    final rows = (costumes.length / CostumeGrid.columns).ceil();
                    final rest =
                        space.s8 +
                        space.s6 +
                        scaler.scale(t.heading.fontSize!) * 1.25 +
                        space.s16 +
                        rows * s.costumeCard +
                        (rows - 1) * space.s10 +
                        space.s24 +
                        space.s4;
                    final art = ClosetArt.viewBox.height;
                    final preview = (box.maxHeight - rest).clamp(
                      art * s.closetMinScale,
                      art,
                    );
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: space.s8),
                          SizedBox(
                            height: preview,
                            child: ClosetPreview(costume: selected),
                          ),
                          SizedBox(height: space.s6),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              costume.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: t.heading.copyWith(color: c.ink),
                            ),
                          ),
                          SizedBox(height: space.s16),
                          CostumeGrid(
                            wardrobe: wardrobe,
                            selected: selected,
                            onSelect: (id) => setState(() => _selected = id),
                          ),
                          SizedBox(height: space.s24 + space.s4),
                        ],
                      ),
                    );
                  },
                ),
              ),
              KoButton(
                label: closetActionLabel(action, costume),
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
