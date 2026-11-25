import '../model/accessories.dart';
import '../model/kitties.dart';
import '../model/neighbor.dart';

/// Pose sprite kucing kamar (`Kucing.dc.html`). Pose `walk` desain dipilih
/// pemanggil: [walk1] dan [walk2] berganti tiap 220 ms saat jalan; pose
/// `geser` begitu juga dengan [geser1] dan [geser2] ([KittyLook.shiftPose]).
enum KittyPose {
  idle,
  lick,
  walk1,
  walk2,
  sleep,
  eat,
  play,
  scratch,
  happy,
  lesu,
  rebah,
  petted,

  /// Mengendus ke samping (Gang Depan: Oyen dan Kumis di bangku).
  endus,

  /// Bergeser sambil duduk, dua bingkai (Kumis memberi tempat di bangku).
  geser1,
  geser2,

  /// Membaca buku di pangkuan, kacamata baca otomatis (Rak Buku, langkah
  /// 40).
  baca,
}

/// Arah hadap sprite kamar: ke depan, atau ke samping (kanan dicerminkan).
enum KittyFacing { down, left, right }

/// Mainan yang ditepuk di pose [KittyPose.play].
enum KittyToy { ball, mouse, none }

/// Satu corak bulu: elips berwarna di atas badan atau kepala
/// (`c.pBody` dan kawan-kawan di `Kucing.dc.html`).
class FurPatch {
  const FurPatch(this.cx, this.cy, this.rx, this.ry, this.fill);

  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final String fill;
}

/// Palet satu kucing: warna (heksa seperti desain) dan coraknya per pose.
class KittyColors {
  const KittyColors({
    required this.fur,
    required this.head,
    required this.stripe,
    required this.tail,
    required this.tailTip,
    required this.belly,
    required this.muzzle,
    required this.earL,
    required this.earR,
    required this.earIn,
    required this.earTip,
    required this.eye,
    required this.line,
    required this.mouth,
    required this.nose,
    required this.blush,
    required this.blushOp,
    required this.whisker,
    required this.whiskerOp,
    this.earTipOn = false,
    this.pupil = false,
    this.edge = 'none',
    this.stripes = false,
    this.maskOn = false,
    this.mask = 'none',
    this.blazeOn = false,
    this.pawOverride,
    this.legOverride,
    this.body = const [],
    this.scratch = const [],
    this.lie = const [],
    this.headPatches = const [],
    this.sleepBody = const [],
    this.sleepHead = const [],
    this.delay = 0,
    this.brow = 'none',
    this.kumisOn = false,
    this.scarfOn = false,
    this.notch = false,
    this.shortTail = false,
    this.tailBand = false,
    this.noAcc = false,
  });

  final String fur;
  final String head;
  final String stripe;
  final String tail;
  final String tailTip;
  final String belly;
  final String muzzle;
  final String earL;
  final String earR;
  final String earIn;
  final String earTip;
  final bool earTipOn;
  final String eye;
  final bool pupil;
  final String line;
  final String mouth;
  final String nose;
  final String blush;
  final double blushOp;
  final String whisker;
  final double whiskerOp;

  /// Garis tepi kucing berbulu terang; `none` = tanpa tepi.
  final String edge;
  final bool stripes;
  final bool maskOn;
  final String mask;
  final bool blazeOn;

  /// Telapak dan kaki yang ditulis sendiri di palet desain.
  final String? pawOverride;
  final String? legOverride;

  final List<FurPatch> body;
  final List<FurPatch> scratch;
  final List<FurPatch> lie;
  final List<FurPatch> headPatches;
  final List<FurPatch> sleepBody;
  final List<FurPatch> sleepHead;

  /// Jeda awal kedip dan napas (detik, negatif) supaya kucing tidak
  /// berkedip serempak (`delay` palet desain).
  final double delay;

  /// Ciri Kumis (`Kucing.dc.html` Gang Depan): alis abu [brow] dan bercak
  /// "kumis" berwarna [mask] di bawah hidung ([kumisOn]), syal merah-krem
  /// ([scarfOn]), telinga kanan sompek ([notch]), ekor pendek bengkok
  /// ([shortTail]) bergaris [stripe] ([tailBand]), dan tanpa aksesoris
  /// Toko ([noAcc]).
  final String brow;
  final bool kumisOn;
  final bool scarfOn;
  final bool notch;
  final bool shortTail;
  final bool tailBand;
  final bool noAcc;

  /// Telapak mengikuti perut kalau tidak ditulis sendiri (desain).
  String get paw => pawOverride ?? belly;

  /// Kaki mengikuti bulu kalau tidak ditulis sendiri (desain).
  String get leg => legOverride ?? fur;

  /// Warna iris: mata kalau kucingnya bermanik, selain itu warna garis.
  String get iris => pupil ? eye : line;

  bool get hasEdge => edge != 'none';
}

const _orange = '#F29A3A';
const _black = '#2E2929';
const _orangeDeep = '#D97B2E';
const _brown = '#A4562A';

/// Palet kesembilan kucing, disalin dari tabel `P` di `Kucing.dc.html`.
const kittyPalette = <KittyId, KittyColors>{
  KittyId.oyen: KittyColors(
    fur: _orange,
    head: '#F5A447',
    stripe: '#C4651A',
    tail: '#E8892B',
    tailTip: '#C4651A',
    belly: '#FBD9A8',
    muzzle: '#FDE6C4',
    earL: _orange,
    earR: _orange,
    earIn: '#F7B98A',
    earTip: '#F7B98A',
    eye: '#3A2618',
    line: '#3A2618',
    mouth: '#3A2618',
    nose: '#D9606A',
    blush: '#F07F6A',
    blushOp: 0.45,
    whisker: '#3A2618',
    whiskerOp: 0.45,
    stripes: true,
  ),
  KittyId.salju: KittyColors(
    fur: '#FBF8F3',
    head: '#FFFFFF',
    stripe: '#E3D6C6',
    tail: '#F6F2EC',
    tailTip: '#F6F2EC',
    belly: '#FFFFFF',
    muzzle: '#FFFFFF',
    earL: '#FBF8F3',
    earR: '#FBF8F3',
    earIn: '#F6AABA',
    earTip: '#F28CA3',
    earTipOn: true,
    eye: '#4C86C6',
    pupil: true,
    line: '#3A2618',
    mouth: '#3A2618',
    nose: '#F28CA3',
    blush: '#F6A2B2',
    blushOp: 0.5,
    whisker: '#3A2618',
    whiskerOp: 0.35,
    edge: '#E3D6C6',
    delay: -3.1,
  ),
  KittyId.telon: KittyColors(
    fur: '#FFF8EE',
    head: '#FFFBF4',
    stripe: _black,
    tail: _orange,
    tailTip: _black,
    belly: '#FFFFFF',
    muzzle: '#FFFFFF',
    earL: _orange,
    earR: _black,
    earIn: '#F7B9A0',
    earTip: '#F7B9A0',
    eye: '#3A2618',
    line: '#3A2618',
    mouth: '#3A2618',
    nose: '#E07A82',
    blush: '#F49A8A',
    blushOp: 0.45,
    whisker: '#3A2618',
    whiskerOp: 0.4,
    edge: '#E6D3B8',
    body: [FurPatch(64, 67, 9, 7, _orange), FurPatch(31, 73, 5, 6, _black)],
    scratch: [
      FurPatch(56, 60, 7, 8, _orange),
      FurPatch(31, 76, 4.5, 6, _black),
    ],
    lie: [FurPatch(74, 80, 10, 6, _orange), FurPatch(88, 86, 5, 4, _black)],
    headPatches: [
      FurPatch(35, 33, 11, 9, _orange),
      FurPatch(65, 32, 10, 8, _black),
    ],
    sleepBody: [
      FurPatch(70, 50, 12, 8, _orange),
      FurPatch(82, 68, 7, 5, _black),
    ],
    sleepHead: [FurPatch(24, 54, 7, 5.5, _orange)],
    delay: -0.7,
  ),
  KittyId.arang: KittyColors(
    fur: _black,
    head: '#383131',
    stripe: _black,
    tail: '#2A2525',
    tailTip: '#2A2525',
    belly: '#4A4140',
    muzzle: '#524847',
    earL: _black,
    earR: _black,
    earIn: '#7A5A60',
    earTip: '#7A5A60',
    eye: '#F5C431',
    pupil: true,
    line: '#F2E3CC',
    mouth: '#F2E3CC',
    nose: '#D98A96',
    blush: '#E0707A',
    blushOp: 0.35,
    whisker: '#F2E3CC',
    whiskerOp: 0.6,
    delay: -1.3,
  ),
  KittyId.mendung: KittyColors(
    fur: '#8C929A',
    head: '#979DA5',
    stripe: '#585E66',
    tail: '#848A92',
    tailTip: '#585E66',
    belly: '#D7DBE0',
    muzzle: '#ECEEF1',
    earL: '#8C929A',
    earR: '#8C929A',
    earIn: '#E7B5BA',
    earTip: '#E7B5BA',
    eye: '#6A9A52',
    pupil: true,
    line: '#2B2E33',
    mouth: '#2B2E33',
    nose: '#D9707A',
    blush: '#F08A8A',
    blushOp: 0.45,
    whisker: '#2B2E33',
    whiskerOp: 0.45,
    stripes: true,
    delay: -2.4,
  ),
  KittyId.kopiSusu: KittyColors(
    fur: '#C89A6E',
    head: '#D2A57A',
    stripe: '#B5865A',
    tail: '#C29468',
    tailTip: '#A87C52',
    belly: '#F6E6CC',
    muzzle: '#FBEFDC',
    earL: '#C89A6E',
    earR: '#C89A6E',
    earIn: '#EFC1A8',
    earTip: '#EFC1A8',
    eye: '#3A2618',
    line: '#3A2618',
    mouth: '#3A2618',
    nose: '#D9707A',
    blush: '#F08A7A',
    blushOp: 0.45,
    whisker: '#3A2618',
    whiskerOp: 0.45,
    delay: -1.8,
  ),
  KittyId.mochi: KittyColors(
    fur: '#F3E6D2',
    head: '#F6EBDB',
    stripe: '#5C4033',
    tail: '#5C4033',
    tailTip: '#4A3226',
    belly: '#FBF4E8',
    muzzle: '#6E4E3A',
    earL: '#5C4033',
    earR: '#5C4033',
    earIn: '#8A6650',
    earTip: '#8A6650',
    eye: '#5A9BD5',
    pupil: true,
    line: '#3A2618',
    mouth: '#F6EBDB',
    nose: '#3A2618',
    blush: '#D49A8A',
    blushOp: 0.3,
    whisker: '#F6EBDB',
    whiskerOp: 0.7,
    edge: '#E2D2BA',
    pawOverride: '#5C4033',
    legOverride: '#5C4033',
    maskOn: true,
    mask: '#7A5842',
    delay: -0.4,
  ),
  KittyId.bos: KittyColors(
    fur: '#262222',
    head: '#2E2828',
    stripe: '#262222',
    tail: '#262222',
    tailTip: '#FFFFFF',
    belly: '#FFFFFF',
    muzzle: '#FFFFFF',
    earL: '#262222',
    earR: '#262222',
    earIn: '#6B4F55',
    earTip: '#6B4F55',
    eye: '#9FD07A',
    pupil: true,
    line: '#F2E3CC',
    mouth: '#3A2618',
    nose: '#E8919C',
    blush: '#E0707A',
    blushOp: 0.35,
    whisker: '#BFB6AC',
    whiskerOp: 0.8,
    pawOverride: '#FFFFFF',
    blazeOn: true,
    delay: -2.8,
  ),
  KittyId.kembang: KittyColors(
    fur: '#3A2C28',
    head: '#40312C',
    stripe: '#3A2C28',
    tail: '#3A2C28',
    tailTip: _orangeDeep,
    belly: '#5A4038',
    muzzle: '#6B4A3E',
    earL: _orangeDeep,
    earR: '#3A2C28',
    earIn: '#8A5A50',
    earTip: '#8A5A50',
    eye: '#E8B23A',
    pupil: true,
    line: '#F2E3CC',
    mouth: '#F2E3CC',
    nose: '#D98A7A',
    blush: '#E0707A',
    blushOp: 0.3,
    whisker: '#F2E3CC',
    whiskerOp: 0.6,
    body: [
      FurPatch(62, 68, 9, 6, _orangeDeep),
      FurPatch(38, 65, 7, 5, _brown),
      FurPatch(66, 80, 5, 4, _orangeDeep),
      FurPatch(30, 74, 4, 5, _orangeDeep),
    ],
    scratch: [
      FurPatch(56, 60, 7, 8, _orangeDeep),
      FurPatch(34, 72, 4, 5, _brown),
      FurPatch(50, 84, 4, 3, _orangeDeep),
    ],
    lie: [
      FurPatch(74, 80, 10, 6, _orangeDeep),
      FurPatch(50, 82, 6, 4, _brown),
      FurPatch(88, 86, 4, 3, _orangeDeep),
    ],
    headPatches: [
      FurPatch(36, 30, 9, 7, _orangeDeep),
      FurPatch(63, 37, 7, 5, _brown),
      FurPatch(70, 27, 5, 4, _orangeDeep),
      FurPatch(28, 46, 5, 3.5, _orangeDeep),
      FurPatch(56, 24, 4, 3, _brown),
    ],
    sleepBody: [
      FurPatch(70, 50, 12, 8, _orangeDeep),
      FurPatch(82, 68, 7, 5, _brown),
      FurPatch(52, 40, 6, 4, _orangeDeep),
    ],
    sleepHead: [
      FurPatch(24, 54, 7, 5, _orangeDeep),
      FurPatch(42, 58, 5, 4, _brown),
    ],
    delay: -1.0,
  ),
};

const _gray = '#8494A7';
const _grayDeep = '#5E6E82';

/// Palet kucing tetangga, disalin dari `P.kumis` di `Kucing.dc.html` Gang
/// Depan.
const neighborPalette = <Neighbor, KittyColors>{
  Neighbor.kumis: KittyColors(
    fur: '#F7F1E6',
    head: '#FAF5EC',
    stripe: _grayDeep,
    tail: '#93A2B4',
    tailTip: '#55657A',
    belly: '#FFFFFF',
    muzzle: '#FFFFFF',
    earL: '#7F8FA2',
    earR: '#7F8FA2',
    earIn: '#E9BCB4',
    earTip: '#E9BCB4',
    eye: '#C99A2E',
    pupil: true,
    line: '#3A2618',
    mouth: '#3A2618',
    nose: '#C98585',
    blush: '#E9A09A',
    blushOp: 0.3,
    whisker: '#3A2618',
    whiskerOp: 0.5,
    edge: '#E2D7C6',
    delay: -1.6,
    mask: '#6E7E92',
    brow: '#4E5C6E',
    kumisOn: true,
    scarfOn: true,
    notch: true,
    shortTail: true,
    tailBand: true,
    noAcc: true,
    body: [
      FurPatch(28, 66, 6.5, 9.5, _gray),
      FurPatch(72, 66, 6.5, 9.5, _gray),
      FurPatch(50, 55, 17, 5, _gray),
    ],
    scratch: [FurPatch(52, 52, 11, 10, _gray), FurPatch(30, 64, 4, 6, _gray)],
    lie: [FurPatch(66, 77, 23, 6.5, _gray), FurPatch(84, 83, 6, 5, _grayDeep)],
    headPatches: [
      FurPatch(50, 25, 22.5, 11, _gray),
      FurPatch(43, 20.5, 2.2, 4.6, _grayDeep),
      FurPatch(50, 19, 2.2, 5, _grayDeep),
      FurPatch(57, 20.5, 2.2, 4.6, _grayDeep),
    ],
    sleepBody: [
      FurPatch(60, 42, 27, 11, _gray),
      FurPatch(81, 53, 9, 10, _gray),
      FurPatch(56, 38, 3, 6, _grayDeep),
      FurPatch(68, 39, 3, 6, _grayDeep),
    ],
    sleepHead: [FurPatch(31, 49, 15, 7.5, _gray)],
  ),
};

/// Kucing kamar yang digambar: siapa, pose, arah, aksesoris, dan mainan.
/// [time] = detik animasi (kedip, ekor, napas, dan gerak pose desain 21c);
/// null = sprite diam, juga saat kurangi gerak.
///
/// Tepat satu dari [kitty] (kucing milik pemain) dan [neighbor] (kucing
/// tetangga, Gang Depan) diisi.
class KittyLook {
  const KittyLook({
    this.kitty,
    this.neighbor,
    this.pose = KittyPose.idle,
    this.facing = KittyFacing.down,
    this.accessory,
    this.toy = KittyToy.ball,
    this.post = true,
    this.mirror = false,
    this.bowl = true,
    this.time,
  }) : assert(
         (kitty == null) != (neighbor == null),
         'KittyLook butuh tepat satu kucing atau tetangga',
       );

  /// Kotak gambar desain (100×100), isinya boleh keluar (topi, gelembung).
  static const viewBox = 100.0;

  final KittyId? kitty;
  final Neighbor? neighbor;

  /// Mangkuk di pose [KittyPose.eat] (`mangkuk` desain); false = minum dari
  /// piring air gang yang digambar latarnya.
  final bool bowl;
  final KittyPose pose;
  final KittyFacing facing;
  final AccessoryId? accessory;

  /// Mainan di pose [KittyPose.play].
  final KittyToy toy;

  /// Tiang garukan di pose [KittyPose.scratch]; false kalau tiangnya sudah
  /// digambar barangnya sendiri.
  final bool post;

  /// Badan dicerminkan (`flipT` desain) tanpa mengubah pose atau arah:
  /// kucing di barang yang dicerminkan. Corak dan aksesoris ikut terbalik
  /// seperti kucing yang menghadap kanan; Zzz, hati, "purr~", dan kilau
  /// (di luar `flipT`) tidak.
  final bool mirror;

  final double? time;

  /// Lama satu bingkai jalan (`Kucing.dc.html`: 220 ms).
  static const walkFrameSeconds = 0.22;

  /// Bingkai jalan pada detik [time]: [KittyPose.walk1] dan
  /// [KittyPose.walk2] bergantian.
  static KittyPose walkPose(double time) =>
      (time / walkFrameSeconds).floor().isOdd
      ? KittyPose.walk2
      : KittyPose.walk1;

  /// Bingkai geser pada detik [time]: [KittyPose.geser1] dan
  /// [KittyPose.geser2] bergantian seperti jalan (`Kucing.dc.html`).
  static KittyPose shiftPose(double time) =>
      (time / walkFrameSeconds).floor().isOdd
      ? KittyPose.geser2
      : KittyPose.geser1;

  KittyColors get colors =>
      kitty != null ? kittyPalette[kitty]! : neighborPalette[neighbor]!;

  /// Kucing ini atau tetangga ini tidak bisa diganti lewat [copyWith]
  /// selain dengan [kitty] (untuk kucing milik pemain).
  KittyLook copyWith({
    KittyId? kitty,
    KittyPose? pose,
    KittyFacing? facing,
    AccessoryId? accessory,
    bool clearAccessory = false,
    KittyToy? toy,
    bool? post,
    bool? mirror,
    bool? bowl,
    double? time,
    bool still = false,
  }) => KittyLook(
    kitty: kitty ?? this.kitty,
    neighbor: kitty != null ? null : neighbor,
    pose: pose ?? this.pose,
    facing: facing ?? this.facing,
    accessory: clearAccessory ? null : accessory ?? this.accessory,
    toy: toy ?? this.toy,
    post: post ?? this.post,
    mirror: mirror ?? this.mirror,
    bowl: bowl ?? this.bowl,
    time: still ? null : time ?? this.time,
  );

  @override
  bool operator ==(Object other) =>
      other is KittyLook &&
      other.kitty == kitty &&
      other.neighbor == neighbor &&
      other.pose == pose &&
      other.facing == facing &&
      other.accessory == accessory &&
      other.toy == toy &&
      other.post == post &&
      other.mirror == mirror &&
      other.bowl == bowl &&
      other.time == time;

  @override
  int get hashCode => Object.hash(
    kitty,
    neighbor,
    pose,
    facing,
    accessory,
    toy,
    post,
    mirror,
    bowl,
    time,
  );

  @override
  String toString() =>
      'KittyLook(${kitty?.name ?? neighbor?.name}, ${pose.name}, '
      '${facing.name}, ${accessory?.name}, ${toy.name}, post: $post, '
      'mirror: $mirror, bowl: $bowl, time: $time)';
}
