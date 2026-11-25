import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/screens/room/room_parts.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pumpBubble(
    WidgetTester tester, {
    required bool left,
    required VoidCallback onTap,
  }) => tester.pumpWidget(
    testApp(
      home: Center(
        child: CoinBubbleView(
          coins: 10,
          label: 'hadiah',
          more: '+2 lagi',
          moreOnLeft: left,
          onTap: onTap,
        ),
      ),
    ),
  );

  for (final left in [false, true]) {
    testWidgets('chip "+N lagi" di ${left ? 'kiri' : 'kanan'} gelembung, '
        'sejajar label, bisa diketuk', (tester) async {
      var taps = 0;
      await pumpBubble(tester, left: left, onTap: () => taps++);
      final coin = tester.getRect(find.text('+10'));
      final chip = tester.getRect(find.text('+2 lagi'));
      expect(chip.center.dy, moreOrLessEquals(coin.center.dy));
      if (left) {
        expect(chip.right, lessThan(coin.left));
      } else {
        expect(chip.left, greaterThan(coin.right));
      }
      await tester.tap(find.text('+2 lagi'));
      expect(taps, 1);
    });
  }

  test('KeepInside fromRight: at = pojok kanan atas, tetap dijepit', () {
    const child = Size(100, 40);
    const size = Size(400, 800);
    expect(
      const KeepInside(
        Offset(300, 50),
        fromRight: true,
      ).getPositionForChild(size, child),
      const Offset(200, 50),
    );
    expect(
      const KeepInside(
        Offset(60, 50),
        margin: 8,
        fromRight: true,
      ).getPositionForChild(size, child),
      const Offset(8, 50),
    );
  });
}
