import 'dart:ui';

import '../model/accessories.dart';
import 'css_animation.dart';
import 'design_svg_home.dart';
import 'kitty.dart';
import 'svg_template.dart';

final _template = SvgTemplate(
  kittySvg,
  keyframes: CssKeyframes.parse(kittyKeyframes),
);
final _cache = <KittyLook, SvgDrawing>{};
// Batasi varian (pose, arah, corak, aksesoris), bukan waktu. Permainan
// panjang atau berganti aksesoris tidak menimbun bingkai animasi.
final _animated = <KittyLook, SvgAnimation>{};
const _maxAnimatedVariants = 96;

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

/// Ekor pendek bengkok (Kumis, `tailsPendek` di `Kucing.dc.html` Gang
/// Depan) untuk tiap jalur ekor biasa: (badan, ujung, titik putar).
const _shortTails = <(String, String), (String, String, String)>{
  _tailBase: (
    'M73 78 C84 80 89.5 72 87.5 64',
    'M87.5 64 C86.8 60.6 84.4 58.8 80.8 58.6',
    '73px 78px',
  ),
  _tailUp: (
    'M73 73 C82 71 85.5 61 83.5 53',
    'M83.5 53 C82.8 49.6 80.4 47.8 76.8 47.6',
    '73px 73px',
  ),
  _tailPlay: (
    'M73 75 C84 74 89 65 87 57',
    'M87 57 C86.3 53.6 83.9 51.8 80.3 51.6',
    '73px 75px',
  ),
  _tailWalk2: (
    'M73 78 C85 77 90.5 69 89 61.5',
    'M89 61.5 C88.3 58.1 85.9 56.3 82.3 56.1',
    '73px 78px',
  ),
  _tailScratch: (
    'M32 86 C20 88 13 81 15 73',
    'M15 73 C15.7 69.6 18.1 67.8 21.7 67.6',
    '32px 86px',
  ),
  _tailLie: (
    'M92 88 C99 89 101 94 96.5 97',
    'M96.5 97 C94.4 98.6 91.6 98.6 89.4 97.4',
    '92px 88px',
  ),
};

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
  final geser1 = pose == KittyPose.geser1;
  final geser2 = pose == KittyPose.geser2;
  final geser = geser1 || geser2;
  final endus = pose == KittyPose.endus;
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
    KittyPose.endus => 'translate(${tx - 7} 6) rotate(-9 50 62)',
    KittyPose.geser1 => 'translate($tx -0.5)',
    KittyPose.geser2 => 'translate(${tx - 1} 0.5)',
  };
  final tail = switch (pose) {
    KittyPose.happy || KittyPose.petted => _tailUp,
    KittyPose.play => _tailPlay,
    KittyPose.walk2 => _tailWalk2,
    KittyPose.scratch => _tailScratch,
    KittyPose.lesu || KittyPose.rebah => _tailLie,
    _ => _tailBase,
  };
  // Tetangga tidak memakai aksesoris Toko (`noAcc` desain).
  final accessory = c.noAcc ? null : look.accessory;
  final a = {for (final id in _headGroup) id.name: accessory == id};
  // Gaya animasi desain (`A()` di `Kucing.dc.html`); kosong = diam.
  final anim = look.time != null;
  String A(String style) => anim ? style : '';
  final (tailD, tailTipD, tailOrigin) = c.shortTail
      ? _shortTails[tail]!
      : (
          tail.$1,
          tail.$2,
          switch (tail) {
            _ when identical(tail, _tailUp) => '73px 72px',
            _ when identical(tail, _tailPlay) => '73px 74px',
            _ when identical(tail, _tailScratch) => '32px 86px',
            _ when identical(tail, _tailLie) => '92px 88px',
            _ => '73px 77px',
          },
        );
  final tailAnim = switch (pose) {
    KittyPose.happy ||
    KittyPose.petted ||
    KittyPose.play => 'kcWag 0.9s ease-in-out infinite',
    _ when walking || geser => 'kcTail 0.9s ease-in-out infinite',
    KittyPose.rebah => 'kcTail 3.4s ease-in-out infinite',
    KittyPose.lesu => 'none',
    _ => 'kcTail 2.6s ease-in-out infinite',
  };
  final eyeOpen = pose == KittyPose.idle || walking || geser || play || isRebah;
  final dl = c.delay;
  final headAnim = endus
      ? A('animation: kcSniff 0.42s ease-in-out infinite alternate')
      : pose == KittyPose.eat
      ? A('animation: kcNom 0.45s ease-in-out infinite alternate')
      : petted
      ? A(
          'transform-origin: 50px 64px; '
          'animation: kcNuzzle 0.9s ease-in-out infinite alternate',
        )
      : '';
  final sleepAnim = A(
    'transform-origin: 52px 88px; '
    'animation: kcBreathe 3.2s ease-in-out infinite; animation-delay: ${dl}s',
  );
  const twinkle =
      'transform-box: fill-box; transform-origin: center; '
      'animation: kcTwinkle 1.2s ease-in-out infinite';
  // Telinga kanan sompek Kumis, saat duduk dan saat tidur.
  const earSleepR = 'M43 44 L52 31 L56 48 Z';
  const earSleepRNotch = 'M43 44 L48.6 34.6 L51 36.4 L52.4 32.6 L56 48 Z';
  final sleepEarR = c.notch ? earSleepRNotch : earSleepR;
  return {
    'c': {
      'fur': c.fur,
      'head': c.head,
      'stripe': c.stripe,
      'stripes': c.stripes,
      'tailBand': c.tailBand,
      'kumisOn': c.kumisOn,
      'scarfOn': c.scarfOn,
      'brow': c.brow,
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
    'flipT': (look.facing == KittyFacing.right) != look.mirror
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
    'tailD': tailD,
    'tailTipD': tailTipD,
    'leanT': geser1
        ? 'rotate(-6 50 92) translate(-1.5 0)'
        : geser2
        ? 'rotate(-7.5 50 92) translate(-4 0)'
        : 'translate(0 0)',
    'earRD': c.notch
        ? 'M79 38 L78 17.2 L75.2 18.8 L72.6 14.8 L55 25 Z'
        : 'M79 38 L77 11 L55 25 Z',
    'sleepEarRD': sleepEarR,
    'sleepEarsD': 'M14 52 L13 33 L29 43 Z $sleepEarR',
    'sleepTailD': c.shortTail
        ? 'M92 62 C98 78 88 90 72 91'
        : 'M92 62 C98 86 62 96 26 88',
    'sleepTipD': c.shortTail
        ? 'M72 91 C68.6 91.2 66.2 89.4 65.6 85.8'
        : 'M30 89 C28 88.5 27 88.3 26 88',
    'pawLX': geser1 ? 35 : (geser2 ? 38 : 39),
    'pawRX': geser2 ? 57 : 61,
    'showBowl': pose == KittyPose.eat && look.bowl,
    'showPost': isScratch && look.post,
    'pawL': walk1 || geser1 ? 84 : (walk2 || geser2 ? 91 : 88),
    'pawR': walk1 || geser1 ? 91 : (walk2 || geser2 ? 84 : 88),
    'pawLOn': isSit && pose != KittyPose.lick,
    'pawROn': isSit && !play,
    'isLick': pose == KittyPose.lick,
    'isPlay': play,
    'isEat': pose == KittyPose.eat,
    'isHappy': happy,
    'isPetted': petted,
    'toyBall': look.toy == KittyToy.ball,
    'toyMouse': look.toy == KittyToy.mouse,
    'eyeSleepy': pose == KittyPose.idle || walking || geser || endus || isRebah,
    'eyeWide': play,
    'eyeClosed': pose == KittyPose.lick || petted || isScratch,
    'eyeHappy': happy || pose == KittyPose.eat,
    'eyeSad': isLesu,
    'mouthW':
        pose == KittyPose.idle ||
        walking ||
        geser ||
        endus ||
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
    'noteOn': anim && !isSleep,
    'tailStyle': A('transform-origin: $tailOrigin; animation: $tailAnim'),
    'headAnim': headAnim,
    'sleepAnim': sleepAnim,
    'accAnim': isSleep ? sleepAnim : headAnim,
    'syalAnim': walking || geser
        ? A(
            'transform-origin: 64px 69px; '
            'animation: kcSway 0.44s ease-in-out infinite alternate',
          )
        : A(
            'transform-origin: 64px 69px; '
            'animation: kcSwaySoft 2.6s ease-in-out infinite alternate',
          ),
    'noteAnim': A('animation: kcFloat 2.2s ease-out infinite'),
    'crownTw': A(twinkle),
    'blinkStyle': eyeOpen
        ? A(
            'transform-box: fill-box; transform-origin: center; '
            'animation: kcBlink 4.6s infinite; animation-delay: ${dl}s',
          )
        : '',
    'zzzAnim': A('animation: kcZzz 2.4s ease-out infinite'),
    'tapAnim': A('animation: kcTap 0.5s ease-in-out infinite alternate'),
    'ballAnim': A(
      'transform-box: fill-box; transform-origin: center; '
      'animation: kcRoll 1s ease-in-out infinite',
    ),
    'scratchA': A('animation: kcScratch 0.35s ease-in-out infinite alternate'),
    'scratchB': A(
      'animation: kcScratch 0.35s ease-in-out infinite alternate; '
      'animation-delay: -0.17s',
    ),
    'lickAnim': A('animation: kcLick 0.6s ease-in-out infinite alternate'),
    'tw1': A(twinkle),
    'tw2': A('$twinkle; animation-delay: -0.4s'),
    'tw3': A('$twinkle; animation-delay: -0.8s'),
    'heartAnim': A('animation: kcFloat 1.6s ease-out infinite'),
    'heartAnim2': A(
      'animation: kcFloat 1.6s ease-out infinite; animation-delay: -0.8s',
    ),
  };
}

/// Gambar [look] di koordinat sprite desain (100×100). Sprite diam
/// ([KittyLook.time] null) disimpan di cache; yang bergerak digambar ulang
/// pada waktu yang tepat memakai varian SVG yang sudah diikat.
SvgDrawing kittyDrawing(KittyLook look) {
  final time = look.time;
  if (time == null) {
    return _cache.putIfAbsent(look, () => _template.render(kittyVals(look)));
  }
  final key = look.copyWith(time: 0);
  var bound = _animated.remove(key);
  if (bound == null) {
    bound = _template.bind(kittyVals(key));
    if (_animated.length >= _maxAnimatedVariants) {
      _animated.remove(_animated.keys.first);
    }
  }
  _animated[key] = bound;
  return bound.render(time: time);
}

/// Menggambar kucing kamar seukuran [size] px di pojok kiri atas kanvas.
/// Topi, mainan, dan gelembung boleh keluar dari kotak itu, seperti
/// `overflow: visible` di desain.
void paintKitty(
  Canvas canvas,
  KittyLook look, {
  double size = KittyLook.viewBox,
}) {
  final drawing = kittyDrawing(look);
  canvas.save();
  canvas.scale(size / KittyLook.viewBox);
  drawing.paint(canvas);
  canvas.restore();
}
