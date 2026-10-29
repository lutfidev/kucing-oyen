import 'dart:ui';

import '../sim/direction.dart';
import 'design_svg.dart';
import 'oyen.dart';
import 'svg_template.dart';

final _template = SvgTemplate(oyenSvg);
final _cache = <OyenLook, SvgDrawing>{};
final _fishBubble = SvgTemplate(fishBubbleSvg).render(const {});

/// Port `renderVals()` di `Oyen.dc.html` (tanpa `label` dan `size`, yang
/// dipakai elemen `<svg>` luar).
Map<String, Object> oyenVals(OyenLook look) {
  final pose = look.pose;
  final dir = look.dir;
  final isSleep = pose == OyenPose.sleep;
  final isBox = pose == OyenPose.box;
  final isNormal = !isSleep && !isBox;
  final back = dir == Direction.up && isNormal;
  final front = !back;
  final side = (dir == Direction.left || dir == Direction.right) && !isSleep;
  var ty = 0;
  if (pose == OyenPose.shock) ty = -3;
  if (pose == OyenPose.eat) ty = 9;
  if (isBox) ty = 8;
  final tx = side ? -5 : 0;
  final walk = pose == OyenPose.walk;
  final happy = pose == OyenPose.happy;
  final shock = pose == OyenPose.shock;
  final eat = pose == OyenPose.eat;
  return {
    'flipT': dir == Direction.right
        ? 'translate(100 0) scale(-1 1)'
        : 'translate(0 0)',
    'headT': 'translate($tx $ty)',
    'faceT': side ? 'translate(-4 1)' : 'translate(0 0)',
    'isSleep': isSleep,
    'isBox': isBox,
    'isNormal': isNormal,
    'notSleep': !isSleep,
    'front': front,
    'back': back,
    'isKnock': pose == OyenPose.knock,
    'isShock': shock,
    'isEat': eat,
    'isHappy': happy,
    'showTailSide': isNormal && !back,
    'showTailBack': back,
    'tailD': happy ? 'M73 72 C88 66 92 44 84 28' : 'M73 77 C94 79 98 58 86 45',
    'tailTipD': happy
        ? 'M85 31 C84.5 29.5 84.2 28.6 84 28'
        : 'M87.5 47 C87 46.2 86.5 45.6 86 45',
    'bodyY': shock ? 69 : 71,
    'bellyY': shock ? 75 : 77,
    'pawL': walk ? 85 : 88,
    'pawR': walk ? 91 : 88,
    'eyeSleepy': !(shock || happy || eat || isSleep),
    'eyeWide': shock,
    'eyeClosed': false,
    'eyeHappy': happy || eat,
    'mouthW': !(shock || happy || eat),
    'mouthO': shock,
    'mouthOpen': happy || eat,
    // Kostum di `Oyen.dc.html` tidak dipakai lagi (Lemari Kostum dihapus
    // di langkah 23; kucing kamar memakai aksesoris).
    'showPeci': false,
    'showKoki': false,
    'showGlasses': false,
    'showSarung': false,
    'showZzz': look.bubble == OyenBubble.zzz,
    'showKaget': look.bubble == OyenBubble.kaget,
    'zzzT': isSleep ? 'translate(-26 16)' : 'translate(0 0)',
  };
}

/// Menggambar Oyen seukuran [size] px di pojok kiri atas kanvas. Gelembung
/// dan topi koki boleh keluar dari kotak itu, seperti `overflow: visible`
/// di desain.
void paintOyen(Canvas canvas, OyenLook look, {double size = OyenLook.viewBox}) {
  final plain = look.copyWith(mirror: false);
  final drawing = _cache.putIfAbsent(
    plain,
    () => _template.render(oyenVals(plain)),
  );
  canvas.save();
  if (look.mirror) {
    canvas
      ..translate(size, 0)
      ..scale(-1, 1);
  }
  canvas.scale(size / OyenLook.viewBox);
  drawing.paint(canvas);
  if (look.bubble == OyenBubble.ikan) _fishBubble.paint(canvas);
  canvas.restore();
}
