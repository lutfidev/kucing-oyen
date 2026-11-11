// V2 documentation scenarios. Store portraits live in brand_test.dart.
// flutter test test/screenshots/screenshot_test.dart --dart-define=SCREENSHOTS=true
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/app.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/screens/shop/shop_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../test_helpers.dart';
import 'capture.dart';

void main() {
  late ArtPack pack;
  setUpAll(() async {
    if (screenshotsEnabled) pack = await ArtPack.load();
    PackageInfo.setMockInitialValues(
      appName: 'Ginger Logic',
      packageName: 'com.gingerlogic.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });
  // Player routes only. Legacy design galleries are not store material.
  final routes = {
    '10-peta-babak-1': AppRoutes.chapter(1),
    '11-toko-barang': AppRoutes.shop(tab: ShopTab.items),
    '12-koleksi-kucing': AppRoutes.shop(tab: ShopTab.kitties),
    '13-toko-camilan': AppRoutes.shop(tab: ShopTab.snacks),
    '14-pengaturan': AppRoutes.settings,
  };
  for (final language in AppLanguage.supported) {
    for (final entry in routes.entries) {
      testWidgets('v2/${language.name}/${entry.key}', (t) async {
        setScreenSize(t, const Size(390, 844));
        final c = testProgressWith(
          best: wonUpTo(12),
          coins: 480,
          language: language,
          clock: () => DateTime(2026, 11, 10, 12),
        );
        await withShadows(() async {
          await t.pumpWidget(
            capturable(
              KucingOrenApp(
                progress: c,
                initialLocation: entry.value,
                roomLife: false,
                loadShopArt: () async => pack,
              ),
            ),
          );
          await settle(t);
          expect(t.takeException(), isNull);
          await capture(t, '${language.name}/${entry.key}');
        });
        await t.pumpWidget(const SizedBox());
        c.dispose();
      }, skip: !screenshotsEnabled);
    }
  }
}
