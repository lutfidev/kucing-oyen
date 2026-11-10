import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../../model/accessories.dart';
import '../../model/home_items.dart';
import '../../model/kitties.dart';
import '../svg_template.dart';

/// One finite set of parsed vector parts. Owners release the whole pack when
/// leaving the gallery/scene; no global frame or combination cache exists.
class ArtPack {
  ArtPack._(this.parts, this.sourceBytes);

  /// Generated, finite subset for synchronous Flame/CustomPainter rendering.
  /// Uses the same SVG sources as the house rig; no asset IO during paint.
  factory ArtPack.oyen(Map<String, String> sources) => ArtPack._(
    Map.unmodifiable({
      for (final entry in sources.entries)
        entry.key: ArtPart(
          SvgTemplate(entry.value).render(const {}),
          const Size(128, 128),
          Offset.zero,
          null,
          null,
        ),
    }),
    sources.values.fold(0, (bytes, svg) => bytes + utf8.encode(svg).length),
  );

  final Map<String, ArtPart> parts;
  final int sourceBytes;
  static const base = 'assets/art/v2/';
  static const expressions = [
    'open',
    'closed',
    'happy',
    'startled',
    'tired',
    'back',
    'side',
    'closed-side',
    'happy-side',
    'startled-side',
    'tired-side',
  ];
  static const anchorNames = {
    'headTop',
    'headSideLeft',
    'headSideRight',
    'neck',
    'face',
  };
  static Set<String> get requiredKeys => {
    for (final cat in KittyId.values) ...{
      for (final part in ['body', 'body-back', 'tail', 'paw'])
        'cats/${cat.name}-$part',
      for (final expression in expressions) 'cats/${cat.name}-head-$expression',
    },
    for (final accessory in AccessoryId.values) 'accessories/${accessory.name}',
    for (final rear in ['kacamata', 'bandana', 'kalung', 'dasiKupu'])
      'accessories/$rear-back',
    for (final item in RoomItemId.values) ...{
      'items/${item.name}-back',
      'items/${item.name}-front',
    },
    for (final area in ['santai', 'makan', 'main', 'rawat'])
      for (final layer in ['wall', 'floor', 'decor']) 'rooms/$area-$layer',
  };

  static Future<ArtPack> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    final source = await assets.loadString(
      '${base}manifest.json',
      cache: false,
    );
    final manifest = jsonDecode(source) as Map<String, dynamic>;
    if (manifest['version'] != 2) {
      throw const FormatException('Unsupported art pack version');
    }
    final entries = manifest['assets'] as Map<String, dynamic>;
    if (entries.keys.toSet().difference(requiredKeys).isNotEmpty ||
        requiredKeys.difference(entries.keys.toSet()).isNotEmpty) {
      throw const FormatException('Incomplete or unexpected art inventory');
    }
    final parts = <String, ArtPart>{};
    var bytes = utf8.encode(source).length;
    for (final entry in entries.entries) {
      final meta = entry.value as Map<String, dynamic>;
      if (entry.key.startsWith('accessories/') &&
          !anchorNames.contains(meta['anchor'])) {
        throw FormatException('Invalid accessory anchor: ${entry.key}');
      }
      final filename = meta['file'] as String;
      if (filename.contains('..') || filename != '${entry.key}.svg') {
        throw FormatException('Invalid art path: $filename');
      }
      final svg = await assets.loadString('$base$filename', cache: false);
      bytes += utf8.encode(svg).length;
      // SVG files retain their external viewBox, but the existing renderer
      // consumes its children in native design units.
      final inner = svg.substring(
        svg.indexOf('>') + 1,
        svg.lastIndexOf('</svg>'),
      );
      final size = Size(
        (meta['width'] as num).toDouble(),
        (meta['height'] as num).toDouble(),
      );
      if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) {
        throw FormatException('Invalid art size: ${entry.key}');
      }
      parts[entry.key] = ArtPart(
        SvgTemplate(inner).render(const {}),
        size,
        _point(meta['pivot']),
        meta['anchor'] as String?,
        meta['interaction'] == null ? null : _point(meta['interaction']),
      );
    }
    return ArtPack._(Map.unmodifiable(parts), bytes);
  }

  static Offset _point(dynamic pair) {
    final point = Offset(
      (pair[0] as num).toDouble(),
      (pair[1] as num).toDouble(),
    );
    if (!point.dx.isFinite || !point.dy.isFinite) {
      throw const FormatException('Invalid art point');
    }
    return point;
  }

  ArtPart operator [](String key) =>
      parts[key] ?? (throw StateError('Missing art: $key'));

  void paint(Canvas canvas, String key) => this[key].drawing.paint(canvas);
}

class ArtPart {
  const ArtPart(
    this.drawing,
    this.size,
    this.pivot,
    this.anchor,
    this.interaction,
  );

  final SvgDrawing drawing;
  final Size size;
  final Offset pivot;
  final String? anchor;
  final Offset? interaction;
}
