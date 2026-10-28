import 'dart:ui';

import '../model/accessories.dart';
import 'design_svg_home.dart';
import 'kitty.dart';
import 'svg_template.dart';

final _template = SvgTemplate(kittySvg);
final _cache = <KittyLook, SvgDrawing>{};

/// Aksesoris yang digambar di dalam grup kepala (grup `a` desain).
const _headGroup = [
  AccessoryId.topiPesta,
  AccessoryId.beanie,
  AccessoryId.pita,
  AccessoryId.kalung,
  AccessoryId.bandana,
  AccessoryId.kacamata,
  AccessoryId.mahkota,
];

/// Aksesoris yang digambar di grup sendiri di atas kepala (grup `b` desain).
const _topGroup = [
  AccessoryId.topiKoki,
  AccessoryId.dasiKupu,
  AccessoryId.syal,
  AccessoryId.baret,
  AccessoryId.jepitBunga,
  AccessoryId.topiPenyihir,
  AccessoryId.headphone,
  AccessoryId.tandukRusa,
  AccessoryId.mahkotaRaja,
];

/// Jalur ekor per pose: (badan, ujung).
const _tailBase = (
  'M73 77 C94 79 98 58 86 45',
  'M87.5 47 C87 46.2 86.5 45.6 86 45',
);
const _tailUp = (
  'M73 72 C88 66 92 44 84 28',
  'M85 31 C84.5 29.5 84.2 28.6 84 28',
);
const _tailPlay = (
  'M73 74 C92 72 98 52 90 38',
  'M91.2 40.5 C90.8 39.5 90.4 38.7 90 38',
);
const _tailWalk2 = (
  'M73 77 C95 75 100 55 89 42',
  'M90.6 44.2 C90 43.2 89.5 42.5 89 42',
);
const _tailScratch = (
  'M32 86 C12 90 4 72 13 58',
  'M14.4 60.4 C13.9 59.5 13.4 58.7 13 58',
);
const _tailLie = (
  'M92 88 C102 90 102 98 90 98',
  'M92 98 C91.2 98 90.6 98 90 98',
);

/// Gaya animasi desain: langkah 22 menggambar sprite diam, jadi semuanya
/// kosong. Langkah 24 menggantinya dengan fungsi `KittyLook.time`.
const _still = '';

List<Map<String, Object>> _patches(List<FurPatch> patches) => [
  for (final p in patches)
    {'cx': p.cx, 'cy': p.cy, 'rx': p.rx, 'ry': p.ry, 'f': p.fill},
];

/// Port `renderVals()` di `Kucing.dc.html` (tanpa `label` dan `size`, yang
/// dipakai elemen `<svg>` luar).
Map<String, Object> kittyVals(KittyLook look) {
  final c = look.colors;
  final pose = look.pose;
  final isSleep = pose == KittyPose.sleep;
  final isLesu = pose == KittyPose.lesu;
  final isRebah = pose == KittyPose.rebah;
  final isLie = isLesu || isRebah;
  final isScratch = pose == KittyPose.scratch;
  final isSit = !isSleep && !isLie && !isScratch;
  final walk1 = pose == KittyPose.walk1;
  final walk2 = pose == KittyPose.walk2;
  final walking = walk1 || walk2;
  final happy = pose == KittyPose.happy;
  final petted = pose == KittyPose.petted;
  final play = pose == KittyPose.play;
  final side =
      (look.facing == KittyFacing.left || look.facing == KittyFacing.right) &&
      isSit;
  final tx = side ? -5 : 0;
  final headT = switch (pose) {
    KittyPose.idle || KittyPose.walk1 => 'translate($tx 0)',
    KittyPose.walk2 => 'translate($tx -1.5)',
    KittyPose.eat => 'translate(0 9)',
    KittyPose.happy || KittyPose.sleep => 'translate(0 0)',
    KittyPose.lick => 'translate(-3 7) rotate(-10 50 50)',
    KittyPose.play => 'translate(3 2) rotate(6 50 50)',
    KittyPose.petted => 'rotate(7 50 60)',
    KittyPose.scratch => 'translate(-12 -14) rotate(-6 50 50)',
    KittyPose.lesu || KittyPose.rebah => 'translate(-8 30)',
  };
  final tail = switch (pose) {
    KittyPose.happy || KittyPose.petted => _tailUp,
    KittyPose.play => _tailPlay,
    KittyPose.walk2 => _tailWalk2,
    KittyPose.scratch => _tailScratch,
    KittyPose.lesu || KittyPose.rebah => _tailLie,
    _ => _tailBase,
  };
  final accessory = look.accessory;
  final a = {for (final id in _headGroup) id.name: accessory == id};
  return {
    'c': {
      'fur': c.fur,
      'head': c.head,
      'stripe': c.stripe,
      'stripes': c.stripes,
      'tail': c.tail,
      'tailTip': c.tailTip,
      'belly': c.belly,
      'muzzle': c.muzzle,
      'earL': c.earL,
      'earR': c.earR,
      'earIn': c.earIn,
      'earTip': c.earTip,
      'earTipOn': c.earTipOn,
      'eye': c.eye,
      'pupil': c.pupil,
      'iris': c.iris,
      'line': c.line,
      'mouth': c.mouth,
      'nose': c.nose,
      'blush': c.blush,
      'whisker': c.whisker,
      'whiskerOp': c.whiskerOp,
      'edge': c.edge,
      'paw': c.paw,
      'leg': c.leg,
      'maskOn': c.maskOn,
      'mask': c.mask,
      'blazeOn': c.blazeOn,
      'pBody': _patches(c.body),
      'pScratch': _patches(c.scratch),
      'pLesu': _patches(c.lie),
      'pHead': _patches(c.headPatches),
      'pSleepBody': _patches(c.sleepBody),
      'pSleepHead': _patches(c.sleepHead),
    },
    'a': a,
    'b': {for (final id in _topGroup) id.name: accessory == id},
    'flipT': look.facing == KittyFacing.right
        ? 'translate(100 0) scale(-1 1)'
        : 'translate(0 0)',
    'headT': headT,
    'faceT': side ? 'translate(-4 1)' : 'translate(0 0)',
    'earLT': isLesu ? 'rotate(-58 30 33)' : 'rotate(0 30 33)',
    'earRT': isLesu ? 'rotate(58 70 33)' : 'rotate(0 70 33)',
    'hasEdge': c.hasEdge,
    'isSit': isSit,
    'isSleep': isSleep,
    'isLie': isLie,
    'isScratch': isScratch,
    'showHead': !isSleep,
    'showTail': !isSleep,
    'tailD': tail.$1,
    'tailTipD': tail.$2,
    'showPost': isScratch && look.post,
    'pawL': walk1 ? 85 : (walk2 ? 91 : 88),
    'pawR': walk1 ? 91 : (walk2 ? 85 : 88),
    'pawLOn': isSit && pose != KittyPose.lick,
    'pawROn': isSit && !play,
    'isLick': pose == KittyPose.lick,
    'isPlay': play,
    'isEat': pose == KittyPose.eat,
    'isHappy': happy,
    'isPetted': petted,
    'toyBall': look.toy == KittyToy.ball,
    'toyMouse': look.toy == KittyToy.mouse,
    'eyeSleepy': pose == KittyPose.idle || walking || isRebah,
    'eyeWide': play,
    'eyeClosed': pose == KittyPose.lick || petted || isScratch,
    'eyeHappy': happy || pose == KittyPose.eat,
    'eyeSad': isLesu,
    'mouthW':
        pose == KittyPose.idle ||
        walking ||
        play ||
        petted ||
        isScratch ||
        isRebah,
    'mouthOpen': happy || pose == KittyPose.eat,
    'mouthTongue': pose == KittyPose.lick,
    'mouthFrown': isLesu,
    'blushOp': petted ? 0.8 : c.blushOp,
    'glassInk': c.line,
    'neckOn': a[AccessoryId.kalung.name]! || a[AccessoryId.bandana.name]!,
    'dangleOn': !isLie,
    'acc2On': accessory != null && _topGroup.contains(accessory),
    'accT': isSleep ? 'translate(-2 30.8) scale(0.72)' : headT,
    'dangle2': !isLie && !isSleep,
    'noteOn': false,
    'tailStyle': _still,
    'headAnim': _still,
    'sleepAnim': _still,
    'accAnim': _still,
    'syalAnim': _still,
    'noteAnim': _still,
    'crownTw': _still,
    'blinkStyle': _still,
    'zzzAnim': _still,
    'tapAnim': _still,
    'ballAnim': _still,
    'scratchA': _still,
    'scratchB': _still,
    'lickAnim': _still,
    'tw1': _still,
    'tw2': _still,
    'tw3': _still,
    'heartAnim': _still,
    'heartAnim2': _still,
  };
}

/// Menggambar kucing kamar seukuran [size] px di pojok kiri atas kanvas.
/// Topi, mainan, dan gelembung boleh keluar dari kotak itu, seperti
/// `overflow: visible` di desain.
void paintKitty(
  Canvas canvas,
  KittyLook look, {
  double size = KittyLook.viewBox,
}) {
  final drawing = _cache.putIfAbsent(
    look,
    () => _template.render(kittyVals(look)),
  );
  canvas.save();
  canvas.scale(size / KittyLook.viewBox);
  drawing.paint(canvas);
  canvas.restore();
}
