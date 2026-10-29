import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/language.dart';
import 'package:kucing_oren/screens/room/room_screen.dart';

import '../test_helpers.dart';

/// Locale yang dipakai layar Beranda.
Locale _locale(WidgetTester tester) =>
    Localizations.localeOf(tester.element(find.byType(RoomScreen)));

void main() {
  testWidgets('bahasa awal mengikuti HP kalau didukung', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pt', 'BR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(
      tester,
      progress: testProgressWith(language: AppLanguage.system),
    );
    expect(_locale(tester), const Locale('pt'));
  });

  testWidgets('bahasa HP yang tidak didukung jatuh ke Inggris', (tester) async {
    tester.platformDispatcher.localesTestValue = const [
      Locale('fr', 'FR'),
      Locale('ja'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(
      tester,
      progress: testProgressWith(language: AppLanguage.system),
    );
    expect(_locale(tester), const Locale('en'));
  });

  testWidgets('bahasa HP diganti saat aplikasi terbuka', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(
      tester,
      progress: testProgressWith(language: AppLanguage.system),
    );
    expect(_locale(tester), const Locale('en'));
    tester.platformDispatcher.localesTestValue = const [Locale('ru', 'RU')];
    await settle(tester);
    expect(_locale(tester), const Locale('ru'));
  });

  testWidgets('pilihan pemain menang atas HP dan langsung dipakai', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final progress = await pumpApp(
      tester,
      progress: testProgressWith(language: AppLanguage.ru),
    );
    expect(_locale(tester), const Locale('ru'));
    await progress.setLanguage(AppLanguage.id);
    await settle(tester);
    expect(_locale(tester), const Locale('id'));
    await progress.setLanguage(AppLanguage.system);
    await settle(tester);
    expect(_locale(tester), const Locale('en'));
  });

  testWidgets('judul aplikasi Ginger Logic', (tester) async {
    await pumpApp(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ginger Logic');
  });
}
