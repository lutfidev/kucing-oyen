import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Perintah Python 3 yang bisa dijalankan, atau null kalau tidak ada.
Future<List<String>?> _python() async {
  for (final command in [
    ['python3'],
    ['python'],
    ['py', '-3'],
  ]) {
    try {
      final result = await Process.run(command.first, [
        ...command.skip(1),
        '--version',
      ]);
      final version = '${result.stdout}${result.stderr}';
      if (result.exitCode == 0 && version.contains('Python 3')) return command;
    } on ProcessException {
      continue;
    }
  }
  return null;
}

void main() {
  test('berkas tinjauan terjemahan sesuai ARB dan listing toko', () async {
    final python = await _python();
    if (python == null) {
      markTestSkipped('Python 3 tidak ada; cek lewat /check di komputer lain');
      return;
    }
    final result = await Process.run(python.first, [
      ...python.skip(1),
      'tool/translations/make_review.py',
      '--check',
    ]);
    expect(
      result.exitCode,
      0,
      reason:
          '${result.stdout}${result.stderr}\n'
          'docs/translations/ basi: jalankan '
          '`python tool/translations/make_review.py` lalu commit hasilnya.',
    );
  }, timeout: const Timeout(Duration(minutes: 1)));
}
