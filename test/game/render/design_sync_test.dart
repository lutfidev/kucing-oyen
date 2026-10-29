import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/game/render/design_svg.dart';
import 'package:kucing_oren/game/render/design_svg_home.dart';
import 'package:kucing_oren/game/render/map_art.dart';
import 'package:kucing_oren/game/render/result_art.dart';
import 'package:kucing_oren/game/render/room_art.dart';

/// `docs/design/` tidak ikut repo; test ini hanya jalan di komputer yang
/// punya ekspor desainnya.
const _source = 'docs/design/source';

/// Desain rumah Oyen (langkah 21-26) ada di folder sendiri.
const _home = 'docs/design/rumah-oyen/project';

/// Akhir baris disamakan (checkout Windows bisa CRLF), tepi dibuang.
String _lf(String s) => s.replaceAll('\r\n', '\n').trim();

String _read(String name) => _lf(File('$_source/$name').readAsStringSync());

String _readHome(String name) => _lf(File('$_home/$name').readAsStringSync());

/// Isi `<svg>` pertama di komponen desain rumah Oyen (penutupnya bisa
/// menjorok).
String _innerHome(String name) => _lf(
  RegExp(
    r'<svg\b[^>]*>\n(.*?)\n\s*</svg>',
    dotAll: true,
  ).firstMatch(_readHome(name))![1]!,
);

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

    group('Beranda dan peta babak', () {
      /// Setiap baris salinan ada di desain (salinan boleh dipotong).
      void linesIn(String svg, String source) {
        for (final line in _lf(svg).split('\n')) {
          expect(source, contains(line.trim()), reason: line);
        }
      }

      test('ikon dapur, area bos, dan ketupat disalin dari desain 02', () {
        final source = _read('02-peta-babak-2-ruang-tamu.html');
        for (final svg in [chapterKitchenSvg, bossAreaSvg, bossKetupatSvg]) {
          linesIn(svg, source);
        }
      });

      test('ikon ruang tamu dan ikan bos: bentuk dari desain 02 dan Tile', () {
        final source =
            _read('02-peta-babak-2-ruang-tamu.html') + _read('Tile.dc.html');
        for (final svg in [chapterLivingRoomSvg, bossFishSvg]) {
          final tags = RegExp(r'<(?!g\b)[a-z][^>]*>').allMatches(svg);
          expect(tags, isNotEmpty);
          for (final tag in tags) {
            expect(source, contains(tag[0]), reason: tag[0]);
          }
        }
      });

      test('letak node, jejak kaki, dan bos sama dengan desain 02', () {
        final source = _read('02-peta-babak-2-ruang-tamu.html');
        final points = MapArt.points
            .map((p) => '[${p.dx.toInt()}, ${p.dy.toInt()}]')
            .join(', ');
        expect(source, contains('const pts = [$points];'));
        expect(source, contains('[0.36, 0.64].forEach'));
        expect(source, contains('const off = k === 0 ? 5 : -5;'));
        expect(
          source,
          contains('opacity: \' + (i + 1 < current ? 0.95 : 0.4)'),
        );
        expect(source, contains('animation: koPulse 1.4s ease-out infinite'));
        expect(source, contains('100%{transform:scale(1.45);opacity:0}'));
        final boss = MapArt.points.last;
        // Kotak bos 106 px (label) di kiri 147, atas 642: tengah kotak 96 px.
        expect(boss, const Offset(147 + 106 / 2, 642 + 96 / 2));
      });
    });

    group('lemari kostum', () {
      test('lemari disalin dari desain 12', () {
        expect(_read('12-lemari-kostum.html'), contains(_lf(closetSvg)));
      });
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

    group('kartu aturan dan tutorial', () {
      test('kartu 1–4 dan kardus terkunci disalin dari desain 05', () {
        final source = _read('05-kartu-aturan-oyen.html');
        for (final svg in [
          ruleKnockSvg,
          ruleFishSvg,
          ruleWaterSvg,
          ruleWallSvg,
          ruleWallCatSvg,
          ruleBoxLockedSvg,
        ]) {
          expect(source, contains(_lf(svg)));
        }
        expect(
          source,
          contains(
            '@keyframes koQuarter{0%,30%{transform:rotate(0deg)}'
            '60%,100%{transform:rotate(90deg)}}',
          ),
        );
        expect(source, contains('animation: koQuarter 2.4s ease-in-out'));
      });

      test(
        'kardus terbuka dan kartu terkunci: bentuk dari desain 05 dan Tile',
        () {
          final source =
              _read('05-kartu-aturan-oyen.html') + _read('Tile.dc.html');
          for (final svg in [
            ruleBoxSvg,
            ruleKnockLockedSvg,
            ruleFishLockedSvg,
            ruleWaterLockedSvg,
            ruleWallLockedSvg,
          ]) {
            final tags = RegExp(r'<(?!g\b)[a-z][^>]*>').allMatches(svg);
            expect(tags, isNotEmpty);
            for (final tag in tags) {
              expect(source, contains(tag[0]), reason: tag[0]);
            }
          }
        },
      );

      test('tangan penunjuk dan geraknya dari desain 11', () {
        final source = _read('11-tutorial-level-1.html');
        expect(source, contains(_lf(tutorialHandSvg)));
        expect(source, contains('width="52" height="64"'));
        expect(
          source,
          contains('50%{transform:translateY(10px) rotate(180deg)}'),
        );
        expect(source, contains('animation: koTap 1s ease-in-out infinite'));
        expect(source, contains('animation: koRing 1.4s ease-out infinite'));
        expect(source, contains('box-shadow:0 0 0 16px rgba(245,154,51,0)'));
      });
    });
  }, skip: missing);

  final homeMissing = !Directory(_home).existsSync()
      ? '$_home tidak ada (desain tidak ikut repo)'
      : null;

  group('isi SVG sama dengan desain rumah Oyen', () {
    test('Kucing.dc.html', () {
      expect(_lf(kittySvg), _innerHome('Kucing.dc.html'));
    });

    test('IkonAksesoris.dc.html', () {
      expect(_lf(accessoryIconSvg), _innerHome('IkonAksesoris.dc.html'));
    });

    test('Barang.dc.html: dua lapisan tiap barang dan camilan', () {
      final source = _readHome('Barang.dc.html');
      final cut = source.indexOf('sc-if value="{{pakai}}"');
      expect(cut, greaterThan(0));
      final back = <String, String>{};
      final front = <String, String>{};
      final boxes = <String, String>{};
      final pattern = RegExp(
        r'<sc-if value="\{\{v\.(\w+)\}\}"[^>]*>\s*<svg\b([^>]*)>\n'
        r'(.*?)\n\s*</svg>\s*</sc-if>',
        dotAll: true,
      );
      for (final m in pattern.allMatches(source)) {
        final code = m[1]!;
        (m.start < cut ? back : front)[code] = _lf(m[3]!);
        boxes.putIfAbsent(
          code,
          () => RegExp(r'viewBox="([-\d. ]+)"').firstMatch(m[2]!)![1]!,
        );
      }
      expect(back, hasLength(24));
      expect(front, hasLength(8));
      expect(roomItemBackSvgs.keys, back.keys.toSet());
      expect(roomItemFrontSvgs.keys, front.keys.toSet());
      for (final MapEntry(:key, :value) in roomItemBackSvgs.entries) {
        expect(_lf(value), back[key], reason: key);
      }
      for (final MapEntry(:key, :value) in roomItemFrontSvgs.entries) {
        expect(_lf(value), front[key], reason: key);
      }
      expect(roomItemViewBoxes.keys, boxes.keys.toSet());
      for (final MapEntry(:key, :value) in roomItemViewBoxes.entries) {
        final (x, y, w, h) = value;
        expect(boxes[key]!.split(' ').map(double.parse).toList(), [
          x,
          y,
          w,
          h,
        ], reason: key);
      }
    });

    test('Kamar.dc.html: jendela dan dekor lantai', () {
      final source = _readHome('Kamar.dc.html');
      expect(source, contains(_lf(roomWindowSvg)));
      expect(source, contains(_lf(roomFloorDecorSvg)));
      expect(
        source,
        contains(
          'left: ${RoomArt.windowBox.left.toInt()}px; '
          'top: ${RoomArt.windowBox.top.toInt()}px',
        ),
      );
    });

    test('TandaLesu.dc.html', () {
      expect(_lf(sadMarkSvg), _innerHome('TandaLesu.dc.html'));
    });
  }, skip: homeMissing);
}
