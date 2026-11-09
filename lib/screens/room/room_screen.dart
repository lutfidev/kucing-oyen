import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../app/progress_scope.dart';
import 'home_view.dart';

/// Beranda v2 (rute `/`): satu area rumah yang dipilih pemain.
class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key, this.random, this.life = true});

  /// Pengacak posisi kucing; null = acak sungguhan.
  final Random? random;

  /// Kucing bergerak sendiri (rutinitas dan animasi).
  final bool life;

  @override
  Widget build(BuildContext context) =>
      HomeView(progress: ProgressScope.of(context), life: life);
}
