import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('tanpa onPressed: hanya saldo, tidak bisa ditekan', (
    tester,
  ) async {
    await pumpThemed(tester, const KoCoinChip(coins: 120));
    expect(find.bySemanticsLabel('120 koin'), findsOneWidget);
    expect(find.byType(KoPressable), findsNothing);
    expect(find.byKey(const ValueKey('coin-plus')), findsNothing);
  });

  testWidgets('tinggi dan garis per gaya', (tester) async {
    final shadow = KoTheme.light().extension<KoShadow>()!.coinChip;
    await pumpThemed(tester, const KoCoinChip(coins: 1));
    final chip = find.byType(KoCoinChip);
    expect(tester.getSize(chip).height, 40);
    expect(decorationOf(tester, chip).boxShadow, shadow);

    await pumpThemed(
      tester,
      const KoCoinChip(coins: 1, style: KoCoinChipStyle.outlined),
    );
    expect(tester.getSize(chip).height, 40);
    expect(decorationOf(tester, chip).border, isNotNull);
    expect(decorationOf(tester, chip).boxShadow, isNull);

    await pumpThemed(
      tester,
      const KoCoinChip(coins: 1, style: KoCoinChipStyle.compact),
    );
    expect(tester.getSize(chip).height, 36);
  });

  testWidgets('dengan onPressed: tombol "tambah koin" dengan +', (
    tester,
  ) async {
    var taps = 0;
    await pumpThemed(tester, KoCoinChip(coins: 120, onPressed: () => taps++));
    expect(find.byKey(const ValueKey('coin-plus')), findsOneWidget);
    final button = find.bySemanticsLabel('120 koin, tambah koin');
    expect(button, findsOneWidget);
    expect(
      tester.getSemantics(button),
      matchesSemantics(
        label: '120 koin, tambah koin',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(KoCoinChip));
    expect(taps, 1);
  });

  testWidgets('raised yang bisa ditekan tetap berbayangan seperti desain', (
    tester,
  ) async {
    final c = KoTheme.light().extension<KoColors>()!;
    await pumpThemed(tester, KoCoinChip(coins: 1, onPressed: () {}));
    final shadows = decorationOf(tester, find.byType(KoCoinChip)).boxShadow!;
    expect(shadows.first.color, c.line);
    expect(shadows.first.offset, const Offset(0, 2));
    expect(shadows, hasLength(2));
  });

  testWidgets('badge: titik dan label bonus harian', (tester) async {
    await pumpThemed(
      tester,
      KoCoinChip(coins: 120, onPressed: () {}, badge: true),
    );
    expect(find.byKey(const ValueKey('coin-badge')), findsOneWidget);
    expect(
      find.bySemanticsLabel('120 koin, tambah koin, bonus harian siap'),
      findsOneWidget,
    );
  });
}
