import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/design_svg.dart';

/// `docs/design/` tidak ikut repo; test ini hanya jalan di komputer yang
/// punya ekspor desainnya.
const _source = 'docs/design/source';

/// Akhir baris disamakan (checkout Windows bisa CRLF), tepi dibuang.
String _lf(String s) => s.replaceAll('\r\n', '\n').trim();

String _read(String name) => _lf(File('$_source/$name').readAsStringSync());

/// Isi `<svg>` pertama di komponen desain.
String _inner(String name) => _lf(
  RegExp(
    r'<svg\b[^>]*>\n(.*?)\n</svg>',
    dotAll: true,
  ).firstMatch(_read(name))![1]!,
);

void main() {
  final missing = !Directory(_source).existsSync()
      ? '$_source tidak ada (desain tidak ikut repo)'
      : null;

  group('isi SVG sama dengan desain', () {
    test('Tile.dc.html', () {
      expect(_lf(tileSvg), _inner('Tile.dc.html'));
    });

    test('Oyen.dc.html', () {
      expect(_lf(oyenSvg), _inner('Oyen.dc.html'));
    });

    test('panah arah hadap di Board.dc.html', () {
      final svg = RegExp(
        r'<svg aria-hidden="true" width="12" height="12" '
        r'viewBox="0 0 12 12">(.*?)</svg>',
      ).firstMatch(_read('Board.dc.html'))![1]!;
      expect(_lf(facingSvg), _lf(svg));
    });
  }, skip: missing);
}
