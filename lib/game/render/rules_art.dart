import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart' show Curves;

import '../model/rules.dart';
import 'design_svg.dart';
import 'svg_template.dart';

/// Ukuran dan gerak gambar kartu aturan (`05-kartu-aturan-oyen.html`) dan
/// tangan penunjuk tutorial (`11-tutorial-level-1.html`).
abstract final class RuleArt {
  /// Gambar kartu aturan, viewBox 76×76.
  static const double size = 76;

  /// Kucing kartu 4 berputar seperempat putaran (`koQuarter`, 2,4 detik):
  /// diam sampai 30%, berputar sampai 60% (`ease-in-out`), lalu diam.
  static const quarterTime = Duration(milliseconds: 2400);

  /// Sudut kucing kartu 4 (derajat) di bagian [t] 0–1 dari [quarterTime].
  static double quarterAngle(double t) {
    final turn = ((t - 0.3) / 0.3).clamp(0.0, 1.0);
    return 90 * Curves.easeInOut.transform(turn);
  }

  /// Tangan penunjuk 52×64, diputar 180°. Ujung jarinya di [handTip]
  /// sesudah diputar, dan tangan turun-naik [handBob] tiap [handBobTime]
  /// (`koTap`, `ease-in-out`).
  static const hand = Size(52, 64);
  static const handTip = Offset(32, 62);
  static const double handBob = 10;
  static const handBobTime = Duration(seconds: 1);

  /// Geser turun tangan (px) di bagian [t] 0–1 dari [handBobTime].
  static double handOffset(double t) {
    final half = t < 0.5 ? t * 2 : (1 - t) * 2;
    return handBob * Curves.easeInOut.transform(half);
  }

  /// Cincin di sekeliling sorotan tutorial melebar dari 0 ke [ringSpread]
  /// sambil memudar tiap [ringTime] (`koRing`, `ease-out`).
  static const double ringSpread = 16;
  static const ringTime = Duration(milliseconds: 1400);
}

final _unlocked = {
  OyenRule.knock: SvgTemplate(ruleKnockSvg).render(const {}),
  OyenRule.fish: SvgTemplate(ruleFishSvg).render(const {}),
  OyenRule.water: SvgTemplate(ruleWaterSvg).render(const {}),
  OyenRule.wall: SvgTemplate(ruleWallSvg).render(const {}),
  OyenRule.box: SvgTemplate(ruleBoxSvg).render(const {}),
};

final _locked = {
  OyenRule.knock: SvgTemplate(ruleKnockLockedSvg).render(const {}),
  OyenRule.fish: SvgTemplate(ruleFishLockedSvg).render(const {}),
  OyenRule.water: SvgTemplate(ruleWaterLockedSvg).render(const {}),
  OyenRule.wall: SvgTemplate(ruleWallLockedSvg).render(const {}),
  OyenRule.box: SvgTemplate(ruleBoxLockedSvg).render(const {}),
};

final _wallCat = SvgTemplate(ruleWallCatSvg).render(const {});

/// Titik putar kucing kartu 4: tengah kotak gambarnya (`transform-box:
/// fill-box`), termasuk garis bantu `M24 37 L54 37` di desain.
final _wallCatPivot = _wallCat.bounds.center;

/// Gambar kartu aturan [rule] di kotak [RuleArt.size]. Kartu yang belum
/// [learned] pudar dengan gembok. Kucing kartu 4 diputar [catAngle]
/// derajat.
void paintRuleArt(
  Canvas canvas,
  OyenRule rule, {
  required bool learned,
  double catAngle = 0,
}) {
  if (!learned) return _locked[rule]!.paint(canvas);
  _unlocked[rule]!.paint(canvas);
  if (rule != OyenRule.wall) return;
  final pivot = _wallCatPivot;
  canvas
    ..save()
    ..translate(pivot.dx, pivot.dy)
    ..rotate(catAngle * math.pi / 180)
    ..translate(-pivot.dx, -pivot.dy);
  _wallCat.paint(canvas);
  canvas.restore();
}

final _hand = SvgTemplate(tutorialHandSvg).render(const {});

/// Tangan penunjuk di kotak [RuleArt.hand], sudah diputar 180°.
void paintTutorialHand(Canvas canvas) {
  const size = RuleArt.hand;
  canvas
    ..save()
    ..translate(size.width, size.height)
    ..rotate(math.pi);
  _hand.paint(canvas);
  canvas.restore();
}
