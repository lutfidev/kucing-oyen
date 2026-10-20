import 'package:flutter/widgets.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';

/// Logo "Ginger Logic" (Beranda desain 01, splash, gambar toko): "Ginger"
/// kecil di atas "Logic" besar oranye. Merek sama di semua bahasa; pembaca
/// layar membacanya sebagai satu judul.
class GameLogo extends StatelessWidget {
  const GameLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return Semantics(
      header: true,
      label: appName,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ginger', style: t.logoSmall.copyWith(color: c.ink)),
            Text(
              'Logic',
              style: t.logo.copyWith(
                color: c.logo,
                shadows: context.koShadow.logo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
