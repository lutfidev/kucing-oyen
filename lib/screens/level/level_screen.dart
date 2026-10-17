import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/progress_scope.dart';
import '../../app/routes.dart';
import '../../game/model/rules.dart';
import '../../game/sim/level.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'level_view.dart';
import 'tutorial.dart';

/// Rute `/babak/:chapter/level/:id`: level dari [ProgressScope] di
/// [LevelView]. Bintang (dan koin bintang baru) dicatat saat layar hasil
/// dibuka. Kartu aturan mengikuti progres, petunjuk dan saldo dari
/// [ProgressController], dan tutorial level tampil sampai selesai sekali.
class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key, required this.chapter, required this.levelId});

  /// Nomor babak di path; null kalau bukan angka.
  final int? chapter;

  /// Nomor level; null kalau rutenya tidak berisi angka.
  final int? levelId;

  static const _backLabel = 'Kembali ke peta';

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.read(context);
    final id = levelId;
    final level = id == null ? null : progress.levelById(id);
    // Kembali ke peta babak level itu; kalau levelnya tidak ada, ke peta
    // di path, atau Beranda kalau path-nya juga bukan babak.
    final backTo = level?.chapter ?? chapter;
    void back() =>
        context.go(backTo == null ? AppRoutes.home : AppRoutes.chapter(backTo));
    if (level == null) {
      return _NotFound(
        backLabel: backTo == null ? 'Kembali ke Beranda' : _backLabel,
        onBack: back,
      );
    }
    return LevelView(
      key: ValueKey(level.id),
      level: level,
      backLabel: _backLabel,
      onBack: back,
      onNext: () => _next(context, progress.levels, level),
      onResult: (stars) {
        final earned = progress.coinsFor(level.id, stars);
        unawaited(progress.record(level.id, stars));
        return earned;
      },
      rules: learnedRules(progress.progress, level.id),
      tutorial: progress.isTutorialDone(level.id)
          ? null
          : tutorialFor(level.id),
      onTutorialDone: () => unawaited(progress.finishTutorial(level.id)),
      hints: progress,
    );
  }

  /// "Lanjut": level berikutnya; sesudah level terakhir kembali ke peta.
  void _next(BuildContext context, List<Level> levels, Level level) {
    final i = levels.indexOf(level);
    final next = i + 1 < levels.length ? levels[i + 1] : null;
    context.go(
      next == null
          ? AppRoutes.chapter(level.chapter)
          : AppRoutes.level(next.id, chapter: next.chapter),
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
