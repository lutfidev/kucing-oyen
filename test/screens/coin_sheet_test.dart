import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/rewards.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/game/render/render.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

const _adFailed = 'Iklannya belum bisa diputar. Coba lagi nanti, ya.';
final _now = DateTime(2026, 10, 19, 9);
final _today = dayNumber(_now);

ProgressController _progress({
  int coins = 0,
  DailyRewards rewards = DailyRewards.initial,
  RewardedAds? ads,
}) => testProgressWith(
  coins: coins,
  rewards: rewards,
  ads: ads,
  clock: () => _now,
);

/// Beranda 390×844 dengan [progress], lalu ketuk chip koin.
Future<ProgressController> _openFromHome(
  WidgetTester tester,
  ProgressController progress, {
  GameAudio? audio,
}) async {
  setScreenSize(tester, const Size(390, 844));
  await pumpApp(tester, progress: progress, audio: audio);
  await _tap(tester, find.byType(KoCoinChip));
  return progress;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await settle(tester);
}

Finder _card(String name) => find.byKey(ValueKey('coin-$name'));

Finder _inCard(String name, String text) =>
    find.descendant(of: _card(name), matching: find.text(text));

/// Tombol berlabel [label] bisa ditekan.
bool _enabled(WidgetTester tester, String label) =>
    tester
        .widget<KoPressable>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(KoPressable),
          ),
        )
        .onPressed !=
    null;

void main() {
  testWidgets('Beranda: titik bonus, chip membuka sheet Tambah Koin', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(tester, progress: _progress(coins: 120));
    expect(find.byKey(const ValueKey('coin-badge')), findsOneWidget);
    expect(
      find.bySemanticsLabel('120 koin, tambah koin, bonus harian siap'),
      findsOneWidget,
    );

    await _tap(tester, find.byType(KoCoinChip));
    expect(find.text('Tambah Koin'), findsOneWidget);
    expect(
      find.text(
        'Koin buat petunjuk dan kostum Oyen. '
        'Ambil bonus tiap hari, atau tonton iklan.',
      ),
      findsOneWidget,
    );
    expect(_inCard('bonus', 'Bonus harian'), findsOneWidget);
    expect(_inCard('bonus', 'Sekali sehari'), findsOneWidget);
    expect(_inCard('bonus', 'Ambil 20 koin'), findsOneWidget);
    expect(_inCard('ad', 'Tonton iklan'), findsOneWidget);
    expect(_inCard('ad', 'Sisa 5 kali hari ini'), findsOneWidget);
    expect(_inCard('ad', '+20 koin'), findsOneWidget);
  });

  testWidgets('ambil bonus: +20 sekali, titik Beranda hilang', (tester) async {
    final progress = await _openFromHome(tester, _progress(coins: 5));
    await _tap(tester, find.text('Ambil 20 koin'));
    expect(progress.coins, 25);
    expect(find.bySemanticsLabel('25 koin'), findsOneWidget);
    expect(_inCard('bonus', 'Sudah diambil hari ini'), findsOneWidget);
    expect(_enabled(tester, 'Ambil lagi besok'), isFalse);
    await _tap(tester, find.text('Ambil lagi besok'));
    expect(progress.coins, 25);

    await _tap(tester, find.bySemanticsLabel('Tutup'));
    expect(find.text('Tambah Koin'), findsNothing);
    expect(find.byKey(const ValueKey('coin-badge')), findsNothing);
    expect(find.bySemanticsLabel('25 koin, tambah koin'), findsOneWidget);
  });

  testWidgets('kembali ke aplikasi esok hari: titik bonus muncul lagi', (
    tester,
  ) async {
    var now = _now;
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      progress: testProgressWith(
        rewards: DailyRewards(bonusDay: _today),
        clock: () => now,
      ),
    );
    expect(find.byKey(const ValueKey('coin-badge')), findsNothing);

    // Ke latar belakang lalu kembali, urutan seperti di perangkat.
    void lifecycle(List<AppLifecycleState> states) {
      for (final state in states) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
    }

    final (inactive, hidden, paused, resumed) = (
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.resumed,
    );
    lifecycle([inactive, hidden, paused]);
    now = _now.add(const Duration(days: 1));
    lifecycle([hidden, inactive, resumed]);
    await settle(tester);
    expect(find.byKey(const ValueKey('coin-badge')), findsOneWidget);
  });

  testWidgets('tonton iklan: +20, sisa berkurang', (tester) async {
    final progress = await _openFromHome(tester, _progress());
    await _tap(tester, find.text('+20 koin'));
    expect(progress.coins, 20);
    expect(_inCard('ad', 'Sisa 4 kali hari ini'), findsOneWidget);
  });

  testWidgets('iklan gagal: saldo tetap, ada pesan', (tester) async {
    final progress = await _openFromHome(
      tester,
      _progress(ads: FakeRewardedAds(succeed: false)),
    );
    await _tap(tester, find.text('+20 koin'));
    expect(progress.coins, 0);
    expect(_inCard('ad', _adFailed), findsOneWidget);
    expect(_inCard('ad', 'Sisa 5 kali hari ini'), findsOneWidget);
  });

  testWidgets('jatah iklan habis: tombol mati', (tester) async {
    final ads = FakeRewardedAds();
    await _openFromHome(
      tester,
      _progress(
        ads: ads,
        rewards: DailyRewards(adDay: _today, adsWatched: maxAdsPerDay),
      ),
    );
    expect(_inCard('ad', 'Jatah hari ini habis'), findsOneWidget);
    expect(_enabled(tester, 'Besok ada lagi'), isFalse);
    await _tap(tester, find.text('Besok ada lagi'));
    expect(ads.shown, 0);
  });

  testWidgets('tombol iklan mati selama iklan diputar', (tester) async {
    final ads = _SlowAds();
    final progress = await _openFromHome(tester, _progress(ads: ads));
    await tester.tap(find.text('+20 koin'));
    await tester.pump();
    expect(_enabled(tester, '+20 koin'), isFalse);
    await tester.tap(find.text('+20 koin'), warnIfMissed: false);
    await tester.pump();
    expect(ads.calls, 1);
    ads.finish(true);
    await settle(tester);
    expect(progress.coins, 20);
    expect(_enabled(tester, '+20 koin'), isTrue);
  });

  testWidgets('Lemari Kostum: chip membuka sheet, saldo baru dipakai', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    await pumpApp(
      tester,
      location: AppRoutes.closet,
      progress: _progress(coins: 25),
    );
    await _tap(
      tester,
      find.byKey(ValueKey('costume-${OyenCostume.kacamata.name}')),
    );
    expect(find.text('Koin kurang · 45'), findsOneWidget);
    expect(find.byKey(const ValueKey('coin-badge')), findsNothing);

    await _tap(tester, find.byType(KoCoinChip));
    expect(find.text('Tambah Koin'), findsOneWidget);
    await _tap(tester, find.text('+20 koin'));
    await _tap(tester, find.bySemanticsLabel('Tutup'));
    expect(find.text('Beli · 45 koin'), findsOneWidget);
    expect(find.byType(OyenView), findsWidgets);
  });

  group('menutup sheet', () {
    testWidgets('ketuk latar', (tester) async {
      await _openFromHome(tester, _progress());
      await tester.tapAt(const Offset(195, 10));
      await settle(tester);
      expect(find.text('Tambah Koin'), findsNothing);
    });

    testWidgets('tombol kembali sistem kembali ke Beranda', (tester) async {
      await _openFromHome(tester, _progress());
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Tambah Koin'), findsNothing);
      expect(find.text('Main'), findsOneWidget);
    });
  });

  group('suara', () {
    List<GameSound> coinSounds(GameAudio audio) =>
        playedBy(audio).where((s) => s != GameSound.tap).toList();

    testWidgets('ambil bonus harian: koin berbunyi', (tester) async {
      final audio = testAudio();
      await _openFromHome(tester, _progress(), audio: audio);
      await _tap(tester, find.text('+20 koin').first);
      expect(coinSounds(audio), [GameSound.coin]);
    });

    testWidgets('iklan selesai: koin berbunyi', (tester) async {
      final audio = testAudio();
      await _openFromHome(
        tester,
        _progress(rewards: DailyRewards(bonusDay: _today)),
        audio: audio,
      );
      await _tap(tester, find.text('+20 koin'));
      expect(coinSounds(audio), [GameSound.coin]);
    });

    testWidgets('iklan gagal: senyap', (tester) async {
      final audio = testAudio();
      await _openFromHome(
        tester,
        _progress(
          rewards: DailyRewards(bonusDay: _today),
          ads: FakeRewardedAds(succeed: false),
        ),
        audio: audio,
      );
      await _tap(tester, find.text('+20 koin'));
      expect(coinSounds(audio), isEmpty);
    });
  });
}

/// Iklan yang selesai saat [finish] dipanggil.
class _SlowAds implements RewardedAds {
  final _pending = <Completer<bool>>[];
  int calls = 0;

  @override
  Future<bool> show() {
    calls++;
    final done = Completer<bool>();
    _pending.add(done);
    return done.future;
  }

  void finish(bool watched) {
    for (final done in _pending) {
      done.complete(watched);
    }
    _pending.clear();
  }
}
