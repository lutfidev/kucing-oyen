import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/reward_turn.dart';

void main() {
  test('kucing pertama menurut urutan KittyId, sisanya dihitung', () {
    final ready = {KittyId.salju, KittyId.arang, KittyId.mochi};
    final turn = rewardTurn([
      KittyId.mochi,
      KittyId.oyen,
      KittyId.salju,
      KittyId.arang,
    ], ready.contains);
    expect(turn.kitty, KittyId.salju);
    expect(turn.more, 2);
  });

  test('tanpa kucing yang siap: null dan 0', () {
    expect(rewardTurn([KittyId.oyen, KittyId.salju], (_) => false), (
      kitty: null,
      more: 0,
    ));
    expect(rewardTurn(const [], (_) => true), (kitty: null, more: 0));
  });

  test('satu kucing siap: tanpa sisa', () {
    expect(
      rewardTurn([KittyId.salju, KittyId.oyen], (k) => k == KittyId.oyen),
      (kitty: KittyId.oyen, more: 0),
    );
  });
}
