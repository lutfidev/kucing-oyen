import 'dart:math' as math;
import 'dart:ui';

import '../../model/accessories.dart';
import '../../model/kitties.dart';
import 'art_pack.dart';

enum CatDirection { front, left, back, right }

enum CatMotion {
  idle,
  walk,
  sit,
  sleep,
  eat,
  play,
  brush,
  pet,
  happy,
  startled,
  tired,
  box,
  drop,
  chase,
  fish,
  win,
  bored,
}

/// Shared portrait/home/puzzle rig, in 128×128 units including hat margin.
/// Null time is the static reduced-motion frame. All geometry is pre-parsed.
class CatRig {
  const CatRig({
    this.cat = KittyId.oyen,
    this.motion = CatMotion.idle,
    this.direction = CatDirection.front,
    this.accessory,
    this.time,
  });

  final KittyId cat;
  final CatMotion motion;
  final CatDirection direction;
  final AccessoryId? accessory;
  final double? time;

  static const anchors = <String, Offset>{
    'headTop': Offset(64, 34),
    'headSideLeft': Offset(38, 46),
    'headSideRight': Offset(90, 46),
    'face': Offset(64, 65),
    'neck': Offset(64, 86),
  };

  int get frame => time == null ? 0 : ((time! % 0.8) / 0.1).floor().clamp(0, 7);
  bool get _walk => motion == CatMotion.walk || motion == CatMotion.chase;
  bool get _lie =>
      motion == CatMotion.sleep ||
      motion == CatMotion.tired ||
      motion == CatMotion.bored;
  double get _wave => time == null ? 0 : math.sin(time! * math.pi * 2 / 0.8);
  bool get _mirror => direction == CatDirection.right;
  bool get _profileWalk =>
      _walk &&
      (direction == CatDirection.left || direction == CatDirection.right);

  bool get _profile =>
      direction == CatDirection.left || direction == CatDirection.right;

  Offset localAnchor(String name) =>
      name == 'face' && _profile ? const Offset(54.5, 65) : anchors[name]!;

  double get accessoryScale =>
      accessory == AccessoryId.kacamata && _profile ? 0.58 : 0.68;
  int get reactionFrame =>
      time == null ? 0 : ((time! % 0.8) / 0.2).floor().clamp(0, 3);

  String get expression {
    if (direction == CatDirection.back) return 'back';
    final face = _expression;
    return _profile ? (face == 'open' ? 'side' : '$face-side') : face;
  }

  String get _expression {
    if (motion == CatMotion.startled || motion == CatMotion.drop) {
      return 'startled';
    }
    if (motion == CatMotion.tired || motion == CatMotion.bored) return 'tired';
    if (motion == CatMotion.sleep ||
        motion == CatMotion.brush ||
        motion == CatMotion.pet) {
      return 'closed';
    }
    if (motion == CatMotion.happy ||
        motion == CatMotion.win ||
        motion == CatMotion.eat ||
        motion == CatMotion.fish) {
      return 'happy';
    }
    final blink = time != null && (time! + cat.index * 0.37) % 4.6 > 4.4;
    return blink ? 'closed' : 'open';
  }

  /// Head transform also carries ALL accessories, including neck ones.
  Offset get headShift => Offset(
    _profileWalk
        ? -10
        : motion == CatMotion.play
        ? _wave * 2
        : 0,
    _lie
        ? 23
        : motion == CatMotion.eat || motion == CatMotion.fish
        ? 10 + _wave * 2
        : _profileWalk
        ? 7 + (frame.isOdd ? -1.5 : 0)
        : _walk
        ? (frame.isOdd ? -1.5 : 0)
        : time == null
        ? 0
        : math.sin(time! * math.pi * 2 / 3.2) * 0.7,
  );

  double get headAngle => _lie
      ? -0.16
      : motion == CatMotion.pet
      ? 0.1 + _wave * 0.04
      : motion == CatMotion.play
      ? _wave * 0.08
      : motion == CatMotion.happy ||
            motion == CatMotion.win ||
            motion == CatMotion.startled
      ? [0.0, -0.04, 0.0, 0.04][reactionFrame]
      : 0;

  void _headSpace(Canvas canvas) {
    canvas.translate(headShift.dx, headShift.dy);
    canvas.translate(64, 72);
    canvas.rotate(headAngle);
    canvas.translate(-64, -72);
  }

  /// Exposed for interaction overlays and alignment verification; includes
  /// direction mirror and pose, never absolute screen coordinates.
  Offset anchor(String name) {
    final p = localAnchor(name) - const Offset(64, 72);
    final a = headAngle;
    final q =
        Offset(
          p.dx * math.cos(a) - p.dy * math.sin(a),
          p.dx * math.sin(a) + p.dy * math.cos(a),
        ) +
        const Offset(64, 72) +
        headShift;
    return _mirror ? Offset(128 - q.dx, q.dy) : q;
  }

  void paint(
    Canvas canvas,
    ArtPack pack, {
    bool portrait = false,
    bool props = true,
  }) {
    canvas.save();
    if (_mirror) {
      canvas.translate(128, 0);
      canvas.scale(-1, 1);
    }
    final prefix = 'cats/${cat.name}';
    if (!portrait) {
      canvas.drawOval(
        const Rect.fromLTWH(30, 111, 70, 10),
        Paint()..color = const Color(0x18573018),
      );
      canvas.save();
      canvas.translate(88, 104);
      canvas.rotate(time == null ? 0 : _wave * 0.08);
      canvas.translate(-88, -104);
      pack.paint(canvas, '$prefix-tail');
      canvas.restore();
      canvas.save();
      if (_lie) {
        canvas.translate(-2, 7);
        canvas.translate(64, 100);
        canvas.scale(1.25, 0.72);
        canvas.translate(-64, -100);
      } else if (_profileWalk) {
        canvas.translate(10, 0);
        canvas.translate(64, 100);
        canvas.scale(1.2, 0.8);
        canvas.translate(-64, -100);
      }
      pack.paint(
        canvas,
        '$prefix-body${direction == CatDirection.back ? '-back' : ''}',
      );
      canvas.restore();
      for (var side = 0; side < 2; side++) {
        canvas.save();
        final dy = _walk
            ? math.sin(frame / 8 * math.pi * 2 + side * math.pi) * 3
            : 0.0;
        canvas.translate(side * (_profileWalk ? 43.0 : 23.0), dy);
        if (motion == CatMotion.play && side == 1) {
          canvas.translate(7, -10 - _wave * 3);
        }
        if (motion == CatMotion.drop && side == 1) {
          canvas.translate(12, -18 - _wave * 3);
        }
        pack.paint(canvas, '$prefix-paw');
        canvas.restore();
      }
    }
    canvas.save();
    _headSpace(canvas);
    pack.paint(canvas, '$prefix-head-$expression');
    if (accessory case final id?) {
      final rear =
          direction == CatDirection.back &&
          const [
            AccessoryId.kacamata,
            AccessoryId.kalung,
            AccessoryId.bandana,
            AccessoryId.dasiKupu,
          ].contains(id);
      final part = pack['accessories/${id.name}${rear ? '-back' : ''}'];
      final target = localAnchor(part.anchor!);
      canvas.translate(target.dx, target.dy);
      canvas.scale(accessoryScale);
      canvas.translate(-part.pivot.dx, -part.pivot.dy);
      part.drawing.paint(canvas);
    }
    canvas.restore();
    if (!portrait && props) _props(canvas, pack);
    canvas.restore();
  }

  void _props(Canvas canvas, ArtPack pack) {
    final brush = motion == CatMotion.brush;
    if (motion == CatMotion.box) {
      canvas.save();
      canvas.translate(4, 41);
      canvas.scale(0.94, 0.63);
      pack.paint(canvas, 'items/kardus-front');
      canvas.restore();
    }
    if (motion == CatMotion.play) {
      canvas.save();
      canvas.translate(82 + _wave * 3, 82);
      canvas.scale(0.3);
      pack.paint(canvas, 'items/bola-back');
      canvas.restore();
    }
    if (brush) {
      final x = 89 + _wave * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 54, 19, 10),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFE9AE60),
      );
      canvas.drawLine(
        Offset(x + 9, 64),
        Offset(x + 9, 78),
        Paint()
          ..color = const Color(0xFF573018)
          ..strokeWidth = 3,
      );
    }
    if (motion == CatMotion.fish) {
      final fish = Path()
        ..moveTo(66, 110)
        ..quadraticBezierTo(76, 101, 89, 110)
        ..quadraticBezierTo(77, 119, 66, 110)
        ..moveTo(89, 110)
        ..lineTo(97, 104)
        ..lineTo(97, 116)
        ..close();
      canvas.drawPath(fish, Paint()..color = const Color(0xFFB0C6B5));
    }
    if (motion == CatMotion.drop) {
      canvas.save();
      canvas.translate(108, 91 + reactionFrame * 3.0);
      canvas.rotate(reactionFrame * 0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -9, 10, 16),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFCD8B79),
      );
      canvas.restore();
    }
    if (motion == CatMotion.chase) {
      canvas.save();
      // Canonical profile faces left; right is mirrored by the whole rig.
      canvas.translate(
        _profile ? -96 : -47,
        _profile
            ? 0
            : direction == CatDirection.back
            ? -88
            : 12,
      );
      final fish = Path()
        ..moveTo(100, 109)
        ..quadraticBezierTo(107, 102, 117, 109)
        ..quadraticBezierTo(107, 116, 100, 109)
        ..moveTo(117, 109)
        ..lineTo(124, 104)
        ..lineTo(124, 114)
        ..close();
      canvas.drawPath(fish, Paint()..color = const Color(0xFFB0C6B5));
      canvas.restore();
    }
    if (motion == CatMotion.eat) {
      canvas.save();
      canvas.translate(32, 85);
      canvas.scale(0.5, 0.3);
      pack.paint(canvas, 'items/mangkuk-back');
      pack.paint(canvas, 'items/mangkuk-front');
      canvas.restore();
    }
    if (motion == CatMotion.win ||
        motion == CatMotion.happy ||
        motion == CatMotion.pet) {
      final p = Path()
        ..moveTo(103, 42)
        ..cubicTo(87, 32, 100, 23, 103, 31)
        ..cubicTo(110, 21, 121, 33, 103, 42);
      canvas.drawPath(p, Paint()..color = const Color(0xFFD98976));
    }
  }
}
