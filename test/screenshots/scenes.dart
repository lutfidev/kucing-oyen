import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/kucing_game.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Menaruh benda (awalan nama slot baki, kolom, baris) lewat seretan.
Future<void> placeItems(
  WidgetTester tester,
  List<(String, int, int)> items,
) async {
  final board = tester.getRect(find.byType(GameWidget<KucingGame>));
  final scale = board.width / 350;
  for (final (slotName, col, row) in items) {
    final slot = find.byWidgetPredicate(
      (w) => w is TraySlot && w.semanticLabel.startsWith(slotName),
    );
    final target = board.topLeft + Offset(col * 50 + 25, row * 50 + 25) * scale;
    final gesture = await tester.startGesture(tester.getCenter(slot));
    await tester.pump();
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }
}

/// Membangunkan Oyen, memutar sampai selesai, lalu membuka layar hasil dan
/// menunggu bintang dan Ibu selesai muncul. Sinar dan "PRANG!" bergerak
/// terus, jadi tanpa `pumpAndSettle`. Tombol dicari dengan teks [l]
/// (default Indonesia).
Future<void> showResult(WidgetTester tester, [AppLocalizations? l]) async {
  l ??= l10nId;
  await tester.tap(find.text(l.wakeOyen));
  await tester.pump();
  await tester.pumpAndSettle();
  await tester.tap(find.text(l.seeResult));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
