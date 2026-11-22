import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/house.dart';
import 'package:kucing_oren/game/model/lane.dart';

void main() {
  test('skala gang: sama dengan rumah di tanah, mengecil di belakangnya', () {
    expect(laneScale(392), closeTo(0.75, 1e-9));
    expect(laneScale(455), closeTo(depthScale(455), 1e-9));
    expect(laneScale(455), closeTo(0.847, 0.001));
    expect(laneScale(292), closeTo(0.287, 0.001));
    expect(laneScale(230), closeTo(0, 1e-9));
  });

  test('tempat di gang (kGang, kTempat)', () {
    expect(laneBenchLeft, (x: 133.2, y: 396.5));
    expect(laneBenchRight, (x: 198.3, y: 396.5));
    expect(laneBenchMiddle, (x: 165.7, y: 396.5));
    expect(laneBenchScaleY, 455);
    expect(laneHopFrom, (x: 124.2, y: 487.8));
    expect(laneHopSeconds, 0.42);
    expect(laneThreshold, (x: 300.0, y: 470.0));
    expect(lanePlaces, hasLength(5));
    expect(kumisArrivePath.first, (x: 226.0, y: 292.0));
    expect(kumisArrivePath.last, (x: 176.0, y: 470.0));
    expect(kumisLeavePath.last, (x: 226.0, y: 292.0));
  });
}
