import 'package:flutter/widgets.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';

/// Logo "Ginger Logic" (Beranda desain 01, splash, gambar toko): "Ginger"
/// kecil di atas "Logic" besar oranye. Merek sama di semua bahasa; pembaca
/// layar membacanya sebagai satu judul. [inline] = satu baris kecil
/// "Ginger Logic" di header kamar (desain 19).
class GameLogo extends StatelessWidget {
  const GameLogo({super.key, this.inline = false});

  final bool inline;

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return Semantics(
      header: true,
      label: appName,
      child: ExcludeSemantics(
        child: inline
            ? Text.rich(
                TextSpan(
                  text: 'Ginger ',
                  children: [
                    TextSpan(
                      text: 'Logic',
                      style: TextStyle(color: c.orangeDeep),
                    ),
                  ],
                ),
                maxLines: 1,
                style: t.logoRow.copyWith(color: c.ink),
              )
            : Column(
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
