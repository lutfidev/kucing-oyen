import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('"Ginger" kecil di atas "Logic" besar oranye', (tester) async {
    await pumpThemed(tester, const GameLogo());
    final theme = KoTheme.light();
    final c = theme.extension<KoColors>()!;
    final t = theme.extension<KoType>()!;
    final ginger = tester.widget<Text>(find.text('Ginger'));
    final logic = tester.widget<Text>(find.text('Logic'));
    expect(ginger.style!.fontSize, t.logoSmall.fontSize);
    expect(logic.style!.fontSize, t.logo.fontSize);
    expect(logic.style!.color, c.logo);
    expect(
      tester.getTopLeft(find.text('Ginger')).dy,
      lessThan(tester.getTopLeft(find.text('Logic')).dy),
    );
  });

  testWidgets('dibaca pembaca layar sebagai satu judul', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(tester, const GameLogo());
    expect(
      tester.getSemantics(find.byType(GameLogo)),
      matchesSemantics(label: 'Ginger Logic', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('inline: satu baris "Ginger Logic" untuk header kamar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpThemed(tester, const GameLogo(inline: true));
    final t = KoTheme.light().extension<KoType>()!;
    expect(find.text('Ginger Logic', findRichText: true), findsOneWidget);
    expect(
      tester.widget<Text>(find.byType(Text)).style!.fontSize,
      t.logoRow.fontSize,
    );
    expect(
      tester.getSemantics(find.byType(GameLogo)),
      matchesSemantics(label: 'Ginger Logic', isHeader: true),
    );
    semantics.dispose();
  });
}
