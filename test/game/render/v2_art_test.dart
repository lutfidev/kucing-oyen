import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/cat_rig.dart';
import 'package:kucing_oren/game/render/v2/room_art.dart';

const export = bool.fromEnvironment('ART_REVIEW');
const measure = bool.fromEnvironment('ART_MEASURE');

Future<ArtPack> loadPack() async {
  // Files are the real pubspec assets. File reads keep bulk art inspection
  // outside the widget binding's fake async clock.
  return ArtPack.load(bundle: _Files());
}

class _Files extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

class _ManifestOverride extends _Files {
  _ManifestOverride(this.change);
  final void Function(Map<String, dynamic>) change;
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final source = await super.loadString(key, cache: false);
    if (!key.endsWith('manifest.json')) return source;
    final data = jsonDecode(source) as Map<String, dynamic>;
    change(data);
    return jsonEncode(data);
  }
}

void label(Canvas c, String text, double x, double y, {double width = 128}) {
  final builder =
      ParagraphBuilder(
          ParagraphStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            textAlign: TextAlign.center,
          ),
        )
        ..pushStyle(TextStyle(color: const Color(0xFF573018)))
        ..addText(text);
  final p = builder.build()..layout(ParagraphConstraints(width: width));
  c.drawParagraph(p, Offset(x, y));
}

Future<void> png(String name, int w, int h, void Function(Canvas) draw) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  draw(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage(w, h);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  final file = File('docs/design-v2/assets/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'incomplete manifest and invalid anchors fail in the load boundary',
    () async {
      await expectLater(
        ArtPack.load(
          bundle: _ManifestOverride(
            (m) => (m['assets'] as Map).remove('cats/oyen-body'),
          ),
        ),
        throwsFormatException,
      );
      await expectLater(
        ArtPack.load(
          bundle: _ManifestOverride(
            (m) => m['assets']['accessories/pita']['anchor'] = 'unknown',
          ),
        ),
        throwsFormatException,
      );
    },
  );

  test('every pose retains directional face geometry and glasses project onto side eyes', () {
    for (final motion in CatMotion.values) {
      final front = CatRig(motion: motion);
      final side = CatRig(
        motion: motion,
        direction: CatDirection.left,
        accessory: AccessoryId.kacamata,
      );
      expect(side.expression, isNot(front.expression));
      expect(side.expression, anyOf('side', endsWith('-side')));
      expect(
        CatRig(motion: motion, direction: CatDirection.back).expression,
        'back',
      );
      final local = side.localAnchor('face');
      expect(local.dx - 18 * side.accessoryScale, closeTo(44, 0.1));
      expect(local.dx + 18 * side.accessoryScale, closeTo(65, 0.1));
    }
  });

  test(
    'real asset pack covers all catalogue identities, masks and layers',
    () async {
      final pack = await loadPack();
      expect(pack.parts.length, 209);
      for (final cat in KittyId.values) {
        for (final expr in ArtPack.expressions) {
          expect(
            pack['cats/${cat.name}-head-$expr'].drawing.length,
            greaterThanOrEqualTo(3),
          );
        }
      }
      for (final a in accessories) {
        expect(pack['accessories/${a.id.name}'].anchor, a.anchor.name);
      }
      for (final item in RoomItemId.values) {
        expect(pack['items/${item.name}-back'].drawing.length, greaterThan(0));
        expect(
          pack['items/${item.name}-front'].interaction,
          const Offset(64, 86),
        );
      }
      for (final area in ArtArea.values) {
        for (final layer in ['wall', 'floor', 'decor']) {
          expect(pack['rooms/${area.name}-$layer'].size, const Size(390, 390));
        }
      }
    },
  );

  test(
    'accessory anchors stay attached under pose changes and explicit mirror',
    () {
      for (final motion in CatMotion.values) {
        for (final time in [null, 0.0, 0.2, 0.7]) {
          final left = CatRig(
            motion: motion,
            direction: CatDirection.left,
            time: time,
          );
          final right = CatRig(
            motion: motion,
            direction: CatDirection.right,
            time: time,
          );
          for (final key in CatRig.anchors.keys) {
            final l = left.anchor(key);
            final r = right.anchor(key);
            expect(l.dx + r.dx, closeTo(128, 1e-9));
            expect(l.dy, r.dy);
            expect(l.dx, inInclusiveRange(0, 128));
            expect(l.dy, inInclusiveRange(0, 128));
          }
        }
      }
      expect(const CatRig(direction: CatDirection.back).expression, 'back');
      expect(const CatRig(direction: CatDirection.left).expression, 'side');
      expect(
        {
          for (var i = 0; i < 8; i++)
            CatRig(motion: CatMotion.walk, time: i * 0.1 + 0.001).frame,
        }.length,
        8,
      );
    },
  );

  test('extreme hats remain inside transparent sprite canvas while sleeping/walking', () async {
    final pack = await loadPack();
    for (final motion in [
      CatMotion.sleep,
      CatMotion.walk,
      CatMotion.startled,
    ]) {
      for (final direction in CatDirection.values) {
        final recorder = PictureRecorder();
        final c = Canvas(recorder);
        for (final cat in KittyId.values) {
          for (final accessory in AccessoryId.values) {
            c.save();
            c.translate(accessory.index * 128.0, cat.index * 128.0);
            CatRig(
              cat: cat,
              motion: motion,
              direction: direction,
              accessory: accessory,
              time: 0.3,
            ).paint(c, pack);
            c.restore();
          }
        }
        final p = recorder.endRecording();
        final image = await p.toImage(2048, 1152);
        final bytes = (await image.toByteData())!;
        // Every sprite cell must have a transparent perimeter. This catches
        // hats, tails, props and rotated anchors clipping at runtime size.
        int alpha(int x, int y) => bytes.getUint8((y * 2048 + x) * 4 + 3);
        for (var row = 0; row < 9; row++) {
          for (var col = 0; col < 16; col++) {
            for (var n = 0; n < 128; n++) {
              expect(
                alpha(col * 128 + n, row * 128),
                0,
                reason: '$motion $direction top',
              );
              expect(
                alpha(col * 128 + n, row * 128 + 127),
                0,
                reason:
                    '$motion $direction bottom cat=$row accessory=$col pixel=$n',
              );
              expect(
                alpha(col * 128, row * 128 + n),
                0,
                reason: '$motion $direction left',
              );
              expect(
                alpha(col * 128 + 127, row * 128 + n),
                0,
                reason: '$motion $direction right',
              );
            }
          }
        }
        image.dispose();
        p.dispose();
      }
    }
  });

  test('stress all combinations without growing the finite part set', () async {
    final before = ProcessInfo.currentRss;
    final pack = await loadPack();
    final loaded = ProcessInfo.currentRss;
    final identity = pack.parts.values.toList();
    final timer = Stopwatch()..start();
    var rendered = 0;
    var recordedBytes = 0;
    for (final cat in KittyId.values) {
      for (final accessory in AccessoryId.values) {
        for (final motion in CatMotion.values) {
          for (final direction in CatDirection.values) {
            final recorder = PictureRecorder();
            CatRig(
              cat: cat,
              motion: motion,
              direction: direction,
              accessory: accessory,
              time: rendered * 0.117,
            ).paint(Canvas(recorder), pack);
            final p = recorder.endRecording();
            recordedBytes += p.approximateBytesUsed;
            p.dispose();
            rendered++;
          }
        }
      }
    }
    timer.stop();
    expect(pack.parts.values.toList(), orderedEquals(identity));
    expect(pack.sourceBytes, lessThan(20 * 1024 * 1024));
    final report = {
      'sourceBytes': pack.sourceBytes,
      'parts': pack.parts.length,
      'draws': rendered,
      'recordingMicrosecondsPerCat': timer.elapsedMicroseconds / rendered,
      'meanPictureBytes': recordedBytes / rendered,
      'rssBeforeLoad': before,
      'rssAfterLoad': loaded,
      'rssAfterStress': ProcessInfo.currentRss,
      'decodedRasterBytes': 0,
      'note': 'Windows flutter_test process RSS includes engine/test overhead; recording is not device build/raster frame timing.',
    };
    if (measure) {
      await Directory('docs/design-v2/assets').create(recursive: true);
      await File('docs/design-v2/assets/measurements.json').writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(report)}\n',
      );
    }
  });

  test('export real runtime review sheets', () async {
    final pack = await loadPack();
    await png('characters', 1152, 460, (c) {
      for (final cat in KittyId.values) {
        for (var row = 0; row < 3; row++) {
          c.save();
          c.translate(cat.index * 128.0, row * 152.0);
          CatRig(
            cat: cat,
            direction: row == 2 ? CatDirection.back : CatDirection.front,
          ).paint(c, pack, portrait: row == 0);
          label(c, '${cat.name}${row == 2 ? ' · belakang' : ''}', 0, 130);
          c.restore();
        }
      }
    });
    await png('motions', 2176, 684, (c) {
      for (final motion in CatMotion.values) {
        for (final direction in CatDirection.values) {
          c.save();
          c.translate(motion.index * 128.0, direction.index * 170.0);
          CatRig(
            motion: motion,
            direction: direction,
            accessory: AccessoryId.pita,
            time: 0.3,
          ).paint(c, pack);
          label(c, '${motion.name}\n${direction.name}', 0, 130);
          c.restore();
        }
      }
    });
    await png('accessories', 2048, 1368, (c) {
      for (final cat in KittyId.values) {
        for (final accessory in AccessoryId.values) {
          c.save();
          c.translate(accessory.index * 128.0, cat.index * 152.0);
          CatRig(cat: cat, accessory: accessory).paint(c, pack);
          label(c, accessory.name, 0, 130);
          c.restore();
        }
      }
    });
    await png('furniture', 896, 480, (c) {
      for (final item in RoomItemId.values) {
        c.save();
        c.translate(item.index % 7 * 128.0, item.index ~/ 7 * 160.0);
        pack.paint(c, 'items/${item.name}-back');
        pack.paint(c, 'items/${item.name}-front');
        label(c, item.name, 0, 130);
        c.restore();
      }
    });
    await png('areas', 780, 828, (c) {
      for (final area in ArtArea.values) {
        c.save();
        c.translate(area.index % 2 * 390.0, area.index ~/ 2 * 414.0);
        paintAreaArt(c, pack, area);
        label(c, area.name, 0, 392, width: 390);
        c.restore();
      }
    });
  }, skip: !export);
}
