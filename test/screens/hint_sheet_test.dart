import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/hint_source.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/screens/level/hint_sheet.dart';
import 'package:kucing_oren/theme/theme.dart';

import '../test_helpers.dart';

const _tier1 =
    'Lihat petak yang menyala. Ada benda yang harus ditaruh di situ.';
const _tier2 =
    'Taruh ember air di petak yang menyala. Oyen bakal kaget dan balik badan.';
const _adFailed = 'Iklannya belum bisa diputar. Coba lagi nanti, ya.';

/// Halaman uji: satu tombol yang membuka sheet Petunjuk level [id].
Future<void> _open(WidgetTester tester, HintSource hints, {int id = 13}) async {
  setScreenSize(tester, const Size(390, 844));
  final level = testLevels.firstWhere((l) => l.id == id);
  await tester.pumpWidget(
    MaterialApp(
      theme: KoTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () =>
                  showHintSheet(context, level: level, hints: hints),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
}

/// Kartu tingkat [n] (1–3).
Finder _card(int n) => find.byKey(ValueKey('hint-tier-$n'));

Finder _inCard(int n, String text) =>
    find.descendant(of: _card(n), matching: find.text(text));

void main() {
  testWidgets('tampilan awal seperti desain 10', (tester) async {
    await _open(tester, testProgressWith(coins: 120));
    expect(find.text('Petunjuk'), findsOneWidget);
    expect(
      find.text('Buka pelan-pelan. Siapa tahu kamu cuma butuh dorongan kecil.'),
      findsOneWidget,
    );
    expect(find.text('120'), findsOneWidget);
    expect(find.bySemanticsLabel('120 koin'), findsOneWidget);
    expect(_inCard(1, 'Sorot petak pertama'), findsOneWidget);
    expect(_inCard(1, 'Tingkat 1'), findsOneWidget);
    expect(_inCard(1, '20 koin'), findsOneWidget);
    expect(_inCard(2, 'Tunjukkan jenis benda'), findsOneWidget);
    expect(_inCard(2, 'Buka tingkat 1 dulu'), findsOneWidget);
    expect(_inCard(3, 'Tampilkan solusi lengkap'), findsOneWidget);
    expect(_inCard(3, 'Buka tingkat 2 dulu'), findsOneWidget);
    expect(_inCard(3, '80 koin'), findsOneWidget);
    expect(find.text('Tonton iklan'), findsNWidgets(3));
  });

  testWidgets('urutan buka tingkat dan koin berkurang', (tester) async {
    final hints = testProgressWith(coins: 120);
    await _open(tester, hints);

    // Tingkat 2 belum bisa dibuka.
    await tester.tap(_inCard(2, '40 koin'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(hints.hintTier(13), 0);

    await tester.tap(_inCard(1, '20 koin'));
    await tester.pumpAndSettle();
    expect(hints.coins, 100);
    expect(find.text('100'), findsOneWidget);
    expect(_inCard(1, 'Terbuka'), findsOneWidget);
    expect(_inCard(1, _tier1), findsOneWidget);
    expect(_inCard(1, 'Tonton iklan'), findsNothing);
    expect(_inCard(2, 'Tingkat 2'), findsOneWidget);

    await tester.tap(_inCard(2, 'Tonton iklan'));
    await tester.pumpAndSettle();
    expect(hints.coins, 100);
    expect(hints.hintTier(13), 2);
    expect(_inCard(2, _tier2), findsOneWidget);
    expect(_inCard(3, '80 koin'), findsOneWidget);
  });

  testWidgets('koin kurang: label berubah, ketukan tidak membuka', (
    tester,
  ) async {
    final hints = testProgressWith(coins: 10);
    await _open(tester, hints);
    expect(_inCard(1, 'Koin kurang · 20'), findsOneWidget);
    await tester.tap(_inCard(1, 'Koin kurang · 20'));
    await tester.pumpAndSettle();
    expect(hints.hintTier(13), 0);
    expect(hints.coins, 10);
  });

  testWidgets('iklan gagal: tingkat tetap tertutup dan ada pesan', (
    tester,
  ) async {
    final hints = testProgressWith(ads: FakeRewardedAds(succeed: false));
    await _open(tester, hints);
    await tester.tap(_inCard(1, 'Tonton iklan'));
    await tester.pumpAndSettle();
    expect(hints.hintTier(13), 0);
    expect(_inCard(1, _adFailed), findsOneWidget);
  });

  testWidgets('tombol nonaktif selama iklan berjalan', (tester) async {
    final ads = _SlowAds();
    final hints = testProgressWith(coins: 100, ads: ads);
    await _open(tester, hints);
    await tester.tap(_inCard(1, 'Tonton iklan'));
    await tester.pump();
    await tester.tap(_inCard(1, '20 koin'), warnIfMissed: false);
    await tester.pump();
    expect(hints.coins, 100);
    ads.finish(true);
    await tester.pumpAndSettle();
    expect(hints.hintTier(13), 1);
    expect(hints.coins, 100);
  });

  testWidgets('level tanpa benda: pesan gratis tanpa tingkat', (tester) async {
    await _open(tester, testProgressWith(coins: 120), id: 1);
    expect(
      find.text('Level ini nggak butuh benda. Langsung bangunkan Oyen!'),
      findsOneWidget,
    );
    expect(find.text('Tonton iklan'), findsNothing);
    expect(_card(1), findsNothing);
  });

  testWidgets('tingkat yang sudah terbuka tampil saat sheet dibuka', (
    tester,
  ) async {
    await _open(tester, testProgressWith(hints: {13: 3}));
    expect(find.text('Terbuka'), findsNWidgets(3));
    expect(
      _inCard(
        3,
        'Ember air dan ikan asin di petak yang menyala. Vas aman, 3 bintang.',
      ),
      findsOneWidget,
    );
  });

  group('menutup sheet', () {
    testWidgets('tombol Tutup', (tester) async {
      await _open(tester, testProgressWith());
      await tester.tap(find.bySemanticsLabel('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Petunjuk'), findsNothing);
    });

    testWidgets('ketuk latar', (tester) async {
      await _open(tester, testProgressWith());
      await tester.tapAt(const Offset(195, 10));
      await tester.pumpAndSettle();
      expect(find.text('Petunjuk'), findsNothing);
    });

    testWidgets('tombol kembali sistem', (tester) async {
      await _open(tester, testProgressWith());
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Petunjuk'), findsNothing);
      expect(find.text('buka'), findsOneWidget);
    });

    testWidgets('tarik ke bawah', (tester) async {
      await _open(tester, testProgressWith());
      await tester.drag(find.text('Petunjuk'), const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(find.text('Petunjuk'), findsNothing);
    });
  });
}

/// Iklan yang selesai saat [finish] dipanggil.
class _SlowAds implements RewardedAds {
  final _pending = <void Function(bool)>[];

  @override
  Future<bool> show() {
    final done = Completer<bool>();
    _pending.add(done.complete);
    return done.future;
  }

  void finish(bool watched) {
    for (final complete in _pending) {
      complete(watched);
    }
    _pending.clear();
  }
}
