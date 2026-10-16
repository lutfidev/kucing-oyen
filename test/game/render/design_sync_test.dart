import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/design_svg.dart';
import 'package:kucing_oren/game/render/result_art.dart';

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

    group('gambar slot baki', () {
      const screen = '03-gameplay-fase-atur.html';

      test('ikan, ember, dan bayangan ember disalin dari desain 03', () {
        final source = _read(screen);
        for (final svg in [trayFishSvg, trayBucketSvg, trayBucketGhostSvg]) {
          expect(source, contains(_lf(svg)));
        }
      });

      test('kardus disalin dari Tile.dc.html', () {
        expect(_read('Tile.dc.html'), contains(_lf(trayBoxSvg)));
      });

      test('setiap elemen bayangan ikan ada di desain 03', () {
        final source = _read(screen);
        final tags = RegExp(r'<[a-z][^>]*>').allMatches(trayFishGhostSvg);
        expect(tags, isNotEmpty);
        for (final tag in tags) {
          expect(source, contains(tag[0]));
        }
      });
    });

    test('gelembung ikan: lingkaran dari Oyen.dc.html, ikan dari Tile', () {
      final source = _read('Oyen.dc.html') + _read('Tile.dc.html');
      final tags = RegExp(r'<(?!g\b)[a-z][^>]*>').allMatches(fishBubbleSvg);
      expect(tags, hasLength(7));
      for (final tag in tags) {
        expect(source, contains(tag[0]));
      }
    });

    group('layar hasil', () {
      test('sinar dan mangkuk disalin dari desain 06', () {
        final source = _read('06-hasil-berhasil.html');
        for (final svg in [raysSvg, successBowlSvg]) {
          expect(source, contains(_lf(svg)));
        }
      });

      test('ilustrasi dan mangkuk disalin dari desain 07', () {
        final source = _read('07-hasil-vas-pecah.html');
        for (final svg in [
          vaseBowlSvg,
          vaseRoomSvg,
          vaseMomSvg,
          vaseTableSvg,
          vasePrangSvg,
        ]) {
          expect(source, contains(_lf(svg)));
        }
        final at = ResultArt.prangAt;
        expect(
          source,
          contains(
            '<g transform="translate(${at.dx.toInt()} ${at.dy.toInt()})">',
          ),
        );
      });

      test('letak Oyen dan mangkuk di kartu ilustrasi', () {
        String place(Rect r) =>
            'left: ${r.left.toInt()}px; top: ${r.top.toInt()}px';
        final success = _read('06-hasil-berhasil.html');
        expect(success, contains(place(ResultArt.successOyen)));
        expect(
          success,
          contains('size="${ResultArt.successOyen.width.toInt()}"'),
        );
        expect(success, contains(place(ResultArt.successBowl)));
        final vase = _read('07-hasil-vas-pecah.html');
        expect(vase, contains(place(ResultArt.vaseOyen)));
        expect(vase, contains('size="${ResultArt.vaseOyen.width.toInt()}"'));
        expect(vase, contains(place(ResultArt.vaseBowl)));
        expect(
          vase,
          contains(
            'width="${ResultArt.vaseBowl.width.toInt()}" '
            'height="${ResultArt.vaseBowl.height.toInt()}"',
          ),
        );
      });
    });
  }, skip: missing);
}
