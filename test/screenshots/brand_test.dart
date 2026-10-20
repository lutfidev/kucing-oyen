// Generator ikon launcher, splash Android, dan gambar Play Store:
//
//   flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true
//
// Menulis PNG ke android/app/src/main/res/ dan docs/store/ (ikut di-commit),
// juga values/colors.xml dari KoColors. Gambar memakai sprite Oyen desain
// (lib/game/render/brand_art.dart), bukan gambar ulang. Tanpa define di
// atas, semua dilewati.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/run_clock.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';
import 'capture.dart';
import 'scenes.dart';

const bool brandEnabled = bool.fromEnvironment('BRAND');

const _res = 'android/app/src/main/res';
const _store = 'docs/store';

/// Faktor densitas Android per folder.
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

/// Folder resource per bahasa splash; Indonesia memakai kualifier lama
/// Android `in`.
const _splashLocales = {'': 'en', '-in': 'id', '-pt': 'pt', '-ru': 'ru'};

final _colors = KoTheme.light().extension<KoColors>()!;

/// Kepala Oyen selebar [width] (warna desain, atau siluet [mono]).
class _Head extends StatelessWidget {
  const _Head({required this.width, this.mono});

  final double width;
  final Color? mono;

  @override
  Widget build(BuildContext context) {
    const box = BrandArt.headBox;
    return CustomPaint(
      size: Size(width, width * box.height / box.width),
      painter: _HeadPainter(width, mono),
    );
  }
}

class _HeadPainter extends CustomPainter {
  _HeadPainter(this.width, this.mono);

  final double width;
  final Color? mono;

  @override
  void paint(Canvas canvas, Size size) {
    final mono = this.mono;
    if (mono == null) {
      paintOyenHead(canvas, width: width);
    } else {
      paintOyenHeadMono(canvas, width: width, color: mono);
    }
  }

  @override
  bool shouldRepaint(_HeadPainter old) =>
      old.width != width || old.mono != mono;
}

/// Kotak [width]×[height] dp siap dipotret, latar transparan.
Widget _frame(
  double width,
  double height,
  Widget child, {
  Locale locale = const Locale('en'),
}) => testApp(
  locale: locale,
  // Material transparan: gaya teks tanpa garis bawah kuning "tanpa Material".
  home: Material(
    type: MaterialType.transparency,
    child: Center(
      child: capturable(SizedBox(width: width, height: height, child: child)),
    ),
  ),
);

Future<void> _shoot(
  WidgetTester tester,
  Widget frame,
  String path, {
  double pixelRatio = 1,
}) async {
  await withShadows(() async {
    await tester.pumpWidget(frame);
    await tester.pumpAndSettle();
    await captureFile(tester, path, pixelRatio: pixelRatio);
  });
}

/// Logo dan tagline di bawah splash (200×80 dp).
class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return Column(
      children: [
        const Expanded(child: FittedBox(child: GameLogo())),
        // Ekor "g" di "Logic" turun di bawah kotak teksnya.
        const SizedBox(height: 8),
        Text(
          context.l10n.splashTagline,
          maxLines: 1,
          style: t.bodyLarge.copyWith(color: c.inkSoft),
        ),
      ],
    );
  }
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

void main() {
  test('values/colors.xml dari KoColors', () {
    File('$_res/values/colors.xml').writeAsStringSync(
      '<?xml version="1.0" encoding="utf-8"?>\n'
      '<!-- Dibuat test/screenshots/brand_test.dart dari KoColors. -->\n'
      '<resources>\n'
      '    <color name="cream">${_hex(_colors.cream)}</color>\n'
      '</resources>\n',
    );
  }, skip: !brandEnabled);

  for (final MapEntry(key: dpi, value: ratio) in _densities.entries) {
    testWidgets('ikon dan splash $dpi', (tester) async {
      // Ikon adaptif: kepala di zona aman 66 dp dari 108 dp (telinga di
      // dalam lingkaran itu).
      await _shoot(
        tester,
        _frame(108, 108, const Center(child: _Head(width: 52))),
        '$_res/mipmap-$dpi/ic_launcher_foreground.png',
        pixelRatio: ratio,
      );
      await _shoot(
        tester,
        _frame(
          108,
          108,
          const Center(child: _Head(width: 52, mono: Color(0xFFFFFFFF))),
        ),
        '$_res/mipmap-$dpi/ic_launcher_monochrome.png',
        pixelRatio: ratio,
      );
      // Ikon lama (Android < 8): kepala di lingkaran krem.
      await _shoot(
        tester,
        _frame(
          48,
          48,
          Center(
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _colors.cream,
                shape: BoxShape.circle,
              ),
              child: const _Head(width: 32),
            ),
          ),
        ),
        '$_res/mipmap-$dpi/ic_launcher.png',
        pixelRatio: ratio,
      );
      // Splash Android 12+: isi di lingkaran 192 dp dari 288 dp.
      await _shoot(
        tester,
        _frame(288, 288, const Center(child: _Head(width: 150))),
        '$_res/drawable-$dpi/splash_icon.png',
        pixelRatio: ratio,
      );
      for (final MapEntry(key: suffix, value: lang) in _splashLocales.entries) {
        await _shoot(
          tester,
          _frame(80 * 2.5, 80, const _Branding(), locale: Locale(lang)),
          '$_res/drawable$suffix-$dpi/splash_branding.png',
          pixelRatio: ratio,
        );
      }
    }, skip: !brandEnabled);
  }

  testWidgets('ikon Play Store 512', (tester) async {
    await _shoot(
      tester,
      _frame(
        512,
        512,
        ColoredBox(
          color: _colors.cream,
          child: const Center(child: _Head(width: 300)),
        ),
      ),
      '$_store/icon-512.png',
    );
  }, skip: !brandEnabled);

  testWidgets('feature graphic 1024×500', (tester) async {
    await _shoot(
      tester,
      _frame(512, 250, const _FeatureGraphic()),
      '$_store/feature-graphic.png',
      pixelRatio: 2,
    );
  }, skip: !brandEnabled);

  // Potret layar ponsel 1080×1920 (360×640 × 3) per bahasa.
  for (final language in AppLanguage.supported) {
    final l = lookupAppLocalizations(Locale(language.name));
    final folder = '$_store/screenshots/${language.name}';
    // Kunci per potret: aplikasi baru (rute dan progres awal) tiap potret.
    Widget app(String name, String location) => capturable(
      KucingOrenApp(
        key: ValueKey(name),
        progress: testProgressWith(
          best: {...wonUpTo(8), 9: 1, 10: 1, 11: 3, 12: 2},
          coins: 120,
          language: language,
        ),
        initialLocation: location,
      ),
    );
    Future<void> shoot(
      WidgetTester tester,
      String name,
      String location,
      Future<void> Function() prepare,
    ) async {
      setScreenSize(tester, const Size(360, 640));
      await withShadows(() async {
        await tester.pumpWidget(app(name, location));
        await settle(tester);
        await prepare();
        await captureFile(tester, '$folder/$name.png', pixelRatio: 3);
      });
    }

    final level13 = AppRoutes.level(13, chapter: 2);
    testWidgets('${language.name}/toko', (tester) async {
      await shoot(tester, '01-beranda', AppRoutes.home, () async {});
      await shoot(tester, '02-peta-babak-2', AppRoutes.chapter(2), () async {});
      await shoot(tester, '03-fase-atur-level-13', level13, () async {});
      await shoot(tester, '04-fase-jalan-level-13', level13, () async {
        await placeItems(tester, [
          (itemName(l, Item.water), 3, 3),
          (itemName(l, Item.fish), 2, 4),
        ]);
        await tester.tap(find.text(l.wakeOyen));
        await tester.pump();
        for (var i = 0; i < 2; i++) {
          await tester.pump(RunClock.stepTime);
        }
        await tester.tap(find.bySemanticsLabel(RegExp(l.pause)));
        await tester.pumpAndSettle();
      });
      await shoot(tester, '06-berhasil-level-13', level13, () async {
        await placeItems(tester, [
          (itemName(l, Item.water), 3, 3),
          (itemName(l, Item.fish), 2, 4),
        ]);
        await showResult(tester, l);
      });
      await shoot(tester, '12-lemari-kostum', AppRoutes.closet, () async {});
    }, skip: !brandEnabled);
  }
}

/// Feature graphic (512×250 dp, dipotret ×2): Oyen tidur di kiri, logo
/// dan tagline di kanan, latar krem.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    final c = context.koColors;
    final t = context.koType;
    return ColoredBox(
      color: c.cream,
      child: Row(
        children: [
          const SizedBox(width: 36),
          const OyenView(
            OyenLook(pose: OyenPose.sleep, bubble: OyenBubble.zzz),
            size: 190,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 110,
                  child: FittedBox(child: GameLogo()),
                ),
                // Ekor "g" di "Logic" turun di bawah kotak teksnya.
                const SizedBox(height: 22),
                Text(
                  context.l10n.tagline,
                  textAlign: TextAlign.center,
                  style: t.bodyLarge.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}
