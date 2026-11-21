// PROTOTIPE (spike): ekspor sprite kucing dan barang v1 ke PNG transparan
// untuk gambar konsep rumah.
//   flutter test test/spike/export_sprites_test.dart --dart-define=SPRITES=<folder>
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui' show Canvas, Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/render.dart';

const _out = String.fromEnvironment('SPRITES');

Future<void> _save(String name, Size size, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  paint(canvas);
  final image = await recorder.endRecording().toImage(
    size.width.ceil(),
    size.height.ceil(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('$_out/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('ekspor sprite', () async {
    const k = 3.0;
    for (final kitty in KittyId.values) {
      for (final pose in [
        KittyPose.idle,
        KittyPose.sleep,
        KittyPose.rebah,
        KittyPose.lick,
        KittyPose.walk1,
      ]) {
        await _save(
          'kitty-${kitty.name}-${pose.name}',
          const Size.square(100 * k),
          (c) => paintKitty(
            c,
            KittyLook(kitty: kitty, pose: pose),
            size: 100 * k,
          ),
        );
      }
    }
    for (final id in RoomItemId.values) {
      final size = RoomItemArt.sizeOf(id) * k;
      await _save('item-${id.name}', size, (c) {
        paintRoomItemArt(c, id, box: size);
      });
    }
    await _save('window', RoomArt.windowBox.size * k, (c) {
      paintRoomWindow(c, box: Offset.zero & RoomArt.windowBox.size * k);
    });
  }, skip: _out.isEmpty);
}
