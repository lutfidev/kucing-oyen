import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/ad_ids.dart';

void main() {
  final unitPattern = RegExp(r'^ca-app-pub-\d+/\d+$');

  test('debug dan profile selalu memakai ID uji Google', () {
    for (final placement in AdPlacement.values) {
      expect(rewardedUnitFor(placement, release: false), testRewardedUnit);
    }
  });

  test('release memakai ID tempelan per tempat', () {
    expect(rewardedUnitFor(AdPlacement.hint, release: true), hintRewardedUnit);
    expect(rewardedUnitFor(AdPlacement.coin, release: true), coinRewardedUnit);
  });

  test('semua ID berbentuk ID unit AdMob', () {
    for (final id in [testRewardedUnit, hintRewardedUnit, coinRewardedUnit]) {
      expect(id, matches(unitPattern));
    }
  });

  test('releaseUsesTestAds sesuai isi tempelan', () {
    expect(
      releaseUsesTestAds,
      hintRewardedUnit == testRewardedUnit ||
          coinRewardedUnit == testRewardedUnit,
    );
  });
}
