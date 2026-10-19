import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/model/sounds.dart';

/// Berkas audio ada, terdaftar di pubspec, dan tetap kecil.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  int sizeOf(String asset) {
    final file = File('assets/$asset');
    expect(file.existsSync(), isTrue, reason: asset);
    final folder = asset.substring(0, asset.lastIndexOf('/') + 1);
    expect(pubspec, contains('- assets/$folder'), reason: asset);
    return file.lengthSync();
  }

  test('efek suara ada dan masing-masing ≤ 40 KB', () {
    for (final sound in GameSound.values) {
      expect(
        sizeOf(sound.asset),
        lessThanOrEqualTo(40 * 1024),
        reason: '$sound',
      );
    }
  });

  test('musik ada dan masing-masing ≤ 400 KB', () {
    for (final track in MusicTrack.values) {
      expect(
        sizeOf(track.asset),
        lessThanOrEqualTo(400 * 1024),
        reason: '$track',
      );
    }
  });

  test('semua audio ≤ 1,2 MB, tanpa berkas yang tidak dipakai', () {
    final used = {
      for (final s in GameSound.values) 'assets/${s.asset}',
      for (final t in MusicTrack.values) 'assets/${t.asset}',
    };
    final files = [
      for (final f in Directory('assets/audio').listSync(recursive: true))
        if (f is File && f.path.endsWith('.ogg')) f,
    ];
    expect({for (final f in files) f.path.replaceAll(r'\', '/')}, used);
    final total = files.fold<int>(0, (sum, f) => sum + f.lengthSync());
    expect(total, lessThanOrEqualTo(1200 * 1024));
  });

  test('lisensi efek suara terdaftar', () {
    expect(File('assets/audio/LICENSE-sfx.txt').existsSync(), isTrue);
    expect(pubspec, contains('- assets/audio/LICENSE-sfx.txt'));
  });
}
