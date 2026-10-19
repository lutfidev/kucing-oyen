import '../sim/direction.dart';

/// Pose Oyen di `Oyen.dc.html` (prop `pose`).
enum OyenPose { idle, walk, sleep, shock, box, knock, eat, happy }

/// Kostum Oyen (prop `costume`).
enum OyenCostume { none, peci, sarung, koki, kacamata }

/// Gelembung di atas kepala Oyen (prop `bubble`). [ikan] tidak ada di
/// desain: gelembung pikiran saat Oyen mengejar ikan (GDD).
enum OyenBubble { none, zzz, kaget, ikan }

/// Tampilan Oyen: pose, arah hadap, kostum, dan gelembung. Data saja,
/// digambar oleh `paintOyen`.
class OyenLook {
  const OyenLook({
    this.pose = OyenPose.idle,
    this.dir = Direction.down,
    this.costume = OyenCostume.none,
    this.bubble = OyenBubble.none,
    this.mirror = false,
  });

  final OyenPose pose;
  final Direction dir;
  final OyenCostume costume;
  final OyenBubble bubble;

  /// Seluruh gambar (termasuk gelembung) dicerminkan kiri-kanan, untuk pose
  /// menjatuhkan ke meja di kiri Oyen. Tidak ada di desain.
  final bool mirror;

  /// Sprite memakai viewBox 100×100 dan boleh menggambar di luarnya
  /// (gelembung, topi koki).
  static const double viewBox = 100;

  OyenLook copyWith({
    OyenPose? pose,
    Direction? dir,
    OyenCostume? costume,
    OyenBubble? bubble,
    bool? mirror,
  }) => OyenLook(
    pose: pose ?? this.pose,
    dir: dir ?? this.dir,
    costume: costume ?? this.costume,
    bubble: bubble ?? this.bubble,
    mirror: mirror ?? this.mirror,
  );

  @override
  bool operator ==(Object other) =>
      other is OyenLook &&
      other.pose == pose &&
      other.dir == dir &&
      other.costume == costume &&
      other.bubble == bubble &&
      other.mirror == mirror;

  @override
  int get hashCode => Object.hash(pose, dir, costume, bubble, mirror);

  @override
  String toString() =>
      'OyenLook(${pose.name}, ${dir.name}, ${costume.name}, ${bubble.name}'
      '${mirror ? ', mirror' : ''})';
}
