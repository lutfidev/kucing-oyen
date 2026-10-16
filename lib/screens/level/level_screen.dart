import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../game/level_loader.dart';
import '../../game/sim/level.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'level_view.dart';

/// Rute `/level/:id`: memuat level dari aset lalu menampilkan [LevelView].
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key, required this.levelId});

  /// Nomor level; null kalau rutenya tidak berisi angka.
  final int? levelId;

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late final Future<List<Level>> _levels = loadLevels();

  // Peta babak dibuat di langkah 9; sampai itu kembali ke Beranda.
  static const _backLabel = 'Kembali ke Beranda';

  void _back() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _levels,
      builder: (context, snapshot) {
        final levels = snapshot.data;
        if (levels == null && !snapshot.hasError) {
          return const Scaffold(body: SizedBox.shrink());
        }
        final level = levels
            ?.where((level) => level.id == widget.levelId)
            .firstOrNull;
        if (level == null) {
          return _NotFound(backLabel: _backLabel, onBack: _back);
        }
        return LevelView(
          key: ValueKey(level.id),
          level: level,
          backLabel: _backLabel,
          onBack: _back,
        );
      },
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.backLabel, required this.onBack});

  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final space = context.koSpace;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KoIconButton(
                icon: KoIcons.back,
                semanticLabel: backLabel,
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Level ini nggak ada.',
                    textAlign: TextAlign.center,
                    style: context.koType.body.copyWith(
                      color: context.koColors.inkSoft,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
