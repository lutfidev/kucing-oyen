import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/game_audio.dart';
import 'package:kucing_oren/app/progress_store.dart';
import 'package:kucing_oren/app/rewarded_ads.dart';
import 'package:kucing_oren/app/sound_player.dart';
import 'package:kucing_oren/game/model/sounds.dart';

/// Iklan yang selesai saat [finish] dipanggil.
class _WaitingAds implements RewardedAds {
  Completer<bool>? _done;

  void finish(bool watched) => _done!.complete(watched);

  @override
  Future<bool> show() => (_done = Completer<bool>()).future;
}

class _BrokenAds implements RewardedAds {
  @override
  Future<bool> show() async => throw StateError('SDK');
}

class _BrokenSoundStore extends MemoryProgressStore {
  @override
  Future<void> saveSound(SoundSettings sound) async =>
      throw StateError('penyimpanan rusak');
}

void main() {
  late FakeSoundPlayer player;
  late MemoryProgressStore store;

  GameAudio audio([SoundSettings settings = SoundSettings.on]) =>
      GameAudio(player: player, store: store, settings: settings);

  setUp(() {
    player = FakeSoundPlayer();
    store = MemoryProgressStore();
  });

  test('sakelar tetap berubah walau gagal disimpan', () async {
    final a = GameAudio(player: player, store: _BrokenSoundStore());
    await a.setEffectsOn(false);
    await a.setMusicOn(false);
    expect(a.effectsOn, isFalse);
    expect(a.musicOn, isFalse);
  });

  test('load menyiapkan efek suara lebih dulu', () async {
    expect(player.preloaded, isFalse);
    await GameAudio.load(store: store, player: player);
    expect(player.preloaded, isTrue);
  });

  test('memuat sakelar tersimpan', () async {
    store.sound = const SoundSettings(music: false, effects: true);
    final a = await GameAudio.load(store: store, player: player);
    expect(a.musicOn, isFalse);
    expect(a.effectsOn, isTrue);
  });

  test('efek suara sampai ke pemain selama menyala', () {
    final a = audio()..play(GameSound.eat);
    expect(player.played, [GameSound.eat]);
    unawaited(a.setEffectsOn(false));
    a.play(GameSound.coin);
    expect(player.played, [GameSound.eat]);
  });

  test('setEffectsOn: disimpan dan pendengar diberi tahu sekali', () async {
    final a = audio();
    var notified = 0;
    a.addListener(() => notified++);
    await a.setEffectsOn(false);
    await a.setEffectsOn(false);
    expect(a.effectsOn, isFalse);
    expect(store.sound, const SoundSettings(effects: false));
    expect(notified, 1);
  });

  test('lagu yang diminta diputar; berganti lagu', () {
    final a = audio();
    expect(player.music, isNull);
    a.setTrack(MusicTrack.home);
    expect(a.track, MusicTrack.home);
    expect(player.music, MusicTrack.home);
    a.setTrack(MusicTrack.level);
    expect(player.music, MusicTrack.level);
    expect(player.musicStarts, 2);
  });

  test('musik mati menghentikan lagu, dinyalakan lagi memutarnya', () async {
    final a = audio()..setTrack(MusicTrack.home);
    await a.setMusicOn(false);
    expect(player.music, isNull);
    expect(store.sound, const SoundSettings(music: false));
    a.setTrack(MusicTrack.level);
    expect(player.music, isNull);
    await a.setMusicOn(true);
    expect(player.music, MusicTrack.level);
    expect(player.musicPaused, isFalse);
  });

  test('musik mati sejak awal: tidak ada lagu', () {
    audio(const SoundSettings(music: false)).setTrack(MusicTrack.home);
    expect(player.music, isNull);
    expect(player.musicStarts, 0);
  });

  test('ditahan dua alasan: jeda sampai keduanya dilepas', () {
    final a = audio()..setTrack(MusicTrack.home);
    a.hold(AudioHold.background);
    expect(player.musicPaused, isTrue);
    a.hold(AudioHold.ad);
    a.release(AudioHold.background);
    expect(player.musicPaused, isTrue);
    a.release(AudioHold.ad);
    expect(player.musicPaused, isFalse);
    expect(player.music, MusicTrack.home);
    expect(player.musicStarts, 1);
  });

  test('selama ditahan efek suara senyap', () {
    final a = audio()..hold(AudioHold.background);
    a.play(GameSound.tap);
    expect(player.played, isEmpty);
    a.release(AudioHold.background);
    a.play(GameSound.tap);
    expect(player.played, [GameSound.tap]);
  });

  test('lagu berganti selama ditahan: diputar saat dilepas', () {
    final a = audio()..setTrack(MusicTrack.home);
    a.hold(AudioHold.background);
    a.setTrack(MusicTrack.level);
    expect(player.music, MusicTrack.home);
    expect(player.musicPaused, isTrue);
    a.release(AudioHold.background);
    expect(player.music, MusicTrack.level);
    expect(player.musicPaused, isFalse);
  });

  group('pauseDuringAds', () {
    for (final watched in [true, false]) {
      test('musik dijeda selama iklan (selesai: $watched)', () async {
        final a = audio()..setTrack(MusicTrack.home);
        final inner = _WaitingAds();
        final ads = a.pauseDuringAds(inner);
        final shown = ads.show();
        expect(player.musicPaused, isTrue);
        inner.finish(watched);
        expect(await shown, watched);
        expect(player.musicPaused, isFalse);
      });
    }

    test('iklan error: musik lanjut dan errornya diteruskan', () async {
      final a = audio()..setTrack(MusicTrack.home);
      await expectLater(
        a.pauseDuringAds(_BrokenAds()).show(),
        throwsStateError,
      );
      expect(player.musicPaused, isFalse);
    });
  });
}
