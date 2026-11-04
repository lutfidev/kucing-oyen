import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/widgets/ tidak mengimpor lib/app/ atau lib/screens/', () {
    final bad = <String>[];
    final files = Directory('lib/widgets')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      for (final line in file.readAsLinesSync()) {
        if (RegExp(
          r'''^(import|export) ['"]((\.\./)+(app|screens)/|package:kucing_oren/(app|screens)/)''',
        ).hasMatch(line)) {
          bad.add('${file.path}: $line');
        }
      }
    }
    expect(bad, isEmpty);
  });
}
