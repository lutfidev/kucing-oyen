import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/sounds.dart';
import 'package:kucing_oren/screens/room/room_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Iklan yang selesai saat [finish] dipanggil.
class _WaitingAds implements RewardedAds {
  final _done = Completer<bool>();

  void finish() => _done.complete(true);

  @override
  Future<bool> show() => _done.future;
}

void main() {
  test('lagu per rute', () {
    expect(musicFor(AppRoutes.home), MusicTrack.home);
    expect(musicFor(AppRoutes.chapter(2)), MusicTrack.home);
    expect(musicFor(AppRoutes.shop()), MusicTrack.home);
    expect(musicFor(AppRoutes.settings), MusicTrack.home);
    expect(musicFor(AppRoutes.gallery), MusicTrack.home);
    expect(musicFor(AppRoutes.level(13, chapter: 2)), MusicTrack.level);
  });

  testWidgets('Beranda memutar lagu Beranda, level memutar lagu level', (
    tester,
  ) async {
    final audio = testAudio();
    final player = audio.player as FakeSoundPlayer;
    await pumpApp(tester, audio: audio);
    expect(player.music, MusicTrack.home);

    GoRouter.of(tester.element(find.byType(RoomScreen)))
        .go(AppRoutes.level(1, chapter: 1));
    await tester.pumpAndSettle();
    expect(player.music, MusicTrack.level);

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is KoIconButton && w.semanticLabel == l10nId.backToMap,
      ),
    );
    await settle(tester);
    expect(player.music, MusicTrack.home);
    expect(player.musicStarts, 3);
  });

  testWidgets('dibuka langsung di level: lagu level', (tester) async {
    final audio = testAudio();
    await pumpApp(
      tester,
      location: AppRoutes.level(13, chapter: 2),
      audio: audio,
    );
    expect((audio.player as FakeSoundPlayer).music, MusicTrack.level);
  });

  testWidgets('musik dijeda di latar belakang dan lanjut sesudahnya', (
    tester,
  ) async {
    final audio = testAudio();
    final player = audio.player as FakeSoundPlayer;
    await pumpApp(tester, audio: audio);

    // Urutan seperti di perangkat.
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
    await tester.pump();
    expect(player.musicPaused, isTrue);

    lifecycle([hidden, inactive, resumed]);
    await tester.pump();
    expect(player.musicPaused, isFalse);
    expect(player.music, MusicTrack.home);
  });

  testWidgets('musik dijeda selama iklan koin dari Beranda', (tester) async {
    final player = FakeSoundPlayer();
    final audio = GameAudio(player: player, store: MemoryProgressStore());
    final ads = _WaitingAds();
    await pumpApp(
      tester,
      audio: audio,
      progress: testProgressWith(ads: audio.pauseDuringAds(ads)),
    );
    await tester.tap(find.byType(KoCoinChip));
    await settle(tester);
    await tester.tap(find.text('+20 koin'));
    await tester.pump();
    expect(player.musicPaused, isTrue);

    ads.finish();
    await settle(tester);
    expect(player.musicPaused, isFalse);
  });

  testWidgets('galeri suara: kartu memutar suaranya tanpa bunyi tap', (
    tester,
  ) async {
    final audio = testAudio();
    final player = audio.player as FakeSoundPlayer;
    await pumpApp(tester, location: AppRoutes.gallery, audio: audio);
    await tester.tap(find.text('Suara'));
    await tester.pumpAndSettle();
    player.played.clear();

    await tester.tap(find.byKey(const ValueKey('sound-vase')));
    expect(player.played, [GameSound.vase]);

    // Daftar efek panjang: kartu lagu baru dibangun sesudah digulir.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('music-level')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('music-level')));
    await tester.pump();
    expect(player.music, MusicTrack.level);
  });
}
