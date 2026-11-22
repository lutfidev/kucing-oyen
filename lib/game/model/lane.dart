import 'house.dart';
import 'room_life.dart';

/// Geometri Gang Depan (catatan kanvas `kGang` dan `kTempat`). Gang memakai
/// titik hilang dan trapesium tanah yang sama dengan rumah, jadi titik di
/// bawah ini titik kaki desain 390×652 dan skalanya [laneScale].

/// Skala kucing di gang menurut y kaki: sama dengan rumah ([depthScale])
/// di trapesium tanah, dan mengecil ke titik hilang di belakangnya
/// (jalur Kumis ke ujung gang): `0,75 × (y − 230) / 162`.
double laneScale(double feetY) => feetY >= houseDepthBack
    ? depthScale(feetY)
    : (0.75 * (feetY - 230) / (houseDepthBack - 230)).clamp(0.0, 0.75);

/// Tempat duduk di bangku: kiri, kanan, dan tengah (pertemuan pertama).
/// Kucing di bangku diskalakan seperti kaki di y [laneBenchScaleY].
const laneBenchLeft = (x: 133.2, y: 396.5);
const laneBenchRight = (x: 198.3, y: 396.5);
const laneBenchMiddle = (x: 165.7, y: 396.5);
const laneBenchScaleY = 455.0;

/// Titik lompat dari tanah ke bangku, dan lama lengkungnya (detik).
const laneHopFrom = (x: 124.2, y: 487.8);
const laneHopSeconds = 0.42;

/// Depan pintu pulang: Oyen berdiri di sini sebelum masuk pintu kucing.
const laneThreshold = (x: 300.0, y: 470.0);

/// Tempat nyaman gang selain bangku: dua teduh pohon, piring air (minum
/// dengan pose makan tanpa mangkuk), tangga warung (skala dari y 404), dan
/// depan pintu pulang.
const lanePlaces = <LifePlace>[
  LifePlace(88, 584, pose: LifePose.lounge, heading: LifeHeading.right),
  LifePlace(170, 574, pose: LifePose.lounge, heading: LifeHeading.left),
  LifePlace(51, 481, pose: LifePose.eat, seconds: lifeEatSeconds * 2),
  LifePlace(85.7, 390.1, pose: LifePose.idle, heading: LifeHeading.right),
  LifePlace(300, 470, pose: LifePose.idle, seconds: lifeIdleSeconds * 2),
];

/// Kaki di tangga warung diskalakan seperti y ini (`kGang`).
const laneStepScaleY = 404.0;

/// Jalur Kumis datang dari ujung gang ke depan bangku, dan pergi kembali.
const kumisArrivePath = [
  (x: 226.0, y: 292.0),
  (x: 205.0, y: 394.0),
  (x: 176.0, y: 470.0),
];
const kumisLeavePath = [
  (x: 190.0, y: 470.0),
  (x: 210.0, y: 394.0),
  (x: 232.0, y: 330.0),
  (x: 226.0, y: 292.0),
];
