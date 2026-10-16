import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Beranda sementara sampai langkah 9 roadmap: judul dan jalan ke galeri.
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
