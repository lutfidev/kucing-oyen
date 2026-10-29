import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../app/progress_scope.dart';
import 'room_view.dart';

/// Beranda (rute `/`): kamar Oyen (desain 19).
class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key, this.random});

  /// Pengacak posisi kucing; null = acak sungguhan.
  final Random? random;

  @override
  Widget build(BuildContext context) =>
      RoomView(progress: ProgressScope.of(context), random: random);
}
