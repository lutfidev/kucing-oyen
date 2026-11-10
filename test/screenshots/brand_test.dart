// Generator ikon launcher, splash Android, dan gambar Play Store:
//
//   flutter test test/screenshots/brand_test.dart --dart-define=BRAND=true
//
// Menulis PNG ke android/app/src/main/res/ dan docs/store/ (ikut di-commit),
// juga values/colors.xml dari KoUi v2. Gambar memakai sprite Oyen desain
// (lib/game/render/brand_art.dart), bukan gambar ulang. Tanpa define di
// atas, semua dilewati.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/progress_snapshot.dart';
import 'package:kucing_oren/game/model/progress.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/needs.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/run_clock.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/game/sim/sim.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/shop/shop_tab.dart';
import 'package:kucing_oren/theme/theme.dart';
import 'package:kucing_oren/theme/ko_ui.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/game/render/v2/cat_rig.dart';
import 'package:kucing_oren/game/render/v2/puzzle_art.dart';
import 'package:kucing_oren/game/render/v2/painted_scenery.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
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

const _cream = KoUi.cream;

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
  late ArtPack pack;
  setUpAll(() async {
    if (brandEnabled) pack = await ArtPack.load();
  });
  test('values/colors.xml dari KoUi v2', () {
    File('$_res/values/colors.xml').writeAsStringSync(
      '<?xml version="1.0" encoding="utf-8"?>\n'
      '<!-- Dibuat test/screenshots/brand_test.dart dari KoUi v2. -->\n'
      '<resources>\n'
      '    <color name="cream">${_hex(_cream)}</color>\n'
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
              decoration: BoxDecoration(color: _cream, shape: BoxShape.circle),
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
          color: _cream,
          child: const Center(child: _Head(width: 300)),
        ),
      ),
      '$_store/icon-512.png',
    );
  }, skip: !brandEnabled);

  for (final language in AppLanguage.supported) {
    testWidgets('feature graphic 1024×500 ${language.name}', (tester) async {
      await _shoot(
        tester,
        _frame(
          512,
          250,
          const _FeatureGraphic(),
          locale: Locale(language.name),
        ),
        language == AppLanguage.en
            ? '$_store/feature-graphic.png'
            : '$_store/feature-graphic-${language.name}.png',
        pixelRatio: 2,
      );
    }, skip: !brandEnabled);
  }

  testWidgets('preview masks and four splash locales', (tester) async {
    setScreenSize(tester, const Size(800, 600));
    await _shoot(
      tester,
      _frame(
        760,
        540,
        ColoredBox(
          color: KoUi.cream,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final circular in [true, false])
                    ClipRRect(
                      borderRadius: BorderRadius.circular(circular ? 60 : 24),
                      child: ColoredBox(
                        color: KoUi.peach,
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: Center(child: _Head(width: 76)),
                        ),
                      ),
                    ),
                  const ColoredBox(
                    color: KoUi.ink,
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Center(
                        child: _Head(width: 76, mono: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final language in AppLanguage.supported)
                    SizedBox(
                      width: 174,
                      height: 260,
                      child: Builder(
                        builder: (context) => Localizations.override(
                          context: context,
                          locale: Locale(language.name),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Head(width: 110),
                              SizedBox(height: 56),
                              SizedBox(
                                height: 70,
                                child: FittedBox(
                                  child: SizedBox(
                                    width: 200,
                                    height: 80,
                                    child: _Branding(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      'docs/design-v2/store/launcher-splash-preview.png',
    );
  }, skip: !brandEnabled);

  // Delapan potret toko per bahasa; fase jalan tambahan untuk dokumentasi.
  for (final language in AppLanguage.supported) {
    final l = lookupAppLocalizations(Locale(language.name));
    final folder = '$_store/screenshots/${language.name}';
    Future<void> shoot(
      WidgetTester tester,
      String name,
      String location,
      Future<void> Function() prepare, {
      HomeArea area = HomeArea.santai,
    }) async {
      setScreenSize(tester, const Size(432, 768));
      final c = ProgressController(
        levels: testLevels,
        store: _ScreenshotStore(),
        progress: Progress({...wonUpTo(8), 9: 1, 10: 1, 11: 3, 12: 2}),
        tutorialsDone: tutorialLevels,
        coins: 480,
        home: _storeHome(),
        needs: HomeNeeds(
          cats: {
            for (final cat in KittyId.values)
              cat: CatNeeds(
                hunger: 55,
                joy: 55,
                at: DateTime(2026, 11, 10, 12),
              ),
          },
        ),
        language: language,
        clock: () => DateTime(2026, 11, 10, 12),
      );
      expect(await c.setHomeArea(area), isTrue);
      expect(c.household.lastArea, area);
      await withShadows(() async {
        await tester.pumpWidget(
          capturable(
            KucingOrenApp(
              key: UniqueKey(),
              progress: c,
              initialLocation: location,
              roomLife: false,
              roomRandom: () => Random(1),
              loadShopArt: () async => pack,
              homeBuilder: (_) =>
                  HomeView(progress: c, life: false, loadArt: () async => pack),
            ),
          ),
        );
        await tester.pump();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(KucingOrenApp));
          for (final image in [
            PaintedScenery.lounge,
            PaintedScenery.dining,
            PaintedScenery.play,
            PaintedScenery.care,
          ]) {
            await precacheImage(image, context);
          }
        });
        await settle(tester);
        await prepare();
        expect(tester.takeException(), isNull);
        if (!name.startsWith('09-')) {
          await captureFile(tester, '$folder/$name.png', pixelRatio: 2.5);
        }
        if (language == AppLanguage.id) {
          await captureFile(
            tester,
            'docs/screenshots/$name.png',
            pixelRatio: 2,
          );
        }
      });
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    }

    final level13 = AppRoutes.level(13, chapter: 2);
    testWidgets('${language.name}/toko', (tester) async {
      await shoot(tester, '01-santai', AppRoutes.home, () async {});
      for (final area in [HomeArea.makan, HomeArea.main, HomeArea.rawat]) {
        await shoot(
          tester,
          '0${area.index + 1}-${area.name}',
          AppRoutes.home,
          () async {},
          area: area,
        );
      }
      await shoot(
        tester,
        '05-toko-aksesoris',
        AppRoutes.shop(tab: ShopTab.accessories),
        () async {
          // Pratinjau aksesoris yang belum dimiliki di Oyen, tanpa membeli.
          await tester.ensureVisible(
            find.byKey(const ValueKey('shop-accessory-jepitBunga')),
          );
          await tester.tap(
            find.byKey(const ValueKey('shop-accessory-jepitBunga')),
          );
          await tester.ensureVisible(
            find.text(l.shopPreviewOf(kittyName(l, KittyId.oyen))),
          );
          await settle(tester);
        },
      );
      await shoot(tester, '06-peta-babak-2', AppRoutes.chapter(2), () async {});
      await shoot(tester, '07-fase-atur-level-13', level13, () async {});
      await shoot(tester, '09-fase-jalan-level-13', level13, () async {
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
      await shoot(tester, '08-berhasil-level-13', level13, () async {
        await placeItems(tester, [
          (itemName(l, Item.water), 3, 3),
          (itemName(l, Item.fish), 2, 4),
        ]);
        await showResult(tester, l);
      });
    }, skip: !brandEnabled);
  }
}

/// Sembilan kucing tersebar 3/2/2/2 melalui migrasi runtime normal.
/// Furnitur/aksesoris dimiliki sebagai data contoh, tanpa menyentuh pemain.
Home _storeHome() {
  var room = Room();
  for (final id in const [
    RoomItemId.karpet,
    RoomItemId.lukisan,
    RoomItemId.rak,
    RoomItemId.tiang,
    RoomItemId.kasur,
    RoomItemId.bola,
    RoomItemId.kardus,
    RoomItemId.monstera,
    RoomItemId.catnip,
  ]) {
    room = room.buy(id);
  }
  return Home(
    room: room,
    kitties: KittyId.values,
    closet: AccessoryCloset(
      owned: const [
        AccessoryId.pita,
        AccessoryId.kalung,
        AccessoryId.bandana,
        AccessoryId.beanie,
      ],
      wearing: const {
        KittyId.oyen: AccessoryId.bandana,
        KittyId.salju: AccessoryId.pita,
        KittyId.arang: AccessoryId.kalung,
        KittyId.mochi: AccessoryId.beanie,
      },
    ),
    pantry: Pantry(const {SnackId.ikanAsin: 3, SnackId.biskuit: 5}),
  );
}

/// Feature graphic (512×250 dp, dipotret ×2): Oyen rig v2 di kiri, logo
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
          const SizedBox(
            width: 190,
            height: 190,
            child: CustomPaint(painter: _FeatureCat()),
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

class _FeatureCat extends CustomPainter {
  const _FeatureCat();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 128);
    const CatRig(motion: CatMotion.sit).paint(canvas, PuzzleArt.cat);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FeatureCat old) => false;
}

// Production-style atomic writes, isolated from device/player preferences.
class _ScreenshotStore extends MemoryProgressStore implements SnapshotStore {
  Map<String, dynamic>? snapshot;
  @override
  Future<Map<String, dynamic>?> readSnapshot() async => snapshot;
  @override
  Future<void> writeSnapshot(Map<String, Object?> value) async {
    snapshot = Map<String, dynamic>.from(value);
  }
}
