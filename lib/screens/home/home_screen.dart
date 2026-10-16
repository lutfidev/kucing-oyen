import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Beranda sementara sampai langkah 9 roadmap: judul, jalan pintas ke tiap
/// level, dan jalan ke galeri.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    final space = context.koSpace;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(space.gutter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kucing Oren',
                  textAlign: TextAlign.center,
                  style: t.display.copyWith(color: c.ink),
                ),
                SizedBox(height: space.s8),
                Text(
                  'Oyen nggak bisa disuruh. Kamu yang mikir.',
                  textAlign: TextAlign.center,
                  style: t.body.copyWith(color: c.inkSoft),
                ),
                SizedBox(height: space.s32),
                Text(
                  'Coba level'.toUpperCase(),
                  style: t.overline.copyWith(color: c.inkSoft),
                ),
                SizedBox(height: space.s12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: space.s8,
                  runSpacing: space.s12,
                  children: [
                    for (var id = 1; id <= 20; id++) _LevelButton(id: id),
                  ],
                ),
                SizedBox(height: space.s32),
                KoButton(
                  label: 'Galeri komponen',
                  kind: KoButtonKind.secondary,
                  onPressed: () => context.go(AppRoutes.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol kecil bernomor ke layar level.
class _LevelButton extends StatelessWidget {
  const _LevelButton({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final s = context.koSize;
    return KoPressable(
      onPressed: () => context.go(AppRoutes.level(id)),
      semanticLabel: 'Level $id',
      color: c.surface,
      edgeColor: c.lineDeep,
      depth: context.koShadow.pressIcon,
      borderColor: c.line,
      borderWidth: s.border,
      radius: context.koRadius.icon,
      width: s.iconButton,
      height: s.iconButton,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('$id', style: context.koType.chip),
        ),
      ),
    );
  }
}
