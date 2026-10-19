import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bahasa yang didukung: Inggris (template), Indonesia, Portugis Brasil,
/// Rusia.
const _locales = ['en', 'id', 'pt', 'ru'];

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

/// Kunci pesan (tanpa `@kunci` dan `@@locale`).
Set<String> _keys(Map<String, dynamic> arb) => {
  for (final key in arb.keys)
    if (!key.startsWith('@')) key,
};

/// Placeholder yang dicetak (`{nama}`), bukan isi cabang plural/select
/// seperti `one{coin}` (didahului nama cabang).
Set<String> _printed(String message) => {
  for (final match in RegExp(r'(?<![\w=])\{(\w+)\}').allMatches(message))
    match.group(1)!,
};

/// Placeholder pemilih plural/select (`{n, plural, ...}`).
Set<String> _selectors(String message) => {
  for (final match in RegExp(r'\{(\w+),').allMatches(message)) match.group(1)!,
};

void main() {
  final template = _arb('en');

  test('setiap pesan template punya deskripsi', () {
    for (final key in _keys(template)) {
      expect(template['@$key'], isA<Map<String, dynamic>>(), reason: key);
    }
  });

  for (final locale in _locales) {
    test('$locale punya semua kunci dan tidak ada kunci lebih', () {
      final arb = _arb(locale);
      expect(arb['@@locale'], locale);
      expect(_keys(arb), _keys(template));
    });

    test('$locale memakai placeholder yang sama dengan template', () {
      final arb = _arb(locale);
      for (final key in _keys(template)) {
        final meta = template['@$key'] as Map<String, dynamic>;
        final declared = {
          ...?(meta['placeholders'] as Map<String, dynamic>?)?.keys,
        };
        final message = arb[key] as String;
        final used = {..._printed(message), ..._selectors(message)};
        expect(declared.containsAll(used), isTrue, reason: '$locale $key');
        // Pemilih plural boleh hilang di bahasa tanpa bentuk jamak
        // (Indonesia: "koin"), tapi yang dicetak template harus ada.
        expect(
          _printed(message).containsAll(_printed(template[key] as String)),
          isTrue,
          reason: '$locale $key',
        );
      }
    });

    test('$locale tidak punya pesan kosong', () {
      final arb = _arb(locale);
      for (final key in _keys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    });
  }
}
