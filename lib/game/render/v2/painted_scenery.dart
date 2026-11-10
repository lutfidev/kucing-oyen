import 'package:flutter/painting.dart';

/// One versioned backdrop, shared by Flutter's bounded image cache. Decode
/// size is fixed instead of increasing with device pixel ratio or frame count.
abstract final class PaintedScenery {
  static const loungeAsset = 'assets/art/v2/scenes/santai-painted-v1.webp';
  static const diningAsset = 'assets/art/v2/scenes/makan-painted-v1.webp';
  static const careAsset = 'assets/art/v2/scenes/rawat-painted-v1.webp';
  static const ImageProvider care = ResizeImage(
    AssetImage(careAsset),
    width: decodeWidth,
  );
  static const playAsset = 'assets/art/v2/scenes/main-painted-v1.webp';
  static const ImageProvider play = ResizeImage(
    AssetImage(playAsset),
    width: decodeWidth,
  );
  static const decodeWidth = 1024;
  static const ImageProvider lounge = ResizeImage(
    AssetImage(loungeAsset),
    width: decodeWidth,
  );
  static const ImageProvider dining = ResizeImage(
    AssetImage(diningAsset),
    width: decodeWidth,
  );
}
