import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_areas.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/render/v2/art_pack.dart';
import 'package:kucing_oren/l10n/l10n.dart';
import 'package:kucing_oren/l10n/names.dart';
import 'package:kucing_oren/screens/room/home_labels.dart';
import 'package:kucing_oren/screens/room/home_view.dart';
import 'package:kucing_oren/widgets/v2/ui_button.dart';

import '../test_helpers.dart';
import 'home_v2_test.dart' as home;

/// Langkah 14c: header, tab, dan panel rumah ringkas seperti konsep A.
void main() {
  setUpAll(() async {
    home.pack = await ArtPack.load();
  });

  Future<AppLocalizations> pump(WidgetTester t, {HomeArea? area}) async {
    setScreenSize(t, const Size(390, 844));
    final c = await home.load(
      home: Home(kitties: [KittyId.oyen, KittyId.salju]),
    );
    if (area != null) await c.setHomeArea(area);
    c.selectHomeKitty(KittyId.oyen);
    await home.pumpHome(t, c);
    return t.element(find.byType(HomeView)).l10n;
  }

  Rect rectOf(WidgetTester t, String key) => t.getRect(home.button(key));

  testWidgets('kamar lebih tinggi dan tanpa baris judul area', (t) async {
    final l = await pump(t);
    final scene = t.getRect(find.byKey(const ValueKey('home-scene')));
    expect(scene.height, greaterThanOrEqualTo(440)); // lama: 414
    // Judul area hanya ada di tab, bukan baris sendiri.
    expect(find.text(homeAreaLabel(l, HomeArea.santai)), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('tab area satu baris chip ringkas, hitungan di semantik', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    final l = await pump(t);
    final tops = <double>{};
    for (final a in HomeArea.values) {
      final label = l.homeAreaCount(homeAreaLabel(l, a), 0, a.capacity);
      expect(label, isNotEmpty);
      tops.add(t.getRect(find.byKey(ValueKey('home-tab-${a.name}'))).top);
    }
    expect(tops, hasLength(1));
    final strip = t.getRect(find.byKey(const ValueKey('home-tabs')));
    expect(strip.height, lessThanOrEqualTo(60));
    expect(
      find.bySemanticsLabel(
        l.homeAreaCount(homeAreaLabel(l, HomeArea.santai), 2, 3),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('bantuan dan Hias berupa ikon di pojok kamar', (t) async {
    final semantics = t.ensureSemantics();
    final l = await pump(t);
    final scene = t.getRect(find.byKey(const ValueKey('home-scene')));
    for (final key in ['home-help', 'home-decorate']) {
      final r = rectOf(t, key);
      expect(r.shortestSide, greaterThanOrEqualTo(48));
      expect(scene.contains(r.center), isTrue, reason: key);
      expect(r.center.dy, lessThan(scene.top + 80), reason: key);
    }
    expect(find.bySemanticsLabel(l.decorate), findsOneWidget);
    expect(find.bySemanticsLabel(l.guidanceHomeTitle), findsOneWidget);
    await home.tap(t, home.button('home-help'));
    expect(find.text(l.guidanceHomeBody), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('panel kucing satu baris dengan dua aksi berikon', (t) async {
    await pump(t);
    await home.export(t, '14c-santai');
    final panel = t.getRect(home.button('home-selection'));
    expect(panel.height, lessThanOrEqualTo(80));
    final actions = t
        .widgetList<UiButton>(
          find.descendant(
            of: home.button('home-selection'),
            matching: find.byType(UiButton),
          ),
        )
        .toList();
    expect(actions, hasLength(2));
    expect(actions.every((b) => b.icon != null), isTrue);
  });

  testWidgets('nama kucing panjang mengecil, tidak terpotong', (t) async {
    setScreenSize(t, const Size(360, 640));
    final c = await home.load(
      language: AppLanguage.en,
      home: Home(kitties: [KittyId.oyen, KittyId.arang]),
    );
    c.selectHomeKitty(KittyId.arang);
    await home.pumpHome(t, c);
    final l = t.element(find.byType(HomeView)).l10n;
    final name = find.text(kittyName(l, KittyId.arang));
    expect(name, findsOneWidget);
    final text = t.widget<Text>(name);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(
      find.ancestor(of: name, matching: find.byType(FittedBox)),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('chip status area dan hadiah di bawah panel', (t) async {
    final l = await pump(t, area: HomeArea.makan);
    await home.export(t, '14c-makan');
    expect(find.byKey(const ValueKey('dining-panel')), findsNothing);
    final chip = rectOf(t, 'dining-choose');
    final reward = rectOf(t, 'home-rewards');
    final panel = rectOf(t, 'home-selection');
    expect(chip.top, greaterThan(panel.bottom - 1));
    expect((chip.center.dy - reward.center.dy).abs(), lessThan(4));
    expect(find.text(l.homeStatusBowl(2, 2)), findsOneWidget);
    expect(
      find.descendant(
        of: home.button('home-rewards'),
        matching: find.textContaining(
          l.homeRewardAvailable(0).split(' ·').first,
        ),
      ),
      findsOneWidget,
    );
    await home.tap(t, home.button('dining-choose'));
    expect(find.text(l.diningStock(2, 2)), findsOneWidget);
    expect(find.text(l.diningFresh), findsOneWidget);
  });
}
